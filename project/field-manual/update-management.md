# Update Management Guide

*Keeping your AGENT-11 installation current and managing version updates*

## Overview

AGENT-11 includes a comprehensive update management system that handles version checking, automated updates, backup creation, and rollback capabilities. This guide covers how to manage updates across your AGENT-11 installations and ensure you always have the latest features and security improvements.

## Update Manager Overview

The update manager (`deployment/scripts/update-manager.sh`) provides:

- **Automatic Version Checking**: Configurable schedule for checking updates
- **Safe Updates**: Automatic backups before any changes
- **Rollback Support**: Easy restoration from backups
- **Flexible Configuration**: Customize update behavior for your workflow
- **Changelog Integration**: Review changes before updating

## Quick Start

### Check for Updates

```bash
# Navigate to any project with AGENT-11 installed
cd /path/to/your/project

# Check for available updates
./deployment/scripts/update-manager.sh check
```

### Install Updates

```bash
# Update to the latest version
./deployment/scripts/update-manager.sh update

# Update to a specific version
./deployment/scripts/update-manager.sh update v2.1.0
```

### View Current Status

```bash
# Show version and configuration information
./deployment/scripts/update-manager.sh status
```

## Installation and Setup

### Enable Update Management

If you installed AGENT-11 recently, update management should be available automatically. For older installations:

```bash
# Navigate to your AGENT-11 installation
cd /path/to/your/project

# Download the update manager
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/deployment/scripts/update-manager.sh -o deployment/scripts/update-manager.sh

# Make it executable
chmod +x deployment/scripts/update-manager.sh

# Set up initial configuration
./deployment/scripts/update-manager.sh configure
```

### Initial Configuration

Configure update behavior for your needs:

```bash
./deployment/scripts/update-manager.sh configure
```

This will prompt you to set:
- **Automatic Checking**: Enable/disable automatic update checking
- **Check Frequency**: Daily, weekly, or monthly checks
- **Auto Installation**: Whether to install updates automatically
- **Notifications**: Enable update notifications
- **Backup Policy**: Create backups before updates

**Recommended Settings for Most Users:**
- Auto Check: Yes
- Frequency: Weekly
- Auto Install: No (manual approval recommended)
- Notifications: Yes
- Backup: Yes

## Configuration Options

### Update Check Frequency

Choose how often to check for updates:

**Daily Checking:**
- Best for: Active development projects
- Pros: Always aware of latest updates
- Cons: May be too frequent for stable projects

**Weekly Checking (Recommended):**
- Best for: Most projects
- Pros: Good balance of awareness and stability
- Cons: None significant

**Monthly Checking:**
- Best for: Stable production projects
- Pros: Minimal disruption
- Cons: May miss important security updates

### Automatic Installation Policy

**Manual Installation (Recommended):**
```bash
# Review updates before installing
./deployment/scripts/update-manager.sh check
./deployment/scripts/update-manager.sh update
```

**Automatic Installation:**
```bash
# Configure for automatic updates
./deployment/scripts/update-manager.sh configure
# Choose "yes" for automatic installation
```

**Hybrid Approach:**
- Auto-install patch versions (bug fixes)
- Manual approval for minor/major versions (feature changes)

## Backup and Restore System

### Automatic Backup Creation

When backups are enabled, the update manager automatically creates backups before any changes:

```bash
# Backups are stored at:
~/.claude/agent-11/backups/backup-YYYYMMDD_HHMMSS/
```

### Manual Backup Creation

```bash
# Create a manual backup before major changes
./deployment/scripts/update-manager.sh backup
```

### List Available Backups

```bash
# See all available backups
./deployment/scripts/update-manager.sh list-backups
```

### Restore from Backup

```bash
# Restore from a specific backup
./deployment/scripts/update-manager.sh restore backup-20240203_143052
```

### Backup Contents

Each backup includes:
- All agent configurations (`~/.claude/agents/`)
- AGENT-11 configuration files
- Version information
- Update history

## Version Management

### Understanding Version Numbers

AGENT-11 uses semantic versioning (MAJOR.MINOR.PATCH):

- **MAJOR**: Breaking changes, new architecture
- **MINOR**: New features, backward compatible
- **PATCH**: Bug fixes, security updates

**Examples:**
- `v1.0.0` → `v1.0.1`: Patch update (safe)
- `v1.0.0` → `v1.1.0`: Minor update (new features)
- `v1.0.0` → `v2.0.0`: Major update (review changes)

### Update Strategy by Version Type

**Patch Updates (1.0.0 → 1.0.1):**
```bash
# Generally safe to auto-install
./deployment/scripts/update-manager.sh update
```

**Minor Updates (1.0.0 → 1.1.0):**
```bash
# Review changelog first
./deployment/scripts/update-manager.sh check
# Then update
./deployment/scripts/update-manager.sh update
```

**Major Updates (1.0.0 → 2.0.0):**
```bash
# Review changelog and backup manually
./deployment/scripts/update-manager.sh backup
./deployment/scripts/update-manager.sh check
# Plan testing after update
./deployment/scripts/update-manager.sh update
```

## Automated Update Checking

### Enable Scheduled Checks

```bash
# Set up automatic checking via cron
./deployment/scripts/update-manager.sh schedule
```

This creates a cron job that checks for updates based on your configured frequency.

### Manual Scheduling

Add to your crontab manually:

```bash
# Edit crontab
crontab -e

# Add line for weekly checks (Mondays at 9 AM)
0 9 * * 1 /path/to/your/project/deployment/scripts/update-manager.sh check >/dev/null 2>&1
```

