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

**Extraction Prompt Template**:
```
Extract structured data from this {category} document into the schema format.

CRITICAL RULES:
1. Extract ALL information - do not summarize or compress
2. Preserve exact values (colors, fonts, sizes, prices)
3. Include all items in lists (features, personas, etc.)
4. Maintain relationships and hierarchies
5. Use direct quotes where available
6. If information doesn't fit a schema field, include it in the closest logical field

Schema reference: project/schemas/foundation-{category}.schema.yaml

Output YAML that can be parsed directly by agents.
Include ALL data from the source document.
```

**Output files**: `.context/structured/{category}.yaml`

**Validation**: After extraction, verify:
- YAML is valid and parseable
- Required schema fields are populated
- No empty arrays/objects where data should exist
- Exact values preserved (especially colors, fonts, sizes)

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
