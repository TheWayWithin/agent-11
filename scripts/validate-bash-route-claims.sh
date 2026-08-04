#!/usr/bin/env bash
#
# validate-bash-route-claims.sh — the gate guard is never described as closing the Bash route.
#
# A11-ISS-16. `library/hooks/gate-guard.sh` blocks Bash writes to gate paths through 12 detection branches.
# It cannot block a path assembled at runtime, an interpreter reaching the path indirectly,
# anything eval'd or base64-decoded, or a write done by a program it launches. No shell
# guard can. A guard described as a boundary is worse than one described as a speed bump,
# because people stop looking.
#
# TWO checks, not one, and the second matters as much as the first:
#
#   ABSENCE   No file claims the guard closes, completes or fully covers the Bash route,
#             or calls it a security boundary.
#   PRESENCE  The three files that carry the guard's description into deployed projects
#             each still say plainly that it does NOT close that route.
#
# Absence alone is satisfied by deleting the honest sentence, or by deleting the file. A
# check that passes on an empty repo is not a check. Hence PRESENCE.
#
# HOW THE ABSENCE CHECK DECIDES. It works on sentences, not lines, because "It does not
# close the Bash route" and "It closes the Bash route" differ by one word that a line-level
# grep for the phrase cannot tell apart. A sentence containing a claim phrase is a breach
# UNLESS either a negator appears BEFORE the phrase in that sentence, or an explicit denial
# marker ("is false", "must not be described") appears anywhere in it. Requiring the
# negator to precede the phrase is what stops "it closes the Bash route and is not a speed
# bump" from clearing itself on a trailing "not".
#
# WHAT THIS CANNOT DO. It reads text. A claim made in a paraphrase it has no pattern for
# passes. It is a regression check on a known family of wording, not a proof of honesty,
# and it is written from inside the tree it checks, so anyone editing the repo can edit it.
#
# STRUCTURAL EXEMPTIONS, and why they are not blanket exemptions. Two files legitimately
# contain the false wording. Each is exempt only for occurrences BETWEEN two markers, so
# adding the claim anywhere else in the same file still fails:
#   - project/deployment/scripts/test-merge-settings.sh holds a verbatim copy of the
#     genuine v6.2.0 settings template inside a heredoc, kept byte-identical so the
#     stale-hook catalogue test proves what actually shipped. Rewriting history in a
#     fixture would make the test assert something untrue.
#   - this script, whose pattern list necessarily spells the phrases out.
#
# Usage:  scripts/validate-bash-route-claims.sh          (silent = compliant)
#         scripts/validate-bash-route-claims.sh -v       (report what was scanned)
#
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO" || exit 1

VERBOSE=0
[ "${1:-}" = "-v" ] && VERBOSE=1

VERBOSE=$VERBOSE python3 - <<'PY'
import os, re, subprocess, sys

VERBOSE = os.environ.get("VERBOSE") == "1"
breaches = []

# --- what to scan -----------------------------------------------------------
# Tracked files only: an untracked scratch file is not shipped and not a claim.
try:
    tracked = subprocess.run(["git", "ls-files"], capture_output=True, text=True,
                             check=True).stdout.splitlines()
except Exception as e:
    print(f"BASHROUTE: cannot list tracked files ({e}) — the check cannot run", file=sys.stderr)
    sys.exit(1)

EXTS = (".md", ".sh", ".json", ".template", ".yaml", ".yml", ".js", ".py", ".txt")
files = [f for f in tracked if f.endswith(EXTS)]

if len(files) < 50:
    print(f"BASHROUTE: only {len(files)} files matched — the scan set collapsed, "
          "so a pass here would be meaningless", file=sys.stderr)
    sys.exit(1)

# --- structural exemptions: (start marker, end marker), not whole-file passes --
EXEMPT_REGIONS = {
    "project/deployment/scripts/test-merge-settings.sh": ("<<'JSON620'", "JSON620\n"),
    "scripts/validate-bash-route-claims.sh": ("# --- claim patterns", "# --- end claim patterns"),
    "scripts/validate-enforcement-claims.sh": ("# --- claim patterns", "# --- end claim patterns"),
}

# --- claim patterns ---------------------------------------------------------
# Two tiers. The first names the Bash route explicitly, so a gate-ish subject is enough
# to make it a claim about this guard. The second is generic praise that is only an
# overclaim when it is aimed at the guard, so it demands a narrower subject: without that
# split, "maintains security boundary" in an unrelated delegation example in the
# tool-permissions guide reads as a gate-guard overclaim, which it is not.
CLAIM = re.compile(
    r"clos\w*\s+(that|the|this)\s+route"
    r"|clos\w*\s+the\s+bash\s+route"
    r"|bash\s+route\s+is\s+clos"
    r"|(covers|covering)\s+(the\s+)?bash\b"
    r"|(no|any|all|every)\s+bash\s+write"
    r"|blocks\s+all\s+bash",
    re.I)

CLAIM_GUARD_ONLY = re.compile(
    r"security\s+boundary"
    r"|backs?\s+up\s+the\s+permission\s+block"
    r"|complet\w*\s+the\s+(protection|coverage)",
    re.I)