### Disable Automatic Checking

```bash
# Reconfigure to disable
./deployment/scripts/update-manager.sh configure
# Choose "no" for automatic checking
```

## Multi-Project Update Management

### Centralized Update Script

For managing multiple projects:

```bash
#!/bin/bash
# update-all-projects.sh

PROJECTS=(
    "$HOME/projects/project-a"
    "$HOME/projects/project-b"
    "$HOME/projects/project-c"
)

for project in "${PROJECTS[@]}"; do
    if [[ -f "$project/deployment/scripts/update-manager.sh" ]]; then
        echo "Checking updates for $(basename $project)..."
        cd "$project"
        ./deployment/scripts/update-manager.sh check
    fi
done
```

### Project-Specific Update Policies

Different projects may need different update strategies:

**Development Projects:**
```bash
# More frequent updates, automatic installation
./deployment/scripts/update-manager.sh configure
# Choose daily checks, auto-install enabled
```

**Production Projects:**
```bash
# Conservative updates, manual approval
./deployment/scripts/update-manager.sh configure
# Choose monthly checks, manual installation
```

## Troubleshooting Updates

### Common Issues and Solutions

**Issue: Update Check Fails**
```bash
# Check network connectivity
curl -I https://api.github.com/repos/TheWayWithin/agent-11

# Check if behind corporate firewall
# Configure proxy if needed
```

**Issue: Update Installation Fails**
```bash
# Check disk space
df -h ~/.claude/

# Check permissions
ls -la ~/.claude/agents/

# Restore from backup if needed
./deployment/scripts/update-manager.sh restore backup-YYYYMMDD_HHMMSS
```

**Issue: Agents Not Working After Update**
```bash
# Restart Claude Code in project directory
/exit
cd /path/to/your/project
claude

# Verify agents are loaded
/agents

# If still failing, restore backup
./deployment/scripts/update-manager.sh restore backup-YYYYMMDD_HHMMSS
```

### Update Validation

After any update:

```bash
# Verify version was updated
./deployment/scripts/update-manager.sh status

# Test agent functionality
@strategist "Confirm you're working correctly after the update"

# Check project-specific functionality
@developer "Review the current project and confirm all context is preserved"
```

### Emergency Rollback

If an update causes issues:

```bash
# Quick rollback to previous version
./deployment/scripts/update-manager.sh list-backups
./deployment/scripts/update-manager.sh restore backup-YYYYMMDD_HHMMSS

# Restart Claude Code
/exit && claude

# Verify functionality
/agents
@coordinator "Confirm all systems are operational"
```

## Update Notifications

### Configuring Notifications

Enable notifications to stay informed about updates:

```bash
./deployment/scripts/update-manager.sh configure
# Choose "yes" for notifications
```

### Notification Methods

**Terminal Notifications:**
- Shown when checking for updates
- Displayed during scheduled checks

**Log File Notifications:**
```bash
# Check update log
tail -f ~/.claude/agent-11/updates.log
```

### Custom Notification Scripts

Create custom notification handlers:

```bash
#!/bin/bash
# ~/.claude/agent-11/notification-handler.sh

if [[ "$1" == "update_available" ]]; then
    # Send email, Slack message, etc.
    echo "AGENT-11 update available: $2" | mail -s "AGENT-11 Update" user@example.com
fi
```

## Best Practices

### Update Workflow

1. **Regular Checking**: Enable weekly automatic checks
2. **Review Changes**: Always read changelog before updating
3. **Backup First**: Ensure backups are enabled
4. **Test After Update**: Verify agents work correctly
5. **Rollback if Needed**: Don't hesitate to rollback if issues arise

### Version Strategy

**For Development:**
- Keep current with latest versions
- Auto-install patch updates
- Review minor updates
- Plan for major updates

**For Production:**
- Conservative update schedule
- Manual review of all updates
- Extensive testing before applying
- Maintain multiple backup versions

### Multi-Environment Management

**Development Environment:**
```bash
# Latest features, frequent updates
./deployment/scripts/update-manager.sh configure
# Daily checks, auto-install patches
```

**Staging Environment:**
```bash
# Test updates before production
# Manual updates after development validation
```

**Production Environment:**
```bash
# Stable versions only
# Manual updates with full testing
# Multiple backup retention
```

## Integration with CI/CD

### Automated Update Testing

```yaml
# .github/workflows/test-agent-updates.yml
name: Test AGENT-11 Updates
on:
  schedule:
    - cron: '0 2 * * 1' # Weekly Monday 2 AM
  workflow_dispatch:

jobs:
  test-update:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Check for updates
        run: ./deployment/scripts/update-manager.sh check
      - name: Test update in staging
        run: ./deployment/scripts/update-manager.sh update
      - name: Validate agents
        run: |
          # Test agent functionality
          # Run integration tests
```

### Update Approval Workflow

```bash
# Create update proposal
./deployment/scripts/update-manager.sh check > update-proposal.md

# Review and approve
git add update-proposal.md
git commit -m "Propose AGENT-11 update to v2.1.0"

# After approval, apply update
./deployment/scripts/update-manager.sh update
```

---

**Remember**: Regular updates ensure you have the latest features, bug fixes, and security improvements. The backup and rollback system makes updates safe, so don't hesitate to keep your AGENT-11 installation current.

**Pro Tip**: Set up different update policies for different types of projects - aggressive updates for development, conservative for production.