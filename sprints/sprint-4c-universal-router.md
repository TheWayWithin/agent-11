# Sprint 4c: The Universal Router

**Part of**: Agent-11 v6.0 Evolution (Sprint 4 umbrella)
**Predecessor**: Sprint 4b — Prompt Hygiene & Budget Controls ✅ (authored; execution in progress)
**Successor**: Sprint 4d — Native Primitives + CLAUDE.md Shrink
**Status**: Detailed spec ready for Jamie's review; execution pending Sprint 4b T6 harness re-run

---

## Goal

Collapse the menu of explicit commands behind a single universal interface: `/coord [mission]`. Use **deterministic mission-based routing** — the mission name dispatches explicitly to a mode, no NLP intent inference. Add dynamic context-loading so sessions don't pay for context they don't need.

## Why This Sprint

Three baseline observations justify this change:

1. **The `/coord` command expands into a massive mission-activation briefing** (visible in the v5.2 baseline at the start of every task — tens of thousands of tokens of ceremony before real work starts). Most of that briefing is duplicated in `coordinator.md` itself; there's no reason to include it in every invocation.
2. **Different mission types have different context needs.** A read-only commit review doesn't need `agent-context.md`. A bug fix doesn't need `evidence-repository.md`. Loading everything always is the v5.2 default; deterministic routing lets each mission type load what it actually needs.
3. **The menu of explicit commands is larger than needed.** `/coord fix`, `/coord build`, `/coord refactor`, `/coord deploy`, `/coord optimize`, `/coord release`, `/coord mvp` — users should have one entry point, not seven. The variation lives in the mission file.

## Scope Reminder

All edits target the **library surface** (`project/commands/`, `project/missions/`, `project/agents/specialists/coordinator.md`). Do not modify `.claude/commands/` in this repo.

---

## Tasks

### T1. Design the routing table

**Deliverable**: a clear table in `project/commands/coord.md` showing which mission names dispatch to which mode, what context files load, and what budget applies.

**Proposed routing table** (starting point — refine during execution):

| Mission name | Mode | Context loaded at start | Notes |
|--------------|------|-------------------------|-------|
| `build` | A — Greenfield | project-plan.md, context.md, relevant skills | Long-horizon; heavy tracking |
| `mvp` | A — Greenfield | project-plan.md, context.md, relevant skills | Build alias; same shape |
| `dev-setup` | A — Greenfield | Starting ideation only | Bootstraps the tracking files |
| `integrate` | A — Greenfield | project-plan.md, context.md | Third-party work |
| `migrate` | A — Greenfield | project-plan.md, context.md | Data / schema work |
| `fix` | B1 — Surgical | nothing by default (or just the bug report) | Light context; no project-plan update unless task becomes multi-step |
| `refactor` | B2 — Mission | project-plan.md if it exists | Moderate context |
| `optimize` | B2 — Mission | project-plan.md if it exists | Moderate context |
| `release` | B2 — Mission | project-plan.md, context.md | Higher stakes; more tracking |
| `deploy` | B2 — Mission | project-plan.md, context.md | Higher stakes; more tracking |

**Acceptance**: Table published in `coord.md`. Jamie has reviewed it and confirmed the dispatch mapping matches his mental model.

---

### T2. Rewrite `project/commands/coord.md`

**Current state**: 549 lines containing the full coordinator briefing inline (duplicates content in `coordinator.md`).

**Target state**: <100 lines. Role:
- Accept a mission name argument.
- Validate the name against the routing table.
- Load context per the routing table (either directly, or by setting expectations for the coordinator that will be delegated to).
- Delegate to the coordinator specialist with minimal extra prompt (the coordinator already knows what to do).

