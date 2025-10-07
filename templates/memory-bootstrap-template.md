# Memory Bootstrap Template

## Purpose
This template provides a structured approach to initializing Claude Code's memory system for AGENT-11 missions. Use this to create persistent project knowledge that survives across sessions.

## When to Use
- **New Projects (Greenfield)**: During `/coord dev-setup` mission
- **Existing Projects (Brownfield)**: During `/coord dev-alignment` mission
- **Mission Start**: At beginning of any multi-session mission
- **After Ideation**: When project vision and requirements are defined

## Memory Directory Structure

```
/memories/
├── project/
│   ├── requirements.xml        # Core features and user stories
│   ├── architecture.xml         # System design and tech stack
│   ├── constraints.xml          # Technical and business constraints
│   └── success_metrics.xml      # Definition of done and KPIs
├── user/
│   ├── preferences.xml          # Communication style, technical depth
│   ├── context.xml              # User background and expertise
│   └── goals.xml                # User objectives and priorities
├── technical/
│   ├── decisions.xml            # ADRs and technical choices
│   ├── patterns.xml             # Proven solutions and anti-patterns
│   └── tooling.xml              # MCP usage, development setup
└── lessons/
    ├── insights.xml             # Cross-session learnings
    ├── debugging.xml            # Common issues and solutions
    └── optimizations.xml        # Performance and cost improvements
```

## Template Files

### 1. Project Requirements (`/memories/project/requirements.xml`)

```xml
<project_requirements>
  <project_name>PROJECT_NAME_HERE</project_name>
  <vision>
    CONCISE_PROJECT_VISION_STATEMENT
  </vision>

  <core_features>
    <feature priority="high">
      <name>FEATURE_NAME</name>
      <description>FEATURE_DESCRIPTION</description>
      <acceptance_criteria>
        - CRITERION_1
        - CRITERION_2
      </acceptance_criteria>
    </feature>
    <!-- Add more features -->
  </core_features>

  <user_stories>
    <story id="US001">
      <as_a>USER_ROLE</as_a>
      <i_want>USER_GOAL</i_want>
      <so_that>USER_BENEFIT</so_that>
    </story>
    <!-- Add more user stories -->
  </user_stories>

  <out_of_scope>
    - EXPLICITLY_EXCLUDED_FEATURE_1
    - EXPLICITLY_EXCLUDED_FEATURE_2
  </out_of_scope>
</project_requirements>
```

### 2. Architecture Decisions (`/memories/project/architecture.xml`)

```xml
<architecture>
  <tech_stack>
    <frontend>
      <framework>FRAMEWORK_NAME</framework>
      <language>LANGUAGE_NAME</language>
      <key_libraries>
        - LIBRARY_1
        - LIBRARY_2
      </key_libraries>
    </frontend>

    <backend>
      <platform>PLATFORM_NAME</platform>
      <database>DATABASE_NAME</database>
      <authentication>AUTH_PROVIDER</authentication>
    </backend>

    <infrastructure>
      <hosting>HOSTING_PROVIDER</hosting>
      <ci_cd>CI_CD_PLATFORM</ci_cd>
      <monitoring>MONITORING_TOOL</monitoring>
    </infrastructure>
  </tech_stack>

  <architectural_decisions>
    <decision id="ADR001">
      <title>DECISION_TITLE</title>
      <context>WHY_DECISION_NEEDED</context>
      <decision>WHAT_WAS_DECIDED</decision>
      <rationale>WHY_THIS_CHOICE</rationale>
      <consequences>
        <positive>BENEFIT_1</positive>
        <negative>TRADEOFF_1</negative>
      </consequences>
    </decision>
    <!-- Add more ADRs -->
  </architectural_decisions>

  <design_patterns>
    <pattern>PATTERN_NAME - WHEN_TO_USE</pattern>
    <pattern>PATTERN_NAME - WHEN_TO_USE</pattern>
  </design_patterns>

  <anti_patterns>
    <avoid>ANTI_PATTERN - WHY_TO_AVOID</avoid>
    <avoid>ANTI_PATTERN - WHY_TO_AVOID</avoid>
  </anti_patterns>
</architecture>
```

### 3. Technical Constraints (`/memories/project/constraints.xml`)

```xml
<constraints>
  <security>
    <requirement>SECURITY_REQUIREMENT_1</requirement>
    <requirement>SECURITY_REQUIREMENT_2</requirement>
    <policies>
      <csp>CONTENT_SECURITY_POLICY</csp>
      <authentication>AUTH_REQUIREMENTS</authentication>
    </policies>
  </security>

  <performance>
    <target>PAGE_LOAD_TIME_TARGET</target>
    <target>API_RESPONSE_TIME_TARGET</target>
    <budget>
      <bundle_size>BUNDLE_SIZE_LIMIT</bundle_size>
      <database_queries>QUERY_TIME_LIMIT</database_queries>
    </budget>
  </performance>

  <technical>
    <browser_support>BROWSER_VERSIONS</browser_support>
    <accessibility>WCAG_LEVEL_REQUIREMENT</accessibility>
    <seo>SEO_REQUIREMENTS</seo>
  </technical>

  <business>
    <timeline>PROJECT_DEADLINE</timeline>
    <budget>COST_CONSTRAINTS</budget>
    <compliance>REGULATORY_REQUIREMENTS</compliance>
  </business>

  <dependencies>
    <external_api>API_NAME - RATE_LIMITS</external_api>
    <external_service>SERVICE_NAME - CONSTRAINTS</external_service>
  </dependencies>
</constraints>
```

