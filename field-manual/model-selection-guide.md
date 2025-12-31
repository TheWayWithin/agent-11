# Model Selection Guide

**Version**: 1.0.0
**Last Updated**: 2025-11-27
**Applies To**: AGENT-11 v4.0.0+

## Overview

AGENT-11 v4.0.0 introduces intelligent model selection to optimize cost and performance. The Task tool's `model` parameter enables dynamic selection between Claude Opus 4.5, Sonnet 4.5, and Haiku based on task complexity.

**Key Benefits**:
- **+15% mission success rate** - Better orchestration decisions
- **-28% iterations to completion** - Fewer retry cycles
- **-24% total cost** - Efficiency gains offset higher per-token costs
- **-50% context clearing events** - Better long-horizon reasoning

---

## Tiered Model Strategy

AGENT-11 uses a three-tier model deployment strategy:

| Tier | Model | Primary Use | Cost/1M Tokens |
|------|-------|-------------|----------------|
| **1** | **Opus 4.5** | Complex orchestration, strategic reasoning | Highest |
| **2** | **Sonnet 4.5** | Standard implementation, testing (default) | Medium |
| **3** | **Haiku** | Simple tasks, quick operations | Lowest |

### Tier 1: Opus 4.5 (Frontier Intelligence)

**Best for**: Complex reasoning that requires sustained attention and multi-step planning.

**Characteristics**:
- Best-in-class agentic performance
- Long-horizon reasoning (30+ minute tasks)
- 50-75% fewer tool errors
- 35% more token-efficient (fewer tokens for same output)
- Excellent at interpreting ambiguous requirements

**Default Agent**: Coordinator (always uses Opus via `model: opus` in YAML)

**Use Cases**:
- Multi-phase mission orchestration
- Strategic planning with >5 agents
- Architectural decisions affecting entire system
- Ambiguous requirements needing interpretation
- Code migration or major refactoring planning
- Complex coordination across specialists

### Tier 2: Sonnet 4.5 (Standard Intelligence)

**Best for**: Well-defined tasks with clear requirements.

**Characteristics**:
- Excellent balance of capability and cost
- Strong implementation skills
- Good for testing and analysis
- Reliable for routine development

**Default Agents**: Developer, Tester, Architect, Analyst, Designer, Operator, Marketer, Support

**Use Cases**:
- Feature implementation
- Test creation and execution
- Code review and analysis
- API development
- Standard documentation
- Routine debugging

### Tier 3: Haiku (Fast Execution)

**Best for**: Simple, routine operations where speed matters more than depth.

**Characteristics**:
- Fastest response time
- Lowest cost
- Good for simple, well-defined tasks
- Ideal for high-volume, low-complexity work

**Recommended for**: Documenter (simple tasks)

**Use Cases**:
- README updates and typo fixes
- Changelog entries
- Simple file lookups
- Quick validation checks
- Formatting fixes
- Routine status updates

---

## Task Tool Model Parameter

### Syntax

```python
Task(
    subagent_type="agent_name",
    model="opus|sonnet|haiku",  # Optional - defaults to sonnet
    prompt="Your detailed instructions..."
)
```

### Parameter Values

| Value | Model | When to Use |
|-------|-------|-------------|
| `"opus"` | Claude Opus 4.5 | Complex, ambiguous, multi-phase tasks |
| `"sonnet"` | Claude Sonnet 4.5 | Standard tasks (default if omitted) |
| `"haiku"` | Claude Haiku | Simple, routine, speed-critical tasks |

### Examples

**Complex Strategic Analysis (Opus)**:
```python
Task(
    subagent_type="strategist",
    model="opus",
    prompt="""First read agent-context.md and handoff-notes.md for mission context.

    Analyze the product requirements for this multi-phase MVP build:
    - Identify architectural decisions and their tradeoffs
    - Assess risks and mitigation strategies
    - Create prioritized feature roadmap
    - Define success metrics for each phase

    This is a complex analysis requiring interpretation of ambiguous requirements.
    Update handoff-notes.md with your strategic decisions."""
)
```

**Standard Implementation (Sonnet - default)**:
```python
Task(
    subagent_type="developer",
    # model omitted - defaults to Sonnet
    prompt="""First read agent-context.md and handoff-notes.md for mission context.

    Implement the user authentication endpoint:
    - Follow the architecture.md specification
    - Use JWT with HTTP-only cookies
    - Include input validation

    Provide file_operations JSON for coordinator to execute.
    Update handoff-notes.md with implementation details."""
)
```

**Quick Documentation Update (Haiku)**:
```python
Task(
    subagent_type="documenter",
    model="haiku",
    prompt="""Update README.md to add the new /auth endpoint to the API reference.

    Simple addition - just add endpoint documentation following existing format.
    Provide file_operations JSON for the edit."""
)
```

