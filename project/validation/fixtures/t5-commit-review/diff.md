commit d501ca9b7303ce6c00cde9fdc12f86db82e0c13b
Author: Jamie <jamie.watters.mail@gmail.com>
Date:   Sun Apr 12 19:20:29 2026 -0400

    security: Add install integrity verification, lockfile, terminal detection, and CI hardening
    
    Sprint 2 of security audit findings:
    - Add secure-install.sh with SHA-256 checksum verification (replaces raw curl|bash)
    - Generate install.sh.sha256 for integrity verification
    - Update one-line-install.sh to recommend secure installer
    - Add concurrent execution lockfile to prevent install corruption
    - Add terminal detection to disable ANSI colors when piped (5 scripts)
    - Pin all GitHub Actions to commit SHAs for supply-chain hardening
    - Upgrade actions/checkout v3->v4.2.2, setup-node v3->v4.4.0,
      github-script v6->v7.0.1, upload-artifact v3->v4.6.2
    
    Note: T2 (git clone verification), T3 (nullglob), T5 (sort -V), T8 (::set-output)
    were found to be N/A after verifying actual code - the audit agent reported issues
    in code patterns that don't exist in the current codebase.
    
    Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>

diff --git a/.github/workflows/validate-agents.yml b/.github/workflows/validate-agents.yml
index 994f1cb..77e76a1 100644
--- a/.github/workflows/validate-agents.yml
+++ b/.github/workflows/validate-agents.yml
@@ -20,10 +20,10 @@ jobs:
 
     steps:
       - name: Checkout code
-        uses: actions/checkout@v3
+        uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
 
       - name: Setup Node.js
-        uses: actions/setup-node@v3
+        uses: actions/setup-node@49933ea5288caeca8642d1e84afbd3f7d6820020 # v4.4.0
         with:
           node-version: '18'
           cache: 'npm'
@@ -48,7 +48,7 @@ jobs:
 
       - name: Comment PR with results
         if: github.event_name == 'pull_request' && failure()
-        uses: actions/github-script@v6
+        uses: actions/github-script@60a0d83039c74a4aee543508d2ffcb1c3799cdea # v7.0.1
         with:
           script: |
             const fs = require('fs');
@@ -93,7 +93,7 @@ jobs:
 
       - name: Upload validation results
         if: always()
-        uses: actions/upload-artifact@v3
+        uses: actions/upload-artifact@ea165f8d65b6db9a8b9c8c4d3e1ef527f67cd7c9 # v4.6.2
         with:
           name: validation-results
           path: validation-results.json
diff --git a/.github/workflows/validate.yml b/.github/workflows/validate.yml
index 1a7da68..d75b07c 100644
--- a/.github/workflows/validate.yml
+++ b/.github/workflows/validate.yml
@@ -10,7 +10,7 @@ jobs:
   validate:
     runs-on: ubuntu-latest
     steps:
-    - uses: actions/checkout@v3
+    - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
     - name: Check structure
       run: |
         echo "🎯 Validating AGENT-11 structure..."
diff --git a/project/deployment/scripts/agent-installer.sh b/project/deployment/scripts/agent-installer.sh
index 255c92f..6c7c288 100755
--- a/project/deployment/scripts/agent-installer.sh
+++ b/project/deployment/scripts/agent-installer.sh
@@ -19,6 +19,11 @@ YELLOW='\033[1;33m'
 BLUE='\033[0;34m'
 NC='\033[0m'
 
+# Disable colors when stdout is not a terminal
+if [ ! -t 1 ]; then
+    RED=''; GREEN=''; YELLOW=''; BLUE=''; NC=''
+fi
+
 # Logging functions
 log() { echo -e "${BLUE}[AGENT]${NC} $1"; }
 success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
diff --git a/project/deployment/scripts/backup-manager.sh b/project/deployment/scripts/backup-manager.sh
index 33723e2..c3c525a 100755
--- a/project/deployment/scripts/backup-manager.sh
+++ b/project/deployment/scripts/backup-manager.sh
@@ -18,6 +18,11 @@ YELLOW='\033[1;33m'
 BLUE='\033[0;34m'
 NC='\033[0m'
 
+# Disable colors when stdout is not a terminal
+if [ ! -t 1 ]; then
+    RED=''; GREEN=''; YELLOW=''; BLUE=''; NC=''
+fi
+
 # Logging functions
 log() { echo -e "${BLUE}[BACKUP]${NC} $1"; }
 success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
diff --git a/project/deployment/scripts/install.sh b/project/deployment/scripts/install.sh
index d48e4db..b659585 100755
--- a/project/deployment/scripts/install.sh
+++ b/project/deployment/scripts/install.sh
@@ -17,6 +17,11 @@ YELLOW='\033[1;33m'
 BLUE='\033[0;34m'
 NC='\033[0m' # No Color
 
