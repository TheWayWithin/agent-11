# Coordinator Commands Guide 🎖️

## Overview

The `/coord` command transforms THE COORDINATOR into a mission-driven orchestration system. Instead of manually managing multi-agent workflows, you can execute predefined missions with a single command.

## Command Syntax

```bash
/coord [mission] [input1] [input2] ... [inputN]
```

### Components

- **`/coord`** - Invokes the coordinator in mission mode
- **`[mission]`** - Mission code (build, fix, mvp, etc.) 
- **`[input1...N]`** - File references for mission context

## Usage Modes

### 1. Interactive Mode (No Arguments)

```bash
/coord
```

The coordinator will:
- Present available missions menu
- Guide you through mission selection
- Request required inputs interactively
- Begin orchestration with your choices

### 2. Mission Mode (With Arguments)

```bash
/coord build requirements.md
```

The coordinator will:
- Load the specified mission briefing
- Parse provided input documents
- Confirm mission parameters
- Execute mission phases systematically

### 3. Multi-Input Mode

```bash
/coord mvp vision.md market-research.md budget.md
```

The coordinator will:
- Load mission with all provided context
- Distribute inputs to appropriate phases
- Leverage full context for better results

## Available Missions

### Core Development

- **`build`** - Transform requirements into features (4-8 hours)
- **`fix`** - Emergency bug resolution (1-3 hours)
- **`refactor`** - Code quality improvement (2-4 hours)
- **`deploy`** - Production deployment prep (1-2 hours)

### Strategic Missions

- **`mvp`** - Rapid prototype development (1-3 days)
- **`migrate`** - System/platform migration (4-8 hours)
- **`optimize`** - Performance improvements (3-6 hours)
- **`security`** - Security audit and fixes (4-6 hours)

### Support Missions

- **`document`** - Create documentation (2-4 hours)
- **`integrate`** - Third-party integrations (3-6 hours)

## Mission Execution Flow

```mermaid
graph TD
    A[/coord Command] --> B{Arguments?}
    B -->|No| C[Interactive Mode]
    B -->|Yes| D[Load Mission]
    C --> E[Select Mission]
    C --> F[Gather Inputs]
    F --> D
    D --> G[Parse Inputs]
    G --> H[Confirm Mission]
    H --> I[Execute Phases]
    I --> J[Track Progress]
    J --> K[Mission Complete]
```

## Examples

### Building a New Feature

```bash
# With detailed PRD
/coord build product-requirements.md

# With multiple inputs
/coord build prd.md design-system.md api-spec.md
```

### Fixing a Critical Bug

```bash
# With bug report
/coord fix bug-report.md

# With additional context
/coord fix error-logs.txt reproduction-steps.md
```

### Creating an MVP

```bash
# From vision document
/coord mvp startup-vision.md

# With market research
/coord mvp vision.md competitor-analysis.md user-feedback.md
```

### Quick Refactor

```bash
# Target specific module
/coord refactor user-service-analysis.md

# With performance goals
/coord refactor code-review.md performance-targets.md
```

## Mission Tracking

During mission execution:

1. **project-plan.md** - Updated with mission tasks
2. **progress.md** - Captures learnings and insights
3. **Status Updates** - Real-time progress tracking
4. **Specialist Handoffs** - Clear delegation tracking

## Best Practices

### Input Preparation

- Provide comprehensive context in input files
- Include constraints and requirements
- Add success criteria when possible
- Reference existing documentation

### Mission Selection

- Choose the most specific mission
- Use `mvp` for new products
- Use `build` for defined features
- Use `fix` for urgent issues

### Progress Monitoring

- Check project-plan.md for status
- Review specialist outputs
- Provide clarification when requested
- Trust the orchestration process

## Customizing Missions

### Creating New Missions

1. Copy `/templates/mission-template.md`
2. Define clear phases and agents
3. Add to `/missions/` directory
4. Update mission library
5. Test with coordinator

### Modifying Existing Missions

- Fork mission file
- Adjust phases/timing
- Update success criteria
- Document variations

## Troubleshooting

### Common Issues

**"Mission not found"**
- Check mission name spelling
- Verify mission exists in library
- Use `/coord` without arguments to see list

**"Input file not found"**
- Ensure file paths are correct
- Use relative paths from project root
- Drag files into chat if needed

**"Specialist not responding"**
- Coordinator will reassign or escalate
- Check for context window limits
- Break down complex tasks

### Mission Abort

To stop a mission:
1. Interrupt current agent
2. Tell coordinator to halt
3. Review progress.md
4. Plan recovery approach

## Advanced Usage

### Chaining Missions

```bash
# MVP then documentation
/coord mvp vision.md
# After MVP completes...
/coord document
```

### Parallel Missions

Run separate missions in different threads:
- Feature A: `/coord build feature-a.md`
- Feature B: `/coord build feature-b.md`

### Mission Variations

Some missions support quick modes:
```bash
# Quick fix (30 min)
/coord fix bug.md --quick

# Enterprise build (extended)
/coord build enterprise-spec.md --extended
```

## Integration Tips

### With Git Workflow

1. Create feature branch
2. Run `/coord build feature.md`
3. Review implementation
4. Commit with mission reference

### With Project Management

- Link missions to tickets
- Update PM tools from progress.md
- Use mission codes in commits
- Track velocity by mission

### With CI/CD

- `/coord deploy` prepares deployments
- Integrate with pipeline triggers
- Use mission success criteria
- Automate post-mission tasks

## Command Benefits

1. **Consistency** - Same process every time
2. **Speed** - No manual orchestration
3. **Context** - Full documentation provided
4. **Tracking** - Automatic progress updates
5. **Learning** - Patterns improve over time

---

*Master the `/coord` command to transform from solo founder to commanding an elite AI squadron.*