#!/bin/bash

# AGENT-11 Installation Script
# Deploys elite AI agent squad to Claude Code
# Target: 95% success rate, <5 minute installation

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Colors for output (defined early for use in functions)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Disable colors when stdout is not a terminal (e.g., piped to file)
if [ ! -t 1 ]; then
    RED=''; GREEN=''; YELLOW=''; BLUE=''; NC=''
fi

# Logging functions (defined early for use in project detection)
log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

fatal() {
    error "$1"
    exit 1
}

# Enhanced project detection with helpful guidance
detect_project_context() {
    local current_dir="$(pwd)"
    local project_indicators=()
    local suggestions=()
    
    # Check for various project indicators
    if [[ -d ".git" ]]; then
        project_indicators+=("Git repository")
    fi
    
    if [[ -d ".claude" ]]; then
        project_indicators+=("Existing Claude agents")
    fi
    
    if [[ -f "package.json" ]]; then
        project_indicators+=("Node.js project")
    fi
    
    if [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]] || [[ -f "setup.py" ]]; then
        project_indicators+=("Python project")
    fi
    
    if [[ -f "Cargo.toml" ]]; then
        project_indicators+=("Rust project")
    fi
    
    if [[ -f "go.mod" ]]; then
        project_indicators+=("Go project")
    fi
    
    if [[ -f "pom.xml" ]] || [[ -f "build.gradle" ]]; then
        project_indicators+=("Java project")
    fi
    
    if [[ -f "composer.json" ]]; then
        project_indicators+=("PHP project")
    fi
    
    if [[ -f "Gemfile" ]]; then
        project_indicators+=("Ruby project")
    fi
    
    if [[ -f "README.md" ]] || [[ -f "README.txt" ]] || [[ -f "readme.md" ]]; then
        project_indicators+=("README file")
    fi
    
    # If we found project indicators, set up project-local installation
    if [[ ${#project_indicators[@]} -gt 0 ]]; then
        CLAUDE_DIR="$(pwd)/.claude"
        AGENTS_DIR="$CLAUDE_DIR/agents"
        COMMANDS_DIR="$CLAUDE_DIR/commands"
        MISSIONS_DIR="$(pwd)/missions"
        TEMPLATES_DIR="$(pwd)/templates"
        FIELD_MANUAL_DIR="$(pwd)/field-manual"
        # BACKUP_DIR is set once, outside the repo, further down (see "T-245: backups
        # live OUTSIDE the target repo"). Deliberately not set here: two assignments
        # would mean two sources of truth for where a user's backup went.
        PROJECT_DETECTED=true
        DETECTED_INDICATORS=("${project_indicators[@]}")
        return 0
    else
        PROJECT_DETECTED=false
        return 1
    fi
}

# Display helpful guidance when no project is detected
show_no_project_guidance() {
    echo
    echo -e "${RED}❌ No project detected in current directory${NC}"
    echo
    echo "AGENT-11 deploys your elite squad to work on a specific project."
    echo
    echo -e "${BLUE}📁 To get started:${NC}"
    echo "1. Navigate to your project directory: cd /path/to/your-project"
    echo "2. Or create a new project: mkdir my-project && cd my-project && git init"
    echo "3. Then run the installer again"
    echo
    echo -e "${BLUE}💡 Looking for existing projects?${NC}"
    echo "Try finding Git repositories: find ~ -name '.git' -type d -maxdepth 3 2>/dev/null | head -10"
    echo
    echo -e "${BLUE}🚀 Quick project setup examples:${NC}"
    echo "# New Node.js project"
    echo "mkdir my-app && cd my-app && npm init -y && git init"
    echo
    echo "# New Python project"
    echo "mkdir my-app && cd my-app && touch requirements.txt && git init"
    echo
    echo "# Existing directory"
    echo "cd my-existing-project && git init"
    echo
    echo "Current directory: $(pwd)"
    echo
    
    # Look for potential projects in nearby directories
    local nearby_projects=()
    if command -v find >/dev/null 2>&1; then
        log "Scanning for nearby projects..."
        while IFS= read -r -d '' project_dir; do
            local project_parent="$(dirname "$project_dir")"
            local relative_path="$(realpath --relative-to="$(pwd)" "$project_parent" 2>/dev/null || echo "$project_parent")"
            nearby_projects+=("$relative_path")
        done < <(find "$(pwd)/.." -maxdepth 2 -name ".git" -type d -print0 2>/dev/null | head -c 1000)
        
        if [[ ${#nearby_projects[@]} -gt 0 ]]; then
            echo -e "${YELLOW}📂 Found nearby projects:${NC}"
            for project in "${nearby_projects[@]}"; do
                echo "  cd $project"
            done
            echo
        fi
    fi
}

# A11-ISS-31: --print-manifest is a read-only query used by the release test.
# It must not demand a project context or take the install lock, or a stale
# lock and an unlucky working directory turn the release gate red for no reason.
A11_MANIFEST_ONLY=false
for _a11_arg in "$@"; do
    [[ "$_a11_arg" == "--print-manifest" ]] && A11_MANIFEST_ONLY=true
done
unset _a11_arg

# Detect project context and require project-local installation
if ! $A11_MANIFEST_ONLY && ! detect_project_context; then
    show_no_project_guidance
    fatal "Installation requires a project context. Please navigate to a project directory first."
fi

# Security: Validate installation paths before any operations
validate_installation_paths() {
    local dirs=("$CLAUDE_DIR" "$AGENTS_DIR" "$COMMANDS_DIR" "$MISSIONS_DIR" "$TEMPLATES_DIR" "$FIELD_MANUAL_DIR")
    for dir_path in "${dirs[@]}"; do
        if [[ -z "$dir_path" || "$dir_path" == "/" ]]; then
            fatal "SECURITY: Installation path is empty or root. Aborting to prevent data loss."
        fi
        case "$dir_path" in
            /etc*|/usr*|/var*|/bin*|/sbin*|/opt*|/System*|/Library*|/tmp)
                fatal "SECURITY: Refusing to operate on system directory: $dir_path"
                ;;
        esac
    done

    # Check for symlink attacks on critical paths
    if [[ -L "$AGENTS_DIR" ]]; then
        fatal "SECURITY: $AGENTS_DIR is a symlink. Aborting for safety."
    fi
    if [[ -L "$COMMANDS_DIR" ]]; then
        fatal "SECURITY: $COMMANDS_DIR is a symlink. Aborting for safety."
    fi
}

$A11_MANIFEST_ONLY || validate_installation_paths

# Prevent concurrent installations
LOCKDIR="/tmp/agent11-install.lock"
if ! $A11_MANIFEST_ONLY; then
    if ! mkdir "$LOCKDIR" 2>/dev/null; then
        fatal "Another AGENT-11 installation is already running. If this is a stale lock, remove: $LOCKDIR"
    fi
fi
# A11-ISS-31: also sweep the in-flight download temp file, so an interrupt
# mid-fetch does not leave a half-written agent11-download.* beside the target.
trap 'if [[ -n "${A11_ACTIVE_TMP:-}" ]]; then rm -f "$A11_ACTIVE_TMP" 2>/dev/null; fi; if ! $A11_MANIFEST_ONLY; then rmdir "$LOCKDIR" 2>/dev/null; fi; true' EXIT

TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# ---------- T-245: backups live OUTSIDE the target repo ----------
#
# install.sh used to write every backup inside the project it was installing
# into: .claude/backups/agent-11/<ts>/, .claude/CLAUDE.md.backup-<ts> and
# .claude/settings.json.backup-<ts>. Five installs into one repo therefore left
# roughly a dozen untracked artefacts behind, and a fleet survey on 2026-08-04
# found exactly that — aisearchmastery 17, SEOAgent 15, aimpactscanner-mvp 13,
# Trader-7 12, aisearcharena 7. That litter is indistinguishable from a user's
# own uncommitted work at a glance, which is precisely what makes an upgrade
# sweep look unsafe when it is not.
#
# fix-fleet-permissions.py hit the same wall and was corrected the same way, so
# this mirrors its layout and its override variable naming deliberately. One
# directory per repo so a backup can be traced back to where it came from.
#
# Override with AGENT11_INSTALL_BACKUPS. Falls back to inside the repo ONLY if
# the external root cannot be created, and says so loudly when it does.
#
# The default is $HOME/.agent-11/backups, not a path under Shared/: this installer
# ships to strangers, and a default pointing at one person's synced fleet directory
# would be meaningless on any other machine.
#
# The key is the project's full path with separators flattened, not its basename.
# Two checkouts named "api" under different parents would otherwise write their
# backups into the same directory and interleave by timestamp, which is a data-loss
# bug waiting for whoever restores the wrong one.
AGENT11_BACKUP_ROOT="${AGENT11_INSTALL_BACKUPS:-$HOME/.agent-11/backups}"
BACKUP_REPO_KEY="$(printf '%s' "$(pwd)" | sed -e "s|^$HOME/||" -e 's|[/ ]|_|g')"

# Decide WHERE without creating anything. This block runs at script top level, before
# --dry-run is even parsed, so a `mkdir -p` here would make a "no changes were made" run
# create a directory — a small lie, but this whole week has been about not shipping those.
# Writability is probed by testing the nearest existing ancestor, and the directory itself
# is created lazily by whoever first needs it.
_probe="$AGENT11_BACKUP_ROOT"
while [[ -n "$_probe" && ! -d "$_probe" ]]; do _probe="$(dirname "$_probe")"; done
if [[ -w "$_probe" ]]; then
    BACKUP_DIR="$AGENT11_BACKUP_ROOT/$BACKUP_REPO_KEY"
    BACKUP_LOCATION="external"
else
    # Only if the external root is genuinely unreachable. Says so in the stamp and in
    # the dry-run plan, so an in-repo backup is never a silent outcome.
    BACKUP_DIR="$CLAUDE_DIR/backups/agent-11"
    BACKUP_LOCATION="in-repo-fallback"
fi
unset _probe
BACKUP_PATH="$BACKUP_DIR/$TIMESTAMP"

# GitHub repository configuration
GITHUB_REPO="TheWayWithin/agent-11"
GITHUB_BRANCH="main"
GITHUB_AGENTS_PATH="project/agents/specialists"
GITHUB_RAW_BASE="https://raw.githubusercontent.com/$GITHUB_REPO/$GITHUB_BRANCH/$GITHUB_AGENTS_PATH"
GITHUB_REPO_BASE="https://raw.githubusercontent.com/$GITHUB_REPO/$GITHUB_BRANCH"


# The Agent-11 squad: always deploys all 11 specialists.
# (Legacy 'core' and 'minimal' squads were removed in favour of a single,
#  deterministic install. Agents are lazy-loaded by Claude Code so having
#  all 11 available costs almost nothing at session start.)
SQUAD_FULL=("strategist" "developer" "tester" "operator" "architect" "designer" "documenter" "support" "analyst" "marketer" "coordinator")

# ---------------------------------------------------------------------------
# Remote download manifest (A11-ISS-31)
#
# Every repo-relative path this installer can fetch from GitHub is declared
# here, once. The install functions read these arrays and `--print-manifest`
# prints the fully expanded list, so project/deployment/tests/
# test-installer-downloads.sh can prove every URL still resolves before a
# release. A path that only exists inside a function body is a path no test
# can see - that is how the dead .mcp.json URL survived for months.
# ---------------------------------------------------------------------------

A11_MISSION_FILES=(
    "project/missions/library.md"
    "project/missions/mission-build.md"
    "project/missions/mission-fix.md"
    "project/missions/mission-mvp.md"
    "project/missions/mission-refactor.md"
    "project/missions/mission-deploy.md"
    "project/missions/mission-document.md"
    "project/missions/mission-optimize.md"
    "project/missions/mission-integrate.md"
    "project/missions/mission-migrate.md"
    "project/missions/mission-security.md"
    "project/missions/mission-release.md"
    "project/missions/mission-architecture.md"
    "project/missions/mission-product-description.md"
    "project/missions/operation-genesis.md"
    "project/missions/dev-setup.md"
    "project/missions/dev-alignment.md"
    "project/missions/connect-mcp.md"
    "project/missions/operation-recon.md"
    "project/missions/README.md"
)

A11_COMMAND_FILES=(
    "project/commands/coord.md"
    "project/commands/meeting.md"
    "project/commands/design-review.md"
    "project/commands/recon.md"
    "project/commands/report.md"
    "project/commands/pmd.md"
    "project/commands/dailyreport.md"
    "project/commands/blog.md"
    "project/commands/planarchive.md"
    # Sprint 9: Plan-Driven Development commands
    "project/commands/foundations.md"
    "project/commands/bootstrap.md"
    "project/commands/plan.md"
    "project/commands/skills.md"
    "project/commands/architect.md"
)

A11_TEMPLATE_FILES=(
    "project/templates/mission-template.md"
    "project/templates/agent-creation-mastery.md"
    "templates/architecture-template.md"
    "templates/product-description-template.md"
    "templates/agent-context-template.md"
    "templates/evidence-repository-template.md"
    "templates/project-plan-template.md"
    "templates/progress-template.md"
    "templates/lessons-index-template.md"
    "templates/lesson-template.md"
    "templates/cleanup-checklist.md"
    "templates/claude-template.md"
    "templates/file-operation-delegation.md"
    "templates/file-verification-checklist.md"
    # Sprint 9: Foundation and Plan templates
    "templates/foundation-prd.md"
    "templates/foundation-vision.md"
    "templates/plan-saas-mvp.yaml"
    "templates/plan-saas-full.yaml"
    "templates/plan-api.yaml"
    # A11-ISS-8: tool project type (A11-ISS-6) plan counterpart
    "templates/plan-tool.yaml"
    # Sprint 6b: ratchet loop input template
    "templates/mission-optimize-input-template.md"
)

A11_FIELD_MANUAL_FILES=(
    "project/field-manual/architecture-sop.md"
    "project/field-manual/project-lifecycle-guide.md"
    "project/field-manual/model-selection-guide.md"
    "project/field-manual/mcp-integration.md"
    "project/field-manual/file-operation-quickref.md"
    # Sprint 9: Plan-Driven Development guides
    "project/field-manual/plan-driven-development.md"
    "project/field-manual/quality-gates-guide.md"
    "project/field-manual/skills-guide.md"
    "project/field-manual/architectural-principles.md"
    # Sprint 6b: loop discipline (ratchet + scored review loop)
    "project/field-manual/loop-discipline-guide.md"
    # PRJ-14: BOS-AI handoff (two tiers + ownership-transfer rule)
    "project/field-manual/bos-ai-handoff.md"
)

A11_SKILL_DIRS=("saas-auth" "saas-payments" "saas-multitenancy" "saas-billing" "saas-email" "saas-onboarding" "saas-analytics" "code-review-loop")

# Skills that ship stack-specific references/ alongside SKILL.md
A11_SKILLS_WITH_REFERENCES=("saas-payments" "saas-auth")
A11_SKILL_REFERENCES=("nextjs-supabase.md" "remix-railway.md")

A11_SCHEMA_FILES=("skill.schema.yaml" "stack-profile.schema.yaml" "skill-loading.schema.yaml" "quality-gate.schema.yaml" "project-plan.schema.yaml" "phase-context.schema.yaml" "handoff-manifest.schema.yaml" "foundation-prd.schema.yaml" "foundation-vision.schema.yaml" "foundation-roadmap.schema.yaml" "foundation-icp.schema.yaml" "foundation-research.schema.yaml" "foundation-brand.schema.yaml" "foundation-positioning.schema.yaml" "foundation-marketing.schema.yaml" "foundation-pricing.schema.yaml")

A11_GATE_TEMPLATES=("nodejs-saas.json" "python-api.json" "minimal.json" "saas-skills-advisory.json")

A11_STACK_PROFILES=("nextjs-supabase.yaml" "remix-railway.yaml" "sveltekit-supabase.yaml" "README.md")

# Everything else the installer reaches for by literal path: files fetched from
# a single call site, plus the two URLs it only prints for the user to run and
# the changelog it reads into a variable. All of them must resolve - a rollback
# command that 404s is as useless as a template that does.
A11_SINGLE_FILES=(
    "library/CLAUDE.md"
    "library/settings.json.template"
    "library/hooks/gate-guard.sh"
    "library/hooks/destructive-guard.sh"
    "library/scripts/mission-state.py"
    "project/constitution/karpathy-constitution.md"
    "project/data/voice-guide-default.md"
    "project/deployment/scripts/migrate-v5-to-v6.sh"
    "project/deployment/scripts/merge-settings.py"
    "project/deployment/scripts/mcp-setup-v2.sh"
    "project/deployment/scripts/mcp-setup.sh"
    "project/deployment/templates/.mcp.json.template"
    ".env.mcp.template"
    "project/gates/run-gates.py"
    "project/gates/gate-types.yaml"
    "project/gates/README.md"
    "docs/MCP-GUIDE.md"
    "docs/MCP-PROFILES.md"
    "docs/MCP-TROUBLESHOOTING.md"
    "docs/MCP-MIGRATION-GUIDE.md"
    "docs/UPGRADE.md"
    # Read into a variable for the release-notes display, not written to a file.
    "CHANGELOG.md"
    # Printed for the user to run via bash <(curl ...); never fetched here.
    "project/deployment/scripts/restore-pre-upgrade.sh"
)

# Is $1 present in the remaining arguments?
a11_list_contains() {
    local needle="$1"; shift
    local item
    for item in "$@"; do
        [[ "$item" == "$needle" ]] && return 0
    done
    return 1
}

# Print every repo-relative path this installer can download, one per line.
# Consumed by project/deployment/tests/test-installer-downloads.sh.
print_download_manifest() {
    local item skill ref
    for item in "${SQUAD_FULL[@]}"; do
        echo "$GITHUB_AGENTS_PATH/$item.md"
    done
    for item in "${A11_MISSION_FILES[@]}" "${A11_COMMAND_FILES[@]}" \
                "${A11_TEMPLATE_FILES[@]}" "${A11_FIELD_MANUAL_FILES[@]}" \
                "${A11_SINGLE_FILES[@]}"; do
        echo "$item"
    done
    for skill in "${A11_SKILL_DIRS[@]}"; do
        echo "project/skills/$skill/SKILL.md"
    done
    for skill in "${A11_SKILLS_WITH_REFERENCES[@]}"; do
        for ref in "${A11_SKILL_REFERENCES[@]}"; do
            echo "project/skills/$skill/references/$ref"
        done
    done
    for item in "${A11_SCHEMA_FILES[@]}"; do
        echo "project/schemas/$item"
    done
    for item in "${A11_GATE_TEMPLATES[@]}"; do
        echo "project/gates/templates/$item"
    done
    for item in "${A11_STACK_PROFILES[@]}"; do
        echo "templates/stack-profiles/$item"
    done
}


# Progress tracking
show_progress() {
    local current=$1
    local total=$2
    local description=$3
    local percent=$((current * 100 / total))
    echo -e "${BLUE}[PROGRESS]${NC} [$current/$total] $percent% - $description"
}

# Platform detection
detect_platform() {
    case "$(uname -s)" in
        Darwin*)    echo "macos" ;;
        Linux*)     echo "linux" ;;
        MINGW*|CYGWIN*|MSYS*) echo "windows" ;;
        *)          echo "unknown" ;;
    esac
}

