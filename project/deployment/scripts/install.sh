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
        BACKUP_DIR="$CLAUDE_DIR/backups/agent-11"
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

# Detect project context and require project-local installation
if ! detect_project_context; then
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

validate_installation_paths

# Prevent concurrent installations
LOCKDIR="/tmp/agent11-install.lock"
if ! mkdir "$LOCKDIR" 2>/dev/null; then
    fatal "Another AGENT-11 installation is already running. If this is a stale lock, remove: $LOCKDIR"
fi
trap 'rmdir "$LOCKDIR" 2>/dev/null' EXIT

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
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

# Download agent file from GitHub
download_agent_from_github() {
    local agent_name="$1"
    local dest_file="$2"
    local url="$GITHUB_RAW_BASE/$agent_name.md"
    
    log "Downloading $agent_name from GitHub..."
    
    if command -v curl >/dev/null 2>&1; then
        if curl -fsSL "$url" -o "$dest_file"; then
            log "Downloaded: $agent_name"
            return 0
        else
            error "Failed to download $agent_name from $url"
            return 1
        fi
    elif command -v wget >/dev/null 2>&1; then
        if wget -q "$url" -O "$dest_file"; then
            log "Downloaded: $agent_name"
            return 0
        else
            error "Failed to download $agent_name from $url"
            return 1
        fi
    else
        error "Neither curl nor wget available for downloading agents"
        return 1
    fi
}

