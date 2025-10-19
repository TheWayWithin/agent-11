# Mission: BUILD 🏗️
## Build New Service/Feature from Requirements

**Mission Code**: BUILD  
**Estimated Duration**: 4-8 hours  
**Complexity**: Medium to High  
**Squad Required**: Full team engagement

## Quick Start

### Ready to Build Features? (3 minutes)

**Step 1**: Copy the requirements template
```bash
cp templates/mission-inputs/requirements.md ./build-requirements.md
```

**Step 2**: Complete these critical sections
- **Core Features & User Stories**: Specific acceptance criteria
- **Technical Requirements**: Performance, security, integration needs
- **Business Rules**: Logic constraints and validation rules
- **Success Metrics**: How you'll measure success
- **Quality Standards**: Testing and documentation requirements

**Step 3**: Execute mission
```bash
/coord build build-requirements.md
```

**What You'll Get**: Production-ready code with full testing, documentation, and deployment configuration.

**Example Requirements Format**:
```markdown
### User Story: User Authentication
- **As a** new user
- **I want** to create an account with email/password
- **So that** I can access personalized features

**Acceptance Criteria:**
- [ ] User can register with valid email and password (8+ chars)
- [ ] System sends email verification before activation
- [ ] User can login with verified credentials
- [ ] Failed login attempts are rate-limited (5 attempts/hour)
```

## Mission Briefing

Transform product requirements into production-ready implementation. This mission takes you from concept through deployment-ready code with full testing and documentation.

## Required Inputs

1. **PRD/Requirements** (required) - Product requirements document
2. **Architecture Guidelines** (optional) - Technical constraints or patterns
3. **Design System** (optional) - UI/UX guidelines or mockups

## Mission Phases

### Phase 1: Strategic Analysis (30-45 minutes) - IMMEDIATE ACTION

**Lead**: @strategist  
**Objective**: Transform requirements into actionable user stories

**COORDINATOR PROTOCOL**:
1. **UPDATE project-plan.md** with Phase 1 tasks:
   ```markdown
   ## Mission: BUILD [Feature Name]
   
   ### Phase 1: Strategic Analysis (In Progress)
   - [ ] Create detailed user stories in INVEST format (assigned to @strategist)
   - [ ] Define clear acceptance criteria (assigned to @strategist)
   - [ ] Identify edge cases and error states (assigned to @strategist)
   - [ ] Prioritize features for MVP vs future iterations (assigned to @strategist)
   - [ ] Define success metrics and KPIs (assigned to @strategist)
   ```

2. **IMMEDIATELY CALL @strategist** - do not plan or wait

```bash
@strategist Review the provided requirements and:
1. Create detailed user stories in INVEST format
2. Define clear acceptance criteria for each story
3. Identify edge cases and error states
4. Prioritize features for MVP vs future iterations
5. Define success metrics and KPIs
```

3. **WAIT FOR @strategist RESPONSE** 
4. **UPDATE project-plan.md** mark completed tasks [x] and add Phase 2 tasks
5. **LOG TO progress.md** deliverables created and any issues (with ALL fix attempts if applicable)

**Deliverables**:
- User stories with acceptance criteria
- Feature prioritization matrix
- Success metrics defined

### Phase 2: Technical Architecture (30-45 minutes) - IMMEDIATE ACTION

**Lead**: @architect  
**Support**: @developer  
**Objective**: Design robust technical foundation

**COORDINATOR ACTION**: After @strategist completes, immediately call @architect

```bash
@architect Based on the requirements and user stories:
1. Define system architecture and component design
2. Select appropriate technology stack
3. Design data models and API contracts
4. Identify integration points
5. Document architectural decisions and trade-offs
```

**WAIT FOR @architect RESPONSE** before proceeding to Phase 3

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
- Frequent progress.md updates (after each deliverable and fix attempt - including failures)

## Mission Debrief Protocol

Upon completion:
1. Update progress.md with comprehensive learnings and root cause analyses
2. Document ALL fix attempts (including failed ones) with rationale and outcomes
3. Add prevention strategies for all issues encountered
4. Note time variations from estimates
5. Capture reusable patterns and improvement suggestions
6. Ensure issue history includes complete attempt logs for future reference

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

*Mission SUCCESS depends on clear requirements and systematic execution. Begin with `/coord build [requirements.md]`*