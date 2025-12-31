# Sprint 9: Consolidated LLM Feedback & Architectural Resolutions

**Objective**: Synthesize feedback from all 6 LLM reviewers (Gemini, GPT, Claude, DeepSeek, Perplexity, Grok) and user insights to create a definitive, actionable set of revisions for the Sprint 9 plan.

## 1. Executive Summary of Consolidated Feedback

Across the board, all LLMs scored the Sprint 9 plan highly (average >9.0/10), validating its strong alignment with the v6 architecture and Claude Code-native principles. The plan is considered implementation-ready with minor-to-medium adjustments. 

**Key Strengths (Universal Praise):**
- **Claude-Native Fidelity**: Perfect adherence to an in-IDE, prompt-driven workflow.
- **BOS-AI Integration**: The `/foundations` command is seen as a robust handoff mechanism.
- **Plan-Driven Orchestration**: The shift to a `project-plan.md` centered workflow is a major step forward.

**Consolidated Gaps & Opportunities:**
- **Token Budgets**: Uniform budgets are insufficient; they must be proportional to information density (especially for the PRD).
- **Operational Workflow**: The plan lacks an explicit workflow for context management, such as using `/clear` between phases.
- **Prototyping & Testing**: The plan needs more explicit, automated validation and prototyping milestones.
- **Stack Agnosticism**: The mechanism for adapting skills to different tech stacks (e.g., via `stack-profiles/`) is undefined.
- **Edge Cases**: Handling of missing foundation documents or oversized summaries needs more detail.

## 2. Grok's Feedback Analysis

Grok's feedback (9.3/10) aligns strongly with other reviewers, reinforcing the plan's quality while highlighting specific, actionable gaps.

| Aspect | Score | Key Insight |
|---|---|---|
| **Alignment with Vision** | 9/10 | Strong match, but quantitative "10x" metrics need to be better defined in tests. |
| **Claude Code-Native Fidelity** | 10/10 | Exemplary, purely IDE-focused. |
| **Phase Structure** | 9/10 | Logical, but lacks explicit prototyping milestones. |
| **Schemas & Foundations** | 9/10 | Good, but could benefit from auto-validation scripts. |
| **Commands & Orchestration** | 9/10 | Solid, but `/plan visualize` implementation is not mentioned. |
| **Testing & Deployment** | 9/10 | Comprehensive, but could include a community contribution guide. |

**Top 3 Grok Recommendations:**
1.  **Add Prototyping Milestones**: Add sub-tasks for `@tester` to create mock files and run commands in a test branch for early validation.
2.  **Flesh out Edge Case Handling**: Expand `/foundations` to handle oversized summaries and suggest templates for missing documents.
3.  **Define Stack Agnosticism**: Add tasks to define how `stack-profiles/` will be integrated into skills for custom code generation.

## 3. New User Insight: Context Management with `/clear`

The user introduced a critical operational pattern:

> "I use /clear when I'm implementing a sprint, typically after each phase... we should lean into creating plans that support context management with the /clear at milestones like the completion of a phase."

**Implication**: The `project-plan.md` and the Coordinator agent must be designed to support a stateless, phase-by-phase execution model. The agent should be able to resume work on the next phase after a `/clear` command with minimal context bleed.

**Architectural Requirement**: 
- The `phase-N-context.yaml` file becomes even more critical. It must contain all necessary information for the agent to resume the *next* phase from a clean slate.
- The `/coord complete sprint X phase Y` command should not just mark completion but also prepare or point to the context for the *next* phase.

This workflow reinforces the rolling wave planning model and makes the system more robust and efficient in terms of token usage.

## 4. Resolving Key Architectural Conflicts

This section will synthesize all 6 LLM reviews to resolve the key architectural debates.

*(This section is to be filled in next)*

### 4.1. Token Budgets: Proportional Allocation
The consensus is clear: **uniform token budgets are a flaw**. The budget must be proportional to the information density of the source document.

**Resolution**: Adopt a tiered, proportional budget system.

| Tier | Document Type | Information Density | Recommended Budget | Rationale |
|---|---|---|---|---|
| 1 | **PRD** | Very High | **600 tokens** | Contains all critical implementation details (features, priorities, tech constraints). A 200-token summary is insufficient for autonomous work. |
| 2 | Strategic Plan, ICP | High | **200 tokens** | Guides high-level decisions and UX. |
| 3 | Brand, Marketing | Medium | **100 tokens** | Guides UI and copy, less critical for core logic. |

**Revised Total Foundation Budget**: ~1200 tokens (up from ~500).

**Justification**:
- **Quality over Quantity**: A higher initial token investment in summaries prevents costly clarification cycles and enables more autonomous operation.
- **Context Window Affordability**: 1200 tokens is a negligible fraction (<1%) of modern context windows (e.g., 200K).
- **User-Centric Principle**: Aligns with the user's core insight that budgets must match information density.

**Implementation**: The `/foundations init` command will be updated to use these new, fixed-but-proportional budgets. A user-configurable override in `handoff-manifest.json` will be considered for a future release to provide maximum flexibility.

### 4.2. Skill Locations: Source vs. Destination
The research confirms a clear distinction between where skills are stored for development (source) and where they must be for Claude Code to use them (destination).

**Resolution**: The Agent-11 architecture will formally adopt a source-to-destination deployment model for skills.

- **Source Location (Agent-11 Library)**: `/project/skills/`
  - This directory within the Agent-11 repository contains the master, version-controlled skill definitions.

