# AGENT-11 Changelog

All notable changes to AGENT-11 will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Nothing yet

## [5.0.0] - 2025-12-31 - SaaS Boilerplate Killer Architecture

### Added

#### Plan-Driven Development System
- **`/foundations init`** - Create vision and PRD documents from BOS-AI handoff
- **`/bootstrap [template]`** - Generate project-plan.md from templates (saas-mvp, saas-full, api)
- **`/plan status`** - View current mission state from project-plan.md
- **`/plan phase [N]`** - Show phase details
- **`/coord continue`** - Autonomous execution until blocked (phase complete, gate failure, blocker)
- **`/skills`** - List and match SaaS skills

#### 7 Production-Ready SaaS Skills
Skills auto-load based on task keywords in project-plan.md:
- `saas-auth` - Authentication with OAuth, email/password, magic links (~3,800 tokens)
- `saas-payments` - Stripe checkout, subscriptions, webhooks (~4,200 tokens)
- `saas-multitenancy` - RLS, tenant isolation, workspace management (~4,100 tokens)
- `saas-billing` - Plans, quotas, trials, usage tracking (~3,900 tokens)
- `saas-email` - Transactional email with Resend (~3,200 tokens)
- `saas-onboarding` - User onboarding wizards (~3,500 tokens)
- `saas-analytics` - PostHog integration, event tracking (~3,600 tokens)

#### Quality Gates System
- Gate enforcement at phase transitions
- Python gate runner (`python gates/run-gates.py --phase implementation`)
- 6 gate types: build, test, lint, security, review, deploy
- 3 severity levels: blocking, warning, info
- 3 gate templates: nodejs-saas, python-api, minimal

#### Stack Profiles
Multi-framework support via `.stack-profile.yaml`:
- `nextjs-supabase` - Next.js 14 + Supabase
- `remix-railway` - Remix + Railway + PostgreSQL
- `sveltekit-supabase` - SvelteKit + Supabase

#### Coordinator Enhancements
- Plan-Driven Orchestration Protocol (project-plan.md as source of truth)
- Smart Delegation Routing (10-path routing table with skill injection)
- Vision Integrity Verification (ALIGNED, MINOR_DRIFT, MAJOR_DRIFT, OUT_OF_SCOPE)
- Phase Context Management (`/clear` workflow support)

#### Documentation
- `plan-driven-development.md` - Complete workflow guide
- `quality-gates-guide.md` - Gate configuration and usage
- `skills-guide.md` - Skill system documentation
- `architectural-principles.md` - 7 design principles from LLM consensus

### Changed
- All agent versions updated to 5.0.0
- README updated with Sprint 9 features
- CLAUDE.md updated with Sprint 9 section
- install.sh updated to deploy skills, schemas, gates, and stack-profiles

### Migration Guide

1. **Run install.sh** to get new files:
   ```bash
   ./install.sh
   ```

2. **Set your stack profile**:
   ```bash
   echo "extends: nextjs-supabase" > .stack-profile.yaml
   ```

3. **Use the new workflow**:
   ```bash
   /foundations init          # Create vision + PRD
   /bootstrap saas-mvp        # Generate project plan
   /coord continue            # Autonomous execution
   ```

---

## [4.1.0] - 2025-11-28 - MCP Context Optimization

### Added
- 13 MCP profiles for context optimization
- `/mcp-switch [profile]` command
- Profile-based token reduction (60-90%)

---

## [4.0.0] - 2025-11-27 - Opus 4.5 Dynamic Model Selection

### Added
- Opus 4.5 for Coordinator orchestration
- Task tool `model` parameter (opus, sonnet, haiku)
- Tiered model strategy documentation
- +15% mission success rate, -28% iterations

---

## [Previous Releases]

### Added
- Mission-driven coordination system with `/coord` command
- Comprehensive brownfield implementation guide
- Update management system with automatic version checking
- Greenfield implementation guide for new projects
- Version management with changelog and rollback capabilities
- **OneRedOak Design Review Integration** - Complete workflow system from top-tier companies
- **Dedicated Design Review Agent** (`@design-review`) for comprehensive UI/UX audits
- **Design Review Slash Command** (`/design-review`) for on-demand reviews
- **Enhanced RECON Protocol** for UI/UX reconnaissance in designer agent
- **SENTINEL Mode** for systematic testing in tester agent
- **PARALLEL STRIKE** capability for coordinator (simultaneous multi-agent operations)
- `/recon` slash command for UI/UX assessment
- `operation-recon.md` mission for comprehensive design reviews
- `ui-doctrine.md` field manual for UI/UX operational standards
- **Design Principles Integration** in CLAUDE.md for project-specific guidelines
- **7-Phase Systematic Protocol** for design reviews with Playwright automation

### Changed
- Enhanced README with mission coordination examples and new Design Review System
- Updated QUICK-START guide with `/coord` command usage and design review commands
- Enhanced ADVANCED-USAGE guide with OneRedOak workflow integration
- Improved agent coordination protocols
- Enhanced designer agent with RECON Protocol capabilities
- Updated documentation with comprehensive design review guidance

### Deprecated
- None

### Removed
- None

### Fixed
- None

### Security
- None

## [2.0.0] - 2024-01-15

