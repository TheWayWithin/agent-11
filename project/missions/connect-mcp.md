# Mission: CONNECT-MCP 🔌
## MCP Discovery, Assessment & Connection

### Mission Type
**Infrastructure Setup** - Identifying and connecting required MCP servers

### Estimated Duration
45-90 minutes

### Required Assets
- Project requirements or ideation document
- API keys for services (if known)
- Node.js 18+ environment
- npm/pnpm package manager

---

## Mission Briefing

This mission systematically identifies required MCPs based on project needs, installs and configures them, and ensures all agents can leverage these tools effectively.

### Prerequisites
- AGENT-11 deployed to project
- Project requirements understood (ideation.md or similar)
- Claude Code with MCP support enabled

### Recommended Approach: MCP Profiles

**AGENT-11 includes pre-configured MCP profiles** that simplify setup:

```bash
# Activate a profile matching your project needs
ln -sf .mcp-profiles/core.json .mcp.json
# Restart Claude Code
```

Available profiles: `core`, `testing`, `database-staging`, `database-production`, `payments`, `deployment`, `fullstack`

See [MCP Profile Guide](../../docs/MCP-GUIDE.md) for complete profile reference. This mission helps you choose and configure the right profile for your project.

---

## Execution Protocol

### Phase 1: Requirements Analysis (10 min)
```bash
/coord "Analyzing project requirements to identify needed MCPs..."
```

**Agent Actions:**
- @strategist reviews project requirements and ideation documents
- Identifies core capabilities needed:
  - Database requirements → Supabase MCP
  - Testing needs → Playwright MCP
  - Documentation needs → Context7 MCP
  - Deployment targets → Netlify/Railway MCPs
  - Version control → GitHub MCP
  - Web scraping → Firecrawl MCP
  - Email services → Gmail/Resend MCPs
  - Payment processing → Stripe MCP

**Capability Mapping:**
```markdown
## Required Capabilities
- [ ] Database operations
- [ ] Authentication system
- [ ] Testing automation
- [ ] Documentation retrieval
- [ ] Web scraping
- [ ] Deployment automation
- [ ] Version control
- [ ] Email services
- [ ] Payment processing
```

### Phase 2: MCP Discovery & Assessment (15 min)
```bash
/coord "Discovering available MCPs and checking current installations..."
```

**Agent Actions:**
- @coordinator runs grep "mcp__" to check existing MCPs
- @architect assesses which MCPs match requirements
- @developer searches npm registry for needed MCPs:

```bash
# Search for official MCP packages
npm search @modelcontextprotocol
npm search mcp-server

# Common MCP packages
npm search supabase-mcp
npm search playwright-mcp
npm search github-mcp
npm search firecrawl-mcp
```

**Assessment Checklist:**
```markdown
## MCP Assessment
### Already Available
- [x] mcp__context7 (documentation)
- [x] mcp__firecrawl (web scraping)
- [x] mcp__playwright (browser automation)

### Needs Installation
- [ ] Supabase MCP (database)
- [ ] GitHub MCP (version control)
- [ ] Railway MCP (backend deployment)
- [ ] Stripe MCP (payments)

### Not Available (Manual Fallback)
- [ ] Custom API integrations
```

### Phase 3: Environment Setup (10 min)
```bash
/coord "Setting up MCP environment and configuration files..."
```

**Agent Actions:**
- @developer creates necessary configuration files:

**1. Create .mcp.json:**
```json
{
  "mcpServers": {
    "supabase": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-supabase"],
      "env": {
        "SUPABASE_URL": "${SUPABASE_URL}",
        "SUPABASE_SERVICE_KEY": "${SUPABASE_SERVICE_KEY}"
      }
    },
    "github": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    },
    "playwright": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-playwright"]
    }
  }
}
```

**2. Create .env.mcp:**
```env
# Database
SUPABASE_URL=your-project-url
SUPABASE_SERVICE_KEY=your-service-key

# Version Control
GITHUB_TOKEN=your-github-token

# Deployment
RAILWAY_TOKEN=your-railway-token
NETLIFY_TOKEN=your-netlify-token

# Services
STRIPE_API_KEY=your-stripe-key
RESEND_API_KEY=your-resend-key
```

