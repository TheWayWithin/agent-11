# /plan - Project State Management

**Purpose**: Primary interface for viewing and managing project state. Provides real-time insights into progress, quality gates, and next actions.

**Usage**: `/plan [subcommand] [args]`

**Available Subcommands**:
- `status` - Show current phase, task, progress, blockers
- `next` - Show what's coming up
- `phase [N]` - Show details for specific phase
- `gate [N]` - Show quality gate status for phase
- `update [field] [value]` - Update plan field
- `archive` - Archive completed phases to reduce context

## Command Implementation

### Prerequisites

Before executing any `/plan` command:
1. Verify `project-plan.md` exists (created by `/bootstrap`)
2. Validate plan structure against `project/schemas/project-plan.schema.yaml`
3. Check for `.context/phase-N-context.yaml` files for active phases

### Error Handling

**Common Errors**:
- **No project-plan.md**: "No project plan found. Run `/bootstrap` to generate one."
- **Invalid schema**: "Project plan validation failed. Check against schema at project/schemas/project-plan.schema.yaml"
- **Phase not found**: "Phase N not found. Available phases: 1-{total}"
- **Invalid field**: "Field '{field}' not recognized. Valid fields: task_status, blockers, current_focus"

---

## Subcommand: `/plan status`

**Purpose**: Display current project state at a glance.

**Algorithm**:
```python
1. Read project-plan.md YAML frontmatter
2. Parse metadata:
   - project_name
   - total_phases
   - current_phase
   - current_task (from current phase)
3. Calculate progress metrics:
   - overall_progress = completed_tasks / total_tasks
   - phase_progress = completed_tasks_current_phase / total_tasks_current_phase
4. Read .context/phase-{current_phase}-context.yaml for:
   - blockers
   - next_action
   - quality_gate_status
5. Format and display output
```

**Output Format**:
```
📊 Project: {project_name}
📍 Phase: {current_phase}/{total_phases} - {phase_name}
📋 Task: {current_task}/{total_tasks_phase} - {task_description}
🎯 Progress: {overall_progress}% overall, {phase_progress}% current phase

⚠️ Blockers: {blockers_list or "None"}
➡️ Next Action: {next_action}

🚦 Quality Gates:
- Phase 1: {status_emoji} {STATUS} ({passed}/{total})
- Phase 2: {status_emoji} {STATUS} ({passed}/{total})
...

Status Legend:
✅ PASSED - All gates passed
🟡 IN PROGRESS - Some gates pending
❌ FAILED - One or more gates failed
⏸️ NOT STARTED - Phase not yet begun
```

**Example Output**:
```
📊 Project: SaaSify MVP
📍 Phase: 2/4 - Core Features
📋 Task: 3/7 - Implement authentication
🎯 Progress: 43% overall, 28% current phase

⚠️ Blockers: None
➡️ Next Action: Create user registration endpoint

🚦 Quality Gates:
- Phase 1: ✅ PASSED (3/3)
- Phase 2: 🟡 IN PROGRESS (1/3)
- Phase 3: ⏸️ NOT STARTED (0/4)
- Phase 4: ⏸️ NOT STARTED (0/2)
```

**Schema Validation**:
```yaml
# Validates against project-plan.schema.yaml
required_fields:
  - metadata.project_name
  - metadata.total_phases
  - phases[].phase_number
  - phases[].tasks[].status
```

---

## Subcommand: `/plan next`

**Purpose**: Show upcoming work to maintain momentum.

**Algorithm**:
```python
1. Read project-plan.md and current phase context
2. Find first task with status != "complete" in current phase
3. If no pending tasks in current phase:
   - Check if current phase quality gates passed
   - If yes, show next phase preview
   - If no, show gates that need attention
4. Check dependencies for next task:
   - List any blockers or prerequisites
   - Show tasks that must complete first
5. Format and display
```

**Output Format**:
```
➡️ Next Up

Current Phase: {phase_number}/{total_phases} - {phase_name}

📋 Next Task:
Task {task_number}: {task_description}
Status: {status}
Estimate: {estimate}
Dependencies: {dependencies or "None"}

[If dependencies exist:]
⚠️ Blocked By:
- Task {dep_task}: {dep_description} ({dep_status})

[If phase near completion:]
🎯 Upcoming:
Phase {next_phase}: {next_phase_name}
First Task: {first_task_description}

[If quality gates needed:]
🚦 Before Next Phase:
- {gate_name}: {gate_status}
- Run: {gate_command}
```

