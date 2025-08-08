# Mission: Dev-Setup 🚀
## Greenfield Project Initialization

### Mission Type
**Initial Setup** - Foundation laying for new projects

### Estimated Duration
30-45 minutes

### Required Assets
- Ideation document (PRD, brand guidelines, architecture specs, vision doc)
- GitHub repository name/URL
- Project vision and goals

---

## Mission Briefing

This mission establishes the foundation for a new greenfield project by:
1. Setting up GitHub integration
2. Analyzing ideation documents
3. Creating initial project plan
4. Establishing progress tracking
5. Configuring CLAUDE.md for ongoing development

### Prerequisites
- AGENT-11 deployed to project
- Ideation document prepared
- GitHub repository created (or ready to create)

---

## Execution Protocol

### Phase 1: GitHub Setup (5 min)
```bash
/coord "Let's set up this greenfield project. First, what's the GitHub repository URL or name for this project?"
```

**Agent Actions:**
- @coordinator prompts for GitHub details
- Initializes git if needed
- Sets up remote origin
- Creates initial commit structure

### Phase 2: Ideation Analysis (10 min)
```bash
/coord "Please share your ideation document - this could be a PRD, vision doc, brand guidelines, or architecture specs"
```

**Agent Actions:**
- @strategist analyzes ideation document
- Extracts key requirements
- Identifies technical constraints
- Maps business objectives
- Notes brand/design requirements

### Phase 3: Project Planning (15 min)
```bash
/coord "Creating initial project plan based on ideation analysis..."
```

**Agent Actions:**
- @strategist creates `project-plan.md` with:
  - Executive summary
  - Core objectives
  - Technical architecture
  - Milestone roadmap
  - Success metrics
  - Risk assessment
  - Resource requirements

**project-plan.md Structure:**
```markdown
# Project Plan

## Executive Summary
[2-3 paragraph overview from ideation doc]

## Core Objectives
- [ ] Primary goal 1
- [ ] Primary goal 2
- [ ] Primary goal 3

## Technical Architecture
### Stack
- Frontend: [from ideation or TBD]
- Backend: [from ideation or TBD]
- Database: [from ideation or TBD]
- Infrastructure: [from ideation or TBD]

### Key Components
1. Component A
2. Component B
3. Component C

## Milestones
### Phase 1: Foundation (Week 1-2)
- [ ] Setup development environment
- [ ] Create basic project structure
- [ ] Implement core data models

### Phase 2: Core Features (Week 3-4)
- [ ] Feature 1
- [ ] Feature 2
- [ ] Feature 3

### Phase 3: Polish & Launch (Week 5-6)
- [ ] Testing & QA
- [ ] Performance optimization
- [ ] Deployment

## Success Metrics
- Metric 1: [target]
- Metric 2: [target]
- Metric 3: [target]

## Risk Mitigation
| Risk | Impact | Mitigation |
|------|--------|------------|
| Risk 1 | High | Strategy |
| Risk 2 | Medium | Strategy |

## Dependencies
- [ ] Dependency 1
- [ ] Dependency 2
```

### Phase 4: Progress Tracking Setup (5 min)
```bash
/coord "Setting up progress tracking system..."
```

**Agent Actions:**
- @documenter creates `progress.md`:

**progress.md Structure:**
```markdown
# Project Progress Log

## Overview
Project Start Date: [DATE]
Last Updated: [DATE]

## Completed Milestones
_None yet - just getting started!_

## Current Sprint
### Goals
- [ ] Goal 1
- [ ] Goal 2
- [ ] Goal 3

### Blockers
_None currently_

## Lessons Learned
_To be updated as we progress_

## Technical Decisions
_Key architectural and implementation decisions will be logged here_

## Performance Insights
_Optimization opportunities and performance wins_
```

### Phase 5: CLAUDE.md Configuration (10 min)
```bash
/coord "Updating CLAUDE.md with project-specific instructions..."
```

**Agent Actions:**
- @coordinator updates CLAUDE.md with:
  - Project overview from ideation
  - Tracking requirements
  - Performance insights section
  - Update protocols

**CLAUDE.md Additions:**
```markdown
## Project Overview
[Extracted from ideation document]

## Ideation Context
Location: `./ideation.md` (or specified location)
Key Requirements:
- [Requirement 1]
- [Requirement 2]
- [Requirement 3]

## Progress Tracking Protocol
After each work session or milestone:
1. Update `project-plan.md` with completed tasks
2. Log issues and resolutions in `progress.md`
3. Document lessons learned
4. Record performance insights

## Performance Insights
[To be updated with optimization opportunities]

## Update Checklist
- [ ] Milestone completed → Update project-plan.md
- [ ] Issue resolved → Log in progress.md
- [ ] Lesson learned → Add to progress.md
- [ ] Performance insight → Update CLAUDE.md
```

---

## Success Metrics

✅ **Mission Complete When:**
- [ ] GitHub repository configured
- [ ] Ideation document analyzed
- [ ] project-plan.md created with roadmap
- [ ] progress.md initialized
- [ ] CLAUDE.md updated with tracking instructions

---

## Post-Mission Checklist

1. **Verify Setup:**
   - Git repository initialized and connected
   - All tracking files created
   - CLAUDE.md properly configured

2. **First Commit:**
   ```bash
   git add .
   git commit -m "🚀 Initial project setup with AGENT-11 framework"
   git push origin main
   ```

3. **Ready for Development:**
   - Project plan established
   - Tracking system in place
   - Team aligned on objectives

---

## Troubleshooting

### Common Issues

**No Ideation Document:**
- Work with user to create basic requirements
- Use @strategist to help structure vision

**Unclear Requirements:**
- @strategist conducts discovery session
- Creates preliminary PRD from discussion

**GitHub Not Ready:**
- Guide through repository creation
- Offer to initialize locally first

---

## Related Missions
- **Dev-Alignment** - For existing projects
- **MVP** - Rapid prototype development
- **Build** - Full feature implementation

---

## Command Reference

```bash
# Quick start for greenfield project
/coord dev-setup ideation.md

# With specific GitHub repo
/coord dev-setup ideation.md --repo github.com/user/project

# With multiple ideation sources
/coord dev-setup "PRD.md, brand-guidelines.pdf, architecture.md"
```

---

*"From blank canvas to battle-ready in 30 minutes."* - AGENT-11 Field Manual