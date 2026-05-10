# Architecture — Tinylink MVP

**Mission**: BUILD Tinylink
**Source of truth**: `ideation.md`, `docs/user-stories.md`
**Author**: Coordinator (Phase 2, acting in @architect role — Task delegation unavailable in nested subagent context, see `progress.md`)
**Date**: 2026-05-03
**Status**: Phase 2 deliverable — locked for Phase 4 implementation

---

## 1. System overview

Tinylink is a single-process Node.js web app:

- **Runtime**: Node.js 20 LTS
- **HTTP framework**: Express 4
- **Templating**: EJS (server-rendered HTML)
- **Database**: SQLite via `better-sqlite3` (synchronous driver, single file on disk)
- **Sessions**: `express-session` with `better-sqlite3-session-store` (sessions persist across server restart, satisfying S2 AC5)
- **Hosting**: Railway, with a persistent volume mounted for the SQLite file and session store

Every request — including the `/:code` redirect — is handled server-side. There is no JS bundle, no client-side routing, no API layer separate from the page handlers. This satisfies S4's "no JS bounce" requirement and keeps the surface area small.

```
[browser] ──HTTP──▶ [Express app on Railway] ──read/write──▶ [SQLite file on persistent volume]
                                                            │
                                                            └──read/write──▶ [sessions table, same DB]
```

### Why this stack

The user picked Option 3 from the Phase 1 → Phase 2 handoff. Concretely it gives us:

- **No framework magic**: line-by-line readable. Easy to verify against user stories.
- **SQLite + Railway volume**: persistence (S2 AC5, S3, S4, S5, S6) without standing up Postgres.
- **Server-rendered HTML**: redirect path is trivial (`res.redirect(302, longUrl)` — no SSR hydration).
- **Smallest dependency surface** of the three candidates.

The deliberate tradeoff: SQLite is single-writer. For a personal-use shortener this is irrelevant; for any future team-mode it would be the wrong call. Out of scope per ideation.

---

## 2. Data model

Three tables. All timestamps stored as `INTEGER` Unix epoch milliseconds (SQLite lacks a true date type; ms-epoch is unambiguous and sortable).

### `users`

| Column          | Type    | Notes                                                |
|-----------------|---------|------------------------------------------------------|
| `id`            | INTEGER | PRIMARY KEY AUTOINCREMENT                            |
| `email`         | TEXT    | NOT NULL UNIQUE — stored lowercase, trimmed          |
| `password_hash` | TEXT    | NOT NULL — argon2id hash (includes params + salt)    |
| `created_at`    | INTEGER | NOT NULL — `Date.now()` at insert                    |

Index: `UNIQUE INDEX idx_users_email ON users(email)` (the UNIQUE constraint is sufficient; SQLite creates the index implicitly).

### `links`

| Column        | Type    | Notes                                                                  |
|---------------|---------|------------------------------------------------------------------------|
| `id`          | INTEGER | PRIMARY KEY AUTOINCREMENT                                              |
| `code`        | TEXT    | NOT NULL UNIQUE — case-sensitive (see §5)                              |
| `long_url`    | TEXT    | NOT NULL — validated http(s), max 2048 chars                           |
| `owner_id`    | INTEGER | NOT NULL REFERENCES users(id) ON DELETE RESTRICT                       |
| `created_at`  | INTEGER | NOT NULL                                                               |
| `deleted_at`  | INTEGER | NULL — when set, link is soft-deleted (S6)                             |

Indexes:
- `UNIQUE INDEX idx_links_code ON links(code)` — supports `GET /:code` lookup and uniqueness check on insert.
- `INDEX idx_links_owner_active ON links(owner_id, deleted_at, created_at DESC)` — supports `/my-links` query "all of user's non-deleted links, newest first".

