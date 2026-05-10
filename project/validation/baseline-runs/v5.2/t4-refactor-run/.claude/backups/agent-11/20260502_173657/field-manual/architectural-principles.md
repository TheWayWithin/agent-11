# Architectural Principles

**Version**: 1.0.0 (Sprint 9)
**Last Updated**: 2025-12-30
**Status**: Consensus from LLM architectural review

## Overview

This document captures the foundational architectural decisions made during Sprint 9 development. These principles guide future development and ensure consistency across the AGENT-11 framework.

## Principle 1: Separate Commands with Distinct Responsibilities

### Decision
Maintain `/foundations`, `/bootstrap`, `/plan`, and `/coord` as distinct commands with clear separation of concerns.

### Rationale

| Command | Role | Responsibility |
|---------|------|----------------|
| `/foundations` | Initializer | Create vision and PRD documents |
| `/bootstrap` | Scaffolder | Generate project-plan.md from templates |
| `/plan` | Observer | View and query plan state (read-only) |
| `/coord` | Executor | Execute tasks, delegate to specialists |

### Why Not Merge?

1. **Cognitive Load**: Single mega-command becomes overwhelming
2. **Extensibility**: Each command evolves independently
3. **Composability**: Commands combine in different workflows
4. **Learning Curve**: Users learn one command at a time

### Examples

```bash
# Clear separation enables flexible workflows:
/foundations init          # Just create vision
/bootstrap api            # Just scaffold plan
/plan status              # Just check state
/coord continue           # Just execute

# Or compose:
/foundations init && /bootstrap saas-mvp && /coord continue
```

## Principle 2: Hybrid Script/Native Execution

### Decision
Use Coordinator prompts for orchestration and judgment; use helper scripts for deterministic tasks.

### The Rule

**If the operation is a pure function (`input → output` with no judgment needed), use a script.**

| Task Type | Handler | Example |
|-----------|---------|---------|
| Orchestration | Coordinator prompt | Deciding which specialist to use |
| Decision-making | Coordinator prompt | Evaluating if work meets requirements |
| Subjective evaluation | Coordinator prompt | Reviewing code quality |
| Repeatable computation | Script | Running quality gates |
| Deterministic checks | Script | Validating YAML schemas |
| Automation | Script | Generating boilerplate |

### Script Locations

```
project/
├── gates/
│   └── run-gates.py      # Quality gate execution
├── skills/
│   └── [skill]/
│       └── helpers/      # Skill-specific scripts
└── schemas/
    └── validate.py       # Schema validation (future)
```

### Benefits

1. **Reproducibility**: Scripts produce identical results every time
2. **Performance**: No LLM tokens for mechanical tasks
3. **Testability**: Scripts have unit tests
4. **Debuggability**: Deterministic failure modes

## Principle 3: Token Budget Proportionality

### Decision
Allocate token budgets based on information density and complexity, not uniform distribution.

### Guidelines

| Content Type | Token Range | Rationale |
|--------------|-------------|-----------|
| Simple patterns | 1,000-2,000 | Direct code, minimal explanation |
| Intermediate skills | 3,000-4,000 | Multiple patterns, stack variations |
| Complex architecture | 4,000-5,000 | Multi-pattern, decision trees |

### Skill Token Budgets

```yaml
saas-auth: 3800        # Multiple auth patterns
saas-payments: 4200    # Complex Stripe integration
saas-multitenancy: 4100 # RLS and tenant isolation
saas-billing: 3900     # Plan management complexity
saas-email: 3200       # Simpler, fewer variations
saas-onboarding: 3500  # UI patterns with flows
saas-analytics: 3600   # Event tracking patterns
```

### Delegation Budget

Maximum 15,000 tokens per delegation:
- Core instruction: ~2,000 tokens
- Skills (max 3): ~12,000 tokens
- Context buffer: ~1,000 tokens

## Principle 4: Skill Source vs Destination Separation

### Decision
Maintain clear separation between skill library (source) and deployed skills (destination).

### Architecture

```
Source (AGENT-11 Repository)          Destination (User Project)
─────────────────────────────         ─────────────────────────
project/skills/                       .claude/skills/
├── saas-auth/SKILL.md        →       ├── saas-auth/SKILL.md
├── saas-payments/SKILL.md    →       ├── saas-payments/SKILL.md
└── ...                               └── ...

templates/stack-profiles/             .stack-profile.yaml
├── nextjs-supabase.yaml      →       (selected profile)
└── ...
```

