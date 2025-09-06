#!/bin/bash

# AGENT-11 MCP Setup & Verification Script
# Automates MCP server configuration for Claude Code
# Ensures all agents have access to required tools

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
# Use current directory as PROJECT_ROOT for MCP setup
PROJECT_ROOT="$(pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

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

# Banner
show_banner() {
    echo -e "${CYAN}"
    echo "=================================================="
    echo "       AGENT-11 MCP Configuration System         "
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
    
    # Check if .mcp.json exists
    if [[ ! -f "$PROJECT_ROOT/.mcp.json" ]]; then
        error ".mcp.json not found in project root"
        log "Creating .mcp.json from template..."
        # The .mcp.json should already exist from our previous step
        fatal "Please ensure .mcp.json exists in the project root"
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

# Detect available MCPs
detect_mcps() {
    log "Detecting currently configured MCP servers..."
    
    # Try to list current MCP servers
    if claude mcp list 2>/dev/null | grep -q "mcpServers"; then
        log "Found existing MCP configurations:"
        claude mcp list
    else
        warn "No MCP servers currently configured"
    fi
}

# Configure MCP servers
configure_mcps() {
    log "Configuring MCP servers from .mcp.json..."
    
    local mcp_json="$PROJECT_ROOT/.mcp.json"
    
    # Parse MCP servers from .mcp.json
    if command -v jq &> /dev/null; then
        # Use jq if available
        local servers=$(jq -r '.mcpServers | keys[]' "$mcp_json" 2>/dev/null)
    else
        # Fallback to grep/sed
        local servers=$(grep '"mcpServers"' -A 100 "$mcp_json" | grep -o '"[^"]*":' | sed 's/"//g' | sed 's/://g' | grep -v mcpServers)
    fi
    
    if [[ -z "$servers" ]]; then
        error "No MCP servers found in .mcp.json"
        return 1
    fi
    
    echo ""
    echo "Found MCP server configurations:"
    echo "$servers" | while read -r server; do
        echo "  - $server"
    done
    echo ""
    
    # Configure each server
    local configured=0
    local failed=0
    
    for server in $servers; do
        log "Configuring $server..."
        
        case $server in
            context7)
                if [[ -n "${CONTEXT7_API_KEY:-}" ]]; then
                    claude mcp add context7 --transport stdio \
                        --command "npx" \
                        --args "@context7/mcp-server" \
                        --env "CONTEXT7_API_KEY=$CONTEXT7_API_KEY" \
                        --scope project 2>/dev/null && {
                        success "✓ Context7 MCP configured"
                        ((configured++))
                    } || {
                        warn "✗ Context7 MCP configuration failed"
                        ((failed++))
                    }
                else
                    warn "✗ Context7 API key not set - skipping"
                fi
                ;;
                
            github)
                if [[ -n "${GITHUB_PERSONAL_ACCESS_TOKEN:-}" ]]; then
                    claude mcp add github --transport stdio \
                        --command "npx" \
                        --args "@modelcontextprotocol/server-github" \
                        --env "GITHUB_PERSONAL_ACCESS_TOKEN=$GITHUB_PERSONAL_ACCESS_TOKEN" \
                        --scope project 2>/dev/null && {
                        success "✓ GitHub MCP configured"
                        ((configured++))
                    } || {
                        warn "✗ GitHub MCP configuration failed"
                        ((failed++))
                    }
                else
                    warn "✗ GitHub token not set - skipping"
                fi
                ;;
                
            firecrawl)
                if [[ -n "${FIRECRAWL_API_KEY:-}" ]]; then
                    claude mcp add firecrawl --transport stdio \
                        --command "npx" \
                        --args "@mendable/firecrawl-mcp" \
                        --env "FIRECRAWL_API_KEY=$FIRECRAWL_API_KEY" \
                        --scope project 2>/dev/null && {
                        success "✓ Firecrawl MCP configured"
                        ((configured++))
                    } || {
                        warn "✗ Firecrawl MCP configuration failed"
                        ((failed++))
                    }
                else
                    warn "✗ Firecrawl API key not set - skipping"
                fi
                ;;
                
            supabase)
                if [[ -n "${SUPABASE_ACCESS_TOKEN:-}" ]] && [[ -n "${SUPABASE_PROJECT_REF:-}" ]]; then
                    claude mcp add supabase --transport stdio \
                        --command "npx" \
                        --args "@supabase/mcp-server" "--access-token" "$SUPABASE_ACCESS_TOKEN" "--project-ref" "$SUPABASE_PROJECT_REF" \
                        --scope project 2>/dev/null && {
                        success "✓ Supabase MCP configured"
                        ((configured++))
                    } || {
                        warn "✗ Supabase MCP configuration failed"
                        ((failed++))
                    }
                else
                    warn "✗ Supabase credentials not set - skipping"
                fi
                ;;
                
            playwright)
                claude mcp add playwright --transport stdio \
                    --command "npx" \
                    --args "@modelcontextprotocol/server-playwright" \
                    --scope project 2>/dev/null && {
                    success "✓ Playwright MCP configured"
                    ((configured++))
                } || {
                    warn "✗ Playwright MCP configuration failed"
                    ((failed++))
                }
                ;;
                
            filesystem)
                claude mcp add filesystem --transport stdio \
                    --command "npx" \
                    --args "@modelcontextprotocol/server-filesystem" "$HOME/DevProjects" \
                    --scope project 2>/dev/null && {
                    success "✓ Filesystem MCP configured"
                    ((configured++))
                } || {
                    warn "✗ Filesystem MCP configuration failed"
                    ((failed++))
                }
                ;;
                
            railway)
                if [[ -n "${RAILWAY_API_TOKEN:-}" ]]; then
                    claude mcp add railway --transport stdio \
                        --command "npx" \
                        --args "@railway/mcp-server" \
                        --env "RAILWAY_API_TOKEN=$RAILWAY_API_TOKEN" \
                        --scope project 2>/dev/null && {
                        success "✓ Railway MCP configured"
                        ((configured++))
                    } || {
                        warn "✗ Railway MCP configuration failed"
                        ((failed++))
                    }
                else
                    warn "✗ Railway API token not set - skipping"
                fi
                ;;
                
            stripe)
                if [[ -n "${STRIPE_API_KEY:-}" ]]; then
                    claude mcp add stripe --transport stdio \
                        --command "npx" \
                        --args "@stripe/mcp-server" \
                        --env "STRIPE_API_KEY=$STRIPE_API_KEY" \
                        --scope project 2>/dev/null && {
                        success "✓ Stripe MCP configured"
                        ((configured++))
                    } || {
                        warn "✗ Stripe MCP configuration failed"
                        ((failed++))
                    }
                else
                    warn "✗ Stripe API key not set - skipping (optional)"
                fi
                ;;
                
            netlify)
                if [[ -n "${NETLIFY_ACCESS_TOKEN:-}" ]]; then
                    claude mcp add netlify --transport stdio \
                        --command "npx" \
                        --args "@netlify/mcp-server" \
                        --env "NETLIFY_ACCESS_TOKEN=$NETLIFY_ACCESS_TOKEN" \
                        --scope project 2>/dev/null && {
                        success "✓ Netlify MCP configured"
                        ((configured++))
                    } || {
                        warn "✗ Netlify MCP configuration failed"
                        ((failed++))
                    }
                else
                    warn "✗ Netlify token not set - skipping (optional)"
                fi
                ;;
                
            figma)
                if [[ -n "${FIGMA_ACCESS_TOKEN:-}" ]]; then
                    claude mcp add figma --transport stdio \
                        --command "npx" \
                        --args "@figma/mcp-server" \
                        --env "FIGMA_ACCESS_TOKEN=$FIGMA_ACCESS_TOKEN" \
                        --scope project 2>/dev/null && {
                        success "✓ Figma MCP configured"
                        ((configured++))
                    } || {
                        warn "✗ Figma MCP configuration failed"
                        ((failed++))
                    }
                else
                    warn "✗ Figma token not set - skipping (optional)"
                fi
                ;;
                
            *)
                warn "Unknown MCP server: $server"
                ;;
        esac
    done
    
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
    
    # List configured MCPs
    log "Currently configured MCP servers:"
    claude mcp list --scope project 2>/dev/null || warn "Could not list project MCPs"
    
    echo ""
    log "MCP Verification Status:"
    
    # Check for critical MCPs
    local critical_mcps=("context7" "github" "firecrawl" "supabase")
    local recommended_mcps=("playwright" "filesystem")
    local optional_mcps=("stripe" "railway" "netlify" "figma")
    
    echo ""
    echo "CRITICAL MCPs (Required for core functionality):"
    for mcp in "${critical_mcps[@]}"; do
        if claude mcp list 2>/dev/null | grep -q "$mcp"; then
            success "  ✓ $mcp - Connected"
        else
            error "  ✗ $mcp - Not connected"
        fi
    done
    
    echo ""
    echo "RECOMMENDED MCPs (Enhanced functionality):"
    for mcp in "${recommended_mcps[@]}"; do
        if claude mcp list 2>/dev/null | grep -q "$mcp"; then
            success "  ✓ $mcp - Connected"
        else
            warn "  ⚠ $mcp - Not connected"
        fi
    done
    
    echo ""
    echo "OPTIONAL MCPs (Specific use cases):"
    for mcp in "${optional_mcps[@]}"; do
        if claude mcp list 2>/dev/null | grep -q "$mcp"; then
            success "  ✓ $mcp - Connected"
        else
            log "  ○ $mcp - Not connected (optional)"
        fi
    done
}

