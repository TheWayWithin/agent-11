# MCP Profile Reference

Complete reference documentation for all AGENT-11 MCP profiles.

## Profile Overview

AGENT-11 provides 7 specialized MCP profiles optimized for different development tasks. Each profile loads only the MCP servers needed for specific workflows, reducing context usage by 40-80%.

### Quick Reference Table

| Profile | MCPs | Context | Reduction | Primary Use Case |
|---------|------|---------|-----------|------------------|
| core | 3 | 3,000 | 80% | General development |
| testing | 4 | 5,500 | 63% | Quality assurance |
| database-staging | 4 | 8,000 | 47% | Database development |
| database-production | 4 | 8,000 | 47% | Production queries (read-only) |
| payments | 4 | 7,000 | 53% | Payment integration |
| deployment | 5 | 9,000 | 40% | Shipping to production |
| fullstack | 8 | 15,000 | 0% | Maximum capabilities |

---

## core

**Purpose:** Lightweight general-purpose development profile

**Context Usage:** 3,000 tokens (80% reduction)

**File:** `.mcp-profiles/core.json`

### Included MCPs

1. **context7** - Library documentation and code examples
2. **github** - Repository management, PRs, issues
3. **filesystem** - File operations and project access

### Configuration

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["@context7/mcp-server"],
      "env": {
        "CONTEXT7_API_KEY": "${CONTEXT7_API_KEY}"
      }
    },
    "github": {
      "command": "npx",
      "args": ["@edjl/github-mcp"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_PERSONAL_ACCESS_TOKEN}"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-filesystem", "${HOME}/DevProjects"]
    }
  }
}
```

### Required Environment Variables

```bash
CONTEXT7_API_KEY=your_context7_key
GITHUB_PERSONAL_ACCESS_TOKEN=your_github_token
```

### Use Cases

- Code review and analysis
- Documentation writing
- Planning and strategy sessions
- Git operations (commit, PR, branch)
- File operations (read, write, edit)
- Library research and lookup
- General development without specialized tools

### When to Use

✅ Use core when:
- Starting a new work session
- Doing code reviews
- Writing documentation
- Planning features or architecture
- Working with git
- You don't need database, testing, or deployment tools

❌ Don't use core when:
- Writing Playwright tests (use testing)
- Performing database operations (use database-*)
- Processing payments (use payments)
- Deploying code (use deployment)

### Agent Compatibility

All AGENT-11 agents work with core profile:
- @coordinator - Mission orchestration
- @strategist - Product planning
- @architect - System design
- @developer - Code implementation
- @documenter - Documentation
- @analyst - Data analysis (file-based)
- @marketer - Marketing content
- @support - Customer support

### Switching to Core

```bash
ln -sf .mcp-profiles/core.json .mcp.json
# Restart Claude Code
```

---

## testing

**Purpose:** Quality assurance and browser automation

**Context Usage:** 5,500 tokens (63% reduction)

**File:** `.mcp-profiles/testing.json`

### Included MCPs

1. **core MCPs** (context7, github, filesystem)
2. **playwright** - Browser automation and testing

### Configuration

```json
{
  "mcpServers": {
    "context7": { /* core config */ },
    "github": { /* core config */ },
    "filesystem": { /* core config */ },
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  }
}
```

### Required Environment Variables

Same as core profile:
```bash
CONTEXT7_API_KEY=your_context7_key
GITHUB_PERSONAL_ACCESS_TOKEN=your_github_token
```

### Playwright Capabilities

- **Browser Navigation** - Navigate to URLs, click, type, submit
- **Element Interaction** - Click, hover, drag, type, fill forms
- **Assertions** - Verify content, visibility, state
- **Screenshots** - Capture full page or element screenshots
- **Visual Regression** - Compare screenshots for changes
- **Accessibility Testing** - Check ARIA labels, keyboard navigation
- **Network Monitoring** - Track API calls, responses
- **Console Logs** - Capture JavaScript errors
- **Cross-Browser** - Test on Chrome, Firefox, Safari
- **Mobile Emulation** - Test responsive designs

### Use Cases

- Writing Playwright tests for user flows
- E2E testing of web applications
- Visual regression testing
- Accessibility audits
- Performance monitoring
- UI interaction testing
- Integration testing
- Browser debugging

### When to Use

✅ Use testing when:
- Writing or running Playwright tests
- Testing user interactions
- Checking accessibility
- Debugging browser issues
- Performing visual regression tests
- Creating test automation

❌ Don't use testing when:
- Not doing browser-based testing
- Writing unit tests (use core)
- Doing database testing (use database-staging)

### Agent Compatibility

Primary agents for testing profile:
- **@tester** - Primary agent for this profile
- @designer - UI/UX testing and verification
- @developer - Test implementation
- All core-compatible agents

### Workflow Example

```bash
# Switch to testing profile
ln -sf .mcp-profiles/testing.json .mcp.json
# Restart Claude Code

