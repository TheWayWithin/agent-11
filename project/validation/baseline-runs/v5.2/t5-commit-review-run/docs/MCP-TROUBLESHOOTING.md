# MCP Troubleshooting Guide

Common issues and solutions for AGENT-11 MCP profile system.

## Quick Diagnostics

### Check Active Profile

```bash
ls -l .mcp.json
```

Expected output:
```
.mcp.json -> .mcp-profiles/core.json
```

### Verify Profile Files Exist

```bash
ls -la .mcp-profiles/
```

Expected output:
```
total 56
drwxr-xr-x  9 user  staff   288 Oct 21 10:00 .
drwxr-xr-x 25 user  staff   800 Oct 21 10:00 ..
-rw-r--r--  1 user  staff   499 Oct 21 10:00 core.json
-rw-r--r--  1 user  staff   750 Oct 21 10:00 database-production.json
-rw-r--r--  1 user  staff   718 Oct 21 10:00 database-staging.json
-rw-r--r--  1 user  staff   834 Oct 21 10:00 deployment.json
-rw-r--r--  1 user  staff  1295 Oct 21 10:00 fullstack.json
-rw-r--r--  1 user  staff   653 Oct 21 10:00 payments.json
-rw-r--r--  1 user  staff   591 Oct 21 10:00 testing.json
```

### Check Environment Variables

```bash
cat .env.mcp | grep -v "^#" | grep -v "^$"
```

**Security Warning:** Don't share this output publicly!

### Verify MCP Servers Installed

```bash
./project/deployment/scripts/mcp-setup.sh --verify
```

---

## Common Issues

## Issue 1: Profile Switch Not Taking Effect

**Symptoms:**
- Switched profiles but MCPs haven't changed
- Agent still using wrong MCPs
- Tools from previous profile still available

**Root Cause:**
Claude Code loads MCP configuration at startup. Switching profiles updates the symlink, but Claude Code doesn't reload until restarted.

**Solution:**

```bash
# 1. Switch profile
ln -sf .mcp-profiles/testing.json .mcp.json

# 2. Restart Claude Code (CRITICAL STEP)
# Exit Claude Code completely
# Restart Claude Code

# 3. Verify the switch
ls -l .mcp.json
```

**Prevention:**
Always restart Claude Code after switching profiles. Add this to your workflow:
```bash
# Create an alias in ~/.bashrc or ~/.zshrc
alias mcp-switch='ln -sf .mcp-profiles/$1.json .mcp.json && echo "Switched to $1 profile. RESTART Claude Code!"'

# Usage
mcp-switch testing
```

---

## Issue 2: MCP Server Not Found

**Symptoms:**
```
Error: MCP server '@context7/mcp-server' not found
Error: Cannot find module '@playwright/mcp'
```

**Root Cause:**
MCP servers not installed locally.

**Solution:**

```bash
# Install all MCP servers
./project/deployment/scripts/mcp-setup.sh

# Or install specific server
npx @context7/mcp-server  # Will install on first run
npx @playwright/mcp@latest
npx @supabase/mcp-server
npx @stripe/mcp-server
npx @netlify/mcp
npx @railway/mcp-server
```

**Verify Installation:**

```bash
./project/deployment/scripts/mcp-setup.sh --verify
```

**Prevention:**
Run setup script as part of initial AGENT-11 installation:
```bash
# After cloning AGENT-11
./project/deployment/scripts/install.sh
./project/deployment/scripts/mcp-setup.sh
```

---

## Issue 3: Environment Variables Not Loading

**Symptoms:**
```
Error: Missing CONTEXT7_API_KEY
Error: GITHUB_PERSONAL_ACCESS_TOKEN not found
Authentication failed
```

**Root Cause:**
- `.env.mcp` file doesn't exist
- Variables incorrectly formatted
- Variables not exported

**Solution:**

### Step 1: Check File Exists

```bash
ls -la .env.mcp
```

If not found:
```bash
cp .env.mcp.template .env.mcp
```

### Step 2: Verify Format

Open `.env.mcp` and check format:

**Correct Format:**
```bash
CONTEXT7_API_KEY=your_key_here
GITHUB_PERSONAL_ACCESS_TOKEN=ghp_your_token
```

**Incorrect Formats:**
```bash
# ❌ Spaces around equals
CONTEXT7_API_KEY = your_key_here

# ❌ Quotes (unless value contains spaces)
CONTEXT7_API_KEY="your_key_here"

# ❌ Export statement
export CONTEXT7_API_KEY=your_key_here

# ❌ Missing value
CONTEXT7_API_KEY=
```

