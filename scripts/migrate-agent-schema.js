#!/usr/bin/env node

/**
 * AGENT-11 Agent Migration Tool
 * Migrate agents from legacy format (v1.0) to new format (v3.0)
 * Features: Dry-run, automatic backup, validation, rollback on failure
 */

const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');
const { glob } = require('glob');
const AgentParser = require('./agent-parser');
const SchemaValidator = require('./validate-schema');

class AgentMigrator {
  constructor() {
    this.parser = new AgentParser();
    this.validator = new SchemaValidator();
  }

  /**
   * Migrate agent file to new v3.0 format
   * @param {string} agentFile - Path to agent markdown file
   * @param {Object} options - Migration options
   * @returns {Object} Migration result
   */
  migrate(agentFile, options = {}) {
    console.log(`🔄 Migrating ${path.basename(agentFile)}...`);

    try {
      // Parse with legacy support
      const parsed = this.parser.parse(agentFile);

      if (parsed.format === 'yaml-v3') {
        console.log(`✅ Already using v3.0 format\n`);
        return { success: true, skipped: true };
      }

      // Generate new frontmatter
      const newFrontmatter = this.generateFrontmatter(parsed);

      // Keep markdown content
      const markdown = parsed.markdown;

      // Write new format
      const newContent = `---\n${yaml.dump(newFrontmatter, { lineWidth: -1 })}---\n${markdown}`;

      if (options.dryRun) {
        console.log('📄 Preview (dry run):\n');
        const preview = newContent.substring(0, 800);
        console.log(preview);
        if (newContent.length > 800) {
          console.log('... (truncated)\n');
        }
        return { success: true, dryRun: true };
      }

      // Backup original
      const backupFile = `${agentFile}.backup`;
      fs.copyFileSync(agentFile, backupFile);
      console.log(`💾 Backup saved: ${path.basename(backupFile)}`);

      // Write new format
      fs.writeFileSync(agentFile, newContent, 'utf8');
      console.log(`✅ Migrated to v3.0 format`);

      // Validate
      const result = this.validator.validateFile(agentFile);

      if (result.valid) {
        console.log(`✅ Validation passed (${result.performance.toFixed(2)}ms)\n`);
        return { success: true, migrated: true };
      } else {
        console.error(`❌ Validation failed:`, result.errors);
        console.log(`🔙 Restoring backup...`);

        // Rollback
        fs.copyFileSync(backupFile, agentFile);
        fs.unlinkSync(backupFile);
        console.log(`✅ Restored original file\n`);

        return { success: false, error: 'Validation failed', errors: result.errors };
      }

    } catch (error) {
      console.error(`❌ Migration failed: ${error.message}\n`);
      return { success: false, error: error.message };
    }
  }

  /**
   * Generate v3.0 frontmatter from parsed legacy agent
   * @param {Object} parsed - Parsed agent data
   * @returns {Object} v3.0 frontmatter
   */
  generateFrontmatter(parsed) {
    const frontmatter = {
      // Required fields
      name: parsed.metadata.name,
      description: parsed.metadata.description
    };

    // Add version (always 3.0.0 for new format)
    frontmatter.version = '3.0.0';

    // Add status
    if (parsed.metadata.status && parsed.metadata.status !== 'stable') {
      frontmatter.status = parsed.metadata.status;
    }

    // Add color
    if (parsed.metadata.color) {
      frontmatter.color = parsed.metadata.color;
    }

    // Add optional fields if present and non-default
    if (parsed.metadata.tags && parsed.metadata.tags.length > 0) {
      frontmatter.tags = parsed.metadata.tags;
    }

    // Add thinking configuration if non-default
    if (parsed.thinking && parsed.thinking.default !== 'think') {
      frontmatter.thinking = {
        default: parsed.thinking.default
      };

      if (parsed.thinking.when_to_use_deeper) {
        frontmatter.thinking.when_to_use_deeper = parsed.thinking.when_to_use_deeper;
      }
    }

    // Add tools if present
    if (parsed.tools && (
      parsed.tools.primary?.length > 0 ||
      parsed.tools.mcp?.length > 0 ||
      parsed.tools.restricted?.length > 0
    )) {
      frontmatter.tools = {};

      if (parsed.tools.primary && parsed.tools.primary.length > 0) {
        frontmatter.tools.primary = parsed.tools.primary;
      }

      if (parsed.tools.mcp && parsed.tools.mcp.length > 0) {
        frontmatter.tools.mcp = parsed.tools.mcp;
      }

      if (parsed.tools.restricted && parsed.tools.restricted.length > 0) {
        frontmatter.tools.restricted = parsed.tools.restricted;
      }
    }

    // Add coordination if present
    if (parsed.coordination.coordinates_with && parsed.coordination.coordinates_with.length > 0) {
      frontmatter.coordinates_with = parsed.coordination.coordinates_with;
    }

    if (parsed.coordination.escalates_to && parsed.coordination.escalates_to !== '@coordinator') {
      frontmatter.escalates_to = parsed.coordination.escalates_to;
    }

    // Add verification flags
    if (parsed.verification.required) {
      frontmatter.verification_required = true;
    }

    if (parsed.verification.self_verification) {
      frontmatter.self_verification = true;
    }

    // Add custom fields if present
    if (parsed.custom && Object.keys(parsed.custom).length > 0) {
      frontmatter.custom = parsed.custom;
    }

    return frontmatter;
  }

