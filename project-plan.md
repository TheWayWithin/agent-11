# AGENT-11 v6.0 Evolution Plan

**Mission**: Evolve Agent-11 from a monolithic, prompt-heavy local squad into a lean, platform-native orchestrator aligned with Claude Code's current primitives.

**Reference**: `Ideation/Agent-11 v6.0 Master Blueprint_ The Lean Orchestrator (Final Revision)`
Companion: `Ideation/Dynamic MCP Tooling for Agent-11_ Context Optimization and Agent Routing.md`

**Created**: 2026-04-17
**Status**: Planning — Sprint 4a detailed, 4b–4h outlined only (rolling wave)

---

## Why This Evolution

Anthropic's platform has caught up to (and past) the custom orchestration Agent-11 hand-rolled. Hooks, subagents, Routines, Tool Search and `defer_loading` are now native primitives. Agent-11's remaining edge is not ceremony — it is:

- BOS-AI pipeline (`/foundations` → `/architect` → `/bootstrap`)
- Opinionated SaaS skills
- Karpathy-aligned behavioural discipline (PAUSE-AND-PLAN, state assumptions, minimal diffs)

Everything else should shrink, move to the platform, or get deleted.

---

## Core Strategic Shifts

1. **Deterministic Routing over Inference** — `/coord [mission]` dispatches on explicit mission name, not NLP intent.
2. **Shrink, Don't Delete** — `.claude/CLAUDE.md` drops to <80 lines (Karpathy constitution + mission index); rules move to the tools that need them.
3. **Context: 5 files → 3** — keep `project-plan.md`, `context.md`, `evidence-repository.md`; drop `progress.md` from active context, fold `handoff-notes.md` into `context.md`.
4. **Platform Primitives** — hooks replace prompt-based quality gates; Routines handle Mode C (operational) work.
5. **Dynamic MCP Tool Search** — replace static profiles with `defer_loading` + `tool_search_tool_regex` for ~80% context reduction on MCP-heavy sessions.

---

## Scope: What We're Changing (Library, Not Working Squad)

**Critical distinction**. AGENT-11 is a library that gets deployed to user projects. This repo contains both:

- **Library surface** (DEPLOYED to users via `install.sh`):
  `project/agents/specialists/`, `project/commands/`, `project/missions/`, `project/field-manual/`, `project/deployment/`, `library/CLAUDE.md`, `templates/`
- **Working squad** (INTERNAL dev tooling, NOT deployed):
  `.claude/agents/`, `.claude/commands/`, `.claude/CLAUDE.md` (in this repo)

**v6.0 evolution changes the LIBRARY**. When this plan says:

