# Agent Context: Tinylink Build

**Mission**: BUILD Tinylink MVP
**Started**: 2026-05-03
**Mode**: A — Greenfield, full tracking
**Source of truth**: `ideation.md`

---

## Mission Objectives

Build a minimal personal URL shortener for solo operators. Logged-in users paste a long URL, get a short code back, share it, and see total click counts on their "My links" page. Soft-delete sets short URLs to 404.

## Active Constraints

1. **Test fixture project** — no commits, pushes, deploys, or remote API calls without explicit user approval.
2. **Stack not pre-selected** — ideation lists Next.js, Remix, SvelteKit, Express + tiny frontend as candidates; SQLite or Postgres for storage. Final choice is a user gate at start of Phase 2.
3. **Deploy targets**: Railway / Vercel / Netlify — must remain deployable to these without extra infra.
4. **No OAuth** in MVP. Email + password only. No password reset, no email verification.
5. **Per-user isolation is non-negotiable** — each user only sees their own links.
6. **Persistence required** — data survives restart.
7. **Karpathy constitution applies** — read before writing, state assumptions, minimal diffs, verify by running, lightest valid path.

## Foundation Documents

- `ideation.md` — present, complete enough for MVP scope.
- `architecture.md` — does not yet exist; @architect produces it in Phase 2.
- `PRD.md` — not separately produced; @strategist's user-story output substitutes for MVP scale.
- `product-specs.md` — not applicable for this MVP.

## Recent Findings

### 2026-05-03 — Phase 2 (technical architecture) complete

- `architecture.md` produced at repo root (11 sections, ~470 lines).
- Stack locked per user choice (see Recent Critical Decisions).
- All 6 user stories mapped to specific routes in §3 route table.
- Schema specified: 3 main tables (users, links, clicks) + sessions table owned by store. All FKs use ON DELETE RESTRICT (no hard-delete in MVP).
- Soft-delete semantics: `deleted_at IS NULL` ⇒ active. Codes never recycled (UNIQUE constraint on `links.code` does this for free, even across soft-deleted rows).
- Security posture documented: CSRF via `csurf`, parameterised queries, EJS auto-escape, in-memory login throttle (5 attempts / 15 min / email).
- Open question for user (non-blocking, can answer at Phase 7): Dockerfile or rely on Railway Nixpacks autodetect? Default plan is Nixpacks (one step fewer).

### 2026-05-03 — Phase 1 (strategic analysis) complete

- 6 INVEST stories produced in `docs/user-stories.md`: signup, signin, shorten, redirect, my-links, soft-delete.
- Edge cases covered explicitly: collision regeneration, soft-deleted revisits returning 404, unauthenticated `/my-links` access, malformed URLs, per-user isolation, persistence across restart.
- Scope locked against ideation's non-goals list — surfaces as a vision-check trigger if a later phase tries to add team accounts, custom domains, password reset, etc.
- 5 MVP-level success signals defined (acceptance scenario, isolation test, soft-delete enforcement, collision unit test, persistence integration test). No production-grade SLOs.
- Architectural constraints implied by stories (for @architect at Phase 2):
  - Server-side redirect required (no client-side JS bounce) — rules out static-only stacks.
  - Session cookies are the natural fit for "persists across restart"; stateless JWT is allowed but should be flagged.
  - Single-process deployment to Railway / Vercel / Netlify required. **Filesystem ephemerality on Vercel/Netlify means SQLite is only viable on Railway with persistent volume.** This is the key tradeoff that shapes the stack-options menu.
  - Click logging must not block the redirect path.

## Recent Critical Decisions

