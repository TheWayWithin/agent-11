# Mission: Dev-Alignment 🎯
## Existing Project Understanding & Setup

### Mission Type
**Project Analysis** - Understanding and aligning with existing codebases

### Estimated Duration
45-60 minutes

### Required Assets
- Existing codebase
- Ideation documents (if available)
- Project documentation
- User context/vision

---

## Mission Briefing

This mission aligns AGENT-11 with an existing project by:
1. Analyzing current codebase structure
2. Understanding project goals and context
3. Reviewing or creating ideation documents
4. Establishing progress tracking
5. Optimizing CLAUDE.md for the specific project

### Prerequisites
- AGENT-11 deployed to existing project
- Access to codebase
- Project context (from docs or user)

---

## Execution Protocol

### Phase 0: MCP Assessment (3 min)
```bash
/coord "Discovering available MCPs in the project..."
```

**Agent Actions:**
- @coordinator checks for available MCPs with grep "mcp__"
- Identifies which MCPs are configured
- Maps MCPs to current architecture:
  - If Supabase used: Check for mcp__supabase
  - If tests exist: Check for mcp__playwright
  - For any libraries: Note mcp__context7 availability
- Documents MCP availability in analysis

### Phase 1: Codebase Analysis (15 min)
```bash
/coord "Starting project alignment. Let me analyze your existing codebase..."
```

**Agent Actions:**
- @architect performs codebase audit:
  - Technology stack identification
  - Architecture pattern analysis
  - Dependencies review
  - Code quality assessment
  - Test coverage check
- @developer identifies:
  - Core functionality
  - Integration points
  - Development patterns
  - Build/deployment setup

**Analysis Output:**
```markdown
## Codebase Analysis

### Technology Stack
- Language: [detected]
- Framework: [detected]
- Database: [detected]
- Testing: [detected]

### Architecture
- Pattern: [MVC/Microservices/etc]
- Structure: [description]

### Current State
- Lines of Code: [count]
- Test Coverage: [percentage]
- Dependencies: [count]
- Last Updated: [date]

### Key Components
1. [Component 1]
2. [Component 2]
3. [Component 3]
```

### Phase 2: Context Discovery (15 min)
```bash
/coord "Now let's understand your project's mission. Do you have ideation documents, or shall we discover the context together?"
```

**Two Paths:**

#### Path A: Existing Ideation Documents
**Agent Actions:**
- @strategist reviews provided documents
- Extracts key objectives
- Identifies gaps in documentation
- Creates consolidated vision

#### Path B: Context Discovery Session
**Agent Actions:**
- @strategist conducts discovery:
  ```
  Questions:
  1. What problem does this project solve?
  2. Who are the target users?
  3. What are the core features?
  4. What's the current status?
  5. What are the immediate goals?
  6. What are the pain points?
  7. What's the vision for success?
  ```
- @documenter creates ideation.md from responses

**ideation.md Structure (if created):**
```markdown
# Project Ideation Document

## Vision
[2-3 paragraphs from discovery]

## Problem Statement
[What problem are we solving]

## Target Users
- User Type 1: [description]
- User Type 2: [description]

## Core Features
1. Feature 1: [description]
2. Feature 2: [description]
3. Feature 3: [description]

## Current Status
- Development Stage: [POC/MVP/Production]
- Users: [count if applicable]
- Key Metrics: [if applicable]

## Immediate Goals
- [ ] Goal 1
- [ ] Goal 2
- [ ] Goal 3

## Success Criteria
- Criterion 1
- Criterion 2
- Criterion 3

## Technical Requirements
[Extracted from codebase analysis]

## Constraints
- Budget: [if applicable]
- Timeline: [if applicable]
- Technical: [if applicable]
```

### Phase 3: Architecture Review/Documentation (10 min)
```bash
/coord "Reviewing and documenting system architecture..."
```

**Agent Actions:**
- @architect reviews existing architecture or creates new documentation:

#### Path A: Existing architecture.md
- Reviews current documentation
- Updates with recent changes
- Identifies architectural drift
- Adds missing sections

#### Path B: No architecture.md exists
- Creates architecture.md using template from `/templates/architecture.md`
- Documents current system design
- Identifies architectural patterns
- Maps infrastructure and data flows
- Records architecture decisions

**Reference**: See `/project/field-manual/architecture-sop.md` for documentation standards

### Phase 4: Project Plan Creation/Update (15 min)
```bash
/coord "Creating project plan based on analysis and context..."
```

**Agent Actions:**
- @strategist creates/updates `project-plan.md`:

**project-plan.md Structure:**
```markdown
# Project Plan

## Executive Summary
[From ideation/discovery]

## Current State Assessment
### Strengths
- [Strength 1]
- [Strength 2]

### Improvement Areas
- [Area 1]
- [Area 2]

### Technical Debt
- [Debt item 1]
- [Debt item 2]

## Roadmap
### Immediate (Week 1-2)
- [ ] Priority task 1
- [ ] Priority task 2
- [ ] Priority task 3

### Short-term (Week 3-4)
- [ ] Feature/Fix 1
- [ ] Feature/Fix 2

### Medium-term (Month 2-3)
- [ ] Major feature 1
- [ ] Major feature 2

## Optimization Opportunities
[From codebase analysis]

## Risk Assessment
| Risk | Impact | Current State | Mitigation |
|------|--------|--------------|------------|
| Risk 1 | High | Active | Strategy |
| Risk 2 | Medium | Potential | Strategy |

## Resource Requirements
- Development: [hours/week]
- Testing: [hours/week]
- DevOps: [if applicable]
```

