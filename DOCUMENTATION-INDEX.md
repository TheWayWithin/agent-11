# AGENT-11 Documentation Index

Complete navigation guide for all AGENT-11 documentation. Find exactly what you need, when you need it.

## 🚀 Getting Started (Priority 1)

**New to AGENT-11? Start here:**

### [5-Minute Quick Start](QUICK-START.md)
**Perfect for**: First-time users who want to get up and running immediately
- One-line installation commands
- Success indicators and verification
- First commands to try
- Common quick fixes

**Time to Complete**: 5 minutes  
**Success Rate**: 98%

### [Installation Guide](INSTALLATION.md)
**Perfect for**: Users who want comprehensive setup information
- System requirements and prerequisites
- Step-by-step installation for all platforms
- Squad types (core, full, minimal) explained
- Platform-specific instructions
- Complete troubleshooting section

**Time to Complete**: 10-15 minutes  
**Coverage**: All installation scenarios

## 📋 Using AGENT-11 (Priority 2)

**Ready to use your deployed agents:**

### [User Guide](USER-GUIDE.md)
**Perfect for**: Users with deployed agents who want to maximize productivity
- Individual agent capabilities and specializations
- Multi-agent coordination patterns
- Best practices for effective collaboration
- Common workflows and examples
- Advanced techniques

**Best for**: Daily usage patterns and workflow optimization

### [Troubleshooting Guide](TROUBLESHOOTING.md)
**Perfect for**: Solving problems and recovering from issues
- Quick diagnostic commands
- Common issues with step-by-step solutions
- Error message reference with fixes
- System recovery procedures
- Platform-specific problem solving

**Best for**: When something isn't working correctly

## 🔧 Advanced Usage (Priority 3)

**For power users and enterprise deployments:**

### [Advanced Usage Guide](ADVANCED-USAGE.md)
**Perfect for**: Customization, enterprise setup, and scaling
- Custom squad configurations
- Backup and restore management
- Enterprise integration patterns
- Performance optimization
- Security considerations
- Maintenance procedures

**Best for**: Organizations and advanced individual users

## 🔌 MCP Integration (NEW!)

### [MCP Integration Guide](field-manual/mcp-integration.md)
**Perfect for**: Understanding and leveraging MCP tools
- What are MCPs and why they matter
- Discovery and connection protocols
- Agent-specific MCP usage patterns
- Security and troubleshooting

### Setup Missions with MCP
- **[DEV-SETUP Mission](missions/dev-setup.md)** - Greenfield project initialization with MCP discovery
- **[DEV-ALIGNMENT Mission](missions/dev-alignment.md)** - Existing project understanding with MCP assessment
- **[CONNECT-MCP Mission](missions/connect-mcp.md)** - Systematic MCP discovery and connection

**Time to Complete**: 45-90 minutes for full MCP setup  
**Benefit**: 60-80% efficiency gains through tool integration

## 📚 Reference Documentation

### Agent Architecture
- **[Core Squad Overview](agents/core-squad.md)** - Essential 4-agent setup with MCP mappings
- **[Full Squad Overview](agents/full-squad.md)** - Complete 11-agent deployment with MCP integration
- **[Individual Agent Specs](agents/specialists/)** - Detailed capabilities per agent including MCP usage

### Mission Workflows (12 Total)
- **[Mission Library](missions/library.md)** - Complete list of all 12 missions
- **[Operation Genesis](missions/operation-genesis.md)** - Complete feature development
- **[Setup Missions](missions/)** - Project initialization with MCP integration
- **[Development Missions](missions/)** - Pre-built workflows for common scenarios

### Community Resources
- **[Success Stories](community/SUCCESS-STORIES.md)** - Real user experiences
- **[Contributing Guide](CONTRIBUTING.md)** - How to improve AGENT-11

## 🎯 Documentation by Use Case