- **Destination Location (User's SaaS Project)**: `/.claude/skills/`
  - This is the directory where Claude Code actively looks for project-specific skills.

**Deployment Mechanism**:
- The `install.sh` script is responsible for copying the skills from the Agent-11 library's `/project/skills/` directory to the user's project `/.claude/skills/` directory during setup.
- This ensures that the user's project has a local, active copy of the skills needed for the SaaS boilerplate generation, without polluting the user's personal `~/.claude/skills/` directory.

This resolves the ambiguity and provides a clean, robust mechanism for managing and deploying skills as part of the Agent-11 ecosystem.

### 4.3. Helper Scripts vs. Coordinator-Native Execution
This conflict, identified between Gemini (pro-scripts) and Claude (pro-native), addresses how complex, deterministic logic should be executed.

**Resolution**: A hybrid approach is the optimal path forward, leveraging the strengths of both methods. This aligns with the official Claude Code documentation, which shows skills containing both markdown instructions and executable scripts.

- **Coordinator-Native Execution**: Use for **orchestration, decision-making, and simple, high-level logic**. The `coordinator.md` agent's prompt should remain focused on the *what* and *why*, directing the overall flow of the plan.

- **Helper Scripts (in Skills)**: Use for **complex, deterministic, or automatable tasks**. Any logic that is repeatable, testable, or involves significant data manipulation should be encapsulated in a script (e.g., Python, shell) within a relevant skill. This keeps prompts clean and logic maintainable.

**Architectural Guideline**:

> If the logic can be described as a pure function (`input -> output`), it belongs in a **script**. If the logic involves orchestrating other agents, making subjective evaluations, or adapting to conversational context, it belongs in the **coordinator's prompt**.

**Example**: Validating the `handoff-manifest.json` against its schema is a perfect candidate for a `scripts/validate_manifest.py` helper script within the `foundations-skill`. The coordinator would then simply invoke this script and react to the success or failure output.

### 4.4. Command Consolidation: `/plan` vs. `/coord`
This debate, raised by DeepSeek, questions whether to consolidate commands under `/coord` or maintain separate commands like `/plan`.

**Resolution**: Maintain separate, purpose-driven commands. The current structure (`/foundations`, `/bootstrap`, `/plan`, `/coord`) is clean, intuitive, and aligns with the principle of command-line interface design where each command has a clear, distinct responsibility.

**Justification**:
- **Clarity and Usability**: Separate commands are easier for users to discover and understand. `/plan status` is more intuitive than `/coord plan status`.
- **Separation of Concerns**: 
    - `/coord` is for **execution and orchestration** (the *Do-er*).
    - `/plan` is for **observation and management** (the *Viewer*).
    - `/foundations` and `/bootstrap` are for **initialization and setup**.
- **Extensibility**: This model allows for adding new command families in the future (e.g., `/test`, `/deploy`) without overloading the `/coord` command.

**Conclusion**: The existing multi-command structure is superior. The focus should be on ensuring seamless data flow between them (e.g., `/bootstrap` creating the `project-plan.md` that `/plan` and `/coord` then use), not on consolidating their invocation.

## 5. Consolidated Sprint 9 Recommendations

Based on the complete analysis, the following changes must be integrated into the Sprint 9 plan.

### 1. **Update Foundational Summary Token Budgets**
- **Action**: Modify the `/foundations init` command specification and associated prompts.
- **Change**: Increase the token budget for `prd-summary.md` to **600 tokens**. Adjust other summary budgets as per the new tiered model (~1200 tokens total).
- **Rationale**: To ensure the PRD summary contains sufficient detail for autonomous implementation, reflecting its high information density.

### 2. **Incorporate `/clear` into the Core Workflow**
- **Action**: Update the `coordinator.md` agent and the `project-plan.md` schema/documentation.
- **Change**: Add explicit instructions and protocol for using `/clear` between phases. The `phase-N-context.yaml` must be the single source of truth for resuming the next phase.
- **Rationale**: To formalize the user's stateless, phase-by-phase execution model, improving context efficiency and robustness.

### 3. **Add Explicit Prototyping and Validation Tasks**
- **Action**: Add new sub-tasks to Phases 9A, 9B, and 9H.
- **Change**: Assign `@tester` to create mock foundation documents, generate sample `handoff-manifest.json` files, and run `end-to-end` validation scripts for core commands. Include automated schema validation.
- **Rationale**: To de-risk implementation by catching issues early, as recommended by Grok and other LLMs.

### 4. **Define and Task Stack Agnosticism**
- **Action**: Add a new task to Phase 9F (SaaS Skills Library).
- **Change**: Assign `@architect` to define the `stack-profiles/` YAML schema and create a task to implement the logic within skills to adapt code generation based on the selected profile.
- **Rationale**: To fulfill a key v6 requirement and ensure Agent-11 is not hardcoded to a single tech stack.

### 5. **Formalize Skill Deployment in `install.sh`**
- **Action**: Update the task description for Phase 9I (Deployment & Release).
- **Change**: Explicitly state that `install.sh` must copy the contents of the library's `/project/skills/` directory to the user project's `/.claude/skills/` directory.
- **Rationale**: To resolve the "source vs. destination" ambiguity for skill locations.

### 6. **Adopt Hybrid Script/Native Execution Model**
- **Action**: Add this architectural guideline to the project's development documentation (part of Phase 9H).
- **Change**: Document the principle: use native prompts for orchestration and scripts within skills for deterministic, repeatable logic.
- **Rationale**: To provide clear guidance for future development and resolve the Gemini vs. Claude feedback conflict.

### 7. **Confirm Separate Command Structure**
- **Action**: No change to the plan, but add a note to the architectural principles document (Phase 9H).
- **Change**: Re-affirm the decision to maintain separate commands (`/plan`, `/coord`, etc.) for clarity and separation of concerns.
- **Rationale**: To formally close the command consolidation debate raised by DeepSeek.
