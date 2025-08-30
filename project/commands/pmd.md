---
name: pmd
description: Post Mortem Dump - Analyze failures and suggest improvements
---

# POST MORTEM DUMP (PMD) COMMAND 🔍

**Command**: `/pmd [issue_description]`

**Purpose**: Conduct systematic root cause analysis of failures to identify improvements in agents, documentation, and processes.

## WHAT IS PMD?

PMD (Post Mortem Dump) is a diagnostic command that analyzes failures and issues to identify their root causes across multiple system layers:
- Agent performance and prompts
- Documentation quality and completeness
- Tool usage and configuration
- Process and coordination issues

## KEY FEATURES

- **Systematic Analysis**: Examines agents, docs, tools, and processes
- **Root Cause Identification**: Pinpoints primary and contributing factors
- **Actionable Recommendations**: Provides specific fixes with file locations
- **Pattern Recognition**: Identifies recurring issues across failures
- **Prevention Strategies**: Suggests monitoring and validation improvements

## USAGE SCENARIOS

```bash
# Analyze recent failures from progress.md
/pmd

# Analyze specific issue
/pmd "Coordinator not using Task tool correctly"

# Analyze deployment failure
/pmd "Installation script failing on Windows"

# Analyze coordination breakdown
/pmd "Agents producing conflicting outputs"
```

## ANALYSIS CATEGORIES

### 1. Agent Performance
- Prompt clarity and completeness
- Scope boundary compliance
- Coordination protocol adherence
- Tool usage correctness
- Error handling robustness

### 2. Documentation Quality
- CLAUDE.md currency and accuracy
- Project-plan.md task definition
- Progress.md issue logging
- Ideation document sufficiency
- README troubleshooting coverage

### 3. Tool Usage
- MCP prioritization
- Task tool delegation
- File operation accuracy
- Error detection and handling
- Performance optimization

### 4. Process Issues
- Planning adequacy
- Communication clarity
- Testing coverage
- Issue detection speed
- Escalation procedures

## OUTPUT STRUCTURE

Generates `post-mortem-analysis.md` containing:

### Executive Summary
High-level description of issue and impact

### Timeline of Events
Chronological sequence leading to failure

### Root Cause Analysis
- Primary cause with evidence
- Contributing factors
- Impact assessment

### Recommendations
- **Immediate Fixes**: Do now with specific file changes
- **Short-term Improvements**: This week enhancements
- **Long-term Enhancements**: This month strategic changes

### Prevention Strategies
- Detection mechanisms
- Prevention validations
- Mitigation procedures

### Follow-up Actions
Checklist of specific tasks with ownership

## BENEFITS

### For Development Teams
- Faster issue resolution
- Reduced repeat failures
- Better agent performance
- Improved documentation

### For Project Quality
- Systematic improvement process
- Knowledge preservation
- Pattern identification
- Risk reduction

### For Stakeholders
- Transparency in issue handling
- Confidence in improvement process
- Reduced project delays
- Better resource allocation

## PATTERN RECOGNITION

When multiple PMDs are run, the system can identify:
- Recurring failure patterns
- Common root causes
- Systemic issues
- Improvement trends

## SEVERITY LEVELS

- **Critical**: System unusable, data loss, security issues
- **High**: Major features broken, significant delays
- **Medium**: Workarounds available, moderate impact
- **Low**: Minor inconveniences, cosmetic issues

## BEST PRACTICES

### When to Run PMD
1. After any critical failure
2. When issues repeat
3. Before major releases
4. During retrospectives
5. When onboarding new team members

### How to Use Results
1. Implement immediate fixes first
2. Track pattern emergence
3. Update documentation promptly
4. Share learnings with team
5. Monitor success metrics

## INTEGRATION WITH AGENT-11

PMD works seamlessly with:
- **progress.md**: Analyzes logged issues
- **CLAUDE.md**: Suggests improvements
- **Agent prompts**: Recommends enhancements
- **Task tool**: Identifies delegation issues
- **MCPs**: Checks tool availability

## SUCCESS METRICS

PMD effectiveness measured by:
- Time to root cause identification
- Reduction in repeat failures
- Implementation of recommendations
- Improvement in agent performance
- Documentation quality scores

## EXAMPLE SCENARIOS

### Scenario 1: Agent Coordination Failure
```bash
/pmd "Developer and tester producing conflicting results"
```
Analyzes handoff protocols, scope boundaries, and communication patterns.

### Scenario 2: Deployment Issues
```bash
/pmd "Installation failing on fresh systems"
```
Examines prerequisites, dependencies, and error handling.

### Scenario 3: Performance Problems
```bash
/pmd "Commands taking too long to execute"
```
Reviews tool usage, MCP availability, and optimization opportunities.

## CONTINUOUS IMPROVEMENT

PMD enables a continuous improvement cycle:
1. **Detect**: Identify failures quickly
2. **Analyze**: Understand root causes
3. **Fix**: Implement targeted solutions
4. **Prevent**: Add validations and monitoring
5. **Learn**: Document and share knowledge

---

*The /pmd command transforms failures into learning opportunities, ensuring AGENT-11 systems continuously improve through systematic analysis and targeted enhancements.*