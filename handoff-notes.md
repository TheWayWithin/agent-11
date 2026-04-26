# Handoff Notes — Agent-11 v6.0 Evolution

**Last Updated**: 2026-04-26
**From**: Sprint 4c close-out (T1-T6, T8 shipped solo)
**To**: Next session — schedule T7 harness re-run, then Sprint 4d

Per the v6.0 plan, `handoff-notes.md` is folded into `agent-context.md` as a structured Phase Handoff block in Sprint 4e. Until then, this file remains the primary next-session handoff.

---

## Where We Are

- **Sprint 4a** (Baseline + Great Deletion) — complete.
- **Sprint 4b** (Prompt Hygiene & Budget Controls) — complete (T6 harness validated, Task 4 dropped 75%). Full results in `project/validation/milestone-4b.md`.
- **Sprint 4c** (Universal Router) — **T1-T6, T8 complete (2026-04-26)**. T7 (harness re-run) deferred to a session with Jamie's terminal.
- **Sprint 4d** (Native Primitives + CLAUDE.md Shrink) — detailed spec written, ready for review.

---

## What Sprint 4c Shipped

- `project/commands/coord.md` — 549 → 91 lines. Deterministic mission-based routing; mode override; unknown-mission fallback; control commands separated from missions; pipeline commands (`/foundations`, `/architect`, `/bootstrap`) noted as standalone.
- `project/agents/specialists/coordinator.md` — added DYNAMIC CONTEXT LOADING section; rewrote SESSION RESUMPTION PROTOCOL to be mode-aware. Mode B1 (`fix`) reads only the bug report. Mode A reads tracking files. `evidence-repository.md` is on-demand only.
- `sprints/sprint-4d-native-primitives-and-claudemd-shrink.md` — outline replaced with detailed spec.

Full close-out in `progress.md` under `[2026-04-26] — Sprint 4c (T1-T6, T8) Complete`.

---

## Next Actions

1. **Schedule T7** — harness re-run for milestone-4c. Subset: Tasks 3 (bug fix), 4 (refactor), 5 (commit review). Cheapest to re-run; exercise the main routing paths. Expected outcome: M2 drops measurably on Mode B1 tasks (3, 5) since they no longer load tracking files by default.
2. **Review Sprint 4d detailed spec** at `sprints/sprint-4d-native-primitives-and-claudemd-shrink.md`. 8 tasks; biggest item is the lean library/CLAUDE.md (<80 lines). Approve or adjust before execution.
3. **Sprint 4d execution** — most of it can run solo. T7 (harness re-run for milestone-4d) requires terminal again.

---

## Open Items for Jamie

1. **Approve Sprint 4d scope** before execution — particularly the relocation map (T1) and hook design (T2).
2. **T7 from 4b's tail and 4c is still parked** — when there's a terminal session, both can be run together against the same baseline if scope allows.
3. **Open questions in Sprint 4d spec**: blocking vs advisory hooks, Meta-Dev Skill trigger mechanism, where plan-driven-development docs live. None are blockers; flagged for review.

---

## Key Files

| File | Purpose |
|------|---------|
| `project-plan.md` | v6.0 evolution overview, 8-sprint roadmap |
| `sprints/sprint-4c-universal-router.md` | Just-completed sprint — T7 still open |
| `sprints/sprint-4d-native-primitives-and-claudemd-shrink.md` | Detailed spec, ready for review |
| `sprints/sprint-4e..4h` | Future sprints — outline only; detailed spec is closing task of preceding sprint |
| `project/validation/harness-spec.md` | How the harness works |
| `project/validation/baseline-v5.2.md` | v5.2 baseline (original target to beat) |
| `project/validation/milestone-4b.md` | Sprint 4b's harness results |
| `project/validation/run-playbook.md` | Step-by-step runbook for any milestone harness run |
| `.archive/2026-04-17-pre-v6/` | Pre-v6 plan, sprints, progress, context, handoff-notes |

---

## Notes for Fresh Session

- Scope rule: edits target library surface (`project/`, `library/CLAUDE.md`, `templates/`), not our internal working squad (`.claude/agents/`, `.claude/commands/`). Sprint 4d has one explicit exception (`.claude/skills/meta-dev/`) — called out in the spec.
- Docs strategy: public-facing docs updated once in Sprint 4h, not per-sprint. Log user-facing changes in `progress.md` under "User-Facing Changes" headings.
- Jamie prefers brief context + specific steps (ADHD). One task at a time, fully closed before moving on.
- British English by default.
- Instructions must be anchored to what Jamie sees on screen right now — don't require him to coordinate multiple windows without explicit consent.
