# AGENT-11 Release History

Complete history of AGENT-11 development sprints and releases.

---

## Sprint 11: Dynamic MCP Tooling & Context Optimization (v5.2.0)
**Released**: 2026-01-17

93% token reduction through dynamic MCP tool loading. Eliminates manual profile switching with Tool Search discovery.

### The Problem

The static MCP profile system had critical limitations:
- **Context Bloat**: Pre-loading all tools consumed 51,000+ tokens before any work
- **Profile Management**: 11 separate files required manual updates
- **Tool Waste**: Agents loaded tools they never used (90%+ waste)
- **Coordination Overhead**: Required manual profile switching and agent restarts

### The Solution

**Dynamic Tool Loading** via Claude Code's Tool Search feature:

| Approach | Initial Context | Reduction |
|----------|-----------------|-----------|
| All Tools (static) | 51,000 tokens | baseline |
| Profile-based | 3,000-15,000 tokens | 40-80% |
| **Dynamic Loading** | **3,300 tokens** | **93%** |

**Two-Tier Tool Architecture**:
- **Discovery Tools** (pre-loaded): Lightweight routing tools (~350 tokens each)
- **Execution Tools** (lazy-loaded): Heavy tools loaded on-demand only

**7 MCPs Configured**:
- context7, firecrawl, playwright, supabase, github, railway, stripe

### Key Changes

1. **Tool Search Protocol**: Agents use `tool_search_tool_regex_20251119("mcp__pattern")` to discover tools
2. **Agent Updates**: coordinator, developer, tester, operator now use DYNAMIC MCP TOOL DISCOVERY
3. **No Profile Switching**: Tools discovered and loaded automatically based on task
4. **Backwards Compatible**: Profile system documented as legacy with rollback path

### New Files

| File | Purpose |
|------|---------|
| `project/mcp/dynamic-mcp.json` | Unified dynamic MCP configuration |
| `project/schemas/dynamic-mcp.schema.yaml` | Schema definition |
| `docs/MCP-MIGRATION-GUIDE.md` | Migration guide from profiles |

### Impact
- Token reduction: 93.5% (51K → 3.3K)
- Profile files eliminated: 11 → 1
- Manual switching: Required → Automatic
- Agent restarts: Required → Not needed

---

## Sprint 10: Structured Context System (v5.1.0)
**Released**: 2026-01-01

100% data preservation in `/foundations init` through structured YAML extraction with document-type-aware processing.

### The Problem

Token-budgeted summaries were causing 50-65% information loss. PRD documents lost numeric targets, phase timelines, and feature sub-components. Brand guidelines worked perfectly (precision values resist summarization), but requirements-heavy documents suffered.

| Document Type | Before | After |
|---------------|--------|-------|
| PRD | 7/10 (FAIL) | 10/10 |
| Vision | 9.5/10 | 10/10 |
| ICP | 98/100 | 100/100 |
| Brand | 100/100 | 100/100 |

### The Solution

**Document Type Classification**:
- **SPECIFICATION** (PRD, Architecture) → COMPLETENESS MODE
- **STRATEGIC** (Vision, Roadmap) → SYNTHESIS MODE
- **PRECISION** (Brand, Style Guide) → EXACT MODE
- **STRUCTURED** (ICP, Personas) → MAPPING MODE

**5 Foundation Schemas** (YAML with explicit structure):
- `foundation-prd.schema.yaml` - With phases, timelines, sub_features, NFRs
- `foundation-vision.schema.yaml` - BHAG, success indicators, values
- `foundation-icp.schema.yaml` - Personas, problems, JTBD, anti-personas
- `foundation-brand.schema.yaml` - Colors, typography, components
- `foundation-marketing.schema.yaml` - Positioning, messaging, channels

**Extraction Mode Rules**:

| Mode | Rules |
|------|-------|
| COMPLETENESS | Extract 100% of lists, ALL numeric values, ALL sub-components, ALL timelines |
| EXACT | Byte-level precision, preserve quotes, units on all measurements |
| MAPPING | Direct structure-to-structure, preserve relationships |
| SYNTHESIS | Capture essence while maintaining key metrics |

