# Handoff Notes — Agent-11 v6.0 Evolution

**Last Updated**: 2026-04-26
**From**: Sprint 4f close-out (T1, T2, T3, T5, T6, T8 shipped solo; recalibrated mid-sprint)
**To**: Next session — schedule T7 batch (4c + 4d + 4e + 4f), then Sprint 4g

---

## Where We Are

- **Sprint 4a** (Baseline + Great Deletion) — complete.
- **Sprint 4b** (Prompt Hygiene & Budget Controls) — complete.
- **Sprint 4c** (Universal Router) — T1-T6, T8 shipped (`ec5745a`); T7 parked.
- **Sprint 4d** (Native Primitives + CLAUDE.md Shrink) — T1-T6, T8 shipped (`3165f3d`); T7 parked. Smoke-tested ✓.
- **Sprint 4e** (Context Consolidation 5→3) — T1, T3-T6, T8 shipped (`9e4acf9`); T7 parked.
- **Sprint 4f** (Dynamic MCP Tool Search) — **T1, T2, T3, T5, T6, T8 complete (2026-04-26)**. T4 REMOVED during recalibration. T7 parked.
- **Sprint 4g** (Skills + Routines) — detailed spec written, ready for review.

---

## What Sprint 4f Shipped

**Recalibration story**: T1 audit revealed Sprint 4f's premise was wrong. `project/mcp/dynamic-mcp.json` (Sprint 11) uses the Claude API schema for per-tool `defer_loading`, not Claude Code's `.mcp.json` schema. The two systems are different. Claude Code handles tool deferring **natively** via `ENABLE_TOOL_SEARCH=auto`. Sprint pivoted from "wire dynamic-mcp.json" to "enable native deferring; archive obsolete config".

**Substantive deliverables**:

- `library/settings.json.template` — `ENABLE_TOOL_SEARCH=auto` env added. This is the actual lever that activates Claude Code's threshold-based tool loading.
- 7 MCP-using specialists (developer, tester, operator, architect, analyst, marketer, designer) updated with concise Tool Search guidance. Long static MCP tool listings removed.
- 4 mission files updated to remove retired `.mcp-profiles/` switching syntax.
- install.sh: `install_mcp_system()` and `setup_mcp_configuration()` simplified — no more `.mcp-profiles/` deployment, no more `dynamic-mcp.json` deployment. Post-install message rewritten to describe native tool deferring.
- Three artefacts archived (all built on misreadings or for retired systems):
  - `project/mcp/dynamic-mcp.json` → `.archive/2026-04-26-pre-4f/` (Claude API schema, not Claude Code).
  - `project/field-manual/mcp-optimization-guide.md` → `.archive/2026-04-26-pre-4f/` (entirely about retired profile-switching).
  - `project/deployment/scripts/validate-mcp-profiles.sh` → `.archive/2026-04-26-pre-4f/` (validates profiles that no longer exist).
- `library/CLAUDE.md` MCP section updated to mention `ENABLE_TOOL_SEARCH=auto` + v5.x retirement note. Still 78 lines.
- `sprints/sprint-4f-dynamic-mcp-tool-search.md` — spec recalibrated to match what was actually built.
- `sprints/sprint-4g-skills-and-routines.md` — outline replaced with detailed spec.

Full close-out in `progress.md` under `[2026-04-26] — Sprint 4f (T1, T2, T3, T5, T6, T8) Complete`.

---

## Next Actions

1. **Schedule the T7 batch** — four parked harness re-runs:
   - **4c** (Tasks 3, 4, 5) → `milestone-4c.md`. Tests dynamic context loading + deterministic router.
   - **4d** (Tasks 1, 2, 5) → `milestone-4d.md`. Tests lean CLAUDE.md + hooks.
   - **4e** (Tasks 1, 2, 3) → `milestone-4e.md`. Tests 3-file model + Phase Handoff blocks.
   - **4f** (Tasks 1, 2, 3) → `milestone-4f.md`. Tests `ENABLE_TOOL_SEARCH=auto` + Tool-Centric Workflow.
   - All four can run in one terminal session against the v5.2 baseline. Trends should show cumulative M2 reduction.
2. **Review Sprint 4g detailed spec** at `sprints/sprint-4g-skills-and-routines.md`. 10 tasks; biggest items are skills audit against open standard (T1), 3 Routine config templates (T4-T6), and `/coord` operational-intent detection (T7). No risky structural changes — Sprint 4g is mostly formalisation and platform integration.
3. **Sprint 4g execution** — most can run solo. T7 (operational-intent detection) is the trickiest behavioural change in 4g. T9 harness re-run needs terminal again.

---

## Open Items for Jamie

1. **Approve Sprint 4g scope** before execution — particularly T7 (`/coord` operational-intent detection). The trigger phrase set is the design call.
2. **T7 batch** — parked T7s now span 4c, 4d, 4e, 4f. Best run as a single terminal session against the v5.2 baseline.
3. **No urgent blockers**. Sprint 4f's recalibration was caught before any wrong code shipped to users.

---

## Key Files

| File | Purpose |
|------|---------|
| `project-plan.md` | v6.0 evolution overview, 8-sprint roadmap |
| `sprints/sprint-4f-dynamic-mcp-tool-search.md` | Just-completed sprint — T7 still open; T4 removed during recalibration |
| `sprints/sprint-4g-skills-and-routines.md` | Detailed spec, ready for review |
| `sprints/sprint-4h-validation-and-migration.md` | Final sprint — outline only; detailed spec is closing task of 4g |
| `project/validation/harness-spec.md` | How the harness works |
| `project/validation/baseline-v5.2.md` | v5.2 baseline (the target to beat) |
| `project/validation/milestone-4b.md` | Sprint 4b's harness results (the only v6.0 harness run so far) |
| `project/validation/run-playbook.md` | Step-by-step runbook for any milestone harness run |
| `library/CLAUDE.md` | 78 lines — deployed user-facing instructions |
| `library/settings.json.template` | Default advisory hooks + ENABLE_TOOL_SEARCH=auto |
| `templates/agent-context-template.md` | Includes Phase Handoff schema (5 fields) |
| `.claude/skills/meta-dev/SKILL.md` | Repo orientation skill (working-squad exception) |
| `.archive/2026-04-26-pre-4f/` | dynamic-mcp.json, mcp-optimization-guide.md, validate-mcp-profiles.sh |
| `.archive/2026-04-26-pre-4e/` | handoff-notes-template.md |
| `.archive/2026-04-17-pre-v6/` | Pre-v6 plan, sprints, progress, context |

---

## Notes for Fresh Session

- Scope rule: edits target library surface. The one v6.0 working-squad exception is `.claude/skills/meta-dev/` (created in 4d).
- Docs strategy: public-facing docs updated once in Sprint 4h. Per-sprint user-facing changes logged in `progress.md` under "User-Facing Changes" headings.
- Jamie prefers brief context + specific steps (ADHD). One task at a time, fully closed before moving on.
- **Instruction ordering**: never put caveats or "wait before X" *after* the step they qualify; trailing instructions are missed (memory-saved 2026-04-26).
- **Schema verification**: when an audit references "the spec" or "the schema", fetch the canonical docs before acting. Sprint 4f's mid-execution recalibration came from a Sprint 11 file that conflated Claude API and Claude Code schemas.
- British English by default.
- Instructions must be anchored to what Jamie sees on screen right now — don't require him to coordinate multiple windows without explicit consent.
