# Schema Extensibility Guide v3.0

## Overview

This document defines how the AGENT-11 agent schema can evolve over time without breaking existing agents, supporting future enhancements while maintaining backward compatibility.

## Design Principles

1. **Optional by Default**: New fields must be optional
2. **Semantic Versioning**: Schema versions follow semver
3. **Graceful Degradation**: Missing fields use sensible defaults
4. **Custom Field Support**: `custom` object for experimental features
5. **Validation Levels**: Strict for core, lenient for extensions

## Extension Mechanisms

### 1. Custom Field Object

**Purpose**: Allow experimental or project-specific fields without schema changes

**Usage**:
```yaml
---
name: custom-agent
description: Agent with custom configuration
custom:
  # Any custom fields here
  special_mode: advanced
  integration_key: "abc123"
  feature_flags:
    - experimental_thinking
    - beta_tools
---
```

**Validation**: Custom object is not validated (freeform)

**Best Practices**:
- Document custom fields in agent markdown
- Prefix with project name to avoid conflicts: `myproject_feature`
- Promote to core schema if widely adopted

**Example Use Cases**:
```yaml
custom:
  # MCP profile recommendation
  mcp_profile: testing

  # Integration configurations
  slack_channel: "#agent-notifications"

  # Experimental features
  experimental:
    multi_agent_orchestration: true
    auto_context_switching: false

  # Performance hints
  performance:
    cache_ttl: 3600
    max_concurrent_tasks: 5
```

### 2. Schema Versioning

**Version Format**: Semantic Versioning (MAJOR.MINOR.PATCH)

**Version Semantics**:
- **MAJOR (3.x.x → 4.x.x)**: Breaking changes, field removals, type changes
- **MINOR (3.0.x → 3.1.x)**: New optional fields, enum value additions
- **PATCH (3.0.0 → 3.0.1)**: Documentation updates, validation refinements

**Example Evolution**:
```yaml
# v3.0.0 - Current
---
name: agent
version: "3.0.0"
tools:
  primary: ["Read"]
---

# v3.1.0 - Add optional context_editing field
---
name: agent
version: "3.1.0"
tools:
  primary: ["Read"]
context_editing:
  enabled: true
  trigger_threshold: 30000
---

# v4.0.0 - Breaking change (new field required)
---
name: agent
version: "4.0.0"
security_level: restricted  # NEW REQUIRED FIELD
tools:
  primary: ["Read"]
---
```

**Version Detection**:
```javascript
function getSchemaVersion(frontmatter) {
  const version = frontmatter.version || '1.0.0';
  const [major, minor, patch] = version.split('.').map(Number);

  return { major, minor, patch, string: version };
}

function isCompatible(agentVersion, schemaVersion) {
  const agent = getSchemaVersion({ version: agentVersion });
  const schema = getSchemaVersion({ version: schemaVersion });

  // Same major version = compatible
  return agent.major === schema.major;
}
```

### 3. Enum Extensions

**Adding Values to Enums**: Safe (backward compatible)

**Example**:
```json
// v3.0.0
{
  "status": {
    "enum": ["stable", "beta", "experimental", "deprecated"]
  }
}

// v3.1.0 - Add "alpha"
{
  "status": {
    "enum": ["stable", "beta", "alpha", "experimental", "deprecated"]
  }
}
```

**Removing Enum Values**: Breaking change (requires major version bump)

### 4. Optional Field Addition

**Safe Extension Pattern**:
```json
// v3.0.0 schema
{
  "properties": {
    "name": { "type": "string" },
    "description": { "type": "string" }
  },
  "required": ["name", "description"]
}

// v3.1.0 - Add optional field
{
  "properties": {
    "name": { "type": "string" },
    "description": { "type": "string" },
    "dependencies": {
      "type": "array",
      "items": { "type": "string" }
    }
  },
  "required": ["name", "description"]
}
```

**Agent Example**:
```yaml
# v3.0.0 agent (still valid in v3.1.0)
---
name: developer
description: Full-stack specialist
---

# v3.1.0 agent (uses new field)
---
name: developer
description: Full-stack specialist
dependencies:  # NEW FIELD
  - architect
  - tester
---
```

