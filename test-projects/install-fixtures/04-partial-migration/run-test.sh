#!/usr/bin/env bash
# Fixture 04 — partial migration recovery. See README.md.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
INSTALL="$REPO_ROOT/project/deployment/scripts/install.sh"

PASS=0; FAIL=0
check() {
    if eval "$2"; then PASS=$((PASS+1)); echo "  ✓ $1"
    else FAIL=$((FAIL+1)); echo "  ✗ $1"; fi
}

WORKDIR="$HOME/.cache/agent-11-fixture-04-$$"
trap 'rm -rf "$WORKDIR"' EXIT
rm -rf "$WORKDIR" && mkdir -p "$WORKDIR/.claude/agents" "$WORKDIR/templates" "$WORKDIR/.claude/backups/v5-to-v6-20260101-120000"

cd "$WORKDIR"
git init -q
touch README.md .claude/agents/coordinator.md
# Only ONE v5 marker remaining (interrupted prior run)
touch templates/handoff-notes-template.md
# Pre-existing backup directory from the interrupted run
echo "stub" > .claude/backups/v5-to-v6-20260101-120000/handoff-notes.md
# Valid settings.json (no v6 features)
echo '{"permissions":{"allow":["Bash(ls:*)"]}}' > .claude/settings.json

echo "Fixture 04: partial-migration recovery"
echo "  workdir: $WORKDIR"

OUT=$(bash "$INSTALL" --upgrade 2>&1)

check "remaining v5 marker cleaned" '[[ ! -f templates/handoff-notes-template.md ]]'
check "old backup directory preserved" '[[ -d .claude/backups/v5-to-v6-20260101-120000 ]]'
check "new backup directory created (different timestamp)" '[[ $(ls -d .claude/backups/v5-to-v6-* 2>/dev/null | wc -l) -ge 2 ]]'
check "Prior migration backup notice in output" 'echo "$OUT" | grep -q "Prior migration backup found"'
check "completing remaining steps notice" 'echo "$OUT" | grep -q "completing the remaining migration steps"'
check "settings merged: ENABLE_TOOL_SEARCH added" 'grep -q ENABLE_TOOL_SEARCH .claude/settings.json'
check "settings merged: original permission preserved" 'python3 -c "import json; d=json.load(open(\".claude/settings.json\")); assert \"Bash(ls:*)\" in d[\"permissions\"][\"allow\"]" 2>/dev/null'
check "11 specialists deployed" '[[ $(ls .claude/agents/*.md 2>/dev/null | wc -l) -ge 11 ]]'
check "summary says Tool deferring enabled" 'echo "$OUT" | grep -q "Tool deferring enabled"'

echo "  PASS=$PASS FAIL=$FAIL"
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
