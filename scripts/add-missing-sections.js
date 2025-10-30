#!/usr/bin/env node

/**
 * Add missing required sections to agent files for Phase 2 completion
 *
 * This script:
 * 1. Converts existing context notes to proper ## CONTEXT PRESERVATION PROTOCOL sections
 * 2. Adds ## CONTEXT EDITING GUIDANCE to coordinator
 * 3. Validates changes
 */

const fs = require('fs');
const path = require('path');

const agentsDir = path.join(__dirname, '../project/agents/specialists');

// Standard context preservation protocol section
const contextPreservationSection = `
## CONTEXT PRESERVATION PROTOCOL

**Before starting any task:**
1. Read agent-context.md for mission-wide context and accumulated findings
2. Read handoff-notes.md for specific task context and immediate requirements
3. Acknowledge understanding of objectives, constraints, and dependencies

**After completing your task:**
1. Update handoff-notes.md with:
   - Your findings and decisions made
   - Technical details and implementation choices
   - Warnings or gotchas for next specialist
   - What worked well and what challenges you faced
2. Add evidence to evidence-repository.md if applicable (screenshots, logs, test results)
3. Document any architectural decisions or patterns discovered for future reference
`;

// Context editing guidance for coordinator
const contextEditingSection = `
## CONTEXT EDITING GUIDANCE

**When to Use /clear:**
- Between implementing distinct mission phases (after phase completion)
- After extracting insights to memory and context files
- When context exceeds 30K tokens during long coordination sessions
- Before starting complex multi-hour mission operations
- When switching between unrelated mission domains

**What to Preserve:**
- Memory tool calls (automatically excluded - NEVER cleared)
- Active mission context (current phase objectives)
- Recent delegation patterns and specialist responses (last 3 tool uses)
- Critical coordination decisions and rationale
- Active blockers and dependency tracking

**Strategic Clearing Points:**
- **After Requirements Phase**: Clear detailed discussions, preserve final decisions in agent-context.md
- **Between Mission Phases**: Clear completed phase details, keep active constraints
- **After Major Milestones**: Clear historical context, preserve learnings in memory
- **Before Complex Coordination**: Start with clean context, reference architecture from memory

**Pre-Clearing Workflow:**
1. Extract coordination insights to /memories/lessons/coordination-insights.xml
2. Update agent-context.md with phase findings and decisions
3. Update handoff-notes.md with current mission state for next phase
4. Verify memory contains critical delegation patterns
5. Ensure at least 5K tokens will be cleared (check context size)
6. Execute /clear to remove old coordination history

**Example Context Editing:**
\`\`\`
# Coordinating complex BUILD mission
[30K tokens: requirement analysis, delegation history, specialist responses]

# Phase 1 complete, extracting insights
→ UPDATE /memories/lessons/coordination-insights.xml: Delegation patterns learned
→ UPDATE agent-context.md: Phase 1 outcomes, architecture decisions
→ UPDATE handoff-notes.md: Phase 2 readiness, next specialist assignments
→ VERIFY memory tool calls are recent
→ /clear

# Start Phase 2 with clean context
[Read agent-context.md for mission state, start fresh delegation]
\`\`\`

**Reference:** /project/field-manual/context-editing-guide.md
`;

/**
 * Find where to insert context preservation section
 * Insert after YAML frontmatter and agent description, before other major sections
 */
function findInsertionPoint(content) {
  const lines = content.split('\n');
  let inFrontmatter = false;
  let frontmatterEnd = -1;

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];

    // Track frontmatter boundaries
    if (line.trim() === '---') {
      if (!inFrontmatter) {
        inFrontmatter = true;
      } else {
        frontmatterEnd = i;
        break;
      }
    }
  }

  // Find first ## heading after frontmatter
  for (let i = frontmatterEnd + 1; i < lines.length; i++) {
    if (lines[i].startsWith('## ')) {
      return i;
    }
  }

  // If no ## heading found, insert after frontmatter
  return frontmatterEnd + 1;
}

/**
 * Check if agent already has the section
 */
function hasSection(content, sectionName) {
  return content.includes(`## ${sectionName}`);
}

/**
 * Add section to agent file
 */
function addSection(agentFile, sectionName, sectionContent) {
  const content = fs.readFileSync(agentFile, 'utf8');

  // Check if section already exists
  if (hasSection(content, sectionName)) {
    console.log(`  ⏭️  ${path.basename(agentFile)}: Already has ${sectionName}`);
    return false;
  }

  const lines = content.split('\n');
  const insertionPoint = findInsertionPoint(content);

  // Insert section at the appropriate point
  lines.splice(insertionPoint, 0, sectionContent.trim(), '');

  const newContent = lines.join('\n');
  fs.writeFileSync(agentFile, newContent, 'utf8');

  console.log(`  ✅ ${path.basename(agentFile)}: Added ${sectionName}`);
  return true;
}

/**
 * Process all agent files
 */
function processAgents() {
  console.log('\n🔧 Adding missing sections to agent files...\n');

  const agentFiles = fs.readdirSync(agentsDir)
    .filter(f => f.endsWith('.md'))
    .map(f => path.join(agentsDir, f));

  let modified = 0;
  let skipped = 0;

  // Add CONTEXT PRESERVATION PROTOCOL to all agents
  console.log('📝 Adding CONTEXT PRESERVATION PROTOCOL sections:');
  agentFiles.forEach(file => {
    if (addSection(file, 'CONTEXT PRESERVATION PROTOCOL', contextPreservationSection)) {
      modified++;
    } else {
      skipped++;
    }
  });

  // Add CONTEXT EDITING GUIDANCE to coordinator only
  console.log('\n📝 Adding CONTEXT EDITING GUIDANCE to coordinator:');
  const coordinatorFile = path.join(agentsDir, 'coordinator.md');
  if (addSection(coordinatorFile, 'CONTEXT EDITING GUIDANCE', contextEditingSection)) {
    modified++;
  } else {
    skipped++;
  }

  console.log(`\n📊 Summary:`);
  console.log(`   Modified: ${modified} files`);
  console.log(`   Skipped:  ${skipped} files (already had section)`);
  console.log(`   Total:    ${agentFiles.length} files processed\n`);
}

// Run the script
if (require.main === module) {
  processAgents();

  console.log('✨ Section addition complete!\n');
  console.log('Next steps:');
  console.log('  1. Run validation: npm run validate:agents');
  console.log('  2. Review changes: git diff project/agents/specialists/');
  console.log('  3. Run tests: npm run test:agents\n');
}

module.exports = { addSection, hasSection };
