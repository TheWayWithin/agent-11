# Delegation Verification Checklist

**PURPOSE**: Quick reference for coordinators to verify file creation after Task tool delegations

## ⚠️ CRITICAL UNDERSTANDING

**Subagents CANNOT directly create or modify files.** They can only provide content and recommendations that the coordinator must then execute using Write/Edit tools.

## Pre-Delegation Checklist

Before delegating any file creation task:

- [ ] Verify context files exist (`agent-context.md`, `handoff-notes.md`)
- [ ] Identify ALL expected file outputs
- [ ] Frame delegation as "provide Write tool call" not "create file"
- [ ] Prepare verification commands for expected files

## Post-Delegation Verification (MANDATORY)

After EVERY Task tool delegation involving files:

### 1. Immediate Verification
```bash
# Check if expected files exist
ls -la file1.md file2.md file3.md 2>&1
```

### 2. For Each Missing File

- [ ] Extract content from subagent's response
- [ ] Execute Write tool with content:
  ```
  Write(
    file_path="/absolute/path/to/file.md",
    content="[Content from subagent response]"
  )
  ```
- [ ] Verify creation: `ls -la /path/to/file.md`
- [ ] Confirm file size reasonable: `wc -l /path/to/file.md`

### 3. For Modified Files

- [ ] Check if modification actually occurred: `git diff /path/to/file.md`
- [ ] If no changes, extract recommendations from subagent
- [ ] Execute Edit tool with changes
- [ ] Verify with Read tool
- [ ] Confirm changes applied: `git diff /path/to/file.md`

### 4. Progress Tracking

- [ ] Log to progress.md what was created/modified
- [ ] Note manual intervention was required
- [ ] Include file paths and descriptions
- [ ] Mark task complete [x] in project-plan.md

## Common Mistake Patterns

### ❌ WRONG: Assume File Exists
```
Coordinator delegates to analyst: "Create post-mortem document"
Analyst responds with content
Coordinator marks task [x] complete
File doesn't exist ← PROBLEM
```

### ✅ CORRECT: Verify and Create
```
Coordinator delegates: "Design post-mortem and provide Write tool params"
Analyst responds with content and parameters
Coordinator verifies: ls -la post-mortem.md (FILE MISSING)
Coordinator executes Write tool
Coordinator verifies: ls -la post-mortem.md (EXISTS, 25KB)
Coordinator marks [x] complete
Coordinator logs to progress.md
```

## Delegation Phrasing Guide

### Instead of:
- ❌ "Create the documentation file"
- ❌ "Write the analysis to a file"
- ❌ "Generate the report"

### Use:
- ✅ "Design the documentation and provide the EXACT Write tool call I should execute"
- ✅ "Analyze and provide content formatted for Write tool with full file_path"
- ✅ "Create the report content and format as a Write tool invocation"

## Quick Verification Script

```bash
#!/bin/bash
# Save as: verify-delegation-output.sh
# Usage: ./verify-delegation-output.sh file1.md file2.md file3.md

echo "🔍 Verifying delegation outputs..."
missing=0

for file in "$@"; do
  if [ -f "$file" ]; then
    size=$(wc -c < "$file")
    lines=$(wc -l < "$file")
    echo "✅ $file (${size} bytes, ${lines} lines)"
  else
    echo "❌ MISSING: $file"
    missing=$((missing + 1))
  fi
done

if [ $missing -gt 0 ]; then
  echo ""
  echo "⚠️  WARNING: $missing file(s) missing!"
  echo "   Extract content from subagent response and use Write tool"
  exit 1
else
  echo ""
  echo "✅ All files verified successfully"
  exit 0
fi
```

## Integration with Progress.md

When manual file creation is required, add entry:

```markdown
### [2025-11-10 15:30] Post-Delegation File Creation

**Context**: Delegated documentation creation to @analyst

**What Happened**:
- Analyst provided comprehensive content but couldn't create files
- Three files were designed but not created:
  - post-mortem.md (930 lines)
  - verification-checklist.md (446 lines)
  - verify-delegation.sh (60 lines)

**Action Taken**:
- Manually executed Write tool for each file
- Verified creation with ls and wc commands
- All files confirmed present and correct size

**Files Created**:
- `/path/to/post-mortem.md` - Complete analysis with timeline
- `/path/to/verification-checklist.md` - Step-by-step verification guide
- `/path/to/verify-delegation.sh` - Automation script for verification

**Prevention**:
- Updated coordinator with FILE CREATION VERIFICATION PROTOCOL
- Added mandatory verification after every file delegation
- Changed delegation phrasing to request Write tool calls explicitly

**Root Cause**:
Task tool limitation - subagents can design but not execute file operations

**Resolution**:
Coordinator must always verify file existence and create files manually using Write tool
```

## When to Use This Checklist

Use this checklist after delegating:
- Documentation creation (READMEs, guides, reports)
- Analysis outputs (post-mortems, assessments)
- Configuration files (CLAUDE.md, .env templates)
- Scripts (automation, deployment)
- Any Task tool delegation mentioning "create", "write", "generate" for files

## Emergency Recovery

If you discover files are missing hours later:

1. **Find the subagent response**: Search conversation history for content
2. **Extract content**: Copy full content from subagent's response
3. **Create files**: Use Write tool for each missing file
4. **Verify**: Check files exist and have reasonable content
5. **Update progress.md**: Log the recovery and root cause
6. **Apply lesson**: Use verification checklist from now on

---

**Last Updated**: 2025-11-10
**Purpose**: Prevent file creation verification failures in Task tool delegations
**Critical**: Always verify file existence after delegation - subagents cannot create files directly
