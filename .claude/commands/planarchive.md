---
name: planarchive
description: Intelligently archive completed/stale content from project-plan.md and progress.md
---

# PLAN ARCHIVE COMMAND 📦

**Command**: `/planarchive [options]`

**Purpose**: Intelligently archive completed/stale content from tracking files using semantic analysis, size-based triggers, and duplication detection to keep them lean and token-efficient while preserving full historical record.

## WHAT IS PLANARCHIVE?

PlanArchive is an **intelligent content manager** that uses semantic analysis to understand what content is truly active vs completed. It moves completed phases, old entries, and resolved issues from active tracking files (project-plan.md, progress.md) to archive files. This reduces token overhead when agents read these files while preserving complete project history.

**Key Innovation**: Unlike simple date-based archival, PlanArchive **understands completion status**, recognizes duplicated content, and generates summaries automatically.

## KEY FEATURES

- **Semantic Analysis**: Understands completion status, dates, and section hierarchy
- **Size-Based Triggers**: Automatically archives large completed sections
- **Duplication Detection**: Identifies content duplicated across tracking files
- **Smart Summaries**: Auto-generates concise summaries of archived content
- **User Control**: Multiple modes (aggressive, analyze, target-based)
- **Token Optimization**: Reports estimated token savings
- **Safe Archival**: Preserves all content in archive files (reversible)

## USAGE

```bash
# Interactive mode - analyze and confirm
/planarchive

# Analyze mode - see what WOULD be archived with reasoning
/planarchive --analyze

# Aggressive mode - archive ALL completed work regardless of age
/planarchive --aggressive

# Target size mode - archive until reaching specific line count
/planarchive --target-lines=1200

# Check for duplicates across tracking files
/planarchive --check-duplicates

# Archive entries older than 7 days (default: 14)
/planarchive --days=7

# Dry run - preview without making changes
/planarchive --dry-run

# Force mode - no confirmation prompts
/planarchive --force

# Archive only progress.md
/planarchive --progress-only

# Archive only project-plan.md
/planarchive --plan-only

# Disable summary generation (keep full content)
/planarchive --no-summaries
```

## OPTIONS

| Option | Description | Default |
|--------|-------------|---------|
| `--analyze` | Show what would be archived with reasoning and scores | false |
| `--aggressive` | Archive ALL completed sprints regardless of age | false |
| `--target-lines=N` | Archive until reaching N lines in active file | - |
| `--check-duplicates` | Identify and report duplicated content | false |
| `--dry-run` | Preview without making changes | false |
| `--days=N` | Archive progress entries older than N days | 14 |
| `--force` | Skip confirmation prompts | false |
| `--progress-only` | Only archive progress.md | false |
| `--plan-only` | Only archive project-plan.md | false |
| `--no-summaries` | Keep full content instead of generating summaries | false |
| `--monthly` | Use monthly archive files | false |

## ARCHIVE LOCATIONS

- **project-plan-archive.md** - Archived phases, milestones, completed task blocks
- **progress-archive.md** - Archived progress entries and resolved issues

Alternative (with `--monthly`):
- **archives/project-plan-YYYY-MM.md** - Monthly rollups
- **archives/progress-YYYY-MM.md** - Monthly rollups

## INTELLIGENT ARCHIVAL RULES

### Automatic Archival Triggers

PlanArchive uses **5 smart triggers** to identify archivable content:

#### 1. Completed Sprint Rule
- **IF**: Section header contains "Sprint" AND status contains "COMPLETE" or "✅"
- **AND**: Completion date > 7 days ago (or --aggressive ignores date)
- **THEN**: Archive all subsections, keep 3-5 sentence summary

**Example**:
```markdown
## Sprint 1: Alpha Arena Implementation ✅ COMPLETE
**Completed**: 2025-11-19 to 2025-11-20
[692 lines of detailed tasks]

→ Archives to: project-plan-archive.md with summary
→ Summary: "Implemented 3 monitors based on DeepSeek analysis. Expected +44% profit improvement. Completed Nov 19-20, 2025."
```

#### 2. Size-Based Rule
- **IF**: Section > 500 lines AND marked complete
- **THEN**: Archive detailed tasks, keep executive summary

**Rationale**: Large completed sections bloat context unnecessarily

#### 3. Dated Phase Rule
- **IF**: Phase status = "COMPLETE" AND date < (today - 7 days)
- **THEN**: Archive implementation details, keep status + outcomes

