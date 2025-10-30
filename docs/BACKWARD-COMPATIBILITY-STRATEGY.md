# Backward Compatibility Strategy v3.0

## Overview

This document defines the backward compatibility strategy for migrating AGENT-11 agents from the legacy format (v1.0-v2.x) to the new YAML frontmatter schema (v3.0), ensuring **ZERO breaking changes** to existing missions and workflows.

## Critical Constraint

**NON-NEGOTIABLE**: All 19 existing missions MUST continue working without modification during and after the migration.

## Design Principles

1. **Dual Parsing**: Support both old and new formats simultaneously
2. **Graceful Degradation**: Missing fields use sensible defaults
3. **Gradual Migration**: 2+ release cycles before deprecation
4. **Clear Communication**: Deprecation warnings with actionable guidance
5. **No Data Loss**: All existing agent functionality preserved
6. **Zero Downtime**: Seamless transition for users

## Format Detection

### Legacy Format Detection (v1.0-v2.x)

**Legacy Format Indicators**:
- Frontmatter contains ONLY: `name`, `description`, `color`
- No `version` field
- No `tools` object
- May have NO frontmatter at all (pure markdown)

**Example Legacy Format**:
```yaml
---
name: coordinator
description: Use this agent to orchestrate complex multi-agent missions
color: green
---
```

### New Format Detection (v3.0+)

**New Format Indicators**:
- Frontmatter contains `version` field
- Frontmatter contains `tools` object
- Follows new schema structure

**Example New Format**:
```yaml
---
name: coordinator
description: Use this agent to orchestrate complex multi-agent missions
version: "3.0.0"
status: stable
color: green

tools:
  primary: ["Task", "TodoWrite", "Write", "Read"]
  mcp: ["mcp__github"]
  restricted: ["Bash", "MultiEdit"]
---
```

## Dual Parsing Implementation

### Parser Architecture

