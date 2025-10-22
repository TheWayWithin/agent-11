# MCP Status Checker

**Usage:** `/mcp-status`

Shows which MCP profile is currently active and what tools are connected.

---

## Your Task

The user wants to see their current MCP profile status.

**Step 1: Check active profile**

Run this command:
```bash
ls -l .mcp.json
```

This shows which profile is active (the symlink target).

**Step 2: Parse the result**

Extract the profile name from the output. For example:
- `.mcp.json -> .mcp-profiles/testing.json` means **testing** profile is active
- `.mcp.json -> .mcp-profiles/core.json` means **core** profile is active

**Step 3: Report status**

Tell the user in this format:
```
📊 MCP Profile Status

Current Profile: [profile-name]

Included MCPs:
• [list each MCP server that's in this profile]

Context Usage: [X tokens] ([Y%] reduction from fullstack)

Best for: [what this profile is optimized for]

To switch profiles: /mcp-switch [profile-name]
To see all profiles: /mcp-list
```

**Step 4: Verify MCPs are actually connected**

After reporting, you can optionally verify by checking available tools:
- Look for tools starting with `mcp__` prefix
- Confirm they match the expected profile

If there's a mismatch, warn the user:
```
⚠️ Profile mismatch detected!

Expected MCPs: [list]
Actually connected: [list]

This usually means you need to restart Claude Code:
1. Type: /exit
2. Then run: claude
```

---

## Example Outputs

### Example 1: Core Profile
```
📊 MCP Profile Status

Current Profile: core

Included MCPs:
• context7 - Documentation and code examples
• github - Repository management and PRs
• filesystem - File operations

Context Usage: 3,000 tokens (80% reduction from fullstack)

Best for: General development, code review, documentation

To switch profiles: /mcp-switch [profile-name]
To see all profiles: /mcp-list
```

### Example 2: Testing Profile
```
📊 MCP Profile Status

Current Profile: testing

Included MCPs:
• context7 - Documentation and code examples
• github - Repository management and PRs
• filesystem - File operations
• playwright - Browser automation and E2E testing

Context Usage: 5,500 tokens (63% reduction from fullstack)

Best for: Running tests, E2E testing, browser automation

To switch profiles: /mcp-switch [profile-name]
To see all profiles: /mcp-list
```

### Example 3: Database Staging Profile
```
📊 MCP Profile Status

Current Profile: database-staging

Included MCPs:
• context7 - Documentation and code examples
• github - Repository management and PRs
• filesystem - File operations
• supabase-staging - Database access (FULL READ/WRITE)

Context Usage: 8,000 tokens (47% reduction from fullstack)

Best for: Database migrations, schema changes, development queries

⚠️ You have FULL READ/WRITE access to the staging database.

To switch profiles: /mcp-switch [profile-name]
To see all profiles: /mcp-list
```

### Example 4: Database Production Profile
```
📊 MCP Profile Status

Current Profile: database-production

Included MCPs:
• context7 - Documentation and code examples
• github - Repository management and PRs
• filesystem - File operations
• supabase-production - Database access (READ-ONLY)

Context Usage: 8,000 tokens (47% reduction from fullstack)

Best for: Production queries, data analysis, reporting

🔒 READ-ONLY MODE - No database writes possible (safety enforced)

To switch profiles: /mcp-switch [profile-name]
To see all profiles: /mcp-list
```

---

## Error Handling

**If .mcp.json doesn't exist:**
```
❌ MCP profile not configured

It looks like you haven't set up MCP profiles yet.

To get started:
1. Run: /mcp-switch core
2. Restart Claude Code: /exit then claude

This will set up the recommended core profile.
```

**If .mcp.json is a regular file (not a symlink):**
```
⚠️ Configuration issue detected

Your .mcp.json is not a symlink to a profile. This might be from an old setup.

To fix:
1. Backup current config: cp .mcp.json .mcp.json.backup
2. Switch to a profile: /mcp-switch core
3. Restart: /exit then claude

If you need help, check: docs/MCP-TROUBLESHOOTING.md
```

---

## Communication Style

✅ **Use clear, visual formatting**
✅ **Include emojis for quick scanning**
✅ **Show next actions clearly**
✅ **Warn about important things (production access, read-only mode)**

❌ Don't be verbose
❌ Don't use technical jargon
❌ Don't hide important warnings
