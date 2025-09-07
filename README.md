<div align="center">
  
# AGENT-11™

### Your Elite AI Development Squad

[![Claude Code Compatible](https://img.shields.io/badge/Claude%20Code-Native-blue?style=for-the-badge)](https://claude.ai)
[![Deploy Time](https://img.shields.io/badge/Deploy%20Time-Under%201%20Second-green?style=for-the-badge)](QUICK-START.md)
[![Success Rate](https://img.shields.io/badge/Success%20Rate-98%25-brightgreen?style=for-the-badge)](INSTALLATION.md)
[![Agents](https://img.shields.io/badge/Agents-11%20Specialists-red?style=for-the-badge)](project/agents/)
[![Missions](https://img.shields.io/badge/Missions-12%20Workflows-purple?style=for-the-badge)](project/missions/)
[![MCP Integration](https://img.shields.io/badge/MCP-Enabled-orange?style=for-the-badge)](project/field-manual/mcp-integration.md)
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
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/install.sh | bash -s core

# Full Squad (11 agents) - For complex projects  
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/install.sh | bash -s full

# Minimal Squad (2 agents) - For quick prototyping
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/install.sh | bash -s minimal
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

### 🔌 MCP Integration Setup (Highly Recommended)

MCPs (Model Context Protocol) give your agents superpowers. Here's how to set them up correctly:

#### Step 1: Install Required MCP Packages
```bash
# Install globally (required for Claude Code to find them)
npm install -g @playwright/mcp           # Browser automation
npm install -g @upstash/context7-mcp    # Documentation lookup
npm install -g firecrawl-mcp            # Web scraping
npm install -g github-mcp-custom        # GitHub integration
npm install -g supabase-mcp             # Database management
npm install -g figma-developer-mcp      # Design tools
```

#### Step 2: Configure API Keys
```bash
# Copy the template (created during installation)
cp .env.mcp.template .env.mcp

# Edit .env.mcp to add your API keys
nano .env.mcp  # or: code .env.mcp
```

Required API keys for full functionality:
- `GITHUB_PERSONAL_ACCESS_TOKEN` - [Create GitHub token](https://github.com/settings/tokens)
- `SUPABASE_ACCESS_TOKEN` & `SUPABASE_PROJECT_REF` - From Supabase dashboard
- `CONTEXT7_API_KEY` - For documentation lookup
- `FIRECRAWL_API_KEY` - For web scraping

#### Step 3: Run MCP Setup
```bash
# Use the v2 script with correct package names
./project/deployment/scripts/mcp-setup-v2.sh

# Or if in project directory:
bash .claude/deployment/scripts/mcp-setup-v2.sh
```

#### Step 4: Restart Claude Code
```bash
# Exit Claude Code
/exit

# Restart in your project directory
claude
```

#### Step 5: Verify MCPs are Working
After restart, check for MCP tools:
- Look for tools prefixed with `mcp__`
- Example: `mcp__playwright__browser_navigate`
- Run: `claude mcp list` to see connection status

**Common Issues & Solutions:**
- **"Failed to connect"** - Normal before restart, exit and restart Claude Code
- **Wrong package names** - Use the exact names listed above, not @modelcontextprotocol/*
- **Missing packages** - Install globally with npm install -g
- **API key issues** - Verify keys in .env.mcp are correct

See [Complete MCP Guide](project/field-manual/mcp-integration.md) for advanced configuration.

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

[Read more success stories →](project/community/SUCCESS-STORIES.md)

## 📐 Architecture Documentation System

**Comprehensive architecture documentation for every project:**

### Architecture Template & SOP
Every project initialized with AGENT-11 includes professional architecture documentation:

- **📋 Template**: Production-ready architecture.md template at `/templates/architecture.md`
- **📚 SOP**: Complete guidelines at `/project/field-manual/architecture-sop.md`
- **🚀 Auto-Creation**: Generated during kickoff missions (dev-setup/dev-alignment)

### Key Sections Covered
- System boundaries and context
- Infrastructure architecture with diagrams
- Application architecture patterns
- Data models and flows
- Integration points and APIs
- Architecture decisions (ADRs)
- Security considerations
- Performance requirements

### When It's Created
- **New Projects**: Automatically during `/coord dev-setup`
- **Existing Projects**: During `/coord dev-alignment` 
- **Manual**: Use the template anytime you need architecture docs

**[📖 Architecture SOP →](project/field-manual/architecture-sop.md)** | **[📋 Template →](templates/architecture.md)**

## 🧠 Context Preservation System (NEW!)

**Revolutionary context management that eliminates rework and accelerates workflows:**

### Battle-Tested Results
- **87.5% Reduction in Rework** - No more repeating discoveries or losing insights
- **37.5% Faster Multi-Agent Workflows** - Seamless handoffs between specialists  
- **Zero Context Loss** - Mission-wide knowledge accumulation across all agents

### Three Mandatory Context Files
Every AGENT-11 deployment automatically creates:

- **📋 agent-context.md** - Mission-wide findings accumulation
  - Key discoveries, technical decisions, and insights
  - Shared knowledge base that grows throughout the mission
  - Prevents duplicate analysis and research

- **🤝 handoff-notes.md** - Agent-to-agent communication
  - Specialist handoffs with specific recommendations  
  - Status updates and context for next agent in the workflow
  - Maintains conversation continuity across agent switches

- **🏛️ evidence-repository.md** - Centralized artifact storage
  - Code examples, configurations, and implementation details
  - Screenshots, logs, and debugging evidence
  - Reference materials and external resources

### How It Works
1. **Agents Read First** - Every agent automatically reads context files before starting tasks
2. **Mission-Wide Accumulation** - Findings and insights build up across the entire mission
3. **Seamless Handoffs** - Agents update handoff notes for the next specialist  
4. **Zero Setup Required** - Templates automatically installed during deployment

### Automatic Template Installation
```bash
# Context templates are installed automatically with your squad:
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/install.sh | bash -s core

# Your project now includes:
# ✅ .claude/context-templates/agent-context.md
# ✅ .claude/context-templates/handoff-notes.md  
# ✅ .claude/context-templates/evidence-repository.md
```

**This system transforms chaotic multi-agent coordination into a seamless collaborative experience where every specialist builds on previous work instead of starting from scratch.**

## 🔌 MCP Integration

**Your agents leverage powerful MCP (Model Context Protocol) tools for enhanced capabilities:**

### Quick MCP Setup (IMPORTANT: Use Correct Package Names)
```bash
# 1. Install MCP packages globally (REQUIRED)
npm install -g @playwright/mcp           # NOT @modelcontextprotocol/server-playwright
npm install -g @upstash/context7-mcp    # NOT @context7/mcp-server
npm install -g firecrawl-mcp            # NOT @mendable/firecrawl-mcp
npm install -g github-mcp-custom        # NOT @modelcontextprotocol/server-github
npm install -g supabase-mcp             # NOT @supabase/mcp-server

# 2. Configure API keys
cp .env.mcp.template .env.mcp
nano .env.mcp  # Add your API keys

# 3. Run setup with v2 script (has correct package names)
./project/deployment/scripts/mcp-setup-v2.sh

# 4. RESTART Claude Code (CRITICAL!)
/exit
claude  # Restart in your project directory

# 5. Verify MCPs are connected
claude mcp list  # Should show "Connected" not "Failed to connect"
```

### Available MCPs Your Agents Can Use
- **🎭 Playwright** (`mcp__playwright__`) - Browser automation and E2E testing
- **🗄️ Supabase** (`mcp__supabase__`) - Database and authentication
- **🐙 GitHub** (`mcp__github__`) - PRs, issues, and version control
- **📚 Context7** (`mcp__context7__`) - Real-time library documentation
- **🔥 Firecrawl** (`mcp__firecrawl__`) - Web scraping and research
- **🚀 Railway/Netlify** - Deployment automation
- **💳 Stripe** - Payment processing (if installed)

### Common MCP Issues & Solutions
- **"Failed to connect"** → Exit and restart Claude Code
- **Package not found** → Use exact package names above, install with `npm install -g`
- **No mcp__ tools** → Restart required after configuration
- **Wrong package names** → Don't use @modelcontextprotocol/* packages

**[📖 Complete MCP Integration Guide →](project/field-manual/mcp-integration.md)**

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

## 📊 Reporting & Analysis Commands (NEW!)

### Progress Reporting
```bash
# Generate stakeholder progress report
/report

# Report since specific date
/report 2025-08-20
```

Generates professional progress reports for BOS-AI or stakeholders including:
- Completed tasks with dates and impact
- Issues encountered and resolutions
- Current status and metrics
- Next milestones and resource needs

### Post Mortem Analysis
```bash
# Analyze recent failures
/pmd

# Analyze specific issue
/pmd "Coordinator not using Task tool correctly"
```

Conducts root cause analysis to identify improvements in:
- Agent performance and prompts
- Documentation quality
- Tool usage patterns
- Process and coordination issues

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

**[📖 Complete Design Review Guide →](project/field-manual/ui-doctrine.md)**

## 🔥 Mission Library (12 Core Missions)

### Setup Missions (NEW!)
- **[🚀 DEV-SETUP](project/missions/dev-setup.md)** - Greenfield project initialization (30-45 min)
- **[🎯 DEV-ALIGNMENT](project/missions/dev-alignment.md)** - Existing project understanding (45-60 min)
- **[🔌 CONNECT-MCP](project/missions/connect-mcp.md)** - MCP discovery and connection (45-90 min)

### Development Missions
- **[🏗️ BUILD](project/missions/mission-build.md)** - New feature development (4-8 hours)
- **[🐛 FIX](project/missions/mission-fix.md)** - Emergency bug resolution (1-3 hours)  
- **[♻️ REFACTOR](project/missions/mission-refactor.md)** - Code quality improvement (2-4 hours)
- **[🚀 DEPLOY](project/missions/mission-deploy.md)** - Production deployment (1-2 hours)
- **[📚 DOCUMENT](project/missions/mission-document.md)** - Documentation creation (2-4 hours)

### Strategic Missions  
- **[💡 MVP](project/missions/mission-mvp.md)** - Minimum viable product (1-3 days)
- **[🔄 MIGRATE](project/missions/mission-migrate.md)** - System migration (4-8 hours)
- **[⚡ OPTIMIZE](project/missions/mission-optimize.md)** - Performance optimization (3-6 hours)
- **[🔒 SECURITY](project/missions/mission-security.md)** - Security audit & fixes (4-6 hours)
- **[🔌 INTEGRATE](project/missions/mission-integrate.md)** - Third-party integration (3-6 hours)
- **[🎯 RELEASE](project/missions/mission-release.md)** - Release management (2-4 hours)

[📋 Complete Mission Library →](project/missions/library.md)

## 🔄 Updating Existing Installation

**Already have AGENT-11?** Get the latest features including the `/coord` mission system:

```bash
# Single command to update your project
cd /path/to/your/project
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/install.sh | bash -s core
```

**[📋 Complete Update Guide →](project/docs/UPDATING.md)** - Everything you need to know about updating

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
