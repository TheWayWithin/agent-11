---
name: foundations
description: Manage BOS-AI foundation documents handoff - scan, validate, summarize
mode: agent
---

# /foundations Command

## PURPOSE

Manage the handoff of BOS-AI foundation documents to AGENT-11. This command scans the `documents/foundations/` directory, generates checksums, creates token-budgeted summaries, and produces a `handoff-manifest.json` for project context.

## SUBCOMMANDS

### `/foundations init`
Initialize the foundations system - scan documents, generate manifest and summaries.

### `/foundations status`
Show current state of all foundation documents with present/summary/modified status.

### `/foundations refresh`
Regenerate summaries for documents that have changed (checksum mismatch).

### `/foundations validate`
Validate that required documents are present and warn on missing advisable documents.

---

## EXECUTION PROTOCOL

### Step 1: Parse Subcommand

Extract the subcommand from the user's input:
- `init` - Full initialization
- `status` - Show status table
- `refresh` - Update changed documents
- `validate` - Check document completeness

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

### Phase 3: Create Token-Budgeted Summaries

**Create directory**: `.context/summaries/`

**Token Budget Allocation** (proportional to information density):

| Category | Token Budget | Rationale |
|----------|--------------|-----------|
| prd | 600 | Highest density - requirements, features, acceptance criteria |
| vision | 200 | Core vision, mission, strategic goals |
| icp | 200 | Client profiles, pain points, success metrics |
| brand | 100 | Brand voice, visual identity essentials |
| marketing | 100 | Positioning, key messages |

**Summary Generation Prompt Template**:
```
Create a {token_budget}-token summary of this {category} document.
Focus on extractable, actionable information for AI agents.

For PRD: Requirements, features, acceptance criteria, constraints
For Vision: Mission, goals, success metrics, strategic direction
For ICP: Target audience, pain points, needs, success criteria
For Brand: Voice, tone, visual identity, personality
For Marketing: Positioning, value propositions, key messages

Output format: Dense, structured bullet points.
```

**Save summaries to**: `.context/summaries/{category}-summary.md`

### Phase 4: Generate handoff-manifest.json

**Schema Reference**: `project/schemas/handoff-manifest.schema.yaml`

**Manifest Structure**:
```json
{
  "$schema": "./project/schemas/handoff-manifest.schema.yaml",
  "version": "1.0.0",
  "generated_at": "<ISO 8601 timestamp>",
  "source_directory": "documents/foundations/",
  "documents": {
    "prd": {
      "source": "documents/foundations/<matched_file>",
      "checksum": "<sha256>",
      "summary_path": ".context/summaries/prd-summary.md",
      "word_count": <number>,
      "status": "present"
    },
    // ... other categories
  },
  "validation": {
    "required_present": ["prd", "vision"],
    "advisable_present": ["icp", "brand", "marketing"],
    "missing_required": [],
    "missing_advisable": []
  },
  "summaries": {
    "total_tokens": 1200,
    "allocation": {
      "prd": 600,
      "vision": 200,
      "icp": 200,
      "brand": 100,
      "marketing": 100
    }
  }
}
```

### Phase 5: Validate Completeness

**Required Documents** (must have):
- prd (PRD, requirements, or product-requirements)
- vision (vision-mission, vision, or strategic-plan)

**Advisable Documents** (should have):
- icp (client-success-blueprint, icp, or personas)
- brand (brand-style-guidelines, brand, or style-guide)
- marketing (marketing-bible, marketing, or positioning)

**Output Validation Report**:
```
FOUNDATIONS INITIALIZATION COMPLETE
===================================

Documents Found: X/5

Required (MUST have):
  [x] prd: prd.md (checksum: abc123...)
  [x] vision: vision-mission.md (checksum: def456...)

Advisable (SHOULD have):
  [x] icp: client-success-blueprint.md (checksum: ghi789...)
  [ ] brand: NOT FOUND - Consider adding brand-style-guidelines.md
  [x] marketing: marketing-bible.md (checksum: jkl012...)

Summaries Generated:
  .context/summaries/prd-summary.md (600 tokens)
  .context/summaries/vision-summary.md (200 tokens)
  .context/summaries/icp-summary.md (200 tokens)
  .context/summaries/marketing-summary.md (100 tokens)

Manifest: handoff-manifest.json

Status: READY (missing 1 advisable document)
```

