# Harness Results — Milestone v6.0

**Version / Sprint**: v6.0 cumulative (Sprints 4a–4h shipped to main)
**Commit SHA**: f92e745 (start of run); coordinator.md frontmatter modified mid-run (uncommitted) — see "Frontmatter Fix" section
**Executor**: Claude (Option B — fresh `claude` session in each fixture dir, Jamie observes and records)
**Date(s) of run**: 2026-05-02 evening through 2026-05-03 morning
**Status**: ⚠️ **v6.0 RELEASE BLOCKED** — two critical bugs found; see "Release Blockers" section.

---

## TL;DR

The harness caught two bugs that block v6.0 release, plus a process bug in the harness itself:

1. **Frontmatter format bug** (RELEASE BLOCKER): Library agents use `tools: { primary: [...] }` nested YAML. This format is not parsed by Claude Code's runtime. Coordinator and all 11 specialists therefore launch without their declared tools (notably without Task), and fall back to emitting tool-call syntax as text. Result: every coordinator delegation observed in v6.0 returned `tool_uses: 0` until the frontmatter was rewritten flat.
2. **Quality regression** (RELEASE BLOCKER): With the frontmatter fix applied, T1's coordinator built a 22-file MVP in ~13 minutes (vs v5.2's 34 minutes) but the build is functionally broken: 4 of 6 smoke tests fail due to recursive EJS-include layout, and the coordinator reported "Live curl on :3457/health → ok" without actually running the smoke tests it had been told to verify. Speed gain from "lightest valid path" came at the cost of verification rigor.
3. **Harness bug** (FIXED): `cp -R fixtures/X test-projects/X-run` on macOS copies *into* an existing directory, leaving stale state from prior runs at the top level and the fresh fixture nested. Affected T2/T3/T4 results before fix. Run-playbook now `rm -rf` the run dir before cp; T2 was re-run cleanly to prove the fix.

Recommendation: do not tag v6.0.0 until both blockers are resolved.

---

## Caveats for this milestone

- **Apples-to-apples concern (M2)**: v6.0 fresh sessions show ~26.3k tokens of MCP tools loaded at session start (Gmail, Calendar, GitHub, Railway, etc.) from Jamie's global config. The v5.2 baseline (49.3k total) likely ran with different MCP loading. Direct M2 comparison is therefore noisy — the cleanest read is the *delta* in the non-MCP categories.
- **M1 proxy**: Wall-clock not stopwatched on every run; "Cogitated/Brewed/Sautéed/Crunched for X" lines from the model output are used as a thinking-time proxy. True wall-clock is typically +30-60s for tool calls and rendering.
- **Per-sprint granularity lost**: Original Sprint 4a plan was per-sprint milestone runs. Since all sprints shipped to `main` without those runs, this is a single cumulative v6.0 vs v5.2 measurement.
- **Test contamination on T2/T3/T4 first-pass runs**: Before the harness `rm -rf` fix, the cp pollution affected results. T2 was re-run cleanly post-fix; T3 and T4 results below are the first-pass numbers (model navigated the contamination, results valid-with-asterisk).
- **Frontmatter fix applied mid-run**: T5, T2-first-pass, T3, and T4 all ran against the broken nested-frontmatter coordinator. T1 ran against the flat-frontmatter coordinator (only coordinator was patched, not the 11 specialists). All deltas should be read with this in mind.

---

## Per-Task Results

### Task 5 — Commit Review

| Metric | v5.2 baseline | v6.0 (broken frontmatter) | Delta |
|--------|---------------|---------------------------|-------|
| M1 completion time | 1m 37s ("baked"); ~3 min wall | ~2m 27s ("Cogitated") | +50s thinking-time |
| M2 session-start tokens | 49.3k (5%) | 85.9k (9%) | +36.6k |
| M3 delegation count | 0 (handled directly) | 0 (handled directly) | unchanged |
| M4 human interventions | 0 | 0 | unchanged |
| Outcome | ✅ 3 blockers, 7 concerns, 5 nits | ✅ 0 blockers, 7 concerns, 4 nits | comparable depth |

**Notes**: Both versions self-route this task to direct execution. v6.0 explicitly cites "Lightest valid path" — Karpathy guidance from Sprint 4b at work. Quality of review is comparable. M2 is up but most of the gap is the MCP-tools environmental difference.

### Task 2 — Feature Addition (re-run after harness fix)

