# Sprint 4c: The Universal Router

**Part of**: Agent-11 v6.0 Evolution (Sprint 4 umbrella)
**Predecessor**: Sprint 4b — Prompt Hygiene & Budget Controls
**Successor**: Sprint 4d — Native Primitives + CLAUDE.md Shrink
**Status**: Outline only — detailed spec produced as the final task of Sprint 4b

---

## Goal (provisional)

Collapse the current menu of explicit commands behind a single universal interface: `/coord [mission]`. Use **deterministic mission-based routing** (no NLP intent inference) so behaviour is predictable. Add dynamic context loading so sessions don't pay for context they don't need.

## Scope Outline (to be refined in detailed spec)

- Rewrite `project/commands/coord.md` with explicit mission dispatch table:
  - Mode A: `build`, `mvp`, `dev-setup`, `integrate`, `migrate`
  - Mode B1 (surgical): `fix`
  - Mode B2 (mission): `refactor`, `optimize`, `release`, `deploy`
- **Dynamic context loading heuristic**:
  - Default: load nothing or just `project-plan.md`
  - Mode A or B2: add `context.md`
  - Artefacts needed: add `evidence-repository.md` on demand
- **Mode override**: `/coord mode:maintenance [mission]` for ambiguous cases.
- **Preserve pipeline commands**: `/foundations`, `/architect`, `/bootstrap` stay as rigid multi-step processes.

## Acceptance (provisional)

- `/coord [mission]` routes correctly for every defined mission.
- Session-start tokens reduced for Mode B1 and Mode C tasks (measured against 4b).
- No breakage in greenfield flow (Mode A from ideation to shipped MVP).

## First Task of This Sprint

Produce detailed spec for this sprint.

## Final Task of This Sprint

Produce detailed spec for Sprint 4d.

## Open Questions

- Does `/foundations` fold into `/bootstrap` (blueprint hint), or stay separate?
- How do explicit mission names interact with existing pipeline commands (e.g., does `/coord build` call `/bootstrap` under the hood)?
- What's the fallback for unknown mission names — error, or interactive prompt?
