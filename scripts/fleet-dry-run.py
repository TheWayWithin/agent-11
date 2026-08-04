#!/usr/bin/env python3
"""fleet-dry-run.py — what an agent-11 upgrade would do to each in-scope repo.

T-245, deliverable 2. Reads only. Runs install.sh with --upgrade --dry-run,
which short-circuits before any work and was verified on 2026-08-04 to leave
the target repo byte-identical and to create no backup directory.

Per repo it reports:
  * the agent-11 version stamp, if any
  * the current branch
  * TRACKED-and-modified files inside .claude/ — the only thing that blocks an
    upgrade, because that is a local customisation the upgrade would overwrite
  * untracked litter inside .claude/ — noise from earlier installs, not a
    conflict, and explicitly not a reason to skip
  * how many of the four gate deny rules are present
  * the upgrade plan install.sh itself prints

Trader-7 is deliberately NOT executed against, even in dry-run: the spec says
it is touched last and never in this run. Its read-only facts are still
gathered from git and the filesystem, so it is not silently missing from the
report.

Usage:
    scripts/fleet-dry-run.py            # human-readable report
    scripts/fleet-dry-run.py --json     # machine-readable
"""

import argparse
import json
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.dirname(HERE)
INSTALL_SH = os.path.join(REPO_ROOT, "project", "deployment", "scripts", "install.sh")

REGISTRY = os.environ.get(
    "REGISTRY", os.path.expanduser("~/Shared/tools/agent-11-fleet/registry.yaml"))

IN_SCOPE = [
    "Trader-7", "aisearcharena", "JamieWatters", "SEOAgent",
    "aimpactscanner-mvp", "llm-txt-mastery", "aisearchmastery",
]

# Named explicitly rather than inferred: the spec's rule, not a heuristic.
NEVER_EXECUTE = {"Trader-7"}

GATE_RULES = [
    "Edit(.quality-gates.json)",
    "Edit(**/*.quality-gates.json)",
    "Edit(gates/**)",
    "Edit(.gates/**)",
]


def registry_entries(path):
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


def git(path, *args, timeout=20):
    try:
        r = subprocess.run(["git", "-C", path, *args],
                           capture_output=True, text=True, timeout=timeout)
        return r.stdout if r.returncode == 0 else ""
    except (OSError, subprocess.SubprocessError):
        return ""


def claude_dir_status(path):
    """Split .claude/ changes into blocking (tracked+modified) and litter.

    The distinction is the whole point. An earlier draft of the sweep rule
    said "skip any dirty repo", which would have skipped 7 of 8 — because the
    dirt is overwhelmingly untracked backup artefacts that previous installs
    left behind, not anyone's work.
    """
    out = git(path, "status", "--porcelain", "--", ".claude")
    blocking, litter = [], []
    for line in out.splitlines():
        if not line.strip():
            continue
        code, _, name = line[:2], line[2:3], line[3:]
        (litter if code.strip() == "??" else blocking).append(name.strip())
    return blocking, litter


def read_stamp(path):
    stamp = os.path.join(path, ".claude", "agent-11-version")
    if not os.path.exists(stamp):
        return None
    try:
        with open(stamp, encoding="utf-8") as fh:
            return json.load(fh).get("version")
    except (OSError, ValueError):
        return None


def count_gate_rules(path):
    settings = os.path.join(path, ".claude", "settings.json")
    if not os.path.exists(settings):
        return 0
    try:
        with open(settings, encoding="utf-8") as fh:
            data = json.load(fh)
    except (OSError, ValueError):
        return 0
    deny = [str(d).strip() for d in (data.get("permissions", {}).get("deny") or [])]
    return sum(1 for r in GATE_RULES if r in deny)


def upgrade_plan(path):
    """Run install.sh --upgrade --dry-run inside the repo and capture the plan."""
    try:
        r = subprocess.run(
            ["bash", INSTALL_SH, "--upgrade", "--dry-run"],
            cwd=path, capture_output=True, text=True, timeout=120,
        )
        text = (r.stdout or "") + (r.stderr or "")
        return text.strip(), r.returncode
    except subprocess.TimeoutExpired:
        return "(dry run timed out after 120s)", 124
    except (OSError, subprocess.SubprocessError) as exc:
        return "(dry run could not be executed: %s)" % exc, 1


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--json", action="store_true")
    args = ap.parse_args()

    by_name = {e["name"]: e for e in registry_entries(REGISTRY)}
    rows = []

    for name in IN_SCOPE:
        e = by_name.get(name)
        if not e:
            rows.append({"name": name, "error": "not in the registry"})
            continue
        path = e.get("path", "")
        if not os.path.isdir(path):
            rows.append({"name": name, "path": path, "error": "path missing"})
            continue

        blocking, litter = claude_dir_status(path)
        row = {
            "name": name,
            "path": path,
            "tier": e.get("tier", ""),
            "version": read_stamp(path),
            "branch": (git(path, "rev-parse", "--abbrev-ref", "HEAD") or "?").strip(),
            "registry_branch": e.get("branch", ""),
            "gate_rules": count_gate_rules(path),
            "blocking": blocking,
            "litter_count": len(litter),
            "executed": False,
            "plan": "",
        }
        if name in NEVER_EXECUTE:
            row["plan"] = ("NOT EXECUTED — the spec holds this repo back until last and "
                           "out of this run entirely; it runs live on Railway. Facts above "
                           "are read from git and the filesystem only.")
        else:
            plan, code = upgrade_plan(path)
            row["executed"] = True
            row["plan"] = plan
            row["plan_exit"] = code
        rows.append(row)

    if args.json:
        print(json.dumps(rows, indent=2))
        return 0

    print("=" * 78)
    print("T-245 DRY RUN — nothing was changed in any repo")
    print("=" * 78)
    print()

    hdr = "%-20s %-9s %-22s %-6s %-9s %s" % (
        "REPO", "VERSION", "BRANCH", "GATES", "BLOCKING", "LITTER")
    print(hdr)
    print("-" * len(hdr))
    for r in rows:
        if r.get("error"):
            print("%-20s %s" % (r["name"], r["error"]))
            continue
        print("%-20s %-9s %-22s %-6s %-9s %s" % (
            r["name"], r["version"] or "-", r["branch"],
            "%d/4" % r["gate_rules"],
            str(len(r["blocking"])), r["litter_count"]))
    print()

    for r in rows:
        if r.get("error"):
            continue
        print("-" * 78)
        print("%s   (%s)" % (r["name"], r["path"]))
        if r["blocking"]:
            print("  BLOCKING — tracked and modified inside .claude/:")
            for f in r["blocking"]:
                print("    %s" % f)
        else:
            print("  Not blocked: no tracked-and-modified file inside .claude/")
        print("  Untracked .claude/ artefacts from earlier installs: %d (litter, not a conflict)"
              % r["litter_count"])
        if r["branch"] != (r["registry_branch"] or r["branch"]):
            print("  NOTE: on '%s' but the registry says '%s'"
                  % (r["branch"], r["registry_branch"]))
        print("  Upgrade plan:")
        for line in (r["plan"] or "(no output)").splitlines():
            print("    %s" % line)
        print()

    blocked = [r["name"] for r in rows if r.get("blocking")]
    print("=" * 78)
    print("%d of %d repos are blocked by a tracked-and-modified .claude/ file%s"
          % (len(blocked), len(rows), (": " + ", ".join(blocked)) if blocked else "."))
    print("Nothing was upgraded. Approve before deliverable 3 runs.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
