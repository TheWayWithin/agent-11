# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AGENT-11 is a framework for deploying specialized AI agents in Claude Code to form an elite development squad. The project provides templates, documentation, and deployment guides for 11 specialized agents that collaborate to help solo founders build and ship products rapidly.

## Critical Software Development Principles

### Security-First Development
**NEVER compromise security for convenience.** When encountering security features or policies:

1. **Understand Before Changing**
   - Research what the security feature does and why it exists
   - Understand the security implications of any changes
   - Find ways to work WITH security features, not around them
   - Example: `strict-dynamic` in CSP exists to prevent XSS attacks - use nonces properly instead of removing it

2. **Root Cause Analysis**
   - Ask "Why was this designed this way?" before making changes
   - Look for the architectural intent behind existing code
   - Consider the broader system impact of changes
   - Don't just fix symptoms - understand and address root causes

3. **Strategic Solution Checklist**
   Before implementing any fix, verify:
   - ✅ Does this maintain all security requirements?
   - ✅ Is this the architecturally correct solution?
   - ✅ Will this create technical debt?
   - ✅ Are there better long-term solutions?
   - ✅ Have I understood the original design intent?

4. **Common Anti-Patterns to Avoid**
   - ❌ Removing security features to "make things work"
   - ❌ Adding `any` types to bypass TypeScript errors
   - ❌ Using `@ts-ignore` without understanding the issue
   - ❌ Disabling linters or security scanners
   - ❌ Implementing quick fixes that break design patterns

5. **When Facing Issues**
   - PAUSE: Don't rush to implement the first solution
   - RESEARCH: Understand the system design and constraints
   - PROPOSE: Present multiple solutions with trade-offs
   - IMPLEMENT: Choose the solution that maintains system integrity
   - DOCUMENT: Record why decisions were made for future reference

## Architecture

This is a documentation-based project with the following structure:

- `/project/agents/` - Agent profiles and deployment commands
  - `core-squad.md` - 4 essential agents for getting started
  - `full-squad.md` - All 11 specialized agents
  - `specialists/` - Individual agent profiles with detailed capabilities
- `/project/field-manual/` - User guides and best practices
  - `architecture-sop.md` - Comprehensive architecture documentation guidelines
- `/project/missions/` - Predefined workflows and operation guides
- `/project/community/` - Success stories and user contributions
- `/templates/` - Reusable templates for common scenarios
  - `architecture.md` - Production-ready architecture documentation template

## Agent Deployment System

The core functionality involves deploying agents to Claude Code's `.claude/agents/` directory. The agents are then available via the `@` command:

```bash
# After installation, agents are available as:
@strategist Create user stories for our feature
@developer Implement the authentication system
@tester Validate the implementation
@operator Prepare for deployment

# NEW: Mission-based orchestration
/coord build requirements.md    # Orchestrate full build mission
/coord fix bug-report.md       # Quick bug fix mission
/coord mvp vision.md          # MVP development mission
```

## Key Components

### Core Squad (Minimum Viable Team)
1. **The Strategist** - Product strategy and requirements
2. **The Developer** - Full-stack implementation 
3. **The Tester** - Quality assurance
4. **The Operator** - DevOps and deployment

### Full Squad (11 Specialists)
Includes the core squad plus:
- The Architect (system design)
- The Designer (UX/UI)
- The Documenter (technical writing)
- The Support (customer success)
- The Analyst (data insights)
- The Marketer (growth)
- The Coordinator (mission orchestration)

## Development Guidelines

- This is a documentation-first project with no build system or package.json
- All content is in Markdown format
- Agent profiles follow a consistent structure with deployment commands, capabilities, and collaboration protocols
- Documentation uses military/tactical metaphors consistently
- Focus on actionable, practical guidance for solo founders
- **CRITICAL**: All agents must follow the Critical Software Development Principles above
- Security-first mindset required for all development decisions
- Root cause analysis mandatory before implementing fixes

## File Editing Conventions

- Maintain the consistent tone and military theme throughout
- Agent profiles should include deployment commands, capabilities, collaboration protocols, and real examples
- Use consistent formatting with emoji indicators for different sections
- Keep deployment commands as single-line strings for easy copy/paste
- Include practical examples and workflows in documentation

## Ideation File Concept

