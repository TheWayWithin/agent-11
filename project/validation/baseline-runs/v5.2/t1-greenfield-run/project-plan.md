# Project Plan: Tinylink MVP

**Mission**: BUILD
**Started**: 2026-05-03
**Source**: `ideation.md`
**Mode**: A (Greenfield)
**Status**: MISSION COMPLETE (2026-05-03) — Phase 7 deferred per user (option C). Working app + 32/32 tests + README delivered. No git commits or deploys per persistent test-fixture rule.

---

## Vision Summary

**Product**: Tinylink — a minimal personal URL shortener web app.
**Core Value Proposition**: Solo operators get a tidy personal short-link namespace + basic per-link click stats without paying for Bitly.
**Target Users**: Writers, consultants, indie devs who share links on social media.
**Success Metric**: A new user can sign up, create a short link, click it in incognito, and see the click counted on their "My links" page.
**Key Constraints**:
- Test fixture project — no production deploys without explicit user approval.
- Stack must be lightweight and deployable to Railway / Vercel / Netlify.
- Minimal infrastructure footprint (SQLite or Postgres).
**Non-Negotiables**:
- Email + password auth (no OAuth in MVP).
- Per-user link isolation (each user only sees their own links).
- Short-code collision handling.
- Data persists across restart.
- Soft-delete (deleted short URLs return 404).
**Explicit Out-of-Scope**:
- Team/shared workspaces.
- Custom domains.
- Detailed analytics (geography, referrers, time-series).
- Password reset / email verification (post-MVP).
- Bulk import/export.
- Marketing/landing/admin pages.
- Rate limiting beyond sensible defaults.
- Fancy UI.

---

## Mission: BUILD Tinylink

### Phase 1: Strategic Analysis — COMPLETE (2026-05-03)
- [x] Create INVEST user stories from ideation (@strategist) — `docs/user-stories.md`
- [x] Define acceptance criteria per story (@strategist) — 6 stories, numbered AC each
- [x] Identify edge cases and error states (@strategist) — covered per-story + cross-cutting
- [x] Confirm MVP scope vs deferred (@strategist) — locked in "Confirmed scope vs non-goals"
- [x] Define success metrics / KPIs (@strategist) — 5 MVP-level signals defined

**Note**: Task delegation to @strategist subagent was unavailable (nested-subagent context), so coordinator produced the stories directly using the strategist's INVEST format and ideation as source. Output is equivalent in structure; user should review for content quality before Phase 2.

### Phase 2: Technical Architecture — COMPLETE (2026-05-03)
- [x] Stack decision (user gate) — Option 3: Express + EJS + better-sqlite3 on Railway with persistent volume
- [x] Component design and data model (@architect) — 3 tables (users, links, clicks) + sessions, FK ON DELETE RESTRICT
- [x] API contracts (@architect) — 11 routes across auth/shorten/redirect/my-links/soft-delete in `architecture.md` §3
- [x] Short-code generation strategy (@architect) — 6-char alphanumeric, `crypto.randomBytes`, UNIQUE collision detect, 5-attempt retry cap
- [x] Auth/session strategy (@architect) — argon2id + `express-session` + `better-sqlite3-session-store` (sessions persist across restart)
- [x] `architecture.md` produced (@architect) — 11 sections, ~330 lines, locked for Phase 4

**Note**: Same nested-subagent constraint as Phase 1 — coordinator wrote `architecture.md` directly in @architect role. Documented in `progress.md`. One non-blocking question for the user, deferrable to Phase 7 (Dockerfile vs Nixpacks autodetect).

### Phase 3: Design & UX — SKIPPED
User confirmed 2026-05-03: ideation says "functional is fine", no designer phase. Row retained for traceability.

### Phase 4: Implementation — COMPLETE (2026-05-03)
- [x] Project scaffold + dependencies — `package.json`, `.env.example`, `.gitignore`
- [x] Database schema + migrations — `db.js` with idempotent `CREATE TABLE/INDEX IF NOT EXISTS`, WAL + foreign_keys pragmas
- [x] Auth: signup, login, session — `routes/auth.js`, `lib/auth.js` (argon2id, in-memory throttle 5/15min, generic errors, session.regenerate)
- [x] Shorten endpoint + collision handling — `routes/links.js`, `lib/shortcode.js` (6-char base62 via `crypto.randomBytes`, UNIQUE-constraint retry, max 5 attempts, reserved-words filter)
- [x] Redirect + click logging — `routes/redirect.js` (302 first, `setImmediate` insert in try/catch)
- [x] My links page — `views/my-links.ejs` + table render with click counts via COUNT(*) join
- [x] Soft-delete endpoint — `POST /links/:id/delete`, idempotent
- [x] Server-rendered minimal UI — EJS partials pattern (header.ejs + footer.ejs, NO layout.ejs), CSRF tokens on all forms, minimal CSS

**Note**: Spawned `@developer` directly from top-level Claude Code (not through coordinator subagent), avoiding the nested-Task-tool constraint that hit Phases 1-2. Real specialist hop. 20 files / ~1,466 LOC. Full file list and 12 Phase-5 concerns in `progress.md` + agent-context Phase 4 → Phase 5 handoff.

