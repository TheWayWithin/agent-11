---
name: planarchive
description: Archive completed/stale content from project-plan.md and progress.md
---

# PLAN ARCHIVE COMMAND 📦

**Command**: `/planarchive [options]`

**Purpose**: Archive completed/stale content from tracking files to keep them lean and token-efficient while preserving full historical record.

## WHAT IS PLANARCHIVE?

PlanArchive is a cleanup command that moves completed phases, old entries, and resolved issues from active tracking files (project-plan.md, progress.md) to archive files. This reduces token overhead when agents read these files while preserving complete project history.

## KEY FEATURES

- **Smart Detection**: Identifies completed phases, resolved issues, and stale entries
- **Safe Archival**: Preserves all content in archive files (reversible)
- **Token Optimization**: Reports estimated token savings
- **Dry Run Mode**: Preview changes before execution
- **Configurable Thresholds**: Adjust age-based archival rules

## USAGE

```bash
# Interactive mode - preview and confirm
/planarchive

# Dry run - see what would be archived
/planarchive --dry-run

# Archive entries older than 7 days
/planarchive --days=7

# Force mode - no confirmation prompts
/planarchive --force

# Archive only progress.md
/planarchive --progress-only

# Archive only project-plan.md
/planarchive --plan-only
```

## OPTIONS

| Option | Description | Default |
|--------|-------------|---------|
| `--dry-run` | Preview without making changes | false |
| `--days=N` | Archive progress entries older than N days | 14 |
| `--force` | Skip confirmation prompts | false |
| `--progress-only` | Only archive progress.md | false |
| `--plan-only` | Only archive project-plan.md | false |
| `--monthly` | Use monthly archive files | false |

## ARCHIVE LOCATIONS

- **project-plan-archive.md** - Archived phases, milestones, completed task blocks
- **progress-archive.md** - Archived progress entries and resolved issues

Alternative (with `--monthly`):
- **archives/project-plan-YYYY-MM.md** - Monthly rollups
- **archives/progress-YYYY-MM.md** - Monthly rollups

## ARCHIVAL RULES

### What Gets Archived from project-plan.md

- ✅ Completed phases (all tasks marked `[x]`)
- ✅ Milestones with past dates AND all tasks complete
- ✅ Retrospective sections from completed sprints
- ✅ Resolved/mitigated risks
- ✅ Locked-in architecture decisions

### What MUST Stay in project-plan.md

- ❌ Executive summary and objectives
- ❌ Current active phase (even if partially complete)
- ❌ Next planned phase
- ❌ Active risks and blockers
- ❌ Success metrics (until project complete)

### What Gets Archived from progress.md

- ✅ Entries older than threshold (default: 14 days)
- ✅ Resolved issues with documented root cause
- ✅ Completed deliverable logs
- ✅ Incorporated lessons learned

### What MUST Stay in progress.md

- ❌ Entries from current sprint/phase
- ❌ Active/unresolved issues
- ❌ Last 5-7 entries minimum
- ❌ Current day's work
- ❌ Lessons not yet incorporated into CLAUDE.md

## EXECUTION FLOW

### Interactive Mode (Default)

1. **Analysis Phase**:
   - Scan both tracking files
   - Identify content qualifying for archival
   - Calculate token savings

2. **Summary Display**:
   ```
   📊 Archive Analysis Complete
   
   project-plan.md:
   - Found 3 completed phases (425 lines)
   - Found 2 resolved risk sections (45 lines)
   
   progress.md:
   - Found 28 entries older than 14 days (890 lines)
   - Found 12 resolved issues (340 lines)
   
   Estimated token reduction: ~4,250 tokens (68% reduction)
   ```

3. **Confirmation Prompt**:
   ```
   Archive this content? [y/n/dry-run]: 
   ```

4. **Execution & Summary**:
   ```
   ✅ Archived to project-plan-archive.md (470 lines)
   ✅ Archived to progress-archive.md (1,230 lines)
   
   📁 Active file sizes:
   - project-plan.md: 1,255 → 785 lines (37% reduction)
   - progress.md: 2,100 → 870 lines (59% reduction)
   ```

