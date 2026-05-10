#!/bin/bash
# apply-file.sh — Deploy a single library file across the fleet
#
# For surgical updates: when a single file in the agent-11 library needs
# to land in every repo without running a full --upgrade. Example: bumping
# project/field-manual/model-selection-guide.md after a model release.
#
# What it does per repo:
#   1. Copy <library-relative-path> from the source repo to the target repo
#      (preserving relative path; e.g. project/field-manual/foo.md →
#       repo/field-manual/foo.md, since project/* deploys flat in user repos)
#   2. Stash any unstaged tracked changes (so push-rebase can run cleanly)
#   3. Stage just that one file
#   4. If unchanged, skip (no commit)
#   5. Commit with a generated message
#   6. Pull-rebase if remote is ahead, then push
#   7. Restore stash
#
# Skips: tier=skip, tier=different-framework, tier=sandbox by default.
# For tier=local-only: commits but does not push.
#
# Usage:
#   bash apply-file.sh <library-relative-path> [--dry-run] [--message=<msg>]
#                      [--tier=<filter>] [--include-dormant] [--include-sandbox]
#
# Example:
#   bash apply-file.sh project/field-manual/model-selection-guide.md
#   bash apply-file.sh project/field-manual/model-selection-guide.md --dry-run
#
# Logs land in: $LOGDIR (default /tmp/agent11-apply-file-<timestamp>/)

set -euo pipefail

# ── Resolve paths ───────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
REGISTRY="${AGENT11_FLEET_REGISTRY:-$HOME/shared/tools/agent-11-fleet/registry.yaml}"
TIER_FILTER="active,local-only"
DRY_RUN=0
CUSTOM_MSG=""
INCLUDE_DORMANT=0
INCLUDE_SANDBOX=0
TARGET_FILE=""

# ── Parse args ──────────────────────────────────────────────────────────
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --tier=*) TIER_FILTER="${arg#--tier=}" ;;
    --message=*) CUSTOM_MSG="${arg#--message=}" ;;
    --include-dormant) INCLUDE_DORMANT=1 ;;
    --include-sandbox) INCLUDE_SANDBOX=1 ;;
    --help|-h) grep '^#' "$0" | sed 's/^# \?//' | head -30; exit 0 ;;
    --*) echo "Unknown flag: $arg" >&2; exit 2 ;;
    *) TARGET_FILE="$arg" ;;
  esac
done

[ "$INCLUDE_DORMANT" = "1" ] && TIER_FILTER="$TIER_FILTER,dormant"
[ "$INCLUDE_SANDBOX" = "1" ] && TIER_FILTER="$TIER_FILTER,sandbox"

if [ -z "$TARGET_FILE" ]; then
  echo "ERROR: no file specified. Pass a library-relative path." >&2
  echo "Usage: $0 <library-relative-path> [--dry-run]" >&2
  exit 2
fi

SRC="$SOURCE_ROOT/$TARGET_FILE"
if [ ! -f "$SRC" ]; then
  echo "ERROR: source file not found: $SRC" >&2
  exit 2
fi

