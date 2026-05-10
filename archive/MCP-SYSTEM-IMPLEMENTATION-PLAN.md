# AGENT-11 MCP System v3.0 Implementation Plan

**Version:** 3.0 (Documentation-Only)
**Date:** October 21, 2025
**Estimated Time:** 8 hours (1 day)
**Architecture:** Pure documentation, no runtime code

---

## Executive Summary

This plan implements a documentation-driven MCP management system for AGENT-11 using **static profile files** and **symlink-based switching**. No JavaScript runtime required - agents guide users to switch between pre-configured MCP profiles based on their current work.

### Key Design Principles

✅ **No runtime code** - Pure documentation approach
✅ **Native Claude Code** - Uses built-in `/mcp` commands
✅ **Symlink switching** - Simple `ln -sf` profile changes
✅ **Agent-guided** - Agents tell users which profile to use
✅ **Context optimized** - 47-80% reduction vs loading all MCPs

---

## Current State Analysis

### What We Have Now
```
.mcp.json                    # Single static config, all MCPs loaded
.env.mcp.template           # Basic environment variables
```

**Problems:**
- All 10 MCPs load simultaneously (~25,000 tokens)
- No multi-environment support (staging vs production)
- No safety controls (production is writable)
- Agents don't know which MCPs they need

### What We're Building
```
.mcp-profiles/              # 7 profile configurations
  ├── core.json            # Essential only (3K tokens)
  ├── testing.json         # Core + Playwright (5.5K tokens)
  ├── database-staging.json      # Core + Supabase staging (8K tokens)
  ├── database-production.json   # Core + Supabase prod read-only (8K tokens)
  ├── payments.json        # Core + Stripe (7K tokens)
  ├── deployment.json      # Core + Netlify + Railway (6K tokens)
  └── fullstack.json       # All MCPs (15K tokens)

.mcp.json → core.json       # Symlink to active profile

docs/
  ├── MCP-GUIDE.md         # User guide
  ├── MCP-PROFILES.md      # Profile reference
  └── MCP-TROUBLESHOOTING.md  # Common issues
```

**Benefits:**
- 47-80% context reduction
- Multi-environment support with safety
- Production read-only enforcement
- Agent-guided profile switching

---

## Implementation Phases

### Phase 1: Create Profile Files (1 hour)

**Objective**: Create 7 static MCP profile JSON files

#### Tasks

**1.1 Create Directory Structure**
```bash
mkdir -p .mcp-profiles
```

**1.2 Create Core Profile** (Essential MCPs only)
- File: `.mcp-profiles/core.json`
- MCPs: context7, github, filesystem
- Context: ~3,000 tokens
- Use: Default profile for all work

**1.3 Create Testing Profile** (Browser automation)
- File: `.mcp-profiles/testing.json`
- MCPs: core + playwright
- Context: ~5,500 tokens
- Use: E2E testing, browser automation

**1.4 Create Database Staging Profile** (Read/write)
- File: `.mcp-profiles/database-staging.json`
- MCPs: core + supabase-staging
- Context: ~8,000 tokens
- Use: Database development, migrations

**1.5 Create Database Production Profile** (Read-only)
- File: `.mcp-profiles/database-production.json`
- MCPs: core + supabase-production (with --read-only flag)
- Context: ~8,000 tokens
- Use: Production queries, analysis

**1.6 Create Payments Profile** (Stripe integration)
- File: `.mcp-profiles/payments.json`
- MCPs: core + stripe
- Context: ~7,000 tokens
- Use: Payment processing, subscriptions

**1.7 Create Deployment Profile** (Frontend + backend)
- File: `.mcp-profiles/deployment.json`
- MCPs: core + netlify + railway
- Context: ~6,000 tokens
- Use: Application deployment

**1.8 Create Fullstack Profile** (All services)
- File: `.mcp-profiles/fullstack.json`
- MCPs: core + supabase + stripe + netlify + railway
- Context: ~15,000 tokens
- Use: Comprehensive full-stack work (use sparingly)

