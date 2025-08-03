#!/bin/bash

# AGENT-11 Environment Validator
# Validates system environment and prerequisites for agent installation

set -euo pipefail

# Configuration
CLAUDE_DIR="$HOME/.claude"
AGENTS_DIR="$CLAUDE_DIR/agents"
MIN_DISK_SPACE_MB=50
MIN_MEMORY_MB=512

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log() { echo -e "${BLUE}[VALIDATE]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

# Validation results
declare -a VALIDATION_ERRORS=()
declare -a VALIDATION_WARNINGS=()
declare -a VALIDATION_INFO=()

# Add validation result
add_error() { VALIDATION_ERRORS+=("$1"); }
add_warning() { VALIDATION_WARNINGS+=("$1"); }
add_info() { VALIDATION_INFO+=("$1"); }

# Platform detection
detect_platform() {
    case "$(uname -s)" in
        Darwin*)    echo "macos" ;;
        Linux*)     echo "linux" ;;
        MINGW*|CYGWIN*|MSYS*) echo "windows" ;;
        *)          echo "unknown" ;;
    esac
}

# Check operating system compatibility
validate_os() {
    local platform
    platform=$(detect_platform)
    
    log "Checking operating system compatibility..."
    
    case "$platform" in
        "macos")
            add_info "Platform: macOS ($(sw_vers -productVersion))"
            ;;
        "linux")
            if command -v lsb_release >/dev/null 2>&1; then
                local distro
                distro=$(lsb_release -d | cut -f2)
                add_info "Platform: Linux ($distro)"
            else
                add_info "Platform: Linux (distribution unknown)"
            fi
            ;;
        "windows")
            add_info "Platform: Windows (WSL/Cygwin/MSYS2)"
            add_warning "Windows support is experimental. Consider using WSL for best results."
            ;;
        "unknown")
            add_error "Unsupported operating system: $(uname -s)"
            ;;
    esac
    
    # Check architecture
    local arch
    arch=$(uname -m)
    case "$arch" in
        x86_64|amd64)
            add_info "Architecture: 64-bit ($arch)"
            ;;
        arm64|aarch64)
            add_info "Architecture: ARM 64-bit ($arch)"
            ;;
        *)
            add_warning "Unusual architecture detected: $arch"
            ;;
    esac
}