**Soft-delete semantics**: `deleted_at IS NULL` ⇒ active. `deleted_at IS NOT NULL` ⇒ deleted. Codes are NEVER recycled (S6 edge case): the row stays, the UNIQUE constraint stays, so generation collision-checks against active *and* deleted rows automatically.

### `clicks`

| Column       | Type    | Notes                                                       |
|--------------|---------|-------------------------------------------------------------|
| `id`         | INTEGER | PRIMARY KEY AUTOINCREMENT                                   |
| `link_id`    | INTEGER | NOT NULL REFERENCES links(id) ON DELETE RESTRICT            |
| `clicked_at` | INTEGER | NOT NULL                                                    |

Index: `INDEX idx_clicks_link ON clicks(link_id)` — supports the COUNT(*) on `/my-links`.

We could store `COUNT(*)` directly on `links` as a denormalised counter and update it on each click. Decided against it: with SQLite + per-user scale, a `COUNT(*)` join is cheap and one fewer write per redirect. If the click table grows surprisingly large in personal use, switching to a counter is a contained migration.

**ON DELETE RESTRICT** on both FKs is deliberate: we never hard-delete users or links in MVP, so the FK is a guard against accidental cascading destruction. Soft-delete handles the only legitimate "delete" path.

### Sessions table

Owned by `better-sqlite3-session-store`. Schema is the library's responsibility (typically `sid TEXT PK`, `sess TEXT`, `expire INTEGER`). Stored in the same SQLite file for operational simplicity (one file to back up).

---

## 3. API / route map

All routes are server-rendered HTML pages or redirects. No JSON API in MVP.

| Method | Path             | Auth        | Purpose                                                    | User story |
|--------|------------------|-------------|------------------------------------------------------------|------------|
| GET    | `/`              | optional    | If signed in, redirect to `/my-links`. Else, redirect to `/login`. | — |
| GET    | `/signup`        | none        | Render signup form                                         | S1 |
| POST   | `/signup`        | none        | Create account, sign user in, redirect to `/my-links`      | S1 |
| GET    | `/login`         | none        | Render login form                                          | S2 |
| POST   | `/login`         | none        | Verify credentials, create session, redirect to `/my-links`| S2 |
| POST   | `/logout`        | required    | Destroy session, redirect to `/login`                      | S2 AC6 |
| GET    | `/my-links`      | required    | Render list of user's active links + click counts + create form | S3, S5 |
| POST   | `/shorten`       | required    | Create short link, redirect back to `/my-links`            | S3 |
| POST   | `/links/:id/delete` | required | Soft-delete (idempotent), redirect to `/my-links`          | S6 |
| GET    | `/:code`         | none        | 302 redirect to long URL; log click best-effort; 404 on unknown or deleted | S4 |

### Route ordering note

`GET /:code` is the broadest pattern. Express must register the named routes (`/signup`, `/login`, `/logout`, `/my-links`, etc.) **before** the `/:code` route, otherwise `/login` would be interpreted as a short code lookup. Implementation must respect this order.

A small reserved-words list (`signup`, `login`, `logout`, `my-links`, `shorten`, `links`) should also reject these as generated short codes (defensive — generator is random so collision probability is negligible, but explicit beats implicit here).

### Form-based mutations

We use HTML form POSTs (not fetch/XHR) for simplicity. This means CSRF protection is required (see §8).

`POST /links/:id/delete` rather than `DELETE /links/:id` because HTML forms cannot natively send DELETE. Method-override middleware is unnecessary complexity for MVP.

---

## 4. Auth model

**Decision**: server-side session cookies, signed, with session records in SQLite via `better-sqlite3-session-store`.

**Why not stateless JWT**: S2 AC5 requires sessions persist across server restart, and S2 AC6 requires a sign-out that "invalidates the session". Stateless JWT either (a) accepts that signed-out tokens remain technically valid until expiry, or (b) needs a denylist — at which point you may as well have a session table. Server-side sessions are the lighter path.

### Cookie configuration

