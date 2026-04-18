# Sprint 4d: Native Primitives + CLAUDE.md Shrink

**Part of**: Agent-11 v6.0 Evolution (Sprint 4 umbrella)
**Predecessor**: Sprint 4c — The Universal Router
**Successor**: Sprint 4e — Context Consolidation (5→3)
**Status**: Outline only — detailed spec produced as the final task of Sprint 4c

---

## Goal (provisional)

Stop reinventing what Claude Code now provides natively. Move quality gates from prompt instructions to deterministic `PostToolUse` hooks. Shrink `.claude/CLAUDE.md` from 214 lines (and `library/CLAUDE.md` from 575) down to a lean Karpathy-constitution + mission index. Migrate operational rules into the specific command files that need them.

## Scope Outline (to be refined in detailed spec)

- **Hooks in `.claude/settings.json`**:
  - `PostToolUse` for Edit/Write → run linters, type checks, test hooks
  - `PreToolUse` for dangerous operations → confirm intent
  - Replace prompt-based "remember to lint" instructions
- **CLAUDE.md shrink**:
  - `/CLAUDE.md` (root) — Jamie's personal preferences only (already small)
  - `.claude/CLAUDE.md` — Karpathy constitution + mission index + skill loading rules → <80 lines
  - `library/CLAUDE.md` (deployed to users) — same 80-line shape
- **Decentralize rules** — the ~500 lines removed from CLAUDE.md move into the specific commands/agents that need them (e.g., foundations rules → `commands/foundations.md`).
- **Meta-Development Skill** — convert `.claude/claude.md` project-guardrail content into a Skill so the agent-11 repo looks different from a product repo.

## Acceptance (provisional)

- `.claude/CLAUDE.md` is <80 lines.
- `library/CLAUDE.md` (deployed) is <80 lines.
- At least two quality checks run via hook rather than prompt.
- Meta-Development Skill loads when working on the agent-11 repo.
- Baseline harness shows reduced session-start tokens and reduced unnecessary delegations.

## First Task of This Sprint

Produce detailed spec for this sprint.

## Final Task of This Sprint

Produce detailed spec for Sprint 4e.

## Open Questions

- Which quality checks are safe to make deterministic hooks given the user stack variety (Node/Python/Ruby)?
- Does the hook config ship in `library/` for deployment to user projects, or stay agent-11-internal?
- What exactly goes in the 80 lines? Draft the final content before deleting the rest.
