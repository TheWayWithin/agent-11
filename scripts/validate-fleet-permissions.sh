#!/usr/bin/env bash
#
# validate-fleet-permissions.sh — the read-only gates can actually bite, fleet-wide.
#
# A11-ISS-18. Sprint 6 shipped four `permissions.deny` rules that make the quality-gate
# files unwritable by the agents they judge. The fleet audit of 2026-08-04 found twelve
# repos, agent-11 included, whose `.claude/settings.local.json` sets
# `permissions.defaultMode: bypassPermissions` alongside blanket `permissions.allow`
# entries for bare `Bash`, `Edit` and `Write`.
#
# THE MECHANISM, CORRECTED 2026-08-04 against the official documentation, because the
# issue and its spec both stated it wrongly and the wrong version would have justified a
# weaker fix:
#
#   NOT TRUE: "bypassPermissions means deny rules are not consulted." The docs are
#   explicit that deny rules apply in every mode: "These controls apply in every mode,
#   including bypassPermissions: deny rules and explicit ask rules, which apply to every
#   tool" (permission-modes.md).
#
#   NOT TRUE: "a blanket Edit allow defeats an Edit(gates/**) deny." Deny is evaluated
#   first and wins; specificity does not reorder it (permissions.md). In bypassPermissions
#   an allow rule does nothing at all — "Allow rules have no effect in bypassPermissions
#   because everything else is already approved."
#
#   WHAT IS ACTUALLY TRUE, and it is worse. `.claude` is a PROTECTED PATH. Writes to
#   protected paths are prompted in `default` and `acceptEdits`, and ALLOWED in
#   `bypassPermissions` (permission-modes.md, "Protected paths" table). So under
#   bypassPermissions an agent cannot edit a gate file directly — the deny rule holds —
#   but it CAN rewrite `.claude/settings.json` and delete the deny rule, then edit the
#   gate freely. The gates are defeated in two steps rather than one, by an agent that
#   was never prompted about either. That is why the mode has to go, and why replacing it
#   with `acceptEdits` is the fix: acceptEdits restores the prompt on protected-path
#   writes, so the rules that judge the agent stop being agent-editable.
#
# The blanket allows are narrowed as defence in depth, not because they override deny.
# They are stated as such rather than as the decisive mechanism.
#
# NOTE ON SCOPE. Passing this check does NOT mean the gates are enforced in a repo. It
# means nothing is neutralising them. The four deny rules are absent nearly fleet-wide,
# which is deployment drift for T-245's sweep. See the reporting rule below.
#
# WHY A CHECK AND NOT JUST TWELVE EDITS. `settings.local.json` is gitignored and
# user-owned. `merge-settings.py` deliberately does not manage it, so nothing stops it
# drifting straight back — a checkbox in a settings UI is all it takes. Twelve manual
# edits without this check just reset the clock. The check is the deliverable.
#
# WHAT FAILS THE CHECK (exit 1):
#   PERMS     any registered, present repo whose settings.json or settings.local.json sets
#             a bypass mode, or grants a blanket allow on a write-capable tool. The USER
#             scope (`~/.claude/settings.json` and `settings.local.json`) is checked too:
#             permission rules merge across scopes rather than replacing one another, so a
#             single blanket allow there would undo every per-repo fix at once, and a check
#             that read only repos would report a clean fleet while all of it was open.
#   REGISTRY  any entry claiming a tier that means "agent-11 is deployed here" when the
#             repo is present on disk and demonstrably has no agent-11 install. That tier
#             is what T-245's fleet sweep reads to decide scope, so a wrong tier means a
#             wrong sweep — the concrete harm, not a tidiness complaint.
#
# WHAT IS REPORTED BUT DOES NOT FAIL:
#   - A registered path that does not exist. `Shared/` syncs between Jamie's MacBook and
#     Mac mini but `DevProjects/` does not, so a repo cloned on one machine is legitimately
#     absent on the other. Failing on that would make the check machine-dependent, which is
#     worse than useless: it would be red for a reason nobody can fix from here.
#   - The four gate deny rules being ABSENT. They are missing nearly fleet-wide, which is
#     deployment drift for T-245's sweep to fix, not a permissions defect. Making this fail
#     would leave the check permanently red and it would get ignored. `-v` reports it.
#
# WHAT THIS CANNOT DO. It reads settings files; it does not exercise Claude Code's
# permission engine. It proves the two known ways of neutralising the deny rules are
# absent. It cannot prove no third way exists.
#
# Usage:  scripts/validate-fleet-permissions.sh          (silent = compliant)
#         scripts/validate-fleet-permissions.sh -v       (per-repo detail)
#         REGISTRY=/path/to/registry.yaml scripts/validate-fleet-permissions.sh
#
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO" || exit 1

VERBOSE=0
[ "${1:-}" = "-v" ] && VERBOSE=1
REGISTRY="${REGISTRY:-$HOME/Shared/tools/agent-11-fleet/registry.yaml}"

VERBOSE=$VERBOSE REGISTRY="$REGISTRY" python3 - <<'PY'
import json, os, re, sys

VERBOSE = os.environ.get("VERBOSE") == "1"
REGISTRY = os.environ["REGISTRY"]
breaches, notes = [], []

if not os.path.exists(REGISTRY):
    print(f"FLEET: registry not found at {REGISTRY} — the check cannot run", file=sys.stderr)
    sys.exit(1)

# --- parse the registry -----------------------------------------------------
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
    print(f"FLEET: parsed only {len(entries)} entries from {REGISTRY} — the parse "
          "collapsed, so a pass here would be meaningless", file=sys.stderr)
    sys.exit(1)

