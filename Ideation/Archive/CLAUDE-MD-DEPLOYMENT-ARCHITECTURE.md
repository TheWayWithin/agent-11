# CLAUDE.md Deployment Architecture

## The Problem

When a library project (like BOS-AI or AGENT-11) uses another framework for development, there's a conflict with CLAUDE.md files:

### Scenario: BOS-AI uses AGENT-11 for development

```
BOS-AI Repo (BEFORE - Problematic)
├── .claude/CLAUDE.md     ← AGENT-11 dev instructions (OVERWRITES on AGENT-11 update)
└── /CLAUDE.md            ← BOS-AI user docs (deploys to users)
```

**The Problem:**
1. `.claude/CLAUDE.md` contains development instructions
2. If AGENT-11 is redeployed/updated, it overwrites `.claude/CLAUDE.md`
3. Development instructions and personal preferences are lost
4. Same problem exists for user projects using BOS-AI

### The Conflict Chain

```
AGENT-11 deploys to → BOS-AI/.claude/CLAUDE.md (overwrites dev instructions)
BOS-AI deploys to   → User/.claude/CLAUDE.md (overwrites user preferences)
```

---

## The Solution

**Separate deployable content from project-specific content.**

### Architecture

```
Library Repo (AFTER - Fixed)
├── /library/
│   └── CLAUDE.md         ← DEPLOYABLE content (goes to target .claude/CLAUDE.md)
│
├── /.claude/
│   └── CLAUDE.md         ← Development framework instructions (safe from overwrites)
│
└── /CLAUDE.md            ← Personal preferences + project context (never deployed)
```

### Key Principles

1. **Deployable content in `/library/`**
   - The CLAUDE.md that gets copied to target projects lives here
   - Clearly separated from development environment

2. **Development instructions in `/.claude/CLAUDE.md`**
   - Framework-specific (AGENT-11 or other)
   - Not touched during deployment TO this repo
   - Only updated when framework is updated

3. **Personal/project preferences in root `/CLAUDE.md`**
   - Project-specific context and preferences
   - Not deployed anywhere
   - Safe space for customization

### Deployment Flow

```
Source Repo                          Target Project
───────────                          ──────────────
/library/CLAUDE.md    ────────►      .claude/CLAUDE.md

/CLAUDE.md (root)     NOT DEPLOYED   (target creates own if needed)
.claude/CLAUDE.md     NOT DEPLOYED   (target has own framework)
```

---

## Implementation Steps

### For BOS-AI (Already Done)

1. Created `/library/` folder
2. Moved deployable CLAUDE.md to `/library/CLAUDE.md`
3. Updated `deploy-bos-ai.sh`:
   - Check for `library/CLAUDE.md` instead of `CLAUDE.md`
   - Copy from `library/CLAUDE.md` to target `.claude/CLAUDE.md`
4. Updated `install.sh`:
   - Download from `library/CLAUDE.md` URL
5. Root `/CLAUDE.md` now contains project context + personal preferences

### For AGENT-11 (DONE - 2025-01-10)

1. ✅ Created `/library/` folder
2. ✅ Moved deployable `CLAUDE.md` to `/library/CLAUDE.md`
3. ✅ Updated `install.sh` to deploy `library/CLAUDE.md` → user's `.claude/CLAUDE.md`
4. ✅ Updated `update-claude-md.sh` to target `.claude/CLAUDE.md`
5. ✅ Created new root `/CLAUDE.md` for Jamie's personal preferences
6. ✅ Updated all documentation (README, Integration Guide, Safety docs)

### Script Changes Required

**deploy script:**
```bash
# BEFORE
cp CLAUDE.md .claude/CLAUDE.md

# AFTER
cp library/CLAUDE.md .claude/CLAUDE.md
```

**install script:**
```bash
# BEFORE
download_file "$GITHUB_RAW_BASE/CLAUDE.md" ".claude/CLAUDE.md"

# AFTER
download_file "$GITHUB_RAW_BASE/library/CLAUDE.md" ".claude/CLAUDE.md"
```

**directory check:**
```bash
# BEFORE
if [ ! -f "CLAUDE.md" ]; then

# AFTER
if [ ! -f "library/CLAUDE.md" ]; then
```

---

## Benefits

1. **No overwrites**: Framework updates don't wipe dev instructions
2. **Personal preferences safe**: Root CLAUDE.md is never touched by deployments
3. **Clear separation**: Obvious what deploys vs what's local
4. **Consistent pattern**: Both BOS-AI and AGENT-11 follow same structure
5. **User projects safe**: Their root CLAUDE.md preserved across BOS-AI updates

---

## File Purposes Summary

| File | Purpose | Deployed? |
|------|---------|-----------|
| `/library/CLAUDE.md` | Content for target projects | ✅ Yes → target `.claude/CLAUDE.md` |
| `/.claude/CLAUDE.md` | Dev framework instructions | ❌ No |
| `/CLAUDE.md` | Personal preferences, project context | ❌ No |

---

## Related Files

- `deployment/scripts/deploy-bos-ai.sh` - Local deployment
- `deployment/scripts/install.sh` - Remote installation
- `.claude/CLAUDE.md` - AGENT-11 development instructions