**Example Output**:
```
➡️ Next Up

Current Phase: 2/4 - Core Features

📋 Next Task:
Task 4: Implement user dashboard
Status: pending
Estimate: 2-3 days
Dependencies: None

🎯 Upcoming:
Phase 3: Integration & Testing
First Task: Set up Playwright test suite

🚦 Before Next Phase:
- All core features tested: 🟡 IN PROGRESS
- API documented: ❌ NOT STARTED
- Run: /plan gate 2
```

---

## Subcommand: `/plan phase [N]`

**Purpose**: Deep dive into specific phase details.

**Usage**: `/plan phase 2`

**Algorithm**:
```python
1. Validate phase number (1 <= N <= total_phases)
2. Read project-plan.md phases section
3. Read .context/phase-{N}-context.yaml if exists
4. Extract:
   - Phase metadata (name, description, timeline)
   - All tasks with statuses
   - Quality gates for phase
   - Deliverables
   - Current blockers (from context file)
5. Calculate phase progress
6. Format and display
```

**Output Format**:
```
📦 Phase {N}/{total_phases}: {phase_name}

📝 Description:
{phase_description}

⏱️ Timeline: {estimated_duration}
📊 Progress: {completed}/{total} tasks ({percentage}%)

📋 Tasks:
[For each task:]
{status_emoji} Task {number}: {description}
   Status: {status}
   Estimate: {estimate}
   [If blocked:] ⚠️ Blocked by: {blocker}

🎯 Deliverables:
- {deliverable_1}
- {deliverable_2}
...

🚦 Quality Gates:
[For each gate:]
{status_emoji} {gate_name}
   Command: {validation_command}
   Criteria: {success_criteria}
   Status: {status}
   [If failed:] ❌ Failure reason: {reason}

Status Legend:
✅ complete | 🔄 in_progress | ⏸️ pending | ❌ blocked
```

**Example Output**:
```
📦 Phase 2/4: Core Features

📝 Description:
Implement essential SaaS features: authentication, user management,
subscription handling, and core business logic.

⏱️ Timeline: 2-3 weeks
📊 Progress: 3/7 tasks (43%)

📋 Tasks:
✅ Task 1: Set up database schema
   Status: complete
   Estimate: 1 day

✅ Task 2: Implement authentication flow
   Status: complete
   Estimate: 2 days

🔄 Task 3: Create user dashboard
   Status: in_progress
   Estimate: 3 days

⏸️ Task 4: Add subscription management
   Status: pending
   Estimate: 2 days

⏸️ Task 5: Implement billing integration
   Status: pending
   Estimate: 3 days
   ⚠️ Blocked by: Task 4 completion

🎯 Deliverables:
- Working authentication system
- User dashboard with core features
- Subscription management interface
- Stripe integration
- Database schema finalized

🚦 Quality Gates:
✅ All features deployed to staging
   Command: /coord deploy staging
   Criteria: All tasks complete, no critical bugs
   Status: PASSED

🟡 End-to-end tests passing
   Command: /tester run e2e
   Criteria: >95% test coverage
   Status: IN PROGRESS (87% coverage)

⏸️ API documentation complete
   Command: /documenter api-docs
   Criteria: All endpoints documented
   Status: NOT STARTED
```

---

## Subcommand: `/plan gate [N]`

**Purpose**: Focus on quality gates for phase validation.

**Usage**: `/plan gate 2`

**Algorithm**:
```python
1. Validate phase number
2. Read project-plan.md for phase gate definition
   - Each phase has a 'gate' object with: type, blocking, criteria, status
3. Read .context/phase-{N}-context.yaml for gate_criteria details
   - Contains: gate_type, checks[], blocking, remediation_hints
4. For the phase gate:
   - Parse gate.type (build|test|lint|security|review|deploy)
   - Get gate.status (pending|passed|failed)
   - Get validation command from gate_criteria.checks
   - Get failure reasons if applicable
5. Calculate overall gate status for phase
6. Provide actionable next steps based on gate_criteria.remediation_hints
```