```javascript
// agent-parser.js
const fs = require('fs');
const yaml = require('js-yaml');

class AgentParser {
  constructor() {
    this.schemaVersion = '3.0.0';
    this.logger = console;
  }

  /**
   * Parse agent file with automatic format detection
   * @param {string} agentFile - Path to agent markdown file
   * @returns {Object} Parsed agent data
   */
  parse(agentFile) {
    const content = fs.readFileSync(agentFile, 'utf8');

    // Check for YAML frontmatter
    const parts = content.split('---\n');

    if (parts.length >= 3) {
      // Has frontmatter - parse it
      try {
        const frontmatter = yaml.load(parts[1]);
        const markdown = parts.slice(2).join('---\n');

        // Detect format version
        if (this.isNewFormat(frontmatter)) {
          return this.parseNewFormat(frontmatter, markdown, agentFile);
        } else {
          this.warnLegacyFormat(agentFile, frontmatter);
          return this.parseLegacyFormat(frontmatter, markdown, agentFile);
        }
      } catch (yamlError) {
        this.logger.error(`YAML parse error in ${agentFile}:`, yamlError.message);
        // Fallback to pure markdown
        return this.parsePureMarkdown(content, agentFile);
      }
    } else {
      // No frontmatter - pure markdown (very old format)
      this.warnPureMarkdown(agentFile);
      return this.parsePureMarkdown(content, agentFile);
    }
  }

  /**
   * Detect if frontmatter uses new schema format
   * @param {Object} frontmatter - Parsed YAML frontmatter
   * @returns {boolean} True if new format
   */
  isNewFormat(frontmatter) {
    // New format has version field or tools object
    return !!(frontmatter.version || frontmatter.tools);
  }

  /**
   * Parse agent using new v3.0 schema format
   */
  parseNewFormat(frontmatter, markdown, filePath) {
    return {
      format: 'yaml-v3',
      source: filePath,
      metadata: {
        name: frontmatter.name,
        description: frontmatter.description,
        version: frontmatter.version || '1.0.0',
        status: frontmatter.status || 'stable',
        color: frontmatter.color,
        tags: frontmatter.tags || []
      },
      thinking: frontmatter.thinking || {
        default: 'think',
        when_to_use_deeper: null
      },
      tools: frontmatter.tools || {
        primary: [],
        mcp: [],
        restricted: []
      },
      coordination: {
        coordinates_with: frontmatter.coordinates_with || [],
        escalates_to: frontmatter.escalates_to || '@coordinator'
      },
      verification: {
        required: frontmatter.verification_required || false,
        self_verification: frontmatter.self_verification || false
      },
      custom: frontmatter.custom || {},
      markdown: markdown
    };
  }

  /**
   * Parse agent using legacy v1.0 format
   */
  parseLegacyFormat(frontmatter, markdown, filePath) {
    return {
      format: 'yaml-v1-legacy',
      source: filePath,
      metadata: {
        name: frontmatter.name,
        description: frontmatter.description,
        version: '1.0.0', // Default for legacy
        status: 'stable', // Assume stable if in production
        color: frontmatter.color,
        tags: this.inferTags(frontmatter.name)
      },
      thinking: {
        default: this.inferDefaultThinking(frontmatter.name),
        when_to_use_deeper: null
      },
      tools: this.extractToolsFromMarkdown(markdown, frontmatter.name),
      coordination: {
        coordinates_with: this.inferCoordination(frontmatter.name),
        escalates_to: '@coordinator'
      },
      verification: {
        required: this.hasVerificationSection(markdown),
        self_verification: this.hasSelfVerification(markdown)
      },
      custom: {},
      markdown: markdown,
      _legacy: true,
      _migration_needed: true
    };
  }

  /**
   * Parse pure markdown without frontmatter (oldest format)
   */
  parsePureMarkdown(content, filePath) {
    const name = this.extractNameFromMarkdown(content, filePath);

    return {
      format: 'markdown-only-legacy',
      source: filePath,
      metadata: {
        name: name,
        description: this.extractDescription(content) || 'Legacy agent - needs migration',
        version: '0.9.0', // Pre-standardization
        status: 'deprecated',
        color: 'gray',
        tags: ['legacy']
      },
      thinking: {
        default: 'think',
        when_to_use_deeper: null
      },
      tools: this.extractToolsFromMarkdown(content, name),
      coordination: {
        coordinates_with: [],
        escalates_to: '@coordinator'
      },
      verification: {
        required: false,
        self_verification: false
      },
      custom: {},
      markdown: content,
      _legacy: true,
      _migration_urgent: true
    };
  }

  /**
   * Infer agent tags from name (backward compat)
   */
  inferTags(agentName) {
    const tagMap = {
      'coordinator': ['core', 'coordination'],
      'developer': ['core', 'technical'],
      'architect': ['core', 'technical', 'design'],
      'tester': ['core', 'qa'],
      'strategist': ['core', 'analysis'],
      'designer': ['creative', 'design'],
      'documenter': ['creative', 'content'],
      'operator': ['ops', 'technical'],
      'analyst': ['analysis', 'data'],
      'marketer': ['creative', 'growth'],
      'support': ['support', 'customer']
    };

    return tagMap[agentName] || [];
  }

  /**
   * Infer default thinking mode from agent role
   */
  inferDefaultThinking(agentName) {
    const thinkingMap = {
      'architect': 'ultrathink',
      'strategist': 'think harder',
      'coordinator': 'think hard',
      'developer': 'think',
      'tester': 'think',
      'designer': 'think hard'
    };

    return thinkingMap[agentName] || 'think';
  }

  /**
   * Extract tools from markdown TOOL PERMISSIONS section
   */
  extractToolsFromMarkdown(markdown, agentName) {
    const primary = [];
    const mcp = [];
    const restricted = [];

    // Find TOOL PERMISSIONS section
    const toolSectionMatch = markdown.match(/## TOOL PERMISSIONS[\s\S]*?(?=##|$)/);

    if (toolSectionMatch) {
      const toolSection = toolSectionMatch[0];

      // Extract primary tools
      const primaryMatch = toolSection.match(/\*\*Primary Tools[^\*]*\*\*:[\s\S]*?(?=\*\*|$)/);
      if (primaryMatch) {
        const tools = primaryMatch[0].match(/- \*\*(\w+)\*\*/g);
        if (tools) {
          primary.push(...tools.map(t => t.match(/\*\*(\w+)\*\*/)[1]));
        }
      }

      // Extract MCP tools
      const mcpMatch = toolSection.match(/\*\*MCP Tools[^\*]*\*\*:[\s\S]*?(?=\*\*|$)/);
      if (mcpMatch) {
        const tools = mcpMatch[0].match(/- \*\*(mcp__\w+)\*\*/g);
        if (tools) {
          mcp.push(...tools.map(t => t.match(/\*\*(mcp__\w+)\*\*/)[1]));
        }
      }

      // Extract restricted tools
      const restrictedMatch = toolSection.match(/\*\*Restricted Tools[^\*]*\*\*:[\s\S]*?(?=\*\*|$)/);
      if (restrictedMatch) {
        const tools = restrictedMatch[0].match(/- \*\*(\w+|mcp__\w+)\*\*/g);
        if (tools) {
          restricted.push(...tools.map(t => t.match(/\*\*(\w+|mcp__\w+)\*\*/)[1]));
        }
      }
    }

    // Fallback to defaults if extraction failed
    if (primary.length === 0) {
      primary.push(...this.getDefaultTools(agentName));
    }

    return { primary, mcp, restricted };
  }

  /**
   * Get default tools for agent if not specified
   */
  getDefaultTools(agentName) {
    const defaults = {
      'coordinator': ['Task', 'TodoWrite', 'Write', 'Read', 'Edit'],
      'developer': ['Read', 'Write', 'Edit', 'Bash', 'Task'],
      'architect': ['Read', 'Write', 'Edit', 'Grep', 'Glob', 'Task'],
      'tester': ['Read', 'Bash', 'Grep', 'Glob', 'Task'],
      'strategist': ['Read', 'Grep', 'Glob', 'Task']
    };

    return defaults[agentName] || ['Read', 'Task'];
  }

  /**
   * Check if markdown has verification section
   */
  hasVerificationSection(markdown) {
    return markdown.includes('## SELF-VERIFICATION PROTOCOL');
  }

  /**
   * Check if verification section has actual content
   */
  hasSelfVerification(markdown) {
    const section = markdown.match(/## SELF-VERIFICATION PROTOCOL[\s\S]*?(?=##|$)/);
    if (!section) return false;

    // Check for checklist
    return section[0].includes('Pre-Handoff Checklist') || section[0].includes('- [ ]');
  }

  /**
   * Extract agent name from markdown content
   */
  extractNameFromMarkdown(content, filePath) {
    // Try to find "You are THE {NAME}" pattern
    const nameMatch = content.match(/You are THE (\w+)/i);
    if (nameMatch) {
      return nameMatch[1].toLowerCase();
    }

    // Fallback to filename
    const filename = filePath.split('/').pop().replace('.md', '');
    return filename;
  }

  /**
   * Extract description from markdown
   */
  extractDescription(content) {
    // Try to find first paragraph after frontmatter
    const firstParagraph = content.match(/^(?!#)([^\n]+)/m);
    return firstParagraph ? firstParagraph[1].trim() : null;
  }

  /**
   * Infer coordination relationships
   */
  inferCoordination(agentName) {
    const coordMap = {
      'developer': ['architect', 'tester', 'operator'],
      'architect': ['strategist', 'developer'],
      'tester': ['developer', 'designer'],
      'designer': ['strategist', 'developer'],
      'operator': ['developer', 'architect']
    };

    return coordMap[agentName] || [];
  }

  /**
   * Warn about legacy format usage
   */
  warnLegacyFormat(filePath, frontmatter) {
    if (process.env.NODE_ENV !== 'production') {
      this.logger.warn(`
