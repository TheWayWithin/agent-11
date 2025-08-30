---
name: report
description: Generate progress report for stakeholders
---

# PROGRESS REPORT GENERATION 📊

**Command**: `/report [since_date]`

**Purpose**: Generate a structured progress report documenting completed tasks, issues encountered, and project status for external stakeholders (BOS-AI, clients, or management).

## KEY FEATURES

- **Automated Data Collection**: Pulls from project-plan.md, progress.md, and git history
- **Time-Based Reporting**: Reports changes since last report or specified date
- **Stakeholder-Ready Format**: Professional structure suitable for external communication
- **BOS-AI Integration**: Special sections when integrated with BOS-AI documents
- **Issue Tracking**: Documents problems encountered and their resolutions

## USAGE EXAMPLES

```bash
# Generate report for last 7 days (default)
/report

# Generate report since specific date
/report 2025-08-20

# Generate report since last report (automatic detection)
/report
```

## REPORT SECTIONS

### 1. Executive Summary
Brief overview of progress and current status

### 2. Tasks Completed
Table of completed tasks with dates and business impact

### 3. Issues & Resolutions
Documentation of problems encountered and how they were resolved

### 4. Current Status
Overall project health and active phase

### 5. Metrics
Key performance indicators and trends

### 6. Next Milestones
Upcoming deliverables and target dates

### 7. Resource Needs
Decisions, resources, or clarifications needed from stakeholders

### 8. Business Alignment (BOS-AI Integration)
How development aligns with business vision and requirements

## OUTPUT

Generates `progress-report.md` with:
- Structured markdown format
- Tables for easy scanning
- Visual indicators (✅, ⚠️, 📈, 📉)
- Clear action items for stakeholders
- Timestamp and next report date

## BENEFITS

- **Transparency**: Clear visibility into development progress
- **Accountability**: Documented completion and issue resolution
- **Communication**: Bridge between technical work and business stakeholders
- **Tracking**: Historical record of project evolution
- **Planning**: Identifies resource needs and blockers early

## INTEGRATION WITH BOS-AI

When BOS-AI documents are present in the ideation folder:
- Reports PRD requirement coverage percentage
- Shows alignment with Vision and Mission.md
- References Strategic Roadmap milestones
- Translates technical progress to business value

## BEST PRACTICES

1. **Regular Cadence**: Generate reports weekly for active projects
2. **Accurate Dating**: Always verify dates against actual completion
3. **Business Language**: Translate technical achievements to business value
4. **Action Items**: Clearly identify what stakeholders need to provide
5. **Trend Analysis**: Show whether project is improving or declining

## ERROR HANDLING

- **Missing project-plan.md**: Falls back to git commit history
- **Missing progress.md**: Reports only completed tasks
- **No activity**: Generates "No Activity" report with explanation
- **Date parsing errors**: Defaults to 7-day window

## CUSTOMIZATION

The report format can be customized by modifying the command to:
- Add project-specific metrics
- Include additional sections
- Adjust formatting for different stakeholders
- Integrate with external tracking systems

---

*The /report command ensures stakeholders stay informed with minimal manual effort, creating a consistent communication channel between development and business teams.*