# Mission: ARCHITECTURE 📐
## Create or Update System Architecture Documentation

**Mission Code**: ARCHITECTURE  
**Estimated Duration**: 2-3 hours  
**Complexity**: Medium  
**Squad Required**: Strategist, Architect, Developer, Documenter

## Quick Start

### Ready to Document Your Architecture? (2 minutes)

**Step 1**: Copy the vision template
```bash
cp templates/mission-inputs/vision.md ./architecture-vision.md
```

**Step 2**: Fill key sections
- **Technical Approach**: Your current or planned tech stack
- **Core Features**: What the system needs to support
- **Technical Principles**: Scalability, security, performance goals
- **Resource Requirements**: Infrastructure and team needs

**Step 3**: Execute mission
```bash
/coord architecture architecture-vision.md
```

**What You'll Get**: Complete `architecture.md` with system design, component diagrams, infrastructure plans, security measures, and scaling strategies.

## Mission Briefing

Transform your system design into comprehensive architecture documentation that serves as the technical blueprint for your project. This mission creates or updates a complete architecture.md document that captures system design, infrastructure decisions, data flow, security measures, and scaling strategies. Essential for onboarding new developers, securing investment, and maintaining system integrity.

## Required Inputs

1. **Existing Codebase or Design** (required) - Current implementation or planned architecture
2. **Requirements Document** (optional) - Product requirements, PRD, or vision document
3. **Infrastructure Details** (optional) - Deployment platforms, services, configurations
4. **Architecture Decisions** (optional) - Previous design decisions and rationale

## Mission Phases

### Phase 1: Requirements Analysis (30 minutes) - IMMEDIATE ACTION

**Lead**: @strategist  
**Support**: @architect  
**Objective**: Understand system requirements and architectural needs

**COORDINATOR PROTOCOL**:
1. **UPDATE project-plan.md** with Phase 1 tasks:
   ```markdown
   ## Mission: ARCHITECTURE Documentation
   
   ### Phase 1: Requirements Analysis (In Progress)
   - [ ] Analyze existing system or requirements (assigned to @strategist)
   - [ ] Identify key architectural characteristics (assigned to @strategist)
   - [ ] Define system boundaries and scope (assigned to @strategist)
   - [ ] Determine stakeholder concerns (assigned to @strategist)
   - [ ] List non-functional requirements (assigned to @strategist)
   ```

2. **IMMEDIATELY CALL @strategist** - do not plan or wait

```bash
@strategist Analyze the system requirements and:
1. Identify key architectural characteristics (scalability, security, performance)
2. Define system boundaries and external interfaces
3. List functional and non-functional requirements
4. Determine primary stakeholder concerns
5. Document architectural constraints and assumptions
```

3. **WAIT FOR @strategist RESPONSE**
4. **UPDATE project-plan.md** mark completed tasks [x] and add Phase 2 tasks
5. **LOG TO progress.md** any issues encountered during this phase

**Deliverables**:
- System requirements summary
- Architectural characteristics matrix
- Stakeholder concerns documented

### Phase 2: System Design (45-60 minutes) - IMMEDIATE ACTION

**Lead**: @architect  
**Support**: @developer  
**Objective**: Design comprehensive system architecture

**COORDINATOR ACTION**: After @strategist completes, immediately call @architect

```bash
@architect Based on the requirements analysis:

**EXTENDED THINKING**: Use ULTRATHINK for this critical system design decision

1. Design high-level system architecture with component diagram
2. Define infrastructure architecture and deployment strategy
3. Design data architecture and database schema
4. Specify integration patterns and external services
5. Define security architecture and measures
6. Create scaling strategy and performance targets
7. Document key architectural decisions and trade-offs

Prompt: "Ultrathink about our system architecture. This is a foundational decision affecting the entire project. Evaluate all alternatives comprehensively considering scalability, maintainability, security, and team capabilities."
```

**WAIT FOR @architect RESPONSE** before proceeding to Phase 3

