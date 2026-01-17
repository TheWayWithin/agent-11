# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

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

### Session Resumption Protocol [PREVENTS REPEATED WORK]

**When starting a new session or resuming work**, Claude MUST check for file staleness before doing any new work:

1. **Read tracking files**: project-plan.md, progress.md, handoff-notes.md
2. **Compare timestamps**: Do they tell a consistent story?
3. **Check for staleness indicators**:
   - Tasks marked [ ] but handoff says "completed"
   - progress.md timestamp older than handoff-notes.md
   - Phase X tasks [ ] but "Phase X Complete" entry in progress.md
4. **If staleness detected**: Update stale files FIRST, then proceed

**Why This Matters**: Without this check, Claude may read outdated project-plan.md showing [ ] tasks and attempt to repeat work that was already completed in a previous session.

### Phase Gate Enforcement [MANDATORY]

**Before transitioning between phases**, coordinators MUST verify:
- ALL current phase tasks marked [x] with timestamps in project-plan.md
- Phase completion entry EXISTS in progress.md with timestamp
- handoff-notes.md updated with "Last Updated: [timestamp]"
- agent-context.md has phase findings merged

**Cannot proceed to next phase if ANY gate check fails.** Update files first, then re-run gate.

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

## Structured Context System (Foundations v2.0)

### Overview
The `/foundations` command extracts BOS-AI foundation documents (PRD, Vision, ICP, Brand, Marketing) into structured YAML that agents can parse directly. This replaces the previous token-budgeted summary approach which caused 50%+ data loss.

**Key Principle**: Extract complete, structured data that agents can parse directly - not lossy prose summaries.

### Why Structured YAML?

| Approach | Data Preservation | Agent Usability |
|----------|-------------------|-----------------|
| Token-budgeted summaries (v1.0) | 25-65% | Requires NLP interpretation |
| Structured YAML extraction (v2.0) | 100% | Direct parsing, no interpretation |

### Directory Structure

```
project-root/
├── documents/foundations/        # Source BOS-AI documents
│   ├── prd.md
│   ├── vision-mission.md
│   ├── client-success-blueprint.md
│   ├── brand-style-guidelines.md
│   └── marketing-bible.md
├── .context/structured/          # Extracted YAML (agent-parseable)
│   ├── prd.yaml
│   ├── vision.yaml
│   ├── roadmap.yaml
│   ├── icp.yaml
│   ├── brand.yaml
│   └── marketing.yaml
└── handoff-manifest.yaml         # Extraction metadata
```

### Schema Reference

Foundation extraction schemas are in `project/schemas/`:
- `foundation-prd.schema.yaml` - Product, features, tech stack, pricing
- `foundation-vision.schema.yaml` - Vision, mission, hedgehog concept, goals
- `foundation-roadmap.schema.yaml` - Strategic roadmap, phases, decision framework, resource planning
- `foundation-icp.schema.yaml` - Personas, pain points, jobs to be done
- `foundation-brand.schema.yaml` - Colors, typography, components, design system
- `foundation-marketing.schema.yaml` - Positioning, messaging, channels

### Agent Context Loading

Agents load foundation context via selective YAML sections:

```yaml
# Example: What designer needs
context:
  brand:
    - colors.primary
    - colors.secondary
    - typography.primary
    - components.buttons
  prd:
    - features.p0_must_have

# Example: What coordinator/strategist needs
context:
  roadmap:
    - strategic_foundation
    - phases
    - decision_framework
    - resource_planning
  vision:
    - hedgehog_concept
    - value_proposition
```

### Mission-to-Context Mapping

| Mission Type | Context Needed |
|--------------|----------------|
| build/mvp | prd.features, prd.tech_stack, roadmap.phases, brand.colors, brand.components |
| design-review | brand.*, icp.personas |
| marketing | marketing.*, vision.value_proposition |
| strategy | vision.*, roadmap.strategic_foundation, roadmap.decision_framework, icp.pain_points |
| planning | roadmap.phases, roadmap.implementation_framework, roadmap.resource_planning, prd.features |
| architecture | prd.tech_stack, roadmap.keystone_products, vision.hedgehog_concept |

