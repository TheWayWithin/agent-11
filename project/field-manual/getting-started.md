## 📋 field-manual/getting-started.md

```markdown
# AGENT-11 Getting Started Guide

Welcome to AGENT-11, your elite AI development squad. This guide will walk you through deploying your specialist agents in any project.

## Prerequisites

- Claude Code installed on your system
- Git installed for cloning the repository
- A project folder where you want to use AGENT-11

## Deployment Steps

### 1. Clone the AGENT-11 Repository

First, clone the AGENT-11 framework to your local machine:

```bash
git clone https://github.com/TheWayWithin/agent-11.git
```

### 2. Navigate to Your Project

Open terminal and navigate to the project where you want to use AGENT-11:

```bash
cd /path/to/your/project
```

### 3. Create the Claude Agents Directory

Create the hidden `.claude/agents/` directory in your project:

```bash
mkdir -p .claude/agents
```

### 4. Copy Agent Files

Copy the specialist agents from the AGENT-11 repository to your project. You'll need to rename them to match Claude Code's expected format:

```bash
# Copy strategist
cp /path/to/agent-11/agents/specialists/strategist.md .claude/agents/strategist.md

# Copy architect
cp /path/to/agent-11/agents/specialists/architect.md .claude/agents/architect.md

# Copy coordinator
cp /path/to/agent-11/agents/specialists/coordinator.md .claude/agents/coordinator.md

# Copy developer
cp /path/to/agent-11/agents/specialists/developer.md .claude/agents/developer.md

# Continue for other agents as needed...
```

**Note**: The files in `.claude/agents/` must be named without number prefixes (e.g., `strategist.md` not `01-strategist.md`).

### 5. Update Agent File Format

Each agent file needs to have the Claude Code metadata header. The files should look like:

```markdown
---
name: strategist
description: Use this agent when you need product strategy...
model: sonnet
color: purple
---

[Agent system prompt goes here]
```

### 6. Initialize Agents in Claude Code

1. If Claude Code is currently running, exit it:
   ```bash
   /exit
   ```

2. Start Claude Code fresh:
   ```bash
   claude
   ```

3. Verify agents are loaded by typing:
   ```bash
   /agents
   ```

You should see your deployed agents listed under "Project agents (.claude/agents)".

## Testing Your Deployment

Test that your agents are working:

```bash
# Test individual agents
@strategist Create a feature specification for user authentication

# Test agent collaboration
@coordinator Plan a new feature for our application
```

## Automated Deployment (Recommended)

For faster deployment, use our automated installer:

```bash
# Core Squad (4 agents) - Recommended
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/deployment/scripts/install.sh | bash -s core

# Full Squad (11 agents) - For complex projects
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/deployment/scripts/install.sh | bash -s full

# Minimal Squad (2 agents) - For quick prototyping
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/deployment/scripts/install.sh | bash -s minimal
```

The automated installer handles all the manual steps above automatically.

## Troubleshooting

### Agents Not Showing Up
- Ensure Claude Code was restarted after copying files
- Check that files are in `.claude/agents/` (note the dot)
- Verify file permissions allow reading

### Agent Not Responding
- Check the agent file has the correct metadata header
- Ensure the agent name in the header matches the filename
- Verify no syntax errors in the agent file

### Can't See .claude Folder
The `.claude` folder is hidden by default. To see it:
- **Mac**: Press `Cmd + Shift + .` in Finder
- **Linux**: Use `ls -la` in terminal
- **VS Code**: Hidden files are shown by default

## Next Steps

1. Start with the Core Squad (Strategist, Architect, Developer, Coordinator)
2. Add specialists as your project needs grow
3. Customize agent prompts for your specific domain
4. Share your success stories with the community

## Contributing

Found a better deployment method? Have ideas for improvement? 
- Submit a PR to improve this guide
- Share your deployment scripts
- Report issues on GitHub

---

*Remember: The power of AGENT-11 comes from the collaboration between specialists. Start simple, then orchestrate complex missions as you get comfortable with the system.*
```

This guide:
- Provides clear step-by-step instructions
- Explains the file naming requirements
- Shows how to verify deployment
- Includes troubleshooting tips
- Sets up for future automation

Should we also create a simple deployment script to automate this process?
