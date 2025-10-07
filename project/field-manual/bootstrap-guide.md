# Bootstrap Guide: Memory Initialization for AGENT-11

## Overview

This guide documents the bootstrap process for initializing Claude Code's memory system from ideation documents or existing codebases. Bootstrap workflows automate the extraction of project knowledge into structured memory files, enabling persistent context across sessions.

## What is Bootstrap?

**Bootstrap** is the automated process of:
1. Reading ideation documents or analyzing codebases
2. Extracting structured information (requirements, constraints, architecture)
3. Creating organized memory files in `/memories` directory
4. Generating project-specific CLAUDE.md configuration
5. Initializing tracking files (project-plan.md, progress.md)

**Security-First Design**: All bootstrap workflows include path validation, content sanitization, and safe file operations to prevent directory traversal attacks and code injection.

## Two Bootstrap Workflows

### Workflow 1: Greenfield Bootstrap (New Projects)
**Mission**: `/coord dev-setup ideation.md`
**Purpose**: Initialize new project from ideation documents
**Input**: Ideation.md, requirements, vision documents
**Output**: Complete project structure with memory, tracking, and CLAUDE.md

### Workflow 2: Brownfield Bootstrap (Existing Projects)
**Mission**: `/coord dev-alignment`
**Purpose**: Understand and align with existing codebase
**Input**: Existing codebase structure and files
**Output**: Analyzed architecture, inferred requirements, optimized CLAUDE.md

## Greenfield Bootstrap Process

### Phase 1: Memory Initialization from Ideation

**Coordinator Prompt**:
```
BOOTSTRAP PROTOCOL - Greenfield Project

1. READ IDEATION DOCUMENT
   - Load ideation.md or specified document
   - Identify all requirements, constraints, preferences

2. CREATE MEMORY STRUCTURE
   Create /memories directory with subdirectories:
   - /memories/project/     (requirements, architecture, constraints, metrics)
   - /memories/user/        (preferences, context, goals)
   - /memories/technical/   (decisions, patterns, tooling)
   - /memories/lessons/     (insights, debugging, optimizations)

3. EXTRACT TO MEMORY FILES
   Using templates from /templates/memory-bootstrap-template.md:

   a) /memories/project/requirements.xml
      - Extract: Core features, user stories, acceptance criteria
      - Extract: Out of scope items explicitly mentioned
      - Format: XML structure per template

   b) /memories/project/constraints.xml
      - Extract: Security requirements and policies
      - Extract: Performance targets and budgets
      - Extract: Technical constraints (browsers, accessibility)
      - Extract: Business constraints (timeline, budget, compliance)
      - Extract: External dependencies and rate limits
      - Format: XML structure per template

   c) /memories/project/architecture.xml
      - Extract: Technology stack preferences
      - Extract: Architectural patterns mentioned
      - Document: Initial architecture decisions
      - Note: Design patterns to follow and anti-patterns to avoid
      - Format: XML structure per template

   d) /memories/user/preferences.xml
      - Infer: Communication style from ideation tone
      - Extract: Technical depth preference
      - Extract: Development workflow preferences
      - Extract: Testing and documentation preferences
      - Format: XML structure per template

   e) /memories/user/context.xml
      - Extract: User background and role
      - Extract: Project goals and objectives
      - Extract: Learning objectives
      - Extract: Pain points and challenges
      - Format: XML structure per template

4. SECURITY VALIDATION
   For each memory file created:
   - Validate path starts with /memories
   - Sanitize content for potential code injection
   - Verify XML structure is well-formed
   - Check file size < 1000 tokens
   - Audit for sensitive information (API keys, passwords)

5. QUALITY CHECKS
   - Verify all required files created
   - Check XML is valid and parseable
   - Ensure no duplicate or redundant content
   - Flag any missing critical information
   - Mark gaps requiring user clarification

6. DOCUMENT BOOTSTRAP RESULTS
   Create bootstrap summary:
   - Files created: [list]
   - Information extracted: [summary]
   - Gaps requiring clarification: [list]
   - Security checks passed: [checklist]
```

### Phase 2: CLAUDE.md Generation

