#!/bin/bash

# AGENT-11 MCP Fix Script
# Corrects MCP configuration issues and verifies connectivity

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PROJECT_ROOT="$(pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Logging functions
log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
fatal() { error "$1"; exit 1; }

# Banner
show_banner() {
    echo -e "${CYAN}"
    echo "=================================================="
    echo "         AGENT-11 MCP Fix & Verification         "
    echo "=================================================="
    echo -e "${NC}"
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    if ! command -v claude &> /dev/null; then
        fatal "Claude Code is not installed or not in PATH"
    fi
    
    if ! command -v npm &> /dev/null; then
        fatal "npm is not installed. Please install Node.js first"
    fi
    
    success "Prerequisites check passed"
}

# Load environment variables
load_env() {
    local env_file="$PROJECT_ROOT/.env.mcp"
    
    if [[ ! -f "$env_file" ]]; then
        error ".env.mcp not found!"
        return 1
    fi
    
    set -a
    source "$env_file"
    set +a
    
    success "Environment variables loaded"
}

# Remove all existing MCPs for clean slate
clean_mcps() {
    log "Cleaning existing MCP configurations..."
    
    local mcps=(
        "supabase" "playwright" "context7" "firecrawl" 
        "github" "stripe" "netlify" "figma" "railway" "filesystem"
    )
    
    for mcp in "${mcps[@]}"; do
        claude mcp remove "$mcp" -s project 2>/dev/null || true
    done
    
    success "Cleaned existing MCP configurations"
}

# Configure MCPs with correct syntax
configure_mcps() {
    log "Configuring MCPs with corrected settings..."
    
    local configured=0
    local failed=0
    
    # 1. Playwright MCP (Priority)
    log "Configuring Playwright..."
    if claude mcp add playwright "npx" "@modelcontextprotocol/server-playwright" -s project 2>/dev/null; then
        success "✓ Playwright configured"
        ((configured++))
    else
        warn "✗ Playwright configuration failed"
        ((failed++))
    fi
    
    # 2. Supabase MCP (Priority) - Direct .mcp.json edit required
    log "Configuring Supabase (manual)..."
    # We'll handle this separately
    
    # 3. Context7 MCP
    if [[ -n "${CONTEXT7_API_KEY:-}" ]]; then
        log "Configuring Context7..."
        if claude mcp add context7 "npx" "@context7/mcp-server" \
            -e "CONTEXT7_API_KEY=${CONTEXT7_API_KEY}" \
            -s project 2>/dev/null; then
            success "✓ Context7 configured"
            ((configured++))
        else
            warn "✗ Context7 configuration failed"
            ((failed++))
        fi
    fi
    
    # 4. GitHub MCP
    if [[ -n "${GITHUB_PERSONAL_ACCESS_TOKEN:-}" ]]; then
        log "Configuring GitHub..."
        if claude mcp add github "npx" "@modelcontextprotocol/server-github" \
            -e "GITHUB_PERSONAL_ACCESS_TOKEN=${GITHUB_PERSONAL_ACCESS_TOKEN}" \
            -s project 2>/dev/null; then
            success "✓ GitHub configured"
            ((configured++))
        else
            warn "✗ GitHub configuration failed"
            ((failed++))
        fi
    fi
    
    # 5. Firecrawl MCP
    if [[ -n "${FIRECRAWL_API_KEY:-}" ]]; then
        log "Configuring Firecrawl..."
        if claude mcp add firecrawl "npx" "@mendable/firecrawl-mcp" \
            -e "FIRECRAWL_API_KEY=${FIRECRAWL_API_KEY}" \
            -s project 2>/dev/null; then
            success "✓ Firecrawl configured"
            ((configured++))
        else
            warn "✗ Firecrawl configuration failed"
            ((failed++))
        fi
    fi
    
    # 6. Filesystem MCP
    log "Configuring Filesystem..."
    if claude mcp add filesystem "npx" "@modelcontextprotocol/server-filesystem" "${HOME}/DevProjects" \
        -s project 2>/dev/null; then
        success "✓ Filesystem configured"
        ((configured++))
    else
        warn "✗ Filesystem configuration failed"
        ((failed++))
    fi
    
    echo ""
    log "Configuration Summary:"
    success "Successfully configured: $configured MCPs"
    if [[ $failed -gt 0 ]]; then
        warn "Failed to configure: $failed MCPs"
    fi
}