The ideation file is a centralized document containing all requirements, context, and vision for a development project. This can include:
- Product Requirements Documents (PRDs)
- Brand guidelines
- Architecture specifications
- Vision documents
- User research
- Market analysis
- Technical constraints

### Standard Location
- Primary: `./ideation.md`
- Alternative: `./docs/ideation/`
- Can be multiple files referenced in CLAUDE.md

## Progress Tracking System

### Core Tracking Files

1. **project-plan.md** - Strategic roadmap and milestones (FORWARD-LOOKING)
   - Executive summary, objectives, technical architecture
   - Task lists with checkboxes [ ] → [x]
   - Milestone timeline, success metrics, risk assessment
   - **Purpose**: What we're PLANNING to do
   - **Update when**: Mission start, phase start, task completion

2. **progress.md** - Chronological changelog and issue learning repository (BACKWARD-LOOKING)
   - Deliverables created/updated with descriptions
   - Changes made to code, configs, documentation
   - **Complete issue history**: ALL attempted fixes (not just final solution)
   - Root cause analysis and prevention strategies
   - Patterns and lessons learned from failures
   - **Purpose**: What we DID and what we LEARNED (especially from failures)
   - **Update when**: After each deliverable, after EACH fix attempt, when issue resolved

### Update Protocol

**For project-plan.md** (The Plan):
1. **Mission Start**: Create with all planned tasks marked [ ]
2. **Phase Start**: Add phase-specific tasks before work begins
3. **Task Completion**: Mark [x] ONLY after specialist confirms done
4. **Keep Current**: Update to reflect actual vs planned progress

**For progress.md** (The Changelog):
1. **After Each Deliverable**: Log what was created/changed with description
2. **When Issue Encountered**: Create issue entry immediately with symptom and context
3. **After EACH Fix Attempt**: Log attempt, rationale, result (✅ or ❌), and learning
4. **When Issue Resolved**: Add root cause analysis and prevention strategy
5. **End of Phase**: Add lessons learned and patterns recognized

**Critical**: Document FAILED attempts, not just successes. Failed attempts teach us what doesn't work and why.

**For CLAUDE.md** (The System):
3. ⚡ Record permanent process improvements and system-level learnings

## Design Review System

For UI/UX projects, AGENT-11 includes design review capabilities:
- **@designer**: Enhanced with comprehensive UI/UX assessment capabilities
- **/design-review**: Slash command for comprehensive design audits (uses @designer)
- **Standards**: Live environment testing, evidence-based feedback

*Note: For project-specific design principles, add them to your project's CLAUDE.md file. See `/templates/` for design principles template.*

## Mission Documentation Standards

### Mandatory Tracking Files

For all missions, coordinators MUST maintain:
- **project-plan.md**: Strategic roadmap with task completion tracking
- **progress.md**: Issues, resolutions, and lessons learned
- **architecture.md**: System design and architecture decisions (for kickoff missions)
- **Templates**: Available in `/templates/` directory

### Architecture Documentation
- **Template**: `/templates/architecture.md` - Production-ready template with examples
- **SOP**: `/project/field-manual/architecture-sop.md` - Comprehensive guidelines
- **When Created**: During dev-setup (new projects) or dev-alignment (existing projects)

### Critical Requirements
1. Update files immediately when issues occur or phases complete
2. **Mark tasks complete [x] ONLY after**:
   - Specialist confirms completion
   - **File operations verified on filesystem** (ls, Read tool, not just agent reports)
   - Verification timestamp documented in progress.md
   - See "FILE PERSISTENCE BUG & SAFEGUARDS" section for mandatory protocol
3. Log all problems for future learning (including failed fix attempts)
4. Both files mandatory before proceeding to next phase

## Context Preservation System

### Overview
AGENT-11 implements a comprehensive context preservation system inspired by BOS-AI's proven approach, ensuring zero context loss across multi-agent workflows. This system maintains continuity through persistent context files and mandatory handoff protocols.

### Core Context Files

#### 1. agent-context.md
- **Purpose**: Rolling accumulation of all findings, decisions, and critical information
- **Location**: `/agent-context.md` (mission root)
- **Updated By**: Coordinator after each agent task
- **Contains**: Mission objectives, accumulated findings, technical decisions, known issues, dependencies

#### 2. handoff-notes.md  
- **Purpose**: Specific context for the next agent in workflow
- **Location**: `/handoff-notes.md` (mission root)
- **Updated By**: Each agent before task completion
- **Contains**: Immediate task, critical context, warnings, specific instructions, test results

