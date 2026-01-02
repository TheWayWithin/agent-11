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

| Category | Priority 1 | Priority 2 | Priority 3 |
|----------|------------|------------|------------|
| **prd** | prd.md | requirements.md | product-requirements.md |
| **vision** | vision-mission.md | vision.md | strategic-plan.md |
| **icp** | client-success-blueprint.md | icp.md | personas.md |
| **brand** | brand-style-guidelines.md | brand.md | style-guide.md |
| **marketing** | marketing-bible.md | marketing.md | positioning.md |

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
- `foundation-icp.schema.yaml`
- `foundation-brand.schema.yaml`
- `foundation-marketing.schema.yaml`

**Extraction Approach** (NOT summarization):

For each document category, extract ALL relevant data into the schema structure. Do NOT compress or summarize - transfer complete information.

### Document Type Classification

Before extraction, classify the document type to apply appropriate rules:

| Document | Type | Mode |
|----------|------|------|
| PRD | SPECIFICATION | COMPLETENESS MODE |
| Vision | STRATEGIC | SYNTHESIS MODE |
| ICP | STRUCTURED | MAPPING MODE |
| Brand | PRECISION | EXACT MODE |
| Marketing | STRATEGIC | SYNTHESIS MODE |

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

VALIDATION CHECK: Before completing, verify:
- Count of list items matches source document
- All numeric targets have values (not just descriptions)
- All timeline information is present
- All technology versions are preserved

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

**Output files**: `.context/structured/{category}.yaml`

### Post-Extraction Validation

After extraction, perform these verification checks:

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

**Validation Output**:
```
EXTRACTION VALIDATION REPORT
============================
Document: {filename}
Category: {category}
Mode: {extraction_mode}

Numeric Values: {source_count} found → {yaml_count} extracted ({percentage}%)
List Items: {source_lists} → {yaml_lists} (100% required)
Timelines: {timeline_count} captured
Technologies: {tech_count} with versions

Status: PASS/FAIL
Issues: [list any gaps]
```

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
    - "foundation-icp.schema.yaml"
    - "foundation-brand.schema.yaml"
    - "foundation-marketing.schema.yaml"
```

### Phase 5: Validate Completeness

**Required Documents** (must have):
- prd (PRD, requirements, or product-requirements)
- vision (vision-mission, vision, or strategic-plan)

**Advisable Documents** (should have):
- icp (client-success-blueprint, icp, or personas)
- brand (brand-style-guidelines, brand, or style-guide)
- marketing (marketing-bible, marketing, or positioning)

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
    ✓ features: 5 P0 features extracted
    ✓ tech_stack: complete
    ✓ success_metrics: 4 metrics defined

  .context/structured/vision.yaml - COMPLETE
    ✓ vision: statement and elaboration
    ✓ mission: statement and elaboration
    ✓ goals: year_1, year_3, year_5 defined

  .context/structured/icp.yaml - COMPLETE
    ✓ personas: 4 personas extracted
    ✓ pain_points: categorized by severity
    ✓ jobs_to_be_done: 6 jobs defined

  .context/structured/brand.yaml - COMPLETE
    ✓ colors: primary, secondary, neutrals, functional
    ✓ typography: primary, scale, weights
    ✓ components: buttons, cards, inputs

  .context/structured/marketing.yaml - COMPLETE
    ✓ positioning: tagline, one_liner
    ✓ messaging: value props, differentiation
    ✓ channels: primary and secondary defined

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

**Re-extract documents that have changed**:

### Step 1: Load Manifest
```bash
if [ ! -f handoff-manifest.yaml ]; then
  echo "Error: No manifest found. Run '/foundations init' first."
  exit 1
fi
```

### Step 2: Check Each Document
For each category in manifest:
1. Compare current checksum to stored checksum
2. If mismatch, add to refresh queue

### Step 3: Re-extract Changed Documents
For each document in refresh queue:
1. Re-extract to structured YAML using schema
2. Calculate new checksum
3. Update manifest entry
4. Update `generated_at` timestamp

### Step 4: Report
```
FOUNDATIONS REFRESH COMPLETE
============================

Documents checked: 5
Documents refreshed: 2

Refreshed:
  - prd: Product Requirements Document.md (re-extracted)
  - icp: Client Success Blueprint.md (re-extracted)

Manifest updated: handoff-manifest.yaml
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
│       ├── Client Success Blueprint.md
│       ├── Brand Style Guide.md
│       └── Marketing Bible.md
├── .context/
│   └── structured/
│       ├── prd.yaml          # Full PRD extraction
│       ├── vision.yaml       # Full vision/mission extraction
│       ├── icp.yaml          # Full ICP extraction
│       ├── brand.yaml        # Full brand extraction
│       └── marketing.yaml    # Full marketing extraction
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
| build/mvp | prd.features, prd.tech_stack, brand.colors, brand.components |
| design-review | brand.*, icp.personas |
| marketing | marketing.*, vision.value_proposition |
| strategy | vision.*, icp.pain_points, prd.success_metrics |

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
