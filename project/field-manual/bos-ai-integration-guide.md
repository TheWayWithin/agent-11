# BOS-AI Integration Guide

**For AGENT-11 Users Starting Projects from BOS-AI Strategy**

**Version**: 1.0.0
**Last Updated**: 2025-10-18
**Status**: Production Ready

---

## What is BOS-AI Integration?

**BOS-AI** is a Business Operating System AI Framework with 30 specialized agents focused on strategic planning, market analysis, and business requirements. **AGENT-11** is a technical execution framework with 11 development specialists.

**Together, they form a complete product development pipeline:**
- **BOS-AI** (Stage 1): Strategic planning and business requirements
- **AGENT-11** (Stage 2): MVP development and technical execution

**The Integration**: BOS-AI creates comprehensive business strategy documents → AGENT-11 reads them and builds the product.

---

## Quick Decision Tree: Do You Need BOS-AI?

### ✅ Use BOS-AI When:
- You're starting a new product from scratch
- You need comprehensive market and competitive analysis
- You want structured business strategy before development
- You're unsure about product-market fit or positioning
- You need detailed user research and persona development
- You want a phased roadmap from MVP to scale

### ✅ Use AGENT-11Standalone When:
- You have clear requirements already defined
- You're building a feature for an existing product
- You're fixing bugs or doing maintenance work
- You have a simple MVP with obvious requirements
- You're prototyping or experimenting quickly

**Bottom Line**: BOS-AI is for strategic clarity before building. AGENT-11 can work alone if you already know what to build.

---

## How BOS-AI → AGENT-11 Handoff Works

### The Simple Version

1. **You work with BOS-AI** to define your business strategy
2. **BOS-AI creates documents** explaining what to build and why
3. **You place those documents** in your AGENT-11 project's `ideation/` folder
4. **You tell AGENT-11** to read those documents and start building
5. **AGENT-11 builds** your product based on the requirements
6. **AGENT-11 reports progress** back (which you can share with BOS-AI if needed)

### The Document Bundle

BOS-AI creates a bundle of documents that AGENT-11 needs:

#### Core Requirements (Required)
- **PRD.md** - Product Requirements Document (what features to build)
- **Vision and Mission.md** - Long-term product vision (why this matters)
- **Client Success Blueprint.md** - Success metrics (how to measure success)

#### Design Guidelines (Recommended)
- **Brand Style Guide.md** - Visual identity, colors, fonts, voice
- **Market and Client Research Template.md** - Target users and research

#### Strategic Direction (Optional but helpful)
- **Strategic Roadmap.md** - Phased evolution from MVP to scale
- **Positioning Statement Template.md** - Market positioning

---

## Step-by-Step: Starting an AGENT-11 Project from BOS-AI

### Prerequisites

✅ You've completed BOS-AI strategic planning
✅ You have BOS-AI documents ready
✅ You have AGENT-11 deployed in Claude Code
✅ You have a project directory ready

### Step 1: Prepare Your Project Directory

Create a new AGENT-11 project directory with an ideation folder for BOS-AI strategy documents:

```bash
mkdir my-project
cd my-project
mkdir ideation
```

---

### Step 2: Copy BOS-AI Documents

Locate your BOS-AI output directory (typically `bos-ai/output/projects/{project-name}/bundle-v{version}/`) and copy the strategy documents to your project's `ideation/` folder:

```bash
cp bos-ai/output/projects/my-saas/bundle-v1.0.0/PRD.md my-project/ideation/
cp bos-ai/output/projects/my-saas/bundle-v1.0.0/Vision\ and\ Mission.md my-project/ideation/
cp bos-ai/output/projects/my-saas/bundle-v1.0.0/Brand\ Style\ Guide.md my-project/ideation/
```

**Required Documents**:
- `PRD.md` - Product requirements (required)

**Recommended Documents**:
- `Vision and Mission.md` - Strategic context
- `Brand Style Guide.md` - Design consistency
- `Client Success Blueprint.md` - Success metrics

---

### Step 3: Initialize AGENT-11 Project

Initialize the AGENT-11 project structure and tracking files:

```bash
/coord dev-setup ideation/PRD.md
```

This command:
- Analyzes the PRD and supporting ideation documents
- Creates `project-plan.md` with development tasks
- Creates `progress.md` for tracking issues and learnings
- Creates `architecture.md` with technical design
- Configures `CLAUDE.md` with project context

---

### Step 4: Start Development

Choose the appropriate mission command based on your needs:

#### MVP Development (Most Common)
```bash
/coord build ideation/PRD.md
```
Builds the complete MVP as defined in your PRD.