**3. Update .gitignore:**
```gitignore
# MCP Configuration
.env.mcp
.env.mcp.local
.mcp.local.json
```

### Phase 4: Package Installation (15 min)
```bash
/coord "Installing required MCP packages..."
```

**Agent Actions:**
- @developer installs MCP packages based on assessment:

```bash
# Core MCPs for development
npm install @modelcontextprotocol/server-github@latest
npm install @modelcontextprotocol/server-playwright@latest

# Database MCP (if using Supabase)
npm install @modelcontextprotocol/server-supabase@latest

# Deployment MCPs (based on stack)
npm install @modelcontextprotocol/server-netlify@latest
npm install @modelcontextprotocol/server-railway@latest

# Additional service MCPs
npm install @modelcontextprotocol/server-stripe@latest
```

**Package.json Update:**
```json
{
  "scripts": {
    "mcp:test": "node scripts/test-mcp-connections.js",
    "mcp:validate": "npx mcp-validator .mcp.json",
    "mcp:restart": "pkill -f mcp-server && claude"
  }
}
```

### Phase 5: Connection Testing (15 min)
```bash
/coord "Testing MCP connections and validating configurations..."
```

**Agent Actions:**
- @tester creates test script for MCP validation:

**scripts/test-mcp-connections.js:**
```javascript
const testConnections = async () => {
  const mcps = [
    { name: 'github', test: 'mcp__github' },
    { name: 'supabase', test: 'mcp__supabase' },
    { name: 'playwright', test: 'mcp__playwright' },
  ];

  for (const mcp of mcps) {
    try {
      console.log(`Testing ${mcp.name}...`);
      // Test connection logic here
      console.log(`✅ ${mcp.name} connected successfully`);
    } catch (error) {
      console.error(`❌ ${mcp.name} failed: ${error.message}`);
    }
  }
};

testConnections();
```

**Validation Checklist:**
```markdown
## Connection Tests
- [ ] GitHub MCP: Repository access verified
- [ ] Supabase MCP: Database queries working
- [ ] Playwright MCP: Browser automation functional
- [ ] Context7 MCP: Documentation retrieval working
- [ ] Firecrawl MCP: Web scraping operational
```

### Phase 6: Agent Configuration (10 min)
```bash
/coord "Updating agent configurations with MCP mappings..."
```

**Agent Actions:**
- @coordinator updates CLAUDE.md with MCP inventory:

**CLAUDE.md Updates:**
```markdown
## Connected MCPs

### Development
- **mcp__github**: Version control, PRs, issues
  - Used by: @developer, @coordinator
- **mcp__supabase**: Database and authentication
  - Used by: @developer, @operator

### Testing
- **mcp__playwright**: E2E testing automation
  - Used by: @tester

### Research & Documentation
- **mcp__context7**: Library documentation
  - Used by: All agents
- **mcp__firecrawl**: Web scraping and research
  - Used by: @architect, @developer

### Deployment
- **mcp__netlify**: Frontend deployment
  - Used by: @operator
- **mcp__railway**: Backend deployment
  - Used by: @operator

## MCP Usage Protocol
1. Always check MCP availability before manual implementation
2. Document MCP usage in project-plan.md
3. Fall back to manual approach if MCP unavailable
4. Report MCP issues to @coordinator
```

### Phase 7: Documentation & Training (10 min)
```bash
/coord "Creating MCP usage documentation for the team..."
```

**Agent Actions:**
- @documenter creates MCP setup guide:

**MCP-SETUP-GUIDE.md:**
```markdown
# MCP Setup Guide

## Quick Start
1. Copy `.env.mcp.example` to `.env.mcp`
2. Add your API keys
3. Restart Claude Code
4. Run `npm run mcp:test` to validate

## Available MCPs
[List of connected MCPs with usage examples]

## Troubleshooting
- Connection failures: Check API keys
- Rate limiting: Implement retry logic
- Authentication errors: Verify permissions

## Adding New MCPs
1. Search npm: `npm search service-mcp`
2. Install: `npm install @package/mcp-server`
3. Configure in `.mcp.json`
4. Test connection
5. Update documentation
```