### Phase 5: Progress Tracking Setup (5 min)
```bash
/coord "Setting up progress tracking..."
```

**Agent Actions:**
- @documenter creates/updates `progress.md` from `/templates/progress-template.md`:

**progress.md Structure:**
```markdown
# Progress Log
# BACKWARD-LOOKING changelog: deliverables, changes, and complete issue history

**Mission**: [Project Name]
**Project Start**: [original date]
**AGENT-11 Onboarding**: [today's date]
**Last Updated**: [today's date]

## Historical Context
[Summary of work done before AGENT-11]

## 📦 Deliverables
[Log what was created/changed with descriptions - both historical and new]

## 🔨 Changes Made
[Record modifications with rationale - track all changes going forward]

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
### Pre-AGENT-11
[Any existing lessons from codebase history]

### With AGENT-11
[Key insights and patterns from missions]

## 📊 Metrics & Progress
[Time tracking, velocity, quality indicators]
```

### Phase 6: CLAUDE.md Optimization (10 min)
```bash
/coord "Optimizing CLAUDE.md for your specific project..."
```

**Agent Actions:**
- @coordinator updates CLAUDE.md with:

**CLAUDE.md Updates:**
```markdown
## Project Overview
[From ideation/discovery]

## Available MCPs
[From MCP assessment phase]
- mcp__[service]: [Usage in project]
- Example: mcp__supabase: Database operations
- Example: mcp__playwright: E2E testing
- Example: mcp__context7: Library documentation

## Codebase Structure
[From analysis]

## Development Guidelines
### Code Style
[Detected patterns]

### Testing Approach
[Current testing strategy]
[Note if mcp__playwright available for testing]

### Build & Deploy
[Current processes]
[Note if mcp__netlify or mcp__railway available]

## Ideation Context
Location: `./ideation.md`
Last Updated: [date]

## Key Objectives
1. [Objective 1]
2. [Objective 2]
3. [Objective 3]

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

## Performance Insights
### Current Bottlenecks
[From analysis]

### Optimization Opportunities
[From analysis]
[MCPs that could help]

## Technical Decisions Log
[Important decisions that affect development]
[MCPs chosen for specific tasks]

## Common Commands
```bash
# Build
[project-specific build command]

# Test
[project-specific test command]

# Run
[project-specific run command]

# MCP Discovery
grep "mcp__"
```

## Known Issues
[Any identified issues]
[MCPs that might help resolve]

## Update Checklist
- [ ] Deliverable created → Log in progress.md with description
- [ ] Code/config changed → Record in progress.md with rationale
- [ ] Issue discovered → Create issue entry in progress.md
- [ ] Fix attempted → Log attempt with result and learning in progress.md
- [ ] Issue resolved → Add root cause analysis to progress.md
- [ ] Task completed → Mark [x] in project-plan.md
- [ ] Performance insight → Update CLAUDE.md
- [ ] Pattern discovered → Document in CLAUDE.md
- [ ] MCP usage → Track successful patterns in CLAUDE.md
```

---

## Success Metrics

✅ **Mission Complete When:**
- [ ] Codebase fully analyzed
- [ ] Project context understood
- [ ] Ideation document reviewed/created
- [ ] architecture.md reviewed/created
- [ ] project-plan.md created/updated with FORWARD-LOOKING roadmap
- [ ] progress.md initialized from template with BACKWARD-LOOKING changelog structure
- [ ] CLAUDE.md optimized for project (including Critical Software Development Principles)

---

## Post-Mission Checklist

1. **Alignment Verification:**
   - Understanding documented
   - Tracking files in place
   - CLAUDE.md customized

2. **Commit Changes:**
   ```bash
   git add .
   git commit -m "🎯 AGENT-11 aligned with existing project"
   git push
   ```

3. **Ready for Enhancement:**
   - Current state understood
   - Improvement plan created
   - Tracking established

---

## Troubleshooting

### Common Issues

**No Documentation:**
- Conduct thorough discovery session
- Create ideation.md from scratch
- Use code analysis for context

**Complex Legacy Code:**
- Focus on critical paths first
- Document understanding incrementally
- Prioritize high-impact areas

**Unclear Objectives:**
- Work with user to clarify
- Start with immediate pain points
- Build vision iteratively

---

## Related Missions
- **Dev-Setup** - For greenfield projects
- **Refactor** - Code improvement mission
- **Debug** - Issue resolution mission
- **Scale** - Performance optimization

---

## Command Reference

```bash
# Quick alignment for existing project
/coord dev-alignment

# With existing ideation document
/coord dev-alignment --ideation requirements.md

# Focus on specific area
/coord dev-alignment --focus backend

# Skip certain phases
/coord dev-alignment --skip-analysis
```

---

*"Understanding before action, alignment before advancement."* - AGENT-11 Field Manual