# --- A11-ISS-31 DOWNLOAD GUARD BEGIN ---------------------------------------
# Hardened download primitive. Everything this installer fetches goes through
# fetch_url_to_file.
#
# Root cause of A11-ISS-31: downloads wrote straight to their destination with
# `curl -sSL -o "$dest"`. curl WITHOUT -f exits 0 on an HTTP error and writes
# the error BODY, so raw.githubusercontent.com's 14-byte "404: Not Found" page
# landed in .mcp.json across 16 repos. Worse, the file then existed, so the
# `[[ ! -f .mcp.json ]]` template fallback that would have repaired it never
# ran, and nothing said a word. A11-ISS-3 put -f on the MCP downloads in July;
# this generalises the guard to every download and adds content validation,
# because -f alone still trusts a 200 response to contain what we asked for.
#
# fetch_url_to_file:
#   1. writes to a temp file, never to the destination;
#   2. requires HTTP 200 (curl) or a clean exit (wget);
#   3. rejects empty payloads and known HTTP error bodies;
#   4. parses the payload for the file type implied by the destination name
#      (JSON / bash / python);
#   5. only then moves it into place.
# A rejected download leaves the destination byte-for-byte as it was and
# returns 1, loudly. Nothing partial, nothing silent.
#
# The BEGIN/END markers are load-bearing: the test at
# project/deployment/tests/test-installer-downloads.sh extracts this block and
# exercises it directly against a real 404.
# ---------------------------------------------------------------------------

# Is $1 valid JSON?
payload_is_valid_json() {
    local file="$1"
    if command -v python3 >/dev/null 2>&1; then
        python3 -c 'import json,sys; json.load(open(sys.argv[1]))' "$file" >/dev/null 2>&1
        return $?
    fi
    if command -v jq >/dev/null 2>&1; then
        jq empty "$file" >/dev/null 2>&1
        return $?
    fi
    # No python3 and no jq. A first-character check is NOT enough: a truncated
    # body like `{ "mcpServers":` starts with { and would sail through, which is
    # A11-ISS-31 reproduced on a minimal container. Nor is balancing brackets
    # enough - that accepts `{"a": }`, `{,,,}` and any prose containing balanced
    # braces. So this is a real (if minimal) JSON walk in awk, which is present
    # on every POSIX box. It validates structure, not semantics.
    if command -v awk >/dev/null 2>&1; then
        awk '
        # Real (if minimal) JSON validation: tokenise and walk with an explicit stack.
        # Deliberately not a bracket balancer - it must reject {"a": }, {"a" "b"},
        # {,,,} and ordinary prose that happens to contain balanced braces.
        { buf = buf $0 "\n" }
        END {
            n = length(buf); i = 1
            # 0 value | 1 key-or-close-object | 2 colon | 3 comma-or-close
            # 5 value-or-close-array | 6 key required (after a comma) | 4 done
            state = 0; depth = 0; ok = 1
            while (i <= n) {
                c = substr(buf, i, 1)
                if (c == " " || c == "\t" || c == "\n" || c == "\r") { i++; continue }
                if (state == 4) { ok = 0; break }

                if (state == 2) {
                    if (c != ":") { ok = 0; break }
                    i++; state = 0; continue
                }
                if (state == 3) {
                    if (c == ",") {
                        i++; state = (stack[depth] == "o") ? 6 : 0; continue
                    }
                    if ((c == "}" && stack[depth] == "o") || (c == "]" && stack[depth] == "a")) {
                        depth--; i++; state = (depth == 0) ? 4 : 3; continue
                    }
                    ok = 0; break
                }
                if (state == 1 || state == 6) {
                    # 1 allows the empty object; 6 is after a comma, where a key is required
                    if (c == "}" && state == 1) { depth--; i++; state = (depth == 0) ? 4 : 3; continue }
                    if (c != "\"") { ok = 0; break }
                    j = scanstring(buf, i, n); if (j < 0) { ok = 0; break }
                    i = j; state = 2; continue
                }
                if (state == 5 && c == "]") {
                    depth--; i++; state = (depth == 0) ? 4 : 3; continue
                }

                # value position (state 0 or 5)
                if (c == "{")      { depth++; stack[depth] = "o"; i++; state = 1; continue }
                if (c == "[")      { depth++; stack[depth] = "a"; i++; state = 5; continue }
                if (c == "\"")     { j = scanstring(buf, i, n); if (j < 0) { ok = 0; break }
                                     i = j; state = (depth == 0) ? 4 : 3; continue }
                if (c == "-" || (c >= "0" && c <= "9")) {
                                     j = scannumber(buf, i, n); if (j < 0) { ok = 0; break }
                                     i = j; state = (depth == 0) ? 4 : 3; continue }
                if (substr(buf, i, 4) == "true" || substr(buf, i, 4) == "null") {
                                     i += 4; state = (depth == 0) ? 4 : 3; continue }
                if (substr(buf, i, 5) == "false") {
                                     i += 5; state = (depth == 0) ? 4 : 3; continue }
                ok = 0; break
            }
            if (ok && (state != 4 || depth != 0)) ok = 0
            exit ok ? 0 : 1
        }
        function scanstring(s, p, n,   k, ch) {
            k = p + 1
            while (k <= n) {
                ch = substr(s, k, 1)
                if (ch == "\\") { k += 2; continue }
                if (ch == "\"") { return k + 1 }
                if (ch == "\n") { return -1 }
                k++
            }
            return -1
        }
        function scannumber(s, p, n,   k, ch, seen) {
            k = p; seen = 0
            if (substr(s, k, 1) == "-") k++
            while (k <= n) { ch = substr(s, k, 1); if (ch >= "0" && ch <= "9") { seen = 1; k++ } else break }
            if (!seen) return -1
            if (substr(s, k, 1) == ".") {
                k++; seen = 0
                while (k <= n) { ch = substr(s, k, 1); if (ch >= "0" && ch <= "9") { seen = 1; k++ } else break }
                if (!seen) return -1
            }
            ch = substr(s, k, 1)
            if (ch == "e" || ch == "E") {
                k++; ch = substr(s, k, 1); if (ch == "+" || ch == "-") k++
                seen = 0
                while (k <= n) { ch = substr(s, k, 1); if (ch >= "0" && ch <= "9") { seen = 1; k++ } else break }
                if (!seen) return -1
            }
            return k
        }
        ' "$file"
        return $?
    fi
    error "Cannot validate JSON: no python3, jq or awk on this system"
    return 1
}

# Reject an HTTP error body, an empty file, or a payload that does not parse
# for its file type. Returns 0 only if the payload is plausibly the real thing.
validate_downloaded_payload() {
    local tmp="$1" dest="$2" label="$3"

    if [[ ! -s "$tmp" ]]; then
        error "Rejected $label: server returned an empty file"
        return 1
    fi

    # Error-page detection. Matching the raw first line is not enough: a proxy or
    # captive portal answers 200 with `<!DOCTYPE HTML PUBLIC ...`, a leading blank
    # line, or an XML prolog, and every one of those walked past the original
    # four-pattern check into the 120 .md/.yaml files that get no type parse at
    # all. So: take the first 256 bytes, flatten newlines, strip leading space,
    # lowercase, and match the opening token.
    local head_bytes lead size
    # A UTF-8 BOM sits in front of the first character and defeats any leading
    # token match, so it is stripped along with leading whitespace.
    head_bytes="$(head -c 256 "$tmp" | tr -d '\r' | tr '\n' ' ')" || head_bytes=""
    lead="$(printf '%s' "$head_bytes" | sed $'s/^\xef\xbb\xbf//' | sed 's/^[[:space:]]*//' | tr '[:upper:]' '[:lower:]')"
    if [[ -z "$lead" ]]; then
        error "Rejected $label: payload is blank"
        return 1
    fi
    case "$lead" in
        # raw.githubusercontent.com serves exactly "404: Not Found" for a missing
        # path; other tiers answer "403: ...", "500: ..." and so on.
        [45][0-9][0-9]:*)
            error "Rejected $label: server returned \"${lead:0:60}\""
            return 1
            ;;
        # Nothing this installer ships starts with an angle bracket - verified
        # across the whole manifest - while every HTML and XML error document
        # does: GitHub's page, Apache's, nginx's 502, an S3 <Error><Code>, a
        # captive portal's <meta refresh>. Matching the family beats chasing
        # each vendor's wording.
        "<"*)
            error "Rejected $label: server returned an HTML/XML document, not a file"
            return 1
            ;;
    esac
    # Short bodies that read like a proxy error ("Error 403: blocked by policy").
    # Length-bounded so a document that happens to discuss error codes is safe.
    size="$(wc -c < "$tmp" | tr -d ' ')"
    if [[ "$size" -lt 1024 ]]; then
        case "$lead" in
            "error "[45][0-9][0-9]*|"error: "*|"forbidden"*|"access denied"*)
                error "Rejected $label: server returned \"${lead:0:60}\""
                return 1
                ;;
        esac
    fi

    # Type is read from the destination name, falling back to the label (the
    # source path) when the destination is an extensionless temp file - the
    # settings.json merge path and the migration scripts download into mktemp
    # files, and those payloads need validating just as much.
    local type_name
    type_name="$(basename "$dest")"
    case "$type_name" in
        *.json|*.json.template|*.sh|*.py) : ;;
        *) type_name="$(basename "$label")" ;;
    esac

    case "$type_name" in
        *.json|*.json.template)
            if ! payload_is_valid_json "$tmp"; then
                error "Rejected $label: payload is not valid JSON"
                return 1
            fi
            ;;
        *.sh)
            if ! bash -n "$tmp" >/dev/null 2>&1; then
                error "Rejected $label: payload is not valid bash"
                return 1
            fi
            ;;
        *.py)
            if command -v python3 >/dev/null 2>&1; then
                if ! python3 -c 'import ast,sys; ast.parse(open(sys.argv[1]).read())' "$tmp" >/dev/null 2>&1; then
                    error "Rejected $label: payload is not valid python"
                    return 1
                fi
            fi
            ;;
    esac

    return 0
}

