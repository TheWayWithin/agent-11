#!/usr/bin/env bash
# Fixture 02 — v5 + user-customised settings.json. See README.md.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
INSTALL="$REPO_ROOT/project/deployment/scripts/install.sh"

PASS=0; FAIL=0
check() {
    if eval "$2"; then PASS=$((PASS+1)); echo "  ✓ $1"
    else FAIL=$((FAIL+1)); echo "  ✗ $1"; fi
}

WORKDIR="$HOME/.cache/agent-11-fixture-02-$$"
trap 'rm -rf "$WORKDIR"' EXIT
rm -rf "$WORKDIR" && mkdir -p "$WORKDIR/.claude/agents" "$WORKDIR/.mcp-profiles" "$WORKDIR/mcp" "$WORKDIR/templates"

cd "$WORKDIR"
git init -q
touch handoff-notes.md mcp/dynamic-mcp.json templates/handoff-notes-template.md README.md .claude/agents/coordinator.md
echo '{"profiles":{}}' > .mcp-profiles/example.json

# Custom settings.json — the user's pre-v6 file
cat > .claude/settings.json <<'JSON'
{
  "_comment": "user's hand-tuned config — must survive the upgrade",
  "permissions": {
    "allow": ["Bash(git status:*)", "Read", "Write"],
    "deny": ["Bash(rm -rf:*)", "Bash(sudo:*)"]
  },
  "env": {
    "CUSTOM_PROJECT_VAR": "live",
    "DEBUG_LEVEL": "verbose"
  }
}
JSON

echo "Fixture 02: v5 + custom settings.json"
echo "  workdir: $WORKDIR"

OUT=$(bash "$INSTALL" --upgrade 2>&1)

# Verify all the user's customisations survived
check "permissions.allow includes Bash(git status:*)" 'python3 -c "import json; d=json.load(open(\".claude/settings.json\")); assert \"Bash(git status:*)\" in d[\"permissions\"][\"allow\"]" 2>/dev/null'
check "permissions.allow includes Read" 'python3 -c "import json; d=json.load(open(\".claude/settings.json\")); assert \"Read\" in d[\"permissions\"][\"allow\"]" 2>/dev/null'
check "permissions.deny includes Bash(rm -rf:*)" 'python3 -c "import json; d=json.load(open(\".claude/settings.json\")); assert \"Bash(rm -rf:*)\" in d[\"permissions\"][\"deny\"]" 2>/dev/null'
check "_comment preserved" 'python3 -c "import json; d=json.load(open(\".claude/settings.json\")); assert \"hand-tuned\" in d[\"_comment\"]" 2>/dev/null'
check "CUSTOM_PROJECT_VAR preserved" 'python3 -c "import json; d=json.load(open(\".claude/settings.json\")); assert d[\"env\"][\"CUSTOM_PROJECT_VAR\"] == \"live\"" 2>/dev/null'
check "DEBUG_LEVEL preserved" 'python3 -c "import json; d=json.load(open(\".claude/settings.json\")); assert d[\"env\"][\"DEBUG_LEVEL\"] == \"verbose\"" 2>/dev/null'
check "ENABLE_TOOL_SEARCH added" 'python3 -c "import json; d=json.load(open(\".claude/settings.json\")); assert d[\"env\"][\"ENABLE_TOOL_SEARCH\"] == \"auto\"" 2>/dev/null'
check "hooks block added" 'python3 -c "import json; d=json.load(open(\".claude/settings.json\")); assert \"PostToolUse\" in d[\"hooks\"]" 2>/dev/null'
check "settings.json backup created" 'ls .claude/settings.json.backup-* >/dev/null 2>&1'
check "summary says Tool deferring enabled" 'echo "$OUT" | grep -q "Tool deferring enabled"'

echo "  PASS=$PASS FAIL=$FAIL"
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
