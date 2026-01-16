---
name: bootstrap
description: Transform foundation YAML extracts into structured project-plan.md with interactive mode selection
arguments:
  vision_file:
    type: string
    required: false
    description: Optional path to vision document (overrides summary)
flags:
  --mode:
    type: string
    values: [auto, engaged, preview]
    description: Skip mode selection and use specified mode directly
  --type:
    type: string
    default: auto
    values: [auto, saas-mvp, saas-full, api]
    description: Project type (auto-detected if not specified)
  --phases:
    type: integer
    default: 4
    min: 2
    max: 6
    description: Number of phases to plan
model: opus
---

# /bootstrap Command

## PURPOSE

Transform foundation YAML extracts (created by `/foundations init`) into a valid, schema-compliant `project-plan.md` with rolling wave planning detail.

**Why This Matters**: Foundation documents contain rich context but lack executable structure. Bootstrap bridges the gap between "what we want to build" and "how we'll build it" by generating a phased execution plan using machine-readable YAML extracts.

## MODE SELECTION (First Step)

When you run `/bootstrap` without flags, you'll be asked to choose a mode:

```
┌─────────────────────────────────────────────────────────────────┐
│ 🏗️ Bootstrap: Project Plan Generation                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ How would you like to proceed?                                  │
│                                                                 │
│ ○ Auto Mode (Recommended for complete, validated PRDs)         │
│   Generates plan immediately from your foundations             │
│   Fast, no questions asked                                     │
│                                                                 │
│ ○ Engaged Mode (Recommended for first-time users)              │
│   Reviews PRD assumptions with you first                       │
│   Validates tech stack, phases, priorities                     │
│   Decision checkpoints before generating                       │
│                                                                 │
│ ○ Preview Mode                                                  │
│   Shows what would be generated without writing files          │
│   Good for reviewing before committing                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Skip mode selection**: Use `--mode` flag to go directly to a mode:
```bash
/bootstrap --mode auto      # Immediate generation
/bootstrap --mode engaged   # Interactive consultation
/bootstrap --mode preview   # Dry run preview
```

## PREREQUISITES

Before running `/bootstrap`, ensure:

1. **`/foundations init` has completed successfully**
   - `.context/structured/` directory exists
   - `handoff-manifest.yaml` exists with checksums

2. **Required YAML extracts are present**:
   - `.context/structured/prd.yaml` (REQUIRED)
   - `.context/structured/vision.yaml` (REQUIRED for saas-* types)
   - `.context/structured/roadmap.yaml` (optional, enhances phase planning)
   - `.context/structured/icp.yaml` (optional, enhances user story quality)

3. **No conflicting project-plan.md exists**
   - If exists, command will prompt for confirmation before overwriting

## USAGE EXAMPLES

```bash
/bootstrap                              # Interactive mode selection
/bootstrap --mode auto                  # Skip to auto mode
/bootstrap --mode engaged               # Skip to engaged mode
/bootstrap --mode preview               # Skip to preview mode
/bootstrap --mode auto --type saas-mvp  # Auto mode with explicit type
/bootstrap ideation/updated-vision.md   # With vision override
```

---

## ENGAGED MODE (Interactive Consultation)

Engaged Mode walks you through your PRD assumptions before generating a plan. This is recommended for:
- First-time AGENT-11 users
- Complex projects with many features
- PRDs that haven't been validated
- When you want to catch issues before they become problems

### Checkpoint 1: Foundation Summary Review

```
┌─────────────────────────────────────────────────────────────────┐
│ 📋 Foundation Summary                                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ From your PRD, I extracted:                                     │
│                                                                 │
│ Product: SoloPilot                                              │
│ Type: SaaS Application                                          │
│ Target: Solo founders managing multiple products                │
│                                                                 │
│ P0 Features (Must Have):                                        │
│   1. User Authentication (Clerk)                                │
│   2. Prompt Library Management                                  │
│   3. AI Model Integration (GPT-4, Claude)                       │
│   4. Usage Tracking Dashboard                                   │
│   5. Stripe Subscription Billing                                │
│                                                                 │
│ Does this summary look correct? [Yes / Edit / Cancel]           │
└─────────────────────────────────────────────────────────────────┘
```

**If "Edit"**: Opens clarification questions for each concern.

### Checkpoint 2: Tech Stack Validation

```
┌─────────────────────────────────────────────────────────────────┐
│ 🔧 Tech Stack Validation                                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ Your PRD specifies:                                             │
│                                                                 │
│ Frontend: Next.js (version not specified)                       │
│   → Assuming Next.js 14 with App Router. Correct?               │
│                                                                 │
│ Database: Supabase                                              │
│   → Will use Row Level Security (RLS). Correct?                 │
│                                                                 │
│ Auth: Clerk                                                     │
│   → Social login + email/password. Correct?                     │
│                                                                 │
│ Payments: Stripe                                                │
│   → Subscription model with usage-based add-ons. Correct?       │
│                                                                 │
│ AI Models: "GPT-4 and Claude"                                   │
│   → Which specific models?                                      │
│     [ ] GPT-4 (standard)                                        │
│     [ ] GPT-4 Turbo                                             │
│     [ ] GPT-4o                                                  │
│     [ ] Claude 3.5 Sonnet                                       │
│     [ ] Claude 3 Opus                                           │
│                                                                 │
│ [Confirm All] [Edit Selections] [Cancel]                        │
└─────────────────────────────────────────────────────────────────┘
```

### Checkpoint 3: Priority Validation

```
┌─────────────────────────────────────────────────────────────────┐
│ 🎯 Feature Priority Check                                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ I found 12 features in your PRD. Here's my priority assessment: │
│                                                                 │
│ P0 (MVP - Must ship):                                           │
│   ✓ Authentication                                              │
│   ✓ Prompt CRUD                                                 │
│   ✓ Basic AI integration                                        │
│   ✓ Stripe checkout                                             │
│   ? Usage tracking - Is this P0 or can it wait?                 │
│                                                                 │
│ P1 (Should have):                                               │
│   ✓ Team collaboration                                          │
│   ✓ Prompt versioning                                           │
│   ? Analytics dashboard - Is this P1 or P2?                     │
│                                                                 │
│ P2 (Nice to have):                                              │
│   ✓ Export features                                             │
│   ✓ API access                                                  │
│                                                                 │
│ Questions marked with ? need your input.                        │
│                                                                 │
│ [Answer Questions] [Accept As-Is] [Cancel]                      │
└─────────────────────────────────────────────────────────────────┘
```

### Checkpoint 4: Phase Structure

```
┌─────────────────────────────────────────────────────────────────┐
│ 📅 Phase Structure                                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ Based on your PRD timeline and feature count, I suggest:        │
│                                                                 │
│ Phase 1: Foundation (Weeks 1-3)                                 │
│   - Project setup, auth, database schema                        │
│   - 8 tasks, ~40 hours estimated                                │
│                                                                 │
│ Phase 2: Core Features (Weeks 4-6)                              │
│   - Prompt management, AI integration                           │
│   - 10 tasks, ~50 hours estimated                               │
│                                                                 │
│ Phase 3: Monetization (Weeks 7-8)                               │
│   - Stripe integration, usage tracking                          │
│   - 6 tasks, ~30 hours estimated                                │
│                                                                 │
│ Phase 4: Polish & Launch (Weeks 9-10)                           │
│   - Testing, docs, deployment                                   │
│   - 5 tasks, ~25 hours estimated                                │
│                                                                 │
│ Total: 4 phases, 29 tasks, ~145 hours                           │
│                                                                 │
│ Does this structure work for you?                               │
│ [Yes, Generate Plan] [Adjust Phases] [Cancel]                   │
└─────────────────────────────────────────────────────────────────┘
```

### Checkpoint 5: Final Confirmation

```
┌─────────────────────────────────────────────────────────────────┐
│ ✅ Ready to Generate                                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ Summary of decisions:                                           │
│                                                                 │
│ Project: SoloPilot (saas-mvp)                                   │
│ Stack: Next.js 14, Supabase, Clerk, Stripe                      │
│ AI: GPT-4o, Claude 3.5 Sonnet                                   │
│ Features: 5 P0, 3 P1, 2 P2                                      │
│ Phases: 4 (10 weeks total)                                      │
│ Quality Gates: build, test, lint                                │
│                                                                 │
│ Files to create:                                                │
│   - project-plan.md (~850 lines)                                │
│   - .context/phase-1-context.yaml                               │
│                                                                 │
│ [Generate Plan] [Start Over] [Cancel]                           │
└─────────────────────────────────────────────────────────────────┘
```

---

## AUTO MODE (Immediate Generation)

Auto Mode generates the plan immediately without consultation. Use this when:
- Your PRD has been thoroughly reviewed
- You've used `/bootstrap` before and know what to expect
- You're regenerating after minor PRD updates

**What happens**:
1. Validates prerequisites
2. Loads foundation YAML extracts
3. Infers project type
4. Generates plan immediately
5. Writes files

**No questions asked** - the PRD is treated as source of truth.

---

## PREVIEW MODE (Dry Run)

Preview Mode shows exactly what would be generated without writing any files. Use this to:
- Review the plan structure before committing
- Compare what would change after PRD updates
- Validate that extraction worked correctly

**Output**: Full plan content displayed in terminal, no files written.

---

## EXECUTION FLOW

### Phase 1: Prerequisite Validation

```yaml
validation_checks:
  - check: handoff-manifest.yaml exists
    fail_action: "Run /foundations init first"

  - check: .context/structured/prd.yaml exists
    fail_action: "PRD extraction missing - run /foundations init with PRD"

  - check: .context/structured/vision.yaml exists
    fail_action: "Vision extraction missing - required for project planning"

  - check: .context/structured/roadmap.yaml exists (optional)
    fail_action: "Roadmap extraction missing - recommended for phase planning"

  - check: project-plan.md does not exist OR user confirms overwrite
    fail_action: "Existing plan found - confirm overwrite or backup first"