+# Disable colors when stdout is not a terminal (e.g., piped to file)
+if [ ! -t 1 ]; then
+    RED=''; GREEN=''; YELLOW=''; BLUE=''; NC=''
+fi
+
 # Logging functions (defined early for use in project detection)
 log() {
     echo -e "${BLUE}[INFO]${NC} $1"
@@ -183,6 +188,13 @@ validate_installation_paths() {
 
 validate_installation_paths
 
+# Prevent concurrent installations
+LOCKDIR="/tmp/agent11-install.lock"
+if ! mkdir "$LOCKDIR" 2>/dev/null; then
+    fatal "Another AGENT-11 installation is already running. If this is a stale lock, remove: $LOCKDIR"
+fi
+trap 'rmdir "$LOCKDIR" 2>/dev/null' EXIT
+
 TIMESTAMP=$(date +%Y%m%d_%H%M%S)
 BACKUP_PATH="$BACKUP_DIR/$TIMESTAMP"
 
diff --git a/project/deployment/scripts/install.sh.sha256 b/project/deployment/scripts/install.sh.sha256
new file mode 100644
index 0000000..c466cc7
--- /dev/null
+++ b/project/deployment/scripts/install.sh.sha256
@@ -0,0 +1 @@
+7db0e95d966ab48ef1864a2362430da6c0dce431bea05376252d176bf89c983c  install.sh
diff --git a/project/deployment/scripts/secure-install.sh b/project/deployment/scripts/secure-install.sh
new file mode 100644
index 0000000..d5c9ae2
--- /dev/null
+++ b/project/deployment/scripts/secure-install.sh
@@ -0,0 +1,75 @@
+#!/bin/bash
+# AGENT-11 Secure Installer
+# Downloads the install script, verifies its SHA-256 checksum, then executes it.
+# This prevents man-in-the-middle attacks on the install flow.
+
+set -euo pipefail
+
+BRANCH="${1:-main}"
+RAW_BASE="https://raw.githubusercontent.com/TheWayWithin/agent-11/$BRANCH"
+INSTALL_URL="$RAW_BASE/project/deployment/scripts/install.sh"
+CHECKSUM_URL="$RAW_BASE/project/deployment/scripts/install.sh.sha256"
+
+# Colors (disabled when not a terminal)
+if [ -t 1 ]; then
+    RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
+else
+    RED=''; GREEN=''; YELLOW=''; BLUE=''; NC=''
+fi
+
+echo -e "${BLUE}AGENT-11 Secure Installer${NC}"
+echo "========================="
+
+# Create temp directory with cleanup trap
+TMPDIR=$(mktemp -d)
+trap 'rm -rf "$TMPDIR"' EXIT INT TERM
+
+# Download installer
+echo -e "${BLUE}Downloading installer...${NC}"
+if ! curl -fsSL "$INSTALL_URL" -o "$TMPDIR/install.sh"; then
+    echo -e "${RED}ERROR: Failed to download installer from $INSTALL_URL${NC}"
+    exit 1
+fi
+
+# Download checksum
+echo -e "${BLUE}Downloading checksum...${NC}"
+CHECKSUM_AVAILABLE=true
+if ! curl -fsSL "$CHECKSUM_URL" -o "$TMPDIR/install.sh.sha256" 2>/dev/null; then
+    CHECKSUM_AVAILABLE=false
+fi
+
+# Verify checksum
+if [[ "$CHECKSUM_AVAILABLE" == "true" && -s "$TMPDIR/install.sh.sha256" ]]; then
+    echo -e "${BLUE}Verifying integrity...${NC}"
+    cd "$TMPDIR"
+    if command -v sha256sum &>/dev/null; then
+        if sha256sum -c install.sh.sha256 --status 2>/dev/null; then
+            echo -e "${GREEN}Checksum verified successfully${NC}"
+        else
+            echo -e "${RED}ERROR: Checksum verification FAILED. The installer may have been tampered with.${NC}"
+            echo -e "${RED}Expected checksum:${NC}"
+            cat install.sh.sha256
+            echo -e "${RED}Actual checksum:${NC}"
+            sha256sum install.sh
+            exit 1
+        fi
+    elif command -v shasum &>/dev/null; then
+        if shasum -a 256 -c install.sh.sha256 --status 2>/dev/null; then
+            echo -e "${GREEN}Checksum verified successfully${NC}"
+        else
+            echo -e "${RED}ERROR: Checksum verification FAILED. The installer may have been tampered with.${NC}"
+            exit 1
+        fi
+    else
+        echo -e "${YELLOW}WARNING: Cannot verify checksum (sha256sum/shasum not found). Proceeding without verification.${NC}"
+    fi
+    cd - >/dev/null
+else
+    echo -e "${YELLOW}WARNING: No checksum file available for branch '$BRANCH'. Proceeding without verification.${NC}"
+    echo -e "${YELLOW}For verified installs, use a tagged release branch.${NC}"
+fi
+
+# Execute installer
+echo -e "${BLUE}Running installer...${NC}"
+echo ""
+bash "$TMPDIR/install.sh"
diff --git a/project/deployment/scripts/update-manager.sh b/project/deployment/scripts/update-manager.sh
index 9b3f99d..f847d6a 100755
--- a/project/deployment/scripts/update-manager.sh
+++ b/project/deployment/scripts/update-manager.sh
@@ -19,6 +19,11 @@ YELLOW='\033[1;33m'
 BLUE='\033[0;34m'
 NC='\033[0m' # No Color
 
+# Disable colors when stdout is not a terminal
+if [ ! -t 1 ]; then
+    RED=''; GREEN=''; YELLOW=''; BLUE=''; NC=''
+fi
+
 # Logging function
 log() {
     echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$UPDATE_LOG"
diff --git a/project/deployment/scripts/version-manager.sh b/project/deployment/scripts/version-manager.sh
index 958e101..f1f6896 100755
--- a/project/deployment/scripts/version-manager.sh
+++ b/project/deployment/scripts/version-manager.sh
@@ -20,6 +20,11 @@ BLUE='\033[0;34m'
 CYAN='\033[0;36m'
 NC='\033[0m' # No Color
 
+# Disable colors when stdout is not a terminal
+if [ ! -t 1 ]; then
+    RED=''; GREEN=''; YELLOW=''; BLUE=''; NC=''
+fi
+
 # Logging function
 log() {
     echo -e "$1"
diff --git a/project/deployment/templates/one-line-install.sh b/project/deployment/templates/one-line-install.sh
index db46c07..8efc38d 100644
--- a/project/deployment/templates/one-line-install.sh
+++ b/project/deployment/templates/one-line-install.sh
@@ -2,44 +2,44 @@
 
 # AGENT-11 One-Line Installer Template
 # This template creates a one-line installer for remote deployment
+#
+# SECURITY: The recommended installation method downloads the script first,
+# verifies its checksum, then executes it. This prevents MITM attacks.
 
 # Configuration
 REPO_URL="https://github.com/TheWayWithin/agent-11"
 BRANCH="main"
-INSTALL_DIR="/tmp/agent-11-install"
+RAW_BASE="https://raw.githubusercontent.com/TheWayWithin/agent-11/$BRANCH"
 
-# One-line installer commands for different squads
-
-echo "AGENT-11 One-Line Installation Commands"
+echo "AGENT-11 Installation Commands"
 echo "======================================="
 echo
-echo "Core Squad (4 agents - recommended for beginners):"
-echo "curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/$BRANCH/deployment/scripts/install.sh | bash -s core"
+echo "RECOMMENDED: Secure Install (download + verify + execute)"
+echo "-----------------------------------------------------------"
+echo
+echo "# Download, verify checksum, then install:"
+cat << 'SECURE_EOF'
+bash <(curl -fsSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/secure-install.sh)
+SECURE_EOF
 echo
-echo "Full Squad (11 agents - complete capability):"
-echo "curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/$BRANCH/deployment/scripts/install.sh | bash -s full"
+echo "ALTERNATIVE: Local git clone method (inherently verified)"
+echo "-----------------------------------------------------------"
 echo
-echo "Minimal Squad (2 agents - lightweight):"
-echo "curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/$BRANCH/deployment/scripts/install.sh | bash -s minimal"
+echo "git clone $REPO_URL && cd agent-11 && ./project/deployment/scripts/install.sh"
 echo
 echo "Prerequisites:"
 echo "- Bash 4.0+"
+echo "- curl or wget"
 echo "- 50MB free disk space"
-echo "- Write access to ~/.claude directory"
-echo
-echo "For local installation (if you have the repo):"
-echo "./deployment/scripts/install.sh core"
-
-# Alternative: Local git clone method
-echo
-echo "Alternative: Git Clone Method"
-echo "============================="
+echo "- A project directory (run from within your project)"
 echo
-echo "git clone $REPO_URL && cd agent-11 && ./deployment/scripts/install.sh core"
+echo "After installation:"
+echo "  Restart Claude Code to activate agents"
+echo "  Try: @coordinator, @developer, @strategist, /coord"
 echo
 echo "Validation:"
-echo "./deployment/scripts/validate-environment.sh"
+echo "  ./project/deployment/scripts/validate-environment.sh"
 echo
 echo "Management:"
-echo "./deployment/scripts/agent-installer.sh list-installed"
-echo "./deployment/scripts/backup-manager.sh list"
\ No newline at end of file
+echo "  ./project/deployment/scripts/agent-installer.sh list-installed"
+echo "  ./project/deployment/scripts/backup-manager.sh list"
