# MCP Migration Guide: Static to Dynamic Tool Loading

**Version**: 1.0
**Sprint**: 11 - Dynamic MCP Architecture
**Date**: January 2026

## Table of Contents

1. [Overview](#overview)
2. [Why This Change?](#why-this-change)
3. [Before/After Comparison](#beforeafter-comparison)
4. [Migration Steps](#migration-steps)
5. [How Tool Search Works](#how-tool-search-works)
6. [Agent-Specific Changes](#agent-specific-changes)
7. [Troubleshooting](#troubleshooting)
8. [Rollback Instructions](#rollback-instructions)
9. [FAQ](#faq)

---

## Overview

### What Changed

AGENT-11 has transitioned from **static MCP tool profiles** to a **dynamic tool loading system** powered by Tool Search. This fundamental shift changes how agents discover and load MCP tools.

**Old System (Static Profiles)**:
- Pre-loaded all MCP tools into agent context at startup
- 51,000+ tokens consumed upfront
- Required manual profile switching between contexts
- Agent-specific profiles (developer.json, tester.json, etc.)

**New System (Dynamic Loading)**:
- Tools loaded on-demand via Tool Search queries
- 3,300 tokens initial load (93.5% reduction)
- Peak context usage <10,000 tokens
- Single unified configuration
- Intelligent tool discovery based on task requirements

### Token Savings

| Metric | Static Profiles | Dynamic Loading | Improvement |
|--------|----------------|-----------------|-------------|
| **Initial Context** | 51,427 tokens | 3,300 tokens | **93.5% reduction** |
| **Peak Context** | 51,427 tokens | <10,000 tokens | **80%+ reduction** |
| **Profiles Needed** | 11 files | 1 file | **91% fewer files** |
| **Maintenance** | Manual updates | Auto-discovery | **Zero maintenance** |

### Benefits

- **Massive Context Savings**: 93.5% reduction in initial token usage
- **No Manual Switching**: Agents automatically discover needed tools
- **Efficient Resource Use**: Only load tools when actually needed
- **Better Scalability**: Add new MCPs without updating profiles
- **Simpler Maintenance**: Single configuration file to manage
- **Faster Agent Startup**: Minimal context initialization

---

## Why This Change?

### The Static Profile Problem

The original static profile system had critical limitations:

1. **Context Bloat**: Pre-loading all tools consumed 51K+ tokens before any work
2. **Profile Management**: 11 separate files required manual updates
3. **Tool Waste**: Agents loaded tools they never used (90%+ waste)
4. **Coordination Overhead**: Required manual profile switching
5. **Scalability Issues**: Adding MCPs meant updating all profiles

### The Dynamic Loading Solution

Tool Search enables:

1. **Lazy Loading**: Tools loaded only when needed
2. **Intelligent Discovery**: Regex-based tool finding
3. **Single Source of Truth**: One `dynamic-mcp.json` configuration
4. **Zero Maintenance**: Agents discover tools automatically
5. **Context Efficiency**: 93.5% reduction in token usage

### Real-World Impact

Consider a typical mission:

**Static Profiles (Old)**:
```
Mission Start: 51K tokens (all MCP tools loaded)
Agent Task 1: Uses 3 tools, wastes 48K context
Agent Task 2: Uses 2 tools, wastes 49K context
Agent Task 3: Uses 4 tools, wastes 47K context
Total Waste: ~144K tokens across 3 agents
```

**Dynamic Loading (New)**:
```
Mission Start: 3.3K tokens (Tool Search only)
Agent Task 1: Loads 3 tools = +2K tokens (5.3K total)
Agent Task 2: Loads 2 tools = +1.5K tokens (4.8K total)
Agent Task 3: Loads 4 tools = +2.5K tokens (5.8K total)
Total Usage: ~16K tokens across 3 agents (89% savings)
```

---

## Before/After Comparison

### Configuration Files

**Before (Static Profiles)**:
```
project/
├── .mcp.json                    # Base MCP servers
└── .mcp/
    └── profiles/
        ├── developer.json       # Developer-specific tools
        ├── tester.json          # Tester-specific tools
        ├── operator.json        # Operator-specific tools
        └── ... (11 profile files)
```

**After (Dynamic Loading)**:
```
project/
└── .mcp.json                    # Single unified configuration
```

### Agent Context Loading

**Before (Static)**:
```yaml
# Agent startup sequence
1. Load agent profile (e.g., developer.json)
2. Pre-load ALL tools from profile (51K tokens)
3. Agent ready with full tool context
4. Agent uses 3-5 tools (90% waste)
```

**After (Dynamic)**:
```yaml
# Agent startup sequence
1. Load Tool Search capabilities (3.3K tokens)
2. Agent ready with discovery tools
3. Agent searches for needed tools on-demand
4. Tools loaded as required (2-6K tokens total)
```

### Code Examples

**Before: Manual Profile Loading**
```json
// .mcp/profiles/developer.json
{
  "mcpServers": {
    "supabase": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-supabase"],
      "env": {
        "SUPABASE_URL": "${SUPABASE_URL}",
        "SUPABASE_SERVICE_ROLE_KEY": "${SUPABASE_SERVICE_ROLE_KEY}"
      }
    },
    "github": { ... },
    // ... 15+ more servers (51K tokens)
  }
}
```

**After: Dynamic Discovery**
```json
// .mcp.json (single file)
{
  "mcpServers": {
    "supabase": { ... },
    "github": { ... }
    // All servers defined once, loaded on-demand
  }
}
```

---

## Migration Steps

### Prerequisites

- Claude Code version supporting Tool Search
- Backup of current `.mcp.json` configuration
- All environment variables configured in `.env.mcp`

### Step 1: Backup Existing Configuration

```bash
# Backup current configuration
cp .mcp.json .mcp.json.backup
cp -r .mcp/ .mcp.backup/ 2>/dev/null || true

# Verify backup
ls -lh .mcp.json.backup
```

### Step 2: Install Dynamic Configuration

```bash
# Copy dynamic configuration from AGENT-11
cp /path/to/agent-11/project/mcp/dynamic-mcp.json .mcp.json

# Verify installation
cat .mcp.json | head -20
```

### Step 3: Verify Environment Variables

The dynamic configuration uses the same environment variables:

```bash
# Check .env.mcp has all required variables
grep -E "(SUPABASE|GITHUB|PLAYWRIGHT|STRIPE|FIRECRAWL|CONTEXT7)" .env.mcp
```

**Required Variables**:
```bash
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
GITHUB_PERSONAL_ACCESS_TOKEN=ghp_your_token
STRIPE_SECRET_KEY=sk_test_your_key
FIRECRAWL_API_KEY=your-firecrawl-key
CONTEXT7_API_KEY=your-context7-key
```

### Step 4: Remove Static Profiles (Optional)

```bash
# Remove old profile directory (after backup)
rm -rf .mcp/profiles/
```

### Step 5: Restart Claude Code

1. **Quit Claude Code completely** (not just close window)
2. **Restart Claude Code**
3. **Wait for MCP servers to initialize** (~10-30 seconds)

### Step 6: Verify Tool Search

Test that Tool Search is working:

```bash
# In Claude Code chat
/mcp-status
```

**Expected Output**:
```
✓ Tool Search available
✓ MCP servers loaded: 7 active
  - supabase (5 tools discoverable)
  - github (8 tools discoverable)
  - playwright (12 tools discoverable)
  - stripe (6 tools discoverable)
  - firecrawl (4 tools discoverable)
  - context7 (3 tools discoverable)
  - railway (6 tools discoverable)
```

### Step 7: Test Dynamic Loading

Verify tools load on-demand:

```bash
# Request a database operation
"Create a users table in Supabase"

# Agent should:
# 1. Use Tool Search to find supabase tools
# 2. Load only supabase MCP tools
# 3. Execute supabase operations
```

**Success Indicators**:
- Agent finds tools via Tool Search
- Only relevant tools loaded (not all 50+)
- Tools execute successfully
- Context usage <10K tokens

---

## How Tool Search Works

### Discovery vs Execution

The dynamic system separates tool discovery from execution:

**Discovery Phase** (Tool Search):
- Agent needs tools for a task
- Runs regex query to find matching tools
- Returns tool names and descriptions
- Minimal context usage (~500 tokens per query)

**Execution Phase** (Tool Loading):
- Agent requests specific tools
- System loads full tool schemas
- Agent executes tools
- Tools remain loaded for session

### Tool Search Query Patterns

Common regex patterns for finding tools:

#### Database Operations
```regex
supabase__          # All Supabase tools
supabase__insert    # Insert operations only
supabase__(select|insert|update)  # Multiple operations
```

#### Version Control
```regex
github__            # All GitHub tools
github__pull        # Pull request tools
github__create.*repo  # Repository creation
```

#### Testing & Automation
```regex
playwright__        # All Playwright tools
playwright__navigate  # Navigation tools
playwright__screenshot  # Screenshot tools
```

#### Payments
```regex
stripe__            # All Stripe tools
stripe__customer    # Customer management
stripe__subscription  # Subscription tools
```

### Query Optimization Tips

**Use Specific Patterns**:
```regex
# Too broad (returns 50+ tools)
.*__

# Better (returns 5-10 tools)
supabase__

# Best (returns 1-2 tools)
supabase__insert
```

---

## Agent-Specific Changes

### Coordinator

**Updated Delegation Pattern**:
```markdown
Task(
  subagent_type="developer",
  description="Database schema setup",
  prompt="""
  First read agent-context.md and handoff-notes.md for mission context.

  Task: Create users and projects tables in Supabase.

  Use Tool Search to discover database tools as needed.
  Update handoff-notes.md with schema details.
  """
)
```

### Developer

**Discovers tools based on tech stack**:
```yaml
Scenario: Backend API development

Step 1: Database Tools
- Tool Search "supabase__" → Load database tools
- Context: +2K tokens

Step 2: Version Control
- Tool Search "github__" → Load Git tools
- Context: +1.5K tokens

Total: ~6K tokens (vs 51K static)
```

### Tester

**Loads based on test type**:
```yaml
Unit Tests:
- No MCP tools needed (uses Read/Edit/Bash)
- Context: 3.3K tokens (Tool Search only)

E2E Tests:
- Tool Search "playwright__" → Load browser automation
- Context: +3K tokens
```

### Operator

**Loads based on deployment target**:
```yaml
Deployment Planning:
- Tool Search "(railway|vercel|netlify)__" → Infrastructure tools
- Context: +4K tokens

Database Management:
- Tool Search "supabase__" → Database tools
- Context: +2K tokens
```

---

## Troubleshooting

### "Tool not found" Errors

**Symptom**: Agent reports tool doesn't exist

**Solution**:
1. Verify MCP server is running: `/mcp-status`
2. Broaden Tool Search query (e.g., `supabase__` instead of `supabase__insert_user`)
3. Check server configuration in `.mcp.json`
4. Verify environment variables in `.env.mcp`

### Context Budget Exceeded

**Symptom**: "Context budget exceeded" errors during tool loading

**Solution**:
1. Load tools sequentially, not all at once
2. Use `/clear` between major phases
3. Request specific tools only

### MCP Server Connection Issues

**Symptom**: "MCP server not responding" or "Connection timeout"

**Solution**:
1. Restart Claude Code completely
2. Check server logs: `tail -f ~/.claude/mcp-logs/*.log`
3. Verify credentials in `.env.mcp`
4. Check network connectivity

---

## Rollback Instructions

### When to Rollback

Consider rolling back if:
- Tool Search not available in your Claude Code version
- Critical tools consistently failing to load
- Performance worse than static profiles
- Migration issues cannot be resolved

### Rollback Steps

```bash
# Restore backed-up configuration
cp .mcp.json.backup .mcp.json
cp -r .mcp.backup/ .mcp/ 2>/dev/null || true

# Verify restoration
ls -lh .mcp/profiles/

# Restart Claude Code
```

---

## FAQ

### General Questions

**Q: Do I have to migrate now?**
A: No, but dynamic loading provides significant benefits. Static profiles will continue working but won't receive updates.

**Q: Will my existing missions break?**
A: No, agents automatically adapt. Existing workflows continue working with better efficiency.

**Q: Can I use both systems?**
A: No, choose one. Dynamic loading is recommended for all new projects.

### Technical Questions

**Q: What Claude Code version do I need?**
A: Any version supporting Tool Search (check with `/mcp-status`).

**Q: Does this affect MCP server configuration?**
A: No, server definitions remain unchanged. Only loading mechanism changes.

**Q: Can I add custom MCPs?**
A: Yes, add to `.mcp.json` under mcpServers. Tools auto-discovered via Tool Search.

### Performance Questions

**Q: Is dynamic loading slower?**
A: Initial discovery adds ~200ms, but saves minutes in context processing.

**Q: How many tools can I load?**
A: Recommended limit: 20 tools per session to stay under 10K context.

---

## Summary

### Key Takeaways

- **93.5% Context Reduction**: From 51K to 3.3K tokens at startup
- **Zero Maintenance**: Single configuration file replaces 11 profiles
- **Automatic Discovery**: Agents find tools as needed
- **Better Scalability**: Add MCPs without updating profiles
- **Faster Development**: Agents start instantly, load tools on-demand

### Migration Checklist

- [ ] Backup existing `.mcp.json` configuration
- [ ] Copy `dynamic-mcp.json` to project root
- [ ] Verify environment variables in `.env.mcp`
- [ ] Remove old `.mcp/profiles/` directory
- [ ] Restart Claude Code completely
- [ ] Run `/mcp-status` to verify Tool Search
- [ ] Test with sample mission
- [ ] Document any issues in `progress.md`

### Support

- **Schema**: `/project/schemas/dynamic-mcp.schema.yaml`
- **Configuration**: `/project/mcp/dynamic-mcp.json`
- **Issues**: Create GitHub issue with reproduction steps
- **Rollback**: Follow Rollback Instructions if needed

---

**Version**: 1.0
**Last Updated**: January 2026
**Sprint**: 11 - Dynamic MCP Architecture