### Added
- Mission-driven orchestration system
- `/coord` command for executing predefined missions
- Mission library with BUILD, FIX, REFACTOR, MVP missions
- Mission template system for custom workflows
- Comprehensive coordinator documentation
- Interactive mission selection
- Multi-input document processing
- Mission progress tracking
- Enhanced coordinator agent with mission execution protocols

### Changed
- Major architecture update to support mission-based workflows
- Coordinator agent enhanced with systematic mission execution
- Updated documentation structure with field manual organization
- README updated with mission coordination examples
- QUICK-START guide updated with mission command usage

### Fixed
- Agent coordination consistency issues
- Documentation organization and navigation

## [1.2.0] - 2024-01-01

### Added
- Advanced usage guide with enterprise configurations
- Multi-project workflow documentation
- Custom squad configurations
- Backup and restore system
- Performance optimization guides
- Security considerations documentation

### Changed
- Enhanced installation system with project detection
- Improved agent deployment verification
- Updated troubleshooting guides

### Fixed
- Installation issues on certain project types
- Agent loading consistency across different environments

## [1.1.0] - 2023-12-15

### Added
- Full squad deployment (11 specialists)
- Individual agent profile documentation
- Agent collaboration protocols
- Success stories and community examples
- Troubleshooting guide
- Advanced configuration options

### Changed
- Improved installation reliability
- Enhanced project detection logic
- Updated agent personalities and capabilities

### Fixed
- Installation script compatibility issues
- Agent file permissions
- Documentation links and references

## [1.0.0] - 2023-12-01

### Added
- Initial release of AGENT-11
- Core squad deployment (4 essential agents)
- Project-local agent installation system
- Basic agent profiles:
  - The Strategist (product strategy)
  - The Developer (full-stack development)
  - The Tester (quality assurance)
  - The Operator (DevOps and deployment)
- Claude Code integration
- Project detection and verification
- Basic documentation and quick start guide
- Installation script with squad options
- Success rate tracking and validation

### Changed
- None (initial release)

### Fixed
- None (initial release)

## Version History Summary

| Version | Release Date | Major Features |
|---------|--------------|----------------|
| 2.0.0   | 2024-01-15   | Mission coordination system, `/coord` command |
| 1.2.0   | 2024-01-01   | Advanced usage, multi-project workflows |
| 1.1.0   | 2023-12-15   | Full squad, individual profiles, community |
| 1.0.0   | 2023-12-01   | Initial release, core squad, project-local agents |

## Upgrade Paths

### From 1.x to 2.0.0
- **Breaking Changes**: None - fully backward compatible
- **New Features**: Mission coordination system available immediately
- **Recommended Actions**: 
  1. Update using `./deployment/scripts/update-manager.sh update`
  2. Try the new `/coord` command for systematic workflows
  3. Review mission library for applicable workflows

### From 1.0.x to 1.1.0
- **Breaking Changes**: None
- **New Features**: Full squad deployment, enhanced documentation
- **Recommended Actions**: Consider upgrading from core to full squad

### From 1.1.x to 1.2.0
- **Breaking Changes**: None
- **New Features**: Advanced configuration, multi-project support
- **Recommended Actions**: Review advanced usage guide for optimization opportunities

## Migration Guides

### Upgrading to Mission System (2.0.0)
```bash
# Update to latest version
./deployment/scripts/update-manager.sh update

# Test new mission system
/coord

# Try a predefined mission
/coord build requirements.md
```

### Migrating from Manual to Mission-Driven Workflows
```bash
# Before (manual coordination)
@strategist "Create requirements"
@developer "Implement feature"
@tester "Test implementation"

# After (mission coordination)
/coord build requirements.md
```

## Deprecation Notices

### Current Deprecations
- None

### Future Deprecations (Planned)
- Manual squad deployment commands may be simplified in v3.0.0
- Legacy configuration file formats will be updated in v3.0.0

## Support and Compatibility

### Supported Versions
- **2.x**: Full support, active development
- **1.2.x**: Security updates only
- **1.1.x**: Security updates only  
- **1.0.x**: End of life

### Claude Code Compatibility
- **Claude Code v1.x**: All AGENT-11 versions
- **Future versions**: Forward compatibility maintained

### Operating System Support
- **macOS**: All versions supported
- **Linux**: All versions supported
- **Windows**: Limited support (1.1.0+)

## Contributing to Changelog

When contributing to AGENT-11, please:

1. **Add entries to [Unreleased]** section first
2. **Use the correct category**:
   - `Added` for new features
   - `Changed` for changes in existing functionality
   - `Deprecated` for soon-to-be removed features
   - `Removed` for now removed features
   - `Fixed` for any bug fixes
   - `Security` for vulnerability fixes

3. **Follow the format**: `- Brief description ([#PR](link) by [@contributor](link))`
4. **Include breaking changes** in the description
5. **Reference issues/PRs** when applicable

## Release Process

### Version Numbering
- **MAJOR**: Breaking changes, new architecture
- **MINOR**: New features, backward compatible  
- **PATCH**: Bug fixes, security updates

### Release Schedule
- **Major releases**: Quarterly
- **Minor releases**: Monthly
- **Patch releases**: As needed for critical fixes

### Release Notes
Each release includes:
- Feature highlights
- Breaking changes (if any)
- Upgrade instructions
- Known issues
- Contributors acknowledgment

---

**Note**: This changelog is automatically updated by the release process. For the most current information, see the [Unreleased] section above.