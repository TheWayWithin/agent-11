#!/usr/bin/env bash
#
# migrate-v5-to-v6.sh — migrate an AGENT-11 v5.x install to v6.0
#
# What this does:
#   1. Detect v5.x markers (handoff-notes.md, .mcp-profiles/, etc.).
#   2. Refuse if the project isn't an AGENT-11 install OR is already v6.0.
#   3. Confirm with the user before any destructive op.
#   4. Backup everything that will change to .claude/backups/v5-to-v6-YYYYMMDD-HHMMSS/.
#   5. Fold handoff-notes.md into agent-context.md (Sprint 4e).
#   6. Retire .mcp-profiles/ and obsolete mcp/dynamic-mcp.json (Sprint 4f).
#   7. Print a summary and next-steps.
#
# What this does NOT do:
#   - Reinstall library files. Run install.sh after migration to deploy v6.0
#     CLAUDE.md, agents, commands, missions, templates, skills.
#   - Modify .mcp.json (the server registry). That stays as-is.
#   - Modify any code files in your project.
#   - Modify the root CLAUDE.md (your personal preferences).
#
# Usage:
#   bash migrate-v5-to-v6.sh            # interactive, with confirmation
#   bash migrate-v5-to-v6.sh --dry-run  # show what would change, do nothing
#   bash migrate-v5-to-v6.sh --yes      # skip confirmation (for automation/CI)
#
# Or via curl:
#   bash <(curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/migrate-v5-to-v6.sh)
#

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log()     { echo -e "${BLUE}[INFO]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }

PROJECT_DIR="$(pwd)"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$PROJECT_DIR/.claude/backups/v5-to-v6-$TIMESTAMP"

# Sprint 5a T5: detect prior migration backup so we can distinguish
# "already on v6 (was always on v6)" from "already on v6 (we migrated last time)".
LATEST_PRIOR_BACKUP=""
if [[ -d "$PROJECT_DIR/.claude/backups" ]]; then
    LATEST_PRIOR_BACKUP=$(find "$PROJECT_DIR/.claude/backups" -maxdepth 1 -type d -name "v5-to-v6-*" 2>/dev/null | sort | tail -1)
fi

# Track what work actually got done — populated as steps run.
ACTIONS_PERFORMED=()

DRY_RUN=false
AUTO_CONFIRM=false
for arg in "$@"; do
    case "$arg" in
        --dry-run|-n)  DRY_RUN=true ;;
        --yes|-y)      AUTO_CONFIRM=true ;;
        --help|-h)
            sed -n '2,/^$/p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
    esac
done

# Run a destructive op, or just log it in dry-run mode.
run_or_log() {
    local description="$1"
    shift
    if $DRY_RUN; then
        log "  (dry run) Would: $description"
    else
        log "  $description"
        "$@"
    fi
}

# ---------- Detection -------------------------------------------------------

detect_agent11() {
    if [[ -f "$PROJECT_DIR/.claude/CLAUDE.md" ]] || [[ -f "$PROJECT_DIR/.claude/agents/coordinator.md" ]]; then
        return 0
    fi
    return 1
}

