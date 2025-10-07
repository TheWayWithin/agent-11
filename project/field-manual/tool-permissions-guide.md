# Tool Permissions Guide: Security-First Tool Access for AGENT-11

## Overview

This guide defines the security-first tool permission model for all AGENT-11 specialist agents. Following the **principle of least privilege**, each agent is granted only the tools essential for their core function, improving both security (preventing accidental misuse) and performance (reducing cognitive load from excessive options).

## Core Principles

### 1. Least Privilege Principle
**Grant only tools agents actually need for their core function.**

- Default: Deny all tools
- Explicit: Allow only what's required
- Minimal: Prefer read-only over read-write
- Justification: Document security rationale for each grant

**Example**: Tester needs Read to analyze code and Bash to execute tests, but should NOT have Write/Edit to prevent accidental code modification.

### 2. Security-First Approach
**Prevent accidental destructive operations.**

- Limit blast radius of mistakes
- Require explicit permission for dangerous operations
- Dangerous tool combinations require extra scrutiny
- Audit trail for all write operations

**Dangerous Tool Combinations**:
- **Bash + Write**: Can execute arbitrary code AND modify files (highest risk)
- **Edit + Bash**: Can inject code and execute it
- **MCPs + Bash**: Can leverage external services with code execution
- **Write + MultiEdit**: Can modify multiple files simultaneously

### 3. Performance Optimization
**Limit to 5-7 primary tools per agent.**

- Reduces cognitive load from excessive tool options
- Improves agent focus and decision speed
- Move auxiliary operations to bash scripts or code generation
- Clearer mental model of agent capabilities

**Strategic Review Recommendation**: "Limit each agent to 5-7 primary tools, move auxiliary operations to bash/code generation"

### 4. Role-Based Access Control
**Tool permissions match agent responsibilities.**

- Implementation roles: Full file manipulation (developer)
- Analysis roles: Read-only access (strategist, analyst)
- Testing roles: Read + execution, no write (tester)
- Deployment roles: Infrastructure-specific tools (operator)
- Coordination roles: Delegation + tracking only (coordinator)

## Tool Categories

### File Operations (High Security Impact)

#### Read (Low Risk - Generally Safe)
**Purpose**: Read file contents from the filesystem

**Security Level**: LOW - Read-only, no modification capability

**Granted To**: All agents (universal need to understand context)

**Restricted From**: None (reading is essential for all roles)

**Security Notes**:
- Cannot modify files
- Safe for all agents
- Essential for context understanding

---

#### Write (HIGH Risk - Destructive)
**Purpose**: Create new files or completely overwrite existing files

**Security Level**: HIGH - Can destroy existing content

**Granted To**:
- **Developer** - Primary implementation tool
- **Documenter** - Creating documentation files
- **Coordinator** - Project tracking files only (project-plan.md, progress.md)
- **Designer** - Design specification files
- **Marketer** - Marketing content files

**Restricted From**:
- **Tester** - Should not modify code/config
- **Strategist** - Analysis only, no file creation
- **Architect** - Documentation editing only (use Edit instead)
- **Analyst** - Data analysis, no file creation
- **Support** - Issue tracking, no file modification
- **Operator** - Configuration files only (use Edit for precision)

**Security Rationale**:
- Write is destructive (overwrites existing files completely)
- Agents should use Edit for modifications (safer, more precise)
- Only grant Write when agent needs to CREATE new files frequently
- Coordinator's Write access limited to tracking files only

**Mitigation**:
- Always read file first before writing (tool enforces this)
- Use Edit for modifications to existing files
- Document why new files are needed

---

#### Edit (MEDIUM Risk - Targeted Modification)
**Purpose**: Make precise string replacements in existing files

**Security Level**: MEDIUM - Can modify files but requires exact match

**Granted To**:
- **Developer** - Code modification and refactoring
- **Documenter** - Documentation updates
- **Coordinator** - Tracking file updates
- **Architect** - Architecture documentation
- **Designer** - Design spec updates

**Restricted From**:
- **Tester** - Should not modify code
- **Strategist** - Analysis only, no modifications
- **Analyst** - Data analysis, no file changes
- **Support** - Issue tracking via tools, not file editing
- **Marketer** - Content via Write (creating new), not editing code
- **Operator** - Config changes via controlled deployment process

