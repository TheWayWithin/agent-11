---
name: meta-dev
version: 1.0.0
category: framework-development
description: AGENT-11 framework development. Use when modifying agents, commands, missions, skills, or library files inside the agent-11 repository itself. Distinguishes the LIBRARY surface (project/agents/specialists/, project/commands/, library/) — which is deployed to users — from the WORKING SQUAD (.claude/agents/, .claude/commands/) — which is internal-only dev tooling. Triggered by the AGENT_11_PROJECT env var set in .claude/settings.local.json.
triggers:
  - agent-11
  - agent11
  - library/CLAUDE.md
  - working squad
  - library agent
  - install.sh
  - project/agents/specialists
  - project/commands
  - sprint 4
specialist: "@developer"
stack_aware: false
complexity: beginner
estimated_tokens: 1200
dependencies: []
---

# AGENT-11 Meta-Development

## What this skill is for

You are working inside the AGENT-11 framework repository, not a user product. Edits here ship to other people via `install.sh`. The same filename can mean two different things depending on directory.

This skill orients you correctly without relying on memory or repeated reminders.

## Two parallel agent sets in this repo

| Path | Role | Modify when |
|------|------|-------------|
| `project/agents/specialists/` | **Library agents** — deployed to users via `install.sh` | You are improving agent capabilities for end users (≥99% of work) |
| `.claude/agents/` | **Working squad** — internal dev tooling | You are improving how we build AGENT-11 itself (rare) |

Same distinction for commands:

| Path | Role | Modify when |
|------|------|-------------|
| `project/commands/` | **Library commands** — deployed | Improving end-user `/coord`, `/foundations`, etc. |
| `.claude/commands/` | **Working squad commands** — internal | Improving internal dev workflows |

## Default work target

When in doubt: `project/agents/specialists/` and `project/commands/`. Most work improves what users get on `install.sh`, not our internal tooling.

## CLAUDE.md hierarchy in this repo

| File | Purpose | Deployed? |
|------|---------|-----------|
| `/CLAUDE.md` | Jamie's personal preferences | NO |
| `library/CLAUDE.md` | AGENT-11 library instructions → user's `.claude/CLAUDE.md` post-install | YES |
| `.claude/CLAUDE.md` | Working-squad project guardrails | NO |

Edits to library content target `library/CLAUDE.md`. Personal preferences belong in root. Internal dev guardrails belong in `.claude/CLAUDE.md`.

## Verification before significant edits

Before editing an agent or command file, ask:
1. Am I improving the AGENT-11 library for end users? → `project/agents/specialists/` or `project/commands/`
2. Am I improving the AGENT-11 development process? → `.claude/agents/` or `.claude/commands/`
3. Quick check: `grep -n "$(basename your-file)" project/deployment/scripts/install.sh` — if found, it's deployed (library); if not, it's internal.

## Sprint 4 v6.0 evolution scope rule

During v6.0 sprints (4a–4h), edits target the **library surface only**:
- `project/agents/specialists/`
- `project/commands/`
- `project/missions/`
- `project/field-manual/`
- `project/skills/`
- `project/deployment/`
- `library/CLAUDE.md`
- `library/settings.json.template`
- `templates/`

The working squad (`.claude/agents/`, `.claude/commands/`) is NOT modified during v6.0 — it is the squad we use to *do* the v6.0 work. The one explicit exception per the v6.0 plan: `.claude/skills/meta-dev/` (this file).

## Anti-patterns to catch

- Editing `.claude/agents/coordinator.md` thinking you're improving the deployed coordinator → wrong file. Library coordinator is `project/agents/specialists/coordinator.md`.
- Editing `.claude/CLAUDE.md` thinking you're updating user-facing instructions → wrong file. User-facing is `library/CLAUDE.md`.
- Adding install steps without updating `install.sh`'s SHA256 (`install.sh.sha256`) → CI guard will fail.
- Modifying agents without updating their schema validation if they have one → pre-commit hook will block.

## Reference

`.claude/CLAUDE.md` carries the full distinction in detail. This skill is a routing aid — use it to default-orient, then read the working-squad file when you need the longer explanation.
