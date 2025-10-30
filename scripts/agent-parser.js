/**
 * Agent Parser - Dual Format Support (v1.0 legacy + v3.0 new)
 *
 * Parses AGENT-11 agent definition files with automatic format detection.
 * Supports:
 * - v3.0 (new format): Full YAML frontmatter schema
 * - v1.0 (legacy): name, description, color only
 * - Pure markdown (v0.x): No frontmatter
 *
 * Performance Target: <5ms parse time (excluding file I/O)
 */

const fs = require('fs');
const yaml = require('js-yaml');
const path = require('path');

class AgentParser {
  constructor(options = {}) {
    this.schemaVersion = '3.0.0';
    this.logger = options.logger || console;
    this.silent = options.silent || false;
  }

  /**
   * Parse agent file with automatic format detection
   * @param {string} agentFile - Path to agent markdown file
   * @returns {Object} Parsed agent data
   */
  parse(agentFile) {
    const startTime = performance.now();

    try {
      const content = fs.readFileSync(agentFile, 'utf8');

      // Check for YAML frontmatter
      const parts = content.split('---\n');

      if (parts.length >= 3 && parts[0] === '') {
        // Has frontmatter - parse it
        try {
          const frontmatter = yaml.load(parts[1]);
          const markdown = parts.slice(2).join('---\n');

          // Detect format version
          if (this.isNewFormat(frontmatter)) {
            return this.parseNewFormat(frontmatter, markdown, agentFile, startTime);
          } else {
            if (!this.silent) {
              this.warnLegacyFormat(agentFile, frontmatter);
            }
            return this.parseLegacyFormat(frontmatter, markdown, agentFile, startTime);
          }
        } catch (yamlError) {
          this.logger.error(`YAML parse error in ${agentFile}:`, yamlError.message);
          // Fallback to pure markdown
          return this.parsePureMarkdown(content, agentFile, startTime);
        }
      } else {
        // No frontmatter - pure markdown (very old format)
        if (!this.silent) {
          this.warnPureMarkdown(agentFile);
        }
        return this.parsePureMarkdown(content, agentFile, startTime);
      }
    } catch (error) {
      throw new Error(`Failed to parse agent file ${agentFile}: ${error.message}`);
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
  parseNewFormat(frontmatter, markdown, filePath, startTime) {
    const parsed = {
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
      markdown: markdown,
      performance: performance.now() - startTime
    };

    return parsed;
  }

  /**
   * Parse agent using legacy v1.0 format
   */
  parseLegacyFormat(frontmatter, markdown, filePath, startTime) {
    const parsed = {
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
      _migration_needed: true,
      performance: performance.now() - startTime
    };

    return parsed;
  }

  /**
   * Parse pure markdown without frontmatter (oldest format)
   */
  parsePureMarkdown(content, filePath, startTime) {
    const name = this.extractNameFromMarkdown(content, filePath);

    const parsed = {
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
      _migration_urgent: true,
      performance: performance.now() - startTime
    };

    return parsed;
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
    const filename = path.basename(filePath, '.md');
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
