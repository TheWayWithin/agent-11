# Progress Log

**Mission**: [Mission Name]
**Started**: [YYYY-MM-DD]
**Last Updated**: [YYYY-MM-DD HH:MM]
**Current Phase**: [Phase X]

---

## ⚠️ TIMESTAMP REQUIREMENTS

**ALL entries in this file MUST include timestamps in format: YYYY-MM-DD HH:MM**

- Entry headers: `### [YYYY-MM-DD HH:MM] - Entry Title`
- Phase completions: `### Phase X Complete - [YYYY-MM-DD HH:MM]`
- Issue discoveries: `**Discovered**: [YYYY-MM-DD HH:MM]`
- Fix attempts: `**Date**: [YYYY-MM-DD HH:MM]`

**Entries without timestamps are INCOMPLETE and trigger staleness detection.**

---

## 🚨 REAL-TIME UPDATE PROTOCOL

**CRITICAL**: This file documents what has HAPPENED (backward-looking). Update IMMEDIATELY when events occur, not later.

### When to Update IMMEDIATELY (Not Later)

#### ✅ UPDATE NOW (Real-Time)
1. **Deliverable Created/Modified** → Log within 5 minutes of completion
   - Don't wait for phase end or daily summary
   - Capture while details are fresh
   - Include file paths and immediate impact

2. **Change Made to Code/Configs** → Log immediately after change
   - Record rationale before context lost
   - Document "why" while decision is clear
   - Link to related issues if applicable

3. **Issue Discovered** → Create issue entry the moment problem identified
   - Don't wait to understand full scope
   - Capture symptom and immediate context
   - Mark status as 🔴 Open

4. **Fix Attempted** → Log EVERY attempt immediately after trying
   - Document even if fix fails (especially if it fails!)
   - Capture rationale before moving to next attempt
   - Record learning while insight is fresh

5. **Issue Resolved** → Add root cause analysis within 30 minutes
   - Document why it worked before forgetting details
   - Capture prevention strategy while problem is clear
   - Link all attempted fixes for pattern recognition

#### ❌ DON'T WAIT (Common Anti-Patterns)

**DON'T**:
- ❌ Batch updates at end of day/week ("I'll log it later")
- ❌ Wait until issue fully resolved to start logging
- ❌ Skip logging failed attempts ("nobody needs to know what didn't work")
- ❌ Assume you'll remember details tomorrow
- ❌ Only log successes and hide failures
- ❌ Wait for phase completion to document lessons

**WHY REAL-TIME MATTERS**:
1. **Context Lost**: Details forgotten within hours, not days
2. **Pattern Recognition**: Failed attempts reveal patterns success hides
3. **Learning Value**: Failures teach more than successes
4. **Audit Trail**: Complete history prevents repeated mistakes
5. **Knowledge Transfer**: Next specialist needs full story, not sanitized version

### In-Progress Work Format

While actively working on tasks, use this format:

```markdown
### [YYYY-MM-DD HH:MM] - [Work Description] - 🔵 IN PROGRESS
**Working on**: [Specific task or issue]
**Assigned to**: @[specialist]
**Started**: [YYYY-MM-DD HH:MM]

**Current Status**:
[What's happening right now - update every 1-2 hours during active work]

**Progress So Far**:
- [Completed step 1]
- [Completed step 2]
- [Currently working on step 3]

**Blockers Encountered**:
- [Blocker 1 if any]
- [Temporary workaround if applicable]

**Next Steps**:
- [Immediate next action]

---
```

**Update this entry every 1-2 hours during active work** to maintain real-time status.

### Real-Time Update Examples