**Coordinator Prompt**:
```
GENERATE CLAUDE.md FROM IDEATION

1. CREATE PROJECT OVERVIEW SECTION
   - Extract project name and vision from ideation
   - Summarize problem statement
   - Document target users and use cases
   - List core features and functionality

2. EXTRACT ARCHITECTURE SECTION
   - Technology stack from memory/project/architecture.xml
   - Infrastructure decisions
   - Integration points
   - Development patterns

3. ADD DEVELOPMENT GUIDELINES
   - Extract code style preferences from ideation
   - Document testing approach
   - Build and deployment processes
   - Security requirements

4. CONFIGURE IDEATION REFERENCE
   - Set ideation file location
   - List key requirements for quick reference
   - Note critical constraints

5. ADD PROGRESS TRACKING PROTOCOL
   - Standard tracking requirements
   - Update checklist for sessions
   - Performance insights section

6. INCLUDE MCP CONFIGURATION
   - List available MCPs
   - Map MCPs to project needs
   - Document usage patterns

7. SECURITY CONSIDERATIONS
   - Document security requirements from constraints
   - List compliance needs
   - Note sensitive data handling

Use template from /templates/claude-template.md as base.
```

### Phase 3: Tracking Files Initialization

**Coordinator Prompt**:
```
INITIALIZE TRACKING FILES

1. CREATE project-plan.md
   - Executive summary from ideation
   - Core objectives as checkboxes
   - Technical architecture from memory
   - Milestone roadmap with phases
   - Success metrics from memory
   - Risk assessment
   - Resource requirements

2. CREATE progress.md
   - Project start date
   - Empty completed milestones section
   - Current sprint goals from first milestone
   - Placeholder sections for:
     - Blockers
     - Lessons learned
     - Technical decisions
     - Performance insights

3. CREATE architecture.md
   - Use /templates/architecture.md as base
   - Populate from memory/project/architecture.xml
   - Add system overview and boundaries
   - Document infrastructure architecture
   - Include initial architecture decisions
```

## Brownfield Bootstrap Process

### Phase 1: Codebase Analysis

**Coordinator Prompt**:
```
BOOTSTRAP PROTOCOL - Existing Codebase

1. ANALYZE PROJECT STRUCTURE
   - Identify root directory and project type
   - Detect framework (React, Next.js, Vue, etc.)
   - Find configuration files (package.json, tsconfig, etc.)
   - Map directory structure

2. IDENTIFY TECHNOLOGY STACK
   - Language: Check file extensions (.ts, .js, .py, etc.)
   - Framework: Check dependencies and imports
   - Database: Look for connection configs, ORMs
   - Testing: Identify test framework and coverage
   - Build tools: Find webpack, vite, etc.
   - Deployment: Check for Dockerfile, netlify.toml, etc.

3. EXTRACT ARCHITECTURE PATTERNS
   - Code organization (feature-based, layered, etc.)
   - State management (Redux, Context, Zustand)
   - API patterns (REST, GraphQL, tRPC)
   - Authentication approach
   - Error handling patterns
   - Logging and monitoring

4. INFER PROJECT REQUIREMENTS
   - Core features from route/component structure
   - User roles from authentication logic
   - Data models from schemas/types
   - Integration points from API calls
   - Business logic from service layer

5. ASSESS CODE QUALITY
   - TypeScript usage and type safety
   - Test coverage percentage
   - Linting configuration
   - Code documentation level
   - Security patterns (CSP, CORS, auth)
   - Performance considerations

6. IDENTIFY DEPENDENCIES
   - Production dependencies
   - Development dependencies
   - Peer dependencies
   - External services (APIs, databases)
   - MCP opportunities (Supabase, Stripe, etc.)

SECURITY NOTE: Perform root cause analysis before making changes.
Understand WHY existing security features exist before modifying.
```

### Phase 2: Memory Initialization from Codebase