### 4. User Preferences (`/memories/user/preferences.xml`)

```xml
<user_preferences>
  <communication>
    <style>concise | detailed | balanced</style>
    <technical_depth>beginner | intermediate | expert</technical_depth>
    <code_comments>minimal | moderate | comprehensive</code_comments>
    <explanation_style>step_by_step | overview_first | learn_by_doing</explanation_style>
  </communication>

  <development>
    <code_style>functional | oop | mixed</code_style>
    <testing_preference>tdd | test_after | integration_focused</testing_preference>
    <documentation>inline | external | both</documentation>
    <error_handling>explicit | try_catch | result_types</error_handling>
  </development>

  <workflow>
    <git_strategy>feature_branch | trunk_based | gitflow</git_strategy>
    <review_preference>pr_review | pair_programming | async_review</review_preference>
    <deployment>manual | auto_staging | full_cicd</deployment>
  </workflow>

  <priorities>
    <primary>speed | quality | learning | cost_optimization</primary>
    <secondary>SECONDARY_PRIORITY</secondary>
  </priorities>
</user_preferences>
```

### 5. User Context (`/memories/user/context.xml`)

```xml
<user_context>
  <background>
    <role>PROFESSIONAL_ROLE</role>
    <experience_level>YEARS_EXPERIENCE</experience_level>
    <technical_expertise>
      <strong>TECHNOLOGY_1</strong>
      <strong>TECHNOLOGY_2</strong>
      <learning>TECHNOLOGY_3</learning>
    </technical_expertise>
  </background>

  <project_goals>
    <primary>PRIMARY_GOAL</primary>
    <secondary>SECONDARY_GOAL</secondary>
    <learning_objectives>
      - LEARNING_GOAL_1
      - LEARNING_GOAL_2
    </learning_objectives>
  </project_goals>

  <working_style>
    <timezone>TIMEZONE</timezone>
    <availability>WORKING_HOURS</availability>
    <collaboration_preference>SYNC_OR_ASYNC</collaboration_preference>
  </working_style>

  <pain_points>
    <challenge>CURRENT_CHALLENGE_1</challenge>
    <challenge>CURRENT_CHALLENGE_2</challenge>
  </pain_points>
</user_context>
```

### 6. Technical Decisions (`/memories/technical/decisions.xml`)

```xml
<technical_decisions>
  <decision date="2025-10-06">
    <category>architecture | tooling | security | performance</category>
    <question>WHAT_WAS_DECIDED</question>
    <chosen_approach>APPROACH_NAME</chosen_approach>
    <alternatives_considered>
      <alternative>OPTION_1 - REJECTED_BECAUSE</alternative>
      <alternative>OPTION_2 - REJECTED_BECAUSE</alternative>
    </alternatives_considered>
    <rationale>WHY_THIS_CHOICE</rationale>
    <implementation_notes>HOW_TO_IMPLEMENT</implementation_notes>
    <review_date>WHEN_TO_REVISIT</review_date>
  </decision>
  <!-- Add more decisions as made -->
</technical_decisions>
```

### 7. Lessons Learned (`/memories/lessons/insights.xml`)

```xml
<lessons_learned>
  <insight date="2025-10-06">
    <category>debugging | optimization | architecture | workflow</category>
    <situation>WHAT_HAPPENED</situation>
    <problem>WHAT_WENT_WRONG</problem>
    <solution>HOW_IT_WAS_FIXED</solution>
    <learning>KEY_TAKEAWAY</learning>
    <prevention>HOW_TO_AVOID_NEXT_TIME</prevention>
  </insight>
  <!-- Add insights as discovered -->
</lessons_learned>
```

## Bootstrap Workflow

### Step 1: Extract from Ideation
```bash
# Coordinator reads ideation.md and creates initial memory
claude --prompt "Read ideation.md and populate memory using bootstrap template:
1. Extract requirements → /memories/project/requirements.xml
2. Extract constraints → /memories/project/constraints.xml
3. Extract user preferences → /memories/user/preferences.xml
4. Note any missing information for user clarification"
```

### Step 2: Validate and Refine
```bash
# Review memory with user
claude --prompt "Show me /memories directory. Let me verify and refine before proceeding."
```

### Step 3: Initialize Agent Access
```bash
# Update all agents to check memory before tasks
# Each agent prompt includes: "First, check /memories for project context"
```

