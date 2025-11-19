# Architectural Decision: Coordinator-as-Executor Pattern for File Persistence

**Status**: APPROVED
**Date**: 2025-01-19
**Sprint**: Sprint 2 (Days 6-12)
**Related**: File Persistence Bug (2025-01-12), Sprint 1 Protocol Enforcement

---

## Problem Statement

### The Root Cause
Task tool delegation creates **isolated agent contexts** where Write/Edit operations execute successfully within the agent's context but **do not persist to the host filesystem** after agent completion. This is an **architectural limitation** of the Task tool, not a patchable bug.

### Evidence
- **2025-01-11**: Task delegation created 14 files, agent verified with ls/find, post-execution: 0 files
- **2025-01-12**: Second verification attempt, same pattern: agent reports success, 0 files persist
- **Workaround Success**: Coordinator direct Write tool usage created all 14 files immediately
- **Reproducibility**: 100% across multiple independent attempts
- **Full Analysis**: `/Users/jamiewatters/DevProjects/ISOTracker/post-mortem-analysis.md`

### Why This Is Critical
- **Silent Failure**: No error messages, agents report success, files don't exist
- **Complete Data Loss**: Hours of specialist work lost with no recovery
- **Prompt Dependency**: Sprint 1 protocols (>80% effective) rely on coordinators remembering verification steps
- **User Experience**: Users experience mysterious file disappearances, trust erosion

---

## Solution Approach: Coordinator-as-Executor Pattern

### Core Principle
**Specialists generate structured output, Coordinator executes ALL file operations.**

### Before (Prompt-Dependent)
```
Coordinator → Task(developer, "Create file X")
           → Developer executes Write tool
           → File operation in isolated context
           → Fails silently when context closes
           → Coordinator assumes success
```

### After (Architecture-Guaranteed)
```
Coordinator → Task(developer, "Generate structured output for file X")
           → Developer returns JSON: {"file": "path", "content": "..."}
           → Coordinator AUTOMATICALLY parses JSON
           → Coordinator EXECUTES Write tool (in coordinator context)
           → Coordinator VERIFIES file exists
           → Success guaranteed (no isolation)
```

### Why This Is Strategic

**Eliminates Root Cause**: File operations execute in coordinator's context, which persists to host filesystem. Isolated agent contexts no longer involved in file operations.

**Removes Prompt Dependency**: Coordinator ALWAYS parses specialist responses and executes file operations. No human memory required, no protocol fatigue.

**Architectural Guarantee**: 100% persistence through architecture, not through human compliance.

---

## Design Specification

### 1. Structured Output Format (JSON)

**Why JSON over YAML**:
- Native JavaScript parsing (JSON.parse)
- Strict schema validation
- Better error messages
- Industry standard for structured data

**JSON Schema**:
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["file_operations"],
  "properties": {
    "file_operations": {
      "type": "array",
      "minItems": 1,
      "items": {
        "type": "object",
        "required": ["operation", "file_path", "description"],
        "properties": {
          "operation": {
            "type": "string",
            "enum": ["create", "edit", "delete", "append"]
          },
          "file_path": {
            "type": "string",
            "pattern": "^/Users/jamiewatters/DevProjects/.*",
            "description": "Absolute path starting with /Users/jamiewatters/DevProjects/"
          },
          "content": {
            "type": "string",
            "description": "Required for create/edit/append, omit for delete"
          },
          "edit_instructions": {
            "type": "string",
            "description": "For edit operations: specific changes to make"
          },
          "description": {
            "type": "string",
            "minLength": 10,
            "description": "Why this file operation is needed (logged to progress.md)"
          },
          "verify_content": {
            "type": "boolean",
            "default": true,
            "description": "Whether to verify file content after operation"
          }
        }
      }
    },
    "specialist_summary": {
      "type": "string",
      "description": "Human-readable summary of specialist's work"
    }
  }
}
```

**Example Specialist Response**:
```json
{
  "file_operations": [
    {
      "operation": "create",
      "file_path": "/Users/jamiewatters/DevProjects/agent-11/project/missions/new-mission.md",
      "content": "# New Mission\n\nMission objectives...",
      "description": "Create mission template for onboarding workflow"
    },
    {
      "operation": "edit",
      "file_path": "/Users/jamiewatters/DevProjects/agent-11/project-plan.md",
      "edit_instructions": "Add task '[ ] Implement onboarding mission' under Phase 3",
      "description": "Track new mission in project plan"
    }
  ],
  "specialist_summary": "Created onboarding mission template and updated project plan with tracking task"
}
```

### 2. Parsing Strategy

**Extraction Algorithm**:
```python
def extract_json(specialist_response: str) -> dict:
    """
    Extract JSON from specialist response.
    Handles: code blocks, raw JSON, mixed content.
    """
    # Try 1: Extract from ```json code block
    json_block = re.search(r'```json\n(.*?)\n```', response, re.DOTALL)
    if json_block:
        return json.loads(json_block.group(1))

    # Try 2: Extract from ``` code block
    code_block = re.search(r'```\n(.*?)\n```', response, re.DOTALL)
    if code_block:
        return json.loads(code_block.group(1))

    # Try 3: Parse entire response as JSON
    try:
        return json.loads(response)
    except:
        raise ParseError("No valid JSON found in specialist response")
