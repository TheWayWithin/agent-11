# UI DOCTRINE - OPERATIONAL STANDARDS 🎖️

## MISSION STATEMENT

This field manual establishes the UI/UX operational standards for all AGENT-11 deployments. These doctrines ensure world-class user interfaces that convert visitors to customers while maintaining tactical excellence in design, accessibility, and performance.

## CORE DESIGN PHILOSOPHY

### STRATEGIC PRIORITIES
1. **Users First**: Every decision prioritizes user needs and workflows
2. **Speed is Life**: Performance directly impacts conversion and retention
3. **Clarity Wins Battles**: Ambiguity kills user confidence
4. **Consistency Builds Trust**: Predictable patterns reduce cognitive load
5. **Accessibility is Non-Negotiable**: Design for all users, always

### TACTICAL PRINCIPLES
- **Function Over Form**: Beautiful but broken loses to ugly but working
- **Mobile-First Always**: Design for constraints, enhance for capabilities
- **Progressive Disclosure**: Show only what's needed, when it's needed
- **Defensive Design**: Anticipate user errors and prevent them
- **Performance Budget**: Every pixel and millisecond counts

## DESIGN SYSTEM SPECIFICATIONS

### COLOR OPERATIONS
Define your color arsenal with semantic purpose:

```css
/* Tactical Color Variables */
--primary: user-defined;        /* Brand identity */
--secondary: user-defined;       /* Supporting actions */
--success: #10B981;             /* Positive outcomes */
--warning: #F59E0B;             /* Caution states */
--danger: #EF4444;              /* Destructive actions */
--info: #3B82F6;                /* Informational */

/* Neutral Territory */
--neutral-50: #FAFAFA;          /* Backgrounds */
--neutral-100: #F4F4F5;         /* Subtle backgrounds */
--neutral-200: #E4E4E7;         /* Borders */
--neutral-300: #D4D4D8;         /* Disabled borders */
--neutral-400: #A1A1AA;         /* Placeholder text */
--neutral-500: #71717A;         /* Secondary text */
--neutral-600: #52525B;         /* Primary text */
--neutral-700: #3F3F46;         /* Headings */
--neutral-800: #27272A;         /* High emphasis */
--neutral-900: #18181B;         /* Maximum contrast */
```

### TYPOGRAPHY COMMAND STRUCTURE

```css
/* Type Scale - Mobile First */
--text-xs: 0.75rem;     /* 12px - Captions */
--text-sm: 0.875rem;    /* 14px - Secondary */
--text-base: 1rem;      /* 16px - Body */
--text-lg: 1.125rem;    /* 18px - Emphasis */
--text-xl: 1.25rem;     /* 20px - H4 */
--text-2xl: 1.5rem;     /* 24px - H3 */
--text-3xl: 1.875rem;   /* 30px - H2 */
--text-4xl: 2.25rem;    /* 36px - H1 */

/* Font Weights */
--font-normal: 400;
--font-medium: 500;
--font-semibold: 600;
--font-bold: 700;

/* Line Heights */
--leading-tight: 1.25;
--leading-normal: 1.5;
--leading-relaxed: 1.75;
```

### SPACING UNITS

All spacing follows an 8-point grid system:

```css
/* Spacing Scale */
--space-0: 0;
--space-1: 0.25rem;    /* 4px */
--space-2: 0.5rem;     /* 8px */
--space-3: 0.75rem;    /* 12px */
--space-4: 1rem;       /* 16px */
--space-6: 1.5rem;     /* 24px */
--space-8: 2rem;       /* 32px */
--space-12: 3rem;      /* 48px */
--space-16: 4rem;      /* 64px */
```

## COMPONENT BATTLE STANDARDS

### BUTTON SPECIFICATIONS

```css
/* Primary Action Button */
.btn-primary {
  padding: var(--space-3) var(--space-6);
  background: var(--primary);
  color: white;
  border-radius: 6px;
  font-weight: var(--font-semibold);
  transition: all 150ms ease-in-out;
}

/* States */
.btn-primary:hover { filter: brightness(110%); }
.btn-primary:active { filter: brightness(90%); }
.btn-primary:disabled { opacity: 0.5; cursor: not-allowed; }
.btn-primary:focus { outline: 2px solid var(--primary); outline-offset: 2px; }
```

### FORM FIELD REQUIREMENTS

```css
/* Input Field Standards */
.input {
  width: 100%;
  padding: var(--space-2) var(--space-3);
  border: 1px solid var(--neutral-200);
  border-radius: 6px;
  font-size: var(--text-base);
  transition: all 150ms ease-in-out;
}

.input:focus {
  border-color: var(--primary);
  outline: none;
  box-shadow: 0 0 0 3px rgba(var(--primary-rgb), 0.1);
}

.input:disabled {
  background: var(--neutral-50);
  cursor: not-allowed;
}

.input-error {
  border-color: var(--danger);
}
```

## ACCESSIBILITY PROTOCOLS (WCAG AA+)

