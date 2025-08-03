#!/bin/bash

# AGENT-11 Installation Script
# Deploys elite AI agent squad to Claude Code
# Target: 95% success rate, <5 minute installation

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors for output (defined early for use in functions)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="$BACKUP_DIR/$TIMESTAMP"

# GitHub repository configuration
GITHUB_REPO="TheWayWithin/agent-11"
GITHUB_BRANCH="main"
GITHUB_AGENTS_PATH=".claude/agents"
GITHUB_RAW_BASE="https://raw.githubusercontent.com/$GITHUB_REPO/$GITHUB_BRANCH/$GITHUB_AGENTS_PATH"


# Available squads
SQUAD_CORE=("strategist" "developer" "tester" "operator")
SQUAD_FULL=("strategist" "developer" "tester" "operator" "architect" "designer" "documenter" "support" "analyst" "marketer" "coordinator" "agent-optimizer")
SQUAD_MINIMAL=("strategist" "developer")


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

# Check if we're running from a local repository or remote execution
detect_execution_mode() {
    # Check if we're running from within the actual git repository
    # This is the most reliable way to detect local vs remote execution
    if [[ -d "$PROJECT_ROOT/.git" && -f "$PROJECT_ROOT/README.md" && -d "$PROJECT_ROOT/.claude/agents" ]]; then
        # We're in the actual AGENT-11 repository
        echo "local"
    elif [[ -d "$PROJECT_ROOT/.git" && -f "$PROJECT_ROOT/README.md" && -d "$PROJECT_ROOT/agents/specialists" ]]; then
        # We're in the repository but using old structure
        echo "local"
    else
        # We're running via curl download or not in repository
        echo "remote"
    fi
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
        # Check if source agents exist in new .claude/agents location first
        if [[ -d "$PROJECT_ROOT/.claude/agents" ]]; then
            log "Using agents from: $PROJECT_ROOT/.claude/agents"
        elif [[ -d "$PROJECT_ROOT/agents/specialists" ]]; then
            log "Using agents from: $PROJECT_ROOT/agents/specialists"
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

# Create backup of existing agents
create_backup() {
    if [[ ! -d "$AGENTS_DIR" ]]; then
        log "No existing agents directory found. Skipping backup."
        return 0
    fi
    
    log "Creating backup of existing agents..."
    
    # Create backup directory
    mkdir -p "$BACKUP_PATH"
    
    # Copy existing agents with error handling
    if cp -r "$AGENTS_DIR"/* "$BACKUP_PATH/" 2>/dev/null; then
        success "Backup created: $BACKUP_PATH"
        echo "$BACKUP_PATH" > "$BACKUP_DIR/latest"
    else
        warn "No existing agents to backup or backup failed"
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
    local yaml_section
    yaml_section=$(sed -n '/^---$/,/^---$/p' "$agent_file")
    
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
        # Try new .claude/agents location first, then fall back to old location
        local source_file
        if [[ -f "$PROJECT_ROOT/.claude/agents/$agent_name.md" ]]; then
            source_file="$PROJECT_ROOT/.claude/agents/$agent_name.md"
        elif [[ -f "$PROJECT_ROOT/agents/specialists/$agent_name.md" ]]; then
            source_file="$PROJECT_ROOT/agents/specialists/$agent_name.md"
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

# Install squad of agents
install_squad() {
    local squad_type="$1"
    local squad_agents
    
    # Get squad agents based on type
    case "$squad_type" in
        "core")
            squad_agents=("${SQUAD_CORE[@]}")
            ;;
        "full")
            squad_agents=("${SQUAD_FULL[@]}")
            ;;
        "minimal")
            squad_agents=("${SQUAD_MINIMAL[@]}")
            ;;
    esac
    
    local total=${#squad_agents[@]}
    local current=0
    local failed_agents=()
    
    log "Installing $squad_type squad ($total agents)..."
    
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
        success "All $squad_type squad agents installed successfully!"
        return 0
    else
        error "Failed to install: ${failed_agents[*]}"
        return 1
    fi
}

# Verify installation
verify_installation() {
    local squad_type="$1"
    local squad_agents
    
    # Get squad agents based on type
    case "$squad_type" in
        "core")
            squad_agents=("${SQUAD_CORE[@]}")
            ;;
        "full")
            squad_agents=("${SQUAD_FULL[@]}")
            ;;
        "minimal")
            squad_agents=("${SQUAD_MINIMAL[@]}")
            ;;
    esac
    
    log "Verifying installation..."
    
    local missing_agents=()
    for agent in "${squad_agents[@]}"; do
        local agent_file="$AGENTS_DIR/$agent.md"
        if [[ ! -f "$agent_file" ]]; then
            missing_agents+=("$agent")
        elif ! validate_agent_file "$agent_file"; then
            missing_agents+=("$agent")
        fi
    done
    
    if [[ ${#missing_agents[@]} -eq 0 ]]; then
        success "Installation verification passed!"
        return 0
    else
        error "Verification failed. Missing or invalid agents: ${missing_agents[*]}"
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
            # Remove current agents directory
            rm -rf "$AGENTS_DIR"
            
            # Restore from backup
            mkdir -p "$AGENTS_DIR"
            cp -r "$latest_backup"/* "$AGENTS_DIR/" 2>/dev/null || true
            
            success "Rollback completed. Restored from: $latest_backup"
        else
            warn "Backup directory not found. Manual cleanup may be required."
        fi
    else
        # No backup exists, just clean up
        rm -rf "$AGENTS_DIR"
        success "Clean rollback completed (no previous agents to restore)"
    fi
}

# Display post-installation instructions
show_post_install_instructions() {
    local squad_type="$1"
    local squad_agents
    
    # Get squad agents based on type
    case "$squad_type" in
        "core")
            squad_agents=("${SQUAD_CORE[@]}")
            ;;
        "full")
            squad_agents=("${SQUAD_FULL[@]}")
            ;;
        "minimal")
            squad_agents=("${SQUAD_MINIMAL[@]}")
            ;;
    esac
    
    echo
    echo "🎉 AGENT-11 $squad_type Squad Deployed Successfully!"
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
    
    case "$squad_type" in
        "core")
            echo "   # 1. Define what to build"
            echo "   @strategist Create user stories for a user authentication feature"
            echo
            echo "   # 2. Build it"
            echo "   @developer Implement the authentication based on the requirements above"
            echo
            echo "   # 3. Test it"
            echo "   @tester Validate the implementation and create test cases"
            echo
            echo "   # 4. Ship it"
            echo "   @operator Deploy to production when tests pass"
            ;;
        "minimal")
            echo "   # Start with strategy"
            echo "   @strategist Define requirements for [your feature]"
            echo
            echo "   # Build it"
            echo "   @developer Implement based on the requirements"
            ;;
        *)
            echo "   # Your full squad is ready for complex missions!"
            echo "   @coordinator Plan and orchestrate multi-agent workflows"
            ;;
    esac
    
    echo -e "${BLUE}📚 Next Steps${NC}"
    echo "  • Your agents are ready to use in this project"
    echo "  • Try the quick start commands above"
    echo "  • Documentation: https://github.com/TheWayWithin/agent-11"
    echo
    
    if [[ -d "$BACKUP_PATH" ]]; then
        echo -e "${YELLOW}💾 Backup Information${NC}"
        echo "  Previous agents backed up to: $BACKUP_PATH"
        echo
    fi
    
    echo -e "${GREEN}✨ Your elite squad is deployed and ready for action!${NC}"
    echo "Need help? Deploy @support for customer success assistance!"
}

# Main installation function
main() {
    local squad_type="${1:-core}"
    local squad_ref
    
    echo "🚁 AGENT-11 Deployment System"
    echo "=============================="
    echo
    
    # Validate squad type and set reference
    case "$squad_type" in
        "core")
            squad_ref="SQUAD_CORE"
            ;;
        "full")
            squad_ref="SQUAD_FULL"
            ;;
        "minimal")
            squad_ref="SQUAD_MINIMAL"
            ;;
        *)
            echo "Usage: $0 [core|full|minimal]"
            echo
            echo "Squad Types:"
            echo "  core     - Essential 4 agents (strategist, developer, tester, operator)"
            echo "  full     - All 11 specialized agents"
            echo "  minimal  - Just strategist and developer"
            echo
            exit 1
            ;;
    esac
    
    # Get selected squad agents
    local selected_squad
    case "$squad_type" in
        "core")
            selected_squad=("${SQUAD_CORE[@]}")
            ;;
        "full")
            selected_squad=("${SQUAD_FULL[@]}")
            ;;
        "minimal")
            selected_squad=("${SQUAD_MINIMAL[@]}")
            ;;
    esac
    
    log "Selected squad: $squad_type (${#selected_squad[@]} agents)"
    echo
    
    # Installation pipeline with rollback on failure
    {
        validate_environment &&
        create_backup &&
        install_squad "$squad_type" &&
        verify_installation "$squad_type"
    } || {
        error "Installation failed. Initiating rollback..."
        rollback_installation
        fatal "Installation aborted. System restored to previous state."
    }
    
    # Show success message and instructions
    show_post_install_instructions "$squad_type"
}

# Handle script interruption
trap 'error "Installation interrupted. Run script again to retry."; exit 130' INT TERM

# Run main function with all arguments
main "$@"