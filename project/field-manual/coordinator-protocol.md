# Coordinator Delegation Protocol

Comprehensive guide for coordinators using the `/coord` command to orchestrate multi-agent missions.

## CRITICAL: Using /coord Command

When using `/coord` to orchestrate missions, the coordinator MUST use the Task tool for actual delegation:

### 1. Task Tool Usage (CORRECT)
- The coordinator must call the Task tool with proper parameters
- Example: `Task(subagent_type="developer", description="Fix auth", prompt="Detailed instructions...")`
- This actually spawns a new agent instance that performs the work

### 2. @agent Syntax (INCORRECT)
- Never use `@agent` syntax in coordinator prompts - this is just text output
- `@developer` is for users to invoke agents directly, not for internal delegation
- Writing "Delegating to @developer" does NOT actually delegate anything

### 3. Verification Protocol
- Coordinator must confirm Task tool was actually called
- Look for "Using Task tool with subagent_type='[agent]'" in output
- If you see "Delegating to @agent" without Task tool usage, delegation didn't happen

### 4. Example of Proper Delegation

```
# WRONG (just describes delegation):
"I'm delegating to @tester for testing"

# RIGHT (actually uses Task tool):
Task(
  subagent_type="tester",
  description="Test auth flow",
  prompt="Create Playwright tests for authentication..."
)
```

## NO ROLE-PLAYING RULE

The coordinator must NEVER role-play or simulate delegation. Every delegation must be an actual Task tool invocation that spawns a real agent instance. Status updates should reflect actual Task tool responses, not imagined agent responses.

---

## Task Tool Limitations & File Creation Verification

**CRITICAL UNDERSTANDING**: The Task tool and subagents have important limitations.

### What Subagents CAN Do
- Analyze code and provide recommendations
- Design solutions and create implementation plans
- Review existing files and suggest changes
- Generate content for files (as text in their response)
- Provide specific Edit/Write tool calls for the coordinator to execute

### What Subagents CANNOT Do
- **Directly create or modify files** - They don't have Write/Edit tool access
- Execute tool calls themselves (only recommend them)
- Verify their outputs were actually created
- Make persistent changes to the filesystem

### Coordinator's Mandatory Verification Protocol

**After EVERY Task tool delegation that should create/modify files:**

1. **Immediately Verify File Existence**:
   ```bash
   ls -la /path/to/expected/file.md 2>/dev/null || echo "FILE MISSING"
   ```

2. **If File Was Supposed to Be Created But Doesn't Exist**:
   - The subagent provided a PLAN, not actual execution
   - Extract the file content from the subagent's response
   - Use Write tool to actually create the file
   - Update progress.md noting manual file creation was required

3. **If File Should Have Been Modified But Wasn't**:
   - The subagent provided RECOMMENDATIONS, not actual edits
   - Extract the specific changes from the subagent's response
   - Use Edit tool to apply the changes
   - Update progress.md noting manual edits were required

4. **Best Practice - Request Tool Calls Directly**:
   ```
   Task(
     subagent_type="developer",
     prompt="Analyze X and provide the EXACT Write tool call I should execute,
             including the complete file_path and full content parameters.
             Format your response as a ready-to-execute tool call."
   )
   ```

### Common Mistake Pattern

```
WRONG FLOW:
1. Coordinator delegates to subagent to "create file X"
2. Subagent responds with file content
3. Coordinator assumes file exists
4. Coordinator marks task complete [x]
5. File doesn't actually exist

CORRECT FLOW:
1. Coordinator delegates to subagent to "design file X and provide Write tool call"
2. Subagent responds with file content and Write tool parameters
3. Coordinator VERIFIES file doesn't exist yet with ls
4. Coordinator EXECUTES Write tool with subagent's parameters
5. Coordinator VERIFIES file now exists
6. Coordinator marks task complete [x]
7. Coordinator logs to progress.md what was created
```

### Verification Checklist Template

After any delegation involving file operations, run:
```bash
# List all expected outputs
ls -la file1.md file2.md file3.md 2>&1

# For each missing file:
# 1. Extract content from subagent response
# 2. Execute Write tool
# 3. Verify creation: ls -la file.md
# 4. Log to progress.md
```

### Integration with Progress Tracking

When manual file creation is required after delegation:

**In progress.md**:
```markdown
### [YYYY-MM-DD HH:MM] Delegation Verification Issue

**What Happened**:
- Delegated file creation to @analyst via Task tool
- Analyst provided file content but couldn't create file directly
- Had to manually execute Write tool with analyst's content

**Prevention**:
- Always verify file existence after delegation
- Request "provide Write tool call" instead of "create file"
- Use verification checklist after every file operation delegation
```

---

## File Persistence Architecture

