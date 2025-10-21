# Video Script: First Mission Walkthrough

**Duration**: 10 minutes
**Target Audience**: Users who just installed AGENT-11
**Purpose**: Complete first mission from ideation to deliverables
**Tone**: Educational, supportive, reassuring

---

## Opening (30 seconds)

### [00:00] Title Screen
**[SCREEN: "Your First Mission with AGENT-11"]**

**Narration:**
"You've installed AGENT-11 and verified your squad is ready. Now let's run your first real mission. In the next 10 minutes, we'll go from a simple product idea to a complete project plan with architecture, requirements, and working code structure - all orchestrated by your AI agents."

**[ON-SCREEN TEXT:]**
What You'll Build:
- Complete project architecture
- Product requirements doc
- Initial code structure
- Testing framework setup
- Deployment configuration

**[SCREEN: Show final deliverables preview]**

---

## Understanding Missions (1 minute)

### [00:30] What Are Missions?
**[SCREEN: missions/ directory structure]**

**Narration:**
"AGENT-11 includes 20 pre-built missions. These are workflows that automatically orchestrate multiple agents to complete complex tasks. Think of them as playbooks your squad executes together."

**[SCREEN: Show mission files list]**
```
missions/
├── mission-mvp.md          # Build complete MVP
├── mission-build.md         # Add new feature
├── mission-fix.md           # Debug and fix issues
├── mission-refactor.md      # Improve code quality
├── dev-setup.md            # Initialize new project ← We'll use this
```

**[HIGHLIGHT: dev-setup.md]**

**Narration:**
"For your first mission, we'll use `dev-setup`. This mission analyzes your product vision, designs the architecture, sets up the project structure, and configures everything you need to start building."

**[ON-SCREEN TEXT:]**
Mission: dev-setup
- Time: 30-45 minutes
- Agents: 4 (Strategist, Architect, Developer, Tester)
- Output: Complete project foundation

---

## Creating Your Vision Document (1 minute 30 seconds)

### [01:30] Step 1: Define Your Idea
**[SCREEN: Text editor with blank file]**

**Narration:**
"Every mission starts with an input document. For `dev-setup`, you need a vision document that describes what you want to build. Let's create one for a simple task management app."

**[TYPE in editor: `vision.md`]**

**Narration:**
"I'll use the template from the templates directory as a starting point."

**[SCREEN: Show templates/vision-template.md]**
**[ACTION: Copy template to vision.md]**

**Narration:**
"Now let's fill it in with our project details."

**[SCREEN: Show typing in editor]**

```markdown
# Project: TaskFlow

## Goal
Simple web-based task management for small teams who need
basic collaboration without enterprise complexity.

## Target Users
- Small teams (3-10 people)
- Startups needing lightweight project tracking
- Remote teams wanting shared task visibility

## Core Features (MVP)
1. Create, edit, and delete tasks
2. Assign tasks to team members
3. Set due dates and priority levels
4. Mark tasks as complete/in-progress/blocked
5. Basic dashboard with task overview
6. Simple search and filtering

## Technical Preferences
- Frontend: React with TypeScript (modern, type-safe)
- Backend: Node.js with Express (JavaScript ecosystem consistency)
- Database: PostgreSQL (reliable, well-documented)
- Auth: Supabase Auth (quick setup, secure)
- Hosting: Vercel (frontend) + Railway (backend + DB)

## Timeline
- MVP target: 2 days development time
- Launch goal: 1 week from project start

## Success Criteria
- 5 team members can use simultaneously
- Tasks persist reliably across sessions
- Mobile-responsive interface
- <2 second page load times
```

**[SCREEN: Save file]**

**[ON-SCREEN TEXT:]**
Vision Document Should Include:
✅ Clear goal and target users
✅ Specific MVP features (not everything)
✅ Tech stack preferences (or "recommend")
✅ Realistic timeline
✅ Measurable success criteria

**Narration:**
"Notice how specific this is. The more detail you provide, the better your agents can design and build exactly what you want. But don't worry about perfection - the strategist will refine this into proper requirements."

---

## Running the Mission (2 minutes)

### [03:00] Step 2: Launch with /coord
**[SCREEN: Terminal in project directory]**

**Narration:**
"Now we're ready to launch the mission. We'll use the `/coord` command - this is your coordinator agent who orchestrates multi-agent workflows."

**[TYPE: `/coord dev-setup vision.md`]**
**[PRESS: Enter]**

**[SCREEN: Show coordinator response starting]**

**Narration:**
"The coordinator reads your vision document and creates a mission plan. Let's see what happens."

**[SCREEN: Show coordinator creating project-plan.md]**

**Narration:**
"First, the coordinator creates a project plan file. This breaks the mission into phases with specific tasks for each agent."

