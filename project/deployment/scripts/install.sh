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

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="$BACKUP_DIR/$TIMESTAMP"

# GitHub repository configuration
GITHUB_REPO="TheWayWithin/agent-11"
GITHUB_BRANCH="main"
GITHUB_AGENTS_PATH="project/agents/specialists"
GITHUB_RAW_BASE="https://raw.githubusercontent.com/$GITHUB_REPO/$GITHUB_BRANCH/$GITHUB_AGENTS_PATH"
GITHUB_REPO_BASE="https://raw.githubusercontent.com/$GITHUB_REPO/$GITHUB_BRANCH"


# Available squads
SQUAD_CORE=("strategist" "developer" "tester" "operator")
SQUAD_FULL=("strategist" "developer" "tester" "operator" "architect" "designer" "documenter" "support" "analyst" "marketer" "coordinator")
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

# Install CLAUDE.md file with context preservation instructions
# Uses template approach to never overwrite existing CLAUDE.md files
install_claude_md() {
    local execution_mode
    execution_mode=$(detect_execution_mode)

    log "Installing AGENT-11 CLAUDE.md template..."

    local dest_file="$(pwd)/CLAUDE.md"
    local template_file="$(pwd)/CLAUDE-AGENT11-TEMPLATE.md"
    local backup_file="$(pwd)/CLAUDE.md.backup-$(date +%Y%m%d_%H%M%S)"

    # Always install/update the template file
    if [[ "$execution_mode" == "local" ]]; then
        local source_file="$PROJECT_ROOT/CLAUDE.md"
        if [[ -f "$source_file" ]]; then
            if cp "$source_file" "$template_file"; then
                log "AGENT-11 template installed: CLAUDE-AGENT11-TEMPLATE.md"
            else
                error "Failed to install AGENT-11 template"
                return 1
            fi
        else
            error "CLAUDE.md not found in project root"
            return 1
        fi
    else
        # Remote installation - download from GitHub
        if download_file_from_github "CLAUDE.md" "$template_file"; then
            log "AGENT-11 template downloaded: CLAUDE-AGENT11-TEMPLATE.md"
        else
            error "Failed to download AGENT-11 template from GitHub"
            return 1
        fi
    fi

    # Check if CLAUDE.md already exists
    if [[ -f "$dest_file" ]]; then
        # Existing CLAUDE.md found - preserve it
        warn "Existing CLAUDE.md detected - preserving your custom instructions"

        # Create backup for safety
        if cp "$dest_file" "$backup_file"; then
            log "Safety backup created: $backup_file"
        fi

        success "Your existing CLAUDE.md has been preserved"
        echo ""
        echo -e "${BLUE}📝 AGENT-11 Integration Instructions:${NC}"
        echo "  1. Review AGENT-11 features: cat CLAUDE-AGENT11-TEMPLATE.md"
        echo "  2. Your current instructions: $dest_file"
        echo "  3. Your backup (safety): $backup_file"
        echo ""
        echo -e "${YELLOW}To add AGENT-11 capabilities to your project:${NC}"
        echo "  • Copy relevant sections from CLAUDE-AGENT11-TEMPLATE.md"
        echo "  • Paste into your CLAUDE.md where appropriate"
        echo "  • Or append entire template: cat CLAUDE-AGENT11-TEMPLATE.md >> CLAUDE.md"
        echo ""

        return 0
    else
        # No existing CLAUDE.md - safe to create from template
        if cp "$template_file" "$dest_file"; then
            success "Created CLAUDE.md from AGENT-11 template"
            log "Template also available at: CLAUDE-AGENT11-TEMPLATE.md"
            return 0
        else
            error "Failed to create CLAUDE.md from template"
            return 1
        fi
    fi
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
        "project/commands/planarchive.md"
    )
    
    # Define template files to install
    local template_files=(
        "project/templates/mission-template.md"
        "project/templates/agent-creation-mastery.md"
        "templates/architecture-template.md"
        "templates/product-description-template.md"
        "templates/agent-context-template.md"
        "templates/handoff-notes-template.md"
        "templates/evidence-repository-template.md"
        "templates/project-plan-template.md"
        "templates/progress-template.md"
        "templates/lessons-index-template.md"
        "templates/lesson-template.md"
        "templates/cleanup-checklist.md"
        "templates/claude-template.md"
    )
    
    # Define field manual files to install
    local field_manual_files=(
        "project/field-manual/architecture-sop.md"
        "project/field-manual/project-lifecycle-guide.md"
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

    # Install command scripts (enhancement scripts, utilities, etc.)
    log "Installing command support scripts..."
    mkdir -p "$COMMANDS_DIR/scripts"

    if [[ "$execution_mode" == "local" ]]; then
        if [[ -f "$PROJECT_ROOT/project/commands/scripts/enhance_dailyreport.py" ]]; then
            if cp "$PROJECT_ROOT/project/commands/scripts/enhance_dailyreport.py" "$COMMANDS_DIR/scripts/"; then
                chmod +x "$COMMANDS_DIR/scripts/enhance_dailyreport.py"
                log "Installed: enhance_dailyreport.py script"
            else
                warn "Could not install enhance_dailyreport.py script"
            fi
        fi
    else
        # Remote installation
        if download_file_from_github "project/commands/scripts/enhance_dailyreport.py" "$COMMANDS_DIR/scripts/enhance_dailyreport.py"; then
            chmod +x "$COMMANDS_DIR/scripts/enhance_dailyreport.py"
            log "Installed: enhance_dailyreport.py script"
        else
            warn "Could not download enhance_dailyreport.py script"
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
    
    if [[ ${#failed_files[@]} -eq 0 ]]; then
        success "Mission system installed successfully!"
        return 0
    else
        error "Failed to install mission system files: ${failed_files[*]}"
        return 1
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
    local template_files=("mission-template.md" "agent-creation-mastery.md" "architecture-template.md" "product-description-template.md" "agent-context-template.md" "handoff-notes-template.md" "evidence-repository-template.md")
    for template_file in "${template_files[@]}"; do
        if [[ ! -f "$TEMPLATES_DIR/$template_file" ]]; then
            missing_items+=("template:$template_file")
        fi
    done
    
    # Verify field manual files
    if [[ ! -f "$FIELD_MANUAL_DIR/architecture-sop.md" ]]; then
        missing_items+=("field-manual:architecture-sop.md")
    fi
    
    # Verify CLAUDE.md template file (always created)
    if [[ ! -f "$(pwd)/CLAUDE-AGENT11-TEMPLATE.md" ]]; then
        missing_items+=("system:CLAUDE-AGENT11-TEMPLATE.md")
    fi

    # Note: CLAUDE.md itself may not exist if user already had one (preserved)
    
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

    log "Installing MCP profile system..."

    local TARGET_DIR="$(pwd)"

    # Copy MCP profile directory
    if [[ "$execution_mode" == "local" ]]; then
        if [[ -d "$PROJECT_ROOT/.mcp-profiles" ]]; then
            log "Installing MCP profiles from local repository..."
            cp -r "$PROJECT_ROOT/.mcp-profiles" "$TARGET_DIR/"
            success "MCP profiles installed (7 profiles)"
        else
            warn "MCP profiles not found in local repository"
        fi
    else
        # Remote installation - download profiles
        log "Downloading MCP profiles from GitHub..."
        mkdir -p "$TARGET_DIR/.mcp-profiles"

        local profiles=("core" "testing" "database-staging" "database-production" "payments" "deployment" "fullstack")
        for profile in "${profiles[@]}"; do
            if download_file_from_github ".mcp-profiles/${profile}.json" "$TARGET_DIR/.mcp-profiles/${profile}.json"; then
                log "Downloaded profile: ${profile}.json"
            else
                warn "Failed to download profile: ${profile}.json"
            fi
        done
    fi

    # Copy MCP documentation
    if [[ "$execution_mode" == "local" ]]; then
        if [[ -d "$PROJECT_ROOT/docs" ]]; then
            log "Installing MCP documentation from local repository..."
            mkdir -p "$TARGET_DIR/docs"

            if [[ -f "$PROJECT_ROOT/docs/MCP-GUIDE.md" ]]; then
                cp "$PROJECT_ROOT/docs/MCP-GUIDE.md" "$TARGET_DIR/docs/"
                cp "$PROJECT_ROOT/docs/MCP-PROFILES.md" "$TARGET_DIR/docs/"
                cp "$PROJECT_ROOT/docs/MCP-TROUBLESHOOTING.md" "$TARGET_DIR/docs/"
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
    fi

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
    echo "   # Option 1: Mission Command (Recommended)"
    echo "   /coord build requirements.md           # Build feature from requirements"
    echo "   /coord fix bug-report.md              # Fix a bug quickly"
    echo "   /coord mvp product-vision.md          # Create an MVP from concept"
    echo "   /coord                                # Interactive mission selection"
    echo
    echo "   # Option 2: Direct Agent Commands"
    
    case "$squad_type" in
        "core")
            echo "   @strategist Create user stories for a user authentication feature"
            echo "   @developer Implement the authentication based on the requirements above"
            echo "   @tester Validate the implementation and create test cases"
            echo "   @operator Deploy to production when tests pass"
            ;;
        "minimal")
            echo "   @strategist Define requirements for [your feature]"
            echo "   @developer Implement based on the requirements"
            ;;
        *)
            echo "   @coordinator Plan and orchestrate multi-agent workflows"
            echo "   @strategist Create user stories for complex features"
            echo "   @architect Design system architecture"
            echo "   @developer Implement features with full-stack expertise"
            ;;
    esac
    
    echo -e "${BLUE}📚 Next Steps${NC}"
    echo "  • Your agents and mission system are ready to use"
    echo "  • Try the /coord command for systematic workflows"
    echo "  • Explore missions in the /missions directory"
    echo "  • Create custom missions using /templates"
    echo "  • Documentation: https://github.com/TheWayWithin/agent-11"
    echo

    echo -e "${BLUE}🔧 MCP Profile System Installed!${NC}"
    echo "  ✓ 7 specialized profiles in .mcp-profiles/"
    echo "  ✓ MCP documentation in docs/"
    echo "  ✓ Environment template: .env.mcp.template"
    echo
    echo "  📝 Setup MCPs in 3 steps:"
    echo "     1. cp .env.mcp.template .env.mcp"
    echo "     2. Edit .env.mcp with your API keys"
    echo "     3. Choose profile: ln -sf .mcp-profiles/core.json .mcp.json"
    echo "     4. Restart Claude Code"
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
        install_claude_md &&
        install_mission_system &&
        install_mcp_system &&
        verify_installation "$squad_type" &&
        setup_mcp_configuration
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