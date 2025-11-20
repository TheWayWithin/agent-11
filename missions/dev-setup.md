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

### Phase 0: MCP Profile Setup (2 min)

**Recommended**: Start with the `core` profile for lightweight development:
```bash
ln -sf .mcp-profiles/core.json .mcp.json
# Restart Claude Code
```

Switch to specialized profiles as needed (testing, deployment, etc.). See [MCP Profile Guide](../../docs/MCP-GUIDE.md) for details.

**Agent Actions:**
- @coordinator identifies which MCP profile matches project needs
- Documents profile selection in project-plan.md
- Notes when to switch profiles for specific tasks (testing, deployment)

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

### Phase 3: Architecture Documentation (10 min)
```bash
/coord "Creating architecture documentation based on ideation and requirements..."
```

**Agent Actions:**
- @architect creates `architecture.md` using template:
  - System overview and boundaries
  - Infrastructure architecture
  - Application architecture
  - Data architecture
  - Integration points
  - Architecture decisions
  - Current limitations
  - Next steps

**Note**: Uses `/templates/architecture.md` as starting point
**Reference**: See `/project/field-manual/architecture-sop.md` for comprehensive guidelines

### Phase 4: Project Planning (15 min)
```bash
/coord "Creating initial project plan based on ideation analysis and architecture..."
```

**Agent Actions:**
- @strategist creates `project-plan.md` with:
  - Executive summary
  - Core objectives
  - Technical architecture (referencing architecture.md)
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

### Phase 5: Progress Tracking Setup (5 min)
```bash
/coord "Setting up progress tracking system..."
```

**Agent Actions:**
- @documenter creates `progress.md` from `/templates/progress-template.md`:

**progress.md Structure:**
```markdown
# Progress Log
# BACKWARD-LOOKING changelog: deliverables, changes, and complete issue history

**Mission**: [Project Name]
**Started**: [YYYY-MM-DD]
**Last Updated**: [YYYY-MM-DD]

## 📦 Deliverables
[Log what was created/changed with descriptions]

## 🔨 Changes Made
[Record modifications with rationale]

## 🐛 Issues Encountered
[Complete issue history with ALL fix attempts - including failures]

### Issue #[ID]: [Title]
**Discovered**: [timestamp] by @[agent]
**Status**: [🔴 Open | 🟡 In Progress | 🟢 Resolved]

#### Fix Attempts
##### Attempt #1: [Approach]
**Result**: [✅ Success | ❌ Failed | ⚠️ Partial]
**Rationale**: Why we thought this would work
**What We Tried**: Specific changes made
**Outcome**: What actually happened
**Learning**: What this taught us

#### Resolution (if resolved)
**Root Cause**: Underlying reason
**Why Previous Attempts Failed**: Analysis
**Prevention Strategy**: How to avoid in future

## 🎓 Lessons Learned
[Key insights and patterns]

## 📊 Metrics & Progress
[Time tracking, velocity, quality indicators]
```

### Phase 6: CLAUDE.md Configuration (10 min)
```bash
/coord "Updating CLAUDE.md with project-specific instructions..."
```

**Agent Actions:**
- @coordinator updates CLAUDE.md with:
  - Project overview from ideation
  - Available MCPs and their usage
  - Tracking requirements
  - Performance insights section
  - Update protocols

**CLAUDE.md Additions:**
```markdown
## Project Overview
[Extracted from ideation document]

## Available MCPs
[Discovered MCPs and their assigned usage]
- mcp__supabase: Database operations (@developer, @operator)
- mcp__context7: Documentation (@all agents)
- mcp__playwright: Testing (@tester)
- mcp__firecrawl: Research (@architect, @developer)
- [Additional MCPs as discovered]

## Ideation Context
Location: `./ideation.md` (or specified location)
Key Requirements:
- [Requirement 1]
- [Requirement 2]
- [Requirement 3]

## Progress Tracking Protocol

### project-plan.md (FORWARD-LOOKING)
**What we're PLANNING to do**:
- Update when: Mission start, phase start, task completion
- Task lists with checkboxes [ ] → [x]
- Milestones, success metrics, risk assessment

### progress.md (BACKWARD-LOOKING CHANGELOG)
**What we DID and what we LEARNED**:
- Update when: After EACH deliverable, after EACH fix attempt, when issue resolved
- Log ALL fix attempts (including failures) - not just final solutions
- Root cause analysis for all issues
- Prevention strategies and lessons learned
- **CRITICAL**: Failed attempts teach us what doesn't work and why

### Update After:
1. **Each Deliverable**: Log to progress.md with description
2. **Each Change**: Record in progress.md with rationale
3. **Issue Discovery**: Create issue entry in progress.md immediately
4. **EACH Fix Attempt**: Log attempt, rationale, result, learning (even if it fails)
5. **Issue Resolution**: Add root cause analysis and prevention strategy
6. **Task Completion**: Mark [x] in project-plan.md
7. **Phase End**: Update both files with results and lessons

## Update Checklist
- [ ] Deliverable created → Log in progress.md with description
- [ ] Code/config changed → Record in progress.md with rationale
- [ ] Issue discovered → Create issue entry in progress.md
- [ ] Fix attempted → Log attempt with result and learning in progress.md
- [ ] Issue resolved → Add root cause analysis to progress.md
- [ ] Task completed → Mark [x] in project-plan.md
- [ ] Performance insight → Update CLAUDE.md
- [ ] MCP pattern discovered → Document usage in CLAUDE.md
```

---

## Success Metrics

✅ **Mission Complete When:**
- [ ] GitHub repository configured
- [ ] Ideation document analyzed
- [ ] architecture.md created from template
- [ ] project-plan.md created with FORWARD-LOOKING roadmap
- [ ] progress.md initialized from template with BACKWARD-LOOKING changelog structure
- [ ] CLAUDE.md updated with tracking instructions (including Critical Software Development Principles)

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

## Post-Mission Cleanup Decision

After completing this mission, decide on cleanup approach based on project status:

### ✅ Milestone Transition (Every 2-4 weeks)
**When**: This mission completes a major project milestone, but more work remains.

**Actions** (30-60 min):
1. Extract lessons to `lessons/[category]/` from progress.md
2. Archive current handoff-notes.md to `archives/handoffs/milestone-X/`
3. Clean agent-context.md (retain essentials, archive historical details)
4. Create fresh handoff-notes.md for next milestone
5. Update project-plan.md with next milestone tasks

**See**: `templates/cleanup-checklist.md` Section A for detailed steps

### 🎯 Project Completion (Mission accomplished!)
**When**: All project objectives achieved, ready for new mission.

**Actions** (1-2 hours):
1. Extract ALL lessons from entire progress.md to `lessons/`
2. Create mission archive in `archives/missions/mission-[name]-YYYY-MM-DD/`
3. Update CLAUDE.md with system-level learnings
4. Archive all tracking files (project-plan.md, progress.md, etc.)
5. Prepare fresh start for next mission

**See**: `templates/cleanup-checklist.md` Section B for detailed steps

### 🔄 Continue Active Work (No cleanup needed)
**When**: Mission complete but continuing active development in same phase.

**Actions**: Update progress.md and project-plan.md, continue working.

---

**Reference**: See `project/field-manual/project-lifecycle-guide.md` for complete lifecycle management procedures.

---

*"From blank canvas to battle-ready in 30 minutes."* - AGENT-11 Field Manual