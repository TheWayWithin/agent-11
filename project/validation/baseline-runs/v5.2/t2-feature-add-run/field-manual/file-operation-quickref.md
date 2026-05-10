# File Operation Quick Reference (Sprint 6)

**Purpose**: Scannable, copy-paste reference for coordinator file operation execution.
**Related**: `templates/file-operation-delegation.md`, `migration-guides/file-persistence-v2.md`

---

## Quick Execution Checklist

After receiving specialist response with file operations:

```
☐ 1. PARSE: Find file_operations JSON in response
☐ 2. VALIDATE: Check paths are absolute, content complete
☐ 3. EXECUTE: Call Write/Edit tools with JSON parameters
☐ 4. VERIFY: ls -la [path] && head -n 5 [path]
☐ 5. LOG: Update progress.md with verification timestamp
☐ 6. COMPLETE: Mark [x] only after all checks pass
```

---

## Step 1: Parse JSON from Response

**Look for** (in priority order):

1. JSON code block:
```json
{
  "file_operations": [...]
}
```

2. Generic code block with JSON:
```
{
  "file_operations": [...]
}
```

3. Inline JSON (less common)

**If no JSON found**: Do NOT mark complete. Re-delegate with explicit JSON requirement.

---

## Step 2: Validate JSON

**Required for each operation**:

| Field | Valid Example | Invalid Example |
|-------|---------------|-----------------|
| `file_path` | `/Users/jamie/project/src/auth.ts` | `src/auth.ts` (relative) |
| `content` | Complete file content | `...rest of code` |
| `operation` | `create`, `edit`, `delete` | `write`, `update` |

**For edit operations**:
- `old_string` must be unique in file
- `new_string` must be different from old_string

---

## Step 3: Execute Operations

### Create Operation
```
Write(
  file_path="/absolute/path/to/file.ts",
  content="...complete content from JSON..."
)
```

### Edit Operation
```
Edit(
  file_path="/absolute/path/to/file.ts",
  old_string="exact text from JSON",
  new_string="replacement text from JSON"
)
```

### Delete Operation (Rare - Use Caution)
```
Bash: rm /absolute/path/to/file.ts
```

### Multiple Operations
Execute sequentially. For dependencies, order matters:
1. Create parent files first
2. Then files that import them
3. Then edits to existing files

---

## Step 4: Verify Files

**MANDATORY after every execution**:

### Single File
```bash
ls -la /absolute/path/to/file.ts    # Confirms existence and size
head -n 5 /absolute/path/to/file.ts  # Confirms content
```

### Multiple Files
```bash
ls -la /path/to/file1.ts /path/to/file2.ts
head -n 3 /path/to/file1.ts
head -n 3 /path/to/file2.ts
```

### What to Check
- File exists (ls shows file)
- Size is reasonable (not 0 bytes)
- Content starts correctly (head shows expected code)

---

## Step 5: Log to progress.md

**Format**:
```markdown
### [YYYY-MM-DD HH:MM] File Operations Completed
**Specialist**: @developer
**Files Created**:
- `/path/to/auth.ts` (2.3KB) ✅ verified
- `/path/to/config.ts` (1.1KB) ✅ verified

**Files Modified**:
- `/path/to/index.ts` - Added auth import ✅ verified

**Verification Commands Used**:
- ls -la /path/to/auth.ts /path/to/config.ts
- head -n 10 /path/to/auth.ts
```

---

## Step 6: Mark Complete

**Only after ALL verification passes**:

```markdown
- [x] Implement authentication (@developer) - ✅ 2025-11-29 15:30
  - **Deliverables**: `src/auth.ts`, `src/config.ts` (verified on filesystem)
  - **Quality**: Complete implementation, all imports valid
  - **Next**: @tester for validation
```

---

## Common Error Recovery

### Error: No JSON in Response

**Specialist said**: "I've created the authentication file..."
**Problem**: Natural language, not structured output

**Recovery**:
1. Extract content from code blocks in response
2. Create JSON manually:
```json
{
  "file_operations": [
    {
      "operation": "create",
      "file_path": "/path/inferred/from/context",
      "content": "extracted from specialist response",
      "description": "manually created JSON"
    }
  ]
}
```
3. Execute and verify
4. Log: "Manual JSON extraction required"