### Commands

```bash
# Initialize - scan, extract, generate manifest
/foundations init

# Check status of all documents
/foundations status

# Re-extract changed documents
/foundations refresh

# Validate completeness
/foundations validate
```

### Migration from v1.0

If upgrading from token-budgeted summaries:
1. Delete `.context/summaries/` directory
2. Run `/foundations init` to create new structured extractions
3. Old `handoff-manifest.json` replaced by `handoff-manifest.yaml`
4. Agents now load YAML sections directly

## Coordinator Delegation Protocol

**Full Documentation**: See `/project/field-manual/coordinator-protocol.md`

### Key Rules
1. **Use Task tool** for delegation, not `@agent` syntax
2. **Verify files** exist after delegation - subagents cannot create files directly
3. **Use Sprint 2 structured output** - specialists return JSON, coordinator executes
4. **Read context files** before delegating, update handoff notes after

### Quick Reference

| What | Correct | Incorrect |
|------|---------|-----------|
| Delegation | `Task(subagent_type="developer", ...)` | "Delegating to @developer" |
| File creation | Coordinator executes Write tool | Assuming subagent created file |
| Verification | `ls -la /path/to/file` after delegation | Trust agent report |

**File Persistence**: Subagents cannot persist files to filesystem. Always use coordinator-as-executor pattern with Sprint 2 structured JSON output. See `/project/field-manual/file-operation-quickref.md`.

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

## MCP (Model Context Protocol) Integration

**Full Documentation**: See `/project/field-manual/mcp-integration.md`

### Key Principles
- **MCP-First**: Check for available MCPs before manual implementation
- **Discovery**: Use `grep "mcp__"` to find available MCP tools
- **Fallback**: Have manual approach ready when MCPs unavailable

### Common MCPs
| Category | MCPs |
|----------|------|
| Infrastructure | `mcp__railway`, `mcp__supabase`, `mcp__vercel` |
| Commerce | `mcp__stripe` |
| Development | `mcp__github`, `mcp__context7` |
| Testing | `mcp__playwright` |
| Research | `mcp__firecrawl`, `WebSearch` |

## Model Selection Guidelines

**Full Documentation**: See `/project/field-manual/model-selection-guide.md`

### Quick Reference

| Model | Use For | Example |
|-------|---------|---------|
| `opus` | Complex orchestration, strategic planning | Multi-phase missions, architecture |
| `sonnet` | Standard tasks (default) | Implementation, testing |
| `haiku` | Simple, fast operations | Doc updates, quick lookups |

**Syntax**: `Task(subagent_type="strategist", model="opus", prompt="...")`

## MCP Setup

**Full Documentation**: See `/project/field-manual/mcp-integration.md`

**Quick Start**: `cp .env.mcp.template .env.mcp` → Add API keys → Restart Claude Code

**Troubleshooting**: Run `grep "mcp__"` to see available tools. If missing, check `.env.mcp` keys and restart Claude Code.

## Sprint 9: Plan-Driven Development

### Overview

Sprint 9 introduces **Plan-Driven Development** where `project-plan.md` is the single source of truth for mission state. This enables stateless resumption after `/clear`, autonomous execution via `/coord continue`, and vision integrity checking.

### New Commands (Sprint 9)

| Command | Purpose |
|---------|---------|
| `/foundations init` | Extract foundation documents to structured YAML |
| `/architect` | Design system architecture (Auto or Engaged mode) |
| `/bootstrap [template]` | Generate project-plan.md from YAML extracts |
| `/plan status` | View current mission state |
| `/plan phase [N]` | Show phase details |
| `/coord continue` | Autonomous execution until blocked |
| `/skills` | List available skills |
| `/skills match [task]` | Find matching skills for a task |

