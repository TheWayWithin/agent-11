# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AGENT-11 is a framework for deploying specialized AI agents in Claude Code to form an elite development squad. The project provides templates, documentation, and deployment guides for 11 specialized agents that collaborate to help solo founders build and ship products rapidly.

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

1. **project-plan.md** - Strategic roadmap and milestones
   - Executive summary, objectives, technical architecture
   - Milestone timeline, success metrics, risk assessment

2. **progress.md** - Operational log and learnings
   - Issues and resolutions, lessons learned
   - Technical decisions and performance insights

### Update Protocol

After each work session or milestone:
1. ✅ Mark completed tasks in `project-plan.md`
2. 📝 Log issues, resolutions, and lessons in `progress.md`
3. ⚡ Record performance insights and optimizations in `CLAUDE.md`

## Design Review System

For UI/UX projects, AGENT-11 includes design review capabilities:
- **@designer**: Enhanced with comprehensive UI/UX assessment
- **@design-review**: Dedicated agent for design audits (when available)
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
2. Mark tasks complete [x] only after specialist confirmation
3. Log all problems for future learning
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

### CONTEXT PRESERVATION REQUIREMENT
Every Task tool invocation MUST include instructions to read context files first and update handoff notes after completion. This ensures seamless context flow between agents.

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
- `/design-review` - Comprehensive UI/UX audit
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