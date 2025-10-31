# AGENT-11 Deployment Validation System

## Overview

The deployment validation system prevents deployment consistency bugs by automatically validating that:
- `install.sh` SQUAD_FULL array contains exactly 11 agents
- SQUAD_FULL matches the library agents directory (`project/agents/specialists/`)
- Source directory priority is correct (library agents prioritized first)
- README.md claims match actual deployment

This system was created in response to Phase 3 bugs where deployment inconsistencies were discovered.

## Quick Start

### Manual Validation

Run validation anytime:

```bash
node scripts/validate-deployment.js
```

**Expected output:**
```
🔍 AGENT-11 Deployment Validation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Found 11 agents in SQUAD_FULL:
  strategist, developer, tester, operator, architect, designer, documenter, support, analyst, marketer, coordinator

Found 11 agents in library:
  analyst, architect, coordinator, designer, developer, documenter, marketer, operator, strategist, support, tester

✓ SQUAD_FULL agent count: 11 (expected: 11)
✓ SQUAD_FULL matches library agents directory
✓ Source directory priority: library first
✓ README consistency: verified

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ All validation checks passed!
```

**Exit codes:**
- `0` = All validation passed
- `1` = Validation failures found

### Automated Testing

Run validation tests with Jest:

```bash
npm test -- tests/deployment-validation.test.js
```

Tests validate:
- SQUAD_FULL extraction
- Agent count accuracy (11 agents)
- Agent list matching
- Source directory priority
- README.md consistency
- Performance (<500ms)
- Phase 3 bug prevention

### Pre-Commit Hook

Install automatic validation on commits:

```bash
./scripts/install-validation-hook.sh
```

The hook:
- Runs automatically when `install.sh` or library agents are modified
- Blocks commits if validation fails
- Fast (<500ms) to not slow down workflow
- Can be bypassed with `git commit --no-verify` if needed

**Hook behavior:**
```bash
# Triggers validation:
git add project/deployment/scripts/install.sh
git commit -m "Update deployment"
# → Validation runs automatically

# Skips validation (not recommended):
git commit --no-verify -m "Emergency fix"
```

## What Gets Validated

### 1. Agent Count Validation

**Check:** SQUAD_FULL contains exactly 11 agents

**Why:** Prevents deploying wrong number of agents

**Example failure:**
```
❌ SQUAD_FULL has 10 agents, expected 11
```

**How to fix:**
1. Count agents in `project/agents/specialists/*.md`
2. Ensure SQUAD_FULL in `install.sh` has all 11 agents
3. Add missing agent to SQUAD_FULL array

### 2. Agent List Matching

**Check:** SQUAD_FULL agents match library agents directory

**Why:** Prevents typos, missing agents, or wrong agent names

**Example failure:**
```
❌ Agents in SQUAD_FULL but missing from library: architekt
❌ Agents in library but missing from SQUAD_FULL: architect
```

**How to fix:**
1. Compare SQUAD_FULL array with `ls project/agents/specialists/*.md`
2. Fix typos in agent names
3. Ensure all agents are included

### 3. Source Directory Priority

**Check:** install.sh checks library agents before working squad

**Why:** Ensures deployment uses correct agent source

**Example failure:**
```
❌ Source directory priority incorrect: working squad checked before library agents
```

**How to fix:**
1. In `install.sh`, find the `install_agent()` function
2. Ensure `project/agents/specialists` is checked before `.claude/agents`
3. Move library agents check to be first priority

### 4. README Consistency

**Check:** README.md claims match actual agent count

**Why:** Prevents documentation drift

**Example output:**
```
✓ README.md correctly claims "11 agents" for full squad
⚠ README.md mentions "7 agents" - verify this is correct
```

**How to fix:**
1. Review README.md for agent count claims
2. Ensure claims match SQUAD_FULL (11 agents for full squad)
3. Update outdated claims

## Common Validation Failures

### Scenario 1: Added Agent to Library, Forgot SQUAD_FULL