### 5. Nested Object Extensions

**Safe Pattern**: Add optional nested objects

**Example**:
```yaml
# v3.0.0
---
name: agent
tools:
  primary: ["Read"]
---

# v3.1.0 - Add tool configuration
---
name: agent
tools:
  primary: ["Read"]
  config:  # NEW NESTED OBJECT
    timeout: 5000
    retry: true
---
```

**Implementation**:
```json
{
  "tools": {
    "type": "object",
    "properties": {
      "primary": { "type": "array" },
      "mcp": { "type": "array" },
      "restricted": { "type": "array" },
      "config": {  // NEW in v3.1.0
        "type": "object",
        "properties": {
          "timeout": { "type": "number" },
          "retry": { "type": "boolean" }
        }
      }
    }
  }
}
```

## Migration Strategies

### Adding New Optional Fields

**Steps**:
1. Add field to JSON Schema with optional flag
2. Update documentation with examples
3. Add default value in parser
4. Deploy with minor version bump (3.x → 3.y)

**Example**:
```javascript
// Parser handles missing field
const agentData = {
  ...parsed.frontmatter,
  newField: parsed.frontmatter.newField || defaultValue
};
```

### Deprecating Fields

**Deprecation Process**:
1. **v3.x.0**: Mark field as deprecated in docs, add warnings
2. **v3.x+1.0**: Emit deprecation warnings when field used
3. **v4.0.0**: Remove field (breaking change, major bump)

**Deprecation Warning**:
```javascript
if (frontmatter.deprecatedField !== undefined) {
  console.warn(`
⚠️  Deprecated field 'deprecatedField' used in ${agentFile}
    This field will be removed in v4.0.0
    Use 'newField' instead
    See migration guide: /docs/MIGRATION-GUIDE.md
  `);
}
```

### Renaming Fields

**Safe Rename Pattern**: Support both old and new names

```javascript
// Support old name with alias
const agentData = {
  newFieldName: frontmatter.newFieldName || frontmatter.oldFieldName
};

if (frontmatter.oldFieldName !== undefined) {
  console.warn(`Field 'oldFieldName' deprecated, use 'newFieldName'`);
}
```

**Example**:
```yaml
# Old format (still works)
---
name: agent
escalation_target: "@coordinator"  # OLD
---

# New format (preferred)
---
name: agent
escalates_to: "@coordinator"  # NEW
---

# Both work during transition (v3.x)
```

## Extension Examples

### Example 1: Adding Context Editing Configuration

**v3.1.0 Enhancement**:
```yaml
---
name: developer
description: Full-stack specialist
version: "3.1.0"

# NEW: Context editing configuration
context_editing:
  enabled: true
  trigger_threshold: 30000  # tokens
  preserve_last_n_tools: 3
  exclude_tools: ["memory"]
---
```

**Schema Update**:
```json
{
  "context_editing": {
    "type": "object",
    "description": "Context editing configuration",
    "properties": {
      "enabled": { "type": "boolean", "default": true },
      "trigger_threshold": { "type": "number", "default": 30000 },
      "preserve_last_n_tools": { "type": "number", "default": 3 },
      "exclude_tools": {
        "type": "array",
        "items": { "type": "string" }
      }
    },
    "additionalProperties": false
  }
}
```

### Example 2: Adding MCP Profile Hints

**v3.1.0 Enhancement**:
```yaml
---
name: tester
description: QA specialist
version: "3.1.0"

# NEW: MCP profile recommendation
mcp_hints:
  recommended_profile: testing
  required_mcps:
    - mcp__playwright
  optional_mcps:
    - mcp__context7
---
```

### Example 3: Adding Performance Hints

**v3.2.0 Enhancement**:
```yaml
---
name: coordinator
description: Mission orchestrator
version: "3.2.0"

# NEW: Performance optimization hints
performance:
  max_concurrent_tasks: 5
  cache_ttl: 3600
  lazy_load: true
  preload: ["developer", "tester"]
---
```

### Example 4: Adding Security Constraints

