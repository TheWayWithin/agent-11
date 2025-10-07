# CLAUDE.md Template
## Project-Specific Configuration for Claude Code

This template provides a starting point for generating project-specific CLAUDE.md files during bootstrap workflows. It should be populated with information from ideation documents (greenfield) or codebase analysis (brownfield).

---

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Project Name**: [PROJECT_NAME]

**Vision**:
[2-3 sentence project vision statement extracted from ideation or inferred from codebase]

**Problem Statement**:
[What problem does this project solve? Who are the users?]

**Core Functionality**:
- [Core feature/capability 1]
- [Core feature/capability 2]
- [Core feature/capability 3]

**Project Stage**: [POC | MVP | Production | Mature]

## Architecture

### Technology Stack

**Frontend**:
- Framework: [React | Vue | Next.js | etc.]
- Language: [TypeScript | JavaScript]
- UI Library: [Tailwind | Material-UI | etc.]
- State Management: [Redux | Context | Zustand | etc.]
- Key Libraries:
  - [Library 1 - Purpose]
  - [Library 2 - Purpose]

**Backend**:
- Platform: [Node.js | Python | Go | etc.]
- Framework: [Express | FastAPI | etc.]
- Database: [PostgreSQL | MongoDB | MySQL | etc.]
- Authentication: [Auth0 | Supabase Auth | NextAuth | etc.]
- Key Services:
  - [Service 1 - Purpose]
  - [Service 2 - Purpose]

**Infrastructure**:
- Hosting: [Vercel | Netlify | Railway | AWS | etc.]
- CI/CD: [GitHub Actions | GitLab CI | etc.]
- Monitoring: [Sentry | LogRocket | etc.]
- Analytics: [PostHog | Mixpanel | etc.]

### System Architecture

**Pattern**: [MVC | Microservices | Serverless | Monolithic | etc.]

**Key Components**:
1. **[Component A]**: [Purpose and responsibility]
2. **[Component B]**: [Purpose and responsibility]
3. **[Component C]**: [Purpose and responsibility]

**Data Flow**:
```
[User] → [Frontend] → [API Layer] → [Business Logic] → [Database]
                    ↓
              [External Services]
```

### Architecture Decisions

**ADR-001: [Decision Title]**
- **Context**: [Why this decision was needed]
- **Decision**: [What was decided]
- **Rationale**: [Why this choice over alternatives]
- **Consequences**: [Trade-offs and implications]

[Add more ADRs as documented in /memories/technical/decisions.xml]

## Codebase Structure

```
[PROJECT_ROOT]/
├── src/
│   ├── components/     # [Description]
│   ├── pages/          # [Description]
│   ├── services/       # [Description]
│   ├── utils/          # [Description]
│   └── types/          # [Description]
├── tests/
│   ├── unit/           # [Description]
│   ├── integration/    # [Description]
│   └── e2e/            # [Description]
├── public/             # [Description]
├── docs/               # [Description]
└── scripts/            # [Description]
```

**Key Directories**:
- `/src/components` - [Purpose and organization]
- `/src/services` - [Purpose and organization]
- `/tests` - [Testing approach and coverage]

**File Naming Conventions**:
- Components: [PascalCase.tsx | kebab-case.tsx | etc.]
- Utilities: [camelCase.ts | snake_case.ts | etc.]
- Tests: [*.test.ts | *.spec.ts | etc.]

## Development Guidelines

### Code Style

**TypeScript Usage**: [Strict | Permissive | Gradual adoption]
- [Specific type requirements or patterns]
- [Any type usage policy]
- [Interface vs Type preference]

**Component Patterns**: [Functional | Class | Mixed]
- [Hook usage guidelines]
- [Component composition patterns]
- [Props interface conventions]

**Code Organization**:
- [Feature-based | Layer-based | Domain-driven]
- [Module boundaries and dependencies]
- [Import/export conventions]

**Formatting**:
- Linter: [ESLint | Biome | etc.]
- Formatter: [Prettier | etc.]
- Config: [Standard | Airbnb | Custom]

### Testing Approach

**Framework**: [Jest | Vitest | Playwright | Cypress | etc.]

**Coverage Targets**:
- Unit tests: [percentage]%
- Integration tests: [percentage]%
- E2E tests: [critical paths]

**Testing Patterns**:
- [Testing Library approach | Enzyme | etc.]
- [Mock strategy - MSW | manual mocks | etc.]
- [Test organization pattern]

**MCP Integration**:
[If mcp__playwright available: Use for E2E and browser automation]

### Error Handling

**Strategy**: [Try-catch | Error boundaries | Result types | etc.]

**Patterns**:
```typescript
// [Example error handling pattern used in project]
```