### Step 4: Continuous Updates
```bash
# Throughout mission, agents update memory
# - New decisions → /memories/technical/decisions.xml
# - New learnings → /memories/lessons/insights.xml
# - Requirement changes → /memories/project/requirements.xml
```

## Memory Protocol for Agents

Add this to each agent's system prompt:

```
MEMORY PROTOCOL:
1. BEFORE TASK: Check /memories directory for relevant context
   - Project requirements: /memories/project/requirements.xml
   - Technical constraints: /memories/project/constraints.xml
   - User preferences: /memories/user/preferences.xml
   - Past decisions: /memories/technical/decisions.xml
   - Lessons learned: /memories/lessons/insights.xml

2. DURING TASK: Apply memory-informed decisions
   - Respect technical constraints
   - Follow established patterns
   - Avoid known anti-patterns
   - Align with user preferences

3. AFTER TASK: Update memory with new knowledge
   - Document decisions made
   - Record insights discovered
   - Update patterns that worked
   - Note issues to avoid

4. HANDOFF: Update handoff-notes.md for next agent
   (Memory = long-term, Handoff = immediate next step)
```

## Integration with Existing Context System

**Memory Tools complement, don't replace, file-based context:**

```
Mission Context Flow:

┌─────────────────────────────────────────┐
│ Long-Term Project Knowledge (Memory)    │
│ /memories/*.xml                         │
│ - Persists across sessions              │
│ - Project requirements, constraints     │
│ - User preferences, technical decisions │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│ Mission Coordination (Context Files)    │
│ agent-context.md, handoff-notes.md      │
│ - Current mission state                 │
│ - Agent-to-agent handoffs              │
│ - Mission-specific findings             │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│ Evidence & Artifacts                    │
│ evidence-repository.md                  │
│ - Screenshots, logs, test results       │
│ - Supporting documentation              │
└─────────────────────────────────────────┘
```

## Example: Complete Bootstrap

```python
# In coordinator's mission initialization
def bootstrap_mission_memory():
    """
    Initialize memory from ideation for new mission.
    """

    # 1. Create memory tool
    memory = LocalFilesystemMemoryTool(base_path="./mission-xyz/memory")

    # 2. Read ideation
    with open("ideation.md") as f:
        ideation = f.read()

    # 3. Extract to memory
    prompt = f"""
    Analyze the following ideation document and populate memory files:

    {ideation}

    Create the following memory files using the templates:

    1. /memories/project/requirements.xml
       - Extract core features, user stories, success criteria
       - Identify what's in scope and explicitly out of scope

    2. /memories/project/architecture.xml
       - Extract tech stack preferences
       - Document any architectural decisions mentioned
       - Note design patterns to follow

    3. /memories/project/constraints.xml
       - Extract security, performance, technical constraints
       - Document business constraints (timeline, budget)
       - Note dependencies and limitations

    4. /memories/user/preferences.xml
       - Infer communication style from ideation tone
       - Extract technical depth preference
       - Note development workflow preferences

    5. /memories/user/context.xml
       - Extract user background if mentioned
       - Document project goals and objectives
       - Note any pain points or challenges mentioned

    Use XML format for structure. Mark any missing information
    that should be clarified with the user.
    """

    # 4. Execute bootstrap
    response = client.messages.create(
        model="claude-sonnet-4-5",
        tools=[memory],
        messages=[{"role": "user", "content": prompt}]
    )

    # 5. Verify with user
    print("Memory initialized. Review /memories directory.")

    return memory
```

## Validation Checklist

After bootstrapping memory, verify:

- [ ] All required memory files created
- [ ] XML format is well-formed and structured
- [ ] No sensitive information stored (passwords, API keys, PII)
- [ ] Path validation prevents directory traversal
- [ ] File sizes are reasonable (< 1000 tokens each)
- [ ] Information is accurate and actionable
- [ ] Missing information is flagged for clarification
- [ ] Memory aligns with ideation intent

## Troubleshooting

**Issue**: Memory files too large, causing "fading memory"
**Solution**: Break into smaller, focused files by concern

**Issue**: Claude announces "checking memory" every time
**Solution**: Add to system prompt: "Check memory silently, don't announce to user"

**Issue**: Memory conflicts with handoff notes
**Solution**: Use memory for persistent knowledge, handoff for immediate instructions

**Issue**: Context editing clears memory tool results
**Solution**: Add `"exclude_tools": ["memory"]` to context management config

**Issue**: Sensitive data in memory
**Solution**: Implement stricter validation, audit memory files regularly

## Next Steps

After bootstrapping memory:

1. **Share with team**: All agents now have access to project knowledge
2. **Update as you learn**: Continuously refine memory throughout mission
3. **Review periodically**: Audit and optimize memory structure
4. **Cross-mission learning**: Extract generalizable insights to global memory
5. **Measure impact**: Track improvements in agent effectiveness and token usage

---

**Template Version**: 1.0
**Created**: October 6, 2025
**Last Updated**: October 6, 2025
**Maintained By**: AGENT-11 Architect
