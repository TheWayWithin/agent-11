---
name: foundations
description: Manage BOS-AI foundation documents handoff - scan, validate, extract to structured YAML
mode: agent
---

# /foundations Command

## PURPOSE

Manage the handoff of BOS-AI foundation documents to AGENT-11. This command scans the `documents/foundations/` directory, extracts content to structured YAML schemas, and produces a `handoff-manifest.yaml` for project context.

**Key Design Principle**: Extract complete, structured data that agents can parse directly - not lossy prose summaries.

## SUBCOMMANDS

### `/foundations init`
Initialize the foundations system - scan documents, extract to structured YAML, generate manifest.

### `/foundations status`
Show current state of all foundation documents with present/extracted/modified status.

### `/foundations refresh`
Re-extract documents that have changed (checksum mismatch).

### `/foundations validate`
Validate that required documents are present and extracted data is complete.

---

## EXECUTION PROTOCOL

### Step 1: Parse Subcommand

Extract the subcommand from the user's input:
- `init` - Full initialization with extraction
- `status` - Show status table
- `refresh` - Update changed documents
- `validate` - Check document and extraction completeness

If no subcommand provided, default to `status`.

---

## SUBCOMMAND: init

### Phase 1: Directory Scan

**Scan Location**: `documents/foundations/`

**Document Category Matching** (case-insensitive, order of precedence):

| Category | Priority 1 | Priority 2 | Priority 3 | Priority 4 | Priority 5 |
|----------|------------|------------|------------|------------|------------|
| **prd** | prd.md | requirements.md | product-requirements.md | *-prd-*.md | prd-*.md |
| **vision** | vision-mission.md | vision.md | strategic-plan.md | vision-and-mission.md | |
| **roadmap** | strategic-roadmap.md | roadmap.md | development-plan.md | | |
| **icp** | client-success-blueprint.md | icp.md | personas.md | customer-success.md | |
| **research** | market-and-client-research.md | market-research.md | competitive-analysis.md | research.md | |
| **brand** | brand-style-guidelines.md | brand.md | style-guide.md | brand-style-guide.md | |
| **marketing** | marketing-bible.md | marketing.md | positioning.md | positioning-statement.md | |
| **pricing** | pricing-strategy.md | pricing.md | pricing-tiers.md | | |

**Pattern Matching Notes**:
- Patterns with `*` are glob patterns (e.g., `*-prd-*.md` matches `ModelOptix-Core-PRD-FINAL.md`)
- Matching is case-insensitive
- First match wins (Priority 1 before Priority 2, etc.)
- Files in subdirectories (e.g., `prds/`) are also scanned

**For each document found**:
1. Read file content
2. Calculate SHA256 checksum: `sha256sum <file>`
3. Count words: `wc -w <file>`
4. Categorize based on filename matching above

### Phase 2: Generate Checksums

For each categorized document:
```bash
sha256sum documents/foundations/<filename> | cut -d' ' -f1
```

### Phase 3: Extract to Structured YAML

**Create directory**: `.context/structured/`

**Schema References** (in `project/schemas/`):
- `foundation-prd.schema.yaml`
- `foundation-vision.schema.yaml`
- `foundation-roadmap.schema.yaml`
- `foundation-icp.schema.yaml`
- `foundation-research.schema.yaml`
- `foundation-brand.schema.yaml`
- `foundation-marketing.schema.yaml`
- `foundation-pricing.schema.yaml`

**Extraction Approach** (NOT summarization):

For each document category, extract ALL relevant data into the schema structure. Do NOT compress or summarize - transfer complete information.

### Document Type Classification

Before extraction, classify the document type to apply appropriate rules:

| Document | Type | Mode |
|----------|------|------|
| PRD | SPECIFICATION | COMPLETENESS MODE |
| Vision | STRATEGIC | SYNTHESIS MODE |
| Roadmap | STRATEGIC | SYNTHESIS MODE |
| ICP | STRUCTURED | MAPPING MODE |
| Research | ANALYTICAL | COMPLETENESS MODE |
| Brand | PRECISION | EXACT MODE |
| Marketing | STRATEGIC | SYNTHESIS MODE |
| Pricing | STRUCTURED | MAPPING MODE |

### Extraction Mode Rules

**COMPLETENESS MODE** (PRD, Architecture):
```
MANDATORY RULES:
- Extract 100% of ALL list items - NEVER sample, truncate, or summarize lists
- Preserve EVERY numeric value with its unit and context (e.g., "1,000 users in 3 months")
- Include ALL sub-components of compound features (every item after commas)
- Extract ALL timeline/duration information (weeks, dates, phases)
- Preserve technology version numbers (Next.js 14, not just "Next.js")
- Include ALL SLAs, thresholds, and performance targets
- When in doubt, INCLUDE rather than exclude
```