- **Phase 3 (Designer) skipped** — user confirmed 2026-05-03. Ideation says "functional is fine". Phase row retained in plan, marked SKIPPED.
- **Phase 7 produces artefacts only** — user confirmed 2026-05-03. Dockerfile / platform config / `.env.example` / CI workflow files only. No execution, no remote pushes, no deploys.
- **Stack selection is a user gate** — user confirmed 2026-05-03. After Phase 1, present 2–3 stack options with tradeoffs (likely Next.js+Postgres, Remix+SQLite, Express+SQLite or similar) and let user pick. @architect does NOT pick the stack autonomously.
- **Stack locked: Option 3 — Express + EJS + better-sqlite3 on Railway with persistent volume** (user confirmed 2026-05-03). Reasoning: smallest dependency surface, line-by-line readable, server-rendered redirect path is trivial, SQLite + Railway volume satisfies persistence without standing up Postgres.
- **Auth: server-side sessions with argon2id password hashing** (Phase 2 decision). Stateless JWT rejected because S2 AC5/AC6 require persistent sessions and clean sign-out invalidation; a session table is lighter than a JWT denylist.
- **Short-code: 6-char alphanumeric (62 symbols), `crypto.randomBytes`-derived, collision-detected via UNIQUE constraint on INSERT, 5-attempt retry cap** (Phase 2 decision). 6 chars exceeds the S3 AC5 floor of 5 and gives ~5.7×10¹⁰ address space.
- **Click logging: synchronous SQLite write deferred via `setImmediate` after `res.redirect()` is sent** (Phase 2 decision). Satisfies S4 AC3 "redirect succeeds even if logging fails" without introducing a queue.

## Known Issues

None yet.

## Dependencies

- Phase 2 architecture decisions block Phase 4 implementation.
- Stack choice (user gate) blocks Phase 2 execution.

## Specialist Tool Permissions Notes

- Specialists cannot Write/Edit directly (per `library/CLAUDE.md` file-creation limitation). They must return `file_operations` JSON or specifications; coordinator executes Write/Edit and verifies on filesystem with `ls`/Read.

## Phase Handoff Blocks

### Phase Handoff: Phase 1 → Phase 2 (2026-05-03)

**From**: Coordinator (Phase 1, strategist role)
**To**: User (stack-selection gate), then @architect

**Deliverable**: `docs/user-stories.md` — 6 INVEST stories + cross-cutting requirements + locked scope + 5 KPIs.

**Key decisions locked**:
- Story scope: auth (signup + signin), shorten, redirect, my-links, soft-delete. No password reset, no email verification, no OAuth.
- Email casing normalised (lowercase) on storage to prevent duplicate-account drift.
- Generic auth error messages (do not leak account existence).
- Short codes are case-sensitive, ≥ 5 chars alphanumeric, never recycled (soft-deleted codes stay reserved).
- Redirect uses 302 (server-side, not JS bounce). Click logging is best-effort and non-blocking.
- Sort order on `/my-links`: most recent first. No pagination in MVP.

**Open scope questions**: none. Ideation was sufficient.

**For the user (decision needed before Phase 2)**:

Three candidate stacks for Tinylink. Coordinator will present these with tradeoffs and let user pick. Likely shortlist:

1. **Next.js (App Router) + Postgres on Railway** — most familiar stack, server actions handle redirect cleanly, Postgres is the safe default for persistence. Heaviest of the three.
2. **Remix + SQLite on Railway with persistent volume** — minimal, server-rendered by default, SQLite means zero external dependency. Cheapest to run.
3. **Express + minimal HTML templates (EJS or similar) + SQLite** — leanest, no framework magic, easiest to reason about line-by-line. Most "old school" but smallest surface area.

(Coordinator: present these with explicit tradeoffs — DX, deploy target compatibility, complexity — when user confirms stories are good.)

**For @architect (after stack is chosen)**:

- Use the stories as the contract. Design for them, not beyond them.
- Architectural constraints from stories are summarised in the "Recent Findings" block above — pay attention to the SQLite-on-Vercel/Netlify caveat.
- Phase 2 deliverable is `architecture.md` covering: data model (users, links, clicks), API contracts, short-code generation strategy with collision retry, auth/session approach, deployment shape for the chosen stack.

**Warnings / gotchas**:
- Persistence-bug protocol applies for any file creation: coordinator must execute Write/Edit and verify with `ls`/Read.
- Test fixture mode: no commits, no remote API calls, no deploys without explicit user approval.
- Phase 3 (designer) is SKIPPED. Phase 7 produces deploy artefacts only — no execution.