- `name`: `tinylink_sid`
- `httpOnly: true` — JS cannot read it (XSS mitigation)
- `secure: true` in production (`process.env.NODE_ENV === 'production'`); `false` in local dev so `http://localhost` works
- `sameSite: 'lax'` — allows top-level navigation from external sites (links from elsewhere) but blocks cross-site form-POST CSRF in modern browsers; combined with explicit CSRF tokens (§8) for form mutations
- `maxAge`: 30 days (sliding session — refreshed on each request)
- `signed: true` via `SESSION_SECRET` env var

### Password hashing: argon2id

**Library**: `argon2` (the `node-argon2` package).

Argon2id is the OWASP-recommended modern default, resistant to GPU and side-channel attacks. Default parameters from the library are appropriate for this scale. Bcrypt would also be fine; picking one to keep this minimal.

Password requirements (per S1 AC5): minimum 8 characters. No upper-bound or composition rules — modern guidance (NIST 800-63B) is that length is what matters, and arbitrary composition rules push users to predictable patterns.

### Login throttling (S2 edge case)

5 consecutive failed logins per email within a 15-minute window returns 429 Too Many Requests. Implemented as an in-memory `Map<email, {count, firstFailureAt}>` reset on success or window expiry. Acceptable for single-process MVP; if the app ever scales horizontally this would need to move to the DB. Documented as a known limitation.

---

## 5. Short-code generation strategy

**Decision**: 6 alphanumeric characters, case-sensitive, drawn uniformly from `[A-Za-z0-9]` (62 symbols).

- Address space: 62⁶ ≈ 5.68 × 10¹⁰. At 1 million links the collision probability on insert is ≈ 1.7 × 10⁻⁵. For personal-scale use (tens to hundreds of links) it is essentially zero.
- 6 chars exceeds the S3 AC5 floor of 5. We pick 6 because it gives a meaningful safety margin without making URLs uglier.

### Algorithm

```
function generateCode():
    for attempt in 1..5:
        bytes = crypto.randomBytes(8)        // 8 random bytes
        code = base62-encode first 6 chars   // discard low bits
        if code in RESERVED_WORDS: continue
        try INSERT INTO links (code, ...) values (...)
        if INSERT succeeds: return code
        if INSERT fails on UNIQUE(code): continue
        else: re-raise
    raise CollisionExhausted          // → HTTP 500 with clear message
```

Key points:
- **Use `crypto.randomBytes`**, not `Math.random()`. Predictable random would let an attacker enumerate other users' links.
- **Generate-then-INSERT-and-check**: the UNIQUE constraint on `links.code` is the source of truth for collision detection. Doing a SELECT first creates a race window. Catching the SQLite UNIQUE-constraint failure on INSERT is the correct pattern.
- **Bound retries to 5**: with the address space above, 5 retries is overwhelming overkill, but unbounded retries are a footgun.
- **Reserved words**: route names (`signup`, `login`, `logout`, `my-links`, `shorten`, `links`) are filtered out before INSERT.
- **No code recycling across soft-delete** falls out for free: the soft-deleted row keeps the UNIQUE constraint on `code`, so a second user (or even the same user) trying to generate that code will collide and retry.

---

## 6. Click logging strategy

**Decision**: best-effort, fire-and-forget within the same Node.js process.

```
GET /:code:
    row = SELECT id, long_url FROM links WHERE code = ? AND deleted_at IS NULL
    if not row: return 404
    res.redirect(302, row.long_url)            // sent immediately
    setImmediate(() => {                       // queued after response
        try { INSERT INTO clicks (link_id, clicked_at) VALUES (?, ?) }
        catch (err) { log.warn('click_log_failed', err) }
    })
```

Why this satisfies S4 AC3 ("if logging fails, the redirect still succeeds"):
- The redirect response is written first.
- The DB insert is scheduled via `setImmediate`, runs after the current tick, and its error path is `log.warn`, not `throw`. The user already has their redirect.

