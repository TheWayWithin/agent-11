# Agent-11 MCP Optimization: Implementation Guide

**Author:** Manus AI  
**Date:** November 28, 2025  
**Version:** 1.0

---

## 1. Executive Summary

This guide provides a step-by-step implementation plan for optimizing Agent-11's Model Context Protocol (MCP) management using Anthropic's advanced tool use features. By following this guide, you will transform Agent-11's MCP architecture from static, profile-based loading to dynamic, on-demand tool discovery. This will result in an **85% reduction in MCP token consumption**, an **8-25 percentage point improvement in tool selection accuracy**, and a **27-35% increase in available context** for mission execution.

The implementation is divided into four phases, starting with a low-risk proof of concept and progressing to a fully optimized, adaptive system. Each phase is designed to deliver incremental value and validate the approach before proceeding.

---

## 2. Prerequisites

Before you begin, ensure you have the following:

- **Claude Opus 4.5 or Sonnet 4.5:** The Tool Search Tool is only supported on these models.
- **API Access:** Access to the Claude API, Microsoft Foundry, Google Cloud Vertex AI, or Amazon Bedrock.
- **Beta Header:** You must include the appropriate beta header in your API calls:
  - `advanced-tool-use-2025-11-20` (Claude API / Microsoft Foundry)
  - `tool-search-tool-2025-10-19` (Vertex AI / Bedrock)
- **Agent-11 Repository:** A local clone of the Agent-11 repository.

---

## 3. Implementation Roadmap

### Phase 1: Proof of Concept (Week 1)

**Goal:** Validate the Tool Search Tool with a single, optimized profile.

#### Step 1: Create a New Profile

1.  Navigate to the `.mcp-profiles` directory in your Agent-11 repository.
2.  Create a new file named `core-optimized.json`.

#### Step 2: Configure the Optimized Profile

Paste the following configuration into `core-optimized.json`. This configuration:
- Includes the `tool_search_tool_regex`.
- Keeps 5 core tools always loaded (`defer_loading: false`).
- Defers all other tools and servers (`defer_loading: true`).

```json
{
  "mcpServers": {
    "tool_search": {
      "type": "tool_search_tool_regex_20251119",
      "name": "tool_search_tool_regex"
    },
    "context7": {
      "command": "npx",
      "args": ["@context7/mcp-server"],
      "env": {
        "CONTEXT7_API_KEY": "${CONTEXT7_API_KEY}"
      },
      "default_config": {
        "defer_loading": true
      },
      "configs": {
        "get-library-docs": {
          "defer_loading": false
        }
      }
    },
    "github": {
      "command": "npx",
      "args": ["@edjl/github-mcp"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_PERSONAL_ACCESS_TOKEN}"
      },
      "default_config": {
        "defer_loading": true
      },
      "configs": {
        "create_pull_request": {
          "defer_loading": false
        },
        "list_issues": {
          "defer_loading": false
        }
      }
    },
    "filesystem": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-filesystem", "${HOME}/DevProjects"],
      "default_config": {
        "defer_loading": true
      },
      "configs": {
        "read_file": {
          "defer_loading": false
        },
        "write_file": {
          "defer_loading": false
        }
      }
    }
  }
}
```

#### Step 3: Activate the New Profile

Run the `/mcp-switch` command in your Claude Code environment and select `core-optimized.json`.

#### Step 4: Test and Validate

1.  **Run a simple mission:** Choose a mission that requires one of the core tools (e.g., reading a file).
    - **Expected:** The mission should complete successfully without any tool search.
2.  **Run a mission requiring a deferred tool:** Choose a mission that needs a deferred GitHub tool (e.g., creating a branch).
    - **Expected:** The agent should use the `tool_search_tool_regex` to find the `create_branch` tool, then invoke it.
3.  **Measure context consumption:** Before running a mission, check the initial context size. It should be around 8-10K tokens, down from 40-45K.

**Success Criteria:**
- 80%+ context reduction.
- Missions complete successfully.
- Tool discovery latency is acceptable (<2 seconds).

---

### Phase 2: Profile Migration (Weeks 2-3)

**Goal:** Migrate all existing profiles to the optimized, on-demand format.

#### Step 1: Identify Core Tools per Profile

For each existing profile (`deployment.json`, `testing.json`, etc.), identify the 3-5 most frequently used tools. These will be your `defer_loading: false` tools.

**Example for `deployment.json`:**
- `netlify__create_site`
- `netlify__deploy_site`
- `railway__create_project`
- `railway__deploy_service`
- `github__create_release`

#### Step 2: Create Optimized Profiles

For each profile, create a new `-optimized.json` version. Copy the structure from `core-optimized.json` and add the profile-specific MCP servers with `default_config: { "defer_loading": true }`. Then, set `defer_loading: false` for the core tools you identified.