SUBJECT = re.compile(r"gate[- ]?guard|guard|hook|gate|deny|permission|quality-gates", re.I)
SUBJECT_GUARD = re.compile(r"gate[- ]?guard|bash[- ]?(write[- ]?)?guard|guard hook|bash", re.I)

NEGATOR = re.compile(r"\b(not|never|cannot|can't|n't|no|without|narrow\w*|speed bump|rather than)\b", re.I)
DENIAL = re.compile(r"is false|is not true|must not be described|is wrong|would be false|is an overclaim", re.I)
# --- end claim patterns -----------------------------------------------------

SENT = re.compile(r"(?<=[.!?;])\s+|\n\n+")


def exempt_span(path, text):
    region = EXEMPT_REGIONS.get(path)
    if not region:
        return None
    start = text.find(region[0])
    if start < 0:
        return None
    end = text.find(region[1], start + len(region[0]))
    return (start, end if end >= 0 else len(text))


scanned = 0
for path in files:
    try:
        text = open(path, encoding="utf-8", errors="replace").read()
    except Exception:
        continue
    scanned += 1
    span = exempt_span(path, text)

    pos = 0
    for sentence in SENT.split(text):
        idx = text.find(sentence, pos)
        if idx >= 0:
            pos = idx + len(sentence)
        m = CLAIM.search(sentence)
        if m and not SUBJECT.search(sentence):
            m = None
        if not m:
            m = CLAIM_GUARD_ONLY.search(sentence)
            if m and not SUBJECT_GUARD.search(sentence):
                m = None
        if not m:
            continue
        if span and span[0] <= idx <= span[1]:
            continue  # inside the declared historical/pattern region
        if DENIAL.search(sentence):
            continue
        before = sentence[:m.start()]
        if NEGATOR.search(before):
            continue
        line_no = text[:idx].count("\n") + 1
        flat = " ".join(sentence.split())[:160]
        breaches.append(f"BASHROUTE: {path}:{line_no} claims the guard closes/completes "
                        f"the Bash route: {flat}")

# --- COUNT: the branch number is the same everywhere, and it matches the code -
#
# An audit once found the guard's header undercounting its own logic by two, and before
# this release the count was stated on two different bases in different files. Both are the
# same defect as overclaiming, pointed the other way, so the number is checked against the
# code rather than trusted. The guard's numbered header list and its in-code branch markers
# must agree, and every document quoting a branch count must quote that number.
GUARD = "library/hooks/gate-guard.sh"
if os.path.exists(GUARD):
    guard_src = open(GUARD, encoding="utf-8").read()
    # The two lists are told apart by indentation, which is the only thing that
    # distinguishes them: the header's catalogue is indented under "WHAT IT CATCHES",
    # the in-code markers sit flush at "# N.".
    header_entries = len(re.findall(r"^#\s{2,}\d+\.\s+\S", guard_src, re.M))
    code_markers = len(re.findall(r"^# \d+\.\s", guard_src, re.M))
    if header_entries != code_markers:
        breaches.append(f"BASHROUTE: {GUARD} header lists {header_entries} branches but the code "
                        f"carries {code_markers} branch markers — the header is describing "
                        "something the code does not do")
    declared = code_markers
    for path in ("library/CLAUDE.md", "library/settings.json.template",
                 "scripts/validate-enforcement-claims.sh", "CHANGELOG.md"):
        if not os.path.exists(path):
            continue
        body = open(path, encoding="utf-8", errors="replace").read()
        for stated in set(re.findall(r"(\d+)\s+detection branches", body)):
            if int(stated) != declared:
                breaches.append(f"BASHROUTE: {path} says {stated} detection branches but "
                                f"{GUARD} carries {declared}")
else:
    breaches.append(f"BASHROUTE: {GUARD} is missing — there is no guard to describe")

# --- PRESENCE: the honest sentence must still be there ----------------------
REQUIRED_HONESTY = {
    "library/hooks/gate-guard.sh":
        r"(does not close|not close|NOT close|closes the Bash route\" is false)",
    "library/settings.json.template":
        r"(does NOT close|NOT close|not close) it",
    "library/CLAUDE.md":
        r"(does \*\*not\*\* close|does not close|not\*\* close)",
}
for path, pattern in REQUIRED_HONESTY.items():
    if not os.path.exists(path):
        breaches.append(f"BASHROUTE: {path} is missing — the honest description of the "
                        "guard's limits does not reach users")
        continue
    body = open(path, encoding="utf-8", errors="replace").read()
    if not re.search(pattern, body):
        breaches.append(f"BASHROUTE: {path} no longer states that the guard does NOT close "
                        "the Bash route — silence here reads as a boundary")
    if not re.search(r"A11-ISS-16", body):
        breaches.append(f"BASHROUTE: {path} no longer cites A11-ISS-16, so a reader cannot "
                        "trace why the limit is stated")

for b in breaches:
    print(b, file=sys.stderr)

if VERBOSE and not breaches:
    print(f"bashroute: {scanned} tracked files scanned; no surviving claim that the gate "
          f"guard closes the Bash route; {len(REQUIRED_HONESTY)} files still state the limit; "
          f"guard header and code agree on {code_markers} detection branches")

sys.exit(1 if breaches else 0)
PY