#### GOOD Example (Immediate Logging):
```markdown
### 2025-10-19 14:30 - Authentication Issue Discovered
**Discovered by**: @developer
**Status**: 🔴 Open

**Symptom**: Users logged out after 5 minutes unexpectedly

**Context**: Testing login flow, noticed session expires too quickly

#### Fix Attempts

##### Attempt #1: Increased token expiry - 2025-10-19 14:45
**Result**: ❌ Failed
**Rationale**: Thought 5-minute token expiry was too short
**What We Tried**: Changed JWT expiry from 5min to 60min
**Outcome**: Users still logged out after 5min - expiry time not the issue
**Learning**: Problem is NOT token expiry, must be refresh mechanism

##### Attempt #2: Fixed refresh token rotation - 2025-10-19 15:20
**Result**: ✅ Success
**Rationale**: Refresh tokens not being stored/rotated properly
**What We Tried**: Added refresh token to localStorage with proper rotation
**Outcome**: Users now stay logged in correctly
**Learning**: Always check refresh mechanism before adjusting token expiry

#### Resolution
**Resolved**: 2025-10-19 15:30
**Root Cause**: Refresh token was not stored after login, causing session loss
**Prevention**: Add test to verify refresh token storage after authentication
```

#### BAD Example (Delayed Logging):
```markdown
### 2025-10-19 - Fixed authentication
**Fixed by**: @developer
**Status**: ✅ Complete

Users were getting logged out. Fixed it by updating refresh tokens.
```
*(Problems: No timestamps, no failed attempts, no learning, no context, no root cause)*

### Daily Check-In Protocol

**End of Each Work Session** (15 minutes):
1. Review all in-progress entries - update current status
2. Convert completed work from "🔵 IN PROGRESS" to final entries
3. Ensure all attempted fixes logged (successes AND failures)
4. Check that all issues have current status (not stale)
5. Add any patterns or insights noticed during work

**DO NOT** wait for:
- Phase completion
- End of week
- Issue fully resolved
- All fixes attempted
- "Until I have something successful to report"

---

## 📦 Deliverables

### [YYYY-MM-DD HH:MM] - [Deliverable Name]
**Created by**: @[agent-name]
**Type**: [Feature|Documentation|Configuration|Infrastructure|Fix]
**Files**: `path/to/file1.ext`, `path/to/file2.ext`

**Description**:
Brief description of what was delivered and why.

**Impact**:
- Who benefits from this
- What problem it solves
- How it fits into the mission

---

## 🔨 Changes Made

### [YYYY-MM-DD HH:MM] - [Change Description]
**Modified by**: @[agent-name]
**Category**: [Code|Configuration|Documentation|Infrastructure]
**Files Changed**: `path/to/file.ext:line-range`

**What Changed**:
Specific technical changes made

**Why Changed**:
Rationale for the change