### Step 3: Verify Variables Load

```bash
# Check file contents (don't share output!)
cat .env.mcp

# Verify no syntax errors
source .env.mcp && echo "Loaded successfully" || echo "Syntax error"
```

### Step 4: Restart Claude Code

After fixing `.env.mcp`, restart Claude Code to reload variables.

**Prevention:**
Use the template and follow the format exactly:
```bash
cp .env.mcp.template .env.mcp
# Edit with your actual values, keeping the same format
```

---

## Issue 4: Production Database Write Blocked

**Symptoms:**
```
Error: Operation not permitted
Error: Database is read-only
INSERT operation failed on production database
```

**Root Cause:**
This is EXPECTED and INTENTIONAL. The `database-production.json` profile has `--read-only` flag for safety.

**Solution:**

### For Read-Only Queries (Correct Usage)

Production profile works correctly for SELECT queries:
```bash
# This is the correct usage
ln -sf .mcp-profiles/database-production.json .mcp.json
# Restart Claude Code

@analyst Generate report on user signups last month
# Works perfectly - read-only queries allowed
```

### For Write Operations (Switch to Staging)

If you need to test writes, use staging database:
```bash
# Switch to staging (read/write)
ln -sf .mcp-profiles/database-staging.json .mcp.json
# Restart Claude Code

@developer Test the user creation flow
# Works - staging has full read/write access
```

### For Production Changes (Manual Process)

Production changes should follow standard deployment process:
1. Develop on staging with `database-staging.json`
2. Test thoroughly on staging
3. Create migration scripts
4. Deploy through proper channels (not through MCP)

**This is NOT a bug - it's a safety feature!**

**Prevention:**
Understand the profile purpose:
- `database-production.json` → Read-only queries, reporting, analysis
- `database-staging.json` → Development, testing, migrations

---

## Issue 5: Symlink Not Working

**Symptoms:**
- `.mcp.json` is a regular file, not a symlink
- `ls -l .mcp.json` doesn't show `->`
- Profile switches don't work

**Root Cause:**
`.mcp.json` was created as a regular file instead of a symlink.

**Solution:**

```bash
# 1. Remove the regular file
rm .mcp.json

# 2. Create proper symlink
ln -sf .mcp-profiles/core.json .mcp.json

# 3. Verify it's a symlink
ls -l .mcp.json
# Should show: .mcp.json -> .mcp-profiles/core.json
```

**Troubleshooting Symlinks:**

```bash
# Check if it's a symlink
file .mcp.json
# Should say: symbolic link to .mcp-profiles/core.json

# Check symlink target
readlink .mcp.json
# Should show: .mcp-profiles/core.json
```

**Prevention:**
Always use `ln -sf` (not `cp` or `cat`) when switching profiles:
```bash
# ✅ Correct
ln -sf .mcp-profiles/testing.json .mcp.json

# ❌ Wrong (creates regular file)
cp .mcp-profiles/testing.json .mcp.json
```

---

## Issue 6: Unknown Profile Error

**Symptoms:**
```
ln: .mcp-profiles/custom.json: No such file or directory
Profile 'custom' not found
```

**Root Cause:**
Trying to use a profile that doesn't exist.

**Solution:**

### List Available Profiles

```bash
ls -1 .mcp-profiles/*.json | xargs -n1 basename | sed 's/.json//'
```

Output:
```
core
database-production
database-staging
deployment
fullstack
payments
testing
```

### Use Standard Profile

```bash
# Choose from the 7 standard profiles
ln -sf .mcp-profiles/core.json .mcp.json
ln -sf .mcp-profiles/testing.json .mcp.json
ln -sf .mcp-profiles/database-staging.json .mcp.json
ln -sf .mcp-profiles/database-production.json .mcp.json
ln -sf .mcp-profiles/payments.json .mcp.json
ln -sf .mcp-profiles/deployment.json .mcp.json
ln -sf .mcp-profiles/fullstack.json .mcp.json
```

### Create Custom Profile (Advanced)

If you need a custom combination:
```bash
# Copy existing profile
cp .mcp-profiles/core.json .mcp-profiles/custom.json

# Edit to add/remove MCPs
nano .mcp-profiles/custom.json

# Use it
ln -sf .mcp-profiles/custom.json .mcp.json
```

