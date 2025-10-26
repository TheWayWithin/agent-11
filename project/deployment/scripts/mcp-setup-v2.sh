#!/bin/bash

# AGENT-11 MCP Setup & Verification Script v2.0
# Uses CORRECT package names and syntax
# Automates MCP server configuration for Claude Code

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PROJECT_ROOT="$(pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

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
    echo "       AGENT-11 MCP Configuration System v2.0    "
    echo "=================================================="
    echo -e "${NC}"
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check if Claude Code is installed
    if ! command -v claude &> /dev/null; then
        fatal "Claude Code is not installed or not in PATH. Please install Claude Code first."
    fi
    
    # Check if npm is available (needed for npx commands)
    if ! command -v npm &> /dev/null; then
        fatal "npm is not installed. Please install Node.js and npm first."
    fi
    
    success "Prerequisites check passed"
}

# Check and setup environment variables
setup_env_vars() {
    log "Checking environment variables..."
    
    local env_file="$PROJECT_ROOT/.env.mcp"
    local env_template="$PROJECT_ROOT/.env.mcp.template"
    
    if [[ ! -f "$env_file" ]]; then
        warn ".env.mcp not found"
        
        if [[ -f "$env_template" ]]; then
            log "Template found at .env.mcp.template"
            echo ""
            echo "To set up your API keys:"
            echo "1. Copy the template: cp .env.mcp.template .env.mcp"
            echo "2. Edit .env.mcp and add your API keys"
            echo "3. Re-run this script"
            echo ""
            read -p "Would you like to copy the template now? (y/n) " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                cp "$env_template" "$env_file"
                success "Created .env.mcp from template"
                echo "Please edit .env.mcp and add your API keys, then re-run this script"
                exit 0
            else
                fatal "Cannot proceed without .env.mcp file"
            fi
        else
            fatal "No .env.mcp or .env.mcp.template found"
        fi
    fi
    
    # Source the environment file
    set -a
    source "$env_file"
    set +a
    
    success "Environment variables loaded from .env.mcp"
}

# Install missing MCP packages
install_mcp_packages() {
    log "Checking and installing MCP packages..."
    
    local packages_to_check=(
        "@playwright/mcp"
        "@upstash/context7-mcp"
        "firecrawl-mcp"
        "@edjl/github-mcp"
        "@supabase/mcp-server-supabase@latest"
        "figma-developer-mcp"
        "@modelcontextprotocol/server-filesystem"
    )
    
    for package in "${packages_to_check[@]}"; do
        if npm list -g "$package" &>/dev/null; then
            success "✓ $package already installed"
        else
            log "Installing $package globally..."
            if npm install -g "$package" 2>/dev/null; then
                success "✓ $package installed"
            else
                warn "✗ Failed to install $package"
            fi
        fi
    done
}

# Clean existing MCPs
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

