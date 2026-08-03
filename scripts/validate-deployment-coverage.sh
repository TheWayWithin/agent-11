#!/usr/bin/env bash
#
# validate-deployment-coverage.sh — every library mission reaches a deployed project.
#
# A11-ISS-13: install.sh's mission_files list is hand-maintained, so a mission could be
# added to project/missions/ and never deployed. That is exactly what happened to
# connect-mcp.md and operation-recon.md, which sat in the library unshipped. A hand-kept
# list with no check against reality will drift again; this is the check.
#
# Compares install.sh's mission_files array against the actual contents of
# project/missions/ and exits non-zero on any mismatch in either direction:
#   - a mission file that install.sh never copies (the ISS-13 defect)
#   - an entry in install.sh with no corresponding file (a broken install)
#
# It also compares the SECOND hand-kept list, in verify_installation(), which had drifted
# to 14 of 20 so a failed copy of the missing six still reported a clean install.
#
# WHAT THIS CANNOT DO. It compares lists; it does not execute the installer. It proves the
# arrays are right, NOT that the copy happens. A `continue` guard injected into the copy
# loop skips a mission while both arrays stay correct. The structural check at the end
# catches the obvious form of that; nothing short of running install.sh into a scratch
# directory and inspecting the result would catch every form. Stated here rather than left
# for someone to discover, because a check that overstates its own reach is the exact
# defect this sprint was about.
#
# Prints NOTHING and exits 0 when they match exactly.
#
# Usage:  scripts/validate-deployment-coverage.sh          (silent = matched)
#         scripts/validate-deployment-coverage.sh -v       (list what was compared)
#
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO" || exit 1

VERBOSE=0
[ "${1:-}" = "-v" ] && VERBOSE=1

INSTALLER="project/deployment/scripts/install.sh"
MISSION_DIR="project/missions"

fail=0
breach() { printf '%s\n' "$*" >&2; fail=1; }

if [ ! -f "$INSTALLER" ]; then
  breach "COVERAGE: $INSTALLER not found"
  exit 1
fi

# What the installer says it deploys: the quoted project/missions/*.md entries inside the
# mission_files array. Anchored to the array so an unrelated mention elsewhere in the
# script cannot pad the list.
#
# Commented-out entries are DROPPED before counting. Scraping text rather than asking bash
# means `# "project/missions/connect-mcp.md"` reads as present while the mission is in fact
# no longer deployed — the exact ISS-13 regression this check exists to prevent, reachable
# by adding one character. A line whose first non-whitespace character is `#` is not an
# array element, so it is not counted as one.
installer_list="$(
  awk '/mission_files=\(/{f=1; next} f&&/^[[:space:]]*\)/{exit} f{print}' "$INSTALLER" \
    | sed 's/[[:space:]]*#.*$//' \
    | grep -oE '"project/missions/[^"]+\.md"' \
    | tr -d '"' \
    | sed 's|project/missions/||' \
    | sort -u
)"

# What is actually in the library.
library_list="$(ls -1 "$MISSION_DIR"/*.md 2>/dev/null | xargs -n1 basename | sort -u)"

if [ -z "$installer_list" ]; then
  breach "COVERAGE: could not parse a mission_files array out of $INSTALLER — the check is broken, not the list"
  exit 1
fi

while IFS= read -r m; do
  [ -z "$m" ] && continue
  if ! printf '%s\n' "$installer_list" | grep -qxF -- "$m"; then
    breach "COVERAGE: $MISSION_DIR/$m exists in the library but $INSTALLER never deploys it"
  fi
done <<< "$library_list"

while IFS= read -r m; do
  [ -z "$m" ] && continue
  if ! printf '%s\n' "$library_list" | grep -qxF -- "$m"; then
    breach "COVERAGE: $INSTALLER deploys $m but $MISSION_DIR/$m does not exist"
  fi
done <<< "$installer_list"

# There is a SECOND hand-kept mission list, in verify_installation(). It had drifted to
# 14 of 20 entries, so a failed copy of the missing six still reported a clean install:
# a check that lies about success is worse than no check. Both lists are compared.
verify_list="$(
  grep -n 'local mission_files=(' "$INSTALLER" \
    | tail -1 \
    | sed 's/^[0-9]*://' \
    | grep -oE '"[^"]+\.md"' \
    | tr -d '"' \
    | sort -u
)"

if [ -z "$verify_list" ]; then
  breach "COVERAGE: could not parse the verify_installation mission list out of $INSTALLER"
else
  while IFS= read -r m; do
    [ -z "$m" ] && continue
    if ! printf '%s\n' "$verify_list" | grep -qxF -- "$m"; then
      breach "COVERAGE: $INSTALLER installs $m but verify_installation() never checks it landed"
    fi
  done <<< "$library_list"
fi

# The copy loop must not skip anything. This catches the obvious subversion (a guard that
# short-circuits the loop for a named mission) without pretending to prove the loop runs.
loop_body="$(
  awk '/for mission_file in/{f=1} f{print} f&&/^[[:space:]]*done/{exit}' "$INSTALLER"
)"
if [ -z "$loop_body" ]; then
  breach "COVERAGE: could not locate the mission copy loop in $INSTALLER — the check cannot see whether entries are actually copied"
elif printf '%s' "$loop_body" | grep -qE '(^|[[:space:]])(continue|break)([[:space:]]|$|;)'; then
  breach "COVERAGE: the mission copy loop in $INSTALLER contains a continue/break — a mission may be silently skipped while both arrays still look complete"
fi

if [ "$VERBOSE" -eq 1 ]; then
  printf 'coverage: %s missions in %s, %s entries in %s — matched\n' \
    "$(printf '%s\n' "$library_list" | grep -c .)" "$MISSION_DIR" \
    "$(printf '%s\n' "$installer_list" | grep -c .)" "$INSTALLER"
fi

exit "$fail"