⚠️  Legacy format detected: ${filePath}
    Current: v1.0 (name, description, color only)
    Upgrade to: v3.0 (structured schema)

    Run migration tool:
    npm run migrate:agent ${filePath}

    Legacy support will be deprecated in v4.0.0
      `);
    }
  }

  /**
   * Warn about pure markdown (no frontmatter)
   */
  warnPureMarkdown(filePath) {
    this.logger.warn(`
⚠️  URGENT: Pure markdown detected (no frontmatter): ${filePath}
    This format will not be supported in v4.0.0

    Migrate immediately:
    npm run migrate:agent ${filePath}
    `);
  }
}

module.exports = AgentParser;
```

## Migration Path

### Timeline

```
┌─────────────┬──────────────────────────────────────────────────────┐
│ Release     │ Support Status                                       │
├─────────────┼──────────────────────────────────────────────────────┤
│ v3.0.0      │ ✅ Full dual parsing support                        │
│ (Now)       │ ✅ New format optional                               │
│             │ ⚠️ Deprecation warnings (development only)          │
│             │ 📝 Migration guide published                         │
├─────────────┼──────────────────────────────────────────────────────┤
│ v3.1.0      │ ✅ Full dual parsing support                        │
│ (+3 months) │ ⚠️ Deprecation warnings (all environments)          │
│             │ 🛠️ Migration tool released                          │
│             │ 📚 Migration examples and tutorials                 │
├─────────────┼──────────────────────────────────────────────────────┤
│ v4.0.0      │ ⚠️ Legacy format deprecated                         │
│ (+6 months) │ ✅ Dual parsing still works                         │
│             │ ❌ Errors for legacy format (blocking)              │
│             │ 🔧 Auto-migration on startup (opt-in)               │
├─────────────┼──────────────────────────────────────────────────────┤
│ v5.0.0      │ ❌ Legacy format removed (if needed)                │
│ (+12 months)│ ✅ Only v3.0+ schema supported                      │
│             │ 🚀 New features require v3.0+ format                │
└─────────────┴──────────────────────────────────────────────────────┘
```

