# New Project Setup Guide

Complete guide to setting up a new project with AGENT-11 from scratch.

## Prerequisites

Before starting, ensure you have:

| Requirement | Check Command | Install |
|-------------|---------------|---------|
| **Claude Code** | `claude --version` | [Download](https://claude.ai/code) |
| **Git** | `git --version` | `brew install git` (macOS) |
| **GitHub CLI** | `gh --version` | `brew install gh` (macOS) or [CLI install](https://cli.github.com/) |
| **GitHub Auth** | `gh auth status` | `gh auth login` if not authenticated |

### GitHub CLI Authentication

If `gh auth status` shows "not logged in":

```bash
gh auth login
# Select: GitHub.com
# Select: HTTPS (recommended)
# Select: Login with a web browser
# Press Enter, copy the code, paste in browser
```

---

## Step 1: Create Project Directory

```bash
# Create and navigate to your project
mkdir my-project
cd my-project
```

**Naming conventions:**
- Use lowercase with hyphens: `my-saas-app`, `client-portal`
- Avoid spaces and special characters
- Keep it short but descriptive

---

## Step 2: Initialize Git

```bash
git init
```

This creates a `.git` directory and enables version control.

---

## Step 3: Create GitHub Repository

```bash
# Private repository (recommended for new projects)
gh repo create my-project --private --source=. --push

# Public repository (for open source)
gh repo create my-project --public --source=. --push
```

**What this does:**
- Creates repository on GitHub
- Links your local directory to it
- Sets up remote origin

**Verify:**
```bash
git remote -v
# Should show: origin https://github.com/yourusername/my-project.git
```

---

## Step 4: Add Foundation Documents (BOS-AI Users)

If you have BOS-AI documents (PRD, Vision, Brand, etc.):

```bash
# Create foundations directory
mkdir -p documents/foundations

# Copy your BOS-AI documents
cp ~/Documents/BOS-AI/PRD.md documents/foundations/
cp ~/Documents/BOS-AI/Vision-Mission.md documents/foundations/
cp ~/Documents/BOS-AI/Brand-Style-Guidelines.md documents/foundations/
cp ~/Documents/BOS-AI/Client-Success-Blueprint.md documents/foundations/
cp ~/Documents/BOS-AI/Marketing-Bible.md documents/foundations/

# Or copy all at once
cp ~/Documents/BOS-AI/*.md documents/foundations/
```

**Expected files:**
| Document | Purpose |
|----------|---------|
| PRD.md | Product requirements, features, tech stack |
| Vision-Mission.md | Business goals, hedgehog concept |
| Brand-Style-Guidelines.md | Colors, typography, design system |
| Client-Success-Blueprint.md | User personas, pain points, jobs to be done |
| Marketing-Bible.md | Positioning, messaging, channels |

**Don't have BOS-AI docs?** Skip to Step 5 - you can use AGENT-11 standalone.

---

## Step 5: Install AGENT-11

```bash
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/install.sh | bash -s full
```

**What gets installed:**
- 11 specialized agents in `.claude/agents/`
- 20 mission templates in `missions/`
- Slash commands in `.claude/commands/`
- Documentation in `field-manual/`
- Templates in `templates/`

**Verify installation:**
```bash
ls .claude/agents/
# Should show: architect.md, coordinator.md, developer.md, etc.
```

---

## Step 6: Restart Claude Code

```bash
/exit
claude
```

This loads the newly installed agents and commands.

**Verify agents loaded:**
```bash
/agents
# Should show all 11 agents
```

---

## Step 7: Choose Your Workflow

### Path A: BOS-AI Workflow (Recommended)

If you copied BOS-AI documents in Step 4:

```bash
# 1. Process foundation documents
/foundations init

# 2. Design system architecture
# Select "Engaged Mode" when prompted (recommended for first time)
/architect

# 3. Generate project plan
# Select "Engaged Mode" when prompted (recommended for first time)
/bootstrap

# 4. Verify everything is ready
/plan status

# 5. Start autonomous execution
/coord continue
```

**What each command does:**

| Command | Duration | Output |
|---------|----------|--------|
| `/foundations init` | 2-5 min | `.context/structured/*.yaml` files |
| `/architect` | 10-15 min | `architecture.md` (~400 lines) |
| `/bootstrap` | 1-5 min | `project-plan.md` with phased tasks |
| `/coord continue` | Hours-Days | Autonomous development |

### Path B: Standalone (No BOS-AI)

Create a simple vision document:

```bash
# Create vision.md with your product idea
cat > vision.md << 'EOF'
# My Product

## What I'm Building
A SaaS application that helps [target users] to [solve problem].

## Key Features
1. User authentication (email, OAuth)
2. Dashboard with analytics
3. Subscription billing

## Tech Preferences
- Next.js with TypeScript
- Supabase for backend
- Tailwind CSS for styling
EOF
```

Then initialize:

```bash
# Option 1: Full project setup
/coord dev-setup vision.md

# Option 2: Jump straight to MVP
/coord mvp vision.md
```

### Path C: Existing Codebase

Adding AGENT-11 to an existing project:

```bash
# Analyze existing project and create documentation
/coord dev-alignment
```

This will:
- Scan your codebase structure
- Identify technologies used
- Create `architecture.md` documenting current state
- Set up tracking files (`project-plan.md`, `progress.md`)

---

## Quick Reference

### Essential Commands After Setup

| Command | Purpose |
|---------|---------|
| `/plan status` | Check current progress |
| `/coord continue` | Resume autonomous execution |
| `/foundations refresh` | Re-process changed docs |
| `/architect --mode engaged` | Redesign architecture |

### Agent Direct Access

```bash
@strategist What features should we prioritize?
@architect Review this database schema
@developer Implement user authentication
@tester Create tests for the login flow
```

### Common Issues

**"Command not found" after install:**
- Restart Claude Code: `/exit` then `claude`

**GitHub CLI not authenticated:**
- Run: `gh auth login`
- Follow browser authentication flow

**BOS-AI docs not found:**
- Check path: `ls documents/foundations/`
- Files should be `.md` extension

**Foundation extraction failed:**
- Ensure docs are valid Markdown
- Run: `/foundations status` for diagnostics

---

## Next Steps

After setup is complete:

1. **Review the plan**: `/plan status` to see what's planned
2. **Start development**: `/coord continue` for autonomous execution
3. **Check progress**: `cat project-plan.md` to see task status
4. **Get help**: `@coordinator What should I focus on?`

---

## Related Guides

- [Essential Setup Guide](essential-setup.md) - MCP configuration, advanced setup
- [Common Workflows Guide](common-workflows.md) - Mission patterns and examples
- [Troubleshooting Guide](troubleshooting.md) - Problem resolution
- [BOS-AI Integration](../features/bos-ai-integration.md) - Complete BOS-AI workflow

---

*Last updated: January 2025*