# fetch_url_to_file <url> <dest> [label]
fetch_url_to_file() {
    local url="$1" dest="$2" label="${3:-$2}"
    local tmp status dest_dir

    if [[ -d "$dest" ]]; then
        # `mv file dir/` succeeds by moving the file INTO the directory and the
        # chmod below would then strip its x bit. Refuse instead.
        error "Rejected $label: destination $dest is a directory"
        return 1
    fi

    # Temp file lives beside the destination, not in $TMPDIR: the final `mv` is
    # then a same-filesystem rename, which is atomic. A cross-device mv is a
    # copy, and an interrupted copy leaves the truncated destination this guard
    # exists to prevent. Falls back to $TMPDIR only if the target dir is not
    # writable, in which case the mv would fail anyway.
    dest_dir="$(dirname "$dest")"
    mkdir -p "$dest_dir" 2>/dev/null || true
    tmp="$(mktemp "$dest_dir/.agent11-download.XXXXXX" 2>/dev/null)" \
        || tmp="$(mktemp "${TMPDIR:-/tmp}/agent11-download.XXXXXX")" \
        || {
            error "Could not create a temp file while downloading $label"
            return 1
        }
    A11_ACTIVE_TMP="$tmp"   # swept by the EXIT trap if we are interrupted

    if command -v curl >/dev/null 2>&1; then
        status="$(curl -sSL --retry 2 --max-time 120 -w '%{http_code}' -o "$tmp" "$url" 2>/dev/null)" || status="000"
    elif command -v wget >/dev/null 2>&1; then
        # wget exits non-zero on 4xx/5xx and we never reuse its output file.
        if wget -q -O "$tmp" "$url"; then status="200"; else status="000"; fi
    else
        error "Neither curl nor wget available for downloading files"
        rm -f "$tmp"
        A11_ACTIVE_TMP=""
        return 1
    fi

    if [[ "$status" != "200" ]]; then
        error "Download failed for $label (HTTP ${status:-unknown}): $url"
        rm -f "$tmp"
        A11_ACTIVE_TMP=""
        return 1
    fi

    if ! validate_downloaded_payload "$tmp" "$dest" "$label"; then
        if [[ -e "$dest" ]]; then
            error "Left $dest untouched"
        fi
        rm -f "$tmp"
        A11_ACTIVE_TMP=""
        return 1
    fi

    # Keep an existing destination's permissions; mktemp creates 600, and curl -o
    # used to leave whatever the file already had.
    #
    # Two traps here, both found by review. GNU `stat -f` means --file-system and
    # takes no format, so it prints filesystem info to stdout AND exits 1 - put
    # BSD's form first and both outputs concatenate into $mode on Linux. GNU's
    # -c form is tried first for that reason. And BSD stat does not follow
    # symlinks without -L, so a symlinked destination yields the LINK's mode
    # (0755) and every such file came out world-executable.
    local mode=""
    if [[ -f "$dest" ]]; then
        mode="$(stat -L -c '%a' "$dest" 2>/dev/null || true)"
        [[ -n "$mode" ]] || mode="$(stat -L -f '%Lp' "$dest" 2>/dev/null || true)"
        # Anything that is not three or four octal digits came from a stat that
        # did not mean what we asked; fall back rather than chmod garbage.
        case "$mode" in
            [0-7][0-7][0-7]|[0-7][0-7][0-7][0-7]) ;;
            *) mode="" ;;
        esac
    fi
    if [[ -L "$dest" ]]; then
        # The link is replaced by a real file rather than written through, so a
        # download can never escape the project via a symlinked destination.
        warn "$dest was a symlink; replacing it with a regular file"
    fi
    chmod "${mode:-644}" "$tmp" 2>/dev/null || chmod 644 "$tmp"

    if ! mv "$tmp" "$dest"; then
        error "Could not write $label to $dest"
        rm -f "$tmp"
        A11_ACTIVE_TMP=""
        return 1
    fi
    A11_ACTIVE_TMP=""
    return 0
}
# --- A11-ISS-31 DOWNLOAD GUARD END -----------------------------------------

# Download agent file from GitHub
download_agent_from_github() {
    local agent_name="$1"
    local dest_file="$2"

    log "Downloading $agent_name from GitHub..."

    if fetch_url_to_file "$GITHUB_RAW_BASE/$agent_name.md" "$dest_file" "$agent_name.md"; then
        log "Downloaded: $agent_name"
        return 0
    fi
    error "Failed to download $agent_name from $GITHUB_RAW_BASE/$agent_name.md"
    return 1
}

# Download file from GitHub repository
download_file_from_github() {
    local relative_path="$1"
    local dest_file="$2"

    log "Downloading $relative_path from GitHub..."

    if fetch_url_to_file "$GITHUB_REPO_BASE/$relative_path" "$dest_file" "$relative_path"; then
        log "Downloaded: $relative_path"
        return 0
    fi
    error "Failed to download $relative_path from $GITHUB_REPO_BASE/$relative_path"
    return 1
}

# Check if we're running from a local repository or remote execution
detect_execution_mode() {
    # Check if we're running from within the actual git repository
    # This is the most reliable way to detect local vs remote execution
    if [[ -d "$PROJECT_ROOT/.git" && -f "$PROJECT_ROOT/README.md" && -d "$PROJECT_ROOT/.claude/agents" ]]; then
        # We're in the actual AGENT-11 repository
        echo "local"
    elif [[ -d "$PROJECT_ROOT/.git" && -f "$PROJECT_ROOT/README.md" && -d "$PROJECT_ROOT/project/agents/specialists" ]]; then
        # We're in the repository but using old structure
        echo "local"
    else
        # We're running via curl download or not in repository
        echo "remote"
    fi
}

# ---------- Sprint 5a: v5→v6 upgrade detection (T1) + subprocess invocation (T2) ----------

