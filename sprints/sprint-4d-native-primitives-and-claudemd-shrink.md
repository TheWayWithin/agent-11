# Sprint 4d: Native Primitives + CLAUDE.md Shrink

**Part of**: Agent-11 v6.0 Evolution (Sprint 4 umbrella)
**Predecessor**: Sprint 4c — The Universal Router ✅ (T1-T6, T8 shipped; T7 deferred)
**Successor**: Sprint 4e — Context Consolidation (5→3)
**Status**: Detailed spec ready for Jamie's review; execution can start once Sprint 4c is committed

---

## Goal

Stop reinventing what Claude Code now provides natively. Two structural moves:

1. **Move quality gates from prompt instructions into platform hooks**. Claude Code's `PreToolUse` and `PostToolUse` hooks (configured in `.claude/settings.json`) now run deterministically. We currently rely on prompt-based reminders to lint/typecheck/test, which the model can ignore under context pressure. Hooks cannot be ignored.
2. **Shrink `library/CLAUDE.md` from 575 lines to under 80**. The 575-line file is the deployed-to-users `.claude/CLAUDE.md`. Most of its content duplicates protocols that already live in `coordinator.md`, individual command files, and the Karpathy constitution. The 80-line target keeps a constitution + mission index + skill loading rules — nothing else.

These changes make the deployed v6.0 surface look like a Claude Code-native project, not a custom orchestration framework.

## Why This Sprint

Three observations:

1. **Prompt-based quality gates fail under context pressure.** The v5.2 baseline shows specialists skipping lint/typecheck reminders when context is full. Hooks are deterministic; they run regardless of context state.
2. **Library CLAUDE.md is bloated and redundant.** 575 lines, half of which restate rules that exist in coordinator.md and command files. Users loading their project incur this cost on every session start. A leaner file means lower session-start tokens (M2) and clearer mental model.
3. **The agent-11 repo and a deployed user project look identical to the model.** They shouldn't. The agent-11 repo is the *library source*; user projects *consume* the library. A Meta-Development Skill that loads only when working inside agent-11 fixes this.

## Scope Reminder

All edits target the **library surface** (`library/CLAUDE.md`, `library/.claude/settings.json.template` if introduced, `project/commands/`, `project/agents/specialists/`, `project/skills/`). Do not modify our own `.claude/agents/`, `.claude/commands/`, or `.claude/CLAUDE.md` (working squad).

The one allowed working-squad edit: a **new** `.claude/skills/meta-dev/` skill if we want it to load while working on agent-11 itself. Called out explicitly under T4.

---

## Tasks

### T1. Audit library/CLAUDE.md and decide what stays

**Deliverable**: an annotation pass on `library/CLAUDE.md` listing, for each section, one of: `KEEP` (in the lean file), `MOVE → [target]` (relocated to a specific command/agent), or `DELETE` (redundant with coordinator.md or covered by hooks).

**Approach**:
1. Read each section of `library/CLAUDE.md` and classify it.
2. Produce a target-state outline of the lean file (<80 lines).
3. Produce a relocation map: which sections move to which file.
4. Identify any sections that are genuinely missing from the rest of the library (rare; flag if found).

**Recommended `KEEP` (in the lean file)**:
- Brief project overview (3-5 lines)
- Karpathy constitution reference (link, not full text — already in `project/constitution/karpathy-constitution.md`)
- Mission index (table: mission name → file)
- Skill loading rules (1 short paragraph + link to skill catalogue)
- Tracking file conventions (one-line: project-plan.md, progress.md, agent-context.md, handoff-notes.md exist; details in coordinator.md)
- Foundation file convention (one-line: ideation.md, architecture.md, PRD live in root or /docs)

