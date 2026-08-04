#!/bin/sh
# AGENT-11 read-only gate guard (Sprint 6a/6c; reworked for A11-ISS-4, hardened for A11-ISS-16).
#
# PreToolUse hook for Bash. Blocks the common Bash write forms against
# quality-gate paths (.quality-gates.json, *quality-gates.json, gates/,
# .gates/) — the route the Edit deny rules cannot cover. Everything else
# is allowed.
#
# WHAT IT CATCHES — 13 branches, and the list below is the branch list. Keep
# them in step: an audit once found this header undercounting its own logic by
# two, which is the same class of defect as overclaiming, pointed the other way.
# scripts/validate-bash-route-claims.sh now compares this list to the code.
#
#   1. redirection            > >> into a gate path
#   2. tee                    tee / tee -a a gate path
#   3. sed -i                 in-place sed on a gate path
#   4. cp / mv                cp onto a gate path (DESTINATION only — cp reads its
#                             source, so `cp gates/x /tmp/y` stays allowed); mv with a
#                             gate path in either position, since mv removes its source
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
#  13. xargs                  a write verb fed by a pipe, where the gate path sits on
#                             the other side of the pipe from the verb
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
#   - a spelling that splits the literal word across shell syntax the flattening
#     pass does not undo: globs (gate?/x, gate*/x), character classes ([g]ates/x),
#     ANSI-C quoting ($'gates'/x), or concatenation across a variable. Brace
#     expansion and simple embedded quoting ARE undone; these are not.
#
# Both "does not catch" lists above are the honest boundary of a text matcher. Two
# cold reviews on a different model found nine and then fifteen live bypasses of a
# header that claimed more than the code did. Assume there are more.
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

# Fast allow: nothing gate-like anywhere in the payload. Case-insensitive, and also
# checked against the brace/quote-flattened form, or `rm -f ga{tes/x,}` and `GATES/x`
# would exit here before any branch ran.
printf '%s' "$input" | tr -d '{},"'"'" | grep -qi 'gates' || exit 0

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

# NORMALISE before matching. Every branch below is a grep, and grep is line-oriented, so
# a backslash-newline continuation put the command word on one line and its target on the
# next and defeated all twelve branches at once -- ordinary bash an agent produces just by
# wrapping a long command. Newlines collapse to spaces, continuations are removed, and
# whitespace runs (including tabs) collapse to one space.
norm=$(printf '%s' "$cmd" | tr '\n\t' '  ' | sed -e 's/\\ / /g' -e 's/  */ /g')