  /**
   * Migrate all agents in directory
   * @param {string} directory - Directory containing agent files
   * @param {Object} options - Migration options
   * @returns {Object} Migration summary
   */
  async migrateAll(directory, options = {}) {
    const pattern = path.join(directory, '*.md');
    const files = await glob(pattern);

    console.log(`📂 Found ${files.length} agent files\n`);

    const summary = {
      total: files.length,
      migrated: 0,
      skipped: 0,
      failed: 0,
      errors: []
    };

    for (const file of files) {
      const result = this.migrate(file, options);

      if (result.success) {
        if (result.skipped) {
          summary.skipped++;
        } else if (result.migrated) {
          summary.migrated++;
        } else if (result.dryRun) {
          summary.skipped++;
        }
      } else {
        summary.failed++;
        summary.errors.push({
          file: path.basename(file),
          error: result.error,
          details: result.errors
        });
      }
    }

    console.log(`\n📊 Migration Summary:`);
    console.log(`   Total:    ${summary.total} files`);
    console.log(`   Migrated: ${summary.migrated} files`);
    console.log(`   Skipped:  ${summary.skipped} files (already v3.0 or dry-run)`);
    console.log(`   Failed:   ${summary.failed} files`);

    if (summary.failed > 0) {
      console.log(`\n❌ Errors:`);
      summary.errors.forEach(err => {
        console.log(`   ${err.file}: ${err.error}`);
      });
    }

    console.log('');

    return summary;
  }

  /**
   * Show help
   */
  showHelp() {
    console.log(`
AGENT-11 Agent Migration Tool

Migrate agents from legacy format (v1.0-v2.x) to new format (v3.0)

Usage:
  migrate-agent-schema.js [options] [file]

Options:
  --all              Migrate all agents in project/agents/specialists/
  --dry-run          Preview changes without writing files
  --help, -h         Show this help message

Examples:
  # Migrate single agent
  npm run migrate:agent project/agents/specialists/coordinator.md

  # Preview changes (dry run)
  npm run migrate:agent project/agents/specialists/coordinator.md --dry-run

  # Migrate all agents
  npm run migrate:all

  # Preview all migrations
  npm run migrate:all --dry-run

Features:
  ✅ Automatic backup before migration
  ✅ Validation after migration
  ✅ Automatic rollback on validation failure
  ✅ Dry-run mode for previewing changes
  ✅ Batch migration with summary report
  ✅ Preserves all agent functionality

Migration Process:
  1. Parse legacy format (supports v1.0, v2.x, pure markdown)
  2. Extract all data (metadata, tools, thinking, coordination)
  3. Generate v3.0 frontmatter with all fields
  4. Create backup (.backup file)
  5. Write new format
  6. Validate with schema validator
  7. Rollback if validation fails

Backup Files:
  - Backup files are created as: <agent-file>.backup
  - Restore manually: mv coordinator.md.backup coordinator.md
  - Delete after verification: rm *.backup

Note: All 19 missions will continue working with both formats
`);
  }

  /**
   * Parse CLI arguments
   */
  parseArgs(args) {
    const options = {
      all: false,
      dryRun: false,
      file: null
    };

    for (let i = 0; i < args.length; i++) {
      const arg = args[i];

      switch (arg) {
        case '--all':
          options.all = true;
          break;
        case '--dry-run':
          options.dryRun = true;
          break;
        case '--help':
        case '-h':
          this.showHelp();
          process.exit(0);
          break;
        default:
          if (!arg.startsWith('--')) {
            options.file = arg;
          }
      }
    }

    return options;
  }

  /**
   * Run CLI
   */
  async run(args) {
    const options = this.parseArgs(args);

    if (options.all) {
      const summary = await this.migrateAll('project/agents/specialists', {
        dryRun: options.dryRun
      });

      return summary.failed === 0 ? 0 : 1;
    }

    if (options.file) {
      const result = this.migrate(options.file, {
        dryRun: options.dryRun
      });

      return result.success ? 0 : 1;
    }

    console.error('❌ No file specified\n');
    console.log('Usage:');
    console.log('  npm run migrate:agent <file>       # Migrate single agent');
    console.log('  npm run migrate:all                # Migrate all agents');
    console.log('  npm run migrate:agent <file> --dry-run  # Preview changes');
    console.log('\nRun with --help for more information');

    return 1;
  }
}

// Run CLI if executed directly
if (require.main === module) {
  const migrator = new AgentMigrator();
  const args = process.argv.slice(2);

  migrator.run(args)
    .then(exitCode => process.exit(exitCode))
    .catch(error => {
      console.error(`❌ Fatal error: ${error.message}`);
      if (process.env.DEBUG) {
        console.error(error.stack);
      }
      process.exit(1);
    });
}

module.exports = AgentMigrator;
