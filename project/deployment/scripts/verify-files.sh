#!/bin/bash
# AGENT-11 File Persistence Verification Script
# Usage: ./verify-files.sh file1.ts file2.ts ...
# Purpose: Verify files exist after Task delegation to catch file persistence bug
#
# Background: Task tool delegation + Write tool operations have a known bug where
# files are created in agent's execution context but don't persist to host filesystem.
# This script provides independent verification of file existence.
#
# See: /CLAUDE.md "FILE PERSISTENCE BUG & SAFEGUARDS" section
# Post-Mortem: /Users/jamiewatters/DevProjects/ISOTracker/post-mortem-analysis.md

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
MISSING=0
EMPTY=0
TOTAL=0

echo "🔍 AGENT-11 File Persistence Verification"
echo "=========================================="
echo ""

# Check if any files provided
if [ $# -eq 0 ]; then
    echo -e "${RED}❌ ERROR: No files specified${NC}"
    echo ""
    echo "Usage: $0 file1.ts file2.ts ..."
    echo ""
    echo "Example:"
    echo "  $0 /path/to/file1.ts /path/to/file2.ts"
    echo "  $0 apps/web/lib/**/*.ts"
    exit 1
fi

echo "Checking $# file(s)..."
echo ""

# Verify each file
for file in "$@"; do
    TOTAL=$((TOTAL + 1))

    # Expand globs if present
    if [[ "$file" == *"*"* ]]; then
        echo -e "${YELLOW}⚠️  GLOB PATTERN: $file (expand manually)${NC}"
        continue
    fi

    # Check if file exists
    if [ ! -f "$file" ]; then
        echo -e "${RED}❌ MISSING: $file${NC}"
        MISSING=$((MISSING + 1))
    else
        # Get file size
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            SIZE=$(stat -f%z "$file")
        else
            # Linux
            SIZE=$(stat -c%s "$file")
        fi

        # Check if empty
        if [ "$SIZE" -eq 0 ]; then
            echo -e "${YELLOW}⚠️  EMPTY: $file (0 bytes)${NC}"
            EMPTY=$((EMPTY + 1))
        else
            # Convert bytes to human-readable
            if [ "$SIZE" -lt 1024 ]; then
                SIZE_HUMAN="${SIZE}B"
            elif [ "$SIZE" -lt 1048576 ]; then
                SIZE_HUMAN="$((SIZE / 1024))KB"
            else
                SIZE_HUMAN="$((SIZE / 1048576))MB"
            fi

            echo -e "${GREEN}✅ EXISTS: $file (${SIZE_HUMAN})${NC}"
        fi
    fi
done

echo ""
echo "=========================================="
echo "Verification Summary"
echo "=========================================="
echo "Total files checked: $TOTAL"
echo -e "Files exist: ${GREEN}$((TOTAL - MISSING))${NC}"
echo -e "Files missing: ${RED}${MISSING}${NC}"
echo -e "Empty files: ${YELLOW}${EMPTY}${NC}"

# Exit code based on results
if [ $MISSING -gt 0 ]; then
    echo ""
    echo -e "${RED}⚠️  CRITICAL: $MISSING file(s) missing${NC}"
    echo ""
    echo "This indicates the FILE PERSISTENCE BUG has been hit."
    echo "Task delegation reported files created, but they don't exist on filesystem."
    echo ""
    echo "RECOVERY STEPS:"
    echo "1. Extract file content from agent's Task tool response"
    echo "2. Use coordinator's Write tool directly (no delegation)"
    echo "3. Verify files exist with this script after creation"
    echo "4. Document in progress.md: 'File persistence bug encountered [timestamp]'"
    echo ""
    echo "See CLAUDE.md 'FILE PERSISTENCE BUG & SAFEGUARDS' for full protocol."
    echo ""
    exit 1
elif [ $EMPTY -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}⚠️  WARNING: $EMPTY empty file(s) detected${NC}"
    echo "Empty files may indicate incomplete write operations."
    echo ""
    exit 2
else
    echo ""
    echo -e "${GREEN}✅ All files verified successfully on filesystem${NC}"
    echo ""
    echo "Recommended: Document in progress.md:"
    echo "  '✅ Files verified on filesystem: $(date '+%Y-%m-%d %H:%M')'"
    echo ""
    exit 0
fi
