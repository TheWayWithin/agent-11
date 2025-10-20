<div align="center">

# AGENT-11™

### Your Elite AI Development Squad

[![Claude Code Compatible](https://img.shields.io/badge/Claude%20Code-Native-blue?style=for-the-badge)](https://claude.ai)
[![Deploy Time](https://img.shields.io/badge/Deploy%20Time-Under%201%20Second-green?style=for-the-badge)](QUICK-START.md)
[![Success Rate](https://img.shields.io/badge/Success%20Rate-98%25-brightgreen?style=for-the-badge)](INSTALLATION.md)
[![Agents](https://img.shields.io/badge/Agents-11%20Specialists-red?style=for-the-badge)](project/agents/)
[![Missions](https://img.shields.io/badge/Missions-20%20Workflows-purple?style=for-the-badge)](project/missions/)
[![MCP Integration](https://img.shields.io/badge/MCP-Enabled-orange?style=for-the-badge)](project/field-manual/mcp-integration.md)
[![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)](LICENSE)

**One Founder. Eleven Specialists. Unlimited Potential.**

[🚀 Quick Start](#-quick-start-5-minutes) · [📖 Documentation](#-complete-documentation) · [🎯 Workflows](#-common-workflows) · [💬 Support](#-join-the-elite)

</div>

---

## What is AGENT-11?

AGENT-11 deploys 11 specialized AI agents to your project, orchestrating them through proven workflows to build production-ready software. Think of it as **hiring an elite development team** - except they're AI agents working together seamlessly.

**Instead of prompting Claude Code for every task, AGENT-11 provides:**
- 🎯 **Specialized Agents** - Each with domain expertise (requirements, architecture, coding, testing, design, etc.)
- 🎖️ **Coordinated Workflows** - 20 pre-built missions that orchestrate multiple agents automatically
- 🧠 **Persistent Context** - Knowledge that survives across sessions and agent handoffs
- ✅ **Quality Assurance** - Built-in testing, verification, and security protocols

### How AGENT-11 Works with BOS-AI

AGENT-11 is the **technical execution arm** of the BOS-AI ecosystem. BOS-AI handles strategic planning (30 business agents) → AGENT-11 handles software development (11 technical agents).

**You can use AGENT-11 standalone** without BOS-AI. [→ Complete BOS-AI Integration Guide](project/field-manual/bos-ai-integration-guide.md)

## Is AGENT-11 Right for You?

### ✅ Perfect For:
- **Solo founders** building products without technical teams
- **Developers** who want structured AI assistance with quality assurance
- **Technical projects** requiring multiple specialties (frontend, backend, DevOps, testing)
- **Long-running projects** needing context preservation across sessions

### ❌ Not Ideal For:
- Simple scripts or one-off tasks (use Claude Code directly)
- Projects requiring constant human oversight (AGENT-11 is autonomous)
- Non-technical work (use BOS-AI for business operations)

## What You Can Build

**The Ultimate Proof: AGENT-11 Built by AGENT-11**

The deployment system you just used was built by AGENT-11 itself—from concept to working system in under 1 day. Complete automated installation, agent orchestration, configuration management, and error handling. 98% success rate, <1 second deployment.

**If AGENT-11 can build itself, it can build anything.**

**Your projects can include:**
- SaaS applications with AI analysis, authentication, payment processing
- Marketplace platforms with OAuth, reviews, community features
- Web applications with Next.js, React, Tailwind CSS, modern stacks
- API services with REST/GraphQL endpoints, third-party integrations
- Business tools with analytics, automation, data pipelines

**Time to MVP**: 1-3 days with `/coord mvp` mission

[→ See 7+ Real Production Projects](docs/PROJECTS-BUILT-WITH-AGENT-11.md)

## Why AGENT-11 Works

**Proven Performance** (v2.0 Modernization Results):
- **39% effectiveness improvement** - Extended thinking + self-verification for better decisions
- **84% token reduction** - Context editing + memory optimization enables 30+ hour missions
- **Time to MVP**: Traditional team (3-6 months) → AGENT-11 (2-4 weeks)
- **Cost per Feature**: Traditional ($10-50k) → AGENT-11 (<$500)

[→ Complete Performance Metrics](docs/features/performance.md)

## Your Squad

**Core Squad (4 agents)**:
- 🎯 **Strategist** - Product vision and requirements analysis
- 💻 **Developer** - Code implementation at light speed
- ✅ **Tester** - Zero bugs reach production (SENTINEL Mode)
- 🚀 **Operator** - Deploy with confidence

**Specialist Squad (7 agents)**:
- 🏗️ **Architect** - Bulletproof technical decisions
- 🎨 **Designer** - Interfaces that convert (RECON Protocol)
- 📚 **Documenter** - Knowledge captured perfectly
- 💬 **Support** - Users become advocates
- 📊 **Analyst** - Data drives decisions
- 📈 **Marketer** - Growth on autopilot
- 🎖️ **Coordinator** - Mission commander (PARALLEL STRIKE)

[→ Complete Agent Reference](docs/reference/agents.md)

## 🚀 Quick Start (5 Minutes)

### Prerequisites
**AGENT-11 requires a project context to deploy.** Your directory needs at least ONE of:
- 🔧 **Git repository** (recommended): `git init`
- 📄 **README file**: `README.md`
- 📦 **Package file**: `package.json`, `requirements.txt`, etc.

[→ Detailed prerequisites](#detailed-prerequisites)

### Step 1: Deploy Your Squad (30 seconds)

```bash
# Navigate to your project
cd /path/to/your/project

# Deploy full squad (recommended)
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/install.sh | bash -s full

# Restart Claude Code
/exit
claude
```

**Success indicator**: You should see "✅ AGENT-11 deployed successfully" message

**What gets installed**:
- 11 specialized agent prompts in `.claude/agents/`
- 20+ mission workflows
- Context management system
- Project templates

### Installation Issues?

**"Command not found" after install?**
```bash
# Restart Claude Code completely
/exit
claude
```

**"Permission denied"?**
```bash
chmod +x ./project/deployment/scripts/install.sh
./project/deployment/scripts/install.sh full
```

**Agents not appearing?**
```bash
# Check installation
ls -la .claude/agents/
# Should show 11 .md files
```

**Expected output after `/agents` command:**
```
Project agents (.claude/agents):
- coordinator.md
- strategist.md
- developer.md
- tester.md
- operator.md
- architect.md
- designer.md
- documenter.md
- support.md
- analyst.md
- marketer.md
```

**Success indicator:** You see 11 agents listed

**If agents don't appear:**
1. Check `.claude/agents/` directory exists: `ls -la .claude/agents/`
2. Restart Claude Code: `/exit` then `claude`
3. Re-run installation if needed

[→ Complete troubleshooting guide](#-troubleshooting)

### Step 2: Verify Deployment (30 seconds)

```bash
# List your agents
/agents
```

**Expected output:**
```
Project agents (.claude/agents):
- coordinator.md
- strategist.md
- developer.md
- tester.md
- operator.md
- architect.md
- designer.md
- documenter.md
- support.md
- analyst.md
- marketer.md
```

**Success indicator:** You see 11 agents listed

```bash
# Test your first specialist
@strategist What should we build first?
```

**Success indicator:** Strategist responds with analysis and questions

### Step 3: Run Your First Mission (2-3 minutes)

**For existing projects**:
```bash
/coord dev-alignment
```
Analyzes your codebase, creates documentation, sets up context system.

**For new projects**:

**Step 1: Create your vision document**
```bash
# Copy template
cp templates/mission-inputs/vision.md my-project-vision.md

# Edit with your details (example below)
nano my-project-vision.md
```

**Example vision.md content:**
```markdown
# Project: Task Manager MVP

## Goal
Simple web-based task management for small teams

## Target Users
Small teams (3-10 people) needing basic task tracking

## Core Features (MVP)
1. Create, edit, delete tasks
2. Assign tasks to team members
3. Mark complete/incomplete
4. Basic search and filtering
5. Simple dashboard view

## Technical Preferences
- Frontend: React with TypeScript
- Backend: Node.js with Express
- Database: PostgreSQL
- Hosting: Vercel + Railway

## Timeline
2-day MVP for initial testing

## Success Criteria
- 5 team members can use simultaneously
- Tasks persist across sessions
- Mobile-responsive interface
```

**Step 2: Initialize project**
```bash
/coord dev-setup my-project-vision.md
```

**What happens (30-45 minutes):**
- Strategist analyzes vision → creates requirements
- Architect designs system → creates architecture.md
- Developer sets up structure → initializes codebase
- Tester configures testing → sets up test framework

**Expected deliverables:**
- `architecture.md` - System design
- `project-plan.md` - Development roadmap
- `CLAUDE.md` - Project-specific instructions
- `/memories/` - Persistent knowledge
- Basic project structure

**Time:** 30-45 minutes

**Success indicator**: Mission completes with `project-plan.md` and `progress.md` created

### Step 4: Build Something (30 minutes)

```bash
# Build a feature
/coord build requirements.md

# Fix a bug
/coord fix bug-report.md

# Create MVP
/coord mvp vision.md
```

**Congratulations!** You're now using AGENT-11.

## 🎯 Common Workflows

Learn the most common AGENT-11 workflows with real examples, time estimates, and expected outcomes.

### 1. Building an MVP (1-3 days)

**When to use**: You have a product vision and need to ship fast

**What you'll get**: Production-ready MVP with auth, payments, testing, and deployment

**Time estimate**: 1-3 days depending on complexity

```bash
# Step 1: Create your vision document
/coord dev-setup ideation/vision.md

# Step 2: Build core features
/coord build ideation/requirements.md

# Step 3: Quality assurance
/coord test

# Step 4: Deploy to production
/coord deploy
```

**What happens**:
- Strategist analyzes vision → creates product requirements
- Architect designs system → creates architecture.md
- Developer implements features → writes code
- Tester validates quality → runs comprehensive tests
- Operator deploys safely → sets up staging + production

**Deliverables**: Working MVP, tests, documentation, deployment guides

**Real example**: [LLM.txt Mastery](https://llmtxtmastery.com) built in 3 days

**Cost estimate:** $5-10 in API usage

**Recovery Protocols:**

**MVP too complex?**
```bash
@strategist "Review my MVP scope and identify what can be cut to ship faster"
```

**Tests failing?**
```bash
/coord fix test-failures.md
```

**Need to add feature after MVP?**
```bash
/coord build feature-requirements.md
```

**Verify deliverables:**
```bash
# Check these files were created:
ls architecture.md project-plan.md progress.md README.md
ls -la src/ tests/ deployment-config/
```

---

### 2. Fixing Critical Issues (2-4 hours)

**When to use**: Production bug that needs immediate attention

**What you'll get**: Root cause identified, fix implemented, tests added

**Time estimate**: 2-4 hours average

```bash
# Analyze and fix the issue
/coord fix bug-report.md
```

**What happens**:
- Coordinator reads bug report → creates fix plan
- Developer identifies root cause → implements fix
- Tester validates fix → ensures no regressions
- Documenter updates docs → prevents recurrence

**Deliverables**: Bug fix, regression tests, updated documentation

**Cost estimate:** $0.50-1.50 in API usage

**Recovery Protocols:**

**Can't reproduce the bug?**
```bash
@tester "Help me create a minimal reproduction case for this bug"
```

**Fix causes other issues?**
```bash
/coord test  # Run full test suite
@tester "Identify regressions from recent fix"
```

**Need emergency rollback?**
```bash
@operator "Rollback to previous deployment"
```

**Verify deliverables:**
```bash
# Confirm fix is deployed:
git log -1  # See commit
npm test    # Tests pass
```

---

### 3. UI/UX Design Review (1-2 hours)

**When to use**: Need professional design audit before launch

**What you'll get**: Comprehensive UI/UX analysis with specific improvements

**Time estimate**: 1-2 hours for full site review

```bash
# Run design review
/design-review
```

**What happens**:
7-phase systematic audit using RECON Protocol:
1. **Preparation** - Environment setup, baseline screenshots
2. **Interaction Testing** - User flows and micro-interactions
3. **Responsive Validation** - Cross-device compatibility (mobile, tablet, desktop)
4. **Visual Polish** - Typography, spacing, hierarchy
5. **Accessibility Audit** - WCAG AA+ compliance, screen readers
6. **Robustness Testing** - Edge cases, error states, loading states
7. **Performance Check** - Load times, console errors

**Deliverables**:
- ✅ Issues classified by severity (BLOCKER/HIGH/MEDIUM/NITPICK)
- ✅ Screenshots and evidence for each issue
- ✅ Reproduction steps for developers
- ✅ Accessibility compliance report

**Real example**: "Identified 12 accessibility issues before launch, preventing legal compliance problems"

**Cost estimate:** $0.50-1 in API usage

**Recovery Protocols:**

**Too many issues to fix?**
```bash
@designer "Prioritize design issues by business impact"
```

**Need design implementation help?**
```bash
@developer "Implement the HIGH priority design fixes"
```

**Accessibility issues found?**
```bash
@designer "Create accessibility remediation plan"
```

**Verify deliverables:**
```bash
# Check report was created:
ls design-review-report.md
# Review evidence:
ls evidence-repository.md
```

---

### 4. Feature Development (4-8 hours)

**When to use**: Building production-quality feature from requirements

**What you'll get**: Feature built, tested, documented, deployed

**Time estimate**: 4-8 hours for standard features

```bash
# Build new feature
/coord build requirements.md
```

**What happens**:
1. **@strategist** analyzes requirements → user stories (30-45 min)
2. **@architect** designs solution → technical approach (30-45 min)
3. **@developer** implements → code + unit tests (2-4 hours)
4. **@tester** validates → E2E tests and quality assurance (1 hour)
5. **@documenter** documents → API docs, user guides (optional, 1 hour)

**Deliverables**:
- ✅ Production-ready feature code
- ✅ Comprehensive test coverage (unit + E2E)
- ✅ Documentation (API, user guide)
- ✅ Updated project-plan.md and progress.md

**Real example**: "Implemented payment processing with Stripe in 6 hours including tests and error handling"

**Cost estimate:** $1-3 in API usage

**Recovery Protocols:**

**Feature too complex?**
```bash
@architect "Break this feature into smaller incremental phases"
```

**Implementation stuck?**
```bash
@developer "Review current implementation and suggest alternative approach"
```

**Tests not passing?**
```bash
@tester "Debug test failures and identify root cause"
```

**Verify deliverables:**
```bash
# Check feature is complete:
git log --oneline -5  # Recent commits
npm test             # Tests pass
ls src/features/     # New feature code
```

---

### 5. Security Audit (2-3 hours)

**When to use**: Before production, after security-related changes, periodic reviews

**What you'll get**: Security vulnerabilities identified and fixed

**Time estimate**: 2-3 hours for comprehensive audit

```bash
# Run security audit
/coord security
```

**What happens**:
1. **@architect** reviews architecture → security assessment
2. **@developer** audits code → vulnerability scan (OWASP Top 10)
3. **@tester** runs security tests → penetration testing
4. **@operator** reviews infrastructure → deployment security (CSP, CORS, HTTPS)
5. **@documenter** logs → security documentation and compliance

**Deliverables**:
- ✅ Vulnerability assessment with severity ratings
- ✅ Security fixes implemented and tested
- ✅ Compliance validation (GDPR, SOC2, etc.)
- ✅ Security documentation and prevention strategies

**Real example**: "Identified and fixed XSS vulnerability before launch, prevented potential data breach"

**Cost estimate:** $2-4 in API usage

**Recovery Protocols:**

**Critical vulnerabilities found?**
```bash
@developer "Implement immediate patches for CRITICAL security issues"
@operator "Review production security posture"
```

**False positives in scan?**
```bash
@architect "Review security findings and filter false positives"
```

**Need compliance documentation?**
```bash
@documenter "Create security compliance documentation for [GDPR/SOC2/etc]"
```

**Verify deliverables:**
```bash
# Check security is improved:
ls security-audit-report.md
npm audit  # No critical vulnerabilities
grep -r "TODO.*security" src/  # All TODOs addressed
```

---

### More Workflows

AGENT-11 includes 20 pre-built missions covering every development need:

**Setup & Initialization:**
- [DEV-SETUP](project/missions/dev-setup.md) - New project initialization (30-45 min)
- [DEV-ALIGNMENT](project/missions/dev-alignment.md) - Understand existing project (45-60 min)
- [CONNECT-MCP](project/missions/connect-mcp.md) - Setup external integrations (45-90 min)

**Development Operations:**
- [REFACTOR](project/missions/mission-refactor.md) - Code quality improvement (2-4 hours)
- [DEPLOY](project/missions/mission-deploy.md) - Production deployment (1-2 hours)
- [DOCUMENT](project/missions/mission-document.md) - Documentation creation (2-4 hours)
- [MIGRATE](project/missions/mission-migrate.md) - System migration (4-8 hours)

**Performance & Quality:**
- [OPTIMIZE](project/missions/mission-optimize.md) - Performance tuning (3-6 hours)
- [INTEGRATE](project/missions/mission-integrate.md) - Third-party APIs (3-6 hours)
- [RELEASE](project/missions/mission-release.md) - Release management (2-4 hours)

[→ See all 20 missions with commands](#-mission-library-20-missions)

[→ Mission execution guide](project/field-manual/mission-execution-cheatsheet.md) - Complete execution manual

## ⚙️ Essential Setup

Beyond basic installation, configure advanced features for production readiness.

### Testing Infrastructure

**SENTINEL Mode Testing** - Zero bugs reach production

AGENT-11 includes comprehensive testing philosophy with separation of duties:
- Developer writes feature code (not tests)
- Tester writes all tests (ensures objectivity)
- SENTINEL Mode validates before deployment

**Quick setup:**
```bash
# Automatic during missions, or manual:
@tester "Set up testing infrastructure"
```

[→ Complete Testing Setup Guide](#-testing--quality-assurance)

---

### MCP Integration (Optional)

**Extend AGENT-11 with 15+ service integrations**

```bash
# Quick MCP setup
npm install -g @playwright/mcp @upstash/context7-mcp firecrawl-mcp @edjl/github-mcp @supabase/mcp-server-supabase

# Configure API keys
cp .env.mcp.template .env.mcp
nano .env.mcp

# Run setup
./project/deployment/scripts/mcp-setup-v2.sh

# Restart Claude Code (critical!)
/exit && claude
```

**Available Integrations**: GitHub, Stripe, Railway, Netlify, Supabase, Playwright, Context7, Firecrawl

[→ Complete MCP Setup Guide](#-mcp-integration-setup-highly-recommended)

---

### Project Initialization

**New projects:**
```bash
/coord dev-setup ideation.md
```
Creates: Architecture docs, project plan, memory system, CLAUDE.md
Duration: 30-45 minutes

**Existing projects:**
```bash
/coord dev-alignment
```
Analyzes: Codebase structure, tech stack, patterns, documentation
Duration: 45-60 minutes

[→ Greenfield guide](project/field-manual/greenfield-implementation.md) | [→ Brownfield guide](project/field-manual/brownfield-implementation.md)

## 🏗️ How AGENT-11 Works

Understanding the architecture helps you maximize effectiveness.

### Three-Layer Architecture

**1. Mission Layer** - What you want to accomplish
- 20 pre-built missions (BUILD, FIX, MVP, DEPLOY, etc.)
- Custom missions via /coord command
- Input: Your requirements → Output: Completed work

**2. Coordination Layer** - How agents collaborate
- THE COORDINATOR orchestrates specialists
- Context preservation prevents information loss
- Parallel execution where possible
- Automatic dependency resolution

**3. Specialist Layer** - Who does the work
- 11 specialized agents with domain expertise
- Each agent has explicit tool permissions
- Extended thinking modes for complex decisions
- Self-verification protocols ensure quality

[→ Complete agent reference](#your-squad)

---

### Mission Execution Flow

```
User: /coord build requirements.md
       ↓
┌─────────────────┐
│  Coordinator    │ ← Reads mission, creates plan
└────────┬────────┘
         ↓
┌─────────────────┐
│ @strategist     │ ← Analyzes requirements (30-45 min)
└────────┬────────┘
         │ Updates handoff-notes.md
         ↓
┌─────────────────┐
│ @architect      │ ← Designs system (30-45 min)
└────────┬────────┘
         │ Updates handoff-notes.md
         ↓
┌─────────────────┐
│ @developer      │ ← Implements feature (2-4 hours)
└────────┬────────┘
         │ Updates handoff-notes.md
         ↓
┌─────────────────┐
│ @tester         │ ← Validates quality (1 hour)
└────────┬────────┘
         ↓
┌─────────────────┐
│ Mission Complete│ ← Updates progress.md, logs learnings
└─────────────────┘
```

---

### Key Concepts

**Context Preservation**
- `agent-context.md` - Mission-wide knowledge accumulation
- `handoff-notes.md` - Agent-to-agent communication
- Zero context loss across sessions

**Extended Thinking**
- Ultrathink (Architect) - System design decisions
- Think harder (Strategist, Coordinator) - Complex planning
- Think (Developer, Tester) - Implementation work

**Tool Permissions**
- Read-only for analysis agents (Strategist, Analyst)
- Full edit for implementation (Developer, Designer)
- Deployment-specific for Operator

[→ Memory Management](project/field-manual/memory-management.md) | [→ Extended Thinking](project/field-manual/extended-thinking-guide.md)

---

### BOS-AI Integration (Detailed)

**How AGENT-11 Works With BOS-AI**:

BOS-AI handles **strategy** (30 business agents analyzing market, competition, positioning)
→ Outputs structured requirements (PRD.md, context.md, brand-guidelines.md, vision.md)

AGENT-11 handles **execution** (11 technical agents building the product)
→ Inputs: BOS-AI documents → Outputs: Production-ready software

**Integration Workflow**:
```bash
# 1. BOS-AI completes strategic analysis
# Output: /bos-ai-output/*.md

# 2. Copy to AGENT-11 project
mkdir my-product/ideation
cp bos-ai-output/*.md my-product/ideation/

# 3. Initialize development
/coord dev-setup ideation/PRD.md

# 4. Build with complete context
/coord build ideation/PRD.md
```

[→ Complete BOS-AI Integration Guide](project/field-manual/bos-ai-integration-guide.md)

## 🚀 Features & Capabilities

Complete overview of AGENT-11's capabilities organized by category.

### Context Management

**Memory Tools** - Persistent project knowledge across sessions
- Native Claude Code memory API integration
- Structured storage by concern (project, user, technical, lessons)
- 100% knowledge retention across sessions
- Automatic bootstrap from ideation documents
- Zero external dependencies

**Context Preservation** - Zero information loss between agents
- `agent-context.md` - Mission-wide knowledge accumulation
- `handoff-notes.md` - Agent-to-agent communication
- `evidence-repository.md` - Artifacts and supporting materials
- Hybrid two-tier strategy (memory + files)
- Complete audit trail of decisions

**Strategic /clear Usage** - Optimize token consumption
- 84% token reduction in long-running missions
- Automatic trigger at 30,000 input tokens
- Memory tools never cleared (persistent knowledge)
- Agent-specific clearing triggers
- Enables 30+ hour autonomous missions

[→ Memory Management](project/field-manual/memory-management.md) | [→ Context Editing](project/field-manual/context-editing-guide.md)

---

### Project Management

**Progress Tracking** - Dual-file system for planning and learning
- `project-plan.md` - Forward-looking task roadmap
- `progress.md` - Backward-looking changelog with issue learning
- Complete fix attempt history (not just final solutions)
- Root cause analysis and prevention strategies
- Searchable lessons repository

**Mission Orchestration** - 20 pre-built workflows
- Setup missions (DEV-SETUP, DEV-ALIGNMENT, CONNECT-MCP)
- Development missions (BUILD, FIX, REFACTOR, DEPLOY)
- Strategic missions (MVP, ARCHITECTURE, SECURITY)
- Time estimates and input requirements
- Single command execution via `/coord`

**Bootstrap Patterns** - Automatic project initialization
- Greenfield bootstrap from ideation documents
- Brownfield bootstrap for existing codebases
- CLAUDE.md auto-generation from analysis
- Memory extraction and structuring
- Architecture documentation creation

[→ Bootstrap Guide](project/field-manual/bootstrap-guide.md) | [→ Mission Library](#-mission-library-20-missions)

---

### Quality Assurance

**SENTINEL Mode** - Separation of duties prevents bugs
- Tester analyzes code (read-only for integrity)
- Developer implements tests (based on tester specs)
- Tester validates results (objective verification)
- 7-phase systematic testing protocol
- Zero bugs reach production

**Self-Verification** - Agents validate their own work
- Pre-handoff checklists for every agent
- 5-step error recovery protocols
- Quality validation frameworks
- 50% rework reduction
- Complete handoff documentation required

**Comprehensive Testing** - Unit, integration, E2E automated
- mcp__playwright for browser automation
- Cross-browser testing (Chrome, Firefox, Safari, Edge)
- Visual regression detection
- Accessibility compliance (WCAG AA+)
- Performance benchmarks and monitoring

[→ Testing Guide](#-testing--quality-assurance) | [→ Enhanced Prompting](project/field-manual/enhanced-prompting-guide.md)

---

### Advanced Capabilities

**Extended Thinking Modes** - Strategic cognitive resource allocation
- **Ultrathink** (Architect) - System design decisions (8x cost, prevents 10-100x rework)
- **Think harder** (Strategist, Coordinator) - Complex planning (3x cost)
- **Think hard** (Designer, Documenter) - Creative decisions (2x cost)
- **Think** (Developer, Tester) - Implementation work (1x cost)
- 39% effectiveness improvement

**MCP Integration** - 15+ service integrations out of box
- GitHub (PRs, issues, releases, CI/CD)
- Playwright (browser automation, testing)
- Context7 (library documentation, code patterns)
- Firecrawl (web scraping, research)
- Supabase (database, auth, real-time)
- Railway, Netlify, Stripe, and more
- Optional setup, zero core dependencies

**Design Review System** - RECON Protocol with Playwright automation
- 7-phase systematic UI/UX audit
- Live environment testing with real interactions
- Evidence-based reports with screenshots
- Triage matrix (BLOCKER/HIGH/MEDIUM/NITPICK)
- Accessibility compliance verification
- `/design-review` and `/recon` commands

**OpsDev Workflow** - Staging environments and safe deployments
- Separation of concerns (developer builds, operator deploys)
- Staging validation before production
- Deployment verification and rollback
- Environment-specific configurations
- Production security hardening

[→ Extended Thinking](project/field-manual/extended-thinking-guide.md) | [→ Tool Permissions](project/field-manual/tool-permissions-guide.md) | [→ UI Doctrine](project/field-manual/ui-doctrine.md)

---

### Performance Metrics

<div align="center">

| Capability | Measurement | Impact |
|------------|-------------|--------|
| **Agent Effectiveness** | 39% improvement | Extended thinking + self-verification |
| **Token Efficiency** | 84% reduction | Context editing + memory optimization |
| **Autonomous Operation** | 30+ hours | Multi-day missions without intervention |
| **Rework Reduction** | 50% fewer errors | Pre-handoff verification catches issues |
| **Context Retention** | 100% persistence | Zero knowledge loss across sessions |
| **Security Model** | 64% read-only agents | Least-privilege tool permissions |
| **Time to MVP** | 2-4 weeks | vs 3-6 months traditional |
| **Cost per Feature** | <$500 | vs $10-50k traditional |

</div>

[→ Complete Performance Analysis](docs/features/performance.md)

### Known Limitations

- **Large codebases** (>50 files) may need phased approach
- **Complex dependencies** may require manual setup
- **Single-user operation** (no real-time collaboration)
- **Requires internet** (Claude API connection)
- **Token costs** vary by mission complexity ($0.50-$10)

[→ Complete capabilities and limitations guide](docs/features/capabilities.md)

---

### Feature Documentation

**Comprehensive Guides Available**:
- [Memory Management](project/field-manual/memory-management.md) - Persistent knowledge system (300+ lines)
- [Bootstrap Guide](project/field-manual/bootstrap-guide.md) - Project initialization (550+ lines)
- [Context Editing](project/field-manual/context-editing-guide.md) - Token optimization (650+ lines)
- [Extended Thinking](project/field-manual/extended-thinking-guide.md) - Cognitive modes (300+ lines)
- [Tool Permissions](project/field-manual/tool-permissions-guide.md) - Security model (650+ lines)
- [Enhanced Prompting](project/field-manual/enhanced-prompting-guide.md) - Quality assurance (600+ lines)

**Total Documentation**: 3,750+ lines of feature guides and implementation patterns

## 🆘 Getting Unstuck Protocol

### Step 1: Immediate Recovery
```bash
/clear  # Reset context (preserves memory)
@coordinator "I'm stuck. Help me diagnose and recover."
```

### Step 2: System Check
```bash
# Verify installation
/agents  # Should list 11 agents
ls .claude/missions/  # Should show mission files
ls .claude/agents/  # Should show 11 .md files
```

### Step 3: Simple Test
```bash
# Run basic functionality test
@developer "Create a simple 'hello world' HTML file to verify system working"
```

### Step 4: Escalation
- Check [Troubleshooting Guide](project/docs/TROUBLESHOOTING.md)
- Use `@support` agent for built-in help
- Create [GitHub Issue](https://github.com/TheWayWithin/agent-11/issues)
- Join [Discord Community](https://discord.gg/agent11)

---

## 📚 Complete Documentation

### 🚀 Quick Start
- [5-Minute Quick Start](QUICK-START.md) | [Installation](INSTALLATION.md) | [User Guide](project/docs/USER-GUIDE.md) | [Troubleshooting](project/docs/TROUBLESHOOTING.md)

### 📖 Setup & Configuration
- [Project Deployment](INSTALLATION.md) | [Update Installation](project/docs/UPDATING.md) | [MCP Integration](project/field-manual/mcp-integration.md) | [MCP Troubleshooting](project/field-manual/mcp-troubleshooting.md) | [Greenfield](project/field-manual/greenfield-implementation.md) | [Brownfield](project/field-manual/brownfield-implementation.md)

### 🎯 Mission Execution
- [Mission Cheatsheet](project/field-manual/mission-execution-cheatsheet.md) | [Custom Missions](project/field-manual/creating-missions.md) | [Coordinator Commands](project/field-manual/coordinator-commands.md) | [Mission Library](project/missions/library.md)

### 🏗️ Architecture & Planning
- [Architecture SOP](project/field-manual/architecture-sop.md) | [Architecture Template](templates/architecture.md) | [Getting Started](project/field-manual/getting-started.md) | [BOS-AI Integration](project/field-manual/bos-ai-integration-guide.md)

### 🆕 v2.0 Modernization Guides
- [Memory Management](project/field-manual/memory-management.md) | [Bootstrap Guide](project/field-manual/bootstrap-guide.md) | [Context Editing](project/field-manual/context-editing-guide.md) | [Extended Thinking](project/field-manual/extended-thinking-guide.md) | [Tool Permissions](project/field-manual/tool-permissions-guide.md) | [Enhanced Prompting](project/field-manual/enhanced-prompting-guide.md)

### 🎨 Quality & Design
- [UI Doctrine](project/field-manual/ui-doctrine.md) | [Testing & QA](#-testing--quality-assurance) | [Design Review](#-design-review-system-new)

### 📚 Agent & Mission Reference
- [Full Squad](project/agents/full-squad.md) | [Core Squad](project/agents/core-squad.md) | [Specialists](project/agents/specialists/) | [Mission Library](project/missions/library.md) | [Performance Metrics](docs/features/performance.md)

### 🛠️ Templates
- [Architecture](templates/architecture.md) | [Project Plan](templates/project-plan-template.md) | [Progress](templates/progress-template.md) | [Cleanup Checklist](templates/cleanup-checklist.md) | [Agent Context](templates/agent-context-template.md) | [Handoff Notes](templates/handoff-notes-template.md)

### 💬 Getting Help
- `@support` | [Troubleshooting](project/docs/TROUBLESHOOTING.md) | [Success Stories](project/community/SUCCESS-STORIES.md) | [GitHub Issues](https://github.com/TheWayWithin/agent-11/issues) | [Discord](https://discord.gg/agent11)

---

## 📊 Mission Progress Tracking System

AGENT-11 uses a dual-file tracking system: **project-plan.md** (forward-looking roadmap) and **progress.md** (backward-looking changelog with complete issue history). Unlike traditional changelogs that only record final solutions, progress.md documents ALL fix attempts including failures, enabling future issues to be solved faster by learning from past mistakes.

**Key Benefits**:
- Complete audit trail of what was tried and why it failed
- Root cause analysis and prevention strategies for every issue
- Searchable lessons repository that compounds over time

[→ Complete Tracking Guide](templates/progress-template.md)

## 🔄 Project Lifecycle Management

AGENT-11 includes a three-tier cleanup strategy to prevent tracking files from growing unmanageably large: **Milestone Transition** (archive completed work every 2-4 weeks), **Project Completion** (comprehensive archive when done), or **Continue Active Work** (no cleanup needed). All lessons from progress.md are extracted to a searchable `lessons/` repository organized by category (security, performance, architecture, process), ensuring knowledge compounds across missions while keeping context lean.

**Key Benefits**:
- Prevents context pollution (tracking files stay under 200 lines vs 20,000+)
- Searchable lessons repository that compounds knowledge over time
- Agents stay focused on current mission, not buried in historical details

[→ Complete Lifecycle Guide](project/field-manual/project-lifecycle-guide.md) | [→ Cleanup Checklist](templates/cleanup-checklist.md)

## 🧪 Testing & Quality Assurance

AGENT-11 uses separation of duties: THE TESTER analyzes code and creates test plans (read-only for integrity), @developer implements tests based on specs, THE TESTER executes and validates. For critical releases, **SENTINEL Mode** activates a 7-phase protocol: perimeter establishment, functional reconnaissance, visual regression, cross-browser operations, performance patrol, stress testing, and accessibility verification (WCAG AA+). Uses mcp__playwright for E2E, Jest/Vitest for unit tests, with comprehensive security validation on every run.

**Key Benefits**:
- Zero bugs reach production (objective testing prevents confirmation bias)
- 80%+ coverage on critical paths, 100% on security-sensitive code
- Cross-browser testing (Chrome, Firefox, Safari, Edge) with visual regression detection

[→ Complete Testing Guide](project/field-manual/testing-setup.md)


## 🚀 Your First Mission

**Use `/coord` to orchestrate multi-agent missions** or `@agent` for direct specialist access. All missions follow pattern: `/coord [mission] [input-file.md]`.

**Quick examples**: `/coord build requirements.md` | `/coord fix bug-report.md` | `/coord mvp vision.md`

[→ Complete Mission Execution Guide](project/field-manual/mission-execution-cheatsheet.md) | [→ Mission Library](#-mission-library-20-missions)

---

## 🎮 Command Reference

AGENT-11 provides 6 powerful slash commands for different workflows:

### 🎖️ `/coord` - Mission Orchestration
**Orchestrate multi-agent missions with automatic specialist coordination**

```bash
# Pattern: /coord [mission] [input-file.md]
/coord build requirements.md      # Feature development (4-8 hours)
/coord fix bug-report.md          # Bug resolution (1-3 hours)
/coord mvp vision.md              # Build MVP (1-3 days)
/coord dev-setup ideation.md      # Project initialization (30-45 min)
/coord dev-alignment              # Analyze existing project (45-60 min)
```

**What it does**:
- Automatically delegates to appropriate specialists
- Maintains context across agent handoffs
- Updates project-plan.md and progress.md
- Ensures quality through built-in verification

[→ See all 20 missions](#-mission-library-20-missions)

---

### 🤝 `/meeting` - Strategic Conversations
**Have natural, conversational discussions with specialists for brainstorming and planning**

```bash
# Pattern: /meeting @agent [topic]
/meeting @strategist                                    # Product strategy discussion
/meeting @architect "microservices vs monolith"         # Architecture consultation
/meeting @designer "improving user onboarding"          # Design brainstorming
/meeting @developer "real-time data synchronization"    # Technical problem-solving
```

**When to use**:
- Brainstorming new features or approaches
- Getting expert advice before formal missions
- Exploring technical decisions and trade-offs
- Creative collaboration and idea generation

**Available specialists**: @strategist, @architect, @coordinator, @developer, @tester, @designer, @operator, @marketer, @analyst, @documenter, @support

---

### 🎨 `/design-review` - UI/UX Audit
**Comprehensive design audit using RECON Protocol with automated testing**

```bash
/design-review    # Full 7-phase UI/UX audit with evidence
```

**What it analyzes** (7-phase RECON Protocol):
1. **Preparation** - Environment setup, baseline screenshots
2. **Interaction** - User flows, micro-interactions, navigation
3. **Responsive** - Mobile, tablet, desktop compatibility
4. **Visual** - Typography, spacing, hierarchy, consistency
5. **Accessibility** - WCAG AA+ compliance, screen readers
6. **Robustness** - Edge cases, error states, loading
7. **Performance** - Load times, console errors

**Deliverables**:
- Issues classified by severity (BLOCKER/HIGH/MEDIUM/NITPICK)
- Screenshots and reproduction steps
- Accessibility compliance report
- Specific recommendations with examples

[→ Complete UI Doctrine Guide](project/field-manual/ui-doctrine.md)

---

### 🔍 `/recon` - Design Intelligence
**Quick design reconnaissance for understanding existing UI/UX patterns**

```bash
/recon    # Rapid design analysis and pattern identification
```

**What it does**:
- Analyzes current design system and patterns
- Identifies UI/UX strengths and weaknesses
- Documents design decisions and rationale
- Provides strategic design recommendations

**Use when**: Need quick design assessment before major changes or starting new features

---

### 📊 `/report` - Progress Reports
**Generate stakeholder-ready progress reports automatically**

```bash
# Pattern: /report [since_date]
/report                  # Last 7 days (default)
/report 2025-08-20      # Since specific date
```

**Report includes**:
- Executive summary of progress
- Completed tasks with business impact
- Issues encountered and resolutions
- Current project status and health
- Key metrics and trends
- Next milestones and resource needs
- BOS-AI alignment (if integrated)

**Output**: Creates `progress-report.md` with professional formatting suitable for stakeholders, clients, or management

---

### 🔬 `/pmd` - Post Mortem Analysis
**Systematic root cause analysis of failures to prevent recurrence**

```bash
# Pattern: /pmd [issue_description]
/pmd                                          # Analyze recent failures from progress.md
/pmd "Coordinator not using Task tool"        # Analyze specific issue
/pmd "Installation failing on Windows"        # Analyze deployment failure
```

**Analysis covers**:
- **Agent Performance** - Prompt clarity, scope compliance, tool usage
- **Documentation Quality** - CLAUDE.md accuracy, task definitions
- **Tool Usage** - MCP prioritization, error handling
- **Process Issues** - Planning, communication, testing coverage

**Deliverables**:
- Timeline of events leading to failure
- Root cause analysis with evidence
- Immediate fixes (do now)
- Short-term improvements (this week)
- Long-term enhancements (this month)
- Prevention strategies and detection mechanisms

**Output**: Creates `post-mortem-analysis.md` with actionable recommendations

---

### Command Comparison

| Command | Purpose | Duration | Output | Best For |
|---------|---------|----------|--------|----------|
| `/coord` | Execute missions with specialists | 1-8 hours | Code, tests, docs | Building, fixing, deploying |
| `/meeting` | Strategic conversations | 15-60 min | Discussion, ideas | Brainstorming, planning |
| `/design-review` | Full UI/UX audit | 1-2 hours | Design report | Pre-launch quality checks |
| `/recon` | Quick design analysis | 30-45 min | Design insights | Understanding existing UI |
| `/report` | Stakeholder updates | 5-10 min | Progress report | Communication, tracking |
| `/pmd` | Failure analysis | 30-60 min | Root cause analysis | Learning from mistakes |

---

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

## 🔥 Mission Library (20 Missions)

### Setup Missions (NEW!)
- **[🚀 DEV-SETUP](project/missions/dev-setup.md)** - Greenfield project initialization (30-45 min)
- **[🎯 DEV-ALIGNMENT](project/missions/dev-alignment.md)** - Existing project understanding (45-60 min)
- **[⚙️ OPSDEV-SETUP](project/missions/mission-opsdev-setup.md)** - DevOps & environment configuration (20-30 min)
- **[📋 CLAUDE-SETUP](project/missions/mission-claude-setup.md)** - CLAUDE.md creation & sync (15-25 min)
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

**Common installation issues?** See the [Project-Only Deployment](#-project-only-deployment) section above for setup requirements and quick fixes.

**Complete troubleshooting guide:** [🛠️ Troubleshooting Guide →](project/docs/TROUBLESHOOTING.md)

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
