# Mission: BUILD 🏗️
## Build New Service/Feature from Requirements

**Mission Code**: BUILD  
**Estimated Duration**: 4-8 hours  
**Complexity**: Medium to High  
**Squad Required**: Full team engagement

## Mission Briefing

Transform product requirements into production-ready implementation. This mission takes you from concept through deployment-ready code with full testing and documentation.

## Required Inputs

1. **PRD/Requirements** (required) - Product requirements document
2. **Architecture Guidelines** (optional) - Technical constraints or patterns
3. **Design System** (optional) - UI/UX guidelines or mockups

## Mission Phases

### Phase 1: Strategic Analysis (30-45 minutes)

**Lead**: @strategist  
**Objective**: Transform requirements into actionable user stories

```bash
@strategist Review the provided requirements and:
1. Create detailed user stories in INVEST format
2. Define clear acceptance criteria for each story
3. Identify edge cases and error states
4. Prioritize features for MVP vs future iterations
5. Define success metrics and KPIs
```

**Deliverables**:
- User stories with acceptance criteria
- Feature prioritization matrix
- Success metrics defined

### Phase 2: Technical Architecture (30-45 minutes)

**Lead**: @architect  
**Support**: @developer  
**Objective**: Design robust technical foundation

```bash
@architect Based on the requirements and user stories:
1. Define system architecture and component design
2. Select appropriate technology stack
3. Design data models and API contracts
4. Identify integration points
5. Document architectural decisions and trade-offs
```

**Deliverables**:
- Architecture design document
- Technology decisions
- API specifications
- Data model designs

### Phase 3: Design & UX (1-2 hours) *[If UI Required]*

**Lead**: @designer  
**Support**: @strategist  
**Objective**: Create user-centered interface designs

```bash
@designer Create the user interface by:
1. Designing user flows and wireframes
2. Creating high-fidelity mockups
3. Defining interaction patterns
4. Ensuring accessibility compliance
5. Providing implementation guidelines
```

**Deliverables**:
- User flow diagrams
- UI mockups
- Design system components
- Implementation guide

### Phase 4: Implementation (2-4 hours)

**Lead**: @developer  
**Support**: @tester  
**Objective**: Build the feature with quality

```bash
@developer Implement the feature following:
1. Architecture design and patterns
2. User stories and acceptance criteria
3. Design specifications (if applicable)
4. Include comprehensive error handling
5. Write unit and integration tests
```

**Deliverables**:
- Working implementation
- Test coverage >80%
- Error handling
- Code documentation

### Phase 5: Quality Assurance (1 hour)

**Lead**: @tester  
**Support**: @developer  
**Objective**: Ensure production quality

```bash
@tester Validate the implementation:
1. Execute acceptance criteria tests
2. Perform edge case testing
3. Validate error handling
4. Check performance benchmarks
5. Security vulnerability scan
```

**Deliverables**:
- Test execution report
- Bug reports (if any)
- Performance metrics
- Security assessment

### Phase 6: Documentation (30-45 minutes)

**Lead**: @documenter  
**Support**: @developer  
**Objective**: Create comprehensive documentation

```bash
@documenter Document the feature:
1. API documentation
2. User guide
3. Integration guide
4. Configuration options
5. Troubleshooting guide
```

**Deliverables**:
- API documentation
- User documentation
- Integration guides
- README updates

### Phase 7: Deployment Preparation (30 minutes)

**Lead**: @operator  
**Support**: @developer  
**Objective**: Prepare for production deployment

```bash
@operator Prepare deployment:
1. Environment configuration
2. CI/CD pipeline setup
3. Monitoring and alerts
4. Rollback procedures
5. Deployment checklist
```

**Deliverables**:
- Deployment scripts
- Environment configs
- Monitoring setup
- Rollback plan

## Success Criteria

- [ ] All user stories implemented and tested
- [ ] Test coverage exceeds 80%
- [ ] Zero critical bugs
- [ ] Documentation complete
- [ ] Performance meets requirements
- [ ] Security scan passed
- [ ] Deployment ready

## Common Variations

### Quick Build (2-4 hours)
- Skip formal design phase
- Minimal documentation
- Focus on core functionality

### Enterprise Build (8-16 hours)
- Extended architecture phase
- Formal design review
- Comprehensive documentation
- Load testing included

### Prototype Build (1-2 hours)
- Proof of concept only
- Minimal testing
- Basic documentation

## Coordination Notes

- Maintain project-plan.md throughout mission
- Each phase requires explicit completion confirmation
- Blockers immediately escalated to coordinator
- Daily progress updates in progress.md

## Mission Debrief Protocol

Upon completion:
1. Update progress.md with learnings
2. Document any reusable patterns
3. Note time variations from estimates
4. Capture improvement suggestions

---

*Mission SUCCESS depends on clear requirements and systematic execution. Begin with `/coord build [requirements.md]`*