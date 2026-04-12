# Sprint 1: Critical Shell Hardening

**Priority**: CRITICAL / HIGH
**Effort**: Small -- mostly one-line fixes with high impact
**Risk if skipped**: Data loss, credential exposure, arbitrary code execution on user machines

---

## Tasks

### T1. Guard `rm -rf` against empty PROJECT_DIR [CRITICAL - C2]

**Files**:
- `project/deployment/scripts/install.sh`
- `project/deployment/scripts/backup-manager.sh`
- `project/deployment/scripts/update-manager.sh`

**What**: Add a guard immediately after `PROJECT_DIR` is set, before any destructive operations.

**Fix**:
```bash
if [[ -z "$PROJECT_DIR" || "$PROJECT_DIR" == "/" ]]; then
    echo "FATAL: PROJECT_DIR is empty or root. Aborting."
    exit 1
fi
```

**Acceptance**: No `rm -rf` can execute when `PROJECT_DIR` is empty or `/`.

---

### T2. Set `chmod 600` on `.env.mcp` before writing API keys [HIGH - H5]

**Files**:
- `project/deployment/scripts/mcp-setup.sh`
- `project/deployment/scripts/mcp-setup-v2.sh`
- `mcp-setup.sh` (root)

**What**: Before writing credentials to `.env.mcp`, set restrictive file permissions so only the owner can read it.

**Fix**:
```bash
touch "$ENV_FILE"
chmod 600 "$ENV_FILE"
# Then write content
cat > "$ENV_FILE" << EOF
...
EOF
```

**Acceptance**: `ls -la .env.mcp` shows `-rw-------` permissions after setup.

---

### T3. Reject system directories in PROJECT_DIR [HIGH - H1]

**Files**:
- `project/deployment/scripts/install.sh`
- `project/deployment/scripts/agent-installer.sh`
- `project/deployment/scripts/backup-manager.sh`
- `project/deployment/scripts/update-manager.sh`

**What**: After resolving `PROJECT_DIR`, reject known system paths.

**Fix**:
```bash
case "$PROJECT_DIR" in
    /|/etc|/usr|/var|/bin|/sbin|/opt|/System|/Library|/tmp)
        echo "ERROR: Refusing to operate on system directory: $PROJECT_DIR"
        exit 1
        ;;
esac
```

**Acceptance**: Running `./install.sh /etc` exits with an error instead of proceeding.

---

### T4. Add cleanup trap in update-manager.sh [HIGH - H2]

**File**: `project/deployment/scripts/update-manager.sh`

**What**: Add a trap to clean up the temp directory on exit, interrupt, or error.

**Fix**:
```bash
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT INT TERM
```

**Acceptance**: Temp directory is cleaned up even when the script fails mid-execution.

---

### T5. Replace `ls` parsing with `find` in backup pruning [HIGH - H4]

**File**: `project/deployment/scripts/backup-manager.sh`

**What**: Replace unsafe `ls | tail` pattern with `find` for determining oldest backup.

**Fix**:
```bash
OLDEST=$(find "$BACKUP_DIR" -maxdepth 1 -mindepth 1 -type d -printf '%T+ %p\n' 2>/dev/null | sort | head -1 | cut -d' ' -f2-)
# macOS fallback (no -printf):
# OLDEST=$(find "$BACKUP_DIR" -maxdepth 1 -mindepth 1 -type d -exec stat -f '%m %N' {} + | sort -n | head -1 | cut -d' ' -f2-)
if [[ -n "$OLDEST" && "$OLDEST" == "${BACKUP_DIR}/"* ]]; then
    rm -rf "$OLDEST"
fi
```

**Acceptance**: Backup pruning works safely with filenames containing spaces or special characters. Path-escape guard prevents deletion outside backup directory.

---

### T6. Add symlink check before backup-then-delete [HIGH - C3]

**File**: `project/deployment/scripts/install.sh`

**What**: Before backing up and deleting `.claude/agents`, verify the path is not a symlink.

**Fix**:
```bash
if [ -L "$PROJECT_DIR/.claude/agents" ]; then
    echo "ERROR: .claude/agents is a symlink. Aborting for safety."
    exit 1
fi
```

**Acceptance**: Install script refuses to proceed if `.claude/agents` is a symlink.

---

### T7. Add `set -euo pipefail` to all shell scripts [MEDIUM - M1]

**Files**: All `.sh` files that don't already have it:
- `project/deployment/scripts/mcp-setup.sh`
- `project/deployment/scripts/mcp-setup-v2.sh`
- `project/deployment/scripts/backup-manager.sh`
- `project/deployment/scripts/update-manager.sh`
- `project/deployment/scripts/agent-installer.sh`
- `project/deployment/scripts/validate-environment.sh`
- `project/deployment/scripts/mcp-fix.sh`
- `project/deployment/scripts/verify-files.sh`
- `project/deployment/scripts/version-manager.sh`
- `project/deployment/scripts/update-claude-md.sh`
- `project/deployment/scripts/validate-mcp-profiles.sh`
- `mcp-setup.sh` (root)
- `scripts/install-validation-hook.sh`

**What**: Add `set -euo pipefail` at the top. Audit variables and add `${VAR:-default}` where they may legitimately be unset.

**Acceptance**: All scripts fail loudly on unset variables, command failures, and pipeline errors.

---

## Definition of Done

- [ ] All tasks above implemented
- [ ] Each script tested manually with: valid path, empty path, system path, symlink path
- [ ] No regressions in normal install flow (`./install.sh /path/to/test-project`)
- [ ] Changes committed with clear commit messages per fix
