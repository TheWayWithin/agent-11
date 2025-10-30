# AGENT-11 Troubleshooting Guide

## Validation Errors

### Schema Validation Errors

#### Error: "No YAML frontmatter found"

**Cause**: Agent file missing `---` delimiters or YAML frontmatter

**Fix**:
```yaml
---
name: your-agent
description: Agent description
---
# Agent content
```

#### Error: "YAML parse error"

**Cause**: Invalid YAML syntax (indentation, quotes, special characters)

**Common issues**:
- Mixed tabs and spaces (use spaces only)
- Unquoted strings with special characters
- Incorrect indentation

**Fix**:
```yaml
# Bad
tools:
primary: ["Read"] # Wrong indentation

# Good
tools:
  primary: ["Read"]
```

#### Error: "Missing required field: name"

**Cause**: `name` or `description` field not present

**Fix**:
```yaml
---
name: agent-name        # Required
description: Agent desc # Required
---
```

#### Error: "Field 'tools.primary' - Expected array, got string"

**Cause**: Tool lists must be arrays, not strings

**Fix**:
```yaml
# Bad
tools:
  primary: "Read, Write"

# Good
tools:
  primary: ["Read", "Write"]
```

#### Error: "Duplicate tool: Read"

**Cause**: Same tool listed in multiple lists (primary, mcp, restricted)

**Fix**:
```yaml
# Bad
tools:
  primary: ["Read", "Write"]
  restricted: ["Read"]  # Duplicate!

# Good
tools:
  primary: ["Write"]
  restricted: ["Read"]
```

#### Error: "Field 'status' - Must be one of: stable, beta, experimental, deprecated"

**Cause**: Invalid status value

**Fix**:
```yaml
# Bad
status: production

# Good
status: stable  # or beta, experimental, deprecated
```

### Semantic Validation Errors

#### Error: "Unknown tool: CustomTool"

**Cause**: Tool not in tool registry

**Fix**:
1. Add tool to `/project/deployment/tool-registry.json`:
   ```json
   [
     "Read",
     "Write",
     "CustomTool"
   ]
   ```
2. Or use standard tool from registry

#### Warning: "Unknown MCP tool: mcp__custom"

**Cause**: MCP tool not in registry (this is a warning, not an error)

**Fix**: This is normal for custom MCP tools. Can be safely ignored if tool exists.

#### Error: "Unknown agent: nonexistent-agent"

**Cause**: Agent name in `coordinates_with` doesn't exist

**Fix**:
```yaml
# Bad
coordinates_with: ["nonexistent-agent"]

# Good
coordinates_with: ["developer", "tester"]
```

#### Error: "Invalid semantic version: 3.0"

**Cause**: Version must be MAJOR.MINOR.PATCH

**Fix**:
```yaml
# Bad
version: "3.0"

# Good
version: "3.0.0"
```

### Content Validation Errors

#### Error: "Missing required section: ## CONTEXT PRESERVATION PROTOCOL"

**Cause**: Required markdown section not present

**Fix**: Add section to markdown content:
```markdown
## CONTEXT PRESERVATION PROTOCOL

**Before Task Execution**:
1. Agent MUST read `agent-context.md` and `handoff-notes.md`
...
```

Required sections:
- `## CONTEXT PRESERVATION PROTOCOL` (always required)
- `## TOOL PERMISSIONS` (if tools defined)
- `## SELF-VERIFICATION PROTOCOL` (if verification_required: true)
- `## EXTENDED THINKING GUIDANCE` (if thinking defined)
- `## CONTEXT EDITING GUIDANCE` (always required)

#### Warning: "Broken internal link: /docs/missing.md"

**Cause**: Markdown link points to nonexistent file

**Fix**:
1. Create the missing file
2. Or update the link to correct path
3. Or remove the broken link

#### Warning: "Primary tool 'Read' not documented in TOOL PERMISSIONS section"

**Cause**: Tool listed in frontmatter but not explained in markdown

**Fix**: Add explanation in TOOL PERMISSIONS section:
```markdown
## TOOL PERMISSIONS

**Primary Tools**:
- **Read** - Essential for reading code, configs, documentation
- **Write** - Create new files (components, modules, configs)
...
```

## Migration Errors

### Error: "Migration failed validation"

**Cause**: Generated frontmatter doesn't pass schema validation

**Fix**:
1. Check error message for specific issue
2. Migration tool automatically rolled back
3. Fix issue manually or report bug

### Error: "Tool extraction failed"

**Cause**: Tools not extracted correctly from markdown

**Fix**: Check `## TOOL PERMISSIONS` section format:
```markdown
## TOOL PERMISSIONS

**Primary Tools**:
- **Read** - Description
- **Write** - Description

**MCP Tools**:
- **mcp__github** - Description
```

Tools must be formatted as: `- **ToolName** - Description`

### Error: "Backup already exists"

**Cause**: `.backup` file from previous migration exists

**Fix**:
```bash
# Remove old backup
rm project/agents/specialists/coordinator.md.backup

# Then re-run migration
npm run migrate:agent project/agents/specialists/coordinator.md
```

