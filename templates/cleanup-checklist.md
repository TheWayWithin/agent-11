# Project Cleanup Checklist

**Purpose**: Quick reference for milestone transitions and project completion cleanup
**Use When**: Transitioning between milestones (every 2-4 weeks) or completing mission
**Reference**: See `project/field-manual/project-lifecycle-guide.md` for detailed procedures

---

## Quick Checklist Selection

**Choose your cleanup type**:
- [ ] **Milestone Transition** → Use Section A below
- [ ] **Project Completion** → Use Section B below
- [ ] **Emergency Context Clear** → Use Section C below

---

## Section A: Milestone Transition Cleanup

**When**: Every 2-4 weeks or at major phase gates
**Time Required**: 30-60 minutes
**Goal**: Archive completed work, retain essentials, start fresh milestone

### Pre-Cleanup Verification

- [ ] All milestone tasks marked [x] in project-plan.md (verified, not assumed)
- [ ] No critical blockers (🔴) remaining
- [ ] All issues in progress.md have current status
- [ ] handoff-notes.md updated within last 24 hours
- [ ] evidence-repository.md contains all milestone artifacts

### Step 1: Extract Lessons (15-20 min)

- [ ] Review progress.md for all milestone learnings
- [ ] Create individual lesson files in `lessons/[category]/`
- [ ] Update `lessons/index.md` with new lessons
- [ ] Tag lessons by category, severity, and keywords
- [ ] Add cross-references to related lessons

**Command**:
```bash
# Review lessons section
grep -A 10 "## 🎓 Lessons Learned" progress.md

# Create lesson file
cp templates/lesson-template.md lessons/[category]/[name].md
```

### Step 2: Archive Handoff Notes (5 min)

- [ ] Create milestone archive directory
- [ ] Copy handoff-notes.md to archive
- [ ] Extract key decisions to archive README
- [ ] Verify archive created successfully

**Commands**:
```bash
# Create archive
mkdir -p archives/handoffs/milestone-X-[name]

# Archive handoff
cp handoff-notes.md archives/handoffs/milestone-X-[name]/handoff-notes-final.md

# Create metadata
cat > archives/handoffs/milestone-X-[name]/README.md << 'EOF'
# Milestone X: [Name] - Handoff Archive
**Archived**: $(date +%Y-%m-%d)
**Key Decisions**: [Brief list]
**Next Milestone**: [Name]
EOF
```

### Step 3: Clean Agent Context (10 min)

- [ ] Archive current agent-context.md
- [ ] Create clean agent-context.md with essentials only
- [ ] Retain: mission objectives, architecture essentials, active constraints
- [ ] Archive: historical findings, resolved issues, completed phase details
- [ ] Verify essential context preserved

**Commands**:
```bash
# Archive old context
cat agent-context.md > archives/context/milestone-X-context.md

# Create clean context (use template sections, fill with essentials only)
```

### Step 4: Create Fresh Handoff Notes (5 min)

- [ ] Copy handoff-notes template
- [ ] Add current milestone number and name
- [ ] Include essential mission context only (2-3 sentences)
- [ ] Add reference to archived handoffs
- [ ] Ready for next specialist

**Command**:
```bash
cp templates/handoff-notes-template.md handoff-notes.md
# Edit to add current milestone and essential context
```

### Step 5: Update Tracking Files (5-10 min)

- [ ] Mark Milestone X as ✅ Complete in project-plan.md
- [ ] Add Milestone Y tasks [ ] to project-plan.md
- [ ] Update timeline and dependencies in project-plan.md
- [ ] Add "Milestone X Complete" entry to progress.md
- [ ] List major achievements in progress.md
- [ ] Reference extracted lessons in progress.md
- [ ] Start Milestone Y section in progress.md

### Step 6: Verification & Handoff (5 min)

- [ ] Lessons extracted to `lessons/` and indexed
- [ ] Old handoff archived to `archives/handoffs/milestone-X/`
- [ ] New handoff-notes.md contains only next milestone context
- [ ] agent-context.md cleaned but retains essentials
- [ ] project-plan.md updated with Milestone Y tasks
- [ ] progress.md has milestone completion entry
- [ ] architecture.md current with latest decisions
- [ ] All specialists briefed on milestone transition

---

## Section B: Project Completion Cleanup

**When**: All project objectives achieved, ready to start new mission
**Time Required**: 1-2 hours
**Goal**: Archive everything, extract all learnings, prepare fresh start

### Pre-Completion Verification

- [ ] All primary objectives ✅ Complete in project-plan.md
- [ ] All deliverables produced and validated
- [ ] Quality metrics meet targets
- [ ] No critical (🔴) issues open
- [ ] All tests passing
- [ ] Documentation complete
- [ ] Stakeholder sign-off obtained