```

### Phase 2: Context Loading

**Load Foundation YAML Extracts**:
```
Read .context/structured/prd.yaml
Read .context/structured/vision.yaml
Read .context/structured/roadmap.yaml (if exists)
Read .context/structured/icp.yaml (if exists)
Read handoff-manifest.yaml for checksums
```

**YAML Extract Structure**:
Each YAML extract provides machine-readable structured data:
```yaml
# Example: prd.yaml structure
metadata:
  source_file: foundations/prd.md
  checksum: sha256-xxx
  extracted: ISO-8601 timestamp

product:
  name: "Product Name"
  description: "..."

features:
  p0_must_have: [...]
  p1_should_have: [...]

tech_stack:
  frontend: {...}
  backend: {...}
```

### Phase 3: Project Type Inference

If `--type auto` (default), infer from PRD YAML extract:

```yaml
type_inference_rules:
  saas-mvp:
    conditions:
      - mvp_feature_count < 5
      - business_model in [subscription, freemium, one-time]
      - no enterprise_requirements
      - timeline <= 12 weeks
    quality_gates: [build, test, lint]

  saas-full:
    conditions:
      - mvp_feature_count >= 5 OR enterprise_requirements present
      - multi-tenant OR team features
      - compliance_requirements mentioned
    quality_gates: [build, test, lint, security, a11y]

  api:
    conditions:
      - api-first OR headless mentioned
      - no frontend requirements OR frontend_optional
      - integration_focus
    quality_gates: [build, test, lint, api-contract]