# Ask tester to create tests
@tester Create Playwright tests for the login flow

# Tester verifies testing profile is active
# Creates comprehensive test suite
# Runs tests and reports results
```

### Switching to Testing

```bash
ln -sf .mcp-profiles/testing.json .mcp.json
# Restart Claude Code
```

---

## database-staging

**Purpose:** Database development with full read/write access

**Context Usage:** 8,000 tokens (47% reduction)

**File:** `.mcp-profiles/database-staging.json`

### Included MCPs

1. **core MCPs** (context7, github, filesystem)
2. **supabase-staging** - Staging database with read/write access

### Configuration

```json
{
  "mcpServers": {
    "context7": { /* core config */ },
    "github": { /* core config */ },
    "filesystem": { /* core config */ },
    "supabase-staging": {
      "command": "npx",
      "args": [
        "@supabase/mcp-server",
        "--access-token", "${SUPABASE_STAGING_TOKEN}",
        "--project-ref", "${SUPABASE_STAGING_REF}"
      ]
    }
  }
}
```

### Required Environment Variables

```bash
CONTEXT7_API_KEY=your_context7_key
GITHUB_PERSONAL_ACCESS_TOKEN=your_github_token
SUPABASE_STAGING_TOKEN=your_staging_token
SUPABASE_STAGING_REF=your_staging_ref
```

### Supabase Capabilities

- **Schema Management** - Create tables, columns, indexes
- **Data Operations** - INSERT, UPDATE, DELETE, SELECT
- **Migrations** - Create and run database migrations
- **Relationships** - Define foreign keys, joins
- **RLS Policies** - Row Level Security configuration
- **Functions** - Database functions and triggers
- **Real-time** - Configure real-time subscriptions
- **Storage** - File storage buckets
- **Auth** - Authentication configuration
- **Edge Functions** - Serverless functions

### Use Cases

- Creating database schema
- Writing migrations
- Developing queries
- Testing data operations
- Setting up RLS policies
- Configuring auth rules
- Storage bucket setup
- Database refactoring

### Safety Features

- ✅ Full read/write access (intentional for development)
- ⚠️ Connected to staging environment only
- 🔒 Separate from production database
- ✅ Safe for experimentation and testing

### When to Use

✅ Use database-staging when:
- Creating or modifying schema
- Writing database migrations
- Testing queries
- Developing new features requiring database
- Setting up RLS policies
- Configuring authentication
- Any database write operations

❌ Don't use database-staging when:
- Querying production data (use database-production)
- Don't need database access (use core)

### Agent Compatibility

Primary agents for database-staging:
- **@developer** - Database operations and migrations
- **@architect** - Schema design
- @tester - Database testing
- All core-compatible agents

### Workflow Example

```bash
# Switch to staging database
ln -sf .mcp-profiles/database-staging.json .mcp.json
# Restart Claude Code

# Ask developer to create migration
@developer Create a migration to add user_preferences table with columns for theme and notifications

