#!/usr/bin/env bash
# Fixture 05 — already on v6, no-op. See README.md.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
INSTALL="$REPO_ROOT/project/deployment/scripts/install.sh"

PASS=0; FAIL=0
check() {
    if eval "$2"; then PASS=$((PASS+1)); echo "  ✓ $1"
    else FAIL=$((FAIL+1)); echo "  ✗ $1"; fi
}

WORKDIR="$HOME/.cache/agent-11-fixture-05-$$"
trap 'rm -rf "$WORKDIR"' EXIT
rm -rf "$WORKDIR" && mkdir -p "$WORKDIR/.claude/agents"

cd "$WORKDIR"
git init -q
touch README.md .claude/agents/coordinator.md

# Already-v6 settings.json
cat > .claude/settings.json <<'JSON'
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "env": { "ENABLE_TOOL_SEARCH": "auto" },
  "hooks": { "PostToolUse": [], "PreToolUse": [] },
  "permissions": { "allow": ["Bash(test:*)"] }
}
JSON

# Snapshot original settings content (whitespace-normalised JSON for comparison)
ORIGINAL_HASH=$(python3 -c "import json,hashlib; print(hashlib.sha256(json.dumps(json.load(open('.claude/settings.json')), sort_keys=True).encode()).hexdigest())")

echo "Fixture 05: already on v6 (A11-ISS-9: shipped hooks propagate, then idempotent)"
echo "  workdir: $WORKDIR"

OUT=$(bash "$INSTALL" --upgrade 2>&1)

# A11-ISS-9 contract: a hooks key no longer short-circuits the merge. Run 1
# fills the empty hook lists with the current template hooks (MERGED); run 2
# must then be a true no-op with a stable file.
check "no v5 markers detected (no migration ran)" '! echo "$OUT" | grep -q "v5 markers found"'
check "run 1: merger reports MERGED (hooks propagated)" 'echo "$OUT" | grep -q "Merged v6 template into existing settings.json"'
check "run 1: gate-guard hook now present" 'grep -q "gate-guard.sh" .claude/settings.json'
check "run 1: gate-guard script deployed" '[[ -f .claude/hooks/gate-guard.sh ]]'
check "11 specialists deployed" '[[ $(ls .claude/agents/*.md 2>/dev/null | wc -l) -ge 11 ]]'
check "summary says Tool deferring enabled" 'echo "$OUT" | grep -q "Tool deferring enabled"'
check "user permission preserved" 'python3 -c "import json; d=json.load(open(\".claude/settings.json\")); assert \"Bash(test:*)\" in d[\"permissions\"][\"allow\"]" 2>/dev/null'

RUN1_HASH=$(python3 -c "import json,hashlib; print(hashlib.sha256(json.dumps(json.load(open('.claude/settings.json')), sort_keys=True).encode()).hexdigest())")
OUT2=$(bash "$INSTALL" --upgrade 2>&1)
RUN2_HASH=$(python3 -c "import json,hashlib; print(hashlib.sha256(json.dumps(json.load(open('.claude/settings.json')), sort_keys=True).encode()).hexdigest())")
check "run 2: merger reports already on v6 (idempotent)" 'echo "$OUT2" | grep -q "settings.json already on v6"'
check "run 2: settings.json content stable (semantic hash match)" '[[ "$RUN1_HASH" == "$RUN2_HASH" ]]'

echo "  PASS=$PASS FAIL=$FAIL"
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