### Plan-Driven Workflow

```bash
# 1. Initialize foundations (extract to YAML)
/foundations init

# 2. Design architecture (REQUIRED before bootstrap)
/architect                  # Prompts: Auto or Engaged mode
/architect --mode engaged   # Walk through 7 decisions together
/architect --mode auto      # Generate from PRD defaults

# 3. Bootstrap project plan from YAML extracts
/bootstrap                  # Prompts: Auto, Engaged, or Preview mode
/bootstrap --mode auto      # Generate immediately

# 4. Start autonomous execution
/coord continue

# After phase complete:
/coord complete phase 1    # Generate next phase context
/clear                     # Clear context
/coord continue            # Resume from project-plan.md
```

### /architect Mode Selection

When running `/architect` without flags, you'll be prompted to choose:

| Mode | Description |
|------|-------------|
| **Engaged (Recommended)** | Walk through 7 architectural decisions together. I explain trade-offs, you make informed choices. |
| **Auto** | Generate architecture from PRD tech stack hints using sensible defaults. Fast, but review afterward. |

**The 7 Decisions** (Engaged Mode):
1. Application Architecture (Monolith vs Modular vs Microservices)
2. Frontend Stack (Framework, rendering, styling, components)
3. Backend & Database (Provider, multi-tenancy, API layer)
4. Authentication (Provider, methods, sessions, roles)
5. External Integrations (Payments, AI models, email)
6. Infrastructure & Deployment (Hosting, CI/CD, environments)
7. Security & Observability (API security, data protection, monitoring)

### Quality Gates

Quality gates enforce at phase transitions:

```bash
# Run gates manually
python project/gates/run-gates.py --config .quality-gates.json --phase implementation

# Gates run automatically during /coord continue at phase transitions
```

**Gate Severity**:
- `blocking` - Must pass to proceed
- `warning` - Logged, continues
- `info` - Informational only

### Skills System

Skills auto-load based on task keywords:

| Skill | Triggers | Tokens |
|-------|----------|--------|
| saas-auth | auth, login, oauth | ~3,800 |
| saas-payments | stripe, checkout | ~4,200 |
| saas-multitenancy | tenant, rls | ~4,100 |
| saas-billing | billing, plan | ~3,900 |
| saas-email | email, resend | ~3,200 |
| saas-onboarding | onboarding, wizard | ~3,500 |
| saas-analytics | analytics, tracking | ~3,600 |

### Stack Profiles

Set your stack in `.stack-profile.yaml`:

```yaml
extends: nextjs-supabase  # or remix-railway, sveltekit-supabase
```

### Documentation

- [Plan-Driven Development Guide](./project/field-manual/plan-driven-development.md)
- [Quality Gates Guide](./project/field-manual/quality-gates-guide.md)
- [Skills Guide](./project/field-manual/skills-guide.md)
- [Architectural Principles](./project/field-manual/architectural-principles.md)

## Available Commands

### Mission Orchestration
- `/coord [mission] [files]` - Orchestrate multi-agent missions
- `/coord continue` - Autonomous execution until blocked (Sprint 9)
- `/design-review` - Comprehensive UI/UX audit (delegates to @designer)
- `/recon` - Design reconnaissance
- `/meeting [agenda]` - Facilitate structured meetings

### Project Setup (Sprint 9)
- `/foundations init` - Extract foundation documents to structured YAML
- `/architect` - Design system architecture (Auto or Engaged mode)
- `/bootstrap [template]` - Generate project-plan.md from YAML extracts
- `/plan status` - View current mission state
- `/plan phase [N]` - Show phase details
- `/skills` - List and match skills

### Reporting & Analysis
- `/report [since_date]` - Generate progress reports for stakeholders
- `/pmd [issue]` - Post Mortem Dump for root cause analysis

