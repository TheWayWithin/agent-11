# Sprint 4b: Prompt Hygiene & Budget Controls

**Part of**: Agent-11 v6.0 Evolution (Sprint 4 umbrella)
**Predecessor**: Sprint 4a — Baseline + Great Deletion ✅
**Successor**: Sprint 4c — The Universal Router
**Status**: Detailed spec ready for Jamie's review; execution pending approval

---

## Goal

Replace forced-immediacy ceremony ("NO WAITING / DELEGATE IMMEDIATELY") with Karpathy-aligned discipline (state assumptions, prefer minimal diffs, choose the lightest valid execution path). Introduce explicit budget controls so Opus 4.7's extended thinking doesn't run away. Measure the impact against the v5.2 baseline.

## Why This Sprint

Sprint 4a's baseline confirmed three problems that this sprint addresses:

1. **Ceremony overhead is significant.** Task 4 took 6:07 for work comparable to Task 3's 1:30. The gap was the coordinator writing `project-plan.md`, `progress.md`, `agent-context.md`, `handoff-notes.md` and phase-completion entries for a two-file refactor. The forced-immediacy language compels the coordinator into theatre.
2. **Delegation is largely empty.** Three of five tasks either didn't delegate at all or got "0 tool uses" responses from the called subagent. The delegation protocol wastes time and tokens on calls that produce nothing.
3. **Subagent hallucinations are persistent.** Architect, tester, and developer subagents produced output referencing code/files that didn't match reality. Coordinator's cross-checks saved the day; without them, real damage would occur.

This sprint changes the *behavioural* layer of the specialists — how they decide what to do and how carefully they verify. Later sprints change the structural layer (router, hooks, context files).

## Scope Reminder

All edits target the **library surface** (`project/agents/specialists/`, `project/commands/`, `library/CLAUDE.md`). Do not modify `.claude/agents/` or `.claude/commands/` in this repo. See `project-plan.md` → "Scope: What We're Changing".

---

## Tasks

### T1. Draft the Karpathy Constitution

**Deliverable**: `project/constitution/karpathy-constitution.md`

Seven principles, short and direct. These live as a standalone document in `project/constitution/` so later sprints can reference it from `library/CLAUDE.md` (Sprint 4d) and individual specialist prompts.

The seven principles (verbatim wording for this sprint):

1. **Read before writing.** Open the file, understand the surrounding code, and verify assumptions before any edit.
2. **State assumptions explicitly.** If an instruction is ambiguous, name the interpretation you are acting on. Do not infer silently.
3. **Prefer minimal diffs.** Change the smallest set of lines that makes the task correct. Refactor only what the task requires.
4. **Verify with tests or by running the code.** A green test or a clean build beats a plausible argument.
5. **Avoid speculative refactors.** Do not improve adjacent code unless the task explicitly calls for it.
6. **Choose the lightest valid execution path first.** If a task can be done without tracking files, without delegation, or without scaffolding, do it that way. Add ceremony only when the task genuinely requires it.
7. **When uncertain between two plausible interpretations, present both briefly and choose one explicitly.** Do not defer the choice to the user unless the cost of being wrong is high.

**Acceptance**: Constitution file committed; Jamie has read and approved the wording; referenced from Sprint 4b specs where relevant.

---

### T2. Replace forced-immediacy patterns in coordinator

**Target**: `project/agents/specialists/coordinator.md` (currently 2,836 lines after Sprint 4a T5).

**What to replace**:

- "NO WAITING" / "DELEGATE IMMEDIATELY" → replace with "PAUSE-AND-PLAN" pattern: state the task, state assumptions, name the lightest valid execution path, then act.
- "MANDATORY" blocks that repeat the same rule three times → collapse to one statement.
- "CRITICAL" / "🚨" stacking where the same rule is flagged multiple times → keep one, drop the rest.
- Self-referential protocol-violation warnings ("IF YOU SEE THIS, STOP") that fire on the coordinator's own output → replace with a single checklist at the point of action.

**What NOT to change**:

