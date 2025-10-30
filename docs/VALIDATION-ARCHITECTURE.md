# Validation Architecture Specification v3.0

## Overview

This document specifies the three-layer validation architecture for AGENT-11 agent definitions, designed to ensure schema compliance, semantic correctness, and content quality while maintaining <100ms performance overhead.

## Architecture Principles

1. **Layered Validation**: Three progressive layers with increasing depth
2. **Fast Feedback**: Pre-commit hooks for instant developer feedback
3. **Comprehensive Coverage**: CI/CD for full validation suite
4. **Performance Target**: <100ms total validation time per agent
5. **Clear Error Messages**: Actionable feedback with fix suggestions
6. **Progressive Enhancement**: Optional layers for deeper validation

## Validation Layers

### Layer 1: Schema Validation (Pre-Commit Hook)

**Purpose**: Fast YAML syntax and type checking before commit

**What it validates**:
- ✅ YAML syntax is valid
- ✅ Required fields present (`name`, `description`)
- ✅ Field types correct (string, array, object, boolean)
- ✅ Enum values valid (`status`, `thinking.default`)
- ✅ Pattern matching (semantic versioning, tool names)
- ✅ No duplicate tool names across lists

**Performance Target**: <10ms per agent

**Implementation**:
```javascript
// validate-schema.js
const Ajv = require('ajv');
const addFormats = require('ajv-formats');
const yaml = require('js-yaml');
const fs = require('fs');

class SchemaValidator {
  constructor(schemaPath) {
    this.ajv = new Ajv({
      allErrors: true,
      strict: false,
      validateFormats: true
    });
    addFormats(this.ajv);

    const schema = JSON.parse(fs.readFileSync(schemaPath, 'utf8'));
    this.validate = this.ajv.compile(schema);
  }

  validateFile(agentFile) {
    const startTime = performance.now();

    try {
      const content = fs.readFileSync(agentFile, 'utf8');
      const parts = content.split('---\n');

      // Check for frontmatter
      if (parts.length < 3) {
        return {
          valid: false,
          errors: [{
            message: 'No YAML frontmatter found',
            fix: 'Add YAML frontmatter between --- delimiters at file start'
          }]
        };
      }

      // Parse YAML
      let frontmatter;
      try {
        frontmatter = yaml.load(parts[1]);
      } catch (yamlError) {
        return {
          valid: false,
          errors: [{
            message: `YAML parse error: ${yamlError.message}`,
            line: yamlError.mark?.line,
            fix: 'Fix YAML syntax error'
          }]
        };
      }

      // Validate against schema
      const valid = this.validate(frontmatter);

      if (!valid) {
        return {
          valid: false,
          errors: this.formatErrors(this.validate.errors),
          performance: performance.now() - startTime
        };
      }

      // Check for duplicate tools
      const duplicateErrors = this.checkDuplicateTools(frontmatter);
      if (duplicateErrors.length > 0) {
        return {
          valid: false,
          errors: duplicateErrors,
          performance: performance.now() - startTime
        };
      }

      return {
        valid: true,
        performance: performance.now() - startTime
      };

    } catch (error) {
      return {
        valid: false,
        errors: [{
          message: `Validation error: ${error.message}`,
          fix: 'Check file format and syntax'
        }]
      };
    }
  }

  formatErrors(errors) {
    return errors.map(err => {
      const field = err.instancePath || err.dataPath;
      const message = err.message;

      // Generate helpful fix suggestions
      let fix = '';
      switch (err.keyword) {
        case 'required':
          fix = `Add required field: ${err.params.missingProperty}`;
          break;
        case 'type':
          fix = `Change ${field} to type: ${err.params.type}`;
          break;
        case 'enum':
          fix = `Use one of: ${err.params.allowedValues.join(', ')}`;
          break;
        case 'pattern':
          fix = `Match pattern: ${err.params.pattern}`;
          break;
        default:
          fix = `Fix validation error for ${field}`;
      }

      return {
        field,
        message,
        fix,
        schema: err.schemaPath
      };
    });
  }

  checkDuplicateTools(frontmatter) {
    if (!frontmatter.tools) return [];

    const { primary = [], mcp = [], restricted = [] } = frontmatter.tools;
    const allTools = [...primary, ...mcp, ...restricted];
    const seen = new Set();
    const duplicates = [];

    allTools.forEach(tool => {
      if (seen.has(tool)) {
        duplicates.push({
          field: 'tools',
          message: `Duplicate tool: ${tool}`,
          fix: `Remove duplicate '${tool}' from tool lists`
        });
      }
      seen.add(tool);
    });

    return duplicates;
  }
}

module.exports = SchemaValidator;
```

