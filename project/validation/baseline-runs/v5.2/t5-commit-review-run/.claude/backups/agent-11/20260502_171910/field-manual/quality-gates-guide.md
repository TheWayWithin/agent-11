# Quality Gates Guide

**Version**: 1.0.0 (Sprint 9)
**Last Updated**: 2025-12-30

## Overview

Quality Gates are automated checks that run at phase transitions to ensure code quality, security, and correctness before proceeding to the next phase. They prevent shipping broken code and enforce consistent standards across your project.

## Quick Start

### 1. Choose a Template

```bash
# Copy a template to your project root
cp project/gates/templates/nodejs-saas.json .quality-gates.json

# Or start minimal
cp project/gates/templates/minimal.json .quality-gates.json
```

### 2. Run Gates Manually

```bash
python project/gates/run-gates.py --config .quality-gates.json --phase implementation
```

### 3. Automatic Enforcement

When using `/coord continue`, gates run automatically at phase transitions.

## Gate Types

| Type | Purpose | Example Command |
|------|---------|-----------------|
| `build` | Verify code compiles | `npm run build` |
| `test` | Run test suite | `npm test` |
| `lint` | Check code style | `npm run lint` |
| `security` | Security scanning | `npm audit` |
| `review` | Code review checks | `gh pr checks` |
| `deploy` | Deployment verification | `npm run deploy:check` |

## Severity Levels

| Level | Behavior | Use For |
|-------|----------|---------|
| `blocking` | Stops execution, must fix | Build, security, critical tests |
| `warning` | Logs warning, continues | Lint, non-critical tests |
| `info` | Informational only | Coverage reports, metrics |

## Configuration

### Basic Structure

```json
{
  "version": "1.0.0",
  "project": "my-saas-app",
  "phases": {
    "implementation": {
      "gates": [
        {
          "name": "Build Check",
          "type": "build",
          "command": "npm run build",
          "severity": "blocking",
          "timeout": 120
        }
      ]
    }
  }
}
```

### Full Gate Configuration

```json
{
  "name": "TypeScript Type Check",
  "type": "build",
  "command": "npx tsc --noEmit",
  "severity": "blocking",
  "timeout": 60,
  "working_directory": "./",
  "environment": {
    "NODE_ENV": "production"
  },
  "success_codes": [0],
  "failure_message": "TypeScript compilation failed. Fix type errors before proceeding.",
  "skip_if": "!test -f tsconfig.json"
}
```

### Configuration Options

| Option | Type | Required | Description |
|--------|------|----------|-------------|
| `name` | string | Yes | Human-readable gate name |
| `type` | string | Yes | Gate type (build, test, lint, security, review, deploy) |
| `command` | string | Yes | Shell command to execute |
| `severity` | string | Yes | blocking, warning, or info |
| `timeout` | number | No | Timeout in seconds (default: 300) |
| `working_directory` | string | No | Directory to run command in |
| `environment` | object | No | Environment variables |
| `success_codes` | array | No | Exit codes considered success (default: [0]) |
| `failure_message` | string | No | Custom failure message |
| `skip_if` | string | No | Condition to skip gate |

## Templates

### Node.js SaaS (nodejs-saas.json)

Pre-configured gates for Node.js/TypeScript SaaS applications:

| Gate | Type | Severity |
|------|------|----------|
| TypeScript Build | build | blocking |
| Unit Tests | test | blocking |
| ESLint Check | lint | warning |
| npm Audit | security | blocking |

### Python API (python-api.json)

Pre-configured gates for Python API projects:

| Gate | Type | Severity |
|------|------|----------|
| Python Syntax | build | blocking |
| Pytest Suite | test | blocking |
| Ruff Linter | lint | warning |
| Bandit Security | security | blocking |

### Minimal (minimal.json)

Minimal gates for any project:

| Gate | Type | Severity |
|------|------|----------|
| Syntax Check | build | blocking |
| Basic Tests | test | warning |

## Gate Runner CLI

### Basic Usage

```bash
python project/gates/run-gates.py --config .quality-gates.json --phase implementation
```

### Options

