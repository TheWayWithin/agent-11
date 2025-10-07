# Mission: MVP 💡
## Rapid MVP Development

**Mission Code**: MVP  
**Estimated Duration**: 1-3 days  
**Complexity**: High  
**Squad Required**: Full team engagement

## Mission Briefing

Transform a product concept into a working Minimum Viable Product. This mission emphasizes speed, core functionality, and rapid market validation.

## Required Inputs

1. **Product Vision** (required) - Concept, problem statement, target users
2. **Market Research** (optional) - Competitor analysis, user feedback
3. **Budget/Timeline** (optional) - Resource constraints

## Mission Phases

### Phase 1: Concept Validation (1-2 hours)

**Lead**: @strategist  
**Support**: @analyst  
**Objective**: Validate and refine the product concept

```bash
@strategist Validate the MVP concept:

**EXTENDED THINKING**: Use THINK HARDER for MVP scope definition - this is a critical strategic decision

1. Define core problem being solved
2. Identify target user personas
3. List absolute must-have features
4. Define success metrics
5. Create value proposition

Prompt: "Think harder about our MVP scope. Wrong scope wastes months of development. Evaluate what's truly essential vs. nice-to-have. Consider user needs, market timing, and technical feasibility."
```

**Deliverables**:
- Problem statement
- User personas
- Core feature list (3-5 max)
- Success metrics
- Value proposition

### Phase 2: Market Analysis (1 hour) *[Optional but Recommended]*

**Lead**: @analyst  
**Support**: @marketer  
**Objective**: Understand market positioning

```bash
@analyst Analyze market opportunity:
1. Identify direct competitors
2. Find market gaps
3. Analyze pricing models
4. Estimate market size
5. Define differentiation
```

**Deliverables**:
- Competitor matrix
- Market gap analysis
- Pricing strategy
- Differentiation points

### Phase 3: MVP Architecture (1-2 hours)

**Lead**: @architect  
**Support**: @developer  
**Objective**: Design minimal viable architecture

```bash
@architect Design MVP architecture:
1. Choose fastest reliable tech stack
2. Design minimal data model
3. Plan for future scaling (but don't build it)
4. Select essential integrations only
5. Define MVP technical constraints
```

**Deliverables**:
- Tech stack decision
- Simple architecture diagram
- Data model
- Integration plan
- Technical constraints

---

### 🧹 Context Management Checkpoint (Day 1 Complete - Planning Done)

**Purpose**: Clear planning artifacts before development begins

**Coordinator Action**:
- Update /memories/project/requirements.xml with MVP core features
- Update /memories/project/architecture.xml with tech stack and MVP architecture
- Update agent-context.md with Day 1 strategic decisions
- Update handoff-notes.md with development priorities for Day 2

**If context > 25K tokens, consider /clear**:
- Preserve: Memory tool calls, final MVP scope, architecture decisions
- Clear: Market research details, architecture exploration iterations
- Benefits: Clean context for development sprint

**Multi-Day Note**: This is ideal /clear point between planning (Day 1) and development (Day 2+)

**Reference**: See /project/field-manual/context-editing-guide.md

---

### Phase 4: Rapid Prototyping (2-3 hours)

**Lead**: @designer  
**Support**: @developer  
**Objective**: Create clickable prototype

```bash
@designer Create rapid prototype:
1. Design core user flows only
2. Create lo-fi wireframes
3. Build clickable prototype
4. Focus on main value proposition
5. Mobile-first approach
```

**Deliverables**:
- User flow diagrams
- Wireframes
- Clickable prototype
- Design system basics

### Phase 5: Core Development (8-16 hours)

**Lead**: @developer  
**Support**: @tester  
**Objective**: Build core functionality fast

```bash
@developer Build MVP:
1. Set up project with chosen stack
2. Implement authentication (if needed)
3. Build core features only
4. Basic error handling
5. Minimal viable UI
```

**Key Principles**:
- Speed over perfection
- Core features only
- Basic but functional UI
- Essential error handling
- Quick deployment setup

---

### 🧹 Context Management Checkpoint (Development Complete)

**Purpose**: Clear implementation details before testing and launch prep