**EXACT MODE** (Brand, Style Guide):
```
MANDATORY RULES:
- Byte-level precision on ALL values
- Preserve exact hex codes, RGB values, font names
- Include units on ALL measurements (px, rem, %)
- No interpretation - pure transcription
- Every color, every font weight, every spacing value
```

**MAPPING MODE** (ICP, Personas):
```
MANDATORY RULES:
- Map ALL personas with ALL fields
- Include ALL pain points, goals, objections
- Preserve ALL numeric criteria (revenue ranges, team sizes)
- Extract ALL quotes verbatim
```

**SYNTHESIS MODE** (Vision, Marketing):
```
MANDATORY RULES:
- Capture strategic statements fully
- Preserve numeric goals and timeframes
- Include emotional/aspirational language
- Extract ALL success indicators and milestones
```

### Extraction Prompt Template

**For PRD Documents** (COMPLETENESS MODE):
```
Extract structured data from this PRD document into the schema format.

CRITICAL COMPLETENESS RULES - YOU MUST FOLLOW THESE:

1. NUMERIC VALUES - Extract EVERY number with full context:
   - "1,000 users" → target: 1000, context: "users"
   - "$10K MRR" → target: 10000, unit: "USD", period: "monthly"
   - "70% retention" → target: 70, unit: "percent"
   - Include ALL SLAs: uptime %, response times, concurrent users

2. LISTS - Extract 100% of items, NEVER truncate:
   - If source has 8 deliverables, output MUST have 8 deliverables
   - If source has 10 requirements, output MUST have 10 requirements
   - Count items in source, verify count in output matches

3. FEATURE SUB-COMPONENTS - Extract ALL parts:
   - "Inline editing, AI rewrite, version comparison" = 3 separate items
   - Every comma-separated item becomes a sub_feature entry
   - Don't flatten or combine

4. TIMELINES - Extract ALL temporal information:
   - Phase ranges: "Weeks 1-6" → start: "Week 1", end: "Week 6"
   - Durations: "3-5 minutes" → duration: "3-5 minutes"
   - Deadlines: "by Q2" → deadline: "Q2"

5. TECHNOLOGY SPECIFICS - Preserve versions and variants:
   - "GPT-4, GPT-4o, Claude" = 3 separate AI model entries
   - "Next.js 14 App Router" → name: "Next.js", version: "14", features: ["App Router"]
   - "Supabase with RLS" → name: "Supabase", features: ["RLS"]

6. GLOSSARY - Extract ALL domain-specific terms:
   - Look for definitions, abbreviations, product-specific terminology
   - Include term, definition, aliases, and examples
   - Terms like "Opportunity", "Function", "Watcher" need clear definitions

7. STATE MACHINES - Extract ALL entity lifecycle states:
   - Subscription states: trial → active → cancelled/expired/paused
   - Opportunity states: new → evaluated → accepted/rejected
   - Include ALL transitions with triggers and side effects
   - Document guard conditions for each transition

8. ACCEPTANCE CRITERIA - Extract for EVERY feature:
   - Use Given/When/Then format where possible
   - "Given I am on checkout, When I click 'Start Trial', Then subscription created"
   - Include edge cases in acceptance criteria

9. CRITICAL USER JOURNEYS - Extract ALL end-to-end flows:
   - "New User to First Insight" - complete signup to value delivery
   - "Upgrade Path" - free trial to paid conversion
   - Include ALL steps with expected results

10. EDGE CASES - Extract ALL boundary conditions:
    - Tier limits: "User at 5 product limit adds 6th"
    - Payment failures: "Card declined during trial conversion"
    - Data edge cases: "Product with 0 functions tracked"
    - Categorize by: tier_limits, authentication, payment, data, concurrency

11. BUSINESS RULES - Extract ALL BR-XXX rules:
    - Include rule ID, category, statement, enforcement locations
    - Capture exceptions and related features
    - CRITICAL: Extract rules for tier limits, downgrade behavior, alerts

12. DATA MODEL ENTITIES - Extract ALL entities:
    - Include entities referenced in features but not explicitly listed
    - Common missing entities: Session, AuditLog, PromotionCode
    - Include ALL attributes with types and constraints

13. INTEGRATION TESTS - Extract cross-component scenarios:
    - "Signup + Stripe + Email" - registration flow integration
    - "Usage tracking + Alerts + Notifications"
    - Include data flow between components

14. SUCCESS CRITERIA BY TIER - Extract tier-specific metrics:
    - Free trial: activation criteria, conversion targets
    - Each paid tier: retention targets, upgrade signals
    - Include key actions that indicate success

15. ADDITIONAL COMPLIANCE - Extract privacy/data requirements:
    - Prompt data disclosure requirements
    - Third-party DPA requirements (OpenAI, Anthropic, etc.)
    - Audit logging requirements
    - Data retention policies

VALIDATION CHECK: Before completing, verify:
- Count of list items matches source document
- All numeric targets have values (not just descriptions)
- All timeline information is present
- All technology versions are preserved
- ALL business rules extracted (count BR-XXX in source vs output)
- ALL state machines with complete transitions
- ALL entities mentioned in features exist in data_model
- Acceptance criteria for EVERY feature

Schema reference: project/schemas/foundation-prd.schema.yaml
```