**Schema Reference**:
```yaml
# In project-plan.md phases section:
phases:
  - id: phase-1
    gate:
      type: build      # Gate category (enum)
      blocking: true   # Blocks next phase
      criteria: "npm run build passes"
      status: passed   # pending|passed|failed

# In .context/phase-N-context.yaml:
gate_criteria:
  gate_type: build
  checks:
    - name: "Build compilation"
      command: "npm run build"
      expected: "exit code 0"
  blocking: true
  remediation_hints:
    - "Check for TypeScript errors"
```

**Output Format**:
```
🚦 Quality Gates - Phase {N}: {phase_name}

Overall Status: {status_emoji} {STATUS}
Passed: {passed}/{total} gates

[For each gate:]
{status_emoji} {gate_name}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Status: {status}
Validation: {validation_command}
Criteria: {success_criteria}
[If passed:] ✅ Passed: {timestamp}
[If failed:] ❌ Failed: {failure_reason}
            💡 Fix: {suggested_fix}
[If pending:] ⏸️ Run: {validation_command}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[If all passed:]
✅ All gates passed! Ready to proceed to Phase {N+1}.

[If some failed:]
⚠️ Action Required:
1. Address failed gates (see above)
2. Re-run validations
3. Update status: /plan update gate_{N}_{gate_id} passed

[If some pending:]
📋 Next Steps:
1. Run pending validations
2. Update results in phase context
3. Re-run: /plan gate {N}
```

**Example Output**:
```
🚦 Quality Gates - Phase 2: Core Features

Overall Status: 🟡 IN PROGRESS
Passed: 1/3 gates

✅ All features deployed to staging
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Status: PASSED
Validation: /coord deploy staging
Criteria: All tasks complete, no critical bugs
✅ Passed: 2025-01-15 14:23:00
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🟡 End-to-end tests passing
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Status: IN PROGRESS
Validation: /tester run e2e
Criteria: >95% test coverage
⏸️ Current: 87% coverage
💡 Fix: Add tests for subscription flow and billing edge cases
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⏸️ API documentation complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Status: NOT STARTED
Validation: /documenter api-docs
Criteria: All endpoints documented with examples
⏸️ Run: /documenter api-docs --format openapi
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️ Action Required:
1. Complete e2e test coverage (add 8% more tests)
2. Generate API documentation
3. Re-run validations
4. Update: /plan update gate_2_tests passed
```

---

## Subcommand: `/plan update [field] [value]`

**Purpose**: Update project plan state with validation.

**Usage Examples**:
- `/plan update task 3 complete`
- `/plan update blocker "Waiting for API keys"`
- `/plan update phase 3`
- `/plan update focus "Implementing payment flow"`

**Valid Fields**:
- `task [N] [status]` - Update task status (pending|in_progress|complete|blocked)
- `phase [N]` - Move to new phase
- `blocker [description]` - Add blocker
- `remove_blocker [id]` - Remove blocker
- `focus [description]` - Update current focus
- `gate [phase_N_gate_id] [status]` - Update quality gate status

**Algorithm**:
```python
1. Parse field and value from command
2. Validate field name against allowed fields
3. Read current project-plan.md
4. Validate against schema before modification
5. Update appropriate section:
   - For task: Update task status in phases array
   - For phase: Update current_phase in metadata
   - For blocker: Append to phase context blockers
   - For focus: Update current_focus in phase context
   - For gate: Update quality_gates in phase
6. Validate modified plan against schema
7. Write updated project-plan.md
8. Update .context/phase-N-context.yaml if needed
9. Show confirmation with updated state
```

**Schema Validation**:
```yaml
# Before write, validate:
task_status:
  enum: [pending, in_progress, complete, blocked]

phase_number:
  type: integer
  minimum: 1
  maximum: total_phases

quality_gate_status:
  enum: [passed, in_progress, failed, not_started]
```

**Output Format**:
```
✅ Updated: {field}

[Show relevant section of plan with change highlighted]

Before: {old_value}
After:  {new_value}

[If task completed:]
🎉 Task completed! Progress: {new_percentage}%
➡️ Next task: {next_task_description}

[If phase changed:]
🚀 Moving to Phase {new_phase}: {phase_name}
📋 First task: {first_task_description}
⚠️ Quality gates from Phase {old_phase}: {gate_status}

[If blocker added:]
⚠️ Blocker added to Phase {phase}
💡 Remember to run /plan status to see updated state
```