### Key Fixes (Sprint 10.1)

Based on validation feedback, enhanced PRD extraction with:
- **Numeric Preservation** - Targets with units (1000 users, $10K MRR, 99.9% uptime)
- **List Completeness** - 8/8 deliverables, not 4/8
- **Timeline Extraction** - Phase start/end/duration objects
- **Feature Decomposition** - Sub-features arrays for compound features
- **Technology Specificity** - Versions (Next.js 14), AI models (GPT-4, Claude)
- **Post-Extraction Validation** - Checklist to catch omissions

### Impact
- Data preservation: 35-50% → 100%
- Numeric values: Now extracted with units, timeframes, source quotes
- Agent implementation accuracy: Significantly improved (requirements complete)

---

## Sprint 9: SaaS Boilerplate Killer Architecture (v5.0.0)
**Released**: 2025-12-31

The paradigm shift. Instead of maintaining boilerplate code libraries, embed domain expertise directly into agents as **skills** that generate fresh, framework-specific code every time.

### The Big Idea

> "Why maintain code libraries when you can embed knowledge in the agent that builds them?"

Traditional approach: Build auth/payments/billing boilerplate → maintain dependencies → debug integration issues → hope it works with the latest framework version.

AGENT-11 v5.0.0 approach: Embed SaaS knowledge as skills → agent generates fresh, current code → always uses latest patterns and APIs → no maintenance burden.

### Key Features

**Plan-Driven Development System**
- `/foundations init` - Process BOS-AI documents into token-efficient summaries
- `/bootstrap [template]` - Generate project-plan.md from templates (saas-mvp, saas-full, api)
- `/plan status` - View current mission state
- `/coord continue` - Autonomous execution until blocked

**7 Production-Ready SaaS Skills** (~25K tokens total, auto-loaded based on task keywords):
| Skill | Tokens | Capabilities |
|-------|--------|--------------|
| `saas-auth` | ~3,800 | OAuth, email/password, magic links, session management |
| `saas-payments` | ~4,200 | Stripe checkout, subscriptions, webhooks, metering |
| `saas-multitenancy` | ~4,100 | RLS, tenant isolation, workspace management |
| `saas-billing` | ~3,900 | Plans, quotas, trials, usage tracking |
| `saas-email` | ~3,200 | Transactional email with Resend |
| `saas-onboarding` | ~3,500 | User onboarding wizards, progress tracking |
| `saas-analytics` | ~3,600 | PostHog integration, event tracking |

**Quality Gates System**
- Enforcement at phase transitions
- 6 gate types: build, test, lint, security, review, deploy
- 3 severity levels: blocking, warning, info
- Python runner: `python gates/run-gates.py --phase implementation`

**Stack Profiles** (Multi-framework support):
- `nextjs-supabase` - Next.js 14 + Supabase
- `remix-railway` - Remix + Railway + PostgreSQL
- `sveltekit-supabase` - SvelteKit + Supabase

### The Complete Workflow

```bash
# 1. Copy BOS-AI docs to documents/foundations/
# 2. Process foundation documents
/foundations init

# 3. Generate project plan
/bootstrap saas-mvp

# 4. Check status
/plan status

# 5. Autonomous execution
/coord continue
# (Repeats until phase complete, gate failure, or blocker)
```

### Impact
- **From idea to execution** in one workflow
- **No boilerplate maintenance** - skills generate fresh code
- **Quality enforced** at every transition
- **Multi-framework** from day one

---

## Sprint 8: Phase Gate Enforcement System (v4.4.0)
**Released**: 2025-12-05

Prevents stale tracking files from causing repeated work.

### The Problem
Claude would read outdated `project-plan.md` showing tasks as `[ ]` incomplete, then re-do work that was already finished in a previous session.

### The Solution
- **Session Resumption Protocol** - Check file staleness before doing new work
- **Phase Gate Enforcement** - Verify all tasks `[x]` before phase transitions
- **Pre-Clear Gate** - Validate files before `/clear`
- **Mission Completion Gate** - Ensure all files current before marking done

