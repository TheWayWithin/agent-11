# MCP Troubleshooting Guide 🔧

Complete troubleshooting guide for MCP (Model Context Protocol) integration in AGENT-11.

## Table of Contents
- [Common Issues](#common-issues)
- [Connection Problems](#connection-problems)
- [API Key Issues](#api-key-issues)
- [Subagent Access](#subagent-access)
- [Performance Issues](#performance-issues)
- [Verification Steps](#verification-steps)
- [Recovery Procedures](#recovery-procedures)

## Common Issues

### MCPs Not Appearing in Claude Code

**Symptoms:**
- `grep "mcp__"` returns no results
- Agents report MCPs unavailable
- Tools starting with `mcp__` not accessible

**Solutions:**

1. **Restart Claude Code**
   ```bash
   /exit
   claude
   ```

2. **Check MCP Configuration**
   ```bash
   # Verify .mcp.json exists
   ls -la .mcp.json
   
   # Check if properly formatted
   cat .mcp.json | jq '.'
   ```

3. **Re-run MCP Setup**
   ```bash
   ./project/deployment/scripts/mcp-setup.sh
   ```

4. **Verify Project Scope**
   ```bash
   # List project-scoped MCPs
   claude mcp list --scope project
   ```

### MCP Configuration Fails

**Symptoms:**
- `mcp-setup.sh` reports failures
- "Configuration failed" messages
- MCPs not connecting despite valid keys

**Solutions:**

1. **Check Network Connection**
   ```bash
   # Test npm connectivity
   npm ping
   
   # Test specific MCP package
   npx @modelcontextprotocol/server-github --version
   ```

2. **Clear npm Cache**
   ```bash
   npm cache clean --force
   ```

3. **Manual MCP Addition**
   ```bash
   # Add MCPs manually one by one
   claude mcp add github --transport stdio \
     --command "npx" \
     --args "@modelcontextprotocol/server-github" \
     --env "GITHUB_PERSONAL_ACCESS_TOKEN=$GITHUB_PERSONAL_ACCESS_TOKEN" \
     --scope project
   ```

## Connection Problems

### MCP Server Not Starting

**Symptoms:**
- Error: "Failed to start MCP server"
- Timeout errors
- Connection refused messages

**Solutions:**

1. **Check Node.js Version**
   ```bash
   node --version  # Should be 18.0.0 or higher
   npm --version   # Should be 8.0.0 or higher
   ```

2. **Install Missing Dependencies**
   ```bash
   # Install MCP packages globally for testing
   npm install -g @modelcontextprotocol/server-github
   npm install -g @mendable/firecrawl-mcp
   ```

3. **Test MCP Server Directly**
   ```bash
   # Test if server can start
   npx @modelcontextprotocol/server-github --help
   ```

### Remote MCP Connection Issues

**Symptoms:**
- Remote MCPs not connecting
- SSL/TLS errors
- Authentication failures

**Solutions:**

1. **Check Firewall/Proxy**
   ```bash
   # Test connectivity to MCP endpoints
   curl -I https://api.context7.com/health
   curl -I https://api.firecrawl.dev/health
   ```

2. **Configure Proxy (if needed)**
   ```bash
   export HTTP_PROXY=http://your-proxy:port
   export HTTPS_PROXY=http://your-proxy:port
   ```

## API Key Issues

### Invalid or Missing API Keys

**Symptoms:**
- "Invalid API key" errors
- "Authentication failed" messages
- MCPs skip during setup

**Solutions:**

1. **Verify API Keys in .env.mcp**
   ```bash
   # Check if file exists
   ls -la .env.mcp
   
   # Verify key format (be careful not to expose keys)
   grep "GITHUB_PERSONAL_ACCESS_TOKEN" .env.mcp | head -c 20
   ```

2. **Test API Keys Directly**
   ```bash
   # Test GitHub token
   curl -H "Authorization: token $GITHUB_PERSONAL_ACCESS_TOKEN" \
     https://api.github.com/user
   
   # Test Firecrawl key
   curl -H "Authorization: Bearer $FIRECRAWL_API_KEY" \
     https://api.firecrawl.dev/v0/health
   ```

3. **Regenerate API Keys**
   - GitHub: https://github.com/settings/tokens
   - Firecrawl: https://firecrawl.dev/dashboard
   - Context7: https://context7.io/dashboard
   - Supabase: https://app.supabase.com/project/_/settings/api

### Environment Variable Not Loading

**Symptoms:**
- Keys in .env.mcp but MCPs report missing
- `${VARIABLE}` not expanding
- "Environment variable not set" errors

**Solutions:**

1. **Source Environment File**
   ```bash
   # Manually source the file
   source .env.mcp
   
   # Verify variables loaded
   echo $GITHUB_PERSONAL_ACCESS_TOKEN | head -c 10
   ```

2. **Check Variable Names**
   ```bash
   # Ensure exact naming match
   grep "=" .env.mcp | cut -d'=' -f1
   ```

3. **Remove Quotes from Values**
   ```bash
   # Wrong
   GITHUB_PERSONAL_ACCESS_TOKEN="ghp_xxxxx"
   
   # Right
   GITHUB_PERSONAL_ACCESS_TOKEN=ghp_xxxxx
   ```

## Subagent Access

### Subagents Can't Access MCPs

**Symptoms:**
- Main Claude Code has MCPs but subagents don't
- `@developer` can't use `mcp__` tools
- Task delegation fails due to missing MCPs

**Current Limitation:**
MCPs are currently only available in the main Claude Code session. Subagents spawned via the Task tool may not have direct MCP access.

**Workarounds:**

1. **Explicit MCP Fallback in Agent Profiles**
   ```markdown
   If mcp__github unavailable:
   - Use Bash with gh CLI
   - Use WebFetch for API calls
   - Request main session assistance
   ```

2. **Coordinator Handles MCP Tasks**
   ```markdown
   When delegating:
   1. Coordinator uses MCPs to gather data
   2. Pass data to subagent in context
   3. Subagent works with provided data
   ```

3. **Use Main Session for MCP Tasks**
   ```bash
   # Instead of delegating MCP tasks
   # Handle them in main session before delegation
   ```

## Performance Issues

### Slow MCP Response

**Symptoms:**
- Long delays when using MCP tools
- Timeouts on MCP operations
- Sluggish agent responses

**Solutions:**

1. **Reduce Concurrent MCPs**
   ```bash
   # Limit active MCPs
   claude mcp remove [unused-mcp]
   ```

2. **Optimize MCP Configuration**
   ```json
   {
     "mcpServers": {
       "github": {
         "command": "npx",
         "args": ["@modelcontextprotocol/server-github"],
         "env": {
           "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_PERSONAL_ACCESS_TOKEN}"
         },
         "timeout": 30000  // Add timeout
       }
     }
   }
   ```

3. **Use Local MCPs When Possible**
   - Prefer stdio transport over HTTP
   - Cache frequently used data
   - Batch MCP operations

## Verification Steps

### Complete MCP Health Check

Run this sequence to verify MCP health:

```bash
# 1. Check configuration files
ls -la .mcp.json .env.mcp

# 2. Verify environment variables
source .env.mcp && env | grep "_TOKEN\|_KEY" | wc -l

# 3. Run setup verification
./project/deployment/scripts/mcp-setup.sh --verify

# 4. Check MCP status
claude mcp list --scope project

# 5. Test in Claude Code
claude
grep "mcp__"

# 6. Generate status report
./project/deployment/scripts/mcp-setup.sh --report
cat .mcp-status.md
```

### MCP Test Commands

Test each MCP individually:

```bash
# Test Context7
mcp__context7__resolve-library-id "react"

# Test GitHub
mcp__github__search_repositories query:"claude mcp"

# Test Firecrawl
mcp__firecrawl__firecrawl_scrape url:"https://example.com"

# Test Playwright
mcp__playwright__browser_navigate url:"https://google.com"
```

## Recovery Procedures

### Complete MCP Reset

If all else fails, perform a complete reset:

```bash
# 1. Remove all MCPs
claude mcp list --scope project | grep -o '"[^"]*":' | sed 's/"//g' | sed 's/://g' | while read mcp; do
  claude mcp remove "$mcp" --scope project
done

# 2. Clear npm cache
npm cache clean --force

# 3. Remove configuration
rm -f .mcp.json .mcp-status.md

# 4. Reinstall from scratch
cp /path/to/agent-11/.mcp.json .
cp /path/to/agent-11/.env.mcp.template .env.mcp
# Edit .env.mcp with your keys
./project/deployment/scripts/mcp-setup.sh

# 5. Restart Claude Code
/exit
claude
```

### Rollback to Manual Tools

If MCPs remain unavailable:

1. **Update CLAUDE.md**
   ```markdown
   ## MCP Status: Unavailable
   Fallback to manual tools enabled.
   ```

2. **Agent Fallback Mode**
   - Agents will use WebFetch, WebSearch, Bash
   - Manual API calls via curl
   - Traditional scripting approaches

3. **Document Issues**
   ```bash
   echo "MCP Issues: $(date)" >> .mcp-issues.log
   # Document specific errors for debugging
   ```

## Getting Help

### Diagnostic Information

When reporting MCP issues, include:

```bash
# System info
uname -a
node --version
npm --version
claude --version

# Configuration
ls -la .mcp.json .env.mcp
cat .mcp-status.md

# Error logs
claude mcp list --scope project 2>&1

# Network test
curl -I https://api.github.com
```

### Support Resources

1. **AGENT-11 Specific**
   - Check `/project/field-manual/mcp-integration.md`
   - Review agent profiles for fallback strategies
   - Consult CLAUDE.md for project-specific notes

2. **Claude Code MCP Docs**
   - Official docs: https://docs.anthropic.com/en/docs/claude-code/mcp
   - MCP GitHub: https://github.com/modelcontextprotocol

3. **Community Support**
   - AGENT-11 Issues: Report on project GitHub
   - Claude Code Forums: Anthropic community
   - MCP Server Issues: Individual server repos

## Prevention Tips

### Best Practices

1. **Regular Verification**
   ```bash
   # Weekly MCP health check
   ./project/deployment/scripts/mcp-setup.sh --verify
   ```

2. **Keep Keys Updated**
   - Rotate API keys periodically
   - Monitor key expiration dates
   - Use separate keys for dev/prod

3. **Document Working Configuration**
   ```bash
   # When everything works, save configuration
   cp .mcp.json .mcp.json.working
   cp .env.mcp .env.mcp.working
   ```

4. **Test After Updates**
   - After Claude Code updates
   - After npm updates
   - After system updates

---

*"When MCPs fail, agents adapt. Troubleshooting is just another mission."*