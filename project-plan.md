# AGENT-11 v6.0 Evolution Plan

**Mission**: Evolve Agent-11 from a monolithic, prompt-heavy local squad into a lean, platform-native orchestrator aligned with Claude Code's current primitives.

**Reference**: `Ideation/Agent-11 v6.0 Master Blueprint_ The Lean Orchestrator (Final Revision)`
Companion: `Ideation/Dynamic MCP Tooling for Agent-11_ Context Optimization and Agent Routing.md`

**Created**: 2026-04-17
**Status**: v6.0 SHIPPED. v6.1.1 SHIPPED 2026-05-07 (Sprint 5a — Hardened Upgrade Path). Sprint 5b CLOSED 2026-05-09 — 17/19 user repos bulk-migrated to v6.1.1 and pushed to github (2 local-only by user choice; 3 deferred).

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
| **4e** | Context Consolidation (5→3) | `handoff-notes.md` folded; `progress.md` write-only (rename of `agent-context.md` skipped) | ✅ T1, T3-T6, T8 complete; T7 (harness) parked |
| **4f** | Dynamic MCP Tool Search | `ENABLE_TOOL_SEARCH=auto` enables native deferring; Tool-Centric Workflow in 7 specialists; profile-switching residue retired (recalibrated mid-sprint after schema audit) | ✅ T1, T2, T3, T5, T6, T8 complete; T4 removed; T7 (harness) parked |
| **4g** | Skills + Routines | 3-tier skills model formalised; open-standard `description` added to all 7 SaaS skills; 3 Routine prompt templates; `/coord` detects operational intent | ✅ T1-T8, T10 complete; T9 (harness) parked |
| **4h** | Validation + Migration | Harness batch (5 milestones); v5.2→v6.0 migration script; consolidated docs; private beta; retrospective | Detailed spec ready |

### Post-v6.0 sprints (added after v6.0 shipped)

| Sprint | Major Feature | Primary Outcome | Status |
|--------|---------------|-----------------|--------|
| **5a** | Hardened Upgrade Path (v6.1.0) | Single-command `install.sh --upgrade`; settings.json surgical merge; `restore-pre-upgrade.sh`; 5 canonical fixtures (43/43); `docs/UPGRADE.md` | ✅ Complete (2026-05-07, tag `v6.1.0-hardened-upgrade-path`) |
| **5a.1** | Subprocess advisory cleanup (v6.1.1) | Suppress stale "Manual merge recommended" warning when migrate.sh runs under install.sh; reword standalone path | ✅ Complete (2026-05-07, tag `v6.1.1`) |
| **5b** | Bulk migration of priority repos | Dry-run sweep + real run + per-repo verification across 19 user repos (17 priority + ASMGE + SoloCMD); commit + push migration to github | ✅ Complete (2026-05-09) — 17/19 pushed to github, 2/19 local-only (no remote configured: Socrates, SoloCMD), 3 deferred (mcp-7, mcp-11, test-project) |

### Sprint 6 — Loop Discipline & Read-Only Verification (umbrella → v6.2.0)

Adopts the converged principle from the loops/autoresearch research (`knowledge/Claude agentic loops.md`, `knowledge/Karpathy autoresearch.md`): **the thing that judges the work must be read-only to the thing doing it.** Library surface only. Sequenced behind V&M priorities — bounded, deliberate, watched.

| Sprint | Major Feature | Primary Outcome | Status |
|--------|---------------|-----------------|--------|
| **6a** | Read-only gates + evidence-gated verification | Gate files (`.quality-gates.json`, `gates/**`) made unwritable by every agent via `permissions.deny` in `library/settings.json.template`; default-fail verification contract in tester/developer/coordinator (criteria start `false`, flip only on attached tool-output evidence); coordinator refuses gate-edit delegation | ✅ Implemented + live-demoed (2026-06-16). 7 files verified on disk; refusal proven in test project (agent blocked from editing `.quality-gates.json` by `permissions.deny`). Remaining: 6b detailed spec (T6) to formally close per rolling-wave |
| **6b** | Ratchet loops | `mission-optimize` rewritten as the Karpathy ratchet (worktree → noise-floor baseline → keep-or-revert → log → caps); scored `code-review-loop` skill (read-only critic + read-write fixer, capped, evidence-gated, diff <1000 lines); loop-discipline guide + input template; install.sh registration + SHA update | ✅ COMPLETE (2026-06-20). T1–T6 done. T5 watched run executed on aimpactmonitor: loop proven end-to-end, two findings folded back into mission-optimize (metric-must-match-intent; worktree breaks on JS/Turbopack). No clean token-per-loop number from the manual run — 6c seeds its error budget from a harness-run loop |
| **6c** | Coordinator phase-gated meta-loop | Convergence over fixed counts; per-phase error budget with escalation; condensed subagent returns; externalised state as recovery point; gate-route test + Bash gate-guard hook | ✅ COMPLETE (2026-06-20). T1–T6 done. Meta-loop wired into `/coord continue`; condensed returns + restart-from-last-passed-gate added; gate-route test found the Bash route (deny covers Edit/Write only) → blocking PreToolUse hook shipped in settings template (no install.sh/SHA churn). Error budget default 3, tune from a harness-run loop |
| **6d** | Consolidation & public comms | Single consolidated update of README, CHANGELOG (finalise `[Unreleased]` → v6.2.0), RELEASE-HISTORY, upgrade docs, and the `agent-11-website` repo — reading the User-Facing Changes running list from progress.md. Cuts the v6.2.0 release | Detailed spec ready, pending Jamie's approval (`sprints/sprint-6d-consolidation-comms.md`). Gate met: 6a live-demoed, 6b shipped+watched, 6c shipped |

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
