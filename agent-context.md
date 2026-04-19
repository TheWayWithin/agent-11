# Agent Context — AGENT-11 v6.0 Evolution

Fresh context file opened at close of Sprint 4a T6 (2026-04-19). Historic context preserved at `.archive/2026-04-17-pre-v6/agent-context-historic.md`.

Per the v6.0 plan (`project-plan.md` → "Context Consolidation"), `handoff-notes.md` will be folded into this file as a structured Phase Handoff block in Sprint 4e; `progress.md` will move out of the active-context default. For now (Sprints 4a–4d), all three files remain in use.

---

## Mission

Evolve Agent-11 from a prompt-heavy local squad into a lean, platform-native orchestrator aligned with Claude Code's native primitives (hooks, subagents, Routines, Tool Search, `defer_loading`). Delivered as 8 sub-sprints (4a–4h) under the Sprint 4 umbrella.

See `project-plan.md` for full plan. See `Ideation/Agent-11 v6.0 Master Blueprint_ The Lean Orchestrator (Final Revision)` for the source document.

---

## Current State (as of 2026-04-19)

**Sprints completed**: 4a (Baseline + Great Deletion)
**Sprint ready**: 4b (Prompt Hygiene & Budget Controls) — detailed spec in `sprints/sprint-4b-prompt-hygiene-and-budget-controls.md`
**Sprints outlined**: 4c, 4d, 4e, 4f, 4g, 4h

---

## Key Decisions Made to Date

1. **Scope rule**: All v6.0 edits target the library surface (`project/`, `library/CLAUDE.md`, `templates/`), not the internal working squad (`.claude/agents/`, `.claude/commands/`). One exception allowed in Sprint 4a T3 (delete dead internal MCP command stubs).
2. **Docs strategy**: Public-facing docs (`README.md`, `CHANGELOG.md`, `docs/RELEASE-HISTORY.md`, `MCP-GUIDE.md`) updated once as a consolidated effort in Sprint 4h. Per-sprint: log user-facing changes to `progress.md`. Exception: brief deprecation notices (≤5 lines) inline when users depend on what's being removed.
3. **Rolling wave planning**: Detailed spec only for the current sprint; the last task of each sprint writes the next sprint's spec.
4. **Executor stance for the validation harness**: Option B — fresh Claude session drives each task, Jamie observes and records. Same stance for all later milestone runs so comparisons are apples-to-apples.
5. **Task 5 (commit review) framing**: Pivoted from "PR review" to "commit review" because Jamie is a solo developer who pushes directly to `main`, not via PRs.

---

## Baseline Metrics (v5.2)

See `project/validation/baseline-v5.2.md` for the full record. Headline numbers:

| Metric | T1 | T2 | T3 | T4 | T5 |
|--------|----|----|----|----|----|
| M1 time | 34:17 | 2:51 | 1:30 | 6:07 | 1:37 |
| M2 tokens | 49.3k | 49.5k | 49.5k | 49.5k | 49.3k |
| M3 delegations | multiple | 2 (both empty) | 0 | 1 (empty) | 0 |
| M4 interventions | 0 | 0 | 0 | 0 | 0 |

---

## Open Questions (resolve at the relevant sprint)

- **4b**: `/effort` vs `MAX_THINKING_TOKENS` for budget controls (resolved in the Sprint 4b detailed spec).
- **4c**: Does `/foundations` fold into `/bootstrap`?
- **4d**: Which quality checks are safe to move from prompts to `PostToolUse` hooks?
- **4e**: Is `progress.md` dropped entirely or retained as an append-only generated artefact?
- **4f**: Which MCP tools are "discovery" (pre-loaded) vs "execution" (deferred)?
- **4g**: Do Routines ship as committed configs or paste-from-docs snippets?

---

## Active Issues / Watch-Items

- **Secure-install squad regression**: `secure-install.sh` drops the squad argument passed to `install.sh`, so users of the secure installer always get core squad (4 agents), no way to select full. Found in Task 5 commit review. Separate from the v6.0 sprints; worth a standalone fix.
- **Subagent hallucinations**: Multiple specialists (architect, tester, developer) produce output referencing code/files that don't match reality. Coordinator's cross-checks save the day in v5.2. Worth explicit attention in Sprint 4b's subagent prompt updates.
