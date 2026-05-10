#!/bin/bash
# apply-upgrade.sh — Bulk install.sh --upgrade across the fleet
#
# For full agent-11 framework upgrades. Runs install.sh --upgrade
# --non-interactive in each repo, then commits the framework files using
# the proven Sprint 5b allowlist, then pushes (with stash/rebase/pop dance
# for repos that have remote work or unstaged user content).
#
# Skips: tier=skip, tier=different-framework, tier=sandbox by default.
# Skips: tier=dormant by default (--include-dormant to opt in).
# For tier=local-only: commits but does not push.
#
# What it does per repo:
#   1. Run install.sh --upgrade --non-interactive (logs to per-repo file)
#   2. Verify markers gone, settings preserved (post-install audit)
#   3. Stage migration paths only (proven Sprint 5b allowlist)
#   4. Stage v5 marker deletions only when status is D (Trader-7 D-vs-M check)
#   5. Audit staging — abort if user-content paths or backup artefacts staged
#   6. Commit with v6.x framework upgrade message
#   7. Stash → pull-rebase → push → pop (handles divergent remotes)
#
# Usage:
#   bash apply-upgrade.sh [--dry-run] [--tier=<filter>] [--include-dormant]
#                         [--message=<custom-commit-msg>]
#
# Logs in: /tmp/agent11-apply-upgrade-<timestamp>/

set -euo pipefail

# ── Resolve paths ───────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
INSTALL_SH="$SOURCE_ROOT/project/deployment/scripts/install.sh"
REGISTRY="${AGENT11_FLEET_REGISTRY:-$HOME/shared/tools/agent-11-fleet/registry.yaml}"
TIER_FILTER="active,local-only"
DRY_RUN=0
CUSTOM_MSG=""
INCLUDE_DORMANT=0

# ── Parse args ──────────────────────────────────────────────────────────
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --tier=*) TIER_FILTER="${arg#--tier=}" ;;
    --message=*) CUSTOM_MSG="${arg#--message=}" ;;
    --include-dormant) INCLUDE_DORMANT=1 ;;
    --help|-h) grep '^#' "$0" | sed 's/^# \?//' | head -30; exit 0 ;;
    *) echo "Unknown flag: $arg" >&2; exit 2 ;;
  esac
done

[ "$INCLUDE_DORMANT" = "1" ] && TIER_FILTER="$TIER_FILTER,dormant"

[ ! -x "$INSTALL_SH" ] && { echo "ERROR: install.sh not found or not executable: $INSTALL_SH" >&2; exit 2; }
[ ! -f "$REGISTRY" ] && { echo "ERROR: registry not found: $REGISTRY" >&2; exit 2; }

[ -z "$CUSTOM_MSG" ] && CUSTOM_MSG="$(cat <<'EOF'
chore(framework): upgrade agent-11 framework via apply-upgrade.sh

- Run install.sh --upgrade to refresh library files
- Migration files only (Sprint 5b allowlist)
- Backup preserved at .claude/backups/v5-to-v6-* for rollback if needed
EOF
)"

# ── Setup ───────────────────────────────────────────────────────────────
TS=$(date +%Y%m%d-%H%M%S)
LOGDIR="${LOGDIR:-/tmp/agent11-apply-upgrade-$TS}"
mkdir -p "$LOGDIR"

echo "=== apply-upgrade.sh — Bulk install.sh --upgrade across fleet ==="
echo "Source:    $SOURCE_ROOT"
echo "install.sh: $INSTALL_SH"
echo "Registry:  $REGISTRY"
echo "Tiers:     $TIER_FILTER"
[ "$DRY_RUN" = "1" ] && echo "Mode:      DRY RUN — no changes will be made"
echo "Logs:      $LOGDIR"
echo

declare -i total=0 upgraded=0 committed=0 pushed=0 unchanged=0 errored=0

# ── Per-repo helper: stage only migration paths (Sprint 5b allowlist) ──
stage_migration_paths() {
  local path="$1"
  cd "$path"
  # Whitelist: directories/files install.sh writes to
  git add .claude/agents .claude/commands .claude/constitution .claude/data .claude/skills 2>/dev/null || true
  git add .claude/CLAUDE.md .claude/settings.json 2>/dev/null || true
  git add missions templates field-manual gates schemas stack-profiles 2>/dev/null || true
  git add .mcp.json .mcp.json.template .env.mcp.template mcp-setup.sh 2>/dev/null || true
  git add docs/MCP-GUIDE.md docs/MCP-PROFILES.md docs/MCP-TROUBLESHOOTING.md docs/MCP-MIGRATION-GUIDE.md docs/UPGRADE.md 2>/dev/null || true
  git add agent-context.md 2>/dev/null || true

  # Smart-stage v5 marker deletions: only stage when status is D, not M
  for marker in "handoff-notes.md" ".mcp-profiles" "mcp/dynamic-mcp.json" "templates/handoff-notes-template.md"; do
    local status
    status=$(git status --porcelain -- "$marker" 2>/dev/null | head -1 | cut -c1-2 || true)
    if [ "$status" = " D" ] || [ "$status" = "D " ]; then
      git add -- "$marker" 2>/dev/null || true
    fi
  done

  # Defensive unstage of backup artefacts
  git reset HEAD -- '.claude/backups' >/dev/null 2>&1 || true
  git reset HEAD -- '.claude/CLAUDE.md.backup-*' >/dev/null 2>&1 || true
  git reset HEAD -- '.claude/settings.json.backup-*' >/dev/null 2>&1 || true
}

