# Enhanced Prompting Guide for AGENT-11

## Overview

This guide documents best practices for agent prompt engineering in AGENT-11, focusing on self-verification patterns, error recovery protocols, and quality assurance. These patterns enable agents to catch and correct issues before handoffs, reducing rework and improving mission success rates.

## Table of Contents

1. [Self-Verification Patterns](#self-verification-patterns)
2. [Error Recovery Protocols](#error-recovery-protocols)
3. [Collaboration Handoff Templates](#collaboration-handoff-templates)
4. [Quality Validation Frameworks](#quality-validation-frameworks)
5. [Role-Specific Prompting Techniques](#role-specific-prompting-techniques)
6. [Integration with Other Systems](#integration-with-other-systems)

---

## Self-Verification Patterns

### Pre-Handoff Checklist Pattern

Every agent should validate their work before handing off to another agent:

```markdown
**Pre-Handoff Checklist**:
- [ ] All deliverables from task prompt completed
- [ ] Quality standards met for [agent role]
- [ ] No obvious errors or gaps in work
- [ ] Documentation updated (handoff-notes.md, relevant context files)
- [ ] Next agent has sufficient context to proceed
```

**Benefits**:
- Catches incomplete work before it reaches next agent
- Ensures documentation is current and accurate
- Reduces "ping-pong" between agents fixing each other's mistakes
- Builds agent accountability and ownership

**Implementation**:
- Add to all 11 agent profiles as SELF-VERIFICATION PROTOCOL section
- Include role-specific checklist items
- Reference in mission templates as verification gates

### Quality Validation Pattern

Each agent should have role-specific quality criteria:

```markdown
**Quality Validation**:
- [Agent-specific quality criteria]
- [Completeness checks]
- [Correctness verification]
- [Consistency with established patterns]
- [Security requirements validation]
```

**Role-Specific Quality Criteria**:

**Developer**:
- Code runs without errors
- Tests pass (unit, integration)
- No security vulnerabilities (hardcoded secrets, SQL injection risks)
- Code follows project style guide
- Error handling is comprehensive

**Tester**:
- All critical paths tested
- Edge cases identified and documented
- Test results clear and reproducible
- Known issues flagged with severity
- Test coverage meets requirements

**Architect**:
- Architecture decisions documented with rationale
- Trade-offs explicitly stated
- Security implications considered
- Scalability addressed
- Integration points defined

**Designer**:
- RECON protocol completed
- Accessibility requirements met (WCAG 2.1 AA minimum)
- Responsive design validated (mobile, tablet, desktop)
- Design system consistency checked
- User feedback incorporated

**Documenter**:
- All sections complete and accurate
- Examples tested and working
- Clear and accessible language (reading level appropriate)
- Proper cross-referencing
- No broken links or outdated information

**Operator**:
- Infrastructure validated and tested
- Security configurations reviewed
- Rollback procedures documented
- Monitoring and alerts configured
- Deployment checklist complete

**Strategist**:
- All stakeholder needs captured
- Requirements testable and measurable
- Constraints and dependencies identified
- Success criteria clearly defined
- Business value articulated

**Analyst**:
- Data sources verified and reliable
- Methodology documented
- Insights supported by evidence
- Recommendations actionable
- Assumptions clearly stated

**Marketer**:
- Brand consistency checked
- Target audience alignment verified
- Call-to-action clarity
- Performance metrics defined
- Messaging tested with sample audience

**Support**:
- Root cause identified (per CLAUDE.md)
- Solution tested and documented
- User communication clear and empathetic
- Knowledge base updated
- Follow-up plan defined

**Coordinator**:
- All delegations resulted in completed work
- project-plan.md accurately reflects status
- progress.md captures issues and learnings
- Mission objectives achieved
- All agents had necessary context

### Dependency Verification Pattern

Ensure next agent has what they need:

```markdown
**Dependency Verification**:
- [ ] Next agent's inputs prepared and documented
- [ ] Required files/artifacts generated
- [ ] Context documented in handoff-notes.md
- [ ] Blockers/concerns flagged proactively
- [ ] Recommendations provided
```

---

## Error Recovery Protocols

### Error Detection Pattern

Define how agents recognize errors early:

```markdown
**Error Detection**:
1. **Syntax/Runtime Errors**: [How agent detects these]
2. **Logic Errors**: [Validation approaches]
3. **Integration Errors**: [Testing strategies]
4. **Security Errors**: [Security scanning methods]
5. **Performance Errors**: [Performance monitoring]
```

**Role-Specific Detection**:

**Developer**:
- Syntax errors: Linter output, compile-time checks
- Runtime errors: Test execution, error logs
- Logic errors: Unit tests, integration tests, edge case testing
- Security errors: Security scanner, manual code review
- Performance errors: Profiler output, load testing

**Tester**:
- Test failures: Automated test suite results
- Regression: Comparison with previous test runs
- Flaky tests: Repeated execution results
- Coverage gaps: Coverage reports
- Environment issues: Deployment validation

**Architect**:
- Design flaws: Peer review feedback
- Missing requirements: Stakeholder validation
- Inconsistencies: Cross-reference with requirements
- Scalability issues: Load modeling analysis
- Security gaps: Threat modeling review

### Root Cause Analysis Pattern

Following CLAUDE.md Critical Software Development Principles:

```markdown
**Root Cause Analysis**:
1. **Symptom Identification**: What is the observed problem?
2. **Context Gathering**: When does it occur? What changed?
3. **Hypothesis Formation**: What could cause this?
4. **Investigation**: Test hypotheses systematically
5. **Root Cause**: Underlying issue, not symptoms
6. **Validation**: Confirm root cause explains all symptoms
```

**Critical Questions**:
- Why was this designed this way?
- What is the architectural intent?
- What are the broader system impacts?
- Are we fixing the symptom or the cause?
- What security implications exist?

**Anti-Patterns to Avoid**:
- ❌ Implementing the first solution that comes to mind
- ❌ Removing security features to "make things work"
- ❌ Adding workarounds instead of fixing root cause
- ❌ Bypassing type systems or linters
- ❌ Quick fixes that create technical debt

### Recovery Strategy Pattern

```markdown
**Recovery Strategy**:
1. **Assess Impact**: How severe is the error?
2. **Identify Options**: What solutions are available?
3. **Evaluate Trade-offs**: Cost, risk, and benefits
4. **Select Solution**: Strategic solution that maintains system integrity
5. **Implement Fix**: Apply solution with testing
6. **Validate**: Confirm error resolved without side effects
7. **Document**: Record in progress.md for future learning
```

**Solution Evaluation Criteria** (from CLAUDE.md):
- ✅ Does this maintain all security requirements?
- ✅ Is this the architecturally correct solution?
- ✅ Will this create technical debt?
- ✅ Are there better long-term solutions?
- ✅ Have I understood the original design intent?

### Prevention Pattern

Learn from errors to improve future work:

```markdown
**Prevention Strategy**:
1. **Pattern Recognition**: Is this error similar to previous ones?
2. **Process Update**: How can we prevent recurrence?
3. **Documentation**: Add to lessons learned
4. **Protocol Enhancement**: Update agent protocols if needed
5. **Knowledge Sharing**: Update memory with insights
```

**Memory Integration**:
- Store error patterns in `/memories/lessons/errors.xml`
- Document solutions in `/memories/technical/patterns.xml`
- Update decision rationale in `/memories/technical/decisions.xml`
- Share insights across agents via memory system

### Escalation Pattern

Know when to request human intervention:

```markdown
**Escalation Triggers**:
- Security vulnerabilities discovered
- Architectural decisions beyond agent scope
- Conflicting requirements or constraints
- Missing critical information from user
- Resource limitations (time, budget, access)
- Repeated errors without clear solution
```

**Escalation Protocol**:
1. Document the issue clearly in handoff-notes.md
2. Provide context and attempted solutions
3. State specific information or decision needed
4. Recommend escalation path (@coordinator or user)
5. Continue with other tasks while awaiting resolution

---

## Collaboration Handoff Templates

### Standard Handoff Template

```markdown
## Handoff to [Next Agent]

**Task Completed**: [Brief description]

**Deliverables**:
- [File/artifact 1]
- [File/artifact 2]
- [Key decisions made]

**Context for Next Agent**:
- [Critical information they need]
- [Assumptions made]
- [Constraints discovered]

**Known Issues**:
- [Issue 1 with workaround/recommendation]
- [Issue 2 with severity and impact]

**Recommendations**:
- [Suggestion 1]
- [Suggestion 2]
- [What to watch out for]

**Files Updated**:
- handoff-notes.md: [What was added]
- progress.md: [Issues/learnings logged]
- [Other relevant files]
```

### Emergency Handoff Template

When urgent issues require immediate attention:

```markdown
## URGENT: [Issue Description]

**Severity**: [Critical/High/Medium]

**Impact**: [What's broken/blocked]

**Root Cause**: [If known, or investigation status]

**Immediate Actions Needed**:
1. [Action 1]
2. [Action 2]

**Context**:
- [Relevant background]
- [What's been tried]
- [Current state]

**Next Agent**: @[specialist] (recommended)
**Escalation**: [If blocking mission progress]
```

### Cross-Phase Handoff Template

When handing off between mission phases:

```markdown
## Phase [X] Handoff to Phase [Y]

**Phase [X] Summary**:
- Objectives: [What was planned]
- Results: [What was achieved]
- Variance: [Any deviations from plan]

**Artifacts Produced**:
- [List all deliverables with locations]

**Lessons Learned**:
- [Insight 1]
- [Insight 2]
- [What to do differently]

**Phase [Y] Prerequisites**:
- [Requirement 1: ✅/❌]
- [Requirement 2: ✅/❌]
- [Any missing prerequisites]

**Recommended Approach for Phase [Y]**:
- [Strategic guidance]
- [Potential pitfalls to avoid]
- [Resources to leverage]
```

---

## Quality Validation Frameworks

### Completeness Framework

Ensure all requirements addressed:

```markdown
**Completeness Checklist**:
- [ ] All items from task description completed
- [ ] All acceptance criteria met
- [ ] All edge cases considered
- [ ] All dependencies addressed
- [ ] All documentation requirements fulfilled
```

**Verification Method**:
1. Cross-reference task description with deliverables
2. Check acceptance criteria one by one
3. Review edge case list for coverage
4. Validate all dependencies resolved or documented
5. Confirm documentation matches implementation

### Correctness Framework

Ensure solutions are accurate and tested:

```markdown
**Correctness Checklist**:
- [ ] Solution addresses root cause, not symptoms
- [ ] Implementation matches specification
- [ ] Tests pass (unit, integration, E2E as appropriate)
- [ ] Manual validation performed
- [ ] No regressions introduced
```

**Testing Hierarchy**:
1. **Unit Tests**: Individual components work correctly
2. **Integration Tests**: Components work together
3. **End-to-End Tests**: Full user flows work correctly
4. **Manual Testing**: UX and edge cases validated
5. **Regression Testing**: Existing functionality still works

### Clarity Framework

Ensure work is understandable:

```markdown
**Clarity Checklist**:
- [ ] Documentation clear and concise
- [ ] Code/content follows style guide
- [ ] Complex logic explained
- [ ] Assumptions stated explicitly
- [ ] Next steps obvious
```

**Clarity Standards**:
- Documentation: Reading level appropriate for audience
- Code: Self-documenting with comments for "why" not "what"
- Handoffs: Next agent can continue without questions
- Decisions: Rationale documented for future reference

### Consistency Framework

Ensure alignment with established patterns:

```markdown
**Consistency Checklist**:
- [ ] Follows project conventions
- [ ] Matches established patterns
- [ ] Aligns with architecture decisions
- [ ] Consistent with brand/style guide
- [ ] Uses approved tools and libraries
```

**Pattern Sources**:
- `/memories/technical/patterns.xml` - Proven patterns
- `/memories/technical/decisions.xml` - Architectural choices
- Project style guides and documentation
- Framework best practices

### Security Framework

Ensure security requirements met:

```markdown
**Security Checklist**:
- [ ] No hardcoded secrets or credentials
- [ ] Input validation implemented
- [ ] Authentication/authorization checked
- [ ] Security features not bypassed
- [ ] Sensitive data handled properly
```

**Security-First Principles** (from CLAUDE.md):
- Never compromise security for convenience
- Research security features before changing them
- Understand WHY security features exist
- Work WITH security features, not around them
- Document security decisions and rationale

---

## Role-Specific Prompting Techniques

### Developer Prompting

**Effective Prompts**:
- "Think harder about implementing the OAuth2 authentication flow. Consider security, token refresh, error handling, and edge cases."
- "Implement the user registration API with comprehensive input validation, rate limiting, and security best practices."
- "Refactor the payment processing module to use the Stripe MCP while maintaining all existing functionality and tests."

**Anti-Patterns**:
- ❌ "Fix the auth bug" (too vague, no context)
- ❌ "Add the feature quickly" (encourages shortcuts)
- ❌ "Just make it work" (ignores quality and security)

**Best Practices**:
- Specify thinking mode based on complexity
- Include security requirements explicitly
- Reference existing patterns from memory
- Define "done" criteria clearly
- Mention testing expectations

### Tester Prompting

**Effective Prompts**:
- "Test the authentication flow with mcp__playwright. Cover happy path, invalid credentials, rate limiting, and session management. Document any edge cases discovered."
- "Execute regression testing suite and compare results with baseline. Investigate any failures and categorize as new bugs or environment issues."
- "Create E2E tests for the checkout flow, including payment processing, error handling, and edge cases like network failures."

**Anti-Patterns**:
- ❌ "Test the app" (no scope, no criteria)
- ❌ "Make sure it works" (undefined success)
- ❌ "Quick sanity check" (encourages superficial testing)

**Best Practices**:
- Define test scope clearly (unit, integration, E2E)
- Specify coverage requirements
- List critical paths to test
- Mention edge cases to consider
- Clarify how to report findings

### Architect Prompting

**Effective Prompts**:
- "Think ultrathink about the architecture for a multi-tenant SaaS platform. Consider data isolation, scalability, security, and cost optimization. Document trade-offs."
- "Design the database schema for the e-commerce platform. Consider normalization, performance, scalability, and future expansion needs."
- "Review the proposed microservices architecture for security vulnerabilities, single points of failure, and operational complexity."

**Anti-Patterns**:
- ❌ "Design the system" (no constraints, no context)
- ❌ "Pick a tech stack" (no criteria)
- ❌ "Make it scalable" (undefined scale, no trade-offs)

**Best Practices**:
- Use "ultrathink" for complex architectural decisions
- Specify constraints (budget, timeline, team size)
- Request trade-off analysis
- Define non-functional requirements
- Ask for decision documentation

### Designer Prompting

**Effective Prompts**:
- "Execute RECON Protocol on the login page. Assess usability, accessibility (WCAG 2.1 AA), responsive design, and brand consistency."
- "Design the user dashboard with focus on data visualization clarity, information hierarchy, and mobile responsiveness."
- "Review the checkout flow for friction points, accessibility issues, and opportunities to reduce cart abandonment."

**Anti-Patterns**:
- ❌ "Make it pretty" (no design goals)
- ❌ "Design a page" (no context, no requirements)
- ❌ "Fix the UI" (no problem definition)

**Best Practices**:
- Reference RECON Protocol for systematic review
- Specify accessibility requirements
- Define target devices/breakpoints
- Mention brand guidelines
- Include user experience goals

### Coordinator Prompting

**Effective Prompts**:
- "Orchestrate the MVP development mission. Analyze requirements, create project-plan.md, delegate to specialists, track progress, ensure quality gates, and deliver working MVP."
- "Coordinate the security audit mission. Delegate security scanning to @tester, vulnerability fixes to @developer, and deployment hardening to @operator."
- "Manage the refactoring mission. Break into phases, assign specialists, track progress in project-plan.md, ensure no regressions, and document learnings in progress.md."

**Anti-Patterns**:
- ❌ "Build the app" (no breakdown, no delegation plan)
- ❌ "Fix all the bugs" (no prioritization, no strategy)
- ❌ "Deploy to production" (no safety checks, no rollback plan)

**Best Practices**:
- Specify mission objectives clearly
- Define success criteria
- Mention tracking requirements
- Include quality gates
- Specify delegation strategy

### Strategist Prompting

**Effective Prompts**:
- "Think harder about the product requirements for the mobile app. Analyze user needs, competitive landscape, business constraints, and create detailed user stories."
- "Define the MVP scope for the SaaS platform. Identify must-have features, nice-to-have features, and features to defer. Provide rationale for each decision."
- "Analyze the market opportunity for the B2B solution. Research competitors, identify differentiation, and recommend positioning strategy."

**Anti-Patterns**:
- ❌ "What should we build?" (no context)
- ❌ "Analyze the market" (too broad, no focus)
- ❌ "Create requirements" (no stakeholder input)

**Best Practices**:
- Use "think harder" for strategic decisions
- Provide market/user context
- Define constraints and goals
- Request prioritization
- Ask for rationale documentation

### Documenter Prompting

**Effective Prompts**:
- "Document the authentication API with examples for each endpoint, error codes, rate limiting, and security best practices."
- "Create user guide for the dashboard feature. Include screenshots, step-by-step instructions, troubleshooting, and FAQ."
- "Update the architecture documentation to reflect the new microservices design. Include diagrams, component descriptions, and integration points."

**Anti-Patterns**:
- ❌ "Write docs" (no scope, no audience)
- ❌ "Document the code" (auto-generated approach)
- ❌ "Update readme" (no specific changes)

**Best Practices**:
- Define audience (developers, users, admins)
- Specify format and structure
- Request examples and diagrams
- Mention testing of examples
- Include cross-referencing

### Operator Prompting

**Effective Prompts**:
- "Deploy the application to production using mcp__railway. Configure auto-scaling, monitoring, logging, and alerting. Document rollback procedure."
- "Set up CI/CD pipeline with GitHub Actions. Include build, test, security scan, and deployment stages. Configure deployment gates."
- "Implement monitoring and alerting for the production environment. Track error rates, response times, and resource utilization. Set up on-call rotation."

**Anti-Patterns**:
- ❌ "Deploy it" (no environment, no safety checks)
- ❌ "Set up monitoring" (no metrics, no thresholds)
- ❌ "Configure CI/CD" (no requirements, no stages)

**Best Practices**:
- Specify environment (dev, staging, production)
- Define deployment strategy (blue-green, canary)
- Request monitoring and alerting setup
- Include rollback procedures
- Mention security configurations

### Analyst Prompting

**Effective Prompts**:
- "Analyze user engagement metrics from the past quarter. Identify trends, anomalies, and opportunities for improvement. Provide actionable recommendations."
- "Evaluate the A/B test results for the new checkout flow. Determine statistical significance, analyze user behavior, and recommend rollout strategy."
- "Create dashboard for product metrics. Include user growth, engagement, retention, and revenue. Provide insights and anomaly detection."

**Anti-Patterns**:
- ❌ "Analyze the data" (no focus, no questions)
- ❌ "Create a report" (no audience, no purpose)
- ❌ "Look at metrics" (no analysis goal)

**Best Practices**:
- Use "think hard" for complex analysis
- Define specific questions to answer
- Specify time period and data sources
- Request actionable insights
- Mention visualization needs

### Marketer Prompting

**Effective Prompts**:
- "Create launch announcement for the new feature. Target B2B SaaS audience, highlight benefits over features, include clear call-to-action."
- "Develop content strategy for blog and social media. Focus on developer audience, technical depth, and thought leadership."
- "Design email campaign for user re-engagement. Segment inactive users, personalize messaging, A/B test subject lines."

**Anti-Patterns**:
- ❌ "Write a blog post" (no topic, no audience)
- ❌ "Create content" (too broad, no strategy)
- ❌ "Promote the product" (no channel, no message)

**Best Practices**:
- Define target audience clearly
- Specify marketing channel
- Include brand voice guidelines
- Request metrics for success
- Mention A/B testing opportunities

### Support Prompting

**Effective Prompts**:
- "Resolve the user-reported authentication issue. Perform root cause analysis, implement fix, test thoroughly, document solution, and update knowledge base."
- "Handle the production incident: checkout flow failing. Identify root cause, coordinate fix with @developer, communicate with affected users, document post-mortem."
- "Improve the help documentation for common user issues. Analyze support tickets, identify patterns, create FAQ, and enhance troubleshooting guides."

**Anti-Patterns**:
- ❌ "Fix the bug" (no investigation, no root cause)
- ❌ "Help the user" (no context, no issue details)
- ❌ "Update docs" (no specific improvements)

**Best Practices**:
- Request root cause analysis (per CLAUDE.md)
- Specify user communication requirements
- Include knowledge base update
- Mention similar issue patterns
- Define resolution criteria

---

## Integration with Other Systems

### Integration with Memory Tools

**Pattern**:
```markdown
**Memory Integration**:
1. Load relevant context from /memories/ before starting
2. Reference prior decisions from /memories/technical/decisions.xml
3. Apply established patterns from /memories/technical/patterns.xml
4. Update memory with new insights after completion
5. Store lessons learned in /memories/lessons/
```

**Benefits**:
- Consistent decision-making across sessions
- Reuse of proven patterns
- Accumulation of project knowledge
- Faster onboarding for new agents

**Example**:
```
Before implementing authentication:
→ READ /memories/technical/decisions.xml (see if auth approach decided)
→ READ /memories/technical/patterns.xml (check for auth patterns)
→ IMPLEMENT using established patterns
→ UPDATE /memories/technical/patterns.xml with new insights
```

### Integration with Extended Thinking

**Pattern**:
```markdown
**Thinking Mode Selection**:
1. Assess task complexity and criticality
2. Choose appropriate thinking mode
3. Use extended thinking for strategic decisions
4. Document thinking process in decisions
5. Evaluate cost vs. benefit of extended thinking
```

**Guidelines**:
- **Ultrathink**: Architectural decisions, complex system design
- **Think harder**: Security implementations, critical components
- **Think hard**: Complex features, major refactoring
- **Think**: Standard implementation, routine tasks
- **Standard**: Trivial changes, documentation updates

**Example**:
```
Task: Implement OAuth2 authentication
→ Complexity: High (security-critical)
→ Thinking Mode: "think harder"
→ Rationale: Security mistakes create vulnerabilities
→ Cost: 2.5-3x baseline, justified for critical component
```

### Integration with Tool Permissions

**Pattern**:
```markdown
**Tool Permission Awareness**:
1. Check available tools before planning approach
2. Verify tool permissions sufficient for task
3. Delegate when lacking required tools
4. Use MCPs when available (prioritize over manual)
5. Document tool usage in handoff notes
```

**Example**:
```
Tester receives task to modify test code:
→ CHECK TOOLS: Read + Bash (test execution) + mcp__playwright
→ NO EDIT PERMISSION: Cannot modify test files
→ DELEGATE: Generate test code, delegate to @developer
→ DOCUMENT: Note delegation reason in handoff-notes.md
```

### Integration with Context Editing

**Pattern**:
```markdown
**Context Editing Protocol**:
1. Monitor context size during long tasks
2. Plan clearing points between distinct work
3. Preserve critical context in memory before clearing
4. Update handoff-notes.md before /clear
5. Resume with clean context after clearing
```

**Strategic Clearing Points**:
- After completing distinct features
- Between debugging and implementation
- After major refactoring commits
- When switching between unrelated work
- After context exceeds 30K tokens

**Example**:
```
After implementing authentication feature:
→ EXTRACT insights to /memories/lessons/auth-implementation.xml
→ DOCUMENT security decisions in /memories/technical/decisions.xml
→ UPDATE handoff-notes.md with current state
→ COMMIT and push code changes
→ /clear
→ Start payment integration with clean context
```

### Integration with Context Preservation

**Pattern**:
```markdown
**Context Preservation Integration**:
1. READ agent-context.md and handoff-notes.md before starting
2. UPDATE handoff-notes.md with findings during work
3. LOG issues and resolutions in progress.md
4. ACCUMULATE findings in agent-context.md (via coordinator)
5. STORE artifacts in evidence-repository.md
```

**File Responsibilities**:
- **agent-context.md**: Rolling mission context (coordinator updates)
- **handoff-notes.md**: Immediate next agent context (each agent updates)
- **progress.md**: Issues and learnings (coordinator updates)
- **evidence-repository.md**: Artifacts and proof (agents add evidence)

---

## Self-Verification Implementation Checklist

When implementing self-verification in agent profiles:

- [ ] Add SELF-VERIFICATION PROTOCOL section to agent
- [ ] Include pre-handoff checklist with role-specific items
- [ ] Define quality validation criteria for agent role
- [ ] Document error detection methods
- [ ] Specify root cause analysis approach (per CLAUDE.md)
- [ ] Define recovery strategies for common errors
- [ ] Include prevention and learning patterns
- [ ] Add escalation triggers and protocol
- [ ] Specify handoff requirements to next agent
- [ ] Integrate with memory, thinking, tools, and context systems
- [ ] Test verification patterns in real workflows
- [ ] Gather feedback and refine verification protocols

---

## Measuring Self-Verification Effectiveness

### Metrics to Track

**Rework Reduction**:
- Baseline: Tasks requiring rework before self-verification
- Target: 50% reduction in rework after self-verification
- Measurement: Track handoffs requiring corrections

**Error Detection Rate**:
- Baseline: Errors caught by next agent vs. self-verification
- Target: 70% of errors caught before handoff
- Measurement: Log where errors are detected

**Handoff Quality**:
- Baseline: Questions from next agent about context
- Target: 80% of handoffs require no clarification
- Measurement: Track clarification requests

**Mission Completion Time**:
- Baseline: Time from start to mission complete
- Target: 20% faster with self-verification
- Measurement: Log mission durations

### Continuous Improvement

**Monthly Review**:
1. Analyze progress.md for recurring error patterns
2. Identify verification gaps in agent protocols
3. Enhance verification checklists based on findings
4. Update quality criteria as standards evolve
5. Share learnings across all agent profiles

**Quarterly Enhancement**:
1. Review all self-verification protocols for effectiveness
2. Update based on agent performance data
3. Incorporate new best practices discovered
4. Enhance integration with other systems
5. Train agents on improved verification techniques

---

## Conclusion

Enhanced prompting with self-verification patterns transforms agents from task executors into quality-conscious professionals. By catching errors before handoffs, performing root cause analysis, and maintaining high quality standards, agents dramatically reduce rework and improve mission success rates.

Key principles:
- **Verify before handing off**: Catch errors early
- **Root cause, not symptoms**: Fix underlying issues
- **Document everything**: Learning compounds over time
- **Integrate systems**: Memory, thinking, tools, context work together
- **Continuous improvement**: Learn from every mission

The investment in self-verification pays dividends through faster missions, higher quality deliverables, and accumulated organizational knowledge.

---

**Last Updated**: October 6, 2025
**Version**: 1.0
**Related Guides**:
- `/project/field-manual/memory-management.md`
- `/project/field-manual/extended-thinking-guide.md`
- `/project/field-manual/tool-permissions-guide.md`
- `/project/field-manual/context-editing-guide.md`