**Recommended `MOVE` (relocate, don't delete)**:
- "Critical Software Development Principles" → keep canonical in coordinator.md DELEGATION RULES; reference from CLAUDE.md.
- "Mission Documentation Standards" → coordinator.md (already there).
- "Context Preservation System" → coordinator.md (already there in detail).
- "Coordinator Delegation Protocol" → coordinator.md.
- "FILE PERSISTENCE BUG & SAFEGUARDS" → coordinator.md (already there).
- "MCP Setup" / "Available Commands" → README or a `commands/README.md`.
- "Sprint 9: Plan-Driven Development" examples → `docs/plan-driven-development.md` (if needed).

**Recommended `DELETE`** (redundant with hooks or coordinator):
- Verbose "phase gate enforcement" duplications.
- Long-form "verification protocol" repeated in coordinator.md.

**Acceptance**:
- An annotation document or commit message lists the classification for each section.
- The proposed lean file outline is <80 lines.
- Jamie has reviewed and approved the relocation map before any deletion.

---

### T2. Design the hook configuration

**Deliverable**: `library/.claude/settings.json.template` (or equivalent) defining the v6.0 default hooks. Plus a section in the lean CLAUDE.md (or a dedicated `library/.claude/HOOKS.md`) documenting what each hook does and how a user disables one.

**Hooks to ship by default** (proposed — refine during execution):

| Event | Matcher | Command | Why |
|-------|---------|---------|-----|
| `PostToolUse` | `Edit\|Write` on `*.ts,*.tsx,*.js,*.jsx` | `npx tsc --noEmit` (if package.json present) | Catch type errors immediately |
| `PostToolUse` | `Edit\|Write` on `*.py` | `ruff check` (if pyproject.toml present) | Lint Python on save |
| `PostToolUse` | `Edit\|Write` on any code file | `git status --short` | Surface what changed |
| `PreToolUse` | `Bash` matching `rm -rf\|git push --force\|git reset --hard` | confirm prompt | Block destructive ops |

**Stack-aware behaviour**: hooks should no-op gracefully when their toolchain isn't present (no `package.json` → skip `tsc`; no `pyproject.toml` → skip `ruff`). Decision required: is the no-op handled by the hook command itself (a wrapper script that detects toolchain) or by the matcher?

**Open question**: which checks are safe to make blocking (`exit 1`) versus advisory (`exit 0` with output)? Recommendation: advisory by default; users can promote to blocking in their own settings.

**Acceptance**:
- `settings.json.template` exists and validates against Claude Code's schema.
- At least 2 hooks demonstrably trigger when running a smoke-test edit on a sample TS file in this repo.
- Hooks fail open (advisory) by default; promotion to blocking is documented.
- The deployment script (`install.sh`) copies the template to user `.claude/settings.json` on install (without overwriting an existing file — merge or back up).

---

### T3. Rewrite `library/CLAUDE.md` to <80 lines

**Deliverable**: the new lean file. Target shape:

```markdown
# CLAUDE.md

[1-2 lines: this file is the AGENT-11 library instructions]

## Constitution

All work follows the Karpathy Constitution: read before writing, state assumptions,
prefer minimal diffs, verify by running, avoid speculative refactors, lightest valid
path, present alternatives explicitly when uncertain.

Full text: `project/constitution/karpathy-constitution.md` (or `.claude/constitution/...` post-deploy).

## Missions

Run via `/coord [mission]` — see `project/commands/coord.md` for the routing table.

| Mode | Missions |
|------|----------|
| A — Greenfield | build, mvp, dev-setup, dev-alignment, integrate, migrate |
| B1 — Surgical  | fix |
| B2 — Maintenance | refactor, optimize, document, release, deploy, security |

Standalone (NOT via /coord): `/foundations`, `/architect`, `/bootstrap`.

## Tracking files

- `project-plan.md` — forward-looking plan
- `progress.md` — backward-looking changelog
- `agent-context.md` — accumulated findings
- `handoff-notes.md` — current task context for next specialist

Coordinator owns these. See `project/agents/specialists/coordinator.md`.

## Foundation files

`ideation.md`, `architecture.md`, `PRD.md`, `product-specs.md` — source of truth.
Live in repo root or `/docs/`. Specialists must verify against these before deciding.

## Skills

Domain skills load on trigger keywords. Catalogue: `project/skills/*/SKILL.md`.
SaaS skills available: auth, payments, multitenancy, billing, email, onboarding, analytics.

## Hooks

Quality gates run via `.claude/settings.json` hooks (lint, typecheck, destructive-op confirm).
Edit `.claude/settings.json` to disable.
```

The above sketch is ~50 lines. The target is `<80`, leaving a small budget for project-specific additions.

**Acceptance**:
- `library/CLAUDE.md` is <80 lines.
- All `MOVE` items from T1 have a confirmed home elsewhere in the library.
- A diff against the previous 575-line version shows the relocation is intentional, not loss.
- Smoke test: a fresh `install.sh` deployment to a scratch directory produces a working setup using only the lean file.

---

### T4. Meta-Development Skill

**Deliverable**: `.claude/skills/meta-dev/SKILL.md` (working squad — exception called out in scope reminder above) that loads when working in this repo.

**Trigger**: presence of `library/CLAUDE.md` and `project/agents/specialists/` in the working directory — or simpler, the AGENT_11_PROJECT env var that's already set in `.claude/settings.local.json`.

**Content** (concise — skill is a routing aid, not a manual):
- "You are working on the AGENT-11 library, not a user project."
- Edits target `project/agents/specialists/` and `project/commands/` (LIBRARY) by default.
- The working squad (`.claude/agents/`, `.claude/commands/`) is INTERNAL — do not modify unless explicitly improving the dev process.
- Reference: `.claude/CLAUDE.md` for the full distinction.

**Why a skill, not just CLAUDE.md**: the CLAUDE.md distinction works but loads on every session regardless of relevance. A skill loads only when the trigger matches, keeping context lean for users (who never see it) while keeping us oriented when working here.

**Acceptance**:
- Skill exists and loads when triggered.
- Working in agent-11, the model defaults to library targets without prompting.
- Skill is invisible (or absent) in deployed user projects.

---

### T5. Decentralise rules from CLAUDE.md to specific files

**Deliverable**: each rule that moved out of `library/CLAUDE.md` lives in its canonical home. Cross-references updated.

**Examples** (final list emerges from T1):
- "FILE PERSISTENCE BUG & SAFEGUARDS" → already in coordinator.md; remove duplicate from CLAUDE.md, leave a one-line pointer.
- "MCP-First Principle" → into the coordinator's DYNAMIC MCP TOOL DISCOVERY section (already there); remove duplicate.
- "Coordinator Delegation Protocol" → into coordinator.md; remove from CLAUDE.md.
- "Sprint 9 plan-driven examples" → into `docs/plan-driven-development.md` (new file) or removed entirely if covered by `/coord continue` documentation.

**Acceptance**:
- No section deleted from CLAUDE.md is silently lost.
- Each `MOVE` has a verified destination (file path + section heading).
- Searching the repo for any unique phrase from the old CLAUDE.md returns at least one canonical location.

---

### T6. Update `install.sh` for hook deployment

**Deliverable**: `project/deployment/scripts/install.sh` copies `library/.claude/settings.json.template` to the user's `.claude/settings.json` (merging if file exists; backing up if it would overwrite).

**Behaviour**:
- Fresh install (no existing settings.json) → copy verbatim.
- Existing settings.json without `hooks` key → add the hooks section.
- Existing settings.json with `hooks` already → leave it alone, log a notice.
- Always back up the previous file to `.claude/settings.json.bak.YYYYMMDD`.

**Acceptance**:
- Install script handles the three cases above.
- Smoke test: install on a fresh directory, on a directory with existing settings, on a directory with existing hooks.
- Document the merge behaviour in `project/deployment/README.md`.

---

### T7. Re-run harness and measure

**Subset**: Tasks 1 (bootstrap), 2 (feature build), 5 (commit review). Bootstrap exercises CLAUDE.md fully on session start; feature build is the long-horizon test; commit review is the cheapest read-only test.

**Deliverable**: `project/validation/milestone-4d.md` with results compared to milestone-4c (or v5.2 baseline if 4c's harness wasn't run).

**Success criteria**:
- M2 (session-start tokens) drops measurably on all three tasks (the lean CLAUDE.md is the main driver).
- At least one quality gate is observed running via hook in the harness recordings.
- No regression in outcomes — all tasks still succeed.
- M3 (unnecessary delegations) does not increase — the relocated content should still be findable by specialists when needed.

---

### T8. Write Sprint 4e detailed spec

**Deliverable**: replace the outline at `sprints/sprint-4e-context-consolidation.md` with a detailed spec.

The spec should cover:
- Folding `handoff-notes.md` into `agent-context.md` as a structured "Phase Handoff" block.
- Removing `progress.md` from active context (retain as append-only generated artefact, or delete entirely — open question).
- Renaming `agent-context.md` → `context.md` to match the v6.0 blueprint vocabulary (or leave as-is — open question).
- Migrating templates and any references in coordinator.md and mission files.
- Backwards-compatibility for users on a deployed v5.x install upgrading.

**Acceptance**: Sprint 4e detailed spec written; Jamie has reviewed and approved scope.

---

## Definition of Done

- [ ] T1: Annotation document classifies every section of library/CLAUDE.md; relocation map approved
- [ ] T2: settings.json.template exists with at least 4 default hooks; smoke test triggers them
- [ ] T3: library/CLAUDE.md is under 80 lines; smoke install works
- [ ] T4: Meta-Development Skill loads only in agent-11 repo
- [ ] T5: Every MOVE item has a verified canonical home; cross-refs updated
- [ ] T6: install.sh handles fresh / existing / hooks-already cases; backed up correctly
- [ ] T7: Harness subset re-run; milestone-4d.md committed; M2 drops measurably
- [ ] T8: Sprint 4e detailed spec written and approved

---

## Risks & Watch-Items

- **Hook portability across user stacks.** A hook that runs `npx tsc --noEmit` is useless on a Python project and noisy on a project without TypeScript. Mitigation: hooks must detect their toolchain and exit cleanly when absent. Test on at least one Node, one Python, one no-toolchain project before shipping.
- **Existing user `.claude/settings.json` overwrite.** A bad install script could overwrite users' custom hooks. Mitigation: always back up; never overwrite hooks that already exist.
- **Lost context from CLAUDE.md shrink.** If a relocation drops a rule that specialists actually relied on, we'll see it as M3 regression in T7. Mitigation: T1's annotation is the gate — review carefully before deleting.
- **Hook execution latency.** Hooks add wall-clock time to every Edit/Write. Mitigation: monitor in T7's harness; if a hook adds >2s on average, drop it or move it to advisory-on-demand.
- **Working-squad scope creep.** T4 creates a `.claude/skills/meta-dev/` — the only working-squad edit allowed in v6.0. Watch that future tasks don't quietly grow more.

---

## Open Design Questions

- **Blocking vs advisory hooks?** Recommendation: advisory by default (exit 0 + output). Users can promote to blocking. Decide for sure during T2.
- **Hook config: ship in `library/.claude/settings.json.template` or merge into `library/CLAUDE.md`?** Recommendation: separate file. Keeps the lean CLAUDE.md uncluttered and lets hooks evolve independently.
- **Meta-Dev Skill trigger?** AGENT_11_PROJECT env var (cleanest), or filesystem heuristic (`library/CLAUDE.md` exists). Recommendation: env var — it's already set in our local settings and is unambiguous.
- **Where does plan-driven-development documentation live?** Currently embedded in CLAUDE.md. Move to `docs/plan-driven-development.md` (new) or `project/missions/README.md` (existing). Decide during T5.

---

## Notes for Execution

- T1 is the thinking task — get the classification right before deleting anything.
- T2 and T3 can run in parallel once T1 is done.
- T4 is the smallest and lowest-risk task — could be lifted to first if a quick win helps.
- T6 (install.sh) is the riskiest task for users on `main` — write the smoke tests before merging.
- T7 is mandatory; without measurement we can't claim the lean file actually reduced session-start tokens.
- Sprint 4d is the structural pre-condition for Sprint 4e (context consolidation). Don't skip the relocation discipline — 4e expects to find rules in their new homes.
