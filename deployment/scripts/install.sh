#!/bin/bash

# AGENT-11 Installation Script
# Deploys elite AI agent squad to Claude Code
# Target: 95% success rate, <5 minute installation

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CLAUDE_DIR="$HOME/.claude"
AGENTS_DIR="$CLAUDE_DIR/agents"
BACKUP_DIR="$CLAUDE_DIR/backups/agent-11"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="$BACKUP_DIR/$TIMESTAMP"

# GitHub repository configuration
GITHUB_REPO="TheWayWithin/agent-11"
GITHUB_BRANCH="main"
GITHUB_AGENTS_PATH=".claude/agents"
GITHUB_RAW_BASE="https://raw.githubusercontent.com/$GITHUB_REPO/$GITHUB_BRANCH/$GITHUB_AGENTS_PATH"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Available squads
SQUAD_CORE=("strategist" "developer" "tester" "operator")
SQUAD_FULL=("strategist" "developer" "tester" "operator" "architect" "designer" "documenter" "support" "analyst" "marketer" "coordinator")
SQUAD_MINIMAL=("strategist" "developer")

# Logging functions
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
    if [[ -d "$PROJECT_ROOT/.claude/agents" ]]; then
        echo "local"
    elif [[ -d "$PROJECT_ROOT/agents/specialists" ]]; then
        echo "local"
    else
        echo "remote"
    fi
}

# Validate environment before installation
validate_environment() {
    log "Validating installation environment..."
    
    # Check if we can write to home directory
    if [[ ! -w "$HOME" ]]; then
        fatal "Cannot write to home directory: $HOME"
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
    echo "📁 Agents installed in: $AGENTS_DIR"
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
    
    echo
    echo "📚 Documentation: $PROJECT_ROOT/README.md"
    echo "🔧 Troubleshooting: $PROJECT_ROOT/field-manual/"
    echo
    
    if [[ -d "$BACKUP_PATH" ]]; then
        echo "💾 Backup created: $BACKUP_PATH"
        echo
    fi
    
    echo "Need help? Check the field manual or deploy @support for customer success!"
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