#### Validation
```bash
# Check all profiles exist
ls -la .mcp-profiles/
# Should show 7 .json files

# Validate JSON syntax
for f in .mcp-profiles/*.json; do echo "Checking $f"; jq empty "$f" && echo "✓ Valid"; done
```

#### Deliverables
- [ ] 7 profile JSON files created
- [ ] All JSON files valid
- [ ] Context estimates documented

---

### Phase 2: Update Agent Prompts (2 hours)

**Objective**: Make agents MCP-aware with profile guidance

#### Tasks

**2.1 Update Coordinator Agent**
- File: `.claude/agents/coordinator.md`
- Add: MCP profile management section
- Add: Profile recommendations by mission type
- Add: Profile switching commands
- Add: Environment verification protocol

**Key additions:**
```markdown
## MCP Profile Management

Before starting any mission, check which MCP profile is active:
```bash
ls -l .mcp.json
```

**Profile Recommendations by Mission:**
- **test**: testing profile (core + playwright)
- **db-migrate**: database-staging profile
- **deploy**: deployment profile
- **payment-integration**: payments profile
```

**2.2 Update Tester Agent**
- File: `.claude/agents/tester.md`
- Add: Required MCP profile (testing)
- Add: Playwright connection verification
- Add: Profile switching guide
- Add: Error handling when Playwright unavailable

**Key additions:**
```markdown
## Required MCP Profile
**testing** (core + playwright)

## Before Starting Work
Check if correct profile is active:
```bash
ls -l .mcp.json
# Should point to: .mcp-profiles/testing.json
```
```

**2.3 Update Developer Agent**
- File: `.claude/agents/developer.md`
- Add: Database operations safety section
- Add: Environment verification before DB operations
- Add: Staging vs production warnings
- Add: Environment switching commands

**Key additions:**
```markdown
## Database Operations Safety

**CRITICAL: Always check which database environment you're connected to**

Before any database operation:
```bash
ls -l .mcp.json
```

**If pointing to database-production.json:**
- ⚠️ **PRODUCTION DATABASE**
- **READ-ONLY MODE**
- No writes allowed
```

**2.4 Update Operator Agent**
- File: `.claude/agents/operator.md`
- Add: Deployment profile requirements
- Add: Pre-deployment checklist
- Add: Profile switching for staging vs production deployments

**2.5 Update Other Agents** (optional enhancements)
- Strategist: Profile awareness for mission planning
- Architect: Profile considerations in architecture decisions
- Designer: Playwright usage for design review
- Documenter: Document MCP requirements in guides
- Analyst: Database profile for data analysis
- Marketer: No MCP changes needed
- Support: No MCP changes needed

#### Validation
```bash
# Check MCP awareness in agents
grep -l "MCP Profile" .claude/agents/*.md
# Should show updated agents

# Check profile switching commands
grep -l "ln -sf .mcp-profiles" .claude/agents/*.md
# Should show agents with switching guidance
```

#### Deliverables
- [ ] Coordinator agent updated with profile management
- [ ] Tester agent updated with Playwright requirements
- [ ] Developer agent updated with database safety
- [ ] Operator agent updated with deployment profiles
- [ ] Optional: Other agents enhanced with MCP awareness

---

### Phase 3: Create User Documentation (2 hours)

**Objective**: Comprehensive guides for MCP profile management

#### Tasks

**3.1 Create MCP Guide**
- File: `docs/MCP-GUIDE.md`
- Sections:
  - Overview of profile system
  - Quick start (check, switch, verify)
  - All 7 profiles with use cases
  - Profile switching workflows (3 scenarios)
  - Troubleshooting section
  - Best practices
  - Context savings table

**Content structure:**
```markdown
# AGENT-11 MCP Management Guide

## Overview
AGENT-11 uses MCP profiles to optimize context...

## Quick Start
1. Check current profile: `ls -l .mcp.json`
2. Switch profile: `ln -sf .mcp-profiles/testing.json .mcp.json`
3. Restart: `/exit && claude`
4. Verify: `/mcp`

## Available Profiles
[Detailed documentation for all 7 profiles]

## Profile Switching Workflow
[3 common scenarios with complete workflows]

## Troubleshooting
[Common issues and solutions]

## Best Practices
[5 recommendations]
```

