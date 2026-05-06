#!/usr/bin/env bash
#
# restore-pre-upgrade.sh — restore files from a v5→v6 migration backup.
#
# Sprint 5a, T7. Companion to migrate-v5-to-v6.sh and install.sh --upgrade.
#
# What this does:
#   - Lists v5→v6 migration backups under .claude/backups/v5-to-v6-*/
#   - Lets you pick one (or pass --backup <path>, or --latest)
#   - Confirms before any change
#   - Restores known v5 files back to their original locations
#   - Optionally restores settings.json from a settings.json.backup-* file
#
# What this does NOT do:
#   - Recover files modified after the migration (newer state wins)
#   - Recover uncommitted edits to deleted files (only what was backed up)
#   - Re-deploy the v5 library — install.sh handles that
#
# Usage:
#   bash restore-pre-upgrade.sh                 Interactive: pick a backup
#   bash restore-pre-upgrade.sh --list          List available backups
#   bash restore-pre-upgrade.sh --latest        Restore most recent migration backup
#   bash restore-pre-upgrade.sh --backup <path> Restore a specific backup directory
#   bash restore-pre-upgrade.sh --settings <path>  Restore a settings.json backup
#   bash restore-pre-upgrade.sh --yes           Skip confirmation
#

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
log()     { echo -e "${BLUE}[INFO]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }

PROJECT_DIR="$(pwd)"
BACKUPS_DIR="$PROJECT_DIR/.claude/backups"

LIST_ONLY=false
USE_LATEST=false
EXPLICIT_BACKUP=""
SETTINGS_BACKUP=""
AUTO_CONFIRM=false

show_help() {
    sed -n '2,/^$/p' "$0" | sed 's/^# \{0,1\}//'
}

# ---------- Arg parsing ----------
while [[ $# -gt 0 ]]; do
    case "$1" in
        --list)     LIST_ONLY=true; shift ;;
        --latest)   USE_LATEST=true; shift ;;
        --backup)   EXPLICIT_BACKUP="${2:-}"; shift 2 ;;
        --settings) SETTINGS_BACKUP="${2:-}"; shift 2 ;;
        --yes|-y)   AUTO_CONFIRM=true; shift ;;
        --help|-h)  show_help; exit 0 ;;
        *)          error "Unknown arg: $1"; show_help; exit 1 ;;
    esac
done

# ---------- Discovery ----------
list_v5_backups() {
    [[ -d "$BACKUPS_DIR" ]] || return 0
    find "$BACKUPS_DIR" -maxdepth 1 -type d -name "v5-to-v6-*" 2>/dev/null | sort
}

list_settings_backups() {
    find "$PROJECT_DIR/.claude" -maxdepth 1 -type f -name "settings.json.backup-*" 2>/dev/null | sort
}

# ---------- List mode ----------
if $LIST_ONLY; then
    echo "Project: $PROJECT_DIR"
    echo
    echo "v5→v6 migration backups (from migrate-v5-to-v6.sh):"
    local_v5_backups="$(list_v5_backups)"
    if [[ -z "$local_v5_backups" ]]; then
        echo "  (none)"
    else
        echo "$local_v5_backups" | sed 's/^/  /'
    fi
    echo
    echo "settings.json backups (from install.sh):"
    local_settings_backups="$(list_settings_backups)"
    if [[ -z "$local_settings_backups" ]]; then
        echo "  (none)"
    else
        echo "$local_settings_backups" | sed 's/^/  /'
    fi
    exit 0
fi

# ---------- Settings-only mode ----------
if [[ -n "$SETTINGS_BACKUP" ]]; then
    if [[ ! -f "$SETTINGS_BACKUP" ]]; then
        error "Settings backup not found: $SETTINGS_BACKUP"
        exit 1
    fi
    echo
    warn "About to restore settings.json from: $SETTINGS_BACKUP"
    warn "Current .claude/settings.json (if any) will be overwritten."
    if ! $AUTO_CONFIRM; then
        if [[ -t 0 ]]; then
            read -r -p "Continue? [y/N] " confirm
        elif [[ -r /dev/tty ]]; then
            read -r -p "Continue? [y/N] " confirm < /dev/tty
        else
            error "No interactive terminal. Use --yes to confirm non-interactively."
            exit 1
        fi
        [[ ! "$confirm" =~ ^[Yy]$ ]] && { log "Aborted."; exit 0; }
    fi
    cp "$SETTINGS_BACKUP" "$PROJECT_DIR/.claude/settings.json"
    success "Restored .claude/settings.json from $SETTINGS_BACKUP"
    exit 0
fi

# ---------- Pick a v5 backup ----------
SELECTED=""
if [[ -n "$EXPLICIT_BACKUP" ]]; then
    SELECTED="$EXPLICIT_BACKUP"
elif $USE_LATEST; then
    SELECTED="$(list_v5_backups | tail -1)"
    if [[ -z "$SELECTED" ]]; then
        error "No v5→v6 migration backups found in $BACKUPS_DIR"
        exit 1
    fi
