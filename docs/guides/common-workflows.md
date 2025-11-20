# Common Workflows Guide

**[← Back to Main README](../../README.md)**

---

## Overview

Practical patterns for daily development work with AGENT-11. This guide shows you how to use agents effectively for common tasks you'll encounter every day.

**What You'll Learn**:
- How to approach different types of development tasks
- When to use individual agents vs. mission orchestration
- Best practices for agent collaboration
- Advanced patterns for complex workflows

---

## Quick Reference

| Task Type | Recommended Approach | Time to Complete |
|-----------|---------------------|------------------|
| **Feature Development** | @strategist → @developer → @tester | 2-8 hours |
| **Bug Fix** | @developer (or `/coord fix bug.md`) | 15-60 minutes |
| **Refactoring** | @architect → @developer → @tester | 1-4 hours |
| **Documentation** | @documenter (or @designer for UX docs) | 30-120 minutes |
| **Deployment** | @operator (or `/coord deploy`) | 20-45 minutes |
| **Full Build** | `/coord build requirements.md` | 4-16 hours |
| **MVP Launch** | `/coord mvp vision.md` | 1-3 days |

---

## Feature Development Workflow

### Pattern: Strategy → Implementation → Validation

This is the most common workflow for building new features.

### Step 1: Define Requirements (@strategist)

**Task**: Create clear, actionable requirements from high-level ideas.

**Example**:
```
@strategist Create user stories for a password reset feature
```

**@strategist Output**:
- User stories with acceptance criteria
- Edge cases and error scenarios
- Security considerations
- Success metrics

**Deliverable**: `requirements/password-reset.md` (or similar)

### Step 2: Implement Feature (@developer)

**Task**: Build the feature according to requirements.

**Example**:
```
@developer Implement password reset feature per requirements/password-reset.md
```

**@developer Actions**:
- Creates/modifies code files
- Implements error handling
- Adds logging and monitoring
- Documents code with comments

**Deliverable**: Working implementation with tests

### Step 3: Validate Quality (@tester)

**Task**: Verify the feature works correctly and meets requirements.

**Example**:
```
@tester Validate password reset implementation against requirements
```

**@tester Actions**:
- Creates test plan
- Writes automated tests (unit, integration, e2e)
- Executes tests and reports results
- Documents edge cases found

**Deliverable**: Test suite with passing results and coverage report

### Step 4: Deploy (@operator)

**Task**: Ship the feature to production.

**Example**:
```
@operator Deploy password reset feature to production
```

**@operator Actions**:
- Prepares deployment checklist
- Configures environment
- Executes deployment
- Monitors for issues
- Creates rollback plan

**Deliverable**: Feature live in production with monitoring

---

## Bug Fix Workflow

### Pattern: Quick Fix vs. Root Cause Analysis

**Quick Fix** (Simple bugs, < 1 hour):
```
@developer Fix bug: [description]
```

**Root Cause Analysis** (Complex bugs, recurring issues):
```bash
/coord fix bug-report.md
```

Or manual workflow:

### Step 1: Analyze Root Cause (@developer or @analyst)

**Task**: Understand why the bug exists.

**Example**:
```
@developer Analyze root cause of authentication timeout bug
```

**Output**:
- Root cause identification
- Impact assessment
- Recommended fix approach
- Prevention strategies

### Step 2: Implement Fix (@developer)

**Task**: Fix the bug and prevent recurrence.

**Example**:
```
@developer Implement fix for authentication timeout with prevention
```

**Actions**:
- Fixes immediate issue
- Adds safeguards to prevent recurrence
- Updates error handling
- Documents the fix in progress.md

### Step 3: Verify Fix (@tester)

**Task**: Confirm bug is resolved and no regressions.

**Example**:
```
@tester Verify authentication timeout fix and check for regressions
```

**Actions**:
- Tests original bug scenario
- Tests edge cases
- Runs regression test suite
- Documents test results

---

## Refactoring Workflow

### Pattern: Design → Implement → Verify

### Step 1: Design Refactoring (@architect)

**Task**: Plan the refactoring to improve code quality without breaking functionality.

**Example**:
```
@architect Design refactoring plan for authentication service
```

**@architect Output**:
- Current architecture analysis
- Proposed improvements
- Migration strategy
- Risk assessment
- Rollback plan

### Step 2: Execute Refactoring (@developer)

**Task**: Implement the refactoring incrementally.

**Example**:
```
@developer Execute authentication service refactoring per architecture plan
```

**Best Practice**: Refactor in small, testable increments. After each increment, run tests.

### Step 3: Validate (@tester)

**Task**: Ensure functionality is preserved and code quality improved.

**Example**:
```
@tester Validate authentication service refactoring - verify no functional changes
```

**Actions**:
- Runs full test suite
- Compares before/after behavior
- Checks performance metrics
- Documents quality improvements

---

## Mission-Based Workflows

### When to Use Missions

Use mission orchestration with `/coord` when:
- **Multiple agents needed** - Complex tasks requiring specialist collaboration
- **Defined process** - Workflow with clear phases (e.g., build, deploy)
- **Context preservation critical** - Need to maintain state across multiple tasks
- **Repeatable pattern** - Workflow you'll use multiple times

