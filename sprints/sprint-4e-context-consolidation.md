# Sprint 4e: Context Consolidation (5→3)

**Part of**: Agent-11 v6.0 Evolution (Sprint 4 umbrella)
**Predecessor**: Sprint 4d — Native Primitives + CLAUDE.md Shrink ✅ (T1-T6, T8 shipped; T7 deferred)
**Successor**: Sprint 4f — Dynamic MCP Tool Search
**Status**: Detailed spec ready for Jamie's review; execution can start once Sprint 4d is committed

---

## Goal

Cut the active-context tracking surface from **5 files to 3** without losing the audit trail or the pause/resume capability that made the originals useful.

**Target shape**:
- `project-plan.md` — single source of truth for tasks and status (kept)
- `context.md` — architectural memory, decisions, findings (renamed from `agent-context.md`; absorbs the `handoff-notes.md` discipline as a structured Phase Handoff block)
- `evidence-repository.md` — large artefacts, loaded on demand (kept; on-demand only since Sprint 4c)

**Files dropped from active context**:
- `handoff-notes.md` — folded into `context.md` as a structured block at phase boundaries.
- `progress.md` — retained as an append-only generated artefact (writeable, not read by default).

## Why This Sprint

Three observations:

1. **Sprint 4c made context loading mode-aware**, but the tracking-file *count* still bloats fresh-start sessions. Mode A loads 4 files at start; Mode B2 loads 2-3. Cutting to 3 active files removes 100-300 redundant lines from every session-start in greenfield work.
2. **`handoff-notes.md` and `agent-context.md` substantially overlap.** Specialists write their findings to handoff-notes; coordinator merges into agent-context. The same content lives in two places during the merge window. A structured Phase Handoff block in `context.md` removes the redundancy.
3. **`progress.md` is a write-only file most of the time.** It's a backward-looking changelog. Reading it at session start is rarely useful (Sprint 4c already scoped its read to staleness checks on resumed missions only). Promoting it to "write-only by default" closes the loop.

## Scope Reminder

Library surface only: `project/agents/specialists/`, `project/commands/`, `project/missions/`, `project/field-manual/`, `templates/`, `library/CLAUDE.md`. Working squad (`.claude/agents/`, `.claude/commands/`) untouched.

---

## Tasks

### T1. Define the Phase Handoff schema

**Deliverable**: a clear schema for the "Phase Handoff" block appended to `context.md` at phase boundaries.

**Proposed schema** (refine during execution):

```markdown
## Phase Handoff — [Phase Name]

**Closed**: [YYYY-MM-DD HH:MM]
**By**: @[specialist or coordinator]

### Findings
- [What was discovered, what worked, what didn't]

### Decisions
- [Decision: rationale]

### Warnings & Gotchas
- [Things the next phase needs to know]

### Open Items
- [What remains unresolved; carries to next phase]

### Evidence
- [Pointers to evidence-repository.md entries, if any]
```

**Acceptance**: Schema published in `templates/context-template.md` and referenced from coordinator.md. Jamie has reviewed the schema.

---

### T2. Rename `agent-context.md` → `context.md`

**Deliverable**: every reference to `agent-context.md` updated to `context.md`. New file naming used in templates, missions, specialists, coordinator, and `library/CLAUDE.md`.

