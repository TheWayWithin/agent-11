# MCP System Guide

## What is MCP?

**Model Context Protocol (MCP)** is a system that allows Claude Code to connect to external services and tools. AGENT-11 uses MCP to provide agents with capabilities like:

- **GitHub Integration** - Repository management, PRs, issues
- **Database Access** - Supabase for data operations
- **Browser Automation** - Playwright for testing
- **Payment Processing** - Stripe integration
- **Deployment Tools** - Netlify and Railway
- **Documentation** - Context7 for library docs
- **File Operations** - Filesystem access

## Why Use MCP Profiles?

Without profiles, all MCP servers load every time, consuming 15,000+ tokens of context. This limits the space available for your actual code and conversation.

**With MCP profiles**, you load only what you need:

| Profile | MCPs Loaded | Context Used | Reduction |
|---------|-------------|--------------|-----------|
| core | 3 | 3,000 tokens | 80% |
| testing | 4 | 5,500 tokens | 63% |
| database-staging | 4 | 8,000 tokens | 47% |
| payments | 4 | 7,000 tokens | 53% |
| deployment | 5 | 9,000 tokens | 40% |
| fullstack | 8 | 15,000 tokens | baseline |

**Key Benefits:**
- 40-80% reduction in context usage
- Faster agent responses
- More room for code and conversation
- Environment safety (production read-only enforced)
- Task-appropriate tooling

## Quick Start

### 1. Install MCP Servers

First-time setup requires installing the MCP servers:

```bash
cd ~/DevProjects/agent-11
./project/deployment/scripts/mcp-setup.sh
```

This installs:
- @context7/mcp-server
- @edjl/github-mcp
- @modelcontextprotocol/server-filesystem
- @playwright/mcp
- @supabase/mcp-server
- @stripe/mcp-server
- @netlify/mcp
- @railway/mcp-server

### 2. Configure Environment Variables

Copy the template and add your API keys:

```bash
cp .env.mcp.template .env.mcp
```

Edit `.env.mcp` and add your credentials:

```bash
# Required for all profiles
CONTEXT7_API_KEY=your_context7_key
GITHUB_PERSONAL_ACCESS_TOKEN=your_github_token

# Required for database profiles
SUPABASE_STAGING_TOKEN=your_staging_token
SUPABASE_STAGING_REF=your_staging_ref
SUPABASE_PRODUCTION_TOKEN=your_production_token
SUPABASE_PRODUCTION_REF=your_production_ref

# Required for payments profile
STRIPE_API_KEY=your_stripe_key

# Required for deployment profile
NETLIFY_ACCESS_TOKEN=your_netlify_token
RAILWAY_API_TOKEN=your_railway_token
```

**Security Note:** `.env.mcp` is in `.gitignore` - never commit credentials to git.

### 3. Choose Your Profile (Easy Way)

**Simple slash commands - no complex syntax to remember:**

```bash
/mcp-switch core          # For general development
/mcp-switch testing       # For testing with Playwright
/mcp-switch database-staging      # For database work (full access)
/mcp-switch database-production   # For production queries (read-only)
/mcp-switch payments      # For payment integration
/mcp-switch deployment    # For deployments
/mcp-switch fullstack     # For everything (uses more context)
```

**Other helpful commands:**
```bash
/mcp-list    # See all available profiles with descriptions
/mcp-status  # Check which profile is currently active
```

<details>
<summary><strong>Advanced: Manual Profile Switching (click to expand)</strong></summary>

If you prefer manual control, you can use symlinks directly:

```bash
# For general development
ln -sf .mcp-profiles/core.json .mcp.json

# For testing with Playwright
ln -sf .mcp-profiles/testing.json .mcp.json

# For database work (staging)
ln -sf .mcp-profiles/database-staging.json .mcp.json

# For production queries (read-only)
ln -sf .mcp-profiles/database-production.json .mcp.json

# For payment integration
ln -sf .mcp-profiles/payments.json .mcp.json

# For deployments
ln -sf .mcp-profiles/deployment.json .mcp.json

# For everything (development only)
ln -sf .mcp-profiles/fullstack.json .mcp.json
```
</details>

### 4. Restart Claude Code

After switching profiles, restart Claude Code when prompted:

```bash
# Type: /exit
# Then run: claude
```

### 5. Verify Active Profile

Check which profile is active:

```bash
/mcp-status
```

Or manually:
```bash
ls -l .mcp.json
```

Output shows: `.mcp.json -> .mcp-profiles/testing.json`

## Profile Selection Guide

### When to Use Each Profile

**core** - Lightweight development
- Code review and analysis
- Documentation writing
- Planning and strategy
- Git operations
- File operations
- When you don't need specialized tools

