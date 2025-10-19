# Mission: DEPLOY 🚀
## Production Deployment Preparation and Execution

**Mission Code**: DEPLOY  
**Estimated Duration**: 1-2 hours  
**Complexity**: Medium  
**Squad Required**: Operator, Tester, Developer

## Mission Briefing

Execute a safe, systematic production deployment with proper validation, monitoring, and rollback procedures. This mission ensures your code reaches users reliably with minimal risk.

## Required Inputs

1. **Tested Codebase** (required) - Code that has passed all tests
2. **Deployment Configuration** (optional) - Environment configs, secrets
3. **Release Notes** (optional) - User-facing change documentation

## Mission Phases

### Phase 1: Pre-Deployment Validation (15-20 minutes)
**Lead**: @tester  
**Objective**: Ensure deployment readiness

**Tasks**:
- Run complete test suite and validate all tests pass
- Verify build process completes successfully
- Check environment configuration and secrets
- Validate database migrations (if applicable)
- Review deployment checklist

**Success Criteria**:
- All tests passing
- Build artifacts generated successfully
- Environment variables configured
- Migration scripts validated

### Phase 2: Deployment Planning (20-30 minutes)
**Lead**: @operator  
**Objective**: Plan deployment strategy and rollback procedures

**Tasks**:
- Review deployment target (staging → production)
- Plan deployment windows and user communication
- Prepare rollback procedures and scripts
- Set up monitoring and health checks
- Configure deployment pipeline

**Success Criteria**:
- Deployment strategy documented
- Rollback procedures ready
- Monitoring configured
- Pipeline ready for execution

### Phase 3: Staging Deployment (15-25 minutes)
**Lead**: @operator  
**Support**: @developer, @tester  
**Objective**: Deploy to staging for final validation

**Tasks**:
- Deploy to staging environment
- Run smoke tests on staging
- Validate all features working correctly
- Check performance and error rates
- Verify integrations and external services

**Success Criteria**:
- Staging deployment successful
- All smoke tests passing
- Performance metrics within acceptable range
- No critical errors detected

### Phase 4: Production Deployment (20-30 minutes)
**Lead**: @operator  
**Support**: @developer, @tester  
**Objective**: Execute production deployment

**Tasks**:
- Deploy to production environment
- Monitor deployment process and metrics
- Run immediate health checks
- Validate critical user flows
- Monitor error rates and performance

**Success Criteria**:
- Production deployment successful
- Health checks passing
- Critical flows working
- Error rates normal

### Phase 5: Post-Deployment Monitoring (10-15 minutes)
**Lead**: @operator  
**Support**: @analyst  
**Objective**: Ensure deployment stability

**Tasks**:
- Monitor application performance
- Track user error reports
- Validate monitoring and alerting
- Document deployment outcomes
- Communicate deployment success

**Success Criteria**:
- Performance metrics stable
- No increase in error rates
- Monitoring systems active
- Team notified of successful deployment

## Common Variations

### Hotfix Deployment
- **Duration**: 30-45 minutes
- **Focus**: Rapid deployment with minimal testing
- **Phases**: Skip staging, focus on critical path validation

### Blue-Green Deployment
- **Duration**: 2-3 hours
- **Focus**: Zero-downtime deployment with traffic switching
- **Phases**: Add traffic switching and gradual rollout

### Database Migration Deployment
- **Duration**: 2-4 hours
- **Focus**: Database changes with backward compatibility
- **Phases**: Add migration validation and rollback testing

### Microservice Deployment
- **Duration**: 1-3 hours
- **Focus**: Service-by-service deployment coordination
- **Phases**: Add service dependency validation

## Success Metrics

- **Deployment Success Rate**: 100% successful deployment
- **Downtime**: < 30 seconds (if any)
- **Rollback Time**: < 5 minutes if needed
- **Error Rate**: No increase post-deployment
- **Performance**: Response times within 10% of baseline

## Emergency Procedures

### Deployment Failure
1. **Immediate**: Stop deployment process
2. **Assess**: Determine failure cause and impact
3. **Rollback**: Execute rollback procedures if needed
4. **Communicate**: Notify team and stakeholders
5. **Post-Mortem**: Document failure and prevention

### Production Issues Post-Deployment
1. **Monitor**: Track error rates and performance
2. **Triage**: Determine if rollback is necessary
3. **Fix**: Apply hotfix if issue is minor
4. **Rollback**: Execute rollback if issue is critical
5. **Learn**: Document and improve procedures

## Integration Points

- **Follows**: BUILD, FIX, REFACTOR missions
- **Enables**: MONITOR, RELEASE missions
- **Coordinates with**: Team communication systems
- **Requires**: CI/CD pipeline and monitoring setup

---

**Mission Command**: `/coord deploy [tested-codebase] [deployment-config] [release-notes]`

*"Deployment is not the end, it's the beginning of your code's journey to users."*

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