**Example**:
```markdown
### Week 9: Deployment & Testnet Validation ✅ COMPLETE
**Status**: Phase 3 COMPLETE - System deployed
[400 lines of deployment logs]

→ Archives to: project-plan-archive.md
→ Keeps: Status line + 2 sentence outcome
```

#### 4. Duplication Rule
- **IF**: Content type = "environment variables" OR "config template"
- **AND**: File exists in .env.example or config files
- **THEN**: Replace with reference link

**Example**:
```markdown
### Environment Setup
[150 lines of .env template]

→ Removes from plan
→ Replaces with: "See .env.example for environment variables"
```

#### 5. Historical Detail Rule
- **IF**: Section contains: code snippets, step-by-step guides, bug fixes
- **AND**: Parent section marked complete
- **THEN**: Archive to preserve history, replace with summary

**Example**:
```markdown
#### Task 1.1: Add Invalidation Level Tracking
**Implementation**: [200 lines of code snippets and steps]

→ Archives detailed implementation
→ Keeps: "Implemented InvalidationMonitor with DeepSeek pattern"
```

### Archival Scoring System

Each section gets scored for archival priority:

```
Archival Score = (age_days × 0.3) + (size_lines × 0.2) + (completion_status × 0.5)
```

**Scoring Components**:
- **Age**: 0-30 days → 0.0-1.0
- **Size**: 0-1000 lines → 0.0-1.0
- **Completion**: COMPLETE=1.0, PARTIAL=0.5, ACTIVE=0.0

**Archival Thresholds**:
- Score ≥ 0.8: High priority (archive immediately)
- Score 0.5-0.8: Medium priority (archive if target not met)
- Score < 0.5: Low priority (keep in active file)

### What Gets Archived from project-plan.md

- ✅ Completed sprints (all tasks marked `[x]`)
- ✅ Completed phases > 7 days old (or all with --aggressive)
- ✅ Large completed sections (> 500 lines)
- ✅ Milestones with past dates AND all tasks complete
- ✅ Retrospective sections from completed sprints
- ✅ Resolved/mitigated risks
- ✅ Locked-in architecture decisions
- ✅ Configuration templates (if exist in separate files)
- ✅ Detailed implementation logs (if parent complete)

### What MUST Stay in project-plan.md

- ❌ Executive summary and objectives
- ❌ Current active phase (even if partially complete)
- ❌ Next planned phase(s)
- ❌ Active risks and blockers
- ❌ Success metrics (until project complete)
- ❌ Any section with pending tasks `[ ]`
- ❌ Content from last 7 days (unless --aggressive)

### What Gets Archived from progress.md

- ✅ Entries older than threshold (default: 14 days)
- ✅ Resolved issues with documented root cause
- ✅ Completed deliverable logs
- ✅ Incorporated lessons learned
- ✅ Entries duplicated in CLAUDE.md

### What MUST Stay in progress.md

- ❌ Entries from current sprint/phase
- ❌ Active/unresolved issues
- ❌ Last 5-7 entries minimum
- ❌ Current day's work
- ❌ Lessons not yet incorporated into CLAUDE.md

## SEMANTIC ANALYSIS

PlanArchive performs **3 levels of analysis**:

### 1. Section Structure Parsing
- Identify all `##` and `###` headers
- Extract status markers: `✅ COMPLETE`, `📋 PLANNED`, `⏳ IN PROGRESS`
- Extract dates: completion, start, last update
- Build section hierarchy tree

### 2. Content Type Classification

**Executive Summary** (KEEP):
- High-level goals, objectives, vision
- Project overview
- Success criteria

**Active Work** (KEEP):
- Sections with pending `[ ]` tasks
- Status: IN PROGRESS or PLANNED
- Recent updates (< 7 days)

**Completed Work** (ARCHIVE):
- All tasks marked `[x]`
- Status: COMPLETE or ✅
- Completion date > threshold

**Configuration Templates** (MOVE/REMOVE):
- Environment variable listings
- Setup instructions duplicated elsewhere
- Templates available in separate files

**Implementation Details** (ARCHIVE):
- Code snippets from completed work
- Step-by-step implementation logs
- Detailed bug fix descriptions

### 3. Cross-File Duplication Detection

