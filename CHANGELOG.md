# AGENT-11 Changelog

All notable changes to AGENT-11 will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **Bulk-ops toolkit** at `project/deployment/bulk/` for users running AGENT-11 across multiple repos. Three operations, tier-aware, registry-driven:
  - `audit.sh` — read-only fleet status (v5 markers, library drift, branch, uncommitted count) per repo
  - `apply-file.sh` — deploy one library file across the fleet, with stash → pull-rebase → push fallback for divergent remotes. Idempotent — re-running with the same source has no effect
  - `apply-upgrade.sh` — bulk `install.sh --upgrade` across the fleet, using the proven Sprint 5b commit allowlist + smart D-vs-M check on v5 marker paths (handles repos that re-introduced same-named files as project content)
  - `lib/parse-registry.py` — hand-rolled minimal YAML parser, no PyYAML dependency
  - `lib/registry-template.yaml` — starter template for users to copy and edit
  - `README.md` — usage, tier behaviour table, troubleshooting
- Tier model: `active`, `local-only`, `dormant`, `sandbox`, `skip`, `different-framework` — drives which repos each operation touches by default. Dormant/sandbox/skip excluded by default; `--include-dormant` opts in.
- Registry file lives outside the framework repo (`AGENT11_FLEET_REGISTRY` env var or `--registry=<path>` flag). Keeps user-specific repo lists out of the framework.

### Changed

- `docs/UPGRADE.md` "Bulk upgrade" section now points at the toolkit as the primary path; the bare-bones bash loop kept as a fallback.
- `README.md` — added a "Managing AGENT-11 across multiple repos?" subsection under v6 messaging.
- Upgraded Opus tier references from 4.6 to 4.7 and Sonnet tier from 4.5 to 4.6 across all documentation.
- Updated `project/field-manual/model-selection-guide.md` (v1.2.0) with Opus 4.7 / Sonnet 4.6 tiers.

## [6.1.1] - 2026-05-07 - Subprocess advisory cleanup

Patch release. Surfaced during real-world v5→v6 pilot runs after v6.1.0 shipped.

### Fixed

- `migrate-v5-to-v6.sh` no longer prints a stale "Manual merge recommended" advisory when invoked as a subprocess by `install.sh --upgrade`. The advisory was a false alarm in chained mode — install.sh's surgical merger handles the merge immediately after, but the warning text appeared just before the success line and looked like the merge had failed. Suppression is gated by an `AGENT11_INSTALL_INVOKED=1` env var that install.sh sets before subprocess invocation.
- Standalone `migrate-v5-to-v6.sh` still surfaces the advisory, but now points at `install.sh --upgrade` as the recommended automatic path and references `docs/UPGRADE.md` (rather than the raw `library/settings.json.template` file).

### Verified

- 31/31 checks across two real-world pilot repos (aisearchmastery, freecalchub) — both have rich existing settings.json with custom permissions and env keys; merge preserved everything.
- 10/10 fixture 02 (custom-mcp) regression test still green.
- Standalone migrate.sh advisory still fires when not invoked via install.sh.

## [6.1.0] - 2026-05-07 - Hardened Upgrade Path

v6.1.0 closes the v5→v6 upgrade-path gap that surfaced in the first weeks after the v6.0 launch. Three sharp edges hit any v5.x user upgrading: install.sh + migrate-v5-to-v6.sh as a brittle two-script flow, install.sh refusing to update existing `settings.json` while still claiming it had ("Tool deferring enabled") in the post-install summary, and migrate.sh's success message being indistinguishable from the no-op case after a real run. v6.1 fixes all three behind an opt-in `--upgrade` flag, with full rollback support, hardened JSON merge logic, and five end-to-end test fixtures.

**Migration**: existing v5.x users now upgrade with a single command:

```bash
bash <(curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/install.sh) --upgrade
```

Preview with `--dry-run`. Roll back any time via `restore-pre-upgrade.sh`. Full guide: [docs/UPGRADE.md](docs/UPGRADE.md).

### Added

