# MCP Integration Guide for AGENT-11 🔌

## What are MCPs?

Model Context Protocol (MCP) servers are specialized tools available in Claude Code that provide direct integration with external services and enhanced capabilities. They appear as tools prefixed with `mcp__` and enable agents to perform complex tasks efficiently without writing custom code.

## Discovery Protocol

### Finding Available MCPs
```bash
# Primary discovery method
grep "mcp__"

# Look for tools starting with mcp__ prefix
# Common pattern: mcp__[service]__[action]
```

### MCP Assessment Checklist
1. ✅ Check for MCPs at mission start
2. ✅ Map MCPs to planned tasks
3. ✅ Document available MCPs in project-plan.md
4. ✅ Track MCP usage throughout project
5. ✅ Update CLAUDE.md with discovered patterns

## Core MCP Categories

### 🔧 Development Stack
Essential MCPs for building features:

#### Context7 - Documentation & Code Analysis
```bash
# Find library documentation
mcp__context7__resolve-library-id "react"
mcp__context7__get-library-docs "/facebook/react"

# Use cases:
- Library documentation retrieval
- Code pattern analysis
- Best practices research
- API reference lookup
```

#### Supabase - Database & Authentication
```bash
# Database and auth operations
mcp__supabase

# Use cases:
- Database setup and management
- Authentication implementation
- Real-time features
- Storage management
```

#### GitHub - Repository Management
```bash
# Repository operations
mcp__github

# Use cases:
- Pull request creation
- Issue management
- Release automation
- Branch operations
```

#### Firecrawl - Web Research & Scraping
```bash
# Web content extraction
mcp__firecrawl__firecrawl_scrape
mcp__firecrawl__firecrawl_search
mcp__firecrawl__firecrawl_extract

# Use cases:
- API documentation extraction
- Competitor analysis
- Market research
- Content aggregation
```

### 🧪 Testing & Quality

#### Playwright - Browser Automation
```bash
# E2E testing automation
mcp__playwright__browser_navigate
mcp__playwright__browser_click
mcp__playwright__browser_snapshot

# Use cases:
- End-to-end testing
- Cross-browser validation
- Visual regression testing
- User flow automation
```

### 🚀 Infrastructure & Deployment

#### Netlify - Frontend Hosting
```bash
# Deployment automation
mcp__netlify

# Use cases:
- Static site deployment
- Serverless functions
- Form handling
- CDN configuration
```

#### Railway - Backend Services
```bash
# Backend deployment
mcp__railway

# Use cases:
- API deployment
- Database hosting
- Background jobs
- Service scaling
```

## Agent-Specific MCP Usage

### 👨‍💻 Developer
**Primary MCPs**: Context7, Supabase, GitHub, Firecrawl

```markdown
Implementation Checklist:
- [ ] Check mcp__supabase for database tasks
- [ ] Use mcp__context7 for library docs
- [ ] Use mcp__github for version control
- [ ] Use mcp__firecrawl for API research
```

### 🏗️ Architect
**Primary MCPs**: Context7, Firecrawl

```markdown
Research Protocol:
1. Use mcp__context7 for framework documentation
2. Use mcp__firecrawl for pattern analysis
3. Research competitors with mcp__firecrawl
4. Document MCP-sourced decisions
```

### 🧪 Tester
**Primary MCPs**: Playwright, Context7

```markdown
Testing Automation:
1. Always check for mcp__playwright first
2. Generate tests from user stories
3. Use mcp__context7 for test framework docs
4. Fall back to manual only if unavailable
```

### ⚙️ Operator
**Primary MCPs**: Supabase, Netlify, Railway

```markdown
Infrastructure Setup:
- Database: mcp__supabase
- Frontend: mcp__netlify
- Backend: mcp__railway
- Monitoring: Check for specific MCPs
```

### 🎯 Coordinator
**Assessment Responsibility**: Check all MCPs

```markdown
MCP Delegation:
1. grep "mcp__" at mission start
2. Map MCPs to specialists
3. Include MCPs in task context
4. Track usage in project-plan.md
```

## Best Practices

### Least-Privilege Credentials (read this before minting any key)

