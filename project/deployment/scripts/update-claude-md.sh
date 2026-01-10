#!/bin/bash
# AGENT-11 CLAUDE.md Update Script
# Updates user's CLAUDE.md with file persistence bug safeguards
# Version: 1.0 (2025-11-12)
#
# Usage: ./update-claude-md.sh [--auto|--interactive|--dry-run]

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
TEMPLATE_FILE="$PROJECT_ROOT/library/CLAUDE.md"

# Logging functions
log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

# Help text
show_help() {
    cat <<EOF
AGENT-11 CLAUDE.md Update Script

Updates your project's .claude/CLAUDE.md with critical file persistence bug safeguards.
(Note: This updates AGENT-11 library instructions, not your personal /CLAUDE.md)

Usage:
  $0 [OPTIONS]

Options:
  --auto          Automatically apply all updates (backs up first)
  --interactive   Ask for confirmation before each change (default)
  --dry-run       Show what would be changed without making changes
  --help          Show this help message

Examples:
  $0                       # Interactive mode
  $0 --dry-run            # Preview changes
  $0 --auto               # Automatic update with backup

What Gets Updated:
  1. New section: "FILE PERSISTENCE BUG & SAFEGUARDS" (~60 lines)
  2. Enhanced "Critical Requirements" with verification mandate
  3. Reference links to new troubleshooting guide

Backup:
  Automatic backup created at: CLAUDE.md.backup-YYYYMMDD_HHMMSS

Documentation:
  See CRITICAL-UPDATE-2025-11-12.md for full details

EOF
    exit 0
}

# Parse arguments
MODE="interactive"
while [[ $# -gt 0 ]]; do
    case $1 in
        --auto) MODE="auto"; shift ;;
        --interactive) MODE="interactive"; shift ;;
        --dry-run) MODE="dry-run"; shift ;;
        --help|-h) show_help ;;
        *) error "Unknown option: $1"; show_help ;;
    esac
done

# Banner
echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║     AGENT-11 CLAUDE.md Update Script v1.0 (2025-11-12)  ║"
echo "║     Critical: File Persistence Bug Safeguards            ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# Detect user's .claude/CLAUDE.md (AGENT-11 library instructions)
CLAUDE_DIR="$(pwd)/.claude"
USER_CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"

if [[ ! -f "$USER_CLAUDE_MD" ]]; then
    error "No .claude/CLAUDE.md found in current directory"
    echo ""
    echo "Please run this script from your project root directory."
    echo "If AGENT-11 is not installed, run the installer first."
    echo "Example: cd /path/to/your/project && /path/to/agent-11/project/deployment/scripts/install.sh"
    exit 1
fi

log "Found .claude/CLAUDE.md at: $USER_CLAUDE_MD"

# Check if template available (source library)
if [[ -f "$TEMPLATE_FILE" ]]; then
    log "Using AGENT-11 library template: $TEMPLATE_FILE"
    SOURCE_FILE="$TEMPLATE_FILE"
else
    error "Cannot find AGENT-11 template file"
    echo "Expected location: $TEMPLATE_FILE"
    exit 1
fi

# Check if already updated
if grep -q "FILE PERSISTENCE BUG & SAFEGUARDS" "$USER_CLAUDE_MD"; then
    warn "Your CLAUDE.md already contains FILE PERSISTENCE BUG section"
    echo ""
    read -p "Continue anyway to verify/update? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "Update cancelled"
        exit 0
    fi
fi

# Create backup
BACKUP_FILE="$USER_CLAUDE_MD.backup-$(date +%Y%m%d_%H%M%S)"
if [[ "$MODE" != "dry-run" ]]; then
    cp "$USER_CLAUDE_MD" "$BACKUP_FILE"
    success "Backup created: $BACKUP_FILE"
fi

# Extract sections from template
log "Extracting safeguards from template..."

# Section 1: FILE PERSISTENCE BUG & SAFEGUARDS
SECTION_START=$(grep -n "### ⚠️ CRITICAL: FILE PERSISTENCE BUG & SAFEGUARDS" "$SOURCE_FILE" | cut -d: -f1 | head -1)
SECTION_END=$(grep -n "### CONTEXT PRESERVATION REQUIREMENT" "$SOURCE_FILE" | cut -d: -f1 | head -1)

if [[ -z "$SECTION_START" ]] || [[ -z "$SECTION_END" ]]; then
    error "Could not find FILE PERSISTENCE BUG section in template"
    exit 1
fi

SECTION_LENGTH=$((SECTION_END - SECTION_START))
BUG_SECTION=$(sed -n "${SECTION_START},$((SECTION_END - 1))p" "$SOURCE_FILE")

log "Extracted FILE PERSISTENCE BUG section (${SECTION_LENGTH} lines)"

# Section 2: Enhanced Critical Requirements
CRIT_START=$(grep -n "### Critical Requirements" "$SOURCE_FILE" | cut -d: -f1 | head -1)
CRIT_END=$((CRIT_START + 8))  # Fixed length section
CRIT_SECTION=$(sed -n "${CRIT_START},${CRIT_END}p" "$SOURCE_FILE")