- **`install.sh --upgrade`** — opt-in flag that detects v5 markers and runs the migration as a subprocess before deploying v6.0 library files. Single command replaces the previous two-step flow. Default behaviour (no flag) on a v5 install is detect-and-warn-and-exit, preserving user agency. Auto-on detection deferred to v6.2 after `--upgrade` validates in the wild.
- **`install.sh --dry-run`** — print the plan without making changes. Inspects v5 markers, settings.json state, execution mode; itemises what would happen. Exits 0.
- **`install.sh --non-interactive` / `--batch-safe`** — promise no prompts; fail fast on conditions that would require human input. Composable with the other flags. Designed for CI / bulk-upgrade wrappers.
- **Settings.json surgical merge** (`merge-settings.py`) — Python 3 helper merges the v6 template into existing `settings.json`. User values win on every conflict; the template only fills gaps. Backup → merge → re-validate → auto-restore-on-fail. Edge cases handled: BOM strip, trailing commas rejected, duplicate keys rejected, `$schema`/`_comment`/custom env keys preserved.
- **`restore-pre-upgrade.sh`** — undoes a v5→v6 upgrade from backups. Modes: `--list` (show available), interactive selector, `--latest`, `--backup <path>`, and `--settings <path>` (restore just settings.json without touching v5 markers).
- **`docs/UPGRADE.md`** — focused upgrade guide: TL;DR, why `--upgrade` is required, what gets done, backup table, preview/dry-run, rollback procedures, manual recovery, bulk-upgrade pattern, known limitations, troubleshooting.
- **Five end-to-end test fixtures** under `test-projects/install-fixtures/` — clean v5, custom settings, malformed JSON, partial migration, already-v6. `run-all.sh` aggregate runner. 43/43 individual checks.

### Changed

- **`migrate-v5-to-v6.sh` output clarity** — three previously-ambiguous cases now distinguished: "no markers + no prior backup" → "Already on v6.0"; "no markers + prior backup" → "Migration was completed previously" (with backup path); "markers + prior backup" → "completing the remaining migration steps". Final success summary itemises what actions were performed.
- **Post-install summary** — no longer claims `ENABLE_TOOL_SEARCH=auto` is enabled when the merge didn't actually happen. Conditional render: true → "Tool deferring enabled"; false → "Tool deferring NOT enabled" + backup pointer + manual merge instructions + restore script reference.
- **`install.sh --help`** — rewritten with a full flag table and usage examples.
- **README v5.x → v6.0 section** — single command replaces the two-step.
- **`docs/MCP-GUIDE.md` migration section** — same simplification, pointer to `docs/UPGRADE.md`.

### Fixed

- v5 install + `bash install.sh` (no migration first) no longer leaves the project in a hybrid v6-library + v5-residue state. Detection happens at script entry; user gets clear instructions with `--upgrade` as the next step.
- `install.sh` no longer prints "✓ Tool deferring enabled" when it didn't actually update `settings.json`.
- `migrate-v5-to-v6.sh` after a real run no longer prints output identical to the "you were always on v6" no-op.
- Subprocess error handling: install.sh now uses explicit `rc=$?` after invoking migrate.sh rather than relying on `set -e` propagation through function returns.

### Reference

- **Sprint spec**: [`sprints/sprint-5a-install-upgrade-path.md`](sprints/sprint-5a-install-upgrade-path.md)
- **Upgrade guide**: [`docs/UPGRADE.md`](docs/UPGRADE.md)
- **Test fixtures**: [`test-projects/install-fixtures/`](test-projects/install-fixtures/)

## [6.0.0] - 2026-05-03 - The Lean Orchestrator

v6.0 is a structural evolution. AGENT-11 stops reinventing what Claude Code's platform now provides natively (hooks, native tool deferring, Routines, the Agent Skills open standard) and shrinks the framework's own surface dramatically — `library/CLAUDE.md` from **575 lines to 78** (-86%), context tracking from **5 active files to 3**, MCP startup cost reduced via `ENABLE_TOOL_SEARCH=auto`. Public-facing API is largely backwards-compatible (`/coord build` still works the same); the wins are mostly invisible structural improvements that ship cleaner sessions.

**Migration**: existing v5.x users run `bash <(curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/migrate-v5-to-v6.sh)` (or download and run manually). The script detects v5.x markers, backs up everything before any change, and guides through the upgrade. See [Migration Guide](docs/MCP-GUIDE.md) for details.

