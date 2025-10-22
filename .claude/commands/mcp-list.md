# MCP Profile List

**Usage:** `/mcp-list`

Shows all available MCP profiles with descriptions and recommendations.

---

## Your Task

The user wants to see all available MCP profiles.

Show them this information in a clear, scannable format:

```
📋 Available MCP Profiles

Current profile: [show current using: ls -l .mcp.json]

────────────────────────────────────────────

⭐ core (RECOMMENDED for most work)
   MCPs: context7, github, filesystem
   Context: 3,000 tokens (80% less than fullstack)
   Best for: General development, code review, documentation

   Switch: /mcp-switch core

────────────────────────────────────────────

🧪 testing
   MCPs: core + playwright
   Context: 5,500 tokens (63% less than fullstack)
   Best for: Running tests, E2E testing, browser automation

   Switch: /mcp-switch testing

────────────────────────────────────────────

🗄️ database-staging
   MCPs: core + supabase-staging
   Context: 8,000 tokens (47% less than fullstack)
   Access: FULL READ/WRITE (safe for development)
   Best for: Database migrations, schema changes, development queries

   Switch: /mcp-switch database-staging

────────────────────────────────────────────

🔒 database-production
   MCPs: core + supabase-production
   Context: 8,000 tokens (47% less than fullstack)
   Access: READ-ONLY (no writes possible - safety enforced)
   Best for: Production queries, data analysis, reporting

   ⚠️ READ-ONLY MODE - Use staging for development

   Switch: /mcp-switch database-production

────────────────────────────────────────────

💳 payments
   MCPs: core + stripe
   Context: 7,000 tokens (53% less than fullstack)
   Best for: Payment integration, Stripe API work, subscriptions

   Switch: /mcp-switch payments

────────────────────────────────────────────

🚀 deployment
   MCPs: core + netlify + railway
   Context: 9,000 tokens (40% less than fullstack)
   Best for: Deploying apps, infrastructure management

   Switch: /mcp-switch deployment

────────────────────────────────────────────

🔧 fullstack
   MCPs: All development MCPs (7 total)
   Context: 15,000 tokens (baseline - uses most context)
   Best for: Complex work needing multiple services at once

   ⚠️ HIGH CONTEXT USAGE - only use when you need multiple services

   Switch: /mcp-switch fullstack

────────────────────────────────────────────

💡 Quick Tips:
• Start with 'core' for most work - switch only when needed
• After switching, you'll need to restart: /exit then claude
• Check your current profile: /mcp-status
• Each profile loads only what you need, saving 40-80% context

📚 More details: docs/MCP-PROFILES.md
```

---

## Highlighting Current Profile

When showing the current profile, add a visual indicator:

```
📋 Available MCP Profiles

Current profile: testing ✅

────────────────────────────────────────────

⭐ core
   [standard description]

────────────────────────────────────────────

🧪 testing ✅ ← YOU ARE HERE
   [highlighted description]

   Already active - you're using this profile now

────────────────────────────────────────────

[rest of profiles...]
```

---

## If No Profile Active

If `.mcp.json` doesn't exist:

```
📋 Available MCP Profiles

⚠️ No profile currently active

[show full list]

────────────────────────────────────────────

🎯 To get started:
1. Choose a profile (core is recommended)
2. Switch to it: /mcp-switch core
3. Restart: /exit then claude

Need help deciding? The 'core' profile works for 90% of tasks.
```

---

## Communication Style

✅ **Use emojis for visual scanning**
✅ **Clear separators between profiles**
✅ **Show the switch command for each profile**
✅ **Highlight warnings (production read-only, high context usage)**
✅ **Make current profile obvious**

❌ Don't be verbose
❌ Don't use technical jargon
❌ Don't hide the context savings
❌ Don't make users remember syntax

---

## Profile Selection Guidance

If user seems unsure, offer guidance:

```
Not sure which profile to choose? Here's a quick guide:

• Working on code, docs, or planning? → core
• Running tests or using Playwright? → testing
• Need database access for development? → database-staging
• Need to query production data? → database-production
• Integrating payments? → payments
• Deploying your app? → deployment
• Need multiple services at once? → fullstack

Still not sure? Start with 'core' - it works for most tasks and you can switch anytime.
```