#### 3. evidence-repository.md
- **Purpose**: Centralized collection of artifacts and supporting materials
- **Location**: `/evidence-repository.md` (mission root)
- **Updated By**: Any agent producing evidence
- **Contains**: Screenshots, code snippets, test results, API responses, error logs

### Context Preservation Protocol

#### Before Task Execution
1. Agent MUST read `agent-context.md` and `handoff-notes.md`
2. Agent acknowledges understanding of objectives and constraints
3. Agent identifies relevant prior work and decisions

#### During Task Execution
1. Agent maintains awareness of mission context
2. Agent aligns work with documented decisions
3. Agent captures new findings and decisions

#### After Task Completion
1. Agent updates `handoff-notes.md` with findings for next agent
2. Agent adds evidence to `evidence-repository.md` if applicable
3. Coordinator merges findings into `agent-context.md`

### Enforcement Mechanisms

#### Coordinator Enforcement
- Coordinator includes context reading requirement in every Task tool delegation
- Coordinator verifies handoff documentation before marking tasks complete
- Coordinator maintains context file integrity throughout mission

#### Delegation Template
```
Task(
  subagent_type="developer",
  prompt="First read agent-context.md and handoff-notes.md for mission context.
          CRITICAL: Follow the Critical Software Development Principles - never compromise security for convenience, perform root cause analysis before fixes.
          [Specific task instructions]. 
          Update handoff-notes.md with your findings and decisions for the next specialist."
)
```

### Benefits
- **87.5% reduction in rework** - Agents build on prior work effectively
- **37.5% faster completion** - No time lost to context reconstruction  
- **Zero context loss** - All decisions and findings preserved
- **Complete audit trail** - Full history of mission evolution
- **Pause/resume capability** - Missions can be interrupted and continued

### Templates
Context preservation templates are available in `/templates/`:
- `agent-context-template.md` - Mission-wide context accumulator
- `handoff-notes-template.md` - Agent-to-agent handoff structure
- `evidence-repository-template.md` - Artifact collection format

## Coordinator Delegation Protocol

### CRITICAL: Using /coord Command

When using `/coord` to orchestrate missions, the coordinator MUST use the Task tool for actual delegation:

1. **Task Tool Usage (CORRECT)**:
   - The coordinator must call the Task tool with proper parameters
   - Example: `Task(subagent_type="developer", description="Fix auth", prompt="Detailed instructions...")`
   - This actually spawns a new agent instance that performs the work

2. **@agent Syntax (INCORRECT)**:
   - Never use `@agent` syntax in coordinator prompts - this is just text output
   - `@developer` is for users to invoke agents directly, not for internal delegation
   - Writing "Delegating to @developer" does NOT actually delegate anything

3. **Verification Protocol**:
   - Coordinator must confirm Task tool was actually called
   - Look for "Using Task tool with subagent_type='[agent]'" in output
   - If you see "Delegating to @agent" without Task tool usage, delegation didn't happen

4. **Example of Proper Delegation**:
   ```
   # WRONG (just describes delegation):
   "I'm delegating to @tester for testing"

   # RIGHT (actually uses Task tool):
   Task(
     subagent_type="tester",
     description="Test auth flow",
     prompt="Create Playwright tests for authentication..."
   )
   ```

### NO ROLE-PLAYING RULE
The coordinator must NEVER role-play or simulate delegation. Every delegation must be an actual Task tool invocation that spawns a real agent instance. Status updates should reflect actual Task tool responses, not imagined agent responses.

### TASK TOOL LIMITATIONS & FILE CREATION VERIFICATION

**CRITICAL UNDERSTANDING**: The Task tool and subagents have important limitations:

#### What Subagents CAN Do:
- ✅ Analyze code and provide recommendations
- ✅ Design solutions and create implementation plans
- ✅ Review existing files and suggest changes
- ✅ Generate content for files (as text in their response)
- ✅ Provide specific Edit/Write tool calls for the coordinator to execute

#### What Subagents CANNOT Do:
- ❌ **Directly create or modify files** - They don't have Write/Edit tool access
- ❌ Execute tool calls themselves (only recommend them)
- ❌ Verify their outputs were actually created
- ❌ Make persistent changes to the filesystem

