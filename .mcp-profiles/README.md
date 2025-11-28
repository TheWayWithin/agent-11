# MCP Profile System - Sprint 5 Optimization

**Token Optimization Strategy**: Use the leanest profile that meets your needs.

## Quick Profile Selection

| Profile | Tokens | Use When |
|---------|--------|----------|
| **minimal-core** | ~3-5K | File operations only, no external services |
| **research-only** | ~12-15K | Documentation lookup, web research |
| **frontend-deploy** | ~12-15K | Netlify static site deployments |
| **backend-deploy** | ~12-15K | Railway API/backend deployments |
| **db-read** | ~12-15K | Read-only database queries |
| **db-write** | ~15-18K | Full database access with writes |
| **core** | ~36-50K | Standard development (context7+github+fs) |
| **testing** | ~44-62K | Browser automation with Playwright |
| **deployment** | ~58-78K | Full deploy (Netlify+Railway) |
| **payments** | ~50-68K | Stripe payment integration |

## Activation

```bash
# Switch to minimal profile (fastest startup)
ln -sf .mcp-profiles/minimal-core.json .mcp.json

# Switch to research profile
ln -sf .mcp-profiles/research-only.json .mcp.json

# Switch back to full core
ln -sf .mcp-profiles/core.json .mcp.json
```

**Restart Claude Code after switching profiles.**

## Profile Decision Tree

```
Need external services?
├── NO → minimal-core (~5K tokens)
└── YES
    ├── Documentation/Research? → research-only (~15K)
    ├── Frontend Deploy? → frontend-deploy (~15K)
    ├── Backend Deploy? → backend-deploy (~15K)
    ├── Database Read? → db-read (~15K)
    ├── Database Write? → db-write (~18K)
    ├── Payments? → payments (~68K)
    ├── Testing? → testing (~62K)
    └── Full Dev Work → core (~50K)
```

## Token Savings

| Scenario | Full Profile | Optimized | Savings |
|----------|-------------|-----------|---------|
| Quick file edits | 50K | 5K | **90%** |
| Research task | 50K | 15K | **70%** |
| Frontend deploy | 78K | 15K | **81%** |
| Database query | 72K | 15K | **79%** |

## Environment Variables

All profiles use environment variables from `.env.mcp`:

```bash
CONTEXT7_API_KEY=your_key
GITHUB_PERSONAL_ACCESS_TOKEN=your_token
NETLIFY_ACCESS_TOKEN=your_token
RAILWAY_API_TOKEN=your_token
SUPABASE_ACCESS_TOKEN=your_token
SUPABASE_PROJECT_REF=your_ref
FIRECRAWL_API_KEY=your_key
STRIPE_API_KEY=your_key
```

## mcpick Integration

For even easier profile switching, use [mcpick](https://npmjs.com/package/mcpick):

```bash
npx mcpick  # Interactive profile selector
```

---

*Created: 2025-11-28 | Sprint 5: MCP Context Optimization*