# Developer verifies database-staging profile
# Creates migration file
# Tests migration on staging
# Reports results
```

### Switching to Database Staging

```bash
ln -sf .mcp-profiles/database-staging.json .mcp.json
# Restart Claude Code
```

---

## database-production

**Purpose:** Production database queries with read-only safety

**Context Usage:** 8,000 tokens (47% reduction)

**File:** `.mcp-profiles/database-production.json`

### Included MCPs

1. **core MCPs** (context7, github, filesystem)
2. **supabase-production** - Production database with **read-only** access

### Configuration

```json
{
  "mcpServers": {
    "context7": { /* core config */ },
    "github": { /* core config */ },
    "filesystem": { /* core config */ },
    "supabase-production": {
      "command": "npx",
      "args": [
        "@supabase/mcp-server",
        "--access-token", "${SUPABASE_PRODUCTION_TOKEN}",
        "--project-ref", "${SUPABASE_PRODUCTION_REF}",
        "--read-only"
      ]
    }
  }
}
```

### Required Environment Variables

```bash
CONTEXT7_API_KEY=your_context7_key
GITHUB_PERSONAL_ACCESS_TOKEN=your_github_token
SUPABASE_PRODUCTION_TOKEN=your_production_token
SUPABASE_PRODUCTION_REF=your_production_ref
```

### Capabilities

- ✅ **SELECT queries** - Read production data
- ✅ **Data analysis** - Generate reports
- ✅ **Debugging** - Investigate production issues
- ❌ **INSERT/UPDATE/DELETE** - Blocked by read-only flag
- ❌ **Schema changes** - Not permitted
- ❌ **Configuration changes** - Not permitted

### Use Cases

- Analyzing production data
- Generating reports
- Investigating production issues
- Debugging data problems
- User analytics
- Performance analysis
- Data auditing

### Safety Features

- 🔒 **Read-only enforced** - `--read-only` flag prevents all writes
- 🛡️ **No accidental changes** - Impossible to modify production data
- ✅ **Production access** - Real production data for analysis
- ⚠️ **Automatic blocking** - Write attempts automatically rejected

### When to Use

✅ Use database-production when:
- Analyzing production data
- Generating user reports
- Investigating production issues
- Debugging data problems
- Creating analytics queries
- Auditing production state

❌ Don't use database-production when:
- Need to modify data (use database-staging for testing)
- Creating migrations (use database-staging)
- Testing writes (use database-staging)

### Agent Compatibility

Primary agents for database-production:
- **@analyst** - Data analysis and reporting
- **@support** - Customer data lookup
- @developer - Production debugging (read-only)
- All core-compatible agents

### Workflow Example

```bash
# Switch to production database (read-only)
ln -sf .mcp-profiles/database-production.json .mcp.json
# Restart Claude Code

# Ask analyst for report
@analyst Generate a report on user activity for the past 30 days

