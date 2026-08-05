#!/usr/bin/env bash
#
# verify-upgraded-repo.sh — did `install.sh --upgrade` do what it claimed, and only that?
#
# Run immediately after upgrading one repo. Twelve criteria, every one default-fail and
# flipped only by evidence read off disk. Prints PASS/FAIL per criterion, exits non-zero
# if any failed.
#
#   Usage: scripts/verify-upgraded-repo.sh <repo-name> [<snapshot-dir>]
#
#   Take the snapshot BEFORE upgrading:
#     git -C <path> status --porcelain > <snapshot-dir>/pre-<repo>.txt
#     git -C <path> rev-parse HEAD     > <snapshot-dir>/head-<repo>.txt
#
# WHY THIS LIVES IN THE REPO NOW. It was written inline during the T-245 sweep and raised
# THREE false alarms across eight repos: it counted the missions directory instead of
# comparing against agent-11's set (a repo's own mission read as a failure), it flagged a
# three-month-old .mcp-status.md as newly created (it tested existence, not creation), and
# it filtered framework files out of the "after" list but not the "before" list, so every
# repo with pre-existing framework dirt reported that user work had changed.
#
# A check that cries wolf three times is worse than no check: by the third time the person
# reading it has learned to wave it through, which is exactly when it would have caught
# something real. All three came from comparing the wrong things rather than from the
# upgrades, and all three are fixed here.
#
set -uo pipefail
R="${1:?usage: verify-upgraded-repo.sh <repo-name> [snapshot-dir]}"
SNAP="${2:-/tmp}"
LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
D="$HOME/DevProjects/$R"
fail=0
ck(){ if [ "$2" = ok ]; then printf "  PASS  %s\n" "$1"; else printf "  FAIL  %s (%s)\n" "$1" "$2"; fail=1; fi; }

[ -d "$D" ] || { echo "  FAIL  repo not found: $D"; exit 1; }

# Everything install.sh deploys. Used to filter BOTH sides of the user-work comparison —
# filtering only one side was the third false alarm.
FRAMEWORK='^...(\.claude/|missions/|templates/|field-manual/|schemas/|gates/|stack-profiles/|docs/|\.mcp\.json|\.env\.mcp|mcp-setup\.sh)'

v=$(python3 -c "import json;print(json.load(open('$D/.claude/agent-11-version'))['version'])" 2>/dev/null)
[ -n "$v" ] && ck "version stamp = $v" ok || ck "version stamp" "absent"

n=$(ls -1 "$D/.claude/agents"/*.md 2>/dev/null | wc -l | tr -d ' ')
[ "${n:-0}" -ge 11 ] && ck "specialists deployed ($n)" ok || ck "specialists" "${n:-0}"

# Compare against agent-11's mission SET, never a count: a repo may carry its own missions.
miss=""
for f in "$LIB/project/missions"/*.md; do
  b=$(basename "$f"); [ -f "$D/missions/$b" ] || miss="$miss $b"
done
own=$(for f in "$D"/missions/*.md; do b=$(basename "$f"); \
  [ -f "$LIB/project/missions/$b" ] || echo "$b"; done 2>/dev/null | grep -c . || true)
[ -z "$miss" ] && ck "all agent-11 missions deployed (+${own:-0} repo-owned, untouched)" ok \
               || ck "missions" "missing:$miss"

g=$(python3 -c "
import json
G=['Edit(.quality-gates.json)','Edit(**/*.quality-gates.json)','Edit(gates/**)','Edit(.gates/**)']
d=(json.load(open('$D/.claude/settings.json')).get('permissions') or {}).get('deny') or []
print(sum(1 for x in G if x in d))" 2>/dev/null)
[ "${g:-0}" = 4 ] && ck "gate deny rules 4/4" ok || ck "gate deny rules" "${g:-0}/4"

[ -s "$D/.claude/hooks/gate-guard.sh" ] && ck "gate-guard.sh installed" ok || ck "gate-guard.sh" "missing"
python3 -c "
import json,sys
h=(json.load(open('$D/.claude/settings.json')).get('hooks') or {}).get('PreToolUse') or []
sys.exit(0 if any('gate-guard.sh' in json.dumps(x) and 'Bash' in str(x.get('matcher','')) for x in h) else 1)" 2>/dev/null \
  && ck "gate-guard wired PreToolUse/Bash" ok || ck "gate-guard wiring" "not wired"

# The guard must actually refuse, not merely exist. Cheap, and it is the whole point.
probe(){ printf '{"tool_name":"Bash","tool_input":{"command":%s}}' \
  "$(python3 -c 'import json,sys;print(json.dumps(sys.argv[1]))' "$1")" \
  | sh "$D/.claude/hooks/gate-guard.sh" >/dev/null 2>&1; echo $?; }
if [ -s "$D/.claude/hooks/gate-guard.sh" ]; then
  [ "$(probe 'echo x > .quality-gates.json')" = 2 ] && [ "$(probe 'npm test')" = 0 ] \
    && ck "gate-guard refuses a gate write and permits npm test" ok \
    || ck "gate-guard behaviour" "does not block, or blocks ordinary work"
fi

[ -f "$D/.claude/scripts/mission-state.py" ] && ck "mission-state.py installed" ok || ck "mission-state.py" "missing"

o=$(grep -l "ORIENTATION PROTOCOL" "$D/.claude/agents"/*.md 2>/dev/null | wc -l | tr -d ' ')
[ "${o:-0}" -ge 11 ] && ck "orientation protocol in $o agents" ok || ck "orientation" "${o:-0} agents"

# New in-repo backups: compare against the snapshot, do not test existence. Testing
# existence flagged a three-month-old .mcp-status.md as newly created.
newb=$(find "$D/.claude" -name "*.backup-*" -newer "$SNAP/head-$R.txt" 2>/dev/null | wc -l | tr -d ' ')
[ "${newb:-0}" = 0 ] && ck "no new in-repo backups" ok || ck "in-repo backups" "$newb new"

# User work: BOTH sides filtered identically.
if [ -f "$SNAP/pre-$R.txt" ]; then
  pre=$(grep -v '^??' "$SNAP/pre-$R.txt" | grep -vE "$FRAMEWORK" | sort)
  now=$(git -C "$D" status --porcelain | grep -v '^??' | grep -vE "$FRAMEWORK" | sort)
  [ "$pre" = "$now" ] && ck "non-framework files unchanged by the upgrade" ok \
                      || { ck "user work" "differs"; diff <(echo "$pre") <(echo "$now") | sed 's/^/        /'; }
else
  ck "user work" "no snapshot at $SNAP/pre-$R.txt — cannot prove"
fi

if [ -f "$SNAP/head-$R.txt" ]; then
  [ "$(git -C "$D" rev-parse HEAD)" = "$(cat "$SNAP/head-$R.txt")" ] && ck "no commits made" ok || ck "HEAD" "moved"
else
  ck "no commits made" "no snapshot"
fi
exit "$fail"
