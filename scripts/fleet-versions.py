#!/usr/bin/env python3
"""fleet-versions.py — read the agent-11 version stamp of every registered repo.

T-245. Until install.sh started writing `.claude/agent-11-version` there was no
way to read what version of the framework a repo carried, before or after an
upgrade. A survey of all 25 registered repos on 2026-08-04 found not one
version marker anywhere, which made "rolled v6.2.0 to the fleet" a claim with
no oracle. This is the reader half of that oracle: the sweep's before and
after picture.

It only reads. It never writes to a target repo, never runs git commands that
change state, and never touches uncommitted work.

Usage:
    scripts/fleet-versions.py                 # every registered repo
    scripts/fleet-versions.py --in-scope      # just the T-245 seven
    scripts/fleet-versions.py --json          # machine-readable
    scripts/fleet-versions.py --gates         # also report gate deny-rule count

Exit status is 0 whenever the scan itself succeeded, even if every repo is
unstamped: "nobody has a version yet" is a valid and expected answer before
the sweep, not an error.
"""

import argparse
import json
import os
import re
import subprocess
import sys

REGISTRY = os.environ.get(
    "REGISTRY", os.path.expanduser("~/Shared/tools/agent-11-fleet/registry.yaml"))

STAMP_RELPATH = os.path.join(".claude", "agent-11-version")

# The T-245 sweep scope, settled in the spec's second pass. agent-11 itself is
# the library rather than a target; executor-file and executor-file-site moved
# to tier: skip; the parked and killed products are out.
IN_SCOPE = [
    "Trader-7", "aisearcharena", "JamieWatters", "SEOAgent",
    "aimpactscanner-mvp", "llm-txt-mastery", "aisearchmastery",
]

# The four rules Sprint 6 ships. Kept literal so a partial set is visible as a
# partial set rather than rounded up to "present".
GATE_RULES = [
    "Edit(.quality-gates.json)",
    "Edit(**/*.quality-gates.json)",
    "Edit(gates/**)",
    "Edit(.gates/**)",
]


def registry_entries(path):
    """Mirror of registry_entries() in fix-fleet-permissions.py.

    Deliberately the same hand-rolled parse rather than a second dialect:
    pyyaml is not installed on this machine, and two parsers that disagree
    about the registry is exactly how a fleet script comes to skip a repo
    nobody noticed was missing.
    """
    entries, cur = [], None
    with open(path, encoding="utf-8") as fh:
        for line in fh:
            m = re.match(r'^\s*-\s+name:\s*(.+?)\s*$', line)
            if m:
                cur = {"name": m.group(1).strip().strip('"')}
                entries.append(cur)
                continue
            if cur is not None:
                m2 = re.match(r'^\s+(path|tier|branch):\s*(.+?)\s*$', line)
                if m2:
                    cur[m2.group(1)] = m2.group(2).strip().strip('"')
    return entries


def read_stamp(repo_path):
    """Return (version, detail) for a repo. Never raises."""
    stamp = os.path.join(repo_path, STAMP_RELPATH)
    if not os.path.isdir(repo_path):
        return None, "repo path missing"
    if not os.path.isdir(os.path.join(repo_path, ".claude")):
        return None, "no .claude/ (agent-11 not installed)"
    if not os.path.exists(stamp):
        return None, "no version stamp"
    try:
        with open(stamp, encoding="utf-8") as fh:
            data = json.load(fh)
    except (OSError, ValueError) as exc:
        return None, "unreadable stamp: %s" % exc
    return data.get("version") or None, data.get("installed_at", "")


def count_gate_rules(repo_path):
    """How many of the four gate deny rules this repo actually carries.

    Reads settings.json only. settings.local.json is user-owned and is not a
    place the framework may claim credit for (A11-ISS-18).
    """
    settings = os.path.join(repo_path, ".claude", "settings.json")
    if not os.path.exists(settings):
        return 0
    try:
        with open(settings, encoding="utf-8") as fh:
            data = json.load(fh)
    except (OSError, ValueError):
        return 0
    deny = data.get("permissions", {}).get("deny", []) or []
    deny = [str(d).strip() for d in deny]
    return sum(1 for rule in GATE_RULES if rule in deny)


def git(repo_path, *args):
    try:
        out = subprocess.run(
            ["git", "-C", repo_path, *args],
            capture_output=True, text=True, timeout=20,
        )
        return out.stdout.strip() if out.returncode == 0 else ""
    except (OSError, subprocess.SubprocessError):
        return ""


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--in-scope", action="store_true",
                    help="only the seven repos in the T-245 sweep")
    ap.add_argument("--json", action="store_true", help="machine-readable output")
    ap.add_argument("--gates", action="store_true",
                    help="also count the four gate deny rules per repo")
    args = ap.parse_args()

    try:
        entries = registry_entries(REGISTRY)
    except OSError as exc:
        print("cannot read registry %s: %s" % (REGISTRY, exc), file=sys.stderr)
        return 2

    if args.in_scope:
        by_name = {e["name"]: e for e in entries}
        missing = [n for n in IN_SCOPE if n not in by_name]
        if missing:
            print("WARNING: in-scope repos absent from the registry: %s"
                  % ", ".join(missing), file=sys.stderr)
        entries = [by_name[n] for n in IN_SCOPE if n in by_name]

    rows = []
    for e in entries:
        path = e.get("path", "")
        version, detail = read_stamp(path)
        row = {
            "name": e["name"],
            "tier": e.get("tier", ""),
            "path": path,
            "version": version,
            "detail": detail,
            "branch": git(path, "rev-parse", "--abbrev-ref", "HEAD") or "?",
        }
        if args.gates:
            row["gate_rules"] = count_gate_rules(path)
        rows.append(row)

    if args.json:
        print(json.dumps(rows, indent=2))
        return 0

    width = max([len(r["name"]) for r in rows] + [4])
    header = "%-*s  %-9s  %-8s  %s" % (width, "REPO", "VERSION", "BRANCH", "NOTE")
    if args.gates:
        header = "%-*s  %-9s  %-8s  %-6s  %s" % (
            width, "REPO", "VERSION", "BRANCH", "GATES", "NOTE")
    print(header)
    print("-" * len(header))

    stamped = 0
    for r in rows:
        version = r["version"] or "-"
        if r["version"]:
            stamped += 1
        note = r["detail"] if not r["version"] else "installed %s" % r["detail"]
        if args.gates:
            print("%-*s  %-9s  %-8s  %-6s  %s" % (
                width, r["name"], version, r["branch"],
                "%d/4" % r["gate_rules"], note))
        else:
            print("%-*s  %-9s  %-8s  %s" % (width, r["name"], version, r["branch"], note))

    print()
    print("%d of %d repos carry a version stamp." % (stamped, len(rows)))
    if args.gates:
        full = sum(1 for r in rows if r.get("gate_rules") == 4)
        print("%d of %d carry all four gate deny rules." % (full, len(rows)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