**3.2 Create MCP Profiles Reference**
- File: `docs/MCP-PROFILES.md`
- Detailed reference for each profile:
  - MCP composition
  - Context usage
  - When to use
  - Switching commands
  - Environment variables required
  - Common use cases

**3.3 Create MCP Troubleshooting Guide**
- File: `docs/MCP-TROUBLESHOOTING.md`
- Common issues:
  - Profile switch didn't work
  - Missing environment variables
  - MCP connection failures
  - Accidentally connected to production
  - Symlink issues
  - Context still high after switching

**3.4 Update README.md**
- Add MCP Profile System section
- Quick reference for profile switching
- Link to detailed guides
- Update installation instructions
- Add context optimization benefits

**Section to add:**
```markdown
## MCP Profile System

AGENT-11 uses profiles to optimize context usage:

**Available Profiles:**
- **core**: Essential MCPs (3K tokens) - Default
- **testing**: Browser automation (5.5K tokens)
- **database-staging**: DB development (8K tokens)
- **database-production**: DB queries read-only (8K tokens)
- **payments**: Stripe integration (7K tokens)
- **deployment**: Netlify + Railway (6K tokens)
- **fullstack**: All MCPs (15K tokens)

**Switch profiles:**
```bash
ln -sf .mcp-profiles/testing.json .mcp.json
/exit && claude
```

See `docs/MCP-GUIDE.md` for complete documentation.
```

#### Validation
```bash
# Check documentation exists
ls docs/MCP-*.md
# Should show 3 files

# Check markdown validity
for f in docs/MCP-*.md; do echo "Checking $f"; markdownlint "$f" 2>/dev/null || echo "✓ Valid"; done

# Check README updated
grep "MCP Profile System" README.md
```

#### Deliverables
- [ ] MCP-GUIDE.md created (~1,350 lines)
- [ ] MCP-PROFILES.md created (profile reference)
- [ ] MCP-TROUBLESHOOTING.md created (common issues)
- [ ] README.md updated with MCP section

---

### Phase 4: Update Installation System (1 hour)

**Objective**: Automated installation with profile setup

#### Tasks

**4.1 Update Environment Template**
- File: `.env.mcp.template`
- Add staging/production variables for Supabase
- Add profile switching guide in comments
- Update documentation links

**New sections:**
```bash
# Supabase Staging (read/write)
SUPABASE_STAGING_TOKEN=your_staging_service_role_key_here
SUPABASE_STAGING_REF=your_staging_project_ref_here

# Supabase Production (read-only)
SUPABASE_PRODUCTION_TOKEN=your_production_service_role_key_here
SUPABASE_PRODUCTION_REF=your_production_project_ref_here

# MCP Profile Guide
# Core: ln -sf .mcp-profiles/core.json .mcp.json
# Testing: ln -sf .mcp-profiles/testing.json .mcp.json
# Database Staging: ln -sf .mcp-profiles/database-staging.json .mcp.json
# [etc.]
```

**4.2 Update Installation Script**
- File: `project/deployment/scripts/install.sh`
- Add `.mcp-profiles/` directory creation
- Copy profile files to user project
- Create symlink to core.json (default)
- Update .gitignore to exclude .mcp.json

**New functionality:**
```bash
# Copy MCP profile files
echo "📦 Installing MCP profiles..."
mkdir -p .mcp-profiles
cp -r "${AGENT11_DIR}/.mcp-profiles/"* .mcp-profiles/

# Create symlink to core profile (default)
if [ ! -f .mcp.json ]; then
  echo "🔗 Setting up default MCP profile (core)..."
  ln -sf .mcp-profiles/core.json .mcp.json
fi

# Update .gitignore
if ! grep -q ".mcp.json" .gitignore 2>/dev/null; then
  echo "📝 Updating .gitignore..."
  cat >> .gitignore << EOF

# AGENT-11 MCP System
.mcp.json
.env.mcp
EOF
fi
```

**4.3 Update .gitignore**
- File: `.gitignore`
- Add `.mcp.json` (symlink is user-specific)
- Add `.env.mcp` (contains secrets)
- Keep `.mcp-profiles/` tracked (template files)

