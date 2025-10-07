# Strategic Context Editing Guide

## Overview

Strategic context editing is a powerful technique that prevents context pollution during long-running missions by selectively clearing old tool results while preserving critical information. When combined with Claude Code's memory tools, context editing enables 30+ hour autonomous operations with 84% reduction in token consumption.

**Critical Principle**: Context editing and memory tools work together - memory preserves knowledge permanently, while context editing manages the working context window.

## When to Use Context Editing

### Trigger Thresholds

**Primary Trigger**: 30,000 input tokens
- Monitor token count during long operations
- Clear before hitting context limits
- Proactive clearing prevents forced truncation

**Secondary Triggers**:
- **Between Major Phases**: After completing significant milestones
- **Task Domain Switching**: Moving from backend to frontend work
- **After Knowledge Extraction**: Information moved to memory/context files
- **Before Complex Operations**: Start with clean context for difficult tasks
- **Tool Result Accumulation**: Many old read/grep/API results

### When NOT to Clear

**Never Clear During**:
- Active debugging sessions with relevant context
- Complex multi-step reasoning in progress
- Incomplete task with critical state in context
- Mid-conversation with unresolved questions
- Security-sensitive operations requiring full audit trail

**Warning Signs of Bad Timing**:
- Recent tool results are still needed
- User just provided new information
- Agent is in middle of complex analysis
- Dependencies between recent operations

## What Gets Preserved vs Cleared

### Always Preserved (NEVER Cleared)

**1. Memory Tool Calls** ✅
```json
// Automatic exclusion in configuration
"exclude_tools": ["memory"]
```
- All memory tool operations remain in context
- Critical for maintaining access to knowledge base
- Enables cross-session continuity

**2. Critical Context Information** ✅
- Current mission objectives from agent-context.md
- Security-critical decisions and constraints
- Recent architectural decisions (last 3 tool uses)
- Active handoff information
- Unresolved blockers or issues

**3. Recent Tool Results** ✅
```json
// Keep last 3 tool uses by default
"keep": {"type": "tool_uses", "value": 3}
```
- Most recent file reads
- Latest grep/search results
- Recent API responses
- Current deployment status

### Strategic Clearing Targets (Remove)

**1. Old Tool Results** ❌
- File reads from previous phases
- Outdated grep results
- Historical API responses
- Superseded deployment logs

**2. Intermediate Debugging Output** ❌
- Resolved error investigations
- Completed troubleshooting steps
- Old stack traces
- Historical test results

**3. Redundant Information** ❌
- Information now in memory files
- Details moved to context files
- Completed task outputs
- Duplicate search results

**4. Completed Task Details** ❌
- Finished implementation discussions
- Resolved design decisions (moved to docs)
- Historical conversation threads
- Old planning iterations

**5. Context Pollution** ❌
- Repetitive tool outputs
- Failed attempt results
- Superseded approaches
- Irrelevant side discussions

## Context Editing Configuration

### Standard Configuration

```python
CONTEXT_MANAGEMENT = {
    "edits": [{
        "type": "clear_tool_uses_20250919",
        "trigger": {"type": "input_tokens", "value": 30000},
        "keep": {"type": "tool_uses", "value": 3},
        "clear_at_least": {"type": "input_tokens", "value": 5000},
        "exclude_tools": ["memory"]
    }]
}
```

### Configuration Parameters

**1. trigger** - When to initiate clearing
```python
"trigger": {"type": "input_tokens", "value": 30000}
```
- Type: `input_tokens` (monitor input context size)
- Value: 30,000 tokens (typical threshold)
- Adjust based on mission complexity
- Lower for rapid iterations (20K)
- Higher for deep analysis (40K)

**2. keep** - What to preserve
```python
"keep": {"type": "tool_uses", "value": 3}
```
- Type: `tool_uses` (number of recent tool invocations)
- Value: 3 (last three tool results)
- Increase for complex debugging (5-7)
- Decrease for routine operations (1-2)

**3. clear_at_least** - Minimum clearing efficiency
```python
"clear_at_least": {"type": "input_tokens", "value": 5000}
```
- Type: `input_tokens` (minimum tokens to clear)
- Value: 5,000 tokens (worthwhile clearing)
- Ensures clearing has meaningful impact
- Prevents thrashing with small clears

**4. exclude_tools** - Never clear these tools
```python
"exclude_tools": ["memory"]
```
- List of tool names to preserve
- **CRITICAL**: Always exclude "memory"
- Add other tools as needed (rarely)
- Memory exclusion is non-negotiable