- Actual content of rules (Sprint 4d does content shrink).
- Load-bearing examples, templates, and delegation patterns.
- The `subagent_type` API guidance (that's still correct for v5.2).

**Acceptance**: `coordinator.md` has no "NO WAITING" language remaining; the PAUSE-AND-PLAN block is present at the top; redundant "CRITICAL" stacking is reduced. No behavioural regression on a smoke run of `/coord fix` against a small fixture.

---

### T3. 3-phase prompt minimization pass

Apply to `coordinator.md` and the 10 other specialists in `project/agents/specialists/` one at a time.

**Phase 1 — Delete decoration** (largely done in 4a for coordinator): check the remaining 10 specialists for ASCII art, decorative emoji as section headers, redundant warning blocks. Remove.

**Phase 2 — Collapse overlapping checklists.** When a prompt lists the same requirement in three different sections (e.g., "verify files exist" appears in pre-delegation, post-delegation, and phase-gate), keep one authoritative statement and reference it from the other places.

**Phase 3 — Relax forced-immediacy language.** 4.7 thinks internally. Phrases like "IMMEDIATELY", "RIGHT NOW", "WITHOUT DELAY", "DO NOT HESITATE" add cost without benefit. Replace with neutral phrasing ("Then", "Next", "When ready").

**Evidence threshold**: a change is worth making if it removes text without changing observed behaviour on a smoke test. When in doubt, keep.

**Acceptance**: All 11 specialists have been through the 3-phase pass. Net line count reduction across the 11 files is at least 10%. Smoke tests of `/coord fix` and `/coord refactor` on small fixtures still succeed.

---

### T4. Add budget controls to mission frontmatter

**Decision**: use `MAX_THINKING_TOKENS` as the primary mechanism. Reasoning:
- `/effort` is a Claude Code CLI flag, set by the user at session start — it can't be set per-mission from within a prompt.
- `MAX_THINKING_TOKENS` is an environment-variable-driven cap that affects the whole session but is documented and supported.
- Mission-level budgets are best expressed as guidance to the coordinator ("this mission is expected to complete in roughly N interactions / M minutes; if it exceeds that, stop and summarise state") rather than as a hard technical cap.

**What to add**:

- Each mission file in `project/missions/mission-*.md` gets a frontmatter block with:
  - `expected_duration`: rough wall-clock target (e.g., `10-20 min`)
  - `expected_interactions`: rough count of tool-use / delegation turns (e.g., `5-15`)
  - `on_budget_exceeded`: what the coordinator does — usually "summarise state to `context.md`, mark next step in `project-plan.md`, stop cleanly"

- A new section in `coordinator.md` (or a referenced doc) describing how the coordinator interprets these budgets — not as a hard cap, but as a signal to pause and check in.

**Acceptance**: Frontmatter present in at least the 3 most-used missions (`build`, `fix`, `refactor`). Coordinator prompt references the budget-exceeded protocol. Budget guidance is consistent with the Karpathy constitution's "lightest valid execution path".

---

### T5. Subagent prompt hardening (address hallucinations found in baseline)

Baseline found that architect, tester, developer all produced output referencing code/files that didn't match reality. Coordinator's cross-checks recovered. This sprint makes the subagents themselves less hallucination-prone.

**For each of: `architect.md`, `developer.md`, `tester.md`**:

- Add a "Read first" preamble: before generating any `old_string` / file content referring to existing code, the subagent must use the Read tool to load the actual file. If Read is not available in the subagent's toolset, the subagent must explicitly say so and produce a *design* rather than a code edit.
- Add a self-check before returning: "Verify every file path, symbol name, or `old_string` you reference matches what you have actually read in this conversation. If you are inferring from memory or the task description, say so and treat your output as a proposal for the coordinator to validate."
- Remove any instruction that tells the subagent to "assume" or "infer" file contents.

**Acceptance**: The three specialists have the "Read first" preamble and self-check. A re-run of Task 4 (refactor) from the baseline shows the developer either (a) reads the actual files before producing edits, or (b) explicitly states it cannot and produces a design only.

---

### T6. Re-run harness subset and measure

**Subset**: Tasks 3 (bug fix), 4 (refactor), 5 (commit review). These are the cheapest to re-run and exercise the main ceremony / delegation / review paths.

**Deliverable**: `project/validation/milestone-4b.md` with one row per re-run task, following the same template as `baseline-v5.2.md`.

**Success criterion**: at least one of the following is true:
- M2 (session-start tokens) drops by ≥5% on re-runs vs baseline.
- M1 (completion time) on Task 4 drops by ≥25% (the most ceremony-heavy task).
- M3 (delegation count) changes are either (a) higher with real content returned, or (b) lower with explicit "coordinator handles directly" reasoning.

If none of these hold, Sprint 4b is closed as "behavioural change made, no measurable impact yet" — the changes still stand and we evaluate again in later sprints.

---

### T7. Write Sprint 4c detailed spec

**Deliverable**: replace the outline at `sprints/sprint-4c-universal-router.md` with a detailed spec.

The detailed spec should cover:
- The deterministic routing table (Mode A / B1 / B2 missions and which each `/coord [mission]` name dispatches to).
- Dynamic context loading heuristic — which files get loaded for each mode.
- How explicit pipeline commands (`/foundations`, `/architect`, `/bootstrap`) are preserved as exceptions.
- Resolution of the open question: does `/foundations` fold into `/bootstrap`?
- Fallback behaviour for unknown mission names.

**Acceptance**: Sprint 4c detailed spec written; Jamie has reviewed and approved scope.

---

## Definition of Done

- [ ] T1: Karpathy constitution published; Jamie approved the wording
- [ ] T2: Coordinator forced-immediacy language replaced with PAUSE-AND-PLAN
- [ ] T3: 3-phase minimization applied to all 11 specialists; ≥10% net line reduction
- [ ] T4: Budget controls in at least 3 mission frontmatters; coordinator knows the budget-exceeded protocol
- [ ] T5: Architect/developer/tester have the "Read first" preamble and self-check
- [ ] T6: Harness subset re-run; milestone-4b.md committed; at least one success criterion met or sprint explicitly closed as "behaviour change, measure again later"
- [ ] T7: Sprint 4c detailed spec written and approved
- [ ] Progress.md entry logged, including any user-facing changes

---

## Risks & Watch-Items

- **Regression risk on coordinator prompt**. Stripping forced-immediacy language could reduce responsiveness or cause the coordinator to sit idle. Test after each major edit; roll back specific changes if observed. Keep `coordinator.md.pre-4b` backup before starting T2.
- **Hallucination hardening that breaks useful inference**. The "Read first" preamble (T5) should not prevent subagents from reasoning about code they cannot read — they should still produce useful design, just explicitly flagged as design not edits.
- **Measurement noise**. Single re-runs have variance. If a metric moves by <10% in either direction, treat it as noise unless multiple tasks move the same way.
- **Scope creep toward Sprint 4d content shrink**. T2/T3 should strip redundancy and decoration, not rules. If a proposed edit removes actual rule content, defer to Sprint 4d.

---

## Open Design Questions Resolved in This Spec

- **Budget control mechanism**: `MAX_THINKING_TOKENS` is the technical cap; mission frontmatter provides advisory budget guidance. `/effort` is out of scope (user-level, not mission-level).
- **Where the Karpathy constitution lives**: standalone `project/constitution/karpathy-constitution.md`. Referenced from specialists and (in Sprint 4d) from `library/CLAUDE.md`. Not duplicated into every specialist prompt.
- **Minimization scope**: all 11 specialists, not just the coordinator. Coordinator is the heaviest but the others contribute to session-start tokens too.

---

## Notes for Execution

- Start with T1 (constitution) because T2 and T3 will reference it.
- Backup `coordinator.md` to `coordinator.md.pre-4b` before T2 so a rollback is trivial.
- T3 can happen in parallel with T4 if we want to parallelise across sessions.
- T5 is the highest-leverage change for subagent reliability; worth doing carefully rather than fast.
- T6 (measurement) is mandatory — don't skip even if changes "feel" right. The whole v6.0 evolution rests on the measurement discipline.
