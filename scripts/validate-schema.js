/**
 * AGENT-11 Schema Validator
 * Layer 1: Fast YAML syntax and type checking
 * Target: <10ms per agent
 */

const Ajv = require('ajv');
const addFormats = require('ajv-formats');
const yaml = require('js-yaml');
const fs = require('fs');
const path = require('path');

class SchemaValidator {
  constructor(schemaPath) {
    this.ajv = new Ajv({
      allErrors: true,
      strict: false,
      validateFormats: true
    });
    addFormats(this.ajv);

    // Load and compile schema
    const schemaFile = schemaPath || path.join(__dirname, '../schema/agent-schema.json');
    const schema = JSON.parse(fs.readFileSync(schemaFile, 'utf8'));
    this.validate = this.ajv.compile(schema);
  }

  /**
   * Validate agent file schema
   * @param {string} agentFile - Path to agent markdown file
   * @returns {Object} Validation result
   */
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
            field: 'frontmatter',
            message: 'No YAML frontmatter found',
            fix: 'Add YAML frontmatter between --- delimiters at file start',
            severity: 'error'
          }],
          performance: performance.now() - startTime
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
            field: 'yaml',
            message: `YAML parse error: ${yamlError.message}`,
            line: yamlError.mark?.line,
            fix: 'Fix YAML syntax error (check indentation, quotes, special characters)',
            severity: 'error'
          }],
          performance: performance.now() - startTime
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
          field: 'file',
          message: `Validation error: ${error.message}`,
          fix: 'Check file exists and is readable',
          severity: 'error'
        }],
        performance: performance.now() - startTime
      };
    }
  }

  /**
   * Format AJV errors with helpful fix suggestions
   */
  formatErrors(errors) {
    return errors.map(err => {
      const field = err.instancePath || err.dataPath || 'unknown';
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
        case 'minLength':
          fix = `Minimum length is ${err.params.limit} characters`;
          break;
        case 'maxLength':
          fix = `Maximum length is ${err.params.limit} characters`;
          break;
        case 'uniqueItems':
          fix = `Remove duplicate items from ${field}`;
          break;
        case 'additionalProperties':
          fix = `Remove unknown field: ${err.params.additionalProperty}`;
          break;
        default:
          fix = `Fix validation error for ${field}`;
      }

      return {
        field: field.replace('/',''),
        message,
        fix,
        schema: err.schemaPath,
        severity: 'error'
      };
    });
  }

  /**
   * Check for duplicate tool names across tool lists
   */
  checkDuplicateTools(frontmatter) {
    if (!frontmatter.tools) return [];

    const { primary = [], mcp = [], restricted = [] } = frontmatter.tools;

    // Check for duplicates across all three lists
    const seen = new Map(); // tool -> list name
    const duplicates = [];

    // Check primary
    primary.forEach(tool => {
      seen.set(tool, 'primary');
    });

    // Check mcp
    mcp.forEach(tool => {
      if (seen.has(tool)) {
        duplicates.push({
          field: 'tools',
          message: `Duplicate tool '${tool}' found in both '${seen.get(tool)}' and 'mcp'`,
          fix: `Remove duplicate '${tool}' from one of the tool lists`,
          severity: 'error'
        });
      }
      seen.set(tool, 'mcp');
    });

    // Check restricted
    restricted.forEach(tool => {
      if (seen.has(tool)) {
        duplicates.push({
          field: 'tools',
          message: `Duplicate tool '${tool}' found in both '${seen.get(tool)}' and 'restricted'`,
          fix: `Remove duplicate '${tool}' from one of the tool lists`,
          severity: 'error'
        });
      }
    });

    return duplicates;
  }

  /**
   * Validate multiple files
   */
  validateFiles(agentFiles) {
    const results = [];

    agentFiles.forEach(file => {
      const result = this.validateFile(file);
      results.push({
        file,
        ...result
      });
    });

    return results;
  }
}

module.exports = SchemaValidator;

// CLI usage
if (require.main === module) {
  const args = process.argv.slice(2);

  if (args.length === 0) {
    console.log('Usage: node validate-schema.js <agent-file.md>');
    process.exit(1);
  }

  const validator = new SchemaValidator();
  const result = validator.validateFile(args[0]);

  if (result.valid) {
    console.log(`✅ Schema validation passed (${result.performance.toFixed(2)}ms)`);
    process.exit(0);
  } else {
    console.log(`❌ Schema validation failed (${result.performance.toFixed(2)}ms)\n`);
    result.errors.forEach(err => {
      console.log(`  ✗ ${err.field}: ${err.message}`);
      console.log(`    Fix: ${err.fix}\n`);
    });
    process.exit(1);
  }
}