```

**Inference Prompt**:
```
Based on the PRD YAML extract, determine the project type:

PRD YAML:
{prd_yaml_content}

Analyze for:
1. Number of MVP features mentioned
2. Business model (subscription/freemium/enterprise)
3. Frontend requirements (full app, minimal, none)
4. Compliance/security requirements
5. Timeline constraints

Return:
- inferred_type: saas-mvp | saas-full | api
- confidence: high | medium | low
- reasoning: brief explanation
```

### Phase 4: Plan Generation

**Rolling Wave Planning Principle**:
- **Phase 1**: Fully detailed (tasks, acceptance criteria, dependencies)
- **Phase 2**: Outlined (key milestones, known dependencies)
- **Phase 3+**: High-level (objectives and rough scope)

**Generation Prompt**:
```
Generate a project plan following this schema and rolling wave principle.

FOUNDATION CONTEXT:

VISION YAML:
{vision_yaml_content}

PRD YAML:
{prd_yaml_content}

ROADMAP YAML (if available):
{roadmap_yaml_content}

ICP YAML (if available):
{icp_yaml_content}

PROJECT PARAMETERS:
- Type: {project_type}
- Phase Count: {phase_count}
- Quality Gates: {quality_gates}

GENERATE project-plan.md following this structure:

```yaml
# Project Plan
version: "1.0"
project_type: {project_type}
generated_from:
  prd_checksum: {prd_checksum}
  vision_checksum: {vision_checksum}
  timestamp: {iso_timestamp}

meta:
  name: [Extract from vision/PRD]
  description: [1-2 sentence summary]
  repository: [Leave as TBD if not specified]
  created: {iso_date}
  last_updated: {iso_timestamp}

objectives:
  primary: [Main goal from vision]
  success_metrics:
    - metric: [Quantifiable metric]
      target: [Specific target]
      measurement: [How to measure]

phases:
  - id: phase-1
    name: "Foundation & Core Setup"
    status: not_started
    objectives:
      - [Specific Phase 1 objectives]
    tasks:
      - id: task-1.1
        name: [Specific task]
        agent: [architect|developer|designer|etc]
        status: pending
        priority: p0
        acceptance_criteria:
          - [Specific, testable criterion]
          - [Another criterion]
        dependencies: []
        estimated_effort: [small|medium|large]
      # Continue with detailed tasks...
    quality_gates:
      {quality_gates_for_type}
    deliverables:
      - [Specific deliverable]

  - id: phase-2
    name: "Core Features"
    status: not_started
    objectives:
      - [Phase 2 objectives - less detailed]
    tasks:
      - id: task-2.1
        name: [Key milestone task]
        agent: developer
        status: pending
        priority: p0
        # Note: Acceptance criteria added when phase begins
    quality_gates:
      {quality_gates_for_type}

  # Phase 3+ are high-level only
  - id: phase-{n}
    name: [Phase name]
    status: not_started
    objectives:
      - [High-level objective]
    # Tasks defined when phase approaches
```