log "Extracted Enhanced Critical Requirements section"

# Preview mode
if [[ "$MODE" == "dry-run" ]]; then
    echo ""
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║                    DRY RUN MODE                          ║"
    echo "║              (No changes will be made)                   ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo ""

    log "Would add FILE PERSISTENCE BUG section (${SECTION_LENGTH} lines):"
    echo "---"
    echo "$BUG_SECTION" | head -20
    echo "... (${SECTION_LENGTH} lines total)"
    echo "---"
    echo ""

    log "Would update Critical Requirements section:"
    echo "---"
    echo "$CRIT_SECTION"
    echo "---"
    echo ""

    success "Dry run complete - no changes made"
    exit 0
fi

# Interactive mode confirmation
if [[ "$MODE" == "interactive" ]]; then
    echo ""
    echo "Ready to apply updates:"
    echo "  1. Add FILE PERSISTENCE BUG & SAFEGUARDS section (${SECTION_LENGTH} lines)"
    echo "  2. Update Critical Requirements with verification mandate"
    echo ""
    read -p "Proceed with updates? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "Update cancelled"
        log "Backup preserved at: $BACKUP_FILE"
        exit 0
    fi
fi

# Apply updates
log "Applying updates to CLAUDE.md..."

# Step 1: Find insertion point for FILE PERSISTENCE BUG section
INSERTION_POINT=$(grep -n "### CONTEXT PRESERVATION REQUIREMENT" "$USER_CLAUDE_MD" | cut -d: -f1 | head -1)

if [[ -z "$INSERTION_POINT" ]]; then
    warn "Could not find CONTEXT PRESERVATION REQUIREMENT section"
    warn "Appending FILE PERSISTENCE BUG section to end of file"

    # Append to end
    echo "" >> "$USER_CLAUDE_MD"
    echo "$BUG_SECTION" >> "$USER_CLAUDE_MD"
    echo "" >> "$USER_CLAUDE_MD"
else
    # Insert before CONTEXT PRESERVATION REQUIREMENT
    TEMP_FILE=$(mktemp)
    head -n $((INSERTION_POINT - 1)) "$USER_CLAUDE_MD" > "$TEMP_FILE"
    echo "" >> "$TEMP_FILE"
    echo "$BUG_SECTION" >> "$TEMP_FILE"
    echo "" >> "$TEMP_FILE"
    tail -n +$INSERTION_POINT "$USER_CLAUDE_MD" >> "$TEMP_FILE"
    mv "$TEMP_FILE" "$USER_CLAUDE_MD"
fi

success "Added FILE PERSISTENCE BUG & SAFEGUARDS section"

# Step 2: Update Critical Requirements (if found)
if grep -q "### Critical Requirements" "$USER_CLAUDE_MD"; then
    CRIT_LINE=$(grep -n "### Critical Requirements" "$USER_CLAUDE_MD" | cut -d: -f1 | head -1)

    # Replace next 5 lines with enhanced version
    TEMP_FILE=$(mktemp)
    head -n $((CRIT_LINE - 1)) "$USER_CLAUDE_MD" > "$TEMP_FILE"
    echo "$CRIT_SECTION" >> "$TEMP_FILE"

    # Skip old Critical Requirements section (assume 5 lines)
    tail -n +$((CRIT_LINE + 5)) "$USER_CLAUDE_MD" >> "$TEMP_FILE"
    mv "$TEMP_FILE" "$USER_CLAUDE_MD"

    success "Updated Critical Requirements section"
else
    warn "Could not find Critical Requirements section - skipped"
fi

# Verification
echo ""
log "Verifying updates..."

if grep -q "FILE PERSISTENCE BUG & SAFEGUARDS" "$USER_CLAUDE_MD"; then
    success "✓ FILE PERSISTENCE BUG section present"
else
    error "✗ FILE PERSISTENCE BUG section NOT found"
fi

if grep -q "File operations verified on filesystem" "$USER_CLAUDE_MD"; then
    success "✓ Enhanced Critical Requirements present"
else
    warn "⚠ Enhanced Critical Requirements may not be complete"
fi

# Summary
echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                   UPDATE COMPLETE                        ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
success "Your CLAUDE.md has been updated with file persistence safeguards"
echo ""
echo "What was added:"
echo "  ✓ FILE PERSISTENCE BUG & SAFEGUARDS section"
echo "  ✓ Enhanced Critical Requirements with verification"
echo "  ✓ Backup preserved at: $BACKUP_FILE"
echo ""
echo "Next steps:"
echo "  1. Review the changes: diff $BACKUP_FILE CLAUDE.md"
echo "  2. Copy verification script to your project"
echo "  3. Test with: ./scripts/verify-files.sh CLAUDE.md"
echo "  4. Read: CRITICAL-UPDATE-2025-11-12.md for full details"
echo ""
echo "Verification script location:"
echo "  $SCRIPT_DIR/verify-files.sh"
echo ""
echo "Copy command:"
echo "  mkdir -p scripts && cp $SCRIPT_DIR/verify-files.sh scripts/"
echo ""

exit 0
