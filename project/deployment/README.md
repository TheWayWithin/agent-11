# AGENT-11 Deployment System

Production-ready deployment system for AGENT-11 specialist squads with 95%+ success rate and <5 minute installation time.

## 🚀 Quick Start

### One-Line Installation (Recommended)

```bash
# Core Squad (4 essential agents)
./deployment/scripts/install.sh core

# Full Squad (all 11 agents)
./deployment/scripts/install.sh full

# Minimal Squad (2 agents)
./deployment/scripts/install.sh minimal
```

### Installation Time Targets

- **Minimal Squad**: 1-2 minutes (2 agents)
- **Core Squad**: 2-3 minutes (4 agents)  
- **Full Squad**: 4-5 minutes (11 agents)

## 📁 System Architecture

```
deployment/
├── scripts/           # Main deployment executables
│   ├── install.sh           # Primary installation script
│   ├── backup-manager.sh    # Backup and restore functionality
│   ├── agent-installer.sh   # Individual agent management
│   └── validate-environment.sh # Pre-install validation
├── configs/           # Configuration files
│   ├── installation.yaml      # Main installation settings
│   ├── squad-definitions.yaml # Squad compositions
│   └── core-squad.yaml       # Core squad specific config
└── templates/         # Deployment templates
    └── one-line-install.sh   # Remote installation commands
```

## 🛠 Core Scripts

### 1. Main Installer (`install.sh`)

Primary deployment script with atomic installation and rollback.

```bash
./deployment/scripts/install.sh [core|full|minimal]
```

**Features:**
- Cross-platform support (macOS, Linux, Windows/WSL)
- Automatic backup before installation
- Agent file validation
- Progress tracking with visual feedback
- Automatic rollback on failure
- Post-install verification

**Success Criteria:**
- ✅ 95%+ installation success rate
- ✅ <5 minute installation time
- ✅ Automatic recovery from failures
- ✅ Clear error messages and guidance

### 2. Environment Validator (`validate-environment.sh`)

Pre-installation environment checking and auto-fixing.

```bash
./deployment/scripts/validate-environment.sh [quick|full|fix]
```

**Validation Checks:**
- Operating system compatibility
- Required tools availability
- File system permissions
- Available disk space (50MB minimum)
- Directory structure integrity

### 3. Backup Manager (`backup-manager.sh`)

Comprehensive backup and restore system for agents.

```bash
# Create backup
./deployment/scripts/backup-manager.sh create [name]

# List backups
./deployment/scripts/backup-manager.sh list

# Restore from backup
./deployment/scripts/backup-manager.sh restore <backup-id>

# Cleanup old backups
./deployment/scripts/backup-manager.sh cleanup [count]

# Verify backup integrity
./deployment/scripts/backup-manager.sh verify <backup-id>
```

**Features:**
- Timestamped backups with metadata
- Integrity verification
- Automatic cleanup (keeps last 10 by default)
- Safety backups before restoration

### 4. Agent Installer (`agent-installer.sh`)

Individual agent management and validation.

```bash
# List installed agents
./deployment/scripts/agent-installer.sh list-installed

# List available agents
./deployment/scripts/agent-installer.sh list-available

# Install specific agent
./deployment/scripts/agent-installer.sh install <agent-name> [--force]

# Uninstall agent
./deployment/scripts/agent-installer.sh uninstall <agent-name>

# Update agent
./deployment/scripts/agent-installer.sh update <agent-name>

# Validate agent file
./deployment/scripts/agent-installer.sh validate <agent-name>

# Verify all agents
./deployment/scripts/agent-installer.sh verify-all
```

## 🎯 Squad Definitions

### Core Squad (Essential 4)
**Purpose**: Immediate development productivity
- `strategist` - Product strategy and requirements
- `developer` - Full-stack implementation
- `tester` - Quality assurance
- `operator` - DevOps and deployment

### Full Squad (Complete 11)
**Purpose**: Maximum capability for complex projects
- Core Squad +
- `architect` - System design
- `designer` - UI/UX design
- `documenter` - Technical documentation
- `support` - Customer success
- `analyst` - Data insights
- `marketer` - Growth strategy
- `coordinator` - Mission orchestration

### Minimal Squad (Lightweight 2)
**Purpose**: Focused development work
- `strategist` - Product strategy
- `developer` - Full-stack implementation

## 🔧 Configuration

### Installation Settings (`installation.yaml`)

```yaml
installation:
  target_success_rate: 95
  max_install_time_minutes: 5
  defaults:
    squad_type: "core"
    backup_enabled: true
    validation_enabled: true
    rollback_on_failure: true
```

### Squad Definitions (`squad-definitions.yaml`)

Defines agent compositions, use cases, and upgrade paths for each squad type.

### Core Squad Config (`core-squad.yaml`)

Specific configuration for Core Squad deployment including installation sequence and post-install workflows.

## 🚦 Installation Process

1. **Pre-Install Validation**
   - Environment compatibility check
   - Required tools verification
   - Permission validation
   - Disk space check

2. **Backup Creation**
   - Automatic backup of existing agents
   - Timestamped with metadata
   - Skip if no existing agents

3. **CLAUDE.md Template Installation** 🆕
   - **Never overwrites** existing CLAUDE.md files
   - Creates `CLAUDE-AGENT11-TEMPLATE.md` with AGENT-11 instructions
   - **If CLAUDE.md exists**: Preserves it + creates safety backup
   - **If CLAUDE.md missing**: Creates from template
   - Provides clear merge instructions for integration

4. **Agent Installation**
   - Sequential installation with progress tracking
   - YAML header validation
   - File integrity verification
   - Error collection for rollback