CRITICAL REQUIREMENTS:
1. Phase 1 MUST have 5-10 detailed tasks with acceptance criteria
2. All task IDs must be unique and follow pattern: task-{phase}.{seq}
3. Agent assignments must be valid: architect, developer, designer, tester, operator, strategist, analyst
4. Priority must be: p0 (critical), p1 (high), p2 (medium), p3 (low)
5. Quality gates must match project type defaults
6. Objectives must be derived from foundation documents, not invented
```

### Phase 5: Phase Context Generation

Generate detailed context file for Phase 1:

**Context Generation Prompt**:
```
Generate phase-1-context.yaml for the first phase.

PHASE 1 FROM PLAN:
{phase_1_content}

PROJECT CONTEXT:
- Type: {project_type}
- Name: {project_name}

Generate .context/phase-1-context.yaml:

```yaml
phase_id: phase-1
phase_name: "Foundation & Core Setup"
status: not_started

context:
  summary: |
    [2-3 sentence summary of phase purpose]

  key_decisions:
    - decision: [Important decision made in planning]
      rationale: [Why this decision]
      alternatives_considered: [What else was considered]

  technical_context:
    stack_decisions: [From architecture/PRD]
    patterns: [Patterns to follow]
    constraints: [Technical constraints]

  dependencies:
    external: [External services, APIs]
    internal: [Internal dependencies]

current_focus:
  active_task: null  # Set when phase begins
  blocked_tasks: []
  completed_tasks: []

handoff_notes:
  from_previous_phase: null  # First phase
  for_next_phase: []  # Populated during execution

quality_requirements:
  gates: {quality_gates}
  acceptance_bar: [What "done" means for this phase]
```
```

### Phase 6: Output Generation

**Write Files**:
1. `project-plan.md` - Main project plan (project root)
2. `.context/phase-1-context.yaml` - Phase 1 execution context

**Update Manifest**:
Add to `handoff-manifest.yaml`:
```yaml
generated_plans:
  project_plan:
    path: project-plan.md
    generated: "ISO-8601"
    from_extracts:
      - prd.yaml
      - vision.yaml
      - roadmap.yaml
    project_type: saas-mvp
