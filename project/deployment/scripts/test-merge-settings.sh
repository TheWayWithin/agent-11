#!/usr/bin/env bash
# test-merge-settings.sh — regression tests for the A11-ISS-9 hook-propagation
# contract in merge-settings.py. Rerunnable, self-contained (fixtures are
# embedded; the v6.2.0 fixture is the genuine f575973 template verbatim).
#
# Cases:
#   a) v6.2.0 settings with the old fail-open if-glob gate guard
#      -> guard replaced by the gate-guard.sh call, no 'if' field remains
#   b) user-added custom hooks alongside our stale hook
#      -> user hooks byte-identical, ours updated
#   c) no hooks at all -> full template hooks added
#   d) already-current -> NOOP_ALREADY_V6, file byte-unchanged
#   e) invalid JSON -> exit 1, file untouched
#   f) user-EDITED shipped hook (advisory promoted to blocking)
#      -> kept as-is, template version NOT added alongside (no duplicates)
#
# Run: bash project/deployment/scripts/test-merge-settings.sh

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
MERGER="$SCRIPT_DIR/merge-settings.py"
TEMPLATE="$REPO_ROOT/library/settings.json.template"

PASS=0; FAIL=0
check() {
    if eval "$2"; then PASS=$((PASS+1)); echo "  ✓ $1"
    else FAIL=$((FAIL+1)); echo "  ✗ $1"; fi
}

WORKDIR="$(mktemp -d -t merge-settings-test)"
trap 'rm -rf "$WORKDIR"' EXIT