**Example Outputs**:

```
# Task status update
✅ Updated: task 3 status

Before: in_progress
After:  complete

🎉 Task completed! Progress: 58% (4/7 tasks)
➡️ Next task: Implement billing integration
```

```
# Blocker added
✅ Updated: blockers

Added: "Waiting for Stripe API keys from client"

⚠️ Blocker added to Phase 2
📋 Current blockers:
1. Waiting for Stripe API keys from client

💡 Update status when resolved:
   /plan update remove_blocker 1
```

```
# Phase transition
✅ Updated: current phase

Before: Phase 2 (Core Features)
After:  Phase 3 (Integration & Testing)

🚀 Moving to Phase 3: Integration & Testing
📋 First task: Set up Playwright test suite
⚠️ Quality gates from Phase 2: 🟡 IN PROGRESS (2/3)

💡 Recommendation: Complete Phase 2 gates before proceeding
   Run: /plan gate 2
```

**Error Cases**:
```
❌ Error: Invalid field 'taks' (did you mean 'task'?)

❌ Error: Invalid task status 'done' (valid: pending, in_progress, complete, blocked)

❌ Error: Phase 5 not found (project has 4 phases)

❌ Error: Cannot update task 3 - task not found in current phase
   Available tasks in Phase 2: 1-7

❌ Error: Schema validation failed
   - Missing required field: phases[2].tasks[0].status
   Please run /bootstrap to regenerate valid plan
```

---

## Subcommand: `/plan archive`

**Purpose**: Archive completed phases to reduce context overhead.

**Algorithm**:
```python
1. Read project-plan.md
2. Identify completed phases:
   - All tasks status = "complete"
   - All quality gates status = "passed"
3. For each completed phase:
   - Create summary (name, completion date, key deliverables)
   - Move full phase details to project-plan-archive.md
   - Replace in project-plan.md with summary reference
4. Update phase context files:
   - Archive .context/phase-N-context.yaml to .context/archive/
   - Keep only active phase contexts
5. Update phase numbering if needed (or keep original for history)
6. Validate resulting project-plan.md against schema
7. Create/update project-plan-archive.md
8. Show summary of archived phases
```

**Integration with `/planarchive` command**:
```python
# Leverage existing planarchive.md command
1. Use planarchive algorithm for archival logic
2. Add phase-specific extensions:
   - Archive quality gates with pass/fail history
   - Preserve gate validation timestamps
   - Link to archived phase contexts
3. Maintain consistent archive structure
```

**Output Format**:
```
📦 Archiving Completed Phases

[For each archived phase:]
✅ Phase {N}: {phase_name}
   Completed: {completion_date}
   Tasks: {total_tasks} (all complete)
   Gates: {passed_gates}/{total_gates} passed
   → Archived to: project-plan-archive.md#{phase_anchor}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Summary:
- Phases archived: {archived_count}
- Context reduced: {old_size} → {new_size} tokens
- Active phases: {active_count}

project-plan.md:
- Before: {old_lines} lines
- After: {new_lines} lines
- Reduction: {percentage}%

💡 To view archived phases:
   cat project-plan-archive.md
   # Or search: grep "Phase {N}" project-plan-archive.md
```

**Example Output**:
```
📦 Archiving Completed Phases

✅ Phase 1: Foundation & Setup
   Completed: 2025-01-10
   Tasks: 5 (all complete)
   Gates: 3/3 passed
   → Archived to: project-plan-archive.md#phase-1

✅ Phase 2: Core Features
   Completed: 2025-01-20
   Tasks: 7 (all complete)
   Gates: 3/3 passed
   → Archived to: project-plan-archive.md#phase-2

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Summary:
- Phases archived: 2
- Context reduced: 15,243 → 6,891 tokens
- Active phases: 2

project-plan.md:
- Before: 342 lines
- After: 156 lines
- Reduction: 54%

💡 To view archived phases:
   cat project-plan-archive.md
   # Or search: grep "Phase 1" project-plan-archive.md
```

**project-plan.md Summary Section** (after archive):
```yaml
# Added to metadata section
archived_phases:
  - phase_number: 1
    name: "Foundation & Setup"
    completed: "2025-01-10"
    summary: "Repository setup, architecture defined, dev environment configured"
    archive_ref: "project-plan-archive.md#phase-1"

  - phase_number: 2
    name: "Core Features"
    completed: "2025-01-20"
    summary: "Authentication, user management, subscription handling implemented"
    archive_ref: "project-plan-archive.md#phase-2"
```

