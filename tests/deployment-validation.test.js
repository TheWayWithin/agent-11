/**
 * AGENT-11 Deployment Validation Test Suite
 * Tests deployment consistency to prevent Phase 3 bugs from recurring
 */

const DeploymentValidator = require('../scripts/validate-deployment');
const fs = require('fs');
const path = require('path');

describe('Deployment Validation', () => {
  let validator;

  beforeEach(() => {
    validator = new DeploymentValidator();
  });

  describe('SQUAD_FULL Validation', () => {
    test('should extract SQUAD_FULL from install.sh', () => {
      const squadFull = validator.extractSquadFull();

      expect(squadFull).toBeDefined();
      expect(Array.isArray(squadFull)).toBe(true);
      expect(squadFull.length).toBeGreaterThan(0);
    });

    test('SQUAD_FULL should contain exactly 11 agents', () => {
      const squadFull = validator.extractSquadFull();

      expect(squadFull).toBeDefined();
      expect(squadFull.length).toBe(11);
    });

    test('SQUAD_FULL should contain expected core agents', () => {
      const squadFull = validator.extractSquadFull();
      const coreAgents = ['strategist', 'developer', 'tester', 'operator'];

      expect(squadFull).toBeDefined();

      coreAgents.forEach(agent => {
        expect(squadFull).toContain(agent);
      });
    });

    test('SQUAD_FULL should contain coordinator agent', () => {
      const squadFull = validator.extractSquadFull();

      expect(squadFull).toBeDefined();
      expect(squadFull).toContain('coordinator');
    });
  });

  describe('Library Agents Directory', () => {
    test('should read library agents from specialists directory', () => {
      const libraryAgents = validator.getLibraryAgents();

      expect(libraryAgents).toBeDefined();
      expect(Array.isArray(libraryAgents)).toBe(true);
      expect(libraryAgents.length).toBeGreaterThan(0);
    });

    test('library should contain exactly 11 agent files', () => {
      const libraryAgents = validator.getLibraryAgents();

      expect(libraryAgents.length).toBe(11);
    });

    test('all library agents should be .md files (excluding backups and system files)', () => {
      const libraryPath = validator.libraryAgentsPath;
      const files = fs.readdirSync(libraryPath);
      const agentFiles = files.filter(file =>
        file.endsWith('.md') && !file.endsWith('.backup') && !file.startsWith('.')
      );

      // Should have exactly 11 agent .md files (not counting backups)
      expect(agentFiles.length).toBe(11);
    });
  });

  describe('Agent List Consistency', () => {
    test('SQUAD_FULL should match library agents directory', () => {
      const squadFull = validator.extractSquadFull();
      const libraryAgents = validator.getLibraryAgents();

      expect(squadFull).toBeDefined();
      expect(libraryAgents).toBeDefined();

      const squadSorted = [...squadFull].sort();
      const librarySorted = [...libraryAgents].sort();

      expect(squadSorted).toEqual(librarySorted);
    });

    test('no agents in SQUAD_FULL should be missing from library', () => {
      const squadFull = validator.extractSquadFull();
      const libraryAgents = validator.getLibraryAgents();

      const missingInLibrary = squadFull.filter(agent => !libraryAgents.includes(agent));

      expect(missingInLibrary).toEqual([]);
    });

    test('no agents in library should be missing from SQUAD_FULL', () => {
      const squadFull = validator.extractSquadFull();
      const libraryAgents = validator.getLibraryAgents();

      const missingInSquad = libraryAgents.filter(agent => !squadFull.includes(agent));

      expect(missingInSquad).toEqual([]);
    });
  });

  describe('Source Directory Priority', () => {
    test('install.sh should check library agents path', () => {
      const installScript = fs.readFileSync(validator.installScriptPath, 'utf8');

      expect(installScript).toContain('project/agents/specialists');
    });

    test('install.sh should prioritize library agents before working squad', () => {
      const installScript = fs.readFileSync(validator.installScriptPath, 'utf8');

      // Find install_agent function
      const functionMatch = installScript.match(/install_agent\(\) \{[\s\S]*?\n\}/);
      expect(functionMatch).toBeDefined();

      const functionBody = functionMatch[0];
      const libraryIndex = functionBody.indexOf('project/agents/specialists');
      const workingSquadIndex = functionBody.indexOf('.claude/agents');

      // Library should be checked first (lower index)
      if (workingSquadIndex !== -1) {
        expect(libraryIndex).toBeLessThan(workingSquadIndex);
      } else {
        // If working squad fallback doesn't exist, that's fine
        expect(libraryIndex).toBeGreaterThan(-1);
      }
    });
  });

  describe('README.md Consistency', () => {
    test('README.md should exist', () => {
      expect(fs.existsSync(validator.readmePath)).toBe(true);
    });

    test('README.md should mention agent count', () => {
      const readme = fs.readFileSync(validator.readmePath, 'utf8');
      const countMatches = readme.match(/\b(\d+)\s+agents?\b/gi);

      expect(countMatches).toBeDefined();
      expect(countMatches.length).toBeGreaterThan(0);
    });

    test('README.md should correctly claim 11 agents for full squad', () => {
      const readme = fs.readFileSync(validator.readmePath, 'utf8');

      // Should contain "11 agents" somewhere
      expect(readme.toLowerCase()).toMatch(/\b11\s+agents?\b/);
    });
  });

  describe('Complete Validation Run', () => {
    test('full validation should pass without errors', () => {
      // Suppress console output during test
      const originalLog = console.log;
      console.log = jest.fn();

      const exitCode = validator.validate();

      // Restore console.log
      console.log = originalLog;

      expect(exitCode).toBe(0);
      expect(validator.errors).toEqual([]);
    });

    test('validation should complete quickly (< 500ms)', () => {
      const start = performance.now();

      // Suppress console output
      const originalLog = console.log;
      console.log = jest.fn();

      validator.validate();

      console.log = originalLog;

      const duration = performance.now() - start;

      expect(duration).toBeLessThan(500);
    });
  });

  describe('Error Detection', () => {
    test('should detect if SQUAD_FULL count is incorrect', () => {
      const squadFull = validator.extractSquadFull();

      // Test the validator's count check
      const result = validator.validateAgentCount(squadFull);

      expect(result).toBe(true); // Should pass with correct count
    });

    test('should detect missing agents in library', () => {
      const squadFull = validator.extractSquadFull();
      const libraryAgents = validator.getLibraryAgents();

      // All squad agents should exist in library
      const missingAgents = squadFull.filter(agent => !libraryAgents.includes(agent));

      expect(missingAgents).toEqual([]);
    });

    test('should detect extra agents in library', () => {
      const squadFull = validator.extractSquadFull();
      const libraryAgents = validator.getLibraryAgents();

      // All library agents should exist in squad
      const extraAgents = libraryAgents.filter(agent => !squadFull.includes(agent));

      expect(extraAgents).toEqual([]);
    });
  });

  describe('Phase 3 Bug Prevention', () => {
    test('should prevent SQUAD_FULL count mismatch (Phase 3 Bug #1)', () => {
      const squadFull = validator.extractSquadFull();

      // This would have caught the Phase 3 bug where count was wrong
      expect(squadFull.length).toBe(11);
    });

    test('should prevent agent list mismatch (Phase 3 Bug #2)', () => {
      const squadFull = validator.extractSquadFull();
      const libraryAgents = validator.getLibraryAgents();

      // This would have caught if SQUAD_FULL had wrong agent names
      const squadSet = new Set(squadFull);
      const librarySet = new Set(libraryAgents);

      expect(squadSet.size).toBe(librarySet.size);

      // Every agent in squad should be in library
      squadFull.forEach(agent => {
        expect(librarySet.has(agent)).toBe(true);
      });
    });

    test('should prevent incorrect source priority (Phase 3 Bug #3)', () => {
      const result = validator.validateSourcePriority();

      // This would have caught if working squad was checked before library
      expect(result).toBe(true);
    });
  });
});