# Manually add Supabase to .mcp.json
add_supabase_manually() {
    log "Adding Supabase MCP manually to .mcp.json..."
    
    if [[ -n "${SUPABASE_ACCESS_TOKEN:-}" ]] && [[ -n "${SUPABASE_PROJECT_REF:-}" ]]; then
        # Check if .mcp.json exists
        if [[ -f "$PROJECT_ROOT/.mcp.json" ]]; then
            # Create temporary file with Supabase added
            cat > "$PROJECT_ROOT/.mcp.json.tmp" << EOF
{
  "mcpServers": {
    "supabase": {
      "type": "stdio",
      "command": "npx",
      "args": [
        "@supabase/mcp-server",
        "--access-token",
        "${SUPABASE_ACCESS_TOKEN}",
        "--project-ref",
        "${SUPABASE_PROJECT_REF}"
      ],
      "env": {}
    }
  }
}
EOF
            
            # Merge with existing .mcp.json if it has content
            if command -v jq &> /dev/null; then
                jq -s '.[0] * .[1]' "$PROJECT_ROOT/.mcp.json" "$PROJECT_ROOT/.mcp.json.tmp" > "$PROJECT_ROOT/.mcp.json.new"
                mv "$PROJECT_ROOT/.mcp.json.new" "$PROJECT_ROOT/.mcp.json"
                rm "$PROJECT_ROOT/.mcp.json.tmp"
                success "✓ Supabase added to .mcp.json"
            else
                warn "jq not available, manual merge required for Supabase"
            fi
        fi
    else
        warn "Supabase credentials not available"
    fi
}

# Verify MCP connectivity
verify_mcps() {
    log "Verifying MCP connections..."
    echo ""
    
    # Get current status
    local status=$(claude mcp list 2>&1)
    
    # Check specific MCPs
    echo -e "${CYAN}=== Priority MCPs ===${NC}"
    
    # Playwright
    if echo "$status" | grep -q "playwright.*✓ Connected"; then
        success "✓ Playwright - Connected"
    else
        error "✗ Playwright - Not connected"
    fi
    
    # Supabase
    if echo "$status" | grep -q "supabase.*✓ Connected"; then
        success "✓ Supabase - Connected"
    else
        error "✗ Supabase - Not connected"
    fi
    
    # Context7
    if echo "$status" | grep -q "context7.*✓ Connected"; then
        success "✓ Context7 - Connected"
    else
        warn "⚠ Context7 - Not connected"
    fi
    
    # GitHub
    if echo "$status" | grep -q "github.*✓ Connected"; then
        success "✓ GitHub - Connected"
    else
        warn "⚠ GitHub - Not connected"
    fi
    
    # Firecrawl
    if echo "$status" | grep -q "firecrawl.*✓ Connected"; then
        success "✓ Firecrawl - Connected"
    else
        warn "⚠ Firecrawl - Not connected"
    fi
    
    echo ""
    echo -e "${CYAN}=== Full MCP Status ===${NC}"
    claude mcp list
}

# Generate diagnostic report
generate_report() {
    local report_file="$PROJECT_ROOT/.mcp-diagnostic.md"
    
    log "Generating diagnostic report..."
    
    cat > "$report_file" << EOF
# MCP Diagnostic Report

Generated: $(date)

## Environment Check

- Claude Code: $(command -v claude &>/dev/null && echo "✓ Installed" || echo "✗ Not found")
- npm: $(command -v npm &>/dev/null && echo "✓ Installed" || echo "✗ Not found")
- .env.mcp: $([ -f .env.mcp ] && echo "✓ Found" || echo "✗ Missing")
- .mcp.json: $([ -f .mcp.json ] && echo "✓ Found" || echo "✗ Missing")

## MCP Configuration

\`\`\`json
$(cat .mcp.json 2>/dev/null || echo "No .mcp.json found")
\`\`\`

## Connection Status

\`\`\`
$(claude mcp list 2>&1)
\`\`\`

## Troubleshooting Steps

1. **If MCPs aren't connecting:**
   - Exit Claude Code: \`/exit\`
   - Restart: \`claude\`
   - Check for mcp__ prefixed tools

2. **If Playwright/Supabase specifically fail:**
   - Verify npm packages are accessible
   - Check API keys in .env.mcp
   - Try manual installation: \`npm install -g @modelcontextprotocol/server-playwright\`

3. **For persistent issues:**
   - Clear npm cache: \`npm cache clean --force\`
   - Reinstall Claude Code
   - Check network/firewall settings
EOF
    
    success "Diagnostic report saved to .mcp-diagnostic.md"
}

# Main execution
main() {
    show_banner
    
    case "${1:-fix}" in
        fix)
            check_prerequisites
            load_env || fatal "Cannot proceed without environment variables"
            clean_mcps
            configure_mcps
            add_supabase_manually
            verify_mcps
            generate_report
            
            echo ""
            success "MCP fix attempt complete!"
            echo ""
            echo "NEXT STEPS:"
            echo "1. Exit Claude Code: /exit"
            echo "2. Restart: claude"
            echo "3. Check for mcp__ tools"
            echo ""
            echo "If issues persist, check .mcp-diagnostic.md for details"
            ;;
            
        verify)
            verify_mcps
            generate_report
            ;;
            
        clean)
            clean_mcps
            ;;
            
        report)
            generate_report
            ;;
            
        *)
            echo "Usage: $0 [fix|verify|clean|report]"
            echo "  fix    - Clean and reconfigure all MCPs (default)"
            echo "  verify - Check current MCP status"
            echo "  clean  - Remove all MCP configurations"
            echo "  report - Generate diagnostic report"
            ;;
    esac
}

# Run main function
main "$@"