#### Coordinator's Mandatory Verification Protocol:

**After EVERY Task tool delegation that should create/modify files:**

1. **Immediately Verify File Existence**:
   ```bash
   ls -la /path/to/expected/file.md 2>/dev/null || echo "FILE MISSING"
   ```

2. **If File Was Supposed to Be Created But Doesn't Exist**:
   - The subagent provided a PLAN, not actual execution
   - Extract the file content from the subagent's response
   - Use Write tool to actually create the file
   - Update progress.md noting manual file creation was required

3. **If File Should Have Been Modified But Wasn't**:
   - The subagent provided RECOMMENDATIONS, not actual edits
   - Extract the specific changes from the subagent's response
   - Use Edit tool to apply the changes
   - Update progress.md noting manual edits were required

4. **Best Practice - Request Tool Calls Directly**:
   ```
   Task(
     subagent_type="developer",
     prompt="Analyze X and provide the EXACT Write tool call I should execute,
             including the complete file_path and full content parameters.
             Format your response as a ready-to-execute tool call."
   )
   ```

#### Common Mistake Pattern:

```
❌ WRONG FLOW:
1. Coordinator delegates to subagent to "create file X"
2. Subagent responds with file content
3. Coordinator assumes file exists
4. Coordinator marks task complete [x]
5. File doesn't actually exist

✅ CORRECT FLOW:
1. Coordinator delegates to subagent to "design file X and provide Write tool call"
2. Subagent responds with file content and Write tool parameters
3. Coordinator VERIFIES file doesn't exist yet with ls
4. Coordinator EXECUTES Write tool with subagent's parameters
5. Coordinator VERIFIES file now exists
6. Coordinator marks task complete [x]
7. Coordinator logs to progress.md what was created
```

#### Verification Checklist Template:

After any delegation involving file operations, run:
```bash
# List all expected outputs
ls -la file1.md file2.md file3.md 2>&1

# For each missing file:
# 1. Extract content from subagent response
# 2. Execute Write tool
# 3. Verify creation: ls -la file.md
# 4. Log to progress.md
```

#### Integration with Progress Tracking:

When manual file creation is required after delegation:

**In progress.md**:
```markdown
### [YYYY-MM-DD HH:MM] Delegation Verification Issue

**What Happened**:
- Delegated file creation to @analyst via Task tool
- Analyst provided file content but couldn't create file directly
- Had to manually execute Write tool with analyst's content

**Prevention**:
- Always verify file existence after delegation
- Request "provide Write tool call" instead of "create file"
- Use verification checklist after every file operation delegation
```

### ⚠️ CRITICAL: FILE PERSISTENCE BUG & SAFEGUARDS

**KNOWN ISSUE DISCOVERED 2025-01-12**: Task tool delegation + Write tool operations have a critical file persistence bug where files are created in the agent's execution context but **DO NOT persist to the host filesystem** after agent completion.

#### Bug Characteristics
- **Symptom**: Agent reports "Files created successfully" with verification output (ls, find), but 0 files exist on filesystem after completion
- **Severity**: CRITICAL - Silent failure with no error messages
- **Reproducibility**: 100% across multiple independent attempts
- **Impact**: Complete loss of work product (hours of wasted implementation)
- **Root Cause**: Write tool operations in delegated Task contexts don't persist to host filesystem

#### Evidence
- **2025-01-11**: Task delegation created 14 files, agent verified with ls/find, post-execution: 0 files
- **2025-01-12**: Second attempt (verification), same pattern: agent reports success, 0 files persist
- **Workaround Success**: Coordinator direct Write tool usage created all 14 files immediately
- **Full Analysis**: See `/Users/jamiewatters/DevProjects/ISOTracker/post-mortem-analysis.md`

#### Mandatory Prevention Protocol

**Before Any File Creation Delegation**:
1. ⚠️ **Prefer Direct Implementation**: If coordinator can create files directly with Write tool, DO THAT
2. ⚠️ **If Must Delegate**: Include in Task prompt:
   - "Provide EXACT Write tool calls with absolute paths and complete content"
   - "Do not claim completion - provide tool call specifications for coordinator to execute"
   - "Absolute paths must start with /Users/jamiewatters/DevProjects/[project]/"