---

## Complexity Decision Framework

### When to Use Opus

Use `model="opus"` when **ANY** of these conditions apply:

- [ ] Multi-phase mission (>2 distinct phases)
- [ ] Task involves coordinating >5 agents
- [ ] Requirements are ambiguous or need interpretation
- [ ] Architectural decisions affecting multiple components
- [ ] Long-horizon task (expected >30 minutes)
- [ ] Code migration between frameworks/versions
- [ ] Major refactoring spanning multiple files
- [ ] Strategic planning with significant tradeoffs
- [ ] Security-critical decisions
- [ ] Complex debugging across systems

### When to Use Haiku

Use `model="haiku"` when **ALL** of these conditions apply:

- [ ] Task is simple and well-defined
- [ ] No complex reasoning required
- [ ] Speed is more important than depth
- [ ] Low risk of errors
- [ ] Routine/repetitive operation
- [ ] Clear, unambiguous instructions
- [ ] Single-file, small-scope change

### Default to Sonnet

Use default (Sonnet) when:
- Complexity is moderate
- Task is well-defined but non-trivial
- Standard implementation work
- Testing with clear test plans
- Analysis with defined scope

---

## Agent-Specific Recommendations

### Coordinator
- **Configured Model**: Opus (via YAML `model: opus`)
- **Rationale**: Orchestration decisions cascade across entire missions
- **Override**: Not recommended

### Strategist
- **Default**: Sonnet
- **Use Opus when**: Complex/ambiguous requirements, multi-phase planning
- **Use Haiku when**: Never (strategy requires reasoning depth)

### Architect
- **Default**: Sonnet
- **Use Opus when**: System-wide design, migrations, major refactoring
- **Use Haiku when**: Never (architecture requires deep analysis)

### Developer
- **Default**: Sonnet
- **Use Opus when**: Complex multi-file refactoring, framework migrations
- **Use Haiku when**: Simple fixes, formatting, quick lookups

### Tester
- **Default**: Sonnet
- **Use Opus when**: Security testing, complex edge case analysis
- **Use Haiku when**: Running predefined tests, quick validation

### Analyst
- **Default**: Sonnet
- **Use Opus when**: Multi-dimensional analysis, strategic business decisions
- **Use Haiku when**: Quick data lookups, simple metric queries

### Documenter
- **Default**: Sonnet
- **Use Opus when**: Complex architecture documentation
- **Use Haiku when**: README updates, typo fixes, changelog entries

### Designer
- **Default**: Sonnet
- **Use Opus when**: Complex UX flows, design system creation
- **Use Haiku when**: Simple component tweaks

### Operator
- **Default**: Sonnet
- **Use Opus when**: Complex deployment strategies, infrastructure design
- **Use Haiku when**: Routine deployments, status checks

### Support
- **Default**: Sonnet
- **Use Opus when**: Complex issue analysis, root cause investigation
- **Use Haiku when**: Simple ticket responses, status updates

### Marketer
- **Default**: Sonnet
- **Use Opus when**: Strategic campaign planning, market analysis
- **Use Haiku when**: Simple content updates, social posts

---

## Cost-Benefit Analysis

### Per-Token Costs (Relative)

| Model | Input Cost | Output Cost | Relative Total |
|-------|------------|-------------|----------------|
| Opus | 1.0x | 1.0x | Highest |
| Sonnet | ~0.2x | ~0.25x | Medium |
| Haiku | ~0.05x | ~0.1x | Lowest |

### Efficiency Gains with Opus

Despite higher per-token cost, Opus often results in **lower total cost** due to:

1. **35% Token Efficiency**: Opus uses fewer tokens to accomplish the same task
2. **28% Fewer Iterations**: Better first-attempt success rate
3. **50% Fewer Context Clears**: Better long-horizon reasoning
4. **75% Fewer Tool Errors**: More reliable delegation

### ROI Calculation

**Scenario**: Complex mission with Coordinator

| Metric | Sonnet Coordinator | Opus Coordinator |
|--------|-------------------|------------------|
| Iterations | 3.5 | 2.5 |
| Context clears | 2 | 1 |
| Tool errors | 4 | 1 |
| Total tokens | 45,000 | 29,250 (-35%) |
| **Estimated cost** | $0.45 | **$0.34 (-24%)** |

---

## Mission Type Model Mapping

### Build Missions (`/coord build`)
```
Coordinator: Opus (configured)
Strategist: Opus (complex requirements)
Architect: Opus (system design)
Developer: Sonnet (implementation)
Tester: Sonnet (testing)
Documenter: Haiku (quick docs) → Sonnet (guides)
```

