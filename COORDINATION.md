# COORDINATION.md - Multi-Agent Orchestration Protocols

*Authoritative guide for agent coordination, delegation, and collaboration in AGENT-11*

## Core Coordination Principles

1. **Single Point of Orchestration**: The Coordinator (@coordinator) is the ONLY agent that delegates work to other agents
2. **Task Tool Mandatory**: ALL delegations MUST use the Task tool - no exceptions
3. **Real-Time Documentation**: Update project-plan.md and progress.md immediately
4. **No Role-Playing**: Agents must NEVER simulate or imagine responses from other agents
5. **Clear Boundaries**: Respect agent scope boundaries defined in AGENT-11.md

## Task Delegation Protocol

### CRITICAL: Proper Task Tool Usage

#### ✅ CORRECT Delegation
```python
Task(
    subagent_type="developer",
    description="Implement auth system",
    prompt="Create JWT-based authentication with the following requirements:
    1. User registration with email/password
    2. Login with JWT token generation
    3. Token refresh mechanism
    4. Password reset flow
    Document your implementation decisions in progress.md"
)
```

#### ❌ INCORRECT Delegation (Never Do This)
```
"I'm delegating this to @developer..."
"@developer, please implement the authentication system..."
"Handing this off to the developer agent..."
```

### Delegation Requirements

1. **Use Task Tool Parameters**:
   - `subagent_type`: The specialist agent type (e.g., "developer", "tester")
   - `description`: Brief 3-5 word task summary
   - `prompt`: Detailed instructions with context and deliverables

2. **Provide Complete Context**:
   - Current project state
   - Specific requirements
   - Expected deliverables
   - Success criteria
   - Relevant file paths

3. **Wait for Completion**:
   - Always wait for agent response
   - Never proceed until task completes
   - Handle failures gracefully

## Documentation Update Protocols

### project-plan.md Updates (MANDATORY)

#### When to Update
1. **Mission Start**: Create plan with all phases and tasks
2. **Phase Start**: Mark phase as "In Progress"
3. **Task Assignment**: Add agent assignment to task
4. **Task Completion**: Mark task [x] ONLY after agent confirms
5. **Phase End**: Update phase status to "Completed"
6. **Mission End**: Final summary with deliverables

#### Update Format
```markdown
### Phase 2: Implementation (In Progress)
**Lead**: @developer
**Support**: @tester

#### Tasks:
- [x] Create authentication module (completed by @developer)
- [ ] Implement user registration (assigned to @developer)
- [ ] Add JWT token generation (assigned to @developer)
```

### progress.md Updates (MANDATORY)

#### When to Update
1. **Issue Encountered**: Log immediately when found
2. **Root Cause Identified**: Document underlying cause
3. **Resolution Applied**: Record fix and lessons learned
4. **Deviation from Requirements**: Document ANY changes
5. **Performance Insights**: Log optimization opportunities

#### Update Format
```markdown
## 2024-12-27 - Authentication Implementation

### Issue Encountered
- **Problem**: JWT tokens expiring too quickly in production
- **Impact**: Users logged out every 15 minutes
- **Discovered by**: @tester during load testing

### Root Cause
- Token expiry set to 900 seconds instead of 86400
- Configuration error in environment variables

### Resolution
- Updated JWT_EXPIRY to 24 hours
- Added validation for token configuration
- Created operational.md entry for token management

### Deviation from Requirements
- **Original**: Simple JWT implementation
- **Changed to**: JWT with refresh token pattern
- **Reason**: Better security and user experience
- **Approved by**: @strategist
```

## Communication Patterns

### Escalation Protocol

Agents MUST escalate when:
1. Task is outside their scope boundaries
2. Requirements are unclear or conflicting
3. Technical blocker encountered
4. Dependencies not available
5. Quality standards at risk

Escalation format:
```
ESCALATION REQUIRED:
- Issue: [Description]
- Impact: [What's blocked]
- Needed from: [@agent or @coordinator]
- Suggested resolution: [If applicable]
```

### Handoff Protocol

When passing work between agents:

1. **Clear Deliverables**:
   - Specify exact files/artifacts
   - Document in standardized format
   - Include validation criteria

