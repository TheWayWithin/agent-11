#!/bin/bash

# AGENT-11 Update Manager
# Handles version checking, updates, and notifications for AGENT-11 installations

set -e

# Configuration
AGENT11_REPO="https://api.github.com/repos/TheWayWithin/agent-11"
AGENT11_RAW="https://raw.githubusercontent.com/TheWayWithin/agent-11/main"
VERSION_FILE="$HOME/.claude/agent-11/version.txt"
CONFIG_FILE="$HOME/.claude/agent-11/update-config.json"
UPDATE_LOG="$HOME/.claude/agent-11/updates.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$UPDATE_LOG"
    echo -e "$1"
}

# Create necessary directories
setup_directories() {
    mkdir -p "$(dirname "$VERSION_FILE")"
    mkdir -p "$(dirname "$CONFIG_FILE")"
    mkdir -p "$(dirname "$UPDATE_LOG")"
}

# Get current installed version
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
}

# Get latest version from GitHub
get_latest_version() {
    curl -s "$AGENT11_REPO/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' 2>/dev/null || echo "unknown"
}

# Get update configuration
get_update_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        cat "$CONFIG_FILE"
    else
        echo '{
            "auto_check": true,
            "auto_install": false,
            "check_frequency": "weekly",
            "last_check": 0,
            "notifications": true,
            "backup_before_update": true
        }'
    fi
}

# Save update configuration
save_update_config() {
    echo "$1" > "$CONFIG_FILE"
}

# Check if update check is due
is_update_check_due() {
    local config=$(get_update_config)
    local frequency=$(echo "$config" | grep -o '"check_frequency":[^,]*' | cut -d'"' -f4)
    local last_check=$(echo "$config" | grep -o '"last_check":[^,}]*' | cut -d':' -f2)
    
    local current_time=$(date +%s)
    local check_interval
    
    case "$frequency" in
        "daily") check_interval=86400 ;;
        "weekly") check_interval=604800 ;;
        "monthly") check_interval=2592000 ;;
        *) check_interval=604800 ;; # default to weekly
    esac
    
    [[ $((current_time - last_check)) -gt $check_interval ]]
}

# Update last check time
update_last_check() {
    local config=$(get_update_config)
    local current_time=$(date +%s)
    local updated_config=$(echo "$config" | sed "s/\"last_check\":[^,}]*/\"last_check\":$current_time/")
    save_update_config "$updated_config"
}

# Compare versions (returns 0 if v1 < v2, 1 if v1 >= v2)
version_lt() {
    [[ "$1" == "$2" ]] && return 1
    local IFS=.
    local i ver1=($1) ver2=($2)
    
    # Remove 'v' prefix if present
    ver1[0]=${ver1[0]#v}
    ver2[0]=${ver2[0]#v}
    
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++)); do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++)); do
        if [[ -z ${ver2[i]} ]]; then
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]})); then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]})); then
            return 0
        fi
    done
    return 1
}

# Get changelog for version
get_changelog() {
    local version="$1"
    curl -s "$AGENT11_REPO/releases/tags/$version" | grep -o '"body":"[^"]*"' | cut -d'"' -f4 | sed 's/\\n/\n/g' 2>/dev/null || echo "Changelog not available"
}

# Backup current installation
backup_installation() {
    local backup_dir="$HOME/.claude/agent-11/backups/backup-$(date +%Y%m%d_%H%M%S)"
    log "${BLUE}Creating backup at $backup_dir${NC}"
    
    mkdir -p "$backup_dir"
    
    # Backup agents
    if [[ -d "$HOME/.claude/agents" ]]; then
        cp -r "$HOME/.claude/agents" "$backup_dir/"
    fi
    
    # Backup configuration
    if [[ -d "$HOME/.claude/agent-11" ]]; then
        cp -r "$HOME/.claude/agent-11" "$backup_dir/config"
    fi
    
    echo "$backup_dir"
}

# List available backups
list_backups() {
    local backup_base="$HOME/.claude/agent-11/backups"
    if [[ -d "$backup_base" ]]; then
        log "${BLUE}Available backups:${NC}"
        ls -la "$backup_base" | grep "backup-" | awk '{print $9, $6, $7, $8}'
    else
        log "${YELLOW}No backups found${NC}"
    fi
}

