# Tinylink

A minimal personal URL shortener.

## What it does

Sign up with an email and password, paste a long URL, get a short code back. Share the short URL; visiting it 302-redirects to the original. Your `/my-links` page lists every link you have created with its total click count. Soft-deleting a link makes the short URL return 404 while preserving the historical click data in the database.

## What it isn't

Tinylink is deliberately small. The following are out of scope and will not be added without a vision-check:

- Team accounts, shared workspaces, or any multi-tenant features
- Custom domains
- Detailed analytics (geography, referrers, time-series, per-day breakdowns). Only total click count is exposed
- Password reset or email verification. A forgotten password means a lost account
- Bulk import / export
- Marketing, pricing, landing, or admin pages
- OAuth or SSO
- Rate limiting beyond the auth-throttle described below
- Pagination on `/my-links`
- A visual design system. CSS is functional only

For the full list see `architecture.md` §9.

## Prerequisites

- Node.js 20 LTS (the `engines` field in `package.json` pins `20.x`)
- npm (bundled with Node)
- A working C++ toolchain. `better-sqlite3` is a native module and compiles on install
  - macOS: `xcode-select --install` if you have not already
  - Debian/Ubuntu: `sudo apt install build-essential python3`
  - Windows: install the "Desktop development with C++" workload from Visual Studio Build Tools

## Quickstart

From the project root:

```bash
cp .env.example .env
npm install
npm start
```

Then open `http://localhost:3000` in a browser. You will be redirected to `/login`; click "Sign up" to create an account.

What each step does:

- `cp .env.example .env` copies the environment template. The defaults work for local development out of the box. The placeholder `SESSION_SECRET` is fine for dev only; set a real one before deploying.
- `npm install` installs runtime and dev dependencies. The `better-sqlite3` native module compiles here; expect a few seconds of build output. You will also see a deprecation notice for `csurf` (see Known limitations).
- `npm start` runs `node server.js`. The app initialises the SQLite database at `./data/tinylink.db` (creating the directory if needed), runs the idempotent schema migration, and listens on `PORT` (default `3000`).

## Configuration

All configuration is via environment variables. `.env` is loaded automatically at startup via `dotenv`.

| Variable | Purpose | Required | Example |
|---|---|---|---|
| `NODE_ENV` | `production` toggles `secure` cookies (HTTPS only) and quieter error pages | yes | `development` |
| `PORT` | Port Express listens on. Railway injects this in production | yes | `3000` |
| `SESSION_SECRET` | Cookie signing secret. Must be a long random string in production | yes | (32 random bytes, hex-encoded) |
| `DB_PATH` | Path to the main SQLite file (users, links, clicks) | yes | `./data/tinylink.db` |
| `SESSION_DB_PATH` | Path to the session store SQLite file. Kept separate from the main DB so sessions can be wiped without touching user data | yes | `./data/sessions.db` |
| `BASE_URL` | Public URL used to render shareable short links (e.g. `{BASE_URL}/x4Ka9`) | yes | `http://localhost:3000` |

Generate a production `SESSION_SECRET`:

