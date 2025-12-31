# Tool Search Tool & MCP Integration Research

## Source
- **Anthropic Engineering Blog:** https://www.anthropic.com/engineering/advanced-tool-use
- **Claude Docs:** https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-search-tool
- **Date:** November 24, 2025

---

## The Problem: MCP Context Explosion

### Real-World Example from Anthropic
A typical 5-server MCP setup consumes massive context:

| MCP Server | Tools | Token Cost |
|------------|-------|------------|
| GitHub | 35 tools | ~26K tokens |
| Slack | 11 tools | ~21K tokens |
| Sentry | 5 tools | ~3K tokens |
| Grafana | 5 tools | ~3K tokens |
| Splunk | 2 tools | ~2K tokens |
| **Total** | **58 tools** | **~55K tokens** |

Add Jira (~17K tokens) and you're at **72K tokens before any work begins**.

**Anthropic's worst case:** 134K tokens consumed by tool definitions alone.

### The Two Core Problems

1. **Context Efficiency:** Tool definitions consume 10-20K tokens per 50 tools, leaving less room for actual work
2. **Tool Selection Accuracy:** Claude's ability to correctly select tools degrades significantly with more than 30-50 tools

---

## The Solution: Tool Search Tool

### How It Works

Instead of loading all tool definitions upfront, Claude discovers tools on-demand:

1. **Mark tools for deferred loading:** Add `defer_loading: true` to tool definitions
2. **Include a tool search tool:** Either regex-based or BM25-based
3. **Claude searches when needed:** Constructs search queries to find relevant tools
4. **API returns 3-5 tool references:** Most relevant tools for the task
5. **References auto-expand:** Full tool definitions loaded into context
6. **Claude invokes discovered tools:** Normal tool calling proceeds

### Two Variants

**Regex Variant (`tool_search_tool_regex_20251119`):**
- Claude constructs Python regex patterns
- Examples: `"weather"`, `"get_.*_data"`, `"database.*query|query.*database"`
- Maximum query length: 200 characters
- Best for: Predictable tool naming patterns

**BM25 Variant (`tool_search_tool_bm25_20251119`):**
- Claude uses natural language queries
- Example: "tools for weather information"
- Best for: Semantic search across diverse tool descriptions

### What Gets Searched

The tool search tool searches across:
- Tool names
- Tool descriptions
- Argument names
- Argument descriptions

---

## Performance Improvements

### Context Savings

| Approach | Context Consumption | Savings |
|----------|---------------------|---------|
| **Traditional** | ~77K tokens (50+ MCP tools) | Baseline |
| **Tool Search Tool** | ~8.7K tokens | **-88% tokens** |
| **Context Preserved** | 191,300 tokens vs 122,800 | **+95% available** |

**Breakdown:**
- Traditional: All tool definitions loaded upfront (~72K tokens)
- Tool Search: Only search tool loaded (~500 tokens) + discovered tools (~3K tokens)

### Accuracy Improvements

Internal MCP evaluations with large tool libraries:

| Model | Without Tool Search | With Tool Search | Improvement |
|-------|---------------------|------------------|-------------|
| **Opus 4** | 49% | 74% | **+25 points** |
| **Opus 4.5** | 79.5% | 88.1% | **+8.6 points** |

---

## MCP-Specific Integration

### Defer Loading Entire MCP Servers

You can defer loading entire MCP servers while keeping specific high-use tools loaded:

```json
{
  "type": "mcp_toolset",
  "mcp_server_name": "google-drive",
  "default_config": {
    "defer_loading": true  // Defer the entire server
  },
  "configs": {
    "search_files": {
      "defer_loading": false  // Keep most-used tool loaded
    }
  }
}
```

### Strategy for Multiple MCP Servers

**Recommended approach:**
1. Identify 3-5 most frequently used tools across all servers
2. Keep those tools with `defer_loading: false`
3. Defer all other tools with `defer_loading: true`
4. Let Claude discover additional tools on-demand

**Example configuration:**
```json
{
  "tools": [
    // Always include the tool search tool
    {
      "type": "tool_search_tool_regex_20251119",
      "name": "tool_search_tool_regex"
    },
    
    // High-frequency tools (always loaded)
    {
      "type": "mcp_toolset",
      "mcp_server_name": "github",
      "configs": {
        "create_pull_request": {"defer_loading": false},
        "list_issues": {"defer_loading": false}
      },
      "default_config": {"defer_loading": true}
    },
    
    // All other tools deferred
    {
      "type": "mcp_toolset",
      "mcp_server_name": "slack",
      "default_config": {"defer_loading": true}
    },
    {
      "type": "mcp_toolset",
      "mcp_server_name": "jira",
      "default_config": {"defer_loading": true}
    }
  ]
}
```

---

## When to Use Tool Search Tool

### Use It When:
✅ Tool definitions consuming **>10K tokens**  
✅ Experiencing **tool selection accuracy issues**  
✅ Building **MCP-powered systems** with multiple servers  
✅ **10+ tools** available  
✅ Tools are **not all used** in every session  

