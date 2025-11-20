# Mission Architecture Guide

**[← Back to Main README](../../README.md)**

---

## Overview

Missions are AGENT-11's orchestrated workflows that coordinate multiple specialist agents to accomplish complex, multi-phase tasks. Unlike single-agent invocations (`@developer fix bug`), missions (`/coord build requirements.md`) manage entire workflows from strategy through deployment.

**What You'll Learn**:
- How missions work internally
- When to use missions vs single agents
- Available mission types and their workflows
- How to create custom missions
- Mission orchestration patterns
- Troubleshooting mission execution

---

## What Is a Mission?

**Mission** = Pre-defined workflow that orchestrates specialist collaboration

**Key Characteristics**:
1. **Multi-Phase**: Breaking complex work into manageable stages
2. **Context-Preserved**: Agents pass findings through handoff-notes.md
3. **Coordinator-Led**: @coordinator manages delegation and verification
4. **File-Based Input**: Takes requirements documents as input (ideation.md, bug-report.md, etc.)
5. **Tracked**: Maintains project-plan.md (roadmap) and progress.md (changelog)

**Example Mission Flow**:
```
User: /coord build requirements/user-auth.md

Mission Workflow:
1. @coordinator reads requirements and creates execution plan
2. @strategist refines requirements into user stories
3. @architect designs system architecture (if needed)
4. @developer implements feature incrementally
5. @tester validates implementation
6. @documenter creates documentation
7. @coordinator updates tracking files
```

---

## When to Use Missions

### Use Missions When:
- **Multiple agents needed** - Task requires specialist collaboration
- **Defined process** - Clear workflow with phases (build, deploy, refactor)
- **Context critical** - Need to maintain state across multiple tasks
- **Repeatable pattern** - Workflow you'll use multiple times
- **Quality gates** - Each phase must complete before next begins

### Use Single Agents When:
- **Quick task** - Single action (fix typo, update config)
- **Specialist expertise** - One agent has all needed skills
- **Exploratory work** - Not sure what you need yet
- **Ad-hoc request** - One-time unusual task

**Example Decision Matrix**:

| Task | Approach | Reason |
|------|----------|--------|
| "Build user authentication" | `/coord build auth-requirements.md` | Multi-phase, needs architecture + code + tests |
| "Fix login button not clickable" | `@developer Fix login button bug` | Single issue, quick fix |
| "Deploy to production" | `/coord deploy` | Multi-step with verification gates |
| "Update README with new section" | `@documenter Add X to README` | Single agent task |
| "Refactor authentication service" | `/coord refactor auth-service.md` | Architecture changes + implementation + testing |
| "Analyze user engagement metrics" | `@analyst Review user metrics` | Single specialist analysis |

---

## Available Missions

### 1. MVP Development (`/coord mvp vision.md`)

**Purpose**: Build Minimum Viable Product from vision to launch

**Input**: Vision document with problem statement, target users, core features

**Workflow**:
1. **Strategic Planning** (@strategist) - Define MVP scope and priorities
2. **Architecture Design** (@architect) - System design and tech stack
3. **Development** (@developer) - Incremental feature implementation
4. **Quality Assurance** (@tester) - Comprehensive testing suite
5. **Deployment Prep** (@operator) - Infrastructure and deployment

**Duration**: 2-5 days for basic MVP

**Deliverables**:
- Working MVP with core features
- Test suite with passing tests
- Deployment-ready package
- User documentation
- architecture.md
- project-plan.md + progress.md

**When to Use**: Starting new product from scratch

---

### 2. Full Build (`/coord build requirements.md`)

**Purpose**: Develop complete feature from requirements through deployment

**Input**: Requirements document with feature specifications

**Workflow**:
1. **Requirements Analysis** (@strategist) - User stories and acceptance criteria
2. **Architecture Review** (@architect) - Design system integration
3. **UI/UX Design** (@designer) - Interface and user flow (if applicable)
4. **Implementation** (@developer) - Feature development
5. **Testing** (@tester) - Unit, integration, and E2E tests
6. **Documentation** (@documenter) - Technical and user docs
7. **Deployment** (@operator) - Production release
8. **Monitoring** (@analyst) - Metrics and performance tracking

**Duration**: 1-3 weeks depending on complexity

**Deliverables**:
- Complete feature implementation
- Comprehensive test coverage
- Documentation (technical + user-facing)
- Deployed to production
- Performance metrics baseline

**When to Use**: Building substantial new features

---

### 3. Quick Fix (`/coord fix bug-report.md`)

