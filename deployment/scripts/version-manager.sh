#!/bin/bash

# AGENT-11 Version Manager
# Handles version management, rollback capabilities, and release management

set -e

# Configuration
AGENT11_REPO="https://api.github.com/repos/TheWayWithin/agent-11"
AGENT11_RAW="https://raw.githubusercontent.com/TheWayWithin/agent-11"
VERSION_FILE="$HOME/.claude/agent-11/version.txt"
VERSIONS_DIR="$HOME/.claude/agent-11/versions"
CURRENT_LINK="$HOME/.claude/agent-11/current"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "$1"
}

# Create necessary directories
setup_directories() {
    mkdir -p "$VERSIONS_DIR"
    mkdir -p "$(dirname "$VERSION_FILE")"
}

# Get current version
get_current_version() {
    if [[ -f "$VERSION_FILE" ]]; then
        cat "$VERSION_FILE"
    else
        echo "unknown"
    fi
}

# Set current version
set_current_version() {
    echo "$1" > "$VERSION_FILE"
    
    # Update current symlink
    if [[ -d "$VERSIONS_DIR/$1" ]]; then
        rm -f "$CURRENT_LINK"
        ln -sf "$VERSIONS_DIR/$1" "$CURRENT_LINK"
    fi
}

# Get all available versions (local and remote)
get_available_versions() {
    local source="$1" # "local", "remote", or "all"
    
    case "$source" in
        "local")
            if [[ -d "$VERSIONS_DIR" ]]; then
                ls "$VERSIONS_DIR" | sort -V -r
            fi
            ;;
        "remote")
            curl -s "$AGENT11_REPO/releases" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sort -V -r
            ;;
        "all"|*)
            {
                get_available_versions "local"
                get_available_versions "remote"
            } | sort -V -r | uniq
            ;;
    esac
}

