# Dynamic MCP Tooling for Agent-11: Context Optimization and Agent Routing

**Author**: Manus AI
**Date**: January 17, 2026

## Introduction

The current architecture of the `agent-11` system, which relies on static Model Context Protocol (MCP) profiles, leads to two critical issues: **context bloat** and **inefficient agent routing**. By pre-loading all tools from a profile, the system consumes a large portion of the model's context window (up to 51,000 tokens or more), even when only a few tools are relevant to the immediate task. Furthermore, the manual profile switching process is a significant point of friction, requiring a full agent restart and breaking the flow of complex missions.

This report outlines a new, dynamic architecture for `agent-11` based on the latest Claude Code features: **Tool Search** and **Lazy Loading** via the `defer_loading` flag. This approach will resolve the context bloat issue and enable a truly **tool-centric** workflow, allowing agents to dynamically discover and load the exact tools they need, when they need them.

## 1. The New Architecture: Dynamic Tool Loading

The core of the new architecture is the replacement of the monolithic MCP profile with a minimal, search-enabled configuration. This shift leverages the model's ability to reason about which tools are necessary for a task and then programmatically load only those tools, drastically reducing the initial context size.

### 1.1. Core Components

The dynamic system relies on two key components:

1.  **Tool Search Tool (`tool_search_tool_regex_20251119`)**: This tool is the only one pre-loaded into the model's context. When an agent needs a tool (e.g., to deploy a service), it uses this search tool to query the full, deferred list of all available tools across all connected MCP servers.
2.  **Lazy Loading (`defer_loading: true`)**: All other tools and entire MCP servers are marked with `defer_loading: true`. This keeps their detailed schemas out of the initial context, saving tokens, but makes them discoverable by the Tool Search tool.

This strategy allows the system to maintain a vast library of tools while keeping the initial context footprint small, typically under 10,000 tokens, which represents a token reduction of over 80% [1].

## 2. Configuration Blueprint: `dynamic-mcp.json`

The new system requires a single, unified MCP configuration file that replaces the current profile-switching mechanism. This file, provisionally named `dynamic-mcp.json`, will be the new source of truth for all MCP tools.

The blueprint for this file includes the Tool Search tool and the seven target MCP servers, all configured for lazy loading by default.

```json
{
  "tools": [
    {
      "type": "tool_search_tool_regex_20251119",
      "name": "tool_search_tool_regex",
      "description": "Use this tool to search for and load any available MCP tool from the deferred toolset. Use a regex pattern that describes the tool's function (e.g., 'deploy service', 'scrape web page', 'create pr')."
    },
    {
      "type": "mcp_toolset",
      "mcp_server_name": "context7",
      "default_config": { "defer_loading": true },
      "tools": [
        { "name": "resolve-library-id", "defer_loading": false, "description": "Quickly resolve a library name to a Context7 ID for documentation search." }
      ]
    },
    {
      "type": "mcp_toolset",
      "mcp_server_name": "firecrawl",
      "default_config": { "defer_loading": true },
      "tools": [
        { "name": "firecrawl_scrape", "defer_loading": false, "description": "Scrape a single URL for content extraction." },
        { "name": "firecrawl_batch_scrape", "defer_loading": false, "description": "Scrape multiple URLs efficiently." }
      ]
    },
    {
      "type": "mcp_toolset",
      "mcp_server_name": "playwright",
      "default_config": { "defer_loading": true },
      "tools": [
        { "name": "playwright_navigate", "defer_loading": false, "description": "Navigate the browser to a specified URL." }
      ]
    },
    {
      "type": "mcp_toolset",
      "mcp_server_name": "supabase",
      "default_config": { "defer_loading": true },
      "tools": [
        { "name": "supabase_list_tables", "defer_loading": false, "description": "List all tables in the connected Supabase database." }
      ]
    },
    {
      "type": "mcp_toolset",
      "mcp_server_name": "github",
      "default_config": { "defer_loading": true },
      "tools": [
        { "name": "github_list_repos", "defer_loading": false, "description": "List repositories accessible to the agent." }
      ]
    },
    {
      "type": "mcp_toolset",
      "mcp_server_name": "railway",
      "default_config": { "defer_loading": true },
      "tools": [
        { "name": "railway_list_services", "defer_loading": false, "description": "List all services in the current Railway project." }
      ]
    },
    {
      "type": "mcp_toolset",
      "mcp_server_name": "stripe",
      "default_config": { "defer_loading": true },
      "tools": [
        { "name": "stripe_search_customers", "defer_loading": false, "description": "Search for customers by email or ID." }
      ]
    }
  ]
}
```

