<div align="center">
  
# AGENT-11™

### Your Elite AI Development Squad

[![Claude Code Compatible](https://img.shields.io/badge/Claude%20Code-Native-blue?style=for-the-badge)](https://claude.ai)
[![Deploy Time](https://img.shields.io/badge/Deploy%20Time-Under%201%20Second-green?style=for-the-badge)](QUICK-START.md)
[![Success Rate](https://img.shields.io/badge/Success%20Rate-98%25-brightgreen?style=for-the-badge)](INSTALLATION.md)
[![Agents](https://img.shields.io/badge/Agents-11%20Specialists-red?style=for-the-badge)](agents/)
[![Missions](https://img.shields.io/badge/Missions-12%20Workflows-purple?style=for-the-badge)](missions/)
[![MCP Integration](https://img.shields.io/badge/MCP-Enabled-orange?style=for-the-badge)](field-manual/mcp-integration.md)
[![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)](LICENSE)

**One Founder. Eleven Specialists. Unlimited Potential.**

[🚀 One-Line Deploy](#-project-only-deployment) · [📖 Quick Start](QUICK-START.md) · [📚 Full Docs](project/docs/DOCUMENTATION-INDEX.md) · [🛠️ Advanced Usage](project/docs/ADVANCED-USAGE.md)

</div>

---

## 🎯 Mission Briefing

You're a solo founder with a vision. You need to build fast, ship quality, and compete with funded teams. **AGENT-11** deploys your elite squad to work on a specific project - each project gets its own specialized team that understands your project context perfectly.

### Your Squad Includes:
- 🎯 **The Strategist** - Product vision and roadmaps
- 🏗️ **The Architect** - Bulletproof technical decisions  
- 💻 **The Developer** - Ship code at light speed
- ✅ **The Tester** - Zero bugs reach production (NEW: SENTINEL Mode)
- 🎨 **The Designer** - Interfaces that convert (NEW: RECON Protocol + Design Review)
- 📚 **The Documenter** - Knowledge captured perfectly
- 🚀 **The Operator** - Deploy with confidence
- 💬 **The Support** - Users become advocates
- 📊 **The Analyst** - Data drives decisions
- 📈 **The Marketer** - Growth on autopilot
- 🎖️ **The Coordinator** - Mission commander (NEW: PARALLEL STRIKE)

## 📋 Prerequisites

**AGENT-11 requires a project context to deploy.** Your directory needs at least ONE of:

- 🔧 **Git repository** (recommended): `git init`
- 📄 **README file**: `README.md`
- 📦 **Package file**: `package.json`, `requirements.txt`, `Cargo.toml`, etc.
- 🗂️ **Any project indicator**: `.gitignore`, source files, or documentation

### Quick Project Setup

```bash
# For new projects - create and initialize:
mkdir my-project && cd my-project
git init
echo "# My Project" > README.md

# For existing folders - just initialize:
cd /path/to/existing/folder
git init  # This is usually all you need!

# For greenfield projects with ideation docs:
cd /path/to/project-with-ideation
git init && echo "# Project Name" > README.md
```

## 🚀 Project-Only Deployment

**Project-Local Agents · No Global Pollution · Clean Isolation**

```bash
# Step 1: Navigate to your project (required)
cd /path/to/your/project

# Step 2: Ensure project context exists (if not already)
git init  # Quick fix if deployment fails with "no project detected"

# Step 3: Deploy your squad
# Core Squad (4 agents) - Recommended for most projects
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/deployment/scripts/install.sh | bash -s core

# Full Squad (11 agents) - For complex projects  
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/deployment/scripts/install.sh | bash -s full

# Minimal Squad (2 agents) - For quick prototyping
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/deployment/scripts/install.sh | bash -s minimal
```

**Project-focused by design!** The installer:
- ✅ Detects your project type and context
- ✅ Creates project-local `.claude/agents/` directory
- ✅ Installs your selected squad with project understanding
- ❌ Fails gracefully if no project context found (with helpful guidance)
- ✅ Shows you exactly what to do next

**[📖 See Complete Project Setup Guide →](QUICK-START.md)**

## ✅ Verify Your Project Deployment

```bash
# Restart Claude Code in your project directory
/exit && claude

# List your project-local agents
/agents

# Test your first specialist (knows your project context)
@strategist What should we build first in this project?
```

---

## 🚀 Your First Mission

### Option 1: Manual Coordination
```bash
# 1. Define requirements
@strategist Create user stories for a user authentication feature

# 2. Build it
@developer Implement authentication based on the requirements above

# 3. Test it
@tester Validate the authentication implementation

# 4. Ship it
@operator Deploy to production when tests pass
```

### Option 2: Command System (NEW!) 🎖️
```bash
# Execute predefined missions with a single command
/coord build requirements.md

# Or start interactively
/coord

# Have strategic conversations with specialists
/meeting @strategist "product roadmap planning"
/meeting @architect "system scalability concerns"

# NEW: Design Review System
/design-review    # Comprehensive UI/UX audit of current changes
/recon           # UI/UX reconnaissance assessment
@design-review   # Dedicated design review specialist
```

The `/coord` command activates THE COORDINATOR to orchestrate complex multi-agent missions automatically. The `/meeting` command enables natural conversations with specialists for brainstorming and strategic planning. The **NEW Design Review System** provides world-class UI/UX audits using the RECON Protocol with Playwright automation. Choose from predefined missions like BUILD, FIX, MVP, or create your own.

## 📊 Mission Success Metrics

<div align="center">

| Metric | Traditional | With AGENT-11 |
|--------|-------------|---------------|
| Time to MVP | 3-6 months | 2-4 weeks |
| Team Size | 5-10 people | 1 founder |
| Cost per Feature | $10-50k | <$500 |
| Project Setup | Hours | Under 5 minutes |
| Team Context | Manual briefings | Automatic project understanding |

</div>

## 🎖️ Battle-Tested Results

> "Each project gets its own elite team that understands the codebase perfectly. Game changer."  
> — *Alex Chen, Solo Founder ($15k MRR)*

> "Project-local agents mean no confusion, no context switching. They just get it."  
> — *Sarah Martinez, Technical Founder*

> "Clean deployments, isolated teams per project. Finally, AI that scales with my workflow."  
> — *David Kim, Multi-Project Founder*

[Read more success stories →](community/SUCCESS-STORIES.md)

## 🔌 MCP Integration (NEW!)

**Your agents now leverage powerful MCP (Model Context Protocol) tools for maximum efficiency:**

### Automatic MCP Discovery & Setup
```bash
# After deploying your squad, connect required MCPs
/coord connect-mcp

# The mission will:
# 1. Analyze your project requirements
# 2. Identify needed MCPs (Supabase, GitHub, Playwright, etc.)
# 3. Install and configure them automatically
# 4. Test all connections
# 5. Map MCPs to your agents
```

### Available MCPs Your Agents Can Use
- **🗄️ Supabase** - Database operations and authentication
- **🐙 GitHub** - PRs, issues, and version control
- **🎭 Playwright** - Browser automation, E2E testing, and design reviews
- **📚 Context7** - Real-time library documentation
- **🔥 Firecrawl** - Web scraping and research
- **🚀 Netlify/Railway** - Deployment automation
- **💳 Stripe** - Payment processing

**[📖 Complete MCP Integration Guide →](field-manual/mcp-integration.md)**

## 🎨 Design Review System (NEW!)

**World-class UI/UX audits integrated into your development workflow**

Based on OneRedOak's proven design review workflows used by top-tier companies like Stripe, Airbnb, and Linear.

### Quick Design Review
```bash
# Audit current branch changes instantly
/design-review

# Get detailed UI/UX reconnaissance  
/recon

# Deploy dedicated design review specialist
@design-review "Review the login form changes"
```

### 7-Phase Systematic Protocol
1. **🔧 Preparation** - Environment setup and change analysis
2. **⚡ Interaction Testing** - User flows and micro-interactions
3. **📱 Responsive Validation** - Cross-device compatibility  
4. **✨ Visual Polish** - Typography, spacing, and hierarchy
5. **♿ Accessibility Audit** - WCAG AA+ compliance testing
6. **🛡️ Robustness Testing** - Edge cases and error states
7. **🚀 Performance Check** - Load times and console errors

### Key Features
- **Live Environment Testing** - Playwright automation for real interactions
- **Evidence-Based Reports** - Screenshots and reproduction steps included
- **Triage Matrix** - Issues classified as [BLOCKER], [HIGH], [MEDIUM], [NITPICK]
- **Problems Over Prescriptions** - Describes issues, not solutions
- **Project-Aware** - Uses your design system and brand guidelines

**[📖 Complete Design Review Guide →](field-manual/ui-doctrine.md)**

## 🔥 Mission Library (12 Core Missions)

### Setup Missions (NEW!)
- **[🚀 DEV-SETUP](missions/dev-setup.md)** - Greenfield project initialization (30-45 min)
- **[🎯 DEV-ALIGNMENT](missions/dev-alignment.md)** - Existing project understanding (45-60 min)
- **[🔌 CONNECT-MCP](missions/connect-mcp.md)** - MCP discovery and connection (45-90 min)

### Development Missions
- **[🏗️ BUILD](missions/mission-build.md)** - New feature development (4-8 hours)
- **[🐛 FIX](missions/mission-fix.md)** - Emergency bug resolution (1-3 hours)  
- **[♻️ REFACTOR](missions/mission-refactor.md)** - Code quality improvement (2-4 hours)
- **[🚀 DEPLOY](missions/mission-deploy.md)** - Production deployment (1-2 hours)
- **[📚 DOCUMENT](missions/mission-document.md)** - Documentation creation (2-4 hours)

### Strategic Missions  
- **[💡 MVP](missions/mission-mvp.md)** - Minimum viable product (1-3 days)
- **[🔄 MIGRATE](missions/mission-migrate.md)** - System migration (4-8 hours)
- **[⚡ OPTIMIZE](missions/mission-optimize.md)** - Performance optimization (3-6 hours)
- **[🔒 SECURITY](missions/mission-security.md)** - Security audit & fixes (4-6 hours)
- **[🔌 INTEGRATE](missions/mission-integrate.md)** - Third-party integration (3-6 hours)
- **[🎯 RELEASE](missions/mission-release.md)** - Release management (2-4 hours)

[📋 Complete Mission Library →](missions/library.md)

## 🔄 Updating Existing Installation

**Already have AGENT-11?** Get the latest features including the `/coord` mission system:

```bash
# Single command to update your project
cd /path/to/your/project
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/deployment/scripts/install.sh | bash -s core
```

**[📋 Complete Update Guide →](UPDATING.md)** - Everything you need to know about updating

## 🛠️ Troubleshooting

### Common Installation Issues

**"No project detected in current directory"**
```bash
# Quick fix - just initialize git:
git init

# Or create a README:
echo "# My Project" > README.md
```

**"Cannot write to current directory"**
```bash
# Check permissions:
ls -la .
# Fix with: sudo chown -R $(whoami) .
```

**"Neither curl nor wget available"**
```bash
# macOS: brew install curl
# Ubuntu/Debian: sudo apt-get install curl
# RHEL/CentOS: sudo yum install curl
```

**Installation for greenfield projects with ideation docs:**
```bash
cd /path/to/project-with-ideation
git init  # Required!
echo "# Project Name" > README.md  # Optional but recommended
# Now run the installer
```

## 📖 Documentation

### Quick References
- **[🚀 5-Minute Project Setup](QUICK-START.md)** - Zero to deployed in under 5 minutes  
- **[🔄 Update Existing Installation](project/docs/UPDATING.md)** - Get latest features in your current project
- **[⚙️ Project Installation Guide](INSTALLATION.md)** - Complete project setup with troubleshooting
- **[📋 User Guide](project/docs/USER-GUIDE.md)** - Master project-based multi-agent workflows
- **[🛠️ Troubleshooting](project/docs/TROUBLESHOOTING.md)** - Fix project setup issues fast

### Advanced Usage
- **[🔧 Advanced Usage](project/docs/ADVANCED-USAGE.md)** - Custom configurations and enterprise setup
- **[🏗️ Agent Architecture](project/agents/)** - Individual agent capabilities and squad compositions
- **[🎯 Mission Workflows](project/missions/)** - Pre-built workflows for common scenarios

### Getting Help
- **Built-in Support**: `@support` - Deploy the support agent for immediate help
- **Community**: [Success Stories](project/community/SUCCESS-STORIES.md) and user experiences
- **Issues**: [GitHub Issues](https://github.com/TheWayWithin/agent-11/issues) for bugs and feature requests

## 🤝 Join the Elite

AGENT-11 is open source and community-driven. We welcome contributions from fellow operators.

- 🐛 [Report Issues](https://github.com/TheWayWithin/agent-11/issues)
- 💡 [Request Features](https://github.com/TheWayWithin/agent-11/issues/new?template=feature_request.md)
- 🔧 [Contribute Code](project/docs/CONTRIBUTING.md)
- 💬 [Join Discord](https://discord.gg/agent11)

## 📜 License

MIT - Use AGENT-11 to build your empire.

---

<div align="center">

**Ready to deploy your project squad?**

[🚀 Project Setup](#-project-only-deployment) · [📖 Quick Start](QUICK-START.md) · [📚 Full Documentation](project/docs/DOCUMENTATION-INDEX.md)

*"One project. One founder. Eleven specialists. Unlimited potential."*

</div>