# Analyst verifies database-production profile
# Confirms read-only mode
# Runs SELECT queries on production
# Generates comprehensive report
```

### Safety Protocol

When agent detects database-production profile:

1. **Verify read-only mode** - Check `--read-only` flag present
2. **Acknowledge environment** - Confirm production database
3. **Restrict operations** - Only SELECT queries permitted
4. **Block write attempts** - Reject INSERT/UPDATE/DELETE
5. **Guide user** - If writes needed, recommend database-staging

### Switching to Database Production

```bash
ln -sf .mcp-profiles/database-production.json .mcp.json
# Restart Claude Code
```

---

## payments

**Purpose:** Payment processing and subscription management

**Context Usage:** 7,000 tokens (53% reduction)

**File:** `.mcp-profiles/payments.json`

### Included MCPs

1. **core MCPs** (context7, github, filesystem)
2. **stripe** - Payment processing and subscription management

### Configuration

```json
{
  "mcpServers": {
    "context7": { /* core config */ },
    "github": { /* core config */ },
    "filesystem": { /* core config */ },
    "stripe": {
      "command": "npx",
      "args": ["@stripe/mcp-server"],
      "env": {
        "STRIPE_API_KEY": "${STRIPE_API_KEY}"
      }
    }
  }
}
```

### Required Environment Variables

```bash
CONTEXT7_API_KEY=your_context7_key
GITHUB_PERSONAL_ACCESS_TOKEN=your_github_token
STRIPE_API_KEY=your_stripe_key  # Use test key for development
```

### Stripe Capabilities

- **Payment Processing** - Create charges, refunds
- **Subscriptions** - Manage recurring billing
- **Products** - Create and manage products
- **Prices** - Configure pricing models
- **Customers** - Customer management
- **Invoices** - Generate and send invoices
- **Payment Methods** - Cards, bank accounts, wallets
- **Webhooks** - Event notifications
- **Analytics** - Revenue reporting
- **Disputes** - Handle chargebacks

### Use Cases

- Integrating Stripe payments
- Setting up subscription billing
- Processing one-time payments
- Managing customer accounts
- Handling refunds and disputes
- Generating invoices
- Revenue analytics
- Webhook configuration

### When to Use

✅ Use payments when:
- Integrating Stripe
- Building payment flows
- Setting up subscriptions
- Processing refunds
- Managing customer billing
- Configuring webhooks
- Analyzing revenue

❌ Don't use payments when:
- Not working with payments (use core)
- Deploying payment code (use deployment)

### Agent Compatibility

Primary agents for payments profile:
- **@developer** - Payment integration
- **@architect** - Payment system design
- @analyst - Revenue analytics
- @support - Payment issue resolution
- All core-compatible agents

### Workflow Example

```bash
# Switch to payments profile
ln -sf .mcp-profiles/payments.json .mcp.json
# Restart Claude Code

# Ask developer to integrate Stripe
@developer Implement subscription billing with Stripe - monthly and annual plans

# Developer verifies payments profile
# Creates Stripe products and prices
# Implements checkout flow
# Configures webhooks
# Tests with Stripe test mode
```

### Switching to Payments

```bash
ln -sf .mcp-profiles/payments.json .mcp.json
# Restart Claude Code
```

---

## deployment

**Purpose:** Deploying applications to production

**Context Usage:** 9,000 tokens (40% reduction)

**File:** `.mcp-profiles/deployment.json`

### Included MCPs

1. **core MCPs** (context7, github, filesystem)
2. **netlify** - Frontend hosting and edge functions
3. **railway** - Backend services and databases

### Configuration

```json
{
  "mcpServers": {
    "context7": { /* core config */ },
    "github": { /* core config */ },
    "filesystem": { /* core config */ },
    "netlify": {
      "command": "npx",
      "args": ["-y", "@netlify/mcp"],
      "env": {
        "NETLIFY_ACCESS_TOKEN": "${NETLIFY_ACCESS_TOKEN}"
      }
    },
    "railway": {
      "command": "npx",
      "args": ["-y", "@railway/mcp-server"],
      "env": {
        "RAILWAY_API_TOKEN": "${RAILWAY_API_TOKEN}"
      }
    }
  }
}
```

### Required Environment Variables

```bash
CONTEXT7_API_KEY=your_context7_key
GITHUB_PERSONAL_ACCESS_TOKEN=your_github_token
NETLIFY_ACCESS_TOKEN=your_netlify_token
RAILWAY_API_TOKEN=your_railway_token
```

### Netlify Capabilities

- **Site Deployment** - Deploy frontend applications
- **Edge Functions** - Serverless functions at the edge
- **Forms** - Form submission handling
- **Redirects** - URL redirect configuration
- **Environment Variables** - Manage env vars
- **Build Hooks** - Trigger deployments
- **Domain Management** - Custom domains
- **SSL Certificates** - Automatic HTTPS

### Railway Capabilities

- **Service Deployment** - Deploy backend applications
- **Database Hosting** - PostgreSQL, MySQL, Redis
- **Environment Variables** - Secure config management
- **Auto-scaling** - Automatic resource scaling
- **Custom Domains** - Domain configuration
- **Cron Jobs** - Scheduled tasks
- **Monitoring** - Service health and logs
- **Rollbacks** - Quick deployment rollbacks

### Use Cases

- Deploying frontend to Netlify
- Deploying backend to Railway
- Configuring production environment
- Managing environment variables
- Setting up custom domains
- Configuring SSL certificates
- Deploying edge functions
- Setting up cron jobs

### When to Use

✅ Use deployment when:
- Deploying to production
- Configuring production environment
- Managing deployment settings
- Setting up infrastructure
- Configuring domains and SSL
- Managing environment variables
- Troubleshooting deployments

❌ Don't use deployment when:
- Not deploying (use core for development)
- Just coding features (use core or fullstack)

### Agent Compatibility

Primary agents for deployment profile:
- **@operator** - Primary agent for deployments
- @architect - Infrastructure design
- @developer - Deployment scripts
- All core-compatible agents

### Workflow Example

```bash
# Switch to deployment profile
ln -sf .mcp-profiles/deployment.json .mcp.json
# Restart Claude Code