**Archive File Structure** (project-plan-archive.md):
```markdown
# Project Plan Archive

Archived phases from project-plan.md for historical reference.
Active phases remain in main project-plan.md.

---

## Phase 1: Foundation & Setup {#phase-1}

**Completed**: 2025-01-10
**Duration**: 5 days
**Status**: ✅ ALL GATES PASSED

### Tasks

- ✅ Task 1: Initialize repository and version control
- ✅ Task 2: Set up development environment
- ✅ Task 3: Create architecture.md
- ✅ Task 4: Configure CI/CD pipeline
- ✅ Task 5: Set up staging environment

### Quality Gates

✅ **Repository Setup Complete**
- Command: git remote -v
- Status: PASSED (2025-01-08)
- Result: Origin and upstream configured

✅ **Development Environment Ready**
- Command: docker-compose up
- Status: PASSED (2025-01-09)
- Result: All services running

✅ **CI/CD Pipeline Functional**
- Command: Check GitHub Actions
- Status: PASSED (2025-01-10)
- Result: Tests passing, auto-deploy to staging

### Deliverables Completed

- Git repository with main and develop branches
- Docker development environment
- architecture.md with system design
- GitHub Actions CI/CD pipeline
- Staging environment on Railway

---

## Phase 2: Core Features {#phase-2}

[Full phase details...]
```

**Error Cases**:
```
⚠️ Warning: No completed phases found
   All phases have incomplete tasks or failed gates.
   Nothing to archive.

⚠️ Warning: Phase 2 has incomplete quality gates
   Cannot archive until all gates pass.
   Current status: 2/3 gates passed
   Run: /plan gate 2

❌ Error: Cannot archive active phase
   Phase 3 is currently in progress.
   Archive is only for completed phases.
```

---

## Implementation Notes

### File Locations

```
project/
├── project-plan.md              # Main plan (active phases)
├── project-plan-archive.md      # Archived phases (created by /plan archive)
└── .context/
    ├── phase-1-context.yaml     # Active phase contexts
    ├── phase-2-context.yaml
    └── archive/
        ├── phase-1-context.yaml # Archived contexts
        └── phase-2-context.yaml
```

### Schema Validation

All `/plan` operations must validate against schemas:
- `project/schemas/project-plan.schema.yaml` - Main plan structure
- `project/schemas/phase-context.schema.yaml` - Phase context files
- `project/schemas/quality-gate.schema.yaml` - Quality gate definitions

**Validation Steps**:
1. Parse YAML/frontmatter
2. Validate structure against schema
3. Check required fields present
4. Validate enum values (status, etc.)
5. Verify cross-references (phase numbers, task IDs)

**On Validation Failure**:
```
❌ Schema Validation Failed

File: project-plan.md
Schema: project/schemas/project-plan.schema.yaml

Errors:
- Missing required field: metadata.project_name
- Invalid value: phases[1].tasks[2].status = "doing" (expected: pending|in_progress|complete|blocked)
- Phase number mismatch: phases[2].phase_number = 3 (expected: 2)

💡 Fix these errors or run /bootstrap to regenerate valid plan
```

### Additional Error Scenarios

**Malformed YAML**:
```
❌ YAML Parse Error

File: project-plan.md
Line: 47, Column: 3

Error: Unexpected indentation - expected 2 spaces, found 3
Context: "   - task: auth"

💡 Check YAML indentation. Use a YAML validator:
   - Online: yamllint.com
   - CLI: yamllint project-plan.md
   - Fix: Ensure consistent 2-space indentation
```

**Missing Task Status**:
```
⚠️ Missing Required Field

Phase 2, Task 3 is missing 'status' field.
Defaulting to: pending

To fix permanently, add status to project-plan.md:
  tasks:
    - id: "2.3"
      description: "Implement billing"
      status: pending  # Add this line
```

**Empty Phase**:
```
⚠️ Empty Phase Detected

Phase 3 has no tasks defined.
This may indicate incomplete planning.

Options:
1. Add tasks to Phase 3 in project-plan.md
2. Run /bootstrap --phases 3 to regenerate
3. If intentional, add a placeholder task
```

