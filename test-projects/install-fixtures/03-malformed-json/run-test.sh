#!/usr/bin/env bash
# Fixture 03 — v5 + malformed settings.json. See README.md.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
INSTALL="$REPO_ROOT/project/deployment/scripts/install.sh"

PASS=0; FAIL=0
check() {
    if eval "$2"; then PASS=$((PASS+1)); echo "  ✓ $1"
    else FAIL=$((FAIL+1)); echo "  ✗ $1"; fi
}

WORKDIR="$HOME/.cache/agent-11-fixture-03-$$"
trap 'rm -rf "$WORKDIR"' EXIT
rm -rf "$WORKDIR" && mkdir -p "$WORKDIR/.claude/agents" "$WORKDIR/.mcp-profiles" "$WORKDIR/mcp" "$WORKDIR/templates"

cd "$WORKDIR"
git init -q
touch handoff-notes.md mcp/dynamic-mcp.json templates/handoff-notes-template.md README.md .claude/agents/coordinator.md
echo '{"profiles":{}}' > .mcp-profiles/example.json

# Malformed settings.json — trailing comma
ORIGINAL_MALFORMED='{"env":{"FOO":"bar",},"permissions":{"allow":["Bash(custom:*)"]}}'
printf '%s' "$ORIGINAL_MALFORMED" > .claude/settings.json

echo "Fixture 03: v5 + malformed settings.json"
echo "  workdir: $WORKDIR"

OUT=$(bash "$INSTALL" --upgrade 2>&1)

check "v5 markers still cleaned (migration ran)" '[[ ! -f handoff-notes.md && ! -d .mcp-profiles ]]'
check "merger reported failure" 'echo "$OUT" | grep -q "settings.json merge failed"'
check "settings.json restored to original (still malformed)" '[[ "$(cat .claude/settings.json)" == "$ORIGINAL_MALFORMED" ]]'
check "backup file created" 'ls .claude/settings.json.backup-* >/dev/null 2>&1'
check "summary says Tool deferring NOT enabled" 'echo "$OUT" | grep -q "Tool deferring NOT enabled"'
check "summary points at docs/UPGRADE.md" 'echo "$OUT" | grep -q "docs/UPGRADE.md"'
check "summary mentions restore script" 'echo "$OUT" | grep -q "restore-pre-upgrade.sh"'
check "11 specialists still deployed" '[[ $(ls .claude/agents/*.md 2>/dev/null | wc -l) -ge 11 ]]'

echo "  PASS=$PASS FAIL=$FAIL"
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