**Logging**:
- Client-side: [Console | Sentry | etc.]
- Server-side: [Winston | Pino | etc.]

### Security Requirements

**Content Security Policy**:
```
[CSP configuration from constraints]
```
**CRITICAL**: Never remove or weaken CSP for convenience. Use nonces with strict-dynamic pattern.

**Authentication**:
- Provider: [Auth0 | Supabase | NextAuth | etc.]
- Session handling: [JWT | Session cookies | etc.]
- Protected routes: [Pattern for route protection]

**Data Validation**:
- Input validation: [Zod | Yup | Joi | etc.]
- API validation: [Middleware pattern]
- Sanitization: [DOMPurify | etc.]

**Critical Principle**: NEVER compromise security for convenience. Research security features before changing them. Work WITH security, not around it.

### Performance Considerations

**Targets**:
- Initial page load: [target ms]
- Time to interactive: [target ms]
- API response time: [target ms]

**Optimization Patterns**:
- Code splitting: [Strategy]
- Image optimization: [Approach]
- Caching strategy: [Pattern]
- Bundle size budget: [limit KB]

**Monitoring**:
- Performance tracking: [Tool/approach]
- Error tracking: [Sentry | etc.]

## Available MCPs

[Discovered during bootstrap - these are powerful integrations available]

### Infrastructure & Deployment
- **mcp__railway**: Backend services, databases, auto-scaling
- **mcp__netlify**: Frontend hosting, edge functions, forms
- **mcp__supabase**: Managed Postgres, auth, real-time, storage

### Development & Documentation
- **mcp__github**: PRs, issues, releases, CI/CD
- **mcp__context7**: Library documentation, code patterns
- **mcp__firecrawl**: Web scraping, competitor analysis

### Testing & Quality
- **mcp__playwright**: Browser automation, E2E testing, screenshots

### Commerce (if applicable)
- **mcp__stripe**: Payments, subscriptions, invoicing

**MCP-First Principle**: Always check if an MCP can handle a task before implementing manually.

**Usage Patterns**:
- Database operations: Use mcp__supabase instead of raw SQL
- Testing: Use mcp__playwright for E2E tests
- Documentation: Use mcp__context7 for library research
- Deployment: Use mcp__railway or mcp__netlify

## Ideation Context

**Location**: `./ideation.md` [or created during dev-alignment]
**Last Updated**: [DATE]

**Key Requirements**:
- [Critical requirement 1 from memory]
- [Critical requirement 2 from memory]
- [Critical requirement 3 from memory]

**Out of Scope**:
- [Explicitly excluded feature 1]
- [Explicitly excluded feature 2]

**Success Criteria**:
- [Success metric 1]
- [Success metric 2]
- [Success metric 3]

## Memory Protocol

AGENT-11 uses Claude Code's native memory tools for persistent project knowledge.

**Memory Location**: `/memories`

**Structure**:
```
/memories/
├── project/        # Requirements, architecture, constraints, metrics
├── user/          # Preferences, context, goals
├── technical/     # Decisions, patterns, tooling
└── lessons/       # Insights, debugging, optimizations
```

**Agent Protocol**:
1. **Before Task**: Read relevant memory files for context
2. **During Task**: Apply memory-informed decisions
3. **After Task**: Update memory with new learnings
4. **Handoff**: Document in handoff-notes.md for next agent

**Key Memory Files**:
- `/memories/project/requirements.xml` - Core features and user stories
- `/memories/project/constraints.xml` - Security, performance, technical limits
- `/memories/user/preferences.xml` - Communication style, technical depth
- `/memories/technical/decisions.xml` - Architecture decisions and rationale

**Integration with Context Files**:
- **Memory**: Long-term project knowledge (persists across sessions)
- **Context Files**: Mission coordination (agent-context.md, handoff-notes.md)
- Both systems work together for optimal agent performance

## Progress Tracking Protocol

After each work session or milestone:

1. **Update project-plan.md**
   - Mark completed tasks with [x]
   - Add new tasks discovered
   - Update timeline estimates
   - Document MCPs used

2. **Log in progress.md**
   - Issues encountered and resolutions
   - Lessons learned
   - Technical decisions made
   - Performance insights

3. **Update CLAUDE.md**
   - New architectural patterns discovered
   - Performance optimizations found
   - Common command updates
   - MCP usage patterns

4. **Update Memory**
   - New technical decisions → /memories/technical/decisions.xml
   - Lessons learned → /memories/lessons/insights.xml
   - Architecture changes → /memories/project/architecture.xml

## Critical Software Development Principles

### Security-First Development
**NEVER compromise security for convenience**

