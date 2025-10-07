# Extended Thinking Guide

## Overview

Extended thinking is a powerful Claude Code feature that allocates additional computational budget for complex reasoning tasks. By using specific keywords in your prompts, you can trigger different levels of thinking depth, allowing agents to explore alternatives, evaluate trade-offs, and produce higher-quality solutions for challenging problems.

**Key Principle**: Use extended thinking strategically - not everywhere. Reserve deeper thinking modes for complex problems where the quality improvement justifies the increased token cost.

## How Extended Thinking Works

### Claude Code Keywords (AGENT-11 Context)

In Claude Code, extended thinking is triggered by specific keywords in your prompts. These keywords are intercepted by Claude Code and converted to API calls with appropriate thinking budgets:

| Keyword | Thinking Budget | Use Case | Cost Impact |
|---------|----------------|----------|-------------|
| **"think"** | ~4,000 tokens | Basic extended thinking for moderately complex tasks | +1x baseline |
| **"think hard"** | ~6,000-8,000 tokens | Moderate extended thinking for complex decisions | +1.5-2x baseline |
| **"think harder"** / **"megathink"** | ~10,000 tokens | Deep extended thinking for critical decisions | +2.5-3x baseline |
| **"ultrathink"** | 31,999 tokens (max) | Maximum extended thinking for major architectural challenges | +8x baseline |

**Important**: These keywords only work in Claude Code, not in Claude's chat interface or raw API calls.

### API Implementation (For Reference)

For developers building custom agents or tools, extended thinking is enabled via the API:

```python
response = client.messages.create(
    model="claude-sonnet-4-5",
    max_tokens=16000,
    thinking={
        "type": "enabled",
        "budget_tokens": 10000  # Allocate thinking budget
    },
    messages=[{"role": "user", "content": "Your prompt here"}]
)
```

**Key Details**:
- Minimum thinking budget: 1,024 tokens
- Thinking tokens count towards `max_tokens` limit
- Thinking tokens are billed as output tokens
- Supported models: Opus 4.1, Opus 4, Sonnet 4.5, Sonnet 4, Sonnet 3.7

## When to Use Extended Thinking

### Appropriate Use Cases

**"think" (Basic Extended Thinking)**
- Moderately complex coding tasks
- Multi-step problem solving
- Code review and optimization
- Test case generation
- Refactoring existing code
- Bug investigation

**"think hard" (Moderate Extended Thinking)**
- Complex product strategy decisions
- UX/UI design with multiple constraints
- Mission orchestration and planning
- Data analysis with pattern recognition
- Multi-agent coordination
- Architecture exploration (not final decisions)

**"think harder" / "megathink" (Deep Extended Thinking)**
- Critical product decisions with long-term impact
- Complex strategy formulation
- Major feature architecture
- Trade-off analysis for important decisions
- Migration planning
- Performance optimization strategies

**"ultrathink" (Maximum Extended Thinking)**
- System architecture decisions
- Technology stack selection
- Major refactoring or migration strategies
- Complex security architecture
- Critical business logic design
- Foundation-level technical decisions

### When NOT to Use Extended Thinking

❌ **Avoid extended thinking for**:
- Simple, straightforward tasks
- Well-defined, routine operations
- Tasks with clear, single solutions
- Quick fixes or minor changes
- Repetitive operations
- Simple file operations or edits

**Why**: Extended thinking adds token cost without improving output quality for simple tasks.

## Extended Thinking in AGENT-11

### Agent-Specific Thinking Mode Assignments

Each AGENT-11 specialist has a default thinking mode based on their role's cognitive requirements:

#### **The Strategist** → "think harder"
- **Rationale**: Complex product strategy decisions require deep analysis of market dynamics, user needs, and business objectives
- **Use deeper thinking for**: MVP scope definition, roadmap planning, feature prioritization
- **Use standard thinking for**: User story creation, requirements documentation

#### **The Architect** → "ultrathink"
- **Rationale**: System architecture decisions have long-term implications and require comprehensive evaluation of alternatives
- **Use deeper thinking for**: Technology stack selection, system design decisions, scalability architecture
- **Use standard thinking for**: Documentation updates, architecture reviews