# Generate MCP status report
generate_report() {
    local report_file="$PROJECT_ROOT/.mcp-status.md"
    
    log "Generating MCP status report..."
    
    cat > "$report_file" << 'EOF'
# MCP Configuration Status Report

Generated: $(date)

## Configuration Summary

EOF
    
    # Add current MCP list to report
    echo '```' >> "$report_file"
    claude mcp list --scope project 2>/dev/null >> "$report_file" || echo "No MCPs configured" >> "$report_file"
    echo '```' >> "$report_file"
    
    cat >> "$report_file" << 'EOF'

## Next Steps

1. If MCPs are missing, check your .env.mcp file for API keys
2. Re-run `./project/deployment/scripts/mcp-setup.sh` to configure missing MCPs
3. Restart Claude Code to ensure MCPs are loaded
4. Test MCPs by asking agents to use their specific tools

## Troubleshooting

- **MCP not appearing**: Ensure API key is set in .env.mcp
- **Configuration fails**: Check network connection and API key validity
- **MCP not available to agents**: Restart Claude Code after configuration

## Support

For help with MCP configuration, see:
- `/project/field-manual/mcp-troubleshooting.md`
- `/project/field-manual/mcp-integration.md`
EOF
    
    success "Report saved to .mcp-status.md"
}

# Interactive setup mode
interactive_setup() {
    echo ""
    echo "=== Interactive MCP Setup ==="
    echo ""
    echo "This will guide you through setting up MCP servers for AGENT-11."
    echo ""
    
    read -p "Do you want to configure all available MCPs? (y/n) " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        configure_mcps
    else
        echo "Selective configuration not yet implemented. Running full configuration..."
        configure_mcps
    fi
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
        --report|-r)
            generate_report
            ;;
        --interactive|-i)
            check_prerequisites
            setup_env_vars
            interactive_setup
            verify_mcps
            generate_report
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --verify, -v      Verify MCP connections"
            echo "  --report, -r      Generate status report"
            echo "  --interactive, -i Interactive setup mode"
            echo "  --help, -h        Show this help message"
            echo ""
            echo "Default: Configure all MCPs from .mcp.json"
            ;;
        *)
            check_prerequisites
            setup_env_vars
            detect_mcps
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
            echo "3. Check MCP tools: grep 'mcp__'"
            echo ""
            ;;
    esac
}

# Run main function
main "$@"