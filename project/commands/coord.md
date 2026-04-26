---
name: coord
description: Universal mission router — dispatches to THE COORDINATOR with deterministic mission-based routing
---

# /coord — Universal Mission Router

**Arguments Provided**: $ARGUMENTS

Dispatch a mission via THE COORDINATOR. Parse the arguments, validate the mission name, hand off to the coordinator with the right mode. The coordinator (`project/agents/specialists/coordinator.md`) owns the orchestration logic — do not duplicate it here.

## Routing Table

| Mission         | Mode | Context at start                                  | Notes |
|-----------------|------|---------------------------------------------------|-------|
| `build`         | A    | project-plan.md, agent-context.md, mission file   | Greenfield feature build |
| `mvp`           | A    | project-plan.md, agent-context.md, mission file   | Rapid MVP from concept |
| `dev-setup`     | A    | ideation input only                               | Greenfield bootstrap; creates tracking files |
| `dev-alignment` | A    | existing codebase, agent-context.md if present    | Brownfield onboarding |
| `integrate`     | A    | project-plan.md, agent-context.md, mission file   | Third-party integration |
| `migrate`       | A    | project-plan.md, agent-context.md, mission file   | Data/schema migration |
| `fix`           | B1   | bug report input only                             | Surgical fix; no tracking unless escalates |
| `refactor`      | B2   | project-plan.md if exists, mission file           | Multi-step refactor |
| `optimize`      | B2   | project-plan.md if exists, mission file           | Performance work |
| `document`      | B2   | project-plan.md if exists, mission file           | Documentation pass |
| `release`       | B2   | project-plan.md, agent-context.md, mission file   | Higher stakes |
| `deploy`        | B2   | project-plan.md, agent-context.md, mission file   | Higher stakes |
| `security`      | B2   | project-plan.md, agent-context.md, mission file   | Audit + fixes |

**Modes**: A = greenfield (long-horizon, full tracking). B1 = surgical (minimal context). B2 = maintenance (moderate context). `evidence-repository.md` loads on demand only — never at start.

### Control Commands

- `continue` — Coordinator resumes from project-plan.md until blocked.
- `complete phase N` — Mark phase N complete; generate phase-(N+1) context.
- `vision-check` — Verify current work against vision in project-plan.md.

### Standalone (NOT routed via /coord)

`/foundations`, `/architect`, `/bootstrap` — pipeline commands; run independently.

## Mode Override

Prefix with `mode:` when default routing is wrong:

```
/coord mode:maintenance security audit-2026-q2
```

Valid prefixes: `mode:greenfield` (A), `mode:surgical` (B1), `mode:maintenance` (B2). The override applies that mode's loading rules regardless of mission name.

## Dispatch Behaviour

1. Parse first argument. If it starts with `mode:`, consume it; the next arg is the mission name.
2. Validate mission name against the routing table or control-command list.
3. If unknown, print the unknown-mission error (below) and stop. No NLP inference.
4. Load mission file if applicable: `project/missions/mission-[name].md` (or `[name].md` for `dev-setup`/`dev-alignment`).
5. Hand off to THE COORDINATOR with mission name, mode, and input paths. The coordinator's DYNAMIC CONTEXT LOADING protocol applies the per-mode rules.

## Unknown Mission Behaviour

If the mission name does not match, print exactly:

```
Unknown mission: <name>

Valid missions:
  Greenfield (Mode A):    build, mvp, dev-setup, dev-alignment, integrate, migrate
  Surgical (Mode B1):     fix
  Maintenance (Mode B2):  refactor, optimize, document, release, deploy, security

Control:                  continue, complete phase N, vision-check
Override:                 /coord mode:maintenance <anything>
Standalone (not /coord):  /foundations, /architect, /bootstrap
```

…and stop.

## Interactive Mode

If `/coord` is invoked with no arguments, present the routing table and ask which mission to run. Require an explicit mission name in the next response — do not infer from free text.

## Examples

```
/coord build prd.md
/coord fix bug-report.md
/coord mvp vision.md
/coord mode:maintenance security
/coord continue
```
