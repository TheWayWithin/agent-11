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

# Subjects the four rules do not cover. This list was a closed catalogue of the exact
# phrases the library happened to use, which a reviewer defeated by rewording one claim
# from "acceptance criteria" to "success criteria": same false claim, silent pass. It is
# now the class of thing an agent gets judged against, not a list of past wordings. Some
# of these will fire on passages that are perfectly true; the fix for a false positive is
# to state the scope explicitly, which is better writing anyway.
UNENFORCED = re.compile(
    r"acceptance criteri|acceptance test"
    r"|success criteri|success metric|exit criteri|definition of done"
    r"|test that serves|test that defines|test file that serves|test which serves"
    r"|metric command|the metric\b|the benchmark|benchmark file"
    r"|the threshold|thresholds\b|the rubric|quality bar"
    r"|outside the named surface|outside the named editable surface|outside the surface",
    re.I,
)
# Co-occurrence is not a claim. "Success Criteria" as a mission heading a few lines from the
# words "quality gate" is not an assertion that anything is enforced, and flagging it is how
# a check earns a reputation for noise and gets switched off. An enforcement VERB must sit
# near the subject before the pairing counts.
ENFORCE_VERB = re.compile(
    r"enforc|unwritable|read-only|refus|blocks?\b|prevent|protect|cannot (?:be )?(?:edit|chang|modif|writ)"
    r"|may (?:never|not) (?:edit|touch|chang)|is not agent-editable|not agent-editable",
    re.I,
)

# Naming a gate path is what makes an enforcement claim legitimate. A passage that claims
# enforcement and names one of these is talking about something the rules actually cover.
GATE_PATH = re.compile(
    r"\.quality-gates\.json|gates/\*\*|\.gates/\*\*|`gates/`|gates/ director|gate path|gate config",
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
    r"|none of (?:those|these|them) (?:is|are) covered"
    r"|nothing (?:stops|refuses|adds|writes|covers|adds one)"
    r"|only the first line is enforced|only the gate paths are enforced"
    r"|only the first two are enforced|the first two, not the third"
    r"|two of those three are enforced"
    r"|until you add|unless you add"
    r"|prohibited by instruction|not refused by the tool layer|rather than refused"
    r"|never by the tool layer|by policy alone|by instruction alone"
    r"|zero protection|no protection|protects? nothing|is not protected"
    r"|only gate paths are covered"
    r"|\*\*not enforced\*\*|\| \*\*No\*\*",
    re.I,
)
MENTIONS_DENY = re.compile(
    r"permissions\.deny|deny rule|Edit\(\) deny|deny list|gate guard|gate-guard"
    r"|read-only (?:quality )?gate|quality gate|gate path",
    re.I,
)

# --- claim patterns (marker region: scripts/validate-bash-route-claims.sh exempts the
# --- wording below, which necessarily spells out the phrases it hunts for)
#
# A second claim class, and the one that survived three audits: saying the Bash guard
# CLOSES the route rather than narrowing it. This overstates a mechanism's completeness
# rather than its scope, so the enforced/unenforced logic below cannot see it. The guard
# carries 12 detection branches as of 2026-08-04; a runtime-assembled path, an interpreter
# reaching the path indirectly, or anything eval'd goes straight through, and no shell
# guard can catch those (A11-ISS-16).
ROUTE_CLOSED = re.compile(
    r"clos(?:es|ing|ed) (?:the |that |off )?(?:one )?route"
    r"|closes the bash route|closes that gap|closes the gap"
    r"|(?<!not )refuses (?:all )?bash writes(?! forms)"
    r"|blocks (?:all )?bash writes(?!\s*\()",
    re.I,
)
ROUTE_QUALIFIED = re.compile(
    r"common (?:bash )?write forms|speed bump|narrows that route|rather than clos"
    r"|does not close|not close the|passes? (?:straight )?through|A11-ISS-16",
    re.I,
)
# --- end claim patterns

# A line window, not a blank-line block. The original defect read "The loop may NEVER edit:
# <bullet list including the metric command> ... These are enforced by permissions.deny", where
# the claim and its referent sit in different paragraphs. Splitting on blank lines pulls them
# apart and misses exactly the defect this check exists to catch.
WINDOW = 8
LONG_LINE = 300

SCANNED_SUFFIXES = {".md", ".json", ".template", ".sh", ".yaml", ".yml"}

# Historical fingerprints, deliberately exempt. merge-settings.py and its test fixtures
# hold byte-exact copies of what PAST releases shipped, used to decide whether a hook or
# rule in a user's settings is one AGENT-11 shipped and may therefore be upgraded.
# "Correcting" the wording in them would break upgrade detection for every repo still on
# the old version. They record what was true then, not what is claimed now.
EXEMPT = {
    "project/deployment/scripts/merge-settings.py",
    "project/deployment/scripts/test-merge-settings.sh",
}

def targets(surface):
    # Not just *.md. The single widest-reach instance of this defect lived in a JSON
    # comment inside library/settings.json.template, which an *.md-only sweep could
    # never see, and the guard script's own header made the same claim about itself.
    p = pathlib.Path(surface)
    if p.is_dir():
        return sorted(q for q in p.rglob("*")
                      if q.is_file() and q.suffix in SCANNED_SUFFIXES and str(q) not in EXEMPT)
    return [p] if p.is_file() and str(p) not in EXEMPT else []

checked = flagged = 0
for surface in surfaces:
    for path in targets(surface):
        text = path.read_text(errors="replace")
        # Filter with the SAME trigger the line scan uses. An earlier version gated on the
        # literal string "permissions.deny", so a file claiming "the gate guard enforces the
        # acceptance criteria test" was never opened at all: the widened trigger below was
        # dead code for any file that did not also happen to say permissions.deny.
        if not MENTIONS_DENY.search(text):
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
            # Markdown wraps, so "no file-level\n      rule is possible" must still match
            # "no file-level rule". Collapse whitespace before matching either pattern.
            window = re.sub(r"\s+", " ", window)
            if ROUTE_CLOSED.search(window) and not ROUTE_QUALIFIED.search(window):
                flagged += 1
                print(f"CLAIMS: {path}:{i + 1} says the Bash guard closes the route. It catches "
                      f"11 command forms; interpreter writes and variable-held paths pass through "
                      f"(A11-ISS-16). Say what it catches, not that it closes.")
                bad = True

            hits = list(UNENFORCED.finditer(window))
            if not hits:
                continue
            # A subject sitting next to a gate path is legitimately scoped: "the
            # threshold inside a gate config cannot be lowered" is true and must not be
            # flagged, or the check gets switched off by the first person it annoys.
            unscoped = [h for h in hits
                        if not GATE_PATH.search(window[max(0, h.start() - 90): h.end() + 90])
                        and ENFORCE_VERB.search(window[max(0, h.start() - 130): h.end() + 130])]
            if not unscoped:
                continue
            flagged += 1
            if not NEGATED.search(window):
                subject = unscoped[0].group(0)
                print(f"CLAIMS: {path}:{i + 1} ties permissions.deny to \"{subject}\", which no "
                      f"shipped rule covers, without saying it is unenforced")
                bad = True

if verbose:
    print(f"claims: {checked} library files mention permissions.deny; "
          f"{flagged} passages pair it with an unenforced subject, all correctly qualified")

sys.exit(1 if bad else 0)
PY

exit "$fail"
