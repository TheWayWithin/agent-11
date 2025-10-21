# Video Script: AGENT-11 Installation Walkthrough

**Duration**: 5 minutes
**Target Audience**: First-time users
**Purpose**: Complete installation from zero to ready
**Tone**: Friendly, encouraging, clear

---

## Opening (30 seconds)

### [00:00] Title Screen
**[SCREEN: AGENT-11 logo with tagline "Your Elite AI Development Squad"]**

**Narration:**
"Welcome to AGENT-11 - the system that deploys 11 specialized AI agents to your project, working together to build production-ready software. In the next 5 minutes, I'll walk you through the complete installation process, from prerequisites to your first command."

**[ON-SCREEN TEXT:]**
- ✅ 98% success rate
- ⚡ Under 1 second deployment
- 🎯 11 specialized agents

---

## Prerequisites (45 seconds)

### [00:30] Prerequisites Check
**[SCREEN: Terminal window, clear view]**

**Narration:**
"Before we start, you'll need three things. First, an Anthropic API account with Claude Code access. If you don't have this, pause here and sign up at anthropic.com."

**[TYPE: `claude --version`]**
**[SCREEN: Show version output]**

**Narration:**
"Second, verify Claude Code is installed by running `claude --version`. You should see version 0.1.0 or higher."

**[SCREEN: Show project directory with README.md, .git folder]**

**Narration:**
"Third, you'll need an active project directory. AGENT-11 installs locally to each project, not globally. This could be a Git repository, a Node project with package.json, or any directory with a README file. For this demo, I'm using a sample project called 'task-manager'."

**[ON-SCREEN TEXT:]**
Required:
1. Anthropic API account
2. Claude Code installed
3. Project directory (Git, package.json, or README)

---

## Installation Command (1 minute)

### [01:15] Running the Installer
**[SCREEN: Terminal in project root directory]**

**Narration:**
"Now let's install AGENT-11. Navigate to your project directory. I'm using `cd task-manager`."

**[TYPE: `cd task-manager`]**
**[PRESS: Enter]**

**Narration:**
"Run the installation command. You can copy this from the README."

**[TYPE: `bash <(curl -fsSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/install.sh) full`]**

**[HIGHLIGHT: The 'full' parameter at the end]**

**Narration:**
"The 'full' parameter installs all 11 agents. You can use 'core' for just 4 essential agents, or 'minimal' for 2. For this walkthrough, we're going with the full squad."

**[PRESS: Enter]**

**[ON-SCREEN TEXT:]**
Install Options:
- `full` = 11 specialists (recommended)
- `core` = 4 essential agents
- `minimal` = 2 basic agents

---

## Installation Progress (1 minute 15 seconds)

### [02:15] Watching the Installation
**[SCREEN: Installation output scrolling]**

**Narration:**
"The installer will run several steps. First, it validates your environment and detects your project type."

**[SCREEN: Show "✓ Project Context Detected" message]**
**[HIGHLIGHT: Project indicators like "Git repository, Node.js project"]**

**Narration:**
"Next, it creates a backup of any existing agents - just in case."

**[SCREEN: Show backup progress messages]**

**Narration:**
"Then it downloads and installs all 11 agents. You'll see progress for each one."

**[SCREEN: Show agent installation progress]**
**[HIGHLIGHT: Progress indicators like "[3/11] 27% - Installing architect"]**

**Narration:**
"The installer also sets up the mission system, which includes 20 pre-built workflows, command tools like `/coord`, and templates for creating your own missions."

**[SCREEN: Show mission system installation]**

**Narration:**
"Finally, it verifies everything installed correctly."

**[SCREEN: Show verification messages]**
**[SCREEN: Show "✅ AGENT-11 deployed successfully!" message]**

**[ON-SCREEN TEXT:]**
Installation Steps:
1. Environment validation
2. Backup existing agents
3. Install 11 specialists
4. Install mission system
5. Verify installation

---

## Verification (1 minute)

### [03:30] Confirming Success
**[SCREEN: Terminal ready for input]**

**Narration:**
"Let's verify the installation. First, list your deployed agents using the `/agents` command."

**[TYPE: `/agents`]**
**[PRESS: Enter]**

**[SCREEN: Show agent list output]**
```
Project agents (.claude/agents):
- coordinator.md
- strategist.md
- architect.md
- developer.md
- designer.md
- tester.md
- documenter.md
- operator.md
- support.md
- analyst.md
- marketer.md
```

**[HIGHLIGHT: Count of 11 agents]**