# A second, flattened candidate with brace-expansion and quoting punctuation removed, so
# `rm -f ga{tes/x.json,}` and `rm -f g"a"tes/x.json` -- single self-contained commands that
# split the literal spelling of "gates" -- are matched too. Every branch tests both forms.
flat=$(printf '%s' "$norm" | tr -d '{},"'"'")

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
# gdd — the gate directory ITSELF as well as anything inside it. `rm -rf gates` destroys
# every gate as thoroughly as editing them, and gd (which requires a trailing slash) let
# it through. Used only by the destructive verbs. The trailing alternation is what keeps
# gates.md allowed: a dot is neither a slash, a space, nor end-of-string.
gdd='([^[:space:]"'\'';&|]*/)?\.?gates([[:space:]]|/|$)'
# c — the start of a command word: optional quoting and an optional path to the binary.
# Without this, /bin/rm and "rm" evaded every command-anchored branch.
c='(^|[;&|[:space:]])["'\'']?([^[:space:];&|"'\'']*/)?'

# Every branch matches case-insensitively (macOS filesystems are case-insensitive by
# default, so GATES/foo.json and gates/foo.json are the same file) and against both the
# normalised and the brace/quote-flattened command.
match() {
    printf '%s' "$norm" | grep -qiE "$1" && return 0
    printf '%s' "$flat" | grep -qiE "$1"
}

blocked=""
# 1. Redirection into a gate path:  > .quality-gates.json / >> gates/x
if match "[0-9]?>>?[[:space:]]*[\"']?(${gd}|${qg}\.json)"; then
    blocked=yes
# 2. tee into a gate path:  tee .quality-gates.json / tee -a gates/x
elif match "${c}tee[\"']?[[:space:]]([^;&|]*[[:space:]\"'=])?(${gd}|${qg})"; then
    blocked=yes
# 3. sed -i on a gate path
elif match "${c}sed[\"']?[[:space:]]+[^;&|]*-i[^;&|]*[[:space:]\"'=](${gd}|${qg})"; then
    blocked=yes
# 4. cp onto a gate path, or mv involving one.
#    cp READS its source, so only the DESTINATION counts: `cp gates/report.json /tmp/x`
#    is a developer archiving a gate for inspection and must stay allowed. Blocking it is
#    the A11-ISS-4 failure mode -- a guard that refuses ordinary work gets deleted rather
#    than fixed. The destination is the last token of the segment, hence the end anchor.
elif match "${c}cp[\"']?[[:space:]][^;&|]*[[:space:]\"']?(${gd}|${qg})[^[:space:];&|\"']*[\"']?[[:space:]]*([;&|]|$)"; then
    blocked=yes
#    mv REMOVES its source, so a gate in either position is a write.
elif match "${c}mv[\"']?[[:space:]]([^;&|]*[[:space:]\"'=])?(${gdd}|${qg}\.json)"; then
    blocked=yes
# 5. rm / truncate / shred / unlink of a gate path — deleting a gate passes it
#    just as effectively as lowering it.
elif match "${c}(rm|truncate|shred|unlink)[\"']?[[:space:]]([^;&|]*[[:space:]\"'=])?(${gdd}|${qg})"; then
    blocked=yes
# 6. dd of= a gate path
elif match "${c}dd[\"']?[[:space:]][^;&|]*of=[\"']?(${gd}|${qg})"; then
    blocked=yes
# 7. ln -s over a gate path — replacing it with a symlink is a write.
elif match "${c}ln[\"']?[[:space:]]+[^;&|]*-[a-z]*s[^;&|]*[[:space:]\"'](${gd}|${qg})"; then
    blocked=yes
# 8. in-place interpreter edits: perl -i / ruby -i on a gate path.
elif match "${c}(perl|ruby)[\"']?[[:space:]]+[^;&|]*-[a-z]*i[^;&|]*[[:space:]\"'=](${gd}|${qg})"; then
    blocked=yes
# 11. patch / git apply feeding a diff into a gate path.
elif match "${c}patch[\"']?[[:space:]]([^;&|]*[[:space:]\"'=])?(${gd}|${qg})"; then
    blocked=yes
elif match "${c}git[\"']?[[:space:]]+apply[[:space:]]" \
     && match "(${gd}|${qg})"; then
    blocked=yes
# 13. xargs feeding a write verb. The command-anchored branches require the target in the
#     same unbroken segment as the verb, and a pipe puts it on the other side:
#     `echo gates/x.json | xargs rm -f`. Here the gate path may be anywhere in the command.
elif match "${c}xargs[\"']?[[:space:]][^;&|]*(rm|truncate|shred|unlink|tee|cp|mv|dd|sed|patch)" \
     && match "(${gdd}|${qg})"; then
    blocked=yes
# 12. git checkout / restore / rm / mv on a gate path. Reverting a gate to an
#     earlier revision, or deleting it, changes the criteria that judge the work
#     just as surely as editing the file in place.
elif match "${c}git[\"']?[[:space:]]+(checkout|restore|rm|mv)[[:space:]][^;&|]*[[:space:]\"'](${gdd}|${qg})"; then
    blocked=yes
fi

# 9. Interpreter one-liner naming a gate path AND a write verb (A11-ISS-16).
#
#    Requiring the write verb is deliberate. `python3 -c "print(open('.quality-gates.json').read())"`
#    is a read and must stay allowed: a guard that refuses ordinary inspection
#    gets removed rather than fixed, which is how A11-ISS-4 happened.
if [ -z "$blocked" ]; then
    if match "${c}(python3?|node|ruby|perl|php|deno|bun)[\"']?[[:space:]]+[^;&|]*-[ce][[:space:]]" \
       && match "(${gd}|${qg})" \
       && match "(open[^)]*,[[:space:]]*[\"'][wax]|writeFileSync|writeFile|appendFile|\.write_text|\.write_bytes|\.write\(|json\.dump|yaml\.dump|os\.remove|os\.unlink|os\.rename|os\.truncate|shutil\.(move|copy|rmtree)|fs\.rm|fs\.unlink|File\.write|IO\.write|FileUtils\.(mv|cp|rm)|file_put_contents|unlink\(|rename\(|truncate\()"; then
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
        if match "[0-9]?>>?[[:space:]]*[\"']?${ref}" \
           || match "${c}(tee|rm|truncate|shred|unlink|patch)[\"']?[[:space:]][^;&|]*${ref}" \
           || match "${c}(cp|mv|ln)[\"']?[[:space:]][^;&|]*${ref}" \
           || match "${c}sed[\"']?[[:space:]]+[^;&|]*-i[^;&|]*${ref}" \
           || match "of=[\"']?${ref}"; then
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
