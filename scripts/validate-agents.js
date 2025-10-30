#!/usr/bin/env node

/**
 * AGENT-11 Agent Validation CLI
 * Unified validation interface for all three layers
 * Usage: validate-agents.js [options] [files...]
 */

const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');
const { glob } = require('glob');
const SchemaValidator = require('./validate-schema');
const SemanticValidator = require('./validate-semantics');
const ContentValidator = require('./validate-content');

class AgentValidationCLI {
  constructor() {
    this.schemaValidator = new SchemaValidator();
    this.semanticValidator = new SemanticValidator();
    this.contentValidator = new ContentValidator();
  }

  /**
   * Parse CLI arguments
   */
  parseArgs(args) {
    const options = {
      all: false,
      layer: 'all', // 'schema', 'semantics', 'content', or 'all'
      format: 'console', // 'console' or 'json'
      verbose: false,
      staged: false,
      files: []
    };

    for (let i = 0; i < args.length; i++) {
      const arg = args[i];

      switch (arg) {
        case '--all':
          options.all = true;
          break;
        case '--layer':
          options.layer = args[++i];
          break;
        case '--format':
          options.format = args[++i];
          break;
        case '--verbose':
        case '-v':
          options.verbose = true;
          break;
        case '--staged':
          options.staged = true;
          break;
        case '--help':
        case '-h':
          this.showHelp();
          process.exit(0);
          break;
        default:
          if (!arg.startsWith('--')) {
            options.files.push(arg);
          }
      }
    }

    return options;
  }

  /**
   * Get files to validate
   */
  async getFiles(options) {
    if (options.staged) {
      // Get staged files from git
      const { execSync } = require('child_process');
      const output = execSync('git diff --cached --name-only --diff-filter=ACM', { encoding: 'utf8' });
      const files = output.split('\n')
        .filter(f => f.includes('project/agents/specialists/') && f.endsWith('.md'))
        .map(f => path.resolve(f));
      return files;
    }

    if (options.all) {
      // Get all agent files
      const pattern = 'project/agents/specialists/*.md';
      const files = await glob(pattern, { cwd: process.cwd() });
      return files.map(f => path.resolve(f));
    }

    // Use provided files
    return options.files.map(f => path.resolve(f));
  }

  /**
   * Validate single file with all layers
   */
  async validateFile(file, layer = 'all') {
    const result = {
      file: path.relative(process.cwd(), file),
      layers: {},
      valid: true,
      totalPerformance: 0
    };

    try {
      const content = fs.readFileSync(file, 'utf8');
      const parts = content.split('---\n');

      if (parts.length < 3) {
        return {
          ...result,
          valid: false,
          error: 'No YAML frontmatter found'
        };
      }

      const frontmatter = yaml.load(parts[1]);

      // Layer 1: Schema validation
      if (layer === 'all' || layer === 'schema') {
        const schemaResult = this.schemaValidator.validateFile(file);
        result.layers.schema = schemaResult;
        result.totalPerformance += schemaResult.performance || 0;

        if (!schemaResult.valid) {
          result.valid = false;
        }
      }

      // Layer 2: Semantic validation
      if (layer === 'all' || layer === 'semantics') {
        const semanticResult = this.semanticValidator.validateFile(file, frontmatter);
        result.layers.semantics = semanticResult;
        result.totalPerformance += semanticResult.performance || 0;

        if (!semanticResult.valid) {
          result.valid = false;
        }
      }

      // Layer 3: Content validation
      if (layer === 'all' || layer === 'content') {
        const contentResult = this.contentValidator.validateFile(file, frontmatter);
        result.layers.content = contentResult;
        result.totalPerformance += contentResult.performance || 0;

        if (!contentResult.valid) {
          result.valid = false;
        }
      }

    } catch (error) {
      result.valid = false;
      result.error = error.message;
    }

    return result;
  }

  /**
   * Validate multiple files
   */
  async validateFiles(files, layer = 'all') {
    const results = [];

    for (const file of files) {
      const result = await this.validateFile(file, layer);
      results.push(result);
    }

    return results;
  }

