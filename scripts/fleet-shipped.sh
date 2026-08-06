#!/usr/bin/env bash
#
# fleet-shipped.sh — is the work actually shipped, everywhere?
#
# Written 2026-08-05 because the honest answer to "have all the changes been committed,
# pushed and merged?" was "nobody knows". Work was landing in working trees and on
# branches and no single command could say what had actually reached `main` on a remote.
#
# For every registered repo it answers four questions, in the order that matters:
#
#   UNCOMMITTED  tracked files changed but not committed. Invisible to everyone else,
#                lost if the machine dies, and impossible to review.
#   UNPUSHED     commits on the current branch that no remote has. Exists on one laptop.
#   BRANCHES     local branches not merged into the default branch, with their age and
#                whether they are ahead of it. This is where finished work goes to die.
#   BEHIND       the default branch is behind its remote, i.e. someone else pushed and
#                this checkout has not caught up.
#
# It reports. It does not commit, push, merge or delete anything, and it never will:
# deciding what is finished is a human judgement, and a script that guessed would either
# ship half-work or destroy it.
#
# Usage:
#   scripts/fleet-shipped.sh              every registered repo
#   scripts/fleet-shipped.sh --dirty      only repos with something outstanding
#   scripts/fleet-shipped.sh --fetch      git fetch first, so "behind" is accurate
#                                         (slower; without it, remote state may be stale)
#
set -uo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REGISTRY="${REGISTRY:-$HOME/Shared/tools/agent-11-fleet/registry.yaml}"

DIRTY_ONLY=0; DO_FETCH=0
for a in "$@"; do
  case "$a" in
    --dirty) DIRTY_ONLY=1 ;;
    --fetch) DO_FETCH=1 ;;
    -h|--help) sed -n '2,30p' "$0"; exit 0 ;;
  esac
done

DIRTY_ONLY=$DIRTY_ONLY DO_FETCH=$DO_FETCH REGISTRY="$REGISTRY" python3 - <<'PY'
import os, re, subprocess, sys

DIRTY_ONLY = os.environ["DIRTY_ONLY"] == "1"
DO_FETCH = os.environ["DO_FETCH"] == "1"
REGISTRY = os.environ["REGISTRY"]

if not os.path.exists(REGISTRY):
    print(f"fleet-shipped: registry not found at {REGISTRY}", file=sys.stderr)
    sys.exit(1)

entries, cur = [], None
for line in open(REGISTRY, encoding="utf-8"):
    m = re.match(r'^\s*-\s+name:\s*(.+?)\s*$', line)
    if m:
        cur = {"name": m.group(1).strip().strip('"')}
        entries.append(cur)
        continue
    if cur is not None:
        m2 = re.match(r'^\s+(path|tier|branch):\s*(.+?)\s*$', line)
        if m2:
            cur[m2.group(1)] = m2.group(2).strip().strip('"')


def git(path, *args, timeout=60):
    try:
        r = subprocess.run(["git", "-C", path, *args], capture_output=True,
                           text=True, timeout=timeout)
        return r.stdout.strip() if r.returncode == 0 else ""
    except Exception:
        return ""


# Framework files are separated from application code. An upgrade of the agent-11
# framework leaves ~40 modified files under .claude/ and friends in every repo; lumping
# those in with real work makes every repo look alarming and hides the code that matters.
#
# `docs/` is NOT a blanket prefix, and that was a real defect: a cold review found that
# aisearcharena keeps 18 tracked product documents under docs/ (PRD sections, positioning,
# foundation docs), and an uncommitted edit to any of them was invisible to the tool whose
# entire job is answering "is the work actually shipped". Only the five files install.sh
# actually writes there are treated as framework.
FRAMEWORK = re.compile(
    r'^(\.claude/|missions/|templates/|field-manual/|schemas/|gates/|stack-profiles/'
    r'|docs/(MCP-GUIDE|MCP-MIGRATION-GUIDE|MCP-PROFILES|MCP-TROUBLESHOOTING|UPGRADE)\.md$'
    r'|\.mcp\.json|\.mcp\.json\.template|\.env\.mcp|\.env\.mcp\.template|mcp-setup\.sh)')

# Untracked build output. These are genuinely not worth reporting as unshipped work, and
# they are excluded by NAME rather than by living under a convenient prefix.
# Build output and tool leftovers. Matched by NAME, and the -staging variants are named
# explicitly: playwright-report-staging/ and test-results-staging/ exist in solomarket and
# were reported as unshipped work on the first run with untracked detection enabled.
# CLAUDE.md.backup-* and settings.json.backup-* are agent-11 install artefacts — install.sh
# writes backups outside the repo as of 2026-08-05, but historic ones are still on disk in
# most repos and are not work anyone needs to ship.
ARTEFACT = re.compile(
    r'(^|/)(\.DS_Store|node_modules/|\.next/|dist/|build/|coverage/|__pycache__/'
    r'|test-results(-\w+)?/|playwright-report(-\w+)?/|Logs/|\.temp/)'
    r'|(^|/)(CLAUDE\.md|settings(\.local)?\.json)\.backup-\d'
    r'|\.(log|pyc)$')