- Research security features before changing them (CSP, CORS, auth)
- Understand WHY security features exist
- Work WITH security features, not around them
- Example: Use nonces properly with strict-dynamic CSP instead of removing security

### Strategic Solution Checklist
Before implementing any fix:
- ✅ Does this maintain all security requirements?
- ✅ Is this the architecturally correct solution?
- ✅ Will this create technical debt?
- ✅ Are there better long-term solutions?
- ✅ Have I understood the original design intent?

### Root Cause Analysis Protocol
- Ask "Why was this designed this way?" before changes
- Look for architectural intent behind existing code
- Consider broader system impact
- Don't just fix symptoms - address root causes
- PAUSE before implementing first solution

### Anti-Patterns to Avoid
- ❌ Removing security features to "make things work"
- ❌ Adding `any` types to bypass TypeScript errors
- ❌ Using `@ts-ignore` without understanding the issue
- ❌ Disabling linters or security scanners
- ❌ Implementing quick fixes that break design patterns

## Performance Insights

[To be populated during development - track optimizations and wins]

**Current Performance**:
- [Baseline metrics]

**Optimization Opportunities**:
- [Areas identified for improvement]
- [MCPs that could help]

**Successful Optimizations**:
- [What worked, by how much]

## Common Commands

```bash
# Development
npm run dev          # [or project-specific command]
npm run build        # [or project-specific command]
npm run test         # [or project-specific command]

# Testing
npm run test:unit    # [if available]
npm run test:e2e     # [if available]
npm run test:coverage # [if available]

# Deployment
npm run deploy       # [or project-specific command]

# Database
npm run db:migrate   # [if applicable]
npm run db:seed      # [if applicable]

# MCP Discovery
grep "mcp__"         # Find available MCP tools

# Code Quality
npm run lint         # [if available]
npm run format       # [if available]
npm run typecheck    # [if available]
```

## Known Issues

[Document current bugs, technical debt, TODOs]

**Active Issues**:
- [Issue 1 - Description and impact]
- [Issue 2 - Description and impact]

**Technical Debt**:
- [Debt item 1 - When to address]
- [Debt item 2 - When to address]

**Planned Improvements**:
- [Improvement 1]
- [Improvement 2]

**MCP Opportunities**:
- [Service that could use MCP integration]
- [Testing that could leverage mcp__playwright]

## Update Checklist

After each work session:
- [ ] Milestone completed → Update project-plan.md
- [ ] Issue resolved → Log in progress.md
- [ ] Lesson learned → Add to progress.md
- [ ] Performance insight → Update CLAUDE.md
- [ ] Pattern discovered → Document in CLAUDE.md
- [ ] MCP usage → Track successful patterns
- [ ] Memory updated → New learnings in /memories

## Troubleshooting

**Common Issues**:

**[Issue Category 1]**:
- Symptom: [What you see]
- Cause: [Root cause]
- Solution: [How to fix]
- Prevention: [How to avoid]

**[Issue Category 2]**:
- Symptom: [What you see]
- Cause: [Root cause]
- Solution: [How to fix]
- Prevention: [How to avoid]

## Additional Resources

**Documentation**:
- [Link to external docs]
- [Link to API reference]

**Design Resources**:
- [Link to design system]
- [Link to component library]

**Infrastructure**:
- [Link to deployment dashboard]
- [Link to monitoring]

---

**Generated**: [DATE]
**Bootstrap Method**: [Greenfield from ideation | Brownfield from codebase]
**Last Updated**: [DATE]
**Maintained By**: AGENT-11 Squad

---

## Template Customization Instructions

### For Greenfield Projects (from ideation.md):
1. Extract project name and vision from ideation
2. Map requirements to core functionality
3. Pull technology stack from architecture preferences
4. Document constraints from ideation (security, performance, business)
5. Extract user preferences for development style
6. List MCPs available in environment
7. Create initial roadmap from ideation milestones

### For Brownfield Projects (from codebase analysis):
1. Infer project name from package.json or repo
2. Analyze codebase to determine tech stack
3. Extract architecture patterns from code organization
4. Document testing approach from existing tests
5. Identify security features from configs (CSP, auth)
6. Map available MCPs to current architecture
7. Extract common commands from package.json scripts
8. Identify known issues from TODOs and Git history

### Security Validation:
- Ensure all paths referenced are safe
- Verify no sensitive data in file (API keys, passwords)
- Validate all examples use secure patterns
- Document security requirements from constraints

### Quality Checks:
- All sections completed with relevant information
- No placeholder text left (replace all [BRACKETS])
- Accurate reflection of project reality
- Clear, actionable guidance for agents
- MCP integration opportunities identified

---

*This template is part of AGENT-11's bootstrap system for automated project initialization.*
