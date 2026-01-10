# CLAUDE.md Architecture Guide

## Overview

AGENT-11 uses a **two-file architecture** that keeps your personal preferences separate from library instructions:

```
Your Project
├── CLAUDE.md              ← Your personal preferences (NEVER touched)
└── .claude/
    └── CLAUDE.md          ← AGENT-11 library instructions (managed by installer)
```

## How It Works

### During Installation

```
AGENT-11 Repository                    Your Project
═══════════════════                    ════════════

library/CLAUDE.md  ──── deploys to ──► .claude/CLAUDE.md
                                       (AGENT-11 instructions)

                        NOT touched ──► /CLAUDE.md
                                       (Your personal preferences)
```

**What happens:**
1. AGENT-11 installs its library instructions to `.claude/CLAUDE.md`
2. Your root `/CLAUDE.md` is **never modified or overwritten**
3. If `.claude/CLAUDE.md` exists, it's backed up before updating

### During Updates

```bash
# Run the installer again to update
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/install.sh | bash
```

**What happens:**
1. `.claude/CLAUDE.md` is backed up to `.claude/CLAUDE.md.backup-[timestamp]`
2. Latest AGENT-11 instructions are installed to `.claude/CLAUDE.md`
3. Your root `/CLAUDE.md` remains untouched

## File Purposes

| File | Purpose | Managed By |
|------|---------|------------|
| `/CLAUDE.md` | Your personal preferences, communication style, project-specific context | **You** |
| `/.claude/CLAUDE.md` | AGENT-11 library instructions, agent protocols, mission system | **AGENT-11 installer** |

## Your Personal CLAUDE.md

Your root `/CLAUDE.md` is the place for:

- **Communication preferences** - How you want Claude to interact with you
- **Project context** - Specific information about your project
- **Custom instructions** - Any personal guidelines for Claude
- **Working style** - Your preferences for code style, documentation, etc.

**Example:**
```markdown
# My Project

## How to Work With Me
- Keep explanations brief
- Give me 2-3 options when deciding
- Always explain the "why"

## Project Context
This is a SaaS for small businesses...

## Code Style
- Use TypeScript
- Prefer functional components
- Always add error handling
```

## AGENT-11 Library CLAUDE.md

The `.claude/CLAUDE.md` contains:

- **Agent protocols** - How the 11 specialists work together
- **Mission system** - `/coord` command workflows
- **Context preservation** - Zero context loss protocols
- **MCP integration** - Tool usage guidelines
- **Security principles** - Development best practices

**You don't need to edit this file** - it's managed by the AGENT-11 installer.

## Common Questions

### Q: Will installing AGENT-11 overwrite my CLAUDE.md?

**No.** Your root `/CLAUDE.md` is never touched. AGENT-11 only writes to `.claude/CLAUDE.md`.

### Q: What if I already have a .claude/CLAUDE.md?

It will be backed up to `.claude/CLAUDE.md.backup-[timestamp]` before updating.

### Q: Do I need to merge anything?

**No.** The two files serve different purposes:
- Your `/CLAUDE.md` = Personal preferences
- `.claude/CLAUDE.md` = Library instructions

Claude Code reads both files automatically.

### Q: How do I customize AGENT-11 behavior?

Add customizations to your root `/CLAUDE.md`. For example:
```markdown
## AGENT-11 Customizations
- Always use @tester before marking tasks complete
- Prefer Sonnet model for routine tasks
```

### Q: What if I want to disable an AGENT-11 feature?

Add an override in your root `/CLAUDE.md`:
```markdown
## Overrides
- Skip design reviews for backend-only changes
- Don't create progress.md for quick fixes
```

## Troubleshooting

### AGENT-11 features not working

```bash
# Verify .claude/CLAUDE.md exists
ls -la .claude/CLAUDE.md

# Verify agents installed
ls .claude/agents/

# Restart Claude Code
/exit
claude
```

### Personal preferences not being followed

```bash
# Verify root CLAUDE.md exists
ls -la CLAUDE.md

# Check file contents
cat CLAUDE.md

# Make sure it's not empty
wc -l CLAUDE.md
```

### Need to restore backup

```bash
# List backups
ls .claude/CLAUDE.md.backup-*

# Restore specific backup
cp .claude/CLAUDE.md.backup-20251010_123456 .claude/CLAUDE.md
```

## Best Practices

### ✅ Do

1. **Keep personal preferences in root `/CLAUDE.md`**
2. **Let AGENT-11 manage `.claude/CLAUDE.md`**
3. **Add project-specific context to your `/CLAUDE.md`**
4. **Run installer to update AGENT-11 features**

### ❌ Don't

1. **Don't edit `.claude/CLAUDE.md` directly** - changes will be overwritten on update
2. **Don't copy AGENT-11 content to root `/CLAUDE.md`** - it's automatically loaded from `.claude/`
3. **Don't delete `.claude/CLAUDE.md`** - AGENT-11 features won't work

## Summary

| Action | Where |
|--------|-------|
| Add personal preferences | `/CLAUDE.md` |
| Add project context | `/CLAUDE.md` |
| Customize Claude behavior | `/CLAUDE.md` |
| Update AGENT-11 | Run installer (updates `.claude/CLAUDE.md`) |
| Override AGENT-11 defaults | `/CLAUDE.md` |

---

**The key principle:** Your `/CLAUDE.md` is yours. AGENT-11 only manages `.claude/CLAUDE.md`.