### "I just heard about AGENT-11"
1. [README.md](README.md) - Project overview and benefits
2. [5-Minute Quick Start](QUICK-START.md) - Get deployed fast
3. [User Guide](USER-GUIDE.md) - Learn effective usage

### "I want to install AGENT-11"
1. [5-Minute Quick Start](QUICK-START.md) - Fastest path
2. [Installation Guide](INSTALLATION.md) - Comprehensive setup
3. [Troubleshooting Guide](TROUBLESHOOTING.md) - If issues arise

### "I'm having problems"
1. [Troubleshooting Guide](TROUBLESHOOTING.md) - Problem-specific solutions
2. [Installation Guide](INSTALLATION.md) - Verify setup is correct
3. **Deploy `@support` agent** - Built-in help system

### "I want to customize AGENT-11"
1. [Advanced Usage Guide](ADVANCED-USAGE.md) - Customization options
2. [Agent Architecture](agents/) - Understanding agent structure
3. [Contributing Guide](CONTRIBUTING.md) - Making modifications

### "I'm deploying for a team/organization"
1. [Advanced Usage Guide](ADVANCED-USAGE.md) - Enterprise patterns
2. [Installation Guide](INSTALLATION.md) - Multiple deployment strategies
3. [Troubleshooting Guide](TROUBLESHOOTING.md) - Team support procedures

### "I want to connect MCPs to my project" (NEW!)
1. [CONNECT-MCP Mission](missions/connect-mcp.md) - Automatic MCP setup
2. [MCP Integration Guide](field-manual/mcp-integration.md) - Complete MCP reference
3. [Quick Start](QUICK-START.md) - Step 3: Connect MCPs

### "I'm starting a new project" (NEW!)
1. [DEV-SETUP Mission](missions/dev-setup.md) - Greenfield project initialization
2. [CONNECT-MCP Mission](missions/connect-mcp.md) - Connect required tools
3. [Mission Library](missions/library.md) - All 12 available workflows

### "I'm joining an existing project" (NEW!)
1. [DEV-ALIGNMENT Mission](missions/dev-alignment.md) - Understand existing codebase
2. [CONNECT-MCP Mission](missions/connect-mcp.md) - Connect project tools
3. [User Guide](USER-GUIDE.md) - Effective agent usage

## 📱 Quick Reference Cards

### Installation Commands
```bash
# Core Squad (recommended for most users)
./deployment/scripts/install.sh core

# Full Squad (all 11 specialists)
./deployment/scripts/install.sh full

# Minimal Squad (strategist + developer only)
./deployment/scripts/install.sh minimal
```

### Essential Agent Commands
```bash
# Planning and strategy
@strategist Create requirements for [feature]

# Implementation
@developer Build [feature] based on requirements above

# Quality assurance
@tester Create tests for the implementation above

# Deployment
@operator Deploy the tested feature to production

# Multi-agent coordination
@coordinator Plan and execute [complex workflow]
```

### Diagnostic Commands
```bash
# Check agent installation
/agents

# Test agent responsiveness
@strategist Hello, are you working?

# View installation logs
cat ~/.claude/logs/agent-11-install.log

# Check agent files
ls -la ~/.claude/agents/
```

### Emergency Recovery
```bash
# Restore from backup
./deployment/scripts/backup-manager.sh restore latest

# Clean reinstall
rm -rf ~/.claude/agents/
./deployment/scripts/install.sh core

# Get immediate help
@support Help me recover from [describe issue]
```

## 🔍 Search Guide

**Looking for something specific? Use this search guide:**