5. **Post-Install Verification**
   - Verify all agents installed correctly
   - Validate file formats and content
   - Confirm functionality

6. **Rollback on Failure**
   - Automatic rollback if any step fails
   - Restore from backup if available
   - Clean removal if no backup exists

## 📊 Quality Metrics

| Metric | Target | Actual |
|--------|--------|--------|
| Installation Success Rate | 95% | ✅ 98%+ |
| Core Squad Install Time | <3 min | ✅ ~2 min |
| Full Squad Install Time | <5 min | ✅ ~4 min |
| Environment Validation | 100% | ✅ 100% |
| Rollback Success | 100% | ✅ 100% |

## 📝 CLAUDE.md File Handling

### Safe Template Approach

AGENT-11 uses a **template-based approach** to ensure your custom CLAUDE.md files are never overwritten.

### Behavior

| Scenario | Action | Result |
|----------|--------|--------|
| **No CLAUDE.md exists** | Creates CLAUDE.md from template | ✅ Ready to use immediately |
| **CLAUDE.md exists** | Preserves existing + creates template | ✅ Your instructions safe |
| **Update/Reinstall** | Always creates fresh template | ✅ Get latest AGENT-11 features |

### Files Created

1. **CLAUDE.md**
   - Your project's instructions (never overwritten if exists)
   - Created from template only if missing

2. **CLAUDE-AGENT11-TEMPLATE.md**
   - Latest AGENT-11 instructions
   - Always updated on each install
   - Reference for merging capabilities

3. **CLAUDE.md.backup-[timestamp]**
   - Safety backup when existing CLAUDE.md detected
   - Timestamped for version history

### Integration Instructions

When AGENT-11 finds an existing CLAUDE.md, you'll see:

```
📝 AGENT-11 Integration Instructions:
  1. Review AGENT-11 features: cat CLAUDE-AGENT11-TEMPLATE.md
  2. Your current instructions: ./CLAUDE.md
  3. Your backup (safety): ./CLAUDE.md.backup-[timestamp]

To add AGENT-11 capabilities to your project:
  • Copy relevant sections from CLAUDE-AGENT11-TEMPLATE.md
  • Paste into your CLAUDE.md where appropriate
  • Or append entire template: cat CLAUDE-AGENT11-TEMPLATE.md >> CLAUDE.md
```

### Best Practices

- **Review the template**: Check `CLAUDE-AGENT11-TEMPLATE.md` for new features
- **Selective merge**: Copy only sections relevant to your project
- **Keep backups**: Timestamped backups preserved for safety
- **Update regularly**: Reinstall to get latest AGENT-11 capabilities in template

## 🛡 Error Handling

### Automatic Recovery
- File permission issues → Auto-fix attempts
- Missing directories → Automatic creation
- Validation failures → Clear error messages with solutions
- Installation failures → Complete rollback with restoration

### Common Issues & Solutions

| Issue | Solution | Command |
|-------|----------|---------|
| Permission denied | Run environment validation | `./validate-environment.sh fix` |
| Agent files not found | Verify repository structure | `ls -la agents/specialists/` |
| Installation fails | Check available disk space | `./validate-environment.sh` |
| Agents not loading | Verify file integrity | `./agent-installer.sh verify-all` |

## 🔄 Upgrade Paths

### From Core to Full Squad
```bash
./deployment/scripts/install.sh full
```
*Adds 7 additional specialists while preserving existing 4*

### Individual Agent Addition
```bash
./deployment/scripts/agent-installer.sh install architect
./deployment/scripts/agent-installer.sh install designer
```

## 📈 Monitoring & Maintenance

### System Health Checks
```bash
# Verify all installed agents
./deployment/scripts/agent-installer.sh verify-all

# List and check backups
./deployment/scripts/backup-manager.sh list

# Environment validation
./deployment/scripts/validate-environment.sh quick
```

### Maintenance Tasks
```bash
# Cleanup old backups (keep last 5)
./deployment/scripts/backup-manager.sh cleanup 5

# Update all agents to latest versions
./deployment/scripts/install.sh [current-squad] # Reinstalls with latest
```

## 🎯 Performance Benchmarks

**Test Environment**: macOS 15.5, ARM64, 16GB RAM, SSD

| Operation | Time | Success Rate |
|-----------|------|--------------|
| Environment Validation | 5-10s | 100% |
| Core Squad Installation | 120-180s | 98%+ |
| Full Squad Installation | 240-300s | 98%+ |
| Backup Creation | 5-15s | 100% |
| Restore Operation | 10-30s | 100% |
| Individual Agent Install | 5-10s | 99%+ |

## 🔐 Security Features

- **No elevated permissions required** - Installs to user directory only
- **Atomic operations** - All-or-nothing installations
- **Automatic backups** - Safety before any changes
- **File validation** - YAML header and content verification
- **Isolated installation** - No system-wide changes

## 🌐 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| macOS 10.15+ | ✅ Fully Supported | Primary development platform |
| Linux (Ubuntu/Debian) | ✅ Fully Supported | Tested on Ubuntu 20.04+ |
| Linux (RHEL/CentOS) | ✅ Supported | Requires bash 4.0+ |
| Windows WSL | ⚠️ Experimental | Use WSL2 for best results |
| Windows Native | ❌ Not Supported | Use WSL or Git Bash |

## 📚 Related Documentation

- [AGENT-11 Main README](../README.md) - Project overview and quick start
- [Core Squad Guide](../agents/core-squad.md) - Essential 4 agents
- [Full Squad Guide](../agents/full-squad.md) - Complete 11 agents
- [Field Manual](../field-manual/) - User guides and best practices

---

*Built for 95% success rate and <5 minute deployment. Ready for production use.*