### Migration Tool

```javascript
// scripts/migrate-agent-schema.js
const fs = require('fs');
const yaml = require('js-yaml');
const AgentParser = require('./agent-parser');

class AgentMigrator {
  constructor() {
    this.parser = new AgentParser();
  }

  /**
   * Migrate agent file to new v3.0 format
   */
  migrate(agentFile, options = {}) {
    console.log(`🔄 Migrating ${agentFile}...`);

    // Parse with legacy support
    const parsed = this.parser.parse(agentFile);

    if (parsed.format === 'yaml-v3') {
      console.log(`✅ Already using v3.0 format`);
      return;
    }

    // Generate new frontmatter
    const newFrontmatter = this.generateFrontmatter(parsed);

    // Keep markdown content
    const markdown = parsed.markdown;

    // Write new format
    const newContent = `---\n${yaml.dump(newFrontmatter)}---\n${markdown}`;

    if (options.dryRun) {
      console.log('📄 Preview (dry run):\n');
      console.log(newContent.substring(0, 500) + '...\n');
      return;
    }

    // Backup original
    const backupFile = `${agentFile}.backup`;
    fs.copyFileSync(agentFile, backupFile);
    console.log(`💾 Backup saved: ${backupFile}`);

    // Write new format
    fs.writeFileSync(agentFile, newContent, 'utf8');
    console.log(`✅ Migrated to v3.0 format`);

    // Validate
    const validator = require('./validate-agents');
    const result = validator.validateFile(agentFile);

    if (result.valid) {
      console.log(`✅ Validation passed`);
    } else {
      console.error(`❌ Validation failed:`, result.errors);
      console.log(`🔙 Restoring backup...`);
      fs.copyFileSync(backupFile, agentFile);
    }
  }

  /**
   * Generate v3.0 frontmatter from parsed legacy agent
   */
  generateFrontmatter(parsed) {
    const frontmatter = {
      // Required fields
      name: parsed.metadata.name,
      description: parsed.metadata.description,

      // Metadata
      version: '3.0.0',
      status: parsed.metadata.status,
      color: parsed.metadata.color
    };

    // Add optional fields if present
    if (parsed.metadata.tags?.length > 0) {
      frontmatter.tags = parsed.metadata.tags;
    }

    if (parsed.thinking?.default !== 'think') {
      frontmatter.thinking = {
        default: parsed.thinking.default
      };
    }

    if (parsed.tools.primary?.length > 0 || parsed.tools.mcp?.length > 0 || parsed.tools.restricted?.length > 0) {
      frontmatter.tools = {};

      if (parsed.tools.primary?.length > 0) {
        frontmatter.tools.primary = parsed.tools.primary;
      }

      if (parsed.tools.mcp?.length > 0) {
        frontmatter.tools.mcp = parsed.tools.mcp;
      }

      if (parsed.tools.restricted?.length > 0) {
        frontmatter.tools.restricted = parsed.tools.restricted;
      }
    }

    if (parsed.coordination.coordinates_with?.length > 0) {
      frontmatter.coordinates_with = parsed.coordination.coordinates_with;
    }

    if (parsed.coordination.escalates_to !== '@coordinator') {
      frontmatter.escalates_to = parsed.coordination.escalates_to;
    }

    if (parsed.verification.required) {
      frontmatter.verification_required = true;
    }

    if (parsed.verification.self_verification) {
      frontmatter.self_verification = true;
    }

    return frontmatter;
  }

  /**
   * Migrate all agents in directory
   */
  migrateAll(directory, options = {}) {
    const files = fs.readdirSync(directory).filter(f => f.endsWith('.md'));

    console.log(`📂 Found ${files.length} agent files\n`);

    files.forEach(file => {
      const fullPath = `${directory}/${file}`;
      this.migrate(fullPath, options);
      console.log('');
    });

    console.log(`✅ Migration complete`);
  }
}

// CLI
if (require.main === module) {
  const args = process.argv.slice(2);
  const migrator = new AgentMigrator();

  if (args.includes('--all')) {
    migrator.migrateAll('project/agents/specialists', {
      dryRun: args.includes('--dry-run')
    });
  } else if (args.length > 0) {
    migrator.migrate(args[0], {
      dryRun: args.includes('--dry-run')
    });
  } else {
    console.log('Usage:');
    console.log('  npm run migrate:agent <file>           # Migrate single agent');
    console.log('  npm run migrate:agent --all            # Migrate all agents');
    console.log('  npm run migrate:agent <file> --dry-run # Preview changes');
  }
}

module.exports = AgentMigrator;
```