---

## SUBCOMMAND: status

**Show current state of all documents**:

```bash
# Check for manifest
if [ -f handoff-manifest.json ]; then
  # Parse and display status
else
  echo "No manifest found. Run '/foundations init' first."
fi
```

**Output Format**:
```
FOUNDATIONS STATUS
==================

| Category  | Document                    | Checksum   | Summary    | Modified |
|-----------|-----------------------------|------------|------------|----------|
| prd       | prd.md                      | abc123...  | present    | no       |
| vision    | vision-mission.md           | def456...  | present    | no       |
| icp       | client-success-blueprint.md | ghi789...  | present    | YES      |
| brand     | NOT FOUND                   | -          | -          | -        |
| marketing | marketing-bible.md          | jkl012...  | present    | no       |

Modified documents detected: 1
Run '/foundations refresh' to update summaries.

Last initialized: 2025-01-15T10:30:00Z
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

**Regenerate summaries for changed documents**:

### Step 1: Load Manifest
```bash
if [ ! -f handoff-manifest.json ]; then
  echo "Error: No manifest found. Run '/foundations init' first."
  exit 1
fi
```

### Step 2: Check Each Document
For each category in manifest:
1. Compare current checksum to stored checksum
2. If mismatch, add to refresh queue

### Step 3: Regenerate Summaries
For each document in refresh queue:
1. Generate new summary with token budget
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
  - prd: prd.md (checksum updated)
  - icp: client-success-blueprint.md (checksum updated)

Manifest updated: handoff-manifest.json
```

---

## SUBCOMMAND: validate

**Check document completeness without regenerating**:

### Validation Rules

**Required Documents** (error if missing):
- prd: Must have at least one of [prd.md, requirements.md, product-requirements.md]
- vision: Must have at least one of [vision-mission.md, vision.md, strategic-plan.md]

**Advisable Documents** (warning if missing):
- icp: Should have at least one of [client-success-blueprint.md, icp.md, personas.md]
- brand: Should have at least one of [brand-style-guidelines.md, brand.md, style-guide.md]
- marketing: Should have at least one of [marketing-bible.md, marketing.md, positioning.md]

**Output Format**:
```
FOUNDATIONS VALIDATION
======================

Required Documents:
  [PASS] prd: prd.md found
  [PASS] vision: vision-mission.md found

Advisable Documents:
  [PASS] icp: client-success-blueprint.md found
  [WARN] brand: No brand document found
         Suggested: Add brand-style-guidelines.md, brand.md, or style-guide.md
  [PASS] marketing: marketing-bible.md found

Summary Integrity:
  [PASS] All summaries present and checksums valid
  [WARN] icp summary outdated (source modified)

======================
Result: VALID (1 warning)

Recommendations:
1. Add a brand guidelines document for complete context
2. Run '/foundations refresh' to update icp summary
```

---

## FILE STRUCTURE CREATED

After `/foundations init`:

```
project-root/
├── documents/
│   └── foundations/
│       ├── prd.md
│       ├── vision-mission.md
│       ├── client-success-blueprint.md
│       ├── brand-style-guidelines.md
│       └── marketing-bible.md
├── .context/
│   └── summaries/
│       ├── prd-summary.md
│       ├── vision-summary.md
│       ├── icp-summary.md
│       ├── brand-summary.md
│       └── marketing-summary.md
└── handoff-manifest.json
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

### Permission Errors
```
Error: Cannot write to .context/summaries/

Check directory permissions and try again.
```

---

## INTEGRATION WITH AGENT-11

### Context Loading
Agents can load foundation context via:
```
Read handoff-manifest.json for document locations
Read .context/summaries/*.md for token-budgeted context
```

### Coordinator Integration
The coordinator should:
1. Check for `handoff-manifest.json` at mission start
2. Load relevant summaries based on mission type
3. Reference full documents when deep context needed

### Memory Integration
Store foundation insights in:
- `/memories/project/foundations.xml` - Core product context
- `/memories/lessons/` - Learnings from foundation documents

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

- Token budgets are recommendations; actual summaries may vary by +/- 10%
- Checksums use SHA256 for reliable change detection
- Summaries are regenerated entirely, not patched
- The manifest is the source of truth for document state
- Always validate after major document updates
