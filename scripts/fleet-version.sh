#!/usr/bin/env bash
#
# fleet-version.sh — what version of AGENT-11 does each registered repo carry?
#
# T-245, deliverable 1's second half, and the task's own oracle: "the sweep is only done
# when a single command prints every in-scope repo with the new version against its name."
# This is that command. Until it existed, "rolled v6.2.0 to the fleet" was a claim with
# nothing to check it against, which is why T-245 sat open from 21 July.
#
# Reads `.claude/agent-11-version`, the stamp install.sh writes on every install and
# upgrade. A repo installed before the stamp existed reports `-` rather than a guess: the
# absence of a marker is information, and inventing a version from file mtimes or content
# heuristics would be the kind of plausible-but-unverified number this repo keeps removing.
#
# It also reports the two things that decide whether a repo can be upgraded at all — the
# branch, and whether any TRACKED-and-modified file sits under `.claude/`. Untracked files
# there are install litter, not a conflict, and are counted separately so the difference is
# visible rather than argued about.
#
# Exit status is 0 whenever the fleet could be read. This is a REPORTER, not a gate: it
# answers "what is out there", and a repo being out of date is the normal state before a
# sweep rather than an error. `--in-scope` narrows to T-245's seven.
#
# Usage:
#   scripts/fleet-version.sh                 every registered repo
#   scripts/fleet-version.sh --in-scope      only T-245's seven target repos
#   scripts/fleet-version.sh --json          machine-readable
#
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO" || exit 1
REGISTRY="${REGISTRY:-$HOME/Shared/tools/agent-11-fleet/registry.yaml}"

MODE=table
SCOPE=all
for a in "$@"; do
  case "$a" in
    --json)     MODE=json ;;
    --in-scope) SCOPE=inscope ;;
    -h|--help)  sed -n '2,28p' "$0"; exit 0 ;;
  esac
done

MODE=$MODE SCOPE=$SCOPE REGISTRY="$REGISTRY" python3 - <<'PY'
import json, os, re, subprocess, sys

MODE = os.environ["MODE"]
SCOPE = os.environ["SCOPE"]
REGISTRY = os.environ["REGISTRY"]

# T-245's scope, settled in the spec's second pass on 2026-08-04. Not agent-11 (it is the
# library, not a target), not the parked or killed products, not executor-file/-site which
# moved to tier skip when A11-ISS-19 found they had no install at all.
IN_SCOPE = ["Trader-7", "aisearcharena", "JamieWatters", "SEOAgent",
            "aimpactscanner-mvp", "llm-txt-mastery", "aisearchmastery"]

GATE_RULES = ["Edit(.quality-gates.json)", "Edit(**/*.quality-gates.json)",
              "Edit(gates/**)", "Edit(.gates/**)"]

if not os.path.exists(REGISTRY):
    print(f"fleet-version: registry not found at {REGISTRY}", file=sys.stderr)
    sys.exit(1)

entries, cur = [], None
for line in open(REGISTRY, encoding="utf-8"):
    m = re.match(r'^\s*-\s+name:\s*(.+?)\s*$', line)
    if m:
        cur = {"name": m.group(1).strip().strip('"')}
        entries.append(cur)
        continue
    if cur is not None:
        m2 = re.match(r'^\s+(path|tier):\s*(.+?)\s*$', line)
        if m2:
            cur[m2.group(1)] = m2.group(2).strip().strip('"')

if len(entries) < 5:
    print(f"fleet-version: parsed only {len(entries)} entries — the parse collapsed",
          file=sys.stderr)
    sys.exit(1)

if SCOPE == "inscope":
    by_name = {e["name"]: e for e in entries}
    missing = [n for n in IN_SCOPE if n not in by_name]
    if missing:
        print(f"fleet-version: in-scope repos absent from the registry: {missing}",
              file=sys.stderr)
        sys.exit(1)
    entries = [by_name[n] for n in IN_SCOPE]


def git(path, *args):
    try:
        r = subprocess.run(["git", "-C", path, *args], capture_output=True,
                           text=True, timeout=20)
        return r.stdout.strip() if r.returncode == 0 else ""
    except Exception:
        return ""