**ARCHITECTURAL LIMITATION IDENTIFIED 2025-01-12**: Task tool delegation + Write tool operations have an architectural limitation where files created in delegated agent contexts don't persist to the host filesystem after agent completion. This is not a patchable bug but a fundamental limitation of the Task tool architecture.

### Sprint 2 Solution (PRODUCTION READY - 2025-01-19)

Coordinator-as-executor pattern implemented and deployed. Specialists return structured JSON with file operation specifications, coordinator automatically parses and executes all operations with verification. Reliability improved from ~80% (Sprint 1 manual) to ~99.9% (Sprint 2 automatic).

### Sprint 6 Enforcement (2025-11-29)

Protocol enforcement added to make bypass impossible. Pre-flight checklists, response validation, and mandatory verification steps now integrated into coord.md and coordinator.md.

### Documentation

Complete migration guide and examples available:
- **Migration Guide**: `/project/field-manual/migration-guides/file-persistence-v2.md`
- **Quick Reference**: `/project/field-manual/file-operation-quickref.md` (Sprint 6)
- **Delegation Templates**: `/templates/file-operation-delegation.md` (Sprint 6)
- **Examples**: `/project/examples/file-operations/` (4 comprehensive examples)

### Limitation Characteristics
- **Symptom**: Agent reports "Files created successfully" with verification output (ls, find), but 0 files exist on filesystem after completion
- **Severity**: CRITICAL - Silent failure with no error messages
- **Reproducibility**: 100% across multiple independent attempts
- **Impact**: Complete loss of work product (hours of wasted implementation)
- **Root Cause**: Write tool operations in delegated Task contexts don't persist to host filesystem

### Evidence
- **2025-01-11**: Task delegation created 14 files, agent verified with ls/find, post-execution: 0 files
- **2025-01-12**: Second attempt (verification), same pattern: agent reports success, 0 files persist
- **Workaround Success**: Coordinator direct Write tool usage created all 14 files immediately

### Sprint 2 Structured Output Protocol (RECOMMENDED)

**For All File Operations** (create, edit, delete):
1. **Delegate with Structured Prompt**: Request JSON response with file_operations array
2. **Specialist Returns JSON**: Complete file specifications with all content
3. **Coordinator Parses & Executes**: Automatic Write/Edit tool execution
4. **Automatic Verification**: Coordinator verifies with ls/head commands
5. **Automatic Logging**: Progress.md updated with all operations

**JSON Format**:
```json
{
  "file_operations": [
    {
      "operation": "create|edit|delete",
      "file_path": "/absolute/path/to/file",
      "content": "complete content for create operations",
      "description": "what this operation does",
      "verify_content": true
    }
  ],
  "specialist_summary": "overall summary"
}
```

See `/project/field-manual/migration-guides/file-persistence-v2.md` for complete guide.

### Legacy Sprint 1 Protocol (FALLBACK ONLY)

**Before Any File Creation Delegation**:
1. **Prefer Direct Implementation**: If coordinator can create files directly with Write tool, DO THAT
2. **If Must Delegate**: Include in Task prompt:
   - "Provide EXACT Write tool calls with absolute paths and complete content"
   - "Do not claim completion - provide tool call specifications for coordinator to execute"

**After Every File Creation Delegation**:
1. **NEVER mark task [x] without filesystem verification**
2. **Immediately verify with independent tools**:
   ```bash
   # Single file verification
   ls -lh /absolute/path/to/file.ts

   # Multiple files verification
   find /absolute/path/to/directory -type f -name "*.ts" -mtime -1

   # Content spot-check (confirms not just empty file)
   head -n 5 /absolute/path/to/file.ts
   ```
3. **If ANY files missing**: Extract content from agent response, use Write tool directly
4. **Document in progress.md**: "Files verified on filesystem: [timestamp]"

### Verification Checklist (MANDATORY)

After Task delegation involving file operations:
- [ ] Agent has returned with completion report
- [ ] Run `ls -lh` on ALL reported file paths independently
- [ ] At least ONE file opened with Read tool to verify content
- [ ] All expected files confirmed present on filesystem
- [ ] Verification timestamp documented in progress.md
- [ ] Task marked [x] ONLY after all checks pass

**If ANY check fails**: Stop, extract content from agent response, implement directly with Write tool, document workaround in progress.md.

---

## Context Preservation Requirement

Every Task tool invocation MUST include instructions to read context files first and update handoff notes after completion. This ensures seamless context flow between agents.

## Principle Enforcement in Delegation

Every Task tool delegation MUST remind agents to:
- Follow Critical Software Development Principles
- Never compromise security for convenience
- Perform root cause analysis before implementing fixes
- Document strategic decisions in handoff-notes.md
