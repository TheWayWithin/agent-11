# CLAUDE.md - AGENT-11 Development Project

## PROJECT OVERVIEW

This is the **AGENT-11 framework repository** - a library of AI agents that gets deployed to user projects. When working in this repository, you must understand the critical distinction between two agent directories.

**Personal preferences**: See root `/CLAUDE.md` for Jamie's communication preferences.

## Library Documentation Standards

When creating library documentation (files in `project/field-manual/`, `project/missions/`, etc.), write for general technical users:
- **Clear, concise technical documentation** - Standard professional tone
- **Assume competent self-directed users** - They can follow instructions without hand-holding
- **No completion prompts** - Don't ask "Ready to continue?" in public docs
- **Standard formatting** - Use common technical documentation patterns

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

### Working Commands (`.claude/commands/`)
**Purpose**: Internal slash commands for AGENT-11 development work
**Location**: `/Users/jamiewatters/DevProjects/agent-11/.claude/commands/`
**Use Case**: Commands used while building the AGENT-11 framework itself
**Commands Include**: Internal development utilities (NOT deployed)

**⚠️ DO NOT MODIFY UNLESS**: You are improving the AGENT-11 development process itself

### Library Commands (`project/commands/`)
**Purpose**: Deployable slash commands for end users
**Location**: `/Users/jamiewatters/DevProjects/agent-11/project/commands/`
**Use Case**: Commands that get deployed to user projects via install.sh
**Commands Include**: coord, meeting, design-review, recon, report, pmd, dailyreport, planarchive

**✅ MODIFY THESE**: When enhancing command capabilities for end users

## DEFAULT WORK TARGET

**When in doubt, work on**:
- `project/agents/specialists/` (Library Agents)
- `project/commands/` (Library Commands)

**Reason**: Most work involves improving what users get when they deploy AGENT-11, not our internal development tools.

## VERIFICATION PROTOCOL

Before modifying ANY agent or command file, ask yourself:

1. **Am I improving the AGENT-11 library for end users?**
   - YES → Work on `project/agents/specialists/` OR `project/commands/`
   - NO → Continue to question 2

2. **Am I improving the AGENT-11 development process?**
   - YES → Work on `.claude/agents/` OR `.claude/commands/`
   - NO → Ask user for clarification

3. **Quick check**: Always verify with the deployment script
   - Run: `grep -n "your-file" project/deployment/scripts/install.sh`
   - If found → it's deployed (library file)
   - If not found → it's internal (working squad file)

## COMMON SCENARIOS

### Scenario: "Improve agent prompting"
**Target**: `project/agents/specialists/` (users benefit)

### Scenario: "Add new agent capability"
**Target**: `project/agents/specialists/` (users benefit)

### Scenario: "Fix bug in /planarchive command"
**Target**: `project/commands/planarchive.md` (users benefit)

### Scenario: "Enhance /coord command features"
**Target**: `project/commands/coord.md` (users benefit)

### Scenario: "Optimize agent performance"
**Target**: `project/agents/specialists/` (users benefit)

### Scenario: "Fix bug in coordinator delegation"
**Target**: `project/agents/specialists/coordinator.md` (users benefit)

### Scenario: "Improve our internal code review process"
**Target**: `.claude/agents/` (development process)

### Scenario: "Add internal dev utility command"
**Target**: `.claude/commands/` (internal tool, not deployed)

### Scenario: "Add agent-optimizer capabilities"
**Target**: `.claude/agents/agent-optimizer.md` (internal tool, not deployed)

## FILE STRUCTURE REFERENCE

```
agent-11/
├── CLAUDE.md             ← Jamie's personal preferences (NOT deployed)
├── library/
│   └── CLAUDE.md         ← DEPLOYABLE content → user's .claude/CLAUDE.md
├── .claude/
│   ├── agents/           ← WORKING SQUAD (12 agents, internal use ONLY)
│   ├── commands/         ← Internal slash commands (NOT deployed)
│   └── claude.md         ← This file (project guardrails)
│
└── project/
    ├── agents/
    │   └── specialists/  ← LIBRARY AGENTS (11 agents, DEPLOYED TO USERS)
    ├── commands/         ← LIBRARY COMMANDS (DEPLOYED TO USERS)
    ├── missions/         ← Mission templates (deployed)
    ├── field-manual/     ← User documentation (deployed)
    └── deployment/
        └── scripts/
            └── install.sh ← Deploys library to user projects
```

## DEPLOYMENT SYSTEM

**Two-File Architecture** (user's project after deployment):
```
user-project/
├── CLAUDE.md              ← User's personal preferences (NEVER touched)
└── .claude/
    └── CLAUDE.md          ← AGENT-11 library instructions (from library/CLAUDE.md)
```

**What Gets Deployed** (see install.sh):
- `library/CLAUDE.md` → user's `.claude/CLAUDE.md` (AGENT-11 instructions)
- `project/agents/specialists/*.md` → user's `.claude/agents/`
- `project/commands/*.md` → user's `.claude/commands/`
- `project/missions/*.md` → user's `missions/`
- `templates/*.md` → user's `templates/`
- `project/field-manual/*.md` → user's `field-manual/`

**What Stays Internal** (NOT deployed):
- `/CLAUDE.md` (root - Jamie's personal preferences)
- `.claude/agents/*.md` (working squad)
- `.claude/commands/*.md` (internal commands)
- `.claude/claude.md` (this file - dev instructions)
- Development documentation (project-plan.md, progress.md)

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
| **Fix command bugs** | `project/commands/` |
| **Add command features** | `project/commands/` |
| **Improve command UX** | `project/commands/` |
| Improve internal dev process | `.claude/agents/` |
| Add internal-only tools | `.claude/agents/` OR `.claude/commands/` |

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
