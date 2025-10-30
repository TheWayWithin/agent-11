# AGENT-11 Agent Migration Guide v3.0

## Overview

This guide helps you migrate your AGENT-11 agents from legacy format (v1.0-v2.x) to the new YAML frontmatter schema (v3.0). The migration is **completely optional** and **backward compatible** - all existing agents will continue working.

## Why Migrate?

The new v3.0 schema provides:
- ✅ **Structured tool permissions** - Clear definition of what tools agents can use
- ✅ **Extended thinking configuration** - Optimize cognitive modes per agent
- ✅ **Coordination metadata** - Explicit agent relationships
- ✅ **Validation support** - Automated schema, semantic, and content validation
- ✅ **Better IDE support** - Syntax highlighting and autocomplete
- ✅ **Future extensibility** - Custom fields for future enhancements

## Migration Timeline

| Release | Support Status |
|---------|---------------|
| **v3.0.0** (Now) | ✅ Full dual parsing support<br>✅ New format optional<br>⚠️ Deprecation warnings (dev only) |
| **v3.1.0** (+3 months) | ✅ Full dual parsing support<br>⚠️ Deprecation warnings (all envs) |
| **v4.0.0** (+6 months) | ⚠️ Legacy format deprecated<br>✅ Dual parsing still works<br>❌ Errors for legacy format |
| **v5.0.0** (+12 months) | ❌ Legacy format removed (if needed) |

**Bottom line**: You have at least 6 months to migrate, and likely 12+ months of legacy support.

## Quick Start

### 1. Check Current Format

```bash
npm run validate:agents
```

This will show which agents are using legacy format vs. v3.0 format.

### 2. Preview Migration (Dry Run)

```bash
# Single agent
npm run migrate:agent project/agents/specialists/coordinator.md -- --dry-run

# All agents
npm run migrate:all -- --dry-run
```

This shows what the new format will look like without making changes.

### 3. Migrate Agent

```bash
# Single agent
npm run migrate:agent project/agents/specialists/coordinator.md

# All agents
npm run migrate:all
```

The migration tool will:
1. Parse your legacy agent
2. Create automatic backup (`.backup` file)
3. Generate v3.0 frontmatter
4. Write new format
5. Validate with schema validator
6. Rollback if validation fails

### 4. Verify Migration

```bash
npm run validate:agent project/agents/specialists/coordinator.md
```

All three validation layers will run and confirm your agent is correctly migrated.

## Before You Start

### Prerequisites

```bash
# Install dependencies
npm install

# Install git hooks (optional but recommended)
npm run install:hooks
```

### Backup Strategy

The migration tool creates automatic backups, but you can also:

```bash
# Manual backup
cp project/agents/specialists/coordinator.md project/agents/specialists/coordinator.md.manual-backup

# Or backup entire directory
cp -r project/agents/specialists project/agents/specialists.backup
```

## Migration Examples

### Example 1: Simple Agent (coordinator)

**Before (v1.0):**
```yaml
---
name: coordinator
description: Mission orchestration specialist
color: green
---
```

**After (v3.0):**
```yaml
---
name: coordinator
description: Mission orchestration specialist
version: "3.0.0"
status: stable
color: green
tags:
  - core
  - coordination
thinking:
  default: think hard
tools:
  primary: ["Task", "TodoWrite", "Write", "Read", "Edit"]
  mcp: ["mcp__github"]
  restricted: ["Bash", "MultiEdit"]
coordinates_with: []
escalates_to: "@user"
verification_required: true
self_verification: true
---
```

**What Changed:**
- Added `version: "3.0.0"` (required for new format)
- Added `status: stable` (inferred from production use)
- Added `tags` (inferred from agent role)
- Added `thinking` configuration (inferred from agent type)
- Added structured `tools` object (extracted from markdown)
- Added coordination metadata (inferred from agent relationships)
- Added verification flags (detected from markdown sections)

### Example 2: Developer Agent

**Before (v1.0):**
```yaml
---
name: developer
description: Full-stack implementation specialist
color: blue
---
## TOOL PERMISSIONS
**Primary Tools**: Read, Write, Edit, Bash, Task
**MCP Tools**: mcp__github, mcp__context7, mcp__supabase
```

**After (v3.0):**
```yaml
---
name: developer
description: Full-stack implementation specialist
version: "3.0.0"
color: blue
tags:
  - core
  - technical
tools:
  primary: ["Read", "Write", "Edit", "Bash", "Task"]
  mcp: ["mcp__github", "mcp__context7", "mcp__supabase"]
  restricted: ["WebSearch"]
coordinates_with: ["architect", "tester", "operator"]
verification_required: true
self_verification: true
---
## TOOL PERMISSIONS
...
```

**What Changed:**
- Extracted tools from markdown into structured `tools` object
- Added coordination relationships based on agent role
- Preserved all markdown content
- Added verification flags based on content analysis

## Migration Workflow

### For Individual Agents

1. **Review agent** - Read through current agent definition
2. **Dry run** - Preview migration with `--dry-run`
3. **Migrate** - Run migration tool
4. **Validate** - Run validation to confirm schema compliance
5. **Test** - Test agent in a mission to verify functionality
6. **Commit** - Commit changes to version control

### For All Agents (Batch)