**Security Rationale**:
- Safer than Write (requires exact string match)
- Limited to agents that need file modification
- Prevents accidental changes (old_string must match exactly)

**Mitigation**:
- Must read file before editing (tool enforces)
- Unique string matching prevents unintended changes
- Audit all edits for security implications

---

#### MultiEdit (HIGH Risk - Multiple File Modification)
**Purpose**: Make coordinated changes across multiple files

**Security Level**: HIGH - Can modify many files in single operation

**Granted To**:
- **Developer** - Large-scale refactoring only

**Restricted From**: All other agents

**Security Rationale**:
- Highest risk file tool (can change many files at once)
- Only developer needs this for refactoring operations
- Even developer should use sparingly

**Mitigation**:
- Require explicit justification before use
- Test changes in isolated branch
- Code review before merging multi-file changes

---

### Code Execution (HIGHEST Security Impact)

#### Bash (HIGHEST Risk - Arbitrary Code Execution)
**Purpose**: Execute shell commands, run scripts, build processes

**Security Level**: HIGHEST - Can execute any system command

**Granted To**:
- **Developer** - Build scripts, testing, git operations, deployment prep
- **Operator** - Deployment commands, infrastructure management, service control
- **Tester** - Test execution, test scripts, validation commands
- **Analyst** - Data processing scripts, metrics collection (limited scope)

**Restricted From**:
- **Coordinator** - Delegates execution to others (uses Task only)
- **Strategist** - Analysis only, no execution
- **Architect** - Documentation and planning, no execution
- **Designer** - Design tools only, no code execution
- **Documenter** - File operations only, no execution
- **Marketer** - Content creation, no execution
- **Support** - Issue tracking, no execution

**Security Rationale**:
- Most dangerous tool (arbitrary command execution)
- Grant to MINIMAL set of agents (only 4 out of 11)
- Each agent has specific execution scope:
  - Developer: Build, test, git (development workflow)
  - Operator: Deploy, infrastructure (production operations)
  - Tester: Test execution only (validation workflow)
  - Analyst: Data tools only (analytics pipeline)

**Dangerous Combinations**:
- Bash + Write: Can create malicious scripts and execute them
- Bash + Edit: Can modify code and immediately execute
- Bash + MCPs: Can leverage external services destructively

**Mitigation**:
- Document all bash commands before execution
- Review commands for security implications
- Use read-only operations when possible
- Limit execution scope to agent's domain
- Require explicit confirmation for destructive operations

---

### Search & Navigation (Low Security Impact)

#### Grep (Low Risk - Content Search)
**Purpose**: Search file contents using regex patterns

**Security Level**: LOW - Read-only operation

**Granted To**: All agents (universal search need)

**Restricted From**: None

**Security Notes**:
- Read-only, safe for all agents
- Essential for code exploration and analysis

---

#### Glob (Low Risk - File Pattern Matching)
**Purpose**: Find files by name patterns

**Security Level**: LOW - Read-only operation

**Granted To**: All agents (universal file discovery need)

**Restricted From**: None

**Security Notes**:
- Read-only, safe for all agents
- Efficient file discovery

---

### Delegation & Coordination (Medium Security Impact)

#### Task (MEDIUM Risk - Spawns New Agent Instances)
**Purpose**: Delegate work to specialist agents

**Security Level**: MEDIUM - Spawns sub-agents with their own permissions

**Granted To**: All agents (enables collaboration)

**Security Notes**:
- Delegation is core to AGENT-11 architecture
- Sub-agents inherit their own permission sets
- Coordinator uses this extensively for orchestration
- Enables agents to delegate when they need specialist help

**Security Mitigation**:
- Sub-agents have their own restricted tool sets
- Coordinator reviews all delegations
- Document delegation chain for audit trail

---

#### TodoWrite (Low Risk - Task Tracking)
**Purpose**: Create and manage structured task lists

**Security Level**: LOW - Tracking only, no file/code modification

**Granted To**:
- **Coordinator** - Mission planning and orchestration
- **Developer** - Task tracking for complex implementations
- **Tester** - Test execution tracking

**Restricted From**: Most agents (use coordinator for task management)

**Security Notes**:
- Tracking tool only, no destructive capability
- Coordinator is primary user for mission orchestration

---

### Research & External Access (Medium Security Impact)