**Purpose**: Rapid bug resolution with root cause analysis

**Input**: Bug report with symptom description and reproduction steps

**Workflow**:
1. **Root Cause Analysis** (@developer or @analyst) - Identify why bug exists
2. **Fix Implementation** (@developer) - Resolve issue and add safeguards
3. **Testing** (@tester) - Verify fix and check for regressions
4. **Documentation** (@documenter) - Update progress.md with learnings
5. **Deployment** (@operator) - Hot-fix deployment (if needed)

**Duration**: 1-4 hours for most bugs

**Deliverables**:
- Bug fixed with prevention safeguards
- Regression tests added
- progress.md entry with root cause analysis

**When to Use**: Critical bugs or recurring issues needing thorough analysis

---

### 4. Feature Development (`/coord feature feature-spec.md`)

**Purpose**: Implement specific feature with full lifecycle

**Input**: Feature specification document

**Workflow**:
1. **Design** (@architect + @designer) - Technical and UI design
2. **Implementation** (@developer) - Feature coding
3. **Testing** (@tester) - Quality validation
4. **Integration** (@developer) - Merge into main codebase
5. **Documentation** (@documenter) - Feature documentation
6. **Release** (@operator) - Deploy and monitor

**Duration**: 1-3 days for focused features

**Deliverables**:
- Working feature integrated into product
- Tests with coverage report
- Feature documentation

**When to Use**: Well-defined features with clear scope

---

### 5. Refactor (`/coord refactor analysis.md`)

**Purpose**: Improve code quality without changing functionality

**Input**: Refactoring analysis or architectural improvement plan

**Workflow**:
1. **Architecture Analysis** (@architect) - Identify improvements and risks
2. **Refactoring Plan** (@strategist) - Define incremental steps
3. **Implementation** (@developer) - Execute refactoring in small, testable increments
4. **Validation** (@tester) - Ensure no functional regressions
5. **Documentation** (@documenter) - Update architecture.md

**Duration**: 1-5 days depending on scope

**Deliverables**:
- Improved code quality (measurable)
- All tests passing (no regressions)
- Updated architecture documentation

**When to Use**: Technical debt reduction, architecture improvements

---

### 6. Analytics Integration (`/coord analytics requirements.md`)

**Purpose**: Add comprehensive analytics and metrics tracking

**Input**: Analytics requirements (events to track, KPIs, dashboards)

**Workflow**:
1. **Metrics Design** (@analyst) - Define events, KPIs, and dashboards
2. **Implementation** (@developer) - Add tracking code
3. **Validation** (@tester) - Verify events firing correctly
4. **Dashboard Setup** (@analyst) - Create visualization and alerts

**Duration**: 1-2 days for standard analytics

**Deliverables**:
- Analytics instrumentation
- Dashboards and reports
- Alert configuration

**When to Use**: Adding metrics to product or feature

---

## Mission Anatomy

### Input Documents

Missions take structured input files:

**Common Input Types**:
- `ideation.md` - Product vision and requirements
- `requirements.md` - Feature specifications
- `bug-report.md` - Bug description and reproduction
- `vision.md` - MVP or product vision
- `analysis.md` - Refactoring or improvement analysis

**Input Document Structure** (Example):
```markdown
# User Authentication Feature

## Problem Statement
Users need secure way to access personalized features.

## Requirements
- Email/password registration
- Session management
- Password reset flow
- Multi-factor authentication (phase 2)

## Acceptance Criteria
- [ ] User can register with email/password
- [ ] User can login and stay logged in for 7 days
- [ ] User can reset password via email
- [ ] All auth endpoints secured with rate limiting

## Technical Constraints
- Must use existing Supabase database
- Support mobile and web clients
- GDPR compliant data handling
```

---

### Mission Phases

Most missions follow this phase structure:

**Phase 1: Planning**
- Coordinator reads input and creates execution plan
- Strategist refines requirements
- Architect designs solution (if needed)
- **Output**: project-plan.md with task list

**Phase 2: Implementation**
- Developer builds incrementally
- Tester validates each increment
- **Output**: Working code with tests

**Phase 3: Quality**
- Tester runs full test suite
- Designer reviews UX (if applicable)
- **Output**: Quality report

**Phase 4: Documentation**
- Documenter creates user and technical docs
- **Output**: Complete documentation

**Phase 5: Deployment**
- Operator prepares infrastructure
- Analyst sets up monitoring
- **Output**: Deployed feature with metrics

**Phase 6: Completion**
- Coordinator updates tracking files
- Final verification of deliverables
- **Output**: Updated project-plan.md and progress.md

