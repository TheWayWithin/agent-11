#!/usr/bin/env node

/**
 * AGENT-11 Deployment Validation Script
 *
 * Validates deployment consistency between:
 * - install.sh SQUAD_FULL array
 * - Library agents directory (project/agents/specialists/)
 * - README.md claims
 *
 * Exit codes:
 * - 0: All validation passed
 * - 1: Validation failures found
 */

const fs = require('fs');
const path = require('path');

// ANSI color codes
const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
};

class DeploymentValidator {
  constructor() {
    this.errors = [];
    this.warnings = [];
    this.projectRoot = path.resolve(__dirname, '..');
    this.installScriptPath = path.join(this.projectRoot, 'project/deployment/scripts/install.sh');
    this.libraryAgentsPath = path.join(this.projectRoot, 'project/agents/specialists');
    this.readmePath = path.join(this.projectRoot, 'README.md');

    // Expected agent count
    this.EXPECTED_AGENT_COUNT = 11;
  }

  log(message, color = colors.blue) {
    console.log(`${color}${message}${colors.reset}`);
  }

  error(message) {
    this.errors.push(message);
    console.log(`${colors.red}✗ ${message}${colors.reset}`);
  }

  warn(message) {
    this.warnings.push(message);
    console.log(`${colors.yellow}⚠ ${message}${colors.reset}`);
  }

  success(message) {
    console.log(`${colors.green}✓ ${message}${colors.reset}`);
  }