#### **The Developer** → "think"
- **Rationale**: Most coding tasks benefit from basic extended thinking for exploring implementation approaches
- **Use deeper thinking for**: Complex algorithm implementation, critical system components
- **Use standard thinking for**: Bug fixes, routine feature implementation, refactoring

#### **The Coordinator** → "think hard"
- **Rationale**: Mission orchestration requires careful planning and multi-agent coordination
- **Use deeper thinking for**: Complex mission planning, multi-specialist coordination, crisis management
- **Use standard thinking for**: Routine task delegation, status updates

#### **The Designer** → "think hard"
- **Rationale**: UX/UI design requires balancing aesthetics, usability, accessibility, and technical constraints
- **Use deeper thinking for**: New feature design, complex user flows, design system decisions
- **Use standard thinking for**: Design refinements, component updates

#### **The Tester** → "think"
- **Rationale**: Test execution is methodical and follows established patterns
- **Use deeper thinking for**: Test strategy design, complex edge case identification
- **Use standard thinking for**: Test implementation, test execution, bug reporting

#### **The Documenter** → "think"
- **Rationale**: Documentation follows established patterns and templates
- **Use deeper thinking for**: Architecture documentation, complex API documentation
- **Use standard thinking for**: User guides, README updates, changelog entries

#### **The Operator** → "think"
- **Rationale**: Deployment follows defined procedures and established patterns
- **Use deeper thinking for**: Disaster recovery planning, infrastructure architecture
- **Use standard thinking for**: Routine deployments, monitoring setup, incident response

#### **The Analyst** → "think hard"
- **Rationale**: Data analysis requires pattern recognition and insight extraction
- **Use deeper thinking for**: Complex data analysis, predictive modeling, trend identification
- **Use standard thinking for**: Data collection, reporting, dashboard creation

#### **The Marketer** → "think"
- **Rationale**: Content creation is creative but follows established frameworks
- **Use deeper thinking for**: Campaign strategy, brand positioning, market analysis
- **Use standard thinking for**: Content creation, social media posts, email campaigns

#### **The Support** → "think"
- **Rationale**: Issue resolution is systematic and follows troubleshooting patterns
- **Use deeper thinking for**: Complex issue investigation, root cause analysis
- **Use standard thinking for**: Ticket resolution, user communication, documentation

### Triggering Extended Thinking

**In Prompts**: Simply include the keyword in your instruction
```
"Please think about the best architecture for our payment processing system"
"Think harder about the trade-offs between microservices and monolith"
"Use ultrathink to evaluate our technology stack options"
```

**In Missions**: Coordinators can request extended thinking for specific phases
```
"For the architecture design phase, use ultrathink to evaluate all options"
"Think hard about the security implications before implementing"
```

**In Agent Responses**: Agents can self-trigger extended thinking
```
"This is a complex architectural decision. Let me use ultrathink to explore alternatives..."
```

## Cost-Benefit Analysis

### Token Cost Implications

Extended thinking tokens are billed as **output tokens** at the same rate as regular output:

**Claude Sonnet 4.5 Pricing** (example):
- Input: $3 per million tokens
- Output: $15 per million tokens

**Cost Examples**:
- **"think"** (4K tokens): ~$0.06 per response
- **"think hard"** (8K tokens): ~$0.12 per response
- **"think harder"** (10K tokens): ~$0.15 per response
- **"ultrathink"** (32K tokens): ~$0.48 per response

### Quality Improvements

Research and user feedback indicates:
- **10-30% improvement** in solution quality for complex problems
- **Reduced rework** from better initial decisions
- **Better architecture** from comprehensive evaluation
- **Fewer bugs** from thorough analysis

### Cost-Benefit Guidelines

**Good Investment** (quality improvement > cost):
- Critical architecture decisions (1 ultrathink vs. days of rework)
- Complex migrations (1 think harder vs. multiple failed attempts)
- Strategic product decisions (1 think harder vs. wrong market direction)
- Security architecture (1 ultrathink vs. security vulnerabilities)

**Poor Investment** (cost > quality improvement):
- Simple bug fixes (use standard thinking)
- Routine feature implementation (use "think" at most)
- Repetitive tasks (no extended thinking needed)
- Well-defined operations (follow existing patterns)