```

## ERROR HANDLING

### Missing Prerequisites

```
Error: Foundation YAML extracts not found

Bootstrap requires foundation YAML extracts to generate a project plan.

Missing:
- .context/structured/prd.yaml
- .context/structured/vision.yaml

Run first:
  /foundations init

Or specify documents directly:
  /foundations init --prd foundations/prd.md --vision foundations/vision.md
```

### Existing Plan Conflict

```
Warning: project-plan.md already exists

Options:
1. Overwrite - Replace existing plan (loses current progress)
2. Backup - Save as project-plan.md.backup, then overwrite
3. Merge - Attempt to merge with existing (experimental)
4. Cancel - Abort without changes

Recommended: Option 2 (Backup) if plan has in-progress work

Continue? [1/2/3/4]:
```

### Type Inference Uncertainty

```
Warning: Project type inference has low confidence

Inferred: saas-mvp (confidence: low)
Reasoning: PRD mentions both API-first design and user dashboard

Options:
1. Accept saas-mvp inference
2. Override to saas-full
3. Override to api
4. Provide clarification

Select option or provide context:
```

### Schema Validation Failure

```
Error: Generated plan failed schema validation

Validation errors:
- phases[0].tasks[2]: missing required field 'acceptance_criteria'
- meta.name: cannot be empty

Retrying generation with explicit constraints...
[Automatic retry with stricter prompts]
```

## EXAMPLES

### Example 1: Interactive Mode Selection (Default)

```bash
# After running /foundations init
/bootstrap
```

**Output**:
```
🏗️ Bootstrap: Project Plan Generation
======================================

Prerequisites:
  [OK] handoff-manifest.yaml found
  [OK] prd.yaml (checksum: abc123)
  [OK] vision.yaml (checksum: def456)
  [OK] roadmap.yaml (checksum: ghi789)

How would you like to proceed?

  1. Auto Mode - Generate immediately (fast, no questions)
  2. Engaged Mode - Review assumptions first (recommended for new users)
  3. Preview Mode - Show what would be generated

Select mode [1/2/3]:
```

### Example 2: Engaged Mode Flow

```bash
/bootstrap --mode engaged
```

**Output** (abbreviated - see ENGAGED MODE section for full checkpoints):
```
🏗️ Bootstrap: Engaged Mode
===========================

📋 Checkpoint 1/5: Foundation Summary
-------------------------------------
From your PRD, I extracted:

Product: SoloPilot
Type: SaaS Application
P0 Features: 5 (Auth, Prompts, AI, Tracking, Billing)

Does this look correct? [Yes/Edit/Cancel]: Yes

🔧 Checkpoint 2/5: Tech Stack
-----------------------------
Frontend: Next.js (version not specified)
  → Assuming Next.js 14 with App Router. Correct? [Y/n]: Y

Database: Supabase with RLS. Correct? [Y/n]: Y

AI Models: Your PRD says "GPT-4 and Claude"
  Which specific models? [select multiple]:
  [x] GPT-4o
  [x] Claude 3.5 Sonnet

[...continues through all 5 checkpoints...]

✅ Checkpoint 5/5: Final Confirmation
-------------------------------------
Ready to generate with your confirmed settings.

[Generate Plan] selected.

Files Created:
  [OK] project-plan.md (847 lines)
  [OK] .context/phase-1-context.yaml (92 lines)

Next: Run /coord continue to start building
```

### Example 3: Auto Mode (Skip Questions)

```bash
/bootstrap --mode auto --type saas-mvp
```

**Output**:
```
🏗️ Bootstrap: Auto Mode
========================

Prerequisites: [OK] All found

