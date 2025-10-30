/**
 * AGENT-11 Content Validator
 * Layer 3: Markdown content completeness and quality checks
 * Target: <60ms per agent
 */

const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');

class ContentValidator {
  constructor() {
    this.requiredSections = [
      'CONTEXT PRESERVATION PROTOCOL',
      'TOOL PERMISSIONS',
      'SELF-VERIFICATION PROTOCOL',
      'EXTENDED THINKING GUIDANCE',
      'CONTEXT EDITING GUIDANCE'
    ];
  }

  /**
   * Validate agent markdown content
   * @param {string} agentFile - Path to agent markdown file
   * @param {Object} frontmatter - Parsed frontmatter
   * @returns {Object} Validation result
   */
  validateFile(agentFile, frontmatter) {
    const startTime = performance.now();
    const errors = [];
    const warnings = [];

    try {
      const content = fs.readFileSync(agentFile, 'utf8');
      const parts = content.split('---\n');
      const markdown = parts.slice(2).join('---\n');

      // Check required sections
      const sectionErrors = this.validateSections(markdown, frontmatter);
      errors.push(...sectionErrors);

      // Check internal links
      const linkWarnings = this.validateLinks(markdown, agentFile);
      warnings.push(...linkWarnings);

      // Check tool explanations
      if (frontmatter.tools) {
        const toolDocWarnings = this.validateToolDocumentation(markdown, frontmatter.tools);
        warnings.push(...toolDocWarnings);
      }

      // Check verification protocols
      if (frontmatter.verification_required || frontmatter.self_verification) {
        const verificationErrors = this.validateVerification(markdown);
        errors.push(...verificationErrors);
      }

      // Check thinking guidance
      if (frontmatter.thinking) {
        const thinkingWarnings = this.validateThinkingGuidance(markdown, frontmatter.thinking);
        warnings.push(...thinkingWarnings);
      }

      return {
        valid: errors.length === 0,
        errors,
        warnings,
        performance: performance.now() - startTime
      };

    } catch (error) {
      return {
        valid: false,
        errors: [{
          section: 'file',
          message: `Content validation error: ${error.message}`,
          fix: 'Check file exists and is readable',
          severity: 'error'
        }],
        warnings: [],
        performance: performance.now() - startTime
      };
    }
  }

  /**
   * Validate required markdown sections exist
   */
  validateSections(content, frontmatter) {
    const errors = [];

    // Context preservation is always required
    if (!content.includes('## CONTEXT PRESERVATION PROTOCOL')) {
      errors.push({
        section: 'CONTEXT PRESERVATION PROTOCOL',
        message: 'Missing required section: ## CONTEXT PRESERVATION PROTOCOL',
        fix: 'Add CONTEXT PRESERVATION PROTOCOL section with handoff guidelines',
        severity: 'error'
      });
    }

    // Tool permissions required if tools defined
    if (frontmatter.tools && !content.includes('## TOOL PERMISSIONS')) {
      errors.push({
        section: 'TOOL PERMISSIONS',
        message: 'Missing required section: ## TOOL PERMISSIONS',
        fix: 'Add TOOL PERMISSIONS section explaining tool usage',
        severity: 'error'
      });
    }

    // Self-verification required if flagged
    if ((frontmatter.verification_required || frontmatter.self_verification) &&
        !content.includes('## SELF-VERIFICATION PROTOCOL')) {
      errors.push({
        section: 'SELF-VERIFICATION PROTOCOL',
        message: 'Missing required section: ## SELF-VERIFICATION PROTOCOL',
        fix: 'Add SELF-VERIFICATION PROTOCOL section with quality checklist',
        severity: 'error'
      });
    }

    // Extended thinking required if defined
    if (frontmatter.thinking && !content.includes('## EXTENDED THINKING GUIDANCE')) {
      errors.push({
        section: 'EXTENDED THINKING GUIDANCE',
        message: 'Missing required section: ## EXTENDED THINKING GUIDANCE',
        fix: 'Add EXTENDED THINKING GUIDANCE section with thinking modes',
        severity: 'error'
      });
    }

    // Context editing always required
    if (!content.includes('## CONTEXT EDITING GUIDANCE')) {
      errors.push({
        section: 'CONTEXT EDITING GUIDANCE',
        message: 'Missing required section: ## CONTEXT EDITING GUIDANCE',
        fix: 'Add CONTEXT EDITING GUIDANCE section with /clear usage',
        severity: 'error'
      });
    }

    return errors;
  }

