#!/bin/bash
# AGENT-11 Secure Installer
# Downloads the install script, verifies its SHA-256 checksum, then executes it.
# This prevents man-in-the-middle attacks on the install flow.

set -euo pipefail

BRANCH="${1:-main}"
RAW_BASE="https://raw.githubusercontent.com/TheWayWithin/agent-11/$BRANCH"
INSTALL_URL="$RAW_BASE/project/deployment/scripts/install.sh"
CHECKSUM_URL="$RAW_BASE/project/deployment/scripts/install.sh.sha256"

# Colors (disabled when not a terminal)
if [ -t 1 ]; then
    RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
else
    RED=''; GREEN=''; YELLOW=''; BLUE=''; NC=''
fi

echo -e "${BLUE}AGENT-11 Secure Installer${NC}"
echo "========================="

# Create temp directory with cleanup trap
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT INT TERM

# Download installer
echo -e "${BLUE}Downloading installer...${NC}"
if ! curl -fsSL "$INSTALL_URL" -o "$TMPDIR/install.sh"; then
    echo -e "${RED}ERROR: Failed to download installer from $INSTALL_URL${NC}"
    exit 1
fi

# Download checksum
echo -e "${BLUE}Downloading checksum...${NC}"
CHECKSUM_AVAILABLE=true
if ! curl -fsSL "$CHECKSUM_URL" -o "$TMPDIR/install.sh.sha256" 2>/dev/null; then
    CHECKSUM_AVAILABLE=false
fi

# Verify checksum
if [[ "$CHECKSUM_AVAILABLE" == "true" && -s "$TMPDIR/install.sh.sha256" ]]; then
    echo -e "${BLUE}Verifying integrity...${NC}"
    cd "$TMPDIR"
    if command -v sha256sum &>/dev/null; then
        if sha256sum -c install.sh.sha256 --status 2>/dev/null; then
            echo -e "${GREEN}Checksum verified successfully${NC}"
        else
            echo -e "${RED}ERROR: Checksum verification FAILED. The installer may have been tampered with.${NC}"
            echo -e "${RED}Expected checksum:${NC}"
            cat install.sh.sha256
            echo -e "${RED}Actual checksum:${NC}"
            sha256sum install.sh
            exit 1
        fi
    elif command -v shasum &>/dev/null; then
        if shasum -a 256 -c install.sh.sha256 --status 2>/dev/null; then
            echo -e "${GREEN}Checksum verified successfully${NC}"
        else
            echo -e "${RED}ERROR: Checksum verification FAILED. The installer may have been tampered with.${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}WARNING: Cannot verify checksum (sha256sum/shasum not found). Proceeding without verification.${NC}"
    fi
    cd - >/dev/null
else
    echo -e "${YELLOW}WARNING: No checksum file available for branch '$BRANCH'. Proceeding without verification.${NC}"
    echo -e "${YELLOW}For verified installs, use a tagged release branch.${NC}"
fi

# Execute installer
echo -e "${BLUE}Running installer...${NC}"
echo ""
bash "$TMPDIR/install.sh"