**For Brand Documents** (EXACT MODE):
```
Extract structured data from this Brand document into the schema format.

CRITICAL EXACTNESS RULES:

1. COLORS - Every hex code, exactly as written:
   - "#6366F1" not "purple" or "primary"
   - Include RGB if provided
   - Include usage context

   NEUTRALS (add if not in source - use Tailwind defaults):
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

   COLOR USAGE (add semantic mappings):
   usage:
     text_primary: "gray_900"
     text_secondary: "gray_600"
     text_muted: "gray_400"
     border_default: "gray_200"
     background_page: "white"
     background_subtle: "gray_50"

2. TYPOGRAPHY - Every specification:
   - Font family exact name
   - All weight values (400, 500, 600, 700)
   - All size values with units (16px, 1rem)
   - Line heights as numbers (1.5, 1.6)

3. SPACING - Every token:
   - Base unit (8px)
   - All scale values
   - Named spacing values

4. COMPONENTS - Full specifications:
   - Button styles with all states
   - Card styles with padding/radius/shadow
   - Input styles with all states

5. SHADOWS (add if not in source - use Tailwind defaults):
   shadows:
     sm: "0 1px 2px 0 rgba(0, 0, 0, 0.05)"
     default: "0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px -1px rgba(0, 0, 0, 0.1)"
     md: "0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -2px rgba(0, 0, 0, 0.1)"
     lg: "0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -4px rgba(0, 0, 0, 0.1)"
     xl: "0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.1)"
   usage:
     card: "default"
     dropdown: "lg"
     modal: "xl"

6. ANIMATIONS (add if not in source - use Tailwind defaults):
   animations:
     durations:
       fast: "150ms"
       normal: "300ms"
       slow: "500ms"
     easings:
       default: "cubic-bezier(0.4, 0, 0.2, 1)"
       in: "cubic-bezier(0.4, 0, 1, 1)"
       out: "cubic-bezier(0, 0, 0.2, 1)"

7. BREAKPOINTS (add if not in source - use Tailwind defaults):
   breakpoints:
     sm: "640px"
     md: "768px"
     lg: "1024px"
     xl: "1280px"
     2xl: "1536px"
   container_widths:
     sm: "640px"
     md: "768px"
     lg: "1024px"
     xl: "1280px"

NOTE: For neutrals, shadows, animations, and breakpoints - use Tailwind CSS
defaults if not specified in source document. Add YAML header comment noting
industry-standard values were used.

Schema reference: project/schemas/foundation-brand.schema.yaml
```

**For Vision Documents** (SYNTHESIS MODE):
```
Extract structured data from this Vision document into the schema format.

CRITICAL RULES:
1. Preserve vision and mission statements in full
2. Extract ALL goals with numeric targets and timeframes
3. Include ALL success indicators by year/period
4. Capture core values with their principles
5. Preserve aspirational language and emotional context

Schema reference: project/schemas/foundation-vision.schema.yaml
```

**For ICP Documents** (MAPPING MODE):
```
Extract structured data from this ICP document into the schema format.

CRITICAL RULES:
1. Extract ALL personas with ALL fields
2. Include ALL pain points with severity levels
3. Extract ALL jobs-to-be-done with context
4. Preserve ALL numeric criteria (revenue, team size, etc.)
5. Include ALL quotes verbatim
6. Extract ALL anti-personas

Schema reference: project/schemas/foundation-icp.schema.yaml
```

**For Marketing Documents** (SYNTHESIS MODE):
```
Extract structured data from this Marketing document into the schema format.

CRITICAL RULES:
1. Extract positioning statements fully
2. Include ALL value propositions by audience
3. Preserve ALL messaging frameworks
4. Extract ALL channel strategies
5. Include ALL competitive differentiators

Schema reference: project/schemas/foundation-marketing.schema.yaml
```

