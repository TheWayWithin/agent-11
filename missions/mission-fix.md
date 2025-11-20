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

**COORDINATOR PROTOCOL**:
1. **UPDATE project-plan.md** with emergency fix tasks:
   ```markdown
   ## Mission: FIX [Bug Description]
   
   ### Phase 1: Triage & Analysis (URGENT - In Progress)
   - [ ] Assess severity and user impact (assigned to @analyst)
   - [ ] Identify affected components (assigned to @analyst)
   - [ ] Review recent changes that might be related (assigned to @analyst)
   - [ ] Analyze error logs and stack traces (assigned to @analyst)
   - [ ] Determine reproduction steps (assigned to @analyst)
   ```

2. **IMMEDIATELY CALL @analyst** - this is emergency response

```bash
@analyst Analyze the bug report:
1. Assess severity and user impact
2. Identify affected components
3. Review recent changes that might be related
4. Analyze error logs and stack traces
5. Determine reproduction steps
```

3. **WAIT FOR @analyst RESPONSE** - critical path for bug resolution
4. **UPDATE project-plan.md** with analysis results and Phase 2 tasks
5. **LOG TO progress.md** issue discovery with symptom, context, and initial hypothesis
6. **CRITICAL**: Start issue entry in progress.md - will add ALL fix attempts as mission progresses

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
1. Document complete timeline of events including ALL fix attempts
2. Review all attempted solutions from progress.md (successes AND failures)
3. Identify why bug wasn't caught earlier
4. Analyze why each failed attempt didn't work
5. Determine root cause and why it was the underlying issue
6. Propose prevention measures based on attempt history
7. Update testing strategies
8. Create action items
```

**COORDINATOR**: Ensure progress.md is updated with:
- Complete resolution section with root cause analysis
- "Why Previous Attempts Failed" analysis
- Prevention strategy to avoid similar issues
- Lessons learned from all attempts

**Deliverables**:
- Post-mortem document leveraging progress.md issue history
- Root cause analysis explaining why earlier attempts failed
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

**File Operations** (Sprint 2 Architecture - Production Ready):
- Coordinator automatically parses and executes structured JSON output from specialists
- File operations now have ~99.9% reliability with zero manual verification required
- Specialists provide `file_operations` array → Coordinator executes Write/Edit tools automatically
- See migration guide: `project/field-manual/migration-guides/file-persistence-v2.md`
- See examples: `project/examples/file-operations/` (single, multiple, edit, mixed patterns)

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

## Post-Mission Cleanup Decision

After completing this mission, decide on cleanup approach based on project status:

### ✅ Milestone Transition (Every 2-4 weeks)
**When**: This mission completes a major project milestone, but more work remains.

**Actions** (30-60 min):
1. Extract lessons to `lessons/[category]/` from progress.md
2. Archive current handoff-notes.md to `archives/handoffs/milestone-X/`
3. Clean agent-context.md (retain essentials, archive historical details)
4. Create fresh handoff-notes.md for next milestone
5. Update project-plan.md with next milestone tasks

**See**: `templates/cleanup-checklist.md` Section A for detailed steps

### 🎯 Project Completion (Mission accomplished!)
**When**: All project objectives achieved, ready for new mission.

**Actions** (1-2 hours):
1. Extract ALL lessons from entire progress.md to `lessons/`
2. Create mission archive in `archives/missions/mission-[name]-YYYY-MM-DD/`
3. Update CLAUDE.md with system-level learnings
4. Archive all tracking files (project-plan.md, progress.md, etc.)
5. Prepare fresh start for next mission

**See**: `templates/cleanup-checklist.md` Section B for detailed steps

### 🔄 Continue Active Work (No cleanup needed)
**When**: Mission complete but continuing active development in same phase.

**Actions**: Update progress.md and project-plan.md, continue working.

---

**Reference**: See `project/field-manual/project-lifecycle-guide.md` for complete lifecycle management procedures.

---

*Swift action saves user satisfaction. Begin with `/coord fix [bug-report.md]`*