**Circular Dependencies**:
```
❌ Circular Dependency Detected

Task 2.3 depends on Task 2.5
Task 2.5 depends on Task 2.3

Resolution:
1. Review task dependencies in Phase 2
2. Remove one dependency to break the cycle
3. Consider reordering tasks
```

### Progress Calculation

```python
def calculate_progress(project_plan):
    """Calculate overall and phase-specific progress."""
    total_tasks = sum(len(phase['tasks']) for phase in project_plan['phases'])
    completed_tasks = sum(
        1 for phase in project_plan['phases']
        for task in phase['tasks']
        if task['status'] == 'complete'
    )

    overall_percentage = (completed_tasks / total_tasks * 100) if total_tasks > 0 else 0

    # Current phase progress
    current_phase = next(
        (p for p in project_plan['phases']
         if p['phase_number'] == project_plan['metadata']['current_phase']),
        None
    )

    if current_phase:
        phase_total = len(current_phase['tasks'])
        phase_completed = sum(1 for t in current_phase['tasks'] if t['status'] == 'complete')
        phase_percentage = (phase_completed / phase_total * 100) if phase_total > 0 else 0
    else:
        phase_percentage = 0

    return {
        'overall': overall_percentage,
        'phase': phase_percentage,
        'total_tasks': total_tasks,
        'completed_tasks': completed_tasks
    }
```

### Quality Gate Status Logic

```python
def determine_gate_status(gates):
    """Determine overall status from individual gates."""
    if not gates:
        return 'not_started', '⏸️'

    statuses = [g['status'] for g in gates]

    if all(s == 'passed' for s in statuses):
        return 'passed', '✅'
    elif any(s == 'failed' for s in statuses):
        return 'failed', '❌'
    elif any(s == 'in_progress' for s in statuses):
        return 'in_progress', '🟡'
    else:
        return 'not_started', '⏸️'
```

### Context File Integration

```python
def read_phase_context(phase_number):
    """Read phase context file with fallback."""
    context_path = f".context/phase-{phase_number}-context.yaml"

    if os.path.exists(context_path):
        with open(context_path) as f:
            return yaml.safe_load(f)
    else:
        # Return default structure if context doesn't exist
        return {
            'blockers': [],
            'next_action': 'Start first task',
            'quality_gates': []
        }
```

### Update Operations

```python
def update_task_status(project_plan, task_number, new_status):
    """Update task status with validation."""
    valid_statuses = ['pending', 'in_progress', 'complete', 'blocked']

    if new_status not in valid_statuses:
        raise ValueError(f"Invalid status. Valid: {valid_statuses}")

    current_phase_num = project_plan['metadata']['current_phase']
    current_phase = next(
        p for p in project_plan['phases']
        if p['phase_number'] == current_phase_num
    )

    if task_number < 1 or task_number > len(current_phase['tasks']):
        raise ValueError(f"Task {task_number} not found in phase {current_phase_num}")

    # Update task
    task = current_phase['tasks'][task_number - 1]
    old_status = task['status']
    task['status'] = new_status
    task['updated_at'] = datetime.now().isoformat()

    return {
        'task': task,
        'old_status': old_status,
        'new_status': new_status
    }
```

---

## Usage Examples

### Quick Status Check
```bash
/plan status
# Shows current progress, blockers, next action
```

### Check What's Next
```bash
/plan next
# Shows next task and upcoming work
```

### Review Specific Phase
```bash
/plan phase 2
# Deep dive into Phase 2 details
```

### Check Quality Gates
```bash
/plan gate 2
# Review all quality gates for Phase 2
```

### Update Task Status
```bash
/plan update task 3 complete
# Mark task 3 as complete
```

### Add Blocker
```bash
/plan update blocker "Waiting for API keys"
# Add blocker to current phase
```

### Move to Next Phase
```bash
/plan update phase 3
# Transition to Phase 3
```

### Archive Completed Work
```bash
/plan archive
# Archive all completed phases
```

---

## Coordinator Integration

### Mission Workflow Integration

```python
# At mission start
/plan status  # Show starting state

# During mission
/plan next    # Determine next task
/plan update task X in_progress  # Mark task started

# Task completion
/plan update task X complete     # Mark task done
/plan gate N                     # Check if phase gates ready

# Phase transition
/plan gate N                     # Verify all gates passed
/plan update phase N+1           # Move to next phase

# Periodic cleanup
/plan archive                    # Archive completed phases
```