# Download and install specific version
install_version() {
    local version="$1"
    local force="$2"
    
    if [[ -z "$version" ]]; then
        log "${RED}Version not specified${NC}"
        return 1
    fi
    
    local version_dir="$VERSIONS_DIR/$version"
    
    # Check if version already exists locally
    if [[ -d "$version_dir" ]] && [[ "$force" != "force" ]]; then
        log "${YELLOW}Version $version already installed locally${NC}"
        return 0
    fi
    
    log "${BLUE}Installing AGENT-11 $version...${NC}"
    
    # Create version directory
    mkdir -p "$version_dir"
    
    # Download the specific version
    local temp_dir="/tmp/agent-11-$version-$$"
    mkdir -p "$temp_dir"
    
    # Try to download release archive
    local archive_url="https://github.com/TheWayWithin/agent-11/archive/refs/tags/$version.tar.gz"
    if curl -sSL "$archive_url" | tar -xz -C "$temp_dir" --strip-components=1 2>/dev/null; then
        log "${GREEN}Downloaded $version from release archive${NC}"
    else
        # Fallback to raw files
        log "${YELLOW}Release archive not found, downloading individual files...${NC}"
        
        # Download key files
        local files=(
            "agents/specialists/strategist.md"
            "agents/specialists/developer.md"
            "agents/specialists/tester.md"
            "agents/specialists/operator.md"
            "agents/specialists/architect.md"
            "agents/specialists/designer.md"
            "agents/specialists/documenter.md"
            "agents/specialists/support.md"
            "agents/specialists/analyst.md"
            "agents/specialists/marketer.md"
            "agents/specialists/coordinator.md"
            "deployment/scripts/install.sh"
            "deployment/scripts/update-manager.sh"
            "deployment/scripts/version-manager.sh"
        )
        
        for file in "${files[@]}"; do
            local file_url="$AGENT11_RAW/$version/$file"
            local file_path="$temp_dir/$file"
            
            mkdir -p "$(dirname "$file_path")"
            if curl -sSL "$file_url" -o "$file_path" 2>/dev/null; then
                log "  ✓ Downloaded $file"
            else
                log "  ✗ Failed to download $file"
            fi
        done
    fi
    
    # Copy to version directory
    cp -r "$temp_dir"/* "$version_dir/"
    
    # Create version metadata
    cat > "$version_dir/version-info.json" << EOF
{
    "version": "$version",
    "installed_date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "source": "version-manager",
    "files_installed": $(find "$version_dir" -type f | wc -l)
}
EOF
    
    # Cleanup
    rm -rf "$temp_dir"
    
    log "${GREEN}Successfully installed AGENT-11 $version${NC}"
}

# Switch to specific version
switch_version() {
    local version="$1"
    local version_dir="$VERSIONS_DIR/$version"
    
    if [[ ! -d "$version_dir" ]]; then
        log "${RED}Version $version not found locally${NC}"
        log "${BLUE}Available local versions:${NC}"
        get_available_versions "local" | sed 's/^/  /'
        log "${BLUE}Install with: $0 install $version${NC}"
        return 1
    fi
    
    local current_version=$(get_current_version)
    if [[ "$current_version" == "$version" ]]; then
        log "${YELLOW}Already using version $version${NC}"
        return 0
    fi
    
    log "${BLUE}Switching from $current_version to $version...${NC}"
    
    # Backup current agents if they exist
    if [[ -d "$HOME/.claude/agents" ]]; then
        local backup_dir="$HOME/.claude/agent-11/backups/switch-backup-$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$backup_dir"
        cp -r "$HOME/.claude/agents" "$backup_dir/"
        log "${CYAN}Current agents backed up to: $backup_dir${NC}"
    fi
    
    # Clear current agents
    rm -rf "$HOME/.claude/agents"
    mkdir -p "$HOME/.claude/agents"
    
    # Copy agents from version directory
    if [[ -d "$version_dir/agents/specialists" ]]; then
        cp -r "$version_dir/agents/specialists"/* "$HOME/.claude/agents/"
        log "${GREEN}Agents installed from version $version${NC}"
    else
        log "${YELLOW}No agents found in version $version${NC}"
    fi
    
    # Update version tracking
    set_current_version "$version"
    
    log "${GREEN}Successfully switched to AGENT-11 $version${NC}"
    log "${BLUE}Restart Claude Code to load the new agents${NC}"
}

# Rollback to previous version
rollback() {
    local target_version="$1"
    
    if [[ -z "$target_version" ]]; then
        # Find the most recent backup
        local backup_dirs=($(ls -1t "$HOME/.claude/agent-11/backups/" 2>/dev/null | grep "switch-backup-" | head -5))
        
        if [[ ${#backup_dirs[@]} -eq 0 ]]; then
            log "${RED}No backup found for rollback${NC}"
            return 1
        fi
        
        log "${BLUE}Available rollback points:${NC}"
        for i in "${!backup_dirs[@]}"; do
            local backup_date=$(echo "${backup_dirs[$i]}" | sed 's/switch-backup-//' | sed 's/_/ /')
            echo "  $((i+1)). $backup_date"
        done
        
        read -p "Select rollback point (1-${#backup_dirs[@]}): " choice
        choice=$((choice-1))
        
        if [[ $choice -lt 0 ]] || [[ $choice -ge ${#backup_dirs[@]} ]]; then
            log "${RED}Invalid selection${NC}"
            return 1
        fi
        
        local backup_dir="$HOME/.claude/agent-11/backups/${backup_dirs[$choice]}"
        
        log "${BLUE}Rolling back to backup from ${backup_dirs[$choice]}...${NC}"
        
        # Restore from backup
        rm -rf "$HOME/.claude/agents"
        cp -r "$backup_dir/agents" "$HOME/.claude/"
        
        log "${GREEN}Rollback completed${NC}"
        log "${BLUE}Restart Claude Code to load the restored agents${NC}"
        
    else
        # Rollback to specific version
        switch_version "$target_version"
    fi
}

# Show version history
show_history() {
    local limit="${1:-10}"
    
    log "${BLUE}AGENT-11 Version History${NC}"
    log "========================="
    
    local current_version=$(get_current_version)
    log "Current Version: ${GREEN}$current_version${NC}"
    log
    
    log "${BLUE}Installed Versions:${NC}"
    local local_versions=($(get_available_versions "local"))
    
    if [[ ${#local_versions[@]} -eq 0 ]]; then
        log "  No versions installed locally"
    else
        for version in "${local_versions[@]:0:$limit}"; do
            local indicator=""
            [[ "$version" == "$current_version" ]] && indicator=" ${GREEN}(current)${NC}"
            
            local version_dir="$VERSIONS_DIR/$version"
            local install_date=""
            if [[ -f "$version_dir/version-info.json" ]]; then
                install_date=$(grep '"installed_date"' "$version_dir/version-info.json" | cut -d'"' -f4 | cut -d'T' -f1)
            fi
            
            echo -e "  $version $indicator"
            [[ -n "$install_date" ]] && echo "    Installed: $install_date"
        done
    fi
    
    log
    log "${BLUE}Available Remote Versions (latest $limit):${NC}"
    local remote_versions=($(get_available_versions "remote"))
    
    if [[ ${#remote_versions[@]} -eq 0 ]]; then
        log "  Unable to fetch remote versions"
    else
        for version in "${remote_versions[@]:0:$limit}"; do
            local status=""
            if [[ -d "$VERSIONS_DIR/$version" ]]; then
                status=" ${CYAN}(installed)${NC}"
            fi
            echo -e "  $version$status"
        done
    fi
}

# Compare versions
compare_versions() {
    local version1="$1"
    local version2="$2"
    
    if [[ -z "$version1" ]] || [[ -z "$version2" ]]; then
        log "${RED}Two versions required for comparison${NC}"
        return 1
    fi
    
    log "${BLUE}Comparing AGENT-11 $version1 vs $version2${NC}"
    log "============================================="
    
    # Check if versions exist locally
    local v1_dir="$VERSIONS_DIR/$version1"
    local v2_dir="$VERSIONS_DIR/$version2"
    
    if [[ ! -d "$v1_dir" ]]; then
        log "${YELLOW}Version $version1 not installed locally${NC}"
        return 1
    fi
    
    if [[ ! -d "$v2_dir" ]]; then
        log "${YELLOW}Version $version2 not installed locally${NC}"
        return 1
    fi
    
    # Compare agent files
    log "${BLUE}Agent Changes:${NC}"
    
    local agents_v1=($(ls "$v1_dir/agents/specialists/" 2>/dev/null | sed 's/\.md$//' || true))
    local agents_v2=($(ls "$v2_dir/agents/specialists/" 2>/dev/null | sed 's/\.md$//' || true))
    
    # Find added agents
    for agent in "${agents_v2[@]}"; do
        if [[ ! " ${agents_v1[@]} " =~ " $agent " ]]; then
            log "  ${GREEN}+ Added: $agent${NC}"
        fi
    done
    
    # Find removed agents
    for agent in "${agents_v1[@]}"; do
        if [[ ! " ${agents_v2[@]} " =~ " $agent " ]]; then
            log "  ${RED}- Removed: $agent${NC}"
        fi
    done
    
    # Find modified agents
    for agent in "${agents_v1[@]}"; do
        if [[ " ${agents_v2[@]} " =~ " $agent " ]]; then
            if ! cmp -s "$v1_dir/agents/specialists/$agent.md" "$v2_dir/agents/specialists/$agent.md" 2>/dev/null; then
                log "  ${YELLOW}~ Modified: $agent${NC}"
            fi
        fi
    done
    
    # Compare file counts
    local files_v1=$(find "$v1_dir" -type f | wc -l)
    local files_v2=$(find "$v2_dir" -type f | wc -l)
    
    log
    log "${BLUE}File Statistics:${NC}"
    log "  $version1: $files_v1 files"
    log "  $version2: $files_v2 files"
    
    if [[ $files_v2 -gt $files_v1 ]]; then
        log "  ${GREEN}+$((files_v2 - files_v1)) files added${NC}"
    elif [[ $files_v1 -gt $files_v2 ]]; then
        log "  ${RED}-$((files_v1 - files_v2)) files removed${NC}"
    else
        log "  ${CYAN}Same number of files${NC}"
    fi
}

# Clean up old versions
cleanup() {
    local keep="${1:-5}"
    
    log "${BLUE}Cleaning up old versions (keeping latest $keep)...${NC}"
    
    local versions=($(get_available_versions "local"))
    local current_version=$(get_current_version)
    
    if [[ ${#versions[@]} -le $keep ]]; then
        log "${GREEN}No cleanup needed (${#versions[@]} versions, keeping $keep)${NC}"
        return 0
    fi
    
    # Remove old versions (but never remove current version)
    local to_remove=($(printf '%s\n' "${versions[@]:$keep}" | grep -v "^$current_version$" || true))
    
    if [[ ${#to_remove[@]} -eq 0 ]]; then
        log "${GREEN}No versions to remove${NC}"
        return 0
    fi
    
    log "${YELLOW}Versions to remove:${NC}"
    printf '  %s\n' "${to_remove[@]}"
    
    read -p "Proceed with cleanup? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy] ]]; then
        for version in "${to_remove[@]}"; do
            rm -rf "$VERSIONS_DIR/$version"
            log "  ${RED}Removed $version${NC}"
        done
        log "${GREEN}Cleanup completed${NC}"
    else
        log "${YELLOW}Cleanup cancelled${NC}"
    fi
}

# Show help
show_help() {
    cat << EOF
AGENT-11 Version Manager

Usage: $0 [command] [options]

Commands:
    list [limit]           List available versions (local and remote)
    history [limit]        Show version history with install dates
    install <version>      Install specific version locally
    switch <version>       Switch to installed version
    rollback [version]     Rollback to previous version or backup
    compare <v1> <v2>      Compare two installed versions
    current                Show current version
    cleanup [keep]         Remove old versions (keep latest N)
    help                   Show this help message

Examples:
    $0 list                    # List all available versions
    $0 install v2.1.0         # Install specific version
    $0 switch v2.0.0          # Switch to installed version
    $0 rollback               # Interactive rollback selection
    $0 rollback v1.2.0        # Rollback to specific version
    $0 compare v2.0.0 v2.1.0  # Compare two versions
    $0 cleanup 3              # Keep only latest 3 versions

Version Management:
    - Installed versions are stored in ~/.claude/agent-11/versions/
    - Current version symlink at ~/.claude/agent-11/current
    - Automatic backups created before switching versions
    - Version metadata tracked for each installation

EOF
}

# Show current version info
show_current() {
    local current_version=$(get_current_version)
    local version_dir="$VERSIONS_DIR/$current_version"
    
    log "${BLUE}Current AGENT-11 Version Information${NC}"
    log "===================================="
    log "Version: ${GREEN}$current_version${NC}"
    
    if [[ -f "$version_dir/version-info.json" ]]; then
        local install_date=$(grep '"installed_date"' "$version_dir/version-info.json" | cut -d'"' -f4)
        local files_count=$(grep '"files_installed"' "$version_dir/version-info.json" | cut -d':' -f2 | tr -d ' ,')
        
        log "Installed: $install_date"
        log "Files: $files_count"
    fi
    
    if [[ -d "$HOME/.claude/agents" ]]; then
        local agent_count=$(ls "$HOME/.claude/agents"/*.md 2>/dev/null | wc -l)
        log "Active Agents: $agent_count"
    fi
    
    local version_dir_size=$(du -sh "$version_dir" 2>/dev/null | cut -f1 || echo "unknown")
    log "Disk Usage: $version_dir_size"
}

# Main function
main() {
    setup_directories
    
    case "${1:-help}" in
        "list")
            get_available_versions "all" | head -n "${2:-20}"
            ;;
        "history")
            show_history "${2:-10}"
            ;;
        "install")
            if [[ -z "$2" ]]; then
                log "${RED}Version required${NC}"
                log "Usage: $0 install <version>"
                exit 1
            fi
            install_version "$2" "$3"
            ;;
        "switch")
            if [[ -z "$2" ]]; then
                log "${RED}Version required${NC}"
                log "Usage: $0 switch <version>"
                exit 1
            fi
            switch_version "$2"
            ;;
        "rollback")
            rollback "$2"
            ;;
        "compare")
            if [[ -z "$2" ]] || [[ -z "$3" ]]; then
                log "${RED}Two versions required${NC}"
                log "Usage: $0 compare <version1> <version2>"
                exit 1
            fi
            compare_versions "$2" "$3"
            ;;
        "current")
            show_current
            ;;
        "cleanup")
            cleanup "${2:-5}"
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# Run main function with all arguments
main "$@"