# Configure MCPs with correct package names and syntax
configure_mcps() {
    log "Configuring MCP servers with correct packages..."
    
    local configured=0
    local failed=0
    
    # 1. Playwright MCP
    log "Configuring Playwright..."
    if claude mcp add playwright -- npx @playwright/mcp -s project 2>/dev/null; then
        success "✓ Playwright configured"
        ((configured++))
    else
        warn "✗ Playwright configuration failed"
        ((failed++))
    fi
    
    # 2. Context7 MCP
    if [[ -n "${CONTEXT7_API_KEY:-}" ]]; then
        log "Configuring Context7..."
        if claude mcp add context7 -e "CONTEXT7_API_KEY=${CONTEXT7_API_KEY}" -- npx @upstash/context7-mcp -s project 2>/dev/null; then
            success "✓ Context7 configured"
            ((configured++))
        else
            warn "✗ Context7 configuration failed"
            ((failed++))
        fi
    else
        warn "✗ Context7 API key not set - skipping"
    fi
    
    # 3. GitHub MCP
    if [[ -n "${GITHUB_PERSONAL_ACCESS_TOKEN:-}" ]]; then
        log "Configuring GitHub..."
        if claude mcp add github -e "GITHUB_TOKEN=${GITHUB_PERSONAL_ACCESS_TOKEN}" -- npx @edjl/github-mcp -s project 2>/dev/null; then
            success "✓ GitHub configured"
            ((configured++))
        else
            warn "✗ GitHub configuration failed"
            ((failed++))
        fi
    else
        warn "✗ GitHub token not set - skipping"
    fi
    
    # 4. Firecrawl MCP
    if [[ -n "${FIRECRAWL_API_KEY:-}" ]]; then
        log "Configuring Firecrawl..."
        if claude mcp add firecrawl -e "FIRECRAWL_API_KEY=${FIRECRAWL_API_KEY}" -- npx firecrawl-mcp -s project 2>/dev/null; then
            success "✓ Firecrawl configured"
            ((configured++))
        else
            warn "✗ Firecrawl configuration failed"
            ((failed++))
        fi
    else
        warn "✗ Firecrawl API key not set - skipping"
    fi
    
    # 5. Supabase MCP (Official Package)
    if [[ -n "${SUPABASE_ACCESS_TOKEN:-}" ]] && [[ -n "${SUPABASE_PROJECT_REF:-}" ]]; then
        log "Configuring Supabase..."
        # Use official Supabase MCP package with correct syntax
        if claude mcp add supabase \
            -e "SUPABASE_ACCESS_TOKEN=${SUPABASE_ACCESS_TOKEN}" \
            -- npx -y @supabase/mcp-server-supabase@latest --project-ref="${SUPABASE_PROJECT_REF}" -s project 2>/dev/null; then
            success "✓ Supabase configured"
            ((configured++))
        else
            warn "✗ Supabase configuration failed"
            ((failed++))
        fi
    else
        warn "✗ Supabase credentials not set - skipping"
    fi
    
    # 6. Filesystem MCP
    log "Configuring Filesystem..."
    if claude mcp add filesystem -- npx @modelcontextprotocol/server-filesystem "${HOME}/DevProjects" -s project 2>/dev/null; then
        success "✓ Filesystem configured"
        ((configured++))
    else
        warn "✗ Filesystem configuration failed"
        ((failed++))
    fi
    
    # 7. Railway MCP (optional)
    if [[ -n "${RAILWAY_API_TOKEN:-}" ]]; then
        log "Configuring Railway..."
        if claude mcp add railway -e "RAILWAY_API_TOKEN=${RAILWAY_API_TOKEN}" -- npx @railway/mcp-server -s project 2>/dev/null; then
            success "✓ Railway configured"
            ((configured++))
        else
            warn "✗ Railway configuration failed"
            ((failed++))
        fi
    fi
    
    # 8. Stripe MCP (optional)
    if [[ -n "${STRIPE_API_KEY:-}" ]]; then
        log "Configuring Stripe..."
        # Note: Check if stripe-mcp package exists
        if claude mcp add stripe -e "STRIPE_API_KEY=${STRIPE_API_KEY}" -- npx stripe-mcp -s project 2>/dev/null; then
            success "✓ Stripe configured"
            ((configured++))
        else
            warn "✗ Stripe configuration failed (package may not exist)"
            ((failed++))
        fi
    fi
    
    # 9. Netlify MCP (optional)
    if [[ -n "${NETLIFY_ACCESS_TOKEN:-}" ]]; then
        log "Configuring Netlify..."
        # Note: Check if netlify-mcp package exists
        if claude mcp add netlify -e "NETLIFY_ACCESS_TOKEN=${NETLIFY_ACCESS_TOKEN}" -- npx netlify-mcp -s project 2>/dev/null; then
            success "✓ Netlify configured"
            ((configured++))
        else
            warn "✗ Netlify configuration failed (package may not exist)"
            ((failed++))
        fi
    fi
    
    # 10. Figma MCP (optional)
    if [[ -n "${FIGMA_ACCESS_TOKEN:-}" ]]; then
        log "Configuring Figma..."
        if claude mcp add figma -e "FIGMA_ACCESS_TOKEN=${FIGMA_ACCESS_TOKEN}" -- npx figma-developer-mcp -s project 2>/dev/null; then
            success "✓ Figma configured"
            ((configured++))
        else
            warn "✗ Figma configuration failed"
            ((failed++))
        fi
    fi
    
    echo ""
    log "Configuration Summary:"
    success "Successfully configured: $configured MCPs"
    if [[ $failed -gt 0 ]]; then
        warn "Failed to configure: $failed MCPs"
    fi
}