#### WebSearch (Low Risk - Read-Only External)
**Purpose**: Search the web for current information

**Security Level**: LOW - Read-only external access

**Granted To**:
- **Strategist** - Market research, competitive analysis
- **Architect** - Technology research, best practices
- **Designer** - Design trends, UX patterns
- **Marketer** - Marketing trends, campaign ideas
- **Support** - Support resources, documentation
- **Analyst** - Data sources, industry benchmarks
- **Coordinator** - Best practices for project management

**Restricted From**:
- **Developer** - Use mcp__context7, mcp__firecrawl, or mcp__grep instead (more targeted)
- **Tester** - Testing documentation via MCPs
- **Operator** - Infrastructure docs via MCPs
- **Documenter** - Technical docs via MCPs

**Security Rationale**:
- Research-focused agents benefit from current information
- Implementation agents have better tools (MCPs) for technical content
- WebSearch is for trends/analysis, not technical implementation

---

#### WebFetch (MEDIUM Risk - External Content Retrieval)
**Purpose**: Fetch and process content from specific URLs

**Security Level**: MEDIUM - Can retrieve arbitrary web content

**Granted To**: Limited use as fallback when MCPs unavailable

**Security Notes**:
- Prefer mcp__firecrawl when available (more capable)
- Use only when specific URL content needed
- Validate content before using in decisions

---

### MCP Tools (Variable Security Impact)

#### mcp__github (MEDIUM Risk - Code Repository Access)
**Purpose**: Repository management, PRs, issues, releases, CI/CD

**Security Level**: MEDIUM - Can create PRs, modify issues, trigger CI/CD

**Granted To**:
- **Developer** - Primary user for version control operations
- **Operator** - Release management, deployment workflows
- **Coordinator** - Project tracking, issue management (read-only preferred)
- **Documenter** - Documentation PRs, wiki updates
- **Support** - Issue tracking and management

**Restricted From**: Agents without direct GitHub workflow needs

**Security Rationale**:
- Can create commits, PRs, trigger CI/CD (significant impact)
- Limit to agents with direct development/deployment responsibilities
- Coordinator should prefer read-only GitHub access

**Mitigation**:
- Review all PR creations before merge
- Limit CI/CD trigger permissions
- Use branch protection rules

---

#### mcp__context7 (Low Risk - Documentation Access)
**Purpose**: Library documentation, code patterns, best practices

**Security Level**: LOW - Read-only documentation access

**Granted To**:
- **Developer** - Primary user for implementation patterns
- **Architect** - Architecture research and patterns
- **Designer** - UI library documentation
- **Documenter** - Documentation standards and examples
- **Tester** - Testing framework documentation

**Restricted From**: Agents without technical implementation needs

**Security Notes**:
- Read-only documentation access
- Safe for all technical roles
- Essential for learning implementation patterns

---

#### mcp__firecrawl (MEDIUM Risk - Web Scraping)
**Purpose**: Web scraping, competitor analysis, market research, API docs

**Security Level**: MEDIUM - Can scrape arbitrary websites

**Granted To**:
- **Strategist** - Competitive intelligence, market research
- **Architect** - API documentation research
- **Developer** - API documentation when context7 insufficient
- **Marketer** - Competitor analysis, content research
- **Designer** - Design inspiration, UX patterns

**Restricted From**: Agents without research/analysis needs

**Security Notes**:
- Can scrape potentially malicious content
- Validate scraped content before use
- Respect robots.txt and rate limits

---

#### mcp__supabase (HIGH Risk - Database Access)
**Purpose**: Database operations, auth, real-time, storage, edge functions

**Security Level**: HIGH - Direct database and auth system access

**Granted To**:
- **Developer** - Primary user for backend implementation
- **Operator** - Database management, backup, scaling

**Restricted From**: All other agents

**Security Rationale**:
- Direct database access can corrupt data
- Auth system access can compromise security
- Only grant to agents with backend implementation responsibilities

**Mitigation**:
- Use read-only connections when possible
- Review all schema changes
- Test database operations in staging first
- Monitor for SQL injection attempts

---

#### mcp__stripe (HIGH Risk - Payment Processing)
**Purpose**: Payments, subscriptions, invoicing, revenue analytics, webhooks

**Security Level**: HIGH - Financial data and payment processing