  /**
   * Extract SQUAD_FULL array from install.sh
   */
  extractSquadFull() {
    try {
      const installScript = fs.readFileSync(this.installScriptPath, 'utf8');

      // Match SQUAD_FULL=("agent1" "agent2" ...) pattern
      const match = installScript.match(/SQUAD_FULL=\((.*?)\)/s);

      if (!match) {
        this.error('SQUAD_FULL array not found in install.sh');
        return null;
      }

      // Extract agent names from quoted strings
      const agentMatches = match[1].match(/"([^"]+)"/g);

      if (!agentMatches) {
        this.error('No agents found in SQUAD_FULL array');
        return null;
      }

      // Remove quotes
      return agentMatches.map(agent => agent.replace(/"/g, ''));
    } catch (error) {
      this.error(`Failed to read install.sh: ${error.message}`);
      return null;
    }
  }

  /**
   * Get list of library agents from specialists directory
   */
  getLibraryAgents() {
    try {
      const files = fs.readdirSync(this.libraryAgentsPath);

      // Filter for .md files (exclude backups and system files) and extract agent names
      return files
        .filter(file =>
          file.endsWith('.md') &&
          !file.endsWith('.backup') &&
          !file.startsWith('.')
        )
        .map(file => path.basename(file, '.md'))
        .sort();
    } catch (error) {
      this.error(`Failed to read library agents directory: ${error.message}`);
      return [];
    }
  }

  /**
   * Validate SQUAD_FULL agent count
   */
  validateAgentCount(squadFull) {
    const count = squadFull.length;

    if (count !== this.EXPECTED_AGENT_COUNT) {
      this.error(`SQUAD_FULL has ${count} agents, expected ${this.EXPECTED_AGENT_COUNT}`);
      return false;
    }

    this.success(`SQUAD_FULL agent count: ${count} (expected: ${this.EXPECTED_AGENT_COUNT})`);
    return true;
  }

  /**
   * Validate SQUAD_FULL matches library agents
   */
  validateAgentList(squadFull, libraryAgents) {
    const squadSorted = [...squadFull].sort();
    const librarySorted = [...libraryAgents].sort();

    // Check for agents in SQUAD_FULL but not in library
    const missingInLibrary = squadSorted.filter(agent => !librarySorted.includes(agent));
    if (missingInLibrary.length > 0) {
      this.error(`Agents in SQUAD_FULL but missing from library: ${missingInLibrary.join(', ')}`);
      return false;
    }

    // Check for agents in library but not in SQUAD_FULL
    const missingInSquad = librarySorted.filter(agent => !squadSorted.includes(agent));
    if (missingInSquad.length > 0) {
      this.error(`Agents in library but missing from SQUAD_FULL: ${missingInSquad.join(', ')}`);
      return false;
    }

    this.success('SQUAD_FULL matches library agents directory');
    return true;
  }

  /**
   * Validate source directory priority in install.sh
   * Library agents (project/agents/specialists) should be prioritized first
   */
  validateSourcePriority() {
    try {
      const installScript = fs.readFileSync(this.installScriptPath, 'utf8');

      // Find the install_agent function
      const functionMatch = installScript.match(/install_agent\(\) \{[\s\S]*?\n\}/);

      if (!functionMatch) {
        this.error('install_agent function not found in install.sh');
        return false;
      }

      const functionBody = functionMatch[0];

      // Check for library path check before working squad path check
      const libraryPathCheck = functionBody.indexOf('project/agents/specialists');
      const workingSquadCheck = functionBody.indexOf('.claude/agents');

      if (libraryPathCheck === -1) {
        this.error('Library agents path check not found in install_agent function');
        return false;
      }

      if (workingSquadCheck === -1) {
        // Working squad check is optional (good if it doesn't exist)
        this.success('Source directory priority: Library agents only (no fallback)');
        return true;
      }

      if (libraryPathCheck < workingSquadCheck) {
        this.success('Source directory priority: Library agents first, then working squad fallback');
        return true;
      } else {
        this.error('Source directory priority incorrect: working squad checked before library agents');
        return false;
      }
    } catch (error) {
      this.error(`Failed to validate source priority: ${error.message}`);
      return false;
    }
  }

  /**
   * Validate README.md consistency
   * Check that README claims match actual deployment
   */
  validateReadmeConsistency(squadFull) {
    try {
      const readme = fs.readFileSync(this.readmePath, 'utf8');

      // Check for mentions of agent count
      const countMatches = readme.match(/\b(\d+)\s+agents?\b/gi);

      if (!countMatches) {
        this.warn('No agent count claims found in README.md');
        return true;
      }

      let hasIncorrectClaim = false;

      countMatches.forEach(match => {
        const number = parseInt(match.match(/\d+/)[0]);

        // Allow mentions of 4 (core squad) and 11 (full squad)
        const validCounts = [4, 11, 2]; // core, full, minimal

        if (!validCounts.includes(number)) {
          this.warn(`README.md mentions "${number} agents" - verify this is correct`);
        } else if (number === this.EXPECTED_AGENT_COUNT) {
          // Found correct claim
          this.success(`README.md correctly claims "${number} agents" for full squad`);
        }
      });

      return !hasIncorrectClaim;
    } catch (error) {
      this.error(`Failed to read README.md: ${error.message}`);
      return false;
    }
  }

  /**
   * Run all validation checks
   */
  validate() {
    this.log('\n🔍 AGENT-11 Deployment Validation', colors.magenta);
    this.log('━'.repeat(50), colors.magenta);
    this.log('');

    // Extract data
    const squadFull = this.extractSquadFull();
    const libraryAgents = this.getLibraryAgents();

    if (!squadFull || libraryAgents.length === 0) {
      this.error('Failed to extract deployment data');
      this.printSummary();
      return 1;
    }

    this.log(`\nFound ${squadFull.length} agents in SQUAD_FULL:`);
    this.log(`  ${squadFull.join(', ')}`, colors.blue);

    this.log(`\nFound ${libraryAgents.length} agents in library:`);
    this.log(`  ${libraryAgents.join(', ')}`, colors.blue);
    this.log('');

    // Run validation checks
    const results = [
      this.validateAgentCount(squadFull),
      this.validateAgentList(squadFull, libraryAgents),
      this.validateSourcePriority(),
      this.validateReadmeConsistency(squadFull),
    ];

    this.printSummary();

    // Return exit code
    return this.errors.length > 0 ? 1 : 0;
  }

  /**
   * Print validation summary
   */
  printSummary() {
    this.log('\n' + '━'.repeat(50), colors.magenta);

    if (this.errors.length === 0 && this.warnings.length === 0) {
      this.log('✅ All validation checks passed!', colors.green);
    } else {
      if (this.errors.length > 0) {
        this.log(`\n❌ Validation failed with ${this.errors.length} error(s):`, colors.red);
        this.errors.forEach(err => this.log(`   • ${err}`, colors.red));
      }

      if (this.warnings.length > 0) {
        this.log(`\n⚠️  ${this.warnings.length} warning(s):`, colors.yellow);
        this.warnings.forEach(warn => this.log(`   • ${warn}`, colors.yellow));
      }
    }

    this.log('');
  }
}

// Run validation if called directly
if (require.main === module) {
  const validator = new DeploymentValidator();
  const exitCode = validator.validate();
  process.exit(exitCode);
}

module.exports = DeploymentValidator;