Checks for content duplicated in:
- **progress.md**: Sprint completion logs
- **.env.example**: Environment variables
- **architecture.md**: Design decisions
- **completed-project-plan.md**: Historical archive
- **CLAUDE.md**: Incorporated lessons

## EXECUTION MODES

### Interactive Mode (Default)

1. **Analysis Phase**:
   ```
   🔍 Analyzing project-plan.md...
   - Parsed 15 sections, 2,845 lines
   - Found 3 completed sprints (age: 12-25 days)
   - Found 2 large completed sections (>500 lines)
   - Detected 1 duplication (.env template)

   🔍 Analyzing progress.md...
   - Parsed 45 entries, 1,890 lines
   - Found 28 entries older than 14 days
   - Found 12 resolved issues
   ```

2. **Summary Display**:
   ```
   📊 Archive Analysis Complete

   project-plan.md:
   ┌─────────────────────────────────────────────────┐
   │ Section                    Lines   Age   Score  │
   ├─────────────────────────────────────────────────┤
   │ Sprint 1: Alpha Arena       692    25d   0.92  │
   │ Sprint 2: Integration       487    18d   0.85  │
   │ Week 9: Deployment          412    12d   0.73  │
   │ .env Template (duplicate)   150     -    1.00  │
   └─────────────────────────────────────────────────┘
   Total archival: 1,741 lines (61% reduction)

   progress.md:
   - 28 entries older than 14 days (890 lines)
   - 12 resolved issues (340 lines)
   Total archival: 1,230 lines (65% reduction)

   Estimated token reduction: ~4,250 tokens (63% reduction)
   ```

3. **Confirmation Prompt**:
   ```
   Archive this content? [y/n/details]:
   ```

4. **Execution & Summary**:
   ```
   ✅ Archived to project-plan-archive.md (1,741 lines)
      - Sprint 1: 692 lines → 85 line summary
      - Sprint 2: 487 lines → 72 line summary
      - Week 9: 412 lines → 65 line summary
      - .env: 150 lines → removed (duplicate)

   ✅ Archived to progress-archive.md (1,230 lines)

   📁 Active file sizes:
   - project-plan.md: 2,845 → 1,104 lines (61% reduction)
   - progress.md: 1,890 → 660 lines (65% reduction)

   📝 Operation logged in progress.md
   ```

### Analyze Mode (`--analyze`)

Shows **what would be archived with detailed reasoning**:

```bash
/planarchive --analyze
```

Output:
```
📊 Archival Analysis (DRY RUN)

project-plan.md - Sections Qualifying for Archival:
┌──────────────────────────────────────────────────────────────────┐
│ Section: Sprint 1: Alpha Arena Implementation                    │
├──────────────────────────────────────────────────────────────────┤
│ Lines: 692                                                       │
│ Status: ✅ COMPLETE                                              │
│ Completed: 2025-11-19 to 2025-11-20 (25 days ago)               │
│ Score: 0.92 (Age: 0.83, Size: 0.69, Complete: 1.0)              │
│                                                                  │
│ Triggers:                                                        │
│  ✓ Completed Sprint Rule (status COMPLETE + date >7 days)       │
│  ✓ Size-Based Rule (692 lines > 500 line threshold)             │
│                                                                  │
│ Action: Archive full content, replace with summary              │
│ Summary: "Implemented 3 monitors (InvalidationMonitor,           │
│           FeeMonitor, CapitalPreservationManager) based on       │
│           DeepSeek #1 winner analysis. Expected +44% monthly     │
│           profit improvement. Completed Nov 19-20, 2025."        │
│                                                                  │
│ Archive Location: project-plan-archive.md (lines TBD)           │
└──────────────────────────────────────────────────────────────────┘

[Additional sections listed similarly...]

🎯 Target Size Analysis:
- Current: 2,845 lines (estimated ~34,000 tokens)
- After archival: 1,104 lines (estimated ~13,200 tokens)
- Reduction: 61% (20,800 tokens saved)

💡 Recommendations:
- Archival quality: EXCELLENT (high-value targets)
- Token efficiency: Would achieve <15,000 token target
- No active work affected: All pending tasks preserved
```

### Aggressive Mode (`--aggressive`)

Archives **ALL completed work** regardless of age:

```bash
/planarchive --aggressive
```

**Behavior**:
- Ignores 7-day age threshold
- Archives any section marked COMPLETE/✅
- Useful after major milestones or before starting new phases
- Still preserves active work and summaries

