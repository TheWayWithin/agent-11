#!/bin/bash

# AGENT-11 One-Line Installer Template
# This template creates a one-line installer for remote deployment
#
# SECURITY: The recommended installation method downloads the script first,
# verifies its checksum, then executes it. This prevents MITM attacks.

# Configuration
REPO_URL="https://github.com/TheWayWithin/agent-11"
BRANCH="main"
RAW_BASE="https://raw.githubusercontent.com/TheWayWithin/agent-11/$BRANCH"

echo "AGENT-11 Installation Commands"
echo "======================================="
echo
echo "RECOMMENDED: Secure Install (download + verify + execute)"
echo "-----------------------------------------------------------"
echo
echo "# Download, verify checksum, then install:"
cat << 'SECURE_EOF'
bash <(curl -fsSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/secure-install.sh)
SECURE_EOF
echo
echo "ALTERNATIVE: Local git clone method (inherently verified)"
echo "-----------------------------------------------------------"
echo
echo "git clone $REPO_URL && cd agent-11 && ./project/deployment/scripts/install.sh"
echo
echo "Prerequisites:"
echo "- Bash 4.0+"
echo "- curl or wget"
echo "- 50MB free disk space"
echo "- A project directory (run from within your project)"
echo
echo "After installation:"
echo "  Restart Claude Code to activate agents"
echo "  Try: @coordinator, @developer, @strategist, /coord"
echo
echo "Validation:"
echo "  ./project/deployment/scripts/validate-environment.sh"
echo
echo "Management:"
echo "  ./project/deployment/scripts/agent-installer.sh list-installed"
echo "  ./project/deployment/scripts/backup-manager.sh list"
