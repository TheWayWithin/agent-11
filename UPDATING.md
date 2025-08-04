# Updating Your AGENT-11 Installation

*Getting the latest features and mission system in your existing project*

## Quick Update (Recommended)

**For most users:** Run this single command in your project directory to get the latest AGENT-11 with full mission system:

```bash
# Navigate to your project
cd /path/to/your/project

# Update to latest version with mission system
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/deployment/scripts/install.sh | bash -s core
```

**This will:**
- ✅ Backup your existing agents automatically
- ✅ Update agents to latest versions  
- ✅ Add missing mission files (`/missions` directory)
- ✅ Add `/coord` command (`.claude/commands/coord.md`)
- ✅ Add mission templates (`/templates` directory)
- ✅ Preserve your project work completely

## What You'll Get

### New Mission System
- **`/coord` command**: Execute systematic multi-agent workflows
- **Mission files**: Pre-built missions like BUILD, FIX, MVP, REFACTOR
- **Custom missions**: Templates to create your own workflows

### Latest Agent Improvements
- Enhanced agent capabilities and coordination
- Improved project context understanding
- Better collaboration protocols

## Before You Update

### Check What You Have
```bash
# Check your current installation
ls -la .claude/agents/     # Should show your current agents
ls -la missions/ 2>/dev/null && echo "✅ Mission system present" || echo "❌ Mission system missing"
ls -la .claude/commands/ 2>/dev/null && echo "✅ Commands present" || echo "❌ Commands missing"
```

### Backup (Optional)
The installer creates automatic backups, but you can create your own:
```bash
# Manual backup (optional - installer does this automatically)
cp -r .claude/ backup-claude-$(date +%Y%m%d)
```

## Update Options

### Option 1: Complete Update (Recommended)
Updates everything to latest version:
```bash
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/deployment/scripts/install.sh | bash -s core
```

### Option 2: Mission System Only
If you just want to add the `/coord` command and missions:
```bash
# Create directories
mkdir -p missions .claude/commands templates

# Download mission system files
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/missions/library.md -o missions/library.md
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/missions/mission-build.md -o missions/mission-build.md
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/missions/mission-fix.md -o missions/mission-fix.md
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/missions/mission-mvp.md -o missions/mission-mvp.md
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/missions/mission-refactor.md -o missions/mission-refactor.md
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/missions/operation-genesis.md -o missions/operation-genesis.md
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/missions/README.md -o missions/README.md

# Download command files
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/.claude/commands/coord.md -o .claude/commands/coord.md

# Download templates
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/templates/mission-template.md -o templates/mission-template.md
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/templates/agent-creation-mastery.md -o templates/agent-creation-mastery.md
```

### Option 3: Squad Upgrade
Upgrade from Core to Full squad (adds 7 more specialists):
```bash
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/deployment/scripts/install.sh | bash -s full
```

## After Updating

### Verify Installation
```bash
# Check everything is installed
ls -la .claude/agents/     # Your agents
ls -la missions/           # Mission files
ls -la .claude/commands/   # coord.md command
ls -la templates/          # Mission templates

# Test the mission system
claude
/coord
```

### Try New Features
```bash
# Test mission command
/coord build requirements.md
/coord fix bug-report.md  
/coord mvp product-vision.md
/coord                    # Interactive mode

# Or continue using direct agent commands
@strategist "What should we build next?"
@developer "Implement the authentication feature"
```

## Troubleshooting Updates

### Issue: "No project detected"
**Solution**: Make sure you're in a valid project directory
```bash
pwd  # Check you're in the right place
ls -la  # Should show .git, package.json, or other project files
```

### Issue: "/coord command not found"
**Solution**: Restart Claude Code to reload commands
```bash
/exit
claude
/coord  # Should work now
```

### Issue: "Mission files not found"
**Solution**: Check mission files are in the right place
```bash
ls -la missions/
# Should show: library.md, mission-build.md, etc.
```

### Issue: Update seems to have failed
**Solution**: Check the backup and restore if needed
```bash
# Check for backup
ls -la .claude/backups/agent-11/

# If backup exists, you can restore
# (Contact support or check troubleshooting guide)
```

## Multiple Project Updates

If you have AGENT-11 in multiple projects:

```bash
# Update each project separately
cd ~/project-1
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/deployment/scripts/install.sh | bash -s core

cd ~/project-2  
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/deployment/scripts/install.sh | bash -s core
```

Each project gets updated independently with no interference.

## Staying Updated

### Automatic Updates (Optional)
Set up the update manager for automatic checking:
```bash
# Download update manager
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/deployment/scripts/update-manager.sh -o deployment/scripts/update-manager.sh
chmod +x deployment/scripts/update-manager.sh

# Configure automatic checking
./deployment/scripts/update-manager.sh configure
```

### Manual Updates
Check for updates periodically:
```bash
# Check what's new
curl -s https://api.github.com/repos/TheWayWithin/agent-11/releases/latest | grep '"tag_name"'

# Update when ready
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/deployment/scripts/install.sh | bash -s core
```

## Version History

### v2.0.0+ (Current)
- ✅ Mission system with `/coord` command
- ✅ Systematic multi-agent workflows  
- ✅ Mission templates and customization
- ✅ Enhanced agent coordination

### v1.x (Legacy)
- ✅ Basic agent deployment
- ❌ No mission system
- ❌ No `/coord` command
- ❌ Manual agent coordination only

## FAQ

**Q: Will updating break my current work?**
A: No. The installer creates automatic backups and preserves all your project files.

**Q: Can I rollback if something goes wrong?**
A: Yes. The installer creates backups before any changes. Contact support for rollback help.

**Q: Do I need to update all my projects?**
A: No. Each project is independent. Update when convenient.

**Q: What if I have custom agents?**
A: Custom agents are preserved. The update only affects standard AGENT-11 agents.

**Q: How often should I update?**
A: Update when you want new features or see an announcement. No forced updates.

---

**Need Help?** 
- Check the [Troubleshooting Guide](TROUBLESHOOTING.md)
- Deploy `@support` in your project for assistance
- Review the [Update Management Guide](field-manual/update-management.md) for advanced options

**Ready to unlock the full power of AGENT-11?** Run the update command and start using `/coord` for systematic development! 🎖️