#!/bin/sh
# AGENT-11 destructive-command guard (A11-ISS-22).
#
# PreToolUse hook for Bash. Blocks a short list of genuinely destructive and
# hard-to-reverse commands so the agent has to come back to the human first.
#
# WHY THIS REPLACED A `prompt` HOOK. The settings template used to express this
# as a "type": "prompt" hook filtered by an `if` glob:
#
#     "if": "Bash(rm -rf *)|Bash(git push --force*)|Bash(git reset --hard*)|..."
#
# That glob failed open on any command shape it did not anticipate — multi-line
# loops, heredocs, redirections, && chains. Same defect A11-ISS-4 found and
# fixed for the gate guard, whose conclusion was recorded plainly: the `if`
# glob "fails open on complex commands (multi-line loops, redirections) and
# blocked unrelated Bash." This hook was left behind. Worse, being `prompt`
# type, a fail-open match handed benign commands to a model to adjudicate,
# which refused them — invisibly, since the refusal goes to the agent, not the
# operator. Work stopped happening and nobody was told.
#
# WHY THE FIRST REWRITE WAS ALSO WRONG. It matched literal substrings against
# the whole command text. That blocks `grep -rn "rm -rf" .` and
# `echo "never run rm -rf in prod"`, neither of which deletes anything — the
# trigger is in an argument to another program. A cold review caught it, and
# then it blocked the very command being used to test it. Substring matching
# on a shell command is the same mistake as glob-matching it: both look at the
# text rather than at what will run.
#
# SO: the command is tokenised with the shell's own quoting rules, split on
# shell separators, and each segment judged by its actual argv[0] and flags.
# A destructive string inside a quoted argument to another program is not a
# destructive command, and is allowed.
#
# WHAT IT BLOCKS (per segment, by argv[0] and real flags):
#   rm      recursive AND force together, in any spelling or order:
#           -rf -fr -Rf -r -f -irf --recursive --force, clustered or separate
#   git push --force / -f, including clustered short flags (-fu).
#           --force-with-lease is deliberately ALLOWED: it is the safe form.
#   git reset --hard
#   git clean with -f (any clustering: -f -fd -df -xfd)
#   git branch -D
#   git checkout/restore with a bare "." pathspec (discards all local edits)
#
# WHAT IT CANNOT SEE, and no matcher of command text can:
#   - a destructive command assembled at runtime or held in a variable
#   - anything eval'd, encoded, or run by a script/program this launches
#   - a destructive action taken through a tool other than Bash
#
# It is a speed bump against the accidental, not a security boundary. The
# operator remains the control.
#
# stdin:  Claude Code hook payload JSON ({"tool_input":{"command":"..."}})
# exit 0: allow the Bash call
# exit 2: block it (stderr is fed back to the model)

set -u

# Fail OPEN whenever anything is unavailable or unparseable. A guard that
# blocks when confused is how an agent stops working for reasons nobody can
# see — the exact bug this file exists to fix.
command -v python3 >/dev/null 2>&1 || exit 0

# The payload travels by environment, not stdin: the interpreter script below
# is itself delivered on stdin via the heredoc, so python3 would otherwise read
# its own source where the JSON should be and every command would sail through
# allowed. That failure is silent and total, which is exactly the shape of bug
# this hook exists to stop — caught only because the test suite asserts the
# blocking cases, not just the allowing ones.
AGENT11_HOOK_PAYLOAD="$(cat 2>/dev/null || true)"
[ -z "$AGENT11_HOOK_PAYLOAD" ] && exit 0
export AGENT11_HOOK_PAYLOAD

python3 - <<'PYGUARD'
import json
import os
import re
import shlex
import sys

try:
    payload = json.loads(os.environ.get("AGENT11_HOOK_PAYLOAD", ""))
except Exception:
    sys.exit(0)

command_text = str((payload.get("tool_input") or {}).get("command", ""))
if not command_text.strip():
    sys.exit(0)

# Split on shell separators that start a new command. Doing this on the raw
# text is safe enough here because a separator inside quotes only ever splits a
# segment into smaller pieces — it cannot invent an argv[0] that is not there.
SEGMENT_SPLIT = re.compile(r'(?:\|\||&&|[;&|\n])')


def tokenise(segment):
    try:
        return shlex.split(segment)
    except ValueError:
        # Unbalanced quotes: a heredoc body or a partial command. Not something
        # we can judge, so let it through rather than guess.
        return []


def short_flags(tokens):
    """Letters from clustered short flags, e.g. -irf -> {i, r, f}."""
    letters = set()
    for t in tokens:
        if t.startswith("-") and not t.startswith("--"):
            letters.update(t[1:])
    return letters


def long_flags(tokens):
    return {t for t in tokens if t.startswith("--")}


def verdict(segment):
    tokens = tokenise(segment)
    if not tokens:
        return None
    # Step over leading env assignments (FOO=bar cmd ...) and `sudo`.
    i = 0
    while i < len(tokens) and ("=" in tokens[i] and not tokens[i].startswith("-")):
        i += 1
    if i < len(tokens) and os.path.basename(tokens[i]) == "sudo":
        i += 1
    if i >= len(tokens):
        return None

    cmd = os.path.basename(tokens[i])
    args = tokens[i + 1:]
    shorts, longs = short_flags(args), long_flags(args)

    if cmd == "rm":
        recursive = bool(shorts & {"r", "R"}) or "--recursive" in longs
        force = "f" in shorts or "--force" in longs
        if recursive and force:
            return "recursive force delete (rm -r -f)"
        return None

    if cmd == "git":
        sub = next((a for a in args if not a.startswith("-")), None)
        if sub == "push":
            if "--force-with-lease" in longs:
                return None          # the safe form, deliberately allowed
            if "--force" in longs or "f" in shorts:
                return "force push (git push --force)"
        elif sub == "reset" and "--hard" in longs:
            return "git reset --hard discards uncommitted work"
        elif sub == "clean" and "f" in shorts:
            return "git clean -f deletes untracked files"
        elif sub == "branch" and "D" in shorts:
            return "git branch -D force-deletes a branch"
        elif sub in ("checkout", "restore"):
            if "." in args:
                return "%s . discards all local modifications" % sub
    return None


for segment in SEGMENT_SPLIT.split(command_text):
    reason = verdict(segment)
    if reason:
        sys.stderr.write("BLOCKED by AGENT-11 destructive-command guard: %s\n" % reason)
        sys.stderr.write("Command: %s\n" % command_text)
        sys.stderr.write(
            "This is destructive and hard to reverse. Ask the user to confirm "
            "explicitly, then run it only if they agree.\n")
        sys.exit(2)

sys.exit(0)
PYGUARD