### Advanced Configurations

**Aggressive Clearing** (Rapid iteration projects):
```python
{
    "trigger": {"type": "input_tokens", "value": 20000},
    "keep": {"type": "tool_uses", "value": 2},
    "clear_at_least": {"type": "input_tokens", "value": 7000},
    "exclude_tools": ["memory"]
}
```

**Conservative Clearing** (Complex research missions):
```python
{
    "trigger": {"type": "input_tokens", "value": 40000},
    "keep": {"type": "tool_uses", "value": 5},
    "clear_at_least": {"type": "input_tokens", "value": 3000},
    "exclude_tools": ["memory"]
}
```

## Integration with Memory System

### Pre-Clearing Workflow

**Before issuing /clear command**:

1. **Extract Critical Insights to Memory**
   ```bash
   # Move important findings to persistent storage
   memory create /memories/lessons/phase-insights.xml
   ```

2. **Update Context Files**
   ```bash
   # Update agent-context.md with phase findings
   # Update handoff-notes.md for next agent
   ```

3. **Verify Memory Updates**
   - Confirm critical knowledge in memory files
   - Check that decisions are documented
   - Ensure handoff information is current

4. **Validate Memory Tool Calls Are Recent**
   - Memory operations in last 3 tool uses
   - Knowledge base accessible after clear

### During Context Editing

**Automatic Process** (no manual intervention):
1. Context editing triggers at threshold (30K tokens)
2. System identifies old tool results
3. Memory tool calls are excluded from clearing
4. Recent 3 tool uses are preserved
5. At least 5K tokens are cleared
6. Context window is cleaned

**What Happens**:
- ✅ Old file reads removed
- ✅ Historical grep results cleared
- ✅ Superseded tool outputs deleted
- ✅ Memory tool calls preserved
- ✅ Recent context maintained

### Post-Clearing Workflow

**After context edit completes**:

1. **Verify Context Continuity**
   - Check mission objectives still clear
   - Confirm recent decisions accessible
   - Validate memory still available

2. **Resume Operations**
   - Continue with clean context window
   - Access memory for historical knowledge
   - Reference context files for coordination

3. **Monitor Performance**
   - Track token consumption reduction
   - Verify operations continue smoothly
   - Confirm no critical information lost

## Strategic Clearing Points

### Mission Phase Boundaries

**Typical Clearing Opportunities**:

**After Requirements Analysis**:
- Clear detailed requirement discussions
- Preserve final user stories in memory
- Keep architectural constraints

**Between Architecture and Implementation**:
- Clear design exploration results
- Preserve final architecture in memory
- Keep implementation guidelines

**Between Features**:
- Clear completed feature implementation
- Preserve learnings in memory
- Keep active feature context

**After Testing**:
- Clear test execution details
- Preserve critical bugs in memory
- Keep deployment readiness status

**Before Deployment**:
- Clear development artifacts
- Preserve deployment configuration
- Keep production requirements

### Agent Handoff Points

**Strategic Clearing for Handoffs**:

**Before Delegating to Next Agent**:
1. Update handoff-notes.md with critical context
2. Move findings to memory if permanent
3. Clear old context from previous agent
4. Provide clean slate for next specialist

**Example**:
```
After @architect completes design:
1. Architecture documented in memory
2. Handoff notes updated for @developer
3. /clear to remove design exploration
4. @developer starts with clean context
```

### Long-Running Operations

**Periodic Clearing During Extended Work**:

**Every 2-3 Hours**:
- Check token count
- Extract key findings to memory
- Clear intermediate results
- Continue with fresh context

**Between Debug Sessions**:
- Document findings in progress.md
- Clear failed attempt results
- Preserve successful approaches
- Start next attempt clean

## Best Practices

### DO ✅

**1. Clear Proactively**
```
# GOOD: Clear before hitting limits
At 25K tokens: Prepare for clearing
At 30K tokens: Execute strategic clear
```

**2. Document Before Clearing**
```
# GOOD: Preserve critical information first
1. Update memory with insights
2. Update context files
3. Then execute /clear
```

**3. Clear at Phase Boundaries**
```
# GOOD: Natural clearing points
Phase 1 Complete → /clear → Phase 2 Start
```

**4. Verify Memory Preservation**
```
# GOOD: Ensure knowledge persists
Check memory files exist before clearing
Verify memory tools in recent context
```