**For Roadmap Documents** (SYNTHESIS MODE):
```
Extract structured data from this Roadmap document into the schema format.

CRITICAL DELIVERABLES_LIST RULES - YOU MUST FOLLOW THESE:

1. For EACH week/period in EACH phase, create a deliverables_list array:
   - Extract EVERY deliverable as a separate item
   - Classify type: code, database, integration, infrastructure, design, documentation, test
   - Add acceptance criteria: "How we know it's done"

   Example:
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

2. For EACH strategic milestone, expand success_criteria to array:
   - Extract EACH measurable criterion
   - Include target (numeric or qualitative)
   - Include measurement method

   Example:
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

3. Preserve the original comma-separated deliverables string for reference

4. Apply to ALL phases (typically 4) and ALL year milestones (Years 1-5)

VALIDATION CHECK:
- Every phase week has deliverables_list array (not just string)
- Every milestone has success_criteria array (not just summary string)
- Every deliverable has item, type, and acceptance fields
- Every criterion has metric, target, and measurement fields

Schema reference: project/schemas/foundation-roadmap.schema.yaml
```

**For Pricing Documents** (MAPPING MODE):
```
Extract structured data from this Pricing Strategy document into the schema format.

CRITICAL MAPPING RULES - YOU MUST FOLLOW THESE:

1. PRICING TIERS - Extract EVERY tier with complete details:
   - Name, monthly price, annual price, currency
   - Primary metric (name and limit)
   - Target persona, stage, job-to-be-done
   - ALL features with included values (Yes/No/Limit)
   - Why this tier exists (strategic reasons)
   - Complete tier-level Marketing Physics

2. MARKETING PHYSICS - Extract at BOTH product and tier levels:
   - Product-level: Dramatic Difference, Overt Benefits, Real Reasons to Believe, FoMo
   - Tier-level: Same four components per tier
   - Preserve exact customer-voice language

3. NUMERIC VALUES - Extract ALL pricing data:
   - Monthly prices, annual prices
   - Metric limits (5 products, 10K API calls, etc.)
   - Alternative costs for competitive comparison
   - Savings calculations (annual savings, time savings)

4. UPGRADE TRIGGERS - Extract for EACH tier transition:
   - Trigger name and measurable signal
   - Upgrade message verbatim

5. OBJECTION HANDLING - Extract ALL objections:
   - Common objection text
   - Value-focused response

6. COMPETITIVE COMPARISON - Extract complete stack:
   - Each alternative with monthly cost and function
   - Total alternative cost (monthly + time)
   - Your value proposition comparison

VALIDATION CHECK:
- All tiers have complete Marketing Physics
- All prices have both monthly and annual values
- All tier transitions have upgrade triggers
- All objections have responses
- Competitive comparison has total cost calculation

Schema reference: project/schemas/foundation-pricing.schema.yaml
```

**Output files**: `.context/structured/{category}.yaml`

### Post-Extraction Validation

After extraction, perform these verification checks:

**CRITICAL: Schema Validation (FAIL mode)**:
- Parse output YAML against schema definition
- FAIL extraction if required fields are missing
- FAIL if field types don't match schema
- Do NOT proceed with incomplete extractions

**Numeric Preservation Check**:
- Count numeric values in source document
- Verify at least 95% are present in YAML
- Flag any metrics without target values

**List Completeness Check**:
- For each major list in source, count items
- Verify YAML has same count
- Flag any truncated lists

**Timeline Check**:
- Verify all phase timelines are extracted
- Verify all duration estimates are present
- Verify all deadlines are captured

**Technology Check**:
- Verify version numbers are preserved
- Verify all named technologies are listed
- Verify feature variants are captured

**Business Rules Check (PRD only)**:
- Count BR-XXX patterns in source document
- Verify same count in extracted business_rules array
- Flag any missing rule IDs
- Verify enforcement locations are populated

**State Machine Check (PRD only)**:
- Verify all entity states mentioned are captured
- Verify all transitions have from/to/trigger
- Flag orphan states (states not reachable via transitions)
- Verify side effects are documented

**Entity Cross-Reference Check (PRD only)**:
- Build list of entities mentioned in features.touched_entities
- Build list of entities in data_model.entities
- FAIL if any touched entity is not in data_model
- Report: "Entity 'X' referenced in feature 'Y' but missing from data_model"

**Acceptance Criteria Check (PRD only)**:
- Count features in p0_must_have, p1_should_have, p2_nice_to_have
- Verify each feature has at least 1 acceptance criterion
- Flag features with empty acceptance_criteria arrays

**Completeness Metrics Report**:
```
COMPLETENESS METRICS
====================
Business Rules: {source_count} found → {yaml_count} extracted
State Machines: {expected_count} entities → {yaml_count} machines
Acceptance Criteria: {feature_count} features → {with_criteria} have criteria
Entity Coverage: {referenced_count} referenced → {defined_count} defined
Edge Cases: {yaml_count} documented
Integration Tests: {yaml_count} scenarios
```

