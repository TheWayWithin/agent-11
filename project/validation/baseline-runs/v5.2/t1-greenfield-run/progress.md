# Progress — Tinylink BUILD

Chronological changelog. Append-only. Read on staleness checks or post-/clear reconstruction.

---

## 2026-05-03 — Phase 1 complete

**Deliverable**: `docs/user-stories.md` (6 INVEST stories + edge cases + locked scope + 5 KPIs)

**Files created**:
- `/Users/jamiewatters/DevProjects/agent-11/test-projects/t1-greenfield-run/docs/user-stories.md`

**Verification**: file present, opened with Read tool, content matches what was written. Persistence-bug check passed.

**Stories produced**:
- S1 — sign up with email + password
- S2 — sign in with email + password
- S3 — shorten a URL
- S4 — redirect on short-link visit
- S5 — my links page
- S6 — soft-delete a link

**Scope decisions locked** (will trigger vision-check if later phases drift):
- Email lowercased on storage; generic auth error messages (no enumeration).
- Short codes ≥ 5 chars alphanumeric, case-sensitive, never recycled.
- Redirect is 302 server-side; click logging non-blocking.
- No pagination on `/my-links`; most-recent-first sort.

**Issue**: nested-subagent context did not have the Task tool available, so coordinator could not delegate Phase 1 to the @strategist subagent. Worked around by producing the deliverable directly using strategist's INVEST format. Documented in project-plan.md Phase 1 row. No content quality compromise — ideation is the source of truth either way — but the user should review the stories file before Phase 2 since this differs from the standard delegation protocol.

**Next**: user gate — confirm stories quality, then pick a stack from the three options listed in the Phase 1 → Phase 2 handoff block in agent-context.md.

---

## 2026-05-03 — Phase 2 complete

**Deliverable**: `architecture.md` (11 sections, ~330 lines)

**Files created**:
- `/Users/jamiewatters/DevProjects/agent-11/test-projects/t1-greenfield-run/architecture.md`

**Verification**: file present (`ls -la`), full read confirms all 11 sections complete through §11 "Phase 4 entry criteria". Tail ends cleanly. Persistence-bug check passed.

**Stack locked** (user chose Option 3): Express 4 + EJS + better-sqlite3 on Railway with persistent volume. Node 20 LTS.

**Key technical decisions locked** (will trigger vision-check if later phases drift):
- Auth: server-side sessions (`express-session` + `better-sqlite3-session-store`), argon2id password hashing, 5-attempt/15-min in-memory login throttle, generic auth errors.
- Short-code: 6-char alphanumeric (62 symbols, ~5.7×10¹⁰ space), `crypto.randomBytes`-derived, UNIQUE constraint catches collisions, 5-attempt retry cap.
- Click logging: `setImmediate` after `res.redirect()` — redirect succeeds even if logging insert fails.
- Schema: 3 tables (users, links, clicks) + sessions table owned by store. FKs ON DELETE RESTRICT. UNIQUE on `links.code` reserves codes across soft-delete (no recycling).
- Route order: `/:code` MUST be registered last to avoid shadowing `/signup`, `/signin`, `/my-links`, `/shorten`, `/links/:id`.
- Security: CSRF via `csurf` on state-changing routes, parameterised queries everywhere, EJS auto-escape on, HTTPS-only cookies in prod, `httpOnly` + `sameSite=lax`.

**Issue**: Same as Phase 1 — nested-subagent context did not expose the Task tool, so coordinator wrote `architecture.md` directly in @architect role. Documented as deviation; output equivalent to a real specialist hop. Coordinator stream timed out before bookkeeping (project-plan.md / progress.md / Phase 2→4 handoff) completed; parent (Claude Code top level) finished those updates directly per Karpathy #6 "lightest valid path".

**Open question for user** (non-blocking, deferrable to Phase 7): Dockerfile vs rely on Railway Nixpacks autodetect? Default plan is Nixpacks.

