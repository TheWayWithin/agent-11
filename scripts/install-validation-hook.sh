#!/bin/bash
#
# Install deployment validation pre-commit hook
#
# Usage:
#   ./scripts/install-validation-hook.sh
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
GIT_HOOKS_DIR="$PROJECT_ROOT/.git/hooks"
HOOK_SOURCE="$SCRIPT_DIR/pre-commit-deployment-validation"
HOOK_DEST="$GIT_HOOKS_DIR/pre-commit"

echo ""
echo -e "${BLUE}🔧 AGENT-11 Deployment Validation Hook Installer${NC}"
echo "================================================="
echo ""

# Check if we're in a git repository
if [ ! -d "$PROJECT_ROOT/.git" ]; then
  echo -e "${RED}❌ Error: Not a git repository${NC}"
  echo "This script must be run from within the AGENT-11 repository."
  exit 1
fi

# Check if hook source exists
if [ ! -f "$HOOK_SOURCE" ]; then
  echo -e "${RED}❌ Error: Hook source not found${NC}"
  echo "Expected: $HOOK_SOURCE"
  exit 1
fi

# Create hooks directory if it doesn't exist
mkdir -p "$GIT_HOOKS_DIR"

# Check if pre-commit hook already exists
if [ -f "$HOOK_DEST" ]; then
  echo -e "${YELLOW}⚠ Existing pre-commit hook found${NC}"
  echo ""
  echo "Current hook: $HOOK_DEST"
  echo ""
  echo "Options:"
  echo "  1. Backup existing and install new hook"
  echo "  2. Append validation to existing hook"
  echo "  3. Cancel installation"
  echo ""
  read -p "Select option [1-3]: " choice

  case $choice in
    1)
      BACKUP="$HOOK_DEST.backup-$(date +%Y%m%d-%H%M%S)"
      echo ""
      echo "Creating backup: $BACKUP"
      cp "$HOOK_DEST" "$BACKUP"
      cp "$HOOK_SOURCE" "$HOOK_DEST"
      chmod +x "$HOOK_DEST"
      echo -e "${GREEN}✅ Hook installed with backup${NC}"
      ;;
    2)
      echo ""
      echo "Appending validation to existing hook..."
      echo "" >> "$HOOK_DEST"
      echo "# AGENT-11 Deployment Validation (added $(date))" >> "$HOOK_DEST"
      cat "$HOOK_SOURCE" >> "$HOOK_DEST"
      chmod +x "$HOOK_DEST"
      echo -e "${GREEN}✅ Validation appended to existing hook${NC}"
      ;;
    3)
      echo ""
      echo "Installation cancelled."
      exit 0
      ;;
    *)
      echo ""
      echo -e "${RED}Invalid option. Installation cancelled.${NC}"
      exit 1
      ;;
  esac
else
  # No existing hook, install directly
  cp "$HOOK_SOURCE" "$HOOK_DEST"
  chmod +x "$HOOK_DEST"
  echo -e "${GREEN}✅ Pre-commit hook installed${NC}"
fi

echo ""
echo -e "${BLUE}📝 Hook Details:${NC}"
echo "  Location: $HOOK_DEST"
echo "  Source: $HOOK_SOURCE"
echo ""
echo -e "${BLUE}🎯 What it does:${NC}"
echo "  • Validates deployment consistency before commits"
echo "  • Runs when install.sh or library agents are modified"
echo "  • Ensures SQUAD_FULL matches library agents"
echo "  • Verifies source directory priority"
echo "  • Checks README.md consistency"
echo ""
echo -e "${BLUE}🧪 Test the hook:${NC}"
echo "  1. Make a change to install.sh"
echo "  2. Try to commit: git commit -m 'test'"
echo "  3. Hook should run validation automatically"
echo ""
echo -e "${BLUE}🔧 Disable temporarily:${NC}"
echo "  git commit --no-verify -m 'message'"
echo ""
echo -e "${GREEN}✅ Installation complete!${NC}"
echo ""
