# Mission: RELEASE 🎯
## Version Release Management and Coordination

**Mission Code**: RELEASE  
**Estimated Duration**: 2-4 hours  
**Complexity**: Medium  
**Squad Required**: Coordinator, Developer, Operator, Marketer

## Mission Briefing

Orchestrate a complete product release from code freeze through user communication, ensuring quality delivery with proper versioning, documentation, and stakeholder coordination. Transform development work into user value.

## Required Inputs

1. **Release Scope** (required) - Features, fixes, and changes to include
2. **Release Timeline** (required) - Target dates and milestone schedule  
3. **Release Notes** (optional) - Prepared user-facing documentation

## Mission Phases

### Phase 1: Release Planning and Preparation (45-60 minutes)
**Lead**: @coordinator  
**Support**: @developer, @operator  
**Objective**: Plan release scope, timeline, and coordinate team activities

**Tasks**:
- Finalize release scope and feature list
- Create release timeline and milestone schedule
- Coordinate code freeze and branch creation
- Plan testing and validation activities
- Assign responsibilities and communication roles

**Success Criteria**:
- Release scope documented and approved
- Timeline established with clear milestones
- Team responsibilities assigned
- Code freeze initiated

### Phase 2: Quality Assurance and Testing (60-90 minutes)
**Lead**: @tester  
**Support**: @developer  
**Objective**: Ensure release quality through comprehensive testing

**Tasks**:
- Execute full regression testing suite
- Perform user acceptance testing scenarios
- Test deployment and rollback procedures
- Validate performance and security requirements
- Sign off on release quality standards

**Success Criteria**:
- All tests passing with acceptable results
- Performance benchmarks met
- Security validation completed
- Quality gates satisfied

### Phase 3: Release Build and Deployment Preparation (30-45 minutes)
**Lead**: @operator  
**Support**: @developer  
**Objective**: Prepare production-ready release artifacts

**Tasks**:
- Create release build with proper versioning
- Prepare deployment configurations and scripts
- Stage release artifacts in deployment pipeline
- Validate build integrity and signatures
- Prepare rollback procedures and artifacts

**Success Criteria**:
- Release build created successfully
- Deployment scripts validated
- Artifacts staged and verified
- Rollback procedures ready

### Phase 4: Documentation and Communication (45-75 minutes)
**Lead**: @documenter  
**Support**: @marketer, @coordinator  
**Objective**: Prepare user-facing documentation and communication

**Tasks**:
- Create comprehensive release notes
- Update user documentation and help guides
- Prepare marketing and communication materials
- Coordinate with customer support for common questions
- Plan user notification and announcement strategy

**Success Criteria**:
- Release notes complete and accurate
- Documentation updated
- Communication materials ready
- Support team briefed

### Phase 5: Release Execution and Monitoring (30-60 minutes)
**Lead**: @operator  
**Support**: @coordinator, @developer  
**Objective**: Execute release deployment with monitoring

**Tasks**:
- Execute production deployment process
- Monitor system health and performance metrics
- Validate release functionality in production
- Coordinate user communications and announcements
- Track early user feedback and issues

**Success Criteria**:
- Deployment successful with no critical issues
- System performance within acceptable range
- User communications sent
- Monitoring systems active

### Phase 6: Post-Release Activities (30-45 minutes)
**Lead**: @coordinator  
**Support**: @marketer, @support  
**Objective**: Complete release activities and gather feedback

**Tasks**:
- Monitor user adoption and feedback
- Track support tickets and user issues
- Coordinate marketing and announcement activities
- Document release outcomes and lessons learned
- Plan follow-up activities and hotfixes if needed

**Success Criteria**:
- User feedback collected and analyzed
- Support load within expected range
- Marketing activities executed
- Release retrospective completed

## Release Types

### Major Release
- **Scope**: New features, breaking changes, architecture updates
- **Timeline**: 2-6 months development, 1-2 weeks release process
- **Testing**: Comprehensive testing, beta programs, staged rollout
- **Communication**: Advance notice, migration guides, training

### Minor Release  
- **Scope**: New features, enhancements, non-breaking changes
- **Timeline**: 2-8 weeks development, 3-7 days release process
- **Testing**: Feature testing, regression testing, limited beta
- **Communication**: Release notes, feature announcements

### Patch Release
- **Scope**: Bug fixes, security updates, minor improvements
- **Timeline**: Days to weeks development, same-day release
- **Testing**: Focused testing, automated validation
- **Communication**: Brief release notes, security advisories