### Delegation Pattern

```python
# Coordinator checks plan state
Task(
  subagent_type="strategist",
  prompt="Read project-plan.md and /plan status output.
          Analyze if we're ready for next phase.
          Provide recommendation."
)

# Update plan based on findings
/plan update task 5 complete
/plan update blocker "API integration delayed"
```

---

## Error Recovery

### Corrupted Plan File
```bash
# If project-plan.md is corrupted:
1. Backup current file: cp project-plan.md project-plan.md.backup
2. Restore from git: git checkout HEAD -- project-plan.md
3. OR regenerate: /bootstrap
```

### Schema Validation Errors
```bash
# If schema validation fails:
1. Check schema at project/schemas/project-plan.schema.yaml
2. Compare plan structure to schema requirements
3. Fix manually OR regenerate with /bootstrap
4. Validate: /plan status (will show validation errors)
```

### Missing Context Files
```bash
# If .context/phase-N-context.yaml missing:
1. /plan will use defaults (no blockers, generic next action)
2. Create manually from template:
   cp project/schemas/phase-context.schema.yaml .context/phase-2-context.yaml
3. OR run phase initialization:
   /coord phase-init 2
```

---

## Performance Considerations

### Large Projects (>10 phases)
- Use `/plan archive` regularly to reduce context
- Keep only active 2-3 phases in project-plan.md
- Archive completed phases immediately after verification

### Fast Status Checks
- `/plan status` reads only frontmatter and current phase context
- Optimized for <100ms response time
- Cached progress calculations

### Batch Updates
- Multiple updates in sequence may be slow
- Consider using Task tool to batch operations:
  ```python
  Task(
    subagent_type="coordinator",
    prompt="Update project plan:
            - Mark tasks 3, 4, 5 complete
            - Update phase to 3
            - Archive completed phases"
  )
  ```

---

## Testing Recommendations

### Unit Tests
- Schema validation functions
- Progress calculation
- Status determination logic
- Update operations

### Integration Tests
- Full workflow: status → update → gate → archive
- Error cases: invalid phase, missing file, schema violation
- Edge cases: empty plan, all tasks complete, no gates

### User Acceptance Tests
- Real project workflows
- Multi-phase transitions
- Long-running projects (>30 days)
- Archive and restore scenarios

---

## Future Enhancements

### Planned Features
1. **Visual Progress Bar**: ASCII art progress visualization
2. **Time Tracking**: Estimate vs. actual time per task
3. **Burndown Charts**: Text-based burndown in terminal
4. **Task Dependencies**: Automated dependency checking
5. **Notifications**: Alerts for blockers or failed gates
6. **Export Formats**: JSON, CSV export for external tools
7. **Team Features**: Multi-user task assignment

### Integration Opportunities
- **GitHub Issues**: Sync tasks with GitHub Issues
- **Project Management**: Export to Jira, Asana, etc.
- **CI/CD**: Automated quality gate validation
- **Slack/Discord**: Status notifications to channels

---

## Related Commands

- `/bootstrap` - Generate initial project-plan.md
- `/foundations` - Process BOS-AI handoff documents
- `/coord` - Mission orchestration with plan integration
- `/planarchive` - Archive completed sections (used by /plan archive)
- `/report` - Generate stakeholder reports from plan

---

## Troubleshooting

### Common Issues

**Issue**: "No project plan found"
- **Solution**: Run `/bootstrap` to generate project-plan.md

**Issue**: Schema validation fails
- **Solution**: Check schema requirements, fix manually or regenerate

**Issue**: Progress percentage incorrect
- **Solution**: Verify all tasks have valid status values, check calculation

**Issue**: Quality gates not showing
- **Solution**: Ensure gates defined in project-plan.md phases section

**Issue**: Archive command does nothing
- **Solution**: Check if any phases are actually complete (all tasks + gates)

### Debug Mode

```bash
# Enable verbose output (future feature)
/plan status --verbose
/plan gate 2 --debug
```

---

**Last Updated**: 2025-12-30 (Phase 9D - /plan Command Specification)
**Dependencies**: /bootstrap, /foundations, project/schemas/*.yaml
**Related**: Phase 9 Foundation Docs Sprint, planarchive.md