**Next**: user gate — light review of `architecture.md` (especially §2 schema, §4 auth, §5 short-codes, §10 open question), then green-light Phase 4 implementation.

---

## 2026-05-03 — Architecture lock-in: EJS template pattern

**User feedback** (Jamie): the architecture left views/layout.ejs underspecified, and the wrapper-layout-with-`include('layout', ...)` pattern caused a recursive include bug in a previous build.

**Resolution**:
- `architecture.md` §7 file layout updated: replaced `layout.ejs` with `partials/header.ejs` + `partials/footer.ejs`.
- New §7 subsection "EJS template pattern (LOCKED — do not deviate)" added: explicitly forbids the wrapper pattern, documents the required `include('partials/header', { title })` ... `include('partials/footer')` composition.
- `agent-context.md` Phase 2 → Phase 4 handoff "Key implementation constraints" updated with the same rule.
- Saved as `feedback_ejs_layout_pattern.md` in user memory so the rule applies to all future EJS work, not just this project.

---

## 2026-05-03 — Phase 4 complete

**Deliverable**: working Tinylink MVP — 20 files, ~1,466 LOC.

**Files created** (verified on disk):

Root: `package.json`, `.env.example`, `.gitignore`, `server.js`, `db.js`
Routes: `routes/auth.js`, `routes/links.js`, `routes/redirect.js`
Lib: `lib/auth.js`, `lib/shortcode.js`, `lib/validate.js`
Views: `views/signup.ejs`, `views/login.ejs`, `views/my-links.ejs`, `views/error.ejs`, `views/partials/header.ejs`, `views/partials/footer.ejs`
Static + dirs: `public/styles.css`, `data/.gitkeep`