**Validation Output**:
```
EXTRACTION VALIDATION REPORT
============================
Document: {filename}
Category: {category}
Mode: {extraction_mode}

Schema Validation: PASS/FAIL
  - Required fields: {present}/{total}
  - Type mismatches: {count}

Numeric Values: {source_count} found → {yaml_count} extracted ({percentage}%)
List Items: {source_lists} → {yaml_lists} (100% required)
Timelines: {timeline_count} captured
Technologies: {tech_count} with versions

PRD-Specific Checks (if applicable):
  Business Rules: {source_br_count} → {yaml_br_count} ({status})
  State Machines: {machine_count} complete ({status})
  Entity Cross-Reference: {status}
    - Missing entities: [list if any]
  Acceptance Criteria: {with_criteria}/{feature_count} features ({percentage}%)

Status: PASS/FAIL
Issues: [list any gaps]
Blocking Issues: [issues that MUST be fixed]
```

**FAIL Conditions** (extraction marked incomplete):
1. Schema required fields missing
2. Less than 90% of business rules extracted
3. Any entity referenced but not defined
4. Any feature missing acceptance criteria
5. State machines missing transitions

**Internal Consistency Check (PRD only)**:
After extraction, verify terminology is consistent across sections:

1. **Term Consistency**:
   - Extract key terms from glossary
   - Verify same terms used in features, acceptance criteria, state machines
   - Flag mismatches (e.g., "Provenance" vs "Output Quality")

2. **Cross-Section Validation**:
   - Terms defined in glossary should match usage in features
   - Entity names in data_model should match touched_entities in features
   - State names in state_machines should match references in business_rules
   - Dimension names in trust/scoring sections should be consistent

3. **Consistency Report**:
```
INTERNAL CONSISTENCY CHECK
==========================
Term Matches: {matched}/{total}
Mismatches Found:
  - "{term_a}" in {section_a} vs "{term_b}" in {section_b}
  - ...

Recommendation: Use "{canonical_term}" consistently (from {authoritative_section})
```

4. **Auto-Correction Prompt**:
   When inconsistency detected, prompt:
   - "Found inconsistent terminology: '{term_a}' vs '{term_b}'"
   - "Authoritative source (glossary/schema) uses: '{canonical}'"
   - "Apply correction? [Y/n]"

### Phase 4: Generate handoff-manifest.yaml

**Schema Reference**: `project/schemas/handoff-manifest.schema.yaml`

**Manifest Structure**:
```yaml
version: "2.0.0"
generated_at: "<ISO 8601 timestamp>"
source_directory: "documents/foundations/"
output_directory: ".context/structured/"

documents:
  prd:
    source: "documents/foundations/<matched_file>"
    checksum: "<sha256>"
    structured_path: ".context/structured/prd.yaml"
    word_count: <number>
    status: "present"
    extraction_status: "complete"
  # ... other categories

validation:
  required_present: ["prd", "vision"]
  advisable_present: ["icp", "brand", "marketing"]
  missing_required: []
  missing_advisable: []
  extraction_complete: true

extraction:
  approach: "structured_yaml"
  schemas_used:
    - "foundation-prd.schema.yaml"
    - "foundation-vision.schema.yaml"
    - "foundation-roadmap.schema.yaml"
    - "foundation-icp.schema.yaml"
    - "foundation-brand.schema.yaml"
    - "foundation-marketing.schema.yaml"
    - "foundation-pricing.schema.yaml"
```

### Phase 5: Validate Completeness

**Required Documents** (must have):
- prd (PRD, requirements, or product-requirements)
- vision (vision-mission, vision, or strategic-plan)

**Advisable Documents** (should have):
- roadmap (strategic-roadmap, roadmap, or development-plan)
- icp (client-success-blueprint, icp, or personas)
- brand (brand-style-guidelines, brand, or style-guide)
- marketing (marketing-bible, marketing, or positioning)
- pricing (pricing-strategy, pricing, or pricing-tiers)

**Extraction Validation**:
For each extracted YAML, verify:
- Required schema fields are populated
- No placeholder or empty values
- Actionable data exists for agents