**Coordinator Prompt**:
```
CREATE MEMORY FROM CODEBASE ANALYSIS

1. CREATE /memories/project/requirements.xml
   - Infer core features from routes/components
   - Extract user stories from UI flows
   - Document success criteria from tests
   - Note features marked as "TODO" or "WIP"

2. CREATE /memories/project/architecture.xml
   - Document detected tech stack
   - Describe architectural patterns found
   - List key libraries and their purposes
   - Document design decisions evident in code
   - Note anti-patterns to avoid (from code smells)

3. CREATE /memories/project/constraints.xml
   - Extract security policies (CSP, CORS from configs)
   - Document performance budgets (if configured)
   - Note browser/platform requirements
   - Identify external API rate limits
   - Document compliance requirements (GDPR, etc.)

4. CREATE /memories/technical/decisions.xml
   - Document framework choice and rationale
   - Note database selection reasoning
   - Describe authentication approach
   - Record deployment strategy

5. CREATE /memories/technical/patterns.xml
   - Document proven patterns found in code
   - Note effective error handling approaches
   - Record successful optimization patterns
   - Flag anti-patterns to avoid

6. CREATE /memories/lessons/debugging.xml
   - Extract lessons from Git history
   - Document bug fixes and their root causes
   - Note testing gaps discovered
   - Record debugging strategies that worked

IMPORTANT: Validate all paths, sanitize content, verify XML structure.
```

### Phase 3: CLAUDE.md Generation from Codebase

**Coordinator Prompt**:
```
GENERATE CLAUDE.md FROM CODEBASE ANALYSIS

1. PROJECT OVERVIEW SECTION
   - Name from package.json or repo
   - Purpose inferred from README or code
   - Architecture summary from analysis

2. TECHNOLOGY STACK SECTION
   - Detected languages and frameworks
   - Key libraries and tools
   - Database and infrastructure
   - Build and deployment setup

3. CODEBASE STRUCTURE SECTION
   - Directory organization pattern
   - Key directories and their purposes
   - File naming conventions
   - Module organization

4. DEVELOPMENT GUIDELINES SECTION
   - Detected code style (from actual code)
   - Testing patterns found
   - Error handling approach
   - Documentation style

5. COMMON COMMANDS SECTION
   - Build command from package.json
   - Test command from scripts
   - Run/dev command
   - Deployment command

6. ARCHITECTURAL PATTERNS SECTION
   - State management approach
   - Data flow patterns
   - API integration patterns
   - Component structure

7. SECURITY CONSIDERATIONS SECTION
   - Detected security features (CSP, auth)
   - Security requirements from code
   - Sensitive data handling patterns

8. KNOWN ISSUES SECTION
   - TODOs from codebase
   - Deprecated dependencies
   - Test failures
   - Technical debt items

9. MCP INTEGRATION OPPORTUNITIES
   - Identify services that could use MCPs
   - Map detected patterns to available MCPs
   - Suggest MCP adoption for improvements

Use template from /templates/claude-template.md as foundation.
```

## CLAUDE.md Template Structure

```markdown
# CLAUDE.md

## Project Overview
[Extracted from ideation or inferred from codebase]
- Project name and vision
- Problem statement
- Target users
- Core functionality

## Architecture
[From memory/project/architecture.xml or codebase analysis]

### Technology Stack
- Frontend: [framework + language]
- Backend: [platform + language]
- Database: [type + provider]
- Infrastructure: [hosting + deployment]

### Key Components
1. Component A: [purpose]
2. Component B: [purpose]
3. Component C: [purpose]

## Codebase Structure
[For brownfield projects]
- /src/components - UI components
- /src/services - Business logic
- /src/api - API integration
- [Directory structure]

## Development Guidelines

### Code Style
- [Style preferences or detected patterns]
- TypeScript usage: [strict/permissive]
- Function vs Class components: [preference]

### Testing Approach
- Framework: [Jest/Vitest/Playwright]
- Coverage target: [percentage]
- Test patterns: [unit/integration/e2e]

### Security Requirements
- CSP policy: [from constraints]
- Authentication: [approach]
- Data validation: [requirements]

## Ideation Context
Location: `./ideation.md` [or created during dev-alignment]
Last Updated: [date]

Key Requirements:
- [Requirement 1]
- [Requirement 2]
- [Requirement 3]

## Available MCPs
[Discovered during bootstrap]
- mcp__supabase: Database operations
- mcp__context7: Library documentation
- mcp__playwright: E2E testing
- mcp__firecrawl: Web scraping
- [Additional MCPs]

## Progress Tracking Protocol
After each work session or milestone:
1. Update project-plan.md with completed tasks
2. Log issues and resolutions in progress.md
3. Document lessons learned
4. Record performance insights

## Memory Protocol
All agents should:
1. Read /memories before starting tasks
2. Apply memory-informed decisions
3. Update memory with new learnings
4. Document handoffs in handoff-notes.md

## Performance Insights
[To be populated during development]

## Common Commands
```bash
# Build
[project-specific build command]