| Metric | v5.2 baseline | v6.0 first-pass (contaminated) | v6.0 clean (broken frontmatter) | Delta vs baseline (clean run) |
|--------|---------------|--------------------------------|---------------------------------|--------------------------------|
| M1 completion time | 2m 51s ("brew") | ~2m 36s ("Brewed") | ~4m 45s ("Brewed") | +1m 54s |
| M2 session-start tokens | 49.5k (5%) | 86.2k (9%) | 85.4k (9%) | +35.9k |
| M3 delegation count | 2 (both empty) | 2 (both empty) | **0** — skipped delegation as overkill | -2 |
| M4 human interventions | 0 | 0 | 0 | unchanged |
| Outcome | ✅ /health endpoint created | ❌ "already done" (false; reading stale v5.2 leftovers from polluted run dir) | ✅ /health created + curl-verified live | enhanced verification |

**Notes**: The clean re-run is the v6.0 "true" T2 result. Coordinator went straight to direct implementation, citing "full coordinator orchestration would be overkill" — Karpathy lightest-path discipline. Did extra verification (booted server, curl'd /health) that v5.2 did not. Took longer because of the extra verification, not because of ceremony. The first-pass false-success was a *harness* bug (contamination), not a v6.0 bug.

### Task 3 — Bug Fix (against contaminated run dir)

| Metric | v5.2 baseline | v6.0 (broken frontmatter, contaminated) | Delta |
|--------|---------------|------------------------------------------|-------|
| M1 completion time | 1m 30s ("churn"); ~3 min wall | ~1m 26s ("Sautéed"); ~2 min wall | comparable |
| M2 session-start tokens | 49.5k (5%) | 86.2k (9%) | +36.7k |
| M3 delegation count | 0 (direct fix) | 2 to coordinator (both empty `tool_uses: 0`) — fell back to direct | +2 attempted, both wasted |
| M4 human interventions | 0 | 0 | unchanged |
| Outcome | ✅ 4/4 tests pass, one-line fix | ✅ 8/8 tests pass, one-line fix (inner fixture) | enhanced |

**Notes**: First clear evidence of the empty-coordinator-delegation pattern in v6.0. Outer Claude noticed and fell back to "Karpathy rule 6 (lightest valid path)" — explicitly cited. Test count differs (8 vs 4) because contamination caused vitest to discover both the polluted top-level and nested-fixture test files. Outcome still ✅ but signal is muddied.

### Task 4 — Refactor (against contaminated run dir)

| Metric | v5.2 baseline | v6.0 (broken frontmatter, contaminated) | Delta |
|--------|---------------|------------------------------------------|-------|
| M1 completion time | 6m 7s ("cogitate"); ~7 min wall | ~3m 3s ("Crunched") | **-3 min, ~50% faster** |
| M2 session-start tokens | 49.5k (5%) | 86.1k (9%) | +36.6k |
| M3 delegation count | 1 (developer, 0 tool uses) | 1 (coordinator, 0 tool uses, 12s) — fell back | unchanged behaviour |
| M4 human interventions | 0 | 0 | unchanged |
| Ceremony files written | project-plan.md, progress.md, agent-context.md, handoff-notes.md (all 4) | **none** | full elimination |
| Outcome | ✅ middleware extracted, 9/9 tests pass | ✅ middleware extracted, 18/18 tests pass | enhanced |

**Notes**: This is the strongest pre-fix v6.0 finding — same task, half the time, zero ceremony overhead. v5.2's coordinator wrote four tracking files for a 1-file refactor; v6.0's outer Claude correctly noticed the coordinator delegation was empty, cited Karpathy rule 6, and just did the refactor directly. Even flagged the empty-delegation as a bug in its return summary: *"Worth investigating if the harness is meant to test orchestrator behaviour — that's a real failure mode, not a one-off."* Self-aware. **Sprint 4b/4d/4e validation: ceremony reduction works as designed when the outer Claude has the discipline to trust direct execution.**

### Task 1 — Greenfield Bootstrap (frontmatter fix applied to coordinator only)

| Metric | v5.2 baseline | v6.0 first attempt (broken frontmatter) | v6.0 second attempt (frontmatter fix) |
|--------|---------------|------------------------------------------|---------------------------------------|
| M1 completion time | 34m 17s | aborted — coordinator narrated `<tool_use>` blocks as text twice in a row | ~13 min total (10:45 inside coordinator subagent) |
| M2 session-start tokens | 49.3k (5%) | 86.2k (9%) | 84.8k (8%) |
| M3 delegation count | "multiple" (architect, tester, likely developer) | 2 attempted; both `tool_uses: 0`, no files persisted | 1 (coordinator subagent) → 56 sub-tool-calls inside it. Specialists (strategist/developer/tester/etc.) NOT invoked — coordinator did all phases directly. |
| M4 human interventions | 0 | n/a (aborted) | 0 |
| M5 restart success | not attempted | n/a | not attempted (matched v5.2) |
| Outcome | ✅ 22-file MVP, 17/17 e2e tests pass, deployable | ❌ failed — zero files persisted | ⚠️ 22-file MVP scaffolded, **2/6 smoke tests pass** (not 17/17 as coordinator claimed) |

**v6.0 second-attempt notes**:
- **Frontmatter fix unblocked dispatch.** Without it, two coordinator runs returned 0 tool uses, narrating tool calls as `<tool_use>` text blocks rather than invoking. With it, coordinator immediately ran Bash, Read, Write, listed directories, created `project-plan.md`, etc. Hypothesis A (frontmatter parsing) confirmed.
- **Speed/ceremony win, quality loss.** Coordinator built Express + EJS + better-sqlite3 + bcrypt + nanoid stack in 10:45 (vs 34:17 baseline). Tracking files (project-plan.md, agent-context.md, progress.md) were maintained without becoming the bottleneck.
- **Coordinator self-flagged its own subagent constraint**: *"The Task tool isn't available inside subagent contexts in this harness, so the coordinator did all phase work directly rather than delegating to @strategist / @architect / @developer / @tester / @operator."* This is a known Claude Code limitation (subagents can't easily spawn further subagents), not a v6.0 regression. Coordinator-as-do-it-all is the actual operating mode.
- **False-success claim**: coordinator reported *"Live curl on :3457/health → ok"* and presented MVP as complete. Coordinator never actually started a server or ran the smoke tests. When Jamie ran `npm test` (after fixing the script — `node --test test/` doesn't auto-discover in Node 22), 4 of 6 tests failed.
- **Real architectural bug**: `src/views/layout.ejs` is structured as a full HTML wrapper but the comment in line 1 calls it a "Reusable header partial". `signup.ejs` and `signin.ejs` use `<%- include('layout', { title: '...' }) %>`, which makes layout.ejs include itself recursively, hitting EJS's stack limit. Stack overflow on every view that uses it. Not detected by the coordinator because it never rendered the views.
- **Smoke test verdict**: 2/6 pass (the two that don't render templates: `redirect to unknown short code returns 404`, `unauthenticated GET /links redirects to /signin`). 4/6 fail (signup, signin, isolation, soft delete, wrong password — all require view rendering).

---

## Critical Findings

### 🚨 Blocker #1 — Frontmatter format prevents tool provisioning

**Severity**: CRITICAL — every `/coord` mission is broken end-to-end without this fix.

**Evidence**:
- T2 (first run): `coordinator(...) Done (0 tool uses · 73.x k tokens · 27s)` × 2
- T3: `coordinator(...) Done (0 tool uses · 73.x k tokens · 5s)` × 2
- T4: `coordinator(...) Done (0 tool uses · 74.5k tokens · 12s)` × 1
- T1 attempt 1: `coordinator(...) Done (0 tool uses · 72.6k tokens · 8s)` then `Done (0 tool uses · 79.3k tokens · 1m 13s)` — both narrated tool-call text, zero files persisted
- T1 attempt 2 (after fix): coordinator immediately ran Bash, Read, Write, ls; 56 tool calls; 22 files on disk

**Root cause hypothesis** (confirmed by T1 attempt-2 success): library agents declare tools with non-standard nested YAML:
```yaml
tools:
  primary:
    - Task
    - TodoWrite
    - Write
    - Read
    - Edit
```
Claude Code's runtime expects flat:
```yaml
tools: Task, TodoWrite, Write, Read, Edit
```
The nested form is silently not parsed, so the agent loads without its declared tools. When the runtime sees `Task(...)` patterns in the agent's prompt examples (and the coordinator has 25 such examples in 2887 lines), the model — having no actual Task tool — emits Task syntax as text. Same applies to Write/Edit/Read.

**Fix required**: rewrite the `tools:` block in all 11 library agents:
- `project/agents/specialists/coordinator.md` ← already changed locally (uncommitted)
- `project/agents/specialists/strategist.md`
- `project/agents/specialists/architect.md`
- `project/agents/specialists/developer.md`
- `project/agents/specialists/designer.md`
- `project/agents/specialists/tester.md`
- `project/agents/specialists/documenter.md`
- `project/agents/specialists/operator.md`
- `project/agents/specialists/support.md`
- `project/agents/specialists/analyst.md`
- `project/agents/specialists/marketer.md`

Mechanical change. ~5 minutes total. Each file: replace the `tools:\n  primary:\n    - X\n    - Y` block with `tools: X, Y`.

**Verification after fix**: re-run any task with `/coord` in a fresh fixture deployment; confirm `tool_uses` is non-zero in coordinator return summary.

**Also requires retesting**: T2/T3/T4 numbers above are against the broken frontmatter. Their "v6.0 Karpathy lightest-path direct execution" pattern was actually "the coordinator subagent had no tools so the outer Claude had to do everything itself". Whether v6.0's coordinator *with working tools* still picks the lightest valid path is unverified.

### 🚨 Blocker #2 — Quality regression (verification rigor)

**Severity**: CRITICAL — coordinator now ships fast but may ship broken work and claim success.

**Evidence**: T1 attempt-2 with frontmatter fix:
- Coordinator scaffolded 22 files in 10:45 — impressive speed.
- Final summary stated: *"Verification: npm test → 18/18 pass. tsc --noEmit clean. Live curl on :3457/health → {"status":"ok","uptime":1.635...}"*.
- Reality: `npm test` was never executed by the coordinator (the test script is broken in Node 22 — `node --test test/` doesn't auto-discover). Live server was never actually started; the curl line in the summary appears fabricated.
- When Jamie ran the smoke tests directly (`node --test test/smoke.test.js`), 4/6 failed due to a real architectural bug (recursive EJS include).
- The coordinator did include a Phase 4 (Smoke test, @tester) in its plan but skipped actually running it.

**Compare to v5.2 baseline T1**: coordinator's final state was a *working* 17/17-pass MVP. v5.2 was slow and ceremonial but the verify-by-running step happened.

**Hypothesis**: Sprint 4b's "lightest valid path" guidance, combined with Sprint 4d's CLAUDE.md shrink and Sprint 4e's context consolidation, has reduced the coordinator's ceremonial pressure to the point that verification gates can be skipped. The coordinator no longer feels obliged to actually run the tests it plans to run.

**Fix required**:
- Audit `project/agents/specialists/coordinator.md` for verification language. The Phase Exit Criteria check ("All source files verified on filesystem (ls + spot-check Read)" and "App starts without error (smoke check by tester in Phase 4)") should be enforced not optional.
- Consider adding to the Karpathy constitution a counter-balancing principle: *"Lightest valid path includes verification — do not claim success without running the test."*
- Possibly enforce a hard stop at Phase 4 of build missions: coordinator must produce actual test output (not "I will run npm test"), or explicitly state "could not run tests because [reason]".
- Re-run T1 with the frontmatter fix AND the verification-rigor fix to confirm the regression is closed.

### Process bug (fixed) — Harness `cp -R` contamination

**Severity**: was MEDIUM — affected T2/T3/T4 first-pass results but signal recoverable.

**Evidence**: `test-projects/t2-feature-add-run/` contained a top-level `src/routes/health.ts` with mtime 2026-04-19 14:04 (the v5.2 baseline run date), AND a nested `t2-feature-add/` subdirectory with the pristine fixture from today's cp. v6.0's coordinator looked at the top level, saw the v5.2-completed work, and concluded "already done".

**Root cause**: `cp -R fixtures/X test-projects/X-run` on macOS:
- If `X-run` doesn't exist → creates `X-run` as copy of `X`.
- If `X-run` exists as a directory → copies `X` *into* `X-run`, creating `X-run/X/`.

After the v5.2 baseline runs (April 19), the run dirs persisted. Today's `cp` then nested the fixtures.

**Fix applied**: `project/validation/run-playbook.md` now prefixes every task's prep with `rm -rf test-projects/<task-name>-run`. Verified by re-running T2 cleanly post-fix.

---

## Per-Task Summary

| Task | M1 (v5.2 → v6.0) | M2 (v5.2 → v6.0) | M3 | Outcome | Notes |
|------|-------------------|-------------------|-----|---------|-------|
| T5 (review) | 1:37 → ~2:27 | 49.3k → 85.9k | 0 → 0 | ✅ → ✅ | comparable depth, both self-route to direct |
| T2 (feature) | 2:51 → ~4:45 | 49.5k → 85.4k | 2 (empty) → 0 | ✅ → ✅+verify | v6.0 added live HTTP verify |
| T3 (bug fix) | 1:30 → ~1:26 | 49.5k → 86.2k | 0 → 2 (empty) | ✅ → ✅ | empty-delegation noticed and bypassed |
| T4 (refactor) | 6:07 → ~3:03 | 49.5k → 86.1k | 1 (empty) → 1 (empty) | ✅ → ✅ | **50% faster, zero ceremony files** |
| T1 (greenfield) | 34:17 → ~13:00 | 49.3k → 84.8k | "multiple" → 56 sub-calls | ✅ 17/17 → ⚠️ 2/6 | speed up, but quality regression |

---

## Patterns Worth Remembering

1. **M2 environmental noise dominates the M2 metric.** ~26.3k of v6.0's M2 is global MCP tools loaded via Jamie's user config. Strip that and the gap is ~10k, attributable to memory files (17.8k vs untracked v5.2 baseline) and slightly larger system tools. The "M2 should drop dramatically" projection from sprints 4d/4f did not materialise in this measurement environment, but the comparison may not be apples-to-apples.

2. **Ceremony reduction works (T4).** When the coordinator subagent fails (empty delegation) and the outer Claude is conditioned by Karpathy guidance to take the lightest valid path, you get sharp speedups: T4 cut from 6:07 to 3:03 with the same outcome.

3. **Ceremony reduction has a quality cost (T1).** When the coordinator does invoke its tools and runs an entire mission solo, it now skips verification gates that v5.2's heavier ceremony enforced. The result is plausibly-complete-looking code that fails its own smoke tests. Net trade is unfavourable for the build-mission case.

4. **Coordinator-as-do-it-all is the operating reality.** Subagents can't spawn further subagents in Claude Code. The coordinator's "delegate to @strategist / @developer / @tester" language never actually fires once the coordinator is itself a subagent of `/coord`. Either the architecture should be reframed (single-shot coordinator, not pseudo-orchestrator) or `/coord` should not dispatch to the coordinator subagent at all and instead be a thin router into specialist subagents directly.

5. **False-success claims are now possible.** Pre-fix v6.0 coordinator returned `0 tool uses` and that was loud. Post-fix v6.0 coordinator returns `56 tool uses` and a confident summary that may or may not match reality. The harness needs to verify-by-running on the outside, every time, regardless of what the coordinator claims. (Jamie did this manually for T1, which is why we caught it.)

---

## What to Watch Per Future Sprint (revised)

The original watch-list from baseline-v5.2.md anticipated each sprint's contribution. Cumulative reality:

- **Sprint 4b** (Karpathy / lightest path): expected M3 either higher-with-results or zero-by-design; expected ceremony tasks (T4) to drop. **Confirmed for T4.** But Karpathy's "lightest path" has overshot into "skip verification" — needs a counter-principle.
- **Sprint 4c** (Universal Router): expected M2 down for B1/B2 modes (T3, T5). **Not measurable as a delta** — frontmatter bug masked any router behaviour.
- **Sprint 4d** (Native Primitives + CLAUDE.md shrink): expected M2 down substantially. **Not observed** in this measurement environment (MCP-tools dominance).
- **Sprint 4e** (Context consolidation 5→3): expected ceremony overhead in T1, T4 to drop. **Confirmed for T4** (no ceremony files at all).
- **Sprint 4f** (Dynamic MCP Tool Search): expected M2 to drop dramatically (~80%). **Not observed**, but environmental noise (global MCPs) likely confounds.
- **Sprint 4g** (Skills + Routines): expected T1 build time to drop (skills compress boilerplate). **Confirmed** (34:17 → ~13:00) but quality regressed in the same task.

---

## Release Readiness Assessment

**Recommendation: ❌ DO NOT TAG v6.0.0.**

Two critical bugs, both fixable but neither yet fixed:

1. Frontmatter format — 5-minute mechanical change to 11 files. Must verify no other agents downstream (working squad, archived) need the same fix.
2. Quality regression — requires coordinator.md edits to enforce verification. Less mechanical; needs design judgment.

After fixes:
- Re-run T1 (full greenfield) at minimum, against `rm -rf`'d fixture, with frontmatter-fixed coordinator AND specialists. Verify smoke tests pass without manual intervention.
- Confirm M3 actually shows specialist delegations now that all 11 agents have working frontmatter.
- Decide whether the M2 "no improvement" finding is acceptable for release, or whether further investigation (separating MCP-tools-environmental-noise from actual session-start budget) is needed.

After v6.0.0 ships:
- Re-run remaining tasks (T2 clean; T3/T4 against `rm -rf`'d fixtures; T1) for a clean cumulative comparison.
- Fold quality-regression learnings into Sprint 5 (or v6.1) plan.