**Related Issues**: [#issue-id if applicable]

---

## 🐛 Issues Encountered

### Issue #[ID]: [Issue Title]

**Discovered**: [YYYY-MM-DD HH:MM] by @[agent-name]
**Status**: [🔴 Open | 🟡 In Progress | 🟢 Resolved]
**Severity**: [Critical|High|Medium|Low]

**Symptom**:
Observable problem or error message

**Context**:
- What task was being performed
- Relevant environment details
- Related code or configuration

**Impact**:
- What functionality is blocked
- Who is affected
- Urgency level

---

#### Fix Attempts

##### Attempt #1: [Approach Name]
**Date**: [YYYY-MM-DD HH:MM]
**Attempted by**: @[agent-name]
**Result**: [✅ Success | ❌ Failed | ⚠️ Partial]

**Rationale**:
Why we thought this would work

**What We Tried**:
Specific changes made or commands run

**Outcome**:
What actually happened

**Learning**:
What this taught us about the problem

---

##### Attempt #2: [Approach Name]
**Date**: [YYYY-MM-DD HH:MM]
**Attempted by**: @[agent-name]
**Result**: [✅ Success | ❌ Failed | ⚠️ Partial]

**Rationale**:
Why we thought this would work differently than Attempt #1

**What We Tried**:
Specific changes made or commands run

**Outcome**:
What actually happened

**Learning**:
What this taught us about the problem

---

#### Resolution (if resolved)

**Final Solution**: [Brief description]
**Resolved**: [YYYY-MM-DD HH:MM] by @[agent-name]
**Resolution Time**: [X hours/days from discovery]

**Root Cause**:
The underlying reason the issue occurred (not just the symptom)

**Why Previous Attempts Failed**:
Analysis of what we misunderstood initially

**Prevention Strategy**:
- How to avoid this issue in the future
- What checks or documentation would have prevented it
- Changes to process or architecture needed

**Related Patterns**:
- Similar issues we've seen before
- Common anti-patterns to watch for

---

## 🎓 Lessons Learned

### [YYYY-MM-DD] - [Lesson Category]

**What We Learned**:
Key insight or pattern recognized

**Why It Matters**:
Impact on future work

**How to Apply**:
Specific actionable changes to process, architecture, or approach

**Related Issues**: [#issue-id, #issue-id]

---

## 📊 Metrics & Progress

### Time Tracking
- **Total Hours**: [X hours]
- **Breakdown**:
  - Planning: [X hours]
  - Development: [X hours]
  - Testing: [X hours]
  - Debugging: [X hours]
  - Documentation: [X hours]

### Velocity
- **Tasks Completed**: [X]
- **Tasks Remaining**: [X]
- **Completion Rate**: [X% per day/week]

### Quality Indicators
- **First-Time Success Rate**: [X%] (deliverables that worked without issues)
- **Average Fix Attempts**: [X] (average attempts before issue resolution)
- **Rework Rate**: [X%] (deliverables that required significant changes)

---

## 📝 Daily Log

### [YYYY-MM-DD]

**Focus**: [Main work area for the day]

**Completed**:
- [Task or deliverable with link to section above]
- [Task or deliverable with link to section above]

**Issues Hit**:
- [Issue #ID - brief status]

**Blockers**:
- [Any blocking issues or dependencies]

**Tomorrow**:
- [Planned next steps]

---

## Usage Guidelines

### When to Update This File

1. **After Each Deliverable**: Add to Deliverables section immediately
2. **After Each Change**: Log in Changes Made section with rationale
3. **When Issue Discovered**: Create issue entry with symptom and context
4. **After EACH Fix Attempt**: Log attempt with full detail (even if it fails)
5. **When Issue Resolved**: Add root cause analysis and prevention
6. **End of Day**: Update Daily Log with summary
7. **Pattern Recognition**: Add to Lessons Learned when insights emerge

### Critical Principles

**Document Failures**: Failed attempts are MORE valuable than successes for learning. Always log:
- What we tried
- Why we thought it would work
- What actually happened
- What we learned

**Root Cause Analysis**: Never stop at "it works now" - understand WHY the issue occurred and WHY the solution works.

**Prevention Focus**: Every resolved issue should include a strategy to prevent similar issues in the future.

**Temporal Distinction**:
- project-plan.md = FORWARD-LOOKING (what we're planning to do)
- progress.md = BACKWARD-LOOKING (what we did and learned)

---

## 🏁 Phase Completion Entry [MANDATORY]

**At the end of EVERY phase, add this entry (required for phase gate to pass):**

```markdown
### Phase [X] Complete - [YYYY-MM-DD HH:MM]

**Tasks Completed**: [count] tasks marked [x] in project-plan.md
**Files Created**: [count] files verified on filesystem
**Files Modified**: [count] edits applied and verified
**Verification**: ls -la / head -n X confirmed all files
**Handoff Updated**: ✅ handoff-notes.md current
**Context Updated**: ✅ agent-context.md merged
**Gate Status**: ✅ ALL CHECKS PASS - Proceeding to Phase [X+1]

**Key Deliverables**:
- [Deliverable 1 with path]
- [Deliverable 2 with path]

**Decisions Made**:
- [Key decision 1 and rationale]
- [Key decision 2 and rationale]

**Issues Encountered**: [count] issues ([count] resolved, [count] carried forward)

**Lessons Learned**:
- [Pattern or insight from this phase]
```

**Without this entry, the Phase Gate check will FAIL and work cannot proceed to the next phase.**

---

## Template Notes

**Remove this section when using template**

- Replace all `[bracketed text]` with actual values
- Keep chronological order (newest entries at top of each section)
- Link between sections using issue IDs
- Be specific: file paths, line numbers, error messages, timestamps
- Focus on learning: why things failed is as important as how they succeeded
- Update frequently: don't wait for phase completion
- Cross-reference: link deliverables to changes to issues to lessons