**Output Validation Report**:
```
FOUNDATIONS INITIALIZATION COMPLETE
===================================

Documents Found: X/5

Required (MUST have):
  [x] prd: Product Requirements Document.md (checksum: abc123...)
  [x] vision: Vision and Mission.md (checksum: def456...)

Advisable (SHOULD have):
  [x] icp: Client Success Blueprint.md (checksum: ghi789...)
  [x] brand: Brand Style Guide.md (checksum: jkl012...)
  [x] marketing: Marketing Bible.md (checksum: mno345...)

Structured Extraction:
  .context/structured/prd.yaml - COMPLETE
    ✓ product: name, tagline, type
    ✓ features: 5 P0 features extracted (all with acceptance criteria)
    ✓ tech_stack: complete
    ✓ success_metrics: 4 metrics defined
    ✓ glossary: 14 terms defined
    ✓ state_machines: 3 machines (Subscription, Opportunity, Product)
    ✓ critical_journeys: 13 end-to-end flows
    ✓ edge_cases: 44 scenarios documented
    ✓ business_rules: 30 rules (BR-001 to BR-030)
    ✓ integration_tests: 23 scenarios
    ✓ data_model: all entities cross-referenced
    ✓ success_criteria_by_tier: all tiers covered
    ✓ additional_compliance: privacy and DPA requirements

  .context/structured/vision.yaml - COMPLETE
    ✓ vision: statement and elaboration
    ✓ mission: statement and elaboration
    ✓ goals: year_1, year_3, year_5 defined

  .context/structured/roadmap.yaml - COMPLETE
    ✓ mvp.development_timeline: 4 phases extracted
    ✓ deliverables_list: acceptance criteria for all weeks
    ✓ strategic_milestones: success_criteria arrays expanded
    ✓ revenue_projections: year_1, year_3, year_5 defined

  .context/structured/icp.yaml - COMPLETE
    ✓ personas: 4 personas extracted
    ✓ pain_points: categorized by severity
    ✓ jobs_to_be_done: 6 jobs defined

  .context/structured/brand.yaml - COMPLETE
    ✓ colors: primary, secondary, neutrals (12 shades), functional
    ✓ typography: primary, scale, weights
    ✓ components: buttons, cards, inputs
    ✓ shadows: 6 elevation levels with usage guide
    ✓ animations: durations, easings, presets
    ✓ breakpoints: 6 responsive breakpoints

  .context/structured/marketing.yaml - COMPLETE
    ✓ positioning: tagline, one_liner
    ✓ messaging: value props, differentiation
    ✓ channels: primary and secondary defined

  .context/structured/pricing.yaml - COMPLETE
    ✓ philosophy: positioning, promise, principles
    ✓ tiers: 4 tiers with Marketing Physics
    ✓ feature_breakdown: core + tier-exclusive
    ✓ value_ladder: progression and transitions
    ✓ competitive_comparison: alternatives vs your solution
    ✓ upgrade_triggers: signals for each transition

Manifest: handoff-manifest.yaml

Status: READY
```

---

## SUBCOMMAND: status

**Show current state of all documents**:

```bash
# Check for manifest
if [ -f handoff-manifest.yaml ]; then
  # Parse and display status
else
  echo "No manifest found. Run '/foundations init' first."
fi
```

**Output Format**:
```
FOUNDATIONS STATUS
==================

| Category  | Document                        | Checksum   | Extracted  | Modified |
|-----------|---------------------------------|------------|------------|----------|
| prd       | Product Requirements Doc.md     | abc123...  | complete   | no       |
| vision    | Vision and Mission.md           | def456...  | complete   | no       |
| icp       | Client Success Blueprint.md     | ghi789...  | complete   | YES      |
| brand     | Brand Style Guide.md            | jkl012...  | complete   | no       |
| marketing | Marketing Bible.md              | mno345...  | complete   | no       |

Modified documents detected: 1
Run '/foundations refresh' to update extractions.

Last initialized: 2026-01-01T10:30:00Z
```

**Modified Detection**:
```bash
# For each document in manifest
current_checksum=$(sha256sum "$source_path" | cut -d' ' -f1)
if [ "$current_checksum" != "$manifest_checksum" ]; then
  echo "MODIFIED"
fi
```

---

## SUBCOMMAND: refresh

**Sync foundation documents - detect new, modified, and removed documents**

This command performs a full sync between your `documents/foundations/` directory and the extracted YAML files. Use this after:
- Editing any foundation document
- Adding a new foundation document (e.g., adding `pricing-strategy.md`)
- Removing a foundation document
- Receiving updated documents from BOS-AI

### Step 1: Load Manifest
```bash
if [ ! -f handoff-manifest.yaml ]; then
  echo "Error: No manifest found. Run '/foundations init' first."
  exit 1
fi
```

### Step 2: Scan Directory (Full Sync)

**Scan `documents/foundations/`** using the same category matching as `init`:

| Category | Priority 1 | Priority 2 | Priority 3 |
|----------|------------|------------|------------|
| **prd** | prd.md | requirements.md | product-requirements.md |
| **vision** | vision-mission.md | vision.md | strategic-plan.md |
| **roadmap** | strategic-roadmap.md | roadmap.md | development-plan.md |
| **icp** | client-success-blueprint.md | icp.md | personas.md |
| **brand** | brand-style-guidelines.md | brand.md | style-guide.md |
| **marketing** | marketing-bible.md | marketing.md | positioning.md |
| **pricing** | pricing-strategy.md | pricing.md | pricing-tiers.md |