# Download file from GitHub repository
download_file_from_github() {
    local relative_path="$1"
    local dest_file="$2"
    local url="$GITHUB_REPO_BASE/$relative_path"
    
    log "Downloading $relative_path from GitHub..."
    
    # Create destination directory if it doesn't exist
    mkdir -p "$(dirname "$dest_file")"
    
    if command -v curl >/dev/null 2>&1; then
        if curl -fsSL "$url" -o "$dest_file"; then
            log "Downloaded: $relative_path"
            return 0
        else
            error "Failed to download $relative_path from $url"
            return 1
        fi
    elif command -v wget >/dev/null 2>&1; then
        if wget -q "$url" -O "$dest_file"; then
            log "Downloaded: $relative_path"
            return 0
        else
            error "Failed to download $relative_path from $url"
            return 1
        fi
    else
        error "Neither curl nor wget available for downloading files"
        return 1
    fi
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
detect_v5_markers_in_cwd() {
    local found=()
    [[ -f "$(pwd)/handoff-notes.md" ]] && found+=("handoff-notes.md")
    [[ -d "$(pwd)/.mcp-profiles" ]] && found+=(".mcp-profiles/")
    [[ -f "$(pwd)/mcp/dynamic-mcp.json" ]] && found+=("mcp/dynamic-mcp.json")
    [[ -f "$(pwd)/templates/handoff-notes-template.md" ]] && found+=("templates/handoff-notes-template.md")

    if [[ ${#found[@]} -eq 0 ]]; then
        return 1
    fi
    printf '%s\n' "${found[@]}"
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
    fi
    echo

    # settings.json plan
    local dest="$(pwd)/.claude/settings.json"
    if [[ -f "$dest" ]]; then
        local has_hooks=false has_tool_search=false
        grep -q '"hooks"' "$dest" 2>/dev/null && has_hooks=true
        grep -q "ENABLE_TOOL_SEARCH" "$dest" 2>/dev/null && has_tool_search=true
        if $has_hooks && $has_tool_search; then
            echo "  settings.json: already on v6 — would no-op (no backup, no diff)"
        elif command -v python3 >/dev/null 2>&1; then
            echo "  settings.json: existing file detected — would merge v6 template"
            echo "    (user values win on conflict; backup created at .claude/settings.json.backup-<ts>)"
        else
            echo "  settings.json: existing file detected, python3 NOT available"
            echo "    Would write template as .claude/settings.json.new (manual merge required)"
        fi
    else
        echo "  settings.json: no existing file — would deploy template verbatim"
    fi
    echo

    echo "  Would deploy:"
    echo "    - 11 specialist agents to .claude/agents/"
    echo "    - library/CLAUDE.md to .claude/CLAUDE.md"
    echo "    - Karpathy constitution to .claude/constitution/"
    echo "    - mission templates to ./missions/"
    echo "    - utility templates to ./templates/"
    echo "    - field manual docs to ./field-manual/"
    echo "    - MCP system files (.mcp.json.template, .env.mcp.template, mcp-setup.sh)"
    echo "    - SaaS skills to .claude/skills/"
    echo "    - schemas + gates + stack-profiles + docs"
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

    bash "$script_path" --yes
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
    local backup_file="$CLAUDE_DIR/CLAUDE.md.backup-$(date +%Y%m%d_%H%M%S)"

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

    local dest_file="$CLAUDE_DIR/settings.json"
    local backup_file="$CLAUDE_DIR/settings.json.backup-$(date +%Y%m%d_%H%M%S)"
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
    local mission_files=(
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
        "project/missions/README.md"
    )
    
    # Define command files to install
    local command_files=(
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
    
    # Define template files to install
    local template_files=(
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
    )
    
    # Define field manual files to install
    local field_manual_files=(
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
    )
    
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

    local skill_dirs=("saas-auth" "saas-payments" "saas-multitenancy" "saas-billing" "saas-email" "saas-onboarding" "saas-analytics")
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
            else
                warn "Could not download skill: $skill"
            fi
        fi
    done

    # Sprint 9: Install schemas
    log "Installing schemas..."
    local SCHEMAS_DIR="$(pwd)/schemas"
    mkdir -p "$SCHEMAS_DIR"

    local schema_files=("skill.schema.yaml" "stack-profile.schema.yaml" "skill-loading.schema.yaml" "quality-gate.schema.yaml" "project-plan.schema.yaml" "phase-context.schema.yaml" "handoff-manifest.schema.yaml")
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
        for template in "nodejs-saas.json" "python-api.json" "minimal.json"; do
            if [[ -f "$PROJECT_ROOT/project/gates/templates/$template" ]]; then
                cp "$PROJECT_ROOT/project/gates/templates/$template" "$GATES_DIR/templates/"
                log "Installed gate template: $template"
            fi
        done
    else
        download_file_from_github "project/gates/run-gates.py" "$GATES_DIR/run-gates.py" && chmod +x "$GATES_DIR/run-gates.py"
        download_file_from_github "project/gates/gate-types.yaml" "$GATES_DIR/gate-types.yaml"
        download_file_from_github "project/gates/README.md" "$GATES_DIR/README.md"
        for template in "nodejs-saas.json" "python-api.json" "minimal.json"; do
            download_file_from_github "project/gates/templates/$template" "$GATES_DIR/templates/$template"
        done
    fi

    # Sprint 9: Install stack profiles
    log "Installing stack profiles..."
    local STACK_PROFILES_DIR="$(pwd)/stack-profiles"
    mkdir -p "$STACK_PROFILES_DIR"

    local stack_profiles=("nextjs-supabase.yaml" "remix-railway.yaml" "sveltekit-supabase.yaml" "README.md")
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
    local mission_files=("library.md" "mission-build.md" "mission-fix.md" "mission-mvp.md" "mission-refactor.md" "mission-deploy.md" "mission-document.md" "mission-optimize.md" "mission-integrate.md" "mission-migrate.md" "mission-security.md" "mission-release.md" "dev-setup.md" "dev-alignment.md")
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

# Setup MCP configuration
setup_mcp_configuration() {
    log "Setting up MCP integration..."

    # Use current directory as target for MCP files
    local TARGET_DIR="$(pwd)"

    # Always download MCP files to ensure latest version
    log "Downloading MCP configuration files..."
    
    # Download .mcp.json
    if curl -sSL -o "$TARGET_DIR/.mcp.json" "https://raw.githubusercontent.com/TheWayWithin/agent-11/main/.mcp.json" 2>/dev/null; then
        success "Downloaded .mcp.json"
    else
        warn "Could not download .mcp.json"
    fi
    
    # Download .env.mcp.template
    if curl -sSL -o "$TARGET_DIR/.env.mcp.template" "https://raw.githubusercontent.com/TheWayWithin/agent-11/main/.env.mcp.template" 2>/dev/null; then
        success "Downloaded .env.mcp.template"
    else
        warn "Could not download .env.mcp.template"
    fi
    
    # Download .mcp.json.template with correct package names
    if curl -sSL -o "$TARGET_DIR/.mcp.json.template" "https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/templates/.mcp.json.template" 2>/dev/null; then
        success "Downloaded .mcp.json.template (correct package names)"
        # Create .mcp.json from template if it doesn't exist
        if [[ ! -f "$TARGET_DIR/.mcp.json" ]]; then
            cp "$TARGET_DIR/.mcp.json.template" "$TARGET_DIR/.mcp.json"
            success "Created .mcp.json with correct MCP package names"
        fi
    else
        warn "Could not download .mcp.json.template"
    fi
    
    # Download mcp-setup-v2.sh (the fixed version)
    if curl -sSL -o "$TARGET_DIR/mcp-setup.sh" "https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/mcp-setup-v2.sh" 2>/dev/null; then
        chmod +x "$TARGET_DIR/mcp-setup.sh"
        success "Downloaded mcp-setup.sh (v2 with correct package names)"
    else
        # Fallback to original if v2 doesn't exist
        if curl -sSL -o "$TARGET_DIR/mcp-setup.sh" "https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/mcp-setup.sh" 2>/dev/null; then
            chmod +x "$TARGET_DIR/mcp-setup.sh"
            warn "Downloaded original mcp-setup.sh (may have issues)"
        else
            warn "Could not download mcp-setup.sh"
        fi
    fi
    
    # Provide instructions for MCP setup
    echo ""
    echo "📌 MCP Setup Instructions:"
    if [[ -f "$TARGET_DIR/.env.mcp" ]]; then
        success "Found .env.mcp - running automatic MCP configuration..."
        if [[ -f "$TARGET_DIR/mcp-setup.sh" ]]; then
            # Run full setup (not just --verify) to actually register MCPs
            if "$TARGET_DIR/mcp-setup.sh"; then
                success "MCP servers configured - restart Claude Code to activate"
            else
                warn "Some MCPs could not be configured - check your API keys"
            fi
        else
            warn "mcp-setup.sh not found - skipping MCP configuration"
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
        echo "    See backup at .claude/settings.json.backup-* and merge manually."
        echo "    Reference: docs/UPGRADE.md"
        echo "    Roll back: bash <(curl -sSL https://raw.githubusercontent.com/$GITHUB_REPO/$GITHUB_BRANCH/project/deployment/scripts/restore-pre-upgrade.sh) --list"
    fi
    echo "  ✓ MCP documentation in docs/"
    echo "  ✓ Environment template: .env.mcp.template"
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
            --help|-h)
                cat <<HELP
Usage: $0 [flags] [core|full|minimal (deprecated)]

Flags:
  --upgrade            Migrate v5.x install to v6.0 before deploying
  --dry-run            Print the plan, make zero changes, exit 0
  --non-interactive    Promise no prompts; fail fast on conditions that
  (or --batch-safe)    would require human input. (Composable with the others.)
  --help, -h           Show this help

Examples:
  bash $0                            Fresh install on a v6 / greenfield repo
  bash $0 --upgrade                  Migrate v5.x then install v6.0
  bash $0 --dry-run                  Show what would happen without changing anything
  bash $0 --upgrade --dry-run        Preview a v5→v6 upgrade run
  bash $0 --upgrade --non-interactive  Bulk-mode: never prompts, exits non-zero on input demand
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
        setup_mcp_configuration
    } || {
        error "Installation failed. Initiating rollback..."
        rollback_installation
        fatal "Installation aborted. System restored to previous state."
    }

    # Show success message and instructions
    show_post_install_instructions
}

# Handle script interruption
trap 'error "Installation interrupted. Run script again to retry."; exit 130' INT TERM

# Run main function with all arguments
main "$@"