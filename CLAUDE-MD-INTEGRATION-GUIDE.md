# CLAUDE.md Integration Guide

## Quick Reference: What Happens During Deployment

### If You Have NO CLAUDE.md

```bash
# Before deployment
your-project/
├── .git/
└── README.md

# After deployment
your-project/
├── CLAUDE.md                      # ← Created from template, ready to use
├── CLAUDE-AGENT11-TEMPLATE.md     # ← Reference copy
└── ... (agents, missions, etc.)
```

**Result**: Your project is ready to use immediately with full AGENT-11 capabilities.

### If You Have Existing CLAUDE.md

```bash
# Before deployment
your-project/
├── .git/
├── CLAUDE.md                      # Your custom instructions
└── README.md

# After deployment
your-project/
├── CLAUDE.md                      # ← Unchanged! Your custom instructions preserved
├── CLAUDE.md.backup-20251008_123456  # ← Safety backup
├── CLAUDE-AGENT11-TEMPLATE.md     # ← AGENT-11 capabilities to integrate
└── ... (agents, missions, etc.)
```

**Result**: Your custom instructions are safe. You decide what AGENT-11 features to add.

## Integration Options

### Option 1: Append Entire Template (Quick & Easy)

**When to use**: You want all AGENT-11 features and don't have conflicting instructions.

```bash
# Backup first (just in case)
cp CLAUDE.md CLAUDE.md.before-agent11

# Append AGENT-11 capabilities
cat CLAUDE-AGENT11-TEMPLATE.md >> CLAUDE.md

# Verify
cat CLAUDE.md
```

**Pros**:
- ✅ Quick (1 command)
- ✅ Get all features
- ✅ Easy to do

**Cons**:
- ⚠️ May have duplicate sections if you already have similar content
- ⚠️ File becomes longer

### Option 2: Selective Integration (Recommended)

**When to use**: You want specific AGENT-11 features without duplicating content.

```bash
# 1. Review what's new in the template
cat CLAUDE-AGENT11-TEMPLATE.md

# 2. Open your CLAUDE.md in editor
code CLAUDE.md  # or vim, nano, etc.

# 3. Copy relevant sections from template
# Example sections to consider:
# - Mission orchestration (/coord command)
# - Context preservation system
# - MCP integration guidelines
# - Agent delegation protocols
# - Critical Software Development Principles

# 4. Paste into appropriate locations in your CLAUDE.md
```

**Pros**:
- ✅ No duplicate content
- ✅ Full control over what's added
- ✅ Keeps file organized
- ✅ Custom integration to your needs

**Cons**:
- ⏱️ Takes more time
- 🤔 Requires reviewing template

### Option 3: Keep Separate (Minimal Changes)

**When to use**: You want to try AGENT-11 without modifying your existing setup.

```bash
# Reference AGENT-11 template when needed
cat CLAUDE-AGENT11-TEMPLATE.md

# Your CLAUDE.md stays unchanged
# Agents will use both files (Claude Code reads multiple .md files)
```

**Pros**:
- ✅ Zero risk - no changes to your file
- ✅ Can reference template when needed
- ✅ Easy to experiment

**Cons**:
- ⚠️ Some AGENT-11 features may not activate automatically
- ⚠️ Need to reference two files

## Recommended Integration Workflow

### Step 1: Review the Template

```bash
# See what AGENT-11 offers
less CLAUDE-AGENT11-TEMPLATE.md

# Focus on these key sections:
# - Mission orchestration
# - Context preservation
# - MCP integration
# - Agent collaboration protocols
```

### Step 2: Identify What You Want

**Essential AGENT-11 Features** (recommend integrating):

1. **Mission Orchestration** - `/coord` command system
   - Section: "Available Commands"
   - Why: Enables systematic multi-agent workflows

2. **Context Preservation** - Zero context loss
   - Section: "Context Preservation System"
   - Why: Agents remember everything across sessions

3. **Agent Delegation Protocols** - Proper coordination
   - Section: "Coordinator Delegation Protocol"
   - Why: Ensures agents work together correctly

4. **MCP Integration** - Supercharge your agents
   - Section: "MCP (Model Context Protocol) Integration"
   - Why: GitHub, web scraping, database access, etc.

**Optional Features** (integrate if relevant):

1. **Critical Software Development Principles** - Security-first approach
2. **Mission Documentation Standards** - Project tracking
3. **Design Review System** - UI/UX projects
4. **Ideation File Concept** - Product development
5. **Progress Tracking System** - Long-running projects

### Step 3: Integrate Selectively

```bash
# 1. Create backup
cp CLAUDE.md CLAUDE.md.before-integration

# 2. Open in editor
code CLAUDE.md

# 3. For each section you want:
#    a. Find it in CLAUDE-AGENT11-TEMPLATE.md
#    b. Copy the entire section (including heading)
#    c. Paste into your CLAUDE.md at appropriate location

# 4. Review for duplicates
#    - Search for duplicate headings
#    - Merge similar sections if needed

# 5. Save and test
```

### Step 4: Verify Integration

