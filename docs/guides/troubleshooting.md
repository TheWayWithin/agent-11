# Troubleshooting Guide

[← Back to Main README](../../README.md)

**Related Guides**: [Essential Setup](essential-setup.md) | [Common Workflows](common-workflows.md) | [Mission Architecture](mission-architecture.md)

## Overview

This guide helps you diagnose and resolve common issues when working with AGENT-11. Most problems fall into predictable categories with known solutions. Before filing a GitHub issue, check this guide - you'll likely find your answer here.

**When to Use This Guide**:
- Installation or setup failures
- Agents not appearing or responding incorrectly
- File operations that don't persist
- Mission execution problems
- MCP integration issues
- Context loss between agent handoffs

**Diagnostic Workflow**:
1. Identify the symptom (what's not working?)
2. Find the relevant section below
3. Run diagnostic commands to confirm issue
4. Apply solution steps in order
5. Verify fix worked
6. Document in progress.md if part of active mission

---

## Installation & Setup Issues

### Agents Not Appearing After Installation

**Symptom**: Typed `@strategist` but agent doesn't autocomplete or respond.

**Diagnosis**:
```bash
# Check if agents were installed
ls -la ~/.claude/agents/

# Should see: coordinator.md, developer.md, strategist.md, etc.
# If empty or missing files, installation failed
```

**Solution**:
```bash
# Re-run installation script
cd /path/to/agent-11
bash project/deployment/scripts/install.sh

# Restart Claude Code completely
# (Quit application, not just close window)

# Verify installation
ls -la ~/.claude/agents/ | grep -E '(coordinator|developer|strategist)'
```

**Prevention**:
- Always restart Claude Code after running install.sh
- Check console for installation errors
- Ensure you have write permissions to `~/.claude/` directory

### MCP Servers Not Connecting

**Symptom**: Commands like `mcp__github` don't work, or tools starting with `mcp__` don't appear.

**Diagnosis**:
```bash
# Check if .mcp.json exists in project root
ls -la .mcp.json

# Check if environment file exists
ls -la .env.mcp

# Look for MCP-related errors in Claude Code console
# Tools > Developer Tools > Console tab
```

**Solution**:
```bash
# 1. Create environment file if missing
cp .env.mcp.template .env.mcp

# 2. Add your API keys to .env.mcp
# Edit with your preferred editor:
nano .env.mcp  # or code .env.mcp

# Required keys:
# - GITHUB_TOKEN (for mcp__github)
# - CONTEXT7_API_KEY (for mcp__context7)
# - FIRECRAWL_API_KEY (for mcp__firecrawl)

# 3. Verify .mcp.json structure
cat .mcp.json | grep -A 5 "mcpServers"

# 4. Restart Claude Code completely

# 5. Test MCP connection
# In Claude Code, try: grep "mcp__" to list available MCP tools
```

**Common Causes**:
- Missing or invalid API keys in `.env.mcp`
- `.mcp.json` malformed (check JSON syntax)
- Environment variables not loaded (restart required)
- MCP server itself is down (check service status)

**Prevention**:
- Keep `.env.mcp` in `.gitignore` (never commit secrets)
- Use `.env.mcp.template` as reference for required keys
- Verify MCP setup before starting missions: `./project/deployment/scripts/mcp-setup.sh --verify`

### Permission Denied Errors During Installation

**Symptom**: `install.sh` fails with "Permission denied" errors.

**Diagnosis**:
```bash
# Check script permissions
ls -l project/deployment/scripts/install.sh

# Should show: -rwxr-xr-x (executable)
# If shows: -rw-r--r-- (not executable), that's the problem
```

**Solution**:
```bash
# Make script executable
chmod +x project/deployment/scripts/install.sh

# Run installation again
bash project/deployment/scripts/install.sh
```

**Alternative (if chmod fails)**:
```bash
# Run with bash explicitly
bash project/deployment/scripts/install.sh

# Or copy files manually:
mkdir -p ~/.claude/agents
cp project/agents/specialists/*.md ~/.claude/agents/
```

---

## Mission Execution Issues

### Coordinator Not Delegating to Specialists

**Symptom**: Typed `/coord build requirements.md` but coordinator just describes what it would do instead of actually delegating.

**Diagnosis**:
```bash
# Check coordinator agent file
grep -n "Task tool" ~/.claude/agents/coordinator.md

# Should see references to Task() function usage
# If missing, coordinator profile may be outdated
```

**Root Cause**: Coordinator is writing "Delegating to @developer" as text instead of calling `Task(subagent_type="developer", ...)` function.

**Solution**:
```bash
# Update coordinator to latest version
cp project/agents/specialists/coordinator.md ~/.claude/agents/

# Restart Claude Code

# Verify by checking coordinator response
# Look for actual Task tool usage: "Using Task tool with subagent_type='developer'"
# Not just text: "I'm delegating to @developer"
```

**How to Verify Fix**:
1. Start simple mission: `/coord fix simple-task.md`
2. Watch for "Using Task tool" messages in output
3. Specialist should actually respond (not coordinator simulating)
4. Check progress.md - should have real specialist findings

**Prevention**:
- Keep coordinator updated with latest profile
- Monitor early mission responses for actual Task tool usage
- See [Mission Architecture](mission-architecture.md) for proper delegation patterns

### Files Created by Agents Don't Persist

**Symptom**: Agent reports "Files created successfully" and you see `ls` output showing files, but after completion, files don't actually exist on filesystem.

**Diagnosis**:
```bash
# After agent claims file creation, immediately verify:
ls -lh /absolute/path/to/reported/file.ts

# If "No such file or directory": File persistence issue confirmed
# If file exists but empty (0 bytes): Partial write issue
# If file exists with content: No issue (false alarm)
```

**Root Cause**: Critical architectural limitation - files created by delegated agents via Task tool don't persist to host filesystem. This is documented in CLAUDE.md under "FILE PERSISTENCE ARCHITECTURE".

**Solution (Sprint 2 - Structured Output Pattern)**:

**Preferred Approach**: Use structured JSON output from specialists:
```bash
# Coordinator delegates with JSON request:
Task(
  subagent_type="developer",
  prompt="Create auth components. Return JSON with file_operations array.
  Format:
  {
    'file_operations': [
      {
        'operation': 'create',
        'file_path': '/absolute/path/to/file.ts',
        'content': 'complete file content here',
        'description': 'what this file does'
      }
    ]
  }"
)

# Coordinator parses JSON and executes Write tool itself
# Coordinator verifies with ls/head commands
```

**Legacy Approach (Sprint 1 - Manual Verification)**:
```bash
# After ANY file creation delegation:

# 1. Verify immediately
ls -lh /path/to/file1.ts /path/to/file2.ts

# 2. If missing, extract from agent response and create manually
# Look for file content in agent's response text
# Use Write tool directly as coordinator

# 3. Verify again
ls -lh /path/to/file1.ts
head -n 5 /path/to/file1.ts  # Check content exists

# 4. Document in progress.md
echo "✅ Files verified on filesystem: $(date)" >> progress.md
```

**Complete Example**:
```bash
# Coordinator receives developer response with file content
# Developer provided: "Here's the auth.ts file: [content]"

# Coordinator must:
1. Extract the content from response
2. Use Write tool directly:
   Write(
     file_path="/Users/jamie/myproject/src/auth.ts",
     content="[extracted content]"
   )
3. Verify creation:
   ls -lh /Users/jamie/myproject/src/auth.ts
4. Check content:
   head -n 10 /Users/jamie/myproject/src/auth.ts
5. Update progress.md with verification timestamp
6. Mark task complete [x] in project-plan.md
```

**Prevention**:
- **NEVER** mark file creation tasks [x] without filesystem verification
- Use structured output pattern (Sprint 2) for all new missions
- Include verification commands in coordinator checklist
- Document verification timestamp in progress.md
- See full details: `/project/field-manual/migration-guides/file-persistence-v2.md`

### Mission Stuck or Not Progressing

**Symptom**: Started mission, got initial response, but then nothing happens.

**Diagnosis**:
```bash
# Check project-plan.md for stuck tasks
grep -A 2 "\[ \]" project-plan.md | head -20

# Check progress.md for last activity
tail -20 progress.md

# Look for uncompleted delegations in last coordinator response
```

**Common Causes**:
1. **Waiting for User Input**: Coordinator asked a question and is waiting for response
2. **Missing Context**: Handoff notes not updated, next agent lacks information
3. **Verification Pending**: Files created but not verified, task stuck at verification step
4. **Error Not Handled**: Specialist encountered error but didn't escalate to coordinator

**Solution**:
```bash
# If waiting for input:
# Answer the coordinator's question and explicitly say "continue"

# If missing context:
# Check handoff-notes.md - is next task clearly defined?
cat handoff-notes.md
# If unclear, ask coordinator: "What's the next step? Provide clear delegation."

# If verification pending:
# Run verification commands manually and report results
ls -lh /path/to/expected/files/

# If error not handled:
# Check logs for error messages
# Manually escalate: "@coordinator - [specialist] encountered error: [details]"
```

**Recovery**:
```bash
# Resume mission from last known good state:
1. Read project-plan.md to find last completed [x] task
2. Read progress.md to understand what was accomplished
3. Read handoff-notes.md to see what was supposed to happen next
4. Ask coordinator explicitly:
   "/coord continue from [last completed phase] - next task is [specific task]"
```

---

## Agent Delegation Problems

### Wrong Agent Responding to Task

**Symptom**: Asked `@developer` to implement feature but `@strategist` responded instead.

**Diagnosis**:
```bash
# Check if you typed agent name correctly
# Common typos: @develop, @strategy, @test (missing 'er')

# Verify agent exists
ls ~/.claude/agents/ | grep developer
```

**Solution**:
- Use exact agent names: `@developer` not `@develop`
- Use tab completion - type `@dev` then Tab key
- If agent still wrong, reinstall agents: `bash project/deployment/scripts/install.sh`

### Agent Doesn't Have Expected Capabilities

**Symptom**: Asked `@developer` to deploy to production but agent says "that's @operator's job".

**Diagnosis**: You asked the right agent, but the task is outside their scope.

**Solution**: Check scope boundaries in agent profiles:
```bash
# View developer scope
grep -A 20 "SCOPE BOUNDARIES" ~/.claude/agents/developer.md

# Developer can: implement features, write code, debug
# Developer cannot: deploy to production, configure infrastructure

# For deployment, use:
@operator Deploy the authentication service to production
```

**Agent Specializations**:
- **@strategist**: Product requirements, user stories, roadmaps
- **@architect**: System design, technical architecture, ADRs
- **@developer**: Code implementation, debugging, feature building
- **@designer**: UI/UX design, user flows, design systems
- **@tester**: Test creation, QA, test automation
- **@documenter**: Technical writing, API docs, user guides
- **@operator**: Deployment, DevOps, infrastructure, monitoring
- **@analyst**: Data analysis, metrics, business insights
- **@marketer**: GTM strategy, content, growth campaigns
- **@support**: Customer success, knowledge base, troubleshooting
- **@coordinator**: Mission orchestration, multi-agent workflows

### Agent Responses Are Generic or Low Quality

**Symptom**: Agent gives surface-level answers instead of deep technical solutions.

**Diagnosis**: Agent may lack context about your project.

**Solution**:
```bash
# Provide better context in your request:

# ❌ Generic request:
@developer Implement authentication

# ✅ Context-rich request:
@developer Implement JWT authentication for our Express API:
- User login with email/password
- Token expiry: 24 hours
- Refresh token support
- Integration with existing Postgres user table
- Follow security best practices from architecture.md
Project context: Read ideation.md for requirements

# Include relevant files:
@developer Fix the authentication bug
Relevant files:
- src/auth/login.ts (broken validation)
- Error log attached in handoff-notes.md
- Expected behavior described in PRD.md section 3.2
```

**Best Practices**:
- Reference project files (ideation.md, architecture.md, PRD.md)
- Include error messages and logs
- Specify constraints and requirements
- Link to relevant previous work
- Use extended thinking when needed: "Think hard about implementing distributed caching"

---

## Context Loss & Handoff Problems

### Next Agent Doesn't Know What Previous Agent Did

**Symptom**: Developer implements feature, but tester asks "what feature should I test?" 

**Diagnosis**: Context preservation broke - handoff-notes.md not updated or not read.

**Solution**:
```bash
# Check if context files exist
ls -lh agent-context.md handoff-notes.md

# If missing, create from templates:
cp /path/to/agent-11/templates/agent-context-template.md ./agent-context.md
cp /path/to/agent-11/templates/handoff-notes-template.md ./handoff-notes.md

# Manually update handoff notes with critical info:
nano handoff-notes.md

# Add:
## What Was Just Completed
- Developer implemented JWT authentication
- Files created: src/auth/jwt.ts, src/middleware/auth.ts
- Ready for testing

## What's Next
- Test authentication flow
- Verify token expiry works correctly
- Check error handling for invalid credentials

# Then continue mission
@coordinator Continue with testing phase
```

**Prevention (Coordinator Responsibility)**:
```bash
# Coordinator MUST include in every delegation:
Task(
  subagent_type="developer",
  prompt="
    FIRST: Read agent-context.md and handoff-notes.md for mission context.
    
    [Task details...]
    
    AFTER COMPLETION: Update handoff-notes.md with:
    - What you implemented
    - Files created/modified
    - Decisions made
    - What the next specialist needs to know
  "
)
```

**Manual Recovery**:
If context already lost:
1. Read progress.md to reconstruct what happened
2. Update agent-context.md with accumulated findings
3. Update handoff-notes.md with immediate next steps
4. Have coordinator verify context files before continuing

### Progress.md and Project-Plan.md Out of Sync

**Symptom**: project-plan.md shows tasks [x] complete but progress.md doesn't mention them, or vice versa.

**Diagnosis**: Files weren't updated together - one fell behind.

**Solution**:
```bash
# Reconcile the files:

# 1. Read both files
cat project-plan.md | grep "\[x\]" > completed-tasks.txt
cat progress.md | grep "###" > progress-entries.txt

# 2. Find discrepancies
# Tasks marked [x] in plan but no progress entry?
# Progress entries for incomplete [ ] tasks?

# 3. Update to match reality:
# If work was done: Mark [x] in plan, add to progress.md
# If work wasn't done: Unmark [ ] in plan, note in progress.md why

# 4. Add reconciliation note to progress.md:
### [2025-01-19 14:30] Manual Reconciliation
**What Happened**: Found project-plan and progress out of sync
**Resolution**: 
- Verified filesystem for completed work
- Updated both files to match actual state
- Tasks A, B, C confirmed complete [x]
- Task D marked incomplete [ ] - files don't exist
**Prevention**: Coordinator must update both files after each phase
```

**Prevention**:
- Coordinator updates project-plan.md immediately when specialist confirms completion
- Specialist updates progress.md after completing work
- Verification required before marking [x]
- See [Progress Tracking Guide](progress-tracking.md) for detailed protocol

---

## Performance & Timeout Issues

### Agent Takes Forever to Respond

**Symptom**: Asked agent a question 5 minutes ago, still waiting.

**Diagnosis**:
```bash
# Check if agent is in extended thinking mode
# Look for "thinking..." indicator in Claude Code

# Check if request was too complex
# Examples that trigger long processing:
# - "Think hard about entire system architecture"
# - "Analyze all code in repository"
# - Large file operations (100+ files)
```

**Solution**:
```bash
# If genuinely stuck:
# 1. Cancel request (Esc key or Stop button)
# 2. Break into smaller requests:

# ❌ Too large:
@developer Refactor entire codebase for TypeScript strict mode

# ✅ Manageable chunks:
@developer Refactor authentication module to TypeScript strict mode
# Then repeat for other modules

# For analysis tasks, provide scope:
@analyst Analyze user engagement metrics from last 30 days
# Not: "Analyze all our data"
```

**Extended Thinking Modes**:
- **No extended thinking**: Simple tasks (updates, small edits)
- **"think"**: Standard mode (documentation, feature implementation)
- **"think hard"**: Complex tasks (architecture, system design)

Use appropriate mode for task complexity. See agent profiles for mode guidance.

### Claude Code Freezes or Crashes

**Symptom**: Application becomes unresponsive during mission execution.

**Diagnosis**:
- Usually caused by memory exhaustion
- Check Activity Monitor (Mac) or Task Manager (Windows)
- Claude Code using >4GB RAM indicates problem

**Solution**:
```bash
# 1. Force quit and restart Claude Code
# Mac: Cmd+Q or Activity Monitor > Force Quit
# Windows: Task Manager > End Task

# 2. Clear context before resuming:
# When Claude Code restarts, use /clear command
# This removes old conversation context

# 3. Resume from last known good state:
# Read project-plan.md and progress.md
# Ask coordinator to continue from last completed phase

# 4. For large operations, use context editing:
# Move important details to memory before clearing:
@coordinator Save architecture decisions to memory before continuing
# Then /clear and resume
```

**Prevention**:
- Use `/clear` periodically during long missions
- Preserve critical info in memory before clearing
- Break large tasks into smaller phases
- See [Context Editing Guide](../field-manual/context-editing-guide.md)

---

## Getting Help

### When to File a GitHub Issue

File issue if:
- ✅ You've tried solutions in this guide
- ✅ Problem is reproducible
- ✅ Appears to be AGENT-11 framework bug
- ✅ Affects multiple users (check existing issues first)

Don't file if:
- ❌ Haven't checked this troubleshooting guide
- ❌ Issue is with your project code, not AGENT-11
- ❌ Problem is covered in documentation
- ❌ Question about how to use (ask in Discussions instead)

### What to Include in Issue Report

**Minimum Information**:
```markdown
## Bug Description
[Clear description of what's not working]

## Steps to Reproduce
1. Started mission with: /coord build requirements.md
2. Coordinator delegated to @developer
3. Developer reported file creation but files don't exist

## Expected Behavior
Files should persist to filesystem after agent completion

## Actual Behavior
Agent shows ls output with files, but 0 files exist after

## Environment
- AGENT-11 version: [check git commit or release]
- Claude Code version: [Help > About]
- Operating System: macOS 14.0 / Windows 11 / Linux Ubuntu 22.04
- Node version (if relevant): node --version

## Diagnostic Output
[Paste relevant commands and output]

```bash
# Commands run:
ls -la /path/to/expected/files/
grep "file creation" progress.md

# Output:
[paste actual output]
```

## Already Tried
- [x] Checked troubleshooting guide
- [x] Verified agent installation
- [x] Restarted Claude Code
- [ ] Other solutions from guide

## Additional Context
[Screenshots, error logs, relevant file contents]
```

### Community Support

**GitHub Discussions**: https://github.com/your-repo/agent-11/discussions
- Ask questions
- Share workflows
- Request features
- Help other users

**Documentation**: Start here first
- [Essential Setup](essential-setup.md)
- [Common Workflows](common-workflows.md)
- [Mission Architecture](mission-architecture.md)
- [Progress Tracking](progress-tracking.md)

---

## Quick Reference: Common Error Messages

### "Agent not found"
**Cause**: Agent not installed or name misspelled
**Fix**: `bash project/deployment/scripts/install.sh` + restart Claude Code

### "Permission denied"
**Cause**: Missing file permissions
**Fix**: `chmod +x script.sh` or use `bash script.sh`

### "MCP server not responding"
**Cause**: Missing API keys or .mcp.json misconfigured
**Fix**: Check `.env.mcp` has valid keys, verify `.mcp.json` syntax, restart Claude Code

### "File not found: handoff-notes.md"
**Cause**: Context files not created
**Fix**: Copy from templates: `cp /templates/handoff-notes-template.md ./handoff-notes.md`

### "Task tool invocation failed"
**Cause**: Coordinator delegation syntax error
**Fix**: Update coordinator to latest: `cp project/agents/specialists/coordinator.md ~/.claude/agents/`

### "Context limit exceeded"
**Cause**: Conversation too long
**Fix**: Use `/clear` command, preserve critical info to memory first

### "Files created but don't exist"
**Cause**: File persistence limitation (see section above)
**Fix**: Use structured output pattern, coordinator verifies with ls before marking complete

---

## Troubleshooting Checklist

Before asking for help, verify:

**Installation**:
- [ ] Ran install.sh successfully
- [ ] Restarted Claude Code after installation
- [ ] Can see agents with `ls ~/.claude/agents/`
- [ ] Agent autocomplete works (type `@dev` + Tab)

**MCP Setup** (if using):
- [ ] Created `.env.mcp` from template
- [ ] Added valid API keys
- [ ] `.mcp.json` exists in project root
- [ ] Restarted Claude Code after MCP config

**Mission Execution**:
- [ ] Created project-plan.md and progress.md
- [ ] Created agent-context.md and handoff-notes.md
- [ ] Coordinator using Task tool (not just describing)
- [ ] Files verified on filesystem after creation
- [ ] Context files updated after each phase

**Recovery**:
- [ ] Read this troubleshooting guide first
- [ ] Tried suggested solutions
- [ ] Checked existing GitHub issues
- [ ] Can reproduce the problem
- [ ] Have diagnostic output ready

---

**Last Updated**: 2025-01-19  
**Related Guides**: [Essential Setup](essential-setup.md) | [Common Workflows](common-workflows.md) | [Mission Architecture](mission-architecture.md) | [Progress Tracking](progress-tracking.md)

[← Back to Main README](../../README.md)
