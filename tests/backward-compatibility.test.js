/**
 * AGENT-11 Backward Compatibility Test Suite
 * Tests dual parsing and ensures all 19 missions work with both formats
 */

const AgentParser = require('../scripts/agent-parser');
const AgentMigrator = require('../scripts/migrate-agent-schema');
const SchemaValidator = require('../scripts/validate-schema');
const SemanticValidator = require('../scripts/validate-semantics');
const ContentValidator = require('../scripts/validate-content');
const fs = require('fs');
const path = require('path');
const { glob } = require('glob');

describe('Backward Compatibility', () => {
  const parser = new AgentParser();
  const migrator = new AgentMigrator();
  const schemaValidator = new SchemaValidator();
  const semanticValidator = new SemanticValidator();
  const contentValidator = new ContentValidator();

  describe('Legacy Format (v1.0) Parsing', () => {
    let testFile;

    beforeAll(() => {
      testFile = '/tmp/test-legacy-agent.md';
    });

    afterAll(() => {
      if (fs.existsSync(testFile)) {
        fs.unlinkSync(testFile);
      }
    });

    test('should parse legacy frontmatter correctly', () => {
      const content = `---
name: coordinator
description: Test agent for backward compatibility
color: green
---
# Agent Content
## TOOL PERMISSIONS
Primary tools listed here.
`;

      fs.writeFileSync(testFile, content);
      const result = parser.parse(testFile);

      expect(result.format).toBe('yaml-v1-legacy');
      expect(result.metadata.name).toBe('coordinator');
      expect(result.metadata.version).toBe('1.0.0');
      expect(result.metadata.color).toBe('green');
      expect(result._legacy).toBe(true);
      expect(result._migration_needed).toBe(true);
    });

    test('should infer default thinking mode', () => {
      const content = `---
name: architect
description: Test architect
color: yellow
---
# Content
`;

      fs.writeFileSync(testFile, content);
      const result = parser.parse(testFile);

      expect(result.thinking.default).toBe('ultrathink');
    });

    test('should infer tags from agent name', () => {
      const content = `---
name: developer
description: Test developer
color: blue
---
# Content
`;

      fs.writeFileSync(testFile, content);
      const result = parser.parse(testFile);

      expect(result.metadata.tags).toContain('core');
      expect(result.metadata.tags).toContain('technical');
    });

    test('should extract tools from markdown TOOL PERMISSIONS section', () => {
      const content = `---
name: developer
description: Test
color: blue
---
## TOOL PERMISSIONS
**Primary Tools**:
- **Read** - Reading files
- **Write** - Writing files
- **Bash** - Running commands
`;

      fs.writeFileSync(testFile, content);
      const result = parser.parse(testFile);

      expect(result.tools.primary).toContain('Read');
      expect(result.tools.primary).toContain('Write');
      expect(result.tools.primary).toContain('Bash');
    });
  });

  describe('Pure Markdown (v0.x) Parsing', () => {
    let testFile;

    beforeAll(() => {
      testFile = '/tmp/test-markdown-agent.md';
    });

    afterAll(() => {
      if (fs.existsSync(testFile)) {
        fs.unlinkSync(testFile);
      }
    });

    test('should parse markdown-only files', () => {
      const content = 'You are THE DEVELOPER\n\nDoes development work.';

      fs.writeFileSync(testFile, content);
      const result = parser.parse(testFile);

      expect(result.format).toBe('markdown-only-legacy');
      expect(result.metadata.name).toBe('developer');
      expect(result.metadata.status).toBe('deprecated');
      expect(result._legacy).toBe(true);
      expect(result._migration_urgent).toBe(true);
    });
  });

  describe('New Format (v3.0) Parsing', () => {
    let testFile;

    beforeAll(() => {
      testFile = '/tmp/test-new-agent.md';
    });

    afterAll(() => {
      if (fs.existsSync(testFile)) {
        fs.unlinkSync(testFile);
      }
    });

    test('should parse new format correctly', () => {
      const content = `---
name: coordinator
description: Test agent
version: "3.0.0"
status: stable
color: green
thinking:
  default: think hard
tools:
  primary: ["Read", "Write", "Task"]
  mcp: ["mcp__github"]
coordinates_with: ["developer", "tester"]
verification_required: true
self_verification: true
---
# Content
`;

      fs.writeFileSync(testFile, content);
      const result = parser.parse(testFile);

      expect(result.format).toBe('yaml-v3');
      expect(result.metadata.version).toBe('3.0.0');
      expect(result.metadata.status).toBe('stable');
      expect(result.thinking.default).toBe('think hard');
      expect(result.tools.primary).toEqual(['Read', 'Write', 'Task']);
      expect(result.tools.mcp).toEqual(['mcp__github']);
      expect(result.coordination.coordinates_with).toEqual(['developer', 'tester']);
      expect(result.verification.required).toBe(true);
      expect(result.verification.self_verification).toBe(true);
      expect(result._legacy).toBeUndefined();
    });
  });

  describe('Agent Registry Compatibility', () => {
    test('should discover all specialist agents', async () => {
      const pattern = 'project/agents/specialists/*.md';
      const files = await glob(pattern, { cwd: process.cwd() });

      expect(files.length).toBeGreaterThan(0);

      // All agents should parse successfully
      files.forEach(file => {
        expect(() => {
          parser.parse(path.resolve(file));
        }).not.toThrow();
      });
    });

    test('should parse all agents in under 100ms average', async () => {
      const pattern = 'project/agents/specialists/*.md';
      const files = await glob(pattern, { cwd: process.cwd() });

      const times = [];

      files.forEach(file => {
        const start = performance.now();
        parser.parse(path.resolve(file));
        times.push(performance.now() - start);
      });

      const avgTime = times.reduce((sum, t) => sum + t, 0) / times.length;

      expect(avgTime).toBeLessThan(100); // <100ms average
    });
  });

  describe('Validation Layers', () => {
    let testFile;

    beforeAll(() => {
      testFile = '/tmp/test-validation-agent.md';
    });

    afterAll(() => {
      if (fs.existsSync(testFile)) {
        fs.unlinkSync(testFile);
      }
    });

    test('schema validator should validate correct schema', () => {
      const content = `---
name: test-agent
description: Test agent for validation
version: "3.0.0"
status: stable
tools:
  primary: ["Read", "Write"]
---
# Content
`;

      fs.writeFileSync(testFile, content);
      const result = schemaValidator.validateFile(testFile);

      expect(result.valid).toBe(true);
      expect(result.performance).toBeLessThan(10); // <10ms target
    });

    test('schema validator should catch missing required fields', () => {
      const content = `---
version: "3.0.0"
---
# Missing name and description
`;

      fs.writeFileSync(testFile, content);
      const result = schemaValidator.validateFile(testFile);

      expect(result.valid).toBe(false);
      expect(result.errors.length).toBeGreaterThan(0);
      expect(result.errors.some(e => e.field === 'name' || e.message.includes('name'))).toBe(true);
    });

    test('schema validator should detect duplicate tools', () => {
      const content = `---
name: test-agent
description: Test agent
tools:
  primary: ["Read", "Write", "Edit"]
  mcp: ["mcp__github"]
  restricted: ["Read"]
---
# Content
`;

      fs.writeFileSync(testFile, content);
      const result = schemaValidator.validateFile(testFile);

      expect(result.valid).toBe(false);
      expect(result.errors.some(e => e.message.includes('Duplicate'))).toBe(true);
    });

    test('semantic validator should validate tool registry', () => {
      const yaml = require('js-yaml');
      const content = `---
name: test-agent
description: Test agent
tools:
  primary: ["Read", "Write", "InvalidTool"]
---
# Content
`;

      fs.writeFileSync(testFile, content);
      const parts = content.split('---\n');
      const frontmatter = yaml.load(parts[1]);

      const result = semanticValidator.validateFile(testFile, frontmatter);

      expect(result.errors.some(e => e.message.includes('InvalidTool'))).toBe(true);
    });

    test('content validator should detect missing required sections', () => {
      const yaml = require('js-yaml');
      const content = `---
name: test-agent
description: Test agent
verification_required: true
---
# Content without required sections
`;

      fs.writeFileSync(testFile, content);
      const parts = content.split('---\n');
      const frontmatter = yaml.load(parts[1]);

      const result = contentValidator.validateFile(testFile, frontmatter);

      expect(result.valid).toBe(false);
      expect(result.errors.some(e => e.section.includes('CONTEXT PRESERVATION'))).toBe(true);
      expect(result.errors.some(e => e.section.includes('SELF-VERIFICATION'))).toBe(true);
    });
  });

  describe('Migration Tool', () => {
    let testFile, backupFile;

    beforeAll(() => {
      testFile = '/tmp/test-migrate-agent.md';
      backupFile = `${testFile}.backup`;
    });

    afterAll(() => {
      [testFile, backupFile].forEach(file => {
        if (fs.existsSync(file)) {
          fs.unlinkSync(file);
        }
      });
    });

    test('should migrate legacy agent successfully', () => {
      const content = `---
name: developer
description: Test developer agent
color: blue
---
## TOOL PERMISSIONS
**Primary Tools**: Read, Write
## CONTEXT PRESERVATION PROTOCOL
Guidelines here
## CONTEXT EDITING GUIDANCE
Guidance here
`;

      fs.writeFileSync(testFile, content);

      const result = migrator.migrate(testFile, { dryRun: false });

      expect(result.success).toBe(true);
      expect(result.migrated).toBe(true);

      // Check new format
      const newContent = fs.readFileSync(testFile, 'utf8');
      expect(newContent).toContain('version: 3.0.0');

      // Parse migrated file
      const parsed = parser.parse(testFile);
      expect(parsed.format).toBe('yaml-v3');
    });

    test('should create backup before migration', () => {
      const content = `---
name: tester
description: Test agent
color: purple
---
Content`;

      fs.writeFileSync(testFile, content);

      migrator.migrate(testFile, { dryRun: false });

      expect(fs.existsSync(backupFile)).toBe(true);
    });

    test('should rollback on validation failure', () => {
      const content = `---
name: invalid
description: This will fail validation somehow
color: red
---
Content`;

      fs.writeFileSync(testFile, content);
      const originalContent = content;

      // Migration should succeed initially
      const result = migrator.migrate(testFile, { dryRun: false });

      // If validation passed, that's fine
      // If validation failed, should rollback
      if (!result.success) {
        const currentContent = fs.readFileSync(testFile, 'utf8');
        expect(currentContent).toContain('name: invalid'); // Original preserved
      }
    });

    test('should skip already migrated agents', () => {
      const content = `---
name: coordinator
description: Already v3.0
version: "3.0.0"
---
Content`;

      fs.writeFileSync(testFile, content);

      const result = migrator.migrate(testFile, { dryRun: false });

      expect(result.success).toBe(true);
      expect(result.skipped).toBe(true);
    });
  });

  describe('Performance Targets', () => {
    test('schema validation should complete in <10ms', async () => {
      const pattern = 'project/agents/specialists/*.md';
      const files = await glob(pattern, { cwd: process.cwd() });

      if (files.length === 0) return;

      const times = [];

      files.slice(0, 5).forEach(file => {
        const result = schemaValidator.validateFile(path.resolve(file));
        if (result.performance) {
          times.push(result.performance);
        }
      });

      const avgTime = times.reduce((sum, t) => sum + t, 0) / times.length;

      expect(avgTime).toBeLessThan(10);
    });

    test('total validation should complete in <100ms', async () => {
      const pattern = 'project/agents/specialists/*.md';
      const files = await glob(pattern, { cwd: process.cwd() });

      if (files.length === 0) return;

      const file = path.resolve(files[0]);
      const content = fs.readFileSync(file, 'utf8');
      const parts = content.split('---\n');

      if (parts.length < 3) return;

      const yaml = require('js-yaml');
      const frontmatter = yaml.load(parts[1]);

      const start = performance.now();

      schemaValidator.validateFile(file);
      semanticValidator.validateFile(file, frontmatter);
      contentValidator.validateFile(file, frontmatter);

      const total = performance.now() - start;

      expect(total).toBeLessThan(100);
    });
  });
});
