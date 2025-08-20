# AGENT-11 Review Workflows Guide 🔍

## Comprehensive Design & Code Review System

This guide covers AGENT-11's advanced review capabilities for maintaining world-class quality standards in your projects.

## Overview

AGENT-11 now includes powerful review protocols inspired by industry best practices:

- **RECON Protocol** - Rapid Evaluation & Critique Operations Network (UI/UX)
- **SENTINEL Mode** - Systematic Evaluation & Testing Intelligence (Functionality)
- **PARALLEL STRIKE** - Simultaneous multi-agent operations

## Quick Start

### Basic UI/UX Review
```bash
# Review current branch changes
/recon

# Review specific PR
/recon PR-123
```

### Full Assessment Mission
```bash
# Comprehensive design and functionality review
/coord operation-recon

# With specific target
/coord operation-recon feature-branch
```

### Parallel Operations
```bash
# Simultaneous design + test review
@coordinator Execute PARALLEL STRIKE for current branch
```

## RECON Protocol (Designer)

### What It Does
Performs systematic UI/UX reconnaissance across 8 tactical phases:

1. **Preparation** - Sets up Playwright, configures viewports
2. **Interaction Reconnaissance** - Tests all interactive states
3. **Responsive Operations** - Validates desktop/tablet/mobile
4. **Visual Inspection** - Checks consistency and aesthetics
5. **Accessibility Sweep** - WCAG AA+ compliance
6. **Robustness Testing** - Edge cases and stress tests
7. **Code Inspection** - Design token usage
8. **Console Reconnaissance** - Error detection

### When to Use
- PR reviews with UI changes
- Before major releases
- Design system compliance checks
- Accessibility audits
- Visual regression detection

### Example Usage
```bash
# Basic RECON
@designer Execute RECON Protocol on the dashboard

# With specific focus
@designer RECON Protocol: Focus on mobile responsiveness for checkout flow

# Quick assessment
/recon
```

### Output Format
```markdown
### RECON REPORT: [Component Name]

#### OPERATIONAL SUMMARY
[Overall assessment and positive observations]

#### CRITICAL THREATS
- [Issue description + Screenshot]

#### URGENT ISSUES  
- [Issue description + Screenshot]

#### TACTICAL IMPROVEMENTS
- [Enhancement suggestions]

#### COSMETIC POLISH
- Polish: [Minor items]
```

## SENTINEL Mode (Tester)

### What It Does
Executes comprehensive testing across 7 phases:

1. **Perimeter Establishment** - Maps test coverage
2. **Functional Reconnaissance** - Tests all features
3. **Visual Regression Sweep** - Compares against baseline
4. **Cross-Browser Operations** - Multi-browser validation
5. **Performance Patrol** - Load time analysis
6. **Stress Testing** - Creative breaking attempts
7. **Accessibility Verification** - Deep validation

### When to Use
- Regression testing
- Cross-browser validation
- Performance verification
- Pre-release quality gates
- Integration with RECON for full coverage

### Example Usage
```bash
# Full SENTINEL deployment
@tester Deploy SENTINEL Mode on user registration flow

# Quick functional check
@tester SENTINEL: Verify payment processing

# Combined with RECON
/coord operation-recon --full-spectrum
```

### Output Format
```markdown
### SENTINEL REPORT: [Feature Name]

#### OPERATIONAL STATUS
- Overall Health: [GREEN/YELLOW/RED]
- Test Coverage: [X%]
- Issues Detected: [Count by severity]

#### CRITICAL THREATS
- [Issue + Steps + Evidence]

#### PERFORMANCE METRICS
- Load Time: [Xms]
- Memory Usage: [XMB]

#### CROSS-BROWSER STATUS
- Chrome: [PASS/FAIL]
- Firefox: [PASS/FAIL]
- Safari: [PASS/FAIL]
```

## PARALLEL STRIKE (Coordinator)

### What It Does
Enables simultaneous multi-agent operations for comprehensive assessment:
- 50-70% faster than sequential reviews
- Catches issues single perspectives miss
- Reduces context switching
- Provides unified reporting

### Activation Patterns

