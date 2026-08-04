#!/usr/bin/env bash
#
# validate-installer-backup-path.sh — install.sh never writes its backups into the repo.
#
# T-245. install.sh used to back up into .claude/backups/agent-11/<ts>/, plus
# .claude/CLAUDE.md.backup-<ts> and .claude/settings.json.backup-<ts>. Every install left
# untracked artefacts behind; a 2026-08-04 survey found repos carrying 12-17 of them, and
# in two repos a committed .claude/backups/agent-11/latest is the ONLY thing that makes
# the repo look ineligible for an upgrade. This asserts the fix, because a default that
# silently reverts is worse than one that was never changed.
#
# Fails if: the default backup root is inside the project, or the CLAUDE.md/settings.json
# backups are written under $CLAUDE_DIR, or the resolved path for a real project is not
# outside that project.
#
set -uo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALLER="$REPO/project/deployment/scripts/install.sh"
fail=0
breach() { printf '%s\n' "$*" >&2; fail=1; }

[ -f "$INSTALLER" ] || { breach "BACKUPPATH: install.sh not found"; exit 1; }

# The default root must not be expressed in terms of the project directory.
root_line="$(grep -E '^AGENT11_BACKUP_ROOT=' "$INSTALLER" || true)"
[ -n "$root_line" ] || breach "BACKUPPATH: no AGENT11_BACKUP_ROOT default found"
case "$root_line" in
  *'$CLAUDE_DIR'*|*'$(pwd)'*|*'$PWD'*)
    breach "BACKUPPATH: the default backup root is inside the project: $root_line" ;;
esac

# The two single-file backups must live under BACKUP_PATH, not in the repo.
grep -qE 'backup_file="\$CLAUDE_DIR/(CLAUDE\.md|settings\.json)\.backup' "$INSTALLER" \
  && breach "BACKUPPATH: a CLAUDE.md/settings.json backup is still written under \$CLAUDE_DIR"

# End to end: resolve the path a real project would get and assert it is outside it.
# Probed under $HOME, not mktemp's /var/folders: install.sh has a security guard that
# refuses to operate on system directories, so a /var probe fails for a reason that has
# nothing to do with what is being tested here.
probe="$HOME/.agent-11-backup-path-selftest.$$"
rm -rf "$probe"
mkdir -p "$probe/proj" && (cd "$probe/proj" && git init -q . && touch README.md)
resolved="$(cd "$probe/proj" && AGENT11_INSTALL_BACKUPS="$probe/backups" \
  bash "$INSTALLER" --dry-run 2>/dev/null | grep -oE 'Backups would go to: [^ ]+' | awk '{print $NF}')"
if [ -z "$resolved" ]; then
  breach "BACKUPPATH: the dry run did not report a backup destination"
elif case "$resolved" in "$probe/proj"/*) true ;; *) false ;; esac; then
  breach "BACKUPPATH: resolved backup path is INSIDE the project: $resolved"
fi
# A dry run must not create it either.
[ -e "$probe/backups" ] && breach "BACKUPPATH: a --dry-run created the backup root at $probe/backups"
rm -rf "$probe"
exit "$fail"