### Step 1: Comprehensive Lessons Extraction (30-45 min)

- [ ] Extract ALL learnings from entire progress.md
- [ ] Create lesson files for technical patterns
- [ ] Create lesson files for common issues
- [ ] Create lesson files for architectural decisions
- [ ] Create lesson files for process improvements
- [ ] Update lessons/index.md with complete catalog
- [ ] Verify all lessons categorized and indexed

### Step 2: Create Mission Archive (15-20 min)

- [ ] Create mission archive directory with date
- [ ] Copy project-plan.md to archive
- [ ] Copy progress.md to archive
- [ ] Copy agent-context.md to archive
- [ ] Copy architecture.md to archive
- [ ] Copy handoff-notes.md as handoff-notes-final.md
- [ ] Copy evidence-repository/ directory to archive
- [ ] Create MISSION-SUMMARY.md with key metrics
- [ ] Verify all files archived successfully

**Commands**:
```bash
# Create mission archive
mkdir -p archives/missions/mission-[name]-$(date +%Y-%m-%d)
cd archives/missions/mission-[name]-$(date +%Y-%m-%d)

# Archive all tracking files
cp ../../project-plan.md ./
cp ../../progress.md ./
cp ../../agent-context.md ./
cp ../../architecture.md ./
cp ../../handoff-notes.md ./handoff-notes-final.md
cp -r ../../evidence-repository/ ./evidence/

# Create mission summary (use template provided in lifecycle guide)
```

### Step 3: System Learnings Update (10-15 min)

- [ ] Review all lessons for system-level improvements
- [ ] Identify patterns applicable to ALL future missions
- [ ] Add process improvements to CLAUDE.md
- [ ] Add tool usage patterns to CLAUDE.md
- [ ] Add common anti-patterns warnings to CLAUDE.md
- [ ] Document architectural principles discovered
- [ ] Commit CLAUDE.md updates with rationale

**Criteria for System Learning**:
- Applies to ALL future missions (not project-specific)
- Prevents common mistakes or inefficiencies
- Improves coordination or delegation
- Enhances context preservation
- Strengthens security or quality practices

### Step 4: Prepare Fresh Start (10-15 min)

- [ ] Move project-plan.md to mission archive
- [ ] Move progress.md to mission archive
- [ ] Move agent-context.md to mission archive
- [ ] Move handoff-notes.md to mission archive
- [ ] Move evidence-repository.md to mission archive
- [ ] KEEP architecture.md (evolves across missions)
- [ ] KEEP lessons/ directory (permanent knowledge base)
- [ ] KEEP CLAUDE.md (project configuration)
- [ ] KEEP archives/ directory (historical records)
- [ ] Ready for next mission initialization

**Commands**:
```bash
# Archive current files
ARCHIVE_DIR="archives/missions/mission-[name]-$(date +%Y-%m-%d)"
mv project-plan.md "${ARCHIVE_DIR}/"
mv progress.md "${ARCHIVE_DIR}/"
mv agent-context.md "${ARCHIVE_DIR}/"
mv handoff-notes.md "${ARCHIVE_DIR}/handoff-notes-final.md"
mv evidence-repository.md "${ARCHIVE_DIR}/"

# Persistent files remain (architecture.md, lessons/, CLAUDE.md)
```

### Step 5: Completion Communication (5-10 min)

- [ ] Create mission completion announcement
- [ ] List major achievements
- [ ] Share key metrics (tasks, issues, timeline)
- [ ] Reference lessons captured
- [ ] Reference mission archive location
- [ ] Announce readiness for next mission
- [ ] Update stakeholders

**Template in project/field-manual/project-lifecycle-guide.md**

### Final Verification

- [ ] Lessons extracted to `lessons/` (all significant learnings)
- [ ] Mission archive complete in `archives/missions/mission-[name]-YYYY-MM-DD/`
- [ ] MISSION-SUMMARY.md created with key information
- [ ] CLAUDE.md updated with system learnings
- [ ] Active tracking files moved to archive
- [ ] architecture.md retained (not archived)
- [ ] lessons/ retained (not archived)
- [ ] Fresh start ready for next mission

---

## Section C: Emergency Context Clear

**When**: Context approaching 30K tokens during long mission
**Time Required**: 10-15 minutes
**Goal**: Clear context pollution while preserving critical information

### Pre-Clear Actions