**Files to touch** (initial scan — refine during execution):
- `project/agents/specialists/coordinator.md`
- `project/agents/specialists/*.md` (all specialists with context-reading instructions)
- `project/missions/*.md`
- `project/commands/coord.md` and other commands
- `templates/agent-context-template.md` → `templates/context-template.md`
- `library/CLAUDE.md` (Sprint 4d's lean version already references `agent-context.md` — update to `context.md`)
- `progress.md` references in coordinator
- `field-manual/coordinator-protocol.md`

**Search-and-replace strategy**: targeted, not blind. Some references in archived sprint docs and historical progress entries are correct as-is — do not rewrite history.

**Migration for existing users**: `library/CLAUDE.md` carries a one-paragraph note: *"v6.0 renames `agent-context.md` to `context.md`. To migrate: `mv agent-context.md context.md`. New deployments use `context.md` from install."*

**Acceptance**: `grep -r "agent-context.md" project/ library/ templates/` returns zero results. A fresh install creates `context.md`, not `agent-context.md`.

---

### T3. Fold `handoff-notes.md` into `context.md`

**Deliverable**: `handoff-notes.md` retired as a separate active-context file. Phase Handoff blocks (per T1 schema) appended to `context.md` at phase boundaries.

**Coordinator changes**:
- `CONTEXT PRESERVATION PROTOCOL` section in coordinator.md updated: specialists update `context.md`'s most recent Phase Handoff block instead of writing a separate `handoff-notes.md`.
- `PHASE GATE ENFORCEMENT` section: replace "handoff-notes.md updated" check with "Phase Handoff block appended to context.md".

**Specialist prompt changes**:
- All `project/agents/specialists/*.md` files that say "First read agent-context.md and handoff-notes.md" become "First read context.md".
- All "Update handoff-notes.md with findings" becomes "Append a Phase Handoff block to context.md with findings".

**Template changes**:
- `templates/handoff-notes-template.md` → deleted (archived to `.archive/2026-04-26-pre-4e/`).
- `templates/context-template.md` → contains the Phase Handoff block schema as a recurring section example.

**Acceptance**: `grep -r "handoff-notes.md" project/ library/ templates/` returns zero results in active library files. Specialists can still complete a multi-phase mission with handoff continuity preserved through the Phase Handoff block.

---

### T4. Demote `progress.md` to write-only

**Deliverable**: `progress.md` is no longer read at session start. It remains an append-only changelog written when issues occur or deliverables ship.

**Coordinator changes**:
- Remove `progress.md` from the staleness check list in `SESSION RESUMPTION PROTOCOL` (Sprint 4c already scoped this — finalise removal here).
- The DYNAMIC CONTEXT LOADING table (Sprint 4c) already lists `progress.md` as on-demand. No change needed there.
- "Update progress.md" instructions stay as-is — it's still written, just not read.

**Why retain at all rather than delete?** Per the v6.0 plan's "Open Questions" — the changelog history is genuinely useful for debugging and post-mortems. Dropping it loses the audit trail. Keeping it write-only preserves the value while removing the read overhead.

**Open question**: should `progress.md` move to `evidence/progress.md` to make its on-demand-only nature visible by location? Recommendation: **leave at root**. Moving it requires migration tooling and breaks existing user mental models for negligible benefit. Document the demotion in `library/CLAUDE.md` instead.

**Acceptance**: No specialist or coordinator reads `progress.md` at session start. `library/CLAUDE.md` notes that `progress.md` is a write-only changelog.

---

### T5. Update `library/CLAUDE.md` for the 3-file model

**Deliverable**: Sprint 4d's lean `library/CLAUDE.md` updated to reflect the new tracking-file count. Brief migration note for users on existing v5.x installs.

**Diff**:
- Tracking files section: list 3 files (`project-plan.md`, `context.md`, `evidence-repository.md`) instead of 4.
- One-line migration note: *"v6.0 renames `agent-context.md` to `context.md` and absorbs `handoff-notes.md` discipline into context.md's Phase Handoff blocks. Migration: `mv agent-context.md context.md && mv handoff-notes.md .archive/`."*

**Acceptance**: Lean CLAUDE.md still under 80 lines after the edit. Migration note is one paragraph, not a section.

---

### T6. Update mission files for the 3-file model

**Deliverable**: every `project/missions/mission-*.md` and `dev-setup.md`/`dev-alignment.md` updated to reference the new file model.

**Common edits**:
- "Initialize agent-context.md and handoff-notes.md" → "Initialize context.md".
- Phase-end protocols that say "update handoff-notes.md" → "append Phase Handoff block to context.md".

**Acceptance**: `grep -rn "agent-context\.md\|handoff-notes\.md" project/missions/` returns zero results.

---

### T7. Re-run harness and measure

**Subset**: Tasks 1 (bootstrap), 2 (feature build), 3 (bug fix). Bootstrap creates the new file shape from scratch; feature build exercises multi-phase Phase Handoff; bug fix confirms B1 mode is unchanged.

**Deliverable**: `project/validation/milestone-4e.md` with results compared to milestone-4d baseline.

**Success criteria**:
- M2 (session-start tokens) drops on Mode A and Mode B2 tasks (fewer files loaded).
- M2 on Mode B1 unchanged (was already minimal in 4c).
- M3 (unnecessary delegations) does not increase — context fidelity preserved through Phase Handoff blocks.
- No regression in pause/resume: a harness task interrupted mid-phase resumes correctly from `context.md` alone.

---

### T8. Write Sprint 4f detailed spec

**Deliverable**: replace the outline at `sprints/sprint-4f-dynamic-mcp-tool-search.md` with a detailed spec.

The spec should cover:
- `library/dynamic-mcp.json` template with `defer_loading: true` and the tool-search regex protocol.
- Which MCP tools are pre-loaded "discovery" tools vs deferred "execution" tools (start from the Dynamic MCP doc's table).
- Specialist prompt updates: replace static MCP profile knowledge with tool-search instructions.
- Migration: existing user projects on the static `.mcp.json` switch to dynamic loading.
- Harness measurement: baseline shows ~50K MCP token cost; target is <5K via deferred loading.

**Acceptance**: Sprint 4f detailed spec written; Jamie has reviewed and approved scope.

---

## Definition of Done

- [ ] T1: Phase Handoff schema published in context-template.md
- [ ] T2: All references to `agent-context.md` updated to `context.md`; templates renamed
- [ ] T3: `handoff-notes.md` retired; Phase Handoff blocks in use; specialist prompts updated
- [ ] T4: `progress.md` demoted to write-only; no session-start reads
- [ ] T5: `library/CLAUDE.md` reflects 3-file model; migration note added
- [ ] T6: All mission files updated for the 3-file model
- [ ] T7: Harness subset re-run; milestone-4e.md committed; M2 drops on Mode A/B2
- [ ] T8: Sprint 4f detailed spec written and approved

---

## Risks & Watch-Items

- **Specialist prompts breaking from search-and-replace.** Many specialists have nuanced context-reading instructions. A blind replace could miss or break edge cases. Mitigation: T3 uses targeted edits, not global replace; review each specialist's diff individually.
- **User migration friction.** Users on v5.x installs have `agent-context.md` and `handoff-notes.md` — a v6.0 upgrade silently looks broken if they don't migrate. Mitigation: prominent migration note in `library/CLAUDE.md`, plus optional `/coord migrate-v5-context` helper if user feedback warrants.
- **Phase Handoff block fidelity.** A free-form structured block could lose the discipline of dedicated handoff-notes if specialists treat it as optional. Mitigation: schema is enforced at phase gate; coordinator rejects phase completion without a Phase Handoff block.
- **Reading stale Phase Handoff blocks.** A new specialist might read all historical Phase Handoff blocks and waste context. Mitigation: T1 schema includes a "Closed" timestamp; specialists read only the most recent block by default.

---

## Open Design Questions

- **`progress.md` location?** Recommendation: leave at root, document the write-only nature in CLAUDE.md. Decision in T4.
- **Migration tooling?** Recommendation: manual `mv` instructions in CLAUDE.md migration note; build `/coord migrate-v5-context` helper only if friction emerges. Decision in T2/T5.
- **Phase Handoff schema fields?** Recommendation: 5 fields (Findings, Decisions, Warnings, Open Items, Evidence) per T1 proposal. Refine during execution if a sixth proves common.

---

## Notes for Execution

- T1 (schema design) gates everything else — get it right before any rename or fold.
- T2 (rename) and T3 (fold) can run in parallel once T1 is approved, but commit them sequentially for cleaner diffs.
- T6 is mostly mechanical search-and-replace once T2/T3 are done.
- T7 is mandatory; without measurement we can't claim the consolidation actually reduced session-start tokens.
- Sprint 4e is the cleanup sprint that lets Sprint 4f's MCP work compose against a stable, lean context surface. Don't compress timelines — fidelity matters.
