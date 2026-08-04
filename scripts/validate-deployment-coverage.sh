#!/usr/bin/env bash
#
# validate-deployment-coverage.sh — every library mission reaches a deployed project,
# and every deployed mission can actually be invoked.
#
# Two defects of the same shape, six weeks apart, both caused by a hand-kept list that
# nothing compared against reality:
#   A11-ISS-13  install.sh's mission_files array had drifted from project/missions/, so
#               connect-mcp.md and operation-recon.md sat in the library and shipped to
#               nobody.
#   A11-ISS-17  /coord's routing table covered 13 of 18 missions, so connect-mcp,
#               architecture, product-description, operation-genesis and operation-recon
#               installed correctly and then hard-errored the moment anyone ran them.
#
# A mission is only real if it survives the whole chain: it exists in project/missions/,
# install.sh copies it, verify_installation() checks it landed, and project/commands/coord.md
# routes it. This script compares all four lists against each other and fails on any
# mismatch in any direction. One script rather than two, deliberately: two scripts parsing
# the same mission set is a fifth list to drift.
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

# ---------------------------------------------------------------------------
# ROUTING (A11-ISS-17). A mission that installs but cannot be invoked is not shipped,
# it is stranded. /coord's routing table is the fourth hand-kept list; this compares it
# to the library the same way the installer arrays are compared.
#
# The table carries an explicit File column precisely so this check can be mechanical.
# Before A11-ISS-17 the command derived the filename from the mission name, which is
# unguessable: `build` -> mission-build.md but `dev-setup` -> dev-setup.md and
# `operation-recon` -> operation-recon.md.
# ---------------------------------------------------------------------------
ROUTER="project/commands/coord.md"
CATALOGUE_FILES="README.md library.md"

if [ ! -f "$ROUTER" ]; then
  breach "ROUTING: $ROUTER not found — cannot prove any mission is invocable"
else
  # Rows of the Routing Table section only, up to the **Modes** line that ends it, so a
  # markdown table elsewhere in the file cannot pad the list. Header and separator rows
  # carry no backticked mission name and drop out.
  routing_rows="$(
    awk '/^## Routing Table/{f=1; next} f&&/^\*\*Modes\*\*/{exit} f&&/^\|/{print}' "$ROUTER"
  )"

  routed_names="$(printf '%s\n' "$routing_rows" \
    | awk -F'|' 'NF>4 {gsub(/[` ]/, "", $2); if ($2 != "" && $2 !~ /^Mission$/ && $2 !~ /^-+$/) print $2}' \
    | sort)"
  routed_files="$(printf '%s\n' "$routing_rows" \
    | awk -F'|' 'NF>4 {gsub(/[` ]/, "", $4); if ($4 ~ /\.md$/) print $4}' \
    | sort)"

  if [ -z "$routed_files" ]; then
    breach "ROUTING: could not parse a routing table out of $ROUTER — the check is broken, not the table"
  else
    # Executable missions = the library minus the catalogue files, which are lists of
    # missions rather than missions. /coord library is correctly an error.
    executable_list="$library_list"
    for c in $CATALOGUE_FILES; do
      executable_list="$(printf '%s\n' "$executable_list" | grep -vxF -- "$c")"
    done
    executable_count="$(printf '%s\n' "$executable_list" | grep -c .)"

    while IFS= read -r m; do
      [ -z "$m" ] && continue
      if ! printf '%s\n' "$routed_files" | grep -qxF -- "$m"; then
        breach "ROUTING: $MISSION_DIR/$m installs but $ROUTER has no routing row for it — /coord would hard-error on it (A11-ISS-17)"
      fi
    done <<< "$executable_list"

    while IFS= read -r m; do
      [ -z "$m" ] && continue
      if ! printf '%s\n' "$library_list" | grep -qxF -- "$m"; then
        breach "ROUTING: $ROUTER routes to $m but $MISSION_DIR/$m does not exist — /coord would fail to load it"
      fi
      for c in $CATALOGUE_FILES; do
        if [ "$m" = "$c" ]; then
          breach "ROUTING: $ROUTER routes to $c, which is the mission catalogue and not a runnable mission"
        fi
      done
    done <<< "$routed_files"

    # One row per mission. A duplicate name is an ambiguous route, and a duplicate file
    # lets one mission occupy two rows while another has none and the counts still match.
    for dup in $(printf '%s\n' "$routed_names" | uniq -d); do
      breach "ROUTING: $ROUTER has more than one row for mission '$dup' — the route is ambiguous"
    done
    for dup in $(printf '%s\n' "$routed_files" | uniq -d); do
      breach "ROUTING: $ROUTER routes two different mission names to $dup"
    done

    # The unknown-mission help text is a FIFTH copy of the list, printed to the user at
    # the exact moment they got a name wrong. If it drifts it teaches the wrong names,
    # so it is compared to the table rather than trusted.
    help_block="$(awk '/^Unknown mission: <name>/{f=1} f{print} f&&/^Standalone \(not \/coord\)/{exit}' "$ROUTER")"
    if [ -z "$help_block" ]; then
      breach "ROUTING: could not find the unknown-mission help block in $ROUTER"
    else
      while IFS= read -r n; do
        [ -z "$n" ] && continue
        if ! printf '%s' "$help_block" | grep -qE "(^|[[:space:],])${n}(,|$|[[:space:]])"; then
          breach "ROUTING: mission '$n' is routable but the unknown-mission help in $ROUTER never lists it"
        fi
      done <<< "$routed_names"
    fi
  fi
fi

if [ "$VERBOSE" -eq 1 ]; then
  printf 'coverage: %s missions in %s, %s entries in %s — matched\n' \
    "$(printf '%s\n' "$library_list" | grep -c .)" "$MISSION_DIR" \
    "$(printf '%s\n' "$installer_list" | grep -c .)" "$INSTALLER"
  printf 'routing:  %s executable missions (%s catalogue files excluded), %s routing rows in %s — matched\n' \
    "${executable_count:-0}" "$(printf '%s' "$CATALOGUE_FILES" | wc -w | tr -d ' ')" \
    "$(printf '%s\n' "${routed_files:-}" | grep -c .)" "$ROUTER"
fi

exit "$fail"
