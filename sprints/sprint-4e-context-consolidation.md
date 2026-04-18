# Sprint 4e: Context Consolidation (5→3)

**Part of**: Agent-11 v6.0 Evolution (Sprint 4 umbrella)
**Predecessor**: Sprint 4d — Native Primitives + CLAUDE.md Shrink
**Successor**: Sprint 4f — Dynamic MCP Tool Search
**Status**: Outline only — detailed spec produced as the final task of Sprint 4d

---

## Goal (provisional)

Reduce context overhead by consolidating the current 5 tracking files into 3, without losing the audit trail or pause/resume capability that made them useful.

## Scope Outline (to be refined in detailed spec)

**Keep**:
- `project-plan.md` — single source of truth for tasks and status
- `context.md` — architectural memory, decisions, findings (renamed from `agent-context.md`)
- `evidence-repository.md` — large artefacts, loaded on demand

**Remove from active context**:
- `progress.md` — becomes a generated artefact or moves to an `evidence/` folder. Not auto-loaded.
- `handoff-notes.md` — merged as a **structured block appended to `context.md`** at the end of each phase. The handoff discipline survives; the file doesn't.

## Scope of Changes

- Update every specialist prompt that currently references `handoff-notes.md` or `progress.md`.
- Update coordinator's delegation protocol to stop enforcing handoff-notes as a separate file.
- Update templates in `/templates/` to match the 3-file model.
- Write a migration note in the deployed `library/CLAUDE.md` for existing user projects.

## Acceptance (provisional)

- No active-path reference to `handoff-notes.md` or `progress.md` remains in coordinator, specialists, or missions.
- `context.md` includes a structured "Phase Handoff" section appended at phase boundaries.
- Baseline harness shows reduced session-start tokens (fewer files loaded).
- Pause/resume across sessions still works correctly — tested on at least one harness task.

## First Task of This Sprint

Produce detailed spec for this sprint.

## Final Task of This Sprint

Produce detailed spec for Sprint 4f.

## Open Questions

- Is `progress.md` dropped entirely or retained as an append-only generated artefact in an `evidence/` folder?
- What is the exact schema for the "Phase Handoff" block appended to `context.md`?
- How do existing user projects migrate — is there a `/migrate-context` helper, or is it a manual `library/CLAUDE.md` note?