**Pre-Commit Hook**:
```bash
#!/bin/bash
# .git/hooks/pre-commit

# Check if any agent files are being committed
AGENT_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep "project/agents/specialists/.*\.md$")

if [ -z "$AGENT_FILES" ]; then
  exit 0
fi

echo "🔍 Validating agent schemas..."

# Run schema validation
node scripts/validate-agents.js --layer=schema $AGENT_FILES

if [ $? -ne 0 ]; then
  echo ""
  echo "❌ Schema validation failed!"
  echo "Fix errors above before committing."
  echo ""
  echo "💡 Tip: Run 'npm run validate:agents' to see detailed errors"
  exit 1
fi

echo "✅ Schema validation passed"
exit 0
```

### Layer 2: Semantic Validation (CI/CD)

**Purpose**: Cross-reference validation and consistency checks

**What it validates**:
- ✅ Tool names exist in tool registry (warning if not found)
- ✅ Agent names in `coordinates_with` exist in agent registry
- ✅ Version numbers follow semantic versioning
- ✅ No broken cross-references
- ✅ Status field matches agent maturity
- ✅ Deprecated agents have escalation alternatives

**Performance Target**: <30ms per agent

**Implementation**:
```javascript
// validate-semantics.js
class SemanticValidator {
  constructor(toolRegistryPath, agentRegistryPath) {
    this.toolRegistry = this.loadRegistry(toolRegistryPath);
    this.agentRegistry = this.loadRegistry(agentRegistryPath);
  }

  loadRegistry(path) {
    const content = fs.readFileSync(path, 'utf8');
    return new Set(JSON.parse(content));
  }

  validateFile(agentFile, frontmatter) {
    const errors = [];
    const warnings = [];

    // Validate tools exist
    if (frontmatter.tools) {
      const toolErrors = this.validateTools(frontmatter.tools);
      errors.push(...toolErrors.errors);
      warnings.push(...toolErrors.warnings);
    }

    // Validate agent references
    if (frontmatter.coordinates_with) {
      const coordErrors = this.validateCoordination(frontmatter.coordinates_with);
      errors.push(...coordErrors);
    }

    // Validate version format
    if (frontmatter.version) {
      const versionErrors = this.validateVersion(frontmatter.version);
      errors.push(...versionErrors);
    }

    // Validate status consistency
    const statusErrors = this.validateStatus(frontmatter);
    warnings.push(...statusErrors);

    return {
      valid: errors.length === 0,
      errors,
      warnings
    };
  }

  validateTools(tools) {
    const errors = [];
    const warnings = [];

    const checkToolList = (list, category) => {
      list?.forEach(tool => {
        if (!this.toolRegistry.has(tool)) {
          // MCP tools may be custom, so just warn
          if (tool.startsWith('mcp__')) {
            warnings.push({
              field: `tools.${category}`,
              message: `Unknown MCP tool: ${tool}`,
              fix: `Verify '${tool}' is a valid MCP or add to tool registry`,
              severity: 'warning'
            });
          } else {
            errors.push({
              field: `tools.${category}`,
              message: `Unknown tool: ${tool}`,
              fix: `Use a valid tool name or add '${tool}' to tool registry`,
              severity: 'error'
            });
          }
        }
      });
    };

    checkToolList(tools.primary, 'primary');
    checkToolList(tools.mcp, 'mcp');
    checkToolList(tools.restricted, 'restricted');

    return { errors, warnings };
  }

  validateCoordination(coordinates) {
    const errors = [];

    coordinates.forEach(agent => {
      if (!this.agentRegistry.has(agent)) {
        errors.push({
          field: 'coordinates_with',
          message: `Unknown agent: ${agent}`,
          fix: `Use a valid agent name from: ${Array.from(this.agentRegistry).join(', ')}`,
          severity: 'error'
        });
      }
    });

    return errors;
  }

  validateVersion(version) {
    const errors = [];

    // Semantic versioning pattern
    const semverPattern = /^\d+\.\d+\.\d+$/;

    if (!semverPattern.test(version)) {
      errors.push({
        field: 'version',
        message: `Invalid semantic version: ${version}`,
        fix: 'Use format: MAJOR.MINOR.PATCH (e.g., "3.0.0")',
        severity: 'error'
      });
    }

    return errors;
  }

  validateStatus(frontmatter) {
    const warnings = [];

    // Deprecated agents should have alternatives
    if (frontmatter.status === 'deprecated' && !frontmatter.custom?.alternative) {
      warnings.push({
        field: 'status',
        message: 'Deprecated agent should specify alternative',
        fix: 'Add custom.alternative: "agent-name" to frontmatter',
        severity: 'warning'
      });
    }

    // Experimental agents should be versioned <1.0.0
    if (frontmatter.status === 'experimental') {
      const version = frontmatter.version || '1.0.0';
      const [major] = version.split('.');
      if (parseInt(major) >= 1) {
        warnings.push({
          field: 'status',
          message: 'Experimental agents should use version <1.0.0',
          fix: 'Set version to "0.x.x" for experimental status',
          severity: 'warning'
        });
      }
    }

    return warnings;
  }
}

module.exports = SemanticValidator;
```

