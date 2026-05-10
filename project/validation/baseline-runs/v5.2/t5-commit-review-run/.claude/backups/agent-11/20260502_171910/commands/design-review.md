---
allowed-tools: Grep, LS, Read, Edit, MultiEdit, Write, NotebookEdit, WebFetch, TodoWrite, WebSearch, Bash, Glob, Task, mcp__context7__resolve-library-id, mcp__context7__get-library-docs, mcp__playwright__browser_close, mcp__playwright__browser_resize, mcp__playwright__browser_console_messages, mcp__playwright__browser_handle_dialog, mcp__playwright__browser_evaluate, mcp__playwright__browser_file_upload, mcp__playwright__browser_install, mcp__playwright__browser_press_key, mcp__playwright__browser_type, mcp__playwright__browser_navigate, mcp__playwright__browser_navigate_back, mcp__playwright__browser_navigate_forward, mcp__playwright__browser_network_requests, mcp__playwright__browser_take_screenshot, mcp__playwright__browser_snapshot, mcp__playwright__browser_click, mcp__playwright__browser_drag, mcp__playwright__browser_hover, mcp__playwright__browser_select_option, mcp__playwright__browser_tab_list, mcp__playwright__browser_tab_new, mcp__playwright__browser_tab_select, mcp__playwright__browser_tab_close, mcp__playwright__browser_wait_for
description: Complete a comprehensive design review of the pending changes on the current branch, following the systematic RECON Protocol for UI/UX assessment
---

# DESIGN REVIEW PROTOCOL ACTIVATION 🎨

You are executing a comprehensive design review using world-class standards from companies like Stripe, Airbnb, and Linear. Your mission is to ensure UI/UX excellence through systematic evaluation.

## OPERATIONAL CONTEXT

### GIT STATUS:
```
!`git status`
```

### FILES MODIFIED:
```
!`git diff --name-only origin/HEAD...`
```

### COMMITS:
```
!`git log --no-decorate --oneline -10 origin/HEAD...`
```

### DIFF CONTENT:
```
!`git diff --merge-base origin/HEAD`
```

## MISSION PARAMETERS

Review the complete diff above containing all UI/UX changes. Execute the comprehensive design review protocol to assess:

- **Visual Consistency**: Design system compliance, typography, spacing
- **User Experience**: Interaction patterns, user flows, conversion optimization
- **Accessibility**: WCAG AA+ compliance, keyboard navigation, screen readers
- **Responsive Design**: Mobile-first, cross-device compatibility
- **Performance**: Load times, animations, resource optimization
- **Code Quality**: Component reuse, design token usage, maintainability

## EXECUTION DIRECTIVE

1. **Deploy @design-review agent** with full systematic protocol
2. **Apply project standards** from `/field-manual/ui-doctrine.md` if available
3. **Use live environment** for interactive testing (provide URL if needed)
4. **Execute all 7 phases** of the design review protocol systematically
5. **Classify findings** by severity: [BLOCKER], [HIGH-PRIORITY], [MEDIUM-PRIORITY], [NITPICK]
6. **Follow "Problems Over Prescriptions"** communication approach
7. **Provide visual evidence** via screenshots for all issues

## REVIEW PHASES TO EXECUTE

### Phase 0: Preparation (5 min)
- Analyze PR motivation and testing notes
- Set up Playwright environment
- Configure initial viewport (1440x900)

### Phase 1: Interaction & User Flow (15 min)
- Test primary user flows
- Validate all interactive states
- Check micro-interactions and animations
- Assess perceived performance

### Phase 2: Responsiveness Testing (10 min)
- Desktop (1440px) with screenshot
- Tablet (768px) layout adaptation
- Mobile (375px) touch optimization
- Breakpoint transition verification

### Phase 3: Visual Polish (10 min)
- Layout alignment consistency
- Typography hierarchy validation
- Color palette and image quality
- Visual hierarchy assessment

### Phase 4: Accessibility Audit (15 min)
- Keyboard navigation testing
- Focus state verification
- Screen reader compatibility
- Color contrast validation (4.5:1 minimum)
- Semantic HTML review

### Phase 5: Robustness Testing (10 min)
- Form validation with invalid inputs
- Content overflow scenarios
- Loading/empty/error states
- Edge case handling

### Phase 6: Code Health (10 min)
- Component reuse patterns
- Design token compliance
- CSS architecture review
- Performance optimization check

### Phase 7: Console & Performance (5 min)
- Browser console error check
- Network request optimization
- Content clarity review

## OUTPUT REQUIREMENTS

Your final response must contain:

1. **Executive Summary** with go/no-go recommendation
2. **Categorized Findings** with severity levels
3. **Visual Evidence** via screenshots where applicable
4. **Accessibility Compliance** status
5. **Performance Notes** and optimization opportunities
6. **Actionable Recommendations** prioritized by impact

## QUALITY STANDARDS

Apply these evaluation criteria:

- **User-First**: Prioritize user needs over aesthetic preferences
- **Performance-Critical**: Speed impacts conversion and retention
- **Accessibility-Mandatory**: Design must be inclusive for all users
- **Mobile-First**: Small screen experience drives success
- **Consistency-Essential**: Predictable patterns build trust

## COORDINATION PROTOCOL

- If **live environment needed**: Request URL for interactive testing
- If **design standards missing**: Use general best practices from UI Doctrine
- If **functional issues found**: Coordinate with @tester SENTINEL Mode
- If **performance concerns**: Alert @operator for optimization
- If **accessibility deep-dive needed**: Execute comprehensive WCAG audit

---

**INITIATE DESIGN REVIEW PROTOCOL NOW**

*Execute systematic evaluation. Document everything. Provide evidence. Deliver actionable insights.*