**Symptom:**
```
❌ Agents in library but missing from SQUAD_FULL: new-agent
```

**Fix:**
```bash
# Edit install.sh
SQUAD_FULL=("strategist" "developer" "tester" "operator" "architect" "designer" "documenter" "support" "analyst" "marketer" "coordinator" "new-agent")
```

### Scenario 2: Typo in SQUAD_FULL

**Symptom:**
```
❌ Agents in SQUAD_FULL but missing from library: develper
❌ Agents in library but missing from SQUAD_FULL: developer
```

**Fix:**
```bash
# Fix typo in install.sh
SQUAD_FULL=("strategist" "developer" "tester" ...)  # Fixed: develper → developer
```

### Scenario 3: Wrong Source Priority

**Symptom:**
```
❌ Source directory priority incorrect: working squad checked before library agents
```

**Fix:**
```bash
# In install.sh, install_agent() function:
# WRONG order:
if [[ -f "$PROJECT_ROOT/.claude/agents/$agent_name.md" ]]; then
  source_file="$PROJECT_ROOT/.claude/agents/$agent_name.md"
elif [[ -f "$PROJECT_ROOT/project/agents/specialists/$agent_name.md" ]]; then
  source_file="$PROJECT_ROOT/project/agents/specialists/$agent_name.md"

# RIGHT order:
if [[ -f "$PROJECT_ROOT/project/agents/specialists/$agent_name.md" ]]; then
  source_file="$PROJECT_ROOT/project/agents/specialists/$agent_name.md"
elif [[ -f "$PROJECT_ROOT/.claude/agents/$agent_name.md" ]]; then
  source_file="$PROJECT_ROOT/.claude/agents/$agent_name.md"
```

### Scenario 4: README Claims Wrong Count

**Symptom:**
```
⚠ README.md mentions "10 agents" - verify this is correct
```

**Fix:**
```markdown
<!-- Update README.md -->
Deploy your elite squad of 11 specialized agents...  # Fixed: 10 → 11
```

## Integration with Existing Workflows

### Development Workflow

```bash
# 1. Make changes to install.sh or library agents
vim project/deployment/scripts/install.sh

# 2. Run validation manually (optional)
node scripts/validate-deployment.js

# 3. Commit changes
git add project/deployment/scripts/install.sh
git commit -m "Add new agent to deployment"
# → Pre-commit hook runs validation automatically

# 4. If validation fails, fix issues and try again
# If validation passes, commit proceeds
```

### CI/CD Integration

Add to your CI pipeline (GitHub Actions, etc.):

```yaml
# .github/workflows/validate.yml
- name: Validate Deployment Consistency
  run: node scripts/validate-deployment.js
```

### npm Scripts

Already integrated:

```bash
# Run all tests (includes deployment validation)
npm test

# Run only deployment validation tests
npm test -- tests/deployment-validation.test.js
```

## Performance

Validation is designed to be fast:

- **Manual validation:** <100ms average
- **Test suite:** <500ms total
- **Pre-commit hook:** <500ms (only runs when needed)

Performance targets ensure validation doesn't slow down development workflow.

## Architecture

### File Structure

```
agent-11/
├── scripts/
│   ├── validate-deployment.js          # Standalone validator
│   ├── pre-commit-deployment-validation # Pre-commit hook
│   └── install-validation-hook.sh      # Hook installer
├── tests/
│   └── deployment-validation.test.js   # Jest test suite
├── project/
│   ├── deployment/scripts/install.sh   # Deployment script (validated)
│   └── agents/specialists/*.md         # Library agents (validated)
└── docs/
    └── VALIDATION.md                   # This file
```

### Validation Flow

```
Manual Run:
  node scripts/validate-deployment.js
    → Extract SQUAD_FULL from install.sh
    → Get library agents from specialists/
    → Run 4 validation checks
    → Print results
    → Exit with code (0=pass, 1=fail)

Pre-Commit Hook:
  git commit
    → Hook detects modified files
    → If install.sh or agents modified:
       → Run validate-deployment.js
       → Block commit if validation fails
    → Allow commit if validation passes

Jest Tests:
  npm test
    → Run all validation test cases
    → Verify each validation function
    → Check performance targets
    → Ensure Phase 3 bug prevention
```