### Layer 3: Content Validation (CI/CD)

**Purpose**: Ensure markdown content completeness and quality

**What it validates**:
- ✅ Required markdown sections exist
- ✅ Tool permissions have detailed explanations
- ✅ Internal links are not broken
- ✅ Code examples are valid syntax
- ✅ Verification checklists are present (if required)
- ✅ Context preservation protocol exists

**Performance Target**: <60ms per agent

**Implementation**:
```javascript
// validate-content.js
class ContentValidator {
  validateFile(agentFile, frontmatter) {
    const errors = [];
    const warnings = [];

    const content = fs.readFileSync(agentFile, 'utf8');

    // Check required sections
    const sectionErrors = this.validateSections(content, frontmatter);
    errors.push(...sectionErrors);

    // Check internal links
    const linkErrors = this.validateLinks(content);
    warnings.push(...linkErrors);

    // Check tool explanations
    if (frontmatter.tools) {
      const toolDocErrors = this.validateToolDocumentation(content, frontmatter.tools);
      warnings.push(...toolDocErrors);
    }

    // Check verification protocols
    if (frontmatter.verification_required) {
      const verificationErrors = this.validateVerification(content);
      errors.push(...verificationErrors);
    }

    return {
      valid: errors.length === 0,
      errors,
      warnings
    };
  }

  validateSections(content, frontmatter) {
    const errors = [];

    const requiredSections = [
      {
        heading: '## CONTEXT PRESERVATION PROTOCOL',
        required: true,
        fix: 'Add CONTEXT PRESERVATION PROTOCOL section with handoff guidelines'
      },
      {
        heading: '## TOOL PERMISSIONS',
        required: frontmatter.tools !== undefined,
        fix: 'Add TOOL PERMISSIONS section explaining tool usage'
      },
      {
        heading: '## SELF-VERIFICATION PROTOCOL',
        required: frontmatter.self_verification === true,
        fix: 'Add SELF-VERIFICATION PROTOCOL section with quality checklist'
      },
      {
        heading: '## EXTENDED THINKING GUIDANCE',
        required: frontmatter.thinking !== undefined,
        fix: 'Add EXTENDED THINKING GUIDANCE section with thinking modes'
      },
      {
        heading: '## CONTEXT EDITING GUIDANCE',
        required: true,
        fix: 'Add CONTEXT EDITING GUIDANCE section with /clear usage'
      }
    ];

    requiredSections.forEach(({ heading, required, fix }) => {
      if (required && !content.includes(heading)) {
        errors.push({
          section: heading,
          message: `Missing required section: ${heading}`,
          fix,
          severity: 'error'
        });
      }
    });

    return errors;
  }

  validateLinks(content) {
    const errors = [];

    // Find all markdown links
    const linkPattern = /\[([^\]]+)\]\(([^)]+)\)/g;
    const matches = content.matchAll(linkPattern);

    for (const match of matches) {
      const [, text, url] = match;

      // Check internal file links
      if (url.startsWith('/') || url.startsWith('.')) {
        const fullPath = path.resolve(path.dirname(agentFile), url);
        if (!fs.existsSync(fullPath)) {
          errors.push({
            link: url,
            message: `Broken internal link: ${url}`,
            fix: `Create file at ${url} or fix link`,
            severity: 'warning'
          });
        }
      }
    }

    return errors;
  }

  validateToolDocumentation(content, tools) {
    const warnings = [];

    // Check if TOOL PERMISSIONS section has explanations
    const toolSection = this.extractSection(content, '## TOOL PERMISSIONS');

    if (!toolSection) return warnings;

    // Check primary tools are documented
    tools.primary?.forEach(tool => {
      if (!toolSection.includes(tool)) {
        warnings.push({
          tool,
          message: `Primary tool '${tool}' not documented in TOOL PERMISSIONS section`,
          fix: `Add explanation for why ${tool} is essential`,
          severity: 'warning'
        });
      }
    });

    return warnings;
  }

  validateVerification(content) {
    const errors = [];

    const verificationSection = this.extractSection(content, '## SELF-VERIFICATION PROTOCOL');

    if (!verificationSection) {
      return [{
        section: 'SELF-VERIFICATION PROTOCOL',
        message: 'verification_required is true but section is missing',
        fix: 'Add SELF-VERIFICATION PROTOCOL section with Pre-Handoff Checklist',
        severity: 'error'
      }];
    }

    // Check for checklist
    if (!verificationSection.includes('Pre-Handoff Checklist')) {
      errors.push({
        section: 'SELF-VERIFICATION PROTOCOL',
        message: 'Missing Pre-Handoff Checklist',
        fix: 'Add **Pre-Handoff Checklist** subsection',
        severity: 'error'
      });
    }

    return errors;
  }

  extractSection(content, heading) {
    const headingIndex = content.indexOf(heading);
    if (headingIndex === -1) return null;

    // Find next ## heading or end of file
    const nextHeadingPattern = /\n##\s/g;
    nextHeadingPattern.lastIndex = headingIndex + heading.length;
    const nextMatch = nextHeadingPattern.exec(content);

    const endIndex = nextMatch ? nextMatch.index : content.length;
    return content.substring(headingIndex, endIndex);
  }
}

module.exports = ContentValidator;
```

