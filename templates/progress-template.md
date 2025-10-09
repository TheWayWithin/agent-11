# Progress Log

**Mission**: [Mission Name]
**Started**: [YYYY-MM-DD]
**Last Updated**: [YYYY-MM-DD]

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

## Template Notes

**Remove this section when using template**

- Replace all `[bracketed text]` with actual values
- Keep chronological order (newest entries at top of each section)
- Link between sections using issue IDs
- Be specific: file paths, line numbers, error messages, timestamps
- Focus on learning: why things failed is as important as how they succeeded
- Update frequently: don't wait for phase completion
- Cross-reference: link deliverables to changes to issues to lessons
