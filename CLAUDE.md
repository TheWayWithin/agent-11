# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AGENT-11 is a framework for deploying specialized AI agents in Claude Code to form an elite development squad. The project provides templates, documentation, and deployment guides for 11 specialized agents that collaborate to help solo founders build and ship products rapidly.

## Architecture

This is a documentation-based project with the following structure:

- `/agents/` - Agent profiles and deployment commands
  - `core-squad.md` - 4 essential agents for getting started
  - `full-squad.md` - All 11 specialized agents
  - `specialists/` - Individual agent profiles with detailed capabilities
- `/field-manual/` - User guides and best practices (minimal content currently)
- `/missions/` - Predefined workflows and operation guides
- `/community/` - Success stories and user contributions
- `/templates/` - Reusable templates for common scenarios

## Agent Deployment System

The core functionality involves using Claude Code's `/agent` command to deploy specialized agents:

```bash
# Example core squad deployment
/agent strategist "You are THE STRATEGIST, an elite product strategy specialist..."
/agent developer "You are THE DEVELOPER, an elite full-stack engineer..."
/agent tester "You are THE TESTER, an elite QA specialist..."
/agent operator "You are THE OPERATOR, an elite DevOps specialist..."
```

## Key Components

### Core Squad (Minimum Viable Team)
1. **The Strategist** - Product strategy and requirements
2. **The Developer** - Full-stack implementation 
3. **The Tester** - Quality assurance
4. **The Operator** - DevOps and deployment

### Full Squad (11 Specialists)
Includes the core squad plus:
- The Architect (system design)
- The Designer (UX/UI)
- The Documenter (technical writing)
- The Support (customer success)
- The Analyst (data insights)
- The Marketer (growth)
- The Coordinator (mission orchestration)

## Development Guidelines

- This is a documentation-first project with no build system or package.json
- All content is in Markdown format
- Agent profiles follow a consistent structure with deployment commands, capabilities, and collaboration protocols
- Documentation uses military/tactical metaphors consistently
- Focus on actionable, practical guidance for solo founders

## File Editing Conventions

- Maintain the consistent tone and military theme throughout
- Agent profiles should include deployment commands, capabilities, collaboration protocols, and real examples
- Use consistent formatting with emoji indicators for different sections
- Keep deployment commands as single-line strings for easy copy/paste
- Include practical examples and workflows in documentation

## Common Tasks

### Adding New Agent Profiles
1. Create new file in `/agents/specialists/`
2. Follow existing template structure
3. Update `/agents/full-squad.md` with new agent
4. Add deployment command to relevant quick-start guides

### Updating Documentation
- Maintain consistency with existing tone and structure
- Focus on practical, actionable content
- Include real-world examples and workflows
- Keep military/tactical metaphors throughout

### Content Guidelines
- Write for solo founders and non-technical founders
- Emphasize speed, efficiency, and practical results
- Include specific commands and examples
- Maintain the "elite squad" branding throughout

## No Build/Test Commands

This project has no build system, package management, or automated testing since it's purely documentation-based. Changes can be verified by:
- Reviewing Markdown formatting
- Testing deployment commands in Claude Code
- Validating links and references between files