### MANDATORY REQUIREMENTS
- **Color Contrast**: Minimum 4.5:1 for normal text, 3:1 for large text
- **Focus Indicators**: Visible focus states on ALL interactive elements
- **Keyboard Navigation**: Full functionality without mouse
- **Screen Reader Support**: Semantic HTML and ARIA labels
- **Touch Targets**: Minimum 44x44px on mobile
- **Error Identification**: Clear error messages with instructions

### TESTING CHECKLIST
- [ ] Tab through entire interface
- [ ] Test with screen reader (NVDA/JAWS/VoiceOver)
- [ ] Verify color contrast ratios
- [ ] Check focus trap in modals
- [ ] Validate form labels and descriptions
- [ ] Test with keyboard only
- [ ] Verify skip links present
- [ ] Check alt text on images
- [ ] Test with 200% zoom
- [ ] Validate ARIA implementation

## RESPONSIVE BREAKPOINTS

```css
/* Mobile First Breakpoints */
--screen-sm: 640px;   /* Small tablets */
--screen-md: 768px;   /* Tablets */
--screen-lg: 1024px;  /* Small laptops */
--screen-xl: 1280px;  /* Desktops */
--screen-2xl: 1536px; /* Large screens */
```

### VIEWPORT STRATEGIES
1. **320px-639px**: Single column, stacked layout
2. **640px-767px**: 2-column grid where appropriate
3. **768px-1023px**: Flexible grid, sidebar appears
4. **1024px+**: Full desktop experience

## PERFORMANCE TARGETS

### CRITICAL METRICS
- **First Contentful Paint (FCP)**: < 1.8s
- **Largest Contentful Paint (LCP)**: < 2.5s
- **Time to Interactive (TTI)**: < 3.8s
- **Cumulative Layout Shift (CLS)**: < 0.1
- **First Input Delay (FID)**: < 100ms

### OPTIMIZATION TACTICS
- Lazy load below-the-fold content
- Optimize images (WebP with fallbacks)
- Minimize JavaScript execution
- Use CSS containment for complex layouts
- Implement virtual scrolling for long lists
- Cache static assets aggressively

## INTERACTION PATTERNS

### MICRO-INTERACTIONS
All interactions should provide immediate feedback:

```css
/* Standard Transition */
transition: all 150ms ease-in-out;

/* Loading States */
@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}

.skeleton {
  animation: pulse 2s infinite;
  background: var(--neutral-100);
}
```

### ANIMATION GUIDELINES
- **Duration**: 150-300ms for micro-interactions
- **Easing**: ease-in-out for most transitions
- **Purpose**: Enhance understanding, not decoration
- **Performance**: Use transform and opacity only
- **Accessibility**: Respect prefers-reduced-motion

## ERROR HANDLING

### USER-FACING ERRORS
```markdown
ERROR CLASSIFICATION:
- [CRITICAL]: Prevents user progress
- [WARNING]: Degraded experience
- [INFO]: Helpful guidance

ERROR MESSAGE FORMAT:
1. What went wrong (clear, non-technical)
2. Why it happened (if helpful)
3. How to fix it (actionable steps)
4. Where to get help (if needed)
```

### VISUAL ERROR STATES
- Red border on invalid fields
- Clear error text below field
- Icon indicator (⚠️ or ❌)
- Preserve user input when possible
- Focus first error field

## DARK MODE OPERATIONS

### IMPLEMENTATION STRATEGY
```css
/* Automatic Detection */
@media (prefers-color-scheme: dark) {
  :root {
    --bg-primary: var(--neutral-900);
    --text-primary: var(--neutral-50);
    /* Invert neutral scale */
  }
}

/* Manual Toggle */
[data-theme="dark"] {
  /* Dark theme overrides */
}
```

### DARK MODE CHECKLIST
- [ ] Sufficient contrast maintained
- [ ] Images have appropriate filters
- [ ] Shadows adapted for dark backgrounds
- [ ] Brand colors adjusted for visibility
- [ ] Code blocks properly themed

## QUALITY ASSURANCE

### PRE-DEPLOYMENT CHECKLIST
- [ ] Cross-browser testing complete
- [ ] Mobile responsiveness verified
- [ ] Accessibility audit passed
- [ ] Performance budget met
- [ ] Error states tested
- [ ] Loading states implemented
- [ ] Empty states designed
- [ ] Print stylesheet included
- [ ] Meta tags optimized
- [ ] Favicon set

### RECON PROTOCOL COMPLIANCE
When executing RECON Protocol, verify:
1. Design tokens properly applied
2. Component patterns consistent
3. Accessibility standards met
4. Performance targets achieved
5. Responsive behavior correct
6. Error handling appropriate
7. Loading states present
8. Dark mode functional

## FIELD NOTES

- Every pixel should earn its place
- Speed perceived is speed achieved
- Consistency reduces support tickets
- Accessibility expands market reach
- Performance is a feature, not a nice-to-have
- Test with real users, not assumptions
- Document decisions for future operators

---

*"In the battlefield of user attention, clarity and speed are your strongest weapons."*