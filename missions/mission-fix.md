# Mission: FIX 🐛
## Emergency Bug Resolution

**Mission Code**: FIX  
**Estimated Duration**: 1-3 hours  
**Complexity**: Low to High  
**Squad Required**: Developer, Tester, Analyst

## Mission Briefing

Rapid response protocol for bug diagnosis and resolution. This mission prioritizes quick identification, fix implementation, and prevention of regression.

## Required Inputs

1. **Bug Report** (required) - Error description, logs, or ticket
2. **Reproduction Steps** (preferred) - How to reproduce the issue
3. **System Context** (optional) - Environment details, recent changes

## Mission Phases

### Phase 1: Triage & Analysis (15-30 minutes) - IMMEDIATE ACTION

**Lead**: @analyst  
**Support**: @developer  
**Objective**: Understand the bug's impact and root cause

**COORDINATOR ACTION**: Immediately call @analyst - this is emergency response

```bash
@analyst Analyze the bug report:
1. Assess severity and user impact
2. Identify affected components
3. Review recent changes that might be related
4. Analyze error logs and stack traces
5. Determine reproduction steps
```

**WAIT FOR @analyst RESPONSE** - critical path for bug resolution

**Deliverables**:
- Impact assessment
- Affected components list
- Reproduction confirmation
- Initial root cause hypothesis

### Phase 2: Root Cause Investigation (30-45 minutes)

**Lead**: @developer  
**Support**: @tester  
**Objective**: Identify exact cause and fix approach

```bash
@developer Investigate the root cause:
1. Reproduce the bug locally
2. Debug to find exact failure point
3. Identify why the bug occurs
4. Assess related code that might be affected
5. Propose fix approach with alternatives
```

**Deliverables**:
- Root cause documentation
- Code analysis results
- Proposed fix approach
- Risk assessment

### Phase 3: Fix Implementation (30-60 minutes)

**Lead**: @developer  
**Objective**: Implement and test the fix

```bash
@developer Implement the fix:
1. Write the minimal fix for the issue
2. Add tests to prevent regression
3. Verify fix resolves the issue
4. Check for side effects
5. Update any affected documentation
```

**Deliverables**:
- Bug fix implementation
- Regression tests
- Side effect analysis
- Code review ready

### Phase 4: Verification & Testing (20-30 minutes)

**Lead**: @tester  
**Support**: @developer  
**Objective**: Ensure fix works without regression

```bash
@tester Verify the fix:
1. Confirm bug is resolved
2. Run regression test suite
3. Test edge cases around the fix
4. Verify no new issues introduced
5. Performance impact check
```

**Deliverables**:
- Test results
- Regression report
- Performance metrics
- Sign-off for deployment

### Phase 5: Post-Mortem (15-20 minutes) *[For Severity 1-2 bugs]*

**Lead**: @analyst  
**Support**: @developer, @tester  
**Objective**: Learn and prevent recurrence

```bash
@analyst Conduct post-mortem:
1. Document timeline of events
2. Identify why bug wasn't caught earlier
3. Propose prevention measures
4. Update testing strategies
5. Create action items
```

**Deliverables**:
- Post-mortem document
- Prevention recommendations
- Process improvements
- Action items

## Success Criteria

- [ ] Bug reproduced and understood
- [ ] Root cause identified
- [ ] Fix implemented and tested
- [ ] No regression introduced
- [ ] Tests added to prevent recurrence
- [ ] Documentation updated

## Severity Classifications

### Severity 1: Critical (Production Down)
- Immediate response required
- All hands on deck
- Hotfix deployment process
- Executive communication

### Severity 2: High (Major Feature Broken)
- Response within 2 hours
- Dedicated team assigned
- Standard deployment process
- Stakeholder updates

### Severity 3: Medium (Feature Degraded)
- Response within 24 hours
- Normal fix process
- Bundled with next release

### Severity 4: Low (Minor Issue)
- Scheduled fix
- Bundled with related work

## Quick Fix Protocol (30 minutes)

For simple, obvious bugs:
1. Developer identifies and fixes (15 min)
2. Tester verifies (10 min)
3. Deploy (5 min)

## Coordination Notes

- Update project-plan.md with bug status
- Communicate progress every 30 minutes for Sev 1-2
- Document learnings immediately
- Consider hotfix deployment needs

## Common Patterns

### Data Corruption Fix
- Include data repair scripts
- Audit affected records
- Implement data validation

### Performance Bug Fix
- Baseline metrics first
- Multiple fix approaches
- Load test verification

### Security Bug Fix
- Private fix development
- Security team review
- Coordinated disclosure

---

*Swift action saves user satisfaction. Begin with `/coord fix [bug-report.md]`*