**Verification**:
- `ls -la` confirmed all files present.
- `views/layout.ejs` does NOT exist (forbidden wrapper pattern absent).
- `grep -c "include('layout'"` across all EJS files returns 0 — locked pattern honoured.
- `node --check server.js` passes.
- `node_modules/` correctly absent (install is user's job per protocol).
- File sizes plausible (server.js 4.9KB, db.js 2.2KB, etc.).

**Key implementation choices** (developer ambiguity resolutions, all noted by developer in handoff):
1. `cookie-parser` wired with `SESSION_SECRET` so `csurf` has a signed cookie source. Net effect matches architecture §4 intent.
2. Generic-error timing leak on login: developer chose NOT to add a dummy argon2 call on the unknown-email branch. Throttle bookkeeping runs both branches identically; ~tens-of-ms timing channel remains. Flagged for Phase 5 as defence-in-depth nice-to-have, not MVP blocker.
3. Signup duplicate-email: SELECT first for friendly error path, AND catch SQLITE_CONSTRAINT_UNIQUE on INSERT for race. Both render the same message.
4. Reserved-words filter: case-insensitive comparison (`code.toLowerCase()` vs the lowercase reserved set). Slightly stricter than necessary, harmless.
5. Root path `/`: signed-in → `/my-links`, else → `/login`. Doubles as Railway healthcheck (always 302).

**Structural improvement vs Phases 1-2**: I (top-level Claude Code) spawned `@developer` directly via Task tool. This was a **real specialist hop** — developer ran with its own context, used Read/Bash/Write directly, no nested-subagent + Task tool constraint, no stream-timeout (Phase 4 ran ~6.5 min cleanly). Recommend continuing this pattern for Phases 5-7.

**12 concerns flagged for Phase 5** (per developer handoff, captured in agent-context Phase 4 → Phase 5 block):
1. better-sqlite3 native build needs C++ toolchain (`xcode-select --install` if missing).
2. better-sqlite3-session-store pinned `^0.1.0` — small library, API stability moderate.
3. csurf is deprecated upstream (still functional; arch §8 explicitly requires it).
4. Login timing leak unknown-email vs wrong-password (defence-in-depth gap).
5. Click-count race under heavy concurrent load (not at personal scale).
6. CSRF failure UX when session expires.
7. Empty-state vs error display in my-links validation rejection path.
8. Soft-delete idempotency on non-existent id silently 302s — confirms architecture intent, but worth UX confirmation.
9. Session persistence across server restart (S2 AC5) needs explicit verification.
10. Incognito click count test (S4 acceptance scenario) needs automation.
11. requireAuth returns 401 on POST without auth (no CSRF refresh path) — reasonable for MVP.
12. No Dockerfile yet (Phase 7).

**Next**: user runs `cp .env.example .env && npm install && npm start`, opens `http://localhost:3000`, walks through signup → shorten → click in incognito → see count → soft-delete → 404 on the deleted code. If clean, Phase 5 begins (automated tests). If anything breaks, that's the next fix entry.

---

## 2026-05-03 — Phase 4 walkthrough: all 8 steps passed

User confirmed: `cp .env.example .env && npm install && npm start` succeeded. All 8 walkthrough steps green:

1. ✅ `/` redirects to `/login` when signed out.
2. ✅ Signup creates account, lands on `/my-links`. (S1)
3. ✅ Logout + login round-trip. (S2)
4. ✅ Server restart preserves session (sessions.db persistence). (S2 AC5)
5. ✅ Shorten produces a short code in the table. (S3)
6. ✅ Incognito visit to short URL → redirect → click count = 1. (S4, S5)
7. ✅ Delete removes link from table. (S6)
8. ✅ Deleted short URL returns 404, no redirect. (S6 AC2)

**Implication**: implementation is functionally correct against the locked acceptance criteria for all 6 stories. Phase 5 now adds automated coverage to lock these behaviours against regression.

---

## 2026-05-03 — Phase 5 complete

**Deliverable**: automated test suite — 9 files / 1,614 LOC of test code.

**Files created** (verified on disk):
- `test/kpi1-acceptance-scenario.test.js` — 1 integration test (full signup→shorten→visit→count→delete→404 path)
- `test/kpi2-per-user-isolation.test.js` — 2 tests (cross-user visibility + cross-user delete attempt)
- `test/kpi3-soft-delete.test.js` — 5 tests (404, row retained, `deleted_at` set, click history preserved, idempotent on already-deleted, 404 on non-existent code)
- `test/kpi4-shortcode-collision.test.js` — 7 tests (basic gen, charset, collision retry, exhaustion error, reserved-words filter — case-insensitive)
- `test/kpi5-persistence.test.js` — 3 tests (users/links/clicks survive fresh DB connection; sessions table exists on disk)
- `test/security-and-validation.test.js` — 14 tests (throttle, generic auth errors, URL validation, CSRF, requireAuth)
- `test/helpers/app.js` — test-only `createApp` factory mirroring `server.js` middleware order (forced by testability finding #1)
- `test/helpers/agent.js` — supertest agent + cookie/CSRF helpers + signup/login/shorten/delete utilities
- `test/helpers/env.js` — per-file unique tmp DB paths in `os.tmpdir()/tinylink-tests/`

**Modified**:
- `package.json` — added `"test": "node --test --test-force-exit \"test/*.test.js\""` script and `supertest@^7.2.2` as devDependency.

**Verification**:
- All 9 files present on filesystem (`ls -la test/ test/helpers/`).
- `package.json` confirmed updated.
- **`npm test` re-run from top-level Claude Code: 32 tests, 32 pass, 0 fail, 0 skip, 839ms.**
- TAP output clean exit (code 0).
- Per-file unique DBs in `os.tmpdir()/tinylink-tests/` — dev `data/` directory untouched.

**Test framework choices** (locked):
- `node:test` (Node 20 built-in) + `supertest@^7.2.2`. Zero extra deps beyond supertest.
- `--test-force-exit` required because csurf and/or session store keep the runner alive after suites finish. Available in Node 18.20+, 20.13+, 22+. User on older Node 20.0-20.12 would see hangs.
- DB isolation: per-file unique tmp paths via `os.tmpdir()`. Cleanup in `after()` hooks.
- No jest/mocha/chai/sinon. Aligns with architecture's "smallest dependency surface".

**4 testability findings** (no source changes made — flagged for user decision):

1. **`server.js` mixes app construction with `app.listen()`**. Test had to build parallel `createApp()` factory in `test/helpers/app.js` mirroring server.js middleware order. Maintenance trap: if `server.js` middleware order changes, helper drifts. Recommendation: refactor `server.js` to export `createApp()`; production entry calls `createApp().listen(PORT)`. Net diff would be small; tests would simplify (delete `test/helpers/app.js`, replace with `require('../../server.js').createApp()`).

2. **Dead branch in `lib/validate.js` `validateLongUrl`**: `if (!parsed.hostname)` is unreachable. Node's `new URL()` reinterprets `http:///path` as `http://path/`; `http://` alone throws at parse and goes through the `catch`. Behaviour is correct, the dead branch is just unreachable.

3. **`db.js` singleton with no reset path**. Fine on Node 20 default test isolation (each test file gets fresh module cache). Fragile on `--experimental-test-isolation=none`. Mitigated by per-file unique `DB_PATH`. A `_resetForTests()` export would make this explicit.

4. **`crypto.randomBytes` imported directly in `lib/shortcode.js`** rather than dependency-injected. Collision tests use module-level monkey-patch. Works but fragile.

**No real bugs found.** Implementation behaves as `architecture.md` and `docs/user-stories.md` specify across all 5 KPIs and the deterministic security concerns.

**Skipped intentionally** (per Phase 5 brief): login timing leak, click-count race under concurrent load, CSRF expired-session UX, real-process session-cookie replay, native-build verification, Phase 7 work.

**Next**: user gate — three options on the 4 testability findings:
- **A**: refactor `server.js` `createApp` factory now (addresses finding #1, biggest payoff). Findings #2-#4 are cosmetic.
- **B**: accept findings as documented limitations and proceed to Phase 6 (docs).
- **C**: do A only, then proceed.

---

## 2026-05-03 — `createApp` factory refactor (Phase 5 finding #1)

**User picked option C** — refactor finding #1, accept #2-#4 as documented limitations.

**Decision rationale**: finding #1 was the only structural finding (test helper duplicating server.js middleware order = real maintenance trap). Findings #2-#4 are cosmetic — dead branch, singleton without reset path, monkey-patched random — none affect correctness or block testing.

**Refactor done by top-level Claude Code directly** (small focused change, no need for @developer subagent):

**Files modified**:
- `/Users/jamiewatters/DevProjects/agent-11/test-projects/t1-greenfield-run/server.js` — wrapped middleware/route wiring in `function createApp(options = {})`. Production behaviour unchanged: `app.listen(PORT)` runs only when `require.main === module` (i.e. via `npm start`). Module exports `{ createApp }`. Options take env defaults so production callers omit them; tests override `sessionSecret`, `sessionDbPath`, `nodeEnv`, and `sessionStoreClearTimer`. Net: 161 → 195 lines (added JSDoc + factory wrapping, no duplicated logic).
- `/Users/jamiewatters/DevProjects/agent-11/test-projects/t1-greenfield-run/test/helpers/app.js` — replaced full middleware-order clone with a thin wrapper that calls `createApp` with test config. **150 → 37 lines** (~75% reduction). Single source of truth for middleware order is now `server.js`.

**Verification**:
- `node --check server.js` and `node --check test/helpers/app.js` both pass.
- `npm test` re-run: **32 tests, 32 pass, 0 fail, 916ms** — refactor preserves all behaviour.
- Production path (`npm start`) unchanged in behaviour: same env vars, same fail-fast on missing SESSION_SECRET, same listen-on-PORT message.

**Maintenance trap killed**: future middleware-order changes in `server.js` propagate to tests automatically. Helper drift is no longer possible.

**Findings #2, #3, #4 status**: accepted as documented limitations. Will be mentioned in Phase 6 README's "known limitations" section if material; otherwise just left in `progress.md` Phase 5 entry as the historical record.

---

## 2026-05-03 — Phase 6 (documentation) starting

Spawning `@documenter` (top-level direct spawn, same pattern as Phases 4 and 5). Brief includes Jamie's voice prefs (British English, no em-dashes in publishing content, no corporate-speak, banned words list).

---

## 2026-05-03 — Phase 6 complete

**Deliverable**: `README.md` at project root — 163 lines, single document for new readers.

**Files created**:
- `/Users/jamiewatters/DevProjects/agent-11/test-projects/t1-greenfield-run/README.md`

**Documenter context constraint**: spawned with Read-only access (Write/Bash unavailable in its context). Returned README content as a structured deliverable in its report. Top-level Claude Code wrote the content verbatim and ran the verification pass.

**Verification**:
- File on disk, 163 lines.
- `grep -c "—" README.md` returns 0 — no em-dashes in prose.
- `grep -i -E "leverage|delve|utili[sz]e|robust|seamless|unlock|empower|ecosystem" README.md` returns no matches — banned words absent.
- British spellings used throughout: behaviour, initialise, favour, licence.
- `npm test` re-run from top-level: **32 tests, 32 pass, 870ms** (consistent with prior runs, refactor + README work haven't broken anything).

**README sections** (in order):
1. One-liner description
2. What it does (3 sentences)
3. What it isn't (out-of-scope bullet list mirroring architecture.md §9)
4. Prerequisites (Node 20, npm, C++ toolchain notes for macOS / Debian / Windows)
5. Quickstart (3-command fenced block + per-command explanation)
6. Configuration (6-var env table + SESSION_SECRET generation hint)
7. Routes (10-row table from architecture.md §3)
8. Running tests (`npm test`, 32/32, ~900ms, framework note)
9. Project structure (directory tree)
10. Deploying to Railway (4-step sketch with env vars)
11. Known limitations (7 honest items including csurf deprecation + bot click counting)
12. Architecture (link to architecture.md and docs/user-stories.md)
13. Licence (placeholder — not yet chosen)

**Discrepancies caught and fixed**:
- agent-context.md Phase 5→6 handoff said "11 routes from architecture.md §3" but the table actually has 10 entries. Documenter caught this; corrected the handoff block. Source of truth (architecture.md §3) wins.

**Decisions made by documenter**:
- Skipped optional `docs/api.md` — README routes table is sufficient, separate file would be over-engineered.
- Did not edit `.env.example` — comments already clear, including SESSION_SECRET generation command.
- Left licence as "Not yet chosen" rather than invent one.
- Did not mention internal-only concerns in README (login timing leak, click-count race) — those are implementation hardening notes, not user-facing.

**Next**: user gate — Phase 7 is "deploy artefacts only" with three sub-decisions. Three options surface to user:
- A: Add Dockerfile + GitHub Actions CI workflow (lint + test).
- B: Skip Dockerfile (rely on Railway Nixpacks autodetect), add only CI workflow.
- C: Call the mission complete after Phase 6 — Railway autodetects from `package.json`, README documents deployment, no CI infra urgent for a personal project.

---

## 2026-05-03 — MISSION COMPLETE

**User picked option C**: wrap mission at Phase 6. Phase 7 (deploy artefacts) deferred — Railway autodetects from `package.json`, README documents deploy, no GitHub remote yet for CI to run against. Re-entry as a surgical fix mission when actually deploying.

### Final deliverables on disk

| Category | Files | LOC |
|---|---|---|
| Foundation docs | `ideation.md` (input), `docs/user-stories.md`, `architecture.md`, `README.md` | input + 700 |
| Application code | `server.js`, `db.js`, 3 × `routes/*.js`, 3 × `lib/*.js` | ~870 |
| Views + assets | 4 EJS pages, 2 partials, 1 CSS file | ~370 |
| Test suite | 6 KPI test files, 3 helpers | ~1,614 |
| Config | `package.json`, `.env.example`, `.gitignore` | ~70 |
| Tracking | `project-plan.md`, `agent-context.md`, `progress.md` | this file + 2 |

**Total**: ~30 files, ~3,600 LOC across application + tests + docs.

### Final verification

- `node --check server.js` and `node --check test/helpers/app.js` — both clean.
- `npm test` — **32 tests, 32 pass, 870ms** (last verified by top-level Claude Code at mission close).
- User walkthrough — all 8 manual steps passed (signup, login, session-restart persistence, shorten, incognito click count = 1, soft-delete, deleted-code 404).
- README — 163 lines, British English, no em-dashes, no banned corporate-speak words.
- No git commits, no remote pushes, no deploys (per persistent test-fixture rule).

### Structural process learnings (worth keeping for future missions)

1. **Nested subagent + Task tool incompatibility**: when `/coord` runs a coordinator as a subagent, that coordinator cannot delegate further via Task tool — Task is unavailable in nested context. Workaround used in Phases 1-2: coordinator wore the strategist/architect hats directly. Documented and surfaced to user.

2. **Stream timeouts on long subagent runs**: Phase 2 coordinator hit a 7.5-min idle timeout before completing bookkeeping. Architecture.md was complete on disk but project-plan.md / progress.md updates didn't land. Top-level Claude Code took over the bookkeeping. Lesson: subagent runs over ~5-7 min are at meaningful timeout risk.

3. **Parent-direct specialist spawning**: from Phase 4 onward, top-level Claude Code spawned `@developer` / `@tester` / `@documenter` directly via Task tool, bypassing the coordinator-as-subagent layer. This gave real specialist hops (no "wearing hats"), avoided the nested-Task constraint, and the per-task streams stayed under timeout limits. **Recommended pattern for future missions**: top-level orchestrates, specialists run as direct Task spawns, coordinator only used as a thin orchestration prompt rather than a long-running container.

4. **Documenter spawned with Read-only context**: in Phase 6, `@documenter` had no Write/Bash. Returned content as a structured deliverable in its report; top-level wrote files. Workaround pattern: agents that lack Write capability should return structured `file_operations` content, not claim "file created".

5. **Architecture docs need EJS pattern lock**: discovered mid-mission that views/layout.ejs underspecification + recursive `include('layout', ...)` is a real bug pattern from Jamie's prior builds. Saved as user-level feedback memory for all future EJS work.

6. **Greenfield refactor finding #1 fixed in flight**: Phase 5 surfaced `server.js` mixing app construction with `app.listen()`. Fixed via `createApp(options)` factory before mission close. Test helper shrank 150 → 37 lines. Maintenance trap killed.

### Open / deferred items (not bugs, not blockers)

- Phase 5 findings #2-#4 (cosmetic): dead branch in `validate.js`, `db.js` singleton without reset path, `crypto.randomBytes` direct import in `shortcode.js`. None affect correctness. Documented but unfixed.
- Phase 7 deploy artefacts (Dockerfile + CI workflow): deferred. Re-entry via `/coord fix add-ci-and-dockerfile` when actually deploying.
- Login timing leak (unknown-email vs wrong-password branch): defence-in-depth gap, not a bug. Documented in Phase 4 handoff and Phase 5 findings.
- csurf is deprecated upstream: still functional. README documents this. Replacement is future work.
- No password reset / email verification: per ideation non-goals. README documents this.
- Licence: README placeholder reads "Not yet chosen." User to pick when desired.

### Mission close checklist

- [x] All planned phases complete (1-2, 4, 5, 6) or explicitly deferred (3 SKIPPED, 7 DEFERRED).
- [x] All deliverables verified on disk.
- [x] Tests passing.
- [x] No commits, pushes, or deploys executed.
- [x] Tracking files (project-plan, progress, agent-context) consistent and up-to-date.
- [x] Re-entry paths documented for any future continuation work.