**New entries:**
```gitignore
# AGENT-11 MCP System
.mcp.json          # Symlink to active profile (user-specific)
.env.mcp           # Environment variables with API keys
```

**4.4 Create Setup Verification Script**
- File: `project/deployment/scripts/verify-mcp-setup.sh`
- Check: All profile files exist
- Check: Symlink is created and valid
- Check: Environment variables are set
- Check: MCPs are connected

#### Validation
```bash
# Test installation on clean directory
cd /tmp/test-install
git clone <agent-11-repo>
cd agent-11
./project/deployment/scripts/install.sh

# Verify structure
ls -la .mcp-profiles/    # Should show 7 profiles
ls -l .mcp.json          # Should be symlink to core.json
cat .env.mcp.template    # Should have staging/production vars

# Verify gitignore
grep ".mcp.json" .gitignore  # Should exist
```

#### Deliverables
- [ ] .env.mcp.template updated with staging/production vars
- [ ] install.sh updated to copy profiles and create symlink
- [ ] .gitignore updated to exclude .mcp.json
- [ ] verify-mcp-setup.sh created for validation

---

### Phase 5: Update Mission Files (1 hour)

**Objective**: Add MCP profile requirements to mission documentation

#### Tasks

**5.1 Update Testing Mission**
- File: `missions/test.md`
- Add: Required MCP Profile section
- Add: Pre-mission profile verification
- Add: Profile switching instructions

**New sections:**
```markdown
# Test Mission

## Required MCP Profile
**testing** (core + playwright)

## Before Starting
Ensure you're using the testing profile:
```bash
ls -l .mcp.json
# Should point to: .mcp-profiles/testing.json
```

If not, switch to testing profile:
```bash
ln -sf .mcp-profiles/testing.json .mcp.json
/exit && claude
```
```

**5.2 Update Database Missions**
- Files: `missions/db-migrate.md`, `missions/db-query.md`, etc.
- Add: Database profile requirements (staging vs production)
- Add: Environment safety warnings
- Add: Profile verification steps

**5.3 Update Deployment Missions**
- Files: `missions/deploy.md`, `missions/deploy-staging.md`, etc.
- Add: Deployment profile requirements
- Add: Profile switching workflow

**5.4 Update Payment Missions**
- Files: `missions/payment-integration.md`, `missions/subscription-setup.md`, etc.
- Add: Payments profile requirements

**5.5 Update Mission Library**
- File: `missions/library.md`
- Add column: Required Profile
- Document profile requirements for each mission

**Example update:**
```markdown
| Mission | Description | Agents | Duration | Required Profile |
|---------|-------------|--------|----------|------------------|
| test | Run test suite | tester, developer | 2-4 hours | testing |
| db-migrate | Database migrations | developer, operator | 1-2 hours | database-staging |
| deploy | Production deployment | operator, tester | 1-2 hours | deployment |
```

#### Validation
```bash
# Check mission files have profile requirements
grep -l "Required MCP Profile" missions/*.md
# Should show updated missions

# Check library has profile column
grep "Required Profile" missions/library.md
```

#### Deliverables
- [ ] test.md updated with testing profile
- [ ] Database missions updated with DB profiles
- [ ] Deployment missions updated with deployment profile
- [ ] Payment missions updated with payments profile
- [ ] library.md updated with profile column

---

### Phase 6: Testing & Validation (1 hour)

**Objective**: Comprehensive testing of profile system

#### Tasks

**6.1 Profile Switching Tests**
```bash
# Test 1: Switch to testing profile
ln -sf .mcp-profiles/testing.json .mcp.json
/exit && claude
/mcp
# ✓ Should show: context7, github, filesystem, playwright

# Test 2: Switch to database-staging
ln -sf .mcp-profiles/database-staging.json .mcp.json
/exit && claude
/mcp
# ✓ Should show: context7, github, filesystem, supabase-staging

# Test 3: Switch to core
ln -sf .mcp-profiles/core.json .mcp.json
/exit && claude
/mcp
# ✓ Should show: context7, github, filesystem (no playwright, no supabase)
```

