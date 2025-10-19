# Operation: GENESIS
## New Feature Development Mission

**Objective**: Build a complete feature from concept to production  
**Duration**: 1-3 days depending on complexity  
**Squad Required**: Full team engagement

## Mission Phases

### Phase 1: Intelligence Gathering (30-60 minutes)

**Lead Agent**: @strategist

```bash
@strategist I need to add [FEATURE DESCRIPTION] to our application. Please:
1. Create detailed user stories with INVEST criteria
2. Define acceptance criteria for each story  
3. Identify edge cases and error states
4. Suggest MVP scope vs future enhancements
5. Define success metrics we should track
```

**Expected Output**:
- Complete PRD with user stories
- Prioritized feature list
- Success metrics defined
- Clear acceptance criteria

### Phase 2: Technical Reconnaissance (30 minutes)

**Lead Agent**: @architect  
**Support**: @developer

```bash
@architect @developer Review the requirements from strategist above. Please:
1. Assess technical feasibility
2. Identify architectural changes needed
3. Estimate implementation complexity
4. Flag any technical risks
5. Suggest technology choices
```

**Expected Output**:
- Technical approach document
- Risk assessment
- Time estimates
- Architecture decisions

### Phase 3: Visual Planning (1-2 hours)

**Lead Agent**: @designer  
**Support**: @strategist

```bash
@designer Based on the requirements and technical constraints above:
1. Create user flow diagrams
2. Design UI mockups for all states
3. Ensure mobile responsiveness
4. Follow our design system
5. Consider loading and error states
```

**Expected Output**:
- User flow diagrams
- UI mockups
- Component specifications
- Interaction patterns

### Phase 4: Implementation (4-8 hours)

**Lead Agent**: @developer  
**Support**: @architect

```bash
@developer Implement the feature based on all specifications above:
1. Set up necessary backend endpoints
2. Create frontend components
3. Integrate with existing systems
4. Write unit tests for critical paths
5. Handle all edge cases identified
```

**Expected Output**:
- Working code implementation
- Unit tests
- API endpoints
- Database migrations

### Phase 5: Quality Assurance (2-3 hours)

**Lead Agent**: @tester  
**Support**: @developer

```bash
@tester Thoroughly test the implementation:
1. Verify all acceptance criteria are met
2. Test edge cases and error scenarios
3. Check responsive design
4. Validate performance
5. Security testing basics
```

**Expected Output**:
- Test results report
- Bug reports (if any)
- Performance metrics
- QA sign-off

### Phase 6: Documentation (1 hour)

**Lead Agent**: @documenter  
**Parallel**: Can run alongside testing

```bash
@documenter Create comprehensive documentation:
1. User guide for the new feature
2. API documentation if applicable
3. Update existing docs
4. Create FAQ entries
5. Add to changelog
```

**Expected Output**:
- User documentation
- Technical documentation
- Updated changelog
- FAQ entries

### Phase 7: Deployment Preparation (30 minutes)

**Lead Agent**: @operator  
**Support**: @developer

```bash
@operator Prepare for deployment:
1. Review the changes
2. Set up deployment pipeline
3. Configure monitoring
4. Plan rollback strategy
5. Schedule deployment window
```

**Expected Output**:
- Deployment checklist
- Monitoring configured
- Rollback plan
- Deployment scheduled

### Phase 8: Launch Operations (1-2 hours)

**Lead Agents**: @operator, @marketer  

```bash
# Deployment
@operator Execute deployment to production with monitoring

# Marketing
@marketer Create launch content:
1. Blog post announcing feature
2. Email to existing users
3. Social media posts
4. Update landing page
```

**Expected Output**:
- Feature live in production
- Launch content published
- Users notified
- Monitoring active

### Phase 9: Post-Launch Analysis (Ongoing)

**Lead Agents**: @analyst, @support

```bash
# Day 1
@support Monitor for user issues and feedback

# Day 3
@analyst Analyze early usage metrics and user behavior

# Week 1
@strategist @analyst Review success metrics and plan iterations
```

## Success Criteria

- [ ] All acceptance criteria met
- [ ] Tests passing with >80% coverage
- [ ] Documentation complete
- [ ] Successfully deployed
- [ ] No critical bugs in first 24 hours
- [ ] Success metrics tracking properly

## Abort Conditions

- Technical blocker that significantly increases scope
- Security vulnerability discovered
- Business priority change
- Resource constraints

## Lessons Learned Template

After mission completion, document:

1. What went well?
2. What could be improved?
3. Time estimates vs actual
4. Unexpected challenges
5. Reusable patterns discovered

## Quick Reference Card

```bash
# Rapid Feature Development (2-hour sprint)
@strategist Quick user story for [feature]
@developer Implement based on above requirements  
@tester Quick validation of implementation
@operator Deploy to staging for review

# Full Feature Cycle (1-2 days)
Follow all phases above in sequence

# Parallel Processing (Maximum speed)
@strategist @designer Work on specs and designs simultaneously
@developer Start on backend while designer finalizes UI
@documenter Begin docs while developer codes
```

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

*"In war, the way is to avoid what is strong and strike at what is weak." - Sun Tzu*

*In AGENT-11, we parallelize what we can and sequence what we must.*