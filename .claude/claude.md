# CLAUDE.md - AGENT-11 Development Project

## PROJECT OVERVIEW

This is the **AGENT-11 framework repository** - a library of AI agents that gets deployed to user projects. When working in this repository, you must understand the critical distinction between two agent directories.

## Project Owner Communication Guidelines

### ADHD-Optimized Interaction Protocol for Working with Jamie

**IMPORTANT**: This section applies ONLY to direct communication with Jamie (the project owner) during development work. This does NOT apply to library documentation written for end users.

**Project Owner Profile**: Jamie has ADHD, gets easily distracted, has poor short-term memory, and is not very technical. When communicating with Jamie during development work, use this structured approach:

**MANDATORY Communication Structure**:

1. **Brief Context** (1-2 sentences max)
   - Explain what we're doing and why it matters
   - Example: "We're adding your API key so the tool can connect to GitHub. This enables automatic code deployments."

2. **Exact Instructions** (numbered, specific, sequential)
   - Start from where the user currently is (e.g., "You should still have the Settings page open from the last step")
   - Never jump ahead or assume completion unless user confirms
   - Use plain language: "Click the blue 'Save' button" not "Persist the configuration"
   - Provide specific locations: "In the left sidebar, click 'Settings'" not "Go to settings"

3. **Completion Prompt** (mandatory after each step)
   - Ask if they've completed the step
   - Ask if they want to continue
   - Example: "Have you clicked Save and seen the success message? Ready to move on?"

**Critical Requirements**:
- ✅ Always provide closure before moving to next step (reduces anxiety and overwhelm)
- ✅ Acknowledge current state before giving next instruction (maintains continuity)
- ✅ Offer 2-3 clear options when decisions needed, with guidance on choosing
- ✅ Provide simple recaps when user seems lost or after multiple steps
- ✅ Gently pause and offer breaks if user appears stuck or overwhelmed
- ❌ Never assume a step is complete unless user confirms
- ❌ Never skip context about why we're doing something
- ❌ Never give general suggestions instead of specific instructions
- ❌ Never overwhelm with too many steps at once (max 3 steps before check-in)

**Example of CORRECT Communication**:
```
Brief Context: We're creating a config file so the agents know which tools to use. This takes about 2 minutes.

Instructions:
1. In the terminal that's currently open, type: cp .env.template .env
2. Press Enter
3. You should see no output - that's normal and means it worked

Completion Prompt: Did the command run without errors? Ready to add your API keys to the file?
```

