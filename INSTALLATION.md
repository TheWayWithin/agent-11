# AGENT-11 Installation Guide

Complete installation documentation for the AGENT-11 deployment system. This guide covers everything from prerequisites to advanced configuration.

## Table of Contents

- [Prerequisites](#prerequisites)
- [System Requirements](#system-requirements)
- [Installation Methods](#installation-methods)
- [Squad Types](#squad-types)
- [Step-by-Step Installation](#step-by-step-installation)
- [Post-Installation Setup](#post-installation-setup)
- [Verification](#verification)
- [Platform-Specific Notes](#platform-specific-notes)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Software
- **Claude Code**: Latest version of Claude Code must be installed and working
- **Bash Shell**: Available on macOS/Linux by default, Windows users need WSL
- **Git**: For cloning the repository (optional if downloading as ZIP)

### System Access
- **Home Directory Write Access**: Installer creates `~/.claude/agents/`
- **Terminal/Command Line**: Basic familiarity with command line operations

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
- Agents install to `~/.claude/agents/` directory
- Claude Code automatically detects new agents on restart
- No additional configuration required

## Installation Methods

### Method 1: Automated Installation (Recommended)

```bash
# Navigate to project directory
cd /path/to/agent-11

# Run installer with your preferred squad
./deployment/scripts/install.sh core
```

### Method 2: Direct Download + Install

```bash
# Download and run in one command (coming soon)
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/deployment/scripts/install.sh | bash -s core
```

### Method 3: Manual Installation

For users who prefer full control:

```bash
# Create agents directory
mkdir -p ~/.claude/agents

# Copy agent files manually
cp agents/specialists/strategist.md ~/.claude/agents/
cp agents/specialists/developer.md ~/.claude/agents/
# ... continue for desired agents
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

## Step-by-Step Installation

### Step 1: Get AGENT-11

```bash
# Option A: Clone repository
git clone https://github.com/yourusername/agent-11.git
cd agent-11

# Option B: Download ZIP
wget https://github.com/yourusername/agent-11/archive/main.zip
unzip main.zip
cd agent-11-main
```

### Step 2: Make Installer Executable

```bash
chmod +x deployment/scripts/install.sh
```

### Step 3: Run Installation

```bash
# Choose your squad type
./deployment/scripts/install.sh core
```

### Step 4: Monitor Installation

The installer provides real-time feedback:

```
🚁 AGENT-11 Deployment System
==============================

[INFO] Selected squad: core (4 agents)
[INFO] Validating installation environment...
[SUCCESS] Environment validation passed
[INFO] Creating backup of existing agents...
[SUCCESS] Backup created: ~/.claude/backups/agent-11/20240203_143022
[INFO] Installing core squad (4 agents)...
[PROGRESS] [1/4] 25% - Installing strategist
[PROGRESS] [2/4] 50% - Installing developer
[PROGRESS] [3/4] 75% - Installing tester
[PROGRESS] [4/4] 100% - Installing operator
[SUCCESS] All core squad agents installed successfully!
[INFO] Verifying installation...
[SUCCESS] Installation verification passed!

🎉 AGENT-11 core Squad Deployed Successfully!
```

### Step 5: Restart Claude Code

```bash
# If Claude Code is running
/exit

# Start fresh
claude
```

## Post-Installation Setup

### Verify Agent Detection

```bash
# In Claude Code
/agents
```

You should see your agents listed under "Project agents (.claude/agents)":

```
Project agents (.claude/agents)
  strategist - Product strategy and requirements specialist
  developer - Full-stack development specialist
  tester - Quality assurance and testing specialist
  operator - DevOps and deployment specialist
```

### Test Basic Functionality

```bash
# Test individual agent
@strategist What types of projects can you help me plan?

# Test agent interaction
@strategist Create requirements for a user authentication system
@developer Review the requirements above and provide implementation approach
```

### Backup Verification

Check that backups were created:

```bash
ls -la ~/.claude/backups/agent-11/
```

## Verification

### Installation Success Checklist

- [ ] No error messages during installation
- [ ] "🎉 AGENT-11 Squad Deployed Successfully!" message shown
- [ ] Agents visible in Claude Code `/agents` command
- [ ] Test agent responds to @agentname commands
- [ ] Backup created in `~/.claude/backups/agent-11/`

### Manual Verification

```bash
# Check agent files exist
ls -la ~/.claude/agents/

# Check file format
head -10 ~/.claude/agents/strategist.md

# Should show YAML header:
# ---
# name: strategist
# description: ...
# ---
```

### Functional Testing

```bash
@strategist Hello! Can you help me plan a project?
@developer What programming languages and frameworks do you work with?
@tester How do you approach testing new features?
@operator What deployment strategies do you recommend?
```

## Platform-Specific Notes

### macOS
- Uses built-in bash shell
- Home directory: `/Users/username`
- May prompt for directory creation permissions

### Linux
- Uses system bash shell
- Home directory: `/home/username`
- File permissions automatically handled

### Windows (WSL)
- Requires Windows Subsystem for Linux
- Home directory: `/home/username` (within WSL)
- May need to install git: `sudo apt install git`

### Windows (Native)
- Use Git Bash or PowerShell with bash support
- Home directory: `C:\Users\username`
- May require additional path configuration

## Troubleshooting

### Installation Fails

**Error**: "Permission denied"
```bash
chmod +x deployment/scripts/install.sh
./deployment/scripts/install.sh core
```

**Error**: "Agent source directory not found"
```bash
# Ensure you're in the agent-11 directory
pwd
ls -la agents/specialists/
```

**Error**: "Cannot write to home directory"
```bash
# Check home directory permissions
ls -ld $HOME
# Should show write permissions for user
```

### Agents Not Appearing

**Issue**: No agents in `/agents` list
```bash
# Restart Claude Code
/exit
claude

# Check agents directory
ls -la ~/.claude/agents/
```

**Issue**: Agent files exist but not detected
```bash
# Check file format
head -10 ~/.claude/agents/strategist.md
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
grep "name:" ~/.claude/agents/strategist.md
```

### Rollback Issues

**Issue**: Installation failed and rollback didn't work
```bash
# Manual cleanup
rm -rf ~/.claude/agents/
# Restore from backup manually
cp -r ~/.claude/backups/agent-11/latest/* ~/.claude/agents/
```

### Performance Issues

**Issue**: Slow installation
```bash
# Check available disk space
df -h $HOME
# Should have at least 10MB free
```

**Issue**: Agents slow to respond
- This is normal for first interaction after installation
- Subsequent responses should be faster

## Advanced Installation Options

### Custom Agent Selection

```bash
# Install only specific agents (requires manual modification)
# Edit deployment/configs/squad-definitions.yaml
# Add custom squad definition
```

### Different Installation Directory

```bash
# Set custom Claude directory (advanced users)
export CLAUDE_DIR="/custom/path"
./deployment/scripts/install.sh core
```

### Development Installation

```bash
# For AGENT-11 developers
./deployment/scripts/install.sh core --dev
# Links files instead of copying (changes reflect immediately)
```

## Upgrade and Maintenance

### Upgrading Squads

```bash
# Upgrade from core to full
./deployment/scripts/install.sh full
# Existing agents preserved, new ones added

# Downgrade (with confirmation)
./deployment/scripts/install.sh core --force
```

### Updating Agents

```bash
# Pull latest changes
git pull origin main

# Re-run installation
./deployment/scripts/install.sh core
```

### Backup Management

```bash
# List backups
ls -la ~/.claude/backups/agent-11/

# Restore from specific backup
cp -r ~/.claude/backups/agent-11/20240203_143022/* ~/.claude/agents/
```

## Getting Help

### Self-Diagnosis

```bash
# Run environment validation
./deployment/scripts/validate-environment.sh

# Check installation logs
cat ~/.claude/logs/agent-11-install.log
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

# Installation logs
cat ~/.claude/logs/agent-11-install.log

# Agent file status
ls -la ~/.claude/agents/
```

---

**Need immediate help?** Deploy the support agent: `@support Help me troubleshoot my AGENT-11 installation`

**Installation working perfectly?** Share your success story in `/community/SUCCESS-STORIES.md`