### Available Missions

**Development Missions**:
- `/coord build requirements.md` - Full feature build (strategy → code → test → docs)
- `/coord mvp vision.md` - MVP development (architecture → build → launch)
- `/coord fix bug-report.md` - Bug fix with root cause analysis
- `/coord refactor analysis.md` - Code refactoring workflow

**Infrastructure Missions**:
- `/coord deploy` - Production deployment
- `/coord dev-setup ideation.md` - New project initialization
- `/coord dev-alignment` - Existing project alignment

**Documentation Missions**:
- `/coord document codebase/` - Generate documentation for codebase
- `/coord integrate service-docs.md` - API integration documentation

### Mission Workflow Example

**Scenario**: Build a new user dashboard feature

**Command**:
```bash
/coord build requirements/user-dashboard.md
```

**What Happens**:
1. **@coordinator** reads requirements and creates execution plan
2. **@strategist** refines requirements and creates user stories
3. **@architect** designs system architecture (if needed)
4. **@developer** implements feature incrementally
5. **@tester** validates each increment
6. **@documenter** creates user and technical documentation
7. **@operator** prepares deployment (if requested)

**Output**:
- Working feature with tests
- Complete documentation
- Deployment-ready package
- Updated project-plan.md and progress.md

---

## Best Practices

### Context Preservation

**Always Maintain**:
- `agent-context.md` - Mission-wide accumulated knowledge
- `handoff-notes.md` - Agent-to-agent handoff information
- `progress.md` - Chronological change log and learnings

**Protocol**:
1. Agent reads context files before starting
2. Agent updates handoff-notes.md with findings
3. Coordinator merges into agent-context.md

**Benefit**: 87.5% reduction in rework, 37.5% faster completion

### Progressive Validation

**Pattern**: Test early, test often.

**Implementation**:
- Run tests after each code change (not just at the end)
- Use `@tester` for quick validation between development iterations
- Catch issues early when they're cheaper to fix

**Example**:
```
@developer Implement user login
@tester Quick validation of login flow
@developer Add password reset
@tester Validate reset flow
@developer Add session management
@tester Full authentication suite validation
```

### Documentation-Driven Development

**Pattern**: Document before implementing.

**Workflow**:
1. **@strategist** creates requirements
2. **@architect** documents design
3. **@developer** implements to spec
4. **@documenter** creates user-facing docs

**Benefit**: Clear direction, reduced rework, better onboarding

### Incremental Deployment

**Pattern**: Ship small, ship often.

**Implementation**:
- Break features into deployable increments
- Use feature flags for incomplete features
- Deploy and monitor before proceeding

**Example**:
```
@operator Deploy user profile API (backend only, no UI)
[Monitor for issues]
@operator Deploy profile UI (feature flag enabled for admins)
[Validate with test users]
@operator Enable profile feature for all users
```

---

## Advanced Patterns

### Parallel Workflows

**Scenario**: Multiple independent features being developed simultaneously.

**Pattern**: Use separate context files per feature.

**Implementation**:
```bash
# Feature A
/coord build requirements/feature-a.md
# Creates: agent-context-feature-a.md, handoff-notes-feature-a.md

# Feature B (in parallel)
/coord build requirements/feature-b.md
# Creates: agent-context-feature-b.md, handoff-notes-feature-b.md
```

**Benefit**: No context pollution between features.

### Specialist Consultation

**Pattern**: Bring in specialist for specific expertise without full mission.

**Example**:
```
# During development, need security review
@developer Building OAuth integration - need security review
@analyst Review OAuth implementation for security vulnerabilities
@developer Implement security recommendations
```

**Use When**: One-off expertise needed mid-workflow.

### Cross-Agent Collaboration

**Pattern**: Agents work together on same task.

**Example** (API Design):
```
@architect Design REST API for user service
@developer Review API design for implementation feasibility
@documenter Create API documentation outline
@strategist Validate API meets product requirements
```

**Benefit**: Multiple perspectives on critical decisions.

### Feedback Loops

**Pattern**: Iterate based on specialist feedback.

**Example**:
```
@developer Implement checkout flow
@tester Validate checkout - found edge case with coupon codes
@developer Fix coupon code edge case
@tester Validate fix - found performance issue
@developer Optimize coupon code validation
@tester Final validation - all tests pass
```

**Benefit**: Continuous improvement until quality standards met.

---

## Next Steps

### Master Progress Tracking
See **[Progress Tracking Guide](./progress-tracking.md)** for:
- How to maintain project-plan.md effectively
- Progress.md best practices
- Issue documentation and learning
- Milestone tracking

### Understand Mission Architecture
See **[Mission Architecture Guide](./mission-architecture.md)** for:
- How missions work internally
- Creating custom missions
- Mission orchestration patterns
- Advanced coordination techniques

### Explore All Features
See **[Features & Capabilities Guide](./features-capabilities.md)** for:
- Complete agent capabilities reference
- Advanced features (memory, extended thinking)
- MCP integration examples
- Team collaboration patterns

---

**[← Back to Main README](../../README.md)** | **[Next: Progress Tracking →](./progress-tracking.md)**