rows = []
for e in entries:
    path = os.path.expanduser(e.get("path", ""))
    row = {"repo": e["name"], "tier": e.get("tier", "?"), "path": path,
           "present": bool(path) and os.path.isdir(path)}
    if not row["present"]:
        row.update(version=None, stamped_at=None, branch=None,
                   claude_tracked_modified=None, claude_untracked=None,
                   gate_rules=None, note="not on this machine")
        rows.append(row)
        continue

    stamp = os.path.join(path, ".claude", "agent-11-version")
    version = stamped = None
    if os.path.exists(stamp):
        try:
            d = json.load(open(stamp, encoding="utf-8"))
            version, stamped = d.get("version"), d.get("installed_at")
        except Exception:
            version = "unparseable"
    row["version"] = version
    row["stamped_at"] = stamped

    row["branch"] = git(path, "rev-parse", "--abbrev-ref", "HEAD") or None

    # A tracked-and-modified file under .claude/ is a local customisation an upgrade
    # would overwrite; an untracked one is almost always a backup an earlier install
    # left behind. Only the first blocks anything.
    #
    # `git diff --name-only` rather than parsing `status --porcelain`: porcelain's
    # two-character status field plus its quoting rules cost this script a leading dot
    # off every path on the first run, which is exactly the sort of small lie that makes
    # a report untrustworthy. diff returns bare paths and needs no parsing. Unstaged and
    # staged are unioned, since a staged change is still a change an upgrade would clobber.
    unstaged = git(path, "diff", "--name-only", "--", ".claude").splitlines()
    staged = git(path, "diff", "--cached", "--name-only", "--", ".claude").splitlines()
    row["claude_tracked_modified"] = sorted({p for p in unstaged + staged if p.strip()})
    # Untracked is COUNTED from porcelain, not from ls-files. ls-files recurses into an
    # untracked directory and returns every file inside it, so fifteen leftover backup
    # directories read as 481 items. Porcelain collapses each to one entry, which is both
    # what `git status` shows a human and what the survey in the spec counted. Counting
    # lines that start with `??` needs no path parsing, so the earlier objection does not
    # apply here.
    porcelain = git(path, "status", "--porcelain", "--", ".claude")
    row["claude_untracked"] = len([l for l in porcelain.splitlines() if l.startswith("??")])

    found = 0
    for fn in ("settings.json", "settings.local.json"):
        f = os.path.join(path, ".claude", fn)
        if not os.path.exists(f):
            continue
        try:
            deny = (json.load(open(f, encoding="utf-8")).get("permissions") or {}).get("deny") or []
        except Exception:
            continue
        found = max(found, sum(1 for g in GATE_RULES if g in deny))
    row["gate_rules"] = found
    rows.append(row)

if MODE == "json":
    json.dump(rows, sys.stdout, indent=2)
    sys.stdout.write("\n")
    sys.exit(0)

hdr = f"{'repo':<22}{'tier':<14}{'version':<12}{'gates':<7}{'branch':<12}{'blocked':<9}{'litter'}"
print(hdr)
print("-" * len(hdr))
for r in rows:
    if not r["present"]:
        print(f"{r['repo']:<22}{r['tier']:<14}{'—':<12}{'—':<7}{'—':<12}{'—':<9}not on this machine")
        continue
    blocked = "YES" if r["claude_tracked_modified"] else "no"
    print(f"{r['repo']:<22}{r['tier']:<14}{(r['version'] or '-'):<12}"
          f"{str(r['gate_rules'])+'/4':<7}{(r['branch'] or '?'):<12}{blocked:<9}"
          f"{r['claude_untracked']} untracked")

present = [r for r in rows if r["present"]]
stamped = [r for r in present if r["version"]]
gated = [r for r in present if (r["gate_rules"] or 0) == 4]
blocked = [r for r in present if r["claude_tracked_modified"]]
print()
print(f"{len(present)} repo(s) present · {len(stamped)} carry a version stamp · "
      f"{len(gated)} carry all four gate deny rules · {len(blocked)} blocked by a "
      f"tracked-and-modified file under .claude/")
if blocked:
    for r in blocked:
        print(f"  blocked: {r['repo']} — " + ", ".join(r["claude_tracked_modified"]))
PY
