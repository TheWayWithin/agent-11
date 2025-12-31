# Post Mortem Analysis: File Persistence Issues with /coord Command

**Date**: 2025-11-28
**Severity**: High (recurring architectural issue)
**Issue**: File operations via `/coord` delegation don't persist when specialists attempt to create files

---

## Executive Summary

When using `/coord complete sprint 5`, file creation delegated to specialists via Task tool fails to persist. This is a **known architectural limitation** documented in CLAUDE.md, but the protocol to prevent it isn't being consistently followed during `/coord` missions.

The system has a documented solution (Sprint 2 Structured Output Protocol), but it requires the coordinator to:
1. Request structured JSON output from specialists
2. Parse the JSON response
3. Execute Write/Edit tools itself
4. Verify files exist on filesystem

When any of these steps are skipped, files vanish.

---

## Root Cause Analysis

### Primary Cause: Architectural Limitation of Task Tool

**The Problem** (from CLAUDE.md line 420):
> "Task tool delegation + Write tool operations have an architectural limitation where files created in delegated agent contexts don't persist to the host filesystem after agent completion."

**Why It Happens**:
- Specialists operate in isolated execution contexts
- Write tool calls within Task delegations execute in that isolated context
- When the Task completes, the context is destroyed
- Files created within that context don't persist to the host filesystem

**Evidence**:
- 100% reproducibility across multiple attempts
- Agent reports success with `ls` verification inside context
- Post-execution: 0 files on host filesystem

### Contributing Factors

1. **Prompt Format Not Enforcing JSON Output**
   - When coordinator delegates with "create files for X", specialists attempt to use Write tool
   - Should delegate with "provide file_operations JSON for X"

2. **Missing Automatic JSON Parsing**
   - Sprint 2 protocol requires coordinator to parse JSON and execute Write tool
   - This step is manual and easy to skip when busy orchestrating

3. **Verification Steps Skipped**
   - `ls -la` verification should happen after coordinator executes Write tool
   - Often skipped when coordinator assumes specialist "did the work"

4. **Documentation Exists But Not Enforced**
   - CLAUDE.md has comprehensive protocol (lines 418-505)
   - coord.md has instructions (lines 125-178)
   - coordinator.md has detailed protocol (lines 300-400)
   - But nothing prevents coordinator from delegating incorrectly

---

## What the Protocol SHOULD Be (Sprint 2)

### Correct Flow

```
1. Coordinator delegates:
   Task(subagent_type="developer", prompt="Provide file_operations JSON for...")

2. Specialist returns:
   {"file_operations": [{"operation": "create", "file_path": "/path/file.ts", "content": "..."}]}

3. Coordinator parses JSON

4. Coordinator executes:
   Write(file_path="/path/file.ts", content="...specialist's content...")

5. Coordinator verifies:
   ls -la /path/file.ts
   head -n 5 /path/file.ts

6. Coordinator marks complete only after verification
```

### What Actually Happens (Bug Case)

```
1. Coordinator delegates:
   Task(subagent_type="developer", prompt="Create files for...")

2. Specialist attempts Write tool (in isolated context)

3. Specialist reports "Files created successfully"

4. Coordinator marks complete

5. Files don't exist on host filesystem
```

---

## Why This Keeps Happening

| Factor | Issue |
|--------|-------|
| **Cognitive Load** | Coordinator is juggling many phases; easy to forget JSON format |
| **Prompt Habits** | Natural to say "create X" instead of "provide JSON for X" |
| **Trust in Agents** | When specialist says "done", coordinator believes it |
| **No Enforcement** | Nothing blocks incorrect delegation format |
| **Manual Steps** | JSON parsing and Write execution are manual |

---

## Recommendations

### Immediate (Today)

1. **For Current Sprint 5 Files**: Verify all created files exist
   ```bash
   ls -la .mcp-profiles/*.json
   ls -la project/field-manual/mcp-optimization-guide.md
   ```

2. **For Future /coord Missions**: Always use structured output format:
   ```
   Task(subagent_type="developer", prompt="
     Provide file_operations JSON for creating auth.ts:
     {
       'file_operations': [
         {'operation': 'create', 'file_path': '...', 'content': '...'}
       ]
     }
   ")
   ```

### Short-Term (This Week)