#### MVP with Strategic Context
```bash
/coord mvp ideation/PRD.md ideation/Vision\ and\ Mission.md
```
Includes vision document for better strategic alignment.

#### Feature Development with Branding
```bash
/coord build ideation/PRD.md ideation/Brand\ Style\ Guide.md
```
Ensures brand consistency in feature implementation.

The development process includes:
- Requirements analysis
- Architecture design
- Feature implementation
- Functionality testing
- Progress tracking updates

---

### Step 5: Monitor Progress

Track development progress through the generated tracking files:

```bash
# View development plan
cat project-plan.md

# Check progress log
cat progress.md

# Review technical architecture
cat architecture.md
```

**Progress File Structure**:
- **project-plan.md**: Task list with `[ ]` (pending) and `[x]` (complete) markers
- **progress.md**: Chronological log of deliverables, issues encountered, and lessons learned

---

## Common Integration Scenarios

### Scenario 1: Pure BOS-AI → AGENT-11 Workflow

**Situation**: You're a solo founder starting fresh with BOS-AI strategic planning.

**Workflow**:
1. Work with BOS-AI to analyze market and define product
2. BOS-AI creates comprehensive requirements bundle
3. Copy bundle to AGENT-11 `ideation/` folder
4. Run `/coord dev-setup ideation/PRD.md`
5. Run `/coord build ideation/PRD.md`
6. Share progress.md with BOS-AI if you want strategic feedback

**Timeline**: BOS-AI strategy (2-5 days) → AGENT-11 setup (15 min) → Development (1-12 weeks)

---

### Scenario 2: BOS-AI Requirements → Manual AGENT-11

**Situation**: You want BOS-AI strategy but prefer to direct AGENT-11 agents manually.

**Workflow**:
1. Get BOS-AI documents as usual
2. Place in `ideation/` folder
3. Instead of `/coord`, use individual agents:
   - `@strategist` - Review and refine requirements
   - `@architect` - Design technical architecture
   - `@developer` - Implement features
   - `@tester` - Validate functionality

**When to use**: You want fine-grained control over each development phase.

---

### Scenario 3: Partial BOS-AI Integration

**Situation**: You have some BOS-AI docs but also your own requirements.

**Workflow**:
1. Place BOS-AI documents in `ideation/`
2. Add your own `custom-requirements.md` in `ideation/`
3. Run `/coord dev-setup ideation/PRD.md ideation/custom-requirements.md`
4. AGENT-11 combines all documents for context

**When to use**: You're supplementing BOS-AI strategy with technical details or constraints.

---

### Scenario 4: BOS-AI Progress Reports

**Situation**: You want to keep BOS-AI updated on development progress.

**Workflow**:
1. After significant progress, review `progress.md`
2. Create a summary report for BOS-AI:
   - What's completed
   - What's in progress
   - Any blockers or changes needed
3. Share with BOS-AI for strategic feedback or course correction

**When to use**: You're using BOS-AI as an ongoing strategic advisor during development.

---

## Document Format Requirements

### What AGENT-11 Expects

**Minimum Required**:
- At least one requirements document (PRD is standard)
- Markdown format (.md files)
- Clear sections and headers
- User stories or feature descriptions

**Recommended Structure for PRD**:
```markdown
# Product Requirements Document

## Problem Statement
[What problem are we solving?]

## Solution Overview
[High-level approach]

## Target Users
[Who is this for?]

## Core Features
### Feature 1: [Name]
- **User Story**: As a [user], I want [action] so that [benefit]
- **Acceptance Criteria**:
  - [ ] Criterion 1
  - [ ] Criterion 2

## Technical Requirements
[Performance, security, integrations]

## Success Metrics
[How we measure success]
```

**BOS-AI Output**: Already in the right format! Just copy and use.

---

## Troubleshooting Integration Issues

### Problem: AGENT-11 Can't Find Documents

**Symptoms**: Error messages indicating missing requirements or context files.

**Solutions**:
1. Verify files are in `ideation/` folder (not in subdirectories)
2. Confirm file names match references in commands
3. Use absolute paths if needed: `/coord dev-setup /full/path/to/ideation/PRD.md`

---

### Problem: Requirements Are Unclear

**Symptoms**: Frequent clarification requests from AGENT-11.

**Solutions**:
1. Review PRD for specific user stories with acceptance criteria
2. Add `context.md` with business rationale
3. Include `Vision and Mission.md` for strategic clarity
4. Use `/coord mvp` for more comprehensive requirements analysis

---

### Problem: Development Doesn't Match Vision

**Symptoms**: Implemented features diverge from expected product direction.