## Troubleshooting

### Validation Fails But Changes Look Correct

**Problem:** Validation reports errors but you believe changes are correct

**Solutions:**
1. Check for hidden files: `ls -la project/agents/specialists/`
2. Check for typos in agent names
3. Check for whitespace differences
4. Run with debug: `node scripts/validate-deployment.js` (outputs detailed info)

### Hook Not Running

**Problem:** Pre-commit hook not executing

**Solutions:**
1. Verify hook is installed: `ls -la .git/hooks/pre-commit`
2. Verify hook is executable: `chmod +x .git/hooks/pre-commit`
3. Reinstall: `./scripts/install-validation-hook.sh`
4. Test manually: `.git/hooks/pre-commit` (should run validation)

### Performance Too Slow

**Problem:** Validation takes too long

**Solutions:**
1. Check if running on network filesystem (can slow down file I/O)
2. Verify Node.js version (should be v16+)
3. Check for very large files in specialists/ directory
4. Report issue if consistently >500ms

### False Positives

**Problem:** Validation fails incorrectly

**Solutions:**
1. Check validation script version: `head -20 scripts/validate-deployment.js`
2. Check for backup files: `ls project/agents/specialists/*.backup`
3. Clear backup files if needed
4. Report issue with specific error message

## Maintenance

### Updating Expected Agent Count

If AGENT-11 changes to have more/fewer agents:

1. Update `EXPECTED_AGENT_COUNT` in `scripts/validate-deployment.js`:
   ```javascript
   this.EXPECTED_AGENT_COUNT = 12; // Changed from 11
   ```

2. Update tests in `tests/deployment-validation.test.js`:
   ```javascript
   expect(squadFull.length).toBe(12); // Changed from 11
   ```

3. Run full test suite to verify:
   ```bash
   npm test
   ```

### Adding New Validation Checks

To add new validation:

1. Add method to `DeploymentValidator` class in `validate-deployment.js`
2. Call method in `validate()` function
3. Add corresponding tests to `deployment-validation.test.js`
4. Update this documentation

Example:
```javascript
// In validate-deployment.js
validateNewCheck() {
  // Validation logic
  if (checkFails) {
    this.error('Check failed');
    return false;
  }
  this.success('Check passed');
  return true;
}

// In validate() method
validate() {
  // ... existing checks ...
  this.validateNewCheck(),
  // ... rest of validation ...
}

// In deployment-validation.test.js
test('should validate new check', () => {
  const result = validator.validateNewCheck();
  expect(result).toBe(true);
});
```

## Prevention of Phase 3 Bugs

This validation system directly addresses bugs found in Phase 3:

| Phase 3 Bug | Prevention Mechanism | Test Coverage |
|-------------|---------------------|---------------|
| SQUAD_FULL count mismatch | `validateAgentCount()` | ✅ Automated |
| Agent list mismatch | `validateAgentList()` | ✅ Automated |
| Wrong source priority | `validateSourcePriority()` | ✅ Automated |
| README outdated claims | `validateReadmeConsistency()` | ✅ Automated |

All bugs would be caught **before commit** if pre-commit hook is installed.

## Support

**Questions or issues?**

1. Check this documentation first
2. Run validation manually to see detailed output
3. Check test results: `npm test -- tests/deployment-validation.test.js`
4. Review validation script: `scripts/validate-deployment.js`
5. Open issue on GitHub with validation output

**Common commands:**

```bash
# Run validation
node scripts/validate-deployment.js

# Run tests
npm test -- tests/deployment-validation.test.js

# Install hook
./scripts/install-validation-hook.sh

# Check hook status
ls -la .git/hooks/pre-commit

# Remove hook
rm .git/hooks/pre-commit
```

---

**Last Updated:** 2025-10-30
**Version:** 1.0.0
**Author:** AGENT-11 Developer
