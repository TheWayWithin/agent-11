#!/usr/bin/env bash
#
# test-installer-downloads.sh — release guard for A11-ISS-31
#
# Why this exists: install.sh used to fetch .mcp.json from a URL that has never
# existed and write the server's 14-byte "404: Not Found" body straight into the
# user's project. Twenty repos ended up with a junk .mcp.json and no MCP setup,
# and nothing failed, warned, or logged. The breakage was invisible until
# somebody opened the file.
#
# Two suites, both cheap enough to run before every release:
#
#   GUARD   (offline) — extracts the download guard out of install.sh and proves
#                       a 404 body, an HTML error page, an empty response and a
#                       malformed JSON payload can none of them reach a
#                       destination file, and that an existing file survives.
#   MANIFEST (live)   — asks install.sh for every path it can download
#                       (--print-manifest), checks each URL returns HTTP 200 on
#                       the configured branch, and parses what comes back
#                       (JSON for .json, bash -n for .sh, python for .py).
#                       Also checks every literal download call site in
#                       install.sh appears in the manifest, so a new fetch
#                       cannot be added without becoming testable.
#
# Usage:
#   bash project/deployment/tests/test-installer-downloads.sh            # both
#   bash project/deployment/tests/test-installer-downloads.sh --offline  # guard only
#
# Exit 0 = safe to release. Any other exit = do not ship install.sh.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
INSTALLER="$REPO_ROOT/project/deployment/scripts/install.sh"

OFFLINE=false
[[ "${1:-}" == "--offline" ]] && OFFLINE=true

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
[[ -t 1 ]] || { RED=''; GREEN=''; YELLOW=''; NC=''; }

PASS=0; FAIL=0
pass() { PASS=$((PASS + 1)); echo -e "${GREEN}  PASS${NC} $1"; }
fail() { FAIL=$((FAIL + 1)); echo -e "${RED}  FAIL${NC} $1"; }
info() { echo -e "${YELLOW}  ....${NC} $1"; }

[[ -f "$INSTALLER" ]] || { echo "install.sh not found at $INSTALLER"; exit 2; }

WORK="$(mktemp -d "${TMPDIR:-/tmp}/a11-dl-test.XXXXXX")"

echo "AGENT-11 installer download tests (A11-ISS-31)"
echo "installer: $INSTALLER"
echo

# ---------------------------------------------------------------------------
# Suite 1: the download guard, offline
# ---------------------------------------------------------------------------
echo "== GUARD (offline) =="

# install.sh brackets its download machinery with these markers so a test can
# load the real functions without running the installer.
GUARD="$WORK/guard.sh"
awk '/^# --- A11-ISS-31 DOWNLOAD GUARD BEGIN/{f=1} f{print} /^# --- A11-ISS-31 DOWNLOAD GUARD END/{f=0}' \
    "$INSTALLER" > "$GUARD"

if [[ ! -s "$GUARD" ]]; then
    fail "could not extract the download guard block from install.sh (markers missing?)"
    echo; echo "$PASS passed, $((FAIL + 1)) failed"; exit 1
fi
pass "download guard block extracted from install.sh ($(wc -l < "$GUARD" | tr -d ' ') lines)"

# Minimal stubs for the logging the guard calls, then load it.
cat > "$WORK/harness.sh" <<'HARNESS'
set -uo pipefail
log()     { :; }
success() { :; }
warn()    { :; }
error()   { echo "[ERROR] $1" >> "$GUARD_ERR_LOG"; }
HARNESS
export GUARD_ERR_LOG="$WORK/errors.log"
: > "$GUARD_ERR_LOG"

# shellcheck disable=SC1090
source "$WORK/harness.sh"
# shellcheck disable=SC1090
source "$GUARD"

if ! declare -f fetch_url_to_file >/dev/null; then
    fail "fetch_url_to_file not defined after sourcing the guard"
    echo; echo "$PASS passed, $((FAIL + 1)) failed"; exit 1
fi
pass "fetch_url_to_file loaded"

SENTINEL='ORIGINAL CONTENT MUST SURVIVE'

# A PATH with the shell utilities but deliberately no python3 and no jq, used to
# prove the JSON fallback still catches truncation on a minimal container.
mkdir -p "$WORK/nobin"
for _b in awk sed tr cut head wc cat mktemp mv rm chmod stat dirname basename bash printf; do
    _src="$(command -v "$_b" 2>/dev/null || true)"
    [[ -n "$_src" ]] && ln -sf "$_src" "$WORK/nobin/$_b"
