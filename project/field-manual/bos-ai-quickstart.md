# BOS-AI → AGENT-11 Quickstart

Go from BOS-AI strategy to working development project in under 10 minutes.

---

## Prerequisites

- BOS-AI PRD.md document (or other strategy docs)
- AGENT-11 installed in Claude Code
- Terminal access

For detailed setup instructions, see the [full integration guide](./bos-ai-integration-guide.md).

---

## 5-Step Setup

### Step 1: Create Project Structure

Create a project directory with an `ideation/` folder for your BOS-AI documents:

```bash
mkdir marketplace-mvp && cd marketplace-mvp
mkdir ideation
ls -la
```

You should see an empty `ideation/` directory in your project.

### Step 2: Copy BOS-AI Documents

Place your BOS-AI strategy documents in the `ideation/` folder:

```bash
# Single file
cp /path/to/bos-ai/output/PRD.md ideation/

# Multiple files
cp /path/to/bos-ai/output/*.md ideation/
```

Verify the copy:
```bash
ls ideation/
```

### Step 3: Initialize AGENT-11 Project

Open Claude Code in your project directory and run:

```bash
/coord dev-setup ideation/PRD.md
```

AGENT-11 analyzes your requirements and creates:
- `project-plan.md` - Development tasks and milestones
- `progress.md` - Issue tracking and learnings
- `architecture.md` - Technical design
- `CLAUDE.md` - Project context for AI agents

This process takes 2-3 minutes.

### Step 4: Start Development

Choose a mission command based on your needs:

**Basic MVP**:
```bash
/coord build ideation/PRD.md
```

**MVP with full strategic context** (recommended):
```bash
/coord mvp ideation/PRD.md ideation/Vision\ and\ Mission.md
```

AGENT-11 coordinates its specialist agents to analyze requirements, design architecture, implement features, and test functionality. Development runs autonomously and may take hours to weeks depending on scope.

### Step 5: Monitor Progress

Check development status using these files:

```bash
# View the development plan
cat project-plan.md

# Check progress log
cat progress.md

# Review technical architecture
cat architecture.md
```

**File purposes**:
- `project-plan.md`: Tasks marked `[ ]` (pending) or `[x]` (complete)
- `progress.md`: Chronological log of work and learnings
- `architecture.md`: System design and technical decisions

---

## Troubleshooting

### AGENT-11 can't find documents
- Ensure files are in `ideation/` folder (not subdirectories)
- Use absolute path: `/coord dev-setup /full/path/to/ideation/PRD.md`

### Development doesn't match vision
- Include `Vision and Mission.md` in `ideation/` folder
- Use `/coord mvp` for more strategic context
- Review `architecture.md` to verify alignment

### Changing requirements mid-development
1. Update the document in `ideation/` folder
2. Document the change rationale in `progress.md`
3. Use `@strategist` to refine the change

---

## Common Commands

```bash
# Project setup
/coord dev-setup ideation/PRD.md

# Development missions
/coord build ideation/PRD.md                    # Basic MVP
/coord mvp ideation/PRD.md ideation/*.md        # MVP with full context

# Monitor progress
cat project-plan.md                             # View plan
cat progress.md                                 # View log
/report 2025-10-18                              # Generate report

# Manual agent control (optional)
@strategist Review ideation/PRD.md and suggest improvements
@architect Create technical architecture for ideation/PRD.md
@developer Build authentication system per ideation/PRD.md
@tester Validate all features in ideation/PRD.md
```

---

## Next Steps

- **[Full Integration Guide](./bos-ai-integration-guide.md)** - Complete documentation with advanced patterns
- **[Common Scenarios](./bos-ai-integration-guide.md#common-integration-scenarios)** - Real-world integration examples
- **Mission Templates** - See `/project/missions/` for workflow examples
- **Agent Reference** - See `/project/agents/specialists/` for capabilities

---

**Completion Time**: 5-10 minutes setup, then autonomous development
**Support**: Full documentation available in [BOS-AI Integration Guide](./bos-ai-integration-guide.md)