### Target Size Mode (`--target-lines=N`)

Archives until reaching specific line count:

```bash
/planarchive --target-lines=1200
```

**Behavior**:
- Prioritizes highest-scoring sections first
- Stops when active file ≤ target lines
- Reports sections archived and final size

**Example**:
```
🎯 Target: Reduce project-plan.md to ≤1200 lines (current: 2,845)

Archival sequence:
1. Sprint 1 (score 0.92, 692 lines) → Remaining: 2,153
2. Sprint 2 (score 0.85, 487 lines) → Remaining: 1,666
3. Week 9 (score 0.73, 412 lines) → Remaining: 1,254
4. .env duplicate (score 1.00, 150 lines) → Remaining: 1,104

✅ Target achieved: 1,104 lines (61% reduction)
```

### Check Duplicates Mode (`--check-duplicates`)

Identifies content duplicated across tracking files:

```bash
/planarchive --check-duplicates
```

**Output**:
```
🔍 Duplication Analysis

project-plan.md:
┌────────────────────────────────────────────────────────┐
│ Duplicate Content Found                                │
├────────────────────────────────────────────────────────┤
│ Section: Environment Setup                             │
│ Lines: 150                                             │
│ Content: .env template with 45 variables               │
│ Also in: .env.example (identical)                      │
│ Recommendation: Remove from plan, add reference        │
│                 "See .env.example for configuration"   │
└────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────┐
│ Section: Sprint 2 Completion Log                      │
│ Lines: 187                                             │
│ Content: Detailed completion notes                     │
│ Also in: progress.md (2025-11-20 to 2025-11-22)       │
│ Recommendation: Archive from plan, keep in progress    │
└────────────────────────────────────────────────────────┘

progress.md:
┌────────────────────────────────────────────────────────┐
│ Section: Security-First Development Principles        │
│ Lines: 95                                              │
│ Content: Development principles                        │
│ Also in: CLAUDE.md (identical)                         │
│ Recommendation: Remove from progress (incorporated)    │
└────────────────────────────────────────────────────────┘

Total duplicated content: 432 lines across 3 files
Potential savings: ~5,200 tokens
```

## SUMMARY GENERATION

When archiving completed sections, PlanArchive **automatically generates concise summaries**:

### Summary Rules

**For Completed Sprints**:
1. **Status Line**: `## Sprint X: [Name] ✅ COMPLETE`
2. **Completion Info** (2-3 sentences):
   - When completed (dates)
   - What was delivered (key features/files)
   - Impact/outcome (metrics if available)
3. **Archive Reference**: `**Archived**: Detailed tasks in project-plan-archive.md ([lines X-Y])`
4. **Key Stats** (1 line): Files created, lines written, tests passing, time spent

**Example Generated Summary**:
```markdown
## Sprint 1: Alpha Arena Implementation ✅ COMPLETE

**Completed**: Nov 19-20, 2025. Implemented 3 critical monitors (InvalidationMonitor, FeeMonitor, CapitalPreservationManager) based on DeepSeek #1 winner analysis. Expected +44% monthly profit improvement, +50% Sharpe ratio improvement. Integration completed in Sprint 2.

**Archived**: Detailed task breakdowns in project-plan-archive.md (lines 450-1142, 692 lines)

**Key Stats**: 8 files created, 1,247 lines added, 12/12 tests passing, 2 days
```

### Disable Summaries

Use `--no-summaries` to keep full content in archive without generating summaries:

```bash
/planarchive --no-summaries
```

**Use case**: When you want complete historical record in active file for reference

## ARCHIVE FILE FORMAT