```

**Validation Algorithm**:
```python
def validate_file_operations(data: dict) -> list[str]:
    """
    Validate against schema, return list of errors.
    Empty list = valid.
    """
    errors = []

    if 'file_operations' not in data:
        errors.append("Missing required field: file_operations")
        return errors

    for idx, op in enumerate(data['file_operations']):
        # Check required fields
        for field in ['operation', 'file_path', 'description']:
            if field not in op:
                errors.append(f"Operation {idx}: Missing {field}")

        # Validate operation type
        if op.get('operation') not in ['create', 'edit', 'delete', 'append']:
            errors.append(f"Operation {idx}: Invalid operation '{op.get('operation')}'")

        # Validate file_path
        if not op.get('file_path', '').startswith('/Users/jamiewatters/DevProjects/'):
            errors.append(f"Operation {idx}: file_path must be absolute starting with /Users/jamiewatters/DevProjects/")

        # Validate content requirement
        if op.get('operation') in ['create', 'edit', 'append'] and 'content' not in op:
            errors.append(f"Operation {idx}: {op.get('operation')} requires 'content' field")

    return errors
```

**Error Recovery**:
```
If parsing fails:
  → Request specialist: "Your response must include valid JSON in a code block. Use this format:
     ```json
     {
       "file_operations": [
         {
           "operation": "create",
           "file_path": "/absolute/path/to/file.md",
           "content": "file content here",
           "description": "why this file is needed"
         }
       ]
     }
     ```"

If validation fails:
  → Request specialist: "JSON validation errors:
     - Operation 0: Missing required field 'description'
     - Operation 1: file_path must be absolute
     Please correct and resubmit."
```

### 3. Execution Engine

**Sequential Execution Algorithm**:
```python
def execute_file_operations(operations: list[dict]) -> dict:
    """
    Execute file operations sequentially.
    Returns: {"success": int, "failed": int, "details": list}
    """
    results = {"success": 0, "failed": 0, "details": []}

    for op in operations:
        # Log operation BEFORE execution
        log_to_progress(f"Executing: {op['operation']} on {op['file_path']}")

        try:
            # Execute operation
            if op['operation'] == 'create':
                write_file(op['file_path'], op['content'])
            elif op['operation'] == 'edit':
                edit_file(op['file_path'], op.get('edit_instructions', op['content']))
            elif op['operation'] == 'delete':
                delete_file_with_confirmation(op['file_path'])
            elif op['operation'] == 'append':
                append_to_file(op['file_path'], op['content'])

            # Verify operation
            if op.get('verify_content', True):
                verify_result = verify_file(op['file_path'])
                if not verify_result['exists']:
                    raise VerificationError(f"File {op['file_path']} doesn't exist after {op['operation']}")

            # Log success
            log_to_progress(f"✅ {op['operation']} successful: {op['file_path']}")
            results['success'] += 1
            results['details'].append({
                "operation": op,
                "status": "success",
                "verification": verify_result
            })

        except Exception as e:
            # Log failure
            log_to_progress(f"❌ {op['operation']} failed: {op['file_path']}: {str(e)}")
            results['failed'] += 1
            results['details'].append({
                "operation": op,
                "status": "failed",
                "error": str(e)
            })

            # STOP on first failure (atomic execution)
            break

    return results
```

**Verification Protocol**:
```python
def verify_file(file_path: str) -> dict:
    """
    Verify file operation with independent tools.
    Returns: {"exists": bool, "size": int, "content_preview": str}
    """
    # Check existence and size
    ls_result = bash(f"ls -lh {file_path} 2>&1")
    exists = "No such file" not in ls_result

    if not exists:
        return {"exists": False, "size": 0, "content_preview": ""}

    # Extract size
    size = extract_size_from_ls(ls_result)

    # Content spot-check
    head_result = bash(f"head -n 5 {file_path}")

    return {
        "exists": True,
        "size": size,
        "content_preview": head_result
    }