# Detect v5.x markers in the user's cwd. Mirrors migrate-v5-to-v6.sh's marker set.
# Returns 0 + prints markers when found, 1 + no output when clean.
# A11-ISS-21: a bare handoff-notes.md is NOT a v5 marker.
#
# It used to be treated as one, and the consequence was severe. `--upgrade` on an
# already-v6 repo would see the file, invoke migrate-v5-to-v6.sh, and that script
# DELETES handoff-notes.md and folds its contents into agent-context.md. Confirmed by
# dry run on 2026-08-04: it does not refuse an already-v6 project, it reports "v5 markers
# still present — completing the remaining migration steps" and proceeds.
#
# Two of T-245's seven in-scope repos tripped it, on genuine project content: Trader-7's
# handoff-notes.md is 426 tracked lines in a repo running live on Railway, and
# JamieWatters' is a session note written in June 2026, months after v6 shipped. The
# agent-11 repo itself trips it too. v6 uses handoff-notes.md as an ordinary working
# file, so its presence says nothing about which version is installed.
#
# The three STRUCTURAL markers below are different: each is a directory or file that
# only a v5 install creates and that v6 actively retired. One of those is required
# before the migration path is even considered. A lone handoff-notes.md is reported as
# an advisory by the caller, never as a trigger.
detect_v5_markers_in_cwd() {
    local structural=()
    [[ -d "$(pwd)/.mcp-profiles" ]] && structural+=(".mcp-profiles/")
    [[ -f "$(pwd)/mcp/dynamic-mcp.json" ]] && structural+=("mcp/dynamic-mcp.json")
    [[ -f "$(pwd)/templates/handoff-notes-template.md" ]] && structural+=("templates/handoff-notes-template.md")

    if [[ ${#structural[@]} -eq 0 ]]; then
        return 1
    fi

    # handoff-notes.md is listed only alongside a structural marker, where it really is
    # part of the v5 layout and the migration really should fold it.
    [[ -f "$(pwd)/handoff-notes.md" ]] && structural+=("handoff-notes.md")
    printf '%s\n' "${structural[@]}"
    return 0
}

# Locate migrate-v5-to-v6.sh: prefer a co-located copy (local clone), else fetch
# from main into a tempfile. Returns path on stdout, non-zero on failure.
find_or_fetch_migrate_script() {
    local execution_mode
    execution_mode=$(detect_execution_mode)

    if [[ "$execution_mode" == "local" ]]; then
        local local_path="$PROJECT_ROOT/project/deployment/scripts/migrate-v5-to-v6.sh"
        if [[ -f "$local_path" ]]; then
            echo "$local_path"
            return 0
        fi
    fi

    local tmp_script
    tmp_script="$(mktemp -t migrate-v5-to-v6.XXXXXX)" || return 1
    if download_file_from_github "project/deployment/scripts/migrate-v5-to-v6.sh" "$tmp_script"; then
        chmod +x "$tmp_script"
        echo "$tmp_script"
        return 0
    fi
    rm -f "$tmp_script"
    return 1
}

# Locate merge-settings.py for T3 settings.json merge. Same pattern as the
# migrate-script lookup. Returns path on stdout, non-zero on failure.
find_or_fetch_settings_merger() {
    local execution_mode
    execution_mode=$(detect_execution_mode)

    if [[ "$execution_mode" == "local" ]]; then
        local local_path="$PROJECT_ROOT/project/deployment/scripts/merge-settings.py"
        if [[ -f "$local_path" ]]; then
            echo "$local_path"
            return 0
        fi
    fi

    local tmp_script
    tmp_script="$(mktemp -t merge-settings.XXXXXX)" || return 1
    if download_file_from_github "project/deployment/scripts/merge-settings.py" "$tmp_script"; then
        echo "$tmp_script"
        return 0
    fi
    rm -f "$tmp_script"
    return 1
}

# Sprint 5a T8: print a high-level "what would happen" plan and exit 0.
# Triggered by --dry-run. Inspects the cwd for v5 markers, settings.json
# state, and execution mode, then itemises every step the install would take.
# No directories created, no files written, no subprocesses started.
print_dry_run_plan() {
    echo
    log "=== DRY RUN — would perform the following: ==="
    echo "  Target directory: $(pwd)"
    local execution_mode
    execution_mode=$(detect_execution_mode)
    echo "  Execution mode: $execution_mode"

    # T-245: a dry run that does not say what is installed now cannot tell you what
    # the upgrade would change. Report the stamp before and the version after.
    local stamp="$(pwd)/.claude/agent-11-version" current="none (pre-stamp install)"
    if [[ -f "$stamp" ]]; then
        current="$(grep -oE '"version"[^,]*' "$stamp" 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+|unknown' || echo unparseable)"
    fi
    echo "  Installed version: $current"
    echo "  Would write version: $(resolve_agent11_version)"
    echo "  Backups would go to: $BACKUP_DIR  ($BACKUP_LOCATION)"

    # A tracked-and-modified file under .claude/ is a local customisation this install
    # would overwrite. Untracked files there are install litter, not a conflict.
    if git -C "$(pwd)" rev-parse --git-dir >/dev/null 2>&1; then
        local branch tracked_mod
        branch="$(git -C "$(pwd)" rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)"
        tracked_mod="$(git -C "$(pwd)" status --porcelain -- .claude 2>/dev/null | grep -vE '^\?\?' || true)"
        echo "  Branch: $branch"
        if [[ -n "$tracked_mod" ]]; then
            echo "  BLOCKED — tracked-and-modified files under .claude/ would be overwritten:"
            printf '%s\n' "$tracked_mod" | sed 's/^/      /'
        else
            echo "  No tracked-and-modified files under .claude/ (untracked litter does not block)"
        fi
    fi
    echo

    # v5 detection
    local v5_markers
    if v5_markers=$(detect_v5_markers_in_cwd); then
        if $UPGRADE_MODE; then
            echo "  v5.x markers detected — would invoke migrate-v5-to-v6.sh:"
            echo "$v5_markers" | sed 's/^/    - /'
            echo "    Run \`bash migrate-v5-to-v6.sh --dry-run\` separately for migration plan."
        else
            echo "  v5.x markers detected — would EXIT 1 with upgrade instructions:"
            echo "$v5_markers" | sed 's/^/    - /'
            echo "    (re-run with --upgrade to proceed)"
            echo
            echo "DRY RUN COMPLETE — no changes were made."
            return 0
        fi
    else
        echo "  No v5.x markers — fresh install or already on v6"
        # A11-ISS-21: mentioned, never acted on. It is an ordinary v6 working file, and
        # treating it as a migration trigger would have deleted tracked project content.
        if [[ -f "$(pwd)/handoff-notes.md" ]]; then
            echo "    (handoff-notes.md is present. That is NOT a v5 marker on its own and"
            echo "     triggers nothing — v6 uses the file too. No migration will be invoked.)"
        fi
    fi
    echo

    # settings.json plan
    local dest="$(pwd)/.claude/settings.json"
    if [[ -f "$dest" ]]; then
        # A11-ISS-24. This used to guess the outcome by grepping the target for
        # '"hooks"' and ENABLE_TOOL_SEARCH. merge-settings.py's own contract is
        # "No-op only if ENABLE_TOOL_SEARCH is present AND hooks AND
        # permissions need no change" — so the guess tested two of three
        # conditions and reported "no-op" whenever permissions were the thing
        # that differed. Every repo in the 2026-08-04 fleet survey carried 0 of
        # the 4 gate deny rules, meaning permissions needed changing in all of
        # them and the plan told the approver the opposite: it promised a
        # no-op while the real run would add deny rules and wire in two
        # PreToolUse hooks the repo had never had.
        #
        # So ask the merger instead of re-deriving its condition. It runs
        # against a COPY in a temp directory, so the repo is untouched and the
        # answer comes from the implementation that will actually do the work.
        local merge_verdict="" trial_dir="" merger_path="" template_path=""
        if command -v python3 >/dev/null 2>&1 \
           && merger_path="$(find_or_fetch_settings_merger 2>/dev/null)" \
           && template_path="$(find_or_fetch_settings_template 2>/dev/null)"; then
            trial_dir="$(mktemp -d 2>/dev/null || true)"
            if [[ -n "$trial_dir" ]]; then
                cp "$dest" "$trial_dir/settings.json" 2>/dev/null || true
                merge_verdict="$(python3 "$merger_path" "$trial_dir/settings.json" "$template_path" 2>/dev/null | tail -1)"
                rm -rf "$trial_dir" 2>/dev/null || true
            fi
        fi

        if [[ "$merge_verdict" == "NOOP_ALREADY_V6" ]]; then
            echo "  settings.json: already current — the merger reports no change needed"
            echo "    (verified by running merge-settings.py against a temp copy, not inferred)"
            echo "    (a backup is still written: install_settings_template copies the file"
            echo "     before it decides whether the merge changes anything)"
        elif [[ "$merge_verdict" == "MERGED" ]]; then
            echo "  settings.json: WOULD BE CHANGED — the merger reports a real merge"
            echo "    (verified by running merge-settings.py against a temp copy, not inferred)"
            echo "    User values win on every conflict. Expect the shipped read-only gate"
            echo "    deny rules to be added, and any missing shipped PreToolUse hooks"
            echo "    (gate-guard.sh, destructive-guard.sh) to be wired in — these"
            echo "    intercept Bash calls, so review them before upgrading."
            echo "    Backup written outside the repo, under \$AGENT11_INSTALL_BACKUPS."
        elif command -v python3 >/dev/null 2>&1; then
            echo "  settings.json: existing file detected — would merge v6 template"
            echo "    (user values win on conflict; backup written outside the repo, under \$AGENT11_INSTALL_BACKUPS)"
        else
            echo "  settings.json: existing file detected, python3 NOT available"
            echo "    Would write template as .claude/settings.json.new (manual merge required)"
        fi
    else
        echo "  settings.json: no existing file — would deploy template verbatim"
    fi
    echo

    # Split by location, because "would deploy" without saying WHERE is how a reader
    # ends up surprised by seven new directories at their project root.
    echo "  Would write inside .claude/ :"
    echo "    - .claude/agents/            11 specialist agents"
    echo "    - .claude/commands/          slash commands"
    echo "    - .claude/CLAUDE.md          library instructions"
    echo "    - .claude/constitution/      Karpathy constitution"
    echo "    - .claude/skills/            SaaS skills"
    echo "    - .claude/hooks/             gate-guard.sh, destructive-guard.sh"
    echo "    - .claude/scripts/           mission-state.py"
    echo "    - .claude/data/              command support data"
    echo "    - .claude/settings.json      merged, user values win"
    echo "    - .claude/agent-11-version   the version stamp"
    echo
    echo "  Would write at the PROJECT ROOT, outside .claude/ :"
    echo "    - missions/                  mission files"
    echo "    - templates/                 utility templates"
    echo "    - field-manual/              documentation"
    echo "    - schemas/                   foundation schemas"
    echo "    - gates/                     run-gates.py, gate-types.yaml, templates/"
    echo "    - stack-profiles/            stack profiles"
    echo "    - docs/                      MCP + upgrade guides"
    echo "    - .mcp.json.template, .env.mcp.template, mcp-setup.sh"
    echo "    (an existing .env.mcp is never overwritten — it holds your API keys)"
    echo

    # A11-ISS-23. The real pipeline ends in setup_mcp_configuration(), which the dry run
    # never reaches — it short-circuits long before. That function does far more than
    # copy files when .env.mcp is present, and none of it is otherwise visible here.
    # A dry run that silently omits the most invasive step is worse than no dry run.
    echo "  MCP configuration:"
    if [[ -f "$(pwd)/.env.mcp" ]]; then
        if $WITH_MCP; then
            echo "    !! --with-mcp GIVEN and .env.mcp is present: mcp-setup.sh WOULD RUN."
            echo "         - 'npm install -g' for up to 7 packages (GLOBAL, outside this project)"
            echo "         - 'claude mcp remove <name> -s project' for 10 servers, then re-add"
            echo "         - writes .mcp-status.md at the project root"
        else
            echo "    .env.mcp is present, but mcp-setup.sh would NOT run (A11-ISS-23:"
            echo "    it is opt-in since 2026-08-05; pass --with-mcp to run it)."
            echo "    Your .env.mcp and your registered MCP servers are left alone."
        fi
        echo "    ./mcp-setup.sh itself IS overwritten with a freshly downloaded copy."
        echo "    An existing .mcp.json is preserved."
    else
        echo "    No .env.mcp — mcp-setup.sh would be deployed but NOT executed."
        echo "    Templates (.mcp.json.template, .env.mcp.template) would be written."
    fi
    echo
    echo "DRY RUN COMPLETE — no changes were made. Re-run without --dry-run to install."
    return 0
}

# Locate library/settings.json.template. Returns path on stdout, non-zero on
# failure. In remote mode, downloads to a tempfile.
find_or_fetch_settings_template() {
    local execution_mode
    execution_mode=$(detect_execution_mode)

    if [[ "$execution_mode" == "local" ]]; then
        local local_path="$PROJECT_ROOT/library/settings.json.template"
        if [[ -f "$local_path" ]]; then
            echo "$local_path"
            return 0
        fi
    fi

    local tmp_template
    tmp_template="$(mktemp -t settings-template.XXXXXX.json)" || return 1
    if download_file_from_github "library/settings.json.template" "$tmp_template"; then
        echo "$tmp_template"
        return 0
    fi
    rm -f "$tmp_template"
    return 1
}

# Run v5→v6 migration as subprocess. Working-directory contract: caller is in
# target repo root. Explicit $? check — set -e does not propagate cleanly through
# function returns when the caller checks the return value with `if`.
run_v5_to_v6_migration() {
    local script_path
    if ! script_path="$(find_or_fetch_migrate_script)"; then
        error "Could not locate or download migrate-v5-to-v6.sh"
        error "Run the migration manually first, then re-run install:"
        error "  bash <(curl -sSL https://raw.githubusercontent.com/$GITHUB_REPO/$GITHUB_BRANCH/project/deployment/scripts/migrate-v5-to-v6.sh)"
        return 1
    fi

    log "Running v5.x → v6.0 migration..."
    log "  Script: $script_path"
    log "  Target: $(pwd)"
    echo

    # AGENT11_INSTALL_INVOKED tells migrate-v5-to-v6.sh to suppress its
    # ENABLE_TOOL_SEARCH manual-merge advisory — install.sh runs the surgical
    # merger right after, so the advisory was a false alarm in chained mode.
    AGENT11_INSTALL_INVOKED=1 bash "$script_path" --yes
    local rc=$?

    if [[ $rc -ne 0 ]]; then
        error "Migration failed (exit code $rc). See messages above for details."
        error "Aborting install. Re-run after resolving migration issues."
        return $rc
    fi

    success "Migration complete. Continuing with v6.0 install..."
    echo
    return 0
}

# Validate environment before installation
validate_environment() {
    log "Validating installation environment..."
    
    # Show project context and installation location
    echo
    echo -e "${GREEN}✓ Project Context Detected${NC}"
    echo "  Directory: $(pwd)"
    echo "  Indicators: ${DETECTED_INDICATORS[*]}"
    echo "  Installation: $AGENTS_DIR"
    echo
    
    # Check if we can write to the current directory
    local current_dir="$(pwd)"
    if [[ ! -w "$current_dir" ]]; then
        fatal "Cannot write to current directory: $current_dir"
    fi
    
    # Detect execution mode
    local execution_mode
    execution_mode=$(detect_execution_mode)
    log "Execution mode: $execution_mode"
    
    if [[ "$execution_mode" == "local" ]]; then
        # Check if source agents exist in library location first (project/agents/specialists)
        if [[ -d "$PROJECT_ROOT/project/agents/specialists" ]]; then
            log "Using agents from: $PROJECT_ROOT/project/agents/specialists"
        elif [[ -d "$PROJECT_ROOT/.claude/agents" ]]; then
            log "Using agents from: $PROJECT_ROOT/.claude/agents"
        else
            fatal "Local agent source directories not found"
        fi
    else
        # Remote execution - check network tools availability
        if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
            fatal "Remote installation requires curl or wget to download agents"
        fi
        log "Remote installation mode - will download agents from GitHub"
        
        # Check if agents already exist in project and warn user
        if [[ -d "$AGENTS_DIR" ]]; then
            local existing_count=$(find "$AGENTS_DIR" -name "*.md" -type f | wc -l)
            if [[ $existing_count -gt 0 ]]; then
                warn "Found $existing_count existing agents in project: $AGENTS_DIR"
                warn "These will be backed up and replaced with latest versions from GitHub"
            fi
        fi
    fi
    
    # Check platform compatibility
    local platform
    platform=$(detect_platform)
    if [[ "$platform" == "unknown" ]]; then
        warn "Unknown platform detected. Installation may not work correctly."
    else
        log "Platform detected: $platform"
    fi
    
    # Check available disk space (require at least 10MB)
    local available_space
    if command -v df >/dev/null 2>&1; then
        available_space=$(df "$HOME" | awk 'NR==2 {print $4}')
        if [[ "$available_space" -lt 10000 ]]; then
            warn "Low disk space detected. Continuing anyway..."
        fi
    fi
    
    success "Environment validation passed"
}

# Create backup of existing agents and mission system
create_backup() {
    local has_content=false
    
    log "Creating backup of existing installation..."
    
    # Create backup directory
    mkdir -p "$BACKUP_PATH"
    
    # Backup agents if they exist
    if [[ -d "$AGENTS_DIR" ]]; then
        mkdir -p "$BACKUP_PATH/agents"
        if cp -r "$AGENTS_DIR"/* "$BACKUP_PATH/agents/" 2>/dev/null; then
            log "Backed up existing agents"
            has_content=true
        fi
    fi
    
    # Backup commands if they exist
    if [[ -d "$COMMANDS_DIR" ]]; then
        mkdir -p "$BACKUP_PATH/commands"
        if cp -r "$COMMANDS_DIR"/* "$BACKUP_PATH/commands/" 2>/dev/null; then
            log "Backed up existing commands"
            has_content=true
        fi
    fi
    
    # Backup missions if they exist
    if [[ -d "$MISSIONS_DIR" ]]; then
        mkdir -p "$BACKUP_PATH/missions"
        if cp -r "$MISSIONS_DIR"/* "$BACKUP_PATH/missions/" 2>/dev/null; then
            log "Backed up existing missions"
            has_content=true
        fi
    fi
    
    # Backup templates if they exist
    if [[ -d "$TEMPLATES_DIR" ]]; then
        mkdir -p "$BACKUP_PATH/templates"
        if cp -r "$TEMPLATES_DIR"/* "$BACKUP_PATH/templates/" 2>/dev/null; then
            log "Backed up existing templates"
            has_content=true
        fi
    fi
    
    # Backup field manual if it exists
    if [[ -d "$FIELD_MANUAL_DIR" ]]; then
        mkdir -p "$BACKUP_PATH/field-manual"
        if cp -r "$FIELD_MANUAL_DIR"/* "$BACKUP_PATH/field-manual/" 2>/dev/null; then
            log "Backed up existing field manual"
            has_content=true
        fi
    fi
    
    if [[ "$has_content" == "true" ]]; then
        success "Backup created: $BACKUP_PATH"
        echo "$BACKUP_PATH" > "$BACKUP_DIR/latest"
    else
        log "No existing installation found. Skipping backup."
        # Remove empty backup directory
        rmdir "$BACKUP_PATH" 2>/dev/null || true
    fi
}

# Validate agent file format
validate_agent_file() {
    local agent_file="$1"
    
    # Check if file exists
    if [[ ! -f "$agent_file" ]]; then
        error "Agent file not found: $agent_file"
        return 1
    fi
    
    # Check YAML header exists
    if ! head -n 10 "$agent_file" | grep -q "^---$"; then
        error "Invalid agent file format (missing YAML header): $agent_file"
        return 1
    fi
    
    # Check required YAML fields
    # Extract only first 30 lines to avoid matching --- separators later in file
    local yaml_section
    yaml_section=$(head -n 30 "$agent_file" | sed -n '/^---$/,/^---$/p')
    
    if ! echo "$yaml_section" | grep -q "^name:"; then
        error "Missing 'name' field in YAML header: $agent_file"
        return 1
    fi
    
    if ! echo "$yaml_section" | grep -q "^description:"; then
        error "Missing 'description' field in YAML header: $agent_file"
        return 1
    fi
    
    return 0
}

# Install individual agent
install_agent() {
    local agent_name="$1"
    local dest_file="$AGENTS_DIR/$agent_name.md"
    local execution_mode
    execution_mode=$(detect_execution_mode)
    
    # Create destination directory if it doesn't exist
    mkdir -p "$AGENTS_DIR"
    
    if [[ "$execution_mode" == "local" ]]; then
        # Try library location first (project/agents/specialists), then fall back to working squad
        local source_file
        if [[ -f "$PROJECT_ROOT/project/agents/specialists/$agent_name.md" ]]; then
            source_file="$PROJECT_ROOT/project/agents/specialists/$agent_name.md"
        elif [[ -f "$PROJECT_ROOT/.claude/agents/$agent_name.md" ]]; then
            source_file="$PROJECT_ROOT/.claude/agents/$agent_name.md"
        else
            error "Agent source file not found: $agent_name"
            return 1
        fi
        
        # Validate source file
        if ! validate_agent_file "$source_file"; then
            return 1
        fi
        
        # Check if source and destination are the same (prevent copy to self)
        if [[ "$(realpath "$source_file" 2>/dev/null || echo "$source_file")" == "$(realpath "$dest_file" 2>/dev/null || echo "$dest_file")" ]]; then
            log "Agent already in correct location: $agent_name"
            return 0
        fi
        
        # Copy agent file
        if cp "$source_file" "$dest_file"; then
            log "Installed: $agent_name"
            return 0
        else
            error "Failed to install: $agent_name"
            return 1
        fi
    else
        # Remote execution - download from GitHub
        if download_agent_from_github "$agent_name" "$dest_file"; then
            # Validate downloaded file
            if validate_agent_file "$dest_file"; then
                log "Installed: $agent_name"
                return 0
            else
                error "Downloaded agent file is invalid: $agent_name"
                rm -f "$dest_file"
                return 1
            fi
        else
            return 1
        fi
    fi
}

# Install CLAUDE.md file to .claude/ directory
# Deploys AGENT-11 library instructions to .claude/CLAUDE.md
# User's root /CLAUDE.md (personal preferences) is NEVER touched
install_claude_md() {
    local execution_mode
    execution_mode=$(detect_execution_mode)

    log "Installing AGENT-11 CLAUDE.md to .claude/ directory..."

    # Ensure .claude directory exists
    mkdir -p "$CLAUDE_DIR"

    local dest_file="$CLAUDE_DIR/CLAUDE.md"
    # T-245: outside the repo, alongside every other install backup.
    mkdir -p "$BACKUP_PATH" 2>/dev/null || true
    local backup_file="$BACKUP_PATH/CLAUDE.md.backup-$(date +%Y%m%d_%H%M%S)"

    # Backup existing .claude/CLAUDE.md if present
    if [[ -f "$dest_file" ]]; then
        if cp "$dest_file" "$backup_file"; then
            log "Backed up existing .claude/CLAUDE.md"
        fi
    fi

    # Deploy library/CLAUDE.md to .claude/CLAUDE.md
    if [[ "$execution_mode" == "local" ]]; then
        local source_file="$PROJECT_ROOT/library/CLAUDE.md"
        if [[ -f "$source_file" ]]; then
            if cp "$source_file" "$dest_file"; then
                success "AGENT-11 instructions installed: .claude/CLAUDE.md"
            else
                error "Failed to install AGENT-11 CLAUDE.md"
                return 1
            fi
        else
            error "library/CLAUDE.md not found in AGENT-11 repository"
            return 1
        fi
    else
        # Remote installation - download from GitHub
        if download_file_from_github "library/CLAUDE.md" "$dest_file"; then
            success "AGENT-11 instructions downloaded: .claude/CLAUDE.md"
        else
            error "Failed to download AGENT-11 CLAUDE.md from GitHub"
            return 1
        fi
    fi

    # Inform user about architecture
    echo ""
    echo -e "${BLUE}📁 CLAUDE.md Architecture:${NC}"
    echo "  • .claude/CLAUDE.md  - AGENT-11 library instructions (just installed)"
    echo "  • /CLAUDE.md (root)  - Your personal preferences (untouched)"
    echo ""
    echo -e "${YELLOW}Your root CLAUDE.md is safe and will never be overwritten.${NC}"
    echo ""

    return 0
}

# Install settings.json template with default hooks (Sprint 4d, hardened in 5a-T3)
# Deploys library/settings.json.template to .claude/settings.json
# - Fresh install (no existing file): copy verbatim
# - Existing settings.json: surgical merge via merge-settings.py (Python 3)
#     - User values win on conflict; template only fills gaps
#     - Backup → merge → re-validate → auto-restore on failure
#     - Python 3 missing: write template as settings.json.new with manual instructions
# Always backs up existing file before any change. Tracks SETTINGS_HAS_V6_FEATURES
# global flag for the post-install summary (T4 — fix the lying summary).
install_settings_template() {
    local execution_mode
    execution_mode=$(detect_execution_mode)

    log "Installing settings.json template (hooks)..."

    mkdir -p "$CLAUDE_DIR"

    # A11-ISS-4: deploy the read-only gate guard script the PreToolUse hook
    # calls (.claude/hooks/gate-guard.sh). Deployed in both fresh and merge
    # paths; if it fails the hook fails open (allows), so non-fatal.
    mkdir -p "$CLAUDE_DIR/hooks"
    local guard_dest="$CLAUDE_DIR/hooks/gate-guard.sh"
    if [[ "$execution_mode" == "local" ]] && [[ -f "$PROJECT_ROOT/library/hooks/gate-guard.sh" ]]; then
        if cp "$PROJECT_ROOT/library/hooks/gate-guard.sh" "$guard_dest"; then
            chmod +x "$guard_dest"
            log "Installed gate guard hook: .claude/hooks/gate-guard.sh"
        else
            warn "Could not install gate-guard.sh - Bash gate guard inactive (Edit/Write deny rules still apply)"
        fi
    else
        if download_file_from_github "library/hooks/gate-guard.sh" "$guard_dest"; then
            chmod +x "$guard_dest"
            log "Installed gate guard hook: .claude/hooks/gate-guard.sh"
        else
            warn "Could not download gate-guard.sh - Bash gate guard inactive (Edit/Write deny rules still apply)"
        fi
    fi

    # A11-ISS-22: deploy the destructive-command guard the PreToolUse hook
    # calls (.claude/hooks/destructive-guard.sh). This replaces a `prompt`-type
    # hook whose `if` glob failed open on multi-line and redirecting commands,
    # handing benign Bash to a model that then refused it without the operator
    # ever seeing why. Same fail-open-on-error contract as the gate guard.
    local destructive_dest="$CLAUDE_DIR/hooks/destructive-guard.sh"
    if [[ "$execution_mode" == "local" ]] && [[ -f "$PROJECT_ROOT/library/hooks/destructive-guard.sh" ]]; then
        if cp "$PROJECT_ROOT/library/hooks/destructive-guard.sh" "$destructive_dest"; then
            chmod +x "$destructive_dest"
            log "Installed destructive-command guard: .claude/hooks/destructive-guard.sh"
        else
            warn "Could not install destructive-guard.sh - destructive commands are not gated"
        fi
    else
        if download_file_from_github "library/hooks/destructive-guard.sh" "$destructive_dest"; then
            chmod +x "$destructive_dest"
            log "Installed destructive-command guard: .claude/hooks/destructive-guard.sh"
        else
            warn "Could not download destructive-guard.sh - destructive commands are not gated"
        fi
    fi

    # T-363: deploy the coordinator's on-disk phase counters
    # (.claude/scripts/mission-state.py). Without it the meta-loop falls back to
    # narrating cycles_this_phase and clean_rounds, which is what T-363 exists to
    # stop, so a failure here is a warning rather than fatal — the coordinator is
    # instructed to say out loud that it is narrating rather than reading.
    mkdir -p "$CLAUDE_DIR/scripts"
    local state_dest="$CLAUDE_DIR/scripts/mission-state.py"
    if [[ "$execution_mode" == "local" ]] && [[ -f "$PROJECT_ROOT/library/scripts/mission-state.py" ]]; then
        if cp "$PROJECT_ROOT/library/scripts/mission-state.py" "$state_dest"; then
            chmod +x "$state_dest"
            log "Installed mission state helper: .claude/scripts/mission-state.py"
        else
            warn "Could not install mission-state.py - coordinator phase counters will be narrated, not read"
        fi
    else
        if download_file_from_github "library/scripts/mission-state.py" "$state_dest"; then
            chmod +x "$state_dest"
            log "Installed mission state helper: .claude/scripts/mission-state.py"
        else
            warn "Could not download mission-state.py - coordinator phase counters will be narrated, not read"
        fi
    fi

    local dest_file="$CLAUDE_DIR/settings.json"
    # T-245: outside the repo, alongside every other install backup.
    mkdir -p "$BACKUP_PATH" 2>/dev/null || true
    local backup_file="$BACKUP_PATH/settings.json.backup-$(date +%Y%m%d_%H%M%S)"
    local source_path="library/settings.json.template"

    # ===== Existing settings.json: T3 surgical merge =====
    if [[ -f "$dest_file" ]]; then
        # Always backup before any change.
        cp "$dest_file" "$backup_file"
        log "Backed up existing .claude/settings.json to $(basename "$backup_file")"

        # Python 3 fallback: write .new alongside, leave original intact.
        if ! command -v python3 >/dev/null 2>&1; then
            warn "python3 not found — cannot perform automatic settings.json merge"
            local new_file="$dest_file.new"
            local template_path
            if template_path="$(find_or_fetch_settings_template)"; then
                cp "$template_path" "$new_file"
                warn "Wrote v6 template to $new_file"
                warn "Manually merge the contents of settings.json.new into settings.json"
                warn "  to enable v6 features (ENABLE_TOOL_SEARCH + advisory hooks)."
                warn "Reference: docs/UPGRADE.md"
            else
                warn "Could not retrieve settings.json template — install python3 and re-run."
            fi
            SETTINGS_HAS_V6_FEATURES=false
            return 0
        fi

        # Resolve helper + template paths.
        local merger_path template_path
        if ! merger_path="$(find_or_fetch_settings_merger)"; then
            warn "Could not locate merge-settings.py — leaving settings.json unchanged"
            SETTINGS_HAS_V6_FEATURES=false
            return 0
        fi
        if ! template_path="$(find_or_fetch_settings_template)"; then
            warn "Could not locate settings.json.template — leaving settings.json unchanged"
            SETTINGS_HAS_V6_FEATURES=false
            return 0
        fi

        # Run merger; capture stdout (status line) and exit code separately.
        local merger_out merger_rc
        merger_out="$(python3 "$merger_path" "$dest_file" "$template_path" 2>&1)"
        merger_rc=$?

        if [[ $merger_rc -ne 0 ]]; then
            warn "settings.json merge failed (exit $merger_rc):"
            echo "$merger_out" | sed 's/^/  /'
            # The merger's atomic write means dest_file is unchanged on failure,
            # but restore from backup defensively in case anything slipped through.
            cp "$backup_file" "$dest_file"
            warn "settings.json restored from backup; v6 features not enabled."
            SETTINGS_HAS_V6_FEATURES=false
            return 0
        fi

        # Defense in depth: re-validate the merged JSON. The merger validates
        # internally, but we re-check from bash to catch any post-write surprise.
        if ! python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$dest_file" >/dev/null 2>&1; then
            error "Merged settings.json is invalid JSON — auto-restoring from backup"
            cp "$backup_file" "$dest_file"
            SETTINGS_HAS_V6_FEATURES=false
            return 0
        fi

        case "$merger_out" in
            *NOOP_ALREADY_V6*)
                log "Existing settings.json already on v6 (ENABLE_TOOL_SEARCH + hooks present)"
                SETTINGS_HAS_V6_FEATURES=true
                ;;
            *MERGED*)
                success "Merged v6 template into existing settings.json (user values preserved)"
                SETTINGS_HAS_V6_FEATURES=true
                ;;
            *)
                warn "settings.json merger returned unexpected output: $merger_out"
                SETTINGS_HAS_V6_FEATURES=false
                ;;
        esac
        return 0
    fi
    # ===== End T3 merge path =====

    # Fresh install - deploy template verbatim
    if [[ "$execution_mode" == "local" ]]; then
        local source_file="$PROJECT_ROOT/$source_path"
        if [[ -f "$source_file" ]]; then
            if cp "$source_file" "$dest_file"; then
                success "Default hooks installed: .claude/settings.json"
                SETTINGS_HAS_V6_FEATURES=true
            else
                warn "Failed to install settings.json - hooks not deployed"
                SETTINGS_HAS_V6_FEATURES=false
            fi
        else
            warn "library/settings.json.template not found - hooks not deployed"
            SETTINGS_HAS_V6_FEATURES=false
        fi
    else
        if download_file_from_github "$source_path" "$dest_file"; then
            success "Default hooks downloaded: .claude/settings.json"
            SETTINGS_HAS_V6_FEATURES=true
        else
            warn "Failed to download settings.json template - hooks not deployed"
            SETTINGS_HAS_V6_FEATURES=false
        fi
    fi

    return 0
}

# Install Karpathy constitution to .claude/constitution/ (Sprint 4d)
install_constitution() {
    local execution_mode
    execution_mode=$(detect_execution_mode)

    log "Installing Karpathy constitution..."

    local dest_dir="$CLAUDE_DIR/constitution"
    local dest_file="$dest_dir/karpathy-constitution.md"
    local source_path="project/constitution/karpathy-constitution.md"

    mkdir -p "$dest_dir"

    if [[ "$execution_mode" == "local" ]]; then
        local source_file="$PROJECT_ROOT/$source_path"
        if [[ -f "$source_file" ]]; then
            if cp "$source_file" "$dest_file"; then
                success "Constitution installed: .claude/constitution/karpathy-constitution.md"
            else
                warn "Failed to install Karpathy constitution"
            fi
        else
            warn "Karpathy constitution not found at $source_path"
        fi
    else
        if download_file_from_github "$source_path" "$dest_file"; then
            success "Constitution downloaded"
        else
            warn "Failed to download Karpathy constitution"
        fi
    fi

    return 0
}

# Install mission system files (missions, commands, templates)
install_mission_system() {
    local execution_mode
    execution_mode=$(detect_execution_mode)
    
    log "Installing mission system files..."
    
    # Define mission files to install
    local mission_files=("${A11_MISSION_FILES[@]}")
    
    # Define command files to install
    local command_files=("${A11_COMMAND_FILES[@]}")
    
    # Define template files to install
    local template_files=("${A11_TEMPLATE_FILES[@]}")
    
    # Define field manual files to install
    local field_manual_files=("${A11_FIELD_MANUAL_FILES[@]}")
    
    local total_files=$((${#mission_files[@]} + ${#command_files[@]} + ${#template_files[@]} + ${#field_manual_files[@]}))
    local current=0
    local failed_files=()
    
    # Install mission files
    for mission_file in "${mission_files[@]}"; do
        ((current++))
        show_progress "$current" "$total_files" "Installing $(basename "$mission_file")"
        
        local dest_file="$MISSIONS_DIR/$(basename "$mission_file")"
        
        if [[ "$execution_mode" == "local" ]]; then
            local source_file="$PROJECT_ROOT/$mission_file"
            if [[ -f "$source_file" ]]; then
                mkdir -p "$MISSIONS_DIR"
                if cp "$source_file" "$dest_file"; then
                    log "Installed: $(basename "$mission_file")"
                else
                    failed_files+=("$mission_file")
                fi
            else
                failed_files+=("$mission_file")
            fi
        else
            # Remote installation
            if download_file_from_github "$mission_file" "$dest_file"; then
                log "Installed: $(basename "$mission_file")"
            else
                failed_files+=("$mission_file")
            fi
        fi
        
        sleep 0.1
    done
    
    # Install command files
    for command_file in "${command_files[@]}"; do
        ((current++))
        show_progress "$current" "$total_files" "Installing $(basename "$command_file")"

        local dest_file="$COMMANDS_DIR/$(basename "$command_file")"

        if [[ "$execution_mode" == "local" ]]; then
            local source_file="$PROJECT_ROOT/$command_file"
            if [[ -f "$source_file" ]]; then
                mkdir -p "$COMMANDS_DIR"
                if cp "$source_file" "$dest_file"; then
                    log "Installed: $(basename "$command_file")"
                else
                    failed_files+=("$command_file")
                fi
            else
                failed_files+=("$command_file")
            fi
        else
            # Remote installation
            if download_file_from_github "$command_file" "$dest_file"; then
                log "Installed: $(basename "$command_file")"
            else
                failed_files+=("$command_file")
            fi
        fi

        sleep 0.1
    done

    # Install command support data — the default voice guide shared by /dailyreport
    # and /blog. Both commands are Claude-native and read this file directly.
    # Lives in .claude/data/ (outside .claude/commands/) so the Claude Code harness
    # doesn't auto-index it as a skill in the command palette.
    log "Installing command support data..."
    mkdir -p "$CLAUDE_DIR/data"

    if [[ "$execution_mode" == "local" ]]; then
        if [[ -f "$PROJECT_ROOT/project/data/voice-guide-default.md" ]]; then
            if cp "$PROJECT_ROOT/project/data/voice-guide-default.md" "$CLAUDE_DIR/data/"; then
                log "Installed: voice-guide-default.md → .claude/data/"
            else
                warn "Could not install voice-guide-default.md"
            fi
        fi
    else
        # Remote installation
        if download_file_from_github "project/data/voice-guide-default.md" "$CLAUDE_DIR/data/voice-guide-default.md"; then
            log "Installed: voice-guide-default.md → .claude/data/"
        else
            warn "Could not download voice-guide-default.md"
        fi
    fi
    
    # Install template files
    for template_file in "${template_files[@]}"; do
        ((current++))
        show_progress "$current" "$total_files" "Installing $(basename "$template_file")"
        
        local dest_file="$TEMPLATES_DIR/$(basename "$template_file")"
        
        if [[ "$execution_mode" == "local" ]]; then
            local source_file="$PROJECT_ROOT/$template_file"
            if [[ -f "$source_file" ]]; then
                mkdir -p "$TEMPLATES_DIR"
                if cp "$source_file" "$dest_file"; then
                    log "Installed: $(basename "$template_file")"
                else
                    failed_files+=("$template_file")
                fi
            else
                failed_files+=("$template_file")
            fi
        else
            # Remote installation
            if download_file_from_github "$template_file" "$dest_file"; then
                log "Installed: $(basename "$template_file")"
            else
                failed_files+=("$template_file")
            fi
        fi
        
        sleep 0.1
    done
    
    # Install field manual files
    local FIELD_MANUAL_DIR="$(pwd)/field-manual"
    for field_manual_file in "${field_manual_files[@]}"; do
        ((current++))
        show_progress "$current" "$total_files" "Installing $(basename "$field_manual_file")"
        
        local dest_file="$FIELD_MANUAL_DIR/$(basename "$field_manual_file")"
        
        if [[ "$execution_mode" == "local" ]]; then
            local source_file="$PROJECT_ROOT/$field_manual_file"
            if [[ -f "$source_file" ]]; then
                mkdir -p "$FIELD_MANUAL_DIR"
                if cp "$source_file" "$dest_file"; then
                    log "Installed: $(basename "$field_manual_file")"
                else
                    failed_files+=("$field_manual_file")
                fi
            else
                failed_files+=("$field_manual_file")
            fi
        else
            # Remote installation
            if download_file_from_github "$field_manual_file" "$dest_file"; then
                log "Installed: $(basename "$field_manual_file")"
            else
                failed_files+=("$field_manual_file")
            fi
        fi
        
        sleep 0.1
    done

    # Sprint 9: Install skills to .claude/skills/
    log "Installing SaaS skills library..."
    local SKILLS_DIR="$CLAUDE_DIR/skills"
    mkdir -p "$SKILLS_DIR"

    local skill_dirs=("${A11_SKILL_DIRS[@]}")
    for skill in "${skill_dirs[@]}"; do
        if [[ "$execution_mode" == "local" ]]; then
            if [[ -d "$PROJECT_ROOT/project/skills/$skill" ]]; then
                mkdir -p "$SKILLS_DIR/$skill"
                if cp -r "$PROJECT_ROOT/project/skills/$skill"/* "$SKILLS_DIR/$skill/" 2>/dev/null; then
                    log "Installed skill: $skill"
                else
                    warn "Could not install skill: $skill"
                fi
            fi
        else
            # Remote: Download SKILL.md for each skill
            mkdir -p "$SKILLS_DIR/$skill"
            if download_file_from_github "project/skills/$skill/SKILL.md" "$SKILLS_DIR/$skill/SKILL.md"; then
                log "Installed skill: $skill"
                # Stack-specific references for skills that ship them.
                # Not every skill has references/; failure here is non-fatal.
                if a11_list_contains "$skill" "${A11_SKILLS_WITH_REFERENCES[@]}"; then
                    mkdir -p "$SKILLS_DIR/$skill/references"
                    for ref in "${A11_SKILL_REFERENCES[@]}"; do
                        download_file_from_github "project/skills/$skill/references/$ref" "$SKILLS_DIR/$skill/references/$ref" 2>/dev/null \
                            && log "Installed reference: $skill/references/$ref" \
                            || warn "Could not download reference: $skill/references/$ref"
                    done
                fi
            else
                warn "Could not download skill: $skill"
            fi
        fi
    done

    # Sprint 9: Install schemas
    log "Installing schemas..."
    local SCHEMAS_DIR="$(pwd)/schemas"
    mkdir -p "$SCHEMAS_DIR"

    local schema_files=("${A11_SCHEMA_FILES[@]}")
    for schema in "${schema_files[@]}"; do
        if [[ "$execution_mode" == "local" ]]; then
            if [[ -f "$PROJECT_ROOT/project/schemas/$schema" ]]; then
                if cp "$PROJECT_ROOT/project/schemas/$schema" "$SCHEMAS_DIR/$schema"; then
                    log "Installed schema: $schema"
                fi
            fi
        else
            if download_file_from_github "project/schemas/$schema" "$SCHEMAS_DIR/$schema"; then
                log "Installed schema: $schema"
            fi
        fi
    done

    # Sprint 9: Install quality gates
    log "Installing quality gates..."
    local GATES_DIR="$(pwd)/gates"
    mkdir -p "$GATES_DIR/templates"

    if [[ "$execution_mode" == "local" ]]; then
        if [[ -f "$PROJECT_ROOT/project/gates/run-gates.py" ]]; then
            cp "$PROJECT_ROOT/project/gates/run-gates.py" "$GATES_DIR/"
            chmod +x "$GATES_DIR/run-gates.py"
            log "Installed: run-gates.py"
        fi
        if [[ -f "$PROJECT_ROOT/project/gates/gate-types.yaml" ]]; then
            cp "$PROJECT_ROOT/project/gates/gate-types.yaml" "$GATES_DIR/"
            log "Installed: gate-types.yaml"
        fi
        if [[ -f "$PROJECT_ROOT/project/gates/README.md" ]]; then
            cp "$PROJECT_ROOT/project/gates/README.md" "$GATES_DIR/"
            log "Installed: gates README.md"
        fi
        # Gate templates
        for template in "${A11_GATE_TEMPLATES[@]}"; do
            if [[ -f "$PROJECT_ROOT/project/gates/templates/$template" ]]; then
                cp "$PROJECT_ROOT/project/gates/templates/$template" "$GATES_DIR/templates/"
                log "Installed gate template: $template"
            fi
        done
    else
        download_file_from_github "project/gates/run-gates.py" "$GATES_DIR/run-gates.py" && chmod +x "$GATES_DIR/run-gates.py"
        download_file_from_github "project/gates/gate-types.yaml" "$GATES_DIR/gate-types.yaml"
        download_file_from_github "project/gates/README.md" "$GATES_DIR/README.md"
        for template in "${A11_GATE_TEMPLATES[@]}"; do
            download_file_from_github "project/gates/templates/$template" "$GATES_DIR/templates/$template"
        done
    fi

    # Sprint 9: Install stack profiles
    log "Installing stack profiles..."
    local STACK_PROFILES_DIR="$(pwd)/stack-profiles"
    mkdir -p "$STACK_PROFILES_DIR"

    local stack_profiles=("${A11_STACK_PROFILES[@]}")
    for profile in "${stack_profiles[@]}"; do
        if [[ "$execution_mode" == "local" ]]; then
            if [[ -f "$PROJECT_ROOT/templates/stack-profiles/$profile" ]]; then
                if cp "$PROJECT_ROOT/templates/stack-profiles/$profile" "$STACK_PROFILES_DIR/$profile"; then
                    log "Installed stack profile: $profile"
                fi
            fi
        else
            if download_file_from_github "templates/stack-profiles/$profile" "$STACK_PROFILES_DIR/$profile"; then
                log "Installed stack profile: $profile"
            fi
        fi
    done

    success "Sprint 9 components installed successfully!"

    if [[ ${#failed_files[@]} -eq 0 ]]; then
        success "Mission system installed successfully!"
        return 0
    else
        error "Failed to install mission system files: ${failed_files[*]}"
        return 1
    fi
}

# Install the Agent-11 squad (all 11 specialists)
install_squad() {
    local squad_agents=("${SQUAD_FULL[@]}")
    local total=${#squad_agents[@]}
    local current=0
    local failed_agents=()

    log "Installing Agent-11 squad ($total agents)..."

    for agent in "${squad_agents[@]}"; do
        ((current++))
        show_progress "$current" "$total" "Installing $agent"

        if ! install_agent "$agent"; then
            failed_agents+=("$agent")
        fi

        # Small delay to show progress clearly
        sleep 0.1
    done

    if [[ ${#failed_agents[@]} -eq 0 ]]; then
        success "All Agent-11 specialists installed successfully!"
        return 0
    else
        error "Failed to install: ${failed_agents[*]}"
        return 1
    fi
}

# ---------- T-245: the version stamp ----------
#
# Until this existed there was no way to read what version of AGENT-11 a repo
# carried, before or after an upgrade. A survey of all 25 registered repos on
# 2026-08-04 found not one version marker anywhere, which made "rolled v6.2.0
# to the fleet" a claim with no oracle. This is that oracle.
#
# The version is read from the CHANGELOG's newest released heading rather than
# a VERSION file, so there is one source of truth and no second thing to keep
# in step. `## [Unreleased]` is skipped by construction: the pattern requires
# digits, so an unreleased section cannot be mistaken for a release.
resolve_agent11_version() {
    local changelog_raw="" version=""

    if [[ -f "$PROJECT_ROOT/CHANGELOG.md" ]]; then
        changelog_raw="$(cat "$PROJECT_ROOT/CHANGELOG.md" 2>/dev/null || true)"
    else
        if command -v curl >/dev/null 2>&1; then
            changelog_raw="$(curl -fsSL "$GITHUB_REPO_BASE/CHANGELOG.md" 2>/dev/null || true)"
        elif command -v wget >/dev/null 2>&1; then
            changelog_raw="$(wget -qO- "$GITHUB_REPO_BASE/CHANGELOG.md" 2>/dev/null || true)"
        fi
    fi

    # `|| true` is load-bearing: the script runs under `set -euo pipefail`, so
    # a grep that matches nothing would otherwise abort the whole install at
    # the assignment. A missing version must degrade to "unknown", never take
    # the installation down with it.
    version="$(printf '%s\n' "$changelog_raw" \
        | grep -oE '^#{1,3} *\[[0-9]+\.[0-9]+\.[0-9]+\]' \
        | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' \
        | head -1 || true)"

    # If the CHANGELOG has real content under [Unreleased], the newest released
    # heading UNDER-describes what is being installed. Stamping a plain "6.2.0"
    # would make a repo upgraded today indistinguishable from one installed when
    # 6.2.0 actually shipped, though the content differs materially — today's
    # library carries the gate guard, mission-state.py, the routing fix and four
    # validators on top of it. The suffix says so in the field people actually read,
    # rather than leaving source_commit as the only honest identifier.
    local unreleased=""
    unreleased="$(printf '%s\n' "$changelog_raw" \
        | awk '/^#{1,3} *\[[Uu]nreleased\]/{f=1; next} /^#{1,3} *\[[0-9]/{f=0} f' \
        | grep -cE '^[-*] ' || true)"
    if [[ -n "$version" && "${unreleased:-0}" -gt 0 ]]; then
        printf '%s' "$version+unreleased"
        return 0
    fi

    # "unknown" is deliberate: a stamp that lies about its version is worse
    # than one that admits it could not tell.
    printf '%s' "${version:-unknown}"
}

write_version_stamp() {
    local mode="install"
    $UPGRADE_MODE && mode="upgrade"

    local version commit
    version="$(resolve_agent11_version)"
    commit="$(git -C "$PROJECT_ROOT" rev-parse --short HEAD 2>/dev/null || echo unknown)"

    mkdir -p "$CLAUDE_DIR"
    cat > "$CLAUDE_DIR/agent-11-version" <<STAMP
{
  "version": "$version",
  "installed_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "mode": "$mode",
  "source_repo": "$GITHUB_REPO",
  "source_branch": "$GITHUB_BRANCH",
  "source_commit": "$commit",
  "backups": "$BACKUP_LOCATION:$BACKUP_DIR"
}
STAMP

    if [[ "$version" == "unknown" ]]; then
        warn "Version stamp written, but the version could not be resolved from the CHANGELOG."
    else
        success "Version stamp written: v$version → .claude/agent-11-version"
    fi

    # Explicit: this sits in the install pipeline's && chain, and a stray
    # non-zero here would trigger a full rollback of a good installation.
    return 0
}

# Verify installation
verify_installation() {
    local squad_agents=("${SQUAD_FULL[@]}")

    log "Verifying installation..."
    
    local missing_items=()
    
    # Verify agents
    for agent in "${squad_agents[@]}"; do
        local agent_file="$AGENTS_DIR/$agent.md"
        if [[ ! -f "$agent_file" ]]; then
            missing_items+=("agent:$agent")
        elif ! validate_agent_file "$agent_file"; then
            missing_items+=("agent:$agent")
        fi
    done
    
    # Verify mission system files
    # Every file the installer deploys to missions/. Kept in step with the
    # mission_files array above by scripts/validate-deployment-coverage.sh —
    # this list had silently drifted to 14 of 20, so a failed copy of the
    # missing six still reported a clean install.
    local mission_files=("README.md" "connect-mcp.md" "dev-alignment.md" "dev-setup.md" "library.md" "mission-architecture.md" "mission-build.md" "mission-deploy.md" "mission-document.md" "mission-fix.md" "mission-integrate.md" "mission-migrate.md" "mission-mvp.md" "mission-optimize.md" "mission-product-description.md" "mission-refactor.md" "mission-release.md" "mission-security.md" "operation-genesis.md" "operation-recon.md")
    for mission_file in "${mission_files[@]}"; do
        if [[ ! -f "$MISSIONS_DIR/$mission_file" ]]; then
            missing_items+=("mission:$mission_file")
        fi
    done
    
    # Verify command files
    if [[ ! -f "$COMMANDS_DIR/coord.md" ]]; then
        missing_items+=("command:coord.md")
    fi
    if [[ ! -f "$COMMANDS_DIR/meeting.md" ]]; then
        missing_items+=("command:meeting.md")
    fi
    if [[ ! -f "$COMMANDS_DIR/report.md" ]]; then
        missing_items+=("command:report.md")
    fi
    if [[ ! -f "$COMMANDS_DIR/pmd.md" ]]; then
        missing_items+=("command:pmd.md")
    fi
    if [[ ! -f "$COMMANDS_DIR/dailyreport.md" ]]; then
        missing_items+=("command:dailyreport.md")
    fi
    if [[ ! -f "$COMMANDS_DIR/planarchive.md" ]]; then
        missing_items+=("command:planarchive.md")
    fi
    
    # Verify template files
    local template_files=("mission-template.md" "agent-creation-mastery.md" "architecture-template.md" "product-description-template.md" "agent-context-template.md" "evidence-repository-template.md")
    for template_file in "${template_files[@]}"; do
        if [[ ! -f "$TEMPLATES_DIR/$template_file" ]]; then
            missing_items+=("template:$template_file")
        fi
    done
    
    # Verify field manual files
    if [[ ! -f "$FIELD_MANUAL_DIR/architecture-sop.md" ]]; then
        missing_items+=("field-manual:architecture-sop.md")
    fi
    
    # Verify CLAUDE.md installed to .claude/ directory
    if [[ ! -f "$CLAUDE_DIR/CLAUDE.md" ]]; then
        missing_items+=("system:.claude/CLAUDE.md")
    fi
    
    if [[ ${#missing_items[@]} -eq 0 ]]; then
        success "Installation verification passed!"
        log "✓ Agents: ${#squad_agents[@]} installed"
        log "✓ Mission system: Complete with kickoff missions"
        log "✓ Commands: /coord and /meeting available"
        log "✓ Templates: Including architecture.md template"
        log "✓ Field Manual: Architecture SOP included"
        return 0
    else
        error "Verification failed. Missing items: ${missing_items[*]}"
        return 1
    fi
}

# Rollback installation
rollback_installation() {
    log "Rolling back installation..."
    
    if [[ -f "$BACKUP_DIR/latest" ]]; then
        local latest_backup
        latest_backup=$(cat "$BACKUP_DIR/latest")
        
        if [[ -d "$latest_backup" ]]; then
            # Remove current installation
            rm -rf "$AGENTS_DIR" "$COMMANDS_DIR" "$MISSIONS_DIR" "$TEMPLATES_DIR" "$FIELD_MANUAL_DIR"
            
            # Restore from backup
            if [[ -d "$latest_backup/agents" ]]; then
                mkdir -p "$AGENTS_DIR"
                cp -r "$latest_backup/agents"/* "$AGENTS_DIR/" 2>/dev/null || true
                log "Restored agents from backup"
            fi
            
            if [[ -d "$latest_backup/commands" ]]; then
                mkdir -p "$COMMANDS_DIR"
                cp -r "$latest_backup/commands"/* "$COMMANDS_DIR/" 2>/dev/null || true
                log "Restored commands from backup"
            fi
            
            if [[ -d "$latest_backup/missions" ]]; then
                mkdir -p "$MISSIONS_DIR"
                cp -r "$latest_backup/missions"/* "$MISSIONS_DIR/" 2>/dev/null || true
                log "Restored missions from backup"
            fi
            
            if [[ -d "$latest_backup/templates" ]]; then
                mkdir -p "$TEMPLATES_DIR"
                cp -r "$latest_backup/templates"/* "$TEMPLATES_DIR/" 2>/dev/null || true
                log "Restored templates from backup"
            fi
            
            if [[ -d "$latest_backup/field-manual" ]]; then
                mkdir -p "$FIELD_MANUAL_DIR"
                cp -r "$latest_backup/field-manual"/* "$FIELD_MANUAL_DIR/" 2>/dev/null || true
                log "Restored field manual from backup"
            fi
            
            success "Rollback completed. Restored from: $latest_backup"
        else
            warn "Backup directory not found. Manual cleanup may be required."
        fi
    else
        # No backup exists, just clean up
        rm -rf "$AGENTS_DIR" "$COMMANDS_DIR" "$MISSIONS_DIR" "$TEMPLATES_DIR" "$FIELD_MANUAL_DIR"
        success "Clean rollback completed (no previous installation to restore)"
    fi
}

# Install MCP profiles and documentation
install_mcp_system() {
    local execution_mode
    execution_mode=$(detect_execution_mode)

    log "Installing MCP system..."

    local TARGET_DIR="$(pwd)"

    # Sprint 4f: profile-based MCP loading (.mcp-profiles/) is RETIRED.
    # Tools defer-load via ENABLE_TOOL_SEARCH=auto (deployed in
    # install_settings_template) and are discovered at runtime via
    # tool_search_tool_regex_20251119. No profile directory needed.

    # Copy MCP documentation
    if [[ "$execution_mode" == "local" ]]; then
        if [[ -d "$PROJECT_ROOT/docs" ]]; then
            log "Installing MCP documentation from local repository..."
            mkdir -p "$TARGET_DIR/docs"

            if [[ -f "$PROJECT_ROOT/docs/MCP-GUIDE.md" ]]; then
                cp "$PROJECT_ROOT/docs/MCP-GUIDE.md" "$TARGET_DIR/docs/"
                cp "$PROJECT_ROOT/docs/MCP-PROFILES.md" "$TARGET_DIR/docs/"
                cp "$PROJECT_ROOT/docs/MCP-TROUBLESHOOTING.md" "$TARGET_DIR/docs/"
                # NEW: Install dynamic MCP migration guide
                if [[ -f "$PROJECT_ROOT/docs/MCP-MIGRATION-GUIDE.md" ]]; then
                    cp "$PROJECT_ROOT/docs/MCP-MIGRATION-GUIDE.md" "$TARGET_DIR/docs/"
                fi
                # Sprint 5a T7: v5→v6 upgrade guide + rollback instructions
                if [[ -f "$PROJECT_ROOT/docs/UPGRADE.md" ]]; then
                    cp "$PROJECT_ROOT/docs/UPGRADE.md" "$TARGET_DIR/docs/"
                fi
                success "MCP documentation installed"
            fi
        fi
    else
        # Remote installation - download documentation
        log "Downloading MCP documentation from GitHub..."
        mkdir -p "$TARGET_DIR/docs"

        if download_file_from_github "docs/MCP-GUIDE.md" "$TARGET_DIR/docs/MCP-GUIDE.md"; then
            log "Downloaded: MCP-GUIDE.md"
        fi
        if download_file_from_github "docs/MCP-PROFILES.md" "$TARGET_DIR/docs/MCP-PROFILES.md"; then
            log "Downloaded: MCP-PROFILES.md"
        fi
        if download_file_from_github "docs/MCP-TROUBLESHOOTING.md" "$TARGET_DIR/docs/MCP-TROUBLESHOOTING.md"; then
            log "Downloaded: MCP-TROUBLESHOOTING.md"
        fi
        # NEW: Download dynamic MCP migration guide
        if download_file_from_github "docs/MCP-MIGRATION-GUIDE.md" "$TARGET_DIR/docs/MCP-MIGRATION-GUIDE.md"; then
            log "Downloaded: MCP-MIGRATION-GUIDE.md"
        fi
        # Sprint 5a T7: v5→v6 upgrade guide + rollback instructions
        if download_file_from_github "docs/UPGRADE.md" "$TARGET_DIR/docs/UPGRADE.md"; then
            log "Downloaded: UPGRADE.md"
        fi
    fi

    # Sprint 4f: Tool deferring is enabled via ENABLE_TOOL_SEARCH=auto in
    # .claude/settings.json (deployed by install_settings_template).
    # The previous Sprint 11 dynamic-mcp.json was based on the Claude API schema,
    # not Claude Code, and is no longer deployed. Archived to
    # .archive/2026-04-26-pre-4f/.

    # Copy .env.mcp.template (NEVER copy .env.mcp to protect user's API keys)
    # SECURITY: We only deploy the template, never the actual .env.mcp file
    if [[ "$execution_mode" == "local" ]]; then
        if [[ -f "$PROJECT_ROOT/.env.mcp.template" ]]; then
            # Always update template to latest version
            cp "$PROJECT_ROOT/.env.mcp.template" "$TARGET_DIR/"
            success "MCP environment template installed"

            # Warn if .env.mcp exists to prevent accidental overwrites
            if [[ -f "$TARGET_DIR/.env.mcp" ]]; then
                log "Existing .env.mcp preserved (contains your API keys)"
            else
                log "Next step: Copy .env.mcp.template to .env.mcp and add your API keys"
            fi
        fi
    else
        if download_file_from_github ".env.mcp.template" "$TARGET_DIR/.env.mcp.template"; then
            success "MCP environment template downloaded"

            # Provide guidance for .env.mcp setup
            if [[ -f "$TARGET_DIR/.env.mcp" ]]; then
                log "Existing .env.mcp preserved (contains your API keys)"
            else
                log "Next step: Copy .env.mcp.template to .env.mcp and add your API keys"
            fi
        fi
    fi

    return 0  # Always succeed - MCPs are enhancement
}

# A11-ISS-3 / A11-ISS-31: MCP downloads use the same hardened primitive as
# everything else - temp file, HTTP 200 required, payload validated for its
# file type, destination untouched on any failure.
download_mcp_file() {
    local url="$1" dest="$2"
    fetch_url_to_file "$url" "$dest" "$(basename "$dest")"
}

# Setup MCP configuration
setup_mcp_configuration() {
    log "Setting up MCP integration..."
    MCP_TEMPLATE_MISSING=false

    # Use current directory as target for MCP files
    local TARGET_DIR="$(pwd)"

    # Always download MCP files to ensure latest version
    log "Downloading MCP configuration files..."

    # A11-ISS-31: there is no .mcp.json to download. It is gitignored upstream,
    # so https://raw.githubusercontent.com/.../main/.mcp.json has always 404ed,
    # and before A11-ISS-3 the 404 BODY was written here - 16 repos ended up with
    # a committed 14-byte ".mcp.json" reading "404: Not Found", which then blocked
    # the template fallback below because the file existed. A download that is
    # expected to fail is not a download; it is noise that teaches everyone to
    # ignore failures. Removed. .mcp.json is created from the validated template
    # below, and an existing one is never touched (A11-ISS-23: it holds the
    # user's MCP server registry).
    # A11-ISS-31: "existing" is not the same as "good". The repos damaged by the
    # original bug hold a 14-byte .mcp.json reading "404: Not Found", and simply
    # preserving it re-runs the damage forever while calling the junk "your MCP
    # server registry". An existing file that does not parse as JSON is backed up
    # and rebuilt from the template below.
    MCP_JSON_INVALID=false
    MCP_REGISTRY_BLOCKED=false
    if [[ -d "$TARGET_DIR/.mcp.json" ]]; then
        # `cp template .mcp.json` would copy INTO the directory and leave the
        # project with no registry and no complaint.
        error ".mcp.json exists as a DIRECTORY - cannot create the MCP registry"
        error "  Move or remove $TARGET_DIR/.mcp.json and re-run the installer"
        MCP_REGISTRY_BLOCKED=true
    elif [[ -L "$TARGET_DIR/.mcp.json" ]]; then
        # A symlink is deliberate configuration, and `cp` writes THROUGH it -
        # to wherever it points, including outside the project. A dangling link
        # is worse: -f is false, so without this branch the installer would take
        # the "there is no .mcp.json" path and create the file at the link's
        # target, outside the repo, while reporting success.
        if payload_is_valid_json "$TARGET_DIR/.mcp.json" 2>/dev/null; then
            log "Existing .mcp.json is a symlink to valid JSON - left alone"
        else
            error ".mcp.json is a symlink to $(readlink "$TARGET_DIR/.mcp.json"), which is missing or not valid JSON"
            error "  Refusing to write through it. Remove the symlink and re-run the installer"
            MCP_REGISTRY_BLOCKED=true
        fi
    elif [[ -f "$TARGET_DIR/.mcp.json" ]]; then
        if [[ ! -r "$TARGET_DIR/.mcp.json" ]]; then
            # Unreadable is not the same as invalid. Never replace a file whose
            # contents nobody has seen.
            error "Existing .mcp.json is not readable - refusing to touch it"
            error "  Fix its permissions or move it, then re-run the installer"
            MCP_REGISTRY_BLOCKED=true
        elif payload_is_valid_json "$TARGET_DIR/.mcp.json"; then
            log "Existing .mcp.json preserved (your MCP server registry)"
        else
            MCP_JSON_INVALID=true
            warn "Existing .mcp.json is not valid JSON (first bytes: $(head -c 40 "$TARGET_DIR/.mcp.json" | tr -d '\n'))"
            warn "It will be backed up and rebuilt from .mcp.json.template"
        fi
    fi

    # Download .env.mcp.template
    if download_mcp_file "$GITHUB_REPO_BASE/.env.mcp.template" "$TARGET_DIR/.env.mcp.template"; then
        success "Downloaded .env.mcp.template"
    else
        warn "Could not download .env.mcp.template - skipped (existing file, if any, untouched)"
    fi

    # Download .mcp.json.template with correct package names
    if download_mcp_file "$GITHUB_REPO_BASE/project/deployment/templates/.mcp.json.template" "$TARGET_DIR/.mcp.json.template"; then
        success "Downloaded .mcp.json.template (correct package names)"
        # Create .mcp.json from the template when there is none, or when the one
        # that is there is junk (A11-ISS-31). A valid registry is never touched.
        if $MCP_REGISTRY_BLOCKED; then
            : # already reported above - never cp into a directory or through a symlink
        elif [[ ! -e "$TARGET_DIR/.mcp.json" ]]; then
            cp "$TARGET_DIR/.mcp.json.template" "$TARGET_DIR/.mcp.json"
            success "Created .mcp.json with correct MCP package names"
        elif $MCP_JSON_INVALID; then
            # Never overwrite an existing backup: the timestamp is fixed for the
            # whole run, so a second repair in the same second would eat the first.
            local backup="$TARGET_DIR/.mcp.json.invalid-$TIMESTAMP"
            local n=1
            while [[ -e "$backup" ]]; do
                backup="$TARGET_DIR/.mcp.json.invalid-$TIMESTAMP-$n"
                n=$((n + 1))
            done
            if mv "$TARGET_DIR/.mcp.json" "$backup"; then
                cp "$TARGET_DIR/.mcp.json.template" "$TARGET_DIR/.mcp.json"
                success "Repaired .mcp.json from the template (old file kept as $(basename "$backup"))"
            else
                error "Could not move the invalid .mcp.json aside - leaving it in place"
                MCP_REGISTRY_BLOCKED=true
            fi
        fi
    else
        # A11-ISS-31: this is the file the whole issue was about. If it does not
        # arrive, the project has no MCP configuration at all - say so in plain
        # words rather than leaving a one-word warning nobody reads.
        error "No MCP configuration installed: .mcp.json.template could not be downloaded"
        error "  Existing files were left untouched. Re-run the installer, or copy the template by hand from:"
        error "  $GITHUB_REPO_BASE/project/deployment/templates/.mcp.json.template"
        MCP_TEMPLATE_MISSING=true
    fi

    # Download mcp-setup-v2.sh (the fixed version)
    if download_mcp_file "$GITHUB_REPO_BASE/project/deployment/scripts/mcp-setup-v2.sh" "$TARGET_DIR/mcp-setup.sh"; then
        chmod +x "$TARGET_DIR/mcp-setup.sh"
        success "Downloaded mcp-setup.sh (v2 with correct package names)"
    else
        # Fallback to original if v2 doesn't exist
        if download_mcp_file "$GITHUB_REPO_BASE/project/deployment/scripts/mcp-setup.sh" "$TARGET_DIR/mcp-setup.sh"; then
            chmod +x "$TARGET_DIR/mcp-setup.sh"
            warn "Downloaded original mcp-setup.sh (may have issues)"
        else
            warn "Could not download mcp-setup.sh - skipped"
        fi
    fi
    
    # Provide instructions for MCP setup
    echo ""
    echo "📌 MCP Setup Instructions:"
    if [[ -f "$TARGET_DIR/.env.mcp" ]]; then
        # A11-ISS-23: this used to run automatically whenever .env.mcp existed.
        # mcp-setup.sh is not a file-copying step — it runs `npm install -g` for up
        # to seven packages, which writes outside the project entirely, and
        # `claude mcp remove -s project` for ten servers before re-adding whichever
        # it has credentials for. An install command should not reach outside the
        # project or tear down existing registrations because a file happened to be
        # present. It is opt-in now, and the invitation says what it would do.
        if $WITH_MCP; then
            if [[ -f "$TARGET_DIR/mcp-setup.sh" ]]; then
                log "--with-mcp given - running MCP configuration..."
                if "$TARGET_DIR/mcp-setup.sh"; then
                    success "MCP servers configured - restart Claude Code to activate"
                else
                    warn "Some MCPs could not be configured - check your API keys"
                fi
            else
                warn "mcp-setup.sh not found - skipping MCP configuration"
            fi
        else
            success "Found .env.mcp - MCP servers left untouched"
            echo "  To (re)register MCP servers, run it deliberately:"
            echo "     ./mcp-setup.sh          (or re-run the installer with --with-mcp)"
            echo "  It installs npm packages globally and re-registers project MCP servers."
        fi
    else
        echo "  To enable MCP integration (optional but recommended):"
        echo "  1. Copy template: cp .env.mcp.template .env.mcp"
        echo "  2. Edit .env.mcp and add your API keys"
        echo "  3. Run setup: ./mcp-setup.sh"
        echo ""
        echo "  MCPs provide GitHub, web scraping, database, and other integrations."
    fi
    
    return 0  # Always succeed - MCPs are enhancement, not requirement
}

# Display post-installation instructions
show_post_install_instructions() {
    local squad_agents=("${SQUAD_FULL[@]}")

    echo
    echo "🎉 AGENT-11 Squad Deployed Successfully! (11 specialists)"
    echo
    echo -e "${GREEN}📁 Project-Local Installation${NC}"
    echo "  Location: $AGENTS_DIR"
    echo "  Project: $(pwd)"
    echo "  Indicators: ${DETECTED_INDICATORS[*]}"
    echo
    echo -e "${BLUE}🎯 Your squad is deployed to THIS project only${NC}"
    echo "  • Agents will only work when you're in this directory"
    echo "  • Each project gets its own specialized squad"
    echo "  • No global installation means clean, isolated deployments"
    echo
    echo "🚀 Quick Start Commands:"
    echo
    echo "   # Option 1: Mission Command (Recommended)"
    echo "   /coord build requirements.md           # Build feature from requirements"
    echo "   /coord fix bug-report.md              # Fix a bug quickly"
    echo "   /coord mvp product-vision.md          # Create an MVP from concept"
    echo "   /coord                                # Interactive mission selection"
    echo
    echo "   # Option 2: Direct Agent Commands"
    echo "   @coordinator Plan and orchestrate multi-agent workflows"
    echo "   @strategist Create user stories for complex features"
    echo "   @architect Design system architecture"
    echo "   @developer Implement features with full-stack expertise"
    
    echo -e "${BLUE}📚 Next Steps${NC}"
    echo "  • Your agents and mission system are ready to use"
    echo "  • Try the /coord command for systematic workflows"
    echo "  • Explore missions in the /missions directory"
    echo "  • Create custom missions using /templates"
    echo "  • Documentation: https://github.com/TheWayWithin/agent-11"
    echo

    echo -e "${BLUE}🔧 MCP Configured!${NC}"
    # T4: tell the truth about whether v6 features actually landed in settings.json.
    if [[ "${SETTINGS_HAS_V6_FEATURES:-false}" == "true" ]]; then
        echo "  ✓ Tool deferring enabled (ENABLE_TOOL_SEARCH=auto in .claude/settings.json)"
    else
        echo -e "  ${YELLOW}⚠ Tool deferring NOT enabled${NC} — settings.json was preserved without v6 changes."
        echo "    See the settings.json backup under \$AGENT11_INSTALL_BACKUPS and merge manually."
        echo "    Reference: docs/UPGRADE.md"
        echo "    Roll back: bash <(curl -sSL https://raw.githubusercontent.com/$GITHUB_REPO/$GITHUB_BRANCH/project/deployment/scripts/restore-pre-upgrade.sh) --list"
    fi
    echo "  ✓ MCP documentation in docs/"
    echo "  ✓ Environment template: .env.mcp.template"
    # A11-ISS-31: never let a missing MCP config hide behind a success banner.
    if [[ "${MCP_TEMPLATE_MISSING:-false}" == "true" ]]; then
        echo -e "  ${RED}✗ .mcp.json.template MISSING${NC} — the download failed, so this project has NO MCP config."
        echo "    Nothing was overwritten. Re-run the installer once you have network access."
    fi
    if [[ "${MCP_REGISTRY_BLOCKED:-false}" == "true" ]]; then
        echo -e "  ${RED}✗ .mcp.json NOT written${NC} — an existing .mcp.json is a directory, a symlink, or unreadable."
        echo "    Nothing was overwritten. See the error above, clear it, and re-run the installer."
    fi
    echo
    echo "  📝 Setup MCP servers in 2 steps:"
    echo "     1. cp .env.mcp.template .env.mcp"
    echo "     2. Edit .env.mcp with your API keys"
    echo "     3. Restart Claude Code"
    echo
    echo "  Tools defer-load by default. Specialists discover them at runtime"
    echo "  via tool_search_tool_regex_20251119 — no profile switching."
    echo
    echo "  📖 Documentation: docs/MCP-GUIDE.md"
    echo
    
    if [[ -d "$BACKUP_PATH" ]]; then
        echo -e "${YELLOW}💾 Backup Information${NC}"
        echo "  Previous agents backed up to: $BACKUP_PATH"
        echo
    fi
    
    echo -e "${GREEN}✨ Your elite squad and mission system deployed successfully!${NC}"
    echo "🎖️ Mission Command: Use /coord for systematic multi-agent workflows"
    echo "Need help? Deploy @support for customer success assistance!"
}

# Main installation function
main() {
    UPGRADE_MODE=false
    DRY_RUN=false
    NON_INTERACTIVE=false
    WITH_MCP=false
    SETTINGS_HAS_V6_FEATURES=false  # set by install_settings_template
    local legacy_arg=""

    # Parse args: flags + optional legacy squad-type positional.
    for arg in "$@"; do
        case "$arg" in
            --upgrade)
                UPGRADE_MODE=true
                ;;
            --dry-run)
                DRY_RUN=true
                ;;
            --non-interactive|--batch-safe)
                NON_INTERACTIVE=true
                ;;
            --with-mcp)
                WITH_MCP=true
                ;;
            --print-manifest)
                # A11-ISS-31: emit every repo-relative path this installer can
                # fetch, so project/deployment/tests/test-installer-downloads.sh
                # can prove each URL still resolves before a release.
                print_download_manifest
                exit 0
                ;;
            --help|-h)
                cat <<HELP
Usage: $0 [flags] [core|full|minimal (deprecated)]

Flags:
  --upgrade            Migrate v5.x install to v6.0 before deploying
  --dry-run            Print the plan, make zero changes, exit 0
  --non-interactive    Promise no prompts; fail fast on conditions that
  (or --batch-safe)    would require human input. (Composable with the others.)
  --with-mcp           Run mcp-setup.sh after installing. OFF by default: it
                       installs npm packages GLOBALLY and re-registers MCP
                       servers, which is not something an install should do
                       without being asked (A11-ISS-23).
  --print-manifest     List every repo path the installer downloads, then exit.
                       Used by project/deployment/tests/ to verify each URL.
  --help, -h           Show this help

Examples:
  bash $0                            Fresh install on a v6 / greenfield repo
  bash $0 --upgrade                  Migrate v5.x then install v6.0
  bash $0 --dry-run                  Show what would happen without changing anything
  bash $0 --upgrade --dry-run        Preview a v5→v6 upgrade run
  bash $0 --upgrade --non-interactive  Bulk-mode: never prompts, exits non-zero on input demand

Exit codes:
  0  Installed.
  1  Failed; rolled back to the previous state.
  2  Squad and mission system installed, but .mcp.json.template could not be
     downloaded, so the project has NO MCP configuration. Nothing was
     overwritten. Re-run when the network is available (A11-ISS-31).
HELP
                exit 0
                ;;
            -*)
                error "Unknown flag: $arg"
                error "Run $0 --help for usage."
                exit 1
                ;;
            *)
                if [[ -z "$legacy_arg" ]]; then
                    legacy_arg="$arg"
                else
                    error "Unexpected argument: $arg"
                    exit 1
                fi
                ;;
        esac
    done

    echo "🚁 AGENT-11 Deployment System"
    echo "=============================="
    echo

    # Handle legacy squad-selection arguments.
    # core/full/minimal are accepted but deprecated — install always deploys all 11 agents.
    case "$legacy_arg" in
        ""|"full")
            # No arg, or the (still-valid) 'full'. No message needed.
            ;;
        "core"|"minimal")
            echo -e "${YELLOW}Note: squad selection ('$legacy_arg') is deprecated.${NC}"
            echo -e "${YELLOW}AGENT-11 now always installs all 11 specialists (~6KB, lazy-loaded).${NC}"
            echo
            ;;
        *)
            echo "Usage: $0 [--upgrade] [core|full|minimal (all deprecated — always installs all 11)]"
            exit 1
            ;;
    esac

    # Sprint 5a T8: --dry-run short-circuits before any work. Print plan and exit.
    if $DRY_RUN; then
        print_dry_run_plan
        exit 0
    fi

    # ----- Sprint 5a T1: v5.x → v6.0 upgrade detection -----
    local v5_markers
    if v5_markers=$(detect_v5_markers_in_cwd); then
        if $UPGRADE_MODE; then
            log "v5.x install detected. Running migration before deploying v6.0..."
            log "v5 markers found:"
            echo "$v5_markers" | sed 's/^/  - /'
            echo
            if ! run_v5_to_v6_migration; then
                fatal "v5→v6 migration failed; install aborted."
            fi
        else
            warn "v5.x install detected. AGENT-11 v6.0 has retired several v5 components."
            warn "v5 markers found:"
            echo "$v5_markers" | sed 's/^/  - /'
            echo
            warn "Re-run with --upgrade to migrate before installing v6.0:"
            warn "  bash $0 --upgrade"
            echo
            warn "Preview the plan first with --dry-run:"
            warn "  bash $0 --upgrade --dry-run"
            echo
            warn "Full upgrade guide: docs/UPGRADE.md"
            warn "  https://github.com/$GITHUB_REPO/blob/$GITHUB_BRANCH/docs/UPGRADE.md"
            exit 1
        fi
    fi
    # ----- end T1 -----

    log "Installing Agent-11 squad (${#SQUAD_FULL[@]} specialists)"
    echo

    # Installation pipeline with rollback on failure
    {
        validate_environment &&
        create_backup &&
        install_squad &&
        install_claude_md &&
        install_constitution &&
        install_settings_template &&
        install_mission_system &&
        install_mcp_system &&
        verify_installation &&
        write_version_stamp &&
        setup_mcp_configuration
    } || {
        error "Installation failed. Initiating rollback..."
        rollback_installation
        fatal "Installation aborted. System restored to previous state."
    }

    # Show success message and instructions
    show_post_install_instructions

    # A11-ISS-31: exit code must not claim success the terminal contradicts. The
    # squad and mission system are installed either way, so this is not a hard
    # failure (1) or a rollback - it is a distinct code that says "installed, but
    # you have no MCP configuration". A human reads the red line in the banner; a
    # fleet script, CI job or && chain only ever reads this.
    if [[ "${MCP_TEMPLATE_MISSING:-false}" == "true" ]]; then
        error "Exiting 2: install completed but .mcp.json.template could not be fetched"
        return 2
    fi
    if [[ "${MCP_REGISTRY_BLOCKED:-false}" == "true" ]]; then
        error "Exiting 2: install completed but .mcp.json could not be written (see the message above)"
        return 2
    fi
}

# Handle script interruption
trap 'error "Installation interrupted. Run script again to retry."; exit 130' INT TERM

# Run main function with all arguments
main "$@"