```bash
# 1. Check file looks good
cat CLAUDE.md | head -50

# 2. Restart Claude Code in your project
/exit
claude

# 3. Test AGENT-11 features
/coord           # Should show mission menu
@strategist      # Should have AGENT-11 capabilities

# 4. If issues, restore backup
cp CLAUDE.md.before-integration CLAUDE.md
```

## Key Sections to Integrate

### 1. Mission Orchestration (High Priority)

**What it is**: `/coord` command for systematic workflows

**From template**:
```markdown
## Available Commands

### Mission Orchestration
- `/coord [mission] [files]` - Orchestrate multi-agent missions
- `/design-review` - Comprehensive UI/UX audit
...
```

**Add to**: Near top of your CLAUDE.md, in a "Commands" or "Features" section

### 2. Context Preservation (High Priority)

**What it is**: Zero context loss system

**From template**:
```markdown
## Context Preservation System

### Overview
AGENT-11 implements a comprehensive context preservation system...
```

**Add to**: Architecture or System Design section

### 3. MCP Integration (Recommended)

**What it is**: Enhanced agent capabilities

**From template**:
```markdown
## MCP (Model Context Protocol) Integration

### MCP-First Principle
Agents should prioritize using available MCP servers...
```

**Add to**: Tools or Integration section

### 4. Agent Delegation (For /coord users)

**What it is**: Proper coordination protocols

**From template**:
```markdown
## Coordinator Delegation Protocol

### CRITICAL: Using /coord Command
...
```

**Add to**: Agent Collaboration section

## Common Integration Scenarios

### Scenario 1: Empty CLAUDE.md

**You have**: Basic project info only

**Recommendation**: Append entire template

```bash
cat CLAUDE-AGENT11-TEMPLATE.md >> CLAUDE.md
```

### Scenario 2: Detailed CLAUDE.md

**You have**: Extensive custom instructions

**Recommendation**: Selective integration

1. Add "Available Commands" section for `/coord`
2. Add "Context Preservation System"
3. Add "MCP Integration" if using MCPs
4. Review rest of template for useful sections

### Scenario 3: Conflicting Instructions

**You have**: Instructions that might conflict with AGENT-11

**Recommendation**: Keep separate, merge carefully

1. Keep files separate initially
2. Test AGENT-11 features
3. Gradually integrate non-conflicting sections
4. Resolve conflicts by choosing what works best

### Scenario 4: Multiple Projects

**You have**: Several projects, each with CLAUDE.md

**Recommendation**: Template approach per project

1. Each project gets its own integration
2. Some projects might use full template
3. Others might use selective integration
4. Tailor to each project's needs

## Troubleshooting

### Issue: Duplicate Sections After Integration

**Symptoms**: Same headings appear twice

**Solution**:
```bash
# Search for duplicates
grep "^##" CLAUDE.md | sort | uniq -d

# Manually merge duplicate sections
# Keep the version with most relevant content for your project
```

### Issue: AGENT-11 Features Not Working

**Symptoms**: `/coord` not found, agents don't have capabilities

**Solution**:
```bash
# Verify agents installed
ls .claude/agents/

# Verify commands installed
ls .claude/commands/

# Restart Claude Code
/exit
claude

# Check template integrated
grep "coord" CLAUDE.md
```

### Issue: File Too Large

**Symptoms**: CLAUDE.md becomes very long

**Solution**:
1. Use selective integration (Option 2)
2. Remove sections not relevant to your project
3. Keep template separate for reference

### Issue: Lost Custom Instructions

**Symptoms**: Your original content missing

**Solution**:
```bash
# Restore from backup
cp CLAUDE.md.backup-[timestamp] CLAUDE.md

# Or from your before-integration backup
cp CLAUDE.md.before-integration CLAUDE.md

# Then try again with more careful integration
```

## Best Practices

### ✅ Do

1. **Backup before integrating** - Always create `CLAUDE.md.before-integration`
2. **Review template first** - Understand what each section does
3. **Integrate incrementally** - Add sections one at a time, test
4. **Test after changes** - Verify features work as expected
5. **Keep backups** - Timestamped versions help track changes

### ❌ Don't

1. **Don't blindly append** - Review what you're adding
2. **Don't delete backups** - Keep for rollback capability
3. **Don't skip testing** - Always verify after integration
4. **Don't integrate everything** - Only add what's useful for your project
5. **Don't ignore conflicts** - Resolve competing instructions

## Getting Help

### Resources

- **Template**: `CLAUDE-AGENT11-TEMPLATE.md` - Full AGENT-11 capabilities
- **Your backup**: `CLAUDE.md.backup-[timestamp]` - Your original
- **This guide**: `CLAUDE-MD-INTEGRATION-GUIDE.md` - Integration help
- **Safety docs**: `CLAUDE-MD-SAFETY.md` - Technical details

### Support

```bash
# Use AGENT-11 support agent
@support I need help integrating AGENT-11 features into my CLAUDE.md

# Or consult documentation
cat CLAUDE-MD-INTEGRATION-GUIDE.md
```

---

**Remember**: Your CLAUDE.md is **never overwritten** by AGENT-11. You have complete control over what gets integrated and when.
