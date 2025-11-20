# Project Lifecycle Management Guide

**Purpose**: Systematic guidance for managing project tracking files throughout mission lifecycle
**Target Audience**: @coordinator agents orchestrating multi-phase missions
**Last Updated**: 2025-10-19

---

## 📖 Table of Contents

1. [Lifecycle Overview](#lifecycle-overview)
2. [Active Project Phase](#active-project-phase)
3. [Milestone Transitions](#milestone-transitions)
4. [Project Completion](#project-completion)
5. [Handoff Archive Strategy](#handoff-archive-strategy)
6. [Lessons Extraction](#lessons-extraction)
7. [Archive Structure](#archive-structure)
8. [Cleanup Protocol](#cleanup-protocol)

---

## Lifecycle Overview

### The Three Phases of Project Files

```
ACTIVE PROJECT (Current Work)
├── project-plan.md          ← Forward-looking plan
├── progress.md              ← Backward-looking changelog
├── agent-context.md         ← Rolling context accumulator
├── handoff-notes.md         ← Current specialist context
├── evidence-repository.md   ← Artifacts collection
└── architecture.md          ← Technical design

MILESTONE TRANSITION (Strategic Pause)
├── Extract lessons → lessons/
├── Archive handoff-notes → archives/handoffs/
├── Update architecture.md with learnings
├── Create next milestone plan
└── Clean agent-context.md (keep essentials)

PROJECT COMPLETE (Archive & Learn)
├── Extract all lessons → lessons/index.md
├── Archive all context → archives/mission-YYYY-MM-DD/
├── Create mission summary
├── Update CLAUDE.md with system learnings
└── Prepare for next mission (fresh files)
```

### When Files Accumulate vs. When to Clean

**Always Accumulate** (Never clean, only grow):
- **progress.md** - Complete history of what happened
- **lessons/** - All learnings ever discovered
- **architecture.md** - Evolving design documentation

**Clean at Milestones** (Strategic reduction):
- **agent-context.md** - Archive completed phases, keep current
- **handoff-notes.md** - Archive and start fresh each milestone
- **evidence-repository.md** - Move old evidence to archives

**Clean at Completion** (Major reset):
- **project-plan.md** - Archive entire mission plan
- **agent-context.md** - Archive all context
- **handoff-notes.md** - Archive final handoff

---

## Active Project Phase

### Real-Time File Maintenance

**During Active Development** (Ongoing updates):

#### project-plan.md - Update Immediately When:
- [ ] New phase starts (add all phase tasks before work)
- [ ] Task completes (mark [x] after specialist confirmation)
- [ ] Blocker discovered (add to Dependencies section)
- [ ] Risk identified (add to Risks section)
- [ ] Milestone status changes
- [ ] Dependencies update

**Verification Protocol**:
```bash
# Before marking ANY task [x], verify:
1. Specialist returned Task tool response
2. Deliverable files exist at specified paths
3. handoff-notes.md updated by specialist
4. Quality spot-check passed
5. No blockers preventing next task
```

#### progress.md - Update Immediately When:
- [ ] Deliverable created/modified (log with description)
- [ ] Change made to code/configs (log with rationale)
- [ ] Issue discovered (create issue entry with symptom)
- [ ] Fix attempted (log attempt, even if failed)
- [ ] Issue resolved (add root cause analysis)
- [ ] Pattern recognized (add to Lessons Learned)

**Real-Time Logging Protocol**:
```markdown
### Issue #5: Authentication Token Expiry
**Discovered**: 2025-10-19 14:30 by @developer
**Status**: 🔴 Open

**Symptom**: Users logged out unexpectedly after 5 minutes

#### Fix Attempts
##### Attempt #1: Increase token expiry
**Result**: ❌ Failed
**Rationale**: Thought short token was the issue
**What We Tried**: Changed JWT expiry from 5min to 60min
**Outcome**: Issue persisted, users still logged out
**Learning**: Not a token expiry issue, must be refresh mechanism

##### Attempt #2: Fix refresh token rotation
**Result**: ✅ Success
**Rationale**: Refresh token not being stored properly
**What We Tried**: Added refresh token to localStorage with expiry check
**Outcome**: Users stay logged in correctly
**Learning**: Always check refresh mechanism before adjusting token expiry
```

#### agent-context.md - Update After Each Task:
- [ ] Specialist completes task
- [ ] Coordinator merges findings from handoff-notes.md
- [ ] Add new decisions and constraints
- [ ] Update known issues list
- [ ] Track dependencies discovered

**Merge Protocol**:
```markdown
## Recent Findings (Last 3 Tasks)

### [YYYY-MM-DD HH:MM] - @developer completed authentication
**Key Findings**:
- JWT implementation using HS256 algorithm
- Refresh tokens stored in HTTP-only cookies
- Token expiry: access 15min, refresh 7days

**Decisions Made**:
- Use cookie-based refresh tokens (more secure than localStorage)
- Implement automatic token refresh 2min before expiry

**Constraints Added**:
- Must support cross-origin requests (CORS configured)
- Browser must allow HTTP-only cookies

**Next Specialist Needs**:
- @tester to validate token security
- @operator to configure production cookie settings
```

#### handoff-notes.md - Update by Each Specialist:
- [ ] Specialist reads before starting task
- [ ] Specialist updates with findings during work
- [ ] Specialist writes complete handoff before finishing
- [ ] Next specialist reads to understand context

**Handoff Template**:
```markdown
# Handoff Notes

**Last Updated**: [YYYY-MM-DD HH:MM] by @[specialist]
**Next Specialist**: @[next-specialist]

## Current Task Completion
[What was just finished and verified]

## Critical Context for Next Task
[Essential information next specialist needs]

## Warnings & Gotchas
[Things that could go wrong or are tricky]

## Specific Instructions
[Exact steps or requirements for next work]

## Test Results (if applicable)
[What was tested and results]
```

### Daily Maintenance Checklist

**End of Day** (Every work session):
- [ ] All completed tasks marked [x] in project-plan.md
- [ ] All issues logged in progress.md with current status
- [ ] agent-context.md updated with day's findings
- [ ] handoff-notes.md ready for next specialist
- [ ] evidence-repository.md contains day's artifacts

**Weekly Review** (Every 7 days or major progress):
- [ ] Review milestone progress in project-plan.md
- [ ] Extract patterns to progress.md Lessons Learned
- [ ] Update success metrics in project-plan.md
- [ ] Check for risks becoming active
- [ ] Verify dependencies still on track

---

## Milestone Transitions

### When to Transition Between Milestones

**Transition Triggers**:
- Major feature complete (e.g., MVP → Beta)
- Phase gate passed (e.g., Development → Testing)
- Architecture shift (e.g., Monolith → Microservices)
- Team change (e.g., new specialists joining)
- 2-4 week duration (prevent file bloat)

### Milestone Transition Protocol (Step-by-Step)

**1. PRE-TRANSITION VERIFICATION**

Before starting transition, verify:
```bash
# Check all milestone tasks complete
grep '\[ \]' project-plan.md | grep "Milestone X"
# Should return no results if milestone complete

# Check no critical blockers
grep '🔴' project-plan.md
# Resolve all critical blockers first

# Verify all handoffs documented
grep 'Last Updated' handoff-notes.md
# Should be recent (within 24 hours)
```

**Checklist**:
- [ ] All milestone tasks verified [x] (not just marked)
- [ ] No critical blockers (🔴) remaining
- [ ] All issues in progress.md have status
- [ ] handoff-notes.md current within 24 hours
- [ ] evidence-repository.md contains all artifacts

**2. LESSONS EXTRACTION**

Extract milestone learnings before archiving:

```bash
# Create lessons directory if not exists
mkdir -p lessons/{patterns,issues,decisions}

# Extract lessons from progress.md to individual lesson files
# See "Lessons Extraction" section below for format
```

**Tasks**:
- [ ] Review progress.md for all milestone lessons
- [ ] Create individual lesson files in `lessons/`
- [ ] Update `lessons/index.md` with new lessons
- [ ] Tag lessons by category and severity
- [ ] Add search keywords to each lesson

**3. HANDOFF NOTES ARCHIVE**

Archive completed milestone handoffs:

```bash
# Create milestone archive directory
mkdir -p archives/handoffs/milestone-X-[name]

# Archive handoff-notes.md
cp handoff-notes.md archives/handoffs/milestone-X-[name]/handoff-notes-final.md

# Add archive metadata
cat >> archives/handoffs/milestone-X-[name]/README.md << 'EOF'
# Milestone X Handoff Archive

**Milestone**: [Name]
**Completed**: [YYYY-MM-DD]
**Key Decisions**: [Brief list]
**Major Issues Resolved**: [Issue IDs]
**Next Milestone**: [Name]
EOF
```

**Selective Retention Strategy**:

Keep in handoff-notes.md:
- ✅ Current phase context
- ✅ Active constraints
- ✅ Known issues affecting next work
- ✅ Recent decisions (last 3 tasks)

Archive from handoff-notes.md:
- 📦 Completed phase findings
- 📦 Resolved issues
- 📦 Historical context
- 📦 Old warnings no longer relevant

**4. AGENT CONTEXT CLEANUP**

Clean agent-context.md strategically:

```bash
# Archive old context sections
cat agent-context.md > archives/context/milestone-X-context.md

# Create clean agent-context.md for next milestone
cat > agent-context.md << 'EOF'
# Mission Context

**Mission**: [Name]
**Current Milestone**: [Milestone Y Name]
**Started**: [YYYY-MM-DD]

## Mission Objectives
[Carry forward from original]

## Technical Architecture (Current)
[Essential architecture decisions only]

## Active Constraints
[Current constraints affecting next work]

## Known Issues
[Only unresolved issues affecting next milestone]

## Recent Critical Decisions (Last Milestone)
[Key decisions from Milestone X that affect Milestone Y]

## Dependencies
[Current external dependencies]
EOF
```

**Retention Rules**:
- Keep: Mission objectives, architecture essentials, active constraints, unresolved issues
- Archive: Historical findings, resolved issues, completed phase details, old warnings

**5. UPDATE TRACKING FILES**

Prepare files for next milestone:

```bash
# Update project-plan.md
# - Mark Milestone X as ✅ Complete
# - Add Milestone Y tasks [ ]
# - Update timeline and dependencies

# Update progress.md
# - Add "Milestone X Complete" entry
# - List major achievements
# - Reference lessons extracted
# - Start Milestone Y section

# Keep architecture.md current
# - Add any architecture changes from Milestone X
# - Update technology decisions
# - Document new patterns discovered
```

**6. VERIFICATION & HANDOFF**

Before proceeding to next milestone:

- [ ] Lessons extracted to `lessons/` and indexed
- [ ] Old handoff archived to `archives/handoffs/milestone-X/`
- [ ] New handoff-notes.md contains only next milestone context
- [ ] agent-context.md cleaned but retains essentials
- [ ] project-plan.md updated with Milestone Y tasks
- [ ] progress.md has milestone completion entry
- [ ] architecture.md current with latest decisions
- [ ] All specialists briefed on milestone transition

**7. COMMUNICATION**

Update team and stakeholders:

```markdown
# Milestone X → Milestone Y Transition Summary

**Milestone X Achievements**:
- [Achievement 1]
- [Achievement 2]
- [Achievement 3]

**Lessons Learned**:
- [Key lesson 1]
- [Key lesson 2]

**Milestone Y Objectives**:
- [Objective 1]
- [Objective 2]

**What Changed**:
- Handoff notes archived and refreshed
- Agent context cleaned (essentials retained)
- Lessons extracted to searchable index

**What's Available**:
- `lessons/index.md` - All learnings searchable
- `archives/handoffs/milestone-X/` - Historical context
- `project-plan.md` - Updated with Milestone Y tasks
```

---

## Project Completion

### When to Complete Project

**Completion Criteria**:
- All primary objectives achieved
- All deliverables produced and verified
- All quality gates passed
- No critical issues remaining
- Stakeholder acceptance obtained

### Project Completion Protocol (Full Cleanup)

**1. FINAL VERIFICATION**

Complete pre-completion checklist:

```bash
# Verify all objectives met
grep '\[ \]' project-plan.md | wc -l
# Should be 0 for primary objectives

# Check quality metrics
grep 'Success Metrics' project-plan.md -A 20

# Verify no critical issues
grep '🔴' progress.md | grep 'Open'
# Should return no results
```

**Checklist**:
- [ ] All primary objectives ✅ Complete
- [ ] All deliverables produced and validated
- [ ] Quality metrics meet targets
- [ ] No critical (🔴) issues open
- [ ] All tests passing
- [ ] Documentation complete
- [ ] Stakeholder sign-off obtained

**2. COMPREHENSIVE LESSONS EXTRACTION**

Extract ALL mission learnings:

```bash
# Extract lessons from entire progress.md
# Create comprehensive lessons for:
# - Technical patterns
# - Common issues
# - Architectural decisions
# - Process improvements
# - Tool usage patterns

# Update lessons/index.md with complete catalog
```

**See "Lessons Extraction" section below for complete process**

**3. MISSION ARCHIVE CREATION**

Create permanent mission archive:

```bash
# Create mission archive directory
mkdir -p archives/missions/mission-[name]-$(date +%Y-%m-%d)
cd archives/missions/mission-[name]-$(date +%Y-%m-%d)

# Archive all tracking files
cp ../../project-plan.md ./
cp ../../progress.md ./
cp ../../agent-context.md ./
cp ../../architecture.md ./

# Archive final handoff
cp ../../handoff-notes.md ./handoff-notes-final.md

# Archive evidence
cp -r ../../evidence-repository/ ./evidence/

# Create mission summary
cat > MISSION-SUMMARY.md << 'EOF'
# Mission Summary: [Mission Name]

**Completed**: [YYYY-MM-DD]
**Duration**: [X weeks]
**Specialists**: [@list of agents involved]

## Objectives Achieved
- [Objective 1] ✅
- [Objective 2] ✅
- [Objective 3] ✅

## Major Deliverables
- [Deliverable 1 with path]
- [Deliverable 2 with path]

## Key Metrics
- **Tasks Completed**: [X]
- **Issues Resolved**: [X]
- **First-Time Success Rate**: [X%]
- **Timeline**: [On time | X days early/late]

## Top 5 Lessons Learned
1. [Lesson 1] - See lessons/[file]
2. [Lesson 2] - See lessons/[file]
3. [Lesson 3] - See lessons/[file]
4. [Lesson 4] - See lessons/[file]
5. [Lesson 5] - See lessons/[file]

## Technical Highlights
- [Architecture decision 1]
- [Technology choice 1]
- [Pattern discovery 1]

## Challenges Overcome
- [Challenge 1 and solution]
- [Challenge 2 and solution]

## Recommendations for Next Mission
- [Recommendation 1]
- [Recommendation 2]

## Archive Contents
- `project-plan.md` - Final mission plan
- `progress.md` - Complete changelog
- `architecture.md` - Technical documentation
- `agent-context.md` - Final context state
- `handoff-notes-final.md` - Final handoff
- `evidence/` - All artifacts and screenshots

**Access**: All materials archived for future reference and learning
EOF
```

**4. SYSTEM LEARNINGS UPDATE**

Update CLAUDE.md with system-level insights:

```bash
# Review lessons for system-level improvements
# Add to CLAUDE.md if:
# - Process improvement applicable to all missions
# - Tool usage pattern everyone should follow
# - Common anti-pattern to warn about
# - Architecture principle discovered
```

**System Learning Criteria**:
- Applies to ALL future missions (not project-specific)
- Prevents common mistakes or inefficiencies
- Improves coordination or delegation
- Enhances context preservation
- Strengthens security or quality practices

**5. FRESH START PREPARATION**

Prepare for next mission:

```bash
# Archive current files
mv project-plan.md archives/missions/mission-[name]-$(date +%Y-%m-%d)/
mv progress.md archives/missions/mission-[name]-$(date +%Y-%m-%d)/
mv agent-context.md archives/missions/mission-[name]-$(date +%Y-%m-%d)/
mv handoff-notes.md archives/missions/mission-[name]-$(date +%Y-%m-%d)/
mv evidence-repository.md archives/missions/mission-[name]-$(date +%Y-%m-%d)/

# Keep persistent files
# - architecture.md (evolves across missions)
# - lessons/ (permanent knowledge base)
# - CLAUDE.md (project configuration)

# Ready for next mission initialization
# Next mission will create fresh:
# - project-plan.md (from template)
# - progress.md (from template)
# - agent-context.md (from template)
# - handoff-notes.md (from template)
```

**What Persists Across Missions**:
- ✅ `architecture.md` - Evolving design documentation
- ✅ `lessons/` - Permanent knowledge repository
- ✅ `CLAUDE.md` - Project configuration
- ✅ `archives/` - Historical mission records

**What Starts Fresh Each Mission**:
- 🆕 `project-plan.md` - New mission plan
- 🆕 `progress.md` - New changelog
- 🆕 `agent-context.md` - New context accumulator
- 🆕 `handoff-notes.md` - New handoff notes
- 🆕 `evidence-repository.md` - New evidence collection

**6. COMPLETION COMMUNICATION**

Announce mission completion:

```markdown
# Mission Complete: [Mission Name]

**Completion Date**: [YYYY-MM-DD]
**Duration**: [X weeks]
**Status**: ✅ All objectives achieved

## Achievements
- [Major achievement 1]
- [Major achievement 2]
- [Major achievement 3]

## By the Numbers
- **Tasks Completed**: [X]
- **Issues Resolved**: [X]
- **Lessons Captured**: [X]
- **Timeline Performance**: [On time | X% ahead/behind]

## Knowledge Captured
- **Lessons Indexed**: [X] new lessons in `lessons/index.md`
- **Mission Archived**: `archives/missions/mission-[name]-YYYY-MM-DD/`
- **System Improvements**: [X] updates to CLAUDE.md

## What's Next
Ready for next mission. All tracking files reset. Knowledge preserved in:
- `lessons/` - Searchable lessons
- `architecture.md` - Current technical design
- `archives/` - Historical mission data

**Access Mission Archive**:
```bash
cd archives/missions/mission-[name]-YYYY-MM-DD
cat MISSION-SUMMARY.md
```
```

---

## Handoff Archive Strategy

### Selective Retention Philosophy

**PROBLEM**: Handoff-notes.md accumulates all specialist findings → file bloat → context confusion

**SOLUTION**: Archive completed work, retain only current context

### What to Archive vs. What to Keep

**Archive to `archives/handoffs/milestone-X/`**:
- ✅ Completed phase findings
- ✅ Resolved issue details
- ✅ Historical decisions (>1 milestone old)
- ✅ Old warnings no longer applicable
- ✅ Specialist findings from finished work

**Keep in Current `handoff-notes.md`**:
- ✅ Active phase context
- ✅ Unresolved issues affecting current work
- ✅ Recent decisions (last 3-5 tasks)
- ✅ Current warnings and gotchas
- ✅ Next specialist instructions

### Archive Format

```bash
archives/
└── handoffs/
    ├── milestone-1-requirements/
    │   ├── README.md              # Archive metadata
    │   ├── handoff-notes-final.md # Complete handoff at milestone end
    │   └── key-decisions.md       # Extracted decisions summary
    ├── milestone-2-development/
    │   ├── README.md
    │   ├── handoff-notes-final.md
    │   └── key-decisions.md
    └── milestone-3-testing/
        ├── README.md
        ├── handoff-notes-final.md
        └── key-decisions.md
```

### Archive Creation Command

```bash
# Archive handoff for completed milestone
archive_handoff() {
    local milestone_num=$1
    local milestone_name=$2

    # Create archive directory
    mkdir -p "archives/handoffs/milestone-${milestone_num}-${milestone_name}"

    # Copy current handoff
    cp handoff-notes.md \
        "archives/handoffs/milestone-${milestone_num}-${milestone_name}/handoff-notes-final.md"

    # Extract key decisions
    grep -A 5 "Decision" handoff-notes.md > \
        "archives/handoffs/milestone-${milestone_num}-${milestone_name}/key-decisions.md"

    # Create metadata
    cat > "archives/handoffs/milestone-${milestone_num}-${milestone_name}/README.md" << EOF
# Milestone ${milestone_num}: ${milestone_name} - Handoff Archive

**Archived**: $(date +%Y-%m-%d)
**Status**: Complete
**Next Milestone**: [Milestone $((milestone_num + 1))]

## Archive Contents
- handoff-notes-final.md: Complete handoff at milestone end
- key-decisions.md: Extracted decision summary

## Quick Reference
Key decisions and findings available in:
- lessons/index.md (searchable by category)
- agent-context.md (if still relevant)
- progress.md (chronological log)
EOF

    echo "Handoff archived to archives/handoffs/milestone-${milestone_num}-${milestone_name}/"
}

# Usage:
# archive_handoff 1 requirements
```

### Handoff Cleanup Process

After archiving, clean current handoff-notes.md:

```bash
# Create clean handoff for next milestone
cat > handoff-notes.md << 'EOF'
# Handoff Notes

**Mission**: [Mission Name]
**Current Milestone**: [Milestone Y]
**Last Updated**: [YYYY-MM-DD HH:MM]
**Next Specialist**: [Awaiting assignment]

## Mission Context (Essential Only)
[Brief mission objective - 2-3 sentences]

## Current Phase Status
[What milestone/phase we're in]

## Active Constraints
[Current constraints affecting next work]

## Known Issues (Unresolved)
[Only issues affecting current/next work]

## Recent Critical Decisions (This Milestone)
[Key decisions from current milestone only]

## Next Task Context
[What the next specialist needs to know]

## Archived Context
Previous milestone handoffs available in:
- `archives/handoffs/milestone-1-[name]/`
- `archives/handoffs/milestone-2-[name]/`
EOF
```

---

## Lessons Extraction

### When to Extract Lessons

**Continuous Extraction** (As discovered):
- Add to `progress.md` Lessons Learned section immediately
- Tag with category and severity
- Reference related issue IDs

**Milestone Extraction** (Every 2-4 weeks):
- Review all lessons in progress.md
- Create individual lesson files in `lessons/`
- Update `lessons/index.md` with new lessons
- Cross-reference related lessons

**Mission Complete Extraction** (End of project):
- Extract ALL lessons from progress.md
- Create comprehensive lesson files
- Build complete searchable index
- Identify patterns and themes

### Lesson Extraction Process

**1. REVIEW PROGRESS.MD FOR LESSONS**

```bash
# Find all lesson entries
grep -A 10 "## 🎓 Lessons Learned" progress.md

# Extract by category
grep -B 2 -A 8 "Category:" progress.md
```

**2. CREATE INDIVIDUAL LESSON FILES**

For each significant lesson:

```bash
# Create lesson file
cat > lessons/[category]/[short-name].md << 'EOF'
# [Lesson Title]

**Lesson ID**: L-[category]-[number]
**Category**: [Technical|Process|Architectural|Security|Performance]
**Severity**: [Critical|High|Medium|Low]
**Discovered**: [YYYY-MM-DD]
**Related Issues**: [#issue-1, #issue-2]
**Related Missions**: [mission-name-1, mission-name-2]

## Problem

[What was the challenge or issue encountered?]

**Symptom**:
[Observable problem that indicated something was wrong]

**Context**:
[When/where does this problem occur?]

**Impact**:
[What consequences did this have?]

## Root Cause

[Why did this happen? What was the underlying reason?]

**Analysis**:
[Deep dive into why the problem exists]

**Contributing Factors**:
- [Factor 1]
- [Factor 2]

## Solution

[How was this resolved or addressed?]

**Approach**:
[The strategy taken to solve the problem]

**Implementation**:
[Specific steps or changes made]

**Results**:
[Outcome after implementing solution]

## Prevention

[How to avoid this issue in the future]

**Detection**:
[How to identify this issue early if it occurs]

**Mitigation**:
- [Prevention step 1]
- [Prevention step 2]
- [Prevention step 3]

**Architectural Changes**:
[Any design changes that prevent recurrence]

**Process Changes**:
[Any workflow improvements needed]

## Application

[When and where to apply this lesson]

**Applies To**:
- [Project type 1]
- [Project type 2]
- [Scenario 1]

**Does NOT Apply To**:
- [Exception 1]
- [Exception 2]

**Examples**:
[Specific examples of applying this lesson]

## Keywords

`[keyword1]`, `[keyword2]`, `[keyword3]`, `[keyword4]`, `[keyword5]`

## Related Lessons

- [L-category-number]: [Related lesson title]
- [L-category-number]: [Related lesson title]

## References

- progress.md: [Issue #X]
- mission-archive: [archives/missions/mission-name/]
- CLAUDE.md: [Section if system learning]

---

**Created**: [YYYY-MM-DD]
**Last Updated**: [YYYY-MM-DD]
**Times Applied**: [X times in X missions]
EOF
```

**3. UPDATE LESSONS INDEX**

Update `lessons/index.md`:

```bash
# Add lesson to appropriate category
# Add keywords to search index
# Update lesson count
# Add cross-references
```

See `templates/lessons-index-template.md` for complete index structure.

**4. TAG AND CATEGORIZE**

Organize lessons by:
- **Category**: Technical, Process, Architectural, Security, Performance, Communication
- **Severity**: Critical (must know), High (should know), Medium (good to know), Low (nice to know)
- **Frequency**: Common (>5 occurrences), Occasional (2-5), Rare (<2)
- **Project Type**: Frontend, Backend, Full-stack, Infrastructure, Data

**5. CREATE QUICK REFERENCE**

Add to quick reference section:

```markdown
## Quick Reference Commands

# Search lessons by keyword
grep -r "authentication" lessons/

# Find lessons by category
ls lessons/security/

# Find critical lessons
grep "Severity: Critical" lessons/**/*.md

# Find recent lessons
ls -lt lessons/**/*.md | head -10
```

---

## Archive Structure

### Recommended Directory Structure

```
project-root/
├── project-plan.md           ← Active mission plan
├── progress.md               ← Active changelog
├── agent-context.md          ← Current context
├── handoff-notes.md          ← Current handoff
├── architecture.md           ← Evolving design (never archives)
│
├── lessons/                  ← Permanent knowledge base (never archives)
│   ├── index.md              ← Searchable master index
│   ├── technical/            ← Technical lessons
│   ├── process/              ← Process lessons
│   ├── architectural/        ← Architecture lessons
│   ├── security/             ← Security lessons
│   └── performance/          ← Performance lessons
│
└── archives/                 ← Historical records
    ├── handoffs/             ← Milestone handoff archives
    │   ├── milestone-1-requirements/
    │   ├── milestone-2-development/
    │   └── milestone-3-testing/
    │
    ├── context/              ← Historical agent context
    │   ├── milestone-1-context.md
    │   ├── milestone-2-context.md
    │   └── milestone-3-context.md
    │
    └── missions/             ← Complete mission archives
        ├── mission-mvp-2025-08-15/
        │   ├── MISSION-SUMMARY.md
        │   ├── project-plan.md
        │   ├── progress.md
        │   ├── agent-context.md
        │   ├── handoff-notes-final.md
        │   └── evidence/
        └── mission-beta-2025-09-01/
            ├── MISSION-SUMMARY.md
            ├── project-plan.md
            ├── progress.md
            └── ...
```

### Archive Access Commands

```bash
# List all archived missions
ls -lt archives/missions/

# View mission summary
cat archives/missions/mission-[name]-YYYY-MM-DD/MISSION-SUMMARY.md

# Search archived progress logs
grep "authentication" archives/missions/*/progress.md

# Find specific milestone handoff
cat archives/handoffs/milestone-2-development/handoff-notes-final.md

# Compare context between milestones
diff archives/context/milestone-1-context.md archives/context/milestone-2-context.md
```

---

## Cleanup Protocol

### Quick Cleanup Checklist

Use `templates/cleanup-checklist.md` for step-by-step cleanup reference.

### Cleanup Commands

**Milestone Transition Cleanup**:
```bash
#!/bin/bash
# cleanup-milestone.sh

MILESTONE_NUM=$1
MILESTONE_NAME=$2

echo "Starting milestone transition cleanup..."

# 1. Extract lessons
echo "Extracting lessons from progress.md..."
# Manual review required - see Lessons Extraction section

# 2. Archive handoff
echo "Archiving handoff-notes.md..."
mkdir -p "archives/handoffs/milestone-${MILESTONE_NUM}-${MILESTONE_NAME}"
cp handoff-notes.md "archives/handoffs/milestone-${MILESTONE_NUM}-${MILESTONE_NAME}/handoff-notes-final.md"

# 3. Archive agent context
echo "Archiving agent-context.md..."
mkdir -p "archives/context"
cp agent-context.md "archives/context/milestone-${MILESTONE_NUM}-context.md"

# 4. Clean agent context (manual review recommended)
echo "Cleaning agent-context.md (review before saving)..."
# Show current sections
echo "Current sections:"
grep "^## " agent-context.md

# 5. Create fresh handoff-notes.md
echo "Creating fresh handoff-notes.md..."
cp templates/handoff-notes-template.md handoff-notes.md

# 6. Update project-plan.md
echo "Update project-plan.md with next milestone tasks..."
echo "Mark Milestone ${MILESTONE_NUM} as complete: ✅"
echo "Add Milestone $((MILESTONE_NUM + 1)) tasks: [ ]"

# 7. Update progress.md
echo "Adding milestone completion entry to progress.md..."
cat >> progress.md << EOF

---

## Milestone ${MILESTONE_NUM} Complete

**Completed**: $(date +%Y-%m-%d)
**Status**: ✅ All objectives achieved

**Major Achievements**:
- [Achievement 1]
- [Achievement 2]
- [Achievement 3]

**Lessons Learned**:
See lessons/index.md for extracted lessons from this milestone.

**Archived**:
- Handoff: archives/handoffs/milestone-${MILESTONE_NUM}-${MILESTONE_NAME}/
- Context: archives/context/milestone-${MILESTONE_NUM}-context.md

---

## Milestone $((MILESTONE_NUM + 1)): [Next Milestone Name]

**Started**: $(date +%Y-%m-%d)

EOF

echo "Milestone transition cleanup complete!"
echo "Next steps:"
echo "1. Review and update agent-context.md manually"
echo "2. Update project-plan.md with Milestone $((MILESTONE_NUM + 1)) tasks"
echo "3. Brief specialists on milestone transition"
```

**Mission Completion Cleanup**:
```bash
#!/bin/bash
# cleanup-mission.sh

MISSION_NAME=$1
COMPLETION_DATE=$(date +%Y-%m-%d)

echo "Starting mission completion cleanup..."

# 1. Extract ALL lessons
echo "Extracting all lessons from progress.md..."
# Manual review required - see Lessons Extraction section

# 2. Create mission archive
echo "Creating mission archive..."
ARCHIVE_DIR="archives/missions/mission-${MISSION_NAME}-${COMPLETION_DATE}"
mkdir -p "${ARCHIVE_DIR}/evidence"

# 3. Copy all tracking files
echo "Archiving tracking files..."
cp project-plan.md "${ARCHIVE_DIR}/"
cp progress.md "${ARCHIVE_DIR}/"
cp agent-context.md "${ARCHIVE_DIR}/"
cp architecture.md "${ARCHIVE_DIR}/"
cp handoff-notes.md "${ARCHIVE_DIR}/handoff-notes-final.md"
cp -r evidence-repository/* "${ARCHIVE_DIR}/evidence/" 2>/dev/null || true

# 4. Create mission summary
echo "Creating mission summary..."
cat > "${ARCHIVE_DIR}/MISSION-SUMMARY.md" << 'EOF'
# Mission Summary: [Mission Name]

**Completed**: [YYYY-MM-DD]
**Duration**: [X weeks]

## Objectives Achieved
[Fill in achievements]

## Key Metrics
[Fill in metrics]

## Top 5 Lessons
[Reference lessons/index.md]

## Archive Contents
- project-plan.md
- progress.md
- architecture.md
- agent-context.md
- handoff-notes-final.md
- evidence/
EOF

# 5. Move active files to archive
echo "Moving active files to archive..."
mv project-plan.md "${ARCHIVE_DIR}/"
mv progress.md "${ARCHIVE_DIR}/"
mv agent-context.md "${ARCHIVE_DIR}/"
mv handoff-notes.md "${ARCHIVE_DIR}/handoff-notes-final.md"
# Keep architecture.md (evolves across missions)

# 6. Update CLAUDE.md with system learnings
echo "Review lessons for system-level updates to CLAUDE.md..."

echo "Mission cleanup complete!"
echo "Mission archived to: ${ARCHIVE_DIR}"
echo "Next mission ready to start with fresh tracking files."
```

### Verification After Cleanup

**After Milestone Transition**:
- [ ] Lessons extracted and indexed in `lessons/index.md`
- [ ] Handoff archived to `archives/handoffs/milestone-X/`
- [ ] Agent context cleaned but retains essentials
- [ ] Fresh handoff-notes.md created from template
- [ ] project-plan.md updated with next milestone
- [ ] progress.md has milestone completion entry

**After Mission Completion**:
- [ ] ALL lessons extracted to `lessons/`
- [ ] Complete mission archive created in `archives/missions/`
- [ ] MISSION-SUMMARY.md created
- [ ] CLAUDE.md updated with system learnings
- [ ] Active tracking files moved to archive
- [ ] architecture.md retained (evolves across missions)
- [ ] Ready for next mission initialization

---

## Best Practices Summary

### DOs ✅

- **DO extract lessons continuously** - Don't wait for milestones
- **DO archive handoffs at milestones** - Prevent file bloat
- **DO keep agent-context.md current** - Archive old, retain essential
- **DO create individual lesson files** - Searchable and reusable
- **DO preserve architecture.md** - Evolves across missions
- **DO update lessons/index.md** - Keep searchable
- **DO verify before archiving** - All tasks complete, no blockers
- **DO communicate transitions** - Brief team on changes

### DON'Ts ❌

- **DON'T let handoff-notes.md accumulate** - Archive completed work
- **DON'T archive architecture.md** - It's a living document
- **DON'T lose context** - Archive before cleaning
- **DON'T forget to extract lessons** - They're the most valuable output
- **DON'T skip verification** - Ensure readiness before transitions
- **DON'T delete archives** - Historical context is valuable
- **DON'T accumulate forever** - Clean strategically at milestones

---

## Quick Reference Commands

```bash
# Create lessons directory
mkdir -p lessons/{technical,process,architectural,security,performance}

# Archive milestone handoff
mkdir -p archives/handoffs/milestone-{num}-{name}
cp handoff-notes.md archives/handoffs/milestone-{num}-{name}/handoff-notes-final.md

# Archive agent context
mkdir -p archives/context
cp agent-context.md archives/context/milestone-{num}-context.md

# Create mission archive
mkdir -p archives/missions/mission-{name}-$(date +%Y-%m-%d)

# Search lessons
grep -r "keyword" lessons/

# Find archived missions
ls -lt archives/missions/

# View mission summary
cat archives/missions/mission-{name}-YYYY-MM-DD/MISSION-SUMMARY.md
```

---

## Related Documentation

- **templates/project-plan-template.md** - Project plan with verification protocols
- **templates/progress-template.md** - Progress log structure
- **templates/lessons-index-template.md** - Searchable lessons index
- **templates/lesson-template.md** - Individual lesson file format
- **templates/cleanup-checklist.md** - Step-by-step cleanup reference
- **CLAUDE.md** - Project tracking system overview

---

**Last Updated**: 2025-10-19
**Maintained By**: @coordinator agents
**Purpose**: Ensure projects stay organized throughout lifecycle without file bloat
