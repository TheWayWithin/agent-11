# MCP Context Optimization Guide

**Version**: 1.0.0
**Created**: 2025-11-28 (Sprint 5)
**Purpose**: Reduce MCP token consumption by 60% without API-level features

## Why MCP Optimization Matters

Claude Code loads ALL tools from configured MCP servers at conversation start. This creates significant context overhead:

| Profile | Tokens Used | Context Available |
|---------|-------------|-------------------|
| Minimal | ~5K | 195K (97%) |
| Core | ~50K | 150K (75%) |
| Full | ~80K | 120K (60%) |

**Problem**: Heavy MCP profiles leave less context for actual work.

**Solution**: Use lean, mission-specific profiles and optimized tool patterns.

## Profile-Based Optimization

### Profile Selection Matrix

| Mission Type | Recommended Profile | Tokens |
|--------------|---------------------|--------|
| Quick file edits | minimal-core | ~5K |
| Research/docs | research-only | ~15K |
| Frontend deploy | frontend-deploy | ~15K |
| Backend deploy | backend-deploy | ~15K |
| Database read | db-read | ~15K |
| Database write | db-write | ~18K |
| Standard dev | core | ~50K |
| Testing | testing | ~62K |
| Full-stack | deployment | ~78K |

### Activating Profiles

```bash
# Switch to minimal profile
ln -sf .mcp-profiles/minimal-core.json .mcp.json

# Restart Claude Code
```

### Profile Decision Tree

```
Do you need external services?
├── NO → minimal-core (~5K)
└── YES
    ├── Only documentation? → research-only (~15K)
    ├── Only deployment?
    │   ├── Frontend → frontend-deploy (~15K)
    │   └── Backend → backend-deploy (~15K)
    ├── Only database?
    │   ├── Read-only → db-read (~15K)
    │   └── Read/write → db-write (~18K)
    ├── Full GitHub access? → core (~50K)
    └── Everything? → deployment (~78K)
```

## Tool Consolidation Patterns

### Description Optimization Formula

**Pattern**: `Action verb + object + key parameters`

**Examples**:
- ✅ "Search files: query, types → matches"
- ✅ "Create PR: branch→main with title, body"
- ❌ "This tool allows you to search through files in the codebase..."

**Before** (47 tokens):
```
"Creates a new pull request in the GitHub repository. This tool allows you to
specify the source branch, target branch, title, body, and reviewers. It will
validate that the branches exist and that you have permission to create PRs."
```

**After** (12 tokens):
```
"Create PR: source→target with title, body, reviewers"
```

**Savings**: 74% per description

### Consolidated Tool Reference

Instead of 32 separate tools, use 8 consolidated patterns:

| Consolidated Tool | Operations | Replaces | Savings |
|-------------------|------------|----------|---------|
| agent11_docs | resolve, fetch, search | context7 (2 tools) | 50% |
| agent11_git | pr, issue, file, commit | github (5 tools) | 80% |
| agent11_deploy | netlify, railway | deploy tools (8) | 89% |
| agent11_research | scrape, search, grep | firecrawl+grep | 66% |
| agent11_web | search, fetch | WebSearch/Fetch | 60% |
| agent11_db | sql, auth, storage | supabase (3) | 70% |
| agent11_test | navigate, click, shot | playwright (5) | 80% |

**Total Reduction**: 55.5K → 14K = **74.8%**

See `/project/mcp/mcp-agent11-optimized.md` for full specification.

## Agent-Specific Recommendations

### Coordinator
- **Default Profile**: core
- **Optimization**: Switch to minimal-core for planning phases
- **When to escalate**: Add services only when delegating to specialists

### Developer
- **Default Profile**: core
- **Optimization**: Use minimal-core for file-only work
- **Add database**: db-write when needed
- **Add testing**: testing when needed

### Tester
- **Default Profile**: testing
- **Optimization**: Use minimal-core for test file creation
- **Full profile**: Only for Playwright automation

