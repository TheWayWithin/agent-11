# Handoff Notes — Agent-11 v6.0 Evolution

**Last Updated**: 2026-04-26
**From**: Sprint 4d close-out (T1-T6, T8 shipped solo)
**To**: Next session — schedule T7 harness re-runs, then Sprint 4e

Per the v6.0 plan, `handoff-notes.md` is folded into `agent-context.md` as a structured Phase Handoff block in Sprint 4e. Until then, this file remains the primary next-session handoff.

---

## Where We Are

- **Sprint 4a** (Baseline + Great Deletion) — complete.
- **Sprint 4b** (Prompt Hygiene & Budget Controls) — complete.
- **Sprint 4c** (Universal Router) — T1-T6, T8 shipped (`ec5745a`); T7 parked.
- **Sprint 4d** (Native Primitives + CLAUDE.md Shrink) — **T1-T6, T8 complete (2026-04-26)**. T7 parked alongside 4c's T7.
- **Sprint 4e** (Context Consolidation 5→3) — detailed spec written, ready for review.

---

## What Sprint 4d Shipped

- `library/CLAUDE.md` — **575 → 79 lines** (-86%). Karpathy constitution + mission table + tracking files + foundation files + skills + MCP search patterns + hooks reference + security + plan-driven pointer. Everything else points at canonical sources.
- `library/settings.json.template` — default advisory hooks: tsc/ruff/rubocop on Edit/Write (auto-skip when toolchain absent), confirm prompt on destructive Bash (rm -rf, force push, hard reset, branch -D, clean -f).
- `.claude/skills/meta-dev/SKILL.md` — orient Claude correctly when working in agent-11 repo (library vs working-squad). Verified registered in skill list.
- `project/deployment/scripts/install.sh` — new functions for settings.json and constitution deployment; field-manual list expanded with `mcp-integration.md`.
- `sprints/sprint-4e-context-consolidation.md` — outline replaced with detailed spec.

Full close-out in `progress.md` under `[2026-04-26] — Sprint 4d (T1-T6, T8) Complete`.

---

## Next Actions

1. **Schedule T7 (harness re-runs)** — Sprint 4c's T7 (Tasks 3, 4, 5 → milestone-4c.md) and Sprint 4d's T7 (Tasks 1, 2, 5 → milestone-4d.md) both pending. Could be done in one terminal session if scope allows. Expected impact: 4d's lean CLAUDE.md is the biggest M2 driver yet.
2. **Review Sprint 4e detailed spec** at `sprints/sprint-4e-context-consolidation.md`. 8 tasks; biggest items are renaming `agent-context.md` → `context.md` and folding `handoff-notes.md` into structured Phase Handoff blocks. Approve or adjust before execution.
3. **Sprint 4e execution** — most can run solo. T7 (harness for milestone-4e) requires terminal again.

---

## Open Items for Jamie

1. **Approve Sprint 4e scope** before execution — particularly the Phase Handoff schema (T1) and the rename strategy (T2/T3). Migration story for existing v5.x users is a key call.
2. **Three parked T7s now** — when there's a terminal session, 4c, 4d, and possibly 4e harness runs can collapse into a single milestone comparison if timing allows.
3. **Open questions in 4e spec resolved with defaults** unless you push back: `progress.md` stays at root (write-only); migration via manual `mv` in CLAUDE.md note, no helper command. 5-field Phase Handoff schema. All flagged in the spec.

---

## Key Files

| File | Purpose |
|------|---------|
| `project-plan.md` | v6.0 evolution overview, 8-sprint roadmap |
| `sprints/sprint-4d-native-primitives-and-claudemd-shrink.md` | Just-completed sprint — T7 still open |
| `sprints/sprint-4e-context-consolidation.md` | Detailed spec, ready for review |
| `sprints/sprint-4f..4h` | Future sprints — outline only; detailed spec is closing task of preceding sprint |
| `project/validation/harness-spec.md` | How the harness works |
| `project/validation/baseline-v5.2.md` | v5.2 baseline (original target) |
| `project/validation/milestone-4b.md` | Sprint 4b's harness results |
| `project/validation/run-playbook.md` | Step-by-step runbook for any milestone harness run |
| `library/CLAUDE.md` | Now 79 lines — the deployed user-facing instructions |
| `library/settings.json.template` | Default advisory hooks template |
| `.claude/skills/meta-dev/SKILL.md` | Repo orientation skill (working-squad exception) |
| `.archive/2026-04-17-pre-v6/` | Pre-v6 plan, sprints, progress, context, handoff-notes |

---

## Notes for Fresh Session

- Scope rule: edits target library surface. `.claude/skills/meta-dev/` is the one explicit exception in v6.0 (created in 4d, T4).
- Docs strategy: public-facing docs updated once in Sprint 4h, not per-sprint. Log user-facing changes in `progress.md` under "User-Facing Changes" headings.
- Jamie prefers brief context + specific steps (ADHD). One task at a time, fully closed before moving on.
- British English by default.
- Instructions must be anchored to what Jamie sees on screen right now — don't require him to coordinate multiple windows without explicit consent.
