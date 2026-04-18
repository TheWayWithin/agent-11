# Handoff Notes — Agent-11 v6.0 Evolution

**Last Updated**: 2026-04-17
**From**: Planning session (2026-04-17)
**To**: Next session — execute Sprint 4a

---

## Where We Are

Planning for the Agent-11 v6.0 evolution is complete. The overall plan is in `project-plan.md`. Eight sprints (4a–4h) under the Sprint 4 umbrella, delivered rolling-wave style: detailed spec only for the current sprint; the final task of each sprint writes the spec for the next.

Reference documents (review is complete — do not re-analyse unless Jamie asks):
- `Ideation/Agent-11 v6.0 Master Blueprint_ The Lean Orchestrator (Final Revision)`
- `Ideation/Dynamic MCP Tooling for Agent-11_ Context Optimization and Agent Routing.md`

**Note**: Sprint 11 work (Dynamic MCP Tooling, Phases 11A–E) shown in the previous handoff-notes is from the archived initiative. That work produced `project/mcp/dynamic-mcp.json` and `project/schemas/dynamic-mcp.schema.yaml`, which remain in the repo and will be picked up again in Sprint 4f. The earlier Phase 11C documentation task is superseded by the v6.0 plan.

---

## What Was Done Today (2026-04-17)

1. Reviewed the v6.0 Master Blueprint and the Dynamic MCP Tooling companion doc.
2. Verified current-state facts against the blueprint:
   - `library/CLAUDE.md` = 575 lines
   - `.claude/CLAUDE.md` = 214 lines
   - `coordinator.md` = 3,558 lines (heavily decorated)
   - `coord.md` = 549 lines
   - MCP profile system exists (`.mcp-profiles/`, commands in `.claude/commands/`)
   - 11 `.backup` files in `project/agents/specialists/`
3. Archived previous initiative to `.archive/2026-04-17-pre-v6/`:
   - Previous `project-plan.md` (Sprint 9 / Sprint 11 era work)
   - `security-sprint-1-critical-shell-hardening.md`
   - `security-sprint-2-install-integrity-and-hardening.md`
4. Wrote new `project-plan.md` (v6.0 overview, 8-sprint roadmap, rolling-wave protocol, open questions).
5. Wrote detailed `sprints/sprint-4a-baseline-and-great-deletion.md` (7 tasks, ready to execute).
6. Wrote outline stubs for `sprints/sprint-4b` through `sprint-4h`.
7. Left `sprints/sprint-3-agent-prompt-injection-defense.md` untouched (active security work, separate initiative).
8. Added explicit scope clarity — all v6.0 edits target the **library surface** (`project/`, `library/CLAUDE.md`, `templates/`), not our internal working squad (`.claude/agents/`, `.claude/commands/`). See `project-plan.md` → "Scope: What We're Changing". One allowed exception is called out in Sprint 4a T3 (delete dead internal MCP command stubs).
9. Added documentation strategy — public-facing docs (`README.md`, `CHANGELOG.md`, `docs/RELEASE-HISTORY.md`, `MCP-GUIDE.md`) updated once as a consolidated effort in Sprint 4h, NOT per-sprint. Each sprint logs "User-Facing Changes" to `progress.md`; 4h consolidates. Exception: brief deprecation notices in-sprint for anything removed users depend on.

---

## Next Action

**Start Sprint 4a** — see `sprints/sprint-4a-baseline-and-great-deletion.md`.

First task: T1 — Validation Harness Spec. Before starting T1, resolve the three items below with Jamie.

---

## Open Items to Resolve Before Sprint 4a Execution

1. **MCP profile commands in use on live projects?**
   Sprint 4a T3 deletes `.claude/commands/mcp-switch.md`, `mcp-status.md`, `mcp-list.md`. Confirm Jamie isn't depending on these in other projects. If he is, add a deprecation step before deletion.

2. **Harness task definition (T1) — pair or solo?**
   T1 is the critical path for measuring every later sprint. The 5 representative tasks need to be reproducible and genuinely representative. Worth Jamie's input on the task selection before drafting.

3. **Open questions in `project-plan.md`** (6 total, one per future sprint)
   Not blockers for 4a, but worth scanning to see if any need early resolution. Examples: `/effort` vs `MAX_THINKING_TOKENS` for budget controls (4b), does `/foundations` fold into `/bootstrap` (4c).

---

## Key Files

| File | Purpose |
|------|---------|
| `project-plan.md` | v6.0 evolution overview, 8-sprint roadmap |
| `sprints/sprint-4a-baseline-and-great-deletion.md` | Current sprint — detailed, ready |
| `sprints/sprint-4b..4h` | Future sprints — outline only; detailed spec is Task 1 of each |
| `.archive/2026-04-17-pre-v6/` | Previous plan and security sprints |
| `progress.md` | Running log (will be archived in Sprint 4a T6) |
| `agent-context.md` | Historic mission context (will be archived in Sprint 4a T6) |

---

## Notes for Fresh Session

- Don't re-litigate the sprint breakdown — it's already reviewed and approved by Jamie.
- The existing `progress.md` and `agent-context.md` are historic (Sprint 9 / Sprint 11 era). They'll be archived as part of Sprint 4a T6. Don't merge today's work into them.
- Jamie prefers brief context + specific steps (ADHD). One task at a time, fully closed before moving on.
- Use British English.
- Naming convention confirmed: v6.0 sprints are 4a–4h. `sprint-3-agent-prompt-injection-defense.md` is separate active security work.
- The previous coordinator protocol (NO WAITING, heavy ASCII decoration) is what v6.0 is replacing. Expect to edit the coordinator prompt itself in Sprints 4a (decoration only) and 4d (content shrink).
