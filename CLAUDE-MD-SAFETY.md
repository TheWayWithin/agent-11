# CLAUDE.md Safety Implementation

## Two-File Architecture

AGENT-11 uses a **two-file architecture** that completely separates your personal preferences from library instructions:

```
Your Project
├── CLAUDE.md              ← Your personal preferences (NEVER touched by AGENT-11)
└── .claude/
    └── CLAUDE.md          ← AGENT-11 library instructions (managed by installer)
```

## How It Works

### Your Root CLAUDE.md is NEVER Touched

| Action | Root `/CLAUDE.md` | `.claude/CLAUDE.md` |
|--------|-------------------|---------------------|
| Fresh install | Not modified | Created from library |
| Update/reinstall | Not modified | Updated from library |
| Uninstall | Not modified | Can be removed |

### Deployment Flow

```
AGENT-11 Repository                    Your Project
═══════════════════                    ════════════

library/CLAUDE.md  ──── deploys to ──► .claude/CLAUDE.md

                        NEVER touches ► /CLAUDE.md (your file)
```

## Safety Features

### 1. Complete Separation
- Your `/CLAUDE.md` contains personal preferences
- AGENT-11's `.claude/CLAUDE.md` contains library instructions
- These are completely independent files

### 2. Automatic Backups
When updating `.claude/CLAUDE.md`:
- Existing file is backed up to `.claude/CLAUDE.md.backup-[timestamp]`
- Easy rollback if needed

### 3. No Merge Required
- Claude Code reads both files automatically
- Your preferences in `/CLAUDE.md` take precedence
- No manual integration needed

## Implementation Details

### Code Location
`project/deployment/scripts/install.sh` - `install_claude_md()` function

### Key Behaviors

```bash
# Destination is ALWAYS .claude/CLAUDE.md
local dest_file="$CLAUDE_DIR/CLAUDE.md"

# Backup existing before overwriting
if [[ -f "$dest_file" ]]; then
    cp "$dest_file" "$backup_file"
fi

# Deploy from library
cp "$PROJECT_ROOT/library/CLAUDE.md" "$dest_file"

# Root /CLAUDE.md is NEVER referenced or modified
```

## File Purposes

| File | Purpose | Who Manages |
|------|---------|-------------|
| `/CLAUDE.md` | Personal preferences, communication style, project context | **You** |
| `/.claude/CLAUDE.md` | AGENT-11 protocols, agent instructions, mission system | **AGENT-11 installer** |

## Rollback

If you need to restore a previous version:

```bash
# List available backups
ls .claude/CLAUDE.md.backup-*

# Restore specific backup
cp .claude/CLAUDE.md.backup-20251010_123456 .claude/CLAUDE.md
```

## Migration from Old Architecture

If you have an old `CLAUDE-AGENT11-TEMPLATE.md` file:
1. It can be safely deleted
2. AGENT-11 instructions now live in `.claude/CLAUDE.md`
3. Run the installer to get the new architecture

```bash
# Remove old template (no longer used)
rm CLAUDE-AGENT11-TEMPLATE.md

# Run installer to set up new architecture
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/install.sh | bash
```

---

**Key Principle**: Your `/CLAUDE.md` is yours. AGENT-11 only manages `.claude/CLAUDE.md`.