**5. Monitor Token Impact**
```
# GOOD: Track clearing efficiency
Before clear: 30K tokens
After clear: 8K tokens (22K cleared)
```

### DON'T ❌

**1. Don't Clear Mid-Task**
```
# BAD: Losing critical working context
Mid-implementation → /clear → Lost state
```

**2. Don't Clear Without Documenting**
```
# BAD: Information loss
/clear → Critical decision lost
Should have: Document → /clear
```

**3. Don't Clear Too Frequently**
```
# BAD: Cache thrashing
/clear every 5 minutes
Minimum: Every 10K tokens gained
```

**4. Don't Skip Memory Updates**
```
# BAD: Losing permanent knowledge
Critical insight → /clear → Lost forever
Should: Insight → memory → /clear
```

**5. Don't Clear During Debugging**
```
# BAD: Losing diagnostic context
Active bug hunt → /clear → Lost clues
Should: Resolve bug → Document → /clear
```

## Prompt Cache Considerations

### How Context Editing Affects Cache

**Cache Invalidation**:
- Context editing invalidates prompt cache prefixes
- Cached responses become unavailable
- System rebuilds cache from new context

**Performance Trade-offs**:
- **Short-term cost**: Cache rebuild overhead
- **Long-term gain**: Smaller context = faster processing
- **Net benefit**: 84% token reduction outweighs cache loss

### Optimizing Cache Usage

**1. Batch Memory Updates**
```
# GOOD: Single cache break
Update all memory files → /clear once

# BAD: Multiple cache breaks
Update memory → /clear → Update → /clear
```

**2. Strategic Timing**
```
# GOOD: Clear when cache benefit is low
After 30K tokens: Cache benefit diminished
Clear and rebuild: Fresh cache on lean context
```

**3. Minimize Thrashing**
```
# GOOD: Meaningful clears only
Clear at least 5K tokens per operation
Allows cache to be useful before next clear
```

## Agent-Specific Guidance

### For Coordinator

**Context Management During Orchestration**:
- Clear between mission phases
- Preserve delegation history in memory
- Keep active agent status in context
- Clear completed agent results

**Timing**:
- After each major phase completion
- Before switching mission types
- When delegating to new specialist

### For Developer

**Context Management During Implementation**:
- Clear between features
- Preserve code decisions in memory
- Keep active implementation context
- Clear old debugging sessions

**Timing**:
- After feature completion
- Between unrelated implementations
- After major refactoring

### For Architect

**Context Management During Design**:
- Clear between design iterations
- Preserve final architecture in memory
- Keep active design constraints
- Clear exploration results

**Timing**:
- After design finalization
- Between system components
- After architecture decisions

### For Tester

**Context Management During Testing**:
- Clear between test suites
- Preserve critical bugs in memory
- Keep active test results
- Clear old test outputs

**Timing**:
- After test suite completion
- Between testing phases
- After bug documentation

## Troubleshooting

### Problem: Memory Lost After Clearing

**Cause**: Memory tools not in exclude list
```python
# WRONG:
"exclude_tools": []  # Memory gets cleared!

# RIGHT:
"exclude_tools": ["memory"]  # Memory preserved
```

**Solution**: Always configure memory exclusion

### Problem: Too Little Context Cleared

**Cause**: Threshold too high or keep value too high
```python
# Current:
"trigger": {"type": "input_tokens", "value": 50000}  # Too late
"keep": {"type": "tool_uses", "value": 10}  # Too many kept

# Better:
"trigger": {"type": "input_tokens", "value": 30000}
"keep": {"type": "tool_uses", "value": 3}
```

### Problem: Critical Information Lost

**Cause**: Clearing without documenting first
**Solution**: Always extract to memory before clearing

**Prevention**:
1. Check what's in context
2. Extract critical insights to memory
3. Update handoff-notes.md
4. Then execute /clear

### Problem: Frequent Cache Invalidation

**Cause**: Clearing too frequently
**Solution**: Set minimum clearing threshold

```python
"clear_at_least": {"type": "input_tokens", "value": 5000}
```

Only clear when at least 5K tokens can be removed.

## Performance Metrics

### Expected Improvements

**Token Consumption**:
- Without context editing: 120K tokens/8hr mission
- With context editing: 19K tokens/8hr mission
- **Reduction**: 84%

**Autonomous Operation Duration**:
- Without context editing: 6-8 hours
- With context editing: 30+ hours
- **Improvement**: 4-5x longer