- [ ] Extract critical insights to memory files (/memories/lessons/*.xml)
- [ ] Update agent-context.md with current phase findings
- [ ] Update handoff-notes.md for next agent/phase
- [ ] Verify memory tool calls are recent (in last 3 tool uses)
- [ ] Confirm at least 5K tokens will be cleared
- [ ] Ensure not in middle of complex delegation chain

### Clear Trigger Conditions

**DO clear context when**:
- [ ] Context approaching 30,000 input tokens
- [ ] Between major mission phases (after phase completion)
- [ ] After extracting insights to memory and context files
- [ ] Before starting complex multi-hour operations
- [ ] When switching between unrelated mission domains

**DON'T clear context when**:
- [ ] In middle of active specialist delegation
- [ ] During critical debugging session
- [ ] Less than 5K tokens would be cleared
- [ ] Haven't updated context files first
- [ ] Within last 3 tool uses (recent context needed)

### Post-Clear Verification

- [ ] Memory still accessible
- [ ] Mission objectives still clear from agent-context.md
- [ ] Specialist can access handoff-notes.md
- [ ] Next delegation ready with context instructions
- [ ] Resume operations with clean context

### Context Clear Delegation Template

```
Task(
  subagent_type="[specialist]",
  prompt="First read agent-context.md and handoff-notes.md for full mission context.
          Access /memories/ for project knowledge and past decisions.
          CRITICAL: Follow Critical Software Development Principles.
          [Task details]
          Update handoff-notes.md with your findings."
)
```

---

## Common Cleanup Mistakes to Avoid

### ❌ DON'T DO THESE

1. **Marking tasks [x] before cleanup verification**
   - Verify specialist confirmation first
   - Check deliverable files exist
   - Confirm handoff-notes.md updated

2. **Archiving architecture.md**
   - architecture.md evolves across missions
   - Never archive, always keep current

3. **Deleting lessons/ directory**
   - Lessons are permanent knowledge base
   - Never delete, only add and update

4. **Skipping lesson extraction**
   - Lessons are the most valuable output
   - Extract before archiving to preserve learnings

5. **Not verifying archives before deletion**
   - Always verify archive created successfully
   - Check all files copied correctly
   - Test archive access before removing originals

6. **Cleaning without context preservation**
   - Update agent-context.md before cleaning
   - Archive handoff-notes.md before clearing
   - Extract insights to memory before /clear

7. **Accumulating handoff-notes forever**
   - Archive completed milestone handoffs
   - Keep only current phase context
   - Reference archived handoffs in current notes

8. **Forgetting to update CLAUDE.md**
   - System-level learnings belong in CLAUDE.md
   - Document process improvements
   - Share patterns with all future missions

---

## Quick Commands Reference

### Lesson Management
```bash
# Create lesson file
cp templates/lesson-template.md lessons/[category]/[name].md

# Update lessons index
# Edit lessons/index.md to add new lesson

# Search lessons
grep -r "keyword" lessons/
```

### Archive Management
```bash
# Create milestone handoff archive
mkdir -p archives/handoffs/milestone-X-[name]
cp handoff-notes.md archives/handoffs/milestone-X-[name]/handoff-notes-final.md

# Create mission archive
mkdir -p archives/missions/mission-[name]-$(date +%Y-%m-%d)

# List archives
ls -lt archives/missions/
ls -lt archives/handoffs/
```

### File Cleanup
```bash
# Create fresh handoff notes
cp templates/handoff-notes-template.md handoff-notes.md

# Archive agent context
cp agent-context.md archives/context/milestone-X-context.md

# Move files to mission archive
mv project-plan.md archives/missions/mission-[name]-YYYY-MM-DD/
```

### Verification
```bash
# Check for open tasks
grep '\[ \]' project-plan.md

# Check for critical blockers
grep '🔴' project-plan.md

# Verify archive created
ls -la archives/missions/mission-[name]-YYYY-MM-DD/
```

---

## Cleanup Schedule Recommendations

### Milestone Transitions
- **Frequency**: Every 2-4 weeks or major phase gates
- **Time**: 30-60 minutes
- **Focus**: Archive completed, retain essentials

### Project Completion
- **Frequency**: End of mission
- **Time**: 1-2 hours
- **Focus**: Comprehensive archival, full lesson extraction

### Emergency Context Clear
- **Frequency**: As needed during long missions
- **Time**: 10-15 minutes
- **Focus**: Quick context cleanup while preserving critical info

### Regular Maintenance
- **Daily**: Update tracking files after each task
- **Weekly**: Review milestone progress, extract emerging lessons
- **Monthly**: Audit lessons index, update cross-references

---

## Related Documentation

- **project/field-manual/project-lifecycle-guide.md** - Complete lifecycle management guide
- **templates/project-plan-template.md** - Project plan with verification protocols
- **templates/progress-template.md** - Progress log structure
- **templates/lessons-index-template.md** - Searchable lessons index
- **templates/lesson-template.md** - Individual lesson file format
- **CLAUDE.md** - Project tracking system overview

---

**Checklist Version**: 1.0
**Last Updated**: 2025-10-19
**Quick Reference**: Print this for fast cleanup workflows
