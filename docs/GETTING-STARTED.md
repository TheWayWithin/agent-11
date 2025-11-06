# Getting Started with AGENT-11

**Complete Beginner's Guide: Installation to First Successful Mission**

## What is AGENT-11?

AGENT-11 deploys 11 specialized AI agents to your project that work together like an elite development team. Instead of prompting Claude Code for every task, you have a coordinated squad of specialists handling strategy, architecture, coding, testing, design, deployment, and more.

**Think of it as**: Hiring an experienced development team that already understands your codebase perfectly.

**Time to first success**: Under 10 minutes

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [Verification](#verification)
4. [Choose Your Path](#choose-your-path)
5. [Common Scenarios](#common-scenarios)
6. [Your First Commands](#your-first-commands)
7. [FAQ](#frequently-asked-questions)
8. [Getting Help](#getting-help)

---

## Prerequisites

### What You Need Before Installing

#### ✅ Required
- **Claude Code** installed and running
- **A project directory** with at least ONE of:
  - Git repository (`.git/` directory)
  - README file
  - Package file (`package.json`, `requirements.txt`, etc.)
  - Source code files

#### 💡 Recommended (Optional)
- **GitHub account** for version control
- **Project vision** or requirements document
- **30 minutes** for your first mission

---

### Quick Project Setup

**Don't have a project yet?** Create one in 30 seconds:

```bash
# Option 1: Brand new project
mkdir my-awesome-project && cd my-awesome-project
git init
echo "# My Awesome Project" > README.md

# Option 2: Add git to existing folder
cd /path/to/existing/folder
git init

# Option 3: Use existing project
cd ~/my-existing-project  # Just navigate there
```

**Success indicator**: Running `ls -la` should show `.git/` or project files

---

## Installation

### Step 1: Navigate to Your Project Directory

```bash
cd /path/to/your/project
```

**Important**: AGENT-11 deploys to your **current project directory**. Each project gets its own isolated squad.

---

### Step 2: Choose Your Squad Size

**Which squad should you install?**

| Squad Type | Agents | Best For | Command |
|------------|--------|----------|---------|
| **Core** (Recommended) | 4 agents | 90% of projects | See below |
| **Full** | 11 agents | Complex projects | See below |
| **Minimal** | 2 agents | Quick prototypes | See below |

**Core Squad (Recommended for most users)**:
```bash
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/install.sh | bash -s core
```

**Full Squad (For complex projects)**:
```bash
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/install.sh | bash -s full
```

**Minimal Squad (For quick experiments)**:
```bash
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/install.sh | bash -s minimal
```

**Installation time**: 30-60 seconds

---

### Step 3: Restart Claude Code

```bash
# Exit current session
/exit

# Restart Claude Code in your project
claude
```

**Why restart?** Claude Code needs to reload to discover your new agents.

---

## Verification

### Verify Installation Succeeded

```bash
# Check your agents are installed
/agents
```

**Expected output** (Core Squad):
```
Project agents (.claude/agents):
  - coordinator.md
  - strategist.md
  - developer.md
  - tester.md
  - operator.md
```

**Success indicator**: You see 4-11 agent files listed (depending on squad size)

---

### Quick Test

Test that an agent responds:

```bash
@strategist Hello! Can you help me?
```

**Expected**: Strategist responds with helpful message and offers assistance

**Success indicator**: You get a response from the agent

---

## Choose Your Path

**Now that AGENT-11 is installed, what should you do next?**

Use this decision tree to find your path:

```
┌─────────────────────────────────────┐
│  What describes your situation?    │
└─────────────────────────────────────┘
                 │
         ┌───────┴───────┐
         ▼               ▼
    ┌─────────┐    ┌──────────┐
    │   NEW   │    │ EXISTING │
    │ PROJECT │    │ PROJECT  │
    └─────────┘    └──────────┘
         │               │
         ▼               ▼
```

---

### Path A: New Project (Greenfield)

**You're starting from scratch with a new idea.**

**What you need**:
- Product vision or idea (can be simple!)
- 30-45 minutes
- A project directory (created above)

**Your first command**:
```bash
/coord dev-setup ideation.md
```

**What happens**:
1. Strategist analyzes your vision → creates requirements
2. Architect designs system → creates `architecture.md`
3. Developer sets up project → initializes codebase
4. Operator configures deployment → sets up infrastructure

**Deliverables**:
- ✅ `architecture.md` - System design documentation
- ✅ `project-plan.md` - Development roadmap
- ✅ `progress.md` - Changelog
- ✅ `CLAUDE.md` - Project-specific AI instructions
- ✅ Basic project structure

**Time**: 30-45 minutes

---

#### Creating Your ideation.md

**Don't have an ideation.md?** Create one in 5 minutes:

```bash
# Copy the template
cp templates/mission-inputs/vision.md ideation.md

# Edit with your details
nano ideation.md
```

**Simple example**:

```markdown
# Project: Task Manager

## Goal
Build a simple task manager for small teams

## Target Users
Small teams (3-10 people) needing basic task tracking

## Core Features
1. Create and edit tasks
2. Assign tasks to team members
3. Mark tasks complete
4. Basic dashboard view

## Technical Preferences
- Frontend: React
- Backend: Node.js
- Database: PostgreSQL

## Timeline
2-day MVP
```

**Success indicator**: File exists and contains your project vision

---

### Path B: Existing Project (Brownfield)

**You already have code and want AGENT-11 to understand it.**

**What you need**:
- Existing codebase
- 45-60 minutes
- Nothing else!

**Your first command**:
```bash
/coord dev-alignment
```

**What happens**:
1. Strategist analyzes codebase → understands project
2. Architect reviews structure → documents architecture
3. Developer explores code → maps technical stack
4. Creates/updates tracking files

**Deliverables**:
- ✅ `architecture.md` - Analyzed system design
- ✅ `project-plan.md` - Current state and next steps
- ✅ `progress.md` - Changelog initialized
- ✅ Understanding of your codebase

**Time**: 45-60 minutes

**Success indicator**: Agents can answer questions about your codebase

---

### Path C: Build Something Right Now

**You already know what feature to build.**

**What you need**:
- Feature requirements (can be simple bullet points!)
- 4-8 hours
- Existing project context (from Path A or B)

**Your first command**:
```bash
/coord build requirements.md
```

**What happens**:
1. Strategist analyzes requirements → user stories (30-45 min)
2. Architect designs solution → technical approach (30-45 min)
3. Developer implements → code + tests (2-4 hours)
4. Tester validates → comprehensive testing (1 hour)

**Deliverables**:
- ✅ Working feature code
- ✅ Unit and E2E tests
- ✅ Updated documentation

**Time**: 4-8 hours

---

#### Creating requirements.md

**Example requirements.md**:

```markdown
# Feature: User Authentication

## Requirements
- Users can sign up with email/password
- Users can log in and log out
- Passwords are hashed securely
- JWT tokens for session management
- Password reset via email

## Technical Notes
- Use bcrypt for password hashing
- Use jsonwebtoken for JWT
- Store sessions in database

## Success Criteria
- User can complete full auth flow
- Security best practices followed
- Tests cover all auth scenarios
```

**Success indicator**: File contains clear feature requirements

---

### Path D: Fix a Bug

**Something's broken and you need it fixed fast.**

**What you need**:
- Bug description or reproduction steps
- 1-3 hours
- Existing project

**Your first command**:
```bash
/coord fix bug-report.md
```

**What happens**:
1. Developer investigates → identifies root cause (30-60 min)
2. Developer implements fix → code changes (30-60 min)
3. Tester validates → regression tests (30 min)
4. Documenter updates → prevents recurrence (15 min)

**Deliverables**:
- ✅ Bug fix implemented
- ✅ Root cause documented
- ✅ Regression tests added

**Time**: 1-3 hours

---

#### Creating bug-report.md

**Example bug-report.md**:

```markdown
# Bug: Login Fails After Password Reset

## Symptoms
- User resets password successfully
- Tries to log in with new password
- Gets "Invalid credentials" error

## Reproduction Steps
1. Go to /forgot-password
2. Enter email address
3. Click reset link in email
4. Enter new password
5. Try to log in with new password → FAILS

## Expected Behavior
User should be able to log in with new password

## Actual Behavior
Login fails with "Invalid credentials"

## Environment
- Browser: Chrome 120
- OS: macOS 14
- User: test@example.com
```

**Success indicator**: File contains clear reproduction steps

---

## Common Scenarios

### Scenario 1: "I Want to Build an MVP Fast"

**Timeline**: 1-3 days

**Steps**:
1. Create `vision.md` with your MVP idea
2. Run `/coord dev-setup vision.md` (30-45 min)
3. Run `/coord mvp vision.md` (6-12 hours)
4. Run `/coord test` (1 hour)
5. Run `/coord deploy` (1-2 hours)

**Total time**: 8-15 hours spread over 1-3 days

**Success indicator**: Working MVP deployed to production

---

### Scenario 2: "I Have a Codebase, Just Installed AGENT-11"

**Timeline**: 1 hour

**Steps**:
1. Install AGENT-11 (you just did this!)
2. Run `/coord dev-alignment` (45-60 min)
3. Ask agents questions: `@architect "Explain our database schema"`

**Success indicator**: Agents understand and can discuss your codebase

---

### Scenario 3: "I Want to Add a Specific Feature"

**Timeline**: 4-8 hours

**Steps**:
1. Create `requirements.md` with feature details
2. Run `/coord build requirements.md` (4-8 hours)
3. Verify with `@tester "Run all tests"`

**Success indicator**: Feature works and tests pass

---

### Scenario 4: "My App Has a Bug in Production"

**Timeline**: 1-3 hours

**Steps**:
1. Create `bug-report.md` with reproduction steps
2. Run `/coord fix bug-report.md` (1-3 hours)
3. Deploy fix: `@operator "Deploy hotfix to production"`

**Success indicator**: Bug is fixed and deployed

---

### Scenario 5: "I Just Want to Explore and Learn"

**Timeline**: 15-30 minutes

**Steps**:
1. Try conversing with agents:
   ```bash
   @strategist "What features should a task manager have?"
   @architect "What's the best database for this use case?"
   @developer "Show me how to implement user authentication"
   ```

2. Use `/meeting` for longer conversations:
   ```bash
   /meeting @architect "microservices vs monolith"
   ```

**Success indicator**: You understand how agents think and respond

---

## Your First Commands

### Direct Agent Commands

Talk to specialists directly using `@agent` syntax:

```bash
# Strategy and planning
@strategist Create user stories for authentication
@strategist What features should we prioritize?

# Architecture and design
@architect Design the database schema for users
@architect Review our current architecture

# Implementation
@developer Implement user registration
@developer Fix the login bug

# Testing
@tester Create tests for authentication
@tester Run all tests and report results

# Deployment
@operator Deploy to production
@operator Set up staging environment
```

**Use direct commands when**: You know exactly what you want from one specialist

---

### Mission Commands (Orchestrated Workflows)

Use `/coord` to run multi-agent missions:

```bash
# Setup missions (30-60 min each)
/coord dev-setup ideation.md          # New project initialization
/coord dev-alignment                  # Understand existing project

# Development missions (4-8 hours each)
/coord build requirements.md          # Build new feature
/coord fix bug-report.md             # Fix a bug
/coord refactor                      # Improve code quality

# Strategic missions (1-3 days)
/coord mvp vision.md                 # Build complete MVP

# Operations missions (1-2 hours)
/coord deploy                        # Deploy to production
/coord security                      # Security audit
```

**Use mission commands when**: You want multiple agents working together systematically

---

### Conversation Commands (Brainstorming)

Use `/meeting` for strategic discussions:

```bash
# Product strategy
/meeting @strategist "product roadmap planning"

# Technical decisions
/meeting @architect "scaling our database"

# Implementation approaches
/meeting @developer "optimizing API performance"

# Design improvements
/meeting @designer "improving user onboarding flow"
```

**Use meeting commands when**: You want to brainstorm or explore ideas conversationally

---

### Design Review Commands

Use design review for UI/UX audits:

```bash
# Full comprehensive audit (1-2 hours)
/design-review

# Quick design analysis (30-45 min)
/recon
```

**Use design commands when**: You need professional UI/UX feedback before launch

---

## Frequently Asked Questions

### "Which squad size should I install?"

**Start with Core Squad** (4 agents). This covers 90% of projects:
- Strategist (requirements)
- Developer (coding)
- Tester (quality)
- Operator (deployment)

**Upgrade to Full Squad later** if you need specialists like Designer, Marketer, or Analyst.

---

### "What if I don't have an ideation.md file?"

**Option 1**: Create a simple one (see [Creating Your ideation.md](#creating-your-ideationmd))

**Option 2**: Skip setup missions and jump straight to building:
```bash
# Create simple requirements
echo "Build a user login system" > requirements.md

# Build it
/coord build requirements.md
```

**Option 3**: Use an existing project with `/coord dev-alignment` (no ideation needed)

---

### "Can I use this with an existing Git repository?"

**Yes!** That's exactly what the brownfield path is for:

```bash
cd /path/to/existing/repo
# Install AGENT-11 (you already did this)
/coord dev-alignment
```

Agents will understand your existing codebase.

---

### "Do I need MCP servers?"

**No for basic usage.** The agents work great without MCPs.

**Yes for advanced features:**
- GitHub integration (PRs, issues)
- Playwright testing (browser automation)
- Supabase database operations
- Web scraping with Firecrawl

**Setup MCPs later** with `/coord connect-mcp` when you need them.

---

### "How do I know if installation worked?"

**Three checks**:

1. **Installation message**: You saw "✅ AGENT-11 deployed successfully"
2. **Agents list**: Running `/agents` shows your squad
3. **Agent responds**: `@strategist Hello!` gets a response

If all three pass, installation succeeded!

---

### "Where do the agents show up in Claude Code?"

**They don't show in a UI.** You use them via commands:

- Type `@strategist` in the chat to invoke the strategist
- Type `/coord build` to run missions
- Type `/agents` to list all available agents

**Think of it like**: Slack (mention @username) not a separate interface

---

### "What's the difference between @agent and /coord?"

**@agent** (Direct command):
- Talk to one specialist
- Quick, immediate
- Example: `@developer "Fix the login bug"`

**/coord** (Mission):
- Multiple agents work together
- Systematic, comprehensive
- Example: `/coord build requirements.md` (involves strategist, architect, developer, tester)

**Use @agent for**: Quick questions or single-agent tasks
**Use /coord for**: Complete workflows requiring coordination

---

### "Can I have multiple projects with AGENT-11?"

**Yes!** Each project gets its own isolated squad:

```bash
# Project A
cd ~/project-a
curl -sSL https://... | bash -s core

# Project B
cd ~/project-b
curl -sSL https://... | bash -s full

# No cross-contamination!
```

---

### "How much does this cost?"

**AGENT-11 is free and open source** (MIT license).

**Claude API usage costs** vary by mission:
- Quick fix: $0.50-1.50
- Feature development: $1-3
- MVP: $5-10

**Compare to**: Hiring a developer ($50-150/hour = $400-1,200/day)

---

### "What if something breaks?"

**Recovery options**:

1. **Start fresh**: `/clear` then try again
2. **Check system**: `/agents` to verify agents loaded
3. **Test agents**: `@developer "Create hello world HTML"`
4. **Get help**: `@support` or see [Troubleshooting Guide](../project/docs/TROUBLESHOOTING.md)
5. **Report bug**: [GitHub Issues](https://github.com/TheWayWithin/agent-11/issues)

**Most common issue**: Forgot to restart Claude Code after installation
**Solution**: `/exit` then `claude`

---

## Getting Help

### Built-in Support

```bash
# Ask the support agent
@support "I'm stuck on installation"

# Check troubleshooting guide
@support "Show me the troubleshooting guide"
```

---

### Documentation

**Quick Reference**:
- [Installation Guide](../INSTALLATION.md) - Detailed installation instructions
- [Troubleshooting Guide](../project/docs/TROUBLESHOOTING.md) - Common issues
- [Mission Library](../project/missions/library.md) - All 20 missions
- [User Guide](../project/docs/USER-GUIDE.md) - Complete reference

**Advanced Topics**:
- [Memory Management](../project/field-manual/memory-management.md) - Persistent context
- [MCP Integration](../project/field-manual/mcp-integration.md) - External services
- [Testing Setup](../project/field-manual/testing-setup.md) - Quality assurance

---

### Community Support

- **GitHub Issues**: [Report bugs or request features](https://github.com/TheWayWithin/agent-11/issues)
- **Discord**: [Join the community](https://discord.gg/agent11)
- **Success Stories**: [See what others built](../project/community/SUCCESS-STORIES.md)

---

## Next Steps

### Now That You're Set Up

**Choose your path** (from above) and run your first mission:

- **New project?** → `/coord dev-setup ideation.md`
- **Existing project?** → `/coord dev-alignment`
- **Build feature?** → `/coord build requirements.md`
- **Fix bug?** → `/coord fix bug-report.md`
- **Just exploring?** → `@strategist "Tell me about AGENT-11"`

---

### Learning Path

**Week 1**: Master direct agent commands
- Practice `@agent` syntax
- Try different specialists
- Build small features

**Week 2**: Learn mission workflows
- Run `/coord build` missions
- Understand multi-agent coordination
- Build complete features

**Week 3**: Advanced capabilities
- Setup MCPs with `/coord connect-mcp`
- Run design reviews with `/design-review`
- Use `/meeting` for strategy

**Week 4**: Production readiness
- Deploy with `/coord deploy`
- Security audit with `/coord security`
- Performance optimization

---

### Pro Tips

**1. Start small**
- Begin with simple tasks to learn the system
- Graduate to complex missions once comfortable

**2. Read handoff notes**
- Check `handoff-notes.md` to see what agents are thinking
- Understand the mission flow

**3. Use project tracking**
- `project-plan.md` shows what's planned
- `progress.md` shows what's done

**4. Ask for help early**
- `@support` is there to help you
- Don't struggle alone

**5. Restart when stuck**
- `/clear` resets context
- Fresh start often solves issues

---

## Quick Start Checklist

Use this to verify you're ready:

- [ ] Claude Code installed and running
- [ ] Project directory created (with git or project files)
- [ ] AGENT-11 installed (`curl` command completed)
- [ ] Claude Code restarted (`/exit` then `claude`)
- [ ] Agents verified (`/agents` shows your squad)
- [ ] Agent test passed (`@strategist Hello!` responded)
- [ ] Path chosen (new project, existing, or build)
- [ ] First mission identified (from decision tree)

**All checked?** You're ready to build! 🚀

---

## Complete Example Workflow

**Let's build a task manager from scratch:**

### 1. Setup (5 minutes)
```bash
# Create project
mkdir task-manager && cd task-manager
git init
echo "# Task Manager" > README.md

# Install AGENT-11
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/install.sh | bash -s core

# Restart Claude Code
/exit
claude
```

### 2. Create Vision (5 minutes)
```bash
# Create vision.md
cat > vision.md << 'EOF'
# Task Manager MVP

## Goal
Simple task management for small teams

## Features
1. Create/edit/delete tasks
2. Assign to team members
3. Mark complete
4. Basic dashboard

## Tech Stack
- React frontend
- Node.js backend
- PostgreSQL database

## Timeline
2 days
EOF
```

### 3. Initialize Project (45 minutes)
```bash
/coord dev-setup vision.md
```

**Wait for**: `architecture.md` and `project-plan.md` created

### 4. Build MVP (6-8 hours)
```bash
/coord mvp vision.md
```

**Wait for**: Working application with all core features

### 5. Test (1 hour)
```bash
/coord test
```

**Wait for**: All tests passing

### 6. Deploy (1 hour)
```bash
/coord deploy
```

**Wait for**: Application live in production

**Total time**: 8-12 hours over 1-2 days
**Cost**: $5-10 in API usage
**Result**: Production-ready task manager

---

## Success Stories

> "Installed AGENT-11 at 9am, had my first feature shipped by 5pm. Game changer."
> — *Alex Chen, Solo Founder*

> "The decision trees in the getting started guide made it so easy to know what to do next."
> — *Sarah Martinez, Technical Founder*

> "I went from never using Claude Code to shipping an MVP in 3 days. AGENT-11's structure made it possible."
> — *David Kim, Non-Technical Founder*

[Read more success stories →](../project/community/SUCCESS-STORIES.md)

---

## Summary

**You've learned**:
- ✅ How to install AGENT-11
- ✅ How to verify installation
- ✅ How to choose your path
- ✅ How to run your first mission
- ✅ Where to get help

**You're ready to**:
- 🚀 Build features
- 🐛 Fix bugs
- 🎨 Create MVPs
- 🔧 Deploy to production

**Next action**: Choose your path from the decision tree and run your first mission!

---

**Questions?** Ask `@support` or check the [Troubleshooting Guide](../project/docs/TROUBLESHOOTING.md)

**Ready to build?** Your elite AI squad is waiting for orders! 🎖️