### Step 3: Compare and Classify

For each document found in directory:
1. Calculate current SHA256 checksum
2. Compare to manifest entry (if exists)

**Classification Logic**:

| Condition | Classification | Action |
|-----------|----------------|--------|
| In manifest, checksum matches | **UNCHANGED** | Skip (no action needed) |
| In manifest, checksum differs | **MODIFIED** | Re-extract to YAML |
| In directory, NOT in manifest | **NEW** | Extract to YAML, add to manifest |
| In manifest, NOT in directory | **REMOVED** | Warn user, mark in manifest |

### Step 4: Process Documents

**For MODIFIED documents**:
1. Re-extract using appropriate schema and extraction mode
2. Overwrite existing `.context/structured/{category}.yaml`
3. Update checksum in manifest
4. Log extraction validation

**For NEW documents**:
1. Extract using appropriate schema and extraction mode
2. Create new `.context/structured/{category}.yaml`
3. Add entry to manifest with checksum
4. Log extraction validation

**For REMOVED documents**:
1. Keep existing YAML (don't delete - user may have removed accidentally)
2. Mark as `status: "source_removed"` in manifest
3. Warn user in output

### Step 5: Update Manifest

Update `handoff-manifest.yaml`:
- Update `generated_at` timestamp
- Update checksums for modified documents
- Add entries for new documents
- Mark removed documents

### Step 6: Report

```
FOUNDATIONS REFRESH COMPLETE
============================

Directory scanned: documents/foundations/
Documents found: 7

Status Summary:
  Unchanged: 4 (skipped - checksums match)
  Modified:  1 (re-extracted)
  New:       2 (extracted and added)
  Removed:   0

Modified Documents:
  ✓ prd: Product Requirements Document.md
    → .context/structured/prd.yaml updated

New Documents:
  ✓ pricing: Pricing Strategy.md
    → .context/structured/pricing.yaml created
  ✓ roadmap: Strategic Roadmap.md
    → .context/structured/roadmap.yaml created

Extraction Validation:
  prd.yaml      - COMPLETE (15 features, 8 metrics)
  pricing.yaml  - COMPLETE (4 tiers, Marketing Physics)
  roadmap.yaml  - COMPLETE (4 phases, deliverables_list)

Manifest updated: handoff-manifest.yaml
Last sync: 2026-01-05T19:30:00Z
```

### Common Workflows

**After editing a document**:
```bash
# Edit your PRD
vim documents/foundations/prd.md

# Sync changes
/foundations refresh
# → Detects PRD modified, re-extracts to prd.yaml
```

**After adding a new document**:
```bash
# Add pricing strategy from BOS-AI
cp ~/BOS-AI-output/pricing-strategy.md documents/foundations/

# Sync to pick up new document
/foundations refresh
# → Detects new pricing document, extracts to pricing.yaml
```

**After receiving updated documents from BOS-AI**:
```bash
# Copy all updated documents
cp ~/BOS-AI-output/*.md documents/foundations/

# Single command syncs everything
/foundations refresh
# → Detects all changes, only re-extracts what changed
```

---

## SUBCOMMAND: validate

**Check document and extraction completeness**:

### Validation Rules

**Required Documents** (error if missing):
- prd: Must have at least one of [prd.md, requirements.md, product-requirements.md]
- vision: Must have at least one of [vision-mission.md, vision.md, strategic-plan.md]

**Advisable Documents** (warning if missing):
- icp: Should have at least one of [client-success-blueprint.md, icp.md, personas.md]
- brand: Should have at least one of [brand-style-guidelines.md, brand.md, style-guide.md]
- marketing: Should have at least one of [marketing-bible.md, marketing.md, positioning.md]
- pricing: Should have at least one of [pricing-strategy.md, pricing.md, pricing-tiers.md]

**Extraction Validation**:
For each extracted YAML:
1. Parse YAML and verify valid syntax
2. Check required schema fields are populated
3. Check for completeness (no empty values where data should exist)
4. Verify data is actionable (can agent use this to make decisions?)

**Output Format**:
```
FOUNDATIONS VALIDATION
======================

Required Documents:
  [PASS] prd: Product Requirements Document.md found
  [PASS] vision: Vision and Mission.md found

Advisable Documents:
  [PASS] icp: Client Success Blueprint.md found
  [WARN] brand: No brand document found
         Suggested: Add brand-style-guidelines.md, brand.md, or style-guide.md
  [PASS] marketing: Marketing Bible.md found

Extraction Integrity:
  [PASS] prd.yaml: All required fields populated
  [PASS] vision.yaml: All required fields populated
  [PASS] icp.yaml: All required fields populated
  [WARN] marketing.yaml: Missing channels.primary data

Checksum Status:
  [PASS] All checksums valid (no modifications)
  [WARN] icp.yaml outdated (source modified)

======================
Result: VALID (2 warnings)

Recommendations:
1. Add a brand guidelines document for complete context
2. Run '/foundations refresh' to update icp extraction
3. Add primary channels to marketing document
```

---

## FILE STRUCTURE CREATED

After `/foundations init`:

```
project-root/
├── documents/
│   └── foundations/
│       ├── Product Requirements Document.md
│       ├── Vision and Mission.md
│       ├── Strategic Roadmap.md
│       ├── Client Success Blueprint.md
│       ├── Brand Style Guide.md
│       ├── Marketing Bible.md
│       └── Pricing Strategy.md
├── .context/
│   └── structured/
│       ├── prd.yaml          # Full PRD extraction
│       ├── vision.yaml       # Full vision/mission extraction
│       ├── roadmap.yaml      # Full roadmap with deliverables_list
│       ├── icp.yaml          # Full ICP extraction
│       ├── brand.yaml        # Full brand extraction (neutrals, shadows, animations, breakpoints)
│       ├── marketing.yaml    # Full marketing extraction
│       └── pricing.yaml      # Full pricing strategy with Marketing Physics
└── handoff-manifest.yaml
```

---

## ERROR HANDLING

### Directory Not Found
```
Error: documents/foundations/ directory not found.

Create the directory and add your BOS-AI foundation documents:
  mkdir -p documents/foundations/

Required documents:
  - prd.md (or requirements.md, product-requirements.md)
  - vision-mission.md (or vision.md, strategic-plan.md)

Advisable documents:
  - client-success-blueprint.md (or icp.md, personas.md)
  - brand-style-guidelines.md (or brand.md, style-guide.md)
  - marketing-bible.md (or marketing.md, positioning.md)
```

### Missing Required Documents
```
Error: Missing required foundation documents.

Required (MISSING):
  [ ] prd: No PRD document found
      Expected: prd.md, requirements.md, or product-requirements.md

Cannot proceed without required documents.
Add the missing files and run '/foundations init' again.
```

### Extraction Validation Failed
```
Error: Extraction validation failed for brand.yaml

Missing required data:
  - colors.primary: No colors extracted
  - typography.primary.font: No font specified

The source document may be missing this information.
Check documents/foundations/brand-style-guidelines.md and ensure it contains:
  - Color palette with hex values
  - Primary font family
```

---

## INTEGRATION WITH AGENT-11

### Context Loading for Agents

Agents load foundation context via selective YAML loading:

```yaml
# In agent delegation, load relevant sections:
context:
  prd:
    - features.p0_must_have
    - tech_stack
    - success_metrics
  brand:
    - colors
    - typography
    - components.buttons
```

### Coordinator Integration

The coordinator should:
1. Check for `handoff-manifest.yaml` at mission start
2. Load relevant YAML sections based on mission type and agent needs
3. Pass structured data directly to agents (no parsing required)

**Mission-to-Context Mapping**:
| Mission Type | Context Needed |
|--------------|----------------|
| build/mvp | prd.features, prd.tech_stack, brand.colors, brand.components, pricing.tiers |
| design-review | brand.*, icp.personas |
| marketing | marketing.*, vision.value_proposition, pricing.product_level_marketing_physics |
| strategy | vision.*, icp.pain_points, prd.success_metrics, pricing.philosophy |
| payments | pricing.*, prd.tech_stack.payments |

### Agent Context Requirements

Each agent profile should declare what context it needs:

```yaml
# In agent profile
context_requirements:
  required:
    - "prd.features"
    - "prd.tech_stack"
  optional:
    - "brand.components"
  exclude:
    - "marketing.*"  # Not needed for this agent
```

---

## USAGE EXAMPLES

```bash
# Initialize foundations for a new project
/foundations init

# Check current status
/foundations status

# Update after editing documents
/foundations refresh

# Validate before major development
/foundations validate
```

---

## NOTES

- Structured YAML preserves 100% of actionable information
- Schemas define what data agents need - extraction fills the schema
- Checksums use SHA256 for reliable change detection
- The manifest is the source of truth for document state
- Always validate after major document updates
- Agents parse YAML directly - no NLP interpretation needed

## MIGRATION FROM v1.0

If you have existing `.context/summaries/` from the token-budget approach:
1. Run `/foundations init` to create new structured extractions
2. The new system creates `.context/structured/`
3. Old summaries can be archived or deleted
4. Update any custom scripts to read from `.context/structured/`
