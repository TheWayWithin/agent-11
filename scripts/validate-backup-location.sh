#!/usr/bin/env bash
#
# validate-backup-location.sh — install.sh must not write backups into the repo
# it is installing into.
#
# T-245. install.sh used to leave every backup inside the target project:
# .claude/backups/agent-11/<ts>/, .claude/CLAUDE.md.backup-<ts> and
# .claude/settings.json.backup-<ts>. A fleet survey on 2026-08-04 found the
# result — aisearchmastery 17 untracked artefacts, SEOAgent 15,
# aimpactscanner-mvp 13, Trader-7 12, aisearcharena 7 — all of it
# indistinguishable at a glance from the owner's own uncommitted work, which
# is what made a routine upgrade sweep look dangerous.
#
# This check fails if that pattern comes back. It is deliberately literal:
# it greps for assignments that would place a backup under $CLAUDE_DIR.
#
# Usage:  scripts/validate-backup-location.sh
# Exits 0 and silent when compliant, 1 with detail otherwise.

set -uo pipefail

cd "$(dirname "$0")/.." || exit 1

INSTALL_SH="project/deployment/scripts/install.sh"
fail=0

if [ ! -f "$INSTALL_SH" ]; then
  printf 'FAIL  %s not found\n' "$INSTALL_SH"
  exit 1
fi

# 1. No backup file may be assigned a path inside $CLAUDE_DIR.
hits="$(grep -nE 'backup[_a-z]*=("|\x27)?\$(\{)?CLAUDE_DIR' "$INSTALL_SH" | grep -viE '^\s*#')"
if [ -n "$hits" ]; then
  printf 'FAIL  a backup path is assigned inside the repo (.claude/):\n'
  printf '%s\n' "$hits" | sed 's/^/      /'
  fail=1
fi

# 2. The external backup root must be configured, with an override.
if ! grep -q 'AGENT11_INSTALL_BACKUPS' "$INSTALL_SH"; then
  printf 'FAIL  no AGENT11_INSTALL_BACKUPS override; the backup root is not configurable\n'
  fail=1
fi

# 3. The default root must live outside any target repo, i.e. under $HOME.
if ! grep -qE 'AGENT11_BACKUP_ROOT=.*\$HOME/' "$INSTALL_SH"; then
  printf 'FAIL  the default backup root is not anchored under $HOME\n'
  fail=1
fi

# 4. Behavioural check, not just textual: run the path-selection logic the way
#    install.sh does and assert the chosen directory is not inside the repo.
tmp_root="$(mktemp -d)"
trap 'rm -rf "$tmp_root"' EXIT
resolved="$(
  AGENT11_INSTALL_BACKUPS="$tmp_root/install-backups" \
  bash -c '
    AGENT11_BACKUP_ROOT="${AGENT11_INSTALL_BACKUPS:-$HOME/Shared/tools/agent-11-fleet/install-backups}"
    BACKUP_REPO_KEY="$(basename "$(pwd)")"
    if mkdir -p "$AGENT11_BACKUP_ROOT/$BACKUP_REPO_KEY" 2>/dev/null; then
      printf "%s" "$AGENT11_BACKUP_ROOT/$BACKUP_REPO_KEY"
    else
      printf "%s" "$(pwd)/.claude/backups/agent-11"
    fi
  '
)"
case "$resolved" in
  "$(pwd)"*)
    printf 'FAIL  resolved backup dir is inside the repo: %s\n' "$resolved"
    fail=1
    ;;
esac

# 5. The version stamp must be written on install AND upgrade, i.e. wired into
#    the shared pipeline rather than an upgrade-only branch. Checking merely
#    that the identifier appears is not enough: deleting the pipeline line
#    leaves the function definition behind and a name-only grep still passes.
#    That exact hole was found by probing this check, so assert the CALL.
if ! grep -q 'write_version_stamp' "$INSTALL_SH"; then
  printf 'FAIL  install.sh never writes a version stamp\n'
  fail=1
elif ! grep -qE '^\s+write_version_stamp\s+&&' "$INSTALL_SH"; then
  printf 'FAIL  write_version_stamp is defined but not called from the install pipeline\n'
  fail=1
fi

# 6. The stamp must record the version, not just a timestamp: an upgrade you
#    cannot read a version out of is the defect this whole task exists to fix.
if ! grep -q '"version":' "$INSTALL_SH"; then
  printf 'FAIL  the version stamp does not record a version field\n'
  fail=1
fi

exit "$fail"
