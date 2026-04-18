# Sprint 4f: Dynamic MCP Tool Search

**Part of**: Agent-11 v6.0 Evolution (Sprint 4 umbrella)
**Predecessor**: Sprint 4e — Context Consolidation
**Successor**: Sprint 4g — Skills + Routines
**Status**: Outline only — detailed spec produced as the final task of Sprint 4e

**Reference**: `Ideation/Dynamic MCP Tooling for Agent-11_ Context Optimization and Agent Routing.md`

---

## Goal (provisional)

Replace static MCP profile switching with dynamic tool discovery using Claude Code's `tool_search_tool_regex` primitive and `defer_loading: true` on MCP server tools. Target: ~80% reduction in session-start tokens for MCP-heavy sessions (from ~51k to ~8.5k per the reference doc).

## Scope Outline (to be refined in detailed spec)

- Implement `.mcp.json` (or `dynamic-mcp.json`) with:
  - Single pre-loaded tool: `tool_search_tool_regex`
  - All MCP servers flagged `default_config: { defer_loading: true }`
  - Per-server "discovery" tools pre-loaded (e.g., `resolve-library-id`, `firecrawl_scrape`, `railway_list_services`)
- Update specialist prompts with the **Tool-Centric Workflow**:
  1. Identify need
  2. Tool search via regex
  3. Tool loaded automatically
  4. Execute
  5. Context clear
- Map discovery / execution split per MCP (context7, firecrawl, playwright, supabase, github, railway, stripe) — starter table in reference doc.
- Retire the profile-switching command stubs left from Sprint 4a.
- Update `library/CLAUDE.md` deployed instructions to describe the new dynamic protocol.

## Acceptance (provisional)

- `.mcp.json` uses `defer_loading` and tool search.
- Specialists can successfully search, load, and execute deferred tools.
- Harness shows ≥50% session-start token reduction on MCP-heavy tasks vs baseline.
- End-to-end test on all 7 target MCP servers passes.
- `MCP-GUIDE.md` / deployed docs reflect the new architecture.

## First Task of This Sprint

Produce detailed spec for this sprint.

## Final Task of This Sprint

Produce detailed spec for Sprint 4g.

## Open Questions

- Which tools go in pre-loaded "discovery" vs deferred "execution"? Start from the reference doc's table and refine per observed usage.
- Is there a regression risk for routines or hooks that depend on specific MCP tools being loaded?
- Does the tool search regex pattern need to be structured (e.g., require tags) or is free-form enough?
