# Agent-11 MCP Usage Analysis

## Current MCP Architecture

### Profile-Based Configuration

Agent-11 uses a **profile-based MCP system** with different configurations for different workflows:

| Profile | MCP Servers | Use Case |
|---------|-------------|----------|
| **core** | context7, github, filesystem | Basic development |
| **database-production** | core + supabase-production (read-only) | Production database access |
| **database-staging** | core + supabase-staging | Staging database work |
| **deployment** | core + netlify, railway | Deployment operations |
| **payments** | core + stripe | Payment integration |
| **testing** | core + playwright | Testing automation |
| **fullstack** | (symlink to another profile) | Full-stack development |

### Core MCPs (Always Loaded)

These 3 MCPs are included in every profile:

1. **context7** - Documentation and code analysis
2. **github** - Repository management
3. **filesystem** - File operations

### Conditional MCPs (Profile-Specific)

Additional MCPs loaded based on workflow:

- **supabase** (production/staging) - Database operations
- **netlify** - Frontend deployment
- **railway** - Backend deployment
- **stripe** - Payment processing
- **playwright** - Browser automation

---

## Current Approach: Strengths

### ✅ Profile Switching
- Users can switch between profiles with `/mcp-switch`
- Prevents loading unnecessary MCPs for specific tasks
- Clear separation of concerns (testing vs deployment vs database)

### ✅ MCP-First Mindset
- Documentation emphasizes checking for MCPs before manual implementation
- Agent-specific MCP usage guidelines
- Discovery protocol with `grep "mcp__"`

### ✅ Organized by Workflow
- Profiles map to common development workflows
- Reduces cognitive overhead for users
- Clear naming conventions

---

## Current Approach: Pain Points

### ❌ All-or-Nothing Loading

**Problem:** When a profile is active, ALL MCPs in that profile are loaded into context.

**Example:** The `deployment` profile loads:
- context7
- github
- filesystem
- netlify
- railway

Even if the current task only needs `netlify`, all 5 servers and their tools are loaded into context.

**Impact:**
- Wasted context tokens on unused tools
- Lower tool selection accuracy (more tools = more confusion)
- Slower performance (more tools to evaluate)

### ❌ No Dynamic Tool Discovery

**Problem:** Agents must know which profile to use before starting work.

**Example:** If an agent needs both `supabase` and `netlify`:
- `database-staging` profile has supabase but not netlify
- `deployment` profile has netlify but not supabase
- No single profile has both

**Current Workaround:** Switch profiles mid-mission or manually configure custom profile.

**Impact:**
- Friction in multi-domain tasks
- Context clearing when switching profiles
- Manual profile management overhead

### ❌ Context Consumption Unknown

**Problem:** No visibility into how many tokens MCPs consume.

**Estimate based on Anthropic data:**
- context7: ~10-15K tokens (documentation server)
- github: ~26K tokens (35 tools per Anthropic example)
- supabase: ~15-20K tokens (database operations)
- playwright: ~8-10K tokens (browser automation)
- netlify: ~5-8K tokens (deployment)
- railway: ~5-8K tokens (deployment)
- stripe: ~8-10K tokens (payment operations)
- filesystem: ~3-5K tokens (file operations)

**Total for `deployment` profile:** ~50-60K tokens  
**Total for `database-production` profile:** ~55-65K tokens  
**Total for `testing` profile:** ~45-55K tokens

**Impact:**
- 50-65K tokens consumed before any work begins
- Less room for actual conversation and code
- Hits context limits faster on complex missions

### ❌ No Tool-Level Granularity

**Problem:** Can't defer specific tools within an MCP server.

**Example:** GitHub MCP has 35 tools, but an agent might only need:
- `create_pull_request`
- `list_issues`

Currently, all 35 tools load into context.

**Impact:**
- Unnecessary context consumption
- Tool selection accuracy degrades with 30+ similar tools

### ❌ Static Configuration

**Problem:** MCP profiles are static JSON files that require manual editing.

**Example:** To add a new MCP to a profile:
1. Edit the JSON file
2. Restart Claude Code
3. Reload the profile

**Impact:**
- Can't dynamically add/remove MCPs during a mission
- No adaptive loading based on task requirements
- Friction in experimentation

---

## Comparison to Anthropic Best Practices