### Phase Handoff: Phase 2 → Phase 4 (2026-05-03)

**From**: Coordinator (Phase 2, architect role)
**To**: User (light review gate), then @developer

**Deliverable**: `architecture.md` (11 sections, ~330 lines, locked).

**Stack locked**: Express 4 + EJS + better-sqlite3 + argon2 + express-session + better-sqlite3-session-store + csurf. Node 20 LTS. Railway with persistent volume mount for SQLite + sessions.

**File layout (per architecture.md §7)**:
```
src/
  app.js              entry, registers middleware + routes (in order: static, session, csrf, auth, /shorten, /my-links, /links/:id, /:code LAST)
  db.js               better-sqlite3 connection + migrations (idempotent CREATE TABLE IF NOT EXISTS)
  auth.js             signup, signin, signout, password hashing
  links.js            shorten, redirect, list, soft-delete, short-code generation
  views/              EJS templates: layout, signup, signin, shorten, my-links, error pages
  middleware/         requireAuth, csrf wiring
public/
  styles.css          minimal functional CSS
package.json
.env.example
```

**Key implementation constraints**:
- `/:code` route registered LAST in `app.js` (otherwise it shadows `/signup`, `/my-links`, etc.)
- Migrations run on app startup, idempotent.
- Click logging: insert via `setImmediate` after `res.redirect(302, target)` returns control. Wrap in try/catch with `console.error` only — never bubble to user.
- Short-code generator: 6-char alphanumeric using `crypto.randomBytes(5).toString('base64url').slice(0, 6)` or equivalent. UNIQUE constraint on INSERT catches collisions. Retry max 5 times then 500.
- Per-user isolation enforced in every query: `WHERE user_id = ? AND deleted_at IS NULL`. Never trust `links.id` alone.
- Generic auth errors only: never reveal whether email is registered.
- **EJS template pattern (LOCKED, see architecture.md §7)**: NO `views/layout.ejs`. Use `views/partials/header.ejs` + `views/partials/footer.ejs`; every page does `<%- include('partials/header', { title }) %>` ... `<%- include('partials/footer') %>`. Wrapper-layout pattern with `include('layout', ...)` is FORBIDDEN — it recurses and crashes the renderer. (Documented because this pattern caused a real bug in a prior build.)

**For @developer (Phase 4)**:
- Use `architecture.md` §7 file layout, §3 route map, §2 schema as the contract.
- Use `docs/user-stories.md` acceptance criteria as the test contract for Phase 5.
- Phase 4 deliverable: working app from `npm install` → `npm start`, all 6 stories passing manually with the locked acceptance criteria. Tests come in Phase 5.
- Single migration file run on startup is acceptable — no migration framework needed for MVP.
- Do NOT add features beyond the 6 stories. Locked scope is in architecture.md §9.

**Open question for user (non-blocking, can answer at Phase 7)**:
- Dockerfile or Railway Nixpacks autodetect? Default is Nixpacks (one step fewer).

**Warnings / gotchas**:
- Same persistence-bug protocol applies for Phase 4 file creation.
- Subagent Task tool limitation persists: if Phase 4 coordinator runs as a subagent, expect to write source files directly rather than delegate to @developer.
- Phase 4 is the largest phase. Recommend the parent (top-level Claude Code) handle Phase 4 by spawning @developer directly, avoiding the nested-subagent + Task-tool problem and the stream-timeout risk that hit Phase 2.

### Phase Handoff: Phase 4 → Phase 5 (2026-05-03)

**From**: @developer (Phase 4, spawned from top-level — real specialist hop)
**To**: User (walkthrough gate), then @tester

**Deliverable**: working Tinylink MVP — 20 files / ~1,466 LOC. All files verified on disk. `node --check server.js` passes. No `views/layout.ejs`; zero `include('layout'` calls.

**User boot procedure** (run from project root):
```
cp .env.example .env       # one-time
npm install                # compiles better-sqlite3 native module — needs C++ toolchain (xcode-select --install if missing)
npm start                  # boots on http://localhost:3000
```

