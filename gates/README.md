# Quality Gate System

AGENT-11's quality gate system ensures code quality and security at every phase transition. Gates are automated checkpoints that must pass before work proceeds to the next phase.

## Overview

Quality gates are integrated into the `/coord` orchestration workflow:

```
Phase 1: Foundation
    ↓
[GATE: lint, security] ← Must pass to proceed
    ↓
Phase 2: Core Implementation
    ↓
[GATE: build, test] ← Must pass to proceed
    ↓
Phase 3: Integration
```

## Gate Types

| Gate Type | Purpose | Blocking | Example Command |
|-----------|---------|----------|-----------------|
| `build` | Code compiles without errors | Yes | `npm run build` |
| `test` | Tests pass, coverage met | Yes | `npm test -- --coverage` |
| `lint` | Style compliance | Yes | `npm run lint` |
| `security` | No vulnerabilities | Yes | `npm audit --audit-level=high` |
| `review` | Manual approval required | Yes | Human checkpoint |
| `deploy` | Deployment succeeds | Yes | `netlify deploy --prod` |

## Severity Levels

Each gate check can have a severity level:

- **blocking** (default): Must pass to proceed. Phase transition blocked on failure.
- **warning**: Logged and reported, but does not block progression.
- **info**: Status-only, for visibility. Never blocks.

## Directory Structure

```
project/gates/
├── README.md           # This file
├── gate-types.yaml     # Gate type definitions with defaults
└── templates/
    ├── nodejs-saas.json    # Node.js SaaS projects
    ├── python-api.json     # Python API projects
    └── minimal.json        # Basic gates for any project
```

## How Gates Work

### 1. Gate Definition

Gates are defined in your project's `project-plan.yaml` or a dedicated gate config:

```yaml
gates:
  - name: pre-implementation
    phase: foundation
    checks:
      - type: lint
        command: npm run lint
        severity: blocking
      - type: security
        command: npm audit --audit-level=high
        severity: blocking
```

### 2. Gate Execution

When `/coord` transitions between phases:

1. Coordinator identifies gates for the completing phase
2. Each check command is executed in sequence
3. Results are collected (pass/fail/warning)
4. If ANY blocking check fails, phase transition is halted
5. Detailed remediation guidance is provided

### 3. Gate Results

```
=== QUALITY GATE: pre-implementation ===

[PASS] lint: npm run lint
       0 errors, 0 warnings

[FAIL] security: npm audit --audit-level=high
       Found 2 high severity vulnerabilities

       REMEDIATION:
       Run: npm audit fix
       Or review: npm audit --json for details

=== GATE BLOCKED: 1 of 2 checks failed ===
Cannot proceed to Phase 2 until security gate passes.
```

## Using Gate Templates

### For Node.js SaaS Projects

```bash
# Copy template to project
cp project/gates/templates/nodejs-saas.json .quality-gates.json

# Or reference in project-plan.yaml:
gates_template: nodejs-saas
```

### For Python API Projects

```bash
cp project/gates/templates/python-api.json .quality-gates.json
```

### For Minimal Setup

```bash
cp project/gates/templates/minimal.json .quality-gates.json
```

## Customizing Gates

### Adding Custom Gates

Edit your `.quality-gates.json` to add project-specific checks:

```json
{
  "gates": [
    {
      "name": "database-migration",
      "phase": "pre-deploy",
      "checks": [
        {
          "type": "build",
          "name": "Migration dry-run",
          "command": "npm run db:migrate:dry",
          "severity": "blocking",
          "remediation": "Fix migration files before deploying"
        }
      ]
    }
  ]
}
```

### Overriding Defaults

To change a gate's severity:

```json
{
  "checks": [
    {
      "type": "lint",
      "severity": "warning"
    }
  ]
}
```

### Conditional Gates

Gates can include conditions:

```json
{
  "checks": [
    {
      "type": "security",
      "command": "npm audit --audit-level=critical",
      "condition": "env.CI == 'true'",
      "severity": "blocking"
    }
  ]
}
```

## Integration with /coord

The coordinator automatically runs gates at phase transitions:

```markdown
/coord build project-plan.yaml

# Coordinator will:
# 1. Execute Phase 1 tasks
# 2. Run Phase 1 exit gates
# 3. If gates pass → proceed to Phase 2
# 4. If gates fail → halt and report
```

## Integration with /plan

When generating project plans, `/plan` includes appropriate gates:

```markdown
/plan saas-mvp my-app --gates=strict

# Options:
# --gates=strict   → All gates blocking
# --gates=standard → Default severities
# --gates=relaxed  → More warnings, fewer blockers
# --gates=none     → No gates (not recommended)
```

## Remediation Guidance

Every gate failure includes actionable remediation:

| Gate Type | Common Failure | Remediation |
|-----------|---------------|-------------|
| `build` | Compilation error | Check error output, fix syntax issues |
| `test` | Test failure | Run `npm test` locally, fix failing tests |
| `lint` | Style violation | Run `npm run lint:fix` for auto-fixable |
| `security` | Vulnerability | Run `npm audit fix` or update packages |
| `review` | Pending approval | Request review from team lead |
| `deploy` | Deploy failure | Check deployment logs, verify env vars |

## Best Practices

1. **Start with minimal gates** and add more as project matures
2. **Never skip security gates** in production workflows
3. **Use warnings for new rules** before making them blocking
4. **Run gates locally** before pushing to catch issues early
5. **Keep gate commands fast** - slow gates slow development

## Schema Reference

Gate configurations must validate against:
`project/schemas/quality-gate.schema.yaml`

See schema for complete field definitions and validation rules.

## Troubleshooting

### Gate Timeout

If a gate command takes too long:

```json
{
  "checks": [
    {
      "type": "test",
      "command": "npm test",
      "timeout": 300
    }
  ]
}
```

### Skip Gates (Emergency Only)

```bash
/coord build project-plan.yaml --skip-gates
```

This is logged and should only be used in emergencies.

### Debug Mode

```bash
/coord build project-plan.yaml --gate-debug
```

Shows detailed gate execution with timing.
