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
**Support**: @operator
**Objective**: Ensure deployment readiness through comprehensive validation

**@tester Actions**:
1. **Execute Complete Test Suite** (Bash)
   ```bash
   # Run all tests
   npm test                    # Unit + integration tests
   npx playwright test         # E2E tests
   npm run test:coverage       # Check coverage
   ```
   - Verify 100% test pass rate
   - Confirm coverage meets standards (>80% critical paths)
   - Check for flaky tests (rerun to confirm stability)

2. **Validate Build Process** (Bash)
   ```bash
   npm run build              # Production build
   npm run lint               # Code quality checks
   npm run type-check         # TypeScript validation
   ```
   - Confirm build completes without errors
   - Check bundle sizes are within limits
   - Validate no console warnings or errors

3. **Security & Configuration Validation** (Read + Bash)
   - **Environment Variables**:
     - ✅ All required env vars present (.env.production)
     - ✅ No test/dev secrets in production config
     - ✅ API keys and tokens valid and not expired
   - **Security Checklist**:
     - ✅ No sensitive data in build artifacts
     - ✅ Security headers configured (CSP, HSTS, etc.)
     - ✅ HTTPS enforced for all endpoints
     - ✅ Authentication and authorization working
   - **Database Migrations** (if applicable):
     - ✅ Migration scripts reviewed and tested
     - ✅ Rollback scripts prepared
     - ✅ Backup taken before migration

4. **Pre-Deployment Checklist Review** (Read)
   - ✅ Feature flags configured correctly
   - ✅ Third-party integrations validated
   - ✅ Monitoring and alerting configured
   - ✅ Rollback procedures documented
   - ✅ Team notified of deployment window

5. **Quality Gate Decision** (Document in progress.md)
   - **PASS**: All validations successful → Proceed to deployment planning
   - **BLOCK**: Critical issues found → Document blockers, fix before deployment

**Success Criteria**:
- ✅ All tests passing (100% pass rate)
- ✅ Build artifacts generated successfully
- ✅ Environment variables validated and secure
- ✅ Migration scripts validated (if applicable)
- ✅ Security checklist complete
- ✅ Quality gate: PASS (ready for deployment planning)

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

### Phase 3: Staging Deployment & Validation (15-25 minutes)
**Lead**: @operator
**Support**: @developer, @tester
**Objective**: Deploy to staging and validate production-like environment

**@operator Actions** (Deployment):
1. **Execute Staging Deployment**
   ```bash
   # Deploy to staging
   git push staging main        # Or platform-specific deployment
   # Wait for deployment completion
   # Monitor deployment logs for errors
   ```
   - Verify deployment completes successfully
   - Check all services start correctly
   - Validate deployment version matches expected

2. **Initial Health Checks**
   - ✅ Application responds to health check endpoint
   - ✅ Database connection established
   - ✅ External services reachable
   - ✅ Background jobs running

**@tester Actions** (Validation):
3. **Smoke Test Execution** (Bash + mcp__playwright)
   ```bash
   # Run smoke tests against staging
   ENVIRONMENT=staging npx playwright test tests/smoke/
   ```
   - **Critical User Flows**:
     - ✅ Homepage loads successfully
     - ✅ User login works correctly
     - ✅ Core feature functionality validated
     - ✅ Payment flow works (test mode)
     - ✅ Data displays correctly
   - **API Validation**:
     - ✅ All critical API endpoints respond
     - ✅ Authentication endpoints working
     - ✅ Data CRUD operations functional
   - **Integration Validation**:
     - ✅ Third-party services connected
     - ✅ Email sending works (test mode)
     - ✅ File uploads/downloads functional

4. **Performance & Error Monitoring** (mcp__playwright + Browser DevTools)
   - **Performance Checks**:
     - ✅ Page load times < 3 seconds
     - ✅ API response times < 1 second
     - ✅ Time to Interactive (TTI) < 5 seconds
     - ✅ No memory leaks during navigation
   - **Error Detection**:
     - ✅ No console errors or warnings
     - ✅ No network request failures
     - ✅ No JavaScript errors
     - ✅ Error tracking service receiving events

5. **Cross-Browser Validation** (mcp__playwright)
   - Test on Chrome, Firefox, Safari (if time permits)
   - Validate responsive design on mobile viewport
   - Check for browser-specific issues

6. **Staging Validation Report** (Document in progress.md)
   - **PASS**: All smoke tests green, performance acceptable → Proceed to production
   - **FAIL**: Critical issues found → Document blockers, fix before production

**Success Criteria**:
- ✅ Staging deployment successful
- ✅ All smoke tests passing (100%)
- ✅ Performance metrics within acceptable range (<3s load, <1s API)
- ✅ No critical errors detected
- ✅ Integrations validated and working
- ✅ Quality gate: PASS (ready for production deployment)

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