**[SCREEN: Show project-plan.md content]**
```markdown
# Project Plan: TaskFlow Development Setup

## Mission Objectives
1. Analyze product vision and create requirements
2. Design system architecture
3. Initialize project structure
4. Configure development environment

## Phases

### Phase 1: Requirements Analysis (30 min)
Agent: @strategist
Tasks:
- [ ] Analyze vision document
- [ ] Create user stories
- [ ] Define acceptance criteria
- [ ] Prioritize features for MVP

### Phase 2: Architecture Design (30 min)
Agent: @architect
Tasks:
- [ ] Design system architecture
- [ ] Select technology stack
- [ ] Plan database schema
- [ ] Create deployment strategy
```

**[HIGHLIGHT: Task checkboxes]**

**Narration:**
"Notice the checkboxes. As each agent completes their tasks, these get marked complete so you can track progress."

**[ON-SCREEN TEXT:]**
Coordinator Creates:
- `project-plan.md` = Mission roadmap
- `agent-context.md` = Shared knowledge
- `handoff-notes.md` = Agent-to-agent context

---

## Watching Agents Work (3 minutes)

### [05:00] Phase 1: Strategist Analysis
**[SCREEN: Show strategist starting work]**

**Narration:**
"Now the coordinator delegates to the strategist. Watch how the strategist reads your vision and creates structured requirements."

**[SCREEN: Show strategist creating requirements.md]**

**Narration:**
"The strategist creates a comprehensive requirements document with user stories, acceptance criteria, and feature priorities."

**[SCREEN: Show snippet of requirements.md]**
```markdown
# TaskFlow Requirements

## User Stories

### Epic 1: Task Management
**US-001: Create Task**
As a team member, I want to create a new task with title,
description, and assignee, so I can track work items.

Acceptance Criteria:
- User can enter task title (required, max 200 chars)
- User can add description (optional, markdown supported)
- User can assign to team member from dropdown
- Task saves to database immediately
- Success message confirms creation

**US-002: Edit Task**
[...]
```

**[HIGHLIGHT: Structured format]**

**Narration:**
"Notice how the strategist breaks your high-level vision into specific, testable requirements. This becomes the blueprint for the entire project."

**[SCREEN: Show handoff-notes.md update]**

**Narration:**
"Before finishing, the strategist updates the handoff notes for the next agent. This ensures the architect has all the context they need."

### [06:00] Phase 2: Architect Design
**[SCREEN: Show architect starting]**

**Narration:**
"Next, the architect reads the requirements and designs the system architecture."

**[SCREEN: Show architect creating architecture.md]**

**Narration:**
"The architect creates a complete architecture document with system design, database schema, API endpoints, and deployment strategy."

**[SCREEN: Show architecture.md excerpt]**
```markdown
# TaskFlow Architecture

## System Design

### High-Level Architecture
[Mermaid diagram showing Frontend → API → Database → Auth]

### Technology Stack
**Frontend**
- React 18 with TypeScript
- Tailwind CSS for styling
- React Query for data fetching
- Zustand for state management

**Backend**
- Node.js 18+ with Express
- PostgreSQL 15 for data persistence
- Supabase Auth for authentication
- Railway for hosting

### Database Schema
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(200) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title VARCHAR(200) NOT NULL,
  description TEXT,
  assignee_id UUID REFERENCES users(id),
  status VARCHAR(20) DEFAULT 'pending',
  priority VARCHAR(20) DEFAULT 'medium',
  due_date TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);
```
```

**[HIGHLIGHT: Specific technical decisions]**

**Narration:**
"The architect makes all the hard technical decisions - tech stack, database design, API structure, deployment strategy. You get a complete blueprint ready to implement."

### [07:00] Phase 3: Developer Setup
**[SCREEN: Show developer starting]**

**Narration:**
"Now the developer initializes the project structure based on the architecture."

**[SCREEN: Show file tree being created]**
```
taskflow/
├── frontend/
│   ├── src/
│   │   ├── components/
│   │   ├── pages/
│   │   ├── hooks/
│   │   └── App.tsx
│   ├── package.json
│   └── tsconfig.json
├── backend/
│   ├── src/
│   │   ├── routes/
│   │   ├── models/
│   │   ├── middleware/
│   │   └── server.ts
│   ├── package.json
│   └── tsconfig.json
├── database/
│   └── schema.sql
└── README.md
```

**Narration:**
"The developer creates the complete project structure, installs dependencies, configures TypeScript, sets up the database schema, and creates starter files for each component."

**[SCREEN: Show package.json files]**

**Narration:**
"All dependencies are installed and configured. You can run `npm install` and start coding immediately."

### [07:45] Phase 4: Tester Configuration
**[SCREEN: Show tester starting]**

**Narration:**
"Finally, the tester sets up the testing framework."

**[SCREEN: Show test files being created]**
```
taskflow/
├── frontend/
│   └── __tests__/
│       ├── components/
│       └── setup.ts
└── backend/
    └── __tests__/
        ├── routes/
        └── setup.ts