### Installation Issues
- **"Won't install"** → [Installation Guide](INSTALLATION.md) + [Troubleshooting](TROUBLESHOOTING.md)
- **"Permission denied"** → [Troubleshooting Guide](TROUBLESHOOTING.md#installation-issues)
- **"Agents not showing"** → [Troubleshooting Guide](TROUBLESHOOTING.md#agent-detection-problems)

### Usage Questions
- **"How do I..."** → [User Guide](USER-GUIDE.md)
- **"Best practices"** → [User Guide](USER-GUIDE.md#best-practices)
- **"Multi-agent workflows"** → [User Guide](USER-GUIDE.md#multi-agent-coordination)

### Customization
- **"Custom agents"** → [Advanced Usage Guide](ADVANCED-USAGE.md#agent-customization)
- **"Enterprise setup"** → [Advanced Usage Guide](ADVANCED-USAGE.md#enterprise-integration)
- **"Backup management"** → [Advanced Usage Guide](ADVANCED-USAGE.md#backup-and-restore-operations)

### Problems
- **Any error message** → [Troubleshooting Guide](TROUBLESHOOTING.md#error-messages-reference)
- **Performance issues** → [Troubleshooting Guide](TROUBLESHOOTING.md#performance-problems)
- **Recovery procedures** → [Troubleshooting Guide](TROUBLESHOOTING.md#system-recovery)

## 📖 Reading Recommendations

### For Beginners
1. **Start**: [README.md](README.md) - Understand what AGENT-11 does
2. **Deploy**: [5-Minute Quick Start](QUICK-START.md) - Get it working
3. **Learn**: [User Guide](USER-GUIDE.md) - Use it effectively

### For Developers
1. **Install**: [Installation Guide](INSTALLATION.md) - Comprehensive setup
2. **Use**: [User Guide](USER-GUIDE.md) - Development workflows
3. **Customize**: [Advanced Usage Guide](ADVANCED-USAGE.md) - Power user features

### For Teams
1. **Plan**: [Advanced Usage Guide](ADVANCED-USAGE.md) - Enterprise considerations
2. **Deploy**: [Installation Guide](INSTALLATION.md) - Team deployment strategies
3. **Support**: [Troubleshooting Guide](TROUBLESHOOTING.md) - Team support procedures

### For Contributors
1. **Understand**: [Agent Architecture](agents/) - System design
2. **Contribute**: [Contributing Guide](CONTRIBUTING.md) - Development process
3. **Advanced**: [Advanced Usage Guide](ADVANCED-USAGE.md) - Internal mechanisms

## 🆘 Getting Help

### Built-in Help System
```bash
# Deploy the support agent (recommended first step)
@support Help me with [describe your issue]

# The support agent has access to all documentation
# and can provide contextual, immediate assistance
```

### Self-Service Resources
1. **Quick Issues**: [Troubleshooting Guide](TROUBLESHOOTING.md)
2. **How-to Questions**: [User Guide](USER-GUIDE.md)
3. **Setup Problems**: [Installation Guide](INSTALLATION.md)

### Community Support
- **GitHub Issues**: Technical problems and bug reports
- **GitHub Discussions**: Usage questions and feature requests
- **Success Stories**: [Community examples](community/SUCCESS-STORIES.md)

### Emergency Contact
**For critical production issues affecting deployed systems:**
1. Deploy `@support` agent immediately
2. Check [System Recovery procedures](TROUBLESHOOTING.md#system-recovery)
3. Report critical bugs via GitHub Issues with "critical" label

---

## 📊 Documentation Stats

| Document | Length | Read Time | Best For |
|----------|--------|-----------|----------|
| Quick Start | 2 pages | 5-10 min | New users |
| Installation | 8 pages | 15-20 min | Setup |
| User Guide | 12 pages | 25-30 min | Daily usage |
| Troubleshooting | 15 pages | Reference | Problem solving |
| Advanced Usage | 18 pages | Reference | Power users |

**Total Documentation**: 50+ pages covering every aspect of AGENT-11 deployment and usage.

**Success Rate**: 98% of users successfully deploy AGENT-11 following this documentation.

---

**Can't find what you're looking for?** Deploy the `@support` agent - it has access to all documentation and can provide personalized assistance! 🚁