**Granted To**:
- **Developer** - Payment integration implementation
- **Operator** - Payment system monitoring and management
- **Analyst** - Revenue analytics (read-only preferred)

**Restricted From**: All other agents

**Security Rationale**:
- Financial data requires highest security
- Payment processing errors can cause monetary loss
- PCI compliance requirements

**Mitigation**:
- Use test mode for development
- Review all payment flows for security
- Monitor for fraudulent patterns
- Use read-only keys for analytics when possible

---

#### mcp__railway (HIGH Risk - Infrastructure Management)
**Purpose**: Backend services, databases, cron jobs, workers, auto-scaling

**Security Level**: HIGH - Infrastructure and production services

**Granted To**:
- **Operator** - Primary user for infrastructure management
- **Developer** - Development environment setup only

**Restricted From**: All other agents

**Security Rationale**:
- Infrastructure changes affect production
- Service misconfigurations can cause outages
- Cost implications from scaling/provisioning

**Mitigation**:
- Use staging environments for testing
- Review infrastructure changes before applying
- Monitor costs and resource usage
- Implement change approval process

---

#### mcp__netlify (MEDIUM Risk - Frontend Deployment)
**Purpose**: Frontend hosting, edge functions, forms, redirects

**Security Level**: MEDIUM - Frontend deployment and configuration

**Granted To**:
- **Operator** - Primary user for frontend deployment
- **Developer** - Preview deployments for testing

**Restricted From**: All other agents

**Security Rationale**:
- Deployment affects production frontend
- Edge function code execution
- Configuration errors can cause outages

**Mitigation**:
- Use preview deployments for testing
- Review edge functions for security
- Monitor deployment status

---

#### mcp__playwright (MEDIUM Risk - Browser Automation)
**Purpose**: Browser automation, UI testing, screenshots, accessibility testing

**Security Level**: MEDIUM - Automated browser control

**Granted To**:
- **Tester** - Primary user for E2E testing
- **Designer** - Visual regression testing, accessibility audits
- **Developer** - Integration testing when needed

**Restricted From**: Agents without testing/design responsibilities

**Security Notes**:
- Browser automation is powerful but controlled
- Can interact with real websites (respect rate limits)
- Screenshot capability useful for testing

---

#### mcp__grep (Low Risk - Code Search)
**Purpose**: Search 1M+ GitHub repos for code patterns, implementations, examples

**Security Level**: LOW - Read-only code search

**Granted To**:
- **Developer** - Primary user for finding implementation patterns
- **Architect** - Architecture pattern research
- **Tester** - Test pattern research

**Restricted From**: Agents without implementation needs

**Security Notes**:
- Read-only external code search
- Useful for learning from existing implementations
- Safe for technical roles

---

### Specialized Tools (Low-Medium Security Impact)

#### NotebookEdit (MEDIUM Risk - Jupyter Notebook Modification)
**Purpose**: Edit Jupyter notebook cells (.ipynb files)

**Security Level**: MEDIUM - Can modify code and markdown cells

**Granted To**:
- **Developer** - Data science and notebook-based development
- **Analyst** - Data analysis notebooks

**Restricted From**: All other agents

**Security Notes**:
- Notebooks can contain executable code
- Primarily for data science workflows
- Review code cells before execution

## Tool Permission Matrix

| Agent | Read | Write | Edit | MultiEdit | Bash | Task | Grep | Glob | WebSearch | TodoWrite |
|-------|------|-------|------|-----------|------|------|------|------|-----------|-----------|
| **Coordinator** | ✅ | ✅* | ✅ | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Strategist** | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ | ❌ |
| **Architect** | ✅ | ❌ | ✅ | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ | ❌ |
| **Developer** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ |
| **Designer** | ✅ | ✅* | ✅ | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ | ❌ |
| **Tester** | ✅ | ❌ | ❌ | ❌ | ✅* | ✅ | ✅ | ✅ | ❌ | ✅ |
| **Documenter** | ✅ | ✅ | ✅ | ❌ | ❌ | ✅ | ✅ | ✅ | ❌ | ❌ |
| **Operator** | ✅ | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| **Analyst** | ✅ | ❌ | ❌ | ❌ | ✅* | ✅ | ✅ | ✅ | ✅ | ❌ |
| **Marketer** | ✅ | ✅* | ✅ | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ | ❌ |
| **Support** | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ | ❌ |

