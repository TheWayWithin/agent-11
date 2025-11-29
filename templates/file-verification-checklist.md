# File Verification Checklist Template

**Purpose**: Copy-paste checklist for verifying file operations after specialist delegation.
**Usage**: Add to progress.md after each file operation execution.

---

## Single File Verification

```markdown
### File Verification - [YYYY-MM-DD HH:MM]

**Task**: [Brief description]
**Specialist**: @[name]
**File**: `[absolute path]`

**Verification Steps**:
- [ ] JSON parsed from specialist response
- [ ] Write/Edit tool executed by coordinator
- [ ] `ls -la [path]` confirms file exists
- [ ] `head -n 5 [path]` confirms correct content
- [ ] File size is reasonable (not 0 bytes)
- [ ] Content matches expected pattern

**Result**: ☐ VERIFIED | ☐ FAILED - [reason]
**Logged by**: Coordinator
```

---

## Multiple File Verification

```markdown
### File Verification - [YYYY-MM-DD HH:MM]

**Task**: [Brief description]
**Specialist**: @[name]
**Files Expected**: [count]

| File | Exists? | Size | Content Check | Status |
|------|---------|------|---------------|--------|
| `/path/to/file1.ts` | ☐ Yes | [size] | ☐ Correct | ☐ ✅ |
| `/path/to/file2.ts` | ☐ Yes | [size] | ☐ Correct | ☐ ✅ |
| `/path/to/file3.ts` | ☐ Yes | [size] | ☐ Correct | ☐ ✅ |

**Verification Commands Used**:
```bash
ls -la /path/to/file1.ts /path/to/file2.ts /path/to/file3.ts
head -n 3 /path/to/file1.ts
head -n 3 /path/to/file2.ts
```

**Result**: [X/Y] files verified | ☐ All PASS | ☐ FAILED - [files]
**Logged by**: Coordinator
```

---

## Mixed Operations Verification

```markdown
### File Verification - [YYYY-MM-DD HH:MM]

**Task**: [Brief description]
**Specialist**: @[name]

**Created Files**:
| File | Exists? | Size | Content | Status |
|------|---------|------|---------|--------|
| `/path/new.ts` | ☐ Yes | [size] | ☐ OK | ☐ ✅ |

**Edited Files**:
| File | Edit Applied? | Content Changed? | Status |
|------|---------------|------------------|--------|
| `/path/existing.ts` | ☐ Yes | ☐ Correct | ☐ ✅ |

**Deleted Files**:
| File | Deleted? | Safety Check | Status |
|------|----------|--------------|--------|
| `/path/old.ts` | ☐ Yes | ☐ No deps | ☐ ✅ |

**Result**: ☐ All operations verified | ☐ FAILED - [operations]
```

---

## Failure Recovery Checklist

```markdown
### Verification FAILED - [YYYY-MM-DD HH:MM]

**Task**: [Brief description]
**Specialist**: @[name]
**Expected Files**: [list]
**Actual Files Found**: [list]

**Failure Details**:
| File | Expected | Actual | Issue |
|------|----------|--------|-------|
| `/path/file.ts` | Exists | Missing | Write tool failed |

**Recovery Actions**:
- [ ] Re-execute Write tool with same parameters
- [ ] Verify parent directory exists
- [ ] Check for path typos
- [ ] Re-delegate with explicit JSON requirement

**Recovery Result**: ☐ RESOLVED | ☐ ESCALATE
**Recovery Timestamp**: [YYYY-MM-DD HH:MM]
```

---

## Quick Verification Commands

```bash
# Single file - existence and content
ls -la /path/to/file.ts && head -n 10 /path/to/file.ts

# Multiple files - existence check
ls -la /path/file1.ts /path/file2.ts /path/file3.ts

# Directory listing
ls -la /path/to/directory/

# Count lines in created file
wc -l /path/to/file.ts

# Verify edit was applied (search for new content)
grep "expected content" /path/to/file.ts
```

---

## Integration with progress.md

**After successful verification, add to progress.md**:

```markdown
### [YYYY-MM-DD HH:MM] File Operations Completed

**Specialist**: @developer
**Task**: Implement authentication middleware

**Files Created**:
- `/src/middleware/auth.ts` (2.3KB, 45 lines) ✅ verified
- `/src/types/auth.ts` (1.1KB, 22 lines) ✅ verified

**Files Modified**:
- `/src/index.ts` - Added auth middleware import ✅ verified

**Verification**: All 3 operations verified via ls/head commands
**Timestamp**: 2025-11-29 15:45:23
```

---

## Task Completion Gate

**Before marking task [x] in project-plan.md, verify**:

```
☐ All file_operations JSON parsed correctly
☐ All Write/Edit tools executed by coordinator
☐ All files verified with ls -la (exist with reasonable size)
☐ At least one file content-checked with head
☐ Verification logged in progress.md
☐ No placeholder content in created files
☐ No relative paths used
```

**If ANY check fails**: Do NOT mark [x]. Re-execute or escalate.

---

**Version**: Sprint 6 (2025-11-29)