**Prevention:**
Stick to the 7 standard profiles unless you have specific needs for custom combinations.

---

## Issue 7: JSON Syntax Error

**Symptoms:**
```
Error: Invalid JSON in .mcp.json
SyntaxError: Unexpected token } in JSON
MCP configuration failed to load
```

**Root Cause:**
Profile JSON file has syntax error (missing comma, extra bracket, etc.)

**Solution:**

### Step 1: Identify Problem Profile

```bash
# Check which profile is active
readlink .mcp.json
```

### Step 2: Validate JSON

```bash
# Validate the JSON syntax
cat .mcp-profiles/core.json | python -m json.tool
# Or use jq
jq empty .mcp-profiles/core.json && echo "Valid JSON" || echo "Invalid JSON"
```

### Step 3: Fix Common Issues

**Missing Comma:**
```json
// ❌ Wrong
{
  "mcpServers": {
    "context7": { /* config */ }
    "github": { /* config */ }
  }
}

// ✅ Correct
{
  "mcpServers": {
    "context7": { /* config */ },
    "github": { /* config */ }
  }
}
```

**Trailing Comma:**
```json
// ❌ Wrong (in most JSON parsers)
{
  "mcpServers": {
    "context7": { /* config */ },
  }
}

// ✅ Correct
{
  "mcpServers": {
    "context7": { /* config */ }
  }
}
```

### Step 4: Restore from Template

If you can't fix it, restore from the original:
```bash
# Check git for original version
git checkout .mcp-profiles/core.json

# Or reinstall
./project/deployment/scripts/mcp-setup.sh
```

**Prevention:**
- Use a JSON validator before saving changes
- Don't hand-edit profile files unless necessary
- Keep backups of working configurations

---

## Issue 8: Agent Doesn't Recognize Profile

**Symptoms:**
- Agent doesn't mention profile requirement
- Agent doesn't verify profile before operations
- Agent uses wrong tools

**Root Cause:**
You're using working agents (`.claude/agents/`) instead of library agents (`project/agents/specialists/`).

**Solution:**

### Check Agent Source

```bash
# List agents in use
ls -la .claude/agents/

# These should be symlinks to library agents
# or library agents should have MCP awareness
```

### Verify Library Agents Updated

The following library agents should have MCP awareness:
- `project/agents/specialists/coordinator.md`
- `project/agents/specialists/tester.md`
- `project/agents/specialists/developer.md`
- `project/agents/specialists/operator.md`

### Check Agent Content

```bash
# Search for MCP Profile mentions
grep -l "MCP PROFILE" project/agents/specialists/*.md
```

Should show:
```
project/agents/specialists/coordinator.md
project/agents/specialists/developer.md
project/agents/specialists/operator.md
project/agents/specialists/tester.md
```

**Prevention:**
Ensure you're using the latest library agents with Phase 2 updates completed.

---

## Issue 9: Context Limits Still Hit

**Symptoms:**
- Using smaller profile but still hitting context limits
- Agent responses truncated
- "Context limit exceeded" errors

**Root Cause:**
- Very large codebase consuming context
- Long conversation history
- Multiple large files loaded

**Solution:**

### Step 1: Use Smallest Appropriate Profile

```bash
# Switch to core (80% reduction)
ln -sf .mcp-profiles/core.json .mcp.json
```

### Step 2: Clear Conversation

```bash
# In Claude Code
/clear
```

### Step 3: Focus on Specific Files

Instead of loading entire codebase, work with specific files:
```bash
@developer Review authentication.ts only
# Rather than "Review all authentication code"
```

### Step 4: Break Down Tasks

Split large tasks into smaller chunks:
```bash
# ❌ Large task
@developer Refactor entire user management system

# ✅ Smaller tasks
@developer Refactor user creation in users.ts
@developer Refactor user authentication in auth.ts
```

**Prevention:**
- Start sessions with smallest appropriate profile
- Use `/clear` regularly to reset context
- Work incrementally on large tasks
- Focus on specific files/functions

---

## Issue 10: Profile Recommendation Conflicts

**Symptoms:**
- Agent recommends different profile
- Coordinator and specialist disagree on profile
- Unclear which profile to use

**Root Cause:**
Some tasks can be done with multiple profiles, agents may recommend different ones.

**Solution:**

### Profile Priority Rules

1. **Smallest viable profile wins** - Use the smallest profile that can complete the task
2. **Safety first** - For production data, always use `database-production.json`
3. **Task-specific beats general** - Specialized profile beats fullstack
4. **Current profile** - If it works, don't switch unnecessarily

