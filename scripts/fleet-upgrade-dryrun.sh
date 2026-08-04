#!/usr/bin/env bash
#
# fleet-upgrade-dryrun.sh — what would `install.sh --upgrade` do to each in-scope repo?
#
# T-245 deliverable 2. Changes NOTHING, anywhere. It runs the real installer's own
# `--upgrade --dry-run` inside each target repo and prints what that installer says it
# would do, alongside the git facts that decide whether the repo is eligible at all.
#
# WHY THE REAL INSTALLER RATHER THAN A SUMMARY. A hand-written "what an upgrade would
# change" is a claim about a script rather than a reading of it, and it goes stale the
# first time install.sh changes. Invoking the installer's own dry run means the report
# cannot drift from the thing it describes.
#
# THE ELIGIBILITY RULE, precisely. A repo is blocked only by a TRACKED-and-modified file
# under `.claude/`, because that is a local customisation the upgrade would overwrite.
# Untracked files there are backup litter from earlier installs — several repos carry a
# dozen or more — and they block nothing. The first draft of the spec said "skip any repo
# whose tree is not clean", which would have skipped six of seven for litter this project
# created itself.
#
# WHAT THIS RUN DOES NOT DO. It does not upgrade anything, and it must not: the report is
# the deliverable, and a human approves it before any repo changes. It executes the
# installer only in `--dry-run` mode, which short-circuits before any work.
#
# Usage:
#   scripts/fleet-upgrade-dryrun.sh              all seven in-scope repos
#   scripts/fleet-upgrade-dryrun.sh SEOAgent     just one
#   scripts/fleet-upgrade-dryrun.sh --full       include each installer plan verbatim
#
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALLER="$REPO/project/deployment/scripts/install.sh"
REGISTRY="${REGISTRY:-$HOME/Shared/tools/agent-11-fleet/registry.yaml}"

# Settled in the spec's second pass, 2026-08-04.
IN_SCOPE=(Trader-7 aisearcharena JamieWatters SEOAgent aimpactscanner-mvp
          llm-txt-mastery aisearchmastery)

FULL=0
TARGETS=()
for a in "$@"; do
  case "$a" in
    --full) FULL=1 ;;
    -h|--help) sed -n '2,28p' "$0"; exit 0 ;;
    *) TARGETS+=("$a") ;;
  esac