---

### Context Preservation

Missions use three context files:

**1. agent-context.md** - Mission-wide accumulated knowledge
- Mission objectives
- Technical decisions
- Known issues and constraints
- Updated by coordinator after each agent task

**2. handoff-notes.md** - Agent-to-agent handoff
- Immediate task context
- Critical findings
- Specific instructions for next agent
- Updated by each agent before completion

**3. evidence-repository.md** - Artifacts and supporting materials
- Screenshots and test results
- Code snippets and API responses
- Error logs and debug output
- Updated by any agent producing evidence

**Context Flow**:
```
1. Agent reads agent-context.md + handoff-notes.md before task
2. Agent performs work with full context
3. Agent updates handoff-notes.md with findings
4. Coordinator merges findings into agent-context.md
5. Next agent has complete context
```

**Benefits**:
- 87.5% reduction in rework
- 37.5% faster completion
- Zero context loss between agents
- Complete audit trail

---

## Creating Custom Missions

### Mission Template Structure

```markdown
# Mission: [Name]

## Objective
[What this mission accomplishes]

## Input Requirements
- Document type: [requirements.md | vision.md | etc.]
- Required sections: [list sections]
- Optional context: [additional helpful info]

## Workflow

### Phase 1: [Name]
**Specialist**: @[agent]
**Task**: [What agent does]
**Deliverable**: [Expected output]
**Duration**: [Time estimate]

### Phase 2: [Name]
**Specialist**: @[agent]
**Task**: [What agent does]
**Dependencies**: [What must complete first]
**Deliverable**: [Expected output]

[... additional phases ...]

## Success Criteria
- [ ] [Measurable outcome 1]
- [ ] [Measurable outcome 2]
- [ ] [Measurable outcome 3]

## Deliverables
- [File or system produced]
- [Documentation created]
- [Deployment or release]
```

---

### Example Custom Mission: Landing Page Redesign

```markdown
# Mission: Landing Page Redesign

## Objective
Redesign landing page to improve conversion rate from 2% to 5%

## Input Requirements
- Document type: design-brief.md
- Required sections: Current metrics, Target audience, Conversion goals
- Optional context: Competitor analysis, User research

## Workflow

### Phase 1: Analysis
**Specialist**: @analyst
**Task**: Analyze current landing page performance and identify improvement opportunities
**Deliverable**: Metrics report with conversion funnel analysis
**Duration**: 2 hours

### Phase 2: Design
**Specialist**: @designer
**Task**: Create high-fidelity mockups for new landing page based on analysis
**Deliverable**: Figma mockups with mobile and desktop views
**Duration**: 1 day

### Phase 3: Content
**Specialist**: @marketer
**Task**: Write compelling copy optimized for conversion
**Deliverable**: Landing page copy with A/B test variants
**Duration**: 4 hours

### Phase 4: Implementation
**Specialist**: @developer
**Task**: Build responsive landing page from designs
**Dependencies**: Design mockups and copy finalized
**Deliverable**: Deployed landing page (staging)
**Duration**: 1 day

### Phase 5: Testing
**Specialist**: @tester
**Task**: Cross-browser and device testing, accessibility audit
**Deliverable**: Test report with issues resolved
**Duration**: 4 hours

### Phase 6: Deployment
**Specialist**: @operator
**Task**: Deploy to production with A/B test configuration
**Deliverable**: Live landing page with analytics tracking
**Duration**: 2 hours

### Phase 7: Monitoring
**Specialist**: @analyst
**Task**: Monitor conversion metrics for 7 days and provide report
**Deliverable**: Conversion analysis with recommendations
**Duration**: 1 week (passive monitoring)

## Success Criteria
- [ ] Conversion rate increases from 2% to 4%+ within 2 weeks
- [ ] Page load time < 2 seconds
- [ ] Accessibility score 95+ (Lighthouse)
- [ ] Zero critical bugs in production

## Deliverables
- New landing page design (Figma)
- Landing page implementation (deployed)
- A/B test configuration
- Conversion tracking dashboard
- Performance report after 2 weeks
```

---

### Custom Mission Best Practices

1. **Clear Objectives**: Define measurable outcomes
2. **Right Granularity**: Not too detailed (micromanagement) or too vague (confusion)
3. **Explicit Dependencies**: Show what must complete before next phase
4. **Realistic Timelines**: Based on actual specialist capacity
5. **Success Criteria**: Measurable, verifiable outcomes
6. **Deliverable Specification**: Exact files/systems to be created

---

## Mission Orchestration Patterns