**6.2 Production Read-Only Test**
```bash
# Test: Production profile has read-only flag
cat .mcp-profiles/database-production.json | grep "read-only"
# ✓ Should show: "--read-only" in args

# Switch to production
ln -sf .mcp-profiles/database-production.json .mcp.json
/exit && claude

# Attempt write operation (should fail)
@developer "Try to insert a test record into users table"
# ✓ Should get read-only error
```

**6.3 Context Usage Validation**
```bash
# Test: Measure context usage per profile
# (Use Claude Code's context display)

# Core profile
ln -sf .mcp-profiles/core.json .mcp.json
/exit && claude
# Check context usage: ~3,000 tokens

# Fullstack profile
ln -sf .mcp-profiles/fullstack.json .mcp.json
/exit && claude
# Check context usage: ~15,000 tokens
# ✓ Verify 80% reduction from fullstack to core
```

**6.4 Agent Guidance Test**
```bash
# Test: Agent recommends profile switch
ln -sf .mcp-profiles/core.json .mcp.json
/exit && claude

@tester "Run E2E tests"
# ✓ Should get message: "I need Playwright. Please switch to testing profile"

# Test: Coordinator checks profile
/coord test
# ✓ Should verify profile and guide user if incorrect
```

**6.5 Documentation Validation**
```bash
# Test: All links work
for file in docs/MCP-*.md; do
  echo "Checking links in $file"
  # Manually verify links or use markdown-link-checker
done

# Test: README.md has MCP section
grep "MCP Profile System" README.md
# ✓ Should exist

# Test: Installation instructions updated
grep "mcp-profiles" README.md
# ✓ Should exist
```

**6.6 Installation Test**
```bash
# Test: Fresh installation
cd /tmp/test-agent11
git clone <agent-11-repo>
cd agent-11
./project/deployment/scripts/install.sh

# Verify
ls -l .mcp.json                    # ✓ Symlink to core.json
ls .mcp-profiles/                  # ✓ 7 profile files
grep "SUPABASE_STAGING" .env.mcp.template  # ✓ Staging vars
grep ".mcp.json" .gitignore        # ✓ Excluded
```

#### Validation Checklist
- [ ] Core profile loads 3 MCPs (3K tokens)
- [ ] Testing profile loads 4 MCPs (5.5K tokens)
- [ ] Database-staging profile loads 4 MCPs (8K tokens)
- [ ] Database-production has --read-only flag
- [ ] Production profile prevents writes
- [ ] Profile switching works correctly
- [ ] Context usage matches estimates
- [ ] Agents guide profile switching
- [ ] Coordinator verifies profiles
- [ ] Documentation links work
- [ ] Fresh installation succeeds
- [ ] Symlink created automatically
- [ ] .mcp.json excluded from git

#### Deliverables
- [ ] Test results documented
- [ ] All validation checks passed
- [ ] Issues identified and fixed
- [ ] Final verification complete

---

## Implementation Timeline

### Day 1 (8 hours total)

**Morning Session (4 hours):**
- 9:00-10:00: Phase 1 - Create Profile Files (1 hour)
- 10:00-12:00: Phase 2 - Update Agent Prompts (2 hours)
- 12:00-1:00: Lunch break

**Afternoon Session (4 hours):**
- 1:00-3:00: Phase 3 - Create User Documentation (2 hours)
- 3:00-4:00: Phase 4 - Update Installation System (1 hour)
- 4:00-5:00: Phase 5 - Update Mission Files (1 hour)
- 5:00-6:00: Phase 6 - Testing & Validation (1 hour)

---

## Success Metrics

### Technical Metrics
- [ ] 7 profile files created and validated
- [ ] 4+ agents updated with MCP awareness
- [ ] 3 documentation files created
- [ ] 5+ mission files updated
- [ ] All tests passed

### Performance Metrics
- [ ] Context usage reduced by 47-80% (vs fullstack)
- [ ] Core profile: ~3,000 tokens (baseline)
- [ ] Testing profile: ~5,500 tokens (47% reduction)
- [ ] Database profile: ~8,000 tokens (47% reduction)