**Solutions**:
1. Ensure `Vision and Mission.md` is present in `ideation/` folder
2. Include `Brand Style Guide.md` for design alignment
3. Review `project-plan.md` early to validate direction
4. Update requirements and re-run setup if needed

---

### Problem: Need to Change Requirements Mid-Development

**Symptoms**: Requirements need adjustment after development has begun.

**Solutions**:
1. Update the relevant document in `ideation/` folder
2. Document the change and rationale in `progress.md`
3. Create a change request document for major changes
4. Use `@strategist` to refine the change
5. Have `@architect` assess impact before `@developer` implements

**Best Practice**: Implement small, incremental changes rather than large pivots.

---

## Advanced Integration Patterns

### Pattern 1: Iterative Refinement

**Use Case**: You want to iterate on BOS-AI strategy based on AGENT-11 technical findings.

**Workflow**:
1. Initial BOS-AI strategy → AGENT-11 analysis
2. AGENT-11 discovers technical constraints
3. Document constraints in `progress.md`
4. Return to BOS-AI with constraints for strategy adjustment
5. BOS-AI creates updated bundle (new version)
6. Update `ideation/` with new documents
7. Continue development with refined strategy

**Benefits**: Strategy stays realistic and technically feasible.

---

### Pattern 2: Multi-Stage Handoffs

**Use Case**: You're building a complex product in phases.

**Workflow**:
1. BOS-AI creates Phase 1 requirements
2. AGENT-11 builds Phase 1 MVP
3. BOS-AI creates Phase 2 requirements (based on learnings)
4. AGENT-11 builds Phase 2 features
5. Repeat for subsequent phases

**Document Management**:
- Keep phase-specific documents in `ideation/phase-1/`, `ideation/phase-2/`, etc.
- Update `CLAUDE.md` to reference current phase
- Maintain `architecture.md` across phases for consistency

---

### Pattern 3: BOS-AI as Strategic Reviewer

**Use Case**: You want BOS-AI feedback on development progress.

**Workflow**:
1. After each AGENT-11 milestone, export progress summary
2. Share with BOS-AI for strategic analysis
3. BOS-AI evaluates alignment with business goals
4. BOS-AI suggests course corrections if needed
5. Incorporate feedback into next development cycle

**Export Command**:
```bash
/report 2025-01-01  # Generates progress report since specified date
```

---

## Best Practices for Integration

### Do's ✅

**Strategic Clarity**:
- ✅ Complete BOS-AI strategy before starting AGENT-11 development
- ✅ Include Vision and Mission for long-term alignment
- ✅ Define success metrics clearly in Client Success Blueprint
- ✅ Update ideation documents when requirements change

**Project Setup**:
- ✅ Use descriptive project directory names
- ✅ Keep ideation folder clean (only strategy documents)
- ✅ Review `project-plan.md` before significant development begins
- ✅ Monitor `progress.md` for issues and learnings

**Communication**:
- ✅ Document all requirement changes in `progress.md`
- ✅ Use change requests for major scope changes
- ✅ Keep BOS-AI strategy and AGENT-11 implementation in sync
- ✅ Report technical constraints back to strategy layer

---

### Don'ts ❌

**Strategic Shortcuts**:
- ❌ Skip BOS-AI strategy for complex products (results in unfocused development)
- ❌ Start AGENT-11 development before BOS-AI documents are ready
- ❌ Ignore business context when making technical decisions
- ❌ Build features not in requirements without updating PRD first

**Project Management**:
- ❌ Mix multiple projects in one `ideation/` folder
- ❌ Modify BOS-AI documents without version tracking
- ❌ Skip the `/coord dev-setup` initialization step
- ❌ Lose track of which requirements version you're implementing

**Process Violations**:
- ❌ Change requirements without documenting why
- ❌ Bypass validation and quality gates under time pressure
- ❌ Ignore AGENT-11's technical constraint findings
- ❌ Build first, strategize later (defeats the purpose of integration)

---

## Integration Success Metrics

### How to Know It's Working

**Strategic Alignment** (80%+ target):
- Development builds what strategy defined
- Technical decisions support business goals
- Features match user needs from research
- Success metrics are measurable and tracked

**Efficiency Gains** (30%+ faster):
- Less rework from unclear requirements
- Faster development with complete context
- Fewer scope changes mid-development
- Better prioritization and focus

**Quality Indicators** (95%+ target):
- Features meet acceptance criteria on first delivery
- User stories are complete and testable
- Business rationale is clear to development team
- Technical debt is minimal

---

## Quick Reference Commands

