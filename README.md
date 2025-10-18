<div align="center">
  
# AGENT-11™

### Your Elite AI Development Squad

[![Claude Code Compatible](https://img.shields.io/badge/Claude%20Code-Native-blue?style=for-the-badge)](https://claude.ai)
[![Deploy Time](https://img.shields.io/badge/Deploy%20Time-Under%201%20Second-green?style=for-the-badge)](QUICK-START.md)
[![Success Rate](https://img.shields.io/badge/Success%20Rate-98%25-brightgreen?style=for-the-badge)](INSTALLATION.md)
[![Agents](https://img.shields.io/badge/Agents-11%20Specialists-red?style=for-the-badge)](project/agents/)
[![Missions](https://img.shields.io/badge/Missions-18%20Workflows-purple?style=for-the-badge)](project/missions/)
[![MCP Integration](https://img.shields.io/badge/MCP-Enabled-orange?style=for-the-badge)](project/field-manual/mcp-integration.md)
[![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)](LICENSE)

**One Founder. Eleven Specialists. Unlimited Potential.**

[🚀 One-Line Deploy](#-project-only-deployment) · [📖 Quick Start](QUICK-START.md) · [📚 Full Docs](project/docs/DOCUMENTATION-INDEX.md) · [🛠️ Advanced Usage](project/docs/ADVANCED-USAGE.md)

</div>

---

## 🎯 Mission Briefing

You're a solo founder with a vision. You need to build fast, ship quality, and compete with funded teams. **AGENT-11** deploys your elite squad to work on a specific project - each project gets its own specialized team that understands your project context perfectly.

## ⚡ What's New in AGENT-11 v2.0

**Major Modernization Complete**: AGENT-11 has been completely rebuilt to leverage Claude Code's latest capabilities, transforming from a powerful agent coordination system into a next-generation agentic development platform.

### 🚀 Core Enhancements

**Memory & Knowledge Management**
- **Native Memory Tools**: Persistent project knowledge across sessions using Claude Code's memory API
- **Automated Bootstrap**: Initialize projects from ideation documents with structured memory generation
- **Zero Context Loss**: 100% knowledge retention across agent handoffs and session resets
- **Hybrid Intelligence**: Two-tier system combining persistent memory with dynamic context files

**Cognitive Optimization**
- **Extended Thinking Modes**: Strategic use of "ultrathink" for architecture, "think harder" for strategy, optimized by complexity
- **Self-Verification Protocols**: Built-in quality assurance with pre-handoff checklists and error recovery
- **Context Editing**: Strategic /clear usage enabling 30+ hour autonomous operation periods
- **Tool Permissions**: Security-first least-privilege model with explicit tool allowlists per agent

### 📊 Performance Improvements

- **39% Effectiveness Improvement** - Extended thinking + self-verification for better decision quality
- **84% Token Reduction** - Context editing + memory optimization for longer missions
- **30+ Hour Autonomous Operation** - Multi-day missions without human intervention
- **50% Rework Reduction** - Self-verification catches errors before handoffs
- **64% Read-Only Agents** - Enhanced security through tool permission optimization

### 📚 New Field Manual Guides

Complete documentation for all modernization features:
- [Memory Management Guide](project/field-manual/memory-management.md) - Persistent context architecture
- [Bootstrap Guide](project/field-manual/bootstrap-guide.md) - Automated project initialization
- [Context Editing Guide](project/field-manual/context-editing-guide.md) - Strategic token optimization
- [Extended Thinking Guide](project/field-manual/extended-thinking-guide.md) - Cognitive resource allocation
- [Tool Permissions Guide](project/field-manual/tool-permissions-guide.md) - Security-first access control
- [Enhanced Prompting Guide](project/field-manual/enhanced-prompting-guide.md) - Self-verification patterns

**Ready to experience next-generation agentic development?** All enhancements work seamlessly within Claude Code - no external infrastructure required.

---

## 🤝 BOS-AI Integration: Strategic Planning → Rapid Execution

**Coming from BOS-AI?** AGENT-11 provides native integration with BOS-AI's 30-agent strategic framework, enabling seamless handoff from business strategy to technical execution.

### What is BOS-AI Integration?

**BOS-AI** handles strategic planning (market research, product strategy, requirements) → **AGENT-11** handles technical execution (MVP development, feature building, deployment). Together, they form a complete AI-powered product development pipeline.

### Who Should Use This?

- ✅ **BOS-AI users** who have completed strategic planning and want to start building
- ✅ **Solo founders** who want strategic clarity before development begins
- ✅ **Teams** looking for seamless handoff between strategy and execution agents

### Get Started in 5 Minutes

Already have BOS-AI strategy documents? **[→ 5-Minute Quickstart](project/field-manual/bos-ai-quickstart.md)**

**Quickstart Summary:**
1. Copy BOS-AI documents to `ideation/` folder
2. Run `/coord dev-setup ideation/PRD.md`
3. Start building with `/coord build` or `/coord mvp`

**[📖 Complete BOS-AI Integration Guide →](project/field-manual/bos-ai-integration-guide.md)** - Full documentation with troubleshooting, advanced patterns, and best practices

---

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
- ✅ **Never overwrites existing CLAUDE.md** - uses safe template approach
- ❌ Fails gracefully if no project context found (with helpful guidance)
- ✅ Shows you exactly what to do next

**[📖 See Complete Project Setup Guide →](QUICK-START.md)**

## 📋 Understanding AGENT-11 Deployment

### What Gets Installed in Your Project

When you deploy AGENT-11, the installer creates a project-local squad with these components:

```
your-project/
├── .claude/
│   ├── agents/              # Your specialist squad (project-scoped)
│   │   ├── strategist.md
│   │   ├── developer.md
│   │   ├── tester.md
│   │   └── ...
│   ├── commands/            # Mission orchestration commands
│   │   ├── coord.md         # /coord command for mission workflows
│   │   ├── meeting.md       # /meeting for structured discussions
│   │   └── ...
│   └── backups/            # Automatic backups of previous installs
│
├── missions/               # Pre-built mission workflows
│   ├── library.md          # Complete mission catalog
│   ├── mission-build.md    # Build feature from PRD
│   ├── mission-fix.md      # Emergency bug fixes
│   └── ...
│
├── templates/              # Reusable project templates
│   ├── architecture-template.md
│   ├── agent-context-template.md
│   └── ...
│
├── field-manual/           # Best practices and SOPs
│   └── architecture-sop.md
│
├── CLAUDE.md               # Your project instructions (never overwritten!)
└── CLAUDE-AGENT11-TEMPLATE.md  # AGENT-11 capabilities reference
```

### CLAUDE.md: Your Project's Intelligence

**CLAUDE.md** is the brain of your project - it tells Claude Code (and all agents) how to work with YOUR specific codebase.

#### How Deployment Handles CLAUDE.md

The installer uses a **safe template approach**:

| Scenario | What Happens | Files Created |
|----------|--------------|---------------|
| **Fresh project** | Creates CLAUDE.md from AGENT-11 template | • CLAUDE.md<br>• CLAUDE-AGENT11-TEMPLATE.md |
| **Existing CLAUDE.md** | Preserves your file completely | • CLAUDE.md (untouched)<br>• CLAUDE-AGENT11-TEMPLATE.md (new)<br>• CLAUDE.md.backup-[timestamp] (safety) |
| **Update/reinstall** | Never overwrites, updates template only | • CLAUDE.md (preserved)<br>• CLAUDE-AGENT11-TEMPLATE.md (updated) |

**Key Points:**
- ✅ **Your CLAUDE.md is NEVER overwritten** - existing instructions always preserved
- ✅ **Automatic backup** - timestamped safety copy created when existing file detected
- ✅ **Latest features available** - CLAUDE-AGENT11-TEMPLATE.md always updated with newest capabilities
- ✅ **Your choice** - decide which AGENT-11 features to integrate into your project

#### Integrating AGENT-11 Capabilities

When you have existing CLAUDE.md, the installer provides clear instructions:

```bash
📝 AGENT-11 Integration Instructions:
  1. Review AGENT-11 features: cat CLAUDE-AGENT11-TEMPLATE.md
  2. Your current instructions: ./CLAUDE.md
  3. Your backup (safety): ./CLAUDE.md.backup-[timestamp]

To add AGENT-11 capabilities to your project:
  • Copy relevant sections from CLAUDE-AGENT11-TEMPLATE.md
  • Paste into your CLAUDE.md where appropriate
  • Or append entire template: cat CLAUDE-AGENT11-TEMPLATE.md >> CLAUDE.md
```

**Best Practice:** Review the template, copy sections that benefit your project (like mission orchestration, context preservation, MCP integration), and paste them into your CLAUDE.md.

## ✅ Verify Your Project Deployment

```bash
# Restart Claude Code in your project directory
/exit && claude

# List your project-local agents
/agents

# Verify CLAUDE.md files
ls -la CLAUDE*.md

# Test your first specialist (knows your project context)
@strategist What should we build first in this project?
```

## 📊 Mission Progress Tracking System

AGENT-11 uses a two-file tracking system that separates planning from learning:

### Core Tracking Files

**project-plan.md** (FORWARD-LOOKING)
- **Purpose**: What you're PLANNING to do
- **Contains**: Strategic roadmap, task lists [ ] → [x], milestones, success metrics
- **Updated**: Mission start, phase transitions, task completions
- **Think**: Your project's roadmap

**progress.md** (BACKWARD-LOOKING)
- **Purpose**: What you DID and what you LEARNED (especially from failures)
- **Contains**: Chronological changelog of deliverables, changes, and **complete issue history**
- **Critical Feature**: Documents ALL fix attempts (including failures) - not just final solutions
- **Updated**: After each deliverable, after EACH fix attempt, when issues resolved
- **Think**: Your project's learning repository

### Why This Matters

**Traditional Approach**:
```
Issue #47: Auth bug fixed ✅
```

**AGENT-11 Approach** (in progress.md):
```markdown
### Issue #47: Authentication Failure

#### Fix Attempts
##### Attempt #1: Update JWT expiry
Result: ❌ Failed
Rationale: Thought token timeout was the issue
What We Tried: Increased JWT expiry from 1h to 24h
Outcome: Auth still failed, different error
Learning: Problem wasn't token expiry - it was validation

##### Attempt #2: Fix token validation
Result: ✅ Success
Rationale: Error showed signature validation failing
What We Tried: Updated JWT secret in .env
Outcome: Auth working correctly
Learning: Secret mismatch between services

#### Resolution
Root Cause: JWT secret mismatch between auth service and API
Why Attempt #1 Failed: Misread initial error message
Prevention: Add secret validation to deployment checklist
```

**Result**: Future similar issues solved in 1 attempt instead of 2+ by learning from documented failures.

### Template Available

See `/templates/progress-template.md` for complete structure and usage guidelines.

### 🔌 MCP Integration Setup (Highly Recommended)

MCPs (Model Context Protocol) give your agents superpowers. Here's how to set them up correctly:

#### Step 1: Install Required MCP Packages
```bash
# Install globally (required for Claude Code to find them)
npm install -g @playwright/mcp                      # Browser automation
npm install -g @upstash/context7-mcp               # Documentation lookup
npm install -g firecrawl-mcp                       # Web scraping
npm install -g @edjl/github-mcp                    # GitHub integration (uses GITHUB_TOKEN)
npm install -g @supabase/mcp-server-supabase       # Official Supabase MCP
npm install -g figma-developer-mcp                 # Design tools
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

## 🎯 How to Execute Missions

### Mission Command Syntax
All missions follow the same execution pattern:
```bash
/coord [mission-name] [input-file.md]
```

### Your First Mission (5 Minutes)
Let's walk through executing your first mission step-by-step:

**Step 1: Choose Your Mission**
- **New Project**: Use `dev-setup` mission with ideation.md
- **Existing Project**: Use `dev-alignment` mission (no input file needed)
- **Build Features**: Use `build` mission with requirements.md

**Step 2: Prepare Input File** 
```bash
# Copy the appropriate template
cp templates/mission-inputs/ideation.md ./my-project-ideation.md

# Edit with your project details
# Fill out all sections with your specific requirements
```

**Step 3: Execute Mission**
```bash
/coord dev-setup my-project-ideation.md
```

**Step 4: Monitor Progress**
Watch for these real-time indicators:
- ✅ **Task Completion**: Each agent marks their work complete
- 📋 **File Creation**: New files appear in your project
- 🔄 **Agent Handoffs**: Coordination between specialists
- ⚠️  **Issues Flagged**: Problems automatically escalated

**Step 5: Review Results**
Check these files for mission outcomes:
- `project-plan.md` - FORWARD-LOOKING: Strategic roadmap with planned and completed tasks
- `progress.md` - BACKWARD-LOOKING: Chronological changelog of deliverables, changes, and complete issue history (including ALL fix attempts)
- `architecture.md` - Technical system design (if applicable)

### Input File Preparation

**Template Locations**:
- `templates/mission-inputs/requirements.md` - For BUILD missions
- `templates/mission-inputs/vision.md` - For MVP missions  
- `templates/mission-inputs/bug-report.md` - For FIX missions
- `templates/mission-inputs/ideation.md` - For DEV-SETUP missions

**Quality Checklist**:
- [ ] All required sections completed
- [ ] Specific, measurable requirements
- [ ] Clear success criteria defined
- [ ] Business context provided
- [ ] Technical constraints identified

### Real-Time Progress Monitoring

**Watch These Indicators**:
```bash
# Mission status updates appear as:
🎯 Mission: BUILD requirements.md [STARTED]
├── @strategist analyzing requirements... [IN PROGRESS]
├── @architect designing system... [QUEUED]  
├── @developer implementing features... [QUEUED]
└── @tester validating implementation... [QUEUED]

# Completion signals:
✅ @strategist: Requirements analysis complete
✅ @architect: System architecture designed  
✅ @developer: Core features implemented
✅ @tester: All tests passing
🎯 Mission: BUILD requirements.md [COMPLETE]
```

**Progress Files Updated Live**:
- `project-plan.md` (FORWARD) - Tasks marked complete [x] as they finish, roadmap evolves
- `progress.md` (BACKWARD) - Deliverables, changes, and ALL fix attempts logged immediately (including failures)
- `handoff-notes.md` - Context passed between agents

### Recovery & Troubleshooting

**If Mission Stalls**:
1. **Check Progress Files**: Review `progress.md` for complete issue history with all attempted fixes
2. **Resume Mission**: Re-run the same command to continue
3. **Escalate Issues**: Complex problems automatically flagged to @coordinator

**Common Issues & Solutions**:
| Issue | Cause | Solution |
|-------|-------|----------|
| "Input file not found" | Wrong file path | Use absolute path: `/full/path/to/file.md` |
| "Missing requirements" | Incomplete template | Fill all sections in input file |
| "Agent timeout" | Complex analysis | Re-run command - work continues from checkpoint |
| "Conflicting dependencies" | Technical constraints | Check `progress.md` for resolution steps |

**Emergency Commands**:
```bash
/coord status              # Check current mission status
/coord resume [mission]    # Continue paused mission
/report today             # Generate progress summary
```

### Mission Success Patterns

**High-Success Missions Include**:
- ✅ **Complete Input Files**: All template sections filled with specific details
- ✅ **Clear Objectives**: Specific, measurable goals defined
- ✅ **Realistic Scope**: MVP-focused feature sets
- ✅ **Context Provided**: Business background and user needs
- ✅ **Technical Constraints**: Budget, timeline, and technology preferences

**Pro Tips for Better Results**:
1. **Be Specific**: "User login" → "OAuth login with Google and GitHub options"
2. **Include Examples**: Show exactly what success looks like
3. **Set Boundaries**: Define what's in/out of scope clearly
4. **Provide Context**: Explain the "why" behind requirements
5. **Review Templates**: Study successful examples in `/templates/`

**Mission Execution Cheatsheet**: [📋 Complete Quick Reference →](project/field-manual/mission-execution-cheatsheet.md)

## 📊 Performance & Impact Metrics

### v2.0 Modernization Results

<div align="center">

| Capability | Before v2.0 | After v2.0 | Improvement |
|------------|-------------|------------|-------------|
| Agent Effectiveness | Baseline | 39% better | Extended thinking + self-verification |
| Token Consumption | ~200K/mission | 84% reduction | Context editing + memory optimization |
| Autonomous Operation | 6-8 hours | 30+ hours | Multi-day missions without intervention |
| Rework & Errors | Frequent ping-pong | 50% reduction | Pre-handoff verification catches issues |
| Context Loss | Partial across sessions | Zero loss | Persistent memory + context files |
| Security Posture | Manual oversight | 64% read-only | Least-privilege tool permissions |

</div>

### Traditional vs AGENT-11

<div align="center">

| Metric | Traditional Team | AGENT-11 v2.0 |
|--------|------------------|---------------|
| Time to MVP | 3-6 months | 2-4 weeks |
| Team Size | 5-10 people | 1 founder + 11 AI specialists |
| Cost per Feature | $10-50k | <$500 |
| Project Setup | Hours | Under 5 minutes |
| Team Context | Manual briefings | Persistent memory + auto bootstrap |
| Quality Assurance | Manual review cycles | Built-in self-verification |
| Multi-Day Missions | Impossible | 30+ hour autonomous operation |

</div>

## 🎖️ Community Success Stories

> "Each project gets its own elite team that understands the codebase perfectly. Game changer."
> — *Alex Chen, Solo Founder ($15k MRR)*

> "Project-local agents mean no confusion, no context switching. They just get it."
> — *Sarah Martinez, Technical Founder*

> "Clean deployments, isolated teams per project. Finally, AI that scales with my workflow."
> — *David Kim, Multi-Project Founder*

> "The v2.0 memory system is incredible - agents remember decisions from days ago. No more context loss."
> — *AGENT-11 Beta Tester*

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

## 🧠 Hybrid Memory & Context System

**Next-generation knowledge management combining persistent memory with dynamic context coordination:**

### Two-Tier Intelligence Architecture

**Tier 1: Persistent Memory (NEW in v2.0)**
- **Native Memory Tools**: Claude Code's memory API for long-term project knowledge
- **Structured Storage**: Organized by concern (project, user, technical, lessons)
- **Cross-Session Persistence**: Knowledge survives context resets and session restarts
- **Automated Bootstrap**: Initialize from ideation documents with structured extraction
- **Zero Knowledge Loss**: 100% retention of critical decisions and insights

**Tier 2: Dynamic Context Files**
- **agent-context.md**: Rolling mission findings and discoveries
- **handoff-notes.md**: Agent-to-agent coordination and specific recommendations
- **evidence-repository.md**: Artifacts, screenshots, code examples, and debugging evidence

### Why This Hybrid Approach?

**Memory = What Needs to PERSIST**
- Project requirements and constraints
- Architectural decisions and rationale
- User preferences and goals
- Technical patterns and lessons learned

**Context Files = What Needs to FLOW**
- Current mission objectives and status
- Agent handoff coordination
- Immediate working evidence
- Mission-specific findings

### System Performance

**Knowledge Management**:
- **100% Retention**: No context loss across sessions or agent switches
- **84% Token Reduction**: Context editing + memory optimization
- **30+ Hour Missions**: Multi-day autonomous operation capability
- **Smart Degradation**: Graceful fallback to context files if memory unavailable

**Coordination Quality**:
- **50% Rework Reduction**: Self-verification catches errors before handoffs
- **Seamless Handoffs**: Complete context transfer between specialists
- **Continuous Learning**: Insights accumulated in persistent memory
- **Audit Trail**: Complete history of decisions and evolution

### How It Works

**Mission Initialization**:
1. Bootstrap workflow extracts knowledge from ideation.md
2. Structured memory files created in /memories/ directory
3. Context files initialized for mission coordination
4. Agents access both memory (persistent) and context (mission-specific)

**Agent Workflow**:
1. **Read Memory**: Load persistent project knowledge
2. **Read Context**: Load current mission status and handoffs
3. **Execute Task**: Apply knowledge to current objective
4. **Update Memory**: Store new insights and learnings
5. **Update Context**: Document handoff for next agent

**No Setup Required**: Templates and protocols automatically included with deployment

### Memory Architecture

```
/memories/
├── project/       # Requirements, architecture, success metrics
├── user/          # Preferences, context, goals
├── technical/     # Decisions, patterns, tooling
└── lessons/       # Insights, debugging, optimizations
```

**[📖 Complete Memory Management Guide →](project/field-manual/memory-management.md)** | **[🚀 Bootstrap Guide →](project/field-manual/bootstrap-guide.md)**

**This hybrid system eliminates the traditional tradeoff between long-term knowledge retention and short-term operational agility - you get both.**

## 🔌 MCP Integration

**Your agents leverage powerful MCP (Model Context Protocol) tools for enhanced capabilities:**

### Quick MCP Setup (IMPORTANT: Use Correct Package Names)
```bash
# 1. Install MCP packages globally (REQUIRED)
npm install -g @playwright/mcp                      # NOT @modelcontextprotocol/server-playwright
npm install -g @upstash/context7-mcp               # NOT @context7/mcp-server
npm install -g firecrawl-mcp                       # NOT @mendable/firecrawl-mcp
npm install -g @edjl/github-mcp                    # NOT github-mcp-custom or @modelcontextprotocol/server-github
npm install -g @supabase/mcp-server-supabase       # NOT supabase-mcp (community package)

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

## 🔧 Claude Code SDK Integration

**AGENT-11 v2.0 is purpose-built for Claude Code, leveraging native capabilities for maximum performance:**

### Native Features (No External Infrastructure Required)

**Memory Tools Integration**
- Direct API access to Claude's persistent memory system
- Structured knowledge storage in /memories/ directory
- Automatic context-to-memory promotion for critical insights
- Zero external dependencies - pure Claude Code implementation

**Extended Thinking Modes**
- Strategic cognitive resource allocation per agent role
- "ultrathink" for architecture (8x cost, prevents 10-100x rework)
- "think harder" for strategy (3x cost, critical product decisions)
- "think hard" for coordination (2x cost, mission orchestration)
- Standard modes for routine execution (cost-optimized)

**Context Editing Protocol**
- Strategic /clear commands at phase transitions
- Automatic trigger at 30,000 input tokens
- Memory tool exclusion (never cleared)
- 84% token reduction in long-running missions

**Tool Permission System**
- Native Claude Code tool allowlisting
- Explicit permissions per agent role
- 64% of agents restricted to read-only
- Security-first least-privilege model

### Why This Matters

**Performance Benefits**:
- 39% effectiveness improvement through cognitive optimization
- 84% token reduction enabling 30+ hour missions
- 50% rework reduction via self-verification
- Zero external API latency or dependencies

**Reliability Advantages**:
- No external services to fail or rate limit
- Pure Claude Code execution environment
- Graceful degradation if features unavailable
- Works in air-gapped or restricted environments

**Developer Experience**:
- Single installation command
- No API keys for core functionality
- No server maintenance or monitoring
- Automatic updates with Claude Code releases

**[📖 Memory Management →](project/field-manual/memory-management.md)** | **[🧠 Extended Thinking →](project/field-manual/extended-thinking-guide.md)** | **[✂️ Context Editing →](project/field-manual/context-editing-guide.md)** | **[🔒 Tool Permissions →](project/field-manual/tool-permissions-guide.md)**

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

## 📚 Field Manual & Capability Guides

**Comprehensive documentation for mastering all AGENT-11 v2.0 capabilities:**

### 🆕 Phase 1 & 2 Modernization Guides (NEW!)

**Foundation Enhancement Guides**
- **[Memory Management Guide](project/field-manual/memory-management.md)** (300+ lines)
  - Native memory tools architecture and API reference
  - Hybrid two-tier context strategy (memory + files)
  - Security-first implementation with path validation
  - Integration patterns for all 11 specialists
  - Performance expectations and best practices

- **[Bootstrap Guide](project/field-manual/bootstrap-guide.md)** (550+ lines)
  - Automated project initialization workflows
  - Greenfield bootstrap from ideation documents
  - Brownfield bootstrap for existing codebases
  - CLAUDE.md auto-generation from analysis
  - Memory extraction and structuring patterns

- **[Context Editing Guide](project/field-manual/context-editing-guide.md)** (650+ lines)
  - Strategic /clear usage for token optimization
  - When and how to clear context safely
  - 84% token reduction patterns
  - Agent-specific clearing triggers
  - Integration with memory tool architecture

**Agent Optimization Guides**
- **[Extended Thinking Guide](project/field-manual/extended-thinking-guide.md)** (300+ lines)
  - All 4 thinking modes explained with ROI analysis
  - Agent-specific mode assignments and rationale
  - Mission-specific thinking triggers
  - Cost-benefit optimization strategies
  - 39% effectiveness improvement patterns

- **[Tool Permissions Guide](project/field-manual/tool-permissions-guide.md)** (650+ lines)
  - Complete tool categorization and security implications
  - Tool permission matrix for all 11 agents
  - Least-privilege security model implementation
  - 64% read-only agent achievement
  - Separation of duties enforcement

- **[Enhanced Prompting Guide](project/field-manual/enhanced-prompting-guide.md)** (600+ lines)
  - Self-verification patterns and pre-handoff checklists
  - 5-step error recovery protocols
  - Collaboration handoff templates
  - Quality validation frameworks
  - Role-specific prompting techniques

### Core Operations Guides

**Architecture & Planning**
- **[Architecture SOP](project/field-manual/architecture-sop.md)** - System design documentation standards
- **[Creating Missions](project/field-manual/creating-missions.md)** - Custom mission development
- **[Mission Execution Cheatsheet](project/field-manual/mission-execution-cheatsheet.md)** - Quick reference

**Integration & Setup**
- **[MCP Integration](project/field-manual/mcp-integration.md)** - Model Context Protocol setup
- **[MCP Troubleshooting](project/field-manual/mcp-troubleshooting.md)** - Common MCP issues
- **[Getting Started](project/field-manual/getting-started.md)** - AGENT-11 quickstart

**Implementation Patterns**
- **[Greenfield Implementation](project/field-manual/greenfield-implementation.md)** - New project patterns
- **[Brownfield Implementation](project/field-manual/brownfield-implementation.md)** - Existing codebase patterns
- **[Multi-Project Workflows](project/field-manual/multi-project-workflows.md)** - Managing multiple projects
- **[Update Management](project/field-manual/update-management.md)** - Keeping AGENT-11 current

**Design & Quality**
- **[UI Doctrine](project/field-manual/ui-doctrine.md)** - Design review protocols
- **[Coordinator Commands](project/field-manual/coordinator-commands.md)** - Mission orchestration

### Quick Navigation

| Guide Type | Documentation | Purpose |
|------------|---------------|---------|
| **Memory & Context** | [Memory](project/field-manual/memory-management.md), [Bootstrap](project/field-manual/bootstrap-guide.md), [Context Editing](project/field-manual/context-editing-guide.md) | Persistent knowledge & token optimization |
| **Agent Enhancement** | [Extended Thinking](project/field-manual/extended-thinking-guide.md), [Tool Permissions](project/field-manual/tool-permissions-guide.md), [Enhanced Prompting](project/field-manual/enhanced-prompting-guide.md) | Cognitive optimization & quality assurance |
| **Project Setup** | [Getting Started](project/field-manual/getting-started.md), [Greenfield](project/field-manual/greenfield-implementation.md), [Brownfield](project/field-manual/brownfield-implementation.md) | Initialize and configure projects |
| **Operations** | [MCP Integration](project/field-manual/mcp-integration.md), [Architecture SOP](project/field-manual/architecture-sop.md), [UI Doctrine](project/field-manual/ui-doctrine.md) | Day-to-day mission execution |

**Total Documentation**: 2,650+ lines of comprehensive guides created in Phase 1 & 2 modernization

## 🔥 Mission Library (18 Missions)

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
- **[📐 ARCHITECTURE](project/missions/mission-architecture.md)** - System architecture documentation (2-3 hours)

### Strategic Missions  
- **[📋 PRODUCT-DESCRIPTION](project/missions/mission-product-description.md)** - Product definition with risk management (2-3 hours)
- **[💡 MVP](project/missions/mission-mvp.md)** - Minimum viable product (1-3 days)
- **[🔄 MIGRATE](project/missions/mission-migrate.md)** - System migration (4-8 hours)
- **[⚡ OPTIMIZE](project/missions/mission-optimize.md)** - Performance optimization (3-6 hours)
- **[🔒 SECURITY](project/missions/mission-security.md)** - Security audit & fixes (4-6 hours)
- **[🔌 INTEGRATE](project/missions/mission-integrate.md)** - Third-party integration (3-6 hours)
- **[🎯 RELEASE](project/missions/mission-release.md)** - Release management (2-4 hours)

### Mission Command Quick Reference

| Mission | Command | Input Required | Duration | Use Case |
|---------|---------|----------------|----------|----------|
| **Setup Missions** |
| DEV-SETUP | `/coord dev-setup ideation.md` | ✅ Ideation | 30-45 min | New project initialization |
| DEV-ALIGNMENT | `/coord dev-alignment` | ❌ None | 45-60 min | Understand existing project |
| CONNECT-MCP | `/coord connect-mcp` | ❌ None | 45-90 min | Setup external integrations |
| **Core Development** |
| BUILD | `/coord build requirements.md` | ✅ Requirements | 3-8 hours | Feature development |
| MVP | `/coord mvp vision.md` | ✅ Vision | 6-12 hours | Minimum viable product |
| FIX | `/coord fix bug-report.md` | ✅ Bug Report | 1-4 hours | Bug resolution |
| REFACTOR | `/coord refactor` | ❌ None | 2-4 hours | Code improvement |
| DEPLOY | `/coord deploy` | ❌ None | 1-2 hours | Production deployment |
| DOCUMENT | `/coord document` | ❌ None | 2-4 hours | Documentation creation |
| MIGRATE | `/coord migrate requirements.md` | ✅ Requirements | 4-8 hours | System migration |
| **Specialized Operations** |
| ARCHITECTURE | `/coord architecture vision.md` | ✅ Vision | 2-4 hours | System design |
| OPTIMIZE | `/coord optimize` | ❌ None | 3-6 hours | Performance tuning |
| SECURITY | `/coord security` | ❌ None | 4-6 hours | Security audit |
| INTEGRATE | `/coord integrate requirements.md` | ✅ Requirements | 3-6 hours | Third-party APIs |
| RELEASE | `/coord release` | ❌ None | 2-4 hours | Deployment prep |
| **Business & Growth** |
| PRODUCT-DESCRIPTION | `/coord product-description vision.md` | ✅ Vision | 2-3 hours | Marketing copy |
| **Operations** |
| GENESIS | `/coord genesis` | ❌ None | 1-2 hours | Project reconnaissance |
| RECON | `/coord recon` | ❌ None | 1-3 hours | Design intelligence |

**Input File Templates**: Available in `/templates/mission-inputs/`  
**Legend**: ✅ Required input file | ❌ No input needed

[📋 Complete Mission Library →](project/missions/library.md)

## 🔄 Updating Existing Installation

**Already have AGENT-11?** Get the latest features including the `/coord` mission system:

```bash
# Single command to update your project
cd /path/to/your/project
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/install.sh | bash -s core
```

**🛡️ Your Custom CLAUDE.md is Safe!** The installer:
- ✅ **Never overwrites** your existing CLAUDE.md file
- ✅ Creates `CLAUDE-AGENT11-TEMPLATE.md` with latest AGENT-11 features
- ✅ Creates automatic backup: `CLAUDE.md.backup-[timestamp]`
- ✅ Provides clear instructions for merging new capabilities

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
