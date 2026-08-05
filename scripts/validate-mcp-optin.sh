#!/usr/bin/env bash
#
# validate-mcp-optin.sh — installing never reaches outside the project on its own.
#
# A11-ISS-23. install.sh used to execute mcp-setup.sh automatically whenever .env.mcp
# existed. That script runs `npm install -g` for up to seven packages — writing outside
# the project entirely, into the global npm prefix — and `claude mcp remove -s project`
# for ten servers before re-adding whichever it has credentials for. An install command
# should not do either because a file happened to be present.
#
# It found its way into T-245's plan for Trader-7, which runs live on Railway and is the
# only in-scope repo with .env.mcp. The dry run could not show it: the plan short-circuits
# long before that code runs, so the most invasive step in the installer was the one step
# nobody could preview.
#
# Asserts: the execution is guarded by $WITH_MCP, the flag exists and defaults to false,
# and .mcp.json is not written over an existing file.
#
set -uo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
I="$REPO/project/deployment/scripts/install.sh"
fail=0
breach(){ printf '%s\n' "$*" >&2; fail=1; }
[ -f "$I" ] || { breach "MCPOPTIN: install.sh not found"; exit 1; }

grep -qE '^\s*WITH_MCP=false' "$I" || breach "MCPOPTIN: WITH_MCP does not default to false"
grep -qE '^\s*--with-mcp\)' "$I"  || breach "MCPOPTIN: no --with-mcp flag is parsed"

# The invocation must sit inside an `if $WITH_MCP` block. Checked structurally: find the
# line that executes mcp-setup.sh and walk back for the guard, rather than trusting that
# the words appear somewhere in the same file.
line="$(grep -nE '^\s*if\s+"\$TARGET_DIR/mcp-setup\.sh"' "$I" | head -1 | cut -d: -f1)"
if [ -z "$line" ]; then
  grep -qE '"\$TARGET_DIR/mcp-setup\.sh"' "$I" \
    && breach "MCPOPTIN: mcp-setup.sh is referenced but the execution site could not be located — check by hand" \
    || true
else
  guarded=0
  start=$(( line > 20 ? line - 20 : 1 ))
  sed -n "${start},${line}p" "$I" | grep -qE 'if\s+\$WITH_MCP' && guarded=1
  [ "$guarded" = 1 ] || breach "MCPOPTIN: mcp-setup.sh is executed at line $line without an 'if \$WITH_MCP' guard above it"
fi

# An existing .mcp.json is the user's server registry and must never be overwritten.
grep -qE 'if \[\[ -f "\$TARGET_DIR/\.mcp\.json" \]\]' "$I" \
  || breach "MCPOPTIN: .mcp.json is written without checking whether one already exists"

exit "$fail"