```markdown
# [Project Name] Archive

> Archived content from tracking files
> Last archive: 2025-11-21 14:30
> Source: ./project-plan.md, ./progress.md

---

## Archive Index

| Date | Source | Description | Lines | Score |
|------|--------|-------------|-------|-------|
| 2025-11-21 | project-plan.md | Sprint 2 Phases 1-3 | 487 | 0.85 |
| 2025-11-21 | project-plan.md | Sprint 1 Full | 692 | 0.92 |
| 2025-11-14 | progress.md | Nov 1-14 entries | 389 | 0.67 |

---

## [2025-11-21 14:30] Archive: Sprint 1 - Alpha Arena Implementation

**Source**: project-plan.md (lines 145-837)
**Reason**: Completed Sprint Rule + Size-Based Rule
**Archival Score**: 0.92 (Age: 0.83, Size: 0.69, Complete: 1.0)
**Status**: ✅ COMPLETE
**Completed**: 2025-11-19 to 2025-11-20 (25 days ago)
**Triggers**:
- Completed Sprint Rule (status COMPLETE + date >7 days)
- Size-Based Rule (692 lines > 500 line threshold)

**Summary Kept in Active File**:
> Implemented 3 monitors based on DeepSeek analysis. Expected +44% profit improvement. Completed Nov 19-20, 2025.

**Full Content**:

[Archived content preserved exactly as-is, 692 lines]

---

## [2025-11-21 14:30] Archive: Sprint 2 - Integration Phase

**Source**: project-plan.md (lines 840-1327)
**Reason**: Completed Sprint Rule
**Archival Score**: 0.85 (Age: 0.60, Size: 0.49, Complete: 1.0)
**Status**: ✅ COMPLETE
**Completed**: 2025-11-20 to 2025-11-22 (18 days ago)

[Content...]

---
```

## SIZE-BASED TARGETS & TOKEN BUDGETS

### Token Budget Analysis

PlanArchive tracks token usage and provides recommendations:

**Token Budget Levels**:
- **Optimal**: <15,000 tokens (excellent context efficiency)
- **Acceptable**: 15,000-25,000 tokens (moderate overhead)
- **Warning**: 25,000-35,000 tokens (inefficient, should archive)
- **Critical**: >35,000 tokens (mandatory archival)

**Line Count Targets**:
- **Ideal**: 800-1,200 lines (core planning + 1 active phase)
- **Acceptable**: 1,200-1,800 lines (multiple active phases)
- **Needs Archival**: >2,000 lines

**Section Size Limits**:
- **Completed sprint**: Max 100 lines (summary only)
- **Active sprint**: Max 400 lines (full detail for current work)
- **Historical deployment**: Max 50 lines (outcome summary)

### Token Estimation

```
Estimated tokens = lines × 12 (average tokens per line for project plans)
```

**Example**:
```
project-plan.md: 2,845 lines × 12 = ~34,140 tokens (⚠️ WARNING LEVEL)
After archival: 1,104 lines × 12 = ~13,248 tokens (✅ OPTIMAL)
```

## SAFETY GUARDRAILS

### Minimum Retention (Non-Overridable)

- Always keep executive summary in project-plan.md
- Always keep current + next phase
- Always keep last 3 progress entries regardless of age
- Never archive unresolved issues
- Never archive content from current day
- Never archive sections with pending `[ ]` tasks
- Always generate summary unless `--no-summaries`

### Validation Checks

**Pre-Archival**:
- [ ] Verify archive file is writable
- [ ] Check for merge conflicts with existing archive
- [ ] Confirm no active work in archival candidates
- [ ] Validate section parsing (no orphaned content)

**Post-Archival**:
- [ ] Validate resulting files have required sections
- [ ] Verify all pending tasks still present
- [ ] Confirm archive references are correct
- [ ] Check file sizes meet targets
- [ ] Atomic operation: full success or no changes

### Backup & Recovery

**Automatic Backup**:
- Creates timestamped backups before archival
- Location: `.backups/project-plan-YYYYMMDD-HHMMSS.md`
- Kept for 30 days

**Rollback Process**:
1. Locate backup: `ls .backups/ | grep project-plan`
2. Copy content from archive back to source file
3. Remove archive entry
4. Log rollback in progress.md

**Example Rollback**:
```bash
# Restore from backup
cp .backups/project-plan-20251121-143000.md project-plan.md

# Or restore specific section from archive
# 1. Open project-plan-archive.md
# 2. Find archived section by date/description
# 3. Copy content back to project-plan.md
# 4. Remove archive entry
```

## INTEGRATION

### With Other Commands

- **After `/coord` mission completion**: Natural archive point
- **Before `/coord` mission start**: Clean slate for new mission
- **After `/dailyreport`**: Archive older daily entries
- **During `/pmd` analysis**: Reference archived issues for patterns

### Context Preservation

When running in mission context:
- Updates `agent-context.md` with archive summary (if exists)
- Adds archive operation to `handoff-notes.md`
- Logs operation in `progress.md`

### Progress Tracking