**Legend**:
- ✅ = Granted
- ❌ = Restricted
- ✅* = Limited scope (see notes below)

**Notes**:
- *Coordinator Write: Limited to project-plan.md, progress.md, context files only
- *Designer Write: Limited to design specification files
- *Tester Bash: Test execution only, no deployment or infrastructure commands
- *Analyst Bash: Data processing scripts only, no deployment or infrastructure
- *Marketer Write: Marketing content files only, no code/config

### MCP Permission Matrix

| Agent | github | context7 | firecrawl | supabase | stripe | railway | netlify | playwright | grep |
|-------|--------|----------|-----------|----------|--------|---------|---------|------------|------|
| **Coordinator** | ✅* | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Strategist** | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Architect** | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| **Developer** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅* | ✅* | ✅ | ✅ |
| **Designer** | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ |
| **Tester** | ✅* | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ |
| **Documenter** | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Operator** | ✅ | ❌ | ❌ | ✅ | ✅* | ✅ | ✅ | ❌ | ❌ |
| **Analyst** | ❌ | ❌ | ❌ | ❌ | ✅* | ❌ | ❌ | ❌ | ✅ |
| **Marketer** | ❌ | ❌ | ✅ | ❌ | ✅* | ❌ | ❌ | ❌ | ❌ |
| **Support** | ✅ | ❌ | ✅ | ❌ | ✅* | ❌ | ❌ | ❌ | ❌ |

**MCP Notes**:
- *Coordinator github: Project boards and issues (read-only preferred)
- *Developer railway/netlify: Development environments only
- *Tester github: Test results reporting (read-only + comment)
- *Operator stripe: Monitoring and management
- *Analyst stripe: Revenue analytics (read-only)
- *Marketer stripe: Revenue metrics (read-only)
- *Support stripe: Subscription management (read-only + support operations)

## Security Review Checklist

Before granting tool access to an agent, verify:

### 1. Need Analysis
- [ ] Does this tool directly support the agent's core function?
- [ ] Can the agent accomplish its role without this tool?
- [ ] Are there safer alternatives to this tool?
- [ ] Is this tool essential or just convenient?

### 2. Risk Assessment
- [ ] What is the worst case if this tool is misused?
- [ ] Can misuse cause data loss or corruption?
- [ ] Can misuse affect production systems?
- [ ] Can misuse create security vulnerabilities?

### 3. Scope Limitation
- [ ] Can we limit the tool to a specific scope? (e.g., read-only)
- [ ] Can we restrict file paths or command types?
- [ ] Can we require confirmation for dangerous operations?
- [ ] Have we documented the allowed use cases?

### 4. Alternative Approaches
- [ ] Can this work be delegated to another specialist via Task?
- [ ] Can we use bash scripts instead of direct tool access?
- [ ] Can we use MCPs instead of lower-level tools?
- [ ] Can we generate code instead of executing commands?

### 5. Audit Trail
- [ ] Have we documented WHY this tool is granted?
- [ ] Have we specified the security implications?
- [ ] Have we defined mitigation strategies?
- [ ] Have we set up monitoring for misuse?

## Fallback Strategies for Restricted Scenarios

### When Agent Lacks Required Tool

**Scenario**: Tester needs to modify test configuration but lacks Write/Edit permissions.

**Fallback Options**:
1. **Delegation**: Use Task to delegate to @developer for code changes
2. **Bash Script**: Generate bash script that developer can execute
3. **Code Generation**: Generate code and request developer to implement
4. **Escalation**: Report to @coordinator for permission evaluation

**Example**:
```markdown
@tester: "I've identified test configuration issues but lack Edit permissions.
Delegating to @developer to update test config:
- File: tests/config.json
- Change: Increase timeout from 5000ms to 10000ms
- Rationale: Complex E2E tests timing out"
```

---

### When MCP is Unavailable

**Scenario**: Developer needs GitHub operations but mcp__github is not configured.

**Fallback Options**:
1. **CLI Tools**: Use `gh` CLI via Bash for GitHub operations
2. **Direct API**: Use WebFetch with GitHub API
3. **Manual Process**: Generate instructions for user to execute
4. **Suggest Setup**: Recommend MCP configuration to user

