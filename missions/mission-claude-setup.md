# Mission: CLAUDE.md Setup & Sync 📋
## Project Configuration and Library Updates

### Mission Type
**Configuration** - CLAUDE.md initialization and synchronization

### Estimated Duration
15-25 minutes

### Required Assets
- AGENT-11 deployed to project
- Project codebase (for analysis)
- Latest AGENT-11 library CLAUDE.md (for comparison)

---

## Mission Briefing

This mission configures or updates the CLAUDE.md file in user projects by:
1. **Initial Setup**: Creating project-specific CLAUDE.md from library template
2. **Update Sync**: Comparing existing CLAUDE.md with latest library version
3. **Smart Merge**: Preserving project-specific customizations while adding new library features
4. **Validation**: Ensuring all required sections are present and properly configured

### Prerequisites
- AGENT-11 deployed to project
- Access to project files

### Use Cases

**Use Case 1: First-Time Setup**
- User just deployed AGENT-11 to their project
- No CLAUDE.md exists yet
- Need to create project-specific configuration

**Use Case 2: Library Update Sync**
- AGENT-11 library updated with new features
- Deployment script detected existing CLAUDE.md (didn't overwrite)
- Need to merge new library sections with existing customizations

**Use Case 3: Manual Review Request**
- User wants to review/improve their CLAUDE.md
- Ensure best practices are followed
- Add missing sections

---

## Execution Protocol

### Phase 1: Detection & Analysis (5 min)
```bash
/coord "Analyzing CLAUDE.md status..."
```

**Agent Actions:**
- @documenter performs CLAUDE.md analysis:

**Step 1: Detect Current State**
```bash
# Check if CLAUDE.md exists
ls -la CLAUDE.md .claude/CLAUDE.md .claude/claude.md

# Determine scenario:
# - No file → First-time setup
# - File exists → Update/sync scenario
```

**Step 2: Load Library Template**
- Read latest AGENT-11 library CLAUDE.md from:
  - `/Users/jamiewatters/DevProjects/agent-11/.claude/CLAUDE.md` (working squad)
  - `/Users/jamiewatters/DevProjects/agent-11/.claude/claude.md` (check both)
- Extract library sections and features

**Step 3: Analyze Existing File (if present)**
```markdown
### Current CLAUDE.md Analysis

**Sections Present**:
- [✅/❌] Project Overview
- [✅/❌] Environment Configuration
- [✅/❌] User Profile/Communication Guidelines
- [✅/❌] Critical Software Development Principles
- [✅/❌] Architecture Overview
- [✅/❌] Progress Tracking System
- [✅/❌] Context Preservation System
- [✅/❌] Coordinator Delegation Protocol
- [✅/❌] MCP Integration
- [✅/❌] Available Commands
- [✅/❌] Common Tasks

**Project-Specific Customizations Detected**:
- [List custom sections]
- [List project-specific content]
- [List environment details]

**Missing from Library**:
- [List new library features not in user's file]
```

**Step 4: Compare Versions**
```markdown
### Library vs Project Comparison

**New Library Features** (not in project):
1. [New section 1]
2. [New feature 2]
3. [Updated content 3]

**Project Customizations** (preserve):
1. [Custom section 1]
2. [Environment config]
3. [User profile settings]

**Recommendations**:
- Add: [list]
- Update: [list]
- Preserve: [list]
```

---

### Phase 2: User Interaction & Planning (5 min)
```bash
/coord "Planning CLAUDE.md configuration..."
```

**Agent Actions:**
- @coordinator presents findings and gets user input:

**Scenario A: First-Time Setup**
```
I'll create your project's CLAUDE.md file.

I need some information to customize it:

1. Project Name: [prompt]
2. Tech Stack (if different from default): [prompt]
3. Environment Setup:
   - Do you have staging? (yes/no): [prompt]
   - Hosting platforms: [prompt]
   - Database: [prompt]

4. Communication Preferences:
   - Special communication needs? (e.g., ADHD-optimized): [prompt]
   - Technical level: (beginner/intermediate/advanced): [prompt]

[Collect responses, then proceed to Phase 3]
```

**Scenario B: Update/Sync**
```
I compared your CLAUDE.md with the latest library version.

**New Features Available**:
1. [Feature 1 description]
2. [Feature 2 description]
3. [Feature 3 description]

**Your Custom Sections** (will be preserved):
- [Custom section 1]
- [Custom section 2]

Would you like me to:
1. Add all new features (recommended)
2. Show me each feature and I'll decide
3. Just show me what's different (no changes)

[Wait for response]
```

**Scenario C: Manual Review**
```
I'll review your CLAUDE.md for best practices.

**Analysis**:
- Missing sections: [list]
- Outdated content: [list]
- Recommendations: [list]

Proceed with improvements? (yes/no)
```

---

### Phase 3: CLAUDE.md Generation/Update (10-15 min)
```bash
/coord "Configuring CLAUDE.md..."
```

**Agent Actions:**
- @documenter creates or updates CLAUDE.md:

**For First-Time Setup:**

1. **Start with Library Template**
   - Copy base structure from AGENT-11 library
   - Preserve core sections (Critical Software Development Principles, etc.)

2. **Customize Project-Specific Sections**

**Section 1: Project Overview** (CUSTOMIZE)
```markdown
## Project Overview

[Project Name] - [Brief description]

**Tech Stack**:
- Frontend: [React/Vue/etc] + [TypeScript/JavaScript] + [Vite/Webpack]
- Backend: [Express/FastAPI/etc] + [TypeScript/Python/etc]
- Database: [PostgreSQL/MongoDB/Supabase]
- Authentication: [JWT/OAuth/Supabase Auth]
- Payments: [Stripe/Paddle] (if applicable)

**Business Model**: [Description if applicable]
```

**Section 2: Environment Configuration** (CUSTOMIZE from opsdev-setup results)
```markdown
## Environment Setup

### Production
- **Frontend**: [URL] ([Platform], `main` branch)
- **Backend**: [URL] ([Platform], `main` branch)
- **Database**: [Provider] ([project/instance])

### Staging (if applicable)
- **Frontend**: [URL] ([Platform], `develop` branch)
- **Backend**: [URL] ([Platform], `develop` branch)
- **Database**: [Provider] ([staging project])

### Development Workflow
See `/docs/[workflow-guide].md` for complete workflow.

**Branch Strategy**:
- `main` → Production (auto-deploy)
- `develop` → Staging (auto-deploy) [if applicable]
- `feature/*` → PR previews

**Deployment Flow**:
1. Create `feature/*` branch from `develop` [or `main`]
2. Push → PR to `develop` [or `main`] → Auto-deploys to staging [or preview]
3. Test on staging [or preview] URLs
4. PR from `develop` to `main` → Production [if staging exists]

### Service Dashboards
[Platform-specific sections based on detected services]
```

**Section 3: User Profile** (CUSTOMIZE if ADHD or other needs)
```markdown
## User Communication Guidelines

### User Context
[Add if user specified communication needs]
- **[Need]**: [Description]
- **Technical Knowledge**: [Level]
- **Communication Preference**: [Style]

### Communication Guidelines

**DO:**
- ✅ [Guideline 1]
- ✅ [Guideline 2]

**DON'T:**
- ❌ [Anti-pattern 1]
- ❌ [Anti-pattern 2]

[Include examples if user has ADHD or specific needs]
```

**Section 4-10: Library Sections** (COPY from library)
- Critical Software Development Principles
- Architecture Overview
- Progress Tracking System
- Context Preservation System
- Coordinator Delegation Protocol
- MCP Integration
- Available Commands

**For Update/Sync:**

1. **Preserve Project Customizations**
   - Keep custom "Project Overview"
   - Keep custom "Environment Setup"
   - Keep custom "User Profile"
   - Keep any custom sections user added

2. **Add Missing Library Sections**
   - Identify sections in library but not in project
   - Insert at appropriate locations
   - Maintain consistent formatting

3. **Update Changed Library Sections**
   - Compare library vs project for core sections
   - Highlight differences
   - Recommend updates (with user approval)

4. **Smart Merge Strategy**
```markdown
## Merge Plan

**Preserve (No Changes)**:
- Project Overview (lines 1-50)
- Environment Setup (lines 51-150)
- User Communication Guidelines (lines 151-200)
- [Other custom sections]

**Add (New from Library)**:
- Section: Context Preservation System → Insert after line 300
- Section: Coordinator Delegation Protocol → Insert after line 350
- Updated: MCP Integration section → Replace lines 400-450

**Update (Library Changes)**:
- Critical Software Development Principles → Updated examples
- Progress Tracking System → New template references

**Confirm Changes?** (yes/no/show me each)
```

5. **Execute Merge**
   - Create backup: `CLAUDE.md.backup-[timestamp]`
   - Apply changes
   - Validate structure

---

### Phase 4: Validation & Testing (5 min)
```bash
/coord "Validating CLAUDE.md configuration..."
```

**Agent Actions:**
- @documenter validates the configuration:

**Validation Checklist:**
```markdown
### CLAUDE.md Validation

**Required Sections** (from library):
- [✅/❌] Critical Software Development Principles
- [✅/❌] Progress Tracking System
- [✅/❌] Context Preservation System
- [✅/❌] Coordinator Delegation Protocol
- [✅/❌] MCP Integration
- [✅/❌] Available Commands

**Project-Specific Sections**:
- [✅/❌] Project Overview (customized)
- [✅/❌] Environment Setup (if applicable)
- [✅/❌] Tech Stack documented
- [✅/❌] Branch strategy documented (if multi-env)

**Formatting**:
- [✅/❌] Consistent markdown headers
- [✅/❌] Code blocks properly formatted
- [✅/❌] Links functional
- [✅/❌] No broken references

**Content Quality**:
- [✅/❌] No placeholder text ([TBD], [TODO])
- [✅/❌] Project-specific details filled in
- [✅/❌] No contradictions with codebase
- [✅/❌] MCP integration reflects available tools

**Validation Result**: [✅ Pass | ⚠️ Needs Review | ❌ Failed]
```

**If Issues Found:**
```
Validation found [X] issues:
1. [Issue description] → [Recommendation]
2. [Issue description] → [Recommendation]

Fix automatically? (yes/no/show me first)
```

---

## Success Metrics

✅ **Mission Complete When:**
- [ ] CLAUDE.md exists in project root
- [ ] All required library sections present
- [ ] Project-specific customizations added
- [ ] Environment configuration documented (if applicable)
- [ ] User communication guidelines configured (if needed)
- [ ] Validation passed
- [ ] Backup created (for updates)
- [ ] User confirmed final result

---

## Output Examples

### Example 1: First-Time Setup Result

```markdown
✅ CLAUDE.md Created Successfully

**Configured Sections**:
- ✅ Project Overview (TaskFlow - Task Management SaaS)
- ✅ Environment Setup (Production + Staging with Netlify/Railway)
- ✅ User Communication (ADHD-optimized)
- ✅ All library sections (11 total)

**File Location**: `/Users/user/project/CLAUDE.md`
**Size**: 15,234 bytes
**Sections**: 14 total (3 custom + 11 library)

**Next Steps**:
1. Review the file and make any final adjustments
2. Commit: `git add CLAUDE.md && git commit -m "Configure CLAUDE.md"`
3. AGENT-11 agents will now use this project-specific guidance
```

### Example 2: Update/Sync Result

```markdown
✅ CLAUDE.md Updated Successfully

**Backup Created**: `CLAUDE.md.backup-2025-10-18-143022`

**Changes Applied**:
- ✅ Added: Context Preservation System (new in library)
- ✅ Added: Coordinator Delegation Protocol (new in library)
- ✅ Updated: MCP Integration (new tools added)
- ✅ Updated: Critical Software Development Principles (new examples)

**Preserved**:
- ✅ Project Overview (your custom content)
- ✅ Environment Setup (your staging config)
- ✅ User Communication Guidelines (ADHD settings)
- ✅ Custom section: "Service Dashboards"

**File Location**: `/Users/user/project/CLAUDE.md`
**Diff**: +234 lines, -18 lines
**New Features**: 4 sections

**Next Steps**:
1. Review changes: `git diff CLAUDE.md`
2. Compare with backup if needed
3. Commit: `git add CLAUDE.md && git commit -m "Update CLAUDE.md with library features"`
```

---

## Post-Mission Checklist

1. **Verify Configuration:**
   - Review CLAUDE.md in editor
   - Ensure project details are accurate
   - Check that environment URLs are correct

2. **Test Agent Understanding:**
   - Ask any agent: "What's our branch strategy?"
   - Verify agent can access project context
   - Confirm MCP integration is documented

3. **Commit Changes:**
   ```bash
   git add CLAUDE.md
   git commit -m "📋 Configure CLAUDE.md for project"
   git push
   ```

4. **Optional: Archive Backup:**
   ```bash
   # If update created backup
   mkdir -p .claude/backups
   mv CLAUDE.md.backup-* .claude/backups/
   ```

---

## Troubleshooting

### Issue: Can't Find Library CLAUDE.md
**Symptom**: Mission can't locate AGENT-11 library template
**Solution**:
1. Check `/Users/jamiewatters/DevProjects/agent-11/.claude/CLAUDE.md`
2. Or use this mission's embedded template
3. Or ask user for AGENT-11 install location

### Issue: Merge Conflicts
**Symptom**: Can't automatically merge library updates with custom content
**Solution**:
1. Create side-by-side comparison
2. Show user both versions
3. Manual merge with user guidance
4. Preserve backup

### Issue: Missing Project Information
**Symptom**: Can't determine tech stack or environment setup
**Solution**:
1. Analyze package.json, requirements.txt, etc.
2. Check git branches for environment strategy
3. Ask user to provide missing details
4. Mark sections as [TBD] for user to fill in

### Issue: User Has Heavy Customizations
**Symptom**: User's CLAUDE.md is very different from library
**Solution**:
1. Respect user's structure
2. Add library features as appendix
3. Create "Library Features Reference" section
4. Don't force library structure

---

## Advanced Features

### Smart Section Detection

The mission uses intelligent detection to identify:
- Custom project sections (preserve)
- Standard library sections (update)
- Outdated content (recommend updates)
- Missing best practices (suggest additions)

### Diff Highlighting

For updates, show clear before/after:
```markdown
### MCP Integration (UPDATED)

**Before** (your version):
- Basic MCP list
- No usage examples

**After** (library version):
- Comprehensive MCP categories
- Usage patterns and examples
- Discovery protocol
- Integration in missions

**Recommendation**: Add usage patterns while keeping your custom MCP list
```

### Incremental Updates

If many changes, offer staged updates:
```
I found 8 new features to add. Would you like to:
1. Add all at once (fast, might need review)
2. One at a time (interactive, I'll explain each)
3. Just critical updates (principles, tracking, etc.)
```

---

## Related Missions
- **Dev-Setup** - Initial greenfield project setup (includes CLAUDE.md creation)
- **Dev-Alignment** - Existing project understanding (includes CLAUDE.md review)
- **OpsDev Setup** - Environment configuration (feeds into CLAUDE.md)

---

## Command Reference

```bash
# Run CLAUDE.md setup mission
/coord claude-setup

# First-time setup mode
/coord claude-setup --new

# Update/sync mode
/coord claude-setup --sync

# Review/validate existing
/coord claude-setup --review

# Compare with library
/coord claude-setup --compare

# Interactive mode (walk through sections)
/coord claude-setup --interactive
```

---

## Template Sections Reference

### Minimal CLAUDE.md (Small Projects)

Required sections only:
1. Project Overview
2. Critical Software Development Principles
3. Progress Tracking System
4. Common Tasks

### Standard CLAUDE.md (Most Projects)

Minimal + recommended:
5. Environment Setup
6. Coordinator Delegation Protocol
7. MCP Integration
8. Available Commands

### Complete CLAUDE.md (Complex Projects)

Standard + advanced:
9. User Communication Guidelines
10. Context Preservation System
11. Agent Tool Specification
12. Architecture Overview
13. Mission Documentation Standards

---

## Integration with Other Missions

### After Dev-Setup
```bash
# dev-setup creates initial CLAUDE.md
# claude-setup can enhance it with project-specific details
/coord dev-setup ideation.md
/coord claude-setup --enhance
```

### After OpsDev-Setup
```bash
# opsdev-setup discovers environment architecture
# claude-setup adds environment config to CLAUDE.md
/coord opsdev-setup
/coord claude-setup --add-environment
```

### Before Major Missions
```bash
# Ensure CLAUDE.md is up-to-date before complex missions
/coord claude-setup --review
/coord build requirements.md
```

---

## Best Practices

### DO:
- ✅ Always create backup before updates
- ✅ Preserve project-specific customizations
- ✅ Validate after changes
- ✅ Test agent understanding
- ✅ Commit changes with clear message
- ✅ Keep user informed of changes

### DON'T:
- ❌ Overwrite custom sections without asking
- ❌ Remove project-specific content
- ❌ Add library sections user explicitly removed
- ❌ Change user's communication guidelines
- ❌ Skip validation step
- ❌ Delete backup files immediately

---

*"Clear guidance makes great agents."* - AGENT-11 Field Manual
