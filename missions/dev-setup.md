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

### Phase 0: MCP Discovery (2 min)
```bash
/coord "Checking available MCPs for project setup..."
```

**Agent Actions:**
- @coordinator runs grep "mcp__" to identify available tools
- Documents available MCPs in project-plan.md
- Maps MCPs to project needs:
  - Database: mcp__supabase
  - Documentation: mcp__context7
  - Testing: mcp__playwright
  - Deployment: mcp__netlify, mcp__railway
- Notes which agents should use which MCPs

### Phase 1: Memory Bootstrap from Ideation (10 min)
```bash
/coord "Bootstrap greenfield project memory from ideation.md"
```

**Agent Actions:**
- @coordinator reads ideation document(s)
- Creates `/memories` directory structure:
  - `/memories/project/` (requirements, architecture, constraints, metrics)
  - `/memories/user/` (preferences, context, goals)
  - `/memories/technical/` (decisions, patterns, tooling)
  - `/memories/lessons/` (insights, debugging, optimizations)
- Extracts to memory files using `/project/field-manual/bootstrap-guide.md`:
  - `/memories/project/requirements.xml` - Core features, user stories
  - `/memories/project/constraints.xml` - Security, performance, business limits
  - `/memories/project/architecture.xml` - Tech stack, architectural decisions
  - `/memories/user/preferences.xml` - Communication style, technical depth
  - `/memories/user/context.xml` - User background, goals, pain points
- **Security validation**: Path validation, content sanitization, size limits
- **Quality checks**: XML validation, gap identification, duplicate detection
- Reports bootstrap results and any missing information

**Reference**: See `/project/field-manual/bootstrap-guide.md` for full bootstrap protocol

### Phase 2: GitHub Setup (5 min)
```bash
/coord "Setting up GitHub integration..."
```

**Agent Actions:**
- @coordinator prompts for GitHub details
- Initializes git if needed
- Sets up remote origin
- Creates initial commit structure

### Phase 3: CLAUDE.md Generation (5 min)
```bash
/coord "Generating project-specific CLAUDE.md from memory..."
```

**Agent Actions:**
- @coordinator generates CLAUDE.md using `/templates/claude-template.md`
- Populates from memory files:
  - Project overview from requirements.xml
  - Architecture from architecture.xml
  - Constraints from constraints.xml
  - Development guidelines from preferences.xml
- Adds MCP configuration discovered in Phase 0
- Includes memory protocol and tracking requirements
- Validates completeness and accuracy

**Reference**: See `/templates/claude-template.md` for template structure

### Phase 4: Architecture Documentation (10 min)
```bash
/coord "Creating architecture documentation from memory..."
```

**Agent Actions:**
- @architect creates `architecture.md` using `/templates/architecture.md`
- Populates from `/memories/project/architecture.xml`:
  - System overview and boundaries
  - Infrastructure architecture (from memory)
  - Application architecture (from memory)
  - Data architecture (from memory)
  - Integration points
  - Architecture decisions (from memory/technical/decisions.xml)
  - Current limitations
  - Next steps
- Ensures alignment with memory and CLAUDE.md

**Reference**: See `/project/field-manual/architecture-sop.md` for comprehensive guidelines

### Phase 5: Project Planning (10 min)
```bash
/coord "Creating project plan from memory and architecture..."
```

**Agent Actions:**
- @strategist creates `project-plan.md` from memory:
  - Executive summary (from requirements.xml vision)
  - Core objectives (from requirements.xml features)
  - Technical architecture (referencing architecture.md and memory)
  - Milestone roadmap (from requirements and constraints)
  - Success metrics (from memories/project/success_metrics.xml)
  - Risk assessment
  - Resource requirements (from constraints.xml)
- Ensures alignment with memory and CLAUDE.md

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

### Phase 6: Progress Tracking Setup (5 min)
```bash
/coord "Setting up progress tracking system..."
```

**Agent Actions:**
- @documenter creates `progress.md`:
- Initializes with project start date and first milestone
- References memory for historical context

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

### Phase 7: Bootstrap Validation (5 min)
```bash
/coord "Validating bootstrap results..."
```

**Agent Actions:**
- @coordinator validates bootstrap completion:
  - ✅ Memory structure created correctly
  - ✅ All required memory files present
  - ✅ XML files are well-formed
  - ✅ Security validation passed (no directory traversal, sensitive data)
  - ✅ File sizes within limits (< 1000 tokens each)
  - ✅ CLAUDE.md generated and complete
  - ✅ Tracking files initialized
  - ✅ Architecture documentation created
- Reports any gaps or issues requiring attention
- Provides bootstrap summary for user review

**Bootstrap Summary Output:**
```markdown
## Bootstrap Complete ✅

### Memory Files Created
- /memories/project/requirements.xml (750 tokens)
- /memories/project/constraints.xml (450 tokens)
- /memories/project/architecture.xml (680 tokens)
- /memories/user/preferences.xml (320 tokens)
- /memories/user/context.xml (280 tokens)

### Project Files Generated
- CLAUDE.md (customized for project)
- architecture.md (from template + memory)
- project-plan.md (from memory)
- progress.md (initialized)

### Security Validation
- ✅ All paths validated
- ✅ No sensitive data detected
- ✅ XML structure validated
- ✅ File sizes within limits

### Gaps Requiring Clarification
[List any missing information from ideation]

### Next Steps
1. Review memory files for accuracy
2. Clarify any gaps identified
3. Begin first milestone from project-plan.md
```

---

## Success Metrics

✅ **Mission Complete When:**
- [ ] Memory structure initialized from ideation
- [ ] All memory files created and validated (requirements, constraints, architecture, preferences, context)
- [ ] Security validation passed (paths, content, file sizes)
- [ ] CLAUDE.md generated from memory
- [ ] architecture.md created from template + memory
- [ ] project-plan.md created from memory
- [ ] progress.md initialized
- [ ] GitHub repository configured
- [ ] Bootstrap validation complete with summary provided

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