done
printf '%s' '{"mcpServers":{}}' > "$WORK/good.json"

# 1a. A real 404 from raw.githubusercontent.com must not touch the destination.
if $OFFLINE; then
    info "skipping live 404 check (--offline)"
else
    dest="$WORK/live404.json"
    echo "$SENTINEL" > "$dest"
    if fetch_url_to_file \
        "https://raw.githubusercontent.com/TheWayWithin/agent-11/main/.mcp.json" \
        "$dest" "live-404" >/dev/null 2>&1; then
        fail "a genuine 404 was reported as a successful download"
    else
        if [[ "$(cat "$dest")" == "$SENTINEL" ]]; then
            pass "genuine 404 rejected, destination untouched"
        else
            fail "genuine 404 rejected but destination was modified: $(head -c 40 "$dest")"
        fi
    fi
fi

# 1b..1e. Payload validation, exercised directly - no network needed.
check_payload_rejected() {
    local name="$1" destname="$2" body="$3"
    local tmp="$WORK/payload.$$"
    printf '%s' "$body" > "$tmp"
    if validate_downloaded_payload "$tmp" "$WORK/$destname" "$name" >/dev/null 2>&1; then
        fail "$name was accepted (it must be rejected)"
    else
        pass "$name rejected"
    fi
    rm -f "$tmp"
}

check_payload_accepted() {
    local name="$1" destname="$2" body="$3"
    local tmp="$WORK/payload.$$"
    printf '%s' "$body" > "$tmp"
    if validate_downloaded_payload "$tmp" "$WORK/$destname" "$name" >/dev/null 2>&1; then
        pass "$name accepted"
    else
        fail "$name was rejected (it must be accepted)"
    fi
    rm -f "$tmp"
}

check_payload_rejected "GitHub 404 body"        ".mcp.json"    '404: Not Found'
check_payload_rejected "GitHub 404 body (.md)"  "mission.md"   '404: Not Found'
check_payload_rejected "HTML error page"        ".mcp.json"    '<!DOCTYPE html><html><body>Not found</body></html>'
check_payload_rejected "empty response"         ".mcp.json"    ''
check_payload_rejected "malformed JSON"         ".mcp.json"    '{ "mcpServers": '
check_payload_rejected "broken bash"            "mcp-setup.sh" 'if [ 1 -eq 1 ]; then echo hi'
check_payload_rejected "broken python"          "run-gates.py" 'def broken(:'
check_payload_accepted "valid JSON"             ".mcp.json"    '{"mcpServers":{}}'
check_payload_accepted "valid JSON template"    ".mcp.json.template" '{"mcpServers":{}}'
check_payload_accepted "valid bash"             "mcp-setup.sh" 'set -e
echo hello'
check_payload_accepted "valid python"           "run-gates.py" 'import sys
print(sys.argv)'
check_payload_accepted "plain markdown"         "mission.md"   '# Mission

Do the thing.'

# Downloads that land in an extensionless mktemp file (the settings.json merge
# path, the migration scripts) must still be typed from their source path.
check_payload_typed_by_label() {
    local name="$1" label="$2" body="$3" expect="$4"
    local tmp="$WORK/payload.$$"
    printf '%s' "$body" > "$tmp"
    if validate_downloaded_payload "$tmp" "$WORK/agent11-tmp.ABC123" "$label" >/dev/null 2>&1; then
        [[ "$expect" == "accept" ]] && pass "$name accepted" || fail "$name was accepted (must be rejected)"
    else
        [[ "$expect" == "reject" ]] && pass "$name rejected" || fail "$name was rejected (must be accepted)"
    fi
    rm -f "$tmp"
}

check_payload_typed_by_label "temp-dest broken JSON (settings.json.template)" \
    "library/settings.json.template" '{ "hooks": ' reject
check_payload_typed_by_label "temp-dest valid JSON (settings.json.template)" \
    "library/settings.json.template" '{"hooks":{}}' accept
check_payload_typed_by_label "temp-dest broken bash (migrate script)" \
    "project/deployment/scripts/migrate-v5-to-v6.sh" 'while true; do echo' reject
check_payload_typed_by_label "temp-dest broken python (merge-settings)" \
    "project/deployment/scripts/merge-settings.py" 'def x(:' reject

# Error pages a first-line literal match walks straight past. These reach .md
# and .yaml destinations, which get no type parse at all, so the error-body
# screen is the only thing standing between them and the user's project.
check_payload_rejected "HTML 2.0 doctype (Apache stock page)" "guide.md" \
    '<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head><title>404 Not Found</title></head></html>'
