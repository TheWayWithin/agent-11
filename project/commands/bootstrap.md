---
name: bootstrap
description: Transform foundation summaries into structured project-plan.md
arguments:
  vision_file:
    type: string
    required: false
    description: Optional path to vision document (overrides summary)
flags:
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
  --dry-run:
    type: boolean
    default: false
    description: Preview plan without writing files
model: opus
---

# /bootstrap Command

## PURPOSE

Transform foundation document summaries (created by `/foundations init`) into a valid, schema-compliant `project-plan.md` with rolling wave planning detail.

**Why This Matters**: Foundation documents contain rich context but lack executable structure. Bootstrap bridges the gap between "what we want to build" and "how we'll build it" by generating a phased execution plan.

## PREREQUISITES

Before running `/bootstrap`, ensure:

1. **`/foundations init` has completed successfully**
   - `.context/summaries/` directory exists
   - `handoff-manifest.json` exists with checksums

2. **Required summaries are present**:
   - `.context/summaries/prd-summary.md` (REQUIRED)
   - `.context/summaries/vision-summary.md` (REQUIRED for saas-* types)
   - `.context/summaries/icp-summary.md` (optional, enhances user story quality)

3. **No conflicting project-plan.md exists**
   - If exists, command will prompt for confirmation before overwriting

## SUBCOMMANDS

### Default: `/bootstrap`

Auto-detect project type and generate plan with 4 phases.

```bash
/bootstrap
```

### With Vision Override: `/bootstrap [vision_file]`

Use a specific vision document instead of cached summary.

```bash
/bootstrap ideation/updated-vision.md
```

### Explicit Type: `/bootstrap --type saas-full`

Override auto-detection for specific project type.

```bash
/bootstrap --type api --phases 3
```

### Preview Mode: `/bootstrap --dry-run`

Generate and display plan without writing files.

```bash
/bootstrap --dry-run
```

## EXECUTION FLOW

### Phase 1: Prerequisite Validation

```yaml
validation_checks:
  - check: handoff-manifest.json exists
    fail_action: "Run /foundations init first"

  - check: .context/summaries/prd-summary.md exists
    fail_action: "PRD summary missing - run /foundations init with PRD"

  - check: .context/summaries/vision-summary.md exists
    fail_action: "Vision summary missing - required for project planning"

  - check: project-plan.md does not exist OR user confirms overwrite
    fail_action: "Existing plan found - confirm overwrite or backup first"
```

### Phase 2: Context Loading

**Load Foundation Summaries**:
```
Read .context/summaries/prd-summary.md
Read .context/summaries/vision-summary.md
Read .context/summaries/icp-summary.md (if exists)
Read handoff-manifest.json for checksums
```

**Parse Summary Structure**:
Each summary follows this format:
```markdown
# [Document Type] Summary

## Source
- File: original/path.md
- Checksum: sha256-xxx
- Extracted: ISO-8601 timestamp

## Key Points
[Bullet list of critical information]

## For Planning
[Structured data relevant to project planning]
```

### Phase 3: Project Type Inference

If `--type auto` (default), infer from PRD summary:

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
Based on the PRD summary, determine the project type:

PRD SUMMARY:
{prd_summary_content}

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

VISION SUMMARY:
{vision_summary_content}

PRD SUMMARY:
{prd_summary_content}

ICP SUMMARY (if available):
{icp_summary_content}

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
Add to `handoff-manifest.json`:
```json
{
  "generated_plans": {
    "project_plan": {
      "path": "project-plan.md",
      "generated": "ISO-8601",
      "from_summaries": ["prd-summary.md", "vision-summary.md"],
      "project_type": "saas-mvp"
    }
  }
}
```

## ERROR HANDLING

### Missing Prerequisites

```
Error: Foundation summaries not found

Bootstrap requires foundation summaries to generate a project plan.

Missing:
- .context/summaries/prd-summary.md
- .context/summaries/vision-summary.md

Run first:
  /foundations init ideation/

Or specify documents directly:
  /foundations init --prd ideation/PRD.md --vision ideation/vision.md
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

### Example 1: Standard MVP Bootstrap

```bash
# After running /foundations init ideation/
/bootstrap
```

**Output**:
```
Bootstrap: Project Plan Generation
==================================

Prerequisites:
  [OK] handoff-manifest.json found
  [OK] prd-summary.md (checksum: abc123)
  [OK] vision-summary.md (checksum: def456)
  [--] icp-summary.md (not found, proceeding without)

Project Analysis:
  Inferred Type: saas-mvp (confidence: high)
  Reasoning: 3 MVP features, subscription model, 8-week timeline

Plan Generation:
  Phases: 4
  Quality Gates: build, test, lint

Generating Phase 1 (detailed)...
  - 7 tasks with acceptance criteria
  - Agent assignments: architect (2), developer (4), designer (1)

Generating Phase 2-4 (outlined)...
  - Phase 2: Core Features (4 milestones)
  - Phase 3: Polish & Testing (3 milestones)
  - Phase 4: Launch Prep (2 milestones)

Files Created:
  [OK] project-plan.md (847 lines)
  [OK] .context/phase-1-context.yaml (92 lines)
  [OK] handoff-manifest.json updated

Next Steps:
  1. Review project-plan.md for accuracy
  2. Run /coord phase-1 to begin execution
  3. Or /bootstrap --dry-run to regenerate
```

### Example 2: API Project with Custom Phases

```bash
/bootstrap --type api --phases 3
```

**Output**:
```
Bootstrap: Project Plan Generation
==================================

Prerequisites:
  [OK] All required summaries found

Project Configuration:
  Type: api (explicit override)
  Phases: 3 (custom)
  Quality Gates: build, test, lint, api-contract

Generating...
  Phase 1: API Foundation (8 tasks)
  Phase 2: Core Endpoints (outlined)
  Phase 3: Documentation & Deploy (outlined)

Files Created:
  [OK] project-plan.md
  [OK] .context/phase-1-context.yaml

Note: API projects include api-contract quality gate.
Ensure OpenAPI spec is maintained during development.
```

### Example 3: Dry Run Preview

```bash
/bootstrap --dry-run
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

- `/foundations init` - Must run first to create summaries
- Foundation documents in `ideation/` or specified paths

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
# Update summaries first
/foundations refresh

# Then regenerate plan
/bootstrap
# Select option 2 (Backup) when prompted
```

---

*Bootstrap transforms strategy into structure. A good plan is the difference between building and wandering.*
