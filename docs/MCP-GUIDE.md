# MCP Guide (v6.0)

**Version**: 2.0.0 (v6.0)
**Last Updated**: 2026-05-01

This guide covers Model Context Protocol (MCP) integration in AGENT-11 v6.0. The previous `.mcp-profiles/` profile-switching system is **retired**; v6.0 uses Claude Code's native tool deferring instead.

---

## What is MCP?

The Model Context Protocol lets Claude Code talk to external services (databases, deployment platforms, payment processors, browsers, version control) through standardised tools. MCP tools appear with the `mcp__` prefix and provide direct integration without writing custom code.

**Common AGENT-11 MCP servers**:
- `mcp__supabase` — PostgreSQL, auth, RLS, storage, real-time
- `mcp__playwright` — browser automation, screenshots, accessibility
- `mcp__railway` — backend deployment, services, logs
- `mcp__netlify` — frontend hosting, edge functions
- `mcp__stripe` — payments, subscriptions, webhooks
- `mcp__github` — PRs, issues, releases, CI/CD
- `mcp__context7` — library documentation, code patterns
- `mcp__firecrawl` — web scraping, market research

---

## How v6.0 Loads MCP Tools

**Native auto-deferring** (the v6.0 mechanism):

`.claude/settings.json` ships with:

```json
{
  "env": { "ENABLE_TOOL_SEARCH": "auto" }
}
```

This activates Claude Code's threshold-based tool loading. When you have many MCP servers configured, Claude Code auto-defers most tools at session start and loads them on demand when specialists request them via Tool Search.

**Specialist workflow** (Tool-Centric):

```
1. Identify the capability you need.
2. Search for tools: tool_search_tool_regex_20251119(pattern="mcp__supabase")
3. Matching tools auto-load on first call.
4. Execute the task.
```

No manual profile switching. No restarts when changing what tools you need. The right tools load when called for.

---

## Setup

### 1. Install AGENT-11

```bash
curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/install.sh | bash
```

This deploys:
- `.claude/settings.json` with `ENABLE_TOOL_SEARCH=auto`
- `.mcp.json` (the server registry — stdio config for each MCP server)
- `.env.mcp.template` (API key template)
- `mcp-setup.sh` (helper for installing MCP server packages)

### 2. Configure API keys

```bash
# Copy the template
cp .env.mcp.template .env.mcp

# Edit with your keys
# Common ones: SUPABASE_ACCESS_TOKEN, GITHUB_PERSONAL_ACCESS_TOKEN,
#              STRIPE_API_KEY, RAILWAY_API_TOKEN, NETLIFY_AUTH_TOKEN
```

### 3. Install MCP server packages

```bash
./mcp-setup.sh
```

This installs the npm packages each MCP server needs.

### 4. Restart Claude Code

```bash
# Type /exit in Claude Code, then:
claude
```

After restart, Tool Search is active and your configured MCP servers are available on demand.

---

## Verifying MCP Tools

Inside a Claude Code session:

```
# List all available MCP tools
tool_search_tool_regex_20251119(pattern="mcp__.*")

# Find database tools
tool_search_tool_regex_20251119(pattern="mcp__supabase")

# Find browser automation tools
tool_search_tool_regex_20251119(pattern="mcp__playwright")
```

If a server isn't appearing, check:
1. `.env.mcp` has the required API keys
2. `.mcp.json` lists the server
3. The MCP server's npm package is installed (`./mcp-setup.sh`)
4. You restarted Claude Code after configuration changes

---

## Specialist → Server Mapping

Each specialist's primary MCP search patterns:

| Specialist | Primary patterns | Common use cases |
|------------|------------------|------------------|
| `@developer` | `mcp__supabase`, `mcp__context7`, `mcp__github` | DB operations, library docs, repo work |
| `@tester` | `mcp__playwright` | Browser automation, E2E tests |
| `@operator` | `mcp__railway`, `mcp__netlify`, `mcp__github` | Deployment, CI/CD |
| `@architect` | `mcp__context7`, `mcp__github`, `mcp__firecrawl` | Architecture research |
| `@analyst` | `mcp__supabase`, `mcp__firecrawl` | Data analysis, metrics |
| `@marketer` | `mcp__firecrawl`, `mcp__stripe` | Research, revenue analytics |
| `@designer` | `mcp__playwright`, `mcp__firecrawl` | Visual checks, competitor research |