Logs archival operation:
```markdown
### [2025-11-21 14:30] Archive Operation

**Command**: `/planarchive --aggressive`
**Files Processed**:
- project-plan.md: 2,845 → 1,104 lines (61% reduction, 1,741 archived)
- progress.md: 1,890 → 660 lines (65% reduction, 1,230 archived)

**Content Archived**:
- Sprint 1: Alpha Arena (692 lines, score 0.92)
- Sprint 2: Integration (487 lines, score 0.85)
- Week 9: Deployment (412 lines, score 0.73)
- .env duplicate removed (150 lines)
- 28 progress entries >14 days old (1,230 lines)

**Token Savings**: ~4,250 tokens (63% reduction)
**Archive Location**: project-plan-archive.md, progress-archive.md
**Backup Location**: .backups/project-plan-20251121-143000.md
```

## EDGE CASES

### Nothing to Archive

If no content qualifies:
```
ℹ️ No content qualifies for archival.

Current state:
- project-plan.md: 1,104 lines, ~13,248 tokens (✅ OPTIMAL)
- progress.md: 660 lines, ~7,920 tokens (✅ OPTIMAL)
- No completed sprints >7 days old
- No large completed sections

Suggestions:
- Your tracking files are already well-optimized
- Run /planarchive --analyze to see scoring details
- Use --days=3 for more aggressive age threshold
- Use --aggressive to force archive all completed work
```

### No Tracking Files

```
⚠️ No tracking files found.

Initialize with:
- /coord dev-setup  (for new projects)
- Create project-plan.md manually
```

### Large Archive File

If archive exceeds 5000 lines:
```
⚠️ Archive file is large (6,200 lines).

Recommendations:
- Use --monthly for monthly rollup structure
- Consider splitting by sprint/phase
- Archive older content to completed-project-plan.md
```

### All Content is Active

If everything has pending tasks or recent updates:
```
ℹ️ All content appears active (no archival candidates).

Analysis:
- 0 completed sprints found
- 0 sections with all tasks [x]
- All content updated within 7 days

This is normal for:
- Projects in active development
- Recently cleaned tracking files
- Early-stage projects
```

## BEST PRACTICES

### When to Run

1. **End of sprint/phase** - Natural archive point
2. **Before major mission** - Start with clean context
3. **When files feel slow** - Token overhead affecting performance
4. **Monthly maintenance** - Regular hygiene
5. **After milestones** - Preserve history, clear space
6. **Token budget warning** - Files >25,000 tokens

### Recommended Workflow

```bash
# 1. Analyze first (understand what will happen)
/planarchive --analyze

# 2. Check for duplicates (optional but recommended)
/planarchive --check-duplicates

# 3. If satisfied, execute
/planarchive

# 4. Verify results
wc -l project-plan.md progress.md
cat project-plan-archive.md | head -50  # Check archive format
```

### Sprint/Phase Cleanup Workflow

```bash
# After completing a sprint
/planarchive --aggressive  # Archive ALL completed work

# Before starting new sprint
/planarchive --target-lines=1200  # Reach ideal size

# Monthly maintenance
/planarchive --days=30 --monthly  # Archive by month
```

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
- Use tables for structured data (more token-efficient)

## SUCCESS CRITERIA

After `/planarchive` execution:

- [ ] Active files contain only current/relevant content
- [ ] All archived content preserved with full fidelity
- [ ] Archive includes timestamp, reason, and score for each block
- [ ] Summaries generated for all completed sprints
- [ ] Operation logged in progress.md
- [ ] Token reduction quantified and reported
- [ ] Backup created automatically
- [ ] No pending tasks accidentally archived
- [ ] Cross-file duplicates identified/removed

## TROUBLESHOOTING

### Issue: "Too much was archived"

**Solution**: Restore from backup
```bash
cp .backups/project-plan-[timestamp].md project-plan.md
```

### Issue: "Not enough was archived"

**Solution**: Use aggressive mode
```bash
/planarchive --aggressive --target-lines=1200
```

### Issue: "Can't find archived content"

**Solution**: Check archive index
```bash
head -50 project-plan-archive.md  # Shows index with line numbers
```

### Issue: "Archival scores seem wrong"

**Solution**: Run analyze mode to see reasoning
```bash
/planarchive --analyze
```

---

*The /planarchive command uses semantic analysis, size-based triggers, and duplication detection to intelligently manage your tracking files. It understands completion status, generates summaries automatically, and provides multiple control modes for different use cases.*