---

### Error: Relative Path

**JSON contains**: `"file_path": "src/auth.ts"`
**Problem**: Not absolute path

**Recovery**:
1. Identify project root from context
2. Construct absolute path: `/Users/jamie/project/src/auth.ts`
3. Update JSON and execute
4. Log: "Path correction applied"

---

### Error: Incomplete Content

**JSON contains**: `"content": "...rest of implementation"`
**Problem**: Placeholder, not complete content

**Recovery**:
1. Do NOT execute
2. Re-delegate with explicit requirement:
   ```
   "Your previous response contained placeholder content ('...rest of implementation').
   REQUIRED: Provide COMPLETE file content with no placeholders."
   ```
3. Wait for corrected response

---

### Error: File Not Created (Post-Execution)

**Verification shows**: `ls: cannot access '/path/to/file.ts': No such file`
**Problem**: Write tool may have failed silently

**Recovery**:
1. Check for error messages in Write tool output
2. Verify path exists (create directories if needed)
3. Re-execute Write tool
4. Verify again
5. Log: "Required re-execution - initial Write failed"

---

## Worked Example: Complete Flow

### 1. Specialist Response
```json
{
  "file_operations": [
    {
      "operation": "create",
      "file_path": "/Users/jamie/project/src/auth/jwt.ts",
      "content": "import { sign, verify } from 'jsonwebtoken';\n\nexport function createToken(payload: object): string {\n  return sign(payload, process.env.JWT_SECRET!);\n}\n\nexport function validateToken(token: string): object {\n  return verify(token, process.env.JWT_SECRET!) as object;\n}",
      "description": "JWT utilities for authentication"
    }
  ]
}
```

### 2. Validation Check
- ✅ file_path is absolute
- ✅ content is complete (no placeholders)
- ✅ operation is "create"

### 3. Execution
```
Write(
  file_path="/Users/jamie/project/src/auth/jwt.ts",
  content="import { sign, verify } from 'jsonwebtoken';\n..."
)
```

### 4. Verification
```bash
ls -la /Users/jamie/project/src/auth/jwt.ts
# -rw-r--r--  1 jamie  staff  342 Nov 29 15:30 /Users/jamie/project/src/auth/jwt.ts

head -n 5 /Users/jamie/project/src/auth/jwt.ts
# import { sign, verify } from 'jsonwebtoken';
#
# export function createToken(payload: object): string {
#   return sign(payload, process.env.JWT_SECRET!);
# }
```

### 5. Log to progress.md
```markdown
### [2025-11-29 15:30] File Operation Completed
**Specialist**: @developer
**Files Created**: `/Users/jamie/project/src/auth/jwt.ts` (342 bytes) ✅ verified
**Verification**: ls confirms file, head confirms JWT import pattern
```

### 6. Mark Complete
```markdown
- [x] Create JWT utilities (@developer) - ✅ 2025-11-29 15:30
```

---

## Quick Commands Reference

| Action | Command |
|--------|---------|
| Verify existence | `ls -la [path]` |
| Check content | `head -n 10 [path]` |
| Count lines | `wc -l [path]` |
| Full content | `cat [path]` (use sparingly) |
| Multiple files | `ls -la file1 file2 file3` |
| Directory listing | `ls -la [directory]/` |

---

## Red Flags Checklist

**Do NOT mark complete if you see**:

- ❌ "file created successfully" without JSON
- ❌ "wrote the file to..." without file_operations
- ❌ Relative paths (no leading /)
- ❌ Placeholder content ("...rest", "// TODO")
- ❌ ls shows file size 0
- ❌ head shows unexpected content

**If any red flag**: Stop, recover, re-verify.

---

**Version**: Sprint 6 (2025-11-29)
**Related Docs**:
- `templates/file-operation-delegation.md`
- `migration-guides/file-persistence-v2.md`
- `coordinator.md` STRUCTURED OUTPUT PARSING PROTOCOL
