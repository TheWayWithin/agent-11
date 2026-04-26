# Handoff Notes — Agent-11 v6.0 Evolution

**Last Updated**: 2026-04-26
**From**: Sprint 4e close-out (T1, T3-T6, T8 shipped solo)
**To**: Next session — schedule T7 batch (4c + 4d + 4e), then Sprint 4f

This is the last `handoff-notes.md` of the v6.0 evolution. From the next sprint forward, these notes get folded into `agent-context.md` as a Phase Handoff block (the v5→v6 migration of our own working files happens once the dust settles on shipping). Until then, this file remains the primary next-session handoff.

---

## Where We Are

- **Sprint 4a** (Baseline + Great Deletion) — complete.
- **Sprint 4b** (Prompt Hygiene & Budget Controls) — complete.
- **Sprint 4c** (Universal Router) — T1-T6, T8 shipped (`ec5745a`); T7 parked.
- **Sprint 4d** (Native Primitives + CLAUDE.md Shrink) — T1-T6, T8 shipped (`3165f3d`); T7 parked. Smoke-tested.
- **Sprint 4e** (Context Consolidation 5→3) — **T1, T3-T6, T8 complete (2026-04-26)**. T7 parked alongside 4c and 4d.
- **Sprint 4f** (Dynamic MCP Tool Search) — detailed spec written, ready for review.

---

## What Sprint 4e Shipped

- **`handoff-notes.md` retired** as a separate active-context file. Phase Handoff blocks (5-field schema) live inside `agent-context.md`.
- **`progress.md` demoted to write-only** — appended when issues/fixes/deliverables occur; read only on staleness checks or post-`/clear` reconstruction.
- 316 `handoff-notes.md` references across the library surface reduced to 5 intentional migration notes.
- All 11 specialist agents updated. All 18 mission files updated. Coordinator's DYNAMIC CONTEXT LOADING table reflects 3-active-file model.
- `library/CLAUDE.md` updated to 78 lines (still under 80) — tracking files now show Active/On-demand/Write-only categorisation. Migration line included for v5.x users.
- `templates/agent-context-template.md` restructured to feature the Phase Handoff schema as the recurring section pattern.
- `templates/handoff-notes-template.md` archived to `.archive/2026-04-26-pre-4e/`. install.sh updated to no longer deploy it.
- Sprint 4f detailed spec written.

Full close-out in `progress.md` under `[2026-04-26] — Sprint 4e (T1, T3-T6, T8) Complete`.

---

## Next Actions

1. **Schedule the T7 batch** — three parked harness re-runs:
   - **4c** (Tasks 3, 4, 5) → `milestone-4c.md`. Tests dynamic context loading and the deterministic router.
   - **4d** (Tasks 1, 2, 5) → `milestone-4d.md`. Tests the lean CLAUDE.md and hooks.
   - **4e** (Tasks 1, 2, 3) → `milestone-4e.md`. Tests the 3-file model and Phase Handoff blocks.
   - Run all three against the v5.2 baseline in one terminal session if scope allows. Each produces a milestone doc; trends show cumulative impact.
2. **Review Sprint 4f detailed spec** at `sprints/sprint-4f-dynamic-mcp-tool-search.md`. 8 tasks; biggest items are wiring `dynamic-mcp.json` as the canonical `.mcp.json` (T2) and updating the 7 MCP-using specialists with Tool-Centric Workflow (T3). Target M2 reduction ≥30K vs v5.2 baseline.
3. **Sprint 4f execution** — most can run solo. T2 is the highest-risk task (affects every install) — smoke test mandatory, same pattern as 4d. T7 (harness for milestone-4f) needs terminal again.

---

## Open Items for Jamie

1. **Approve Sprint 4f scope** before execution — particularly T2 (replacing `.mcp.json` with dynamic-mcp.json) since it changes user installs. Smoke test will catch issues but the design call is yours.
2. **T7 batch** — when terminal time is available, three harness re-runs will give us the cumulative v6.0 vs v5.2 comparison the rolling-wave protocol assumes.
3. **Open questions in 4f spec resolved with defaults**: replace .mcp.json (don't merge); 1-2 discovery tools per server; field-manual/mcp-integration.md is canonical for the pattern catalogue. All flagged inline.

---

## Key Files

| File | Purpose |
|------|---------|
| `project-plan.md` | v6.0 evolution overview, 8-sprint roadmap |
| `sprints/sprint-4e-context-consolidation.md` | Just-completed sprint — T7 still open |
| `sprints/sprint-4f-dynamic-mcp-tool-search.md` | Detailed spec, ready for review |
| `sprints/sprint-4g..4h` | Future sprints — outline only; detailed spec is closing task of preceding sprint |
| `project/validation/harness-spec.md` | How the harness works |
| `project/validation/baseline-v5.2.md` | v5.2 baseline (the target to beat) |
| `project/validation/milestone-4b.md` | Sprint 4b's harness results |
| `project/validation/run-playbook.md` | Step-by-step runbook for any milestone harness run |
| `library/CLAUDE.md` | Now 78 lines — deployed user-facing instructions |
| `library/settings.json.template` | Default advisory hooks template |
| `templates/agent-context-template.md` | Now includes Phase Handoff schema |
| `.claude/skills/meta-dev/SKILL.md` | Repo orientation skill (working-squad exception) |
| `.archive/2026-04-26-pre-4e/handoff-notes-template.md` | Archived |
| `.archive/2026-04-17-pre-v6/` | Pre-v6 plan, sprints, progress, context |

---

## Notes for Fresh Session

- Scope rule: edits target library surface. The one v6.0 working-squad exception is `.claude/skills/meta-dev/` (created in 4d).
- Docs strategy: public-facing docs updated once in Sprint 4h. Per-sprint user-facing changes logged in `progress.md` under "User-Facing Changes" headings.
- Jamie prefers brief context + specific steps (ADHD). One task at a time, fully closed before moving on.
- **Instruction ordering**: never put caveats or "wait before X" *after* the step they qualify; trailing instructions are missed (memory-saved 2026-04-26).
- British English by default.
- Instructions must be anchored to what Jamie sees on screen right now — don't require him to coordinate multiple windows without explicit consent.