**Example of INCORRECT Communication**:
```
Let's set up the config. Run the setup script and configure your environment variables for the MCP servers. Then we'll proceed with initialization.
```
*(Problems: No context for why, assumes terminal is open, uses jargon like "environment variables" and "MCP servers", no specific commands, doesn't check for completion)*

**Agent Responsibility**: Every agent interaction with Jamie (the project owner) MUST follow this structure. This is not optional - it's a core requirement for effective collaboration.

**CRITICAL**: This communication structure is for working with Jamie only. When creating library documentation (files in `project/field-manual/`, `project/missions/`, etc.), write for general technical users with standard documentation style.

## Library Documentation Standards

**Target Audience**: General technical users deploying AGENT-11 to their projects. These are developers, founders, and teams who will use AGENT-11 in their own work.

**Writing Style for Library Documentation**:
- **Clear, concise technical documentation** - Standard professional tone
- **Assume competent self-directed users** - They can follow instructions without hand-holding
- **No completion prompts** - Don't ask "Ready to continue?" or "Did this work?"
- **No personal communication patterns** - No ADHD-specific structure in public docs
- **Standard formatting** - Use common technical documentation patterns

**What TO Include in Library Docs**:
- Clear setup instructions with copy-paste commands
- Decision trees for different scenarios
- Troubleshooting common issues
- Examples and realistic use cases
- "Why" context where helpful, but concisely

**What NOT to Include in Library Docs**:
- ❌ Completion check questions ("Have you finished? Ready for the next step?")
- ❌ Consent prompts between every step
- ❌ "Brief Context:" and "Completion Prompt:" labels
- ❌ Excessive explanations between steps
- ❌ Personal accommodation patterns

**Example of GOOD Library Documentation**:
```markdown
## Quick Start

1. Create your project directory and navigate to it
2. Copy your BOS-AI documents to `ideation/` folder
3. Initialize AGENT-11: `/coord dev-setup ideation/PRD.md`
4. Start development: `/coord build` or `/coord mvp`

See troubleshooting section if you encounter issues.
```

**Example of BAD Library Documentation** (too personal):
```markdown
## Quick Start

Brief Context: We're setting up your project so AGENT-11 can help you build your MVP. This takes about 5 minutes.

Instructions:
1. Create your project directory and navigate to it
2. Copy your BOS-AI documents to `ideation/` folder

Completion Prompt: Have you copied the files? Ready to continue?
```

## ⚠️ CRITICAL ARCHITECTURE DISTINCTION

### Working Squad (`.claude/agents/`)
**Purpose**: Internal development squad for AGENT-11 project work
**Location**: `/Users/jamiewatters/DevProjects/agent-11/.claude/agents/`
**Agent Count**: 12 agents
**Use Case**: Building, testing, and maintaining the AGENT-11 framework itself
**Agents Include**: coordinator, developer, strategist, tester, architect, designer, operator, analyst, marketer, support, documenter, agent-optimizer
**Archived**: content-creator (overlaps with marketer), design-review (overlaps with designer)

**⚠️ DO NOT MODIFY UNLESS**: You are improving the AGENT-11 development process itself

### Library Agents (`project/agents/specialists/`)
**Purpose**: Deployable agent library for end users
**Location**: `/Users/jamiewatters/DevProjects/agent-11/project/agents/specialists/`
**Agent Count**: 11 agents
**Use Case**: Agents that get deployed to user projects via install.sh
**Agents Include**: coordinator, strategist, architect, developer, designer, tester, documenter, operator, analyst, marketer, support

**✅ MODIFY THESE**: When enhancing agent capabilities for end users

## DEFAULT WORK TARGET

**When in doubt, work on**: `project/agents/specialists/` (Library Agents)

**Reason**: Most work involves improving what users get when they deploy AGENT-11, not our internal development tools.

## VERIFICATION PROTOCOL

Before modifying ANY agent file, ask yourself:

1. **Am I improving the AGENT-11 library for end users?**
   - YES → Work on `project/agents/specialists/`
   - NO → Continue to question 2

2. **Am I improving the AGENT-11 development process?**
   - YES → Work on `.claude/agents/`
   - NO → Ask user for clarification

## COMMON SCENARIOS

### Scenario: "Improve agent prompting"
**Target**: `project/agents/specialists/` (users benefit)

### Scenario: "Add new agent capability"
**Target**: `project/agents/specialists/` (users benefit)

### Scenario: "Optimize agent performance"
**Target**: `project/agents/specialists/` (users benefit)

### Scenario: "Fix bug in coordinator delegation"
**Target**: `project/agents/specialists/coordinator.md` (users benefit)

### Scenario: "Improve our internal code review process"
**Target**: `.claude/agents/` (development process)

### Scenario: "Add agent-optimizer capabilities"
**Target**: `.claude/agents/agent-optimizer.md` (internal tool, not deployed)

## FILE STRUCTURE REFERENCE

```
agent-11/
├── .claude/
│   ├── agents/           ← WORKING SQUAD (12 agents, internal use)
│   ├── commands/         ← Slash commands (also deployed)
│   └── claude.md         ← This file (project guardrails)
│
└── project/
    ├── agents/
    │   └── specialists/  ← LIBRARY AGENTS (11 agents, DEPLOYED TO USERS)
    ├── missions/         ← Mission templates (deployed)
    ├── field-manual/     ← User documentation (deployed)
    └── deployment/
        └── scripts/
            └── install.sh ← Deploys library agents to user projects
```

## DEPLOYMENT SYSTEM

**What Gets Deployed**:
- `project/agents/specialists/*.md` → user's `.claude/agents/`
- `project/missions/*.md` → user's `missions/` (optional)
- `.claude/commands/*.md` → user's `.claude/commands/` (optional)

**What Stays Internal**:
- `.claude/agents/*.md` (working squad)
- Development documentation
- Internal tools and utilities

## PHASE 1 & 2 MODERNIZATION CONTEXT

**What Was Modernized** (October 2025):
- ✅ `project/agents/specialists/` - 11 library agents fully modernized
- ✅ Memory tool integration
- ✅ Extended thinking modes
- ✅ Tool permissions
- ✅ Self-verification protocols
- ✅ Context editing guidance

**Working Squad Status**:
- `.claude/agents/` received SOME modernization updates
- Not comprehensively updated (not priority)
- Focus was on library agents for user benefit

## ERROR RECOVERY PROTOCOL

If you realize you've been working on the wrong agent directory:

1. **STOP immediately**
2. **Assess**: Is the work relevant to library agents?
3. **If YES**: Apply changes to `project/agents/specialists/` agents
4. **If NO**: Revert changes and restart with correct directory
5. **Document**: Update progress.md with error recovery

## QUICK REFERENCE

| Task | Target Directory |
|------|-----------------|
| Improve agent capabilities | `project/agents/specialists/` |
| Add new agent features | `project/agents/specialists/` |
| Fix agent bugs | `project/agents/specialists/` |
| Update agent protocols | `project/agents/specialists/` |
| Optimize agent performance | `project/agents/specialists/` |
| Improve internal dev process | `.claude/agents/` |
| Add internal-only tools | `.claude/agents/` |

## COORDINATION RULES

When coordinating missions:
- Default to library agents unless explicitly internal work
- Verify target directory before starting significant work
- Document which directory changes apply to
- Update both project-plan.md and progress.md with correct paths

## REMINDER

**99% of work should target**: `project/agents/specialists/`

**1% of work targets**: `.claude/agents/` (rare, internal improvements only)

---

**Last Updated**: 2025-10-18
**Purpose**: Prevent confusion between working squad and library agents
**Critical**: Always verify which agents you're modifying before starting work