| Option | Description |
|--------|-------------|
| `--config FILE` | Path to config file (default: .quality-gates.json) |
| `--phase PHASE` | Phase to run gates for |
| `--gate NAME` | Run specific gate only |
| `--dry-run` | Show what would run without executing |
| `--verbose` | Detailed output |
| `--json` | Output results as JSON |

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | All gates passed |
| 1 | One or more blocking gates failed |
| 2 | Configuration error |

## Phase-Specific Gates

Configure different gates for different phases:

```json
{
  "phases": {
    "setup": {
      "gates": [
        { "name": "Dependencies", "type": "build", "command": "npm install", "severity": "blocking" }
      ]
    },
    "implementation": {
      "gates": [
        { "name": "Build", "type": "build", "command": "npm run build", "severity": "blocking" },
        { "name": "Tests", "type": "test", "command": "npm test", "severity": "blocking" },
        { "name": "Lint", "type": "lint", "command": "npm run lint", "severity": "warning" }
      ]
    },
    "deployment": {
      "gates": [
        { "name": "Security Audit", "type": "security", "command": "npm audit", "severity": "blocking" },
        { "name": "E2E Tests", "type": "test", "command": "npm run test:e2e", "severity": "blocking" }
      ]
    }
  }
}
```

## Integration with Coordinator

### Automatic Gate Execution

When `/coord continue` completes a phase, it automatically:

1. Detects phase completion (all tasks `[x]`)
2. Runs configured gates for that phase
3. If all blocking gates pass → transitions to next phase
4. If any blocking gate fails → stops and reports failure

### Manual Gate Check

```bash
# Check gates before phase transition
/coord gate-check implementation
```

### Gate Failure Handling

When a gate fails:

1. Coordinator stops autonomous execution
2. Failure details logged to progress.md
3. Task marked as blocked in project-plan.md
4. User must fix issue and retry

## Best Practices

### 1. Start Minimal, Add as Needed

```json
// Start with just build
{ "name": "Build", "type": "build", "command": "npm run build", "severity": "blocking" }

// Add tests when test suite exists
{ "name": "Tests", "type": "test", "command": "npm test", "severity": "blocking" }
```

### 2. Use Appropriate Severity

- **blocking**: Build failures, security vulnerabilities, broken tests
- **warning**: Lint issues, low test coverage
- **info**: Metrics, documentation coverage

### 3. Set Reasonable Timeouts

```json
{ "timeout": 30 }   // Fast checks (lint)
{ "timeout": 120 }  // Build steps
{ "timeout": 300 }  // Full test suites
{ "timeout": 600 }  // E2E tests
```

### 4. Provide Helpful Failure Messages

```json
{
  "failure_message": "TypeScript compilation failed. Run 'npx tsc --noEmit' locally to see errors."
}
```

### 5. Skip Gates When Not Applicable

```json
{
  "skip_if": "!test -f package.json"  // Skip if no package.json
}
```

## Troubleshooting

### "Gate command not found"

Ensure the command is available in PATH:
```bash
which npm  # Should show path
```

### "Gate times out"

Increase timeout:
```json
{ "timeout": 600 }
```

### "Gate fails but command works locally"

Check:
1. Working directory is correct
2. Environment variables are set
3. Dependencies are installed

### "Want to skip a gate temporarily"

Add skip condition:
```json
{ "skip_if": "true" }  // Always skip (temporary)
```

## Creating Custom Gates

### Example: Database Migration Check

```json
{
  "name": "Migration Check",
  "type": "deploy",
  "command": "npx prisma migrate status --exit-code",
  "severity": "blocking",
  "failure_message": "Pending migrations found. Run 'npx prisma migrate deploy' first."
}
```

### Example: Bundle Size Check

```json
{
  "name": "Bundle Size",
  "type": "build",
  "command": "npm run build && size-limit",
  "severity": "warning",
  "failure_message": "Bundle size exceeds limit. Review and optimize imports."
}
```

### Example: API Contract Check

```json
{
  "name": "API Contract",
  "type": "test",
  "command": "npm run test:contract",
  "severity": "blocking",
  "failure_message": "API contract violations detected. Update OpenAPI spec or fix implementation."
}
```

## Related Guides

- [Plan-Driven Development](./plan-driven-development.md) - Overall workflow
- [Coordinator Commands](./coordinator-commands.md) - Command reference
- [Project Lifecycle](./project-lifecycle-guide.md) - Phase management