---

## Success Metrics

✅ **Mission Complete When:**
- [ ] All required MCPs identified from requirements
- [ ] MCP packages installed successfully
- [ ] Configuration files created (.mcp.json, .env.mcp)
- [ ] All connections tested and validated
- [ ] CLAUDE.md updated with MCP inventory
- [ ] Agent mappings documented
- [ ] Setup guide created for team

---

## Post-Mission Checklist

1. **Verify Connections:**
   ```bash
   npm run mcp:test
   grep "mcp__" # Should show all connected MCPs
   ```

2. **Restart Claude Code:**
   ```bash
   # MCPs load on startup
   /exit
   claude
   ```

3. **Test Agent Usage:**
   ```bash
   @developer "Use mcp__supabase to create a users table"
   @tester "Use mcp__playwright to test the login flow"
   ```

---

## Troubleshooting

### Common Issues

**MCP Not Available After Installation:**
- Restart Claude Code completely
- Check .mcp.json syntax
- Verify package installation: `npm ls @package/mcp-server`

**Authentication Failures:**
- Verify API keys in .env.mcp
- Check token permissions/scopes
- Test API directly with curl

**Connection Timeouts:**
- Check network connectivity
- Verify service status
- Review rate limits

**Package Not Found:**
- Search alternative names: `npm search service`
- Check official MCP registry
- Consider community implementations

---

## Security Considerations

1. **API Key Management:**
   - Never commit .env.mcp to git
   - Use minimum required permissions
   - Rotate keys regularly

2. **Access Control:**
   - Document which agents use which MCPs
   - Implement operation tiers (read/write/delete)
   - Add confirmation for destructive operations

3. **Monitoring:**
   - Log MCP operations
   - Track API usage
   - Monitor for anomalies

---

## Related Missions
- **Dev-Setup** - Initial project setup
- **Dev-Alignment** - Existing project analysis
- **Build** - Feature development with MCPs
- **Deploy** - Deployment using infrastructure MCPs

---

## Command Reference

```bash
# Quick MCP connection
/coord connect-mcp

# With specific requirements
/coord connect-mcp --services "supabase,stripe,railway"

# Test mode only
/coord connect-mcp --test-only

# Update existing MCPs
/coord connect-mcp --update
```

---

## Post-Mission Cleanup Decision

After completing this mission, decide on cleanup approach based on project status:

### ✅ Milestone Transition (Every 2-4 weeks)
**When**: This mission completes a major project milestone, but more work remains.

**Actions** (30-60 min):
1. Extract lessons to `lessons/[category]/` from progress.md
2. Archive current handoff-notes.md to `archives/handoffs/milestone-X/`
3. Clean agent-context.md (retain essentials, archive historical details)
4. Create fresh handoff-notes.md for next milestone
5. Update project-plan.md with next milestone tasks

**See**: `templates/cleanup-checklist.md` Section A for detailed steps

### 🎯 Project Completion (Mission accomplished!)
**When**: All project objectives achieved, ready for new mission.

**Actions** (1-2 hours):
1. Extract ALL lessons from entire progress.md to `lessons/`
2. Create mission archive in `archives/missions/mission-[name]-YYYY-MM-DD/`
3. Update CLAUDE.md with system-level learnings
4. Archive all tracking files (project-plan.md, progress.md, etc.)
5. Prepare fresh start for next mission

**See**: `templates/cleanup-checklist.md` Section B for detailed steps

### 🔄 Continue Active Work (No cleanup needed)
**When**: Mission complete but continuing active development in same phase.

**Actions**: Update progress.md and project-plan.md, continue working.

---

**Reference**: See `project/field-manual/project-lifecycle-guide.md` for complete lifecycle management procedures.

---

*"Connect the tools, multiply the force. MCPs are the infrastructure of AI-powered development."* - AGENT-11 Field Manual