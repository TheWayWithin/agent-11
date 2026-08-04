#!/bin/sh
# AGENT-11 read-only gate guard (Sprint 6a/6c; reworked for A11-ISS-4, hardened for A11-ISS-16).
#
# PreToolUse hook for Bash. Blocks the common Bash write forms against
# quality-gate paths (.quality-gates.json, *quality-gates.json, gates/,
# .gates/) — the route the Edit deny rules cannot cover. Everything else
# is allowed.
#
# WHAT IT CATCHES — 12 branches, and the list below is the branch list. Keep
# them in step: an audit once found this header undercounting its own logic by
# two, which is the same class of defect as overclaiming, pointed the other way.
#
#   1. redirection            > >> into a gate path
#   2. tee                    tee / tee -a a gate path
#   3. sed -i                 in-place sed on a gate path
#   4. cp / mv                onto a gate path
#   5. rm / truncate / shred / unlink   of a gate path
#   6. dd of=                 a gate path
#   7. ln -s                  over a gate path
#   8. perl -i / ruby -i      in-place interpreter edit of a gate path
#   9. interpreter one-liner  python/python3/node/ruby/perl/php with -c/-e, a
#                             literal gate path, AND a write verb (A11-ISS-16)
#  10. variable indirection   G=<gate path> … then a write through $G, for the
#                             write forms in branches 1-7 (A11-ISS-16)
#  11. patch / git apply      applying a diff to a gate path
#  12. git checkout / restore / rm / mv   on a gate path (reverting or deleting
#                             a gate changes the criteria as surely as editing it)
#
# HOW EACH BRANCH MATCHES ITS TARGET. Every branch accepts the gate path with or
# without leading directory components (gates/x and project/gates/x both match),
# and every command-anchored branch accepts the command quoted or given by path
# (rm, "rm" and /bin/rm all match). Until 2026-08-04 none of that was true: the
# patterns required a bare relative path and a bare command name, so
# `echo x > project/gates/foo.json` and `/bin/rm -f .quality-gates.json` walked
# past a header claiming to catch redirection and rm. The probe list in
# scripts/validate-sprint6-closeout.sh tested one spelling per branch and passed
# it clean, which is why it now tests several.
#
# WHAT IT DOES NOT CATCH, and no shell guard can:
#   - a gate path assembled at runtime:  P=ga; P="${P}tes/x"; echo y > "$P"
#   - anything encoded, eval'd, or piped through base64/xxd before execution
#   - a write performed by a program it launches (a script, a make target, an
#     installed tool) rather than by the command string itself
#   - an interpreter one-liner that reaches the path indirectly, e.g. through
#     os.environ, a glob, or a path built by string concatenation
#   - a heredoc fed to an interpreter on stdin (`python3 <<'EOF'`) rather than
#     passed with -c
#   - a shell alias or function that renames a write command
#   - a path reached through a symlink whose name contains no "gates" segment
#
# Branches 9 and 10 raise the cost of the two forms A11-ISS-16 named. They do
# not close the category, and nothing in this file should be read as claiming
# they do.
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
# gd — a gates/ or .gates/ path SEGMENT, wherever it sits in the path. The optional
# leading group must end in "/", which is what keeps delegates/ and aggregates/ from
# matching: neither has a slash immediately before "gates/". Before 2026-08-04 gd had no
# leading group at all, so `echo x > project/gates/foo.json` walked past every branch
# while the bare form was blocked -- the header claimed a coverage the code did not have.
gd='([^[:space:]"'\'';&|]*/)?\.?gates/'
# c — the start of a command word: optional quoting and an optional path to the binary.
# Without this, /bin/rm and "rm" evaded every command-anchored branch.
c='(^|[;&|[:space:]])["'\'']?([^[:space:];&|"'\'']*/)?'

blocked=""
# 1. Redirection into a gate path:  > .quality-gates.json / >> gates/x
if printf '%s' "$cmd" | grep -qE "[0-9]?>>?[[:space:]]*[\"']?(${gd}|${qg}\.json)"; then
    blocked=yes
# 2. tee into a gate path:  tee .quality-gates.json / tee -a gates/x
elif printf '%s' "$cmd" | grep -qE "${c}tee[\"']?[[:space:]]([^;&|]*[[:space:]\"'=])?(${gd}|${qg})"; then
    blocked=yes
# 3. sed -i on a gate path
elif printf '%s' "$cmd" | grep -qE "${c}sed[\"']?[[:space:]]+[^;&|]*-i[^;&|]*[[:space:]\"'=](${gd}|${qg})"; then
    blocked=yes
# 4. cp/mv onto a gate path
elif printf '%s' "$cmd" | grep -qE "${c}(cp|mv)[\"']?[[:space:]]([^;&|]*[[:space:]\"'=])?(${gd}|${qg}\.json)"; then
    blocked=yes
# 5. rm / truncate / shred / unlink of a gate path — deleting a gate passes it
#    just as effectively as lowering it.
elif printf '%s' "$cmd" | grep -qE "${c}(rm|truncate|shred|unlink)[\"']?[[:space:]]([^;&|]*[[:space:]\"'=])?(${gd}|${qg})"; then
    blocked=yes
# 6. dd of= a gate path
elif printf '%s' "$cmd" | grep -qE "${c}dd[\"']?[[:space:]][^;&|]*of=[\"']?(${gd}|${qg})"; then
    blocked=yes
# 7. ln -s over a gate path — replacing it with a symlink is a write.
elif printf '%s' "$cmd" | grep -qE "${c}ln[\"']?[[:space:]]+[^;&|]*-[a-z]*s[^;&|]*[[:space:]\"'](${gd}|${qg})"; then
    blocked=yes
# 8. in-place interpreter edits: perl -i / ruby -i on a gate path.
elif printf '%s' "$cmd" | grep -qE "${c}(perl|ruby)[\"']?[[:space:]]+[^;&|]*-[a-z]*i[^;&|]*[[:space:]\"'=](${gd}|${qg})"; then
    blocked=yes
# 11. patch / git apply feeding a diff into a gate path.
elif printf '%s' "$cmd" | grep -qE "${c}patch[\"']?[[:space:]]([^;&|]*[[:space:]\"'=])?(${gd}|${qg})"; then
    blocked=yes
elif printf '%s' "$cmd" | grep -qE "${c}git[\"']?[[:space:]]+apply[[:space:]]" \
     && printf '%s' "$cmd" | grep -qE "(${gd}|${qg})"; then
    blocked=yes
# 12. git checkout / restore / rm / mv on a gate path. Reverting a gate to an
#     earlier revision, or deleting it, changes the criteria that judge the work
#     just as surely as editing the file in place.
elif printf '%s' "$cmd" | grep -qE "${c}git[\"']?[[:space:]]+(checkout|restore|rm|mv)[[:space:]][^;&|]*[[:space:]\"'](${gd}|${qg})"; then
    blocked=yes
fi

# 9. Interpreter one-liner naming a gate path AND a write verb (A11-ISS-16).
#
#    Requiring the write verb is deliberate. `python3 -c "print(open('.quality-gates.json').read())"`
#    is a read and must stay allowed: a guard that refuses ordinary inspection
#    gets removed rather than fixed, which is how A11-ISS-4 happened.
if [ -z "$blocked" ]; then
    if printf '%s' "$cmd" | grep -qE "${c}(python3?|node|ruby|perl|php|deno|bun)[\"']?[[:space:]]+[^;&|]*-[ce][[:space:]]" \
       && printf '%s' "$cmd" | grep -qE "(${gd}|${qg})" \
       && printf '%s' "$cmd" | grep -qE "(open[^)]*,[[:space:]]*[\"'][wax]|writeFileSync|writeFile|appendFile|\.write_text|\.write_bytes|\.write\(|json\.dump|yaml\.dump|os\.remove|os\.unlink|os\.rename|os\.truncate|shutil\.(move|copy|rmtree)|fs\.rm|fs\.unlink|File\.write|IO\.write|FileUtils\.(mv|cp|rm)|file_put_contents|unlink\(|rename\(|truncate\()"; then
        blocked=yes
    fi
fi

# 10. Variable indirection (A11-ISS-16): a gate path assigned to a shell
#     variable, then written through that variable.
#
#     Each candidate variable is checked individually rather than assuming any
#     write in the command belongs to it, so `G=gates/x; echo y > /tmp/other`
#     stays allowed while `G=gates/x; echo y > $G` does not.
if [ -z "$blocked" ]; then
    gate_vars=$(printf '%s' "$cmd" \
        | grep -oE "(^|[;&|[:space:](])[A-Za-z_][A-Za-z0-9_]*=[\"']?(${gd}|${qg})" \
        | sed -e 's/^[^A-Za-z_]*//' -e 's/=.*$//' \
        | sort -u)
    for v in $gate_vars; do
        [ -n "$v" ] || continue
        # Any of the branch 1-7 write forms, aimed at $v or ${v}.
        ref="\\\$(\\{)?${v}(\\})?"
        if printf '%s' "$cmd" | grep -qE "[0-9]?>>?[[:space:]]*[\"']?${ref}" \
           || printf '%s' "$cmd" | grep -qE "${c}(tee|rm|truncate|shred|unlink|patch)[\"']?[[:space:]][^;&|]*${ref}" \
           || printf '%s' "$cmd" | grep -qE "${c}(cp|mv|ln)[\"']?[[:space:]][^;&|]*${ref}" \
           || printf '%s' "$cmd" | grep -qE "${c}sed[\"']?[[:space:]]+[^;&|]*-i[^;&|]*${ref}" \
           || printf '%s' "$cmd" | grep -qE "of=[\"']?${ref}"; then
            blocked=yes
            break
        fi
    done
fi

if [ -n "$blocked" ]; then
    echo 'BLOCKED (Sprint 6a/6c read-only gates): refusing a Bash write to a quality-gate path. The criteria that judge the work are not agent-editable. The Edit deny rules do not cover Bash, so this hook catches the common write forms. Do not look for a form it misses: finding one is reward-hacking, not a workaround. To change a gate, do it as a deliberate human action.' >&2
    exit 2
fi
exit 0