# Restore from backup
restore_backup() {
    local backup_name="$1"
    local backup_dir="$HOME/.claude/agent-11/backups/$backup_name"
    
    if [[ ! -d "$backup_dir" ]]; then
        log "${RED}Backup $backup_name not found${NC}"
        return 1
    fi
    
    log "${BLUE}Restoring from backup: $backup_name${NC}"
    
    # Restore agents
    if [[ -d "$backup_dir/agents" ]]; then
        rm -rf "$HOME/.claude/agents"
        cp -r "$backup_dir/agents" "$HOME/.claude/"
    fi
    
    # Restore configuration
    if [[ -d "$backup_dir/config" ]]; then
        cp -r "$backup_dir/config"/* "$HOME/.claude/agent-11/"
    fi
    
    log "${GREEN}Restore completed${NC}"
}

# Check for updates
check_updates() {
    log "${BLUE}Checking for AGENT-11 updates...${NC}"
    
    local current_version=$(get_current_version)
    local latest_version=$(get_latest_version)
    
    if [[ "$latest_version" == "unknown" ]]; then
        log "${YELLOW}Unable to check for updates (network issue?)${NC}"
        return 1
    fi
    
    update_last_check
    
    if [[ "$current_version" == "unknown" ]]; then
        log "${YELLOW}Current version unknown. Run 'update-manager.sh install' to set up version tracking${NC}"
        return 0
    fi
    
    if version_lt "$current_version" "$latest_version"; then
        log "${GREEN}Update available: $current_version → $latest_version${NC}"
        echo "---"
        echo "Changelog:"
        get_changelog "$latest_version"
        echo "---"
        log "${BLUE}Run 'update-manager.sh update' to install${NC}"
        return 0
    else
        log "${GREEN}AGENT-11 is up to date ($current_version)${NC}"
        return 1
    fi
}

# Install update
install_update() {
    local target_version="$1"
    local current_version=$(get_current_version)
    
    if [[ -z "$target_version" ]]; then
        target_version=$(get_latest_version)
    fi
    
    if [[ "$target_version" == "unknown" ]]; then
        log "${RED}Unable to determine target version${NC}"
        return 1
    fi
    
    log "${BLUE}Installing AGENT-11 $target_version...${NC}"
    
    # Check if backup is enabled
    local config=$(get_update_config)
    local backup_enabled=$(echo "$config" | grep -o '"backup_before_update":[^,}]*' | cut -d':' -f2 | tr -d ' ')
    
    local backup_dir=""
    if [[ "$backup_enabled" == "true" ]]; then
        backup_dir=$(backup_installation)
    fi
    
    # Download and install the installer script
    local temp_installer="/tmp/agent-11-installer-$$.sh"
    curl -sSL "$AGENT11_RAW/deployment/scripts/install.sh" > "$temp_installer"
    
    if [[ ! -f "$temp_installer" ]]; then
        log "${RED}Failed to download installer${NC}"
        return 1
    fi
    
    # Make installer executable
    chmod +x "$temp_installer"
    
    # Run the installer with update flag
    if bash "$temp_installer" update; then
        set_current_version "$target_version"
        log "${GREEN}Successfully updated to AGENT-11 $target_version${NC}"
        
        if [[ -n "$backup_dir" ]]; then
            log "${BLUE}Backup created at: $backup_dir${NC}"
        fi
    else
        log "${RED}Update failed${NC}"
        
        if [[ -n "$backup_dir" ]]; then
            log "${BLUE}Restoring from backup...${NC}"
            restore_backup "$(basename "$backup_dir")"
        fi
        return 1
    fi
    
    # Cleanup
    rm -f "$temp_installer"
}

# Configure update settings
configure() {
    local config=$(get_update_config)
    
    echo -e "${BLUE}Current Configuration:${NC}"
    echo "$config" | grep -E "(auto_check|auto_install|check_frequency|notifications|backup_before_update)" | sed 's/[",]//g' | sed 's/^[ ]*/  /'
    echo
    
    echo -e "${BLUE}Configure Update Settings:${NC}"
    
    # Auto check
    read -p "Enable automatic update checking? (y/n) [y]: " auto_check
    auto_check=${auto_check:-y}
    [[ "$auto_check" =~ ^[Yy] ]] && auto_check="true" || auto_check="false"
    
    # Check frequency
    echo "Update check frequency:"
    echo "  1) Daily"
    echo "  2) Weekly"
    echo "  3) Monthly"
    read -p "Choose (1-3) [2]: " freq_choice
    freq_choice=${freq_choice:-2}
    
    case "$freq_choice" in
        1) check_frequency="daily" ;;
        3) check_frequency="monthly" ;;
        *) check_frequency="weekly" ;;
    esac
    
    # Auto install
    read -p "Enable automatic installation of updates? (y/n) [n]: " auto_install
    auto_install=${auto_install:-n}
    [[ "$auto_install" =~ ^[Yy] ]] && auto_install="true" || auto_install="false"
    
    # Notifications
    read -p "Enable update notifications? (y/n) [y]: " notifications
    notifications=${notifications:-y}
    [[ "$notifications" =~ ^[Yy] ]] && notifications="true" || notifications="false"
    
    # Backup before update
    read -p "Create backup before updates? (y/n) [y]: " backup_updates
    backup_updates=${backup_updates:-y}
    [[ "$backup_updates" =~ ^[Yy] ]] && backup_updates="true" || backup_updates="false"
    
    # Save configuration
    local new_config="{
    \"auto_check\": $auto_check,
    \"auto_install\": $auto_install,
    \"check_frequency\": \"$check_frequency\",
    \"last_check\": $(date +%s),
    \"notifications\": $notifications,
    \"backup_before_update\": $backup_updates
}"
    
    save_update_config "$new_config"
    log "${GREEN}Configuration saved${NC}"
}

