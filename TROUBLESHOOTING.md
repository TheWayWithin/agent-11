# AGENT-11 Troubleshooting Guide

Complete problem-solving guide for AGENT-11 deployment and usage issues. This guide provides solutions for common problems, error messages, and system recovery procedures.

## Table of Contents

- [Quick Diagnostic Commands](#quick-diagnostic-commands)
- [Installation Issues](#installation-issues)
- [Agent Detection Problems](#agent-detection-problems)
- [Agent Response Issues](#agent-response-issues)
- [Performance Problems](#performance-problems)
- [Backup and Recovery](#backup-and-recovery)
- [Platform-Specific Issues](#platform-specific-issues)
- [Error Messages Reference](#error-messages-reference)
- [System Recovery](#system-recovery)

## Quick Diagnostic Commands

Start troubleshooting with these commands:

```bash
# Check if agents are installed
ls -la ~/.claude/agents/

# Verify Claude Code can see agents
claude
/agents

# Test basic agent functionality
@strategist Hello, are you working?

# Check installation logs
cat ~/.claude/logs/agent-11-install.log

# Run system validation
./deployment/scripts/validate-environment.sh
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

### Problem: "Agent source directory not found"

**Error Message**:
```
[ERROR] Agent source directory not found: /path/to/agent-11/agents/specialists
```

**Diagnosis**:
```bash
# Check current directory
pwd
# Should be in agent-11 root directory

# Check if agents directory exists
ls -la agents/specialists/
```

**Solution**:
```bash
# Navigate to correct directory
cd /path/to/agent-11

# Verify agents exist
ls -la agents/specialists/

# Re-run installation
./deployment/scripts/install.sh core
```

### Problem: "Cannot write to home directory"

**Error Message**:
```
[ERROR] Cannot write to home directory: /home/username
```

**Diagnosis**:
```bash
# Check home directory permissions
ls -ld $HOME

# Check available disk space
df -h $HOME
```

**Solution**:
```bash
# Fix permissions (if owned by you)
sudo chown $USER:$USER $HOME

# Or create agents directory manually
mkdir -p ~/.claude/agents
chmod 755 ~/.claude/agents

# Re-run installation
./deployment/scripts/install.sh core
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
rm -rf ~/.claude/agents/

# Restart with verbose logging
./deployment/scripts/install.sh core --debug

# Check logs for specific error
tail -f ~/.claude/logs/agent-11-install.log
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
# Check if agent files exist
ls -la ~/.claude/agents/

# Check file permissions
ls -la ~/.claude/agents/*.md

# Check file format
head -5 ~/.claude/agents/strategist.md
```

**Solution**:
```bash
# Restart Claude Code completely
/exit
claude

# Check agents again
/agents

# If still not working, verify file format
grep -n "^name:" ~/.claude/agents/*.md
# Each file should have a name field
```

**Advanced Solution**:
```bash
# Manually verify YAML headers
for file in ~/.claude/agents/*.md; do
  echo "Checking $file:"
  head -10 "$file" | grep -E "^(---|name:|description:)"
done
```

### Problem: Agents Show but Don't Respond

**Symptoms**: Agents appear in `/agents` but don't respond to @mentions

**Diagnosis**:
```bash
# Check exact agent names
/agents
# Note the exact spelling

# Test with exact name
@strategist test

# Check for hidden characters
cat -A ~/.claude/agents/strategist.md | head -10
```

**Solution**:
```bash
# Use exact agent name from /agents list
# Note: agent names are case-sensitive

# If name has spaces, use quotes
@"agent name" test message

# Verify YAML name matches filename
grep "name:" ~/.claude/agents/strategist.md
# Should output: name: strategist
```

### Problem: Some Agents Missing After Installation

**Symptoms**: Only some agents from squad appear in `/agents`

**Diagnosis**:
```bash
# Check which agents were requested
./deployment/scripts/install.sh core --dry-run

# Check which files exist
ls -la ~/.claude/agents/

# Check installation logs
grep "Installing" ~/.claude/logs/agent-11-install.log
```

**Solution**:
```bash
# Re-run installation for missing agents
./deployment/scripts/install.sh core --force

# Or install specific agents manually
cp agents/specialists/tester.md ~/.claude/agents/

# Restart Claude Code
/exit
claude
```

## Agent Response Issues

### Problem: Agent Gives Generic Responses

**Symptoms**: Agent responds but doesn't follow specialized instructions

**Diagnosis**:
```bash
# Check agent file content
cat ~/.claude/agents/strategist.md

# Verify it contains specialized prompt
grep -i "strategist" ~/.claude/agents/strategist.md
```

**Solution**:
```bash
# Re-install agents to get latest versions
./deployment/scripts/install.sh core --update

# Or restore from backup
./deployment/scripts/backup-manager.sh restore latest
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
# Check if backup exists
ls -la ~/.claude/backups/agent-11/

# Restore from latest backup
./deployment/scripts/backup-manager.sh restore latest

# Or restore manually
cp -r ~/.claude/backups/agent-11/latest/* ~/.claude/agents/

# Restart Claude Code
/exit
claude
```

### Problem: Backup Restoration Fails

**Error Message**:
```
[ERROR] Backup directory not found
```

**Diagnosis**:
```bash
# Check backup directory
ls -la ~/.claude/backups/agent-11/

# Check backup contents
ls -la ~/.claude/backups/agent-11/*/
```

**Solution**:
```bash
# Manual restoration
mkdir -p ~/.claude/agents/

# Find valid backup
for backup in ~/.claude/backups/agent-11/*/; do
  echo "Backup: $backup"
  ls "$backup"
done

# Copy from valid backup
cp -r ~/.claude/backups/agent-11/20240203_143022/* ~/.claude/agents/
```

### Problem: No Backups Available

**If you have no backups and lost agents**:

```bash
# Clean reinstall
rm -rf ~/.claude/agents/

# Fresh installation
./deployment/scripts/install.sh core

# This will create new agents and new backup
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
# Use Linux paths in WSL
cd /mnt/c/Users/username/agent-11/
./deployment/scripts/install.sh core
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
| `No such file or directory` | Wrong directory | `cd agent-11` first |
| `Cannot write to home` | Permission issue | Check `$HOME` permissions |
| `Agent source not found` | Missing agent files | Verify git clone worked |
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
| `Backup directory not found` | No backups exist | Run installation to create backup |
| `Restore failed` | Corrupted backup | Try different backup |
| `Cannot create backup` | Permission issue | Check write permissions |

## System Recovery

### Complete System Reset

If everything is broken, start fresh:

```bash
# 1. Remove all agent files
rm -rf ~/.claude/agents/
rm -rf ~/.claude/backups/agent-11/

# 2. Clean logs
rm -f ~/.claude/logs/agent-11*.log

# 3. Fresh installation
cd /path/to/agent-11
git checkout HEAD -- .
./deployment/scripts/install.sh core

# 4. Verify installation
/exit
claude
/agents
@strategist Hello!
```

### Partial Recovery

If some agents work but others don't:

```bash
# 1. Identify working agents
/agents

# 2. Backup working agents
mkdir -p ~/temp-agent-backup/
cp ~/.claude/agents/* ~/temp-agent-backup/

# 3. Clean reinstall
rm -rf ~/.claude/agents/
./deployment/scripts/install.sh core

# 4. Test all agents
@strategist test
@developer test  
@tester test
@operator test
```

### Emergency Rollback

If new installation breaks everything:

```bash
# 1. Stop Claude Code
/exit

# 2. Emergency restore
rm -rf ~/.claude/agents/
cp -r ~/.claude/backups/agent-11/latest/* ~/.claude/agents/

# 3. Start Claude Code
claude

# 4. Verify recovery
/agents
```

## Getting Additional Help

### Self-Diagnosis Tools

```bash
# Run comprehensive check
./deployment/scripts/health-check.sh --full

# Generate diagnostic report
./deployment/scripts/diagnostics.sh > my-diagnostic-report.txt
```

### Log Analysis

```bash
# View installation logs
less ~/.claude/logs/agent-11-install.log

# Search for errors
grep -i error ~/.claude/logs/agent-11-install.log

# Check recent activity
tail -50 ~/.claude/logs/agent-11-install.log
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

# AGENT-11 status
ls -la ~/.claude/agents/
cat ~/.claude/logs/agent-11-install.log

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