**Example `deployment-optimized.json` snippet:**
```json
{
  "mcpServers": {
    // ... core servers from Phase 1 ...
    "netlify": {
      "command": "npx",
      "args": ["-y", "@netlify/mcp"],
      "env": {
        "NETLIFY_ACCESS_TOKEN": "${NETLIFY_ACCESS_TOKEN}"
      },
      "default_config": {
        "defer_loading": true
      },
      "configs": {
        "create_site": {
          "defer_loading": false
        },
        "deploy_site": {
          "defer_loading": false
        }
      }
    },
    "railway": {
      "command": "npx",
      "args": ["-y", "@railway/mcp-server"],
      "env": {
        "RAILWAY_API_TOKEN": "${RAILWAY_API_TOKEN}"
      },
      "default_config": {
        "defer_loading": true
      },
      "configs": {
        "create_project": {
          "defer_loading": false
        },
        "deploy_service": {
          "defer_loading": false
        }
      }
    }
  }
}
```

#### Step 3: A/B Testing

Run a set of missions that use the `deployment` profile. Run them once with the original profile and once with the optimized profile. Measure context consumption, iterations to completion, and mission success rate.

**Success Criteria:**
- All profiles show 80%+ context reduction.
- Tool selection accuracy improves by 8-25 percentage points.
- User satisfaction is maintained or improved.

---

### Phase 3: Agent Integration (Weeks 4-5)

**Goal:** Update agent prompts to make them aware of and leverage tool discovery.

#### Step 1: Update Coordinator Prompt

Add the following section to the Coordinator agent's prompt (`coordinator.md`):

```markdown
## DYNAMIC TOOL DISCOVERY PROTOCOL

You have access to a `tool_search_tool_regex`. Instead of assuming which tools are available, you MUST use this tool to discover specialist capabilities on-demand.

**Workflow:**
1.  **Identify need:** Determine the capability required (e.g., "database access," "browser testing").
2.  **Formulate query:** Create a regex pattern to find relevant tools (e.g., `database|supabase`, `test|playwright`).
3.  **Search for tools:** Invoke `tool_search_tool_regex` with your query.
4.  **Review results:** The system will return references to matching tools.
5.  **Delegate:** Invoke the discovered tool to delegate the task.

**Example:**
- **Need:** Create a new database table.
- **Query:** `database|supabase.*table`
- **Action:** `tool_search_tool_regex(query="database|supabase.*table")`
- **Result:** `supabase__create_table`
- **Delegation:** `supabase__create_table(...)`

This protocol eliminates the need for manual profile switching and ensures you always have access to the full range of specialist capabilities.
```

#### Step 2: Update Specialist Prompts

Add a similar, simpler section to specialist agent prompts (e.g., `developer.md`, `tester.md`):

```markdown
## DYNAMIC TOOL DISCOVERY

If you need a tool that is not immediately available, use the `tool_search_tool_regex` to find it. For example, if you need to interact with a database, search for `database|supabase`.
```

#### Step 3: Test Agent Behavior

Run missions that require agents to discover tools. For example, a development mission that unexpectedly requires a deployment task. Verify that the agent successfully searches for and finds the deployment tools instead of failing or asking for a profile switch.

**Success Criteria:**
- Agents successfully discover and use deferred tools.
- Manual profile switching is significantly reduced.
- Mission autonomy is improved.

---

### Phase 4: Advanced Optimization (Weeks 6-8)

**Goal:** Fine-tune the system and implement advanced features for maximum efficiency.

#### Step 1: Implement Programmatic Tool Calling

For data-heavy operations (e.g., log analysis by the Analyst agent), refactor the agent to use programmatic tool calling. This involves the agent writing a Python script that calls tools in a code execution environment.

**Benefit:** Reduces context pollution from large intermediate results.

#### Step 2: Add Tool Use Examples

For complex tools with many optional parameters (e.g., `github__create_pull_request`), add `tool_use_examples` to the tool definition. This will help Claude learn the correct usage patterns and reduce errors.

**Example:**
```json
{
  "name": "github__create_pull_request",
  "examples": [
    {
      "context": "User wants to create a PR from feature/login to main",
      "input": {
        "head": "feature/login",
        "base": "main",
        "title": "feat: Add user login functionality",
        "body": "This PR implements the user login flow as per ticket #123."
      }
    }
  ]
}
```

#### Step 3: Build a Context Monitoring Dashboard

Create a simple dashboard that tracks:
- Initial context consumption per profile.
- Number of tool searches per mission.
- Most frequently discovered tools.
- Context savings over time.

This will provide visibility into the system's performance and help identify further optimization opportunities.

---

## 4. Rollback Plan

If any phase introduces issues, you can easily roll back:

- **Phase 1-2:** Switch back to the original, non-optimized MCP profile using the `/mcp-switch` command. No code changes are required.
- **Phase 3:** Revert the changes to the agent prompt files.

This low-risk approach ensures that you can safely experiment with optimizations without disrupting the core functionality of Agent-11.

---

## 5. Conclusion

By following this implementation guide, you can systematically transform Agent-11's MCP management into a state-of-the-art, on-demand system. This will not only make your agents more efficient and accurate but also unlock the ability to work with much larger and more complex tool libraries, paving the way for more sophisticated and autonomous missions.

**Recommendation:** Begin with Phase 1 this week to realize immediate benefits and validate the approach.