# Compute target relative path. The agent-11 install.sh deploys
# `project/*` flat into the user's repo (project/missions → missions/,
# project/field-manual → field-manual/, etc). Strip the `project/` prefix.
case "$TARGET_FILE" in
  project/*) TARGET_REL="${TARGET_FILE#project/}" ;;
  library/CLAUDE.md) TARGET_REL=".claude/CLAUDE.md" ;;
  *) TARGET_REL="$TARGET_FILE" ;;
esac

# ── Setup ───────────────────────────────────────────────────────────────
TS=$(date +%Y%m%d-%H%M%S)
LOGDIR="${LOGDIR:-/tmp/agent11-apply-file-$TS}"
mkdir -p "$LOGDIR"

if [ -z "$CUSTOM_MSG" ]; then
  filename=$(basename "$TARGET_FILE")
  CUSTOM_MSG="chore(framework): sync $filename from agent-11 library

Deployed via apply-file.sh on $(date +%Y-%m-%d)."
fi

# ── Header ──────────────────────────────────────────────────────────────
echo "=== apply-file.sh — Single-file fleet deploy ==="
echo "Source:        $SRC"
echo "Target (rel):  $TARGET_REL"
echo "Tiers:         $TIER_FILTER"
[ "$DRY_RUN" = "1" ] && echo "Mode:          DRY RUN — no changes will be made"
echo "Logs:          $LOGDIR"
echo

declare -i total=0 skipped=0 unchanged=0 committed=0 pushed=0 errored=0

# ── Loop ────────────────────────────────────────────────────────────────
while IFS=$'\t' read -r name path remote branch tier notes; do
  total=$((total + 1))

  if [ ! -d "$path" ]; then
    echo "✗ $name | path missing"
    errored=$((errored + 1))
    continue
  fi

  log="$LOGDIR/${name// /_}.log"
  cd "$path"

  # Compare contents
  target_path="$path/$TARGET_REL"
  if [ -f "$target_path" ] && cmp -s "$SRC" "$target_path"; then
    echo "= $name | already up-to-date"
    unchanged=$((unchanged + 1))
    continue
  fi

  if [ "$DRY_RUN" = "1" ]; then
    if [ -f "$target_path" ]; then
      diff_lines=$( (diff "$SRC" "$target_path" 2>/dev/null || true) | wc -l | tr -d ' ')
      echo "→ $name | would update ($diff_lines diff lines)"
    else
      echo "+ $name | would create $TARGET_REL"
    fi
    continue
  fi

  # Stash unstaged changes (only if any tracked-modified files exist)
  did_stash=0
  modified_count=$(git status --porcelain | (grep -E '^.M|^.D' || true) | wc -l | tr -d ' ')
  if [ "$modified_count" -gt 0 ]; then
    if git stash push -u -m "agent11-apply-file:$name:$TS" > "$log.stash" 2>&1; then
      did_stash=1
    fi
  fi

  # Ensure parent dir exists
  mkdir -p "$(dirname "$target_path")"
  cp "$SRC" "$target_path"

  # Stage + commit
  git add -- "$TARGET_REL" 2>>"$log"
  if git diff --cached --quiet; then
    echo "= $name | content matched after copy (no diff to commit)"
    [ "$did_stash" = "1" ] && git stash pop > /dev/null 2>&1
    unchanged=$((unchanged + 1))
    continue
  fi

  if ! git commit -m "$CUSTOM_MSG" >> "$log" 2>&1; then
    echo "✗ $name | commit failed (see $log)"
    [ "$did_stash" = "1" ] && git stash pop > /dev/null 2>&1
    errored=$((errored + 1))
    continue
  fi
  committed=$((committed + 1))

  # Push (unless local-only)
  if [ "$tier" = "local-only" ] || [ "$remote" = "none" ]; then
    echo "✓ $name | committed (local-only, no push)"
    [ "$did_stash" = "1" ] && git stash pop > /dev/null 2>&1
    continue
  fi

  # Try push, with one rebase retry
  if git push origin "$branch" >> "$log" 2>&1; then
    echo "✓ $name | committed + pushed"
    pushed=$((pushed + 1))
  else
    # Try fetch + pull-rebase + push
    git fetch origin --quiet 2>>"$log" || true
    if git pull --rebase origin "$branch" >> "$log" 2>&1 \
       && git push origin "$branch" >> "$log" 2>&1; then
      echo "✓ $name | committed + rebased + pushed"
      pushed=$((pushed + 1))
    else
      echo "✗ $name | push failed even after rebase (see $log)"
      git rebase --abort 2>/dev/null || true
      errored=$((errored + 1))
    fi
  fi

  [ "$did_stash" = "1" ] && git stash pop > /dev/null 2>&1

done < <(python3 "$SCRIPT_DIR/lib/parse-registry.py" "$REGISTRY" --tier="$TIER_FILTER")

# ── Summary ─────────────────────────────────────────────────────────────
echo
echo "Summary: $total repos | $unchanged unchanged | $committed committed | $pushed pushed | $errored errors"
[ "$errored" -gt 0 ] && exit 1
exit 0
