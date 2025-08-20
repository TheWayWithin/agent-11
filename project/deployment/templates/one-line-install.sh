#!/bin/bash

# AGENT-11 One-Line Installer Template
# This template creates a one-line installer for remote deployment

# Configuration
REPO_URL="https://github.com/TheWayWithin/agent-11"
BRANCH="main"
INSTALL_DIR="/tmp/agent-11-install"

# One-line installer commands for different squads

echo "AGENT-11 One-Line Installation Commands"
echo "======================================="
echo
echo "Core Squad (4 agents - recommended for beginners):"
echo "curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/$BRANCH/deployment/scripts/install.sh | bash -s core"
echo
echo "Full Squad (11 agents - complete capability):"
echo "curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/$BRANCH/deployment/scripts/install.sh | bash -s full"
echo
echo "Minimal Squad (2 agents - lightweight):"
echo "curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/$BRANCH/deployment/scripts/install.sh | bash -s minimal"
echo
echo "Prerequisites:"
echo "- Bash 4.0+"
echo "- 50MB free disk space"
echo "- Write access to ~/.claude directory"
echo
echo "For local installation (if you have the repo):"
echo "./deployment/scripts/install.sh core"

# Alternative: Local git clone method
echo
echo "Alternative: Git Clone Method"
echo "============================="
echo
echo "git clone $REPO_URL && cd agent-11 && ./deployment/scripts/install.sh core"
echo
echo "Validation:"
echo "./deployment/scripts/validate-environment.sh"
echo
echo "Management:"
echo "./deployment/scripts/agent-installer.sh list-installed"
echo "./deployment/scripts/backup-manager.sh list"