else
    BACKUPS=()
    while IFS= read -r b; do
        [[ -n "$b" ]] && BACKUPS+=("$b")
    done < <(list_v5_backups)
    if [[ ${#BACKUPS[@]} -eq 0 ]]; then
        error "No v5→v6 migration backups found in $BACKUPS_DIR"
        error "Run \`$0 --list\` to see all backups (including settings.json variants)."
        exit 1
    fi
    echo "Available v5→v6 migration backups:"
    for i in "${!BACKUPS[@]}"; do
        echo "  $((i+1))) ${BACKUPS[$i]}"
    done
    echo
    if $AUTO_CONFIRM; then
        SELECTED="${BACKUPS[$((${#BACKUPS[@]} - 1))]}"
        log "Auto-selected most recent: $SELECTED"
    else
        if [[ -t 0 ]]; then
            read -r -p "Enter number (or q to quit): " choice
        elif [[ -r /dev/tty ]]; then
            read -r -p "Enter number (or q to quit): " choice < /dev/tty
        else
            error "No interactive terminal. Use --latest, --backup <path>, or --yes."
            exit 1
        fi
        [[ "$choice" == "q" || "$choice" == "Q" ]] && { log "Aborted."; exit 0; }
        if ! [[ "$choice" =~ ^[0-9]+$ ]] || [[ "$choice" -lt 1 ]] || [[ "$choice" -gt ${#BACKUPS[@]} ]]; then
            error "Invalid selection: $choice"
            exit 1
        fi
        SELECTED="${BACKUPS[$((choice - 1))]}"
    fi
fi

if [[ ! -d "$SELECTED" ]]; then
    error "Backup directory not found: $SELECTED"
    exit 1
fi

# ---------- Confirm + restore ----------
echo
echo "Restore plan"
echo "============"
echo "From: $SELECTED"
echo "To:   $PROJECT_DIR"
echo
echo "Will restore (if present in backup):"
echo "  handoff-notes.md             → ./handoff-notes.md"
echo "  agent-context.md             → ./agent-context.md  (overwrites current)"
echo "  .mcp-profiles/               → ./.mcp-profiles/"
echo "  dynamic-mcp.json             → ./mcp/dynamic-mcp.json"
echo "  handoff-notes-template.md    → ./templates/handoff-notes-template.md"
echo "  CLAUDE.md                    → ./.claude/CLAUDE.md"
echo "  settings.json                → ./.claude/settings.json"
echo
warn "This DOES NOT recover:"
warn "  - Files added or modified after the migration"
warn "  - Uncommitted edits to files that were later deleted"
warn "  - Library files deployed by install.sh (those need re-install)"
echo

if ! $AUTO_CONFIRM; then
    if [[ -t 0 ]]; then
        read -r -p "Continue with restore? [y/N] " confirm
    elif [[ -r /dev/tty ]]; then
        read -r -p "Continue with restore? [y/N] " confirm < /dev/tty
    else
        error "No interactive terminal. Use --yes to confirm non-interactively."
        exit 1
    fi
    [[ ! "$confirm" =~ ^[Yy]$ ]] && { log "Aborted."; exit 0; }
fi

echo
log "Restoring..."
RESTORED=()

# Mapping: backup-name → restore-target. Only restore if the backup contains it.
restore_if_present() {
    local backup_name="$1"
    local target_path="$2"
    local src="$SELECTED/$backup_name"
    if [[ -e "$src" ]]; then
        mkdir -p "$(dirname "$target_path")"
        if [[ -d "$src" ]]; then
            rm -rf "$target_path"
            cp -r "$src" "$target_path"
        else
            cp "$src" "$target_path"
        fi
        log "  restored: $target_path"
        RESTORED+=("$target_path")
    fi
}

restore_if_present "handoff-notes.md"             "$PROJECT_DIR/handoff-notes.md"
restore_if_present "agent-context.md"             "$PROJECT_DIR/agent-context.md"
restore_if_present ".mcp-profiles"                "$PROJECT_DIR/.mcp-profiles"
restore_if_present "dynamic-mcp.json"             "$PROJECT_DIR/mcp/dynamic-mcp.json"
restore_if_present "handoff-notes-template.md"    "$PROJECT_DIR/templates/handoff-notes-template.md"
restore_if_present "CLAUDE.md"                    "$PROJECT_DIR/.claude/CLAUDE.md"
restore_if_present "settings.json"                "$PROJECT_DIR/.claude/settings.json"

echo
if [[ ${#RESTORED[@]} -eq 0 ]]; then
    warn "Backup directory was empty — nothing to restore."
    exit 0
fi
success "Restore complete. Files restored:"
for r in "${RESTORED[@]}"; do
    echo "  - $r"
done
echo
echo "Next steps:"
echo "  - Review restored files."
echo "  - To return to v6, re-run: bash install.sh --upgrade"
echo "  - The backup directory is preserved at: $SELECTED"
