# Field-Manual Audit (Phase 3, sprint 2026-05-10)

Audit of every file in `project/field-manual/` against Addy Osmani's "process over prose" criterion. Each file is classified into one of four dispositions, with a recommended action. Conversion and retirement actions are followup work; this audit is the inventory and the plan.

## Classification

| Code | Meaning |
|---|---|
| **WORKFLOW** | Numbered steps with exit criteria. Agent-actionable as-is. Keep, possibly tighten. |
| **POINTER** | Cross-link or index. Slim by intent. Keep slim. |
| **ESSAY** | Prose reference. Useful as background, not actionable. Convert to workflow OR demote to a slim pointer that links to canonical source elsewhere. |
| **DEAD** | Stale; superseded by other content; or zero current relevance. Retire. |

Heuristic: numbered-step density (`steps / lines`) is the primary signal. Workflows score above 0.05; essays below 0.02. Citation count from canonical sources (README, CHANGELOG, agent prompts, install.sh, library/) determines whether a file can be retired without breaking links.

## Inventory and disposition

Sorted by lines, descending. "Active refs" is citations from agent prompts, commands, missions, library, or install.sh; canonical sources only.

| File | Lines | Steps | Active refs | Class | Action |
|---|---:|---:|---:|---|---|
| architecture-sop.md | 1,370 | 54 | 2 | WORKFLOW | Keep. Tighten: 1,370 lines is too long; split into core SOP plus appendices. |
| project-lifecycle-guide.md | 1,261 | 18 | 21 | ESSAY | Heavily cited but mostly prose. Convert to workflow (numbered phase exits with checkable artefacts) before next major release. Highest-impact conversion target. |
| migration-guides/file-persistence-v2.md | 1,153 | 55 | 3 | WORKFLOW | Keep. Migration runbook with steps. Tighten if v6.x renders parts obsolete. |
| tool-permissions-guide.md | 942 | 25 | 0 (14 broader) | ESSAY | Cited from README and `enhanced-prompting-guide`. Convert to workflow plus reference table; 942 lines for a permissions guide is essay-shaped. |
| enhanced-prompting-guide.md | 897 | 81 | 0 (1 broader) | WORKFLOW | High step density; well-structured. Cited from README only. Keep, retitle if needed. |
| bootstrap-guide.md | 712 | 67 | 2 | WORKFLOW | Keep. Bootstrap workflow used by `/bootstrap` command. |
| context-editing-guide.md | 700 | 38 | 22 | WORKFLOW | Keep. Cited 22 times; load-bearing for agents. |
| greenfield-implementation.md | 623 | 3 | 0 (2 broader) | ESSAY | Three numbered steps in 623 lines: prose. Cited from README only. Convert to workflow OR retire and replace with a one-page pointer to `mission-mvp` / `mission-build`. |
| bos-ai-integration-guide.md | 608 | 60 | 0 (6 broader) | WORKFLOW | Genuine workflow shape; cited from README. Keep. |
| architecture-decisions/file-persistence-solution.md | 591 | 2 | 0 (1 broader) | ESSAY | Architecture decision record; cited only from `project-plan-archive.md`. Keep as historical ADR; no action. |
| memory-management.md | 570 | 36 | 0 (8 broader) | WORKFLOW | High step density; cited from README. Keep. |
| extended-thinking-guide.md | 488 | 34 | 22 | WORKFLOW | Keep. Cited 22 times. |
| update-management.md | 483 | 5 | 0 (1 broader) | ESSAY | Five numbered steps in 483 lines; superseded by `docs/UPGRADE.md`. RETIRE; redirect single citation. |
| model-selection-guide.md | 453 | 18 | 0 (10 broader) | ESSAY | Cited from CHANGELOG; recently updated for Opus 4.7 / Sonnet 4.6. Mostly prose. Convert to a one-page table plus pointers; the prose explanation can move to a blog post. |
| mcp-troubleshooting.md | 444 | 34 | 0 (3 broader) | WORKFLOW | Step density 0.077; troubleshooting runbook. Keep. |
| skills-guide.md | 434 | 0 | 1 | ESSAY | Zero numbered steps, 434 lines. Convert to workflow including the new platform-side progressive-disclosure section (Phase 4 task 3). Highest-priority conversion in this list given its name. |
| brownfield-implementation.md | 410 | 4 | 0 (2 broader) | ESSAY | Same shape as greenfield-implementation: prose with few steps, cited only from README. Convert OR retire and replace with a pointer to `mission-dev-alignment`. |
| troubleshooting/task-delegation-file-persistence.md | 396 | 14 | 0 (3 broader) | WORKFLOW | Cited from `UPDATE-GUIDE.md` and `CRITICAL-UPDATE-2025-11-12.md`. Keep. |
| creating-missions.md | 394 | 36 | 0 (1 broader) | WORKFLOW | Cited from README. Keep. |
| multi-project-workflows.md | 344 | 9 | 0 (1 broader) | ESSAY | Step density 0.026. Single citation from `docs/README-restructuring-specification.md`. Candidate for RETIRE; the bulk-ops toolkit (v6.1.1 unreleased) supersedes most of this content. |
| quality-gates-guide.md | 340 | 11 | 0 (35 broader) | ESSAY | Cited 35 times incl. CHANGELOG. Convert: gate guide should itself be a workflow with verification steps. |
| ui-doctrine.md | 321 | 22 | 6 | WORKFLOW | Used by designer agent. Keep. |
| file-operation-quickref.md | 311 | 22 | 2 | WORKFLOW | Keep. Quickref consumed by coordinator. |
| mcp-integration.md | 287 | 25 | 1 | WORKFLOW | Keep; canonical MCP doc per v6.0 changelog. |
| plan-driven-development.md | 281 | 15 | 1 | WORKFLOW | Keep. Cited from `library/CLAUDE.md`. |
| architectural-principles.md | 273 | 30 | 0 (3 broader) | WORKFLOW | Cited from CHANGELOG and `install.sh`. Keep. |
| coordinator-commands.md | 272 | 22 | 0 (45 broader) | WORKFLOW | Cited 45 times. Keep. |
| coordinator-protocol.md | 254 | 27 | 0 (1 broader) | WORKFLOW | Single citation from `progress.md` (write-only changelog). Largely superseded by `project/agents/specialists/coordinator.md`. RETIRE if the reference can be removed; otherwise demote to pointer. |
| mission-execution-cheatsheet.md | 207 | 14 | 0 (4 broader) | WORKFLOW | Cited from README. Keep. |
| troubleshooting-file-persistence.md | 187 | 11 | 0 (2 broader) | WORKFLOW | Cited from sprint files only; v6.0 changes may have addressed the underlying issue. Keep until next file-persistence audit. |
| getting-started.md | 169 | 7 | 3 | POINTER/ESSAY | Mixed. Keep, slim if needed. |
| bos-ai-quickstart.md | 154 | 3 | 0 (2 broader) | ESSAY | Three steps in 154 lines. Cited only from `docs/` and an example README. Convert to a true quickstart (numbered, terse) or retire in favour of `bos-ai-integration-guide.md`. |
| README.md | 1 | 0 | 14 | POINTER | Index. Cited 14 times. Keep. |