**Deliverables**:
- System architecture diagrams
- Infrastructure design
- Data model specifications
- Integration architecture
- Security measures
- Scaling strategy

### Phase 3: Technical Validation (30-45 minutes)

**Lead**: @developer  
**Support**: @architect  
**Objective**: Validate architecture against implementation realities

```bash
@developer Review the proposed architecture and:
1. Validate technical feasibility of the design
2. Identify implementation challenges or risks
3. Verify technology stack compatibility
4. Check for missing components or services
5. Estimate development complexity for each component
6. Suggest optimizations or alternatives where needed
```

**Deliverables**:
- Feasibility assessment
- Risk identification
- Technology validation
- Implementation considerations

### Phase 4: Documentation Generation (30-45 minutes)

**Lead**: @documenter  
**Support**: @architect  
**Objective**: Create comprehensive architecture documentation

```bash
@documenter Using the architecture-template.md and all gathered information:
1. Generate complete architecture.md document
2. Create all necessary diagrams (ASCII or descriptions)
3. Document all architectural decisions with rationale
4. Include development and deployment guidelines
5. Add monitoring and operations sections
6. Ensure all sections are complete and consistent
7. Add glossary and references
```

**Deliverables**:
- Complete architecture.md document
- All supporting diagrams
- Decision log
- Operations guide

### Phase 5: Final Review (15-30 minutes)

**Lead**: @architect  
**Support**: @developer, @strategist  
**Objective**: Ensure documentation accuracy and completeness

```bash
@architect Perform final review:
1. Verify technical accuracy of all sections
2. Ensure consistency across the document
3. Validate that all requirements are addressed
4. Check that diagrams match descriptions
5. Confirm architectural decisions are justified
6. Approve for team use
```

**Deliverables**:
- Reviewed and approved architecture.md
- List of future considerations
- Recommendations for updates

## Success Criteria

- [ ] Complete architecture.md document created/updated
- [ ] All major system components documented
- [ ] Infrastructure and deployment strategy defined
- [ ] Data architecture and flow documented
- [ ] Security measures and compliance addressed
- [ ] Scaling strategy and performance targets set
- [ ] Key architectural decisions captured with rationale
- [ ] Document reviewed and approved by technical team

## Common Variations

### Greenfield Project
- More emphasis on technology selection
- Greater focus on architectural patterns
- More time in design phase
- Include proof-of-concept validation

### Legacy System Documentation
- Focus on current state documentation
- Include technical debt assessment
- Document migration strategies
- Emphasize incremental improvement paths

### Microservices Architecture
- Service boundaries definition
- Inter-service communication patterns
- Distributed system considerations
- Service mesh and orchestration details

## Special Considerations

### Stakeholder Communication
- Use appropriate level of technical detail for audience
- Include executive summary for non-technical stakeholders
- Provide clear diagrams and visualizations
- Document business value of architectural choices

### Living Documentation
- Architecture should be versioned
- Include change log for major updates
- Plan for regular review cycles
- Keep synchronized with implementation

### Compliance Requirements
- Address relevant compliance standards early
- Document data residency requirements
- Include security and privacy considerations
- Plan for audit requirements

## Coordination Notes

- Use architecture-template.md from templates directory
- Ensure all phases build on previous findings
- Document assumptions and constraints clearly
- Keep focus on practical, implementable architecture
- Balance ideal design with pragmatic constraints

## Common Patterns

### Technology Stack Selection
- Evaluate against requirements
- Consider team expertise
- Factor in licensing costs
- Plan for long-term support

### Integration Challenges
- Document all external dependencies
- Plan for service failures
- Include retry and fallback strategies
- Consider rate limiting and quotas

### Performance Bottlenecks
- Identify potential bottlenecks early
- Document performance requirements
- Plan for monitoring and profiling
- Include optimization strategies

---

*Transform your system design into a living blueprint that guides development, ensures quality, and accelerates onboarding. Your architecture documentation becomes the single source of truth for technical decisions.*

*Begin with `/coord architecture [requirements]`*