1. **Add Pre-Flight Check to coord.md**:
   Before any file operation delegation, verify prompt includes:
   - [ ] "Provide file_operations JSON"
   - [ ] "DO NOT attempt to create files"
   - [ ] JSON schema example

2. **Add Warning Detection**:
   If specialist response contains "file created" or "wrote file" without returning JSON, flag as potential violation.

### Long-Term (This Month)

1. **Automatic JSON Parsing Engine**:
   Add to coordinator agent a section that automatically:
   - Detects file_operations JSON in specialist response
   - Parses and executes Write/Edit tools
   - Verifies with ls/head
   - Logs to progress.md

2. **Delegation Linter**:
   Before executing Task tool, validate prompt format:
   - Reject prompts containing "create file" or "write file"
   - Require "file_operations JSON" language

3. **File Operation Wrapper Tool**:
   Create a coordinator-only tool that:
   - Takes specialist JSON output
   - Executes all file operations
   - Returns verification results

---

## Prevention Strategies

### Detection Mechanisms
- [ ] Alert when specialist says "created" but no coordinator Write tool follows
- [ ] Monitor for Task completions without subsequent file verification
- [ ] Track file_operations JSON presence in specialist responses

### Process Validations
- [ ] Pre-delegation checklist includes "structured output format required"
- [ ] Post-delegation checklist includes "execute Write tool from JSON"
- [ ] File verification mandatory before marking task complete

### Documentation Updates
- [ ] Add bold warning to coord.md about file persistence
- [ ] Create quick reference card for correct delegation format
- [ ] Add examples of right vs wrong delegation to mission templates

---

## Pattern Recognition

This is the **same architectural issue** documented from:
- 2025-01-11: ISOTracker - 14 files lost
- 2025-01-12: ISOTracker - Reproduction confirmed
- 2025-01-19: Sprint 1/2 fix implemented
- 2025-11-28: Sprint 5 - Issue recurred with /coord

**Pattern**: Issue recurs when:
1. Large multi-phase missions with many delegations
2. Coordinator is focused on orchestration, not file operations
3. Natural language ("create X") instead of structured output format
4. High cognitive load from complex missions

---

## Follow-up Actions

| Action | Owner | Priority | Status |
|--------|-------|----------|--------|
| Verify Sprint 5 files exist | Coordinator | HIGH | ✅ Complete |
| Update coord.md with warning | Documenter | HIGH | Pending |
| Add structured output examples | Documenter | MEDIUM | Pending |
| Create file operation wrapper | Developer | MEDIUM | Pending |
| Add delegation linter | Developer | LOW | Pending |

---

## Lessons Learned

1. **Architectural limitations require architectural solutions** - Prompt-based workarounds are fragile
2. **Documentation alone doesn't prevent issues** - Need enforcement mechanisms
3. **Cognitive load is the enemy** - Complex missions increase error rate
4. **Trust but verify** - Always check filesystem after specialist claims completion
5. **Manual steps get skipped** - Automation is the only reliable solution

---

*This post-mortem will be referenced in future missions to prevent recurrence.*

---
---
---

# Post Mortem Analysis: DailyReport Missing Sprint 4 Entries

**Date**: 2025-11-28
**Severity**: Low (data loss prevented by manual correction)
**Issue**: `/dailyreport` command excluded Sprint 4 (Opus 4.5) entries from daily report

---

## Executive Summary

The `/dailyreport` command only captured Sprint 5 entries, missing all Sprint 4 (Opus 4.5 Integration) work. This occurred because the command is designed to extract only entries matching **today's date**, and Sprint 4 entries were timestamped with `[2025-11-27]` while today is `2025-11-28`.

---

## Timeline of Events

1. **Sprint 4 completed**: Work logged to progress.md with date `[2025-11-27]`
2. **Sprint 5 completed**: Work logged to progress.md with date `[2025-11-28]`
3. **User runs `/dailyreport`**: Command extracts only `2025-11-28` entries
4. **Blog generated**: Only contains Sprint 5 content
5. **User notices**: "I thought we did a lot today on Opus 4.5 too"
6. **Manual fix applied**: Report manually updated to include both sprints

---

## Root Cause Analysis

### Primary Cause: Date-Strict Filtering by Design

The `/dailyreport` command documentation explicitly states:

