#!/bin/sh
# AGENT-11 read-only gate guard (Sprint 6a/6c; reworked for A11-ISS-4).
#
# PreToolUse hook for Bash. Blocks the common Bash write forms against
# quality-gate paths (.quality-gates.json, *quality-gates.json, gates/,
# .gates/) — the route the Edit deny rules cannot cover. Everything else
# is allowed.
#
# WHAT IT CATCHES: redirection (> >>), tee, sed -i, cp, mv, rm, truncate,
# dd of=, ln -s, and in-place interpreter edits (perl -i, ruby -i).
#
# WHAT IT DOES NOT CATCH, and no shell guard can:
#   - writes through an interpreter:  python3 -c "open('.quality-gates.json','w')..."
#   - variable indirection:           G=.quality-gates.json; echo x > $G
#   - anything encoded, eval'd, or written by a program it launches
#
# This is a speed bump against the accidental and the lazy, NOT a security
# boundary. It raises the cost of the obvious routes; it does not close the
# category. Any claim that it "closes the Bash route" is false — see
# A11-ISS-16. The enforceable guarantee is the Edit() deny rules, which the
# tool layer applies and which no phrasing can route around.
#
# stdin:  Claude Code hook payload JSON ({"tool_input":{"command":"..."}})
# exit 0: allow the Bash call
# exit 2: block it (stderr is fed back to the model)
#
# History: the original guard matched via a hook `if` glob in settings.json.
# That filter fails open on complex commands (multi-line loops, redirections),
# so ordinary non-gate Bash was blocked (A11-ISS-4). The decision now happens
# here, against the actual command string.

input=$(cat 2>/dev/null) || input=""

# Fast allow: nothing gate-like anywhere in the payload.
printf '%s' "$input" | grep -q 'gates' || exit 0

# Extract tool_input.command (jq, then python3, then raw-JSON fallback).
cmd=""
if command -v jq >/dev/null 2>&1; then
    cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)
fi
if [ -z "$cmd" ] && command -v python3 >/dev/null 2>&1; then
    cmd=$(printf '%s' "$input" | python3 -c 'import json,sys
try:
    print(json.load(sys.stdin).get("tool_input", {}).get("command", ""))
except Exception:
    pass' 2>/dev/null)
fi
[ -n "$cmd" ] || cmd="$input"

# Gate targets:
#   qg — a token containing quality-gates (.quality-gates.json etc.)
#   gd — a path starting at gates/ or .gates/ (delegates/ must NOT match)
qg='[^[:space:]"'\'']*quality-gates'
gd='(\./)?\.?gates/'

blocked=""
# 1. Redirection into a gate path:  > .quality-gates.json / >> gates/x
if printf '%s' "$cmd" | grep -qE "[0-9]?>>?[[:space:]]*[\"']?(${gd}|${qg}\.json)"; then
    blocked=yes
# 2. tee into a gate path:  tee .quality-gates.json / tee -a gates/x
elif printf '%s' "$cmd" | grep -qE "(^|[;&|[:space:]])tee[[:space:]]([^;&|]*[[:space:]\"'=])?(${gd}|${qg})"; then
    blocked=yes
# 3. sed -i on a gate path
elif printf '%s' "$cmd" | grep -qE "(^|[;&|[:space:]])sed[[:space:]]+[^;&|]*-i[^;&|]*[[:space:]\"'=](${gd}|${qg})"; then
    blocked=yes
# 4. cp/mv onto a gate path
elif printf '%s' "$cmd" | grep -qE "(^|[;&|[:space:]])(cp|mv)[[:space:]]([^;&|]*[[:space:]\"'=])?(${gd}|${qg}\.json)"; then
    blocked=yes
# 5. rm / truncate / shred / unlink of a gate path — deleting a gate passes it
#    just as effectively as lowering it.
elif printf '%s' "$cmd" | grep -qE "(^|[;&|[:space:]])(rm|truncate|shred|unlink)[[:space:]]([^;&|]*[[:space:]\"'=])?(${gd}|${qg})"; then
    blocked=yes
# 6. dd of= a gate path
elif printf '%s' "$cmd" | grep -qE "(^|[;&|[:space:]])dd[[:space:]][^;&|]*of=[\"']?(${gd}|${qg})"; then
    blocked=yes
# 7. ln -s over a gate path — replacing it with a symlink is a write.
elif printf '%s' "$cmd" | grep -qE "(^|[;&|[:space:]])ln[[:space:]]+[^;&|]*-[a-z]*s[^;&|]*[[:space:]\"'](${gd}|${qg})"; then
    blocked=yes
# 8. in-place interpreter edits: perl -i / ruby -i on a gate path.
elif printf '%s' "$cmd" | grep -qE "(^|[;&|[:space:]])(perl|ruby)[[:space:]]+[^;&|]*-[a-z]*i[^;&|]*[[:space:]\"'=](${gd}|${qg})"; then
    blocked=yes
fi

if [ -n "$blocked" ]; then
    echo 'BLOCKED (Sprint 6a/6c read-only gates): refusing a Bash write to a quality-gate path. The criteria that judge the work are not agent-editable. The Edit/Write deny rules do not cover Bash redirection, so this hook closes that route. To change a gate, do it as a deliberate human action.' >&2
    exit 2
fi
exit 0