#### Pattern 1: UI + Functionality
```bash
@coordinator PARALLEL STRIKE:
- Designer: Execute RECON Protocol
- Tester: Deploy SENTINEL Mode
```

#### Pattern 2: Full Spectrum PR Review
```bash
@coordinator PARALLEL STRIKE for PR-789:
- Designer: Visual and UX assessment
- Tester: Functional validation
- Developer: Code quality review
- Architect: Architecture compliance
```

#### Pattern 3: Triple Vector Assessment
```bash
@coordinator PARALLEL STRIKE:
- Operator: Performance profiling
- Developer: Security scanning
- Designer: Accessibility audit
```

### Synchronization
- Checkpoints every 30-60 minutes
- Automated evidence collection
- Conflict resolution protocols
- Unified report generation

## Field Manual Integration

### UI Doctrine
Located at `/field-manual/ui-doctrine.md`, defines:
- Design system specifications
- Color and typography standards
- Component patterns
- Accessibility requirements
- Performance targets

### Using UI Doctrine in Reviews
```bash
# RECON automatically references UI doctrine
@designer RECON Protocol: Verify compliance with ui-doctrine.md

# Custom standards check
@designer Check dashboard against our design tokens in field-manual
```

## Common Workflows

### PR Review Workflow
```bash
# 1. Initial assessment
/recon

# 2. If issues found, deep dive
/coord operation-recon

# 3. After fixes, verify
@tester Quick SENTINEL check on fixed issues
```

### Pre-Release Quality Gate
```bash
# Full parallel assessment
@coordinator PARALLEL STRIKE for release-1.0:
- All specialists report to stations
- Execute comprehensive review
- Compile unified report
```

### Design System Compliance
```bash
# Check component library
@designer RECON Protocol on all components in /components
Verify against ui-doctrine.md standards
```

## Best Practices

### 1. Evidence Collection
- Always capture screenshots for visual issues
- Document exact reproduction steps
- Include browser/device information
- Save console logs for errors

### 2. Threat Classification
- Use consistent severity levels
- Consider user impact first
- Balance fix effort vs benefit
- Document decision rationale

### 3. Communication
- Follow "Observe-Don't-Prescribe" principle
- Describe problems, not solutions
- Start with positive observations
- Be specific and actionable

### 4. Efficiency
- Use PARALLEL STRIKE for complex reviews
- Set clear time boundaries
- Focus on high-impact issues
- Automate repetitive checks

## Troubleshooting

### Issue: Playwright MCP not available
```bash
# Install Playwright MCP first
claude mcp add @modelcontextprotocol/server-playwright

# Then retry RECON
/recon
```

### Issue: Conflicting specialist findings
```bash
# Escalate to strategist for prioritization
@strategist Resolve conflict between designer and developer findings
```

### Issue: Review taking too long
```bash
# Use focused assessment
@designer Quick RECON: Focus only on mobile responsive issues

# Or set time limits
@coordinator 30-minute PARALLEL STRIKE on critical paths only
```

## Advanced Techniques

### Custom Review Profiles
```bash
# Create project-specific review criteria
echo "Custom accessibility requirements" >> field-manual/custom-standards.md

# Reference in reviews
@designer RECON with custom-standards.md requirements
```

### Automated Review Triggers
```bash
# On PR creation (GitHub Actions)
on: pull_request
  run: claude code /recon

# Pre-commit hook
pre-commit:
  - claude code @tester Quick SENTINEL check
```

### Metrics Tracking
```bash
# After each review, update metrics
@analyst Track review findings:
- Issues by category
- Time to resolution
- Regression patterns
```

## Summary

AGENT-11's review capabilities provide:
- **Comprehensive Coverage** - UI, functionality, performance, accessibility
- **Speed** - Parallel operations reduce review time by 50-70%
- **Consistency** - Standardized protocols and classifications
- **Evidence-Based** - Screenshot and data-driven findings
- **Actionable** - Clear severity levels and recommendations

Start with `/recon` for quick assessments, escalate to `/coord operation-recon` for comprehensive reviews, and leverage PARALLEL STRIKE for maximum efficiency.

---

*"In the battlefield of code quality, systematic reconnaissance wins the war."*