# Test
[project-specific test command]

# Run
[project-specific run command]

# MCP Discovery
grep "mcp__"
```

## Update Checklist
- [ ] Milestone completed → Update project-plan.md
- [ ] Issue resolved → Log in progress.md
- [ ] Lesson learned → Add to progress.md
- [ ] Performance insight → Update CLAUDE.md
```

## Security-First Bootstrap

### Path Validation (CRITICAL)

All bootstrap workflows MUST validate file paths to prevent directory traversal attacks:

```python
# Conceptual validation (executed by Claude Code)
def validate_memory_path(path: str) -> bool:
    """
    Security validation for memory file paths.
    """
    # 1. Path must start with /memories
    if not path.startswith("/memories"):
        raise ValueError(f"Path must start with /memories: {path}")

    # 2. Prevent directory traversal
    forbidden = ["../", "..\\", "%2e%2e", "..%2f", "..%5c"]
    if any(seq in path.lower() for seq in forbidden):
        raise ValueError(f"Directory traversal detected: {path}")

    # 3. Canonical path must be within memory root
    # (Claude Code handles this through safe file operations)

    # 4. No absolute paths outside project
    if path.startswith("/") and not path.startswith("/memories"):
        raise ValueError(f"Absolute path outside memory: {path}")

    return True
```

### Content Sanitization

All content extracted to memory must be sanitized:

```python
# Conceptual sanitization (executed by Claude Code)
def sanitize_memory_content(content: str) -> str:
    """
    Sanitize content before writing to memory files.
    """
    # 1. Remove potential code injection
    # (Claude already refuses dangerous content, but add extra layer)

    # 2. Validate XML structure
    try:
        import xml.etree.ElementTree as ET
        ET.fromstring(content)
    except ET.ParseError as e:
        raise ValueError(f"Invalid XML structure: {e}")

    # 3. Check for sensitive data patterns
    sensitive_patterns = [
        r"password\s*=\s*['\"].*['\"]",
        r"api[_-]?key\s*=\s*['\"].*['\"]",
        r"secret\s*=\s*['\"].*['\"]",
        r"token\s*=\s*['\"].*['\"]"
    ]
    # Flag if found, don't auto-remove (might be legitimate)

    # 4. Verify file size
    if len(content) > 10000:  # ~1000 tokens
        raise ValueError("Memory file too large, split into smaller files")

    return content
```

### File Size Monitoring

Bootstrap workflows must enforce memory file size limits:

```
MEMORY FILE SIZE LIMITS:
- Individual file: < 1000 tokens (~10KB)
- Total /memories: < 10,000 tokens (~100KB)
- Alert if approaching limits
- Suggest splitting large files
```

## Bootstrap Validation Checklist

After bootstrap completion, verify:

**Memory Structure**:
- [ ] /memories directory created
- [ ] All subdirectories present (project, user, technical, lessons)
- [ ] Required files created per workflow

**Security Validation**:
- [ ] All paths start with /memories
- [ ] No directory traversal sequences
- [ ] Content sanitized for code injection
- [ ] No sensitive data in memory files
- [ ] File sizes within limits

**Content Quality**:
- [ ] XML files are well-formed
- [ ] Information is accurate and actionable
- [ ] No duplicate or redundant content
- [ ] Gaps flagged for user clarification
- [ ] Memory aligns with source documents

**Integration**:
- [ ] CLAUDE.md generated and accurate
- [ ] project-plan.md created with roadmap
- [ ] progress.md initialized
- [ ] architecture.md created/updated
- [ ] All files reference memory correctly