**v3.3.0 Enhancement**:
```yaml
---
name: developer
description: Full-stack specialist
version: "3.3.0"

# NEW: Security configuration
security:
  sandbox_mode: false
  require_approval_for:
    - database_writes
    - external_api_calls
  audit_log: true
---
```

## Testing Extensions

### Extension Compatibility Test

```javascript
// tests/schema-extensions.test.js
describe('Schema Extensions', () => {
  it('should handle missing optional fields gracefully', () => {
    const minimal = {
      name: 'agent',
      description: 'Test'
    };

    const parsed = parser.parse(minimal);

    // Should have default values
    expect(parsed.context_editing).toBeDefined();
    expect(parsed.context_editing.enabled).toBe(true);
  });

  it('should support custom fields', () => {
    const withCustom = {
      name: 'agent',
      description: 'Test',
      custom: {
        special_feature: true,
        integration: 'slack'
      }
    };

    const parsed = parser.parse(withCustom);

    expect(parsed.custom.special_feature).toBe(true);
    expect(parsed.custom.integration).toBe('slack');
  });

  it('should maintain backward compatibility', () => {
    const v1Agent = {
      name: 'agent',
      description: 'Test',
      color: 'blue'
    };

    const v3Agent = {
      name: 'agent',
      description: 'Test',
      version: '3.0.0',
      color: 'blue',
      tools: {
        primary: ['Read']
      }
    };

    // Both should parse successfully
    expect(() => parser.parse(v1Agent)).not.toThrow();
    expect(() => parser.parse(v3Agent)).not.toThrow();
  });
});
```

## Extension Governance

### Proposal Process

1. **RFC (Request for Comments)**:
   - Create issue with `schema-extension` label
   - Describe proposed field and use case
   - Provide examples and rationale

2. **Community Review**:
   - Minimum 2-week review period
   - Gather feedback from users
   - Identify potential conflicts

3. **Implementation**:
   - Update JSON Schema
   - Update parser with defaults
   - Update documentation
   - Add tests

4. **Release**:
   - Minor version bump (3.x → 3.y)
   - Update changelog
   - Migration guide if needed

### Extension Criteria

**Approve if**:
- ✅ Broadly useful across multiple agents
- ✅ Clear use case and examples
- ✅ Backward compatible (optional)
- ✅ Well-defined validation rules
- ✅ Documented with examples

**Reject if**:
- ❌ Project-specific (use `custom` instead)
- ❌ Breaking change (wait for major version)
- ❌ Overlaps with existing field
- ❌ Poorly defined or ambiguous
- ❌ Low adoption potential

## Versioning Best Practices

### For Schema Maintainers

- **Add fields as optional** - easier to make required later than vice versa
- **Document deprecations early** - give users time to migrate
- **Maintain backward compatibility** - users should never be forced to update
- **Test thoroughly** - ensure old agents work with new schema

### For Agent Authors

- **Specify version** - helps parser understand which features are available
- **Use custom for experiments** - don't wait for schema changes
- **Update incrementally** - adopt new fields as they're useful
- **Test compatibility** - ensure agent works across schema versions

## Future Extensions (Proposed)

### Under Consideration for v3.x

```yaml
# Proposed: Agent relationships
relationships:
  replaces: ["old-agent"]
  superseded_by: ["new-agent"]
  similar_to: ["related-agent"]

# Proposed: Execution constraints
constraints:
  max_execution_time: 300  # seconds
  max_memory: 512  # MB
  required_environment:
    - nodejs: ">=18"

# Proposed: Telemetry
telemetry:
  track_performance: true
  track_errors: true
  track_usage: true

# Proposed: Internationalization
i18n:
  supported_languages: ["en", "es", "fr"]
  default_language: "en"
```

## References

- **JSON Schema Spec**: https://json-schema.org/
- **Semantic Versioning**: https://semver.org/
- **Schema Definition**: `/schema/agent-schema.json`
- **Parser Implementation**: `/scripts/agent-parser.js`
- **Extension Tests**: `/tests/schema-extensions.test.js`
- **RFC Template**: `/docs/RFC-TEMPLATE.md`

---

**Version**: 3.0.0
**Status**: Draft - Pending Developer Implementation
**Author**: @architect
**Date**: 2025-10-30