**Example**:
```markdown
@developer: "mcp__github unavailable, using fallback strategy:

# Using gh CLI via Bash
gh pr create --title "Add authentication" --body "..." --base main

Note: Recommended to configure mcp__github MCP for better integration.
See: /project/deployment/scripts/mcp-setup.sh"
```

---

### When Agent Needs Elevated Permissions

**Scenario**: Architect needs to execute infrastructure analysis but lacks Bash.

**Fallback Options**:
1. **Delegate Execution**: Use Task to delegate to @operator or @developer
2. **Code Generation**: Generate analysis script for others to execute
3. **Request Permission**: Escalate to @coordinator for one-time permission
4. **Alternative Approach**: Use read-only tools (Grep, Read) for manual analysis

**Example**:
```markdown
@architect: "Need infrastructure analysis via bash commands but lack Bash permissions.

Delegating to @operator:
Task(
  subagent_type='operator',
  prompt='Analyze infrastructure: run `docker ps`, `df -h`, `top -n 1`
         Report resource usage and identify bottlenecks.'
)

Rationale: Architect should analyze results, not execute commands."
```

## Performance Optimization Through Tool Limitation

### Cognitive Load Reduction

**Problem**: Agents with 15+ available tools experience decision paralysis.

**Solution**: Limit to 5-7 primary tools per agent.

**Evidence**: Strategic review recommendation based on Claude Code best practices.

**Benefits**:
- Faster decision-making (fewer options to evaluate)
- Clearer mental model (agent knows its capabilities)
- Reduced errors (less chance of using wrong tool)
- Improved focus (tools match core function)

**Example**:
```
# BAD: Developer with 20+ tools (cognitive overload)
Tools: Read, Write, Edit, MultiEdit, Bash, Grep, Glob, LS, WebSearch, WebFetch,
       TodoWrite, NotebookEdit, Task, + 8 MCP tools = 21 tools

# GOOD: Developer with 7 primary tools (focused capability)
Primary: Read, Write, Edit, Bash, Task, Grep, Glob
MCPs (when available): github, context7, supabase, stripe
Total effective: 11 tools (7 primary + 4 MCP)
```

### Auxiliary Operations via Bash/Code Generation

**Problem**: Agents need auxiliary operations occasionally, not frequently enough to justify dedicated tools.

**Solution**: Move auxiliary operations to bash scripts or code generation.

**Example - File Analysis**:
```markdown
# Instead of: Giving all agents LS, FileInfo, StatFile, etc.
# Use: Bash script generated by agent, executed by developer

@architect: "Need file size analysis but lack specialized tools.
Generating bash script for @developer to execute:

#!/bin/bash
find src/ -type f -name '*.ts' -exec wc -l {} + | sort -rn | head -20

This identifies largest TypeScript files for refactoring analysis."
```

**Example - Data Processing**:
```markdown
# Instead of: Giving analyst specialized data tools
# Use: Python/Node script generated by analyst, executed by developer

@analyst: "Need user engagement metrics.
Generating Python script for @developer to execute:

import pandas as pd
df = pd.read_csv('analytics.csv')
print(df.groupby('user_type')['sessions'].mean())

Analyzes average sessions by user type."
```

## Coordinator Tool Permission Delegation

### Pre-Delegation Tool Availability Check

Before delegating tasks, coordinator MUST verify specialist has required tools:

**Protocol**:
1. Identify tools required for task
2. Check specialist's permitted tool set
3. If specialist lacks tools, choose one:
   - Modify task to work within specialist's tools
   - Delegate to different specialist with required tools
   - Generate code/scripts for specialist to execute
   - Request one-time permission escalation (rare)

**Example**:
```markdown
@coordinator planning delegation:

Task: "Update database schema for new feature"
Specialist: @developer
Required Tools: Bash (for migration), Edit (for schema files), mcp__supabase
Developer Tools: ✅ Bash, ✅ Edit, ✅ mcp__supabase
Decision: ✅ Developer has all required tools, proceed with delegation

---

Task: "Analyze database performance metrics"
Specialist: @analyst
Required Tools: Bash (for db queries), mcp__supabase
Analyst Tools: ✅ Bash (limited scope), ❌ mcp__supabase
Decision: ❌ Analyst lacks database access
Alternative: Delegate to @developer to extract metrics, then @analyst to analyze
```

### Alternative Approach Suggestion