1. **Dry run all** - `npm run migrate:all -- --dry-run`
2. **Review output** - Check generated frontmatter for all agents
3. **Backup** - `cp -r project/agents/specialists project/agents/specialists.backup`
4. **Migrate all** - `npm run migrate:all`
5. **Validate all** - `npm run validate:agents`
6. **Test critical missions** - Run your most important missions
7. **Commit** - Commit all changes together

## Troubleshooting

### Migration Failed Validation

**Problem**: Migration completes but validation fails

**Solution**:
1. Check validation error messages
2. Fix issues manually in agent file
3. Re-run validation: `npm run validate:agent <file>`
4. Migration tool already rolled back to original

### Backup File Not Created

**Problem**: `.backup` file wasn't created

**Cause**: Agent already using v3.0 format

**Solution**: No migration needed

### Tool Extraction Incorrect

**Problem**: Tools not extracted correctly from markdown

**Solution**:
1. Check `## TOOL PERMISSIONS` section format
2. Ensure tools listed as: `- **ToolName** - Description`
3. Manually edit frontmatter `tools` section
4. Re-run validation

### Custom Fields Lost

**Problem**: Custom metadata not preserved

**Solution**:
1. Legacy format doesn't support custom fields
2. Add custom fields manually to `custom:` section in new format
3. Example:
   ```yaml
   custom:
     my_field: value
     research_tools: ["mcp__context7"]
   ```

## Validation

After migration, agents are validated with three layers:

### Layer 1: Schema Validation (<10ms)
- YAML syntax correctness
- Required fields present
- Field types correct
- No duplicate tools

### Layer 2: Semantic Validation (<30ms)
- Tool names exist in registry
- Agent names valid
- Version format correct
- Status consistency

### Layer 3: Content Validation (<60ms)
- Required markdown sections exist
- Internal links not broken
- Tool permissions documented
- Verification protocols complete

## Rollback

If you need to rollback a migration:

### Automatic Rollback

Migration tool automatically rolls back if validation fails.

### Manual Rollback

```bash
# Restore from backup
mv coordinator.md.backup coordinator.md

# Or restore entire directory
rm -r project/agents/specialists
mv project/agents/specialists.backup project/agents/specialists
```

### Git Rollback

```bash
# Rollback uncommitted changes
git checkout -- project/agents/specialists/

# Rollback committed changes
git revert <commit-hash>
```

## Best Practices

### 1. Migrate One Agent at a Time (First Time)

Start with a simple agent to understand the process:

```bash
npm run migrate:agent project/agents/specialists/support.md
npm run validate:agent project/agents/specialists/support.md
```

### 2. Use Dry Run Extensively

Always preview before migrating:

```bash
npm run migrate:agent <file> -- --dry-run
```

### 3. Test After Migration

Run a simple mission to verify agent functionality:

```bash
# Test coordinator
/coord test-mission.md

# Test other agents
@developer "Simple test task"
```

### 4. Commit Incrementally

Don't migrate all agents in one commit:

```bash
git add project/agents/specialists/coordinator.md
git commit -m "feat: Migrate coordinator agent to v3.0 schema"
```

### 5. Keep Backups Until Verified

Don't delete `.backup` files until you've verified agents work correctly:

```bash
# After successful verification (1-2 weeks)
rm project/agents/specialists/*.backup
```

## FAQ

### Q: Do I have to migrate?

**A:** No, migration is optional. Legacy format will be supported for 6+ months, likely 12+ months.

### Q: Will my missions break?

**A:** No, all 19 missions work with both formats. Dual parsing ensures zero breaking changes.

### Q: Can I mix formats?

**A:** Yes, you can have some agents in v1.0 and some in v3.0. They work together seamlessly.

### Q: What if migration fails?

**A:** The tool automatically rolls back to your original file. No data loss.

### Q: Can I migrate back to legacy?

**A:** Yes, use the `.backup` file or git history. However, v3.0 format has no disadvantages.

### Q: Do I need to update missions?

**A:** No, missions reference agents by name only. Format is transparent to missions.

### Q: What about custom modifications?

**A:** All markdown content is preserved. Custom fields can be added to `custom:` section.

### Q: How long does migration take?

**A:** ~5 minutes per agent (review, migrate, validate, test). Batch migration is faster.

## Support

### Get Help

- **Documentation**: `/docs/` directory
- **Validation**: `npm run validate:agents`
- **Issues**: GitHub issues with `migration` label
- **Community**: Discord #agent-11-help channel

### Report Problems

If you encounter migration issues:

1. Run validation: `npm run validate:agent <file> --verbose`
2. Check logs: Migration tool outputs detailed errors
3. Create GitHub issue with:
   - Agent name
   - Error message
   - Validation output
   - Agent file (if possible)

## Next Steps

After successful migration:

1. **Enable Git Hooks** - `npm run install:hooks` for automatic validation
2. **Set Up CI/CD** - GitHub Actions will validate on PR
3. **Update Custom Agents** - Migrate any custom agents you've created
4. **Enjoy New Features** - Use structured tools, thinking modes, etc.

## Conclusion

The v3.0 migration is:
- ✅ **Safe** - Automatic backups and rollback
- ✅ **Optional** - Legacy format supported for 6-12+ months
- ✅ **Beneficial** - Better tooling, validation, and extensibility
- ✅ **Simple** - One command with automatic migration

Start with one agent, verify it works, then migrate the rest at your own pace.

---

**Version**: 1.0.0
**Last Updated**: 2025-10-30
**Applies To**: AGENT-11 v3.0.0+
