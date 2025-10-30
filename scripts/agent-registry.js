/**
 * Agent Registry - Lazy loading with cache integration
 *
 * Discovers agent files and loads them on-demand.
 * Integrates with AgentCache for performance.
 *
 * Performance Target: ~50ms discovery, <1ms cached access, ~40ms first load
 */

const AgentParser = require('./agent-parser');
const AgentCache = require('./agent-cache');
const glob = require('glob');
const path = require('path');
const fs = require('fs');

class AgentRegistry {
  constructor(agentDir = 'project/agents/specialists', options = {}) {
    this.agentDir = agentDir;
    this.agents = new Map(); // Lazy-loaded agents: name -> parsed data
    this.agentFiles = new Map(); // Agent name -> file path
    this.parser = new AgentParser(options);
    this.logger = options.logger || console;

    // Discover agent files (fast scan)
    this.discover();
  }

  /**
   * Discover agent files without parsing
   * Only scans file names and quick YAML name extraction
   */
  discover() {
    const startTime = performance.now();

    const pattern = path.join(this.agentDir, '*.md');
    const files = glob.sync(pattern);

    files.forEach(file => {
      // Quick name extraction (no full parse)
      const name = this.extractNameQuick(file);
      if (name) {
        this.agentFiles.set(name, file);
      }
    });

    const duration = performance.now() - startTime;
    this.logger.log(`📂 Discovered ${files.length} agents in ${duration.toFixed(2)}ms`);
  }

  /**
   * Extract agent name without full parse
   * Reads only first 300 bytes for YAML frontmatter name
   */
  extractNameQuick(file) {
    try {
      const fd = fs.openSync(file, 'r');
      const buffer = Buffer.alloc(300);
      fs.readSync(fd, buffer, 0, 300, 0);
      fs.closeSync(fd);

      const content = buffer.toString('utf8');

      // Try to match "name: agent-name" in frontmatter
      const nameMatch = content.match(/name:\s*['"]?([a-z0-9-]+)['"]?/);

      if (nameMatch) {
        return nameMatch[1];
      }

      // Fallback to filename
      return path.basename(file, '.md');
    } catch (error) {
      // If quick extraction fails, fallback to filename
      return path.basename(file, '.md');
    }
  }

  /**
   * Get agent (lazy load on first access)
   * @param {string} name - Agent name
   * @returns {Object} Parsed agent data
   */
  getAgent(name) {
    // Check if already loaded in memory
    if (this.agents.has(name)) {
      return this.agents.get(name);
    }

    // Get file path
    const file = this.agentFiles.get(name);
    if (!file) {
      throw new Error(`Agent not found: ${name}`);
    }

    // Check cache first
    const cached = AgentCache.get(file);
    if (cached) {
      this.agents.set(name, cached);
      return cached;
    }

    // Parse on demand
    const startTime = performance.now();
    const parsed = this.parser.parse(file);
    const duration = performance.now() - startTime;

    // Store in cache and registry
    AgentCache.set(file, parsed);
    this.agents.set(name, parsed);

    if (duration > 50) {
      this.logger.warn(`⚠️ Slow parse for ${name}: ${duration.toFixed(2)}ms`);
    }

    return parsed;
  }

  /**
   * Preload specific agents for faster access
   * @param {string[]} names - Agent names to preload
   */
  preload(names) {
    const startTime = performance.now();

    names.forEach(name => {
      try {
        this.getAgent(name);
      } catch (error) {
        this.logger.warn(`⚠️ Failed to preload ${name}: ${error.message}`);
      }
    });

    const duration = performance.now() - startTime;
    this.logger.log(`⚡ Preloaded ${names.length} agents in ${duration.toFixed(2)}ms`);
  }

  /**
   * Preload core agents (coordinator, developer, tester, strategist)
   */
  preloadCore() {
    this.preload(['coordinator', 'developer', 'tester', 'strategist']);
  }

  /**
   * Get all agent names (without parsing)
   */
  listAgents() {
    return Array.from(this.agentFiles.keys());
  }

  /**
   * Get all loaded agents (actually parsed)
   */
  getLoadedAgents() {
    return Array.from(this.agents.keys());
  }

  /**
   * Reload specific agent (invalidate cache)
   */
  reload(name) {
    const file = this.agentFiles.get(name);
    if (file) {
      AgentCache.invalidate(file);
      this.agents.delete(name);
      this.logger.log(`🔄 Reloaded agent: ${name}`);
    }
  }

  /**
   * Reload all agents (invalidate all caches)
   */
  reloadAll() {
    AgentCache.clear();
    this.agents.clear();
    this.discover();
    this.logger.log(`🔄 Reloaded all agents`);
  }

  /**
   * Get agent file path
   */
  getAgentFilePath(name) {
    return this.agentFiles.get(name);
  }

  /**
   * Check if agent exists
   */
  hasAgent(name) {
    return this.agentFiles.has(name);
  }

  /**
   * Get registry statistics
   */
  getStats() {
    return {
      discovered: this.agentFiles.size,
      loaded: this.agents.size,
      cached: AgentCache.getStats().size,
      cacheStats: AgentCache.getStats()
    };
  }

  /**
   * Report registry status
   */
  report() {
    const stats = this.getStats();
    const cacheStats = AgentCache.getStats();

    return `
📋 Agent Registry Statistics:
   Discovered: ${stats.discovered} agents
   Loaded: ${stats.loaded} agents
   Cache: ${stats.cached} entries
   Cache Hit Rate: ${cacheStats.hitRatePercent}%

   Available Agents: ${this.listAgents().join(', ')}
    `.trim();
  }

  /**
   * Get all agents (loads all if not already loaded)
   */
  getAllAgents() {
    const agents = {};
    const names = this.listAgents();

    names.forEach(name => {
      try {
        agents[name] = this.getAgent(name);
      } catch (error) {
        this.logger.error(`Failed to load ${name}: ${error.message}`);
      }
    });

    return agents;
  }
}

// Export class (not singleton - allow multiple registries)
module.exports = AgentRegistry;