## Error Reporting

### Error Message Format

**Console Output**:
```
❌ Validation failed for: project/agents/specialists/coordinator.md

Schema Errors (Layer 1):
  ✗ Field 'tools.primary' - Expected array, got string
    Fix: Change tools.primary to an array: ["Read", "Write"]

  ✗ Field 'status' - Must be one of: stable, beta, experimental, deprecated
    Fix: Use one of the allowed values

Semantic Warnings (Layer 2):
  ⚠ Field 'tools.mcp' - Unknown MCP tool: mcp__custom_tool
    Fix: Verify 'mcp__custom_tool' is a valid MCP or add to tool registry

Content Errors (Layer 3):
  ✗ Missing required section: ## TOOL PERMISSIONS
    Fix: Add TOOL PERMISSIONS section explaining tool usage

Performance: 45ms
```

**JSON Output** (for CI/CD):
```json
{
  "file": "project/agents/specialists/coordinator.md",
  "valid": false,
  "performance": 45,
  "layers": {
    "schema": {
      "valid": false,
      "errors": [
        {
          "field": "tools.primary",
          "message": "Expected array, got string",
          "fix": "Change tools.primary to an array: [\"Read\", \"Write\"]",
          "severity": "error"
        }
      ]
    },
    "semantics": {
      "valid": true,
      "warnings": [
        {
          "field": "tools.mcp",
          "message": "Unknown MCP tool: mcp__custom_tool",
          "fix": "Verify 'mcp__custom_tool' is a valid MCP or add to tool registry",
          "severity": "warning"
        }
      ]
    },
    "content": {
      "valid": false,
      "errors": [
        {
          "section": "## TOOL PERMISSIONS",
          "message": "Missing required section: ## TOOL PERMISSIONS",
          "fix": "Add TOOL PERMISSIONS section explaining tool usage",
          "severity": "error"
        }
      ]
    }
  }
}
```