**Walkthrough script** (verifies the 6 stories):
1. Open `http://localhost:3000` → redirects to `/login`.
2. Click "Sign up" → enter `test@example.com` + password `password123` → land on `/my-links`. (S1)
3. Logout → log back in. (S2)
4. Stop server (Ctrl-C), restart with `npm start` → confirm still logged in. (S2 AC5 — sessions persist via `data/sessions.db`)
5. Paste `https://example.com/some/long/path` into shorten form → see new short code in table. (S3)
6. Open the short URL in an incognito/private window → redirects to long URL → return to logged-in window, refresh `/my-links` → click count = 1. (S4, S5)
7. Click delete on the link → row disappears from table. (S6)
8. Visit the deleted short URL → 404 page, not redirect. (S6 AC2)

**Key implementation decisions developer locked** (these matter for Phase 5 test design):
- `cookie-parser` wired with SESSION_SECRET so csurf has a signed cookie source.
- Generic-error login: throttle bookkeeping runs on both unknown-email AND wrong-password branches; argon2.verify only on wrong-password branch (small timing leak — Phase 5 defence-in-depth concern).
- Signup duplicate handling: SELECT-first for friendly error + catch SQLITE_CONSTRAINT_UNIQUE on INSERT race — both render same message.
- Reserved-words filter compares lowercase (`code.toLowerCase()` vs lowercase reserved set).
- `/` doubles as Railway healthcheck (always 302).
- WAL mode + foreign_keys pragma enabled in `db.js`.
- Two SQLite files: `data/tinylink.db` (users/links/clicks) + `data/sessions.db` (session store).

**For @tester (Phase 5) — required test coverage**:
- KPIs from `docs/user-stories.md` map to integration tests:
  - Acceptance scenario: signup → shorten → click in incognito → see count → delete → 404.
  - Per-user isolation: user A cannot see/delete user B's links via direct route access.
  - Soft-delete enforcement: deleted code returns 404, never redirects.
  - Collision unit test: stub `crypto.randomBytes` to force a collision and confirm retry-then-succeed.
  - Persistence: spawn server → insert → kill → respawn → confirm row + session both still there.
- Suggested test framework: native `node:test` (Node 20 has it built-in, zero extra deps) + `supertest` for HTTP assertions. Both align with the "smallest dependency surface" stack philosophy.
- Add to `package.json` as devDependencies and `npm test` script.

**12 concerns developer flagged for Phase 5** (full detail in `progress.md` Phase 4 entry):
1. better-sqlite3 native build (C++ toolchain).
2. better-sqlite3-session-store version pinning.
3. csurf upstream deprecation warning (informational only).
4. Login timing leak unknown-email vs wrong-password.
5. Click-count race under heavy concurrent load.
6. CSRF expired-session UX.
7. URL-validation error message UX.
8. Soft-delete idempotency on non-existent id (currently silent 302).
9. Session persistence across restart explicit test.
10. Incognito click-count automation.
11. requireAuth 401 on POST without auth (no CSRF refresh path).
12. No Dockerfile (Phase 7 work).

**Warnings / gotchas**:
- Phase 5 should NOT modify implementation to "fix" architecture-locked behaviour. Anything that requires changing locked decisions (auth model, short-code algorithm, click-logging strategy) needs a vision-check first.
- Test files go in `test/` directory. Add it to `package.json` test script. Don't pollute `routes/` or `lib/` with `.test.js` siblings — keep test code separate.
- Spawn `@tester` directly from top-level (same pattern as Phase 4) to avoid nested-subagent + stream-timeout issues.

### Phase Handoff: Phase 5 → Phase 6 (2026-05-03)

**From**: @tester (Phase 5, spawned from top-level — real specialist hop, ran ~88 min, 99 tool calls, completed cleanly)
**To**: User (refactor decision gate), then @documenter

**Deliverable**: 32-test suite, 32 pass, 839ms runtime. Detail in `progress.md` Phase 5 entry.

**Open user decision before Phase 6**: 4 testability findings, none of which are bugs. Most actionable is finding #1 (`server.js` mixes app construction with `app.listen()`). Three options: A (refactor now), B (accept and document), C (refactor #1 only).