**Agent Effectiveness**:
- Memory-informed decisions: 39% improvement
- Reduced context confusion: Better focus
- Cleaner handoffs: Fewer errors

### Monitoring Metrics

**Track These Values**:
1. **Token count before/after clear**: Should clear 5K+ tokens
2. **Clear frequency**: Every 10-15K tokens accumulated
3. **Memory file count**: Should stay manageable (< 20 files)
4. **Mission completion time**: Should decrease with experience
5. **Context loss incidents**: Should be zero with proper documentation

## Examples by Scenario

### Example 1: Build Mission (8-hour operation)

**Context Clearing Strategy**:

```
Mission Start (0 tokens):
↓
Phase 1: Requirements (10K tokens):
- Strategic analysis
- User stories created
→ UPDATE memory: requirements.xml
→ UPDATE handoff: next agent context
→ /clear → (3K tokens)

Phase 2: Architecture (13K tokens from 3K):
- System design
- Technology choices
→ UPDATE memory: architecture.xml
→ UPDATE handoff: implementation guide
→ /clear → (3K tokens)

Phase 3: Implementation (30K tokens from 3K):
- Feature 1 complete
→ UPDATE memory: decisions.xml
→ /clear → (5K tokens)
- Feature 2 complete
→ UPDATE memory: lessons.xml
→ /clear → (5K tokens)

Phase 4: Testing (15K tokens from 5K):
- Test results documented
→ UPDATE memory: quality.xml
→ /clear → (3K tokens)

Mission Complete (3K tokens):
Total tokens used: ~71K (vs 250K without clearing)
Reduction: 71% even with conservative clearing
```

### Example 2: Debugging Session

**Context Clearing Strategy**:

```
Bug Report (0 tokens):
↓
Investigation (15K tokens):
- Stack traces analyzed
- Code reviewed
- Root cause unclear
→ DO NOT CLEAR (active debugging)

Root Cause Found (20K tokens):
- Issue identified
- Solution designed
→ UPDATE memory: debugging.xml
→ UPDATE progress.md: root cause
→ /clear → (4K tokens)

Fix Implementation (14K tokens from 4K):
- Code changes made
- Tests passing
→ UPDATE memory: solution.xml
→ /clear → (3K tokens)

Complete (3K tokens):
Clearing enabled focused debugging without losing critical trace information.
```

### Example 3: Multi-Day Mission

**Context Clearing Strategy**:

```
Day 1 - Phase 1 & 2 (8 hours):
- Requirements + Architecture
- Memory initialized
- /clear at end of day → (3K tokens)

Day 2 - Phase 3 (8 hours):
- Read memory to resume context
- Implementation begins
- /clear between features (3x)
- End of day → (4K tokens)

Day 3 - Phase 4 & 5 (8 hours):
- Read memory to resume
- Testing + Deployment
- /clear after testing → (3K tokens)
- Mission complete

Total: 3 days, minimal token usage, zero context loss
```

## Quick Reference

### Context Editing Checklist

Before executing /clear:
- [ ] Critical insights extracted to memory
- [ ] Context files updated (agent-context.md, handoff-notes.md)
- [ ] Recent memory tool calls verified
- [ ] Current task is complete or at natural boundary
- [ ] At least 5K tokens will be cleared
- [ ] Not in middle of complex operation

After executing /clear:
- [ ] Verify memory still accessible
- [ ] Check mission objectives still clear
- [ ] Confirm recent decisions available
- [ ] Resume operations successfully

### Configuration Quick Start

**Standard Setup** (most missions):
```python
{
    "trigger": {"type": "input_tokens", "value": 30000},
    "keep": {"type": "tool_uses", "value": 3},
    "clear_at_least": {"type": "input_tokens", "value": 5000},
    "exclude_tools": ["memory"]
}
```

**Key Principles**:
1. Memory tools ALWAYS excluded
2. Clear at phase boundaries
3. Document before clearing
4. Monitor token impact
5. Never clear mid-task

---

## Related Documentation

- **Memory Management**: `/project/field-manual/memory-management.md`
- **Bootstrap Guide**: `/project/field-manual/bootstrap-guide.md`
- **Mission Templates**: `/missions/mission-*.md`
- **Agent Profiles**: `/project/agents/specialists/*.md`

---

**Last Updated**: October 6, 2025
**Version**: 1.0
**Part of**: AGENT-11 Modernization Phase 1.3