```markdown
## DATE PARSING LOGIC

- Extract dates from progress.md entries in format: `### [YYYY-MM-DD HH:MM]`
- Match today's date (use system date as reference)
- If timestamp found, compare date portion only (ignore time)
```

**Evidence from progress.md**:
- Sprint 4 entries: `### [2025-11-27] - Sprint 4: Opus 4.5 Integration`
- Sprint 5 entries: `### [2025-11-28] - Sprint 5: MCP Context Optimization`

The command worked **exactly as designed** - it filtered for today's date (`2025-11-28`) and correctly excluded yesterday's entries (`2025-11-27`).

### Contributing Factor: Multi-Day Work Sessions

When work spans multiple calendar days but feels like "today" to the user (e.g., continuous session, or same context window), the strict date filtering creates a mismatch between user expectations and command behavior.

---

## Impact Assessment

| Aspect | Impact |
|--------|--------|
| Data Loss | None (manual correction applied) |
| User Experience | Moderate (confusion, extra work to fix) |
| Blog Quality | Initially incomplete, now corrected |
| Trust in Tool | Minor - user may question automation |

---

## Recommendations

### Immediate Fix (Applied)
✅ Manually updated `/progress/2025-11-28.md` to include both Sprint 4 and Sprint 5 content

### Short-Term Improvements

#### Option A: Add Date Range Parameter
```bash
# Allow specifying date range
/dailyreport --since 2025-11-27
/dailyreport --days 2
```

**Pros**: Flexible, explicit control
**Cons**: More complex, users must remember to use it

#### Option B: Session-Aware Extraction
Detect entries from the current continuous session (based on timestamps within X hours of each other), regardless of date boundaries.

**Pros**: Matches user mental model of "today's work"
**Cons**: Complex to implement, may include too much

#### Option C: Confirmation with Preview
Show extracted entries before generating report, ask user to confirm or add more.

**Pros**: User control, catches missing items
**Cons**: Extra step, less automated

### Recommended Approach: Option A + Warning

1. **Add `--since` parameter** to dailyreport command
2. **Add warning** when recent entries exist from previous day:
   ```
   ⚠️ Found 4 entries from 2025-11-27 (yesterday).
   Include them? Run: /dailyreport --since 2025-11-27
   ```

### Long-Term Enhancement

Update dailyreport.md command to include:

```markdown
## DATE RANGE SUPPORT

By default, `/dailyreport` extracts only TODAY's entries.

To include multiple days:
- `/dailyreport --since YYYY-MM-DD` - Include all entries from specified date
- `/dailyreport --days N` - Include last N days of entries

The command will warn if recent entries exist from previous days that might be relevant.
```

---

## Prevention Strategies

### Detection Mechanisms
- [ ] Add warning when progress.md has entries from previous 24 hours that won't be included
- [ ] Show entry count before generating: "Found X entries for 2025-11-28, Y entries from 2025-11-27"

### Process Improvements
- [ ] Document that dailyreport is date-strict in command help
- [ ] Consider "sprint mode" that captures entire sprint regardless of dates

### Validation Improvements
- [ ] Preview mode: `/dailyreport --preview` shows what will be included
- [ ] Interactive confirmation before finalizing report

---

## Follow-up Actions

| Action | Owner | Status |
|--------|-------|--------|
| Manually update report with Sprint 4 | Coordinator | ✅ Complete |
| Document date-strict behavior | Documenter | Pending |
| Implement `--since` parameter | Developer | Pending |
| Add recent entries warning | Developer | Pending |

---

## Lessons Learned

1. **Date filtering is not intuitive**: Users think in sessions/context, not calendar days
2. **Automation needs visibility**: Silent filtering causes confusion
3. **Design documentation helps**: The command worked as documented, but docs weren't consulted
4. **Quick manual fixes prevent escalation**: Catching this early avoided blog publishing with incomplete info

---

## Pattern Recognition

This issue relates to a broader pattern: **Automation assumptions vs. user mental models**

Similar issues:
- Git commits with wrong date/author
- Logs filtered by timestamp missing relevant context
- Reports that capture "today" but miss ongoing work

**Meta-lesson**: Any date-based filtering should include visibility into what's being excluded.

---

*Generated by /pmd command on 2025-11-28*