### Project Initialization
```bash
# New project from BOS-AI strategy
/coord dev-setup ideation/PRD.md

# With vision context
/coord dev-setup ideation/PRD.md ideation/Vision\ and\ Mission.md
```

### Development Missions
```bash
# Build complete MVP
/coord build ideation/PRD.md

# MVP with full strategic context
/coord mvp ideation/PRD.md ideation/Vision\ and\ Mission.md

# Feature development with branding
/coord build ideation/PRD.md ideation/Brand\ Style\ Guide.md
```

### Progress Tracking
```bash
# View development plan
cat project-plan.md

# Check progress log
cat progress.md

# View technical architecture
cat architecture.md

# Generate progress report
/report 2025-01-01
```

### Manual Agent Control
```bash
# Review requirements
@strategist Review ideation/PRD.md and suggest improvements

# Design architecture
@architect Create technical architecture for ideation/PRD.md

# Implement features
@developer Build authentication system per ideation/PRD.md

# Test functionality
@tester Validate all features in ideation/PRD.md
```

---

## When to Use Which Approach

### Use `/coord` Missions When:
- You want AGENT-11 to orchestrate multiple specialists automatically
- You have complete requirements and trust the framework
- You're building a standard web/mobile application
- You want hands-off development with progress tracking

### Use Manual `@agent` Commands When:
- You need fine-grained control over each development phase
- You're working on unusual or highly specialized projects
- You want to review each step before proceeding
- You're learning how AGENT-11 agents work together

### Use Hybrid Approach When:
- You want `/coord` for routine tasks but manual control for critical parts
- You're experimenting with different architectures
- You want to validate strategy before full implementation
- You're teaching or demonstrating the framework

---

## Next Steps

### For New Users
1. ✅ **Review this guide** for integration fundamentals
2. ✅ **Prepare BOS-AI documents** in `ideation/` folder
3. ✅ **Run `/coord dev-setup`** to initialize project
4. ✅ **Start development** with `/coord build` or `/coord mvp`
5. ✅ **Monitor progress** in `progress.md` and `project-plan.md`

### For Advanced Users
- **Study**: Review [WORKFLOWS.md](../../WORKFLOWS.md) for detailed process flows
- **Customize**: Read [INTEGRATION-STANDARDS.md](../../INTEGRATION-STANDARDS.md) for document formats
- **Optimize**: Explore [BOS-AI-INTEGRATION-ARCHITECTURE.md](../../BOS-AI-AGENT-11-INTEGRATION-ARCHITECTURE.md) for technical details
- **Automate**: Set up validation pipeline for multi-project workflows

---

## Additional Resources

### In This Repository
- **CLAUDE.md**: Project-specific guidance for Claude Code
- **project-plan.md**: Your current development roadmap (created after dev-setup)
- **progress.md**: Development log and learnings (created after dev-setup)
- **architecture.md**: Technical design documentation (created after dev-setup)

### BOS-AI Documentation
- BOS-AI repository: https://github.com/TheWayWithin/BOS-AI
- BOS-AI strategic framework and agent documentation
- Template library for business documents

### AGENT-11 Documentation
- **Field Manual**: `/project/field-manual/` - Integration guides and best practices
- **Mission Guides**: `/project/missions/` - Detailed workflow documentation
- **Agent Profiles**: `/project/agents/specialists/` - Individual agent capabilities

---

## Support

### Common Questions

**Q: Can I use AGENT-11 without BOS-AI?**
A: Yes! AGENT-11 works standalone with any requirements. BOS-AI integration is optional for when you want comprehensive strategic planning.

**Q: What if my BOS-AI documents don't match the expected format?**
A: AGENT-11 is flexible. As long as you have clear requirements in Markdown, it will work. PRD format is recommended but not strictly required.

**Q: Can I modify BOS-AI documents after handoff?**
A: Yes, but document changes in `progress.md` and consider updating version numbers. Keep strategy and implementation in sync.

**Q: How do I report AGENT-11 progress back to BOS-AI?**
A: Use `/report` command to generate progress summaries, or manually extract key updates from `progress.md` to share with BOS-AI for strategic feedback.

**Q: What if AGENT-11 finds technical issues with BOS-AI strategy?**
A: Document constraints in `progress.md`, create a change request, and consider returning to BOS-AI for strategy refinement. This is a feature, not a bug - better to find issues early.

---

**Last Updated**: 2025-10-18
**Maintained By**: AGENT-11 Core Team
**Feedback**: Submit issues or improvements via repository

---

*The BOS-AI ↔ AGENT-11 integration represents a new paradigm: strategic AI plans, technical AI builds, humans guide both.*