```

**Narration:**
"The tester configures Jest, React Testing Library, and Playwright for end-to-end tests. They also create example test files showing how to test each type of component."

---

## Reviewing Deliverables (1 minute 30 seconds)

### [08:45] What You Got
**[SCREEN: File explorer showing all created files]**

**Narration:**
"Let's review what your agents created in the last 35 minutes."

**[SCREEN: Highlight each file type]**

**[ON-SCREEN TEXT:]**
Deliverables Created:
✅ requirements.md - Complete user stories and acceptance criteria
✅ architecture.md - Full system design with diagrams
✅ project-plan.md - Development roadmap
✅ Complete project structure - Frontend, backend, database
✅ All dependencies installed - package.json with exact versions
✅ Testing framework configured - Jest, RTL, Playwright
✅ README.md - Project documentation
✅ CLAUDE.md - Project-specific AI instructions

**Narration:**
"You also get `progress.md` which tracks what was done, and `agent-context.md` which preserves all the decisions and knowledge from this mission. This means future missions have full context."

**[SCREEN: Show progress.md excerpt]**
```markdown
# Progress Log

## 2025-10-20: Project Setup Complete

### Deliverables Created
1. **requirements.md** - 15 user stories with acceptance criteria
2. **architecture.md** - Complete system design with database schema
3. **Project structure** - Frontend, backend, database directories
4. **Configuration** - TypeScript, testing, linting configured

### Decisions Made
- Database: PostgreSQL for reliability and SQL familiarity
- Auth: Supabase Auth to avoid building custom auth
- Hosting: Vercel + Railway for cost-effectiveness
- State management: Zustand for simplicity over Redux
```

**[HIGHLIGHT: Decisions Made section]**

**Narration:**
"The progress log documents every decision made and why. This becomes invaluable when you need to remember why you chose PostgreSQL over MongoDB, or why you used Zustand instead of Redux."

---

## Next Steps (45 seconds)

### [10:00] Building Your First Feature
**[SCREEN: Terminal ready]**

**Narration:**
"Now you're ready to build features. Let's create the task creation functionality."

**[TYPE: `/coord build`]**
**[SCREEN: Show coordinator asking for requirements]**

**Narration:**
"The build mission walks you through creating a new feature. Or you can use individual agents directly."

**[SCREEN: Show example agent commands]**
```bash
# Option 1: Mission-based (recommended)
/coord build feature-requirements.md

# Option 2: Direct agent commands
@developer Implement the task creation API endpoint from architecture.md
@tester Create tests for the task creation endpoint
```

**[ON-SCREEN TEXT:]**
What's Next:
1. Build features: `/coord build`
2. Fix issues: `/coord fix bug-report.md`
3. Deploy: `/coord deploy`
4. Get help: `@support`

---

## Closing (15 seconds)

### [10:45] Wrap Up
**[SCREEN: Project structure with checkmarks]**

**Narration:**
"Congratulations! You've completed your first AGENT-11 mission. In 35 minutes of agent work, you went from a simple idea to a complete, production-ready project foundation. Now go build your MVP."

**[ON-SCREEN TEXT:]**
✅ First Mission Complete
🎯 Project Foundation Ready
🚀 Next: Build Features with `/coord build`

**[FADE OUT]**

---

## Production Notes

### Visual Cues Reference
- **[SCREEN: ...]** = What should be visible
- **[TYPE: ...]** = Text being typed
- **[HIGHLIGHT: ...]** = Element to emphasize
- **[ON-SCREEN TEXT:]** = Graphics overlay
- **[ACTION: ...]** = Editor or UI action

### Pacing Notes
- Allow viewers to read on-screen code snippets (3-5 seconds per snippet)
- Use speed-up effects for repetitive actions (file creation, installation)
- Pause narration when showing complex diagrams (let viewers absorb)

### Key Moments to Emphasize
1. **[03:00]** - The moment coordinator creates the plan (shows orchestration)
2. **[05:00]** - Strategist creating structured requirements (shows intelligence)
3. **[07:00]** - Complete file structure appearing (shows productivity)
4. **[08:45]** - All deliverables together (shows value)

### Common Confusion Points to Address
- **Why create vision.md?** "The more specific you are, the better the output. Agents need direction, not mind-reading."
- **How long does this take?** "Missions run in real-time. Dev-setup typically takes 30-45 minutes. Grab coffee and check back."
- **What if I don't like the architecture?** "You can ask the architect to revise, or edit architecture.md directly. Agents read and respect your changes."

### Accessibility Considerations
- Read all code snippets aloud (at least key parts)
- Describe file structures verbally, not just visually
- Use high contrast for all text overlays
- Provide closed captions with code snippets in caption text

---

## Script Metadata

**Created**: 2025-10-20
**Purpose**: First mission walkthrough for new users
**Target**: Users who completed installation, ready for first real task
**Success Metric**: 85%+ complete first mission successfully after watching
**Dependencies**: Assumes installation-walkthrough.md completed
**Update Frequency**: Review when dev-setup mission process changes

---

*This script balances education with engagement. Pace the narration to match the complexity - slower for important concepts, faster for repetitive actions. Consider adding a "pause here to try it yourself" moment at [05:00] for interactive learning.*