`better-sqlite3` is synchronous — there is no async DB driver to fight. The "fire-and-forget" effect is achieved by deferring the insert to the next tick rather than by spawning a queue or worker. Adequate for personal scale; would need rethinking at any meaningful concurrency.

---

## 7. Deployment model (Railway, artefacts only)

Per project constraint, this phase produces config; nothing is deployed.

### Service shape

- Single Node.js service.
- Start command: `node server.js` (or `npm start`).
- Build command: `npm ci` (or `npm install --production` if no devDeps needed at build time).
- Health check: `GET /` returns 302 (signed-out → /login). Sufficient liveness signal.

### Persistent volume

- Mount path: `/data`
- Files in this directory:
  - `/data/tinylink.db` — main SQLite database (users, links, clicks)
  - `/data/sessions.db` — session store (could be the same file as `tinylink.db`; keeping separate for operational clarity, e.g. you can wipe sessions without touching user data)

### Environment variables

| Var               | Purpose                                              | Required | Example                       |
|-------------------|------------------------------------------------------|----------|-------------------------------|
| `NODE_ENV`        | `production` toggles secure cookies, error verbosity | yes      | `production`                  |
| `PORT`            | Express listen port (Railway injects this)           | yes      | `3000`                        |
| `SESSION_SECRET`  | Cookie signing secret (≥ 32 random bytes)            | yes      | `<generated>`                 |
| `DB_PATH`         | Path to main SQLite file                             | yes      | `/data/tinylink.db`           |
| `SESSION_DB_PATH` | Path to session SQLite file                          | yes      | `/data/sessions.db`           |
| `BASE_URL`        | Public URL used to build shareable links            | yes      | `https://tinylink.app`        |

Local-dev defaults (in `.env.example`): `NODE_ENV=development`, `PORT=3000`, `DB_PATH=./data/tinylink.db`, `BASE_URL=http://localhost:3000`, etc.

### File layout (proposed for Phase 4)

```
.
├── server.js                # Express bootstrap, route registration, listen()
├── db.js                    # better-sqlite3 instance + schema migrations
├── routes/
│   ├── auth.js              # /signup, /login, /logout
│   ├── links.js             # /my-links, /shorten, /links/:id/delete
│   └── redirect.js          # /:code  (registered LAST)
├── lib/
│   ├── shortcode.js         # generateCode() with collision retry
│   ├── validate.js          # url + email + password validators
│   └── auth.js              # password hash/verify, requireAuth middleware
├── views/                   # EJS templates — see "EJS template pattern" below
│   ├── partials/
│   │   ├── header.ejs       # opens <html>, <head>, nav, <body>
│   │   └── footer.ejs       # closes </body>, </html>
│   ├── signup.ejs
│   ├── login.ejs
│   └── my-links.ejs
├── public/                  # static assets (minimal CSS only)
│   └── styles.css
├── data/                    # local-dev SQLite files (gitignored)
├── test/                    # tests (Phase 5)
├── package.json
├── .env.example
└── Dockerfile               # produced in Phase 7 if Railway needs one (often it does not)
```

### EJS template pattern (LOCKED — do not deviate)

There is **no** `views/layout.ejs`. Pages compose via header/footer partials, not a wrapper layout.

**Required pattern** in every page template:

```ejs
<%- include('partials/header', { title: 'My Links' }) %>

<!-- page-specific content here -->

<%- include('partials/footer') %>
```

**Forbidden pattern** (causes recursive include and crashes the renderer):

```ejs
<%# DO NOT DO THIS — layout.ejs as wrapper that pages include('layout', ...) recurses %>
<%- include('layout', { body: '...' }) %>
```

If a page needs different `<head>` content (per-page title, meta), pass it through the `header` partial's locals (e.g. `include('partials/header', { title })`). Do not introduce a `layout.ejs` wrapper to solve this — extend the header partial instead.