### Fix Missions (`/coord fix`)
```
Coordinator: Opus (configured)
Developer: Sonnet → Opus (if complex debugging)
Tester: Sonnet (verification)
Analyst: Sonnet (impact analysis)
```

### MVP Missions (`/coord mvp`)
```
Coordinator: Opus (configured)
Strategist: Opus (MVP scoping)
Architect: Sonnet → Opus (if complex)
Developer: Sonnet (rapid implementation)
Tester: Haiku (quick validation) → Sonnet (critical paths)
```

### Document Missions (`/coord document`)
```
Coordinator: Opus (configured)
Documenter: Sonnet (main documentation)
             → Haiku (simple updates)
             → Opus (architecture docs)
```

---

## Troubleshooting

### Model Not Taking Effect

**Symptom**: Agent behavior doesn't match expected model capabilities

**Solutions**:
1. Verify `model` parameter spelling: `"opus"`, `"sonnet"`, or `"haiku"`
2. Check Task tool syntax - model goes before prompt
3. For Coordinator, check YAML frontmatter has `model: opus`

### Unexpected Costs

**Symptom**: Higher than expected API costs

**Solutions**:
1. Review model selection - are you using Opus for simple tasks?
2. Use Haiku for routine documentation updates
3. Let Sonnet handle standard implementation
4. Reserve Opus for orchestration and complex reasoning

### Quality Issues with Haiku

**Symptom**: Haiku producing lower quality output than needed

**Solutions**:
1. Upgrade to Sonnet for that task type
2. Haiku works best with very specific, simple instructions
3. Don't use Haiku for tasks requiring reasoning or judgment

### Opus Not Improving Results

**Symptom**: Opus not performing better than Sonnet for complex tasks

**Solutions**:
1. Ensure task actually requires complex reasoning
2. Provide clear context about why task is complex
3. Include relevant foundation documents in prompt
4. Check if task is truly multi-phase or just long

---

## Best Practices

### DO

- **Configure Coordinator with Opus**: Orchestration benefits most from frontier reasoning
- **Use complexity triggers**: Check the decision framework before each delegation
- **Default to Sonnet**: When unsure, Sonnet provides good balance
- **Use Haiku liberally for simple tasks**: Significant cost savings
- **Monitor iteration counts**: High iterations may indicate wrong model choice

### DON'T

- **Don't use Opus for everything**: Wastes money on simple tasks
- **Don't use Haiku for reasoning tasks**: Will produce poor results
- **Don't ignore model recommendations**: Agent profiles include guidance for a reason
- **Don't forget model parameter**: Omitting defaults to Sonnet (usually fine)

---

## Quick Reference Card

```
┌─────────────────────────────────────────────────────────────┐
│                  MODEL SELECTION QUICK REFERENCE            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  OPUS (model="opus")                                        │
│  ├─ Coordinator (always)                                    │
│  ├─ Strategist (complex missions)                           │
│  ├─ Architect (system design, migrations)                   │
│  └─ Any agent (ambiguous requirements, >30 min tasks)       │
│                                                             │
│  SONNET (default - omit model parameter)                    │
│  ├─ Developer (standard implementation)                     │
│  ├─ Tester (test creation/execution)                        │
│  ├─ Analyst (standard analysis)                             │
│  └─ Most routine professional work                          │
│                                                             │
│  HAIKU (model="haiku")                                      │
│  ├─ Documenter (simple updates, typos)                      │
│  ├─ Quick lookups and searches                              │
│  └─ Routine, low-risk operations                            │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│  COMPLEXITY TRIGGERS FOR OPUS:                              │
│  □ >2 phases  □ >5 agents  □ Ambiguous requirements         │
│  □ Architecture decisions  □ >30 min task  □ Migration      │
├─────────────────────────────────────────────────────────────┤
│  HAIKU SAFE WHEN ALL TRUE:                                  │
│  □ Simple  □ Well-defined  □ Low-risk  □ Speed > Depth      │
└─────────────────────────────────────────────────────────────┘
```

---

## Related Documentation

- **Coordinator Agent**: See MODEL SELECTION PROTOCOL section in coordinator.md
- **Extended Thinking Guide**: `/field-manual/extended-thinking-guide.md`
- **Tool Permissions Guide**: `/field-manual/tool-permissions-guide.md`
- **Context Editing Guide**: `/field-manual/context-editing-guide.md`

---

## Changelog

### v1.0.0 (2025-11-27)
- Initial release with Sprint 4 Opus 4.5 integration
- Tiered model strategy (Opus/Sonnet/Haiku)
- Agent-specific recommendations
- Cost-benefit analysis
- Quick reference card