# The genuine v6.2.0 template (git f575973) — carries the fail-open if-glob
# gate guard that A11-ISS-4 replaced. Kept verbatim so the test proves the
# STALE_SHIPPED_HOOKS catalogue matches what actually shipped.
cat > "$WORKDIR/settings-620.json" <<'JSON620'
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "_comment": "AGENT-11 default Claude Code settings. Hooks below are advisory by default — they run linters/typecheckers and output results, but do not block edits. To promote a hook to blocking, change `|| true` at the end of its command to `|| exit 2`. To disable a hook entirely, remove its entry from the array.",
  "_comment_permissions": "Read-only gates (Sprint 6a): an agent must not edit the criteria that judge its own work. The deny rules below make the quality-gate config and any gates/ directory unwritable by every agent, so a passing gate means the work was done, not that the threshold was loosened. To intentionally change a gate, edit the file as a deliberate human action with these rules temporarily removed; never let an agent do it mid-mission. Sprint 6c note: the Edit/Write/MultiEdit deny rules below do NOT cover Bash, so a PreToolUse 'read-only gate guard' hook blocks Bash writes (redirection, tee, sed -i, cp, mv) to gate paths and closes that route.",
  "env": {
    "ENABLE_TOOL_SEARCH": "auto"
  },
  "permissions": {
    "deny": [
      "Edit(.quality-gates.json)",
      "Write(.quality-gates.json)",
      "MultiEdit(.quality-gates.json)",
      "Edit(**/*.quality-gates.json)",
      "Write(**/*.quality-gates.json)",
      "Edit(gates/**)",
      "Write(gates/**)",
      "MultiEdit(gates/**)",
      "Edit(.gates/**)",
      "Write(.gates/**)"
    ]
  },
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "if": "Edit(*.ts|*.tsx)|Write(*.ts|*.tsx)|MultiEdit(*.ts|*.tsx)",
            "command": "command -v npx >/dev/null 2>&1 && [ -f package.json ] && [ -f tsconfig.json ] && npx --no-install tsc --noEmit 2>&1 || true",
            "statusMessage": "tsc --noEmit",
            "timeout": 60
          },
          {
            "type": "command",
            "if": "Edit(*.py)|Write(*.py)|MultiEdit(*.py)",
            "command": "command -v ruff >/dev/null 2>&1 && [ -f pyproject.toml ] && ruff check 2>&1 || true",
            "statusMessage": "ruff check",
            "timeout": 30
          },
          {
            "type": "command",
            "if": "Edit(*.rb)|Write(*.rb)|MultiEdit(*.rb)",
            "command": "command -v rubocop >/dev/null 2>&1 && [ -f Gemfile ] && rubocop --force-exclusion 2>&1 || true",
            "statusMessage": "rubocop",
            "timeout": 30
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "prompt",
            "if": "Bash(rm -rf *)|Bash(git push --force*)|Bash(git push -f *)|Bash(git reset --hard*)|Bash(git clean -f*)|Bash(git branch -D*)",
            "prompt": "This command is destructive and hard to reverse. Confirm to proceed: $ARGUMENTS",
            "timeout": 60
          },
          {
            "type": "command",
            "if": "Bash(* > *quality-gates.json*)|Bash(*>> *quality-gates.json*)|Bash(*tee *quality-gates*)|Bash(*sed -i*quality-gates*)|Bash(*cp * *quality-gates.json*)|Bash(*mv * *quality-gates.json*)|Bash(* > gates/*)|Bash(*>> gates/*)|Bash(*tee *gates/*)|Bash(*sed -i*gates/*)|Bash(*cp * gates/*)|Bash(*mv * gates/*)|Bash(* > .gates/*)|Bash(*tee *.gates/*)",
            "command": "echo 'BLOCKED (Sprint 6a/6c read-only gates): refusing a Bash write to a quality-gate path. The criteria that judge the work are not agent-editable. The Edit/Write deny rules do not cover Bash redirection, so this hook closes that route. To change a gate, do it as a deliberate human action.' >&2; exit 2",
            "statusMessage": "read-only gate guard",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
JSON620

echo "merge-settings.py A11-ISS-9 contract tests"
echo "  workdir: $WORKDIR"

# ---------- (a) stale v6.2.0 gate guard is replaced ----------
cp "$WORKDIR/settings-620.json" "$WORKDIR/a.json"
OUT_A=$(python3 "$MERGER" "$WORKDIR/a.json" "$TEMPLATE"); RC_A=$?
check "(a) exit 0, status MERGED" '[[ $RC_A -eq 0 && "$OUT_A" == "MERGED" ]]'
check "(a) old if-glob guard gone" '! grep -q "quality-gates.json\*" "$WORKDIR/a.json"'
check "(a) new gate-guard.sh call present" 'grep -q "gate-guard.sh" "$WORKDIR/a.json"'
check "(a) guard entry has no if field" 'python3 -c "
import json
d=json.load(open(\"$WORKDIR/a.json\"))
gs=[e for g in d[\"hooks\"][\"PreToolUse\"] for e in g[\"hooks\"] if e.get(\"statusMessage\")==\"read-only gate guard\"]
assert len(gs)==1 and \"if\" not in gs[0], gs"'
check "(a) result is valid JSON, permissions intact" 'python3 -c "
import json
d=json.load(open(\"$WORKDIR/a.json\"))
assert \"Edit(gates/**)\" in d[\"permissions\"][\"deny\"]"'

# ---------- (b) user custom hooks survive byte-identical ----------
python3 - "$WORKDIR" <<'PY'
import json, sys
w = sys.argv[1]
d = json.load(open(f"{w}/settings-620.json"))
d["hooks"]["PreToolUse"][0]["hooks"].append(
    {"type": "command", "command": "echo my-custom-audit >> .audit.log || true",
     "statusMessage": "my custom audit", "timeout": 5})
d["hooks"]["SessionStart"] = [
    {"matcher": "*", "hooks": [{"type": "command", "command": "echo hello"}]}]
json.dump(d, open(f"{w}/b.json", "w"), indent=2)
PY
OUT_B=$(python3 "$MERGER" "$WORKDIR/b.json" "$TEMPLATE"); RC_B=$?
check "(b) exit 0, status MERGED" '[[ $RC_B -eq 0 && "$OUT_B" == "MERGED" ]]'
check "(b) user hook entry byte-identical" 'python3 -c "
import json
d=json.load(open(\"$WORKDIR/b.json\"))
es=[e for g in d[\"hooks\"][\"PreToolUse\"] for e in g[\"hooks\"] if e.get(\"statusMessage\")==\"my custom audit\"]
assert es==[{\"type\":\"command\",\"command\":\"echo my-custom-audit >> .audit.log || true\",\"statusMessage\":\"my custom audit\",\"timeout\":5}], es"'
check "(b) user SessionStart group untouched" 'python3 -c "
import json
d=json.load(open(\"$WORKDIR/b.json\"))
assert d[\"hooks\"][\"SessionStart\"]==[{\"matcher\":\"*\",\"hooks\":[{\"type\":\"command\",\"command\":\"echo hello\"}]}]"'
check "(b) stale guard still replaced" 'grep -q "gate-guard.sh" "$WORKDIR/b.json" && ! grep -q "quality-gates.json\*" "$WORKDIR/b.json"'

# ---------- (c) no hooks at all -> full template add ----------
printf '{\n  "env": {"FOO": "bar"},\n  "permissions": {"allow": ["Bash(ls:*)"]}\n}\n' > "$WORKDIR/c.json"
OUT_C=$(python3 "$MERGER" "$WORKDIR/c.json" "$TEMPLATE"); RC_C=$?
check "(c) exit 0, status MERGED" '[[ $RC_C -eq 0 && "$OUT_C" == "MERGED" ]]'
check "(c) template hooks + ENABLE_TOOL_SEARCH added, user keys kept" 'python3 -c "
import json
d=json.load(open(\"$WORKDIR/c.json\"))
assert \"PreToolUse\" in d[\"hooks\"] and \"PostToolUse\" in d[\"hooks\"]
assert d[\"env\"][\"FOO\"]==\"bar\" and d[\"env\"][\"ENABLE_TOOL_SEARCH\"]==\"auto\"
assert d[\"permissions\"][\"allow\"]==[\"Bash(ls:*)\"]"'
check "(c) gate-guard.sh call present" 'grep -q "gate-guard.sh" "$WORKDIR/c.json"'

# ---------- (d) already-current -> NOOP, byte-unchanged ----------
cp "$TEMPLATE" "$WORKDIR/d.json"
H1=$(shasum "$WORKDIR/d.json")
OUT_D=$(python3 "$MERGER" "$WORKDIR/d.json" "$TEMPLATE"); RC_D=$?
H2=$(shasum "$WORKDIR/d.json")
check "(d) exit 0, status NOOP_ALREADY_V6" '[[ $RC_D -eq 0 && "$OUT_D" == "NOOP_ALREADY_V6" ]]'
check "(d) file byte-unchanged" '[[ "$H1" == "$H2" ]]'

# ---------- (e) invalid JSON -> refused, untouched ----------
printf '{ "env": { "ENABLE_TOOL_SEARCH": "auto", }\n' > "$WORKDIR/e.json"
H1=$(shasum "$WORKDIR/e.json")
OUT_E=$(python3 "$MERGER" "$WORKDIR/e.json" "$TEMPLATE" 2>/dev/null); RC_E=$?
H2=$(shasum "$WORKDIR/e.json")
check "(e) exit 1 on invalid JSON" '[[ $RC_E -eq 1 ]]'
check "(e) file untouched" '[[ "$H1" == "$H2" ]]'
check "(e) no .new litter" '[[ ! -f "$WORKDIR/e.json.new" ]]'

# ---------- (f) user-edited shipped hook kept, not duplicated ----------
python3 - "$WORKDIR" <<'PY'
import json, sys
w = sys.argv[1]
d = json.load(open(f"{w}/settings-620.json"))
for g in d["hooks"]["PostToolUse"]:
    for e in g["hooks"]:
        if e.get("statusMessage") == "tsc --noEmit":
            e["command"] = e["command"].replace("|| true", "|| exit 2")  # promoted to blocking
json.dump(d, open(f"{w}/f.json", "w"), indent=2)
PY
OUT_F=$(python3 "$MERGER" "$WORKDIR/f.json" "$TEMPLATE"); RC_F=$?
check "(f) exit 0 (stale guard still needs replacing)" '[[ $RC_F -eq 0 && "$OUT_F" == "MERGED" ]]'
check "(f) promoted tsc hook kept, exactly one, not reverted" 'python3 -c "
import json
d=json.load(open(\"$WORKDIR/f.json\"))
es=[e for g in d[\"hooks\"][\"PostToolUse\"] for e in g[\"hooks\"] if e.get(\"statusMessage\")==\"tsc --noEmit\"]
assert len(es)==1 and es[0][\"command\"].endswith(\"|| exit 2\"), es"'

echo "  PASS=$PASS FAIL=$FAIL"
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