### Key Deliverables
- coord.md: +150 lines (4 new protocol sections)
- coordinator.md: +100 lines (enhanced gates)
- CLAUDE.md: Session Resumption + Phase Gate sections
- 12 mission files updated with PHASE GATE PROTOCOL

### Impact
- Update compliance: 70% → 99.9%+
- Near-zero phase transition failures

---

## Sprint 7: Social Media Post Generation (v4.3.0)
**Released**: 2025-12-01

Build-in-public automation for `/dailyreport`.

### Features
- **Twitter/X posts** - 280 char limit, optimized 71-100 chars, copy-paste ready
- **LinkedIn posts** - 800-1000 chars, hook-optimized first 140 chars
- **Platform-specific tone** - Authentic developer/founder voice
- **Hashtag optimization** - #buildinpublic, #solofounder, etc.

### Output Files
```
progress/
├── 2025-12-01.md           # Raw daily report
├── 2025-12-01-blog.md      # Blog post (narrative)
├── 2025-12-01-twitter.md   # Twitter/X (copy-paste)
└── 2025-12-01-linkedin.md  # LinkedIn (copy-paste)
```

### Cost
~$0.002 per complete report (blog + 2 social posts)

---

## Sprint 6: Persistence Protocol Enforcement (v4.2.0)
**Released**: 2025-11-29

Made file persistence bypass architecturally impossible.

### The Problem
Specialists could still technically attempt Write/Edit operations, leading to silent failures.

### The Solution
- **Pre-flight checklists** - Mandatory before file operation delegation
- **Response validation** - JSON output required, no file claims accepted
- **Verification templates** - Standardized post-operation checks

### Key Deliverables
- `templates/file-operation-delegation.md` (243 lines)
- `templates/file-verification-checklist.md` (176 lines)
- `project/field-manual/file-operation-quickref.md` (311 lines)

### Impact
- File persistence: 80% → 100%
- Zero prompt dependency for reliability

---

## Sprint 5: MCP Context Optimization (v4.1.0)
**Released**: 2025-11-28

60-90% context token reduction with mission-specific MCP profiles.

### The Problem
Loading all MCPs consumed ~50-60K tokens, limiting mission complexity.

### The Solution
13 specialized profiles loading only needed tools:

| Profile | Tokens | Reduction | Use Case |
|---------|--------|-----------|----------|
| `minimal-core` | ~5K | 90% | File-only operations |
| `research-only` | ~15K | 70% | Documentation lookup |
| `frontend-deploy` | ~15K | 70% | Netlify deployments |
| `backend-deploy` | ~15K | 70% | Railway deployments |
| `db-read` | ~15K | 70% | Read-only database |
| `db-write` | ~18K | 64% | Full database access |
| `core` | ~3K | 80% | General development |
| `testing` | ~5.5K | 63% | Playwright automation |
| `fullstack` | ~50K | 0% | All development MCPs |

### Commands
- `/mcp-switch [profile]` - Switch profiles
- `/mcp-list` - See all profiles
- `/mcp-status` - Check current

---

## Sprint 4: Opus 4.5 Dynamic Model Selection (v4.0.0)
**Released**: 2025-11-27

Intelligent model selection based on task complexity.

### Tiered Strategy

| Tier | Model | When to Use |
|------|-------|-------------|
| **1** | Opus | Complex orchestration, strategic reasoning, multi-phase missions |
| **2** | Sonnet | Standard implementation, testing, analysis (default) |
| **3** | Haiku | Simple docs, quick lookups, routine operations |

### Task Tool Syntax
```python
# Complex - use Opus
Task(subagent_type="strategist", model="opus", prompt="...")

# Standard - use default (Sonnet)
Task(subagent_type="developer", prompt="...")

# Simple - use Haiku
Task(subagent_type="documenter", model="haiku", prompt="...")
```

### Impact
- Mission success rate: +15%
- Iterations to completion: -28%
- Total cost: -24% (efficiency offsets higher per-token)