**testing** - Quality assurance
- Writing Playwright tests
- Running browser automation
- Visual regression testing
- Accessibility testing
- Integration testing
- UI testing

**database-staging** - Database development
- Schema migrations
- Data modeling
- Query development
- Database testing
- Staging data operations
- Full read/write access

**database-production** - Production queries
- Read-only production access
- Data analysis
- Report generation
- Production debugging
- Safety-enforced (no writes possible)

**payments** - Payment integration
- Stripe integration
- Payment testing
- Subscription management
- Invoice generation
- Revenue analytics

**deployment** - Shipping code
- Netlify deployments
- Railway deployments
- Environment configuration
- Production releases
- Infrastructure management

**fullstack** - Development mode
- All development MCPs combined
- Maximum capabilities
- Higher context usage
- Use when you need multiple MCP types
- Excludes production database (safety)

## Workflow Examples

### Example 1: Testing Workflow

```bash
# Switch to testing profile
/mcp-switch testing

# Claude Code will prompt you to restart

# Ask agent to create tests
@tester Create Playwright tests for the login flow

# Agent automatically uses Playwright MCP
# Tests are created and executed
```

### Example 2: Database Migration

```bash
# Switch to staging database
/mcp-switch database-staging

# Restart when prompted

# Ask agent to create migration
@developer Create a migration to add user preferences table

# Agent uses Supabase MCP (staging, read/write)
# Migration is created and tested
```

### Example 3: Production Analysis

```bash
# Switch to production database (read-only)
/mcp-switch database-production

# Restart when prompted

# Ask agent to analyze data
@analyst Generate report on user activity last month

# Agent uses Supabase MCP (production, read-only enforced)
# No risk of accidental writes
```

### Example 4: Deployment

```bash
# Switch to deployment profile
/mcp-switch deployment

# Restart when prompted

# Ask agent to deploy
@operator Deploy the latest version to production

# Agent uses Netlify/Railway MCPs
# Deployment proceeds with appropriate tools
```

## Best Practices

### 1. Start Small
Begin with the smallest profile that meets your needs. You can always switch to a larger profile if needed.

### 2. Profile Per Session
Set the appropriate profile at the start of your work session and stick with it. Switching mid-session requires a restart.

### 3. Production Safety
Always use `database-production.json` for production queries. The read-only flag prevents accidental writes.

### 4. Check Before Operations
Before any critical operation, verify your active profile:

```bash
/mcp-status
```

### 5. Environment Separation
Use separate profiles for staging vs production to enforce clear boundaries:
- `database-staging.json` - Full access for development
- `database-production.json` - Read-only for queries

### 6. Task-Appropriate Tooling
Match your profile to your task:
- Testing? Use testing profile
- Database work? Use database profile
- Deployment? Use deployment profile

### 7. Context Management
Monitor context usage. If you're hitting limits, switch to a smaller profile:
- core: 80% reduction
- testing: 63% reduction
- database-staging: 47% reduction

### 8. Documentation
When asking agents to work, mention if a specific profile is needed:

```bash
# Good
@tester (testing profile) Create Playwright tests for checkout

# Better (let agent guide you)
@tester I need to create tests for checkout flow
# Agent will tell you which profile to use
```

## Advanced Usage

### Creating Custom Profiles

You can create custom profiles for specific workflows:

```bash
# Create new profile
cp .mcp-profiles/core.json .mcp-profiles/custom.json

# Edit to add only the MCPs you need
# Then switch to it
ln -sf .mcp-profiles/custom.json .mcp.json
```

### Checking MCP Server Status

Verify MCP servers are running:

```bash
./project/deployment/scripts/mcp-setup.sh --verify
```

### Environment-Specific Variables

Use different environment files for different contexts:

```bash
# Development environment
cp .env.mcp .env.mcp.dev

# Production environment (read-only tokens only)
cp .env.mcp .env.mcp.prod
```

### Profile Switching Commands

**Built-in slash commands** (recommended - no setup needed):
```bash
/mcp-switch testing
/mcp-switch database-staging
```

**Advanced: Custom Shell Script** (if you prefer terminal-based switching):

Create a helper script for quick switching:

```bash
#!/bin/bash
# save as ~/bin/mcp-profile

profile=$1
ln -sf .mcp-profiles/${profile}.json .mcp.json
echo "Switched to ${profile} profile"
echo "Restart Claude Code for changes to take effect"
```

Usage:
```bash
mcp-profile testing
mcp-profile database-staging
```

**Note:** The built-in `/mcp-switch` commands are simpler and provide better guidance.

## Integration with Agents

AGENT-11 agents are MCP-aware and will guide you on profile selection:

### Coordinator
When starting missions, coordinator checks active profile and recommends switches:

```bash
/coord test
# Coordinator: "I recommend the testing profile for this mission."
# "Run: /mcp-switch testing"
```

### Tester
Before testing work, tester verifies testing profile is active:

```bash
@tester Create tests
# Tester: "I need the testing profile for Playwright."
# "Run: /mcp-switch testing"
```

### Developer
Before database operations, developer checks environment:

```bash
@developer Update user table
# Developer: "I need database access. For staging (read/write), run: /mcp-switch database-staging"
```

### Operator
Before deployments, operator verifies deployment profile:

```bash
@operator Deploy to production
# Operator: "I need deployment tools. Run: /mcp-switch deployment"
```

## Troubleshooting

### Profile Not Taking Effect

**Symptom:** Switched profiles but MCPs haven't changed

**Solution:** Always restart Claude Code after switching profiles

```bash
# After using /mcp-switch, you'll be prompted to restart
# Type: /exit
# Then run: claude

# Verify the switch worked:
/mcp-status
```

### MCP Server Not Found

**Symptom:** "MCP server not installed" errors

**Solution:** Run the setup script

```bash
./project/deployment/scripts/mcp-setup.sh
```

### Environment Variables Not Loading

**Symptom:** "Missing API key" errors

**Solution:** Check `.env.mcp` exists and has correct values

```bash
# Verify file exists
ls -la .env.mcp

# Check contents (don't commit this!)
cat .env.mcp

# Ensure proper format (no spaces around =)
GITHUB_PERSONAL_ACCESS_TOKEN=ghp_your_token_here
```

### Production Write Blocked

**Symptom:** "Operation not permitted" on production database

**Solution:** This is expected! Production profile is read-only.

```bash
# For write operations, switch to staging
ln -sf .mcp-profiles/database-staging.json .mcp.json

# Restart Claude Code
```

### Symlink Not Working

**Symptom:** `.mcp.json` is a regular file, not a symlink

**Solution:** Remove the file and create proper symlink

```bash
# Remove regular file
rm .mcp.json

# Create symlink
ln -sf .mcp-profiles/core.json .mcp.json

# Verify it's a symlink
ls -l .mcp.json
```

### Unknown Profile

**Symptom:** Profile doesn't exist in `.mcp-profiles/`

**Solution:** Use one of the 7 standard profiles

```bash
# List available profiles
ls -la .mcp-profiles/

# Should show:
# core.json
# testing.json
# database-staging.json
# database-production.json
# payments.json
# deployment.json
# fullstack.json
```

## Reference

### Available MCPs by Profile

**core** (3 MCPs):
- context7 - Library documentation
- github - Repository management
- filesystem - File operations

**testing** (4 MCPs):
- core MCPs +
- playwright - Browser automation

**database-staging** (4 MCPs):
- core MCPs +
- supabase-staging - Database (read/write)

**database-production** (4 MCPs):
- core MCPs +
- supabase-production - Database (read-only)

**payments** (4 MCPs):
- core MCPs +
- stripe - Payment processing

**deployment** (5 MCPs):
- core MCPs +
- netlify - Frontend hosting
- railway - Backend services

**fullstack** (8 MCPs):
- core MCPs +
- playwright
- supabase-staging
- stripe
- netlify
- railway
- (excludes production database)

### Context Usage Table

| Profile | MCPs | Tokens | Reduction |
|---------|------|--------|-----------|
| core | 3 | 3,000 | 80% |
| testing | 4 | 5,500 | 63% |
| database-staging | 4 | 8,000 | 47% |
| database-production | 4 | 8,000 | 47% |
| payments | 4 | 7,000 | 53% |
| deployment | 5 | 9,000 | 40% |
| fullstack | 8 | 15,000 | baseline |

### Profile Files Location

All profiles are stored in:
```
.mcp-profiles/
├── core.json
├── testing.json
├── database-staging.json
├── database-production.json
├── payments.json
├── deployment.json
└── fullstack.json
```

Active profile symlink:
```
.mcp.json -> .mcp-profiles/[profile].json
```

### Related Documentation

- **Profile Reference**: docs/MCP-PROFILES.md
- **Troubleshooting**: docs/MCP-TROUBLESHOOTING.md
- **Installation Guide**: project/deployment/README.md
- **Agent Integration**: project/agents/specialists/

## Next Steps

1. **Install MCP servers** if you haven't already
2. **Configure environment variables** in `.env.mcp`
3. **Choose a profile** based on your current task
4. **Restart Claude Code** to activate the profile
5. **Verify activation** with `ls -l .mcp.json`
6. **Start working** - agents will guide you on profile needs

For more details on each profile, see [MCP-PROFILES.md](./MCP-PROFILES.md).

For common issues and solutions, see [MCP-TROUBLESHOOTING.md](./MCP-TROUBLESHOOTING.md).