**For @documenter (Phase 6) — required deliverables**:
- `README.md` at project root covering: what Tinylink is, prerequisites (Node 20+, C++ toolchain for native module), `cp .env.example .env && npm install && npm start` quickstart, `npm test` for tests, environment variables explained, deploy hint pointing at Phase 7 work, known limitations (no password reset, no horizontal scaling, csurf deprecation notice, in-memory throttle).
- A short API/route reference — can be a section in README or `docs/api.md`. Cover all 10 routes from architecture.md §3 (`/`, `/signup` GET+POST, `/login` GET+POST, `/logout`, `/my-links`, `/shorten`, `/links/:id/delete`, `/:code`) with auth requirement, purpose, and form fields where applicable.
- A configuration guide — likely a section in README. Just enumerate `.env.example` vars in plain English.
- Use the locked-scope and out-of-scope lists from architecture.md §9 to write the "what this is not" section. Important for managing future expectations.
- Style: Jamie's preferences — British English, no em-dashes in publishing-style content, no corporate-speak banned-words list (leverage, delve, utilize, robust, seamless, navigate-as-metaphor, unlock, empower, ecosystem). Keep it tight. README is the only "public" doc; internal tracking files don't need that style.

**Test commands user knows**:
- `npm install` — installs runtime + devDeps (supertest now included).
- `npm start` — boots app on port from `PORT` env var.
- `npm test` — runs full suite, ~900ms, exits 0 on success.

**Warnings / gotchas**:
- Phase 6 is just docs. No source changes. No test changes. If something turns up that needs implementation, that's a separate Phase 4 follow-up.
- Don't write fake docs — every claim in the README must match what the code actually does. Cross-reference architecture.md and the test suite for ground truth.

### Phase Handoff: Phase 6 → Phase 7 (2026-05-03)

**From**: @documenter (Phase 6, spawned with Read-only context — content returned to top-level for filesystem write)
**To**: User (scope decision), then potentially @operator

**Deliverable**: `README.md` (163 lines, all style rules respected, 32/32 tests still pass).

**Phase 7 scope** (per `project-plan.md`):
- Dockerfile or Railway Nixpacks autodetect
- `.env.example` + config docs (already done in Phase 4 + 6 README)
- CI workflow (lint + test) — file only, not pushed
- Brief deploy guide for Railway/Vercel/Netlify (already covered in README "Deploying to Railway" section)

**Real Phase 7 work remaining** (everything else is already done):
1. **Dockerfile** — open question from architecture.md §10. Default plan: skip, rely on Nixpacks. Adding it: ~20 lines, gives explicit control if Railway's autodetect ever drifts.
2. **CI workflow** (`.github/workflows/test.yml` or similar) — runs `npm install && npm test` on push/PR. Locks the 32/32 status against future regressions. Useful even if not pushed to a remote yet.

**Three options to surface to user**:
- A: do both (Dockerfile + CI workflow)
- B: do only CI workflow (skip Dockerfile per default plan)
- C: declare mission complete after Phase 6 (Railway autodetects, README documents deploy, CI not urgent for personal project, can be added later)

**For @operator (if Phase 7 proceeds)**:
- Dockerfile: based on `node:20-alpine` or `node:20-slim`. Multi-stage build is overkill for a single-file Express app; single-stage is fine. EXPOSE 3000, CMD `["node", "server.js"]`. Mount `/data` as a volume in docker-compose if doing local Docker testing.
- CI workflow: GitHub Actions, single job, ubuntu-latest, Node 20, `npm ci && npm test`. Cache `~/.npm` for speed. No deploy step (this is "artefacts only" per ideation).
- DO NOT push the workflow to a remote (no `git push` per persistent rule). Just produce the file.

**Warnings / gotchas**:
- This is the last phase. No further handoffs after this unless mission scope expands.
- No commits, no pushes, no actual deploys — even at Phase 7. Producing artefacts only.
- Spawn from top-level (same pattern as Phases 4/5/6) to avoid nested-subagent constraints.
