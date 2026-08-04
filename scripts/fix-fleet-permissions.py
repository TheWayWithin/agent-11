#!/usr/bin/env python3
"""fix-fleet-permissions.py — remediate what validate-fleet-permissions.sh detects.

A11-ISS-18. Two edits per settings file, and nothing else:

  1. `permissions.defaultMode: bypassPermissions` -> `acceptEdits`.
     NOT removed. Removing it lands on `default`, which prompts on every file edit; that
     gets switched off again within a day, and a weaker setting that survives beats a
     stronger one that does not. `acceptEdits` keeps edits flowing while restoring the
     prompt on shell, network and — the part that actually matters here — writes to
     PROTECTED PATHS, which include `.claude/`. Under bypassPermissions an agent can
     rewrite `.claude/settings.json` and delete the very deny rules that judge it; under
     acceptEdits that write prompts. See the header of validate-fleet-permissions.sh for
     the documentation this rests on.

  2. Blanket `permissions.allow` entries for write-capable tools are dropped: a bare
     `Bash`, `Edit`, `Write`, `MultiEdit`, `NotebookEdit`, or the same with only a
     wildcard argument. Specific grants like `Bash(git add:*)` are KEPT — they are
     genuinely in use and removing them would put a prompt in front of routine work.
     Bare `Read`, `Glob`, `Grep` and friends are KEPT: they are not write-capable, they
     cannot reach a deny rule's subject matter, and prompting on every read is the
     friction that gets a permission model turned off.

EVERYTHING ELSE IS PRESERVED. These are user-owned local settings carrying real
allowlists, env vars and MCP grants. The file is parsed, the two keys above are edited in
place, and it is written back with key order intact. It is never templated over.

Dry run by default. `--apply` writes, after taking a timestamped backup beside each file.

Usage:
  scripts/fix-fleet-permissions.py                 # show what would change
  scripts/fix-fleet-permissions.py --apply         # do it
  scripts/fix-fleet-permissions.py --apply --repo solomarket   # one repo
"""

import argparse
import json
import os
import re
import shutil
import sys
from datetime import datetime

REGISTRY = os.environ.get(
    "REGISTRY", os.path.expanduser("~/Shared/tools/agent-11-fleet/registry.yaml"))

WRITE_TOOLS = ("Bash", "Edit", "Write", "MultiEdit", "NotebookEdit")
_TOOL = re.compile(r'^(%s)\s*(?:\((.*)\))?$' % "|".join(WRITE_TOOLS), re.S)


def is_blanket(rule):
    """Must stay identical to is_blanket() in validate-fleet-permissions.sh.

    If the detector and the remediation disagree, the check reports a problem the fixer
    will not fix, or the fixer strips a grant the check never objected to. Bare tool name,
    or an argument made only of path-wildcard punctuation (`*`, `**`, `//**`, `~/**`,
    `**/**`, `:*`). A named file type such as `Edit(**/*.json)` is not blanket.
    """
    m = _TOOL.match(str(rule).strip())
    if not m:
        return False
    arg = m.group(2)
    if arg is None:
        return True
    arg = arg.strip()
    return arg == "" or bool(re.fullmatch(r'[~/:*]+', arg))
BYPASS = {"bypasspermissions", "bypass"}
REPLACEMENT_MODE = "acceptEdits"


def registry_entries(path):
    entries, cur = [], None
    for line in open(path, encoding="utf-8"):
        m = re.match(r'^\s*-\s+name:\s*(.+?)\s*$', line)
        if m:
            cur = {"name": m.group(1).strip().strip('"')}
            entries.append(cur)
            continue
        if cur is not None:
            m2 = re.match(r'^\s+(path|tier):\s*(.+?)\s*$', line)
            if m2:
                cur[m2.group(1)] = m2.group(2).strip().strip('"')
    return entries


def plan_for(cfg):
    """Return (changes, mutate) — what would change, and a function to apply it."""
    changes = []
    perms = cfg.get("permissions")
    if not isinstance(perms, dict):
        return changes, None

    mode = perms.get("defaultMode")
    if mode and str(mode).strip().lower() in BYPASS:
        changes.append(f"permissions.defaultMode: {mode!r} -> {REPLACEMENT_MODE!r}")
    top_mode = cfg.get("defaultMode")
    if top_mode and str(top_mode).strip().lower() in BYPASS:
        changes.append(f"defaultMode: {top_mode!r} -> {REPLACEMENT_MODE!r}")

    allow = perms.get("allow")
    dropped = [r for r in allow if is_blanket(r)] if isinstance(allow, list) else []
    if dropped:
        changes.append("permissions.allow: drop blanket " + ", ".join(repr(d) for d in dropped))

    if not changes:
        return changes, None

    def mutate(c):
        p = c["permissions"]
        if p.get("defaultMode") and str(p["defaultMode"]).strip().lower() in BYPASS:
            p["defaultMode"] = REPLACEMENT_MODE
        if c.get("defaultMode") and str(c["defaultMode"]).strip().lower() in BYPASS:
            c["defaultMode"] = REPLACEMENT_MODE
        if isinstance(p.get("allow"), list):
            p["allow"] = [r for r in p["allow"] if not is_blanket(r)]
        return c

    return changes, mutate


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--apply", action="store_true", help="write changes (default: dry run)")
    ap.add_argument("--repo", action="append", help="limit to these registry names")
    args = ap.parse_args()

    if not os.path.exists(REGISTRY):
        print(f"registry not found: {REGISTRY}", file=sys.stderr)
        return 1

    stamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    touched = skipped = 0

    for e in registry_entries(REGISTRY):
        if args.repo and e["name"] not in args.repo:
            continue
        path = os.path.expanduser(e.get("path", ""))
        if not path or not os.path.isdir(path):
            continue
        for fn in ("settings.json", "settings.local.json"):
            f = os.path.join(path, ".claude", fn)
            if not os.path.exists(f):
                continue
            try:
                original = open(f, encoding="utf-8").read()
                cfg = json.loads(original)
            except Exception as ex:
                print(f"SKIP  {e['name']}/{fn}: unparseable ({ex})")
                skipped += 1
                continue

            changes, mutate = plan_for(cfg)
            if not changes:
                continue

            keys_before = list(cfg.keys())
            print(f"{'APPLY' if args.apply else 'WOULD'} {e['name']}/.claude/{fn}")
            for c in changes:
                print(f"        {c}")

            if not args.apply:
                touched += 1
                continue

            shutil.copy2(f, f"{f}.bak-{stamp}")
            cfg = mutate(cfg)
            # Reread-and-verify below depends on this being valid JSON with the same
            # top-level keys; a settings file that fails to parse disables every rule
            # in it, which would be a worse outcome than the drift being fixed.
            text = json.dumps(cfg, indent=2, ensure_ascii=False) + "\n"
            json.loads(text)
            open(f, "w", encoding="utf-8").write(text)

            check = json.load(open(f, encoding="utf-8"))
            assert list(check.keys()) == keys_before, f"{f}: top-level keys changed"
            touched += 1

    print(f"\n{'changed' if args.apply else 'would change'}: {touched} file(s); "
          f"skipped (unparseable): {skipped}")
    if not args.apply and touched:
        print("dry run — re-run with --apply to write")
    return 0


if __name__ == "__main__":
    sys.exit(main())