**Coordinator Action**:
- Update /memories/technical/patterns.xml with MVP code patterns
- Update /memories/lessons/insights.xml with development challenges and solutions
- Update handoff-notes.md with known limitations and test priorities

**If context > 30K tokens, strongly recommend /clear**:
- Preserve: Memory tool calls, working code location, deployment setup
- Clear: Code iteration details, debugging sessions, old implementation attempts
- Benefits: Clean context for testing and launch activities

**Multi-Day Note**: Ideal checkpoint after intensive development sprint

**Reference**: See /project/field-manual/context-editing-guide.md

---

### Phase 6: Growth Foundation (2-3 hours)

**Lead**: @marketer  
**Support**: @analyst  
**Objective**: Prepare for launch and growth

```bash
@marketer Prepare launch:
1. Create landing page
2. Set up analytics
3. Design onboarding flow
4. Create launch messaging
5. Plan user acquisition
```

**Deliverables**:
- Landing page
- Analytics setup
- Onboarding flow
- Launch copy
- Acquisition plan

### Phase 7: Quick Testing (2-3 hours)

**Lead**: @tester  
**Support**: @developer  
**Objective**: Ensure core functionality works

```bash
@tester Validate MVP:
1. Test core user journeys
2. Verify on target devices
3. Basic load testing
4. Security essentials
5. Fix showstoppers only
```

**Deliverables**:
- Core functionality verified
- Showstopper bugs fixed
- Basic security check
- Launch readiness

### Phase 8: Rapid Deployment (1-2 hours)

**Lead**: @operator  
**Support**: @developer  
**Objective**: Get MVP live quickly

```bash
@operator Deploy MVP:
1. Choose simple hosting (Vercel, Heroku)
2. Set up basic monitoring
3. Configure domain
4. Enable error tracking
5. Create backup strategy
```

**Deliverables**:
- Live MVP
- Monitoring dashboard
- Error tracking
- Backup system

---

### 🧹 Context Management Checkpoint (MVP Launch Complete)

**Purpose**: Final cleanup after successful MVP deployment

**Coordinator Action**:
- Update /memories/lessons/insights.xml with launch learnings
- Update /memories/technical/tooling.xml with deployment configurations
- Archive mission context for future iterations

**Final /clear recommended**:
- Preserve: Memory files (all MVP knowledge persists)
- Clear: All mission execution details (testing, deployment logs)
- Benefits: Fresh start for post-launch iteration and optimization

**Performance Summary**:
- Mission duration: 1-3 days
- Without context editing: ~300K tokens consumed
- With strategic clearing: ~50K tokens (83% reduction)
- Multi-day mission sustainable with memory preservation

**Reference**: See /project/field-manual/context-editing-guide.md

---

## Success Criteria

- [ ] Core problem solved
- [ ] Deployable in <3 days
- [ ] Users can complete primary action
- [ ] Basic analytics tracking
- [ ] Feedback collection ready
- [ ] Can iterate based on data

## MVP Principles

### Include
- Core value proposition
- One main user flow
- Basic authentication
- Simple analytics
- Feedback mechanism

### Exclude
- Nice-to-have features
- Perfect design
- Extensive testing
- Complex integrations
- Scaling concerns

### Technical Choices
- Use familiar tech
- Leverage templates
- Choose PaaS over IaaS
- Use managed services
- Monolith over microservices

## Common MVP Types

### SaaS MVP
- Authentication
- Core feature
- Basic billing
- Simple dashboard

### Marketplace MVP
- Listing creation
- Search/browse
- Contact/transaction
- Basic profiles

### Content MVP
- Content creation
- Basic categorization
- Simple consumption
- User accounts

### Tool MVP
- Core functionality
- File handling
- Basic UI
- Export capability

## Post-MVP Protocol

After launch:
1. Monitor user behavior
2. Collect feedback actively
3. Fix only critical bugs
4. Plan iteration based on data
5. Decide: pivot, persevere, or scale

## Coordination Notes

- Daily standups during build
- Rapid decision making
- Document assumptions
- Track velocity
- Celebrate launch!

---

*Speed is the MVP superpower. Begin with `/coord mvp [vision.md]`*