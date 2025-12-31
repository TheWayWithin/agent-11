# Claude Code Skills: Location Architecture

## Official Skill Locations (from Claude Code Docs)

Claude Code looks for skills in these locations, with **priority order** (higher wins):

| Priority | Location | Path | Applies To |
|----------|----------|------|------------|
| 1 (highest) | Enterprise | Managed settings | All users in organization |
| 2 | Personal | `~/.claude/skills/` | User, across all projects |
| 3 | Project | `.claude/skills/` | Anyone working in repository |
| 4 (lowest) | Plugin | Bundled with plugins | Anyone with plugin installed |

**Key insight**: If two Skills have the same name, higher priority wins.

## Deployment Architecture for Agent-11

### Source vs Destination Distinction

**DEPLOYED FROM (Agent-11 Library)**:
- Location: `/project/skills/` within Agent-11 library repo
- Purpose: Master skill definitions, templates, versioned protocols
- Contains: SKILL.md files + supporting files (reference.md, scripts/)

**DEPLOYED TO (Target Product Project)**:
- Location: `.claude/skills/` in the SaaS project being built
- Purpose: Active skills for Claude Code to discover and use
- Mechanism: Copy/symlink from Agent-11 library to project

### Deployment Flow

```
Agent-11 Library                    Target SaaS Project
/agent-11/                          /my-saas-app/
├── skills/                         ├── .claude/
│   ├── foundations-skill/          │   └── skills/
│   │   └── SKILL.md       ──────►  │       ├── foundations-skill/
│   ├── auth-skill/                 │       │   └── SKILL.md
│   │   └── SKILL.md       ──────►  │       ├── auth-skill/
│   └── payments-skill/             │       │   └── SKILL.md
│       └── SKILL.md       ──────►  │       └── payments-skill/
└── ...                             │           └── SKILL.md
                                    ├── src/
                                    └── ...
```

## Skill File Structure

Each skill is a **directory** containing:

```
skill-name/
├── SKILL.md              (required - YAML frontmatter + instructions)
├── reference.md          (optional - detailed docs, loaded on demand)
├── examples.md           (optional - usage examples)
└── scripts/
    └── helper.py         (optional - utility scripts, executed not loaded)
```

### SKILL.md Format

```yaml
---
name: skill-name          # lowercase, hyphens, max 64 chars
description: Brief description of what this Skill does and when to use it
allowed-tools: Read, Grep, Glob  # optional - restrict tool access
model: claude-sonnet-4-20250514  # optional - override model
---

# Skill Name

## Instructions
[Markdown instructions Claude follows when skill is active]

## Additional Resources
- See [reference.md](reference.md) for details
```

## Key Behaviors

1. **Auto-discovery**: Claude loads only name/description at startup (fast)
2. **Semantic matching**: Claude matches requests to skill descriptions
3. **Progressive disclosure**: Supporting files loaded only when needed
4. **Context efficiency**: Keep SKILL.md under 500 lines

## Implications for Agent-11

### install.sh Should:
1. Copy skills from Agent-11 library to `.claude/skills/` in target project
2. NOT copy to `~/.claude/skills/` (personal) unless explicitly requested
3. Maintain skill directory structure (not just SKILL.md files)

### Skill Naming:
- Use lowercase with hyphens: `foundations-skill`, `auth-implementation`
- Match directory name to skill name in YAML

### Token Budget Consideration:
- Skills compete for context with conversation history
- Use progressive disclosure for large reference material
- Keep SKILL.md focused, put details in reference.md

## Distribution Methods

1. **Project Skills**: Commit `.claude/skills/` to version control
2. **Plugins**: Create `skills/` directory in plugin package
3. **Enterprise**: Deploy via managed settings (org-wide)

For Agent-11, **Project Skills** is the primary method - skills are copied into each SaaS project's `.claude/skills/` directory.