**Key edits**:
- Remove the duplicated coordinator briefing (it lives in `coordinator.md` now and shouldn't be reproduced in the command).
- Replace with a thin dispatch shell: validate mission name, set context-loading flags, hand off.
- Preserve the "unknown mission" fallback — if mission name doesn't match, print the valid list and exit (no NLP inference).

**Acceptance**: `coord.md` is under 100 lines. A smoke test of `/coord fix` against a small fixture still behaves correctly. `/coord bogus` produces a clear "unknown mission" error.

---

### T3. Preserve pipeline commands as explicit exceptions

**Pipeline commands** are multi-step processes where deviation is not allowed:
- `/foundations` — ingest BOS-AI documents, structure them into YAML
- `/architect` — 8-decision design session
- `/bootstrap` — scaffold project-plan.md from templates

These remain as standalone commands. The routing table does NOT dispatch them via `/coord`.

**Open question from project-plan.md**: should `/foundations` fold into `/bootstrap` since they're always sequential?

**Decision for this spec**: **keep them separate.** Reasoning:
- `/foundations` can run independently when users have BOS-AI documents but aren't ready to scaffold yet.
- `/bootstrap` can run independently when users have a vision in their head and want a plan template without going through BOS-AI ingestion.
- Merging them hard-wires a sequence that doesn't always apply.
- If the sequential flow is common, a thin `/kickoff` wrapper that calls both in order is better than merging.

**Acceptance**: `/foundations`, `/architect`, `/bootstrap` preserved unchanged. `/coord` routing table explicitly notes these as "not routed via /coord — see standalone commands".

---

### T4. Implement dynamic context loading

**Mechanism**: the coordinator reads the routing table entry for the invoked mission and loads *only* the context files listed. `evidence-repository.md` is NEVER loaded by default — only on demand when the coordinator determines it's needed.

**Changes in `coordinator.md`**:
- Add a "Dynamic Context Loading" section near the top that describes the per-mode behaviour.
- Replace the current "always read all 4 tracking files first" pattern with "read only what the mode requires".
- Retain the staleness-check logic but scope it to the files actually loaded.

**Changes in `/coord`**:
- The dispatcher passes the mission name to the coordinator along with the expected context set.

**Acceptance**: A `/coord fix` run starts by reading only the bug report (not project-plan.md, not context.md, not handoff-notes.md). A `/coord build` run reads project-plan.md and context.md as before.

---

### T5. Mode override for ambiguous tasks

**Syntax**: `/coord mode:maintenance [mission]` lets a user explicitly set the mode when the default routing would be wrong.

**Example**: `/coord mode:maintenance security audit` — treats "security audit" as a maintenance mode B2 task (loads project-plan.md) rather than rejecting because "security" isn't in the routing table.

**Implementation**: simple argument parser in `/coord` that strips the `mode:X` prefix and applies that mode's loading rules regardless of mission name.

**Acceptance**: Mode override works for all three modes (A, B1, B2). Documented in `coord.md` usage help.

---

### T6. Unknown-mission fallback

**Behaviour**: when the mission name doesn't match the routing table, `/coord` prints a clear error listing valid missions and exits. No NLP inference. No "did you mean...".

**Rationale**: the v6.0 blueprint explicitly warns against "the hidden coin flip of intent inference". Deterministic routing means the user knows what happened; the command either ran or it didn't.

**Acceptance**: `/coord definitely-not-a-mission` prints:
```
Unknown mission: definitely-not-a-mission

Valid missions:
  Greenfield (Mode A):     build, mvp, dev-setup, integrate, migrate
  Surgical (Mode B1):      fix
  Maintenance (Mode B2):   refactor, optimize, release, deploy

Override: /coord mode:maintenance <anything>
Standalone: /foundations, /architect, /bootstrap
```
...and exits.

---

### T7. Re-run harness and measure

**Subset**: Tasks 3 (bug fix), 4 (refactor), 5 (commit review). Cheapest to re-run; exercise the main routing paths.

**Deliverable**: `project/validation/milestone-4c.md` with results compared to the latest baseline (v5.2 or whatever Sprint 4b produced if its T6 ran).

**Success criteria**:
- M2 (session-start tokens) drops measurably on Mode B1 tasks (3, 5) — those no longer load project-plan.md/context.md by default.
- M2 on Mode A/B2 tasks (4) stays roughly flat or improves.
- No regression in outcomes — all tasks still succeed.

---

### T8. Write Sprint 4d detailed spec

**Deliverable**: replace the outline at `sprints/sprint-4d-native-primitives-and-claudemd-shrink.md` with a detailed spec.

The detailed spec should cover:
- Exact `.claude/settings.json` hooks for PostToolUse / PreToolUse quality gates.
- What rules move from prompts into hooks, and what rules stay in prompts.
- The <80 line shape of `library/CLAUDE.md`.
- Which rules get decentralised into specific command files.
- The Meta-Development Skill that makes the agent-11 repo look different from a user product repo.

**Acceptance**: Sprint 4d detailed spec written; Jamie has reviewed and approved scope.

---

## Definition of Done

- [ ] T1: Routing table published in `coord.md`; Jamie approved
- [ ] T2: `coord.md` under 100 lines; smoke test passes
- [ ] T3: Pipeline commands preserved; routing table notes them as separate
- [ ] T4: Dynamic context loading working — `/coord fix` doesn't load tracking files by default
- [ ] T5: Mode override syntax works for all three modes
- [ ] T6: Unknown-mission fallback prints clear error and exits
- [ ] T7: Harness subset re-run; `milestone-4c.md` committed; M2 drops on Mode B1 tasks
- [ ] T8: Sprint 4d detailed spec written and approved

---

## Risks & Watch-Items

- **Breaking existing `/coord` calls.** If anyone has scripts or aliases using `/coord build foo.md` they should still work — the routing table preserves those exact mission names. But `/coord` with no argument currently enters interactive mode; this sprint should preserve that or explicitly change it.
- **Regression in mission-flow semantics.** Mission files contain detailed phase protocols. The dispatch shell must still invoke those protocols — it just shouldn't duplicate them inline in `coord.md`.
- **Context loading heuristics being wrong.** If `/coord fix` needs project-plan.md for an unusually complex fix, the coordinator can still load it on demand — default is minimal, not forbidden.
- **Interactive mode behaviour.** `/coord` with no arguments today presents a menu. Decide whether to preserve, simplify, or remove that. Spec recommendation: preserve, simpler text.

---

## Open Design Questions Resolved in This Spec

- **`/foundations` fold into `/bootstrap`?** No — keep separate. Consider a thin `/kickoff` wrapper later if the sequential flow is common.
- **Mode override syntax?** `/coord mode:maintenance [mission]` — simple prefix parse.
- **Unknown-mission behaviour?** Fail closed with a clear error. No NLP inference.

---

## Notes for Execution

- T1 is the thinking task — get the routing table right before any code changes.
- T2 is the biggest single diff — `coord.md` 549 lines → <100 lines. Backup before starting.
- T7 is mandatory — no skipping the measurement step.
- Sprint 4c changes the `/coord` surface area that users touch directly. Be careful. Preserve a working backup and smoke-test on a small fixture before committing.