# Ask operator to deploy
@operator Deploy the latest version to production - frontend on Netlify, backend on Railway

# Operator verifies deployment profile
# Checks git status and latest commit
# Deploys frontend to Netlify
# Deploys backend to Railway
# Verifies deployments successful
# Reports deployment URLs and status
```

### Switching to Deployment

```bash
ln -sf .mcp-profiles/deployment.json .mcp.json
# Restart Claude Code
```

---

## fullstack

**Purpose:** Maximum development capabilities

**Context Usage:** 15,000 tokens (baseline, no reduction)

**File:** `.mcp-profiles/fullstack.json`

### Included MCPs

1. **core MCPs** (context7, github, filesystem)
2. **playwright** - Browser automation
3. **supabase-staging** - Staging database (read/write)
4. **stripe** - Payment processing
5. **netlify** - Frontend hosting
6. **railway** - Backend services

**Note:** Intentionally excludes production database for safety

### Configuration

```json
{
  "mcpServers": {
    "context7": { /* core config */ },
    "github": { /* core config */ },
    "filesystem": { /* core config */ },
    "playwright": { /* testing config */ },
    "supabase-staging": { /* database-staging config */ },
    "stripe": { /* payments config */ },
    "netlify": { /* deployment config */ },
    "railway": { /* deployment config */ }
  }
}
```

### Required Environment Variables

```bash
# Core
CONTEXT7_API_KEY=your_context7_key
GITHUB_PERSONAL_ACCESS_TOKEN=your_github_token

# Database
SUPABASE_STAGING_TOKEN=your_staging_token
SUPABASE_STAGING_REF=your_staging_ref

# Payments
STRIPE_API_KEY=your_stripe_key

# Deployment
NETLIFY_ACCESS_TOKEN=your_netlify_token
RAILWAY_API_TOKEN=your_railway_token
```

### Combined Capabilities

Includes all capabilities from:
- core (documentation, git, files)
- testing (browser automation)
- database-staging (database operations)
- payments (Stripe integration)
- deployment (hosting and services)

### Use Cases

- Full-stack feature development
- Working across multiple systems simultaneously
- Complex workflows requiring multiple MCPs
- When you need maximum flexibility
- Development sessions crossing multiple domains

### When to Use

✅ Use fullstack when:
- Building features spanning multiple systems
- Need testing + database + payments
- Unsure which MCPs you'll need
- Starting complex development work
- Want maximum agent capabilities

❌ Don't use fullstack when:
- Focused on single domain (use specific profile)
- Hitting context limits (switch to smaller profile)
- Need production database (use database-production separately)

### Trade-offs

**Advantages:**
- All development MCPs available
- No profile switching needed
- Maximum agent capabilities
- One profile for everything

**Disadvantages:**
- Highest context usage (15,000 tokens)
- Less context available for code/conversation
- May hit context limits faster
- Slower agent responses

### Recommended Workflow

1. **Start with smaller profiles** - Use task-specific profiles first
2. **Switch to fullstack when needed** - Only if you need multiple MCP types
3. **Monitor context usage** - Watch for context limit warnings
4. **Switch back** - Return to smaller profiles when possible

### Agent Compatibility

All AGENT-11 agents work with fullstack profile with maximum capabilities.

### Switching to Fullstack

```bash
ln -sf .mcp-profiles/fullstack.json .mcp.json
# Restart Claude Code
```

---

## Profile Switching Reference

### Quick Switch Commands

```bash
# Core (lightweight)
ln -sf .mcp-profiles/core.json .mcp.json

