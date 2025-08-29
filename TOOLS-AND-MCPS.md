# TOOLS-AND-MCPS.md - Available Capabilities Catalog

*Comprehensive guide to tools and MCP servers available in AGENT-11*

## MCP-First Principle

**Always check for MCP availability before manual implementation**

MCPs (Model Context Protocol servers) provide proven, efficient implementations for common tasks. Using MCPs reduces errors, saves time, and ensures consistency across projects.

### MCP Discovery Protocol

1. Check if an MCP exists for your task
2. Use the MCP if available
3. Fall back to manual implementation only if no MCP exists
4. Document MCP usage in project documentation

## Available MCP Servers

### Testing & Automation

#### mcp__playwright
**Purpose**: Complete browser automation and testing
**When to use**: ANY browser interaction, testing, or automation task
**Capabilities**:
- Browser navigation and interaction
- Screenshot capture and visual testing
- Form filling and file uploads
- Network request monitoring
- Cross-browser testing (Chrome, Firefox, Safari)
- Accessibility testing
- Performance monitoring

**Key Tools**:
- `mcp__playwright__browser_navigate` - Navigate to URLs
- `mcp__playwright__browser_click` - Click elements
- `mcp__playwright__browser_type` - Type text
- `mcp__playwright__browser_snapshot` - Capture page state
- `mcp__playwright__browser_take_screenshot` - Visual capture
- `mcp__playwright__browser_fill_form` - Form automation
- `mcp__playwright__browser_evaluate` - Execute JavaScript

**Example Usage**:
```python
# Navigate and test
mcp__playwright__browser_navigate(url="https://example.com")
mcp__playwright__browser_snapshot()  # Get page structure
mcp__playwright__browser_click(element="Login button", ref="button#login")
```

### Research & Documentation

#### mcp__context7
**Purpose**: Access up-to-date library documentation
**When to use**: Need documentation for any library or framework
**Capabilities**:
- Retrieve current documentation
- Find code examples and patterns
- Discover best practices
- Get API references

**Key Tools**:
- `mcp__context7__resolve-library-id` - Find library identifiers
- `mcp__context7__get-library-docs` - Retrieve documentation

**Example Usage**:
```python
# Get React documentation
mcp__context7__resolve-library-id(libraryName="react")
mcp__context7__get-library-docs(
    context7CompatibleLibraryID="/facebook/react",
    topic="hooks"
)
```

#### mcp__firecrawl
**Purpose**: Advanced web scraping and research
**When to use**: Need to extract information from websites
**Capabilities**:
- Single page scraping
- Batch scraping multiple URLs
- Site mapping and discovery
- Deep research with AI analysis
- Structured data extraction

**Key Tools**:
- `mcp__firecrawl__firecrawl_scrape` - Scrape single page
- `mcp__firecrawl__firecrawl_map` - Discover all URLs on site
- `mcp__firecrawl__firecrawl_search` - Search and scrape results
- `mcp__firecrawl__firecrawl_deep_research` - AI-powered research
- `mcp__firecrawl__firecrawl_extract` - Extract structured data

**Example Usage**:
```python
# Research competitor features
mcp__firecrawl__firecrawl_deep_research(
    query="SaaS pricing strategies for developer tools",
    maxDepth=3,
    maxUrls=50
)
```

### Version Control & Collaboration

#### mcp__github
**Purpose**: GitHub repository management
**When to use**: ANY GitHub operation
**Capabilities**:
- Repository creation and management
- File operations (create, update, push)
- Pull request management
- Issue tracking
- Branch operations
- Code search across GitHub

**Key Tools**:
- `mcp__github__create_repository` - Create new repos
- `mcp__github__push_files` - Push multiple files
- `mcp__github__create_pull_request` - Open PRs
- `mcp__github__create_issue` - Create issues
- `mcp__github__search_code` - Search all GitHub code
- `mcp__github__get_file_contents` - Read repository files

**Example Usage**:
```python
# Create PR with multiple files
mcp__github__push_files(
    owner="username",
    repo="project",
    branch="feature-branch",
    files=[
        {"path": "src/auth.js", "content": "..."},
        {"path": "tests/auth.test.js", "content": "..."}
    ],
    message="Add authentication system"
)
```

### IDE Integration

#### mcp__ide
**Purpose**: VS Code integration
**When to use**: Need IDE diagnostics or Jupyter execution
**Capabilities**:
- Get language diagnostics
- Execute code in Jupyter notebooks
- Access IDE state

**Key Tools**:
- `mcp__ide__getDiagnostics` - Get code diagnostics
- `mcp__ide__executeCode` - Run code in Jupyter

## Core Claude Code Tools

### File Operations

#### Read
**Purpose**: Read file contents
**When to use**: Need to view any file
**Features**:
- Read text and binary files
- View images (PNG, JPG, etc.)
- Read PDFs with text extraction
- Parse Jupyter notebooks
- Line number display

**Usage**:
```python
Read(file_path="/absolute/path/to/file.js", limit=100, offset=50)
```

#### Write
**Purpose**: Create new files
**When to use**: Creating new files (prefer Edit for existing files)
**Requirements**:
- Must use absolute paths
- Will overwrite existing files
- Must read file first if it exists

#### Edit
**Purpose**: Modify existing files
**When to use**: Making changes to existing files
**Requirements**:
- Must read file first
- Old string must be unique
- Preserve exact indentation

#### MultiEdit
**Purpose**: Multiple edits to one file
**When to use**: Making several changes to the same file
**Benefits**:
- More efficient than multiple Edit calls
- Atomic operations (all or nothing)
- Sequential application

### Search & Discovery