When specialist lacks tools, coordinator suggests alternatives:

**Delegation Pattern**:
```markdown
Task(
  subagent_type="tester",
  prompt="Test authentication flow.

  NOTE: You lack Edit permissions for test files.
  If test modifications needed:
  1. Generate test code
  2. Delegate to @developer for implementation
  3. Verify implementation meets testing requirements

  Use Playwright MCP for E2E testing execution."
)
```

### Security Review for Unusual Tool Requests

If specialist requests tool outside their normal set:

**Coordinator Review Protocol**:
1. **Understand Request**: Why does specialist need this tool?
2. **Evaluate Risk**: What are security implications?
3. **Check Alternatives**: Can task be accomplished another way?
4. **Temporary Grant**: If justified, grant for specific task only
5. **Document Decision**: Record why tool was granted
6. **Monitor Usage**: Watch for misuse or issues

**Example**:
```markdown
@tester requests: "Need Edit permission to fix test configuration"

@coordinator analysis:
- Request Reason: Test config has syntax error blocking test execution
- Security Risk: Medium (Edit is safer than Write, specific file)
- Alternatives:
  1. Delegate to @developer (better - maintains separation)
  2. Generate fix code for developer (better - tester can verify)
  3. Temporary Edit grant (acceptable - specific file, documented)
- Decision: Delegate to @developer (maintains security boundary)

@coordinator delegation:
Task(
  subagent_type="developer",
  prompt="Fix test config syntax error identified by @tester:
  File: tests/playwright.config.ts
  Error: Missing comma after timeout property
  Change: Add comma after line 42

  @tester will verify fix enables test execution."
)
```

## Tool Permission Enforcement

### Technical Enforcement (Future Enhancement)

While currently documentation-based, future technical enforcement could include:

**Agent Definition Metadata**:
```yaml
name: developer
allowed_tools:
  - Read
  - Write
  - Edit
  - MultiEdit
  - Bash
  - Task
  - Grep
  - Glob
allowed_mcps:
  - github
  - context7
  - supabase
  - stripe
```

**Runtime Validation**:
- Check tool usage against allowlist
- Warn on restricted tool usage
- Log all tool usage for audit
- Require confirmation for high-risk operations

### Documentation-Based Enforcement (Current)

**Current Approach**: Agent profiles document permitted tools, agents self-regulate.

**Enforcement Mechanisms**:
1. **Agent Awareness**: Each agent knows its permitted tools
2. **Delegation**: Agents delegate when they lack tools
3. **Coordinator Review**: Coordinator monitors for unusual tool requests
4. **User Monitoring**: Users can review tool usage in logs

**Limitations**:
- Relies on agent following documented guidelines
- No technical barrier to tool misuse
- Requires vigilance from coordinator and users

## Future Enhancements

### 1. Dynamic Permission Elevation
- Temporary tool grants for specific tasks
- Automatic revocation after task completion
- Audit trail of all permission elevations

### 2. Tool Usage Analytics
- Track which tools each agent uses most
- Identify permission gaps (agents requesting tools frequently)
- Optimize permissions based on actual usage patterns

### 3. Security Monitoring
- Alert on unusual tool usage patterns
- Detect potential misuse or mistakes
- Automatic rollback on dangerous operations

### 4. Permission Templates
- Pre-defined tool sets for common agent types
- Easy customization for specialized agents
- Inheritance-based permission models

## References

- **CLAUDE.md**: Critical Software Development Principles (security-first development)
- **Strategic Review**: Tool surface reduction recommendation (5-7 primary tools)
- **/project/field-manual/memory-management.md**: Memory tool exclusion from context editing
- **/project/field-manual/extended-thinking-guide.md**: Cognitive load optimization
- **/project/field-manual/context-editing-guide.md**: Context preservation with memory protection

## Appendix: Agent-Specific Tool Permission Details

See individual agent profiles in `/project/agents/specialists/` for complete TOOL PERMISSIONS sections with:
- Primary tools (5-7 essential tools)
- MCP tools (when available)
- Restricted tools (not permitted)
- Security rationale (why these specific permissions)
- Fallback strategies (what to do when tools unavailable)

---

**Last Updated**: October 6, 2025
**Document Owner**: AGENT-11 Development Squad
**Security Classification**: Internal - Tool Permission Guidelines