Project Analysis:
  Type: saas-mvp (explicit)
  Phases: 4
  Quality Gates: build, test, lint

Generating Phase 1 (detailed)...
  - 7 tasks with acceptance criteria

Generating Phase 2-4 (outlined)...
  - Phase 2: Core Features (4 milestones)
  - Phase 3: Polish & Testing (3 milestones)
  - Phase 4: Launch Prep (2 milestones)

Files Created:
  [OK] project-plan.md (847 lines)
  [OK] .context/phase-1-context.yaml (92 lines)

⚠️ Note: Auto mode used PRD as-is without validation.
   Run /bootstrap --mode engaged to review assumptions.
```

### Example 4: Preview Mode

```bash
/bootstrap --mode preview
```

**Output**:
```
Bootstrap: Dry Run (no files written)
=====================================

Would generate:

project-plan.md:
---
version: "1.0"
project_type: saas-mvp
...
[Full preview of plan content]
---

.context/phase-1-context.yaml:
---
phase_id: phase-1
...
[Full preview of context]
---

To generate these files, run:
  /bootstrap
```

### Example 4: With Vision Override

```bash
/bootstrap ideation/revised-vision.md --type saas-full
```

**Output**:
```
Bootstrap: Project Plan Generation
==================================

Vision Source: ideation/revised-vision.md (override)
  [OK] File exists and readable
  [OK] Generating fresh summary...

Note: Using fresh vision analysis instead of cached summary.
Cached summary will be updated after successful generation.

[Continues with normal flow...]
```

## INTEGRATION WITH OTHER COMMANDS

### Workflow Position

```
/foundations init  -->  /bootstrap  -->  /coord phase-1
     |                      |                  |
  Summarize            Generate            Execute
  Documents            Plan                Phase
```

### Prerequisites For

- `/coord phase-1` - Requires project-plan.md to exist
- `/coord build` - Uses project-plan.md for task orchestration
- `/planarchive` - Archives project-plan.md when complete

### Depends On

- `/foundations init` - Must run first to create YAML extracts
- Foundation documents in `foundations/` or specified paths

## SCHEMA COMPLIANCE

The generated `project-plan.md` MUST comply with:
- `project/schemas/project-plan.schema.yaml`

The generated `.context/phase-1-context.yaml` MUST comply with:
- `project/schemas/phase-context.schema.yaml`

**Validation is automatic** - if generation fails validation, the command will retry with stricter constraints before failing.

## QUALITY GATE TEMPLATES

### saas-mvp (minimal)
```yaml
quality_gates:
  - gate: build
    required: true
    command: "npm run build"
  - gate: test
    required: true
    command: "npm test"
    threshold: 80
  - gate: lint
    required: true
    command: "npm run lint"
```

### saas-full (comprehensive)
```yaml
quality_gates:
  - gate: build
    required: true
  - gate: test
    required: true
    threshold: 90
  - gate: lint
    required: true
  - gate: security
    required: true
    command: "npm audit --audit-level=high"
  - gate: a11y
    required: true
    command: "npm run test:a11y"
```

### api (contract-focused)
```yaml
quality_gates:
  - gate: build
    required: true
  - gate: test
    required: true
    threshold: 85
  - gate: lint
    required: true
  - gate: api-contract
    required: true
    command: "npm run validate:openapi"
```

## TROUBLESHOOTING

### Plan Quality Issues

**Problem**: Generated tasks are too vague
**Solution**: Ensure PRD summary contains specific feature requirements. Re-run `/foundations init` with more detailed PRD.

**Problem**: Wrong agent assignments
**Solution**: Override with `--type` flag to get appropriate task distribution. API projects assign more to developer, SaaS-full includes designer.

**Problem**: Missing acceptance criteria
**Solution**: Schema validation will catch this. If persistent, check that PRD summary includes testable requirements.

### Regeneration

To regenerate plan after foundation updates:

```bash
# Update YAML extracts first
/foundations refresh

# Then regenerate plan
/bootstrap
# Select option 2 (Backup) when prompted
```

---

*Bootstrap transforms strategy into structure. A good plan is the difference between building and wandering.*