### Operator/Deployer
- **Default Profile**: deployment or frontend-deploy/backend-deploy
- **Optimization**: Split frontend/backend into separate profiles
- **Savings**: 78K → 15K when using specialized profiles

### Documenter
- **Default Profile**: research-only
- **Optimization**: Minimal external services needed
- **Focus**: Context7 for library docs

### Analyst
- **Default Profile**: research-only
- **Optimization**: Add database when analysis needed
- **Focus**: Research and documentation tools

## mcpick Integration

For easier profile switching, use [mcpick](https://github.com/anthropics/mcpick):

```bash
# Install
npm install -g mcpick

# Interactive profile selector
npx mcpick

# Direct selection
npx mcpick use minimal-core
```

## Quick Reference Card

### Token Targets by Scenario

| Scenario | Target Tokens | Profile |
|----------|---------------|---------|
| Emergency fix | <5K | minimal-core |
| Research task | <15K | research-only |
| Single deploy | <15K | frontend/backend-deploy |
| Standard dev | <50K | core |
| Full project | <80K | deployment |

### Profile Switching Commands

```bash
# Minimal (fastest)
ln -sf .mcp-profiles/minimal-core.json .mcp.json

# Research
ln -sf .mcp-profiles/research-only.json .mcp.json

# Core (standard)
ln -sf .mcp-profiles/core.json .mcp.json

# Frontend deploy
ln -sf .mcp-profiles/frontend-deploy.json .mcp.json

# Backend deploy
ln -sf .mcp-profiles/backend-deploy.json .mcp.json

# Database read
ln -sf .mcp-profiles/db-read.json .mcp.json

# Database write
ln -sf .mcp-profiles/db-write.json .mcp.json

# Testing
ln -sf .mcp-profiles/testing.json .mcp.json
```

## Future: defer_loading

Anthropic's API supports `defer_loading` for 85% token reduction, but Claude Code doesn't support it yet ([GitHub Issue #7328](https://github.com/anthropics/claude-code/issues/7328)).

**When available**, update profiles:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["@edjl/github-mcp"],
      "default_config": {
        "defer_loading": true
      },
      "configs": {
        "create_pull_request": { "defer_loading": false }
      }
    }
  }
}
```

**Ready-to-use templates** will be in `/project/mcp/future/`.

## Troubleshooting

### Profile Not Loading
1. Verify symlink: `ls -la .mcp.json`
2. Check JSON syntax: `python3 -m json.tool .mcp.json`
3. Restart Claude Code

### Tools Not Available
1. Check profile includes required MCP server
2. Verify environment variables in `.env.mcp`
3. Check MCP server is installed: `npx @context7/mcp-server --version`

### High Token Usage
1. Check current profile: `cat .mcp.json`
2. Switch to leaner profile for current task
3. Split work across multiple sessions if needed

### Environment Variables Missing
```bash
# Check which vars are set
grep -v '^#' .env.mcp

# Required vars per profile:
# minimal-core: none
# research-only: CONTEXT7_API_KEY, FIRECRAWL_API_KEY
# core: CONTEXT7_API_KEY, GITHUB_PERSONAL_ACCESS_TOKEN
# database: SUPABASE_ACCESS_TOKEN, SUPABASE_PROJECT_REF
# deployment: NETLIFY_ACCESS_TOKEN, RAILWAY_API_TOKEN
# testing: none (playwright is local)
# payments: STRIPE_API_KEY
```

## Metrics & Monitoring

### What to Track
1. **Token consumption per profile** - Before/after optimization
2. **Tool selection accuracy** - Failed tool calls
3. **Mission completion rate** - Ensure optimization doesn't hurt outcomes
4. **Profile switch frequency** - Should decrease with better-targeted profiles

### Expected Results

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Avg profile tokens | 50-60K | 20-30K | 50-60% |
| Minimal profile | N/A | 5K | New |
| Lean profiles | N/A | 15K | New |
| Profile switches/mission | 2-3 | 0-1 | 66% |

---

**Document Version**: 1.0.0
**Sprint**: 5 - MCP Context Optimization
**Last Updated**: 2025-11-28