```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

In production on Railway, set `DB_PATH=/data/tinylink.db` and `SESSION_DB_PATH=/data/sessions.db` so both files land on the persistent volume.

## Routes

All routes are server-rendered HTML or redirects. There is no JSON API.

| Method | Path | Auth | Purpose |
|---|---|---|---|
| GET | `/` | optional | Redirects to `/my-links` if signed in, else `/login` |
| GET | `/signup` | none | Renders the signup form |
| POST | `/signup` | none | Creates the account, signs in, redirects to `/my-links` |
| GET | `/login` | none | Renders the login form |
| POST | `/login` | none | Verifies credentials, creates a session, redirects to `/my-links` |
| POST | `/logout` | required | Destroys the session, redirects to `/login` |
| GET | `/my-links` | required | Lists the user's active links with click counts; renders the create form |
| POST | `/shorten` | required | Creates a new short link, redirects to `/my-links` |
| POST | `/links/:id/delete` | required | Soft-deletes the link (idempotent), redirects to `/my-links` |
| GET | `/:code` | none | 302 to the long URL; logs the click best-effort. 404 on unknown or soft-deleted codes |

`GET /:code` is registered last so it cannot shadow the named routes. Short codes are 6 characters drawn from `[A-Za-z0-9]` and are case-sensitive (`x4Ka9` and `x4ka9` are different links).

## Running tests

```bash
npm test
```

Expected output: `32 tests, 32 pass`, completing in roughly 900ms.

The suite uses Node's built-in test runner (`node:test`) with `supertest` for HTTP assertions, matching the project's "smallest dependency surface" stack philosophy. Each test file gets a fresh SQLite file in the OS temp directory (`os.tmpdir()/tinylink-tests/...`), so running the suite has no impact on your local dev database in `./data`.

Tests share the same `createApp(options)` factory used by `npm start`, so the wiring under test is the same wiring that runs in production. There is no parallel test-only middleware stack to drift out of sync.

## Project structure

```
.
├── server.js              # Express bootstrap; exports createApp(options); listens only under `npm start`
├── db.js                  # better-sqlite3 connection + idempotent schema migration
├── routes/
│   ├── auth.js            # /signup, /login, /logout
│   ├── links.js           # /my-links, /shorten, /links/:id/delete
│   └── redirect.js        # /:code  (registered LAST in server.js)
├── lib/
│   ├── auth.js            # password hash/verify, login throttle, requireAuth middleware
│   ├── shortcode.js       # generateAndInsert() with collision retry
│   └── validate.js        # email, password, URL validators
├── views/                 # EJS templates with header/footer partials
├── public/                # static assets (minimal CSS)
├── data/                  # local-dev SQLite files (gitignored)
├── test/                  # node:test + supertest suite
├── package.json
├── .env.example
├── architecture.md        # locked design document
└── docs/
    └── user-stories.md    # the 6 user stories with acceptance criteria
```

## Deploying to Railway

The app is designed for Railway with a persistent volume. Sketch:

1. Create a Railway service from the repo. Railway's Nixpacks autodetects Node from `package.json` and uses `npm start` as the start command. No Dockerfile is included by default (this is an open Phase 7 decision, see Known limitations).
2. Attach a persistent volume mounted at `/data`.
3. Set the environment variables in the Railway dashboard:
   - `NODE_ENV=production`
   - `SESSION_SECRET` (generated as above; never reuse the dev placeholder)
   - `DB_PATH=/data/tinylink.db`
   - `SESSION_DB_PATH=/data/sessions.db`
   - `BASE_URL=https://your-domain.example`
   - `PORT` is injected automatically by Railway
4. Deploy. The schema migration runs idempotently on every startup, so first-boot creates the tables and subsequent boots are no-ops.

Behind Railway's TLS terminator, the app sets `trust proxy` so `secure` cookies work correctly when the platform forwards `X-Forwarded-Proto: https`.

## Known limitations

- **No password reset, no email verification.** A forgotten password means a lost account in v1.
- **In-memory login throttle.** 5 failed logins per email per 15-minute window returns 429. The counter lives in process memory, so it does not survive a restart and does not work across multiple processes. Single-process deployments only.
- **`csurf` is deprecated upstream.** It still works and is in use here. `npm install` will print a deprecation notice. Replacing it is a future task.
- **SQLite is single-writer.** Fine for personal use, not suitable for any team-scale workload.
- **No pagination on `/my-links`.** A personal user has tens of links, not thousands. Will need revisiting if that assumption breaks.
- **Bots count as clicks.** Every `GET /:code` increments the click counter, including link-preview crawlers. There is no bot filtering.
- **No Dockerfile yet.** Railway's Nixpacks autodetects Node from `package.json`. A Dockerfile may be added in Phase 7 if explicit control is wanted.

## Architecture

The full design (data model, route map, auth model, short-code algorithm, click-logging strategy, security posture, deployment shape) is in [`architecture.md`](architecture.md). User stories with acceptance criteria are in [`docs/user-stories.md`](docs/user-stories.md).

## Licence

Not yet chosen.
