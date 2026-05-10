#!/bin/bash
# audit.sh — Read-only fleet audit for agent-11 deployments
#
# Reports per-repo state: path existence, v5 markers, library drift,
# git branch, uncommitted file count, computed status flag.
#
# Usage:
#   bash audit.sh [--tier=<filter>] [--registry=<path>] [--source=<path>]
#
# Defaults:
#   --tier=active,local-only,dormant
#   --registry=$AGENT11_FLEET_REGISTRY or ~/shared/tools/agent-11-fleet/registry.yaml
#   --source=<this script's repo root> (resolved automatically)
#
# Reads, never writes. Safe to run any time.

set -euo pipefail

# ── Resolve script paths ────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
REGISTRY="${AGENT11_FLEET_REGISTRY:-$HOME/shared/tools/agent-11-fleet/registry.yaml}"
TIER_FILTER="active,local-only,dormant"

# ── Parse args ──────────────────────────────────────────────────────────
for arg in "$@"; do
  case "$arg" in
    --tier=*) TIER_FILTER="${arg#--tier=}" ;;
    --registry=*) REGISTRY="${arg#--registry=}" ;;
    --source=*) SOURCE_ROOT="${arg#--source=}" ;;
    --help|-h)
      grep '^#' "$0" | sed 's/^# \?//' | head -25
      exit 0
      ;;
  esac
done

if [ ! -f "$REGISTRY" ]; then
  echo "ERROR: registry not found at $REGISTRY" >&2
  echo "Set AGENT11_FLEET_REGISTRY env var, or pass --registry=<path>" >&2
  exit 2
fi
if [ ! -d "$SOURCE_ROOT/library" ]; then
  echo "ERROR: source root has no library/ dir: $SOURCE_ROOT" >&2
  exit 2
fi

SOURCE_HASH=$(shasum -a 256 "$SOURCE_ROOT/library/CLAUDE.md" 2>/dev/null | awk '{print $1}')
[ -z "$SOURCE_HASH" ] && { echo "ERROR: cannot hash $SOURCE_ROOT/library/CLAUDE.md" >&2; exit 2; }

# ── Header ──────────────────────────────────────────────────────────────
TS=$(date +"%Y-%m-%d %H:%M")
echo "=== AGENT-11 Fleet Audit ($TS) ==="
echo "Registry: $REGISTRY"
echo "Source:   $SOURCE_ROOT  (library/CLAUDE.md @ ${SOURCE_HASH:0:8})"
echo "Tiers:    $TIER_FILTER"
echo
printf "%-22s | %-10s | %-10s | %-7s | %-9s | %-6s | %s\n" \
  "Repo" "Tier" "v5 markers" "Library" "Branch" "Uncomm" "Status"
printf '%s\n' "─────────────────────────────────────────────────────────────────────────────────────────────"

# ── Counters ────────────────────────────────────────────────────────────
declare -i total=0 ok=0 needs_upgrade=0 drifted=0 missing=0 errored=0

# ── Loop ────────────────────────────────────────────────────────────────
while IFS=$'\t' read -r name path remote branch tier notes; do
  total=$((total + 1))

  # Path existence check
  if [ ! -d "$path" ]; then
    printf "%-22s | %-10s | %-10s | %-7s | %-9s | %-6s | %s\n" \
      "$name" "$tier" "—" "—" "—" "—" "MISSING"
    missing=$((missing + 1))
    continue
  fi

  # v5 markers (D-vs-presence not relevant here — just count files that exist)
  v5=0
  [ -f "$path/handoff-notes.md" ] && v5=$((v5 + 1))
  [ -d "$path/.mcp-profiles" ] && v5=$((v5 + 1))
  [ -f "$path/mcp/dynamic-mcp.json" ] && v5=$((v5 + 1))
  [ -f "$path/templates/handoff-notes-template.md" ] && v5=$((v5 + 1))

  # Special case: Trader-7-style repos may have a re-introduced handoff-notes.md
  # as legitimate project content. We can't distinguish here without git history.
  # The bulk apply scripts handle this with a D-vs-M check; audit just reports.
  if [ "$v5" = "0" ]; then
    v5_str="clean"
  else
    v5_str="${v5} marker$([ "$v5" = "1" ] || echo s)"
  fi

  # Library drift
  if [ -f "$path/.claude/CLAUDE.md" ]; then
    deployed_hash=$(shasum -a 256 "$path/.claude/CLAUDE.md" 2>/dev/null | awk '{print $1}')
    if [ "$deployed_hash" = "$SOURCE_HASH" ]; then
      lib_status="match"
    else
      lib_status="drift"
      drifted=$((drifted + 1))
    fi
  else
    lib_status="absent"
    drifted=$((drifted + 1))
  fi

  # Git state
  if [ -d "$path/.git" ]; then
    cur_branch=$(git -C "$path" branch --show-current 2>/dev/null || echo "?")
    uncomm=$(git -C "$path" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  else
    cur_branch="no-git"
    uncomm="—"
  fi

  # Compute status
  if [ "$v5" -gt 0 ]; then
    status="needs upgrade"
    needs_upgrade=$((needs_upgrade + 1))
  elif [ "$lib_status" = "drift" ] || [ "$lib_status" = "absent" ]; then
    status="library drift"
  elif [ "$tier" = "local-only" ]; then
    status="ok (local-only)"
    ok=$((ok + 1))
  else
    status="ok"
    ok=$((ok + 1))
  fi

  printf "%-22s | %-10s | %-10s | %-7s | %-9s | %-6s | %s\n" \
    "$name" "$tier" "$v5_str" "$lib_status" "$cur_branch" "$uncomm" "$status"

done < <(python3 "$SCRIPT_DIR/lib/parse-registry.py" "$REGISTRY" --tier="$TIER_FILTER")

# ── Summary ─────────────────────────────────────────────────────────────
echo
echo "Summary: $total repos | $ok ok | $needs_upgrade need upgrade | $drifted drifted | $missing missing"

# Exit code reflects state: 0 if everything ok, 1 if any drift/missing/upgrade-needed
if [ "$needs_upgrade" -gt 0 ] || [ "$drifted" -gt 0 ] || [ "$missing" -gt 0 ]; then
  exit 1
fi
exit 0