# Tiers that assert agent-11 is deployed and maintained in that repo. `skip`,
# `different-framework` and `sandbox` make no such claim and are not held to it.
DEPLOYED_TIERS = {"active", "local-only", "dormant"}

# Write-capable tools. Read/Glob/Grep are omitted deliberately: a blanket Read grant
# cannot defeat an Edit() deny rule, and removing it would put a prompt in front of every
# file read, which is exactly the friction that gets a permission model switched off.
WRITE_TOOLS = ("Bash", "Edit", "Write", "MultiEdit", "NotebookEdit")
# Bare name, or a grant whose only argument is a wildcard: Edit(*), Bash(**), Bash(:*).
BLANKET = re.compile(r'^(%s)\s*(\(\s*[:*]?\s*\*{0,2}\s*\))?$' % "|".join(WRITE_TOOLS))
BYPASS = {"bypasspermissions", "bypass"}
GATE_RULES = ["Edit(.quality-gates.json)", "Edit(**/*.quality-gates.json)",
              "Edit(gates/**)", "Edit(.gates/**)"]

checked_repos = checked_files = 0


def scan(label, path, cfg):
    """Flag the two neutralising settings in one parsed settings file."""
    out = []
    perms = cfg.get("permissions") or {}
    # defaultMode is documented nested under permissions and referred to as a top-level
    # key elsewhere in the docs, so both spellings are checked rather than assumed.
    for where, mode in (("permissions.defaultMode", perms.get("defaultMode")),
                        ("defaultMode", cfg.get("defaultMode"))):
        if mode and str(mode).strip().lower() in BYPASS:
            out.append(
                f"PERMS: {label} sets {where}={mode} — writes to protected paths, which "
                f"include .claude/, are allowed without a prompt in this mode. An agent can "
                f"rewrite .claude/settings.json and delete the gate deny rules, then edit "
                f"the gate. (Deny rules themselves still apply in every mode; the defeat is "
                f"two-step, not one.) Use acceptEdits")
    for rule in (perms.get("allow") or []):
        if BLANKET.match(str(rule).strip()):
            out.append(
                f"PERMS: {label} allows {rule!r} with no path restriction — an unrestricted "
                f"grant on a write-capable tool. Deny is evaluated before allow, so this "
                f"does not by itself override a gate deny rule; it is flagged as defence in "
                f"depth and because it grants everything the deny list does not happen to name")
    return out


# USER SCOPE FIRST. Permission rules merge across scopes rather than replacing one
# another, and user settings apply to every repo at once. A blanket allow or a bypass mode
# in ~/.claude/ would silently undo the per-repo fixes everywhere, and checking only
# repos would report a clean fleet while every repo was wide open.
for user_file in ("~/.claude/settings.json", "~/.claude/settings.local.json"):
    uf = os.path.expanduser(user_file)
    if not os.path.exists(uf):
        continue
    checked_files += 1
    try:
        breaches.extend(scan(user_file, uf, json.load(open(uf, encoding="utf-8"))))
    except Exception as ex:
        breaches.append(f"PERMS: {user_file} is not parseable JSON ({ex}) — "
                        "Claude Code cannot apply rules it cannot read")

for e in entries:
    name, tier = e["name"], e.get("tier", "?")
    path = os.path.expanduser(e.get("path", ""))
    if not path or not os.path.isdir(path):
        notes.append(f"absent: {name} ({tier}) — {path or '<no path>'} not on this machine; skipped")
        continue

    checked_repos += 1
    has_a11 = os.path.exists(os.path.join(path, ".claude/agents/coordinator.md"))

    # REGISTRY: a tier that claims deployment, on a repo that plainly has none.
    if tier in DEPLOYED_TIERS and not has_a11:
        breaches.append(
            f"REGISTRY: {name} is tier '{tier}' but has no .claude/agents/coordinator.md — "
            f"agent-11 is not installed there. T-245's sweep reads this tier to decide "
            f"scope, so it would act on a repo that has nothing to update ({path})")

    gate_state = []
    for fn in ("settings.json", "settings.local.json"):
        f = os.path.join(path, ".claude", fn)
        if not os.path.exists(f):
            continue
        checked_files += 1
        try:
            cfg = json.load(open(f, encoding="utf-8"))
        except Exception as ex:
            breaches.append(f"PERMS: {name}/.claude/{fn} is not parseable JSON ({ex}) — "
                            "Claude Code cannot apply rules it cannot read")
            continue

        perms = cfg.get("permissions") or {}
        breaches.extend(scan(f"{name}/.claude/{fn}", f, cfg))

        found = sum(1 for g in GATE_RULES if g in (perms.get("deny") or []))
        if found:
            gate_state.append(f"{fn}:{found}/4")

    if VERBOSE:
        gs = ", ".join(gate_state) if gate_state else "no gate deny rules (T-245 deployment drift)"
        print(f"  {name:<24} tier={tier:<18} agent-11={'yes' if has_a11 else 'NO ':<3} {gs}")

for n in notes:
    if VERBOSE:
        print(f"  {n}")
for b in breaches:
    print(b, file=sys.stderr)

if VERBOSE and not breaches:
    print(f"fleet: {checked_repos} present repos, {checked_files} settings files — "
          f"no bypass mode, no blanket write-tool allow, every deployment tier matches "
          f"the filesystem ({len(notes)} registered path(s) absent on this machine)")

sys.exit(1 if breaches else 0)
PY
