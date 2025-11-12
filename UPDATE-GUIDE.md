# AGENT-11 Update Guide

**How to Update Your Project's CLAUDE.md with Critical Safeguards**

---

## Quick Start (Choose Your Method)

### 🚀 Method 1: Automated Script (Recommended)

**Step 1**: Navigate to your project
```bash
cd /path/to/your/project
```

**Step 2**: Run the update script
```bash
# Interactive mode (asks for confirmation)
/path/to/agent-11/project/deployment/scripts/update-claude-md.sh

# Or automatic mode (applies immediately, creates backup)
/path/to/agent-11/project/deployment/scripts/update-claude-md.sh --auto

# Or dry-run mode (preview changes only)
/path/to/agent-11/project/deployment/scripts/update-claude-md.sh --dry-run
```

**Done!** Your CLAUDE.md is now updated with file persistence safeguards.

---

### ✋ Method 2: Manual Update (Full Control)

**Step 1**: Backup your CLAUDE.md
```bash
cd /path/to/your/project
cp CLAUDE.md CLAUDE.md.backup-$(date +%Y%m%d)
```

**Step 2**: Open both files side-by-side
```bash
code CLAUDE.md CLAUDE-AGENT11-TEMPLATE.md
# Or your preferred editor
```

**Step 3**: Copy these sections from template to your CLAUDE.md:

#### Section 1: FILE PERSISTENCE BUG & SAFEGUARDS
- **Template location**: Search for "### ⚠️ CRITICAL: FILE PERSISTENCE BUG"
- **Your CLAUDE.md location**: Insert BEFORE "### CONTEXT PRESERVATION REQUIREMENT"
- **Size**: ~60 lines

#### Section 2: Enhanced Critical Requirements
- **Template location**: Search for "### Critical Requirements"
- **Your CLAUDE.md location**: Replace existing "Critical Requirements" section
- **Size**: ~8 lines

**Step 4**: Verify the update
```bash
grep -n "FILE PERSISTENCE BUG" CLAUDE.md
# Should return the line number where section exists
```

---

## What Gets Updated

### 1. New Section: FILE PERSISTENCE BUG & SAFEGUARDS

**What it does**: Documents critical bug where Task delegation + Write tool fails to persist files
**Contains**:
- Bug characteristics and symptoms
- Evidence from production failures (6+ hours lost)
- Mandatory prevention protocol
- Verification checklist with bash commands
- Recovery procedures
- Bug reporting template

**Impact**: Prevents silent file creation failures that waste hours of work

### 2. Enhanced Critical Requirements

**What it does**: Adds mandatory filesystem verification before marking tasks complete
**Contains**:
- Requirement to verify files with ls/Read tool
- Timestamp documentation requirement
- Reference to FILE PERSISTENCE BUG section

**Impact**: Ensures coordinators never trust agent reports without verification

---

## Verification Steps

After updating, verify everything is in place:

### 1. Check CLAUDE.md has new section
```bash
cd /path/to/your/project
grep -c "FILE PERSISTENCE BUG" CLAUDE.md
# Should return: 1 or more
```

### 2. Check coordinator.md has alert
```bash
grep -c "FILE PERSISTENCE BUG ALERT" .claude/agents/coordinator.md
# Should return: 1
```

### 3. Test verification script
```bash
# Copy verification script
mkdir -p scripts
cp /path/to/agent-11/project/deployment/scripts/verify-files.sh scripts/
chmod +x scripts/verify-files.sh

# Test it
./scripts/verify-files.sh CLAUDE.md
# Should output: ✅ EXISTS: CLAUDE.md
```

---

## New Tools Available

After updating, you'll have access to:

### 1. Verification Script
**Location**: `scripts/verify-files.sh` (after copying)
**Purpose**: Automatically verify files exist on filesystem
**Usage**:
```bash
./scripts/verify-files.sh file1.ts file2.ts file3.ts
```

### 2. Troubleshooting Guide
**Location**: Copy from AGENT-11 to your project
```bash
mkdir -p docs/troubleshooting
cp /path/to/agent-11/project/field-manual/troubleshooting/task-delegation-file-persistence.md \
   docs/troubleshooting/
```

---

## Why This Update Is Critical

**Without these safeguards** (what happened in production):
1. Coordinator delegates file creation to @developer
2. @developer reports: "✅ Created 14 files successfully"
3. @developer shows verification: `ls` output listing all files
4. Reality check: **0 files exist on filesystem**
5. Result: 6+ hours of work lost, mission blocked

**With these safeguards**:
1. Same delegation scenario
2. Coordinator runs mandatory verification: `ls -lh [files]`
3. Detection: 0 files exist = BUG HIT
4. Coordinator uses workaround: direct Write tool
5. Result: Files created successfully, mission continues

**Time saved**: 6+ hours per occurrence

---

## Troubleshooting

### "Script says CLAUDE.md already updated"

If the script detects the FILE PERSISTENCE BUG section already exists:
- Your CLAUDE.md may already be updated
- Or you may have a partial update
- Choose "Continue anyway" to verify/complete the update

### "Cannot find CONTEXT PRESERVATION REQUIREMENT section"

If your CLAUDE.md is heavily customized and missing this section:
- Script will append the FILE PERSISTENCE BUG section to the end
- Manually move it to appropriate location if needed

### "Coordinator.md doesn't have bug alert"

If your coordinator agent wasn't updated with the working squad:
- Run AGENT-11 install.sh again to update agents
- Or manually add the alert from template

### "Verification script not working"

Common issues:
```bash
# Not executable
chmod +x scripts/verify-files.sh

# Wrong directory
cd /path/to/your/project  # Must run from project root

# Files don't exist
ls -la file.ts  # Check file actually exists
```

---

## Support & Documentation

**Full Details**: `CRITICAL-UPDATE-2025-11-12.md`

**Troubleshooting Guide**: `project/field-manual/troubleshooting/task-delegation-file-persistence.md`

**Verification Script**: `project/deployment/scripts/verify-files.sh`

**Update Script**: `project/deployment/scripts/update-claude-md.sh`

**Questions?**: Open an issue in AGENT-11 repository

---

## Update Checklist

Use this to track your update:

- [ ] Backup created: `CLAUDE.md.backup-YYYYMMDD`
- [ ] Update method chosen (automated or manual)
- [ ] Update applied to CLAUDE.md
- [ ] FILE PERSISTENCE BUG section verified (grep test)
- [ ] Critical Requirements section enhanced
- [ ] Verification script copied to project
- [ ] Verification script tested successfully
- [ ] Troubleshooting guide copied (optional)
- [ ] Coordinator aware of new protocol
- [ ] Ready to use `/coord` with safeguards active

---

**Last Updated**: 2025-11-12
**Version**: AGENT-11 v2.1 (File Persistence Safeguards Release)