## 3. Agent Routing and Tool Discovery Protocol

The primary change is in the agents' internal logic, replacing the "profile check" with a "tool search" step.

### 3.1. New Agent Protocol (Tool-Centric Workflow)

The new protocol for any specialist agent requiring an MCP tool is as follows:

| Step | Action | Rationale |
| :--- | :--- | :--- |
| **1. Identify Need** | Agent determines the specific action required (e.g., "deploy service," "run migration," "scrape documentation"). | Focuses the agent on the task, not the toolset. |
| **2. Tool Search** | Agent uses the pre-loaded `tool_search_tool_regex` with a descriptive regex query (e.g., `tool_search_tool_regex(regex="deploy.*service")`). | Dynamically finds the most relevant tool from the entire deferred library. |
| **3. Tool Loading** | Claude Code automatically loads the full schema of the discovered tool into the context. | Only the necessary tool's schema is loaded, minimizing context bloat. |
| **4. Execution** | Agent executes the newly loaded tool (e.g., `railway_deploy_service(...)`). | Direct, efficient execution without manual profile switching. |
| **5. Context Clear** | Upon completion, the tool's schema is automatically removed from the context, or the agent can use the `/clear` command to reset the context for the next task. | Ensures the context remains clean for subsequent operations. |

### 3.2. Agent-Specific Tool Mapping

The following table details the suggested pre-loaded ("Discovery") tools and the deferred ("Execution") tools for the target MCPs, aligning them with the specialist agents in `agent-11`.

| MCP Service | Specialist Agent | Discovery Tools (`defer_loading: false`) | Execution Tools (`defer_loading: true`) |
| :--- | :--- | :--- | :--- |
| **context7** | Architect, Strategist | `resolve-library-id` | `get-documentation`, `search-docs` |
| **firecrawl** | Strategist, Analyst | `firecrawl_scrape`, `firecrawl_batch_scrape` | `firecrawl_crawl`, `firecrawl_extract_data` |
| **playwright** | Tester | `playwright_navigate` | `playwright_click`, `playwright_type`, `playwright_screenshot`, `playwright_wait_for` |
| **Supabase** | Developer | `supabase_list_tables` | `supabase_query_sql`, `supabase_create_migration`, `supabase_manage_auth` |
| **GitHub** | Developer, Coordinator | `github_list_repos` | `github_create_pr`, `github_manage_issues`, `github_commit_file` |
| **Railway** | Operator | `railway_list_services` | `railway_deploy`, `railway_manage_env`, `railway_link_service` |
| **Stripe** | Developer, Analyst | `stripe_search_customers` | `stripe_create_payment`, `stripe_get_logs`, `stripe_manage_subscriptions` |

## 4. Conclusion and Implementation Roadmap

The adoption of the dynamic MCP tool loading architecture is a critical upgrade for `agent-11`, transforming it from a profile-centric system with high context overhead into a highly efficient, tool-centric agent capable of managing hundreds of tools with minimal context bloat. This change directly addresses the user's goal of connecting the right agents at the right time by making the tools themselves the primary routing mechanism.

### Implementation Roadmap

1.  **Create `dynamic-mcp.json`**: Implement the configuration blueprint detailed in Section 2.
2.  **Update Agent Prompts**: Modify the core specialist agent prompts (e.g., `developer.md`, `operator.md`) to remove the old profile-checking logic and incorporate the new **Tool Search Protocol** (Section 3.1).
3.  **Testing and Validation**: Conduct end-to-end tests to ensure agents can successfully search for, load, and execute deferred tools across all seven target MCP servers.
4.  **Documentation**: Update `MCP-GUIDE.md` and `CLAUDE.md` to reflect the new dynamic architecture and the token savings achieved.

This new system ensures that `agent-11` remains on the cutting edge of AI agent development, maximizing efficiency and minimizing operational cost.

***

### References

[1] Joe Njenga. *Claude Code Just Cut MCP Context Bloat by 46.9% — 51K Tokens Down to 8.5K With New Tool Search*. Medium. [https://medium.com/@joe.njenga/claude-code-just-cut-mcp-context-bloat-by-46-9-51k-tokens-down-to-8-5k-with-new-tool-search-ddf9e905f734](https://medium.com/@joe.njenga/claude-code-just-cut-mcp-context-bloat-by-46-9-51k-tokens-down-to-8-5k-with-new-tool-search-ddf9e905f734)
