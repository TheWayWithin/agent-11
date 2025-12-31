# Plan-Driven Development Guide

**Version**: 1.0.0 (Sprint 9)
**Last Updated**: 2025-12-30

## Overview

Plan-Driven Development is AGENT-11's approach to mission execution where `project-plan.md` serves as the single source of truth for all mission state. This enables:

- **Stateless Resumption**: Resume missions after `/clear` with zero context loss
- **Autonomous Execution**: `/coord continue` runs until blocked, not until context exhausted
- **Vision Alignment**: Major decisions verified against original vision
- **Quality Enforcement**: Gates checked at every phase transition

## Core Concepts

### 1. project-plan.md as Truth

Your `project-plan.md` file contains ALL mission state:

```yaml
## Current State
- **Active Phase**: Phase 2 - Implementation
- **Active Task**: Create user authentication
- **Blockers**: None
- **Last Completed**: Database schema (2025-12-30 14:30)
```

The Coordinator reads this at mission start to understand exactly where you are.

### 2. The /coord continue Loop

When you run `/coord continue`, the Coordinator:

1. **Reads** project-plan.md current state
2. **Finds** next incomplete task `[ ]` in active phase
3. **Loads** relevant skills based on task keywords
4. **Routes** to appropriate specialist via Smart Delegation
5. **Verifies** deliverables exist on filesystem
6. **Updates** project-plan.md marking task `[x]`
7. **Checks** if phase complete → run quality gates
8. **Repeats** until a stopping condition is met

### 3. Stopping Conditions

The autonomous loop stops when:

| Condition | What Happens |
|-----------|--------------|
| Phase complete | All tasks `[x]`, gates run, user review |
| Quality gate failure | Blocking gate failed, fix required |
| Blocker encountered | Task marked blocked, user input needed |
| User intervention | Special marker in plan requests pause |
| Error threshold | 3 consecutive task failures |
| Context limit | >80% context utilization, safe to `/clear` |

### 4. The /clear Workflow

For long missions, use `/clear` between phases:

```
Phase 1: Complete
  ↓
/coord complete phase 1  → Generates phase-2-context.yaml
  ↓
/clear                   → Clears context
  ↓
/coord continue          → Reads project-plan.md, loads phase-2-context.yaml
  ↓
Phase 2: Begin
```

## Quick Start

### Starting a New Mission

```bash
# 1. Initialize foundations
/foundations init

# 2. Bootstrap with plan template
/bootstrap saas-mvp

# 3. Start autonomous execution
/coord continue
```

### Resuming After /clear

```bash
# After clearing context, simply:
/coord continue

# Coordinator reads project-plan.md and picks up where you left off
```

### Checking Status

```bash
# View current mission state
/plan status

# See detailed phase progress
/plan phase current
```

## The project-plan.md Structure

### Required Sections

```markdown
# Project Plan: [Project Name]

## Vision Summary
One-paragraph summary of what you're building and why.

## Current State
- **Active Phase**: Phase N - Name
- **Active Task**: Current task being worked
- **Blockers**: Any blocking issues
- **Last Completed**: Most recent completion with timestamp

## Phases

### Phase 1: Name
**Status**: Complete | In Progress | Pending
**Quality Gates**: build, test, lint

#### Tasks
- [x] Completed task (@specialist) ✅ 2025-12-30 14:30
- [ ] Pending task (@specialist)
- [ ] Another task (@specialist)

### Phase 2: Name
...
```

### Task Format

```markdown
- [ ] Task description (@specialist)
  - **Details**: Additional context if needed
  - **Depends On**: Other tasks if applicable
```

When completed:
```markdown
- [x] Task description (@specialist) ✅ 2025-12-30 14:30
```

## Smart Delegation Routing

The Coordinator automatically routes tasks to specialists based on keywords:

| Task Contains | Routes To | Skills Loaded |
|---------------|-----------|---------------|
| auth, login, oauth | @developer | saas-auth |
| ui, design, component | @designer | - |
| api, endpoint, backend | @developer | - |
| test, spec, validation | @tester | - |
| deploy, infrastructure | @operator | - |
| docs, readme, guide | @documenter | - |
| analytics, metrics, tracking | @analyst | saas-analytics |
| architecture, schema, rls | @architect | saas-multitenancy |
| strategy, product, requirements | @strategist | - |
| marketing, content, copy | @marketer | - |

## Quality Gates

Gates are checked at phase transitions:

```yaml
# .quality-gates.json
{
  "phases": {
    "implementation": {
      "gates": [
        { "type": "build", "severity": "blocking" },
        { "type": "test", "severity": "blocking" },
        { "type": "lint", "severity": "warning" }
      ]
    }
  }
}
```

Run gates manually:
```bash
python project/gates/run-gates.py --config .quality-gates.json --phase implementation
```

## Vision Integrity

Before major decisions, the Coordinator verifies alignment:

| Drift Level | Action |
|-------------|--------|
| ALIGNED | Proceed normally |
| MINOR_DRIFT | Log and continue |
| MAJOR_DRIFT | Pause for user confirmation |
| OUT_OF_SCOPE | Reject, request clarification |

## Best Practices

### 1. Keep project-plan.md Updated

Always reflect actual state:
- Mark tasks `[x]` immediately when complete
- Add timestamps to completions
- Update Current State section after each task

### 2. Use Meaningful Task Descriptions

```markdown
# Good
- [ ] Create Stripe checkout session endpoint (@developer)

# Bad
- [ ] Do payments
```

### 3. Set Appropriate Gates

- **Blocking**: Must pass (build, security)
- **Warning**: Should pass (lint, test coverage)
- **Info**: Nice to have (docs coverage)

### 4. Leverage Skills

Task descriptions with trigger keywords automatically load relevant skills:
- "implement user authentication" → loads saas-auth skill
- "set up stripe payments" → loads saas-payments skill

### 5. Use /clear Strategically

Clear context between phases, not mid-phase:
```bash
# Good: After phase complete
/coord complete phase 1
/clear
/coord continue

# Bad: Mid-phase (lose task context)
# Don't do this
```

## Troubleshooting

### "Coordinator doesn't know what to do"

Check that project-plan.md has:
- Clear Current State section
- Tasks with `[ ]` checkboxes
- Proper specialist assignments

### "Wrong specialist assigned"

Add explicit routing in task:
```markdown
- [ ] Review API design (@architect)  # Forces architect
```

### "Quality gate keeps failing"

1. Check gate configuration in `.quality-gates.json`
2. Run gate manually: `python project/gates/run-gates.py --config .quality-gates.json --phase [phase]`
3. Review gate output for specific failures

### "Context filling up too fast"

1. Complete current phase
2. Run `/coord complete phase N`
3. Use `/clear`
4. Resume with `/coord continue`

## Related Guides

- [Bootstrap Guide](./bootstrap-guide.md) - Getting started with /bootstrap
- [Quality Gates Guide](./quality-gates-guide.md) - Configuring quality gates
- [Skills Guide](./skills-guide.md) - Using and creating skills
- [Coordinator Commands](./coordinator-commands.md) - Full command reference