check_payload_rejected "HTML after a blank line" "guide.md" '
<!DOCTYPE html>
<html><body>nope</body></html>'
check_payload_rejected "HTML after a leading space" "guide.md" ' <!DOCTYPE html>
<html></html>'
check_payload_rejected "XML prolog error doc" "profile.yaml" '<?xml version="1.0"?>
<Error><Code>NoSuchKey</Code></Error>'
check_payload_rejected "captive-portal meta refresh" "guide.md" \
    '<meta http-equiv="refresh" content="0; url=https://portal.example/login">'
check_payload_rejected "proxy text error" "guide.md" 'Error 403: forbidden by policy'
check_payload_rejected "404 body with a leading space" "guide.md" ' 404: Not Found'
check_payload_rejected "404 body after a tab" "guide.md" '	404: Not Found'
check_payload_rejected "UTF-8 BOM then a doctype" "guide.md" \
    "$(printf '\xef\xbb\xbf<!DOCTYPE html><html>404</html>')"
check_payload_rejected "S3-style XML error" "profile.yaml" \
    '<Error><Code>NoSuchKey</Code></Error>'
check_payload_rejected "nginx 502 in caps" "guide.md" \
    '<HTML><HEAD><TITLE>502 Bad Gateway</TITLE></HEAD></HTML>'
check_payload_rejected "whitespace-only body" "guide.md" '   
  '

# A document that merely talks about error codes must still install.
check_payload_accepted "prose mentioning an error code" "guide.md" \
    '# Troubleshooting

Error 403: forbidden usually means your token lacks the scope. Read on for the
full list of causes, the checks to run, and what to change in .env.mcp before
you retry the install. This file is deliberately longer than the 1024-byte
threshold the error-body screen uses, so that a genuine document discussing
HTTP failures is never mistaken for one. Padding follows to clear that bar.
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor
incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis
nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu
fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in
culpa qui officia deserunt mollit anim id est laborum. Sed ut perspiciatis unde
omnis iste natus error sit voluptatem accusantium doloremque laudantium.'

# The destination must never be a directory: `mv file dir/` succeeds by moving
# INTO it, and the chmod that follows would strip its x bit.
dir_dest="$WORK/dest-as-dir"
mkdir -p "$dir_dest"
if fetch_url_to_file "https://raw.githubusercontent.com/TheWayWithin/agent-11/main/CHANGELOG.md" \
     "$dir_dest" "dir-dest" >/dev/null 2>&1; then
    fail "a directory destination was accepted"
else
    if [[ -d "$dir_dest" && -x "$dir_dest" ]]; then
        pass "directory destination rejected, directory left traversable"
    else
        fail "directory destination rejected but the directory was damaged"
    fi
fi

# Nothing the installer ships starts with an angle bracket, and the guard relies
# on that to reject the whole HTML/XML error family. If a shipped file ever
# does start with one, this check fails before the guard silently drops it.
angle=0
while IFS= read -r mpath; do
    [[ -f "$REPO_ROOT/$mpath" ]] || continue
    firstch="$(sed -e 's/^[[:space:]]*//' "$REPO_ROOT/$mpath" | grep -m1 . | cut -c1)"
    if [[ "$firstch" == "<" ]]; then
        fail "shipped file starts with '<' and would be rejected as an error page: $mpath"
        angle=$((angle + 1))
    fi
done < <( (cd "$REPO_ROOT" && bash "$INSTALLER" --print-manifest) 2>/dev/null )
if [[ $angle -eq 0 ]]; then
    pass "no shipped file starts with an angle bracket"
fi

# The no-parser fallback must still catch truncation. This is the original bug
# on a box with neither python3 nor jq, so it is tested with both hidden.
truncated="$WORK/truncated.json"
printf '%s' '{ "mcpServers": ' > "$truncated"
if PATH="$WORK/nobin" bash -c '
      set -uo pipefail
      export GUARD_ERR_LOG="$1"
      error() { :; }; log() { :; }; success() { :; }; warn() { :; }
      . "$2"
      payload_is_valid_json "$3"
   ' _ "$GUARD_ERR_LOG" "$GUARD" "$truncated" 2>/dev/null; then
    fail "truncated JSON accepted when no python3/jq is available"
else
    pass "truncated JSON rejected with no python3/jq on PATH"