# Show status
show_status() {
    local current_version=$(get_current_version)
    local latest_version=$(get_latest_version)
    local config=$(get_update_config)
    
    echo -e "${BLUE}AGENT-11 Update Status${NC}"
    echo "========================"
    echo -e "Current Version: ${GREEN}$current_version${NC}"
    echo -e "Latest Version:  ${GREEN}$latest_version${NC}"
    echo
    
    if [[ "$current_version" != "unknown" ]] && [[ "$latest_version" != "unknown" ]]; then
        if version_lt "$current_version" "$latest_version"; then
            echo -e "Status: ${YELLOW}Update Available${NC}"
        else
            echo -e "Status: ${GREEN}Up to Date${NC}"
        fi
    else
        echo -e "Status: ${YELLOW}Unknown${NC}"
    fi
    
    echo
    echo -e "${BLUE}Configuration:${NC}"
    echo "$config" | grep -E "(auto_check|auto_install|check_frequency|notifications|backup_before_update)" | sed 's/[",]//g' | sed 's/^[ ]*/  /'
}

# Show help
show_help() {
    cat << EOF
AGENT-11 Update Manager

Usage: $0 [command] [options]

Commands:
    check               Check for available updates
    update [version]    Install update (latest or specific version)
    status             Show current status and configuration
    configure          Configure update settings
    backup             Create manual backup
    restore <name>     Restore from backup
    list-backups       List available backups
    schedule           Set up automatic update checking
    help               Show this help message

Examples:
    $0 check                    # Check for updates
    $0 update                   # Update to latest version
    $0 update v2.1.0           # Update to specific version
    $0 configure               # Configure update settings
    $0 restore backup-20240203  # Restore from backup

EOF
}

# Set up automatic checking (via cron)
setup_schedule() {
    local config=$(get_update_config)
    local auto_check=$(echo "$config" | grep -o '"auto_check":[^,}]*' | cut -d':' -f2 | tr -d ' ')
    
    if [[ "$auto_check" != "true" ]]; then
        log "${YELLOW}Automatic checking is disabled. Run 'configure' to enable it.${NC}"
        return 1
    fi
    
    local frequency=$(echo "$config" | grep -o '"check_frequency":[^,]*' | cut -d'"' -f4)
    local cron_schedule
    
    case "$frequency" in
        "daily") cron_schedule="0 9 * * *" ;;
        "weekly") cron_schedule="0 9 * * 1" ;;
        "monthly") cron_schedule="0 9 1 * *" ;;
        *) cron_schedule="0 9 * * 1" ;;
    esac
    
    local cron_command="$0 check >/dev/null 2>&1"
    
    # Add to crontab if not already present
    (crontab -l 2>/dev/null | grep -v "$0 check"; echo "$cron_schedule $cron_command") | crontab -
    
    log "${GREEN}Automatic update checking scheduled ($frequency)${NC}"
}

# Main function
main() {
    setup_directories
    
    case "${1:-help}" in
        "check")
            check_updates
            ;;
        "update")
            install_update "$2"
            ;;
        "status")
            show_status
            ;;
        "configure")
            configure
            ;;
        "backup")
            backup_installation
            ;;
        "restore")
            if [[ -z "$2" ]]; then
                echo "Usage: $0 restore <backup-name>"
                list_backups
                exit 1
            fi
            restore_backup "$2"
            ;;
        "list-backups")
            list_backups
            ;;
        "schedule")
            setup_schedule
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# Run main function with all arguments
main "$@"