**Narration:**
"Perfect! You should see all 11 agents listed. Each one is a specialized AI focused on a specific aspect of software development."

**[SCREEN: File explorer showing .claude/agents/ directory]**

**Narration:**
"These agents are installed in your project's `.claude/agents/` directory. They're markdown files with structured prompts that define each agent's role, capabilities, and collaboration protocols."

**[SCREEN: Show missions directory]**

**Narration:**
"You'll also see a new `missions/` directory with 20 pre-built workflows, a `templates/` directory for creating custom missions, and a `field-manual/` directory with comprehensive guides."

**[ON-SCREEN TEXT:]**
Installed Files:
- `.claude/agents/` = 11 specialist agents
- `.claude/commands/` = Slash commands (/coord, /meeting, etc.)
- `missions/` = 20 pre-built workflows
- `templates/` = Mission templates
- `field-manual/` = Documentation guides

---

## First Test (45 seconds)

### [04:30] Testing Your Squad
**[SCREEN: Terminal ready]**

**Narration:**
"Let's test your squad with a simple command. We'll ask the strategist to help us plan a feature."

**[TYPE: `@strategist What should I consider when building a user authentication feature?`]**
**[PRESS: Enter]**

**[SCREEN: Show strategist response appearing]**
**[HIGHLIGHT: Response shows strategic thinking about security, UX, technical requirements]**

**Narration:**
"Notice how the strategist focuses on product strategy and requirements - exactly what you'd want from a product strategist. Each agent has this kind of specialized expertise."

**[ON-SCREEN TEXT:]**
Test Your Squad:
- `@strategist` = Product strategy
- `@architect` = System design
- `@developer` = Code implementation
- `@tester` = Quality assurance

---

## Next Steps (30 seconds)

### [05:15] What's Next
**[SCREEN: Terminal with example commands shown]**

**Narration:**
"You're all set! Here are your next steps:"

**[ON-SCREEN TEXT:]**
Next Steps:
1. Try a mission: `/coord mvp vision.md`
2. Explore agents: `@architect`, `@developer`, `@tester`
3. Read the docs: `field-manual/`
4. Get support: `@support`

**Narration:**
"For your first real project, I recommend running `/coord mvp` with a product vision file. This orchestrates multiple agents to create a complete MVP in 1-3 days."

**[SCREEN: Show documentation link]**

**Narration:**
"For more details, check out the complete documentation at github.com/TheWayWithin/agent-11. If you run into issues, use the `@support` agent for help, or create a GitHub issue."

---

## Closing (15 seconds)

### [05:45] Wrap Up
**[SCREEN: AGENT-11 logo with success checkmark]**

**Narration:**
"Congratulations! You've successfully deployed your elite AI development squad. Now go build something amazing."

**[ON-SCREEN TEXT:]**
✅ Installation Complete
🎯 11 Agents Ready
🚀 Start Building: `/coord mvp vision.md`

**[FADE OUT]**

---

## Production Notes

### Visual Cues Reference
- **[SCREEN: ...]** = What should be visible on screen
- **[TYPE: ...]** = Text being typed into terminal
- **[HIGHLIGHT: ...]** = Specific element to emphasize (use arrow, circle, or zoom)
- **[ON-SCREEN TEXT:]** = Graphics overlay with key points
- **[PRESS: Enter]** = Keyboard action to show

### Timing Markers
- All timestamps are cumulative from video start
- Segments can be slightly adjusted but total should stay within 5 minutes
- Allow 2-3 seconds for visual transitions between sections

### Tone Guidelines
- **Friendly**: Use conversational language, avoid jargon
- **Encouraging**: Emphasize how easy the process is
- **Clear**: Speak slowly enough to follow along
- **Confident**: Reassure viewers this will work

### Accessibility
- Narration should describe all visual elements for screen reader users
- On-screen text should reinforce narration (redundancy is good)
- Terminal output should be large enough to read at 720p
- Use high contrast colors for highlights

### Common Issues Callout
Consider adding a 10-second segment at [04:00] if timing allows:

**"If agents don't appear after installation, restart Claude Code completely using `/exit` then `claude`. This refreshes the agent registry."**

---

## Script Metadata

**Created**: 2025-10-20
**Purpose**: Video walkthrough for AGENT-11 installation
**Target**: First-time users with basic terminal knowledge
**Success Metric**: 95%+ can install without external help after watching
**Update Frequency**: Review quarterly or when installation process changes

---

*This script is designed for professional video production. Adjust pacing and detail level based on actual screen recording and narration speed during production.*
