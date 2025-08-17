# Operation: RECON 🔍
## UI/UX Reconnaissance Mission

**Mission Code**: RECON  
**Estimated Duration**: 2-4 hours  
**Complexity**: High  
**Squad Required**: Designer (lead), Tester (support)

## Mission Briefing

Execute a comprehensive UI/UX reconnaissance operation on frontend changes. This mission deploys the RECON Protocol to assess design quality, user experience, accessibility compliance, and visual consistency across all modified components.

## Required Inputs

1. **Target Scope** (required) - PR number, branch name, or specific components
2. **Live Environment** (required) - URL for testing or local dev server
3. **Design Standards** (optional) - Reference to design system or brand guidelines
4. **Success Metrics** (optional) - Specific KPIs or requirements to validate

## Mission Phases

### Phase 0: Intelligence Gathering (15 minutes)

**Lead**: @coordinator  
**Support**: @designer  
**Objective**: Understand scope and prepare battlefield

```bash
# Assess the operational theater
git fetch origin
git diff origin/main...HEAD --stat
git diff origin/main...HEAD --name-only | grep -E '\.(jsx?|tsx?|css|scss|sass)$'

# Review mission parameters
@designer Analyze the scope:
1. Identify all UI components modified
2. Map user journeys affected
3. Review existing design patterns
4. Note any accessibility requirements
5. Check for design system compliance needs
```

**Deliverables**:
- Component inventory
- Affected user flows
- Risk assessment
- Testing priorities

### Phase 1: RECON Protocol Activation (30-45 minutes)

**Lead**: @designer  
**Support**: @tester  
**Objective**: Execute systematic UI/UX assessment

```bash
@designer Execute RECON Protocol:
1. PREPARATION - Set up Playwright, configure viewports
2. INTERACTION RECONNAISSANCE - Test all interactive elements
3. RESPONSIVE OPERATIONS - Validate across devices
4. VISUAL INSPECTION - Check consistency and aesthetics
5. ACCESSIBILITY SWEEP - WCAG AA+ compliance
6. ROBUSTNESS TESTING - Edge cases and stress tests
7. CODE INSPECTION - Design token usage
8. CONSOLE RECONNAISSANCE - Check for errors
```

**Key Activities**:
- Capture screenshot evidence at each viewport
- Document all interactive state changes
- Test keyboard navigation completely
- Verify focus management
- Check color contrast ratios
- Validate responsive breakpoints

### Phase 2: SENTINEL Mode Deployment (30-45 minutes)

**Lead**: @tester  
**Support**: @designer  
**Objective**: Comprehensive functional and visual validation

```bash
@tester Activate SENTINEL Mode:
1. PERIMETER ESTABLISHMENT - Map test coverage
2. FUNCTIONAL RECONNAISSANCE - Test all features
3. VISUAL REGRESSION SWEEP - Compare against baseline
4. CROSS-BROWSER OPERATIONS - Multi-browser testing
5. PERFORMANCE PATROL - Load time analysis
6. STRESS TESTING - Break it creatively
7. ACCESSIBILITY VERIFICATION - Deep validation
```

**Testing Matrix**:
- Chrome/Chromium (latest)
- Firefox (latest)
- Safari/WebKit (if applicable)
- Mobile browsers (iOS Safari, Chrome)
- Edge cases and boundary conditions

### Phase 3: Threat Assessment (20 minutes)

**Lead**: @designer  
**Support**: @tester  
**Objective**: Classify and prioritize findings

```bash
@designer Classify all findings:
[CRITICAL] - Blocks user progress, breaks accessibility
[URGENT] - Major UX degradation, needs immediate fix
[TACTICAL] - Medium priority improvements
[COSMETIC] - Minor polish items

@tester Add functional severity:
[CRITICAL] - System failure or data loss
[HIGH] - Major functionality broken
[MEDIUM] - Degraded experience
[LOW] - Edge cases only
```

**Classification Criteria**:
- User impact severity
- Frequency of occurrence
- Business criticality
- Technical complexity to fix
- Regression risk