### Deployment Rules

1. **Source skills are templates**: May contain `{{stack.*}}` placeholders
2. **Deployed skills are concrete**: Placeholders resolved for user's stack
3. **User customization**: Users can modify deployed skills
4. **Updates are opt-in**: Updating AGENT-11 doesn't overwrite user changes

### Install Process

```bash
./install.sh
# Copies skills, resolves stack placeholders
# User's .stack-profile.yaml determines substitutions
```

## Principle 5: /clear Context Model

### Decision
Support stateless, phase-by-phase execution where `/clear` is a first-class operation.

### The Model

```
Phase N Complete
      ↓
/coord complete phase N     → Generates phase-(N+1)-context.yaml
      ↓
/clear                      → Clears Claude context
      ↓
/coord continue             → Reads project-plan.md + context file
      ↓
Phase N+1 Begins            ← Zero context bleed from Phase N
```

### Context Carryover

`phase-N-context.yaml` contains only essential carryover:

```yaml
phase: 3
previous_phases:
  - phase: 1
    status: complete
    key_decisions: [...]
  - phase: 2
    status: complete
    key_decisions: [...]
blockers: []
dependencies_for_next_phase:
  - "User table schema in migrations/001_users.sql"
  - "Auth middleware in src/middleware/auth.ts"
```

### Benefits

1. **Token Efficiency**: Long missions stay under context limits
2. **Clean Slate**: Each phase starts fresh without accumulated noise
3. **Resumability**: Can pause, close terminal, resume next day
4. **Debuggability**: Clear boundaries between phases

## Principle 6: Plan as Single Source of Truth

### Decision
`project-plan.md` is the authoritative source for mission state.

### What Lives in project-plan.md

| State | Location | Format |
|-------|----------|--------|
| Active phase | Current State section | Plain text |
| Active task | Current State section | Plain text |
| Blockers | Current State section | Bullet list |
| Task completion | Task checkboxes | `[x]` with timestamp |
| Phase status | Phase header | "Complete", "In Progress", "Pending" |

### What Doesn't Live in project-plan.md

| Information | Location | Reason |
|-------------|----------|--------|
| Code changes | Git commits | Version controlled |
| Issue history | progress.md | Changelog format |
| Evidence | evidence-repository.md | Artifacts |
| Handoff context | handoff-notes.md | Agent-to-agent |

### State Recovery

After `/clear`, Coordinator can fully recover state by reading:
1. `project-plan.md` - Current phase, completed tasks
2. `phase-N-context.yaml` - Phase-specific context
3. `handoff-notes.md` - Immediate next steps (optional)

## Principle 7: Quality Gates at Transitions

### Decision
Enforce quality gates at phase transitions, not continuously.

### Gate Timing

```
Task 1 → Task 2 → Task 3 → [PHASE GATE] → Task 4 → Task 5 → [PHASE GATE]
                           ↑                                  ↑
                     Gates checked                      Gates checked
```

### Rationale

1. **Efficiency**: Don't run full test suite after every task
2. **Natural boundaries**: Phases represent deployable increments
3. **Clear expectations**: Users know when gates run
4. **Fast feedback**: Individual task failures caught by specialist

### Gate Severity at Transitions

| Severity | Behavior |
|----------|----------|
| `blocking` | Must pass to proceed to next phase |
| `warning` | Logged, proceeds with caution |
| `info` | Informational, always proceeds |

## Summary

These seven principles form the architectural foundation of AGENT-11's Sprint 9 design:

1. **Separate Commands**: Clear responsibilities, composable workflows
2. **Hybrid Execution**: Scripts for determinism, prompts for judgment
3. **Token Proportionality**: Budgets match complexity
4. **Source/Destination**: Library vs deployment separation
5. **/clear Model**: Stateless phases with explicit carryover
6. **Plan as Truth**: Single source for mission state
7. **Gate Transitions**: Quality enforcement at phase boundaries

These principles should guide all future development and extensions to the framework.

## Related Documentation

- [Plan-Driven Development](./plan-driven-development.md)
- [Quality Gates Guide](./quality-gates-guide.md)
- [Skills Guide](./skills-guide.md)
- [Coordinator Commands](./coordinator-commands.md)