### Pattern 1: Sequential Phases (Standard)

**Use When**: Each phase depends on previous completion

**Example**: Build Mission
```
Strategist → Architect → Developer → Tester → Documenter → Operator
```

**Benefits**:
- Clear dependencies
- Quality gates between phases
- Easy to track progress

---

### Pattern 2: Parallel Tracks

**Use When**: Multiple independent workstreams

**Example**: Full Product Launch
```
Track 1: Developer → Tester (Backend API)
Track 2: Designer → Developer (Frontend UI)
Track 3: Marketer (Launch materials)

Then: Operator (Deploy all)
```

**Benefits**:
- Faster completion
- Specialist efficiency

**Risks**:
- Coordination complexity
- Integration challenges

---

### Pattern 3: Iterative Cycles

**Use When**: Repeated refinement needed

**Example**: Design Iteration
```
Cycle 1: Designer → Tester → Designer (feedback)
Cycle 2: Designer → Tester → Designer (feedback)
Final: Designer → Developer (implementation)
```

**Benefits**:
- Progressive improvement
- Feedback loops

**Risks**:
- Scope creep
- Longer timelines

---

### Pattern 4: Hub-and-Spoke

**Use When**: Central coordinator distributes work

**Example**: Bug Fix Sprint
```
Coordinator → (Developer, Developer, Developer) → Tester → Coordinator
```

**Benefits**:
- Parallel execution
- Central oversight

**Risks**:
- Coordinator bottleneck
- Context fragmentation

---

## Troubleshooting Missions

### Issue: Mission Stuck on Phase

**Symptoms**: Phase not completing, repeated errors

**Diagnosis**:
1. Check handoff-notes.md for blocker description
2. Review progress.md for error patterns
3. Verify phase deliverables are achievable

**Solutions**:
- Simplify phase scope if too ambitious
- Add intermediate verification step
- Break phase into smaller sub-tasks
- Consult specialist directly (`@developer What's blocking X?`)

---

### Issue: Context Loss Between Agents

**Symptoms**: Agents repeat work, miss prior decisions

**Diagnosis**:
1. Check if agent-context.md is being updated
2. Verify handoff-notes.md contains sufficient detail
3. Review coordinator delegation prompts

**Solutions**:
- Ensure coordinator includes "read agent-context.md" in delegation
- Make handoff-notes.md more detailed
- Add explicit context recap before each phase

---

### Issue: Mission Taking Longer Than Expected

**Symptoms**: Timeline estimates significantly off

**Diagnosis**:
1. Review progress.md for unexpected issues
2. Check if scope expanded during execution
3. Identify which phases took longest

**Solutions**:
- Update project-plan.md with revised estimates
- Consider splitting mission into multiple smaller missions
- Add buffer time for complex phases
- Document lessons in progress.md for future estimation

---

### Issue: Deliverables Don't Meet Requirements

**Symptoms**: Output doesn't match input document expectations

**Diagnosis**:
1. Review input document clarity
2. Check if requirements changed mid-mission
3. Verify specialist understood requirements

**Solutions**:
- Improve input document specificity
- Add acceptance criteria to each phase
- Include verification step after critical phases
- Have strategist review requirements before starting

---

## Mission Templates Location

Pre-built mission templates available in:
```
/missions/
├── mission-mvp.md              # MVP development
├── mission-build.md            # Full feature build
├── mission-fix.md              # Bug fix with analysis
├── mission-feature.md          # Feature development
├── mission-refactor.md         # Code refactoring
├── mission-analytics.md        # Analytics integration
├── mission-deploy.md           # Production deployment
├── mission-document.md         # Documentation creation
├── mission-security.md         # Security audit and fixes
└── mission-custom-template.md  # Template for custom missions
```

**Usage**: Reference these when creating custom missions or understanding workflow patterns.

---

## Next Steps

### Master Progress Tracking
See **[Progress Tracking Guide](./progress-tracking.md)** for:
- project-plan.md structure and best practices
- progress.md maintenance and issue tracking
- Context file integration
- Learning from failed attempts

### Explore Common Workflows
See **[Common Workflows Guide](./common-workflows.md)** for:
- Feature development workflow
- Bug fixing patterns
- Refactoring strategies
- When to use missions vs single agents

### Understand Features
See **[Features & Capabilities Guide](./features-capabilities.md)** for:
- Complete agent capabilities reference
- Advanced features (memory, extended thinking)
- MCP integration
- Team collaboration patterns

---

**[← Back to Main README](../../README.md)** | **[Next: Progress Tracking →](./progress-tracking.md)**
