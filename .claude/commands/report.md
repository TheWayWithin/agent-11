---
name: report
description: Generate progress report for stakeholders
---

# PROGRESS REPORT GENERATION 📊

**Command**: `/report [since_date]`

**Arguments**: 
- `since_date` (optional): Date to report from (YYYY-MM-DD format). Defaults to last report date or 7 days ago.

## REPORT GENERATION PROTOCOL

You are generating a structured progress report for external stakeholders (BOS-AI or clients) based on project-plan.md and progress.md.

### EXECUTION STEPS

1. **Parse Arguments**
   - Extract since_date if provided
   - If not provided, look for last progress-report.md date
   - Default to 7 days ago if no previous report exists

2. **Gather Information**
   - Read project-plan.md for completed tasks
   - Read progress.md for issues and resolutions
   - Check git log for recent commits
   - Review any test results or metrics

3. **Generate Report Structure**

Create `progress-report.md` with the following format:

```markdown
# Progress Report

**Report Date**: [Today's date]
**Period**: [Since date] to [Today's date]
**Project**: AGENT-11 Development

## Executive Summary

[2-3 sentences summarizing overall progress and status]

## Tasks Completed

| Task | Completion Date | Impact |
|------|----------------|--------|
| [Task from project-plan.md] | [Date] | [Business value delivered] |

## Issues & Resolutions

| Issue | Date | Resolution | Status |
|-------|------|------------|--------|
| [From progress.md] | [Date] | [How resolved] | ✅ Resolved / ⚠️ In Progress |

## Current Status

- **Overall Progress**: [On Track / At Risk / Behind Schedule]
- **Active Phase**: [Current phase from project-plan.md]
- **Blockers**: [Any current blockers]

## Metrics

| Metric | Target | Actual | Trend |
|--------|--------|--------|-------|
| Development Velocity | [X] tasks/week | [Y] completed | 📈/📉/➡️ |
| Issue Resolution Time | <24 hours | [Actual] | 📈/📉/➡️ |
| Test Coverage | >80% | [If available] | 📈/📉/➡️ |

## Next Milestones

| Milestone | Target Date | Status |
|-----------|------------|--------|
| [From project-plan.md] | [Date] | Planning / In Progress / At Risk |

## Resource Needs

- [ ] [Any decisions needed from stakeholders]
- [ ] [Any resources or support required]
- [ ] [Any clarifications needed]

## Recommendations

[Any strategic recommendations based on progress]

---
*Generated: [Timestamp]*
*Next Report Due: [Date + 7 days]*
```

4. **Special Sections for BOS-AI Integration**

If BOS-AI documents detected in ideation folder, add:

```markdown
## Business Alignment

**Requirements Coverage**: [X]% of PRD requirements completed
**Vision Alignment**: [How development aligns with Vision and Mission.md]
**Next Business Milestone**: [From Strategic Roadmap]
```

5. **Quality Checks**
   - Ensure all dates are accurate
   - Verify task completion status
   - Cross-reference with git commits
   - Include only factual information

### SUCCESS CRITERIA

✅ Report generated with accurate information
✅ All completed tasks since last report included
✅ Issues and resolutions documented
✅ Clear next steps identified
✅ Professional format suitable for stakeholders

### ERROR HANDLING

- If no project-plan.md exists: Report basic git activity
- If no progress.md exists: Focus on completed tasks only
- If no changes since last report: Generate "No Activity" report

Remember: This report may be the only visibility stakeholders have into the project. Make it comprehensive, accurate, and actionable.