### Phase 4: Evidence Collection (15 minutes)

**Lead**: @designer  
**Support**: @tester  
**Objective**: Document all findings with proof

```bash
@designer Capture evidence:
1. Screenshot all issues at point of failure
2. Record interaction videos for complex issues
3. Export browser console logs
4. Document exact reproduction steps
5. Note browser/device combinations affected
```

**Evidence Requirements**:
- Before/after comparisons
- Annotated screenshots
- Console error logs
- Network timing data
- Accessibility audit results

### Phase 5: Report Compilation (30 minutes)

**Lead**: @coordinator  
**Support**: @designer, @tester  
**Objective**: Deliver actionable intelligence

```bash
@coordinator Compile unified report:
1. Merge RECON and SENTINEL findings
2. Deduplicate overlapping issues
3. Prioritize by business impact
4. Create executive summary
5. Generate fix recommendations
```

**Report Sections**:
1. **Executive Summary** - Overall health, critical issues
2. **RECON Findings** - Design and UX issues
3. **SENTINEL Findings** - Functional and performance issues
4. **Evidence Gallery** - Screenshots and recordings
5. **Recommendations** - Prioritized action plan
6. **Metrics** - Coverage, pass/fail rates

## Success Criteria

- [ ] All modified components assessed
- [ ] Cross-browser testing complete
- [ ] Accessibility audit passed (WCAG AA)
- [ ] Performance benchmarks met
- [ ] Visual regression detected
- [ ] Report delivered with evidence
- [ ] Fix priorities established

## Tactical Advantages

### When to Deploy
- PR review for frontend changes
- Pre-release quality gates
- Design system compliance checks
- Accessibility audits
- Performance regression detection
- Cross-browser compatibility validation

### Mission Variants

#### Quick RECON (30 minutes)
- Single component or page
- Desktop only
- Basic accessibility check
- Visual inspection only

#### Deep RECON (4+ hours)
- Full application audit
- All breakpoints and devices
- Complete accessibility audit
- Performance profiling
- Security considerations

#### Regression RECON (2 hours)
- Before/after comparison
- Visual regression focus
- Automated screenshot diff
- Performance comparison

## Equipment Requirements

### Primary Tools (MCPs)
- mcp__playwright (browser automation)
- mcp__context7 (documentation)

### Secondary Tools
- Browser DevTools
- Lighthouse (performance)
- axe DevTools (accessibility)
- Screen readers (NVDA/VoiceOver)

### Communication Channels
- Screenshots via mcp__playwright
- Reports in markdown
- Evidence in project repository

## After Action Protocol

1. **Immediate Actions**:
   - Fix [CRITICAL] issues before merge
   - Schedule [URGENT] fixes for current sprint
   - Document [TACTICAL] items in backlog

2. **Learning Capture**:
   - Update ui-doctrine.md with new patterns
   - Add edge cases to test suite
   - Document accessibility findings

3. **Process Improvement**:
   - Automate detected regression patterns
   - Update RECON Protocol if needed
   - Share findings with squad

## Coordination Notes

- RECON and SENTINEL can run in parallel
- Designer leads visual assessment
- Tester leads functional validation
- Coordinator merges findings
- Evidence must support every issue
- Use "Observe-Don't-Prescribe" principle

## Common Issues Detected

### Visual/UX
- Inconsistent spacing
- Misaligned elements
- Color contrast failures
- Missing hover states
- Broken responsive layouts
- Font hierarchy issues

### Functional
- Broken interactions
- Form validation errors
- Navigation failures
- State management bugs
- API integration issues

### Accessibility
- Missing focus indicators
- Keyboard traps
- Unlabeled form fields
- Missing ARIA attributes
- Screen reader incompatibility

### Performance
- Large bundle sizes
- Unoptimized images
- Render blocking resources
- Memory leaks
- Slow API calls

---

*Begin reconnaissance with `/coord recon [target]` or `/recon` for current branch*