| Plan wording | Actual target |
|--------------|---------------|
| "Shrink CLAUDE.md to <80 lines" | `library/CLAUDE.md` (which becomes users' `.claude/CLAUDE.md` after install) |
| "Rewrite `/coord`" | `project/commands/coord.md` (deployed) |
| "Strip decoration from coordinator" | `project/agents/specialists/coordinator.md` (deployed) |
| "Delete MCP profile system" | Deployed scaffolding in `project/mcp/`, `project/deployment/`, `project/missions/connect-mcp.md`, plus any dead internal stubs |
| "Native primitives hooks" | `library/.claude/settings.json.template` (or equivalent) that deploys to user projects |

**We do NOT modify our own `.claude/agents/` or `.claude/commands/`** during v6.0 work — those are the working squad we use to *do* the v6.0 work. See `.claude/CLAUDE.md` in this repo for that distinction.

**The one allowed exception**: deleting dead internal dev artefacts (e.g., the abandoned `.claude/commands/mcp-*.md` stubs) when they only existed to mirror deployed behaviour we're retiring. Any such edit is called out explicitly in the relevant sprint.

---

## Three Execution Modes (Target State)

| Mode | Work | Routing | Model |
|------|------|---------|-------|
| A | Greenfield build (BOS-AI → shipped) | `/coord build`, `/coord mvp`, `/coord dev-setup`, `/coord integrate`, `/coord migrate` | Opus 4.7 direct |
| B1 | Surgical bug fix | `/coord fix` | Sonnet executor, minimal context |
| B2 | Multi-step feature / refactor | `/coord refactor`, `/coord optimize`, `/coord release`, `/coord deploy` | Sonnet + Opus advisor |
| C | Daily reports, blogs, audits, PR review | Claude Code Routines | Routine-owned |

---

## Sprint Roadmap

The v6.0 evolution is delivered as **8 sub-sprints under the "Sprint 4" umbrella**. Rolling wave: detailed spec exists only for the current sprint. The final task of each sprint is to produce the detailed spec for the next.

| Sprint | Major Feature | Primary Outcome | Status |
|--------|---------------|-----------------|--------|
| **4a** | Baseline + Great Deletion | Validation harness + baseline metrics; MCP profile system, backups, ASCII art removed | ✅ Complete |
| **4b** | Prompt Hygiene & Budget Controls | Karpathy constitution; PAUSE-AND-PLAN replaces NO-WAITING; minimization pass; budget controls | ✅ Complete |
| **4c** | The Universal Router | Rewritten `/coord` with deterministic mission routing and dynamic context loading | ✅ T1-T6, T8 complete; T7 (harness) parked |
| **4d** | Native Primitives + CLAUDE.md Shrink | `settings.json` hooks for quality; `.claude/CLAUDE.md` ≤80 lines; Meta-Dev Skill for agent-11 repo | ✅ T1-T6, T8 complete; T7 (harness) parked |
| **4e** | Context Consolidation (5→3) | `handoff-notes.md` folded; `progress.md` write-only; `agent-context.md` → `context.md` | Detailed spec ready |
| **4f** | Dynamic MCP Tool Search | `dynamic-mcp.json` + `defer_loading` + tool search protocol for specialists | Outline only |
| **4g** | Skills + Routines | SKILL.md open standard; 3 priority Routines (pr-review, nightly-qa, backlog-triage) | Outline only |
| **4h** | Validation + Migration | Harness on v6.0 vs baseline; v5.2→v6.0 migration script; private beta | Outline only |

---

## Rolling Wave Protocol

For each sprint:
1. **First task** — execute the detailed spec (produced as the last task of the previous sprint, reviewed with Jamie).
2. **Middle tasks** — execute per spec, one assessable deliverable at a time.
3. **Closing task 1** — demo + measure outcome against baseline harness.
4. **Closing task 2** — produce the detailed spec for the *next* sprint and review it with Jamie.

A sprint is not complete until the next sprint's detailed spec exists and is approved. This keeps planning effort close to the moment of execution, preserves optionality, and means the overall v6.0 plan stays coarse until concrete lessons from each sprint feed into the next.

---

## Success Metrics (from validation harness)

Measured across 5 representative tasks: bootstrap, feature build, bug fix, refactor, PR review.

- Task completion time (wall clock)
- Session-start token usage
- Unnecessary delegations (defined in harness spec)
- Human intervention rate
- Restart / recovery success rate

Target: each sprint must either improve at least one metric or be explicitly justified as a non-metric change (architectural, migration, enabler).

---

## Documentation & Release Communications

**Strategy**: public-facing docs (`README.md`, `CHANGELOG.md`, `docs/RELEASE-HISTORY.md`, deployment docs, `MCP-GUIDE.md`) are updated **once as a consolidated effort in Sprint 4h**, not per-sprint.

**Why**:
- User-facing docs should reflect the SHIPPED state of v6.0, not its in-flight evolution.
- Per-sprint doc churn creates inconsistent reading for anyone arriving at the repo mid-evolution.
- Users on `main` during the v6.0 build are on stable v5.x — they don't need mid-flight v6.0 guidance yet.
- One consolidated edit is cheaper and more coherent than seven small ones.

**Per-sprint discipline**: each sprint logs any user-facing change (new command, removed feature, migration step) into `progress.md` under a "User-Facing Changes" heading. Sprint 4h reads that running list and produces the doc update.

**Exception**: if a sprint removes or renames something users on `main` actively depend on (e.g., the MCP profile commands in Sprint 4a), add a brief deprecation notice to the README in that sprint. Keep deprecation notices under 5 lines and point to the migration guide.

---

## Dependencies & Ordering Rationale

- **4a first** so every later sprint proves its impact against a real baseline.
- **4b before 4c** — cleaner prompts make the router rewrite easier and smaller.
- **4c before 4d** — native primitives (hooks, settings) hook into the new router surface.
- **4d before 4e** — CLAUDE.md shrink and context consolidation both touch the same specialists; do structural change first, then content move.
- **4f is independent but deliberately after 4e** — MCP work could run in parallel, but Jamie's preference is sequential. Could slot earlier if a future session flags context bloat as blocker.
- **4g after 4f** — Routines and Skills both reference the new tool-loading model and the shrunken CLAUDE.md.
- **4h last** — validation requires the full v6.0 surface area to compare fairly against the baseline.

---

## Out of Scope for This Plan

- Anthropic web UI integrations beyond Routines config output.
- Public marketplace launch for Tier 3 SaaS skills — format for the standard, don't publish yet.
- Breaking changes to the BOS-AI foundations interface — `/foundations`, `/architect`, `/bootstrap` stay.
- Security hardening work (tracked separately in archived `security-sprint-1/2`, plus active `sprint-3`).

---

## Working Files

- This plan: `/project-plan.md`
- Detailed current sprint: `/sprints/sprint-4a-baseline-and-great-deletion.md`
- Outline-only future sprints: `/sprints/sprint-4{b..h}-*.md`
- Archived pre-v6 plan and sprints: `.archive/2026-04-17-pre-v6/`
- Running log: `/progress.md`

---

## Open Questions (to resolve at or before relevant sprint)

- **4b**: Is `/effort` the right budget control mechanism, or `MAX_THINKING_TOKENS`, or both?
- **4c**: Should `/foundations` fold into `/bootstrap` as the blueprint hints, or stay separate?
- **4d**: Which quality checks are safe to move from prompt-based to `PostToolUse` hooks given the user's stack variety?
- **4e**: Is `progress.md` dropped entirely, or retained as an append-only generated artefact?
- **4f**: Which MCP tools are pre-loaded "discovery" tools vs deferred "execution" tools? Start from the Dynamic MCP doc's table.
- **4g**: Do Routines run in-repo (committed configs) or user-owned (web UI paste)? Blueprint says paste; confirm.
