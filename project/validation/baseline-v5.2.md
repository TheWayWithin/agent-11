# Harness Results — Baseline v5.2

**Version / Sprint**: v5.2 baseline (pre-v6.0 evolution)
**Commit SHA**: 2ed048f (as of first task run)
**Executor**: Claude (Option B — fresh `claude` session in each fixture dir, Jamie observes and records)
**Date(s) of run**: 2026-04-19 onwards
**Notes**: Running task by task. Full squad (11 agents) installed via `install.sh full` from local repo (functionally equivalent to v5.2 `main` at install time).

---

## Caveats for this baseline (Option B executor)

- Metric M4 ("human interventions") is captured from Jamie's observation while the fresh Claude session works. Because Claude is "driving", M4 reflects times the fresh Claude asked Jamie to clarify, redirect, or unblock — not times Jamie proactively intervened.
- All later milestone runs will use the same Option B stance so comparisons are apples-to-apples.
- If a milestone result looks suspicious compared to baseline, consider re-running that task with explicit logging.

---

## Task 1 — Greenfield Bootstrap

| Metric | Value |
|--------|-------|
| M1 completion time | 34m 17s (agent "brew"); 4 min past 30-min stop criterion but not abandoned |
| M2 session-start tokens | 49.3k (5% of 1M context) |
| M3 delegation count | Multiple (architect and tester called by name; likely developer too). Exact count not captured — summary flagged activity but didn't enumerate. |
| M4 human interventions | 0 |
| M5 restart success | **Not attempted** — coordinator (me) forgot to prompt mid-task for the `/clear` + resume test. Counts as "not-attempted" per spec; re-test on a later milestone if we want the data point. |
| Outcome | Success — full working Tinylink MVP: Remix + TypeScript + Drizzle + iron-session + bcrypt, SQLite DB, 22 source files, 17/17 e2e tests pass, docs + README + deploy config |
| Notes | Impressive result — complete MVP from 1-page ideation in 34 min. But ALSO: "architect and tester both produced output referencing code/files that did not match reality. Coordinator cross-checked every delegation before writing." Same hallucination pattern seen in T2 and T4. Coordinator caught and corrected 4 issues mid-task (missing soft-delete column, scope creep, drizzle-kit bug, wrong test endpoints). **Coordinator again wrote all 4 tracking files** (project-plan, progress, handoff-notes, agent-context) — same ceremony overhead as T4. Went 4 minutes over stop criterion; deliberately not abandoned because it was clearly making progress. Jamie's global rule "no commits/deploys without explicit confirmation" was respected — MVP left uncommitted for review. |

---

## Task 2 — Feature Addition

| Metric | Value |
|--------|-------|
| M1 completion time | 2m 51s (agent "brew"); ~5 min wall clock including setup and `npm install` |
| M2 session-start tokens | 49.5k (5% of 1M context) |
| M3 delegation count | 2 (both to `developer` — both returned "0 tool uses", empty responses) |
| M4 human interventions | 0 |
| M5 restart success | Not attempted this run — skipped to save time |
| Outcome | Success — /health endpoint created, test added, all 6 tests pass |
| Notes | **First task where coordinator actually tried to delegate.** Both delegations to `developer` came back with "0 tool uses" — the sub-agent didn't actually do anything, just returned. Coordinator then did all the Write tool calls itself (correct fallback behaviour, but wasted a couple of seconds on each empty delegation). Real data point on v5.2 delegation effectiveness. Output style matched fixture: minimal diff, existing conventions preserved. |

---

## Task 3 — Bug Fix

| Metric | Value |
|--------|-------|
| M1 completion time | 1m 30s (agent "churn"); ~3 min wall clock including `npm install` |
| M2 session-start tokens | 49.5k (5% of 1M context) |
| M3 delegation count | 0 — coordinator handled the fix directly, did NOT delegate |
| M4 human interventions | 0 |
| M5 restart success | n/a |
| Outcome | Success — bug identified, one-line fix applied, all 4 tests pass |
| Notes | Second time in a row the "coordinator" ignored its own ceremony and did the work directly. Clean minimal fix — matched the fixture's CLAUDE.md style rule about minimal diffs. `npm install` happened automatically because fixture ships no `node_modules`. |

---

## Task 4 — Refactor

| Metric | Value |
|--------|-------|
| M1 completion time | 6m 7s (agent "cogitate"); ~7 min wall clock |
| M2 session-start tokens | 49.5k (5% of 1M context) |
| M3 delegation count | 1 (developer, returned "0 tool uses" in 30s — empty) |
| M4 human interventions | 0 |
| M5 restart success | n/a |
| Outcome | Success — middleware extracted, 9/9 tests pass, no behaviour change |
| Notes | **Huge ceremony overhead.** Coordinator created and maintained `project-plan.md`, `progress.md`, `agent-context.md`, `handoff-notes.md` — all 4 of the tracking files v6.0 is consolidating (Sprint 4e) or decentralising (Sprint 4d). Marked tasks [x] with timestamps, wrote phase-completion entries, etc. Delegated to developer (same pattern as T2 — 0 tool uses returned). Coordinator noticed developer's `old_string` reconstructions were inaccurate and applied the design to real file contents itself. **6+ minute task for what T3 did in 1:30 — the bulk of the extra time is ceremony, not work.** This task is the single strongest piece of evidence for why Sprints 4b/4d/4e matter. |

