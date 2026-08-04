#!/bin/sh
# AGENT-11 destructive-command guard (A11-ISS-22).
#
# PreToolUse hook for Bash. Blocks a short list of genuinely destructive and
# hard-to-reverse commands so the agent has to come back to the human before
# running one.
#
# WHY THIS REPLACES A `prompt` HOOK. The settings template used to express this
# as a `"type": "prompt"` hook filtered by an `if` glob:
#
#     "if": "Bash(rm -rf *)|Bash(git push --force*)|Bash(git reset --hard*)|..."
#
# That glob fails open on any command whose shape it did not anticipate —
# multi-line loops, heredocs, redirections, `&&` chains. This is the same
# defect A11-ISS-4 found and fixed for the gate guard, where the conclusion was
# recorded plainly: the `if` glob filter "fails open on complex commands
# (multi-line loops, redirections) and blocked unrelated Bash." The gate guard
# was moved to a script reading stdin; this hook was left behind.
#
# The consequence was worse than a false positive. Because the hook was
# `prompt` type, a fail-open match handed a benign command to a model to
# adjudicate, and it refused things like `chmod +x`, a `git status` loop and a
# scratch-directory test — silently from the operator's point of view, since
# the refusal goes to the agent, not to the human. Work simply stopped
# happening and nobody was told. Observed repeatedly on 2026-08-04.
#
# So the decision is made here, deterministically, against the real command
# text, with no glob and no adjudicating model.
#
# WHAT IT BLOCKS:
#   rm -rf / rm -fr / rm -r -f     recursive force delete
#   git push --force / -f          history overwrite on a remote
#   git reset --hard               discards uncommitted work
#   git clean -f / -fd             deletes untracked files
#   git branch -D                  force-deletes a branch
#   git checkout/switch/restore .  discards local modifications wholesale
#
# WHAT IT DOES NOT BLOCK, and no text matcher can:
#   - a destructive command assembled at runtime or held in a variable
#   - anything eval'd, encoded, or run by a program this launches
#   - `--force-with-lease`, which is deliberately allowed: it is the safe form
#   - a destructive action taken through a tool other than Bash
#
# It is a speed bump against the accidental, not a security boundary. The
# operator remains the control.
#
# stdin:  Claude Code hook payload JSON ({"tool_input":{"command":"..."}})
# exit 0: allow the Bash call
# exit 2: block it (stderr is fed back to the model)

set -u

payload="$(cat 2>/dev/null || true)"
[ -z "$payload" ] && exit 0

# Prefer a real JSON parse. A command containing quotes, newlines or escapes is
# exactly the case the old glob got wrong, so guessing with sed is the last
# resort rather than the first.
command_text=""
if command -v python3 >/dev/null 2>&1; then
    command_text="$(printf '%s' "$payload" | python3 -c '
import json,sys
try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)
ti = d.get("tool_input") or {}
sys.stdout.write(str(ti.get("command", "")))
' 2>/dev/null || true)"
fi

# Fail OPEN, deliberately: if the payload cannot be read, allow the command.
# A guard that blocks whenever it is confused is how an agent stops working
# for reasons nobody can see, which is the bug this file exists to fix.
[ -z "$command_text" ] && exit 0

block() {
    printf 'BLOCKED by AGENT-11 destructive-command guard: %s\n' "$1" >&2
    printf 'Command: %s\n' "$command_text" >&2
    printf 'This is destructive and hard to reverse. Ask the user to confirm explicitly, then run it only if they agree.\n' >&2
    exit 2
}

# Normalise whitespace so a multi-line or oddly spaced command matches the same
# as a single-line one. This is the whole point: the old filter saw the shape of
# the command, this sees its content.
flat="$(printf '%s' "$command_text" | tr '\n\t' '  ' | tr -s ' ')"

case "$flat" in
    *"rm -rf"*|*"rm -fr"*|*"rm -r -f"*|*"rm -f -r"*)
        block "recursive force delete (rm -rf)" ;;
esac

case "$flat" in
    *"git push"*)
        case "$flat" in
            *--force-with-lease*) : ;;                 # the safe form; allowed
            *--force*|*" -f "*|*" -f")
                block "force push (git push --force)" ;;
        esac ;;
esac

case "$flat" in
    *"git reset --hard"*)      block "git reset --hard discards uncommitted work" ;;
    *"git clean -f"*|*"git clean -df"*|*"git clean -fd"*)
                               block "git clean -f deletes untracked files" ;;
    *"git branch -D"*)         block "git branch -D force-deletes a branch" ;;
    *"git checkout -- ."*|*"git checkout ."*)
                               block "git checkout . discards all local modifications" ;;
    *"git restore ."*|*"git restore --staged --worktree ."*)
                               block "git restore . discards all local modifications" ;;
esac

exit 0