  /**
   * Output results in console format
   */
  outputConsole(results, verbose = false) {
    const passed = results.filter(r => r.valid).length;
    const failed = results.filter(r => !r.valid).length;

    console.log(`\n🔍 Validation Results: ${passed} passed, ${failed} failed\n`);

    results.forEach(result => {
      if (result.valid) {
        if (verbose) {
          console.log(`✅ ${result.file} (${result.totalPerformance.toFixed(2)}ms)`);

          // Show warnings if any
          Object.entries(result.layers).forEach(([layer, layerResult]) => {
            if (layerResult.warnings && layerResult.warnings.length > 0) {
              console.log(`   ⚠️  ${layer}: ${layerResult.warnings.length} warnings`);
            }
          });
        }
      } else {
        console.log(`❌ ${result.file}`);

        if (result.error) {
          console.log(`   Error: ${result.error}`);
        }

        // Show errors from each layer
        Object.entries(result.layers).forEach(([layer, layerResult]) => {
          if (layerResult.errors && layerResult.errors.length > 0) {
            console.log(`\n   ${layer.toUpperCase()} ERRORS (${layerResult.performance?.toFixed(2)}ms):`);
            layerResult.errors.forEach(err => {
              console.log(`   ✗ ${err.field || err.section}: ${err.message}`);
              console.log(`     Fix: ${err.fix}\n`);
            });
          }

          if (verbose && layerResult.warnings && layerResult.warnings.length > 0) {
            console.log(`\n   ${layer.toUpperCase()} WARNINGS:`);
            layerResult.warnings.forEach(warn => {
              console.log(`   ⚠️  ${warn.field || warn.section || warn.tool}: ${warn.message}`);
              console.log(`     Fix: ${warn.fix}\n`);
            });
          }
        });
      }
    });

    // Performance summary
    if (verbose && results.length > 0) {
      const totalTime = results.reduce((sum, r) => sum + (r.totalPerformance || 0), 0);
      const avgTime = totalTime / results.length;
      console.log(`\n⏱️  Performance: Total ${totalTime.toFixed(2)}ms, Average ${avgTime.toFixed(2)}ms per agent`);
    }

    return failed === 0 ? 0 : 1;
  }

  /**
   * Output results in JSON format
   */
  outputJSON(results) {
    console.log(JSON.stringify(results, null, 2));

    const failed = results.filter(r => !r.valid).length;
    return failed === 0 ? 0 : 1;
  }

  /**
   * Show help
   */
  showHelp() {
    console.log(`
AGENT-11 Agent Validation CLI

Usage:
  validate-agents.js [options] [files...]

Options:
  --all              Validate all agents in project/agents/specialists/
  --layer <layer>    Validate specific layer: schema, semantics, content, or all (default: all)
  --format <format>  Output format: console or json (default: console)
  --verbose, -v      Show verbose output including warnings and performance
  --staged           Validate only git staged files
  --help, -h         Show this help message

Examples:
  # Validate single agent
  validate-agents.js project/agents/specialists/coordinator.md

  # Validate all agents
  validate-agents.js --all

  # Validate specific layer only
  validate-agents.js --all --layer=schema

  # JSON output for CI/CD
  validate-agents.js --all --format=json

  # Verbose mode with performance metrics
  validate-agents.js --all --verbose

  # Validate only staged files (for pre-commit hook)
  validate-agents.js --staged --layer=schema

  # Watch mode (use with nodemon)
  nodemon --watch project/agents/specialists --exec 'validate-agents.js --all'

Validation Layers:
  schema      - Fast YAML syntax and type checking (<10ms)
  semantics   - Cross-reference validation (<30ms)
  content     - Markdown completeness checks (<60ms)
  all         - Run all three layers (<100ms)

Performance Targets:
  Schema:     <10ms per agent
  Semantics:  <30ms per agent
  Content:    <60ms per agent
  Total:      <100ms per agent

Exit Codes:
  0 - All validations passed
  1 - One or more validations failed
`);
  }

  /**
   * Run CLI
   */
  async run(args) {
    const options = this.parseArgs(args);

    // Get files to validate
    const files = await this.getFiles(options);

    if (files.length === 0) {
      console.error('❌ No files to validate');
      console.log('\nUsage: validate-agents.js --all OR specify files');
      return 1;
    }

    // Validate files
    const results = await this.validateFiles(files, options.layer);

    // Output results
    if (options.format === 'json') {
      return this.outputJSON(results);
    } else {
      return this.outputConsole(results, options.verbose);
    }
  }
}

// Run CLI if executed directly
if (require.main === module) {
  const cli = new AgentValidationCLI();
  const args = process.argv.slice(2);

  cli.run(args)
    .then(exitCode => process.exit(exitCode))
    .catch(error => {
      console.error(`❌ Fatal error: ${error.message}`);
      if (process.env.DEBUG) {
        console.error(error.stack);
      }
      process.exit(1);
    });
}

module.exports = AgentValidationCLI;
