# Sprint 4a: Baseline + The Great Deletion

**Part of**: Agent-11 v6.0 Evolution (Sprint 4 umbrella)
**Predecessor**: none — first sprint of v6.0 evolution
**Successor**: Sprint 4b — Prompt Hygiene & Budget Controls
**Status**: Ready to start

---

## Goal

Establish measurement baseline and remove dead weight before any behavioural changes. Low-risk cleanup that creates space and lets every later sprint prove its impact.

## Why This Sprint First

You cannot assess whether prompt hygiene, router rewrite, or MCP changes are improvements without a baseline. And you cannot evaluate context bloat honestly while the repo still carries MCP profile switching, `.backup` files, and ASCII decoration.

---

## Scope Reminder

All edits target the **library surface** (`project/`, `library/CLAUDE.md`, `templates/`) — what gets deployed to users — unless explicitly noted. Do **not** modify `.claude/agents/` or `.claude/commands/` in this repo during v6.0 work; those are the working squad we use to *do* the work. See `project-plan.md` → "Scope: What We're Changing" for the full distinction.

The one allowed exception in this sprint: T3 deletes dead internal dev artefacts (`.claude/commands/mcp-*.md`) that only exist to mirror deployed behaviour we're retiring. Called out explicitly in T3.

---

## Tasks

### T1. Validation Harness Spec

**Deliverable**: `project/validation/harness-spec.md`

Define 5 representative tasks that run against every v6.0 milestone:
1. Greenfield bootstrap (simple SaaS from a short ideation doc)
2. Feature addition on an existing codebase
3. Bug fix (single-file scope)
4. Refactor (2-3 file scope)
5. PR review (read-only)

For each task, document:
- Starting state (repo snapshot, prompt given)
- Success criteria
- Metrics captured: task completion time, session-start tokens, delegations count, human intervention count, restart / recovery success

**Acceptance**: Spec reviewed by Jamie; 5 tasks defined; metrics capture method documented and reproducible.

---

### T2. Baseline Run on v5.2

**Deliverable**: `project/validation/baseline-v5.2.md`

Run all 5 harness tasks on current v5.2 (`main` branch). Capture metrics per task.

**Acceptance**: Baseline numbers recorded; baseline file committed; used as comparison for every later sprint.

---

### T3. Delete MCP Profile System (Dead Artefacts)

Two targets, both cleanup:

**(a) Library surface — deployed but obsolete** (DELETE):
- `.mcp-profiles/` directory (root) — leftover dev artefacts
- Root-level `mcp-setup.sh` — leftover duplicate
- Library scripts that implement profile switching in `project/deployment/scripts/` **stay until Sprint 4f** (still used by install.sh until we wire in dynamic MCP)

**(b) Working squad — dead internal stubs** (DELETE — allowed exception to the scope rule):
- `.claude/commands/mcp-switch.md`
- `.claude/commands/mcp-status.md`
- `.claude/commands/mcp-list.md`

These three internal commands exist only to mirror deployed behaviour we're retiring. Deleting them is aligned cleanup, not feature work on the working squad.

**Keep for Sprint 4f**:
- `project/mcp/dynamic-mcp.json`
- `project/schemas/dynamic-mcp.schema.yaml`
- `.mcp.json` (rewritten to dynamic format in 4f)
- `project/deployment/scripts/mcp-*.sh` (deployed; rewritten in 4f)

**User-facing change to log**: Add a "User-Facing Changes" entry to `progress.md` noting that `mcp-switch` / `mcp-status` / `mcp-list` commands are gone from dev, and the deployed replacement ships in 4f. Add a brief deprecation notice to README.

**Acceptance**: `grep -r "mcp-switch\|mcp-status\|mcp-list" .` returns no references except intentional deprecation notices. Repo still functions for daily work. Deployed MCP still works end-to-end until 4f replaces it.

---

### T4. Delete `.backup` Files in Specialists

**Target**: 11 `*.backup` files in `project/agents/specialists/`.

**Acceptance**: No `.backup` files remain; git history preserves originals if rollback ever needed.

---

### T5. Strip ASCII Box Art & Decorative Emoji from Coordinator Prompt

**Target**: `project/agents/specialists/coordinator.md` (currently 3,558 lines; heavily decorated).

**Strip**:
- ASCII box frames (`╔╗╚╝║═` etc.)
- Decorative emojis used as section headers (keep semantic `⚠️` in actual error/warning sections)
- Redundant warning blocks that repeat the same rule

**Do NOT strip yet**:
- The actual rules (Sprint 4d does the content shrink)
- Load-bearing examples and templates

**Acceptance**: `coordinator.md` is measurably smaller (target: <2,500 lines) and visually calmer; a smoke test of `/coord fix` still behaves the same.

---

### T6. Archive Historic Context Files, Start Fresh

**Move to archive** (`.archive/2026-04-17-pre-v6/`):
- `progress.md` → `progress-historic.md`
- `agent-context.md` → `agent-context-historic.md`
- `handoff-notes.md` → `handoff-notes-historic.md`

**Create fresh**:
- New empty `progress.md` scoped to v6.0 evolution
- New empty `agent-context.md` with mission header
- New empty `handoff-notes.md` (still in use until Sprint 4e)

**Acceptance**: Fresh files exist at repo root; historic versions accessible from archive.

---

### T7. Spec Sprint 4b

**Deliverable**: Replace outline at `sprints/sprint-4b-prompt-hygiene-and-budget-controls.md` with detailed spec.

Cover:
- Karpathy constitution (7 principles) — exact wording, where it lives, how it's referenced
- PAUSE-AND-PLAN replacement pattern — specific edits to coordinator.md
- 3-phase prompt minimization procedure (what gets cut, what gets kept, evidence threshold)
- Budget controls mechanism choice — resolve the `/effort` vs `MAX_THINKING_TOKENS` question
- Acceptance: re-run a subset of harness tasks on the minimized prompts and show at least one metric improved

**Acceptance**: Sprint 4b spec exists, Jamie has reviewed it, scope confirmed.

---

## Definition of Done

- [ ] T1: Validation harness spec published and reviewed
- [ ] T2: Baseline metrics captured for all 5 tasks on v5.2
- [ ] T3: MCP profile system deleted; no stale references
- [ ] T4: `.backup` files removed from `project/agents/specialists/`
- [ ] T5: `coordinator.md` de-decorated (<2,500 lines)
- [ ] T6: Historic context files archived; fresh ones in place
- [ ] T7: Sprint 4b detailed spec written and approved
- [ ] Demo + measurement recorded in `progress.md`

---

## Risks & Watch-Items

- **Deletion breaks live user projects**: MCP profile scripts may be in active use on Jamie's other projects. Verify before deletion; consider a deprecation warning commit first.
- **Baseline reproducibility**: if harness tasks can't be re-run cleanly, the whole v6.0 evaluation is shaky. Invest in T1/T2 quality — don't rush them.
- **Coordinator prompt churn**: 4a only strips decoration; Sprint 4d does the actual rule shrink. Do not accidentally delete load-bearing content.
- **Scope creep**: resist pulling in 4b items (like PAUSE-AND-PLAN replacement) just because `coordinator.md` is open. T5 is decoration only.

---

## Notes for Execution

- This sprint is mostly cleanup + measurement, not design. Suitable for a single focused session.
- T1 and T2 are the critical path — if they're weak, nothing later can be measured.
- T3 should wait until Jamie confirms no live dependency on the MCP profile commands in his other projects.
