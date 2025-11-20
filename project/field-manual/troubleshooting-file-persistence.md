# Troubleshooting File Persistence Issues

## Overview

If you're experiencing issues where agents report creating files but those files don't appear on your filesystem, you've encountered the **Task Tool File Persistence Limitation**. This guide will help you verify, recover, and prevent this issue.

**Important**: This is a known architectural limitation with established workarounds. Sprint 2 (Days 6-12) will implement a strategic fix that eliminates this issue entirely.

## Symptoms - What to Watch For

### Primary Symptom
Agent reports successful file creation with verification output:
```
✅ Created /path/to/file.ts
✅ Verified with ls: file.ts exists
✅ Files successfully created: 14 files
```

But when you check the filesystem yourself:
```bash
$ ls /path/to/
ls: /path/to/file.ts: No such file or directory
```

### Warning Signs
1. **Agent verification passes** but files missing when you check
2. **No error messages** during file creation (silent failure)
3. **Happens after Task tool delegation** (coordinator delegated file creation to specialist)
4. **100% reproducibility** - happens every time in this scenario

## Verification - How to Check

### Step 1: Independent Verification
After any file creation task, **always verify independently**:

```bash
# For single file
ls -lh /absolute/path/to/file.ts

# For multiple files
find /absolute/path/to/directory -type f -name "*.ts" -mtime -1

# Content spot-check (confirms not just empty file)
head -n 5 /absolute/path/to/file.ts
```

### Step 2: Check Mission Logs
Look in `progress.md` for file creation entries:
```markdown
### [YYYY-MM-DD HH:MM] Files Created
- /path/to/file1.ts
- /path/to/file2.ts
✅ Files verified on filesystem: [timestamp]
```

**If timestamp missing** → Files not verified, likely don't exist

### Step 3: Verification Checklist
After Task delegation involving file operations:
- [ ] Agent has returned with completion report
- [ ] Run `ls -lh` on ALL reported file paths independently
- [ ] At least ONE file opened with Read tool to verify content
- [ ] All expected files confirmed present on filesystem
- [ ] Verification timestamp documented in progress.md
- [ ] Task marked [x] ONLY after all checks pass

## Recovery - Steps When Files Are Missing

If verification shows files don't exist, **don't panic** - the content is recoverable:

### Step 1: Locate Agent Response
Find the agent's response in the conversation history. It contains the file content even if the file wasn't created.

### Step 2: Extract Content
Copy the file content from the agent's response. Look for:
- Code blocks with file content
- Write tool call parameters
- Complete file specifications

### Step 3: Coordinator Manual Creation
Coordinator executes Write tool directly:

```
Write(
  file_path="/absolute/path/to/file.ts",
  content="""[paste complete content from agent response]"""
)
```

### Step 4: Verify Creation
```bash
ls -lh /absolute/path/to/file.ts
head -n 5 /absolute/path/to/file.ts
```

### Step 5: Document Recovery
Update `progress.md`:
```markdown
### [YYYY-MM-DD HH:MM] File Persistence Recovery

**What Happened**:
- Delegated file creation to @developer via Task tool
- Developer provided file content but files didn't persist
- Manually executed Write tool with developer's content

**Files Recovered**:
- /path/to/file1.ts (verified: [timestamp])
- /path/to/file2.ts (verified: [timestamp])

**Prevention**: Following Sprint 1 Phase 1A/1B protocol for future operations
```

## Prevention - Best Practices (Sprint 1)

Sprint 1 Phases 1A-1B implemented enhanced protocols:

### Protocol 1: Coordinator Direct Implementation (Preferred)
If coordinator can create files directly with Write tool → **DO THAT**
- Skip Task delegation for file operations
- Coordinator writes files based on specialist analysis
- Immediate filesystem persistence guarantee

### Protocol 2: Specialist Provides Specifications
If must delegate analysis:
```
Task(
  subagent_type="developer",
  prompt="Analyze X and provide EXACT Write tool call specifications.
          Include absolute paths and complete content.
          Do NOT attempt file creation - provide specifications only."
)
```

Coordinator then executes the specifications.

### Protocol 3: Mandatory Verification
**After EVERY file operation**:
1. Run filesystem verification commands
2. Document verification timestamp in progress.md
3. Mark task [x] ONLY after confirmation

### Protocol 4: Reference Enhanced Instructions
Coordinator.md now contains:
- FILE CREATION LIMITATION section
- Detailed verification protocols
- Recovery procedures
- Sprint 2 timeline reference

## Strategic Fix - Sprint 2 Solution

**Timeline**: Days 6-12 (see project-plan.md)

**Approach**: Coordinator-as-executor pattern
- Specialists provide analysis and specifications
- Coordinator executes ALL file operations directly
- Eliminates Task tool file operations entirely
- Zero file persistence issues by design

**Benefits**:
- No manual verification needed
- No recovery procedures required
- Guaranteed filesystem persistence
- Simplified mission workflows

**Status**: Documented in project-plan.md Sprint 2 Phase 2A

## Additional Resources

- **CLAUDE.md**: Complete file persistence limitation documentation
- **coordinator.md**: Enhanced delegation protocols
- **project-plan.md**: Sprint 2 strategic fix timeline
- **progress.md**: Real examples of issue and recovery

## Support

If you encounter this issue:
1. Follow recovery steps above
2. Document in progress.md with "File Persistence Recovery" heading
3. Reference this guide in your notes
4. Continue mission using Sprint 1 protocols

**Remember**: This is a temporary limitation with established workarounds. Sprint 2 eliminates it permanently.

---

*Last Updated: 2025-01-12*
*Sprint: 1 Phase 1C*
*Strategic Fix: Sprint 2 Phase 2A*