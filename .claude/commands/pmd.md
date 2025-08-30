---
name: pmd
description: Post Mortem Dump - Analyze failures and suggest improvements
---

# POST MORTEM DUMP (PMD) ANALYSIS 🔍

**Command**: `/pmd [issue_description]`

**Arguments**: 
- `issue_description` (optional): Specific issue to analyze. If not provided, analyzes recent failures from progress.md

## PMD ANALYSIS PROTOCOL

You are conducting a systematic post-mortem analysis to identify root causes in agent performance, documentation, and system configuration.

### EXECUTION STEPS

1. **Issue Identification**
   - If issue_description provided, focus on that specific problem
   - Otherwise, analyze recent issues from progress.md
   - Check for patterns in repeated failures

2. **Root Cause Analysis**

Examine these areas systematically:

#### A. Agent Performance Analysis
```
- Agent Prompts: Are instructions clear and complete?
- Scope Boundaries: Are agents staying in their lanes?
- Coordination: Is Task tool being used correctly?
- Handoffs: Are deliverables clearly defined?
```

#### B. Documentation Quality
```
- CLAUDE.md: Is it current and comprehensive?
- project-plan.md: Are tasks well-defined?
- progress.md: Are issues being logged properly?
- Ideation docs: Do they provide sufficient context?
```

#### C. Tool Usage Patterns
```
- MCP Usage: Are agents checking for MCPs first?
- Task Tool: Is delegation working correctly?
- File Operations: Are paths and edits correct?
- Error Handling: Are failures being caught?
```

#### D. Process Issues
```
- Planning: Was the approach correct?
- Communication: Were requirements clear?
- Testing: Were edge cases considered?
- Monitoring: Was the issue detected quickly?
```

3. **Generate Post-Mortem Analysis**

Create `post-mortem-analysis.md` with:

```markdown
# Post Mortem Analysis

**Analysis Date**: [Today's date]
**Issue**: [Description of failure/issue]
**Severity**: Critical / High / Medium / Low
**First Occurred**: [Date if known]

## Executive Summary

[Brief description of the issue and its impact]

## Timeline of Events

| Time | Event | Actor | Outcome |
|------|-------|-------|---------|
| [When] | [What happened] | [Who/what] | [Result] |

## Root Cause Analysis

### Primary Cause
**Category**: [Agent / Documentation / Tool / Process / External]
**Specific Issue**: [Detailed explanation]
**Evidence**: [Specific examples from logs/files]

### Contributing Factors
1. [Factor 1 with explanation]
2. [Factor 2 with explanation]
3. [Factor 3 with explanation]

## Impact Assessment

- **Development Impact**: [Time lost, rework required]
- **Quality Impact**: [Bugs introduced, tech debt]
- **Team Impact**: [Confusion, blocked work]
- **Business Impact**: [Delays, feature gaps]

## What Went Wrong

### Agent-Related Issues
- [ ] Unclear or incomplete prompts
- [ ] Missing coordination protocols
- [ ] Scope boundary violations
- [ ] Incorrect tool usage
- [ ] Missing error handling

### Documentation Issues
- [ ] Outdated CLAUDE.md
- [ ] Incomplete project-plan.md
- [ ] Missing context in ideation docs
- [ ] Unclear requirements
- [ ] Missing troubleshooting guides

### System Configuration Issues
- [ ] MCP not available when needed
- [ ] Environment variables missing
- [ ] Dependencies not installed
- [ ] Version mismatches
- [ ] Permission problems

### Process Issues
- [ ] Inadequate planning
- [ ] Poor communication
- [ ] Insufficient testing
- [ ] Late detection
- [ ] No escalation path

## Recommendations

### Immediate Fixes (Do Now)
1. **[Specific action]**
   - File: [Which file to update]
   - Change: [Specific modification]
   - Owner: [Which agent/person]

2. **[Specific action]**
   - File: [Which file to update]
   - Change: [Specific modification]
   - Owner: [Which agent/person]

### Short-term Improvements (This Week)
1. [Improvement with rationale]
2. [Improvement with rationale]

### Long-term Enhancements (This Month)
1. [Enhancement with expected impact]
2. [Enhancement with expected impact]

## Lessons Learned

### What Worked Well
- [Positive aspect to preserve]
- [Positive aspect to preserve]

### What Didn't Work
- [Failed approach to avoid]
- [Failed approach to avoid]

### Key Takeaways
1. [Learning for future projects]
2. [Learning for future projects]
3. [Learning for future projects]

## Prevention Strategies

### Detection
- Add monitoring for: [Specific metric/event]
- Create alert when: [Condition]

### Prevention
- Add validation for: [Input/output]
- Add check for: [Precondition]

### Mitigation
- Fallback plan: [Alternative approach]
- Recovery procedure: [Steps to recover]

## Follow-up Actions

- [ ] Update CLAUDE.md with: [Specific addition]
- [ ] Modify agent prompt for: [Agent name]
- [ ] Add test case for: [Scenario]
- [ ] Document workaround in: [Location]
- [ ] Create monitoring for: [Metric]

## Success Metrics

How we'll know the fix worked:
- [ ] [Specific measurable outcome]
- [ ] [Specific measurable outcome]
- [ ] [Specific measurable outcome]

---
*Analysis generated: [Timestamp]*
*Follow-up review date: [Date + 7 days]*
```

4. **Pattern Recognition**

If analyzing multiple issues, add:

```markdown
## Pattern Analysis

### Recurring Issues
| Pattern | Frequency | First Seen | Last Seen |
|---------|-----------|------------|-----------|
| [Pattern description] | [N times] | [Date] | [Date] |

### Common Root Causes
1. **[Root cause]**: Seen in [X]% of failures
2. **[Root cause]**: Seen in [Y]% of failures
```

5. **Severity Classification**

- **Critical**: System unusable, data loss, security breach
- **High**: Major feature broken, significant delay
- **Medium**: Workaround available, moderate impact
- **Low**: Minor inconvenience, cosmetic issue

### SUCCESS CRITERIA

✅ Root cause clearly identified
✅ Specific, actionable recommendations provided
✅ Clear ownership assigned for fixes
✅ Success metrics defined
✅ Prevention strategies documented

### FOCUS AREAS

When analyzing, pay special attention to:
- Repeated failures in the same area
- Issues that required manual intervention
- Problems that caused significant delays
- Failures in agent coordination
- Gaps in documentation

Remember: The goal is not to assign blame but to improve the system. Focus on systematic improvements that prevent future occurrences.