## Performance Issues

### Validation Takes >100ms

**Cause**: Performance targets exceeded

**Possible reasons**:
1. Large agent files (>5000 lines)
2. Complex markdown content
3. Many internal links to validate

**Fix**:
1. Verify performance with: `npm run validate:agents --verbose`
2. Check if specific layer is slow
3. Report if consistently above targets

### Tests Failing

#### Error: "Tests timeout"

**Cause**: Test suite taking too long

**Fix**:
```bash
# Increase timeout
npm test -- --testTimeout=10000
```

#### Error: "Mock file system issues"

**Cause**: Test files not cleaned up

**Fix**:
```bash
# Clean temp files
rm /tmp/test-*.md
rm /tmp/*.backup

# Re-run tests
npm test
```

## Git Hooks

### Pre-commit Hook Not Running

**Cause**: Hook not installed or not executable

**Fix**:
```bash
# Install hooks
npm run install:hooks

# Or manually
chmod +x .git/hooks/pre-commit
```

### Pre-commit Hook Failing

**Cause**: Agent files have schema errors

**Fix**:
1. Check which files failing: `git status`
2. Validate manually: `npm run validate:agent <file>`
3. Fix errors
4. Retry commit

### Bypass Pre-commit Hook (Emergency)

**Use with caution**:
```bash
git commit --no-verify -m "Emergency commit"
```

## CI/CD Issues

### GitHub Actions Failing

#### Error: "npm ci failed"

**Cause**: Dependencies not installed correctly

**Fix**: Check `package.json` and `package-lock.json` are committed

#### Error: "Validation failed in CI"

**Cause**: Agent files pass locally but fail in CI

**Possible reasons**:
1. Different Node version
2. Missing files in git
3. Environment differences

**Fix**:
```bash
# Test with CI Node version locally
nvm use 18
npm ci
npm test
```

#### Error: "No files to validate"

**Cause**: Changed files not in validation paths

**Fix**: Check `.github/workflows/validate-agents.yml` paths match your files

## Common Questions

### Q: Why does validation work locally but fail in CI?

**A:** Common causes:
1. Missing `.gitignore` files
2. Different Node versions
3. Cache issues

**Fix**:
```bash
# Clear npm cache
npm cache clean --force

# Clear git cache
git rm -r --cached .
git add .
```

### Q: Can I skip validation for one file?

**A:** Not recommended, but you can:
```bash
git commit --no-verify
```

Better: Fix the validation errors

### Q: Migration tool stuck

**A:** Kill process and check for:
1. Corrupted agent file
2. Permission issues
3. Disk space

```bash
# Kill stuck process
ps aux | grep migrate
kill -9 <PID>

# Check disk space
df -h
```

### Q: Validation errors after migration

**A:** Migration tool validates automatically. If you see errors:
1. Migration already rolled back
2. Original file restored
3. Fix issues and retry

### Q: How to debug validation?

**A:** Use verbose mode:
```bash
npm run validate:agent <file> --verbose
```

Shows:
- All validation layers
- Performance metrics
- Warning details
- Error context

## Getting Help

### Check Documentation

1. **Migration Guide**: `/docs/MIGRATION-GUIDE.md`
2. **Schema Spec**: `/docs/YAML-SCHEMA-SPECIFICATION.md`
3. **Validation Spec**: `/docs/VALIDATION-ARCHITECTURE.md`
4. **Compatibility Spec**: `/docs/BACKWARD-COMPATIBILITY-STRATEGY.md`

### Run Diagnostics

```bash
# Validate all agents
npm run validate:agents --verbose

# Run tests
npm test

# Check git hooks
ls -la .git/hooks/pre-commit
```

### Report Issues

Create GitHub issue with:
1. Error message (full output)
2. Agent file (or relevant parts)
3. Validation output: `npm run validate:agent <file> --verbose`
4. Environment: Node version, OS, npm version
5. Steps to reproduce

### Emergency Rollback

If everything breaks:

```bash
# Restore from git
git checkout -- project/agents/specialists/

# Or restore from backup
mv project/agents/specialists.backup project/agents/specialists
```

## Tips

### Prevent Issues

1. **Always use dry-run first**: `npm run migrate:agent <file> -- --dry-run`
2. **Validate before commit**: `npm run validate:agents`
3. **Install git hooks**: `npm run install:hooks`
4. **Keep backups**: Don't delete `.backup` files immediately
5. **Test after changes**: Run a simple mission to verify

### Debugging Workflow

1. Identify which layer failing (schema, semantics, content)
2. Run that layer with verbose: `npm run validate:agent <file> --layer=schema --verbose`
3. Read error message carefully
4. Check examples in docs
5. Fix and re-validate

### Performance Optimization

1. Keep agent files reasonable size (<2000 lines)
2. Minimize complex regex in content
3. Avoid deeply nested structures
4. Use caching effectively

---

**Version**: 1.0.0
**Last Updated**: 2025-10-30
**Applies To**: AGENT-11 v3.0.0+