# Testing (browser automation)
ln -sf .mcp-profiles/testing.json .mcp.json

# Database Staging (read/write)
ln -sf .mcp-profiles/database-staging.json .mcp.json

# Database Production (read-only)
ln -sf .mcp-profiles/database-production.json .mcp.json

# Payments (Stripe)
ln -sf .mcp-profiles/payments.json .mcp.json

# Deployment (Netlify + Railway)
ln -sf .mcp-profiles/deployment.json .mcp.json

# Fullstack (everything)
ln -sf .mcp-profiles/fullstack.json .mcp.json
```

**Remember:** Always restart Claude Code after switching profiles!

### Verification

Check which profile is active:

```bash
ls -l .mcp.json
# Output: .mcp.json -> .mcp-profiles/testing.json
```

---

## Context Optimization

### Context Usage Comparison

| Profile | Tokens | vs Fullstack | Available for Code |
|---------|--------|--------------|-------------------|
| core | 3,000 | -12,000 | +12,000 |
| testing | 5,500 | -9,500 | +9,500 |
| database-staging | 8,000 | -7,000 | +7,000 |
| database-production | 8,000 | -7,000 | +7,000 |
| payments | 7,000 | -8,000 | +8,000 |
| deployment | 9,000 | -6,000 | +6,000 |
| fullstack | 15,000 | baseline | baseline |

### Recommendations

- **80% reduction (core)**: Best for code review, planning, git operations
- **63% reduction (testing)**: Efficient for test automation
- **47-53% reduction (specialized)**: Good balance for focused work
- **40% reduction (deployment)**: Reasonable for deployment tasks
- **No reduction (fullstack)**: Use only when necessary

---

## Environment Variable Reference

### Core Profile Variables

Required for all profiles:

```bash
# Context7 - Library documentation
CONTEXT7_API_KEY=your_context7_api_key

# GitHub - Repository management
GITHUB_PERSONAL_ACCESS_TOKEN=ghp_your_github_token
```

### Testing Profile Variables

No additional variables beyond core.

### Database Profile Variables

```bash
# Staging Database (read/write)
SUPABASE_STAGING_TOKEN=sbp_staging_token
SUPABASE_STAGING_REF=staging_project_ref

# Production Database (read-only)
SUPABASE_PRODUCTION_TOKEN=sbp_production_token
SUPABASE_PRODUCTION_REF=production_project_ref
```

### Payments Profile Variables

```bash
# Stripe - Payment processing
STRIPE_API_KEY=sk_test_your_stripe_key  # Use test key for development
```

### Deployment Profile Variables

```bash
# Netlify - Frontend hosting
NETLIFY_ACCESS_TOKEN=your_netlify_token

# Railway - Backend services
RAILWAY_API_TOKEN=your_railway_token
```

### Fullstack Profile Variables

Requires all variables from core, database, payments, and deployment profiles.

---

## Related Documentation

- **Setup Guide**: [MCP-GUIDE.md](./MCP-GUIDE.md)
- **Troubleshooting**: [MCP-TROUBLESHOOTING.md](./MCP-TROUBLESHOOTING.md)
- **Installation**: project/deployment/README.md
- **Agent Integration**: project/agents/specialists/

## Next Steps

1. Choose the appropriate profile for your current task
2. Switch to it using the commands above
3. Restart Claude Code
4. Verify the switch with `ls -l .mcp.json`
5. Start working - agents will use the active profile's MCPs

For common issues and solutions, see [MCP-TROUBLESHOOTING.md](./MCP-TROUBLESHOOTING.md).