detect_v5_markers() {
    local found=()
    [[ -f "$PROJECT_DIR/handoff-notes.md" ]] && found+=("handoff-notes.md")
    [[ -d "$PROJECT_DIR/.mcp-profiles" ]] && found+=(".mcp-profiles/")
    [[ -f "$PROJECT_DIR/mcp/dynamic-mcp.json" ]] && found+=("mcp/dynamic-mcp.json")
    [[ -f "$PROJECT_DIR/templates/handoff-notes-template.md" ]] && found+=("templates/handoff-notes-template.md")

    if [[ ${#found[@]} -eq 0 ]]; then
        return 1
    fi

    printf '%s\n' "${found[@]}"
    return 0
}

# ---------- Pre-flight checks -----------------------------------------------

echo
echo "AGENT-11 v5.x → v6.0 migration"
echo "==============================="
echo "Working directory: $PROJECT_DIR"
$DRY_RUN && echo -e "${YELLOW}DRY RUN MODE — no changes will be made${NC}"
echo

if ! detect_agent11; then
    error "No AGENT-11 install detected at $PROJECT_DIR"
    error "Looking for .claude/CLAUDE.md or .claude/agents/coordinator.md — neither found."
    error "Run install.sh first to install AGENT-11, then run this migration."
    exit 1
fi

log "AGENT-11 install detected."

if ! V5_MARKERS=$(detect_v5_markers); then
    # Sprint 5a T5: distinguish "already on v6 (we migrated previously)" from
    # "already on v6 (was always v6)" — the previous behaviour gave identical
    # output for both, which left users unsure whether their migration ran.
    if [[ -n "$LATEST_PRIOR_BACKUP" ]]; then
        success "No v5.x markers detected. Migration was completed previously."
        success "Most recent migration backup: $LATEST_PRIOR_BACKUP"
        log "Already on v6.0 — no further action needed."
    else
        success "No v5.x markers detected. Already on v6.0 — no migration needed."
    fi
    exit 0
fi

# Sprint 5a T5: if markers ARE present but a prior backup exists, this is an
# idempotent re-run after a partial migration. Flag it so the user knows what
# they're seeing.
if [[ -n "$LATEST_PRIOR_BACKUP" ]]; then
    warn "Prior migration backup found: $LATEST_PRIOR_BACKUP"
    warn "v5 markers still present — completing the remaining migration steps."
    echo
fi

echo
log "v5.x markers found:"
echo "$V5_MARKERS" | sed 's/^/  - /'
echo

if ! $DRY_RUN; then
    if $AUTO_CONFIRM; then
        log "Auto-confirmed via --yes flag."
    elif [[ -t 0 ]]; then
        # Interactive — stdin is the user's terminal
        read -r -p "Continue with v5.x → v6.0 migration? [y/N] " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            log "Migration cancelled."
            exit 0
        fi
    elif [[ -r /dev/tty ]]; then
        # Non-interactive stdin (e.g., piped) but TTY is available — prompt via TTY
        read -r -p "Continue with v5.x → v6.0 migration? [y/N] " confirm < /dev/tty
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            log "Migration cancelled."
            exit 0
        fi
    else
        error "No interactive terminal available. Use --yes to confirm non-interactively, or --dry-run to preview."
        exit 1
    fi
fi

# ---------- Backup ----------------------------------------------------------

if $DRY_RUN; then
    log "(dry run) Would create backup at: $BACKUP_DIR"
else
    log "Creating backup at $BACKUP_DIR"
    if ! mkdir -p "$BACKUP_DIR" 2>/dev/null; then
        error "Failed to create backup directory: $BACKUP_DIR"
        error "Check filesystem permissions and free space."
        exit 1
    fi
fi

backup_if_exists() {
    local src="$1"
    if [[ -e "$src" ]]; then
        if $DRY_RUN; then
            log "  (dry run) Would back up: $src"
        else
            cp -r "$src" "$BACKUP_DIR/" || warn "Could not back up $src"
            log "  Backed up: $src"
        fi
    fi
}

echo
log "Backing up files that will change..."
backup_if_exists "$PROJECT_DIR/handoff-notes.md"
backup_if_exists "$PROJECT_DIR/agent-context.md"
backup_if_exists "$PROJECT_DIR/.mcp-profiles"
backup_if_exists "$PROJECT_DIR/mcp/dynamic-mcp.json"
backup_if_exists "$PROJECT_DIR/templates/handoff-notes-template.md"
backup_if_exists "$PROJECT_DIR/.claude/CLAUDE.md"
backup_if_exists "$PROJECT_DIR/.claude/settings.json"

if ! $DRY_RUN; then
    success "Backup complete."
fi

# ---------- Migrate context (Sprint 4e) ------------------------------------

if [[ -f "$PROJECT_DIR/handoff-notes.md" ]]; then
    echo
    log "Folding handoff-notes.md into agent-context.md (Sprint 4e)..."

    if [[ -f "$PROJECT_DIR/agent-context.md" ]]; then
        if $DRY_RUN; then
            log "  (dry run) Would append handoff-notes.md content to agent-context.md"
        else
            {
                echo
                echo "---"
                echo
                echo "## Migrated from handoff-notes.md ($(date +%Y-%m-%d))"
                echo
                cat "$PROJECT_DIR/handoff-notes.md"
            } >> "$PROJECT_DIR/agent-context.md"
            log "  Appended handoff-notes.md content to agent-context.md"
        fi
    else
        if $DRY_RUN; then
            log "  (dry run) Would create agent-context.md from handoff-notes.md (no agent-context.md present)"
        else
            cp "$PROJECT_DIR/handoff-notes.md" "$PROJECT_DIR/agent-context.md"
            log "  Created agent-context.md from handoff-notes.md content"
        fi
    fi

    run_or_log "Remove handoff-notes.md (backup is in $BACKUP_DIR)" \
        rm -- "$PROJECT_DIR/handoff-notes.md"
    $DRY_RUN || ACTIONS_PERFORMED+=("Folded handoff-notes.md into agent-context.md")
fi

# ---------- Migrate MCP (Sprint 4f) ----------------------------------------

if [[ -d "$PROJECT_DIR/.mcp-profiles" ]]; then
    echo
    log "Retiring .mcp-profiles/ (Sprint 4f — profile-switching system retired)..."
    run_or_log "Remove .mcp-profiles/ (backup is in $BACKUP_DIR)" \
        rm -rf -- "$PROJECT_DIR/.mcp-profiles"
    $DRY_RUN || ACTIONS_PERFORMED+=("Retired .mcp-profiles/")
fi

if [[ -f "$PROJECT_DIR/mcp/dynamic-mcp.json" ]]; then
    echo
    log "Removing obsolete mcp/dynamic-mcp.json (Sprint 4f finding — wrong schema for Claude Code)..."
    run_or_log "Remove mcp/dynamic-mcp.json (backup is in $BACKUP_DIR)" \
        rm -- "$PROJECT_DIR/mcp/dynamic-mcp.json"
    if ! $DRY_RUN; then
        rmdir "$PROJECT_DIR/mcp" 2>/dev/null || true
        ACTIONS_PERFORMED+=("Removed obsolete mcp/dynamic-mcp.json")
    fi
fi

if [[ -f "$PROJECT_DIR/templates/handoff-notes-template.md" ]]; then
    echo
    log "Retiring templates/handoff-notes-template.md (Sprint 4e)..."
    run_or_log "Remove templates/handoff-notes-template.md (backup is in $BACKUP_DIR)" \
        rm -- "$PROJECT_DIR/templates/handoff-notes-template.md"
    $DRY_RUN || ACTIONS_PERFORMED+=("Retired templates/handoff-notes-template.md")
fi

# ENABLE_TOOL_SEARCH check
SETTINGS_FILE="$PROJECT_DIR/.claude/settings.json"
echo
log "Checking .claude/settings.json for ENABLE_TOOL_SEARCH (Sprint 4f)..."
if [[ -f "$SETTINGS_FILE" ]]; then
    if grep -q "ENABLE_TOOL_SEARCH" "$SETTINGS_FILE"; then
        log "  Already has ENABLE_TOOL_SEARCH — leaving alone."
    else
        warn "  Existing .claude/settings.json found WITHOUT ENABLE_TOOL_SEARCH."
        warn "  Manual merge recommended. Add this to the top level of settings.json:"
        warn '    "env": { "ENABLE_TOOL_SEARCH": "auto" }'
        warn "  Reference: library/settings.json.template in the AGENT-11 repo."
        warn "  Backup of current settings.json is at $BACKUP_DIR"
    fi
else
    log "  No .claude/settings.json yet. Run install.sh after migration to deploy v6.0 defaults"
    log "  (which include ENABLE_TOOL_SEARCH=auto plus advisory hooks)."
fi

# ---------- Summary --------------------------------------------------------

echo
echo "==============================="
if $DRY_RUN; then
    echo -e "${YELLOW}DRY RUN COMPLETE — no changes were made${NC}"
    echo "Re-run without --dry-run to perform the migration."
else
    # Sprint 5a T5: itemise what was actually done so the user can tell a real
    # run apart from a no-op re-run.
    if [[ ${#ACTIONS_PERFORMED[@]} -eq 0 ]]; then
        success "v5.x → v6.0 migration complete (no changes needed — markers already cleared)"
    else
        success "v5.x → v6.0 migration complete"
        echo
        echo "Performed:"
        for a in "${ACTIONS_PERFORMED[@]}"; do
            echo "  - $a"
        done
    fi
fi
echo "==============================="
echo

if ! $DRY_RUN; then
    echo "Backup: $BACKUP_DIR"
    echo
fi

echo "Next steps:"
echo "  1. Run install.sh to deploy v6.0 library files (CLAUDE.md, agents, commands,"
echo "     constitution, settings.json hooks):"
echo "     curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/install.sh | bash"
echo
echo "  2. Restart Claude Code so new settings.json hooks take effect."
echo
echo "  3. Note: progress.md is now write-only by default. The coordinator appends"
echo "     to it (issues, fixes, deliverables) but doesn't read it at session start."
echo
if ! $DRY_RUN; then
    echo "Rollback: bash <(curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/restore-pre-upgrade.sh) --latest"
    echo "  Or manually: copy files from $BACKUP_DIR back to project root."
    echo "  See: docs/UPGRADE.md"
    echo
fi