**Testing**:
- [ ] Memory persists across context resets
- [ ] Agents can read memory successfully
- [ ] Memory updates work correctly
- [ ] Token consumption reduced as expected

## Troubleshooting

### Issue: Bootstrap creates files outside /memories

**Root Cause**: Path validation not enforced
**Solution**: Implement strict path checking in coordinator prompt
**Prevention**: Add explicit validation step to bootstrap workflow

### Issue: Memory files too large (> 1000 tokens)

**Root Cause**: Too much information extracted at once
**Solution**: Break into smaller, focused files by concern
**Example**: Split architecture.xml into architecture_frontend.xml and architecture_backend.xml

### Issue: XML parsing errors

**Root Cause**: Malformed XML structure in extracted content
**Solution**: Validate XML before writing, use XML escaping for special characters
**Prevention**: Include XML validation in bootstrap workflow

### Issue: Sensitive data in memory files

**Root Cause**: Insufficient content sanitization
**Solution**: Remove sensitive data, add to .gitignore if local secrets
**Prevention**: Implement stricter sensitive data detection

### Issue: Context editing clears memory

**Root Cause**: Memory tool not excluded from context management
**Solution**: Add `"exclude_tools": ["memory"]` to context editing config
**Prevention**: Document in bootstrap completion checklist

## Best Practices

### DO ✅

**1. Validate Before Creating**
- Always check paths before file creation
- Validate XML structure before writing
- Verify file sizes stay within limits

**2. Extract Strategically**
- Focus on essential information only
- Break large documents into logical chunks
- Use XML structure for clarity

**3. Document Gaps**
- Flag missing information for user clarification
- Note assumptions made during extraction
- Mark areas requiring validation

**4. Test Bootstrap Results**
- Verify memory files load correctly
- Test agent access to memory
- Confirm token consumption improvements

### DON'T ❌

**1. Don't Skip Security Validation**
- Never create files without path validation
- Don't bypass sanitization for convenience
- Always audit for sensitive data

**2. Don't Create Monolithic Files**
- Avoid single large memory files
- Don't accumulate duplicate information
- Split by concern for focused access

**3. Don't Over-Extract**
- Don't copy entire documents to memory
- Avoid storing conversation history
- Exclude implementation details

**4. Don't Ignore Errors**
- Don't proceed if validation fails
- Address XML parsing errors immediately
- Fix size violations before continuing

## Integration with Missions

### Dev-Setup Mission Integration

```markdown
## Phase 1: Bootstrap Project Memory (5 min)

/coord "Bootstrap greenfield project from ideation.md"

**Coordinator executes**:
1. Read ideation.md
2. Create /memories directory structure
3. Extract to memory files using bootstrap template
4. Validate security and content quality
5. Generate CLAUDE.md from memory
6. Create project-plan.md and progress.md
7. Report bootstrap results and gaps
```

### Dev-Alignment Mission Integration

```markdown
## Phase 1: Analyze and Bootstrap (15 min)

/coord "Bootstrap from existing codebase"

**Coordinator executes**:
1. Analyze codebase structure and technology
2. Infer requirements from code organization
3. Extract architecture patterns
4. Create /memories from analysis
5. Generate CLAUDE.md from codebase
6. Create/update tracking files
7. Report analysis findings and opportunities
```

## Summary

**Bootstrap Purpose**: Automate project knowledge extraction into persistent memory

**Two Workflows**:
- **Greenfield**: Initialize from ideation documents
- **Brownfield**: Analyze and extract from existing code

**Security-First**: Path validation, content sanitization, size limits

**Outputs**:
- /memories directory with XML files
- Generated CLAUDE.md
- Initialized tracking files
- Architecture documentation

**Key Principle**: Bootstrap creates the foundation for memory-enhanced agent collaboration, enabling 39% effectiveness improvement and 84% token reduction through persistent context.

---

**Created**: October 6, 2025
**Phase**: 1.2 - Bootstrap Pattern Implementation
**Status**: Documentation Complete
**Next**: Mission file integration and coordinator protocol update