# Check required tools and commands
validate_tools() {
    log "Checking required system tools..."
    
    local required_tools=("bash" "cp" "mkdir" "find" "grep" "sed" "date")
    local missing_tools=()
    
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            missing_tools+=("$tool")
        fi
    done
    
    if [[ ${#missing_tools[@]} -eq 0 ]]; then
        add_info "All required tools available: ${required_tools[*]}"
    else
        add_error "Missing required tools: ${missing_tools[*]}"
    fi
    
    # Check optional but useful tools
    local optional_tools=("curl" "wget" "git" "du" "df")
    local available_optional=()
    local missing_optional=()
    
    for tool in "${optional_tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            available_optional+=("$tool")
        else
            missing_optional+=("$tool")
        fi
    done
    
    if [[ ${#available_optional[@]} -gt 0 ]]; then
        add_info "Optional tools available: ${available_optional[*]}"
    fi
    
    if [[ ${#missing_optional[@]} -gt 0 ]]; then
        add_warning "Optional tools missing: ${missing_optional[*]}"
    fi
}

# Check file system permissions
validate_permissions() {
    log "Checking file system permissions..."
    
    # Check home directory write access
    if [[ -w "$HOME" ]]; then
        add_info "Home directory is writable: $HOME"
    else
        add_error "Cannot write to home directory: $HOME"
    fi
    
    # Check if .claude directory exists and permissions
    if [[ -d "$CLAUDE_DIR" ]]; then
        if [[ -w "$CLAUDE_DIR" ]]; then
            add_info "Claude directory is writable: $CLAUDE_DIR"
        else
            add_error "Cannot write to Claude directory: $CLAUDE_DIR"
        fi
    else
        # Try to create .claude directory
        if mkdir -p "$CLAUDE_DIR" 2>/dev/null; then
            add_info "Created Claude directory: $CLAUDE_DIR"
        else
            add_error "Cannot create Claude directory: $CLAUDE_DIR"
        fi
    fi
    
    # Check agents directory
    if [[ -d "$AGENTS_DIR" ]]; then
        if [[ -w "$AGENTS_DIR" ]]; then
            add_info "Agents directory is writable: $AGENTS_DIR"
            
            # Count existing agents
            local existing_agents
            existing_agents=$(find "$AGENTS_DIR" -name "*.md" 2>/dev/null | wc -l)
            if [[ "$existing_agents" -gt 0 ]]; then
                add_info "Existing agents found: $existing_agents"
                add_warning "Installation will backup existing agents before proceeding"
            fi
        else
            add_error "Cannot write to agents directory: $AGENTS_DIR"
        fi
    else
        add_info "Agents directory will be created during installation"
    fi
}

# Check available disk space
validate_disk_space() {
    log "Checking available disk space..."
    
    if command -v df >/dev/null 2>&1; then
        local available_kb
        available_kb=$(df "$HOME" | awk 'NR==2 {print $4}')
        local available_mb=$((available_kb / 1024))
        
        add_info "Available disk space: ${available_mb}MB"
        
        if [[ "$available_mb" -lt "$MIN_DISK_SPACE_MB" ]]; then
            add_error "Insufficient disk space. Required: ${MIN_DISK_SPACE_MB}MB, Available: ${available_mb}MB"
        fi
    else
        add_warning "Cannot check disk space (df command not available)"
    fi
}

# Check available memory
validate_memory() {
    log "Checking available memory..."
    
    local platform
    platform=$(detect_platform)
    
    case "$platform" in
        "macos")
            if command -v vm_stat >/dev/null 2>&1; then
                local free_pages
                free_pages=$(vm_stat | grep "Pages free" | awk '{print $3}' | tr -d '.')
                local free_mb=$((free_pages * 4096 / 1024 / 1024))
                add_info "Available memory: ${free_mb}MB"
                
                if [[ "$free_mb" -lt "$MIN_MEMORY_MB" ]]; then
                    add_warning "Low memory detected. Available: ${free_mb}MB"
                fi
            else
                add_warning "Cannot check memory on macOS"
            fi
            ;;
        "linux")
            if [[ -f "/proc/meminfo" ]]; then
                local available_kb
                available_kb=$(grep "MemAvailable" /proc/meminfo | awk '{print $2}')
                local available_mb=$((available_kb / 1024))
                add_info "Available memory: ${available_mb}MB"
                
                if [[ "$available_mb" -lt "$MIN_MEMORY_MB" ]]; then
                    add_warning "Low memory detected. Available: ${available_mb}MB"
                fi
            else
                add_warning "Cannot check memory on this Linux system"
            fi
            ;;
        *)
            add_warning "Memory check not supported on this platform"
            ;;
    esac
}

# Check shell compatibility
validate_shell() {
    log "Checking shell compatibility..."
    
    # Check if running in bash
    if [[ "${BASH_VERSION:-}" ]]; then
        add_info "Running in Bash version: $BASH_VERSION"
        
        # Check bash version (need 4.0+)
        local bash_major
        bash_major=$(echo "$BASH_VERSION" | cut -d'.' -f1)
        if [[ "$bash_major" -ge 4 ]]; then
            add_info "Bash version is compatible"
        else
            add_warning "Old Bash version detected. Some features may not work."
        fi
    else
        add_warning "Not running in Bash. Compatibility not guaranteed."
    fi
    
    # Check current shell
    local current_shell
    current_shell=$(basename "$SHELL")
    add_info "Default shell: $current_shell"
}

# Check network connectivity (for future remote installations)
validate_network() {
    log "Checking network connectivity..."
    
    if command -v curl >/dev/null 2>&1; then
        if curl -s --connect-timeout 5 https://github.com >/dev/null 2>&1; then
            add_info "Network connectivity: OK"
        else
            add_warning "Limited network connectivity detected"
        fi
    elif command -v wget >/dev/null 2>&1; then
        if wget --timeout=5 --tries=1 -q --spider https://github.com 2>/dev/null; then
            add_info "Network connectivity: OK"
        else
            add_warning "Limited network connectivity detected"
        fi
    else
        add_warning "Cannot test network connectivity (curl/wget not available)"
    fi
}

# Check for conflicting installations
validate_conflicts() {
    log "Checking for potential conflicts..."
    
    # Check for common agent-related directories that might conflict
    local potential_conflicts=(
        "$HOME/.anthropic"
        "$HOME/.openai"
        "$HOME/.ai-agents"
    )
    
    local found_conflicts=()
    for conflict_dir in "${potential_conflicts[@]}"; do
        if [[ -d "$conflict_dir" ]]; then
            found_conflicts+=("$conflict_dir")
        fi
    done
    
    if [[ ${#found_conflicts[@]} -gt 0 ]]; then
        add_warning "Found other AI tool directories: ${found_conflicts[*]}"
        add_info "This should not cause conflicts, but be aware of potential overlap"
    fi
    
    # Check for existing Claude agents with different structure
    if [[ -d "$AGENTS_DIR" ]]; then
        local non_md_files
        non_md_files=$(find "$AGENTS_DIR" -type f ! -name "*.md" 2>/dev/null | wc -l)
        if [[ "$non_md_files" -gt 0 ]]; then
            add_warning "Found non-Markdown files in agents directory"
            add_info "Installation will preserve existing files"
        fi
    fi
}

# Display validation summary
display_results() {
    echo
    echo "===================================="
    echo "AGENT-11 Environment Validation"
    echo "===================================="
    echo
    
    # Display errors
    if [[ ${#VALIDATION_ERRORS[@]} -gt 0 ]]; then
        echo -e "${RED}ERRORS (${#VALIDATION_ERRORS[@]}):${NC}"
        for error in "${VALIDATION_ERRORS[@]}"; do
            echo -e "  ${RED}✗${NC} $error"
        done
        echo
    fi
    
    # Display warnings
    if [[ ${#VALIDATION_WARNINGS[@]} -gt 0 ]]; then
        echo -e "${YELLOW}WARNINGS (${#VALIDATION_WARNINGS[@]}):${NC}"
        for warning in "${VALIDATION_WARNINGS[@]}"; do
            echo -e "  ${YELLOW}⚠${NC} $warning"
        done
        echo
    fi
    
    # Display info
    if [[ ${#VALIDATION_INFO[@]} -gt 0 ]]; then
        echo -e "${GREEN}SYSTEM INFO (${#VALIDATION_INFO[@]}):${NC}"
        for info in "${VALIDATION_INFO[@]}"; do
            echo -e "  ${GREEN}✓${NC} $info"
        done
        echo
    fi
    
    # Overall result
    if [[ ${#VALIDATION_ERRORS[@]} -eq 0 ]]; then
        if [[ ${#VALIDATION_WARNINGS[@]} -eq 0 ]]; then
            echo -e "${GREEN}✓ ENVIRONMENT READY${NC} - All checks passed!"
        else
            echo -e "${YELLOW}⚠ ENVIRONMENT READY WITH WARNINGS${NC} - Installation can proceed"
        fi
        echo
        echo "You can now run the AGENT-11 installation:"
        echo "  ./deployment/scripts/install.sh core"
        return 0
    else
        echo -e "${RED}✗ ENVIRONMENT NOT READY${NC} - Please resolve errors before installation"
        return 1
    fi
}

# Run quick validation (subset of all checks)
quick_validate() {
    log "Running quick validation..."
    validate_os
    validate_permissions
    validate_tools
    display_results
}

# Run full validation
full_validate() {
    log "Running comprehensive environment validation..."
    validate_os
    validate_tools
    validate_permissions
    validate_disk_space
    validate_memory
    validate_shell
    validate_network
    validate_conflicts
    display_results
}

# Fix common issues automatically
auto_fix() {
    log "Attempting to fix common issues..."
    
    local fixes_applied=()
    
    # Create missing directories
    if [[ ! -d "$CLAUDE_DIR" ]]; then
        if mkdir -p "$CLAUDE_DIR" 2>/dev/null; then
            fixes_applied+=("Created Claude directory: $CLAUDE_DIR")
        fi
    fi
    
    if [[ ! -d "$AGENTS_DIR" ]]; then
        if mkdir -p "$AGENTS_DIR" 2>/dev/null; then
            fixes_applied+=("Created agents directory: $AGENTS_DIR")
        fi
    fi
    
    # Fix directory permissions if possible
    if [[ -d "$CLAUDE_DIR" && ! -w "$CLAUDE_DIR" ]]; then
        if chmod u+w "$CLAUDE_DIR" 2>/dev/null; then
            fixes_applied+=("Fixed Claude directory permissions")
        fi
    fi
    
    if [[ ${#fixes_applied[@]} -gt 0 ]]; then
        success "Applied fixes:"
        for fix in "${fixes_applied[@]}"; do
            echo "  ✓ $fix"
        done
        echo
        log "Re-running validation..."
        quick_validate
    else
        warn "No automatic fixes available"
    fi
}

# Display usage information
usage() {
    echo "AGENT-11 Environment Validator"
    echo
    echo "Usage: $0 [command]"
    echo
    echo "Commands:"
    echo "  quick     Quick validation (essential checks only)"
    echo "  full      Full comprehensive validation (default)"
    echo "  fix       Attempt to fix common issues automatically"
    echo
    echo "Examples:"
    echo "  $0                # Run full validation"
    echo "  $0 quick          # Run quick validation"
    echo "  $0 full           # Run comprehensive validation"
    echo "  $0 fix            # Auto-fix issues then validate"
}

# Main function
main() {
    local command="${1:-full}"
    
    case "$command" in
        "quick")
            quick_validate
            ;;
        "full")
            full_validate
            ;;
        "fix")
            auto_fix
            ;;
        "help"|"--help"|"-h")
            usage
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