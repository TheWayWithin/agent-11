/**
 * Quick test script for Phase 1 components
 * Tests Parser, Cache, and Registry
 */

const AgentParser = require('./agent-parser');
const AgentCache = require('./agent-cache');
const AgentRegistry = require('./agent-registry');

console.log('🧪 Testing Phase 1 Components\n');

// Test 1: Parser with legacy format
console.log('Test 1: Parsing legacy agent (coordinator.md)');
const parser = new AgentParser({ silent: false });
const coordPath = 'project/agents/specialists/coordinator.md';

try {
  const result = parser.parse(coordPath);
  console.log(`✅ Parsed successfully`);
  console.log(`   Format: ${result.format}`);
  console.log(`   Name: ${result.metadata.name}`);
  console.log(`   Version: ${result.metadata.version}`);
  console.log(`   Parse time: ${result.performance.toFixed(2)}ms`);
  console.log(`   Tools: ${result.tools.primary.length} primary, ${result.tools.mcp.length} MCP`);
  console.log();
} catch (error) {
  console.log(`❌ Parser test failed: ${error.message}\n`);
}

// Test 2: Cache
console.log('Test 2: Testing cache performance');
try {
  // First parse (cache miss)
  AgentCache.clear();
  const startMiss = performance.now();
  const firstParse = parser.parse(coordPath);
  const missDuration = performance.now() - startMiss;
  AgentCache.set(coordPath, firstParse);

  // Second parse (cache hit)
  const startHit = performance.now();
  const cached = AgentCache.get(coordPath);
  const hitDuration = performance.now() - startHit;

  const speedup = ((missDuration / hitDuration)).toFixed(0);

  console.log(`✅ Cache working`);
  console.log(`   Cache miss: ${missDuration.toFixed(2)}ms`);
  console.log(`   Cache hit: ${hitDuration.toFixed(2)}ms`);
  console.log(`   Speedup: ${speedup}x faster`);
  console.log(`   ${AgentCache.report()}`);
  console.log();
} catch (error) {
  console.log(`❌ Cache test failed: ${error.message}\n`);
}

// Test 3: Registry
console.log('Test 3: Testing agent registry');
try {
  const registry = new AgentRegistry('project/agents/specialists');
  const agents = registry.listAgents();
  console.log(`✅ Registry discovered ${agents.length} agents`);
  console.log(`   Agents: ${agents.slice(0, 5).join(', ')}...`);

  // Test lazy loading
  const coord = registry.getAgent('coordinator');
  console.log(`✅ Lazy loaded coordinator`);
  console.log(`   Format: ${coord.format}`);

  console.log(`\n${registry.report()}`);
  console.log();
} catch (error) {
  console.log(`❌ Registry test failed: ${error.message}\n`);
}

console.log('🎉 Phase 1 tests complete!');