### Phase 5: Quality Assurance — COMPLETE (2026-05-03)
- [x] Unit tests (collision, auth, soft-delete) — `kpi3-soft-delete.test.js`, `kpi4-shortcode-collision.test.js`, security suite
- [x] Integration tests (signup → shorten → redirect → see click → delete → 404) — `kpi1-acceptance-scenario.test.js`
- [x] Edge case validation — URL validation (5 tests), CSRF (4 tests), throttle, generic auth errors, requireAuth
- [x] Per-user isolation verified — `kpi2-per-user-isolation.test.js` (2 tests covering visibility + cross-user delete attempt)

**Stack**: `node:test` (Node 20 built-in) + `supertest@^7.2.2` (only new devDep). Aligns with architecture's "smallest dependency surface" stance.

**Result**: 32 tests / 10 suites / **32 pass / 0 fail** / 839ms runtime. Re-run with `npm test`.

**Coverage by KPI**: 1 acceptance, 2 isolation, 5 soft-delete, 7 collision (incl. exhaustion + reserved-words), 3 persistence, 1 throttle, 2 generic-error, 5 URL-validation, 4 CSRF, 2 requireAuth.

**4 testability findings** (no source changes made; flagged for separate decision):
1. `server.js` mixes app construction with `app.listen()` → forced parallel test-only `createApp` factory in `test/helpers/app.js`. Refactor recommendation: extract `createApp()` and have prod entry call `createApp().listen(PORT)`.
2. `lib/validate.js` `validateLongUrl` has unreachable `!parsed.hostname` branch (Node's `new URL()` reinterprets `http:///path` as `http://path/`). Behaviour correct via the `catch`; dead branch only.
3. `db.js` exposes singleton with no reset path — fine on Node 20 default test isolation, fragile on `--experimental-test-isolation=none`.
4. `crypto.randomBytes` imported directly (not injected) in `lib/shortcode.js` — collision tests use module-level monkey-patch. Acceptable but fragile.

**Skipped intentionally** (per Phase 5 brief): login timing leak, click-count concurrent-load race, CSRF expired-session UX, real-process session-cookie replay, native build verification, Phase 7 work.

### Phase 6: Documentation — COMPLETE (2026-05-03)
- [x] README with run/test instructions — `README.md` (163 lines)
- [x] API reference — included as routes table in README (10 routes from architecture.md §3); separate `docs/api.md` deemed unnecessary, kept tight
- [x] Configuration guide — included as env-var table in README (6 vars with examples + SESSION_SECRET generation command)

**Style adherence verified**:
- British English throughout (behaviour, initialise, favour, licence)
- Zero em-dashes (`grep -c "—" README.md` returned 0)
- Zero banned corporate-speak words (leverage / delve / utilize / robust / seamless / unlock / empower / ecosystem) — `grep -i -E` confirmed
- 163 lines (target was 150-300)

**Documenter context note**: @documenter spawned with Read-only tool access (Write/Bash unavailable in its context). Returned README content; top-level Claude Code wrote it to disk and ran final `npm test` verification (32/32 pass, 870ms post-Phase-6). One discrepancy caught by documenter and fixed: agent-context.md Phase 5→6 handoff said "11 routes" but architecture.md §3 has 10. Corrected in handoff block.

### Phase 7: Deployment Artefacts — DEFERRED (2026-05-03)
- User picked option C: wrap mission at Phase 6.
- Reasoning: Railway autodetects Node from `package.json`, README documents deploy steps, no GitHub remote exists yet for CI to run against. Adding artefacts now is speculative work.
- Deferred items (do as a surgical fix mission when actually deploying):
  - Dockerfile (~20 lines, optional — Nixpacks autodetect is the default plan)
  - GitHub Actions CI workflow (`.github/workflows/test.yml`, runs `npm ci && npm test`)
- `.env.example` already done in Phase 4. Config docs already in README.
- Re-entry: `/coord fix add-ci-and-dockerfile` or similar.

---

## Current State

- **Active phase**: NONE — mission complete.
- **Final state**: Working Tinylink MVP at this directory. Run `npm start` to boot, `npm test` for the 32-test suite. README.md is the entry point for any new reader.
- **Uncommitted**: All Tinylink files are working-tree only. No git commits made (test-fixture rule). User may commit at their discretion.
- **Re-entry options**:
  - `/coord fix <issue>` — surgical fix for any issue surfaced in the walkthrough or future use.
  - `/coord deploy` (or `/coord fix add-ci-and-dockerfile`) — pick up the deferred Phase 7 artefacts.
  - `/coord refactor` — address Phase 5 testability findings #2-#4 if they ever bite (not currently expected).

---

## Risks & Mitigation

| Risk | Mitigation |
|------|-----------|
| Stack chosen without user input | Stop before Phase 2, present 2–3 options |
| Persistence bug (Task tool + Write) | Coordinator executes Write itself; verify with `ls`/Read after every delegation |
| Scope creep into post-MVP features | Lock to ideation's "Non-goals" list; surface anything beyond it as a vision-check |
| Auth without password reset is fragile | Acceptable per ideation; document the limitation in README |

---

## Specialist Assignments (Planned)

| Phase | Lead | Support |
|-------|------|---------|
| 1 | @strategist | — |
| 2 | @architect | @developer |
| 4 | @developer | @tester |
| 5 | @tester | @developer |
| 6 | @documenter | @developer |
| 7 | @operator | @developer |