## CI/CD Integration

### GitHub Actions Workflow

```yaml
# .github/workflows/validate-agents.yml
name: Validate Agent Schemas

on:
  push:
    paths:
      - 'project/agents/specialists/**/*.md'
      - 'schema/agent-schema.json'
  pull_request:
    paths:
      - 'project/agents/specialists/**/*.md'
      - 'schema/agent-schema.json'

jobs:
  validate:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install dependencies
        run: npm ci

      - name: Run validation
        id: validate
        run: |
          node scripts/validate-agents.js --all --format=json > validation-results.json
          echo "results=$(cat validation-results.json)" >> $GITHUB_OUTPUT

      - name: Report results
        if: failure()
        uses: actions/github-script@v6
        with:
          script: |
            const results = JSON.parse('${{ steps.validate.outputs.results }}');
            const failures = results.filter(r => !r.valid);

            const body = failures.map(f => {
              const errors = [
                ...f.layers.schema.errors || [],
                ...f.layers.semantics.errors || [],
                ...f.layers.content.errors || []
              ];

              return `### ❌ ${f.file}\\n\\n${errors.map(e =>
                `- **${e.field || e.section}**: ${e.message}\\n  Fix: ${e.fix}`
              ).join('\\n')}`;
            }).join('\\n\\n---\\n\\n');

            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `## Agent Validation Results\\n\\n${body}`
            });

      - name: Upload results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: validation-results
          path: validation-results.json
```

## Validation CLI

### Usage Examples

```bash
# Validate single agent (all layers)
npm run validate:agent project/agents/specialists/coordinator.md

# Validate all agents
npm run validate:agents

# Validate specific layer only
npm run validate:agents --layer=schema
npm run validate:agents --layer=semantics
npm run validate:agents --layer=content

# JSON output for CI/CD
npm run validate:agents --format=json

# Verbose mode
npm run validate:agents --verbose

# Watch mode for development
npm run validate:agents --watch
```

### NPM Scripts

```json
{
  "scripts": {
    "validate:agent": "node scripts/validate-agents.js",
    "validate:agents": "node scripts/validate-agents.js --all",
    "validate:watch": "nodemon --watch project/agents/specialists --exec 'npm run validate:agents'",
    "validate:pre-commit": "node scripts/validate-agents.js --layer=schema --staged"
  }
}
```

## Performance Monitoring

### Performance Targets

| Layer | Target | Acceptable | Critical |
|-------|--------|------------|----------|
| Schema | <10ms | <20ms | >50ms |
| Semantics | <30ms | <50ms | >100ms |
| Content | <60ms | <100ms | >200ms |
| **Total** | **<100ms** | **<150ms** | **>300ms** |

### Performance Tracking

```javascript
// Track validation performance
class PerformanceMonitor {
  trackValidation(file, layer, duration) {
    if (duration > this.targets[layer].critical) {
      console.warn(`⚠️ ${layer} validation for ${file} took ${duration}ms (critical threshold: ${this.targets[layer].critical}ms)`);
    }
  }

  generateReport() {
    // Generate performance report for CI/CD
  }
}
```

## Extensibility

### Adding New Validation Rules

```javascript
// Custom validation plugin
class CustomValidator {
  constructor() {
    this.name = 'custom-rule-name';
  }

  validate(frontmatter, content) {
    // Custom validation logic
    return {
      valid: true,
      errors: [],
      warnings: []
    };
  }
}

// Register custom validator
validatorRegistry.register(new CustomValidator());
```

## References

- **JSON Schema**: `/schema/agent-schema.json`
- **Tool Registry**: `/project/deployment/tool-registry.json`
- **Agent Registry**: Generated from `/project/agents/specialists/*.md`
- **Validation Scripts**: `/scripts/validate-agents.js`
- **Pre-Commit Hook**: `.git/hooks/pre-commit`
- **GitHub Actions**: `.github/workflows/validate-agents.yml`

---

**Version**: 3.0.0
**Status**: Draft - Pending Developer Implementation
**Author**: @architect
**Date**: 2025-10-30
