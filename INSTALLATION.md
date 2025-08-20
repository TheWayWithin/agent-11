# AGENT-11 Project Installation Guide

Complete project installation documentation for the AGENT-11 deployment system. AGENT-11 deploys your elite squad to work on a specific project - each project gets its own specialized team that understands your project context perfectly.

## Table of Contents

- [Project Requirements](#project-requirements)
- [System Requirements](#system-requirements)
- [Project Installation Methods](#project-installation-methods)
- [Squad Types](#squad-types)
- [Step-by-Step Project Setup](#step-by-step-project-setup)
- [Post-Installation Setup](#post-installation-setup)
- [Verification](#verification)
- [Updating Existing Installation](#updating-existing-installation)
- [Multi-Project Setup](#multi-project-setup)
- [Troubleshooting](#troubleshooting)

## Project Requirements

### Valid Project Directory
AGENT-11 requires installation within a valid project directory. The installer detects:

✅ **Git Repository**: `.git/` directory  
✅ **Package Files**: `package.json`, `requirements.txt`, `Cargo.toml`, `go.mod`, etc.  
✅ **Source Code**: `.js`, `.py`, `.go`, `.rs`, `.ts`, etc. files  
✅ **Configuration Files**: `docker-compose.yml`, `.env`, config files  
✅ **Build Tools**: `Makefile`, `webpack.config.js`, etc.

### Examples of Valid Projects
```bash
# Node.js project
ls -la ~/my-app/
# .git/ package.json src/ public/

# Python project  
ls -la ~/data-analysis/
# .git/ requirements.txt main.py data/

# Go project
ls -la ~/api-server/
# .git/ go.mod main.go cmd/

# Generic project with source code
ls -la ~/website/
# .git/ index.html style.css scripts/
```

### Required Software
- **Claude Code**: Latest version must be installed and working
- **Bash Shell**: Available on macOS/Linux by default, Windows users need WSL
- **Project Directory Write Access**: Installer creates `.claude/agents/` in your project

### Minimum System Requirements
- **Storage**: 10MB free space (agents are lightweight text files)
- **Memory**: No additional memory requirements
- **Network**: Internet connection for initial download only

## System Requirements

### Supported Platforms
| Platform | Status | Notes |
|----------|--------|-------|
| macOS | ✅ Fully Supported | Tested on macOS 10.15+ |
| Linux | ✅ Fully Supported | Tested on Ubuntu, CentOS, Debian |
| Windows + WSL | ✅ Supported | Requires Windows Subsystem for Linux |
| Windows (native) | ⚠️ Limited | Use Git Bash or PowerShell with bash |

### Claude Code Integration
- Agents install to project-local `.claude/agents/` directory
- Claude Code automatically detects project agents when started in project directory
- Each project maintains its own isolated agent squad
- No global pollution or cross-project contamination

## Project Installation Methods

### Method 1: Direct Project Installation (Recommended)

```bash
# Step 1: Navigate to your project directory (REQUIRED)
cd /path/to/your/project

# Step 2: Verify project is valid
ls -la  # Should show .git, package.json, source files, etc.

# Step 3: Install your squad
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/install.sh | bash -s core

# Other squad options:
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/install.sh | bash -s full
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/install.sh | bash -s minimal
```

### Method 2: Clone AGENT-11 then Install to Project

```bash
# Step 1: Get AGENT-11 source
git clone https://github.com/TheWayWithin/agent-11.git
cd agent-11

# Step 2: Navigate to your project
cd /path/to/your/project

# Step 3: Run installer from AGENT-11 directory
/path/to/agent-11/deployment/scripts/install.sh core
```

### Method 3: Manual Project Installation

For users who prefer full control:

```bash
# Step 1: Navigate to your project
cd /path/to/your/project

# Step 2: Create project agents directory
mkdir -p .claude/agents

# Step 3: Copy agent files to your project
cp /path/to/agent-11/project/agents/specialists/strategist.md .claude/agents/
cp /path/to/agent-11/project/agents/specialists/developer.md .claude/agents/
# ... continue for desired agents

# Step 4: Verify project-local installation
ls -la .claude/agents/
```

## Squad Types

### Core Squad (Recommended)
**Agents**: Strategist, Developer, Tester, Operator  
**Install Time**: 2-3 minutes  
**Best For**: MVP development, learning AGENT-11, small projects

```bash
./deployment/scripts/install.sh core
```

### Full Squad
**Agents**: All 11 specialists  
**Install Time**: 4-5 minutes  
**Best For**: Production applications, complex projects, full product lifecycle

```bash
./deployment/scripts/install.sh full
```

### Minimal Squad
**Agents**: Strategist, Developer  
**Install Time**: 1-2 minutes  
**Best For**: Quick prototyping, focused development, resource constraints

```bash
./deployment/scripts/install.sh minimal
```

## Step-by-Step Project Setup

### Step 1: Prepare Your Project

```bash
# Navigate to your project directory
cd /path/to/your/project

# Verify it's a valid project
ls -la
# Should show: .git/, package.json, source files, etc.

# If no project yet, initialize one:
git init
echo '# My Project' > README.md
git add README.md
git commit -m "Initial commit"
```

### Step 2: Install Project Squad

```bash
# From your project directory, run installer
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/install.sh | bash -s core
```

### Step 3: Verify Project Detection

The installer will show project detection:

```
🔍 Detecting project context...
✅ Git repository detected
✅ Node.js project detected (package.json found)
✅ Source code detected (src/ directory)
📁 Installing to: /your/project/.claude/agents/
```

### Step 4: Monitor Installation

The installer provides real-time feedback with project context:

```
🚁 AGENT-11 Project Deployment System
=====================================

[INFO] Selected squad: core (4 agents)
[INFO] Project directory: /Users/you/my-startup-app
[INFO] Detected project type: Node.js application with React
[INFO] Validating project environment...
[SUCCESS] Project validation passed
[INFO] Creating project-local agents directory...
[SUCCESS] Created: /Users/you/my-startup-app/.claude/agents/
[INFO] Installing core squad (4 agents)...
[PROGRESS] [1/4] 25% - Installing strategist (with project context)
[PROGRESS] [2/4] 50% - Installing developer (React/Node.js specialist)
[PROGRESS] [3/4] 75% - Installing tester (Jest/React Testing Library)
[PROGRESS] [4/4] 100% - Installing operator (Node.js deployment)
[SUCCESS] All core squad agents installed successfully!
[INFO] Verifying project installation...
[SUCCESS] Project installation verification passed!

🎉 AGENT-11 Project Squad Deployed Successfully!
```

### Step 4: Restart Claude Code in Project

```bash
# If Claude Code is running
/exit

# Start fresh in your project directory
cd /path/to/your/project
claude
```

## Post-Installation Setup

### Verify Project Agent Detection

```bash
# In Claude Code (from your project directory)
/agents
```

You should see your project-specific agents:

```
Project agents (.claude/agents)
  strategist - Product strategy specialist (knows your project context)
  developer - Full-stack specialist (familiar with React/Node.js stack)
  tester - QA specialist (configured for Jest/RTL)
  operator - DevOps specialist (Node.js deployment ready)
```

### Test Project-Aware Functionality

```bash
# Test project understanding
@strategist What should we build next in this project?

# Test stack-aware development
@developer Add a new feature using our existing React/Node.js stack

# Test project-specific testing
@tester Create tests that fit our existing test structure
```

### Project Structure Verification

Check that project structure is correct:

```bash
# Verify project agents directory
ls -la .claude/agents/

# Should show your squad files:
# strategist.md
# developer.md  
# tester.md
# operator.md
```

## Verification

### Project Installation Success Checklist

- [ ] No error messages during installation
- [ ] Project type correctly detected
- [ ] "🎉 AGENT-11 Project Squad Deployed Successfully!" message shown
- [ ] Agents visible in Claude Code `/agents` command (when in project directory)
- [ ] Test agent responds with project context
- [ ] Project-local `.claude/agents/` directory created

### Manual Project Verification

```bash
# From your project directory
# Check project agent files exist
ls -la .claude/agents/

# Check file format
head -10 .claude/agents/strategist.md

# Should show YAML header:
# ---
# name: strategist
# description: Product strategy specialist with project context
# ---
```

### Project-Aware Functional Testing

```bash
@strategist What features should we prioritize in this project?
@developer How can we improve our existing codebase?
@tester What testing strategy fits our current setup?
@operator How should we deploy this specific project?
```

## Updating Existing Installation

### Quick Update Process

If you already have AGENT-11 installed and want to get the latest features (including the mission system):

```bash
# Navigate to your project
cd /path/to/your/project

# Update to latest version  
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/install.sh | bash -s core
```

**This update will:**
- ✅ Automatically backup existing agents
- ✅ Update agents to latest versions
- ✅ Add mission system (`/coord` command)
- ✅ Install mission files and templates
- ✅ Preserve all your project work

### What's New in Latest Version

**Mission System:**
- `/coord` command for systematic workflows
- Pre-built missions: BUILD, FIX, MVP, REFACTOR
- Mission templates for custom workflows

**Enhanced Agents:**
- Improved coordination protocols
- Better project context understanding
- Enhanced collaboration capabilities

### Update Verification

After updating, verify everything is working:

```bash
# Check mission system is installed
ls -la missions/           # Mission files
ls -la .claude/commands/   # coord.md command  
ls -la templates/          # Mission templates

# Test new features
claude
/coord                     # Test mission command
@coordinator "Verify all systems are working"
```

### Detailed Update Guide

For comprehensive update instructions, troubleshooting, and advanced options:

**[📋 Complete Update Guide →](UPDATING.md)**

## Multi-Project Setup

### Managing Multiple Projects

```bash
# Each project gets its own isolated squad
cd ~/project-a
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/install.sh | bash -s core

cd ~/project-b  
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/install.sh | bash -s full

cd ~/project-c
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/install.sh | bash -s minimal
```

### Project Isolation Benefits

✅ **No Cross-Contamination**: Each project's agents understand only that project  
✅ **Stack-Specific Knowledge**: Agents adapt to each project's technology stack  
✅ **Clean Separation**: No global pollution or conflicting configurations  
✅ **Independent Upgrades**: Upgrade squads per project without affecting others  

### Platform-Specific Notes

### All Platforms
- Project agents stored in `.claude/agents/` within each project
- Claude Code detects agents when started in project directory
- No global installation - everything is project-local

## Troubleshooting

### Installation Fails

**Error**: "Permission denied"
```bash
chmod +x deployment/scripts/install.sh
./deployment/scripts/install.sh core
```

**Error**: "No project detected" or "Not a valid project directory"
```bash
# Ensure you're in a valid project directory
pwd  # Should show your project path
ls -la  # Should show .git, package.json, source files, etc.

# If not a project, initialize one:
git init
echo '{}' > package.json  # or create appropriate project files
```

**Error**: "Cannot write to project directory"
```bash
# Check project directory permissions
ls -ld .
# Should show write permissions for user

# If permission issue:
sudo chown -R $USER .
```

### Agents Not Appearing

**Issue**: No agents in `/agents` list
```bash
# Restart Claude Code in project directory
/exit
cd /path/to/your/project
claude

# Check project agents directory
ls -la .claude/agents/
```

**Issue**: Agent files exist but not detected
```bash
# Ensure you're in the project directory where agents are installed
pwd
ls -la .claude/agents/

# Check file format
head -10 .claude/agents/strategist.md
# Must have YAML header with name field
```

### Agent Not Responding

**Issue**: Agent doesn't respond to @mentions
```bash
# Check exact agent name
/agents
# Use exact name shown in list
```

**Issue**: "Agent not found" error
```bash
# Verify file name matches agent name in YAML header
grep "name:" .claude/agents/strategist.md

# Ensure Claude Code is running from project directory
pwd  # Should show your project path
```

### Rollback Issues

**Issue**: Installation failed and cleanup needed
```bash
# Manual cleanup of project agents
rm -rf .claude/agents/

# Re-run installation
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/install.sh | bash -s core
```

### Performance Issues

**Issue**: Slow installation
```bash
# Check available disk space in project
df -h .
# Should have at least 10MB free
```

**Issue**: Agents slow to respond
- This is normal for first interaction after installation
- Subsequent responses should be faster

## Advanced Installation Options

### Custom Project Agent Selection

```bash
# Install only specific agents to your project
# Navigate to your project first
cd /path/to/your/project

# Then install specific agents manually
mkdir -p .claude/agents
cp /path/to/agent-11/project/agents/specialists/strategist.md .claude/agents/
cp /path/to/agent-11/project/agents/specialists/developer.md .claude/agents/
```

### Different Project Agent Directory

```bash
# Agents are always project-local in .claude/agents/
# This ensures isolation and project-specific context
# No global installation options by design
```

### Development Installation

```bash
# For AGENT-11 developers working on a project
cd /path/to/your/project
./path/to/agent-11/deployment/scripts/install.sh core --dev
# Links files instead of copying (changes reflect immediately)
```

## Upgrade and Maintenance

### Upgrading Project Squads

```bash
# From your project directory
cd /path/to/your/project

# Upgrade from core to full
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/install.sh | bash -s full
# Existing project agents preserved, new ones added

# Each project can have different squad types
```

### Updating Project Agents

```bash
# Update agents for a specific project
cd /path/to/your/project

# Re-run installation to get latest agents
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/install.sh | bash -s core
```

### Project Agent Management

```bash
# Each project manages its own agents
cd /path/to/your/project
ls -la .claude/agents/

# Remove project agents if needed
rm -rf .claude/agents/

# Reinstall fresh
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/install.sh | bash -s core
```

## Getting Help

### Self-Diagnosis

```bash
# From your project directory
pwd  # Verify you're in the right project
ls -la .claude/agents/  # Check agents are installed

# Test project detection
@strategist What type of project is this?
```

### Support Channels

1. **Built-in Support**: Deploy `@support` agent for immediate help
2. **Documentation**: Check `/field-manual/` for detailed guides
3. **Community**: Visit `/community/` for user discussions
4. **Issues**: Report problems on GitHub Issues

### Reporting Issues

When reporting problems, include:

```bash
# System information
uname -a
claude --version

# Project information
pwd  # Current project directory
ls -la  # Project structure
ls -la .claude/agents/  # Installed agents

# Project type
file package.json requirements.txt go.mod Cargo.toml 2>/dev/null || echo "No standard project files found"
```

---

**Need immediate help?** Deploy the support agent: `@support Help me troubleshoot my AGENT-11 project installation`

**Project installation working perfectly?** Share your success story in `/community/SUCCESS-STORIES.md`