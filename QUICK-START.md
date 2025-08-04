# AGENT-11 Project Setup Guide

## Zero to Project Squad in Under 5 Minutes

Welcome to AGENT-11! This guide gets you from curious to deployed to productive in under 5 minutes. AGENT-11 deploys your elite squad to work on a specific project - each project gets its own specialized team that understands your project context perfectly.

## Project-Only Installation

**Project-Local Agents · No Global Pollution · Clean Isolation**

### Step 1: Navigate to Your Project (Required)

```bash
# Navigate to your project directory
cd /path/to/your/project

# Examples of valid project directories:
cd ~/my-startup-app      # Has package.json, git repo
cd ~/client-website      # Has git repo, source files
cd ~/data-analysis       # Has Python files, requirements.txt
cd ~/mobile-app          # Has React Native, Expo config
```

### Step 2: Deploy Your Squad

```bash
# Core Squad (4 agents) - Recommended for most projects
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/deployment/scripts/install.sh | bash -s core

# Full Squad (11 agents) - For complex projects  
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/deployment/scripts/install.sh | bash -s full

# Minimal Squad (2 agents) - For quick prototyping
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/deployment/scripts/install.sh | bash -s minimal
```

**Project-focused by design!** The installer automatically:
- Detects your project type and context
- Creates project-local `.claude/agents/` directory
- Installs your selected squad with project understanding
- Verifies project compatibility
- Shows you exactly what to do next

## What You Get

### Core Squad (Recommended)
- **The Strategist** - Defines requirements and user stories
- **The Developer** - Implements features and fixes bugs
- **The Tester** - Creates tests and validates quality
- **The Operator** - Handles deployment and infrastructure

### Project Setup Time: 2-3 minutes

## Project Requirements

AGENT-11 requires a valid project directory. The installer looks for:

✅ **Git Repository**: `.git/` directory  
✅ **Package Files**: `package.json`, `requirements.txt`, `Cargo.toml`, etc.  
✅ **Source Code**: `.js`, `.py`, `.go`, `.rs`, `.ts`, etc. files  
✅ **Configuration Files**: `docker-compose.yml`, `.env`, config files  

### What Makes a Valid Project?

```bash
# Examples of project indicators:
ls -la  # Should show one or more of:
# .git/                 (Git repository)
# package.json          (Node.js project)
# requirements.txt      (Python project)
# Cargo.toml           (Rust project)
# go.mod               (Go project)
# docker-compose.yml   (Docker project)
# src/ or app/         (Source code directories)
```

## After Installation

You'll see a project-specific success message like this:

```
🎉 AGENT-11 Project Squad Deployed Successfully!

📁 Project detected: Node.js application with React frontend
📍 Squad location: /your/project/.claude/agents/

✅ Core Squad agents installed:
   - strategist (Product strategy specialist with project context)  
   - developer (Full-stack specialist familiar with your stack)
   - tester (QA specialist understanding your project structure)
   - operator (DevOps specialist configured for your deployment)

🚁 Next Steps:
   1. Restart Claude Code in this project: /exit then claude
   2. Verify project agents: /agents  
   3. Start building: @strategist What should we build next in this project?
```

## Restart Claude Code in Your Project

```bash
# Exit current session
/exit

# Start fresh session in your project directory
cd /path/to/your/project
claude
```

## Verify Installation

```bash
# Check your project-local agents
/agents

# You should see your squad listed under "Project agents (.claude/agents)"
# Example output:
# Project agents (.claude/agents)
#   strategist - Product strategy specialist (knows your project context)
#   developer - Full-stack specialist (familiar with your tech stack)
#   tester - QA specialist (understands your project structure)
#   operator - DevOps specialist (configured for your deployment)
```

## Your First Commands

### Option 1: Direct Agent Commands
```bash
# 1. Define what to build (with project context)
@strategist Create user stories for authentication in this project

# 2. Build it (understanding your tech stack)
@developer Implement authentication using our existing stack

# 3. Test it (knowing your project structure)
@tester Create tests that fit our testing framework

# 4. Ship it (configured for your deployment)
@operator Deploy using our existing CI/CD pipeline
```

### Option 2: Mission Commands (NEW!) 🎖️
```bash
# Use predefined missions for common workflows
/coord build requirements.md           # Build feature from requirements
/coord fix bug-report.md              # Fix a bug quickly
/coord mvp product-vision.md          # Create an MVP from concept
/coord refactor target-module.md      # Improve code quality

# Or let the coordinator guide you
/coord                                # Interactive mission selection
```

The `/coord` command orchestrates multi-agent missions automatically. Your entire squad works together following proven patterns. [Learn more about missions →](field-manual/coordinator-commands.md)

## Success Indicators

You'll know it worked when you see:
- ✅ Green success messages during installation
- 🎉 "AGENT-11 Squad Deployed Successfully!" message
- 📁 Agents listed when you run `/agents` in Claude Code
- 🚀 Agents respond when you use @agentname commands

## Common Issues (Quick Fixes)

### "No agents showing up"
```bash
# Restart Claude Code in your project directory
/exit
cd /path/to/your/project
claude
```

### "No project detected" or "Installation failed"
```bash
# Ensure you're in a valid project directory
pwd  # Should show your project path
ls -la  # Should show project files (.git, package.json, etc.)

# If not in project directory:
cd /path/to/your/project

# Re-run installation
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/deployment/scripts/install.sh | bash -s core
```

### "Permission denied" or "Directory not writable"
```bash
# Check project directory permissions
ls -ld .
# Should show write permissions for your user

# If you own the project directory, try again:
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/deployment/scripts/install.sh | bash -s core
```

## What's Next?

### For New Users:
1. Start with the strategist: `@strategist What should we build next in this project?`
2. Have the developer implement: `@developer Build the feature using our existing stack`
3. Test it: `@tester Create tests that fit our project structure`
4. Deploy it: `@operator Deploy using our existing pipeline`

### For Experienced Users:
- Set up multiple projects with different squads
- Explore the [Full Documentation](field-manual/)
- Try multi-agent workflows with `@coordinator`
- Customize agents for your specific project domains

## Need Help?

- **Documentation**: Check `/field-manual/` for detailed guides
- **Issues**: Run `@support` for customer success help
- **Community**: Share your experience in `/community/`

## Upgrade Your Project Squad

Start with Core, upgrade anytime:

```bash
# From your project directory
cd /path/to/your/project

# Upgrade to Full Squad (adds 7 more specialists)
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/deployment/scripts/install.sh | bash -s full

# Your existing project work is preserved - backups are automatic
```

## Multi-Project Workflow

```bash
# Each project gets its own isolated squad
cd ~/project-a
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/deployment/scripts/install.sh | bash -s core

cd ~/project-b  
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/deployment/scripts/install.sh | bash -s full

# No cross-contamination, perfect isolation
```

---

**Time from project to first working command: Under 5 minutes**

**Success Rate: 98% (based on automated testing)**

**Project-local by design: Clean, isolated, context-aware**

Ready to build something amazing? Your project-specific elite AI squad is waiting for orders! 🚁