#!/usr/bin/env bash
#
# validate-enforcement-claims.sh — the library may not claim protection it does not have.
#
# A11-ISS-11/15 were one defect in eight places: documentation telling operators that
# `permissions.deny` makes something read-only when no rule covers it. The shipped deny
# set is exactly four rules, all matching gate paths:
#
#     Edit(.quality-gates.json)  Edit(**/*.quality-gates.json)
#     Edit(gates/**)             Edit(.gates/**)
#
# So an acceptance-criteria test living anywhere else, a benchmark, a metric command, or
# "everything outside the named surface" is NOT enforced by anything. Saying otherwise is
# worse than saying nothing: an operator who believes the tool layer is stopping an agent
# stops watching for the thing it is not stopping.
#
# THE INVARIANT. In any deployed-library file, a passage that mentions `permissions.deny`
# alongside one of those unenforced subjects must also carry an explicit marker saying it
# is not enforced. A passage may claim enforcement, or mention an unenforced subject, but
# not claim enforcement OF an unenforced subject.
#
# Prints NOTHING and exits 0 when compliant.
#
# Usage:  scripts/validate-enforcement-claims.sh          (silent = compliant)
#         scripts/validate-enforcement-claims.sh -v       (list what was checked)
#
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO" || exit 1

VERBOSE=0
[ "${1:-}" = "-v" ] && VERBOSE=1

fail=0

# The surface a user actually reads. library/, project/ and templates/ are installed into
# their repo; docs/, CHANGELOG.md and README.md are what they read before and after
# installing, and a false claim there misleads just as effectively. sprints/, progress.md
# and handoff notes are this repo's own working history and are deliberately out of scope.
SURFACES=(library project templates docs CHANGELOG.md README.md)

python3 - "$VERBOSE" "${SURFACES[@]}" <<'PY' >&2 || fail=1
import json, re, sys, pathlib

verbose = sys.argv[1] == "1"
surfaces = sys.argv[2:]

EXPECTED_RULES = {
    "Edit(.quality-gates.json)",
    "Edit(**/*.quality-gates.json)",
    "Edit(gates/**)",
    "Edit(.gates/**)",
}

bad = False

# The rule set is the authority. If it grows, this check must be revisited deliberately
# rather than quietly passing a doc that describes rules which now exist.
tmpl = pathlib.Path("library/settings.json.template")
try:
    shipped = set((json.loads(tmpl.read_text()).get("permissions") or {}).get("deny") or [])
except Exception as e:
    print(f"CLAIMS: cannot read the shipped deny rules from {tmpl}: {e}")
    sys.exit(1)

if shipped != EXPECTED_RULES:
    print("CLAIMS: the shipped permissions.deny set has changed; this check encodes what the "
          "docs are allowed to promise and must be updated alongside it.")
    print(f"  expected: {sorted(EXPECTED_RULES)}")
    print(f"  shipped:  {sorted(shipped)}")
    bad = True

# Subjects the four rules do not cover, in the wording the library actually uses.
UNENFORCED = re.compile(
    r"acceptance criteria|acceptance test|test that serves|test that defines|test file that serves"
    r"|metric command|the benchmark|outside the named surface|outside the named editable surface",
    re.I,
)
# An explicit statement that the thing is NOT enforced. These have to be specific: an early
# version allowed a bare `\bNOT\b` under re.I, which matched the incidental "not" in "not a
# quiet widening of scope" and passed the very defect the check was written for. A negation
# marker must assert non-enforcement, not merely contain the word "not".
NEGATED = re.compile(
    r"not enforced"
    r"|is not covered|are not covered|not covered by"
    r"|covered by no|no shipped rule|no rule covers|no file-level rule"
    r"|nothing (?:stops|refuses|adds|writes|covers|adds one)"
    r"|only the first line is enforced|only the gate paths are enforced"
    r"|only the first two are enforced|the first two, not the third"
    r"|two of those three are enforced"
    r"|until you add|unless you add"
    r"|prohibited by instruction|not refused by the tool layer|rather than refused"
    r"|only gate paths are covered"
    r"|\*\*not enforced\*\*|\| \*\*No\*\*",
    re.I,
)
MENTIONS_DENY = re.compile(r"permissions\.deny", re.I)

# A line window, not a blank-line block. The original defect read "The loop may NEVER edit:
# <bullet list including the metric command> ... These are enforced by permissions.deny", where
# the claim and its referent sit in different paragraphs. Splitting on blank lines pulls them
# apart and misses exactly the defect this check exists to catch.
WINDOW = 8
LONG_LINE = 300

def targets(surface):
    p = pathlib.Path(surface)
    if p.is_dir():
        return sorted(p.rglob("*.md"))
    return [p] if p.is_file() else []

checked = flagged = 0
for surface in surfaces:
    for path in targets(surface):
        text = path.read_text(errors="replace")
        if "permissions.deny" not in text:
            continue
        checked += 1
        lines = text.splitlines()
        for i, line in enumerate(lines):
            if not MENTIONS_DENY.search(line):
                continue
            # A long line is its own paragraph. CHANGELOG and release-history bullets run to
            # ~1000 characters, so a line window straddles several unrelated entries and
            # borrows a subject from a neighbour. Judge those on the line alone.
            if len(line) > LONG_LINE:
                window = line
            else:
                lo, hi = max(0, i - WINDOW), min(len(lines), i + WINDOW + 1)
                window = "\n".join(lines[lo:hi])
            if not UNENFORCED.search(window):
                continue
            flagged += 1
            if not NEGATED.search(window):
                subject = UNENFORCED.search(window).group(0)
                print(f"CLAIMS: {path}:{i + 1} ties permissions.deny to \"{subject}\", which no "
                      f"shipped rule covers, without saying it is unenforced")
                bad = True

if verbose:
    print(f"claims: {checked} library files mention permissions.deny; "
          f"{flagged} passages pair it with an unenforced subject, all correctly qualified")

sys.exit(1 if bad else 0)
PY

exit "$fail"