### Added

- **Universal Router (`/coord [mission]`)** — deterministic mission-based routing. 13 missions across Mode A (greenfield: `build`, `mvp`, `dev-setup`, `dev-alignment`, `integrate`, `migrate`), Mode B1 (surgical: `fix`), Mode B2 (maintenance: `refactor`, `optimize`, `document`, `release`, `deploy`, `security`). Mode override syntax: `/coord mode:maintenance security`. Unknown missions fail with a clear error and the valid list — no NLP "did you mean..." inference.
- **Karpathy operating constitution** — seven principles applied by every specialist: read before writing, state assumptions, prefer minimal diffs, verify by running, avoid speculative refactors, lightest valid path, present alternatives explicitly when uncertain. Replaces the previous "always delegate" discipline. Deployed to `.claude/constitution/karpathy-constitution.md`.
- **Dynamic context loading** — coordinator reads only the files the mission's mode requires. Mode A loads `project-plan.md` + `agent-context.md` + mission file; Mode B1 (`fix`) loads only the bug report; Mode B2 loads `project-plan.md` if it exists. `evidence-repository.md` and `progress.md` are on-demand only.
- **Phase Handoff blocks** — structured 5-field schema (Findings / Decisions / Warnings & Gotchas / Open Items / Evidence) appended to `agent-context.md` at phase boundaries. Replaces the separate `handoff-notes.md` file.
- **Quality-gate hooks** — `.claude/settings.json` ships with advisory `PostToolUse` hooks for `tsc`/`ruff`/`rubocop` on Edit/Write/MultiEdit (auto-skip when toolchain absent — `package.json`/`pyproject.toml`/`Gemfile` gates) and a `PreToolUse` confirmation prompt for destructive Bash (`rm -rf`, `git push --force`, `git reset --hard`, etc.). Advisory by default (`|| true`); promote to blocking by changing to `|| exit 2`.
- **Native MCP tool deferring** — `.claude/settings.json` ships `ENABLE_TOOL_SEARCH=auto`, leveraging Claude Code's threshold-based tool loading. Specialists discover MCP tools on demand via `tool_search_tool_regex_20251119(pattern="mcp__SERVERNAME")`.
- **Routines for Mode C (operational work)** — three paste-ready prompt templates in `routines/`: `pr-review.md` (GitHub webhook), `nightly-qa.md` (cron), `backlog-triage.md` (cron). `/coord` detects cadence keywords ("daily", "every Monday", "schedule", etc.) and points users at the matching template instead of executing one-time work. Routines run on Anthropic-managed cloud via `claude.ai/code/routines`.
- **3-tier skills model** — Tier 1 (behavioural, in CLAUDE.md), Tier 2 (project-domain, in user `skills/`), Tier 3 (marketplace, in `.claude/skills/`). All 7 SaaS skills aligned with Anthropic's [Agent Skills open standard](https://agentskills.io/specification): each has a proper `description` field. Custom AGENT-11 fields preserved for backward-compat.
- **`migrate-v5-to-v6.sh`** — one-command migration script for v5.x users. Detects markers, backs up before changes, folds `handoff-notes.md` into `agent-context.md`, retires `.mcp-profiles/`. Supports `--dry-run` and `--yes` flags. Idempotent.
- **`/coord` mode override** — `/coord mode:greenfield|surgical|maintenance [mission]` forces a specific mode regardless of mission name.
- **`/coord` Routine detection** — cadence keywords trigger a pointer to the matching Routine template instead of one-time delegation.

### Changed