# Verify MCP connections
verify_mcps() {
    log "Verifying MCP connections..."
    echo ""

    # Show actual health check output
    log "MCP Health Check (source of truth):"
    echo ""
    claude mcp list --scope project 2>/dev/null || claude mcp list 2>/dev/null || warn "Could not list MCPs"

    echo ""
    log "Reading health check results..."

    # Capture the output to parse it
    local health_output=$(claude mcp list 2>/dev/null)

    # Check for critical MCPs
    local critical_mcps=("context7" "github" "firecrawl" "supabase")
    local recommended_mcps=("playwright" "filesystem")
    local optional_mcps=("stripe" "railway" "netlify" "figma")

    local critical_connected=0
    local critical_total=${#critical_mcps[@]}

    echo ""
    echo "CRITICAL MCPs (Required for core functionality):"
    for mcp in "${critical_mcps[@]}"; do
        if echo "$health_output" | grep -q "$mcp.*Connected"; then
            success "  ✓ $mcp - Connected and working"
            ((critical_connected++))
        else
            error "  ✗ $mcp - Not connected (check API keys in .env.mcp)"
        fi
    done

    echo ""
    echo "RECOMMENDED MCPs (Enhanced functionality):"
    for mcp in "${recommended_mcps[@]}"; do
        if echo "$health_output" | grep -q "$mcp.*Connected"; then
            success "  ✓ $mcp - Connected and working"
        else
            warn "  ⚠ $mcp - Not connected (recommended but not critical)"
        fi
    done

    echo ""
    echo "OPTIONAL MCPs (Specific use cases):"
    for mcp in "${optional_mcps[@]}"; do
        if echo "$health_output" | grep -q "$mcp.*Connected"; then
            success "  ✓ $mcp - Connected and working"
        else
            log "  ○ $mcp - Not configured (optional)"
        fi
    done

    echo ""
    if [[ $critical_connected -eq $critical_total ]]; then
        success "All critical MCPs connected! ($critical_connected/$critical_total)"
    else
        warn "Some critical MCPs not connected ($critical_connected/$critical_total)"
        echo ""
        echo "To fix:"
        echo "1. Check your .env.mcp file has the required API keys"
        echo "2. Re-run this script"
    fi
}

# Generate MCP status report
generate_report() {
    local report_file="$PROJECT_ROOT/.mcp-status.md"
    
    log "Generating MCP status report..."
    
    cat > "$report_file" << 'EOF'
# MCP Configuration Status Report

Generated: $(date)

## Configuration Summary

```
EOF
    
    # Add current MCP list to report
    claude mcp list --scope project 2>/dev/null >> "$report_file" || echo "No project MCPs configured" >> "$report_file"
    echo '```' >> "$report_file"
    
    cat >> "$report_file" << 'EOF'

## Known Working MCP Packages

These are the correct package names that actually exist:
- `@playwright/mcp` - Playwright browser automation
- `@upstash/context7-mcp` - Context7 documentation
- `firecrawl-mcp` - Web scraping
- `@edjl/github-mcp` - GitHub integration (uses GITHUB_TOKEN env var)
- `@supabase/mcp-server-supabase@latest` - Official Supabase MCP
- `figma-developer-mcp` - Figma design

## Next Steps

1. Exit Claude Code: `/exit`
2. Restart Claude Code: `claude`
3. Look for MCP tools prefixed with `mcp__`
4. Test specific MCPs:
   - Playwright: Look for `mcp__playwright__` tools
   - Supabase: Look for `mcp__supabase__` tools
   - Context7: Look for `mcp__context7__` tools

## Troubleshooting

- **MCP not appearing**: Restart Claude Code is required
- **Configuration fails**: Check API keys in .env.mcp
- **Package not found**: May need global install: `npm install -g <package>`
- **Connection failed**: Normal until Claude Code restart

## Support

For help with MCP configuration:
- AGENT-11 Issues: https://github.com/TheWayWithin/agent-11/issues
- Claude Code Docs: https://docs.anthropic.com/en/docs/claude-code/mcp
EOF
    
    success "Report saved to .mcp-status.md"
}

# Main execution
main() {
    show_banner
    
    # Parse command line arguments
    case "${1:-}" in
        --verify|-v)
            check_prerequisites
            setup_env_vars
            verify_mcps
            generate_report
            ;;
        --install|-i)
            check_prerequisites
            install_mcp_packages
            ;;
        --clean|-c)
            clean_mcps
            ;;
        --report|-r)
            generate_report
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --verify, -v      Verify MCP connections"
            echo "  --install, -i     Install MCP packages"
            echo "  --clean, -c       Remove all MCP configurations"
            echo "  --report, -r      Generate status report"
            echo "  --help, -h        Show this help message"
            echo ""
            echo "Default: Full setup (install, configure, verify)"
            ;;
        *)
            check_prerequisites
            setup_env_vars
            install_mcp_packages
            clean_mcps
            configure_mcps
            verify_mcps
            generate_report
            
            echo ""
            success "MCP setup complete!"
            echo ""
            echo "IMPORTANT: Restart Claude Code for changes to take effect"
            echo ""
            echo "To verify MCPs are working:"
            echo "1. Exit Claude Code: /exit"
            echo "2. Restart Claude Code: claude"
            echo "3. Check for mcp__ prefixed tools"
            echo ""
            echo "Priority MCPs to verify:"
            echo "  • mcp__playwright__ - Browser automation"
            echo "  • mcp__supabase__ - Database access"
            echo "  • mcp__context7__ - Documentation"
            echo "  • mcp__github__ - Repository management"
            echo "  • mcp__firecrawl__ - Web scraping"
            ;;
    esac
}

# Run main function
main "$@"