# ── Audit: confirm staging is sane before commit ───────────────────────
audit_staging() {
  local path="$1"
  cd "$path"
  local staged_count backups_staged user_files_staged
  staged_count=$(git diff --cached --name-only | wc -l | tr -d ' ')
  backups_staged=$(git diff --cached --name-only | (grep -cE "(\.claude/backups/|\.backup-)" || true))
  user_files_staged=$(git diff --cached --name-only | (grep -cE "^(progress\.md|project-plan\.md|CLAUDE\.md)$" || true))

  if [ "$staged_count" = "0" ]; then echo "no-changes"; return; fi
  if [ "$staged_count" -lt 30 ] || [ "$staged_count" -gt 250 ]; then echo "out-of-range:$staged_count"; return; fi
  if [ "$backups_staged" != "0" ]; then echo "backups-staged:$backups_staged"; return; fi
  if [ "$user_files_staged" != "0" ]; then echo "user-files-staged:$user_files_staged"; return; fi
  echo "ok:$staged_count"
}

# ── Loop ────────────────────────────────────────────────────────────────
while IFS=$'\t' read -r name path remote branch tier notes; do
  total=$((total + 1))
  log="$LOGDIR/${name// /_}.log"

  if [ ! -d "$path" ]; then
    echo "✗ $name | path missing"; errored=$((errored + 1)); continue
  fi

  # ── 1. Run install.sh --upgrade ────────────────────────────────────────
  if [ "$DRY_RUN" = "1" ]; then
    echo "→ $name | would run install.sh --upgrade --non-interactive"
    continue
  fi

  cd "$path"
  if ! bash "$INSTALL_SH" --upgrade --non-interactive > "$log" 2>&1; then
    echo "✗ $name | install.sh failed (see $log)"; errored=$((errored + 1)); continue
  fi
  upgraded=$((upgraded + 1))

  # ── 2. Stage migration paths only ──────────────────────────────────────
  stage_migration_paths "$path"

  # ── 3. Audit staging ────────────────────────────────────────────────────
  audit=$(audit_staging "$path")
  case "$audit" in
    ok:*)
      staged_n="${audit#ok:}"
      ;;
    no-changes)
      echo "= $name | upgrade ran but no framework files changed"
      unchanged=$((unchanged + 1)); continue ;;
    *)
      echo "✗ $name | staging audit failed: $audit (see $log)"; errored=$((errored + 1)); continue ;;
  esac

  # ── 4. Commit ──────────────────────────────────────────────────────────
  if ! git commit -m "$CUSTOM_MSG" >> "$log" 2>&1; then
    echo "✗ $name | commit failed"; errored=$((errored + 1)); continue
  fi
  committed=$((committed + 1))

  # ── 5. Push (unless local-only) ────────────────────────────────────────
  if [ "$tier" = "local-only" ] || [ "$remote" = "none" ]; then
    echo "✓ $name | upgraded + committed (local-only, no push) [$staged_n files]"; continue
  fi

  did_stash=0
  modified_count=$(git status --porcelain | (grep -E '^.M|^.D' || true) | wc -l | tr -d ' ')

  attempt_push() {
    git push origin "$branch" >> "$log" 2>&1
  }

  if attempt_push; then
    echo "✓ $name | upgraded + committed + pushed [$staged_n files]"
    pushed=$((pushed + 1))
    continue
  fi

  # Push rejected — try stash → fetch → rebase → push → pop
  if [ "$modified_count" -gt 0 ]; then
    if git stash push -u -m "agent11-apply-upgrade:$name:$TS" >> "$log" 2>&1; then
      did_stash=1
    fi
  fi
  git fetch origin --quiet >> "$log" 2>&1 || true
  if git pull --rebase origin "$branch" >> "$log" 2>&1 && attempt_push; then
    echo "✓ $name | upgraded + rebased + pushed [$staged_n files]"
    pushed=$((pushed + 1))
  else
    echo "✗ $name | push failed even after rebase (see $log)"
    git rebase --abort >/dev/null 2>&1 || true
    errored=$((errored + 1))
  fi
  [ "$did_stash" = "1" ] && git stash pop >/dev/null 2>&1 || true

done < <(python3 "$SCRIPT_DIR/lib/parse-registry.py" "$REGISTRY" --tier="$TIER_FILTER")

# ── Summary ─────────────────────────────────────────────────────────────
echo
echo "Summary: $total repos | $upgraded upgraded | $committed committed | $pushed pushed | $unchanged unchanged | $errored errors"
[ "$errored" -gt 0 ] && exit 1
exit 0