### Less Beneficial When:
❌ Small tool library (**<10 tools**)  
❌ All tools used **frequently in every session**  
❌ Tool definitions are **compact**  
❌ Tools have **very similar names/descriptions** (search may not differentiate well)  

---

## Implementation Details

### Beta Header Required

| Provider | Beta Header | Supported Models |
|----------|-------------|------------------|
| Claude API / Microsoft Foundry | `advanced-tool-use-2025-11-20` | Opus 4.5, Sonnet 4.5 |
| Google Cloud Vertex AI | `tool-search-tool-2025-10-19` | Opus 4.5, Sonnet 4.5 |
| Amazon Bedrock | `tool-search-tool-2025-10-19` | Opus 4.5 only |

### Response Format

When Claude uses the tool search tool, responses include new block types:

```json
{
  "role": "assistant",
  "content": [
    {
      "type": "server_tool_use",
      "id": "srvtoolu_01ABC123",
      "name": "tool_search_tool_regex",
      "input": {"query": "weather"}
    },
    {
      "type": "tool_result",
      "tool_use_id": "srvtoolu_01ABC123",
      "content": [
        {"type": "tool_reference", "tool_name": "get_weather"}
      ]
    },
    {
      "type": "tool_use",
      "id": "toolu_01XYZ789",
      "name": "get_weather",
      "input": {"location": "San Francisco"}
    }
  ]
}
```

**Key points:**
- `server_tool_use`: Claude invoking the tool search tool
- `tool_result` with `tool_reference`: Search results
- `tool_reference` blocks are **auto-expanded** into full tool definitions
- Normal `tool_use` follows for discovered tools

### Prompt Caching Compatibility

✅ **Tool Search Tool doesn't break prompt caching**

Why? Deferred tools are excluded from the initial prompt entirely. They're only added to context after Claude searches for them, so your system prompt and core tool definitions remain cacheable.

---

## Advanced: Custom Tool Search Implementation

You can implement your own client-side tool search using embeddings or other strategies. Return `tool_reference` blocks from your custom search implementation:

```json
{
  "type": "tool_result",
  "tool_use_id": "toolu_custom_search",
  "content": [
    {"type": "tool_reference", "tool_name": "get_weather"},
    {"type": "tool_reference", "tool_name": "get_forecast"}
  ]
}
```

This allows for:
- Semantic search using embeddings
- Custom ranking algorithms
- Integration with external tool catalogs
- Dynamic tool generation

---

## Complementary Features

### Programmatic Tool Calling

**Problem:** Each tool call requires a full inference pass, and intermediate results pile up in context.

**Solution:** Claude writes code that calls tools in a code execution environment. Only final results return to context.

**Example:** Processing 2,000 expense line items
- Traditional: All 2,000 items enter context, Claude manually processes
- Programmatic: Claude writes Python script, processes in sandbox, returns summary only

**Benefit:** Reduces context pollution, faster execution, better for loops/conditionals

### Tool Use Examples

**Problem:** JSON schemas define what's structurally valid, but can't express usage patterns.

**Solution:** Provide example tool calls with context to teach Claude correct usage.

**Example:**
```json
{
  "name": "send_notification",
  "examples": [
    {
      "context": "User requested urgent notification to team",
      "input": {
        "channel": "team-alerts",
        "priority": "high",
        "message": "Deploy failed, immediate attention needed"
      }
    }
  ]
}
```

**Benefit:** Shows when to use optional parameters, which combinations make sense, API conventions

---

## Real-World Use Cases

### Claude for Excel (Anthropic Example)
Uses Programmatic Tool Calling to read and modify spreadsheets with thousands of rows without overloading context.

### IDE Assistant (Hypothetical)
Integrates git operations, file manipulation, package managers, testing frameworks, and deployment pipelines. Tool Search Tool discovers only relevant tools for current task.

### Operations Coordinator (Hypothetical)
Connects Slack, GitHub, Google Drive, Jira, company databases, and dozens of MCP servers simultaneously. Discovers tools on-demand instead of loading 100+ tool definitions upfront.

---

## Key Takeaways for Agent-11

1. **MCP context explosion is real:** 5 servers = 55K tokens before any work
2. **Tool Search Tool solves it:** 88% context reduction, 88% tool selection accuracy
3. **MCP-native support:** Can defer entire servers or specific tools
4. **Prompt caching compatible:** Deferred tools don't break caching
5. **Two variants:** Regex for predictable patterns, BM25 for semantic search
6. **Keep 3-5 core tools loaded:** Balance between context and latency
7. **Opus 4.5 recommended:** Best performance with Tool Search Tool (88.1% accuracy)

---

## Implementation Complexity

**Easy:** Add tool search tool and mark tools as deferred (2-4 hours)  
**Medium:** Optimize which tools to keep loaded vs defer (4-8 hours)  
**Hard:** Implement custom tool search with embeddings (1-2 weeks)  

**Recommended starting point:** Use regex variant with default defer strategy, measure results, optimize from there.
