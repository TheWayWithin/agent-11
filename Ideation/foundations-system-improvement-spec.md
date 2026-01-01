# AGENT-11 Foundations System Improvement Specification

**Issue ID**: AGENT11-FOUNDATIONS-001
**Date**: 2026-01-01
**Reporter**: Validation testing on SoloPilot project
**Priority**: High
**Component**: `/foundations` skill, context preservation system

---

## Executive Summary

The current `/foundations init` system uses arbitrary token budgets to compress foundation documents into summaries. Testing revealed this approach sacrifices critical implementation details, making summaries inadequate for agent decision-making. A schema-driven, AI-readable approach is recommended instead.

---

## Issue Description

### Current Behavior

The `/foundations` skill creates summaries with fixed token budgets:

| Category | Token Budget | Actual Need |
|----------|--------------|-------------|
| PRD | 600 | ~1,200 |
| Vision | 200 | ~400 |
| ICP | 200 | ~500 |
| Brand | 100 | ~400 |
| Marketing | 100 | ~300 |

### Problem Discovered

Validation testing on SoloPilot foundation documents revealed:

| Category | Completeness | Actionability | Verdict |
|----------|--------------|---------------|---------|
| Brand | 25% | 20% | CRITICAL - Designer cannot build UI |
| ICP | 35% | 35% | Developer will miss user needs |
| Marketing | 40% | 45% | Marketer lacks execution details |
| PRD | 45% | 40% | Developer will make wrong assumptions |
| Vision | 65% | 70% | Acceptable for strategic alignment |

### Root Cause

Token limits are the **wrong constraint**. The approach optimizes for brevity rather than agent usability. This creates:

1. **Lossy compression** - Critical implementation details are discarded
2. **Arbitrary ratios** - 600 tokens for PRD regardless of document complexity
3. **No scalability** - Complex projects would need even more tokens, defeating the purpose
4. **Human-oriented format** - Prose summaries require parsing; agents work better with structured data

---

## Proposed Solution

### Shift from Token Budgets to Schema-Driven Structure

**Old Constraint**: "How short can we make this?"
**New Constraint**: "What format lets agents extract the right information efficiently?"

### Architecture Change

```
CURRENT FLOW:
Source Document → Compress to Token Budget → Prose Summary

PROPOSED FLOW:
Source Document → Extract to Schema → Structured YAML/JSON
                                           ↓
                              Selective Section Loading
                                           ↓
                              Agent gets only what it needs
```

### New File Structure

```
.context/
├── structured/
│   ├── prd.yaml          # Schema-driven, all critical data
│   ├── vision.yaml       # Complete but structured
│   ├── icp.yaml          # All personas, full attributes
│   ├── brand.yaml        # Complete design system
│   └── marketing.yaml    # Positioning, channels, keywords
├── manifest.yaml         # Section-level metadata
└── summaries/            # (Optional) Quick-reference prose
    └── ...
```

### Example Schema: PRD

```yaml
# .context/structured/prd.yaml
product:
  name: "SoloPilot"
  tagline: "The autopilot CRM for multi-product solopreneurs"
  type: "SaaS Web Application"
  website: "solopilot.work"

problem:
  core: "Email Guilt Loop"
  cycle:
    - "Multiple inboxes"
    - "Miss emails"
    - "Guilt"
    - "Rush response"
    - "Bad response"
    - "Angry customer"
    - "Lost business"

users:
  - profile: "Multi-Product Indie Hackers"
    priority: 1
    products: "3+"
    mrr_range: "$5K-50K"
  - profile: "Single-Product SaaS Builders"
    priority: 2
    mrr_range: "$1K-20K"

features:
  p0_must_have:
    - name: "Multi-Stripe Integration"
      acceptance_criteria:
        - "Connect unlimited Stripe accounts via OAuth"
        - "Sync customers, subscriptions, transactions"
        - "Real-time webhook updates"
        - "Merge duplicate customers across accounts"
      success_metric: "100% Stripe data visible within 5 minutes"

    - name: "Unified Customer View"
      acceptance_criteria:
        - "Customer profile with all purchases across products"
        - "Complete email history"
        - "Subscription status and MRR contribution"
        - "Customer health score"
        - "Timeline of all interactions"
      success_metric: "<3 seconds to full customer context"
    # ... more features

tech_stack:
  frontend: "Next.js 14 (App Router)"
  backend: "Next.js API Routes + tRPC"
  database: "PostgreSQL (Supabase or Neon)"
  auth: "Clerk or NextAuth"
  hosting: "Vercel"
  email: "Resend"
  ai: "OpenAI GPT-4"
  queues: "Inngest or Trigger.dev"

success_metrics:
  - metric: "Sean Ellis Test"
    target: "40%+ very disappointed"
  - metric: "Support Automation"
    target: "80%+ handled without intervention"
  - metric: "Monthly Churn"
    target: "<5%"
  - metric: "Trial Conversion"
    target: "25%+"
```

### Example Schema: Brand