### Hotfix Release
- **Scope**: Critical bug fixes, security patches, urgent issues
- **Timeline**: Hours to days development, immediate release
- **Testing**: Minimal testing, focused validation
- **Communication**: Immediate notification, incident reports

## Release Management Best Practices

### Version Control
- **Semantic Versioning**: MAJOR.MINOR.PATCH format
- **Branch Strategy**: GitFlow, feature branches, release branches
- **Tag Management**: Consistent tagging, signed tags, release artifacts
- **Changelog**: Automated or manual change documentation

### Quality Gates
- **Code Review**: All changes reviewed and approved
- **Automated Testing**: CI/CD pipeline validation
- **Security Scanning**: Vulnerability and compliance checks
- **Performance Testing**: Load and stress testing validation

### Risk Management
- **Feature Flags**: Gradual rollout, A/B testing capability
- **Blue-Green Deployment**: Zero-downtime deployment strategy
- **Rollback Planning**: Quick rollback procedures and triggers
- **Monitoring**: Real-time health and performance monitoring

### Communication Strategy
- **Internal Communication**: Team coordination, status updates
- **External Communication**: User announcements, release notes
- **Support Preparation**: FAQ updates, issue resolution guides
- **Marketing Coordination**: Feature promotion, user education

## Release Communication Templates

### Internal Release Announcement
```
🎉 [Product] v[Version] Released Successfully!

Release Highlights:
- [Feature 1]: [Brief description]
- [Feature 2]: [Brief description]  
- [Bug fixes]: [Number] issues resolved

Metrics:
- Deployment time: [X] minutes
- Test pass rate: [X]%
- Performance impact: [X]%

Next Steps:
- Monitor user feedback and adoption
- Support team ready for user questions
- Marketing campaign launches [Date]
```

### User Release Announcement
```
🚀 New [Product] Release: [Version Name]

What's New:
- [User-facing feature 1]
- [User-facing feature 2]
- [Performance improvements]

Getting Started:
- [Link to documentation]
- [Migration guide if needed]
- [New feature tutorials]

Questions? Contact support or check our updated FAQ.
```

## Success Metrics

### Technical Metrics
- **Deployment Success**: 100% successful deployment
- **Rollback Rate**: <1% of releases require rollback
- **Bug Escape Rate**: <5 critical bugs per release
- **Performance Impact**: <5% performance degradation

### User Metrics
- **Adoption Rate**: Feature usage within target timeframe
- **User Satisfaction**: Positive feedback on new features
- **Support Load**: Support tickets within normal range
- **Retention**: User retention post-release

### Process Metrics
- **Release Frequency**: Consistent release cadence
- **Lead Time**: Development to release time
- **Team Efficiency**: Resource utilization and coordination
- **Documentation Quality**: Complete and accurate documentation

## Tools and Automation

### Release Management
- **Git**: Version control, branching, tagging
- **GitHub/GitLab**: Pull requests, release notes, automation
- **Jira**: Issue tracking, release planning
- **Confluence**: Documentation, release coordination

### CI/CD and Deployment
- **Jenkins/GitHub Actions**: Build automation, testing
- **Docker**: Containerization, artifact management  
- **Kubernetes**: Orchestration, rolling deployments
- **Terraform**: Infrastructure as code

### Monitoring and Analytics
- **DataDog/New Relic**: Application performance monitoring
- **Google Analytics**: User behavior and adoption
- **Sentry**: Error tracking and alerting
- **Custom Dashboards**: Release-specific metrics

### Communication
- **Slack**: Team coordination, automated notifications
- **Email**: User announcements, release notes
- **Documentation Sites**: User guides, API docs
- **Social Media**: Marketing, community engagement

## Risk Mitigation

### Pre-Release Risks
- **Incomplete Features**: Feature flags, phased rollout
- **Quality Issues**: Comprehensive testing, quality gates
- **Timeline Delays**: Buffer time, scope management
- **Team Coordination**: Clear roles, communication plans

### Post-Release Risks
- **Performance Issues**: Monitoring, quick rollback
- **User Confusion**: Clear documentation, support preparation
- **Security Vulnerabilities**: Security scanning, patch procedures
- **Adoption Problems**: User education, feedback collection

## Integration Points

- **Follows**: BUILD, TEST, DEPLOY missions
- **Enables**: User value delivery, business growth
- **Coordinates with**: Marketing, support, business stakeholders
- **Requires**: Quality code, documentation, communication plan

---

**Mission Command**: `/coord release [release-scope] [release-timeline] [release-notes]`

*"A release is not just code deployment; it's the delivery of user value."*

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