**ROI Formula**:
```
If (potential_rework_hours * hourly_rate) > extended_thinking_cost:
    Use extended thinking
Else:
    Use standard thinking
```

## Integration with Other AGENT-11 Systems

### Memory + Extended Thinking

Extended thinking works best when combined with memory tools:

1. **Before Extended Thinking**: Load relevant context from memory
```
"First read /memories/project/architecture.xml, then ultrathink about migration strategy"
```

2. **During Extended Thinking**: Agent reasons with full project context
```
Thinking: Considering previous architecture decisions in memory...
Evaluating migration approaches based on project constraints...
```

3. **After Extended Thinking**: Store insights in memory
```
"Save this architecture decision to /memories/technical/decisions.xml"
```

### Context Editing + Extended Thinking

Strategic `/clear` usage preserves thinking quality:

1. **Before Complex Thinking**: Clear accumulated context
```
/clear  # Remove old exploration, keep memory
"Now ultrathink about our system architecture"
```

2. **Benefit**: Extended thinking operates on clean, focused context
3. **Result**: Better quality reasoning without pollution

### Bootstrap + Extended Thinking

During project initialization:

1. **Bootstrap Phase**: Analyze codebase and create memory
2. **Thinking Phase**: Use extended thinking to evaluate architecture
3. **Documentation Phase**: Store decisions in CLAUDE.md and memory
4. **Result**: New projects start with thoroughly considered foundations

## Best Practices

### DO ✅

1. **Use extended thinking for complex decisions**
   - Architecture choices, strategy decisions, critical implementations

2. **Specify thinking mode explicitly when needed**
   - "Think harder about migration approaches"
   - "Use ultrathink to evaluate these architecture options"

3. **Combine with memory and context editing**
   - Clear context before extended thinking
   - Load relevant memory for informed reasoning
   - Store insights after thinking completes

4. **Document when you use deeper thinking**
   - Note in commit messages: "Architecture designed with ultrathink"
   - Helps team understand decision thoroughness

5. **Use appropriate thinking depth for task complexity**
   - Match thinking budget to problem complexity
   - Don't overuse expensive modes

### DON'T ❌

1. **Don't use ultrathink for simple tasks**
   - 8x cost increase rarely justified for routine work
   - Reserve for critical, high-impact decisions

2. **Don't use extended thinking on polluted context**
   - Clear context first for better thinking quality
   - Polluted context → wasted thinking budget

3. **Don't ignore cost implications**
   - Monitor token usage
   - Evaluate if thinking improvement justifies cost

4. **Don't use extended thinking for well-defined problems**
   - If solution is clear, extended thinking adds cost without value
   - Save thinking budget for ambiguous, complex problems

5. **Don't forget to store thinking results**
   - Extended thinking insights are valuable
   - Save to memory or documentation for future reference

## Mission-Specific Thinking Triggers

### BUILD Mission

**Phase 1: Requirements Analysis**
- **Thinking Mode**: "think hard"
- **Why**: Complex requirements need thorough analysis
- **Trigger**: Before creating technical specifications

**Phase 2: Architecture Design**
- **Thinking Mode**: "ultrathink" (if greenfield) or "think harder" (if extending)
- **Why**: Architecture decisions have long-term implications
- **Trigger**: Before finalizing system design

**Phase 3: Implementation**
- **Thinking Mode**: "think" (default)
- **Why**: Code implementation is systematic
- **Trigger**: For complex algorithms or critical components

**Phase 4: Testing**
- **Thinking Mode**: "think" (default)
- **Why**: Test execution follows patterns
- **Trigger**: For test strategy design use "think hard"

**Phase 5: Deployment**
- **Thinking Mode**: "think" (default)
- **Why**: Deployment follows procedures
- **Trigger**: For infrastructure decisions use "think hard"

### MVP Mission

**Day 1: MVP Scope Definition**
- **Thinking Mode**: "think harder"
- **Why**: MVP scope determines initial success
- **Trigger**: During scope definition workshop

**Day 2-3: Development Sprint**
- **Thinking Mode**: "think" (default)
- **Why**: Fast execution with focused scope
- **Trigger**: For architecture decisions use "think hard"