### Dry Run Mode

Shows exactly what would be archived without making changes:
- Lists each section/entry that qualifies
- Shows excerpts of content to be archived
- Displays projected file sizes
- Exits without modifications

## ARCHIVE FILE FORMAT

```markdown
# [Project Name] Archive

> Archived content from tracking files
> Last archive: 2025-11-21 14:30
> Source: ./project-plan.md, ./progress.md

---

## Archive Index

| Date | Source | Description | Lines |
|------|--------|-------------|-------|
| 2025-11-21 | project-plan.md | Sprint 2 Phases 1-3 | 245 |
| 2025-11-14 | progress.md | Nov 1-14 entries | 389 |

---

## [2025-11-21 14:30] Archive: Sprint 2 Completion

**Source**: project-plan.md
**Reason**: All phases completed
**Lines**: 245

[Archived content preserved exactly as-is]

---
```

## SAFETY GUARDRAILS

### Minimum Retention (Non-Overridable)

- Always keep executive summary in project-plan.md
- Always keep current + next phase
- Always keep last 3 progress entries regardless of age
- Never archive unresolved issues
- Never archive content from current day

### Validation Checks

- Verify archive file is writable before starting
- Check for merge conflicts with existing archive
- Validate resulting files have required sections
- Atomic operation: full success or no changes

### Recovery

- All archived content preserved in archive files
- Archive operations logged in progress.md
- Rollback: Copy content from archive back to source file

## INTEGRATION

### With Other Commands

- **After `/coord` mission completion**: Suggested cleanup point
- **Before `/coord` mission start**: Clean slate for new mission
- **After `/dailyreport`**: Archive older daily entries
- **During `/pmd` analysis**: Reference archived issues for patterns

### Context Preservation

- Updates agent-context.md with archive summary (if exists)
- Adds archive operation to handoff-notes.md
- Logs operation in progress.md

## TOKEN EFFICIENCY NOTES

**Why Markdown (not JSON/YAML)?**

Analysis shows Markdown remains optimal for tracking files:
- ~10-20% fewer tokens than JSON for same content
- Better human readability
- Cleaner git diffs
- Native LLM comprehension (Claude trained on Markdown)

**Markdown Optimization Tips** (applied automatically):
- Compress timestamps: `2025-01-15 14:30` not `### [2025-01-15 14:30:00 UTC]`
- Flatten shallow nesting where possible
- Remove redundant labels when context is clear

## EDGE CASES

### Nothing to Archive

If no content qualifies:
```
ℹ️ No content qualifies for archival.

Suggestions:
- Decrease --days threshold (current: 14)
- Wait for phase completion
- Use --include-completed to force archive completed tasks
```

### No Tracking Files

```
⚠️ No tracking files found.
Initialize with `/coord dev-setup` or create project-plan.md manually.
```

### Large Archive File

If archive exceeds 5000 lines:
```
⚠️ Archive file is large (6,200 lines).
Consider using --monthly for monthly rollup structure.
```

## BEST PRACTICES

### When to Run

1. **End of sprint/phase** - Natural archive point
2. **Before major mission** - Start with clean context
3. **When files feel slow** - Token overhead affecting performance
4. **Monthly maintenance** - Regular hygiene

### Recommended Workflow

```bash
# 1. Preview first
/planarchive --dry-run

# 2. If satisfied, execute
/planarchive

# 3. Verify results
cat project-plan.md | wc -l
cat progress.md | wc -l
```

## SUCCESS CRITERIA

After `/planarchive` execution:

- [ ] Active files contain only current/relevant content
- [ ] All archived content preserved with full fidelity
- [ ] Archive includes timestamp and reason for each block
- [ ] Operation logged in progress.md
- [ ] Token reduction quantified and reported

---

*The /planarchive command keeps your tracking files lean and efficient while preserving complete project history for reference and auditing.*