fi
if PATH="$WORK/nobin" bash -c '
      set -uo pipefail
      error() { :; }; log() { :; }; success() { :; }; warn() { :; }
      . "$2"
      payload_is_valid_json "$3"
   ' _ "$GUARD_ERR_LOG" "$GUARD" "$WORK/good.json" 2>/dev/null; then
    pass "valid JSON accepted with no python3/jq on PATH"
else
    fail "valid JSON rejected when no python3/jq is available"
fi

# --print-manifest is a read-only query. It must work from any directory and
# must not take the install lock, or a stale lock turns the release gate red.
manifest_probe="$WORK/not-a-project"
mkdir -p "$manifest_probe"
if (cd "$manifest_probe" && bash "$INSTALLER" --print-manifest) > "$WORK/probe.txt" 2>"$WORK/probe.err"; then
    if [[ "$(grep -c . "$WORK/probe.txt")" -gt 100 ]]; then
        pass "--print-manifest works outside a project directory"
    else
        fail "--print-manifest printed only $(grep -c . "$WORK/probe.txt") lines outside a project"
    fi
else
    fail "--print-manifest failed outside a project directory: $(head -1 "$WORK/probe.err")"
fi
if [[ -d /tmp/agent11-install.lock ]]; then
    fail "--print-manifest left /tmp/agent11-install.lock behind (it must not take the lock)"
else
    pass "--print-manifest takes no install lock"
fi

# 1f. No unguarded writer left anywhere in install.sh: every curl/wget that
#     writes to a file must be inside the guard block.
# Any curl/wget that can put bytes in a file: -o/-O/--output (with or without a
# space), -qO, --remote-name, a > redirect, or a pipe into tee.
strays="$(grep -n -E '(curl|wget)([^#]*)(-o ?"|-O ?"|-qO ?[^-]|--output|--remote-name|> *"|\| *tee)' "$INSTALLER" \
         | grep -v 'fetch_url_to_file' \
         | grep -v -E '^[0-9]+:[[:space:]]*#' || true)"
guard_start="$(grep -n 'A11-ISS-31 DOWNLOAD GUARD BEGIN' "$INSTALLER" | cut -d: -f1)"
guard_end="$(grep -n 'A11-ISS-31 DOWNLOAD GUARD END' "$INSTALLER" | cut -d: -f1)"
outside=""
while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    ln="${line%%:*}"
    if (( ln < guard_start || ln > guard_end )); then
        outside+="    install.sh:$line"$'\n'
    fi
done <<< "$strays"
if [[ -n "$outside" ]]; then
    fail "curl/wget writes to a file outside the download guard:"
    printf '%s' "$outside"
else
    pass "no curl/wget file writes outside the download guard"
fi

echo

# ---------------------------------------------------------------------------
# Suite 2: the manifest, against the live repo
# ---------------------------------------------------------------------------
if $OFFLINE; then
    echo "== MANIFEST (skipped: --offline) =="
    echo
    echo "$PASS passed, $FAIL failed"
    [[ $FAIL -eq 0 ]] || exit 1
    exit 0
fi

echo "== MANIFEST (live GitHub) =="

MANIFEST="$WORK/manifest.txt"
# Run from the repo root: install.sh refuses to start outside a project context,
# so the manifest must not depend on the caller's working directory.
if ! (cd "$REPO_ROOT" && bash "$INSTALLER" --print-manifest) > "$MANIFEST" 2>"$WORK/manifest.err"; then
    fail "install.sh --print-manifest failed: $(head -3 "$WORK/manifest.err")"
    echo; echo "$PASS passed, $FAIL failed"; exit 1
fi
count="$(grep -c . "$MANIFEST")"
if [[ "$count" -lt 130 ]]; then
    fail "manifest has only $count entries - expected the full install set (~136)"
else
    pass "manifest lists $count downloadable paths"
fi

dupes="$(sort "$MANIFEST" | uniq -d)"
if [[ -n "$dupes" ]]; then
    fail "manifest contains duplicates: $(echo "$dupes" | tr '\n' ' ')"
else
    pass "manifest has no duplicate entries"
fi

# Repo/branch the installer actually targets, read from install.sh itself.
REPO="$(grep -m1 '^GITHUB_REPO=' "$INSTALLER" | cut -d'"' -f2)"
BRANCH="$(grep -m1 '^GITHUB_BRANCH=' "$INSTALLER" | cut -d'"' -f2)"
BASE="https://raw.githubusercontent.com/$REPO/$BRANCH"
info "checking against $BASE"

DOWNLOADS="$WORK/downloads"
mkdir -p "$DOWNLOADS"