2. **Context Transfer**:
   - Current state summary
   - Decisions made and rationale
   - Known issues or limitations
   - Next steps required

3. **Verification**:
   - Receiving agent confirms receipt
   - Validates deliverables meet requirements
   - Logs any issues in progress.md

## Mission Execution Flow

### Standard Mission Phases

1. **Initialization**
   - Coordinator parses requirements
   - Creates/updates project-plan.md
   - Identifies required specialists

2. **Strategic Analysis**
   - Delegate to @strategist for requirements
   - Update project-plan.md with user stories
   - Define success criteria

3. **Technical Planning**
   - Delegate to @architect for design
   - Update architecture.md
   - Technology selection

4. **Implementation**
   - Delegate to @developer
   - Continuous updates to progress.md
   - Code reviews and testing

5. **Quality Assurance**
   - Delegate to @tester
   - Execute test suites
   - Performance validation

6. **Deployment**
   - Delegate to @operator
   - Update operational.md
   - Production verification

7. **Documentation**
   - Delegate to @documenter
   - Update all documentation
   - Knowledge transfer

### Parallel Execution

When tasks can run in parallel:
1. Identify independent tasks
2. Delegate simultaneously using multiple Task calls
3. Track progress separately
4. Synchronize at merge points

Example:
```python
# Parallel delegation
Task(subagent_type="developer", prompt="Implement frontend...")
Task(subagent_type="designer", prompt="Create mockups...")
Task(subagent_type="tester", prompt="Prepare test cases...")
```

## Conflict Resolution

### Priority Conflicts
1. Product requirements (@strategist) > Technical preferences
2. Security requirements > Feature requests
3. User experience > Developer convenience
4. Performance > Premature optimization

### Scope Conflicts
When agents disagree on ownership:
1. Refer to AGENT-11.md boundaries
2. Escalate to @coordinator
3. Document resolution in progress.md
4. Update boundaries if needed

### Technical Conflicts
When technical approaches differ:
1. @architect makes final technical decisions
2. Document trade-offs in architecture.md
3. Record decision rationale in progress.md

## Quality Gates

### Phase Completion Criteria

Before marking any phase complete:
1. All tasks marked [x] in project-plan.md
2. Deliverables verified by specialist
3. Tests passing (if applicable)
4. Documentation updated
5. Issues resolved or documented

### Mission Completion Criteria

Before closing a mission:
1. All phases completed successfully
2. Success metrics achieved
3. All documentation current
4. Operational procedures documented
5. Knowledge transferred

## Anti-Patterns to Avoid

### ❌ Never Do These

1. **Simulated Delegation**:
   - Writing "@developer is now working on..."
   - Describing what an agent "would do"
   - Creating fake agent responses

2. **Direct Agent Communication**:
   - Agents talking to each other directly
   - Skipping the coordinator
   - Informal handoffs

3. **Delayed Documentation**:
   - Batching updates for later
   - Waiting until phase end
   - Skipping progress.md entries

4. **Scope Creep**:
   - Agents doing work outside boundaries
   - Adding features without approval
   - Changing requirements unilaterally

5. **Missing Context**:
   - Delegating without full requirements
   - No success criteria defined
   - Unclear deliverables

## Coordination Metrics

Track these metrics for continuous improvement:

1. **Task Success Rate**: % of tasks completed successfully
2. **Documentation Lag**: Time between event and documentation
3. **Escalation Rate**: % of tasks requiring escalation
4. **Handoff Efficiency**: Time spent on handoffs
5. **Rework Rate**: % of tasks requiring revision

## Emergency Protocols

### When Things Go Wrong

1. **Immediate Actions**:
   - Stop current work
   - Document issue in progress.md
   - Escalate to @coordinator
   - Assess impact

2. **Recovery Process**:
   - Identify root cause
   - Document in progress.md
   - Implement fix
   - Update operational.md

3. **Post-Incident**:
   - Conduct retrospective
   - Update procedures
   - Share learnings
   - Prevent recurrence

---

*This document defines mandatory coordination protocols. All agents MUST follow these procedures without exception.*