Specialists search for these patterns themselves when delegated work needs MCP capabilities. You don't need to pre-load anything.

---

## v5.x → v6.0 Migration

**v6.1.0+ (recommended)** — single command:

```bash
bash <(curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/install.sh) --upgrade
```

The installer:
- Detects v5 markers and runs `migrate-v5-to-v6.sh` automatically
- Backs up everything before any change to `.claude/backups/v5-to-v6-YYYYMMDD-HHMMSS/`
- Folds `handoff-notes.md` into `agent-context.md`, retires `.mcp-profiles/`, removes `mcp/dynamic-mcp.json`
- **Merges your existing `.claude/settings.json`** (user values win; only fills gaps with `ENABLE_TOOL_SEARCH=auto` and the advisory `hooks` block)
- Deploys the v6.0 library files

Preview before running: add `--dry-run`. Bulk-mode for CI/scripts: add `--non-interactive`. Full guide and rollback flow: **[docs/UPGRADE.md](UPGRADE.md)**.

`.mcp.json` (server registry) and `.env.mcp` (API keys) are untouched.

**Rollback**: use the restore script:
```bash
bash <(curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/restore-pre-upgrade.sh) --list
```

**Manual migration** (if you prefer):
```bash
# Move handoff-notes content into agent-context
cat handoff-notes.md >> agent-context.md && rm handoff-notes.md

# Retire profile-switching directory
mv .mcp-profiles .claude/backups/

# Add ENABLE_TOOL_SEARCH to settings.json
# (use library/settings.json.template from the AGENT-11 repo as reference)
```

---

## Troubleshooting

### Tool Search returns no results

1. Verify pattern syntax: `mcp__supabase` (double underscore)
2. Try the broadest pattern: `tool_search_tool_regex_20251119(pattern="mcp__.*")`
3. Check `.env.mcp` has the required API keys
4. Check the MCP server's npm package is installed

### Specialist says "tool not found"

The specialist may have searched with the wrong pattern. The server might also not be configured. Check `.mcp.json` — if the server isn't listed there, add it via `.mcp.json.template` and restart.

### Hooks blocking my work

`.claude/settings.json` ships with **advisory** hooks (`tsc`/`ruff`/`rubocop` on save, destructive Bash confirmation). To promote a hook to **blocking**, change `|| true` at the end of its command to `|| exit 2`. To **disable** a hook, remove its entry from the array.

### Migration script refuses to run

The script refuses on:
- Directories without an AGENT-11 install (no `.claude/CLAUDE.md` or `.claude/agents/coordinator.md`) — install AGENT-11 first.
- Already-v6.0 installs (no v5.x markers detected) — nothing to migrate.

### Stale agent context after migration

If specialists seem confused after migration, check:
- `agent-context.md` exists and has both your original content and the appended Phase Handoff content (look for "Migrated from handoff-notes.md" separator).
- `progress.md` is no longer being read at session start (this is correct — it's write-only in v6.0).

---

## Reference

- **`field-manual/mcp-integration.md`** — deeper MCP integration patterns (AGENT-11-specific).
- **Anthropic MCP docs**: https://code.claude.com/docs/en/mcp
- **Tool Search**: built into Claude Code; no separate setup beyond `ENABLE_TOOL_SEARCH=auto` in `.claude/settings.json`.

---

## What v6.0 Does NOT Do

- **Per-tool `defer_loading` config in `.mcp.json`**. That's a Claude API feature, not Claude Code. v6.0's Sprint 11 attempt at this (`project/mcp/dynamic-mcp.json`) was based on a schema misreading — caught and archived in Sprint 4f.
- **Profile switching**. Retired. Native deferring replaces it.
- **Manual MCP optimisation**. The `mcp-optimization-guide.md` from v5.x is archived; its premise no longer applies.

If something in your workflow expects the v5.x patterns, run `bash install.sh --upgrade` (v6.1.0+) to bring your project up to date.
