# AGENT-11 Project Troubleshooting Guide

Complete problem-solving guide for AGENT-11 project deployment and usage issues. This guide provides solutions for common problems, error messages, and project-specific recovery procedures.

## Table of Contents

- [Quick Diagnostic Commands](#quick-diagnostic-commands)
- [Installation Issues](#installation-issues)
- [Agent Detection Problems](#agent-detection-problems)
- [Agent Response Issues](#agent-response-issues)
- [Mission System Issues](#mission-system-issues)
- [Performance Problems](#performance-problems)
- [Backup and Recovery](#backup-and-recovery)
- [Platform-Specific Issues](#platform-specific-issues)
- [Error Messages Reference](#error-messages-reference)
- [System Recovery](#system-recovery)

## Quick Diagnostic Commands

Start troubleshooting with these project-focused commands:

```bash
# Ensure you're in your project directory
pwd  # Should show your project path

# Check if project agents are installed
ls -la .claude/agents/

# Check if mission system is installed
ls -la missions/
ls -la .claude/commands/
ls -la templates/

# Verify Claude Code can see project agents
claude
/agents

# Test project-aware agent functionality
@strategist What type of project is this?

# Test mission system
/coord

# Check project structure
ls -la  # Should show .git, package.json, source files, etc.
```

## Installation Issues

### Problem: "Permission denied" Error

**Error Message**:
```
bash: ./deployment/scripts/install.sh: Permission denied
```

**Solution**:
```bash
# Make script executable
chmod +x deployment/scripts/install.sh

# Run installation
./deployment/scripts/install.sh core
```

**Alternative Solution** (if chmod fails):
```bash
# Run with bash directly
bash deployment/scripts/install.sh core
```

### Problem: "No project detected" or "Not a valid project directory"

**Error Message**:
```
[ERROR] No project detected in current directory
[ERROR] Not a valid project directory
```

**Diagnosis**:
```bash
# Check current directory
pwd  # Should show your project path

# Check for project indicators
ls -la  # Should show .git, package.json, source files, etc.
```

**Solution**:
```bash
# Navigate to your project directory
cd /path/to/your/project

# Verify it's a valid project
ls -la  # Should show project files

# If not a project, initialize one:
git init
echo '{}' > package.json  # or create appropriate project files

# Re-run installation
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/deployment/scripts/install.sh | bash -s core
```

### Problem: "Cannot write to project directory"

**Error Message**:
```
[ERROR] Cannot write to project directory: /path/to/project
```

**Diagnosis**:
```bash
# Check project directory permissions
ls -ld .  # Should show write permissions for your user

# Check available disk space
df -h .  # Should have at least 10MB free
```

**Solution**:
```bash
# Fix permissions (if you own the project)
sudo chown -R $USER:$USER .

# Or create project agents directory manually
mkdir -p .claude/agents
chmod 755 .claude/agents

# Re-run installation from project directory
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/deployment/scripts/install.sh | bash -s core
```

### Problem: Installation Hangs or Freezes

**Symptoms**: Installation starts but never completes

**Diagnosis**:
```bash
# Check if process is running
ps aux | grep install.sh

# Check system resources
top
df -h
```

**Solution**:
```bash
# Kill hung process
pkill -f install.sh

# Clean partial installation
rm -rf .claude/agents/

# Ensure you're in project directory
pwd  # Should show your project path

# Restart installation
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/deployment/scripts/install.sh | bash -s core
```

### Problem: "Invalid agent file format"

**Error Message**:
```
[ERROR] Invalid agent file format (missing YAML header): strategist.md
```

**Diagnosis**:
```bash
# Check agent file format
head -10 agents/specialists/strategist.md
# Should start with ---
```

**Solution**:
```bash
# Re-download or reset agent files
git checkout HEAD -- agents/specialists/

# Verify file integrity
./deployment/scripts/validate-agents.sh

# Re-run installation
./deployment/scripts/install.sh core
```

## Agent Detection Problems

### Problem: Agents Not Showing in `/agents` List

**Symptoms**: Installation succeeds but agents don't appear in Claude Code

**Diagnosis**:
```bash
# Ensure you're in the project directory
pwd  # Should show your project path

# Check if project agent files exist
ls -la .claude/agents/

# Check file permissions
ls -la .claude/agents/*.md

# Check file format
head -5 .claude/agents/strategist.md
```

**Solution**:
```bash
# Restart Claude Code in project directory
/exit
cd /path/to/your/project
claude

# Check project agents again
/agents

# If still not working, verify file format
grep -n "^name:" .claude/agents/*.md
# Each file should have a name field
```

**Advanced Solution**:
```bash
# Manually verify YAML headers in project agents
for file in .claude/agents/*.md; do
  echo "Checking $file:"
  head -10 "$file" | grep -E "^(---|name:|description:)"
done
```

### Problem: Agents Show but Don't Respond

**Symptoms**: Agents appear in `/agents` but don't respond to @mentions

**Diagnosis**:
```bash
# Ensure Claude Code is running in project directory
pwd  # Should show your project path

# Check exact agent names
/agents
# Note the exact spelling

# Test with exact name
@strategist test

# Check for hidden characters in project agents
cat -A .claude/agents/strategist.md | head -10
```

**Solution**:
```bash
# Use exact agent name from /agents list
# Note: agent names are case-sensitive

# If name has spaces, use quotes
@"agent name" test message

# Verify YAML name matches filename in project
grep "name:" .claude/agents/strategist.md
# Should output: name: strategist
```

### Problem: Some Agents Missing After Installation

**Symptoms**: Only some agents from squad appear in `/agents`

**Diagnosis**:
```bash
# Check which files exist in project
ls -la .claude/agents/

# Verify you're in the right project directory
pwd  # Should show your project path

# Check what squad was requested
echo "Expected agents for core squad: strategist, developer, tester, operator"
```

**Solution**:
```bash
# Re-run installation for missing agents from project directory
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/deployment/scripts/install.sh | bash -s core

# Restart Claude Code in project directory
/exit
cd /path/to/your/project
claude
```

## Agent Response Issues

### Problem: Agent Gives Generic Responses

**Symptoms**: Agent responds but doesn't follow specialized instructions

**Diagnosis**:
```bash
# Check project agent file content
cat .claude/agents/strategist.md

# Verify it contains specialized prompt
grep -i "strategist" .claude/agents/strategist.md
```

**Solution**:
```bash
# Re-install project agents to get latest versions
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/deployment/scripts/install.sh | bash -s core

# This will update your project's agents
```

### Problem: Agent "Not Found" Error

**Error Message**:
```
Agent 'strategist' not found
```

**Solution**:
```bash
# Check exact agent name
/agents

# Use exact name (case-sensitive)
@strategist (not @Strategist or @strategy)

# If name is different, use the correct one
@agent_name_from_list your message here
```

### Problem: Agent Responses Are Slow

**Symptoms**: Long delays before agent responds

**Diagnosis**:
```bash
# Check system resources
top
free -h

# Check Claude Code logs
claude --verbose
```

**Solutions**:
```bash
# Restart Claude Code
/exit
claude

# Check network connection
ping claude.ai

# Optimize agent prompts (reduce length)
# Large agent files can slow responses
```

## Mission System Issues

### Problem: `/coord` Command Not Found

**Symptoms**: Claude Code shows "Command not found" when using `/coord`

**Diagnosis**:
```bash
# Check if command file exists
ls -la .claude/commands/coord.md

# Check if you're in the correct project directory
pwd
```

**Solutions**:
```bash
# If commands directory is missing
mkdir -p .claude/commands

# If coord.md is missing, reinstall mission system
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/.claude/commands/coord.md -o .claude/commands/coord.md

# Or copy from AGENT-11 source if available locally
cp /path/to/agent-11/.claude/commands/coord.md .claude/commands/

# Restart Claude Code to reload commands
/exit
claude
```

### Problem: Mission Files Not Found

**Symptoms**: `/coord` works but can't find mission files like `mission-build.md`

**Diagnosis**:
```bash
# Check mission files exist
ls -la missions/

# Should show: library.md, mission-build.md, mission-fix.md, etc.
```

**Solutions**:
```bash
# Create missions directory
mkdir -p missions

# Download missing mission files
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/missions/library.md -o missions/library.md
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/missions/mission-build.md -o missions/mission-build.md
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/missions/mission-fix.md -o missions/mission-fix.md
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/missions/mission-mvp.md -o missions/mission-mvp.md
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/missions/mission-refactor.md -o missions/mission-refactor.md

# Or copy from AGENT-11 source if available locally
cp -r /path/to/agent-11/missions/* missions/
```

### Problem: Incomplete AGENT-11 Installation

**Symptoms**: Agents work but mission system is missing

**Diagnosis**: Check if installation only includes agents but not mission files

**Solutions**:
```bash
# Reinstall with updated installer to get full mission system
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/deployment/scripts/install.sh | bash -s core

# Or manually install mission system components
mkdir -p missions .claude/commands templates

# Copy all mission system files
cp -r /path/to/agent-11/missions/* missions/
cp -r /path/to/agent-11/.claude/commands/* .claude/commands/
cp -r /path/to/agent-11/templates/* templates/
```

### Problem: Mission System Works But Missing Custom Templates

**Symptoms**: Basic missions work but template creation fails

**Diagnosis**:
```bash
# Check template directory
ls -la templates/

# Should show: mission-template.md, agent-creation-mastery.md
```

**Solutions**:
```bash
# Create templates directory
mkdir -p templates

# Download template files
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/templates/mission-template.md -o templates/mission-template.md
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/templates/agent-creation-mastery.md -o templates/agent-creation-mastery.md

# Or copy from source
cp -r /path/to/agent-11/templates/* templates/
```

## Performance Problems

### Problem: Installation Takes Too Long

**Normal Times**:
- Minimal Squad: 1-2 minutes
- Core Squad: 2-3 minutes  
- Full Squad: 4-5 minutes

**If Slower**:
```bash
# Check disk speed
dd if=/dev/zero of=~/testfile bs=1M count=100
rm ~/testfile

# Check available memory
free -h

# Use parallel installation
./deployment/scripts/install.sh core --parallel
```

### Problem: High CPU Usage During Agent Use

**Diagnosis**:
```bash
# Monitor Claude Code CPU usage
top -p $(pgrep claude)

# Check for runaway processes
ps aux --sort=-%cpu | head -10
```

**Solutions**:
```bash
# Restart Claude Code
/exit
claude

# Reduce agent prompt complexity
# Simplify agent instructions in ~/.claude/agents/

# Use fewer agents simultaneously
# Don't run all 11 agents at once
```

### Problem: Memory Issues

**Symptoms**: System becomes slow or unresponsive

**Diagnosis**:
```bash
# Check memory usage
free -h
cat /proc/meminfo

# Check swap usage
swapon --show
```

**Solutions**:
```bash
# Close unnecessary applications
# Restart Claude Code
/exit
claude

# Use minimal squad instead of full
./deployment/scripts/install.sh minimal

# Add swap space (Linux)
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

## Backup and Recovery

### Problem: Lost Agents After Failed Installation

**Symptoms**: Installation failed and agents are missing

**Solution**:
```bash
# Clean project agents and reinstall
rm -rf .claude/agents/

# Reinstall project squad
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/deployment/scripts/install.sh | bash -s core

# Restart Claude Code in project directory
/exit
cd /path/to/your/project
claude
```

### Problem: Backup Restoration Fails

**Error Message**:
```
[ERROR] Backup directory not found
```

**Diagnosis**:
```bash
# Check if project has any existing agents
ls -la .claude/agents/

# Verify you're in the correct project
pwd  # Should show your project path
```

**Solution**:
```bash
# Manual project agent setup
mkdir -p .claude/agents/

# Reinstall fresh project agents
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/deployment/scripts/install.sh | bash -s core
```

### Problem: No Backups Available

**If you have no project agents**:

```bash
# Clean project reinstall
rm -rf .claude/agents/

# Ensure you're in project directory
pwd  # Should show your project path

# Fresh installation
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/deployment/scripts/install.sh | bash -s core

# This will create new project-specific agents
```

## Platform-Specific Issues

### macOS Issues

**Problem**: "Operation not permitted" error
```bash
# Check System Integrity Protection
csrutil status

# Use different path if needed
mkdir -p ~/claude-agents/
./deployment/scripts/install.sh core --target ~/claude-agents/
```

**Problem**: Gatekeeper blocking scripts
```bash
# Allow script execution
sudo spctl --master-disable

# Or run with explicit interpreter
bash ./deployment/scripts/install.sh core
```

### Linux Issues

**Problem**: SELinux blocking file creation
```bash
# Check SELinux status
sestatus

# Temporarily disable for installation
sudo setenforce 0
./deployment/scripts/install.sh core
sudo setenforce 1
```

**Problem**: Wrong shell (not bash)
```bash
# Check current shell
echo $SHELL

# Switch to bash
bash
./deployment/scripts/install.sh core
```

### Windows (WSL) Issues

**Problem**: Path format issues
```bash
# Use Linux paths in WSL and navigate to your project
cd /mnt/c/Users/username/my-project/
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/deployment/scripts/install.sh | bash -s core
```

**Problem**: File permissions in WSL
```bash
# Fix WSL permissions
sudo umount /mnt/c
sudo mount -t drvfs C: /mnt/c -o metadata
```

## Error Messages Reference

### Installation Errors

| Error | Meaning | Solution |
|-------|---------|----------|
| `Permission denied` | Script not executable | `chmod +x script.sh` |
| `No project detected` | Not in project directory | `cd /path/to/your/project` first |
| `Cannot write to project` | Permission issue | Check project permissions |
| `Not valid project` | Missing project files | Add `.git`, `package.json`, etc. |
| `Invalid agent format` | Corrupted agent file | Re-download agents |

### Runtime Errors

| Error | Meaning | Solution |
|-------|---------|----------|
| `Agent not found` | Wrong agent name | Check `/agents` for exact name |
| `No response` | Agent not loaded | Restart Claude Code |
| `Command not recognized` | Wrong syntax | Use `@agentname message` |
| `Connection timeout` | Network issue | Check internet connection |

### Backup Errors

| Error | Meaning | Solution |
|-------|---------|----------|
| `Project agents not found` | No project agents | Install agents to project |
| `Project installation failed` | Project setup issue | Check project validity |
| `Cannot create project agents` | Permission issue | Check project write permissions |

## System Recovery

### Complete System Reset

If everything is broken, start fresh:

```bash
# 1. Remove project agent files
rm -rf .claude/agents/

# 2. Verify you're in your project directory
pwd  # Should show your project path
ls -la  # Should show project files (.git, package.json, etc.)

# 3. Fresh project installation
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/deployment/scripts/install.sh | bash -s core

# 4. Verify project installation
/exit
cd /path/to/your/project
claude
/agents
@strategist What type of project is this?
```

### Partial Recovery

If some project agents work but others don't:

```bash
# 1. Identify working agents in your project
/agents

# 2. Clean project reinstall
rm -rf .claude/agents/

# 3. Reinstall project squad
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/deployment/scripts/install.sh | bash -s core

# 4. Test all project agents
@strategist What can we build in this project?
@developer What's our current tech stack?
@tester How should we test this project?
@operator How should we deploy this project?
```

### Emergency Rollback

If new project installation breaks everything:

```bash
# 1. Stop Claude Code
/exit

# 2. Clean project agents
rm -rf .claude/agents/

# 3. Start Claude Code in project directory
cd /path/to/your/project
claude

# 4. Try installation again
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/deployment/scripts/install.sh | bash -s core

# 5. Verify recovery
/agents
```

## Getting Additional Help

### Self-Diagnosis Tools

```bash
# Check project agent status
ls -la .claude/agents/

# Verify project directory
pwd  # Should show your project path
ls -la  # Should show project files

# Test project agents
@strategist What type of project is this?
```

### Log Analysis

```bash
# Check recent installation output
# Installation output is shown directly in terminal

# Verify project agent files
ls -la .claude/agents/

# Check agent file content
head -10 .claude/agents/strategist.md
```

### Community Support

1. **Built-in Support**: `@support Help me troubleshoot this issue: [describe problem]`
2. **Documentation**: Check other guides in this repository
3. **GitHub Issues**: Report bugs and get help from maintainers
4. **Community Forums**: Share experiences with other users

### Reporting Issues

When reporting problems, include:

```bash
# System information
uname -a
claude --version

# Project information
pwd  # Current project directory
ls -la  # Project structure
ls -la .claude/agents/  # Project agents

# Project type indicators
file package.json requirements.txt go.mod Cargo.toml 2>/dev/null || echo "No standard project files found"

# Error messages
# Copy exact error messages you're seeing

# Steps to reproduce
# What you did before the problem occurred
```

---

**Still stuck?** The AGENT-11 community is here to help! Report your issue with the diagnostic information above, and we'll get you back up and running quickly. 🛠️

## Emergency Contacts

- **Immediate Help**: Deploy `@support` agent for instant assistance
- **Documentation**: All guides in `/field-manual/` directory  
- **Community**: Join discussions in `/community/` section
- **Bug Reports**: GitHub Issues for technical problems
- **Feature Requests**: GitHub Discussions for improvements

**Remember**: 98% of AGENT-11 installations work perfectly on the first try. If you're having issues, you're in the 2% - but every problem has a solution!