  /**
   * Validate internal file links
   */
  validateLinks(content, agentFile) {
    const warnings = [];

    // Find all markdown links
    const linkPattern = /\[([^\]]+)\]\(([^)]+)\)/g;
    const matches = content.matchAll(linkPattern);

    for (const match of matches) {
      const [, text, url] = match;

      // Check internal file links (relative or absolute project paths)
      if (url.startsWith('/') || url.startsWith('.')) {
        const fullPath = path.resolve(path.dirname(agentFile), url);

        if (!fs.existsSync(fullPath)) {
          warnings.push({
            link: url,
            message: `Broken internal link: ${url}`,
            fix: `Create file at ${url} or fix link`,
            severity: 'warning'
          });
        }
      }
    }

    return warnings;
  }

  /**
   * Validate tool documentation completeness
   */
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

    // Check for MCP fallback strategies
    if (tools.mcp && tools.mcp.length > 0) {
      if (!toolSection.includes('MCP FALLBACK') && !toolSection.includes('Fallback')) {
        warnings.push({
          tool: 'MCP',
          message: 'MCP tools used but no fallback strategies documented',
          fix: 'Add MCP Fallback Strategies section explaining alternatives',
          severity: 'warning'
        });
      }
    }

    return warnings;
  }

  /**
   * Validate verification protocol content
   */
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
        fix: 'Add **Pre-Handoff Checklist** subsection with actionable items',
        severity: 'error'
      });
    }

    // Check for quality validation
    if (!verificationSection.includes('Quality Validation')) {
      errors.push({
        section: 'SELF-VERIFICATION PROTOCOL',
        message: 'Missing Quality Validation section',
        fix: 'Add **Quality Validation** subsection with quality criteria',
        severity: 'error'
      });
    }

    // Check for error recovery
    if (!verificationSection.includes('Error Recovery')) {
      errors.push({
        section: 'SELF-VERIFICATION PROTOCOL',
        message: 'Missing Error Recovery section',
        fix: 'Add **Error Recovery** subsection with recovery protocols',
        severity: 'error'
      });
    }

    return errors;
  }

  /**
   * Validate thinking guidance content
   */
  validateThinkingGuidance(content, thinking) {
    const warnings = [];

    const thinkingSection = this.extractSection(content, '## EXTENDED THINKING GUIDANCE');

    if (!thinkingSection) return warnings;

    // Check default mode is documented
    if (thinking.default && !thinkingSection.includes(thinking.default)) {
      warnings.push({
        section: 'EXTENDED THINKING GUIDANCE',
        message: `Default thinking mode "${thinking.default}" not explained in guidance`,
        fix: `Add explanation of when to use "${thinking.default}" mode`,
        severity: 'warning'
      });
    }

    // Check for cost-benefit guidance
    if (!thinkingSection.includes('cost') && !thinkingSection.includes('Cost')) {
      warnings.push({
        section: 'EXTENDED THINKING GUIDANCE',
        message: 'Missing cost-benefit guidance for thinking modes',
        fix: 'Add cost-benefit analysis explaining when deeper thinking is justified',
        severity: 'warning'
      });
    }

    return warnings;
  }

  /**
   * Extract markdown section content
   */
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
              section: 'frontmatter',
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
            section: 'file',
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

module.exports = ContentValidator;

// CLI usage
if (require.main === module) {
  const args = process.argv.slice(2);

  if (args.length === 0) {
    console.log('Usage: node validate-content.js <agent-file.md>');
    process.exit(1);
  }

  const validator = new ContentValidator();

  try {
    const content = fs.readFileSync(args[0], 'utf8');
    const parts = content.split('---\n');
    const frontmatter = yaml.load(parts[1]);

    const result = validator.validateFile(args[0], frontmatter);

    if (result.valid) {
      console.log(`✅ Content validation passed (${result.performance.toFixed(2)}ms)`);
      if (result.warnings.length > 0) {
        console.log(`\n⚠️  Warnings:`);
        result.warnings.forEach(warn => {
          console.log(`  - ${warn.section || warn.tool || warn.link}: ${warn.message}`);
          console.log(`    Fix: ${warn.fix}\n`);
        });
      }
      process.exit(0);
    } else {
      console.log(`❌ Content validation failed (${result.performance.toFixed(2)}ms)\n`);
      result.errors.forEach(err => {
        console.log(`  ✗ ${err.section}: ${err.message}`);
        console.log(`    Fix: ${err.fix}\n`);
      });
      process.exit(1);
    }
  } catch (error) {
    console.error(`❌ Error: ${error.message}`);
    process.exit(1);
  }
}
