# MCP Profile Switcher

**Usage:** `/mcp-switch [profile-name]`

**Available profiles:**
- `core` - Essential tools only (recommended for most work)
- `testing` - Adds Playwright for browser testing
- `database-staging` - Adds database access (read/write, safe for development)
- `database-production` - Adds database access (read-only, production queries)
- `payments` - Adds Stripe for payment integration
- `deployment` - Adds Netlify + Railway for deployments
- `fullstack` - All development tools (uses more context)

---

## Your Task

The user wants to switch to the **{profile-name}** profile.

**Step 1: Confirm the switch**

Tell the user:
```
Switching to {profile-name} profile...

This profile includes:
[List the MCPs for this profile]

Context usage: [X tokens] ([Y%] reduction from fullstack)
```

**Step 2: Make the switch**

Run this command:
```bash
ln -sf .mcp-profiles/{profile-name}.json .mcp.json
```

**Step 3: Guide restart**

Tell the user:
```
✅ Profile switched to {profile-name}

To activate the new profile, restart Claude Code:
1. Type: /exit
2. Then run: claude

After restart, verify with: /mcp-status
```

**Step 4: Verify (after restart)**

After they restart, run:
```bash
ls -l .mcp.json
```

Confirm it points to the correct profile.

---

## Profile Details

### core
- **MCPs:** context7, github, filesystem
- **Context:** 3,000 tokens (80% reduction)
- **Best for:** General development, code review, documentation

### testing
- **MCPs:** core + playwright
- **Context:** 5,500 tokens (63% reduction)
- **Best for:** Running tests, E2E testing, browser automation

### database-staging
- **MCPs:** core + supabase-staging
- **Context:** 8,000 tokens (47% reduction)
- **Best for:** Database migrations, schema changes, development queries
- **Access:** Full read/write

### database-production
- **MCPs:** core + supabase-production
- **Context:** 8,000 tokens (47% reduction)
- **Best for:** Production queries, data analysis, reporting
- **Access:** ⚠️ READ-ONLY (no writes possible)

### payments
- **MCPs:** core + stripe
- **Context:** 7,000 tokens (53% reduction)
- **Best for:** Payment integration, Stripe API work, subscriptions

### deployment
- **MCPs:** core + netlify + railway
- **Context:** 9,000 tokens (40% reduction)
- **Best for:** Deploying apps, infrastructure management

### fullstack
- **MCPs:** All development MCPs
- **Context:** 15,000 tokens (baseline)
- **Best for:** Complex multi-service work
- **Note:** Uses more context - only use when you need multiple services

---

## Error Handling

**If profile doesn't exist:**
Tell the user:
```
❌ Profile '{profile-name}' not found.

Available profiles: core, testing, database-staging, database-production, payments, deployment, fullstack

Use: /mcp-list to see descriptions of each profile
```

**If no profile specified:**
Tell the user:
```
Please specify a profile name.

Usage: /mcp-switch [profile-name]

Quick examples:
- /mcp-switch core
- /mcp-switch testing
- /mcp-switch database-staging

Use /mcp-list to see all available profiles.
```

---

## Communication Style

✅ **Use simple, clear language**
✅ **Break instructions into numbered steps**
✅ **Show exactly what will happen**
✅ **Confirm completion**

❌ Don't use technical jargon
❌ Don't skip the restart instruction
❌ Don't assume they know Unix commands
