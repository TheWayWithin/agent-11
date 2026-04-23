# Handoff Notes — Agent-11 v6.0 Evolution

**Last Updated**: 2026-04-19
**From**: Sprint 4a close-out
**To**: Next session — execute Sprint 4b

Fresh handoff file opened at close of Sprint 4a T6. Historic file preserved at `.archive/2026-04-17-pre-v6/handoff-notes-historic.md`.

Per the v6.0 plan, `handoff-notes.md` is folded into `agent-context.md` as a structured Phase Handoff block in Sprint 4e. Until then, this file remains the primary next-session handoff.

---

## Where We Are

- **Sprint 4a** (Baseline + Great Deletion) — complete. See `progress.md`.
- **Sprint 4b** (Prompt Hygiene & Budget Controls) — T1, T2, T3, T4, T5, T7 done solo. T6 (harness re-run) parked for a session where Jamie has ~45 min of terminal time.
- **Sprint 4c** (Universal Router) — detailed spec ready; execution blocked on Sprint 4b T6.
- **Install squad simplification** — shipped as `c6a53fa` (always installs all 11 agents).

---

## Next Action

**Sprint 4b T6 — harness re-run.** Measures whether the Sprint 4b changes (Karpathy constitution, PAUSE-AND-PLAN, subagent hardening, budget controls) produced measurable improvement vs the v5.2 baseline.

Subset to re-run: Tasks 3 (bug fix), 4 (refactor), 5 (commit review). Tasks 1 and 2 optional — they take longer and we have less hypothesis about their movement.

Run procedure: same as baseline run. Follow `project/validation/run-playbook.md`. Record results in `project/validation/milestone-4b.md`.

After T6 is done, Sprint 4c is ready to execute per `sprints/sprint-4c-universal-router.md`.

---

## Open Items for Jamie Before Starting Sprint 4b

1. **Review Sprint 4b detailed spec** and approve (or adjust) before execution starts.
2. **Open Issues flagged from baseline** (not blockers for 4b):
   - Secure-install squad regression (`secure-install.sh` drops the squad argument) — separate fix.
   - Subagent hallucinations in v5.2 — worth explicit attention in 4b's prompt updates.

---

## Key Files

| File | Purpose |
|------|---------|
| `project-plan.md` | v6.0 evolution overview, 8-sprint roadmap |
| `sprints/sprint-4b-prompt-hygiene-and-budget-controls.md` | Current sprint — detailed, ready |
| `sprints/sprint-4c..4h` | Future sprints — outline only; detailed spec is closing task of preceding sprint |
| `project/validation/harness-spec.md` | How the harness works |
| `project/validation/baseline-v5.2.md` | Baseline results + summary observations |
| `project/validation/run-playbook.md` | Step-by-step runbook for any milestone harness run |
| `.archive/2026-04-17-pre-v6/` | Pre-v6 plan, sprints, progress, context, handoff-notes |

---

## Notes for Fresh Session

- Scope rule: edits target library surface (`project/`, `library/CLAUDE.md`, `templates/`), not our internal working squad (`.claude/agents/`, `.claude/commands/`).
- Docs strategy: public-facing docs updated once in Sprint 4h, not per-sprint. Log user-facing changes here.
- Jamie prefers brief context + specific steps (ADHD). One task at a time, fully closed before moving on.
- Use British English.
- Instructions must be anchored to what Jamie sees on screen right now — don't require him to coordinate multiple windows without explicit consent.