# Fetch every manifest entry, 8 at a time. Each worker writes one status line.
export BASE DOWNLOADS
fetch_one() {
    local path="$1"
    local safe="${path//\//__}"
    local code
    code="$(curl -sSL --retry 2 --max-time 60 -w '%{http_code}' \
            -o "$DOWNLOADS/$safe" "$BASE/$path" 2>/dev/null)" || code="000"
    echo "$code|$path|$safe"
}
export -f fetch_one

RESULTS="$WORK/results.txt"
grep . "$MANIFEST" | xargs -P 8 -I{} bash -c 'fetch_one "$@"' _ {} > "$RESULTS"

bad_status=0
while IFS='|' read -r code path safe; do
    if [[ "$code" != "200" ]]; then
        fail "HTTP $code  $BASE/$path"
        bad_status=$((bad_status + 1))
    fi
done < "$RESULTS"
if [[ $bad_status -eq 0 ]]; then
    pass "all $count URLs return HTTP 200"
fi

# Every fetched payload must parse for its type, and must not be an error body.
bad_parse=0
while IFS='|' read -r code path safe; do
    [[ "$code" == "200" ]] || continue
    file="$DOWNLOADS/$safe"
    first="$(head -n 1 "$file" | tr -d '\r' | cut -c1-40)"
    case "$first" in
        4[0-9][0-9]:*|5[0-9][0-9]:*)
            fail "error body served with HTTP 200: $path (\"$first\")"
            bad_parse=$((bad_parse + 1)); continue ;;
    esac
    if [[ ! -s "$file" ]]; then
        fail "empty payload: $path"
        bad_parse=$((bad_parse + 1)); continue
    fi
    case "$path" in
        *.json|*.json.template)
            python3 -c 'import json,sys; json.load(open(sys.argv[1]))' "$file" >/dev/null 2>&1 \
                || { fail "not valid JSON: $path"; bad_parse=$((bad_parse + 1)); } ;;
        *.sh)
            bash -n "$file" >/dev/null 2>&1 \
                || { fail "not valid bash: $path"; bad_parse=$((bad_parse + 1)); } ;;
        *.py)
            python3 -c 'import ast,sys; ast.parse(open(sys.argv[1]).read())' "$file" >/dev/null 2>&1 \
                || { fail "not valid python: $path"; bad_parse=$((bad_parse + 1)); } ;;
        *.yaml|*.yml)
            if python3 -c 'import yaml' >/dev/null 2>&1; then
                python3 -c 'import yaml,sys; yaml.safe_load(open(sys.argv[1]))' "$file" >/dev/null 2>&1 \
                    || { fail "not valid YAML: $path"; bad_parse=$((bad_parse + 1)); }
            fi ;;
    esac
done < "$RESULTS"
if [[ $bad_parse -eq 0 ]]; then
    pass "every fetched payload parses for its file type"
fi

# The .mcp.json.template is the file A11-ISS-31 was raised about: it must be
# byte-identical to what the repo ships, not merely valid.
tmpl_local="$REPO_ROOT/project/deployment/templates/.mcp.json.template"
tmpl_remote="$DOWNLOADS/project__deployment__templates__.mcp.json.template"
if [[ -f "$tmpl_local" && -f "$tmpl_remote" ]]; then
    if diff -q "$tmpl_local" "$tmpl_remote" >/dev/null 2>&1; then
        pass ".mcp.json.template on $BRANCH matches the working tree byte for byte"
    else
        info ".mcp.json.template differs from the working tree (unpushed local edits?)"
    fi
fi

# Coverage: every literal path passed to a download call site must be in the
# manifest, so a newly added fetch cannot escape this test.
missing_cover=0
while IFS= read -r path; do
    [[ -z "$path" ]] && continue
    grep -Fxq "$path" "$MANIFEST" || { fail "download call site not in manifest: $path"; missing_cover=$((missing_cover + 1)); }
done < <(
    {
        grep -oE 'download_file_from_github "[^"$]+"' "$INSTALLER" | sed 's/.*"\(.*\)"/\1/'
        grep -oE '(download_mcp_file|fetch_url_to_file) "\$GITHUB_REPO_BASE/[^"]+"' "$INSTALLER" \
            | sed 's|.*\$GITHUB_REPO_BASE/||; s/"$//'
    } | grep -v '[$]' | sort -u
)
if [[ $missing_cover -eq 0 ]]; then
    pass "every literal download call site is covered by the manifest"
fi

echo
echo "$PASS passed, $FAIL failed"
echo "artifacts kept in $WORK"
[[ $FAIL -eq 0 ]] || exit 1
exit 0
