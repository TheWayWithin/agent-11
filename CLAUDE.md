# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AGENT-11 is a framework for deploying specialized AI agents in Claude Code to form an elite development squad. The project provides templates, documentation, and deployment guides for 11 specialized agents that collaborate to help solo founders build and ship products rapidly.

## Architecture

This is a documentation-based project with the following structure:

- `/agents/` - Agent profiles and deployment commands
  - `core-squad.md` - 4 essential agents for getting started
  - `full-squad.md` - All 11 specialized agents
  - `specialists/` - Individual agent profiles with detailed capabilities
- `/field-manual/` - User guides and best practices (minimal content currently)
- `/missions/` - Predefined workflows and operation guides
- `/community/` - Success stories and user contributions
- `/templates/` - Reusable templates for common scenarios

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
   - Executive summary
   - Objectives and goals
   - Technical architecture
   - Milestone timeline
   - Success metrics
   - Risk assessment

2. **progress.md** - Operational log and learnings
   - Completed milestones
   - Current sprint status
   - Issues and resolutions
   - Lessons learned
   - Technical decisions
   - Performance insights

### Update Protocol

After each work session or milestone:
1. ✅ Mark completed tasks in `project-plan.md`
2. 📝 Log issues and resolutions in `progress.md`
3. 💡 Document lessons learned in `progress.md`
4. ⚡ Record performance insights in both `progress.md` and `CLAUDE.md`
5. 🔧 Update `CLAUDE.md` with any new patterns, decisions, or optimizations

### Performance-Driving Insights

When updating CLAUDE.md, include:
- Discovered optimization opportunities
- Successful patterns and approaches
- Performance bottlenecks and solutions
- Architecture decisions and rationale
- Testing strategies that work
- Deployment optimizations

## Common Tasks

### Project Initialization

#### Greenfield Projects (New)
```bash
/coord dev-setup ideation.md
```
- Sets up GitHub repository
- Analyzes ideation documents
- Creates project-plan.md
- Initializes progress.md
- Configures CLAUDE.md

#### Existing Projects (Brownfield)
```bash
/coord dev-alignment
```
- Analyzes existing codebase
- Understands project context
- Creates/updates tracking files
- Optimizes CLAUDE.md for project

### Adding New Agent Profiles
1. Create new file in `/agents/specialists/`
2. Follow existing template structure
3. Update `/agents/full-squad.md` with new agent
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

### Common MCPs by Function

#### Development Stack
- **mcp__github**: PRs, issues, releases, repository management
- **mcp__context7**: Library documentation, code patterns, best practices
- **mcp__supabase**: Database operations, authentication, real-time features
- **mcp__firecrawl**: Web scraping, API research, documentation extraction
- **mcp__playwright**: Browser automation, E2E testing
- **mcp__netlify**: Deployment, hosting configuration
- **mcp__railway**: Backend services, infrastructure

#### Testing & Quality
- **mcp__playwright**: Cross-browser testing, visual regression, user flows
- **mcp__context7**: Test framework documentation, coverage analysis
- **Memory MCPs**: Test result persistence, pattern tracking

#### Research & Documentation
- **mcp__firecrawl**: Competitor analysis, market research, documentation extraction
- **mcp__context7__resolve-library-id**: Find correct library identifiers
- **mcp__context7__get-library-docs**: Retrieve up-to-date documentation
- **WebSearch**: Current events, recent updates

#### Infrastructure & Operations
- **mcp__supabase**: Database and authentication infrastructure
- **mcp__netlify**: Frontend deployment and hosting
- **mcp__railway**: Backend service deployment
- **mcp__stripe**: Payment processing (when applicable)

### MCP Usage Examples

#### For Developers
```bash
# Before implementing Supabase integration manually:
# 1. Check for Supabase MCP
# 2. Use mcp__supabase for database operations
# 3. Use mcp__context7 for Supabase documentation
```

#### For Architects
```bash
# Before designing new patterns:
# 1. Use mcp__context7 to research proven patterns
# 2. Use mcp__firecrawl for competitor analysis
# 3. Document MCP availability in architecture decisions
```

#### For Testers
```bash
# For E2E testing:
# 1. Prioritize mcp__playwright for browser automation
# 2. Use mcp__context7 for Playwright documentation
# 3. Only write custom scripts if MCP unavailable
```

### MCP Integration in Missions
All missions should include an MCP discovery phase:
1. Identify available MCPs at mission start
2. Map MCPs to mission tasks
3. Include MCP usage in execution plans
4. Document MCPs used for future reference

## No Build/Test Commands

This project has no build system, package management, or automated testing since it's purely documentation-based. Changes can be verified by:
- Reviewing Markdown formatting
- Testing deployment commands in Claude Code
- Validating links and references between files