```

**Progress.md Logging**:
```markdown
### [2025-01-19 14:32] File Operations Executed

**Specialist**: @developer
**Task**: Implement authentication middleware

**Operations**:
1. ✅ create /Users/jamiewatters/DevProjects/myapp/src/middleware/auth.ts (2.3 KB)
   - Description: Create authentication middleware for Express
   - Verified: File exists, content preview matches expected structure

2. ✅ edit /Users/jamiewatters/DevProjects/myapp/src/app.ts
   - Description: Import and use authentication middleware
   - Verified: File exists, edits applied correctly

**Summary**: 2/2 operations successful, 0 failed
```

### 4. Security Safeguards

**Path Validation**:
```python
def is_safe_path(file_path: str) -> bool:
    """
    Validate file path is safe for operations.
    Returns: True if safe, False if dangerous
    """
    # Must be absolute path
    if not file_path.startswith('/'):
        return False

    # Must be within allowed directory
    if not file_path.startswith('/Users/jamiewatters/DevProjects/'):
        return False

    # No path traversal
    if '..' in file_path:
        return False

    # No hidden system files
    if '/..' in file_path or file_path.startswith('.'):
        return False

    return True
```

**Operation Whitelist**:
- **Allowed**: create, edit, delete, append (tool-based only)
- **Forbidden**: Arbitrary bash commands, code execution, network operations

**Content Validation**:
```python
def validate_content(content: str, operation: str) -> list[str]:
    """
    Validate content for safety and size.
    Returns: List of warnings (empty = safe)
    """
    warnings = []

    # Size checks
    if len(content) > 10_000_000:  # 10 MB
        warnings.append("REJECT: Content exceeds 10MB limit")
    elif len(content) > 1_000_000:  # 1 MB
        warnings.append("WARNING: Content exceeds 1MB (large file)")

    # Encoding check
    try:
        content.encode('utf-8')
    except:
        warnings.append("WARNING: Content contains non-UTF-8 characters")

    return warnings
```

**Delete Confirmation**:
```python
def delete_file_with_confirmation(file_path: str):
    """
    Delete file with explicit confirmation step.
    """
    # Show file content first
    content_preview = bash(f"head -n 20 {file_path}")

    # Log deletion request
    log_to_progress(f"""
    ⚠️ DELETE REQUESTED: {file_path}
    Content preview:
    {content_preview}

    Confirm deletion? (Manual review required)
    """)

    # Require explicit confirmation
    # (In practice: coordinator reviews, confirms, executes)
