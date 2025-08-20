#!/bin/bash

# AGENT-11 Agent Installer
# Handles individual agent installation, validation, and management

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CLAUDE_DIR="$HOME/.claude"
AGENTS_DIR="$CLAUDE_DIR/agents"
SOURCE_DIR="$PROJECT_ROOT/agents/specialists"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log() { echo -e "${BLUE}[AGENT]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

# Validate agent file format and content
validate_agent_file() {
    local agent_file="$1"
    local agent_name=$(basename "$agent_file" .md)
    local issues=()
    
    log "Validating agent file: $agent_name"
    
    # Check if file exists
    if [[ ! -f "$agent_file" ]]; then
        error "Agent file not found: $agent_file"
        return 1
    fi
    
    # Check file is not empty
    if [[ ! -s "$agent_file" ]]; then
        issues+=("Agent file is empty")
    fi
    
    # Extract YAML header
    local yaml_header
    if ! yaml_header=$(sed -n '/^---$/,/^---$/p' "$agent_file"); then
        issues+=("Failed to extract YAML header")
    fi
    
    # Check YAML header exists
    if [[ -z "$yaml_header" ]] || ! echo "$yaml_header" | grep -q "^---$"; then
        issues+=("Missing or invalid YAML header format")
    fi
    
    # Check required YAML fields
    if ! echo "$yaml_header" | grep -q "^name:"; then
        issues+=("Missing required field: name")
    fi
    
    if ! echo "$yaml_header" | grep -q "^description:"; then
        issues+=("Missing required field: description")
    fi
    
    # Validate YAML field values
    local yaml_name
    if yaml_name=$(echo "$yaml_header" | grep "^name:" | cut -d':' -f2- | sed 's/^ *//'); then
        yaml_name=$(echo "$yaml_name" | tr -d '"'"'" | xargs)
        if [[ "$yaml_name" != "$agent_name" ]]; then
            issues+=("YAML name '$yaml_name' does not match filename '$agent_name'")
        fi
    fi
    
    # Check for agent content after YAML header
    local content_after_yaml
    content_after_yaml=$(sed -n '/^---$/,/^---$/!p' "$agent_file" | sed '/^---$/d')
    if [[ -z "$content_after_yaml" ]] || [[ "$(echo "$content_after_yaml" | wc -w)" -lt 10 ]]; then
        issues+=("Insufficient content after YAML header")
    fi
    
    # Check for required agent sections
    if ! grep -q "Core Capabilities:" "$agent_file"; then
        warn "Missing recommended section: Core Capabilities"
    fi
    
    if ! grep -q "You are THE" "$agent_file"; then
        warn "Missing agent persona declaration"
    fi
    
    # Report validation results
    if [[ ${#issues[@]} -eq 0 ]]; then
        success "Agent validation passed: $agent_name"
        return 0
    else
        error "Agent validation failed: $agent_name"
        for issue in "${issues[@]}"; do
            error "  - $issue"
        done
        return 1
    fi
}

# Install single agent
install_agent() {
    local agent_name="$1"
    local source_file="$SOURCE_DIR/$agent_name.md"
    local dest_file="$AGENTS_DIR/$agent_name.md"
    local force="${2:-false}"
    
    log "Installing agent: $agent_name"
    
    # Check if source file exists
    if [[ ! -f "$source_file" ]]; then
        error "Source agent file not found: $source_file"
        return 1
    fi
    
    # Validate source file
    if ! validate_agent_file "$source_file"; then
        error "Source agent validation failed: $agent_name"
        return 1
    fi
    
    # Check if destination already exists
    if [[ -f "$dest_file" && "$force" != "true" ]]; then
        warn "Agent already exists: $agent_name (use --force to overwrite)"
        return 1
    fi
    
    # Create destination directory
    mkdir -p "$AGENTS_DIR"
    
    # Copy agent file
    if cp "$source_file" "$dest_file"; then
        success "Agent installed: $agent_name"
        
        # Verify installation
        if validate_agent_file "$dest_file"; then
            log "Installation verification passed: $agent_name"
            return 0
        else
            error "Installation verification failed: $agent_name"
            rm -f "$dest_file"
            return 1
        fi
    else
        error "Failed to copy agent file: $agent_name"
        return 1
    fi
}

# Uninstall agent
uninstall_agent() {
    local agent_name="$1"
    local dest_file="$AGENTS_DIR/$agent_name.md"
    
    log "Uninstalling agent: $agent_name"
    
    if [[ ! -f "$dest_file" ]]; then
        warn "Agent not installed: $agent_name"
        return 1
    fi
    
    # Create backup before removal
    local backup_dir="$HOME/.claude/backups/agent-11/uninstall-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    cp "$dest_file" "$backup_dir/"
    
    # Remove agent
    if rm "$dest_file"; then
        success "Agent uninstalled: $agent_name"
        log "Backup created: $backup_dir/$agent_name.md"
        return 0
    else
        error "Failed to uninstall agent: $agent_name"
        return 1
    fi
}

# List installed agents
list_installed_agents() {
    log "Scanning installed agents in: $AGENTS_DIR"
    echo
    
    if [[ ! -d "$AGENTS_DIR" ]]; then
        warn "Agents directory not found: $AGENTS_DIR"
        return 0
    fi
    
    local agent_files=($(find "$AGENTS_DIR" -name "*.md" 2>/dev/null | sort))
    
    if [[ ${#agent_files[@]} -eq 0 ]]; then
        warn "No agents installed"
        return 0
    fi
    
    printf "%-15s %-10s %-15s %-50s\n" "AGENT" "STATUS" "SIZE" "DESCRIPTION"
    printf "%-15s %-10s %-15s %-50s\n" "-----" "------" "----" "-----------"
    
    for agent_file in "${agent_files[@]}"; do
        local agent_name=$(basename "$agent_file" .md)
        local file_size=$(du -h "$agent_file" | cut -f1)
        local status="UNKNOWN"
        local description="No description"
        
        # Validate agent and extract info
        if validate_agent_file "$agent_file" >/dev/null 2>&1; then
            status="VALID"
            # Extract description from YAML header
            local yaml_desc
            if yaml_desc=$(sed -n '/^---$/,/^---$/p' "$agent_file" | grep "^description:" | cut -d':' -f2- | sed 's/^ *//'); then
                description=$(echo "$yaml_desc" | tr -d '"'"'" | cut -c1-50)
                if [[ ${#yaml_desc} -gt 50 ]]; then
                    description="${description}..."
                fi
            fi
        else
            status="INVALID"
        fi
        
        printf "%-15s %-10s %-15s %-50s\n" "$agent_name" "$status" "$file_size" "$description"
    done
    
    echo
    log "Total agents installed: ${#agent_files[@]}"
}

# List available agents (in source directory)
list_available_agents() {
    log "Scanning available agents in: $SOURCE_DIR"
    echo
    
    if [[ ! -d "$SOURCE_DIR" ]]; then
        error "Source directory not found: $SOURCE_DIR"
        return 1
    fi
    
    local source_files=($(find "$SOURCE_DIR" -name "*.md" 2>/dev/null | sort))
    
    if [[ ${#source_files[@]} -eq 0 ]]; then
        warn "No source agents found"
        return 0
    fi
    
    printf "%-15s %-10s %-10s %-50s\n" "AGENT" "STATUS" "INSTALLED" "DESCRIPTION"
    printf "%-15s %-10s %-10s %-50s\n" "-----" "------" "---------" "-----------"
    
    for source_file in "${source_files[@]}"; do
        local agent_name=$(basename "$source_file" .md)
        local dest_file="$AGENTS_DIR/$agent_name.md"
        local status="UNKNOWN"
        local installed="NO"
        local description="No description"
        
        # Check if installed
        if [[ -f "$dest_file" ]]; then
            installed="YES"
        fi
        
        # Validate source and extract info
        if validate_agent_file "$source_file" >/dev/null 2>&1; then
            status="VALID"
            # Extract description from YAML header
            local yaml_desc
            if yaml_desc=$(sed -n '/^---$/,/^---$/p' "$source_file" | grep "^description:" | cut -d':' -f2- | sed 's/^ *//'); then
                description=$(echo "$yaml_desc" | tr -d '"'"'" | cut -c1-50)
                if [[ ${#yaml_desc} -gt 50 ]]; then
                    description="${description}..."
                fi
            fi
        else
            status="INVALID"
        fi
        
        printf "%-15s %-10s %-10s %-50s\n" "$agent_name" "$status" "$installed" "$description"
    done
    
    echo
    log "Total available agents: ${#source_files[@]}"
}

# Update agent (reinstall with force)
update_agent() {
    local agent_name="$1"
    
    log "Updating agent: $agent_name"
    
    if install_agent "$agent_name" "true"; then
        success "Agent updated successfully: $agent_name"
        return 0
    else
        error "Failed to update agent: $agent_name"
        return 1
    fi
}

# Verify all installed agents
verify_all_agents() {
    log "Verifying all installed agents..."
    
    if [[ ! -d "$AGENTS_DIR" ]]; then
        warn "No agents directory found"
        return 0
    fi
    
    local agent_files=($(find "$AGENTS_DIR" -name "*.md" 2>/dev/null))
    local valid_count=0
    local invalid_agents=()
    
    for agent_file in "${agent_files[@]}"; do
        local agent_name=$(basename "$agent_file" .md)
        if validate_agent_file "$agent_file" >/dev/null 2>&1; then
            ((valid_count++))
        else
            invalid_agents+=("$agent_name")
        fi
    done
    
    echo
    log "Verification Results:"
    log "  Valid agents: $valid_count"
    log "  Total agents: ${#agent_files[@]}"
    
    if [[ ${#invalid_agents[@]} -gt 0 ]]; then
        warn "Invalid agents found: ${invalid_agents[*]}"
        return 1
    else
        success "All installed agents are valid!"
        return 0
    fi
}

# Display usage information
usage() {
    echo "AGENT-11 Agent Installer"
    echo
    echo "Usage: $0 <command> [options]"
    echo
    echo "Commands:"
    echo "  install <name> [--force]   Install specific agent"
    echo "  uninstall <name>           Uninstall specific agent"
    echo "  update <name>              Update specific agent"
    echo "  list-installed             List installed agents"
    echo "  list-available             List available agents"
    echo "  validate <name>            Validate specific agent file"
    echo "  verify-all                 Verify all installed agents"
    echo
    echo "Examples:"
    echo "  $0 install strategist              # Install strategist agent"
    echo "  $0 install developer --force       # Force reinstall developer"
    echo "  $0 uninstall tester                # Uninstall tester agent"
    echo "  $0 update operator                 # Update operator agent"
    echo "  $0 list-installed                  # Show installed agents"
    echo "  $0 list-available                  # Show available agents"
    echo "  $0 validate strategist             # Validate agent file"
    echo "  $0 verify-all                      # Verify all agents"
}

# Main function
main() {
    local command="${1:-}"
    
    case "$command" in
        "install")
            if [[ -z "${2:-}" ]]; then
                error "Agent name required for install command"
                usage
                exit 1
            fi
            local force="false"
            if [[ "${3:-}" == "--force" ]]; then
                force="true"
            fi
            install_agent "$2" "$force"
            ;;
        "uninstall")
            if [[ -z "${2:-}" ]]; then
                error "Agent name required for uninstall command"
                usage
                exit 1
            fi
            uninstall_agent "$2"
            ;;
        "update")
            if [[ -z "${2:-}" ]]; then
                error "Agent name required for update command"
                usage
                exit 1
            fi
            update_agent "$2"
            ;;
        "list-installed")
            list_installed_agents
            ;;
        "list-available")
            list_available_agents
            ;;
        "validate")
            if [[ -z "${2:-}" ]]; then
                error "Agent name required for validate command"
                usage
                exit 1
            fi
            local agent_file="$SOURCE_DIR/$2.md"
            validate_agent_file "$agent_file"
            ;;
        "verify-all")
            verify_all_agents
            ;;
        "")
            usage
            exit 1
            ;;
        *)
            error "Unknown command: $command"
            usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@"