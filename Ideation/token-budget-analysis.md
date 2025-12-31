# Token Budget Analysis: Information Density vs Allocation

## Current Sprint 9 Token Budgets

| Summary Type | Current Budget | Source Document |
|--------------|----------------|-----------------|
| vision-summary.md | ~100 tokens | strategic-plan.md |
| icp-summary.md | ~100 tokens | client-success-blueprint.md |
| brand-summary.md | ~100 tokens | brand-style-guidelines.md |
| prd-summary.md | ~200 tokens | prd.md |
| **Total Foundation** | **~500 tokens** | |

Phase context: ~500 tokens (rolling wave)
**Total working context**: ~1000 tokens + conversation

## The Problem: Proportionality to Information Density

The user raises a critical point: **token budgets should be proportional to information density**, not uniform.

### Information Density Analysis

| Document | Information Density | Criticality | Suggested Budget |
|----------|---------------------|-------------|------------------|
| **PRD** | **VERY HIGH** - Features, requirements, acceptance criteria, MVP scope, tech constraints | **P0** - Everything builds from this | **500-800 tokens** |
| **Strategic Plan** | HIGH - Vision, mission, goals, success metrics | P1 - Guides decisions | 200-300 tokens |
| **Client Success Blueprint** | HIGH - ICP, pain points, jobs-to-be-done, personas | P1 - Guides UX/features | 200-300 tokens |
| **Brand Guidelines** | MEDIUM - Colors, fonts, tone, voice | P2 - Guides UI/copy | 100-150 tokens |
| **Marketing Bible** | MEDIUM - Messaging, positioning, channels | P3 - Later phases | 100-150 tokens |

### Why PRD Needs More Tokens

The PRD contains:
1. **Feature specifications** - What to build
2. **Acceptance criteria** - How to verify
3. **Priority tiers** - What to build first
4. **Technical constraints** - How to build
5. **MVP scope** - What's in/out
6. **User stories** - Why to build

Compressing this to 200 tokens loses critical implementation details. A developer needs:
- Exact feature names and descriptions
- Priority ordering
- Technical requirements (auth type, payment provider, etc.)
- Integration requirements

### The Summarization Paradox

> "By creating summaries we are reducing the tokens anyway"

True, but the **quality of reduction matters**:
- A 200-token PRD summary might say "Build auth, payments, dashboard"
- A 600-token PRD summary can say "Build Supabase auth with magic links, Stripe payments with 4-tier pricing (Free/Solo/Growth/Scale), admin dashboard with user management and analytics"

The second version enables autonomous implementation. The first requires constant clarification.

## Recommended Token Budget Revision

### Tier 1: Implementation-Critical (Higher Budget)
| Summary | Budget | Rationale |
|---------|--------|-----------|
| prd-summary.md | **600 tokens** | Contains all implementation requirements |
| tech-summary.md | **300 tokens** | Stack decisions, constraints, integrations |

### Tier 2: Decision-Guiding (Medium Budget)  
| Summary | Budget | Rationale |
|---------|--------|-----------|
| vision-summary.md | **200 tokens** | Guides feature prioritization |
| icp-summary.md | **200 tokens** | Guides UX decisions |

### Tier 3: Style-Guiding (Lower Budget)
| Summary | Budget | Rationale |
|---------|--------|-----------|
| brand-summary.md | **100 tokens** | Colors, fonts, tone |
| marketing-summary.md | **100 tokens** | Messaging, positioning |

**Revised Total**: ~1500 tokens for foundations (vs 500 current)

### Why This Is Acceptable

1. **Context windows are large**: Claude has 200K context. 1500 tokens is <1%
2. **Quality > Quantity**: Better summaries = fewer clarification rounds
3. **Front-loaded investment**: Spend tokens upfront, save conversation tokens later
4. **Progressive disclosure**: Full docs available if summary insufficient

## Dynamic Budget Allocation

Instead of fixed budgets, consider **information-density-based allocation**:

```yaml
summary_budgets:
  strategy: proportional_to_density
  
  # High-density documents get more tokens
  high_density:
    - prd.md: 600
    - technical-requirements.md: 300
    
  # Medium-density documents
  medium_density:
    - strategic-plan.md: 200
    - client-success-blueprint.md: 200
    
  # Lower-density documents
  low_density:
    - brand-style-guidelines.md: 100
    - marketing-bible.md: 100
    
  # Total budget cap (soft limit)
  max_total: 2000
```

## Implementation Recommendation

### Option A: Fixed Higher Budgets
Update Sprint 9 to use revised budgets:
- PRD: 600 tokens
- Vision/ICP: 200 tokens each
- Brand/Marketing: 100 tokens each
- Total: ~1200 tokens

### Option B: Dynamic Budgets (Preferred)
Let `/foundations init` analyze document complexity and allocate proportionally:

```python
def calculate_budget(doc_type, doc_length, doc_complexity):
    base_budgets = {
        'prd': 600,
        'strategic': 200,
        'icp': 200,
        'brand': 100,
        'marketing': 100
    }
    
    # Adjust based on actual document complexity
    complexity_multiplier = min(1.5, doc_complexity / baseline_complexity)
    
    return min(
        base_budgets[doc_type] * complexity_multiplier,
        max_budget_cap
    )
```

### Option C: User-Configurable
Allow users to specify budgets in `handoff-manifest.json`:

```json
{
  "token_budgets": {
    "prd": 800,
    "vision": 300,
    "icp": 200,
    "brand": 100
  }
}
```

## Conclusion

The current 500-token total budget is **too restrictive** for PRD content. Recommend:

1. **Increase PRD budget to 600 tokens** (minimum)
2. **Keep other summaries at 100-200 tokens**
3. **Allow user override** via manifest configuration
4. **Document the rationale**: Higher-density documents need more tokens

This aligns with the principle: **token budgets should be proportional to information density**.