## Summary by disposition

**WORKFLOW (16 files, 7,873 lines).** Keep as-is or tighten. The bulk of well-cited content. Two oversized (architecture-sop.md at 1,370 lines, file-persistence-v2.md at 1,153 lines) deserve length cuts but not retirement.

**ESSAY (12 files, 6,316 lines).** The conversion opportunity. Highest-impact targets:
1. `project-lifecycle-guide.md` (1,261 lines, 21 active refs). Most-cited essay; converting it pays back across 21 call sites.
2. `tool-permissions-guide.md` (942 lines). README-cited; current shape is reference-doc not agent-actionable.
3. `skills-guide.md` (434 lines). Specifically named as a target for Phase 4 task 3 (platform-side progressive disclosure).
4. `quality-gates-guide.md` (340 lines, 35 broader refs). The gate guide should be a workflow.

**RETIRE candidates (3 files, 982 lines).** All have low active-citation counts:
- `update-management.md` (483 lines). Superseded by `docs/UPGRADE.md`. Redirect the single citation in `project/docs/UPDATING.md`.
- `multi-project-workflows.md` (344 lines). Superseded by the bulk-ops toolkit (Unreleased section of CHANGELOG). Single citation in a `docs/` file.
- `coordinator-protocol.md` (254 lines). Largely superseded by `project/agents/specialists/coordinator.md`. Single citation in `progress.md` (write-only).

Conditional retirement: `bos-ai-quickstart.md` (154 lines), `greenfield-implementation.md` (623), `brownfield-implementation.md` (410). These are essay-shaped, lightly cited, and arguably superseded by mission files (`mission-mvp.md`, `mission-build.md`, `mission-dev-alignment.md`). Decision: keep or retire as part of a deliberate documentation refactor, not a hygiene pass.

**POINTER (2 files).** README.md and getting-started.md. Keep slim.

## Recommended next actions

1. **Now (this sprint, before merge):** No content changes. The audit is the deliverable; conversions and retirements are larger pieces of work that need their own attention.
2. **Next sprint, low-effort wins:**
   - Retire `update-management.md`, redirecting `project/docs/UPDATING.md` to `docs/UPGRADE.md`.
   - Retire `multi-project-workflows.md`, redirecting the single citation to the bulk-ops toolkit README.
   - Convert `skills-guide.md` to a workflow (this is also Phase 4 task 3 of the current sprint, but the conversion itself is a separate piece of work).
3. **Subsequent sprints, larger conversions:**
   - `project-lifecycle-guide.md` essay-to-workflow.
   - `tool-permissions-guide.md` essay-to-workflow plus reference table.
   - `quality-gates-guide.md` essay-to-workflow.
   - `architecture-sop.md` length cut: split core SOP from appendices.

## What this audit deliberately does not do

- Retire any files. References from README and active library content mean retirement requires reference updates that are out of scope here.
- Convert any essays to workflows. Each conversion is a substantive piece of work that deserves its own review.
- Touch the four files Phase 4 will modify (`skills-guide.md` for progressive-disclosure docs).

The audit is the plan. Acting on it is sequenced work for subsequent sprints.