### Decision Matrix

| Task Type | First Choice | Fallback | Never Use |
|-----------|-------------|----------|-----------|
| Code review | core | fullstack | database-production |
| Browser testing | testing | fullstack | core |
| DB development | database-staging | fullstack | database-production |
| Production queries | database-production | - | database-staging |
| Payment dev | payments | fullstack | core |
| Deployment | deployment | fullstack | core |
| Multi-domain | fullstack | - | - |

### When Agents Disagree

Trust the specialist agent for their domain:
- @tester recommends testing → Use testing
- @developer recommends database-staging → Use database-staging
- @operator recommends deployment → Use deployment

**Prevention:**
Understand the profile purpose and choose based on task requirements, not agent preference.

---

## Issue 11: Slow Agent Responses

**Symptoms:**
- Agent takes longer to respond
- Noticeable delay before agent starts working
- Timeout errors

**Root Cause:**
Using fullstack profile loads all MCPs, increasing initialization time.

**Solution:**

### Switch to Smaller Profile

```bash
# From fullstack (8 MCPs)
ln -sf .mcp-profiles/core.json .mcp.json  # 3 MCPs, much faster
```

### Profile Performance Comparison

| Profile | MCPs | Avg Init Time | Relative Speed |
|---------|------|---------------|----------------|
| core | 3 | ~1s | Fastest |
| testing | 4 | ~2s | Fast |
| database-* | 4 | ~2s | Fast |
| payments | 4 | ~2s | Fast |
| deployment | 5 | ~3s | Moderate |
| fullstack | 8 | ~5s | Slowest |

### Optimization Tips

1. Start with core profile by default
2. Only switch to specialized profiles when needed
3. Switch back to core after specialized work
4. Avoid leaving fullstack active between sessions

**Prevention:**
Make core your default profile:
```bash
# Set core as default
ln -sf .mcp-profiles/core.json .mcp.json

# Only switch when you need specialized MCPs
```

---

## Issue 12: API Key Errors

**Symptoms:**
```
Error: Invalid CONTEXT7_API_KEY
Error: GitHub authentication failed
Stripe API key not valid
```

**Root Cause:**
- API keys expired
- API keys revoked
- Wrong API key format
- API keys not properly set

**Solution:**

### Step 1: Verify API Key Format

**Context7:**
```bash
# Should start with 'ctx7_'
echo $CONTEXT7_API_KEY | grep '^ctx7_' && echo "Valid format" || echo "Invalid format"
```

**GitHub:**
```bash
# Should start with 'ghp_', 'gho_', or 'github_pat_'
echo $GITHUB_PERSONAL_ACCESS_TOKEN | grep -E '^(ghp_|gho_|github_pat_)' && echo "Valid format" || echo "Invalid format"
```

**Stripe:**
```bash
# Should start with 'sk_test_' (test) or 'sk_live_' (production)
echo $STRIPE_API_KEY | grep -E '^sk_(test|live)_' && echo "Valid format" || echo "Invalid format"
```

### Step 2: Test API Keys

**GitHub Token:**
```bash
curl -H "Authorization: token $GITHUB_PERSONAL_ACCESS_TOKEN" https://api.github.com/user
# Should return your user info
```

**Stripe Key:**
```bash
curl https://api.stripe.com/v1/balance \
  -u $STRIPE_API_KEY:
# Should return balance info
```

### Step 3: Regenerate Keys

If keys are invalid:
1. **Context7**: Visit https://context7.com/account/api-keys
2. **GitHub**: Visit https://github.com/settings/tokens
3. **Stripe**: Visit https://dashboard.stripe.com/apikeys
4. **Supabase**: Visit https://app.supabase.com/project/[project]/settings/api
5. **Netlify**: Visit https://app.netlify.com/user/applications
6. **Railway**: Visit https://railway.app/account/tokens

### Step 4: Update .env.mcp

```bash
# Edit with new keys
nano .env.mcp

# Verify format
cat .env.mcp

# Restart Claude Code
```

