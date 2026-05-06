#!/usr/bin/env bash
# Fixture 01 — clean v5 install. See README.md for scenario.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
INSTALL="$REPO_ROOT/project/deployment/scripts/install.sh"

PASS=0; FAIL=0
check() {
    if eval "$2"; then PASS=$((PASS+1)); echo "  ✓ $1"
    else FAIL=$((FAIL+1)); echo "  ✗ $1"; fi
}

# Isolated workdir under user's home (avoids /tmp security guard in install.sh)
WORKDIR="$HOME/.cache/agent-11-fixture-01-$$"
trap 'rm -rf "$WORKDIR"' EXIT
rm -rf "$WORKDIR" && mkdir -p "$WORKDIR/.claude/agents" "$WORKDIR/.mcp-profiles" "$WORKDIR/mcp" "$WORKDIR/templates"

# Build pre-state
cd "$WORKDIR"
git init -q
echo "v5 handoff content" > handoff-notes.md
echo "{}" > mcp/dynamic-mcp.json
echo "v5 template" > templates/handoff-notes-template.md
echo '{"profiles":{}}' > .mcp-profiles/example.json
touch README.md .claude/agents/coordinator.md

echo "Fixture 01: clean v5 install"
echo "  workdir: $WORKDIR"

# Run installer
OUT=$(bash "$INSTALL" --upgrade 2>&1)

# Assertions
check "all 4 v5 markers removed" '[[ ! -f handoff-notes.md && ! -d .mcp-profiles && ! -f mcp/dynamic-mcp.json && ! -f templates/handoff-notes-template.md ]]'
check "agent-context.md created" '[[ -f agent-context.md ]]'
check "agent-context.md contains folded handoff content" 'grep -q "v5 handoff content" agent-context.md'
check "migration backup created" 'ls .claude/backups/v5-to-v6-* >/dev/null 2>&1'
check "11 specialists deployed" '[[ $(ls .claude/agents/*.md 2>/dev/null | wc -l) -ge 11 ]]'
check "settings.json deployed" '[[ -f .claude/settings.json ]]'
check "settings.json has ENABLE_TOOL_SEARCH" 'grep -q ENABLE_TOOL_SEARCH .claude/settings.json'
check "settings.json has hooks block" 'grep -q "\"hooks\"" .claude/settings.json'
check "summary says Tool deferring enabled" 'echo "$OUT" | grep -q "Tool deferring enabled"'
check "summary does NOT say NOT enabled" '! echo "$OUT" | grep -q "Tool deferring NOT enabled"'

echo "  PASS=$PASS FAIL=$FAIL"
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