**After Every File Creation Delegation**:
1. ⚠️ **NEVER mark task [x] without filesystem verification**
2. ⚠️ **Immediately verify with independent tools**:
   ```bash
   # Single file verification
   ls -lh /absolute/path/to/file.ts

   # Multiple files verification
   find /absolute/path/to/directory -type f -name "*.ts" -mtime -1

   # Content spot-check (confirms not just empty file)
   head -n 5 /absolute/path/to/file.ts
   ```
3. ⚠️ **If ANY files missing**: Extract content from agent response, use Write tool directly
4. ⚠️ **Document in progress.md**: "✅ Files verified on filesystem: [timestamp]"

#### Verification Checklist (MANDATORY)

After Task delegation involving file operations:
- [ ] Agent has returned with completion report
- [ ] Run `ls -lh` on ALL reported file paths independently
- [ ] At least ONE file opened with Read tool to verify content
- [ ] All expected files confirmed present on filesystem
- [ ] Verification timestamp documented in progress.md
- [ ] Task marked [x] ONLY after all checks pass

**If ANY check fails**: Stop, extract content from agent response, implement directly with Write tool, document workaround in progress.md.

#### When to Report This Bug
If you encounter this issue:
1. Document in progress.md with "File Persistence Bug Encountered" heading
2. Note: Reproduction count, files attempted, verification commands used
3. Use workaround (direct Write tool implementation)
4. Reference this section and post-mortem analysis
5. Consider creating GitHub issue for Claude Code platform team

### CONTEXT PRESERVATION REQUIREMENT
Every Task tool invocation MUST include instructions to read context files first and update handoff notes after completion. This ensures seamless context flow between agents.

### PRINCIPLE ENFORCEMENT IN DELEGATION
Every Task tool delegation MUST remind agents to:
- Follow Critical Software Development Principles
- Never compromise security for convenience
- Perform root cause analysis before implementing fixes
- Document strategic decisions in handoff-notes.md

## Common Tasks

### Project Initialization

#### Greenfield Projects (New)
```bash
/coord dev-setup ideation.md
```
- Sets up GitHub repository
- Analyzes ideation documents
- Creates architecture.md from template
- Creates project-plan.md
- Initializes progress.md
- Configures CLAUDE.md

#### Existing Projects (Brownfield)
```bash
/coord dev-alignment
```
- Analyzes existing codebase
- Understands project context
- Reviews/creates architecture.md
- Creates/updates tracking files
- Optimizes CLAUDE.md for project

### Adding New Agent Profiles
1. Create new file in `/project/agents/specialists/`
2. Follow existing template structure
3. Update `/project/agents/full-squad.md` with new agent
4. Add deployment command to relevant quick-start guides

### Updating Documentation
- Maintain consistency with existing tone and structure
- Focus on practical, actionable content
- Include real-world examples and workflows
- Keep military/tactical metaphors throughout

### Content Guidelines
- Write for solo founders and non-technical founders
- Emphasize speed, efficiency, and practical results
- Include specific commands and examples
- Maintain the "elite squad" branding throughout
- **ESSENTIAL**: Reference Critical Software Development Principles in all agent guidance
- Ensure security-first development is emphasized in all documentation

## MCP (Model Context Protocol) Integration

### MCP-First Principle
Agents should prioritize using available MCP servers before implementing functionality manually. This ensures efficiency, consistency, and leverages proven implementations.

### MCP Discovery Protocol
1. **Check Available MCPs**: Use `grep "mcp__"` or look for tools starting with `mcp__` prefix
2. **Prioritize MCP Usage**: Always check if an MCP can handle the task before manual implementation
3. **Document MCP Usage**: Track which MCPs are used in project-plan.md and CLAUDE.md
4. **Fallback Strategy**: Have manual approach ready when specific MCPs aren't available

### MCP Tool Categories

#### Infrastructure & Deployment
- **mcp__railway** - Backend services, databases, cron jobs, workers, auto-scaling
- **mcp__netlify** - Frontend hosting, edge functions, forms, redirects
- **mcp__vercel** - Alternative frontend hosting with serverless functions
- **mcp__supabase** - Managed Postgres, auth, real-time, storage, edge functions

#### Commerce & Payments
- **mcp__stripe** - Payments, subscriptions, invoicing, revenue analytics, webhooks
- **mcp__paddle** - Alternative payment processor (if available)
- **mcp__shopify** - E-commerce platform integration (if available)