**Prevention:**
- Store backup of working API keys securely (password manager)
- Set calendar reminders before token expiration
- Use tokens with appropriate scopes (don't use overly permissive tokens)

---

## Advanced Troubleshooting

### Enable Debug Mode

```bash
# Check MCP server logs (if available)
# Location varies by MCP server implementation
```

### Verify MCP Server Processes

```bash
# Check if MCP servers are running
ps aux | grep -E '(mcp-server|playwright|supabase|stripe|netlify|railway)'
```

### Test Profile Manually

```bash
# Load profile and test
cat .mcp-profiles/core.json

# Validate JSON
jq empty .mcp-profiles/core.json && echo "Valid" || echo "Invalid"

# Check environment variables referenced
grep -o '\${[A-Z_]*}' .mcp-profiles/core.json | sort -u
```

### Clean Install

If all else fails, reinstall:

```bash
# Backup current config
cp .env.mcp .env.mcp.backup
cp .mcp.json .mcp.json.backup

# Clean profiles
rm -rf .mcp-profiles/

# Reinstall
./project/deployment/scripts/mcp-setup.sh

# Restore env
cp .env.mcp.backup .env.mcp

# Recreate symlink
ln -sf .mcp-profiles/core.json .mcp.json

# Restart Claude Code
```

---

## Getting Help

### Before Asking for Help

Collect this information:

```bash
# 1. Active profile
ls -l .mcp.json

# 2. Available profiles
ls -la .mcp-profiles/

# 3. Environment variables (REDACT YOUR KEYS!)
cat .env.mcp | grep -o '^[A-Z_]*='

# 4. JSON validation
for f in .mcp-profiles/*.json; do
  echo "Checking $f"
  jq empty "$f" && echo "✅ Valid" || echo "❌ Invalid"
done

# 5. MCP server status
./project/deployment/scripts/mcp-setup.sh --verify
```

### Where to Get Help

1. **Documentation**:
   - [MCP-GUIDE.md](./MCP-GUIDE.md) - Setup and usage
   - [MCP-PROFILES.md](./MCP-PROFILES.md) - Profile reference

2. **GitHub Issues**:
   - Search existing issues: https://github.com/anthropics/agent-11/issues
   - Create new issue with collected information above

3. **Community**:
   - Discord: [AGENT-11 community](link)
   - Discussions: https://github.com/anthropics/agent-11/discussions

---

## Prevention Checklist

Use this checklist to avoid common issues:

- [ ] MCP servers installed (`./project/deployment/scripts/mcp-setup.sh`)
- [ ] `.env.mcp` created from template
- [ ] API keys added to `.env.mcp` in correct format
- [ ] `.mcp.json` is a symlink (not regular file)
- [ ] Always restart Claude Code after profile switch
- [ ] Verify profile with `ls -l .mcp.json` before work
- [ ] Use smallest profile that meets needs
- [ ] Use `database-production.json` for production queries
- [ ] Use `database-staging.json` for development
- [ ] Keep `.env.mcp` in `.gitignore`

---

## Quick Reference

### Most Common Fixes

| Issue | Quick Fix |
|-------|----------|
| Profile not working | Restart Claude Code |
| MCP not found | Run `./project/deployment/scripts/mcp-setup.sh` |
| API key error | Check `.env.mcp` format |
| Production write blocked | Switch to `database-staging.json` |
| Symlink error | `rm .mcp.json && ln -sf .mcp-profiles/core.json .mcp.json` |
| Context limits | Switch to smaller profile + `/clear` |

### Profile Quick Switch

```bash
# Fastest one-liner to switch and verify
ln -sf .mcp-profiles/testing.json .mcp.json && ls -l .mcp.json && echo "Restart Claude Code!"
```

### Emergency Reset

```bash
# Nuclear option - reset everything
rm .mcp.json
ln -sf .mcp-profiles/core.json .mcp.json
# Restart Claude Code
```

---

## Appendix: Error Messages Reference

### Common Error Messages and Meanings

| Error Message | Meaning | Solution |
|--------------|---------|----------|
| "MCP server not found" | MCP not installed | Run setup script |
| "Missing [VAR]" | Environment variable not set | Add to `.env.mcp` |
| "Invalid JSON" | Syntax error in profile | Validate with `jq` |
| "Operation not permitted" | Read-only mode (expected) | Switch to staging or this is correct |
| "Authentication failed" | Invalid API key | Regenerate key |
| "Context limit exceeded" | Too much context | Use smaller profile |
| "Profile not found" | Invalid profile name | Use standard profile |

---

**Last Updated:** October 21, 2025
**Version:** MCP System v3.0

For setup instructions, see [MCP-GUIDE.md](./MCP-GUIDE.md).
For profile details, see [MCP-PROFILES.md](./MCP-PROFILES.md).
