/**
 * AGENT-11 Semantic Validator
 * Layer 2: Cross-reference validation and consistency checks
 * Target: <30ms per agent
 */

const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');

class SemanticValidator {
  constructor(options = {}) {
    this.toolRegistry = this.loadToolRegistry(options.toolRegistryPath);
    this.agentRegistry = this.loadAgentRegistry(options.agentRegistryPath);
  }

  /**
   * Load tool registry
   */
  loadToolRegistry(registryPath) {
    const defaultPath = path.join(__dirname, '../project/deployment/tool-registry.json');
    const toolRegistryFile = registryPath || defaultPath;

    if (fs.existsSync(toolRegistryFile)) {
      const content = fs.readFileSync(toolRegistryFile, 'utf8');
      return new Set(JSON.parse(content));
    }

    // Default tool registry if file doesn't exist
    return new Set([
      'Read', 'Write', 'Edit', 'MultiEdit', 'Bash', 'Task',
      'Grep', 'Glob', 'TodoWrite', 'NotebookEdit', 'WebSearch', 'WebFetch',
      'mcp__github', 'mcp__context7', 'mcp__firecrawl', 'mcp__playwright',
      'mcp__supabase', 'mcp__stripe', 'mcp__netlify', 'mcp__railway',
      'mcp__grep', 'mcp__ide'
    ]);
  }

  /**
   * Load agent registry from specialist directory
   */
  loadAgentRegistry(registryPath) {
    const specialistsDir = registryPath || path.join(__dirname, '../project/agents/specialists');

    if (!fs.existsSync(specialistsDir)) {
      return new Set();
    }

    const files = fs.readdirSync(specialistsDir).filter(f => f.endsWith('.md'));
    const agents = files.map(f => f.replace('.md', ''));

    return new Set(agents);
  }

  /**
   * Validate agent file semantics
   * @param {string} agentFile - Path to agent markdown file
   * @param {Object} frontmatter - Parsed frontmatter
   * @returns {Object} Validation result
   */
  validateFile(agentFile, frontmatter) {
    const startTime = performance.now();
    const errors = [];
    const warnings = [];

    // Validate tools exist
    if (frontmatter.tools) {
      const toolResults = this.validateTools(frontmatter.tools);
      errors.push(...toolResults.errors);
      warnings.push(...toolResults.warnings);
    }

    // Validate agent references
    if (frontmatter.coordinates_with) {
      const coordErrors = this.validateCoordination(frontmatter.coordinates_with);
      errors.push(...coordErrors);
    }

    // Validate escalation target
    if (frontmatter.escalates_to) {
      const escalateErrors = this.validateEscalation(frontmatter.escalates_to);
      errors.push(...escalateErrors);
    }

    // Validate version format
    if (frontmatter.version) {
      const versionErrors = this.validateVersion(frontmatter.version);
      errors.push(...versionErrors);
    }

    // Validate status consistency
    const statusWarnings = this.validateStatus(frontmatter);
    warnings.push(...statusWarnings);

    return {
      valid: errors.length === 0,
      errors,
      warnings,
      performance: performance.now() - startTime
    };
  }

  /**
   * Validate tools exist in registry
   */
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

  /**
   * Validate coordination relationships
   */
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

  /**
   * Validate escalation target
   */
  validateEscalation(escalateTo) {
    const errors = [];

    // Remove @ prefix
    const agentName = escalateTo.replace('@', '');

    // Special cases
    if (agentName === 'user') {
      return []; // Valid - escalate to user
    }

    if (!this.agentRegistry.has(agentName)) {
      errors.push({
        field: 'escalates_to',
        message: `Unknown escalation target: ${escalateTo}`,
        fix: `Use @coordinator, @user, or a valid agent name`,
        severity: 'error'
      });
    }

    return errors;
  }

  /**
   * Validate semantic version format
   */
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

  /**
   * Validate status field consistency
   */
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
    if (frontmatter.status === 'experimental' && frontmatter.version) {
      const version = frontmatter.version;
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

    // Beta agents should document known issues
    if (frontmatter.status === 'beta') {
      warnings.push({
        field: 'status',
        message: 'Beta agents should document known issues in markdown',
        fix: 'Add "## Known Issues" section to markdown content',
        severity: 'warning'
      });
    }

    return warnings;
  }

  /**
   * Validate multiple files
   */
  validateFiles(agentFiles) {
    const results = [];

    agentFiles.forEach(file => {
      try {
        const content = fs.readFileSync(file, 'utf8');
        const parts = content.split('---\n');

        if (parts.length >= 3) {
          const frontmatter = yaml.load(parts[1]);
          const result = this.validateFile(file, frontmatter);
          results.push({
            file,
            ...result
          });
        } else {
          results.push({
            file,
            valid: false,
            errors: [{
              field: 'frontmatter',
              message: 'No frontmatter found',
              fix: 'Add YAML frontmatter',
              severity: 'error'
            }],
            warnings: [],
            performance: 0
          });
        }
      } catch (error) {
        results.push({
          file,
          valid: false,
          errors: [{
            field: 'file',
            message: `Error: ${error.message}`,
            fix: 'Check file format',
            severity: 'error'
          }],
          warnings: [],
          performance: 0
        });
      }
    });

    return results;
  }
}

module.exports = SemanticValidator;

// CLI usage
if (require.main === module) {
  const args = process.argv.slice(2);

  if (args.length === 0) {
    console.log('Usage: node validate-semantics.js <agent-file.md>');
    process.exit(1);
  }

  const validator = new SemanticValidator();

  try {
    const content = fs.readFileSync(args[0], 'utf8');
    const parts = content.split('---\n');
    const frontmatter = yaml.load(parts[1]);

    const result = validator.validateFile(args[0], frontmatter);

    if (result.valid) {
      console.log(`✅ Semantic validation passed (${result.performance.toFixed(2)}ms)`);
      if (result.warnings.length > 0) {
        console.log(`\n⚠️  Warnings:`);
        result.warnings.forEach(warn => {
          console.log(`  - ${warn.field}: ${warn.message}`);
          console.log(`    Fix: ${warn.fix}\n`);
        });
      }
      process.exit(0);
    } else {
      console.log(`❌ Semantic validation failed (${result.performance.toFixed(2)}ms)\n`);
      result.errors.forEach(err => {
        console.log(`  ✗ ${err.field}: ${err.message}`);
        console.log(`    Fix: ${err.fix}\n`);
      });
      process.exit(1);
    }
  } catch (error) {
    console.error(`❌ Error: ${error.message}`);
    process.exit(1);
  }
}
