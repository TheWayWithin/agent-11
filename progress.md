# AGENT-11 v6.0 Evolution — Progress Log

Fresh log starting at the close of Sprint 4a T6 (2026-04-19). Historic log preserved at `.archive/2026-04-17-pre-v6/progress-historic.md`.

This file tracks the v6.0 evolution only. Per the v6.0 plan (`project-plan.md` → "Context Consolidation"), `progress.md` is retained as a backward-looking changelog but will be moved out of the active-context default in Sprint 4e.

---

## 📦 Recent Deliverables

### [2026-04-19] — Sprint 4a Complete ✅

**Summary**: Sprint 4a (Baseline + Great Deletion) complete. Harness spec locked, full v5.2 baseline measured across 5 tasks, MCP profile system deleted, `.backup` files removed, coordinator prompt stripped of ASCII decoration, historic context files archived, Sprint 4b detailed spec authored.

**Deliverables (T1–T7)**:
- `project/validation/harness-spec.md` — 5-task harness with metric definitions and capture method (T1)
- `project/validation/baseline-v5.2.md` — full v5.2 baseline results, 5 tasks run, summary observations captured (T2)
- MCP profile system deleted: `.mcp-profiles/`, root `mcp-setup.sh`, `.claude/commands/mcp-{switch,status,list}.md` (T3)
- 12 `.backup` files in `project/agents/specialists/` removed; `project/agents/specialists.backup-20251030-083005/` directory removed (T4)
- `project/agents/specialists/coordinator.md` de-decorated: 3,559 → 2,836 lines (~20% reduction); rules intact (T5)
- `progress.md`, `agent-context.md`, `handoff-notes.md` archived to `.archive/2026-04-17-pre-v6/*-historic.md`; fresh versions created (T6)
- `sprints/sprint-4b-prompt-hygiene-and-budget-controls.md` expanded from outline to detailed spec (T7)

**Baseline Key Findings (v5.2)**:
- M2 (session-start tokens) flat at ~49.4k across all 5 tasks — this is the number v6.0 must beat.
- Delegation is largely theatre: 3 of 5 tasks either didn't delegate or got empty responses from the called subagent, with the coordinator doing the work itself.
- Ceremony overhead is significant: Task 4 took 6:07 for work comparable to Task 3's 1:30. The gap is tracking-file creation.
- Subagent hallucinations are persistent (architect, tester, developer all produced output referencing code/files that didn't exist); coordinator's cross-checks caught them.
- M4 (human interventions) was zero across all tasks — the system is autonomous, just not efficient.

**User-Facing Changes** (for Sprint 4h docs consolidation):
- `/mcp-switch`, `/mcp-list`, `/mcp-status` commands retired. Replacement is dynamic tool search in Sprint 4f. Deprecation notice added to README.

---

### [2026-04-19] — v6.0 Evolution Kickoff

Continuing from the v6.0 planning session committed in `aa6ecdb`. Historic context (pre-v6 plan, Sprint 9/11 work) preserved in `.archive/2026-04-17-pre-v6/`.