---

## Task 5 — Commit Review

| Metric | Value |
|--------|-------|
| M1 completion time | 1m 37s (agent "baked" time); ~3 min wall clock including setup |
| M2 session-start tokens | 49.3k (5% of 1M context) |
| M3 delegation count | 0 — coordinator did the review directly, did NOT delegate to a specialist |
| M4 human interventions | 0 |
| M5 restart success | n/a |
| Outcome | Success |
| Notes | Coordinator explicitly skipped "coord tracking machinery (project-plan.md, progress.md etc.)" and delivered review directly — good sign that even v5.2 sometimes ignores its own ceremony when it's obviously unnecessary. Review found 3 real blockers, 7 concerns, 5 nits. Blocker #1 is a genuine regression in our secure-install flow (squad arg dropped) worth fixing outside this sprint. Concern #2 (no CI checksum guard) was already addressed by fea148d earlier today but the reviewer was working off the d501ca9 fixture. |

---

## Baseline Summary — v5.2 Observations

Completed: 2026-04-19. All 5 tasks run.

### Metric totals

| Metric | T1 | T2 | T3 | T4 | T5 |
|--------|----|----|----|----|----|
| M1 time | 34:17 | 2:51 | 1:30 | 6:07 | 1:37 |
| M2 tokens | 49.3k | 49.5k | 49.5k | 49.5k | 49.3k |
| M3 delegations | multiple | 2 (both empty) | 0 | 1 (empty) | 0 |
| M4 interventions | 0 | 0 | 0 | 0 | 0 |
| M5 restart | not attempted | skipped | n/a | n/a | n/a |
| Outcome | ✅ | ✅ | ✅ | ✅ | ✅ |

### Patterns worth remembering

1. **M2 is flat at ~49.4k tokens** across all fresh sessions. This is the session-start floor for v5.2 full-squad. Any v6.0 sprint that improves prompt hygiene, shrinks CLAUDE.md, or consolidates context files should move this number down. This is the single cleanest baseline metric for comparison.

2. **Delegation is largely theatre in v5.2.** Task 3 and Task 5 didn't delegate at all — coordinator did the work directly. Task 2 delegated twice to `developer`, both returned "0 tool uses" (empty). Task 4 delegated once to `developer`, also empty. Task 1's architect and tester delegations "produced output referencing code/files that did not match reality" (coordinator's words). **When the coordinator actually tries to delegate, the subagents often return nothing useful and the coordinator has to do the work itself.** This is a strong signal for Sprint 4b (prompt hygiene / delegation discipline) and Sprint 4d (native primitives). Either fix the delegation mechanism or lean into "coordinator does the work" explicitly.

3. **Ceremony overhead is visible and significant.** Tasks 4 and 1 triggered the full tracking-file ceremony (project-plan.md, progress.md, agent-context.md, handoff-notes.md all written). Task 3 did comparable real work in 1:30 vs Task 4's 6:07 — the gap is ceremony. Sprint 4d (CLAUDE.md shrink + hooks) and Sprint 4e (5 context files → 3) should materially reduce this.

4. **Even v5.2 sometimes chooses the light path.** Task 5 explicitly skipped "coord tracking machinery (project-plan.md, progress.md, etc.) and delivered the review directly". So the ceremony is partly self-selecting — the coordinator sometimes decides it's unnecessary. Sprint 4b's Karpathy-discipline changes (PAUSE-AND-PLAN, "choose the lightest valid execution path") should make this the default, not the exception.

5. **Subagent hallucinations are a persistent pattern.** Multiple tasks saw subagents produce plausible-looking output that didn't match reality. Task 4's developer produced `old_string` reconstructions that were inaccurate. Task 1's architect and tester both hallucinated files. Coordinator caught these by verifying. This is load-bearing — without the coordinator's cross-check, the hallucinations would cause real damage. Worth explicit attention in the v6.0 subagent prompts.

6. **M4 (human interventions) was zero across all tasks.** The system does operate autonomously — good. But this doesn't mean the system is efficient; it means the coordinator has enough ceremony to keep itself on rails without human help. Substantially the same number of interventions should be seen in v6.0 with much less ceremony.

### What to watch per future sprint

Each later sprint's results file should reference these patterns and show deltas:
- **Sprint 4b** — expect M2 down (prompt minimisation, Karpathy constitution); expect M3 to be either higher (delegations that actually work) or zero by design (explicit "coordinator does the work" path); expect M1 on ceremonial tasks (T4) to drop notably.
- **Sprint 4c** (Universal Router) — expect M2 down further for Mode B1 / Mode C tasks (T3, T5).
- **Sprint 4d** (Native Primitives + CLAUDE.md shrink) — expect M2 down substantially; expect ceremony tasks (T4) to shrink.
- **Sprint 4e** (Context consolidation 5→3) — expect tracking-file overhead in T1, T4 to drop.
- **Sprint 4f** (Dynamic MCP Tool Search) — expect M2 to drop dramatically (target: ~80%).
- **Sprint 4g** (Skills + Routines) — expect M1 on T1 to drop (skills compress boilerplate).
- **Sprint 4h** — final comparison across all five.
