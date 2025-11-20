# Essential Setup Guide

**[← Back to Main README](../../README.md)**

**Time to First Agent**: < 5 minutes

---

## Overview

Get AGENT-11 up and running in your project quickly. This guide covers everything from prerequisites through your first agent invocation.

**What You'll Accomplish**:
- Install the Core Squad (4 essential agents) or Full Squad (11 specialists)
- Verify agents are working correctly
- Invoke your first agent and see results
- Know where to go next for your development workflow

---

## Prerequisites

Before installing AGENT-11, ensure you have:

### Required
- **Claude Code** (claude.ai/code) - The platform where AGENT-11 agents run
- **Active Project Directory** - The codebase you want AGENT-11 to help with

### Recommended
- **Git Repository** - For version control and collaboration
- **Command Line Access** - For running installation scripts

---

## Quick Install

### Option 1: Core Squad (Recommended for Getting Started)

The Core Squad includes 4 essential agents that handle most development workflows:
- **@strategist** - Product strategy and requirements
- **@developer** - Full-stack implementation
- **@tester** - Quality assurance and validation
- **@operator** - DevOps and deployment

**Install Command**:
```bash
/usr/bin/curl -fsSL https://raw.githubusercontent.com/jaemskyle/agent-11/main/project/deployment/scripts/install.sh | bash -s -- --core
```

**What This Does**:
1. Downloads agent profiles to your `.claude/agents/` directory
2. Sets up mission templates in `missions/` directory
3. Configures slash commands in `.claude/commands/`
4. Creates basic project structure

### Option 2: Full Squad (For Comprehensive Projects)

The Full Squad adds 7 additional specialists:
- **@architect** - System design and architecture
- **@designer** - UX/UI design and branding
- **@documenter** - Technical writing and knowledge management
- **@support** - Customer success and user experience
- **@analyst** - Data insights and metrics
- **@marketer** - Growth and marketing strategy
- **@coordinator** - Mission orchestration (automatically included)

**Install Command**:
```bash
/usr/bin/curl -fsSL https://raw.githubusercontent.com/jaemskyle/agent-11/main/project/deployment/scripts/install.sh | bash -s -- --full
```

---

## Verify Installation

After installation completes, verify agents are available:

### 1. Check Agent Directory
```bash
ls -la .claude/agents/
```

**Expected Output** (Core Squad):
```
strategist.md
developer.md
tester.md
operator.md
coordinator.md  # Automatically included
```

**Expected Output** (Full Squad):
```
All agents above, plus:
architect.md
designer.md
documenter.md
support.md
analyst.md
marketer.md
```

### 2. Test Agent Invocation

In Claude Code, type `@` to see available agents. You should see your installed agents in the list.

### 3. Invoke Your First Agent

Try a simple task:
```
@strategist What's the first thing I should work on in this project?
```

The strategist will analyze your codebase and provide strategic recommendations.

---

## First Steps After Installation

### Recommended Workflow

**1. Project Initialization** (New Projects)
```bash
/coord dev-setup ideation.md
```
This creates your project structure, including:
- `architecture.md` - System design documentation
- `project-plan.md` - Task tracking and milestones
- `progress.md` - Change log and issue history
- `CLAUDE.md` - Project-specific guidance

**2. Project Alignment** (Existing Projects)
```bash
/coord dev-alignment
```
This analyzes your existing codebase and creates documentation to align AGENT-11 with your project.

**3. Start Development**

Once initialized, start your first development task:
```
@strategist Create user stories for [feature name]
@developer Implement [specific functionality]
@tester Validate the implementation
```

Or use mission-based workflows:
```bash
/coord build requirements.md
/coord fix bug-report.md
/coord mvp vision.md
```

---

## Troubleshooting

### Agents Don't Appear in @ Menu

**Solution**: Restart Claude Code. Agent profiles are loaded on startup.

### Installation Script Fails

**Common Issues**:
1. **Permission Denied**: Run with appropriate permissions or manually create `.claude/agents/` directory
2. **Network Error**: Check your internet connection and try again
3. **Directory Already Exists**: Installation script won't overwrite existing files. Remove `.claude/agents/` and retry if you want a clean install.

### Agent Responds But Doesn't Seem Specialized

**Cause**: Generic Claude may be responding instead of the specialized agent.

**Solution**: Ensure agent profile files are in `.claude/agents/` with correct filenames (e.g., `strategist.md`, not `strategist.txt`).

### Can't Find Slash Commands

**Check**:
```bash
ls -la .claude/commands/
```

You should see `coord.md` (and other command files if installed).

**Solution**: Re-run installation with `--commands` flag:
```bash
curl -fsSL https://raw.githubusercontent.com/jaemskyle/agent-11/main/project/deployment/scripts/install.sh | bash -s -- --commands
```

---

## Next Steps

### Learn Common Workflows
See **[Common Workflows Guide](./common-workflows.md)** for practical patterns you'll use daily:
- Feature development workflow
- Bug fixing workflow
- Refactoring patterns
- Mission-based orchestration

### Explore Agent Capabilities
See **[Features & Capabilities Guide](./features-capabilities.md)** for:
- Detailed agent specializations
- Advanced features (memory system, extended thinking)
- MCP integration capabilities
- Team collaboration patterns

### Set Up Progress Tracking
See **[Progress Tracking Guide](./progress-tracking.md)** for:
- `project-plan.md` usage
- `progress.md` maintenance
- Task completion workflow
- Issue documentation

### Understand Mission Architecture
See **[Mission Architecture Guide](./mission-architecture.md)** for:
- How missions work
- Available mission templates
- Creating custom missions
- Mission orchestration with `/coord`

---

## Quick Reference

**Install Core Squad**:
```bash
curl -fsSL https://raw.githubusercontent.com/jaemskyle/agent-11/main/project/deployment/scripts/install.sh | bash -s -- --core
```

**Install Full Squad**:
```bash
curl -fsSL https://raw.githubusercontent.com/jaemskyle/agent-11/main/project/deployment/scripts/install.sh | bash -s -- --full
```

**Initialize New Project**:
```bash
/coord dev-setup ideation.md
```

**Align Existing Project**:
```bash
/coord dev-alignment
```

**Invoke Agent**:
```
@strategist [your request]
@developer [your request]
@tester [your request]
```

**Run Mission**:
```bash
/coord [mission-name] [input-files]
```

---

**[← Back to Main README](../../README.md)** | **[Next: Common Workflows →](./common-workflows.md)**