### User Experience Metrics
- [ ] Profile switching: 3 commands (check, switch, restart)
- [ ] Agent guidance: Clear instructions in prompts
- [ ] Documentation: Complete guides available
- [ ] Installation: Automatic setup with defaults

### Safety Metrics
- [ ] Production database read-only enforced
- [ ] Environment verification in agent prompts
- [ ] Safety warnings before production operations
- [ ] Clear staging vs production distinction

---

## Risk Assessment & Mitigation

### Risk 1: Symlink Issues on Windows
**Impact:** Medium
**Probability:** Low
**Mitigation:**
- Document Windows symlink requirements (Admin or Developer Mode)
- Provide fallback: Copy profile file to .mcp.json
- Add troubleshooting guide for Windows users

### Risk 2: Profile Files Out of Sync
**Impact:** Low
**Probability:** Medium
**Mitigation:**
- Version control .mcp-profiles/ directory
- Document profile update process
- Create profile validation script

### Risk 3: Users Forget to Restart Claude Code
**Impact:** Low
**Probability:** High
**Mitigation:**
- Clear instructions: "After switching, run: /exit && claude"
- Agent prompts remind users to restart
- Verification step: "Check /mcp to confirm"

### Risk 4: Environment Variables Not Set
**Impact:** Medium
**Probability:** Medium
**Mitigation:**
- Clear error messages from agents
- .env.mcp.template has examples
- Troubleshooting guide covers missing vars
- Verification script checks .env.mcp

### Risk 5: Accidental Production Write Attempts
**Impact:** High
**Probability:** Low
**Mitigation:**
- Production profile has --read-only flag
- Agent prompts warn before switching to production
- Developer agent checks environment before DB operations
- Read-only errors are clear and actionable

---

## Migration Guide

### For Existing AGENT-11 Users

#### Step 1: Backup Current Config
```bash
cp .mcp.json .mcp.json.backup
cp .env.mcp .env.mcp.backup
```

#### Step 2: Pull Latest Changes
```bash
cd /path/to/agent-11
git pull origin main
```

#### Step 3: Run Installation
```bash
./project/deployment/scripts/install.sh
```

**What this does:**
- Creates `.mcp-profiles/` directory
- Copies 7 profile files
- Creates symlink to `core.json`
- Updates `.gitignore`

#### Step 4: Update Environment Variables
```bash
# Copy new template
cp .env.mcp.template .env.mcp.new

# Add your existing keys from backup
# Add new staging/production variables
nano .env.mcp.new

# Replace old file
mv .env.mcp.new .env.mcp
```

#### Step 5: Restart Claude Code
```bash
/exit
claude
```

#### Step 6: Verify Installation
```bash
# Check symlink
ls -l .mcp.json
# Should point to: .mcp-profiles/core.json

# Check MCPs
/mcp
# Should show: context7, github, filesystem

# Check documentation
ls docs/MCP-*.md
# Should show 3 files
```

### Rollback Procedure

If something goes wrong:

```bash
# Restore backup
cp .mcp.json.backup .mcp.json
cp .env.mcp.backup .env.mcp

# Remove new files
rm -rf .mcp-profiles/
rm docs/MCP-*.md

# Restart
/exit && claude
```

---

## File Inventory

### New Files Created (13 files)

#### Profile Files (7 files)
- `.mcp-profiles/core.json`
- `.mcp-profiles/testing.json`
- `.mcp-profiles/database-staging.json`
- `.mcp-profiles/database-production.json`
- `.mcp-profiles/payments.json`
- `.mcp-profiles/deployment.json`
- `.mcp-profiles/fullstack.json`

#### Documentation Files (3 files)
- `docs/MCP-GUIDE.md`
- `docs/MCP-PROFILES.md`
- `docs/MCP-TROUBLESHOOTING.md`

#### Deployment Files (2 files)
- `project/deployment/scripts/verify-mcp-setup.sh`
- (install.sh updated, not new)

#### Repository Files (1 file)
- `.gitignore` (updated with .mcp.json exclusion)

### Modified Files (10+ files)