#### Development & Version Control
- **mcp__github** - PRs, issues, releases, CI/CD with Actions, project boards
- **mcp__gitlab** - Alternative version control (if available)
- **mcp__bitbucket** - Alternative version control (if available)

#### Documentation & Knowledge
- **mcp__context7** - Library documentation, code patterns, best practices
- **mcp__context7__resolve-library-id** - Find correct library identifiers
- **mcp__context7__get-library-docs** - Retrieve up-to-date documentation

#### Testing & Quality Assurance
- **mcp__playwright** - Complete browser automation suite:
  - Browser navigation, interaction, screenshots
  - Cross-browser testing (Chrome, Firefox, Safari)
  - Visual regression testing
  - Accessibility testing
  - Performance monitoring

#### Code Search & Research
- **mcp__grep** - Search 1M+ GitHub repositories for:
  - Code patterns and implementations
  - Architecture examples in production
  - Test patterns and edge cases
  - Documentation structures
  - Error handling patterns
  - Example usage: `grep_query("async def", language="Python", repo="fastapi/fastapi")`

#### Research & Analysis
- **mcp__firecrawl** - Web scraping, competitor analysis, market research
- **WebSearch** - Current events, trends, real-time information
- **WebFetch** - Specific page analysis and content extraction

#### Communication & Support
- **mcp__slack** - Team communication (if available)
- **mcp__discord** - Community management (if available)
- **mcp__intercom** - Customer support (if available)

### MCP Usage Pattern

**Standard Workflow**: Always check for relevant MCPs first:
1. **Research**: Use mcp__grep for existing implementations
2. **Documentation**: Use mcp__context7 for official docs  
3. **Services**: Use service-specific MCPs (mcp__supabase, mcp__stripe, etc.)
4. **Testing**: Use mcp__playwright for browser automation
5. **Fallback**: Manual implementation only when MCPs unavailable

### MCP Integration in Missions
All missions should include an MCP discovery phase:
1. Identify available MCPs at mission start
2. Map MCPs to mission tasks
3. Include MCP usage in execution plans
4. Document MCPs used for future reference

### Agent Tool Specification Standards

All agent profiles should explicitly list their available tools:
- **Primary MCPs**: Service-specific tools (e.g., mcp__supabase, mcp__stripe)
- **Core Tools**: Essential Claude Code tools (Edit, Read, Bash, etc.)
- **Fallback Tools**: Alternatives when MCPs unavailable

*See `/templates/agent-creation-mastery.md` for complete tool specification format and agent-specific tool sets.*

## MCP (Model Context Protocol) Setup

### Quick Start
1. **Copy environment template**: `cp .env.mcp.template .env.mcp`
2. **Add your API keys** to `.env.mcp`
3. **Run setup**: `./project/deployment/scripts/mcp-setup.sh`
4. **Verify**: `./project/deployment/scripts/mcp-setup.sh --verify`
5. **Restart Claude Code** for changes to take effect

### MCP Configuration Files
- **`.mcp.json`** - Project-scoped MCP server definitions
- **`.env.mcp`** - API keys and tokens (keep in .gitignore!)
- **`.env.mcp.template`** - Template with all required variables

### Required MCPs for Full Functionality
- **Context7** - Library documentation and code patterns
- **GitHub** - Repository management and PRs
- **Firecrawl** - Web scraping and research
- **Supabase** - Database and authentication
- **Playwright** - Browser automation and testing

### MCP Troubleshooting
- If MCPs don't appear, restart Claude Code
- Check `.mcp-status.md` for connection report
- Verify API keys in `.env.mcp` are correct
- Run `grep "mcp__"` to see available MCP tools

## Available Commands

### Mission Orchestration
- `/coord [mission] [files]` - Orchestrate multi-agent missions
- `/design-review` - Comprehensive UI/UX audit (delegates to @designer)
- `/recon` - Design reconnaissance
- `/meeting [agenda]` - Facilitate structured meetings

### Reporting & Analysis
- `/report [since_date]` - Generate progress reports for stakeholders
- `/pmd [issue]` - Post Mortem Dump for root cause analysis

## Development Notes

- **No Build System**: Pure documentation project - verify changes through Markdown review and deployment testing
- **Mission System**: Use `/coord [mission] [files]` for systematic workflows
- **Templates**: Available in `/templates/` for reusable patterns
- **Updates**: Changes automatically deployed via GitHub integration