- `library/CLAUDE.md` shrunk from 575 lines to **78 lines** (-86%). Most content was duplicate of canonical sources elsewhere (coordinator.md, field-manual/, command files); lean version points at them.
- `project/commands/coord.md` shrunk from 549 lines to **134 lines**. Old briefing duplicated content already in coordinator.md; thin dispatcher only.
- Coordinator's session-start protocol now mode-aware. Staleness check only runs on resumed missions (where tracking files exist), not blindly on every fresh start.
- `progress.md` demoted to **write-only** by default. Coordinator appends entries (issues, fixes, deliverables) but doesn't read at session start. Reads happen on staleness checks (resumed missions) or post-`/clear` reconstruction.
- MCP server registry (`.mcp.json`) deployment unchanged — it's correctly Claude Code's stdio config. v5.x's `.mcp-profiles/` profile-switching system is retired entirely.
- All 7 MCP-using specialists (`developer`, `tester`, `operator`, `architect`, `analyst`, `marketer`, `designer`) updated with concise Tool-Centric Workflow guidance. Long static MCP tool listings replaced with Tool Search references.
- `install.sh` deploys: `library/settings.json.template` → `.claude/settings.json` (new); `project/constitution/karpathy-constitution.md` → `.claude/constitution/` (new — was referenced by coordinator but missing pre-v6.0); `field-manual/mcp-integration.md` (added to deployment list).
- `install.sh` always installs all 11 specialists (previously defaulted to "core" 4-agent squad). The squad selector argument is accepted but ignored with a deprecation notice.

### Deprecated

- `install.sh [core|full|minimal]` arguments accepted but ignored (deprecation notice). Removal scheduled for v7.0.

### Removed

- `handoff-notes.md` retired as a separate active-context file. Folded into `agent-context.md` as Phase Handoff blocks. v5.x users migrate via `migrate-v5-to-v6.sh` (one line: `cat handoff-notes.md >> agent-context.md && rm handoff-notes.md`).
- `.mcp-profiles/` directory and the profile-switching system retired. Replaced by native tool deferring (`ENABLE_TOOL_SEARCH=auto`).
- `/mcp-switch`, `/mcp-list`, `/mcp-status` slash commands retired (Sprint 4a).
- `templates/handoff-notes-template.md` retired (folded into `agent-context-template.md`).
- `project/mcp/dynamic-mcp.json` removed — Sprint 11 artefact based on Claude API schema (per-tool `defer_loading`), which doesn't apply to Claude Code's `.mcp.json`. Caught at Sprint 4f T1 audit. Native deferring replaces it.
- `project/field-manual/mcp-optimization-guide.md` archived — its entire premise was the retired profile-switching optimisation. `field-manual/mcp-integration.md` is now the canonical MCP doc.
- `project/deployment/scripts/validate-mcp-profiles.sh` archived — validated profiles that no longer exist.
- `mcp-setup.sh` at repo root (root-level MCP setup helper) retired in Sprint 4a alongside the profile system.

### Architecture

v6.0 is delivered as 8 sub-sprints under the "Sprint 4" umbrella. Each followed a rolling-wave protocol where the next sprint's spec was the closing task of the current sprint:

- **4a — Baseline + Great Deletion**: validation harness; v5.2 baseline measured; MCP profile system, backups, ASCII art deleted.
- **4b — Prompt Hygiene & Budget Controls**: Karpathy constitution shipped; PAUSE-AND-PLAN replaces NO-WAITING; mission budget frontmatter; subagent hardening. Headline measurement: Task 4 (refactor) dropped 75% (6:07 → 1:33).
- **4c — The Universal Router**: `/coord` rewritten 549 → 91 lines; deterministic mission routing; dynamic context loading.
- **4d — Native Primitives + CLAUDE.md Shrink**: hooks in `settings.json`; `library/CLAUDE.md` 575 → 79 lines; Meta-Dev skill for the agent-11 repo; constitution deployment fix.
- **4e — Context Consolidation 5→3**: `handoff-notes.md` folded into `agent-context.md` as Phase Handoff blocks; `progress.md` demoted to write-only.
- **4f — Dynamic MCP Tool Search**: recalibrated mid-sprint after T1 audit caught a schema mismatch; `ENABLE_TOOL_SEARCH=auto` enabled native deferring; `dynamic-mcp.json` archived; profile-switching residue retired.
- **4g — Skills + Routines**: skills audited against open standard; 3-tier model documented; 3 paste-ready Routine templates; `/coord` operational-intent detection.
- **4h — Validation + Migration**: harness validates v6.0 vs baseline; `migrate-v5-to-v6.sh` for v5.x upgrades; consolidated docs (this CHANGELOG entry).

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