# Mission Briefings 🎖️

Pre-configured workflows for common development scenarios. Each mission coordinates multiple agents to achieve specific objectives.

## Quick Start

```bash
# Launch a mission
/coord [mission-name] [inputs...]

# Examples
/coord build requirements.md
/coord fix bug-report.md
/coord mvp vision.md
/coord operation-recon PR-123  # NEW!
```

## Available Missions

### Core Operations

| Mission | Code | Duration | Description |
|---------|------|----------|-------------|
| [Build](mission-build.md) | `build` | 2-4 hours | Build new feature from requirements |
| [Fix](mission-fix.md) | `fix` | 1-2 hours | Emergency bug resolution |
| [Refactor](mission-refactor.md) | `refactor` | 2-3 hours | Code improvement and optimization |
| [MVP](mission-mvp.md) | `mvp` | 1-3 days | Rapid MVP development |
| [Deploy](mission-deploy.md) | `deploy` | 1-2 hours | Production deployment |

### Quality & Review (NEW!)

| Mission | Code | Duration | Description |
|---------|------|----------|-------------|
| [Operation RECON](operation-recon.md) | `operation-recon` | 2-4 hours | **UI/UX reconnaissance with RECON Protocol** |
| [Document](mission-document.md) | `document` | 2-3 hours | Comprehensive documentation |
| [Optimize](mission-optimize.md) | `optimize` | 2-4 hours | Performance optimization |
| [Security](mission-security.md) | `security` | 3-4 hours | Security audit and hardening |

### Integration & Migration

| Mission | Code | Duration | Description |
|---------|------|----------|-------------|
| [Integrate](mission-integrate.md) | `integrate` | 2-4 hours | Third-party integration |
| [Migrate](mission-migrate.md) | `migrate` | 3-5 hours | System/database migration |
| [Release](mission-release.md) | `release` | 2-3 hours | Version release preparation |

### Project Setup

| Mission | Code | Duration | Description |
|---------|------|----------|-------------|
| [Dev Setup](dev-setup.md) | `dev-setup` | 30-45 min | Initialize greenfield project |
| [Dev Alignment](dev-alignment.md) | `dev-alignment` | 20-30 min | Understand existing project |
| [OpsDev Setup](mission-opsdev-setup.md) | `opsdev-setup` | 20-30 min | Configure DevOps & environment settings |
| [CLAUDE.md Setup](mission-claude-setup.md) | `claude-setup` | 15-25 min | Create or sync CLAUDE.md configuration |
| [Connect MCP](connect-mcp.md) | `connect-mcp` | 15-20 min | Connect MCP tools |
| [Operation Genesis](operation-genesis.md) | `genesis` | 4-6 hours | Complete project initialization |

## NEW: Enhanced Review Capabilities

### Operation RECON
The most comprehensive review mission, combining:
- **RECON Protocol** (Designer) - 8-phase UI/UX assessment
- **SENTINEL Mode** (Tester) - 7-phase functional validation
- **PARALLEL STRIKE** (Coordinator) - Simultaneous operations

```bash
# Quick UI review
/recon

# Full operation
/coord operation-recon

# With specific target
/coord operation-recon feature-branch

# Full spectrum with all specialists
/coord operation-recon PR-456 --full-spectrum
```

## Mission Structure

Each mission follows this structure:

1. **Briefing** - Objectives and requirements
2. **Phases** - Step-by-step execution
3. **Specialists** - Agents involved
4. **Deliverables** - Expected outputs
5. **Success Criteria** - Completion metrics

## Choosing the Right Mission

### For New Features
- Small feature: Use `build`
- Large feature: Use `mvp` then `build`
- With design needs: Use `operation-recon` after `build`

### For Quality Assurance
- UI/UX review: Use `operation-recon`
- Performance issues: Use `optimize`
- Security concerns: Use `security`
- General bugs: Use `fix`

### For Project Setup
- New project: Use `dev-setup`
- Existing project: Use `dev-alignment`
- Configure DevOps: Use `opsdev-setup`
- Setup/sync CLAUDE.md: Use `claude-setup`
- Add tools: Use `connect-mcp`

## Custom Missions

Create your own missions by copying a template:

```bash
cp missions/mission-template.md missions/mission-custom.md
```

Edit to define:
- Phases and timing
- Agent coordination
- Success criteria
- Deliverables

## Mission Coordination

The Coordinator manages all missions with:
- Task delegation to specialists
- Progress tracking in `project-plan.md`
- Issue resolution in `progress.md`
- MCP tool assignment

### PARALLEL STRIKE Capability (NEW!)
Missions can now execute with simultaneous agent operations:
- 50-70% faster completion
- Better issue detection
- Synchronized reporting
- Unified evidence collection

## Pro Tips

1. **Start Small**: Begin with `fix` or `build` missions
2. **Document First**: Run `dev-alignment` on existing projects
3. **Review Often**: Use `operation-recon` before releases
4. **Combine Missions**: Chain missions for complex workflows
5. **Track Progress**: Check `project-plan.md` for status

## Mission Success Metrics

Track your mission effectiveness:
- Completion time vs estimate
- Issues detected/prevented
- Code quality improvements
- User satisfaction scores

---

*"Every mission is a step toward shipping excellence."*