#!/bin/bash

# AGENT-11 Backup Manager
# Handles creation, restoration, and management of agent backups

set -euo pipefail

# Configuration
CLAUDE_DIR="$HOME/.claude"
AGENTS_DIR="$CLAUDE_DIR/agents"
BACKUP_DIR="$CLAUDE_DIR/backups/agent-11"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log() { echo -e "${BLUE}[BACKUP]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

# Create timestamped backup
create_backup() {
    local backup_name="${1:-$TIMESTAMP}"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    log "Creating backup: $backup_name"
    
    # Check if agents directory exists
    if [[ ! -d "$AGENTS_DIR" ]]; then
        warn "No agents directory found. Nothing to backup."
        return 0
    fi
    
    # Check if agents directory is empty
    if [[ -z "$(ls -A "$AGENTS_DIR" 2>/dev/null)" ]]; then
        warn "Agents directory is empty. Nothing to backup."
        return 0
    fi
    
    # Create backup directory
    mkdir -p "$backup_path"
    
    # Copy agents with metadata
    if cp -r "$AGENTS_DIR"/* "$backup_path/" 2>/dev/null; then
        # Create backup metadata
        cat > "$backup_path/.backup-info" << EOF
backup_timestamp=$backup_name
backup_date=$(date)
backup_source=$AGENTS_DIR
backup_agent_count=$(find "$AGENTS_DIR" -name "*.md" | wc -l)
backup_total_size=$(du -sh "$AGENTS_DIR" | cut -f1)
EOF
        
        # Update latest backup pointer
        echo "$backup_path" > "$BACKUP_DIR/latest"
        
        success "Backup created: $backup_path"
        return 0
    else
        error "Failed to create backup"
        return 1
    fi
}

# List available backups
list_backups() {
    log "Available backups in $BACKUP_DIR:"
    echo
    
    if [[ ! -d "$BACKUP_DIR" ]]; then
        warn "No backup directory found."
        return 0
    fi
    
    local backups=($(find "$BACKUP_DIR" -maxdepth 1 -type d -name "[0-9]*" | sort -r))
    
    if [[ ${#backups[@]} -eq 0 ]]; then
        warn "No backups found."
        return 0
    fi
    
    printf "%-20s %-20s %-10s %-10s\n" "BACKUP ID" "DATE" "AGENTS" "SIZE"
    printf "%-20s %-20s %-10s %-10s\n" "--------" "----" "------" "----"
    
    for backup in "${backups[@]}"; do
        local backup_id=$(basename "$backup")
        local backup_info="$backup/.backup-info"
        
        if [[ -f "$backup_info" ]]; then
            local agent_count=$(grep "backup_agent_count=" "$backup_info" | cut -d'=' -f2)
            local total_size=$(grep "backup_total_size=" "$backup_info" | cut -d'=' -f2)
            local backup_date=$(grep "backup_date=" "$backup_info" | cut -d'=' -f2-)
            local display_date=$(echo "$backup_date" | cut -d' ' -f1-3)
            
            printf "%-20s %-20s %-10s %-10s\n" "$backup_id" "$display_date" "$agent_count" "$total_size"
        else
            printf "%-20s %-20s %-10s %-10s\n" "$backup_id" "Unknown" "?" "?"
        fi
    done
    
    echo
    if [[ -f "$BACKUP_DIR/latest" ]]; then
        local latest_backup=$(cat "$BACKUP_DIR/latest")
        local latest_id=$(basename "$latest_backup")
        echo "Latest backup: $latest_id"
    fi
}

# Restore from backup
restore_backup() {
    local backup_id="$1"
    local backup_path="$BACKUP_DIR/$backup_id"
    
    if [[ ! -d "$backup_path" ]]; then
        error "Backup not found: $backup_id"
        return 1
    fi
    
    log "Restoring from backup: $backup_id"
    
    # Create safety backup of current state
    if [[ -d "$AGENTS_DIR" && -n "$(ls -A "$AGENTS_DIR" 2>/dev/null)" ]]; then
        local safety_backup="restore-safety-$TIMESTAMP"
        log "Creating safety backup before restore: $safety_backup"
        create_backup "$safety_backup"
    fi
    
    # Remove current agents directory
    rm -rf "$AGENTS_DIR"
    
    # Create new agents directory
    mkdir -p "$AGENTS_DIR"
    
    # Restore from backup
    if cp -r "$backup_path"/* "$AGENTS_DIR/" 2>/dev/null; then
        # Remove backup metadata from restored directory
        rm -f "$AGENTS_DIR/.backup-info"
        
        success "Restore completed from backup: $backup_id"
        
        # Show restored agents
        local restored_count=$(find "$AGENTS_DIR" -name "*.md" | wc -l)
        log "Restored $restored_count agents"
        
        return 0
    else
        error "Failed to restore from backup: $backup_id"
        return 1
    fi
}

# Clean old backups (keep last N backups)
cleanup_backups() {
    local keep_count="${1:-10}"
    
    log "Cleaning up old backups (keeping last $keep_count)..."
    
    if [[ ! -d "$BACKUP_DIR" ]]; then
        warn "No backup directory found."
        return 0
    fi
    
    local backups=($(find "$BACKUP_DIR" -maxdepth 1 -type d -name "[0-9]*" | sort -r))
    local total_backups=${#backups[@]}
    
    if [[ $total_backups -le $keep_count ]]; then
        log "Only $total_backups backups found. No cleanup needed."
        return 0
    fi
    
    local to_delete=$((total_backups - keep_count))
    log "Removing $to_delete old backups..."
    
    for ((i=keep_count; i<total_backups; i++)); do
        local backup_to_delete="${backups[$i]}"
        local backup_id=$(basename "$backup_to_delete")
        log "Removing old backup: $backup_id"
        rm -rf "$backup_to_delete"
    done
    
    success "Cleanup completed. Kept $keep_count most recent backups."
}

# Verify backup integrity
verify_backup() {
    local backup_id="$1"
    local backup_path="$BACKUP_DIR/$backup_id"
    
    if [[ ! -d "$backup_path" ]]; then
        error "Backup not found: $backup_id"
        return 1
    fi
    
    log "Verifying backup integrity: $backup_id"
    
    local issues=()
    
    # Check if backup contains any agents
    local agent_files=($(find "$backup_path" -name "*.md" 2>/dev/null))
    if [[ ${#agent_files[@]} -eq 0 ]]; then
        issues+=("No agent files found in backup")
    fi
    
    # Verify each agent file
    for agent_file in "${agent_files[@]}"; do
        if [[ ! -f "$agent_file" ]]; then
            issues+=("Agent file missing: $(basename "$agent_file")")
            continue
        fi
        
        # Check YAML header
        if ! head -n 10 "$agent_file" | grep -q "^---$"; then
            issues+=("Invalid YAML header: $(basename "$agent_file")")
        fi
        
        # Check file size (should not be empty)
        if [[ ! -s "$agent_file" ]]; then
            issues+=("Empty agent file: $(basename "$agent_file")")
        fi
    done
    
    # Check backup metadata
    if [[ -f "$backup_path/.backup-info" ]]; then
        local expected_count=$(grep "backup_agent_count=" "$backup_path/.backup-info" | cut -d'=' -f2)
        local actual_count=${#agent_files[@]}
        
        if [[ "$expected_count" != "$actual_count" ]]; then
            issues+=("Agent count mismatch: expected $expected_count, found $actual_count")
        fi
    else
        warn "No backup metadata found (older backup format)"
    fi
    
    if [[ ${#issues[@]} -eq 0 ]]; then
        success "Backup verification passed: $backup_id"
        return 0
    else
        error "Backup verification failed: $backup_id"
        for issue in "${issues[@]}"; do
            error "  - $issue"
        done
        return 1
    fi
}

# Display usage information
usage() {
    echo "AGENT-11 Backup Manager"
    echo
    echo "Usage: $0 <command> [options]"
    echo
    echo "Commands:"
    echo "  create [name]     Create backup with optional custom name"
    echo "  list              List all available backups"
    echo "  restore <id>      Restore from backup by ID"
    echo "  cleanup [count]   Remove old backups (keep last N, default: 10)"
    echo "  verify <id>       Verify backup integrity"
    echo
    echo "Examples:"
    echo "  $0 create                    # Create backup with timestamp"
    echo "  $0 create pre-upgrade        # Create backup with custom name"
    echo "  $0 list                      # Show all backups"
    echo "  $0 restore 20240803_143022   # Restore specific backup"
    echo "  $0 cleanup 5                 # Keep only last 5 backups"
    echo "  $0 verify 20240803_143022    # Verify backup integrity"
}

# Main function
main() {
    local command="${1:-}"
    
    case "$command" in
        "create")
            create_backup "${2:-}"
            ;;
        "list")
            list_backups
            ;;
        "restore")
            if [[ -z "${2:-}" ]]; then
                error "Backup ID required for restore command"
                usage
                exit 1
            fi
            restore_backup "$2"
            ;;
        "cleanup")
            cleanup_backups "${2:-10}"
            ;;
        "verify")
            if [[ -z "${2:-}" ]]; then
                error "Backup ID required for verify command"
                usage
                exit 1
            fi
            verify_backup "$2"
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