#### Agent Files (4+ files)
- `.claude/agents/coordinator.md` - Add MCP profile management
- `.claude/agents/tester.md` - Add Playwright requirements
- `.claude/agents/developer.md` - Add database safety
- `.claude/agents/operator.md` - Add deployment profiles
- (Optional: strategist, architect, designer, documenter, analyst)

#### Mission Files (5+ files)
- `missions/test.md` - Add testing profile requirement
- `missions/db-migrate.md` - Add database profile requirement
- `missions/deploy.md` - Add deployment profile requirement
- `missions/library.md` - Add profile column
- (Plus any other mission files with MCP requirements)

#### Core Files (3 files)
- `README.md` - Add MCP Profile System section
- `.env.mcp.template` - Add staging/production variables
- `project/deployment/scripts/install.sh` - Add profile installation

---

## Next Steps After Implementation

### Immediate (Week 1)
1. Monitor user adoption of profile system
2. Gather feedback on profile switching UX
3. Address any installation issues
4. Update troubleshooting guide based on issues

### Short-term (Month 1)
1. Add profile recommendations to more missions
2. Create video tutorial on profile switching
3. Enhance agent guidance based on feedback
4. Consider additional profiles (e.g., design-review profile)

### Long-term (Quarter 1)
1. Analyze context savings across user base
2. Optimize profile compositions based on usage
3. Consider profile presets for common workflows
4. Explore automatic profile switching (if feasible)

---

## Conclusion

This implementation plan delivers a **documentation-driven MCP management system** that:

✅ Maintains AGENT-11's architecture (no runtime code)
✅ Optimizes context usage (47-80% reduction)
✅ Enables multi-environment workflows (staging/production)
✅ Enforces safety controls (read-only production)
✅ Provides clear user guidance (agent prompts)
✅ Implements in 1 day (8 hours total)

The profile-based approach is **simple, maintainable, and user-friendly** while solving all critical MCP management issues.

**Ready for implementation: October 21, 2025**

---

## Appendix A: Profile Composition Reference

| Profile | MCPs | Context | Reduction vs Fullstack |
|---------|------|---------|------------------------|
| core | context7, github, filesystem | 3,000 | 80% |
| testing | core + playwright | 5,500 | 63% |
| database-staging | core + supabase-staging | 8,000 | 47% |
| database-production | core + supabase-production | 8,000 | 47% |
| payments | core + stripe | 7,000 | 53% |
| deployment | core + netlify + railway | 6,000 | 60% |
| fullstack | core + all services | 15,000 | Baseline |

---

## Appendix B: Command Reference

### Profile Management Commands
```bash
# Check current profile
ls -l .mcp.json

# Switch to core (default)
ln -sf .mcp-profiles/core.json .mcp.json
/exit && claude

# Switch to testing (Playwright)
ln -sf .mcp-profiles/testing.json .mcp.json
/exit && claude

# Switch to database staging (read/write)
ln -sf .mcp-profiles/database-staging.json .mcp.json
/exit && claude

# Switch to database production (read-only)
ln -sf .mcp-profiles/database-production.json .mcp.json
/exit && claude

# Switch to payments (Stripe)
ln -sf .mcp-profiles/payments.json .mcp.json
/exit && claude

# Switch to deployment (Netlify + Railway)
ln -sf .mcp-profiles/deployment.json .mcp.json
/exit && claude

# Switch to fullstack (all MCPs)
ln -sf .mcp-profiles/fullstack.json .mcp.json
/exit && claude

# Verify MCPs connected
/mcp

# Verify environment
cat .env.mcp | grep SUPABASE
```

---

## Appendix C: Troubleshooting Quick Reference

| Issue | Solution |
|-------|----------|
| Profile didn't switch | Restart Claude Code: `/exit && claude` |
| Symlink not working | Check permissions: `ls -l .mcp.json` |
| MCP not connecting | Check `.env.mcp` has API key |
| Production is writable | Check profile has `--read-only` flag |
| Wrong MCPs loaded | Verify symlink: `ls -l .mcp.json` |
| High context usage | Switch to specific profile, not fullstack |

---

**End of Implementation Plan**
