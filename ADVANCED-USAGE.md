# AGENT-11 Advanced Usage Guide

Advanced techniques, customization, and enterprise-level usage of the AGENT-11 deployment system. This guide covers custom configurations, backup management, integration patterns, and scaling strategies.

## Table of Contents

- [Enhanced Review Capabilities (NEW)](#enhanced-review-capabilities-new)
- [PARALLEL STRIKE Operations](#parallel-strike-operations)
- [Custom Squad Configurations](#custom-squad-configurations)
- [Backup and Restore Operations](#backup-and-restore-operations)
- [Agent Customization](#agent-customization)
- [Enterprise Integration](#enterprise-integration)
- [Performance Optimization](#performance-optimization)
- [Scaling Strategies](#scaling-strategies)
- [Security Considerations](#security-considerations)
- [Maintenance and Updates](#maintenance-and-updates)

## Enhanced Review Capabilities (NEW)

### OneRedOak Design Review Integration

AGENT-11 now includes the complete OneRedOak design review workflow system, providing world-class UI/UX audits based on standards from companies like Stripe, Airbnb, and Linear.

#### Core Design Review Commands

```bash
# Comprehensive design review of current branch changes
/design-review

# Quick UI/UX reconnaissance assessment
/recon

# Deploy dedicated design review specialist
@design-review "Review the dashboard redesign"

# Full design review mission with systematic protocol
/coord operation-recon
```

#### Specialized Design Review Agent

The `@design-review` agent provides systematic 7-phase evaluation:

```bash
@design-review "Audit the checkout flow for accessibility compliance"
```

**Key Features**:
- **Live Environment Testing** - Playwright automation for real interactions
- **Evidence-Based Reports** - Screenshots and reproduction steps included
- **Problems Over Prescriptions** - Describes issues, not technical solutions
- **Triage Matrix** - [BLOCKER], [HIGH-PRIORITY], [MEDIUM-PRIORITY], [NITPICK]
- **Project-Aware** - Uses your design system and brand guidelines

### RECON Protocol - Enhanced UI/UX Reconnaissance

The designer agent now includes advanced UI/UX assessment capabilities:

```bash
# Quick UI/UX assessment of current changes
/recon

# Full design review mission
/coord operation-recon

# Direct designer assessment with RECON Protocol
@designer Execute RECON Protocol on the login page
```

**RECON Protocol Phases**:
1. **Preparation** - Environment setup and scope analysis
2. **Interaction Reconnaissance** - Test all interactive elements
3. **Responsive Operations** - Validate across devices (desktop/tablet/mobile)
4. **Visual Inspection** - Check consistency and aesthetics
5. **Accessibility Sweep** - WCAG AA+ compliance verification
6. **Robustness Testing** - Edge cases and stress tests
7. **Code Inspection** - Design token usage validation
8. **Console Reconnaissance** - Error and warning detection

**Threat Level Classification**:
- `[CRITICAL]` - Blocks user progress or violates accessibility
- `[URGENT]` - Significant UX degradation
- `[TACTICAL]` - Medium-priority improvements
- `[COSMETIC]` - Minor polish items

### SENTINEL Mode - Systematic Testing

The tester agent now includes comprehensive evaluation capabilities:

```bash
# Activate SENTINEL Mode for comprehensive testing
@tester Deploy SENTINEL Mode on the checkout flow

# Combined with RECON for full assessment
/coord operation-recon --full
```

**SENTINEL Mode Phases**:
1. **Perimeter Establishment** - Map test coverage
2. **Functional Reconnaissance** - Test all features
3. **Visual Regression Sweep** - Compare against baseline
4. **Cross-Browser Operations** - Multi-browser testing
5. **Performance Patrol** - Load time and memory analysis
6. **Stress Testing** - Break it creatively
7. **Accessibility Verification** - Deep validation

## PARALLEL STRIKE Operations

The coordinator now supports simultaneous multi-agent operations for 50-70% faster assessments:

### Activation

```bash
# Full spectrum PR review
@coordinator Execute PARALLEL STRIKE for PR-123:
- Designer: RECON Protocol
- Tester: SENTINEL Mode
- Developer: Code quality review
- Architect: Architecture compliance
```

### Common PARALLEL STRIKE Patterns

**1. UI/UX + Functionality Assessment**:
```bash
/coord operation-recon --parallel
# Runs @design-review and @tester SENTINEL simultaneously
```

**2. Performance + Security + Accessibility**:
```bash
@coordinator PARALLEL STRIKE:
- Operator: Performance profiling
- Developer: Security scanning
- @design-review: Accessibility audit with WCAG AA+ validation
```

**3. Full PR Review**:
```bash
/coord operation-recon PR-456 --full-spectrum
# Deploys all relevant specialists including @design-review in parallel
```

**4. Design System Compliance Check**:
```bash
@coordinator PARALLEL STRIKE:
- @design-review: Component consistency audit
- Developer: Design token usage validation
- Tester: Cross-browser visual regression
```

### Synchronization Points

- Checkpoints every 30-60 minutes
- Automated evidence collection
- Conflict resolution protocols
- Unified report generation

## Custom Squad Configurations

### Creating Custom Squad Definitions

Edit `/deployment/configs/squad-definitions.yaml` to create custom squads:

```yaml
# Add to custom_templates section
custom_templates:
  data_science_squad:
    name: "Data Science Squad"
    description: "Specialized squad for ML and data analysis projects"
    agents:
      - strategist
      - developer
      - analyst
      - tester
    use_cases:
      - "Machine learning projects"
      - "Data pipeline development"
      - "Analytics dashboards"
```

Deploy your custom squad:

```bash
# Modify installer to support custom squads
./deployment/scripts/install.sh data_science_squad
```

### Domain-Specific Agent Selection

**Frontend-Heavy Projects**:
```yaml
frontend_squad:
  agents: [strategist, developer, designer, tester]
```

**Backend/API Projects**:
```yaml
backend_squad:
  agents: [strategist, architect, developer, tester, operator]
```

**Business/Product Projects**:
```yaml
business_squad:
  agents: [strategist, analyst, marketer, support, coordinator]
```

### Agent Dependency Management

Define agent relationships in your configuration:

```yaml
dependencies:
  coordinator:
    requires: [strategist]
    recommends: [developer, tester]
  architect:
    requires: [strategist]
    suggests: [developer]
```

## Backup and Restore Operations

### Advanced Backup Management

```bash
# Create named backup
./deployment/scripts/backup-manager.sh create "pre-upgrade-backup"

# List all backups
./deployment/scripts/backup-manager.sh list

# Restore from specific backup
./deployment/scripts/backup-manager.sh restore "pre-upgrade-backup"

# Clean old backups (keep last 5)
./deployment/scripts/backup-manager.sh cleanup --keep 5
```

### Automated Backup Strategies

**Daily Backups** (cron job):
```bash
# Add to crontab
0 2 * * * /path/to/agent-11/deployment/scripts/backup-manager.sh create "daily-$(date +%Y%m%d)"
```

**Pre-Deployment Backups**:
```bash
# Always backup before changes
./deployment/scripts/backup-manager.sh create "pre-deploy-$(date +%Y%m%d_%H%M)"
./deployment/scripts/install.sh full
```

### Backup Storage Options

**Local Backups**:
```bash
# Default location
~/.claude/backups/agent-11/

# Custom location
export BACKUP_DIR="/custom/backup/path"
./deployment/scripts/backup-manager.sh create "custom-backup"
```

**Remote Backups**:
```bash
# Sync to cloud storage
rsync -av ~/.claude/backups/agent-11/ user@server:/backups/agent-11/

# Or use cloud tools
aws s3 sync ~/.claude/backups/agent-11/ s3://my-agent-backups/
```

## Agent Customization

### Modifying Agent Personalities

Customize agents for your specific domain or style:

```markdown
<!-- In agents/specialists/developer.md -->
---
name: developer
description: Senior Ruby on Rails developer specializing in e-commerce platforms
model: sonnet
color: green
---

You are THE DEVELOPER, a senior Ruby on Rails specialist with 10+ years of experience in e-commerce platforms. You excel at:

- Ruby on Rails architecture and best practices
- E-commerce specific patterns (payments, inventory, orders)
- Performance optimization for high-traffic sites
- Integration with payment processors and third-party services

[Continue with customized prompt...]
```

### Creating Specialized Variants

Create domain-specific versions of agents:

```bash
# Copy base agent
cp agents/specialists/developer.md agents/specialists/rails-developer.md

# Customize for Rails development
# Edit rails-developer.md with Rails-specific instructions

# Install custom variant
cp agents/specialists/rails-developer.md ~/.claude/agents/
```

### Agent Collaboration Templates

Define standard collaboration patterns:

```markdown
<!-- In agents/specialists/coordinator.md -->
When planning feature development, always follow this pattern:

1. @strategist: Define requirements and acceptance criteria
2. @architect: Review requirements and design system architecture  
3. @developer: Implement based on architecture
4. @tester: Create comprehensive test suite
5. @operator: Deploy with monitoring and rollback plan

Ensure each step is completed before proceeding to the next.
```

## Enterprise Integration

### Team-Based Deployments

Deploy different squads for different teams:

```bash
# Frontend team
mkdir -p teams/frontend/.claude/agents
./deployment/scripts/install.sh frontend_squad --target teams/frontend/.claude/agents

# Backend team  
mkdir -p teams/backend/.claude/agents
./deployment/scripts/install.sh backend_squad --target teams/backend/.claude/agents

# DevOps team
mkdir -p teams/devops/.claude/agents
./deployment/scripts/install.sh ops_squad --target teams/devops/.claude/agents
```

### Centralized Agent Management

**Shared Agent Repository**:
```bash
# Central agents repository
/shared/claude/agents/

# Symlink to individual developer environments
ln -s /shared/claude/agents ~/.claude/agents
```

**Version-Controlled Agents**:
```bash
# Store agents in git
git add ~/.claude/agents/
git commit -m "Update agent configurations"
git push origin main

# Deploy to team
git pull origin main
cp -r repo/agents/* ~/.claude/agents/
```

### Configuration Management

**Environment-Specific Agents**:
```yaml
# deployment/configs/environments.yaml
environments:
  development:
    agents: [strategist, developer, tester]
    debug: true
    
  staging:
    agents: [developer, tester, operator]
    validation: strict
    
  production:
    agents: [operator, support, analyst]
    monitoring: enabled
```

**Deploy by Environment**:
```bash
./deployment/scripts/install.sh --env production
```

## Performance Optimization

### Installation Performance

**Parallel Installation**:
```bash
# Modify installer for parallel agent deployment
# Reduces installation time by 60-70%
./deployment/scripts/install.sh full --parallel
```

**Cached Installations**:
```bash
# Cache frequently used squads
./deployment/scripts/install.sh core --cache
# Subsequent installations use cached files
```

### Runtime Performance

**Agent Response Optimization**:
```markdown
<!-- Optimize agent prompts for faster responses -->
You are THE DEVELOPER. Respond concisely and directly.

Key rules:
- Provide code first, explanation second
- Use bullet points for multiple items
- Skip verbose introductions
- Focus on actionable solutions
```

**Memory Management**:
```bash
# Monitor Claude Code memory usage
top -p $(pgrep claude)

# Optimize agent file sizes
# Keep agent files under 50KB for best performance
```

## Scaling Strategies

### Multi-Project Management

**Project-Specific Agents**:
```bash
# Different agents per project
mkdir -p projects/ecommerce/.claude/agents
mkdir -p projects/mobile-app/.claude/agents
mkdir -p projects/data-platform/.claude/agents

# Deploy appropriate squads
./deployment/scripts/install.sh full --target projects/ecommerce/.claude/agents
./deployment/scripts/install.sh mobile_squad --target projects/mobile-app/.claude/agents
./deployment/scripts/install.sh data_squad --target projects/data-platform/.claude/agents
```

**Context Switching**:
```bash
# Switch between project contexts
export CLAUDE_AGENTS_DIR="./projects/ecommerce/.claude/agents"
claude

# Or use aliases
alias claude-ecommerce="CLAUDE_AGENTS_DIR=./projects/ecommerce/.claude/agents claude"
alias claude-mobile="CLAUDE_AGENTS_DIR=./projects/mobile-app/.claude/agents claude"
```

### Load Balancing

**Distributed Agent Usage**:
```bash
# Route different workflows to different Claude instances
# Heavy development work -> Instance 1
# Testing and QA -> Instance 2  
# Documentation and planning -> Instance 3
```

### Horizontal Scaling

**Team Multiplication**:
```bash
# Scale teams by replicating successful patterns
./deployment/scripts/install.sh core --team frontend-team-1
./deployment/scripts/install.sh core --team frontend-team-2
./deployment/scripts/install.sh core --team backend-team-1
```

## Security Considerations

### Agent File Security

**File Permissions**:
```bash
# Secure agent files
chmod 600 ~/.claude/agents/*.md
chown $USER:$USER ~/.claude/agents/*.md
```

**Sensitive Information**:
- Never include API keys or passwords in agent prompts
- Use environment variables for sensitive configuration
- Audit agent files regularly for sensitive data

### Access Control

**Team Access**:
```bash
# Group-based access
chgrp development-team ~/.claude/agents/
chmod 640 ~/.claude/agents/*.md
```

**Audit Logging**:
```bash
# Log agent installations and modifications
echo "$(date): Agent installation by $USER" >> ~/.claude/logs/agent-audit.log
```

### Backup Security

**Encrypted Backups**:
```bash
# Encrypt backups
tar -czf - ~/.claude/agents/ | gpg -c > backup-$(date +%Y%m%d).tar.gz.gpg

# Restore encrypted backup
gpg -d backup-20240203.tar.gz.gpg | tar -xzf -
```

## Maintenance and Updates

### Regular Maintenance Tasks

**Weekly Maintenance**:
```bash
#!/bin/bash
# weekly-maintenance.sh

# Backup current agents
./deployment/scripts/backup-manager.sh create "weekly-$(date +%Y%m%d)"

# Update agent repository
git pull origin main

# Validate agent files
./deployment/scripts/validate-agents.sh

# Clean old backups
./deployment/scripts/backup-manager.sh cleanup --keep 10
```

**Monthly Updates**:
```bash
# Update to latest agent versions
./deployment/scripts/install.sh core --update

# Performance review
./deployment/scripts/performance-report.sh

# Security audit
./deployment/scripts/security-audit.sh
```

### Version Management

**Agent Versioning**:
```yaml
# deployment/configs/versions.yaml
agent_versions:
  strategist: v2.1.0
  developer: v2.0.5
  tester: v1.9.2
  operator: v2.0.1
```

**Rollback Procedures**:
```bash
# Rollback to previous version
./deployment/scripts/install.sh core --version v1.8.0

# Rollback specific agent
./deployment/scripts/rollback-agent.sh strategist v2.0.0
```

### Health Monitoring

**Agent Health Checks**:
```bash
# Check agent responsiveness
./deployment/scripts/health-check.sh

# Validate agent file integrity
./deployment/scripts/validate-agents.sh --deep

# Performance monitoring
./deployment/scripts/performance-monitor.sh --continuous
```

**Automated Monitoring**:
```bash
# Add to cron for continuous monitoring
*/30 * * * * /path/to/agent-11/deployment/scripts/health-check.sh --quiet
```

## Advanced Troubleshooting

### Debug Mode Installation

```bash
# Enable detailed logging
./deployment/scripts/install.sh core --debug --verbose

# Check installation logs
tail -f ~/.claude/logs/agent-11-install.log
```

### Performance Profiling

```bash
# Profile installation time
time ./deployment/scripts/install.sh core

# Memory usage monitoring
./deployment/scripts/monitor-memory.sh during-install
```

### Custom Validation

```bash
# Create custom validation rules
./deployment/scripts/custom-validator.sh --rules my-validation-rules.yaml
```

## Integration Examples

### CI/CD Integration

```yaml
# .github/workflows/deploy-agents.yml
name: Deploy AGENT-11
on: 
  push:
    paths: ['agents/**']
    
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Deploy agents
        run: ./deployment/scripts/install.sh core
      - name: Validate deployment
        run: ./deployment/scripts/validate-installation.sh
```

### Docker Integration

```dockerfile
# Dockerfile for AGENT-11 development environment
FROM ubuntu:20.04

COPY deployment/ /agent-11/deployment/
COPY agents/ /agent-11/agents/

RUN /agent-11/deployment/scripts/install.sh core

CMD ["claude"]
```

---

**Ready for Enterprise Scale?** These advanced patterns let you customize, secure, and scale AGENT-11 for any organization size or complexity. Your elite AI development infrastructure awaits! 🚁

## Quick Reference

### Essential Advanced Commands
```bash
# Custom squad deployment
./deployment/scripts/install.sh custom_squad

# Backup management  
./deployment/scripts/backup-manager.sh create "backup-name"

# Environment-specific deployment
./deployment/scripts/install.sh core --env production

# Health monitoring
./deployment/scripts/health-check.sh --continuous
```

### Configuration Files
- `/deployment/configs/squad-definitions.yaml` - Squad configurations
- `/deployment/configs/environments.yaml` - Environment settings  
- `~/.claude/agents/` - Deployed agent files
- `~/.claude/backups/agent-11/` - Backup storage