done
[ ${#TARGETS[@]} -eq 0 ] && TARGETS=("${IN_SCOPE[@]}")

[ -f "$INSTALLER" ] || { echo "installer not found: $INSTALLER" >&2; exit 1; }
[ -f "$REGISTRY" ]  || { echo "registry not found: $REGISTRY" >&2; exit 1; }

path_for() {
  python3 - "$REGISTRY" "$1" <<'PY'
import re, sys
reg, want = sys.argv[1], sys.argv[2]
cur = None
for line in open(reg, encoding="utf-8"):
    m = re.match(r'^\s*-\s+name:\s*(.+?)\s*$', line)
    if m:
        cur = m.group(1).strip().strip('"')
        continue
    m2 = re.match(r'^\s+path:\s*(.+?)\s*$', line)
    if m2 and cur == want:
        print(m2.group(1).strip().strip('"'))
        break
PY
}

# The agent-11 tree is the SOURCE of this sweep: install.sh resolves PROJECT_ROOT from its
# own location, so execution mode is "local" and it copies from this working tree, not from
# GitHub. An uncommitted or unpushed library is therefore a real hazard — the fleet would
# receive files nobody can review from the remote. Stated up front, before any repo.
echo "============================================================"
echo " AGENT-11 FLEET UPGRADE — DRY RUN. Nothing is changed."
echo "============================================================"
echo " Source library : $REPO"
echo " Source branch  : $(git -C "$REPO" rev-parse --abbrev-ref HEAD 2>/dev/null)"
echo " Source commit  : $(git -C "$REPO" rev-parse --short HEAD 2>/dev/null)"
lib_dirty="$(git -C "$REPO" status --porcelain 2>/dev/null | grep -vE '^\?\?' | wc -l | tr -d ' ')"
lib_unpushed="$(git -C "$REPO" log --oneline @{u}..HEAD 2>/dev/null | wc -l | tr -d ' ')"
echo " Source state   : $lib_dirty tracked-modified file(s), $lib_unpushed unpushed commit(s)"
[ "$lib_dirty" != "0" ] && echo "   WARNING: the library has uncommitted changes; the sweep would deploy them."
[ "$lib_unpushed" != "0" ] && echo "   WARNING: the library has unpushed commits; the fleet would get code not on the remote."
echo " Would write    : version $(grep -oE '^#{1,3} *\[[0-9]+\.[0-9]+\.[0-9]+\]' "$REPO/CHANGELOG.md" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
echo

eligible=(); blocked=(); notes=()

for name in "${TARGETS[@]}"; do
  p="$(path_for "$name")"
  p="${p/#\~/$HOME}"
  echo "------------------------------------------------------------"
  echo "  $name"
  echo "------------------------------------------------------------"
  if [ -z "$p" ] || [ ! -d "$p" ]; then
    echo "  NOT PRESENT on this machine — skipped"; echo
    notes+=("$name: not present")
    continue
  fi

  branch="$(git -C "$p" rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)"
  stamp="$p/.claude/agent-11-version"
  version="none (pre-stamp install)"
  [ -f "$stamp" ] && version="$(grep -oE '"version"[^,]*' "$stamp" | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+|unknown' || echo unparseable)"

  # Tracked-and-modified under .claude/ — the only thing that blocks. Bare paths, no
  # porcelain parsing.
  tracked_mod="$( { git -C "$p" diff --name-only -- .claude 2>/dev/null;
                    git -C "$p" diff --cached --name-only -- .claude 2>/dev/null; } | sort -u | sed '/^$/d')"
  untracked_n="$(git -C "$p" status --porcelain -- .claude 2>/dev/null | grep -c '^??' || true)"
  repo_dirty="$(git -C "$p" status --porcelain 2>/dev/null | grep -vcE '^\?\?' || true)"

  echo "  Branch                 : $branch"
  echo "  Installed version      : $version"
  echo "  Gate deny rules present: $(python3 - "$p" <<'PY'
import json, os, sys
GATES = ["Edit(.quality-gates.json)", "Edit(**/*.quality-gates.json)",
         "Edit(gates/**)", "Edit(.gates/**)"]
best = 0
for fn in ("settings.json", "settings.local.json"):
    f = os.path.join(sys.argv[1], ".claude", fn)
    if os.path.exists(f):
        try:
            deny = (json.load(open(f)).get("permissions") or {}).get("deny") or []
            best = max(best, sum(1 for g in GATES if g in deny))
        except Exception:
            pass
print(f"{best}/4")
PY
)"
  echo "  .claude untracked      : $untracked_n (install litter — does not block)"
  echo "  Repo tracked-modified  : $repo_dirty file(s) outside .claude/ (does not block)"
  if [ -n "$tracked_mod" ]; then
    echo "  BLOCKED — tracked-and-modified under .claude/:"
    printf '%s\n' "$tracked_mod" | sed 's/^/      /'
    blocked+=("$name")
  else
    echo "  Eligible               : yes"
    eligible+=("$name")
  fi

  plan="$(cd "$p" && bash "$INSTALLER" --upgrade --dry-run 2>&1 || true)"
  if [ "$FULL" -eq 1 ]; then
    echo "  --- installer plan ---"
    printf '%s\n' "$plan" | sed 's/^/    /'
  else
    echo "  Installer says:"
    printf '%s\n' "$plan" | grep -E 'settings.json:|v5\.x markers|Backups would go to|Would write version' | sed 's/^ */      /'
  fi
  echo
done

echo "============================================================"
echo " SUMMARY — nothing was changed by this run"
echo "============================================================"
printf ' Eligible now (%s): %s\n' "${#eligible[@]}" "${eligible[*]:-none}"
printf ' Blocked (%s)     : %s\n' "${#blocked[@]}" "${blocked[*]:-none}"
for n in ${notes[@]+"${notes[@]}"}; do echo " Note: $n"; done
echo
echo " A blocked repo needs its own .claude/ change committed or discarded by a human."
echo " Nothing here should be upgraded until that report has been read and approved."