```

---

## Comparison with Alternatives

### Alternative 1: Task Tool Modification (Platform Change)
**Pros**:
- ✅ Would fix root cause at platform level
- ✅ No user-side changes required
- ✅ All existing workflows continue

**Cons**:
- ❌ Requires Anthropic platform change
- ❌ No user control over timeline
- ❌ May never happen
- ❌ Leaves users vulnerable indefinitely

**Verdict**: Not viable (no user control)

### Alternative 2: SharedFile Tool (Platform Feature)
**Pros**:
- ✅ Could enable cross-context file sharing
- ✅ Maintains delegation model

**Cons**:
- ❌ Platform feature doesn't exist
- ❌ Would require complex state management
- ❌ Security implications unclear
- ❌ No timeline for availability

**Verdict**: Not viable (doesn't exist)

### Alternative 3: Coordinator-as-Executor (CHOSEN)
**Pros**:
- ✅ 100% file persistence guarantee
- ✅ Zero prompt dependency (architectural solution)
- ✅ Simplifies specialist logic (output only)
- ✅ Single point of file operation control
- ✅ User-controlled implementation
- ✅ Immediate deployment

**Cons**:
- ❌ Increases coordinator complexity (~30%)
- ❌ Requires coordinator profile changes
- ❌ Migration effort for existing specialists
- ❌ Specialist responses become more structured

**Verdict**: Best option (user control + architectural guarantee)

---

## Trade-offs Analysis

### Coordinator Complexity vs Reliability
**Trade-off**: Coordinator becomes 30% more complex (parsing, execution, verification) in exchange for 100% file persistence.

**Justification**: This is a strategic trade-off. File persistence is CRITICAL for system function. Coordinator complexity is manageable through:
- Automated parsing (no human intervention)
- Structured execution engine (deterministic logic)
- Clear error messages (debugging support)

**Mitigation**: Comprehensive testing of parsing/execution engine before deployment.

### Specialist Simplification vs Response Structure
**Trade-off**: Specialists no longer execute file operations (simpler logic) but must output structured JSON (more rigid format).

**Justification**: Specialists become stateless output generators. This is architecturally cleaner:
- No tool permission complexity
- No verification responsibilities
- No file operation failures
- Clear input → output contract

**Mitigation**: Provide JSON templates and examples in specialist profiles.

### Migration Effort vs Long-Term Benefit
**Trade-off**: Requires updating 11 specialist profiles and mission templates over Sprint 2-3 (estimated 2 weeks effort).

**Justification**: One-time migration cost for permanent architectural improvement. Benefits:
- Eliminates file persistence issues forever
- Reduces cognitive load on users (no verification protocols)
- Simplifies specialist logic (easier maintenance)
- Enables future automation (predictable structure)

**Mitigation**: Phased rollout (2-3 specialists first, validate, then full migration).

---

## Migration Path

### Sprint 2 (Days 6-12): Foundation
**Phase 2A (Days 6-7)**: Solution design (THIS DOCUMENT)
**Phase 2B (Day 8)**: Coordinator profile enhancement
**Phase 2C (Day 9)**: Execution engine implementation
**Phase 2D (Day 10)**: Specialist profile updates (2-3 specialists)
**Phase 2E (Days 11-12)**: Integration testing

### Sprint 3 (Days 13-18): Migration
**Phase 3A (Days 13-14)**: Migrate remaining specialists
**Phase 3B (Days 15-16)**: Update mission templates
**Phase 3C (Days 17-18)**: End-to-end testing

### Sprint 4 (Days 19-24): Completion
**Phase 4A (Days 19-20)**: User acceptance testing
**Phase 4B (Days 21-22)**: Documentation updates
**Phase 4C (Day 23)**: Remove Sprint 1 protocols
**Phase 4D (Day 24)**: Final validation

### Backward Compatibility
**During Migration**: Sprint 1 protocols continue working alongside Sprint 2 pattern.
**After Migration**: All new missions use coordinator-as-executor, old missions archived.
**Rollback Plan**: If critical issues discovered, revert to Sprint 1 protocols temporarily.

---

## Expected Outcomes

### Success Metrics

**Primary Metric**: File Persistence Rate
- **Current (Baseline)**: 0% (with Task tool delegation)
- **Sprint 1 (Protocol)**: 80-85% (with manual verification)
- **Sprint 2 Target**: 100% (architectural guarantee)
- **Measurement**: Files created / Files expected = 1.0

**Secondary Metrics**:
- **Prompt Dependency**: 0% (automated parsing/execution)
- **Specialist Complexity**: -50% (no file operations, output only)
- **Coordinator Complexity**: +30% (offset by automation)
- **Verification Failures**: -90% (eliminated root cause)

### Qualitative Benefits
- ✅ Users trust file operations (no mysterious disappearances)
- ✅ Coordinators focus on orchestration (not verification)
- ✅ Specialists focus on domain logic (not file operations)
- ✅ System architecture cleaner (separation of concerns)
- ✅ Future automation enabled (structured outputs)

### Risk Mitigation
- **Parsing Failures**: Automated error messages guide specialists to correct format
- **Execution Failures**: Atomic operations with rollback on failure
- **Verification Failures**: Immediate escalation with detailed error context
- **Migration Issues**: Phased rollout with fallback to Sprint 1 protocols

---

## Implementation Notes

### Coordinator Profile Changes
- Add JSON parsing logic to core capabilities
- Add execution engine to file operation handling
- Add verification protocol to every operation
- Update delegation templates with structured output requirements

### Specialist Profile Changes
- Remove Write/Edit tool permissions
- Add structured output guidance
- Add JSON templates and examples
- Update task completion criteria (JSON delivery, not file creation)

### Mission Template Changes
- Update task prompts to request JSON outputs
- Add verification checkpoints after specialist completion
- Update success criteria (files verified, not just created)

### Testing Strategy
- Unit tests: JSON parsing, validation, execution logic
- Integration tests: Full coordinator → specialist → execution flow
- End-to-end tests: dev-setup, build, fix missions
- Performance tests: Large file operations, multiple operations

---

## Conclusion

The coordinator-as-executor pattern provides an **architectural guarantee** for file persistence by eliminating the root cause (isolated agent contexts). This is the most viable solution given platform constraints, providing 100% reliability through user-controlled implementation.

**Key Success Factor**: Automated parsing and execution removes prompt dependency, ensuring coordinator ALWAYS handles file operations correctly without human intervention.

**Strategic Value**: This pattern establishes a foundation for future automation and reliability improvements across AGENT-11's multi-agent architecture.

**Next Steps**: Proceed to Phase 2B (Coordinator Enhancement) to implement execution engine.