This pattern is locked at the architecture level because the wrapper-layout-with-recursive-include pattern caused a real bug in a prior build. Phase 4 implementation must follow it. Any deviation requires a vision-check.

---

## 8. Security posture

| Concern              | Mitigation                                                                       |
|----------------------|----------------------------------------------------------------------------------|
| Password storage     | argon2id with library defaults; never plaintext (S1 AC6)                         |
| Account enumeration  | Generic "invalid email or password" on login failure (S2 AC2/AC3)                |
| Session hijacking    | `httpOnly`, `secure` (in prod), `sameSite=lax`, signed cookies                   |
| CSRF                 | `csurf` middleware on all state-changing POSTs (`/signup`, `/login`, `/shorten`, `/links/:id/delete`, `/logout`); token rendered in every form |
| XSS                  | EJS auto-escapes `<%= %>` interpolations; no use of unescaped `<%- %>` for user-controlled content |
| SQL injection        | All queries use parameterised prepared statements (`better-sqlite3` `prepare(...).run(?, ?)`) — never string concatenation |
| Open redirect        | The redirect target is the URL the user themselves submitted. They have already chosen to share it. Validation rejects non-http(s) schemes (S3 edge cases) so we cannot become a redirector to `javascript:` or `data:` URLs. |
| Brute-force login    | In-memory throttle: 5 failed attempts per email per 15 minutes → 429             |
| URL validation       | `new URL(input)`; require protocol ∈ {`http:`, `https:`}; reject if length > 2048; reject if hostname empty |
| Cross-user access    | Every link query filters by `owner_id = req.session.userId`; never trusts route params for ownership (S5 AC3, S6 cross-user edge case) |

**Rate limiting beyond auth-throttle**: explicitly out of scope per ideation. README will document this as a known limitation.

**HTTPS**: Railway terminates TLS at the load balancer; the Node app speaks plain HTTP behind it. `secure: true` cookies still work because Railway sets `X-Forwarded-Proto: https`; Express must `app.set('trust proxy', 1)` so `req.secure` is correctly inferred. This is required for cookies to be sent in production.

---

## 9. Out of scope (explicit, mirrors ideation)

The following are NOT in this architecture and any later phase trying to add them must trigger a vision-check:

- Team accounts / shared workspaces.
- Custom domains.
- Detailed analytics: geography, referrers, time-series charts, per-day breakdowns. Only total click count per link is exposed.
- Password reset / email verification. Forgotten password = lost account in v1.
- Bulk import / export.
- Marketing / landing / pricing / admin pages.
- Rate limiting beyond the auth throttle described in §4.
- OAuth / SSO.
- Visual design system. CSS is minimal and functional.
- Horizontal scaling. Single-process SQLite is the model.
- Background workers / queues.
- Pagination on `/my-links`.

---

## 10. Open questions for the user (before Phase 4)

None blocking. One optional preference:

- **Do you want a `Dockerfile` in Phase 7, or rely on Railway's Nixpacks autodetection?** Either works; Nixpacks is one-step less. Default plan: skip Dockerfile, let Railway autodetect Node from `package.json`. Flag if you want explicit Dockerfile.

That can be answered at Phase 7. No blocker for Phase 4.

---

## 11. Phase 4 entry criteria — what implementer needs

- This file (`architecture.md`) — locked.
- `docs/user-stories.md` — the contract.
- `ideation.md` — for non-goals reference.
- Stack: Express 4, EJS, better-sqlite3, argon2, express-session, better-sqlite3-session-store, csurf. Node 20.
- File layout: per §7 above.
- Route order constraint: `/:code` registered last.
- Schema: per §2; expose as a single migration file run on app startup (idempotent CREATE TABLE IF NOT EXISTS + CREATE INDEX IF NOT EXISTS).
- Test scaffold (for Phase 5): see KPIs in `docs/user-stories.md` for the required automated tests.
