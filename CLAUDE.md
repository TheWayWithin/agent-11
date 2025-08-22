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
- `/project/field-manual/` - User guides and best practices (minimal content currently)
- `/project/missions/` - Predefined workflows and operation guides
- `/project/community/` - Success stories and user contributions
- `/project/templates/` - Reusable templates for common scenarios

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

## Design Review System

### Automated Design Reviews

AGENT-11 includes a comprehensive design review system based on OneRedOak's best practices:

#### Quick Design Review
```bash
/design-review
```
Executes systematic UI/UX assessment of current branch changes using the RECON Protocol.

#### Specialized Agents
- **@design-review**: Dedicated agent for comprehensive design audits
- **@designer**: Enhanced with RECON Protocol capabilities
- **/recon**: UI/UX reconnaissance command for detailed assessment

#### Review Standards
The system applies world-class standards from companies like Stripe, Airbnb, and Linear:

1. **Live Environment First**: Interactive testing prioritized over static analysis
2. **Problems Over Prescriptions**: Describe issues, not technical solutions
3. **Evidence-Based**: Screenshot proof for all visual findings
4. **Systematic Protocol**: 7-phase comprehensive evaluation process

#### Design Principles Integration
Store your project's design principles in this CLAUDE.md file for consistent application:

```markdown
## Project Design Principles

### Brand Guidelines
- Primary Color: [Your brand color]
- Secondary Color: [Supporting color]
- Typography: [Primary font family]
- Voice & Tone: [Brand personality]

### UI Standards
- Design System: [Link or description]
- Component Library: [Location/documentation]
- Accessibility Level: WCAG AA+ (minimum)
- Performance Targets: FCP < 1.8s, LCP < 2.5s

### User Experience Priorities
1. [Primary user goal]
2. [Secondary user goal]
3. [Key conversion metrics]

### Quality Gates
- [ ] Cross-browser compatibility (Chrome, Firefox, Safari)
- [ ] Mobile-first responsive design
- [ ] Keyboard navigation complete
- [ ] Screen reader tested
- [ ] Color contrast validated (4.5:1 minimum)

### Innovation Principles
*"Think Different" - Challenge conventions and push boundaries*
- [ ] Questions existing patterns and assumptions
- [ ] Creates breakthrough user experiences
- [ ] Advances the state of interface design
- [ ] Makes meaningful difference to users
- [ ] Pushes the human experience forward
```

## Project Documentation Standards

### Mandatory File Management

AGENT-11 coordinators MUST maintain two critical files for all missions:

#### project-plan.md
- **Purpose**: Track planned vs actual task completion
- **Update Triggers**: Mission start, phase start, task completion, phase end
- **Required Elements**: All tasks marked [ ] or [x], agent assignments, deliverables
- **Template**: See `/templates/project-plan-template.md`

#### progress.md  
- **Purpose**: Log issues, root causes, resolutions, and learnings
- **Update Triggers**: Issue encountered, root cause found, problem resolved, phase complete
- **Required Elements**: Issue descriptions, root causes, fixes, lessons learned
- **Template**: See `/templates/progress-template.md`

### File Update Protocol
1. **NEVER skip updates** - both files are mandatory for mission tracking
2. **Update immediately** when issues occur or phases complete
3. **Mark tasks complete [x]** only after specialist confirmation
4. **Log all problems** to progress.md for future learning
5. **Phase end requirement** - update both files before proceeding

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

### MCP Usage Examples

#### For Developers
```bash
# Before implementing any feature:
# 1. Search mcp__grep for existing implementations
# 2. Check for relevant service MCPs (supabase, stripe, etc.)
# 3. Use mcp__context7 for official documentation
# Example: grep_query("authentication middleware", language="TypeScript")
```

#### For Architects
```bash
# Before designing new patterns:
# 1. Use mcp__grep to find production architecture examples
# 2. Use mcp__context7 to research proven patterns
# 3. Use mcp__firecrawl for competitor analysis
# Example: grep_query("microservice architecture", language="Go")
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

### Agent Tool Specification Standards

All agent profiles MUST explicitly list their available tools to ensure optimal performance:

#### Required Tool Sections
1. **Primary MCPs** - MCP tools that should be checked first (mcp__ prefix)
2. **Core Tools** - Essential Claude Code tools for the agent's function
3. **Fallback Tools** - Alternative tools when MCPs are unavailable

#### Tool Listing Format
```markdown
AVAILABLE TOOLS:
Primary MCPs (Always check these first):
- mcp__railway - Backend deployment, services, databases
- mcp__stripe - Payment processing, subscriptions
- mcp__supabase - Database, auth, real-time features
[Additional MCPs relevant to agent]

Core Tools:
- Edit, MultiEdit - Code modification
- Write, Read - File operations
- Bash - Command execution
[Additional core tools]

Fallback Tools:
- WebSearch - When MCPs unavailable
- WebFetch - Manual documentation
- Task - Complex workflows
```

#### Agent-Specific Tool Sets

**Developers**: Grep, Railway, Stripe, Supabase, GitHub, Context7, Firecrawl + code editing tools
**Testers**: Playwright (all functions), Grep, Context7, Stripe, Railway + testing tools
**Operators**: Railway, Netlify, Supabase, Stripe, GitHub + infrastructure tools
**Strategists**: Firecrawl, Context7, Stripe, GitHub + research tools
**Designers**: Playwright (browser functions), Firecrawl, Context7 + design tools
**Architects**: Grep, Context7, Firecrawl, Railway, Supabase + analysis tools
**Documenters**: Grep, Context7, GitHub, Firecrawl + documentation tools
**Others**: Tailored tool sets based on their specific responsibilities

## No Build/Test Commands

This project has no build system, package management, or automated testing since it's purely documentation-based. Changes can be verified by:
- Reviewing Markdown formatting
- Testing deployment commands in Claude Code
- Validating links and references between files