# Tiers that are not "work in flight" and so cannot have unshipped work worth reporting.
# `archived` joined this on 2026-08-05 (A11-ISS-26): it was documented as a real tier in
# registry.yaml the same day, and digital-estate — retired, GitHub read-only, folder moved
# to Archive/ — still has .git on disk, so without it the repo reports as UNCOMMITTED noise
# in every run, forever. A report that always contains known noise stops being read.
EXCLUDED_TIERS = ("skip", "different-framework", "archived")

rows, missing = [], []
for e in entries:
    path = os.path.expanduser(e.get("path", ""))
    if not path or not os.path.isdir(path) or not os.path.isdir(os.path.join(path, ".git")):
        # Silently skipping made a repo that has vanished from disk indistinguishable
        # from one that is perfectly clean. ASMGE, mcp-7 and mcp-11 are registered and
        # absent; that is registry drift worth seeing, not an all-clear.
        if e.get("tier") not in EXCLUDED_TIERS:
            missing.append((e["name"], e.get("tier", "?"), path or "<no path>"))
        continue
    if e.get("tier") in EXCLUDED_TIERS:
        continue

    if DO_FETCH:
        git(path, "fetch", "--quiet", "--all", timeout=120)

    r = {"name": e["name"], "tier": e.get("tier", "?"), "path": path}
    r["branch"] = git(path, "rev-parse", "--abbrev-ref", "HEAD") or "?"

    changed = set(git(path, "diff", "--name-only").splitlines()) | \
              set(git(path, "diff", "--cached", "--name-only").splitlines())
    changed = {c for c in changed if c.strip()}
    r["app_dirty"] = sorted(c for c in changed if not FRAMEWORK.match(c))
    r["fw_dirty"] = len(changed) - len(r["app_dirty"])

    # UNTRACKED files. Previously not checked at all, which meant a brand-new file — the
    # single most common shape of unshipped work — was invisible in a clean repo. Build
    # output and framework files are filtered out so this reports work, not noise.
    untracked = [u for u in git(path, "ls-files", "--others", "--exclude-standard").splitlines()
                 if u.strip() and not ARTEFACT.search(u) and not FRAMEWORK.match(u)]
    r["untracked"] = sorted(untracked)

    # Default branch: the REGISTRY wins, because origin/HEAD lies here.
    #
    # aimpactmonitor, PlebTest and modeloptix all work on `develop` while GitHub's
    # origin/HEAD still points at `main`. Trusting origin/HEAD made this script report
    # develop as a stranded branch carrying 14, 86 and 6 unmerged commits — three false
    # alarms out of twelve, in a report whose whole job is telling Jamie what is genuinely
    # unshipped. The registry already records the real working branch, with a note saying
    # so, and it is maintained for the bulk-ops scripts anyway.
    default = e.get("branch", "").strip()
    if default and not git(path, "rev-parse", "--verify", "--quiet", f"refs/heads/{default}"):
        default = ""          # registry names a branch this checkout does not have
    if not default:
        head = git(path, "symbolic-ref", "--quiet", "refs/remotes/origin/HEAD")
        default = head.rsplit("/", 1)[-1] if head else ""
    if not default:
        for cand in ("main", "master"):
            if git(path, "rev-parse", "--verify", "--quiet", f"refs/heads/{cand}"):
                default = cand
                break
    r["default"] = default or "?"

    has_remote = bool(git(path, "remote"))
    r["has_remote"] = has_remote
    r["unpushed"] = 0
    r["behind"] = 0
    r["forked"] = ""
    r["no_upstream"] = False
    if has_remote:
        # A branch with a remote but NO upstream makes `@{u}` fail, which returned ""
        # and was read as zero — so SEOAgent and mastery-ai Framework reported "in sync"
        # while carrying unpushed commits nobody could see. Fall back to origin/<default>
        # and say so, because silently reading as clean is the worst answer available.
        upstream = git(path, "rev-parse", "--abbrev-ref", "@{u}")
        ref = upstream or (f"origin/{default}" if default else "")
        r["no_upstream"] = not upstream and bool(ref)
        ahead = git(path, "rev-list", "--count", f"{ref}..HEAD") if ref else ""
        behind = git(path, "rev-list", "--count", f"HEAD..{ref}") if ref else ''
        r["unpushed"] = int(ahead) if ahead.isdigit() else 0
        r["behind"] = int(behind) if behind.isdigit() else 0
        r["forked"] = ""
        if r["unpushed"] and r["behind"]:
            base = git(path, "merge-base", "HEAD", "@{u}")
            r["forked"] = git(path, "log", "-1", "--format=%cr", base) if base else "unknown"

    # Local branches carrying work the default branch does not have.
    r["unmerged"] = []
    if default:
        for b in git(path, "branch", "--format=%(refname:short)").splitlines():
            b = b.strip()
            if not b or b == default:
                continue
            ahead = git(path, "rev-list", "--count", f"{default}..{b}")
            if ahead.isdigit() and int(ahead) > 0:
                when = git(path, "log", "-1", "--format=%cr", b)
                r["unmerged"].append((b, int(ahead), when))
    rows.append(r)