#### Grep
**Purpose**: Search file contents
**When to use**: Finding code patterns or text
**Features**:
- Full regex support
- File filtering by type or glob
- Context lines (-A, -B, -C)
- Multiple output modes

**Usage**:
```python
Grep(
    pattern="async function.*getData",
    glob="**/*.js",
    output_mode="content",
    -B=2,
    -A=2
)
```

#### Glob
**Purpose**: Find files by pattern
**When to use**: Locating files by name
**Features**:
- Standard glob patterns
- Sorted by modification time

**Usage**:
```python
Glob(pattern="src/**/*.test.js")
```

#### LS
**Purpose**: List directory contents
**When to use**: Exploring directory structure
**Requirements**:
- Must use absolute paths

### Execution & Automation

#### Bash
**Purpose**: Execute shell commands
**When to use**: Running commands, scripts, git operations
**Important**:
- Avoid find, grep commands (use Grep tool)
- Avoid cat, head, tail (use Read tool)
- Use for git operations
- Quote paths with spaces

**Usage**:
```python
Bash(
    command="npm run test",
    description="Run test suite",
    timeout=120000
)
```

#### Task
**Purpose**: Delegate work to specialist agents
**When to use**: ONLY in @coordinator for delegation
**Critical**:
- MANDATORY for all agent delegation
- Never use @agent syntax
- Provide detailed prompts

**Usage**:
```python
Task(
    subagent_type="developer",
    description="Build auth system",
    prompt="Implement JWT authentication with..."
)
```

### Documentation & Planning

#### TodoWrite
**Purpose**: Task tracking and planning
**When to use**: Managing complex multi-step tasks
**Features**:
- Status tracking (pending, in_progress, completed)
- Unique IDs for each task
- Real-time updates

#### NotebookEdit
**Purpose**: Modify Jupyter notebooks
**When to use**: Working with .ipynb files
**Features**:
- Cell-level editing
- Support for code and markdown cells
- Insert/delete operations

### Web Operations

#### WebSearch
**Purpose**: Search the web
**When to use**: Need current information
**Features**:
- Domain filtering
- US-based searches

#### WebFetch
**Purpose**: Fetch and analyze web content
**When to use**: Analyzing specific web pages
**Features**:
- HTML to markdown conversion
- AI-powered content analysis
- 15-minute cache

## Tool Selection Decision Tree

```
Need to interact with browser?
├─ YES → Use mcp__playwright
└─ NO → Continue

Need documentation for a library?
├─ YES → Use mcp__context7
└─ NO → Continue

Need to scrape/research web?
├─ YES → Use mcp__firecrawl
└─ NO → Continue

Working with GitHub?
├─ YES → Use mcp__github
└─ NO → Continue

Need to search code patterns?
├─ YES → Use Grep
└─ NO → Continue

Need to find files?
├─ YES → Use Glob
└─ NO → Continue

Need to edit existing file?
├─ YES → Use Edit/MultiEdit
└─ NO → Continue

Need to create new file?
├─ YES → Use Write
└─ NO → Continue

Need to run commands?
├─ YES → Use Bash
└─ NO → Continue
```

## MCP Integration Best Practices

### 1. Check Availability First
Before implementing any feature:
- Check if an MCP provides it
- Review MCP capabilities
- Use MCP if available

### 2. Document MCP Usage
In your project documentation:
- List MCPs used
- Document configuration
- Note any limitations

### 3. Fallback Strategies
When MCP unavailable:
- Document why MCP wasn't used
- Implement manual solution
- Consider requesting MCP addition

### 4. Performance Considerations

#### Fast Operations
- File operations (Read, Write, Edit)
- Local searches (Grep, Glob)
- MCP operations (usually optimized)

#### Slower Operations
- Web operations (WebSearch, WebFetch)
- Large file operations
- Complex Bash commands

### 5. Error Handling
- Always handle MCP failures gracefully
- Have fallback approaches ready
- Document errors in progress.md

## Common MCP Patterns

### Testing Pattern
```python
# 1. Navigate to application
mcp__playwright__browser_navigate(url="http://localhost:3000")

# 2. Perform actions
mcp__playwright__browser_click(element="Login", ref="#login-btn")
mcp__playwright__browser_type(element="Email", ref="#email", text="test@example.com")

# 3. Verify results
mcp__playwright__browser_snapshot()  # Check page state
mcp__playwright__browser_take_screenshot(filename="login-test.png")
```

### Research Pattern
```python
# 1. Search for information
results = mcp__firecrawl__firecrawl_search(
    query="best practices React performance",
    limit=5
)

# 2. Deep dive on specific topic
mcp__firecrawl__firecrawl_deep_research(
    query="React performance optimization techniques",
    maxDepth=3
)
```

### Documentation Pattern
```python
# 1. Resolve library
mcp__context7__resolve-library-id(libraryName="nextjs")

# 2. Get specific docs
mcp__context7__get-library-docs(
    context7CompatibleLibraryID="/vercel/next.js",
    topic="app router",
    tokens=15000
)
```

## Tool Usage Restrictions

### Never Use These Bash Commands
- `find` - Use Glob instead
- `grep` - Use Grep tool instead
- `cat`, `head`, `tail` - Use Read instead
- `ls` - Use LS tool instead

### Always Use Absolute Paths
- Read, Write, Edit tools require absolute paths
- LS requires absolute paths
- Bash commands should use absolute paths

### Respect Tool Limits
- Read: 2000 lines default limit
- Grep: Use head_limit for large results
- WebFetch: Results may be summarized if large
- Task: One in_progress task at a time

---

*This document catalogs all available tools and MCPs. Always consult before implementing features to ensure you're using the most efficient approach.*