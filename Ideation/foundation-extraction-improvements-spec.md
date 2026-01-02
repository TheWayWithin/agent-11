# Foundation Extraction Improvements Specification

**Document Type**: Developer Specification
**Created**: 2026-01-01
**Priority**: Medium
**Estimated Effort**: 30-45 minutes

---

## Executive Summary

Following validation of the `.context/structured/` YAML extractions, two files require enhancement to reach production-ready status. All other extractions (6 of 8) passed validation and require no changes.

---

## Improvement 1: roadmap.yaml Enhancement

**File**: `.context/structured/roadmap.yaml`
**Current Score**: 78%
**Target Score**: 95%
**Priority**: Medium
**Impact**: Developers need granular task breakdown for implementation planning

### Problem

The current extraction captures phase timelines and goals but lacks:
1. Specific deliverables per phase (what gets built each week)
2. Success criteria per milestone (how we know it's done)

### Required Changes

#### 1.1 Add `deliverables` Array to Each MVP Phase

**Location**: `mvp_v1.development_timeline.phases[].weeks[]`

**Current Structure**:
```yaml
phases:
  - phase: 1
    name: "Foundation"
    duration: "Weeks 1-6"
    goal: "Core infrastructure and Stripe integration working"
    weeks:
      - weeks: "1-2"
        focus: "Project Setup"
        deliverables: "Next.js app scaffold, PostgreSQL database schema, authentication system (Clerk), CI/CD pipeline"
        milestone: "Dev environment operational"
```

**Required Structure** (add `deliverables_list` array):
```yaml
phases:
  - phase: 1
    name: "Foundation"
    duration: "Weeks 1-6"
    goal: "Core infrastructure and Stripe integration working"
    weeks:
      - weeks: "1-2"
        focus: "Project Setup"
        deliverables: "Next.js app scaffold, PostgreSQL database schema, authentication system (Clerk), CI/CD pipeline"
        deliverables_list:
          - item: "Next.js app scaffold"
            type: "code"
            acceptance: "App runs on localhost:3000"
          - item: "PostgreSQL database schema"
            type: "database"
            acceptance: "Migrations run successfully"
          - item: "Authentication system (Clerk)"
            type: "integration"
            acceptance: "User can sign up/login"
          - item: "CI/CD pipeline"
            type: "infrastructure"
            acceptance: "Push to main triggers deployment"
        milestone: "Dev environment operational"
```

**Apply to all 4 phases, all week entries.**

#### 1.2 Add `success_criteria` Array to Strategic Milestones

**Location**: `strategic_milestones.year_1_foundation_2026[]`

**Current Structure**:
```yaml
strategic_milestones:
  year_1_foundation_2026:
    - milestone: "Beta Launch"
      target_date: "Q1 2026"
      success_criteria: "50 beta users, core features working"
```

**Required Structure** (expand `success_criteria` to array):
```yaml
strategic_milestones:
  year_1_foundation_2026:
    - milestone: "Beta Launch"
      target_date: "Q1 2026"
      success_criteria_summary: "50 beta users, core features working"
      success_criteria:
        - metric: "Beta users"
          target: 50
          measurement: "Signed up accounts with activity"
        - metric: "Core features"
          target: "5 P0 features functional"
          measurement: "QA checklist passed"
        - metric: "Critical bugs"
          target: 0
          measurement: "No P0 bugs in production"
```

**Apply to all milestones in Years 1-5.**

### Source Data

Extract deliverable details from: `documents/foundations/Strategic Roadmap.md`

Relevant sections:
- "MVP Development Timeline" (lines 72-147) - Contains week-by-week breakdown
- "Strategic Milestones" (lines 371-403) - Contains milestone success criteria

---

## Improvement 2: brand.yaml Enhancement

**File**: `.context/structured/brand.yaml`
**Current Score**: 85%
**Target Score**: 95%
**Priority**: Low
**Impact**: Designer needs complete design tokens for production UI

### Problem

The current extraction captures primary colors and typography but lacks:
1. Neutral color palette (grays for text, borders, backgrounds)
2. Shadow/elevation system
3. Animation timing tokens
4. Responsive breakpoints

### Required Changes

#### 2.1 Add Neutral Color Palette

**Location**: `colors` section (add new `neutrals` key)

**Add this structure**:
```yaml
colors:
  # ... existing primary, secondary, etc. ...

  neutrals:
    white: "#FFFFFF"
    gray_50: "#F9FAFB"
    gray_100: "#F3F4F6"
    gray_200: "#E5E7EB"
    gray_300: "#D1D5DB"
    gray_400: "#9CA3AF"
    gray_500: "#6B7280"
    gray_600: "#4B5563"
    gray_700: "#374151"
    gray_800: "#1F2937"
    gray_900: "#111827"
    black: "#000000"

  usage:
    text_primary: "gray_900"
    text_secondary: "gray_600"
    text_muted: "gray_400"
    border_default: "gray_200"
    border_strong: "gray_300"
    background_page: "white"
    background_subtle: "gray_50"
    background_muted: "gray_100"
```

#### 2.2 Add Shadow/Elevation System

**Location**: Add new top-level `shadows` section

```yaml
shadows:
  sm: "0 1px 2px 0 rgba(0, 0, 0, 0.05)"
  default: "0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px -1px rgba(0, 0, 0, 0.1)"
  md: "0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -2px rgba(0, 0, 0, 0.1)"
  lg: "0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -4px rgba(0, 0, 0, 0.1)"
  xl: "0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.1)"
  inner: "inset 0 2px 4px 0 rgba(0, 0, 0, 0.05)"
  none: "0 0 #0000"

  usage:
    card: "default"
    dropdown: "lg"
    modal: "xl"
    input_focus: "sm"
    button_hover: "md"
```

#### 2.3 Add Animation Timing Tokens

**Location**: Add new top-level `animations` section

```yaml
animations:
  durations:
    instant: "0ms"
    fast: "150ms"
    normal: "300ms"
    slow: "500ms"

  easings:
    default: "cubic-bezier(0.4, 0, 0.2, 1)"
    in: "cubic-bezier(0.4, 0, 1, 1)"
    out: "cubic-bezier(0, 0, 0.2, 1)"
    in_out: "cubic-bezier(0.4, 0, 0.2, 1)"
    bounce: "cubic-bezier(0.68, -0.55, 0.265, 1.55)"

  presets:
    fade_in: "opacity normal default"
    slide_up: "transform normal out"
    button_press: "transform fast default"
    modal_enter: "opacity normal out, transform normal out"
```

#### 2.4 Add Responsive Breakpoints

**Location**: Add new top-level `breakpoints` section

```yaml
breakpoints:
  xs: "0px"
  sm: "640px"
  md: "768px"
  lg: "1024px"
  xl: "1280px"
  2xl: "1536px"

  usage:
    mobile: "< sm"
    tablet: "sm to lg"
    desktop: ">= lg"

  container_widths:
    sm: "640px"
    md: "768px"
    lg: "1024px"
    xl: "1280px"
```

### Source Data

The source `documents/foundations/Brand Style Guide.md` may not contain all these tokens explicitly. Use industry-standard values (Tailwind CSS defaults) where not specified in source.

Note in the YAML header:
```yaml
# Note: neutrals, shadows, animations, and breakpoints use
# industry-standard values (Tailwind CSS) as source document
# did not specify these tokens explicitly.
```

---

## Implementation Checklist

### roadmap.yaml
- [ ] Read source: `documents/foundations/Strategic Roadmap.md`
- [ ] Add `deliverables_list` array to Phase 1, Weeks 1-2
- [ ] Add `deliverables_list` array to Phase 1, Weeks 3-4
- [ ] Add `deliverables_list` array to Phase 1, Weeks 5-6
- [ ] Add `deliverables_list` array to Phase 2, Weeks 7-8
- [ ] Add `deliverables_list` array to Phase 2, Weeks 9-10
- [ ] Add `deliverables_list` array to Phase 2, Weeks 11-12
- [ ] Add `deliverables_list` array to Phase 3, Weeks 13-14
- [ ] Add `deliverables_list` array to Phase 3, Weeks 15-16
- [ ] Add `deliverables_list` array to Phase 3, Weeks 17-18
- [ ] Add `deliverables_list` array to Phase 4, Weeks 19-20
- [ ] Add `deliverables_list` array to Phase 4, Weeks 21-22
- [ ] Add `deliverables_list` array to Phase 4, Weeks 23-24
- [ ] Expand `success_criteria` for Year 1 milestones (4 milestones)
- [ ] Expand `success_criteria` for Year 2 milestones (3 milestones)
- [ ] Expand `success_criteria` for Year 3 milestones (2 milestones)
- [ ] Expand `success_criteria` for Year 5 milestones (2 milestones)
- [ ] Validate YAML syntax: `python3 -c "import yaml; yaml.safe_load(open('.context/structured/roadmap.yaml'))"`

### brand.yaml
- [ ] Add `neutrals` color palette under `colors`
- [ ] Add `usage` guide under `colors`
- [ ] Add `shadows` section with 6 elevation levels
- [ ] Add shadow `usage` guide
- [ ] Add `animations` section with durations and easings
- [ ] Add animation `presets`
- [ ] Add `breakpoints` section with 6 breakpoints
- [ ] Add breakpoint `usage` and `container_widths`
- [ ] Update YAML header comment noting industry-standard values used
- [ ] Validate YAML syntax: `python3 -c "import yaml; yaml.safe_load(open('.context/structured/brand.yaml'))"`

---

## Validation After Implementation

Run this validation command after completing changes:

```bash
# Validate all YAML files
for f in .context/structured/*.yaml; do
  python3 -c "import yaml; yaml.safe_load(open('$f'))" 2>&1 && \
  echo "✓ $(basename $f)" || echo "✗ $(basename $f) - INVALID"
done

# Count lines to verify additions
wc -l .context/structured/roadmap.yaml .context/structured/brand.yaml
```

**Expected Results**:
- roadmap.yaml: ~700-800 lines (up from 548)
- brand.yaml: ~750-850 lines (up from 638)
- All files: Valid YAML syntax

---

## Success Criteria

| File | Current Score | Target Score | Validation |
|------|---------------|--------------|------------|
| roadmap.yaml | 78% | 95% | Has deliverables_list in all phases |
| brand.yaml | 85% | 95% | Has neutrals, shadows, animations, breakpoints |

**Definition of Done**:
1. All checklist items completed
2. YAML validation passes
3. Designer agent can find neutral colors and shadows
4. Developer agent can list specific deliverables per phase