| Anthropic Recommendation | Agent-11 Current State | Gap |
|--------------------------|------------------------|-----|
| **Defer loading** most tools | All tools in profile loaded upfront | ❌ Major gap |
| **Keep 3-5 core tools** loaded | 3 core MCPs always loaded | ✅ Good |
| **Dynamic tool discovery** | Static profile switching | ❌ Major gap |
| **Tool-level granularity** | Server-level only | ❌ Major gap |
| **Context efficiency** | Unknown token consumption | ❌ Major gap |
| **85% context reduction** | No optimization | ❌ Major gap |

---

## Estimated Context Impact

### Current State (Without Tool Search)

**Typical mission with `deployment` profile:**
- MCP tool definitions: ~50-60K tokens
- System prompt + agent definitions: ~10-15K tokens
- Conversation history: ~20-30K tokens
- **Total before hitting 200K limit:** ~80-105K tokens used

**Context remaining for actual work:** ~95-120K tokens (47-60% of context)

### With Tool Search Tool (Projected)

**Same mission with deferred loading:**
- Tool Search Tool: ~500 tokens
- Core MCPs (3-5 most used tools): ~5K tokens
- Discovered tools (3-5 on-demand): ~3K tokens
- System prompt + agent definitions: ~10-15K tokens
- Conversation history: ~20-30K tokens
- **Total:** ~38-53K tokens used

**Context remaining for actual work:** ~147-162K tokens (73-81% of context)

**Improvement:** +26-42K tokens available (+27-35% more context)

---

## Agent-Specific MCP Usage Patterns

### Coordinator
**Current:** Needs to know about all MCPs for delegation  
**Pain Point:** Must load all MCPs to delegate effectively  
**Opportunity:** Use Tool Search to discover MCPs on-demand

### Developer
**Current:** Uses context7, github, supabase frequently  
**Pain Point:** Loads deployment MCPs even when not deploying  
**Opportunity:** Keep core 3 loaded, defer deployment tools

### Architect
**Current:** Uses context7, firecrawl for research  
**Pain Point:** Loads database/deployment MCPs unnecessarily  
**Opportunity:** Research-focused profile with deferred operational tools

### Tester
**Current:** Uses playwright, context7  
**Pain Point:** Loads database/deployment MCPs unnecessarily  
**Opportunity:** Testing profile with only playwright + core

### Deployer
**Current:** Uses netlify, railway  
**Pain Point:** Loads testing/database MCPs unnecessarily  
**Opportunity:** Deployment profile with deferred testing tools

---

## Key Insights

1. **Profile system is good foundation** - Clear workflow separation
2. **All-or-nothing loading is wasteful** - Need tool-level granularity
3. **50-65K tokens consumed by MCPs** - Significant context pressure
4. **No dynamic discovery** - Static profiles limit flexibility
5. **Tool Search Tool is perfect fit** - Solves all major pain points

---

## Opportunities for Improvement

### High Impact
1. **Implement Tool Search Tool** - 85% context reduction, 88% accuracy improvement
2. **Defer non-core tools** - Keep 3-5 most-used tools, defer rest
3. **Tool-level granularity** - Defer specific tools within MCP servers

### Medium Impact
4. **Dynamic MCP discovery** - Let agents discover MCPs on-demand
5. **Context monitoring** - Track MCP token consumption
6. **Adaptive profiles** - Adjust loaded tools based on mission type

### Low Impact (Future)
7. **Custom tool search** - Implement semantic search with embeddings
8. **MCP usage analytics** - Track which tools are actually used
9. **Automatic profile optimization** - Learn optimal tool sets over time

---

## Recommended Strategy

### Phase 1: Foundation (Week 1-2)
- Implement Tool Search Tool with regex variant
- Defer all non-core tools in existing profiles
- Keep context7, github, filesystem as always-loaded
- Measure context savings and accuracy improvements

### Phase 2: Optimization (Week 3-4)
- Identify 3-5 most-used tools per agent
- Create agent-specific defer strategies
- Implement tool-level granularity for large MCP servers (github, supabase)
- A/B test against baseline

### Phase 3: Advanced (Month 2)
- Implement dynamic MCP discovery
- Add context monitoring and analytics
- Build adaptive profile system
- Enable programmatic tool calling for data-heavy operations

---

## Success Metrics

**Context Efficiency:**
- Target: 50-60K tokens → 8-10K tokens (85% reduction)
- Measure: Token consumption before first user message

**Tool Selection Accuracy:**
- Target: +8-25 percentage points improvement
- Measure: Correct tool selection rate on standardized tasks

**Mission Performance:**
- Target: -20-30% iterations to completion
- Measure: Average iterations per mission type

**User Experience:**
- Target: Eliminate manual profile switching
- Measure: Number of profile switches per mission