```yaml
# .context/structured/brand.yaml
identity:
  essence: "The autopilot CRM for multi-product solopreneurs"
  philosophy: "AI-native from the ground up"
  voice: "First person, direct, transparent"

colors:
  primary:
    purple:
      hex: "#8B5CF6"
      rgb: [139, 92, 246]
      usage: "Primary actions, brand identity, links"
    deep_violet:
      hex: "#6D28D9"
      rgb: [109, 40, 217]
      usage: "Hover states, gradients"

  neutrals:
    slate_950:
      hex: "#0F0D13"
      usage: "Deepest backgrounds"
    slate_900:
      hex: "#1A1720"
      usage: "Primary dark background"
    slate_800:
      hex: "#2D2A36"
      usage: "Cards, elevated surfaces"
    slate_300:
      hex: "#D4D2DC"
      usage: "Primary text (dark mode)"

  functional:
    success: "#10B981"
    error: "#EF4444"
    warning: "#F59E0B"
    info: "#3B82F6"

typography:
  primary:
    font: "Inter"
    source: "Google Fonts"
    weights: [400, 500, 600, 700]
  monospace:
    font: "JetBrains Mono"
    usage: "Code snippets"

  scale:
    display: { size: "56px", weight: 700, line_height: 1.1 }
    h1: { size: "48px", weight: 700, line_height: 1.2 }
    h2: { size: "36px", weight: 600, line_height: 1.25 }
    body: { size: "16px", weight: 400, line_height: 1.6 }

spacing:
  base: "8px"
  scale: [4, 8, 16, 24, 32, 48, 64, 96]

components:
  buttons:
    primary:
      background: "#8B5CF6"
      text: "#FFFFFF"
      radius: "8px"
      padding: "12px 24px"
    secondary:
      background: "transparent"
      border: "1px solid #8B5CF6"
      text: "#8B5CF6"

  cards:
    default:
      background: "#1A1720"
      border: "1px solid #2D2A36"
      radius: "12px"
      padding: "24px"

icons:
  library: "Lucide"
  style: "Outline"
  stroke: "2px"
  sizes: [16, 20, 24, 32]
```

---

## Implementation Recommendations

### 1. Update `/foundations` Skill

**File**: `project/skills/foundations.md` (or equivalent)

Changes needed:
- Remove token budget constraints
- Add schema definitions for each category (PRD, Vision, ICP, Brand, Marketing)
- Generate YAML/JSON structured files instead of prose summaries
- Include validation that all required schema fields are populated

### 2. Update Handoff Manifest Schema

**File**: `project/schemas/handoff-manifest.schema.yaml`

Add section-level metadata:
```yaml
documents:
  prd:
    source: "documents/foundations/prd.md"
    structured: ".context/structured/prd.yaml"
    checksum: "abc123..."
    sections:
      - id: "features.p0_must_have"
        tokens: ~450
      - id: "tech_stack"
        tokens: ~120
```

### 3. Add Context Requirements to Agent Profiles

Each agent should declare what context it needs:

```yaml
# In agent profile
context_requirements:
  required:
    - "prd.features"
    - "prd.tech_stack"
  optional:
    - "brand.components"
  exclude:
    - "marketing.*"
```

### 4. Update Coordinator Delegation

When delegating, load only relevant context sections:

```python
Task(
  subagent_type="developer",
  prompt=f"""
  Context loaded: prd.features, prd.tech_stack, brand.components

  {load_sections(['prd.features', 'prd.tech_stack', 'brand.components'])}

  [Task instructions...]
  """
)
```

### 5. Optional: Keep Quick-Reference Summaries

The current prose summaries could remain as "quick-reference" for human review, while structured files are the source of truth for agents.

---

## Benefits of This Approach

| Aspect | Current | Proposed |
|--------|---------|----------|
| Information loss | High (25-65% completeness) | None (100% in structured format) |
| Scalability | Poor (fixed budgets) | Good (schema adapts to content) |
| Agent parsing | Requires NLP interpretation | Direct field access |
| Selective loading | All or nothing | Section-level granularity |
| Validation | Manual review | Schema validation |
| Maintenance | Re-summarize on changes | Update specific fields |

---

## Migration Path

### Phase 1: Schema Definitions
- Define YAML schemas for each foundation category
- Document required vs optional fields

### Phase 2: `/foundations` Skill Update
- Update skill to output structured YAML
- Keep prose summaries as secondary output (optional)

### Phase 3: Agent Integration
- Add context_requirements to agent profiles
- Update coordinator to load sections selectively

### Phase 4: Testing
- Validate on SoloPilot project
- Confirm agents can make correct decisions from structured context alone

---

## Files to Modify in AGENT-11

1. `project/skills/foundations.md` - Main skill logic
2. `project/schemas/handoff-manifest.schema.yaml` - Manifest schema
3. `project/schemas/` - Add new schemas:
   - `prd.schema.yaml`
   - `vision.schema.yaml`
   - `icp.schema.yaml`
   - `brand.schema.yaml`
   - `marketing.schema.yaml`
4. `project/agents/specialists/*.md` - Add context_requirements to each
5. `project/agents/coordinator.md` - Update delegation to use selective loading
6. `CLAUDE.md` - Document the new context system

---

## Test Case

After implementation, re-run validation on SoloPilot:

**Expected Results**:
- All categories should have 95%+ completeness
- Agents should be able to make implementation decisions without source document reference
- Designer can build consistent UI from brand.yaml alone
- Developer can implement features from prd.yaml alone

---

## Appendix: Validation Evidence

See `/Users/jamiewatters/DevProjects/SoloPilot/progress.md` for full validation results that identified this issue.

Key finding: Brand summary at 100 tokens captured only 25% of information needed for a designer to build consistent UI. This is unacceptable for agent-driven development.

---

*Generated from SoloPilot foundation validation mission - 2026-01-01*
