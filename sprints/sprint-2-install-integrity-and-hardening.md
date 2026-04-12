# Sprint 2: Install Integrity and Script Hardening

**Priority**: HIGH / MEDIUM
**Effort**: Medium -- requires design decisions and cross-platform testing
**Risk if skipped**: Supply-chain attacks via install flow, data loss from concurrent runs, silent failures on macOS

---

## Tasks

### T1. Add integrity verification to curl|bash install [CRITICAL - C1]

**File**: `project/deployment/templates/one-line-install.sh`

**What**: Replace the raw `curl | bash` pattern with a download-then-verify approach. Publish SHA-256 checksums alongside releases.

**Option A -- Checksum verification**:
```bash
#!/bin/bash
# AGENT-11 Secure Installer
set -euo pipefail
BRANCH="${1:-main}"
INSTALL_URL="https://raw.githubusercontent.com/TheWayWithin/agent-11/$BRANCH/project/deployment/scripts/install.sh"
CHECKSUM_URL="https://raw.githubusercontent.com/TheWayWithin/agent-11/$BRANCH/project/deployment/scripts/install.sh.sha256"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

curl -fsSL "$INSTALL_URL" -o "$TMPDIR/install.sh"
curl -fsSL "$CHECKSUM_URL" -o "$TMPDIR/install.sh.sha256"

cd "$TMPDIR"
if command -v sha256sum &>/dev/null; then
    sha256sum -c install.sh.sha256
elif command -v shasum &>/dev/null; then
    shasum -a 256 -c install.sh.sha256
else
    echo "WARNING: Cannot verify checksum (sha256sum/shasum not found). Proceeding anyway."
fi

bash install.sh "$@"
```

**Option B -- GPG signature** (more secure, higher friction):
- Publish a GPG public key
- Sign each release
- Verify signature before execution

**Recommendation**: Start with Option A (checksums). Add a CI step to auto-generate `.sha256` files on release.

**New files needed**:
- `project/deployment/scripts/install.sh.sha256` (auto-generated)
- CI workflow step to regenerate checksum on changes to install.sh

**Acceptance**: Users can verify installer integrity before execution. The one-line install documentation is updated.

---

### T2. Add git clone verification in update-manager [HIGH - H3]

**File**: `project/deployment/scripts/update-manager.sh`

**What**: After cloning, verify the checkout matches an expected tag or commit.

**Fix**:
```bash
# Pin to tagged release
git clone --depth 1 --branch "$EXPECTED_TAG" "$REPO_URL" agent-11-update

# Verify we got what we expected
ACTUAL_TAG=$(git -C agent-11-update describe --tags --exact-match 2>/dev/null || echo "untagged")
if [[ "$ACTUAL_TAG" != "$EXPECTED_TAG" ]]; then
    echo "ERROR: Tag mismatch. Expected $EXPECTED_TAG, got $ACTUAL_TAG"
    exit 1
fi
```

**Acceptance**: Update manager only applies updates from verified tagged releases.

---

### T3. Add nullglob to agent-installer.sh [MEDIUM - M5]

**File**: `project/deployment/scripts/agent-installer.sh`

**What**: Wrap glob loops with `shopt -s nullglob` to prevent iterating on literal patterns.

**Fix**:
```bash
shopt -s nullglob
for agent_file in "${SOURCE_DIR}"/project/agents/specialists/*.md; do
    cp "$agent_file" "${AGENTS_DIR}/"
done
shopt -u nullglob
```

**Acceptance**: Script handles empty directories gracefully without errors.

---

### T4. Add concurrent execution lockfile [LOW - L4]

**Files**:
- `project/deployment/scripts/install.sh`
- `project/deployment/scripts/update-manager.sh`

**What**: Prevent multiple simultaneous executions that could corrupt the installation.

**Fix**:
```bash
LOCKDIR="/tmp/agent11-install.lock"
if ! mkdir "$LOCKDIR" 2>/dev/null; then
    echo "ERROR: Another AGENT-11 installation is running."
    echo "If this is a stale lock, remove: $LOCKDIR"
    exit 1
fi
trap 'rmdir "$LOCKDIR" 2>/dev/null' EXIT
```

**Acceptance**: Running two installs simultaneously results in a clean error on the second.

---

### T5. Fix macOS sort -V compatibility [MEDIUM - M3]

**File**: `project/deployment/scripts/update-manager.sh`

**What**: Check for `sort -V` availability and provide fallback.

**Fix**:
```bash
version_sort() {
    if sort --version-sort /dev/null 2>/dev/null; then
        sort -V
    else
        # macOS fallback: use perl for version sorting
        perl -e 'print sort { 
            my @a = ($a =~ /(\d+)/g); 
            my @b = ($b =~ /(\d+)/g); 
            for (0..$#a) { return $a[$_] <=> $b[$_] if $a[$_] != $b[$_] } 
            return @a <=> @b 
        } <>'
    fi
}
```

**Acceptance**: Version comparison works on both Linux (GNU coreutils) and macOS (BSD).

---

### T6. Add terminal detection for color codes [LOW - L2]

**Files**: All shell scripts with color output.

**What**: Only output ANSI escape codes when stdout is a terminal.

**Fix** (add to top of each script, after color definitions):
```bash
if [ ! -t 1 ]; then
    RED=''; GREEN=''; YELLOW=''; BLUE=''; DIM=''; BOLD=''; NC=''
fi
```

**Acceptance**: `./install.sh /path 2>&1 | cat` produces clean output without escape codes.

---

### T7. Pin GitHub Actions to commit SHA [LOW - L1]

**File**: `.github/workflows/validate-agents.yml`, `.github/workflows/validate.yml`

**What**: Replace version tag references with pinned commit SHAs for supply-chain hardening.

**Fix**:
```yaml
# Before:
- uses: actions/checkout@v4

# After (pin to known-good SHA):
- uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
```

**Acceptance**: Workflows use SHA-pinned actions with version comments.

---

### T8. Update deprecated `::set-output` in run-gates.py [LOW - L2]

**File**: `gates/run-gates.py`

**What**: Replace deprecated `::set-output` with `$GITHUB_OUTPUT` file-based approach.

**Fix**:
```python
if self.ci_mode:
    output = { ... }
    github_output = os.environ.get('GITHUB_OUTPUT')
    if github_output:
        with open(github_output, 'a') as f:
            f.write(f"gates-result={json.dumps(output)}\n")
    else:
        # Fallback for local CI testing
        print(f"gates-result={json.dumps(output)}")
```

**Acceptance**: Quality gates work with modern GitHub Actions runners without deprecation warnings.

---

## Definition of Done

- [ ] All tasks implemented
- [ ] Install flow tested on macOS and Linux (or CI)
- [ ] Checksum generation integrated into release workflow
- [ ] No regressions in existing install/update/backup flows