def outstanding(r):
    return (bool(r["app_dirty"]) or bool(r.get("untracked")) or r["unpushed"]
            or r["unmerged"] or r["behind"] or r.get("no_upstream"))

shown = [r for r in rows if outstanding(r)] if DIRTY_ONLY else rows

hdr = (f"{'repo':<22}{'branch':<14}{'dirty':<8}{'new':<7}{'state':<24}"
       f"{'unmerged'}")
print(hdr); print("-" * len(hdr))
for r in shown:
    if not r["has_remote"]:
        state = "no remote"
    elif r["unpushed"] and r["behind"]:
        state = f"DIVERGED {r['unpushed']}/{r['behind']}"
    elif r["unpushed"]:
        state = f"{r['unpushed']} unpushed"
    elif r["behind"]:
        state = f"{r['behind']} behind"
    else:
        state = "in sync"
    print(f"{r['name']:<22}{r['branch'][:13]:<14}{len(r['app_dirty']) or '-':<8}"
          f"{len(r.get('untracked') or []) or '-':<7}{state:<24}{len(r['unmerged']) or '-'}")

need = [r for r in rows if outstanding(r)]
print()
print(f"{len(rows)} repo(s) checked · {len(need)} with something outstanding")
if missing:
    print(f"{len(missing)} registered repo(s) NOT ON THIS MACHINE — state unknown, not clean:")
    for n, t, pth in missing:
        print(f"    {n} [{t}] {pth}")
if not DO_FETCH:
    print("(remote state may be stale — re-run with --fetch for accurate 'unpushed'/'behind')")

for r in need:
    print(f"\n{r['name']}  [{r['tier']}]  {r['path']}")
    if r["app_dirty"]:
        print(f"  UNCOMMITTED application files ({len(r['app_dirty'])}):")
        for f in r["app_dirty"][:12]:
            print(f"      {f}")
        if len(r["app_dirty"]) > 12:
            print(f"      … and {len(r['app_dirty']) - 12} more")
    if r.get("untracked"):
        print(f"  UNTRACKED, never added to git ({len(r['untracked'])}):")
        for f in r["untracked"][:10]:
            print(f"      {f}")
        if len(r["untracked"]) > 10:
            print(f"      … and {len(r['untracked']) - 10} more")
    if r["fw_dirty"]:
        print(f"  ({r['fw_dirty']} agent-11 framework file(s) also modified — from the "
              f"install, review and commit separately)")
    if not r["has_remote"]:
        print("  NO REMOTE — nothing here can ever be pushed")
    elif r["unpushed"] and r["behind"]:
        # Both directions means the histories forked; this is NOT work waiting to be
        # pushed and `git push` will refuse it. Calling it "unpushed" would send someone
        # to force-push, which is how the remote's commits get destroyed.
        print(f"  ** DIVERGED ** local and remote both moved since a common ancestor "
              f"{r['forked']}.")
        print(f"     {r['unpushed']} local-only commit(s), {r['behind']} remote-only commit(s).")
        print(f"     `git push` will refuse this. Needs a merge or rebase decision per repo —")
        print(f"     NEVER a force-push, which would discard the {r['behind']} on the remote.")
    elif r["unpushed"]:
        extra = " (no upstream set — `git push -u origin <branch>`)" if r.get("no_upstream") else ""
        print(f"  UNPUSHED: {r['unpushed']} commit(s) on {r['branch']} exist only on this "
              f"machine — a plain `git push` ships them{extra}")
    elif r["behind"]:
        print(f"  BEHIND: {r['behind']} commit(s) on the remote are not here — `git pull`")
    for b, ahead, when in r["unmerged"]:
        print(f"  UNMERGED BRANCH: {b} — {ahead} commit(s) not in {r['default']}, last active {when}")
PY
