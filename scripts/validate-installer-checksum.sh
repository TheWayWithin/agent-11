#!/usr/bin/env bash
#
# validate-installer-checksum.sh — the recorded installer checksum matches the installer.
#
# A11-ISS-20. `secure-install.sh` is the ONLY install command in the README. It downloads
# install.sh and install.sh.sha256 and, on a mismatch, prints "Checksum verification
# FAILED. The installer may have been tampered with." and exits 1.
#
# Between 2026-08-03 and 2026-08-04, three commits edited install.sh and none regenerated
# the checksum. Nothing compared the two, so nothing noticed. For that whole period the
# documented way to install agent-11 refused to run, and accused the project of tampering
# while doing it — the worst possible failure mode, because it reads as compromise rather
# than staleness.
#
# This is the comparison that was missing. Run it before any push that touches install.sh.
#
# WHAT THIS CANNOT DO. It proves the recorded hash matches the file in this working tree.
# It does not authenticate either: anyone who can edit install.sh can regenerate the hash
# next to it. It is a staleness check, not a supply-chain control. The real control is
# that both files are reviewed in the same commit.
#
# Usage:  scripts/validate-installer-checksum.sh        (silent = matching)
#         scripts/validate-installer-checksum.sh -v     (print both hashes)
#
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO/project/deployment/scripts" || exit 1

VERBOSE=0
[ "${1:-}" = "-v" ] && VERBOSE=1

fail=0
breach() { printf '%s\n' "$*" >&2; fail=1; }

[ -f install.sh ]        || breach "CHECKSUM: install.sh is missing"
[ -f install.sh.sha256 ] || breach "CHECKSUM: install.sh.sha256 is missing — secure-install.sh would warn and install unverified"
[ "$fail" -eq 0 ] || exit 1

if command -v shasum >/dev/null 2>&1; then
  actual="$(shasum -a 256 install.sh | cut -d' ' -f1)"
elif command -v sha256sum >/dev/null 2>&1; then
  actual="$(sha256sum install.sh | cut -d' ' -f1)"
else
  breach "CHECKSUM: neither shasum nor sha256sum available — cannot verify"
  exit 1
fi

recorded="$(cut -d' ' -f1 install.sh.sha256)"

# The file secure-install.sh feeds to `shasum -c` must name install.sh, or the -c run
# looks for a file that is not there and the verification silently does nothing useful.
grep -qE '[[:space:]]\*?install\.sh$' install.sh.sha256 \
  || breach "CHECKSUM: install.sh.sha256 does not name 'install.sh' — \`shasum -c\` would not check the installer"

if [ "$actual" != "$recorded" ]; then
  breach "CHECKSUM: install.sh.sha256 is stale. Recorded ${recorded:0:16}…, actual ${actual:0:16}…"
  breach "CHECKSUM: secure-install.sh would exit 1 with a tampering error. Regenerate with:"
  breach "CHECKSUM:   cd project/deployment/scripts && shasum -a 256 install.sh > install.sh.sha256"
fi

if [ "$VERBOSE" -eq 1 ] && [ "$fail" -eq 0 ]; then
  printf 'checksum: install.sh matches install.sh.sha256 (%s…)\n' "${actual:0:16}"
fi
exit "$fail"
