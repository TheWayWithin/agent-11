#!/usr/bin/env bash
#
# validate-destructive-guard.sh — the destructive guard must block what it
# claims to block, and must NOT block ordinary work.
#
# A11-ISS-22. The hook this replaces was a `prompt` type filtered by an `if`
# glob that failed open on multi-line loops, heredocs and redirections, handing
# benign commands to a model that refused them — invisibly, because the refusal
# goes to the agent and not to the operator. The false-negative cases below
# (the "must allow" list) are therefore the more important half of this test:
# they are the exact command shapes that were being silently refused.
#
# Usage:  scripts/validate-destructive-guard.sh
# Exits 0 and silent when every case behaves; 1 with detail otherwise.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

GUARD="library/hooks/destructive-guard.sh"
fail=0

run_guard() {
  python3 -c '
import json,sys
print(json.dumps({"tool_input": {"command": sys.argv[1]}}))
' "$1" | sh "$GUARD" >/dev/null 2>&1
  echo $?
}

must_block() {
  local code; code="$(run_guard "$1")"
  if [ "$code" != "2" ]; then
    printf 'FAIL  should have been BLOCKED (got exit %s): %s\n' "$code" "$1"
    fail=1
  fi
}

must_allow() {
  local code; code="$(run_guard "$1")"
  if [ "$code" != "0" ]; then
    printf 'FAIL  should have been ALLOWED (got exit %s): %s\n' "$code" "$1"
    fail=1
  fi
}

# --- genuinely destructive: must block -------------------------------------
must_block 'rm -rf /some/path'
must_block 'cd /tmp && rm -rf build'
must_block 'git push --force origin main'
must_block 'git push -f origin main'
must_block 'git reset --hard HEAD~3'
must_block 'git clean -fd'
must_block 'git branch -D feature/x'
must_block 'git checkout -- .'
# Multi-line: the shape the old glob filter could not see through.
must_block 'for d in a b c; do
  cd "$d"
  rm -rf node_modules
done'

# --- ordinary work: must allow ---------------------------------------------
# Every one of these was refused in a real session on 2026-08-04.
must_allow 'chmod +x scripts/fleet-versions.py'
must_allow 'npm run build'
must_allow 'git status --short'
must_allow 'rm -f tests/_tmp.spec.ts'
must_allow 'git push origin main'
must_allow 'git push --force-with-lease origin feature'
must_allow 'for p in a b c; do echo "$p $(git -C /repos/$p status --porcelain | wc -l)"; done > /tmp/before.txt'
must_allow 'cat > /tmp/harness.sh <<EOF
echo hello
EOF
bash /tmp/harness.sh'
must_allow 'sed -n "1,20p" install.sh > /tmp/x.txt; wc -l /tmp/x.txt'
must_allow 'python3 -c "import json; print(json.load(open(\".claude/settings.json\")))"'

# --- the guard must fail OPEN on an unreadable payload ---------------------
code="$(printf 'not json at all' | sh "$GUARD" >/dev/null 2>&1; echo $?)"
if [ "$code" != "0" ]; then
  printf 'FAIL  guard must fail open on an unparseable payload (got exit %s)\n' "$code"
  fail=1
fi
code="$(printf '' | sh "$GUARD" >/dev/null 2>&1; echo $?)"
if [ "$code" != "0" ]; then
  printf 'FAIL  guard must fail open on empty stdin (got exit %s)\n' "$code"
  fail=1
fi

exit "$fail"