Most AGENT-11 setups combine a browser MCP (Playwright) with MCPs that read
private data. Playwright can navigate, click, and submit forms on the open
web, so anything another MCP can read, a prompt-injected agent can exfiltrate
by pasting it into a form or URL. Scope every credential as if this will
happen:

1. **Supabase**: never use a service-role or full-access key for agent work.
   The MCP server runs with `--read-only` and `--project-ref` in AGENT-11
   configs; keep both flags, and prefer a database role or key limited to the
   tables the project actually needs.
2. **Filesystem**: pin the root to the current project directory (AGENT-11
   configs use `.` / the project root). Never point it at `$HOME` or `/` — a
   wide root exposes SSH keys, other repos, and personal files.
3. **Figma**: use a token scoped to the one file or project being built,
   read-only. A team-wide token exposes unreleased product designs.
4. **GitHub**: use a fine-grained PAT scoped to the one repository this
   project uses, with only the permissions the mission needs. A classic
   `repo`-scope PAT reads every private repo on the account.
5. **Stripe**: test-mode keys for agent work; if live data is unavoidable,
   a restricted read-only key. A full-access `sk_live_` key exposes customer
   PII and payment history.
6. **Everything else**: narrowest scope, shortest expiry the provider
   supports, read-only unless the mission needs writes. Real values live only
   in a gitignored `.env.mcp` — placeholders everywhere else.

### MCP-First Development
1. **Always check first**: Before manual implementation
2. **Document usage**: Track in project-plan.md
3. **Share discoveries**: Update CLAUDE.md
4. **Fallback ready**: Have manual approach as backup

### Common Patterns

#### Database Operations
```bash
# Instead of: Writing custom Supabase client
# Use: mcp__supabase for all operations
```

#### Documentation Research
```bash
# Instead of: Googling for docs
# Use: mcp__context7__get-library-docs
```

#### Web Scraping
```bash
# Instead of: Writing scraping scripts
# Use: mcp__firecrawl__firecrawl_scrape
```

#### Testing Automation
```bash
# Instead of: Manual Playwright setup
# Use: mcp__playwright browser commands
```

## MCP Discovery Mission

When starting a new project:

```markdown
## MCP Discovery Checklist
- [ ] Run grep "mcp__" to find all MCPs
- [ ] Document in project-plan.md
- [ ] Map MCPs to team specialists
- [ ] Create MCP usage guidelines
- [ ] Update CLAUDE.md with patterns
```

## Fallback Strategies

When MCPs are unavailable:

1. **Document absence**: Note in project-plan.md
2. **Manual implementation**: Use traditional approach
3. **Request addition**: Suggest MCP installation
4. **Track workarounds**: Document for future

## Performance Benefits

Using MCPs provides:
- ⚡ **Speed**: Pre-built integrations
- 🎯 **Accuracy**: Tested implementations
- 📚 **Documentation**: Always up-to-date
- 🔄 **Consistency**: Standardized approaches
- 🛡️ **Reliability**: Maintained by providers

## Troubleshooting

### MCP Not Available
- Check spelling: `mcp__` prefix required
- Verify installation in project
- Check Claude Code MCP settings
- Fall back to manual approach

### MCP Errors
- Check parameters and format
- Verify service credentials
- Review MCP documentation
- Report to @coordinator

## Future MCPs to Watch

Keep an eye out for:
- Analytics MCPs (tracking, metrics)
- Email service MCPs (SendGrid, Resend)
- Payment MCPs (Stripe expansion)
- Monitoring MCPs (Sentry, DataDog)
- AI service MCPs (OpenAI, Anthropic)

---

## Quick Reference

```bash
# Discovery
grep "mcp__"

# Common MCPs
mcp__context7__get-library-docs    # Documentation
mcp__supabase                      # Database
mcp__firecrawl__firecrawl_scrape  # Web scraping
mcp__playwright__browser_*         # Testing
mcp__github                        # Version control
mcp__netlify                       # Frontend deploy
mcp__railway                       # Backend deploy
```

---

*"Use the tools available before building new ones. MCPs are force multipliers for AGENT-11 specialists."*