## Testing Strategy

### Backward Compatibility Test Suite

```javascript
// tests/backward-compatibility.test.js
const AgentParser = require('../scripts/agent-parser');
const fs = require('fs');

describe('Backward Compatibility', () => {
  const parser = new AgentParser();

  describe('Legacy Format (v1.0)', () => {
    it('should parse legacy frontmatter correctly', () => {
      const content = `---
name: coordinator
description: Test agent
color: green
---
# Agent content
`;

      fs.writeFileSync('/tmp/test-agent.md', content);
      const result = parser.parse('/tmp/test-agent.md');

      expect(result.format).toBe('yaml-v1-legacy');
      expect(result.metadata.name).toBe('coordinator');
      expect(result.metadata.version).toBe('1.0.0');
      expect(result._legacy).toBe(true);
    });

    it('should infer tools from markdown', () => {
      const content = `---
name: developer
description: Test
color: blue
---
## TOOL PERMISSIONS
**Primary Tools**:
- **Read** - Reading files
- **Write** - Writing files
`;

      fs.writeFileSync('/tmp/test-agent.md', content);
      const result = parser.parse('/tmp/test-agent.md');

      expect(result.tools.primary).toContain('Read');
      expect(result.tools.primary).toContain('Write');
    });
  });

  describe('Pure Markdown (v0.x)', () => {
    it('should parse markdown-only files', () => {
      const content = 'You are THE DEVELOPER\n\nDoes stuff.';

      fs.writeFileSync('/tmp/test-agent.md', content);
      const result = parser.parse('/tmp/test-agent.md');

      expect(result.format).toBe('markdown-only-legacy');
      expect(result.metadata.status).toBe('deprecated');
      expect(result._migration_urgent).toBe(true);
    });
  });

  describe('New Format (v3.0)', () => {
    it('should parse new format correctly', () => {
      const content = `---
name: coordinator
description: Test agent
version: "3.0.0"
status: stable

tools:
  primary: ["Read", "Write"]
  mcp: ["mcp__github"]
---
# Content
`;

      fs.writeFileSync('/tmp/test-agent.md', content);
      const result = parser.parse('/tmp/test-agent.md');

      expect(result.format).toBe('yaml-v3');
      expect(result.metadata.version).toBe('3.0.0');
      expect(result.tools.primary).toEqual(['Read', 'Write']);
      expect(result._legacy).toBeUndefined();
    });
  });

  describe('Mission Compatibility', () => {
    it('should work with all existing mission files', () => {
      const missionFiles = fs.readdirSync('project/missions');

      missionFiles.forEach(file => {
        // Ensure missions can still reference agents by name
        const content = fs.readFileSync(`project/missions/${file}`, 'utf8');

        // Check for @agent references
        const agentRefs = content.match(/@(\w+)/g) || [];

        agentRefs.forEach(ref => {
          const agentName = ref.substring(1);

          // Agent should be parseable
          expect(() => {
            parser.parse(`project/agents/specialists/${agentName}.md`);
          }).not.toThrow();
        });
      });
    });
  });
});
```

## Rollback Strategy

### If Migration Causes Issues

1. **Immediate Rollback** (v3.0.x patch):
   - Revert to legacy-only parsing
   - Issue patch release (v3.0.1)
   - Investigate and fix

2. **Graceful Degradation**:
   - Parser falls back to legacy format on any error
   - Logs warning but continues operation
   - No user-facing breakage

3. **Backup Protocol**:
   - Migration tool creates `.backup` files
   - Easy rollback: `mv agent.md.backup agent.md`
   - Automated rollback script available

## Success Criteria

**Migration Success Metrics**:
- ✅ All 11 library agents parse without errors
- ✅ All 19 missions execute without modification
- ✅ Performance <100ms per agent (both formats)
- ✅ Zero user-reported issues related to parsing
- ✅ Migration tool success rate >95%

**Deprecation Success Metrics** (v4.0):
- ✅ >90% of agents migrated to v3.0 format
- ✅ Migration guide completed with examples
- ✅ User feedback positive
- ✅ No blocking issues reported

## References

- **Parser Implementation**: `/scripts/agent-parser.js`
- **Migration Tool**: `/scripts/migrate-agent-schema.js`
- **Test Suite**: `/tests/backward-compatibility.test.js`
- **Migration Guide**: `/docs/MIGRATION-GUIDE.md` (to be created)
- **Schema Specification**: `/docs/YAML-SCHEMA-SPECIFICATION.md`

---

**Version**: 3.0.0
**Status**: Draft - Pending Developer Implementation
**Author**: @architect
**Date**: 2025-10-30