**Day 4: Launch Preparation**
- **Thinking Mode**: "think" (default)
- **Why**: Launch follows checklist
- **Trigger**: For rollback planning use "think hard"

### ARCHITECTURE Mission

**Architecture Exploration**
- **Thinking Mode**: "ultrathink"
- **Why**: Evaluating fundamental system design
- **Trigger**: At mission start

**Technology Stack Evaluation**
- **Thinking Mode**: "ultrathink"
- **Why**: Technology choices affect entire project
- **Trigger**: During technology selection

**Documentation**
- **Thinking Mode**: "think" (default)
- **Why**: Documentation follows templates
- **Trigger**: Standard documentation tasks

### SECURITY Mission

**Threat Modeling**
- **Thinking Mode**: "think hard"
- **Why**: Comprehensive threat identification
- **Trigger**: During threat analysis phase

**Security Architecture**
- **Thinking Mode**: "ultrathink"
- **Why**: Security design is critical and complex
- **Trigger**: For authentication, authorization, encryption design

**Implementation**
- **Thinking Mode**: "think" (default)
- **Why**: Security implementation follows established patterns
- **Trigger**: Standard security implementations

## Performance Monitoring

### Tracking Extended Thinking Effectiveness

1. **Monitor Quality Improvements**
   - Compare solutions with/without extended thinking
   - Track rework reduction
   - Measure architecture decision quality

2. **Track Cost Impact**
   - Monitor token consumption
   - Calculate cost per project phase
   - Evaluate ROI on extended thinking usage

3. **Optimize Thinking Allocation**
   - Identify tasks that benefit most from extended thinking
   - Adjust agent default modes based on actual results
   - Refine mission thinking triggers

### Metrics to Track

- **Thinking token usage**: How much thinking budget consumed
- **Solution quality**: Measured by rework reduction
- **Time to decision**: How thinking affects decision speed
- **Cost per decision**: Thinking cost vs. value delivered
- **Rework reduction**: Fewer iterations needed with extended thinking

## Troubleshooting

### Extended Thinking Not Working

**Symptom**: Keyword doesn't trigger extended thinking
- **Cause**: Keywords only work in Claude Code, not chat interface
- **Solution**: Use Claude Code environment or API with thinking parameter

**Symptom**: Thinking output seems shallow
- **Cause**: Context pollution or insufficient context
- **Solution**: Clear context before extended thinking, load relevant memory

**Symptom**: Too expensive
- **Cause**: Overuse of deep thinking modes
- **Solution**: Reserve ultrathink for critical decisions, use "think" for most tasks

### Quality Issues

**Symptom**: Extended thinking produces wrong conclusions
- **Cause**: Incorrect or incomplete context
- **Solution**: Load relevant memory, provide complete problem context

**Symptom**: Thinking time seems wasted
- **Cause**: Problem too simple for extended thinking
- **Solution**: Use standard thinking, reserve extended for complex problems

## Advanced Patterns

### Iterative Thinking

For extremely complex problems:

1. **First Pass**: "Think about the problem space"
2. **Second Pass**: "Think harder about the top 3 approaches"
3. **Final Pass**: "Ultrathink about the selected approach to finalize details"

### Collaborative Thinking

Multiple agents thinking together:

1. **Architect**: "Ultrathink about system design options"
2. **Developer**: "Think about implementation complexity for each option"
3. **Operator**: "Think hard about operational implications"
4. **Coordinator**: Synthesize insights and make decision

### Checkpoint Thinking

Save thinking progress during long sessions:

1. **Initial Thinking**: "Think harder about approach options"
2. **Save State**: Store thinking insights to memory
3. **Clear Context**: `/clear` to reset
4. **Resume Thinking**: Load memory, continue with fresh context

## Conclusion

Extended thinking is a powerful tool for improving decision quality on complex problems. Use it strategically:

- **Reserve deeper modes** for critical, high-impact decisions
- **Match thinking depth** to problem complexity
- **Combine with memory and context editing** for best results
- **Monitor cost vs. quality** improvements
- **Document thinking usage** for team awareness

When used appropriately, extended thinking can:
- Reduce rework by 30-50%
- Improve architecture quality significantly
- Save days or weeks of iteration
- Prevent costly mistakes in critical decisions

The key is strategic use: not everywhere, but where it matters most.