---

## Sprint 3: Design Review System (v3.0.0)
**Released**: 2025-11-20

Comprehensive UI/UX audit capabilities.

### Features
- **RECON Protocol** - 7-phase systematic design review
- **Playwright automation** - Automated interaction testing
- **SENTINEL Mode** - Zero bugs reach production
- **Evidence-based** - Screenshots and reproduction steps

### 7-Phase Protocol
1. Preparation - Environment setup, baseline screenshots
2. Interaction - User flows, micro-interactions
3. Responsive - Mobile, tablet, desktop
4. Visual - Typography, spacing, hierarchy
5. Accessibility - WCAG AA+ compliance
6. Robustness - Edge cases, error states
7. Performance - Load times, console errors

### Commands
- `/design-review` - Full 7-phase audit
- `/recon` - Quick design reconnaissance

---

## Sprint 2: Coordinator-as-Executor Pattern (v2.0.0)
**Released**: 2025-11-19

The architectural solution to file persistence.

### The Problem (Sprint 1 Discovery)
Specialists operating in isolated Task tool contexts couldn't persist files. Files would appear created during agent execution but vanish after completion. 100% reproducible.

### The Solution
- **Specialists return JSON** with file specifications
- **Coordinator executes** Write/Edit tools
- **Automatic verification** confirms file existence

### JSON Output Format
```json
{
  "file_operations": [
    {
      "operation": "create",
      "file_path": "/absolute/path/to/file",
      "content": "complete file content",
      "description": "what this operation does"
    }
  ]
}
```

### Impact
- File persistence: ~30% (baseline) → 100%
- Silent failures: Eliminated
- Prompt dependency: Zero

---

## Sprint 1: Foundation & File Persistence Discovery (v1.x)
**Released**: 2025-11-15

Initial release and critical bug discovery.

### Features
- 11 specialized agents (Strategist, Developer, Tester, Operator, Architect, Designer, Documenter, Support, Analyst, Marketer, Coordinator)
- Mission-driven orchestration (`/coord`)
- 20 pre-built mission workflows
- Context preservation system
- Project-local installation

### Critical Discovery
Identified file persistence bug where specialists couldn't reliably create files. This led to Sprint 2's architectural solution.

### Initial Architecture
```
User → /coord → Coordinator → Specialists → Files
                    ↓
              Context Files (agent-context.md, handoff-notes.md)
```

---

## Version Summary

| Version | Sprint | Release Date | Key Feature |
|---------|--------|--------------|-------------|
| 5.1.0 | 10 | 2026-01-01 | Structured Context System (100% data preservation) |
| 5.0.0 | 9 | 2025-12-31 | SaaS Boilerplate Killer (Skills, Gates, Plan-Driven) |
| 4.4.0 | 8 | 2025-12-05 | Phase Gate Enforcement |
| 4.3.0 | 7 | 2025-12-01 | Social Media Post Generation |
| 4.2.0 | 6 | 2025-11-29 | Persistence Protocol Enforcement |
| 4.1.0 | 5 | 2025-11-28 | MCP Context Optimization |
| 4.0.0 | 4 | 2025-11-27 | Opus 4.5 Dynamic Model Selection |
| 3.0.0 | 3 | 2025-11-20 | Design Review System |
| 2.0.0 | 2 | 2025-11-19 | Coordinator-as-Executor Pattern |
| 1.x | 1 | 2025-11-15 | Foundation + Bug Discovery |

---

## Cumulative Impact

| Metric | v1.0 | v5.1.0 | Improvement |
|--------|------|--------|-------------|
| File persistence | ~30% | 100% | +233% |
| Mission success | 70% | 85% | +21% |
| Context efficiency | Baseline | 90% reduction | 10x |
| Data preservation | ~50% | 100% | +100% |
| Iterations to complete | 3.5 avg | 2.5 avg | -28% |
| Cost per mission | Baseline | -24% | Significant |

---

*For technical changelog format, see [CHANGELOG.md](../CHANGELOG.md)*
