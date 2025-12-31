# Product Requirements Document (PRD) Template

> **Purpose**: Define WHAT you're building, for WHOM, and the specific requirements for MVP. This is the tactical companion to your vision document.
>
> **Token Budget**: When summarized for Agent-11, this document should compress to ~600 tokens capturing features, technical constraints, MVP scope, and priorities.

---

## Instructions

Complete each section with specific, actionable details. Vague requirements lead to scope creep and missed deadlines. Be ruthless about MVP scope - you can always add features later.

---

## 1. Product Overview

**Product Name**:

**One-Line Description**:
<!-- What does it do in one sentence? -->

[Your description here]

**Problem Statement**:
<!-- What specific problem does this solve? Be concrete. -->

[Your answer here]

**Solution Approach**:
<!-- How does your product solve this problem? -->

[Your answer here]

---

## 2. User Personas

### Primary Persona

**Name/Label**:
**Role**:
**Technical Level**: [Non-technical / Semi-technical / Technical]
**Key Goals**:
1.
2.
3.

**Pain Points**:
1.
2.
3.

**Success Scenario**:
<!-- Describe what success looks like for this user -->

[Your scenario here]

### Secondary Persona (if applicable)

**Name/Label**:
**Role**:
**Key Difference from Primary**:

---

## 3. Feature Requirements

### MVP Features (Must Have)

> *These are non-negotiable for launch. Be ruthless - every feature here delays launch.*

| ID | Feature | User Story | Acceptance Criteria | Priority |
|----|---------|------------|---------------------|----------|
| F1 |         | As a [user], I want to [action] so that [benefit] | - [ ] Criterion 1<br>- [ ] Criterion 2 | P0 |
| F2 |         | As a [user], I want to [action] so that [benefit] | - [ ] Criterion 1<br>- [ ] Criterion 2 | P0 |
| F3 |         | As a [user], I want to [action] so that [benefit] | - [ ] Criterion 1<br>- [ ] Criterion 2 | P0 |
| F4 |         | As a [user], I want to [action] so that [benefit] | - [ ] Criterion 1<br>- [ ] Criterion 2 | P0 |
| F5 |         | As a [user], I want to [action] so that [benefit] | - [ ] Criterion 1<br>- [ ] Criterion 2 | P0 |

### Post-MVP Features (Nice to Have)

> *Features for future iterations. Document them but don't build them yet.*

| ID | Feature | Why Deferred | Target Version |
|----|---------|--------------|----------------|
| F6 |         |              | v1.1           |
| F7 |         |              | v1.1           |
| F8 |         |              | v2.0           |

### Explicitly Out of Scope

> *Features you're consciously NOT building. Prevents scope creep.*

-
-
-

---

## 4. Technical Requirements

### Technology Constraints

**Required Technologies** (if any):
<!-- Technologies that MUST be used -->
-
-

**Preferred Technologies** (if any):
<!-- Technologies you'd LIKE to use but are flexible on -->
-
-

**Prohibited Technologies** (if any):
<!-- Technologies you specifically want to avoid -->
-

### Platform Requirements

**Target Platforms**:
- [ ] Web (Desktop)
- [ ] Web (Mobile)
- [ ] iOS Native
- [ ] Android Native
- [ ] Desktop App (Mac/Windows/Linux)
- [ ] CLI Tool
- [ ] API Only

**Browser Support** (if web):
- [ ] Chrome (latest)
- [ ] Firefox (latest)
- [ ] Safari (latest)
- [ ] Edge (latest)
- [ ] Mobile browsers

### Integration Requirements

| Integration | Purpose | Required for MVP? |
|-------------|---------|-------------------|
|             |         | Yes / No          |
|             |         | Yes / No          |
|             |         | Yes / No          |

### Performance Requirements

| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| Page Load Time | < 3s |  |
| API Response Time | < 500ms |  |
| Uptime | 99.9% |  |
| Concurrent Users |  |  |

### Security Requirements

- [ ] User authentication required
- [ ] Data encryption at rest
- [ ] Data encryption in transit (HTTPS)
- [ ] GDPR compliance needed
- [ ] SOC2 compliance needed
- [ ] PCI compliance needed (if payments)
- Other:

---

## 5. Data Requirements

### Core Data Entities

| Entity | Key Attributes | Relationships |
|--------|----------------|---------------|
|        |                |               |
|        |                |               |
|        |                |               |

### Data Storage Preferences

- [ ] SQL Database (PostgreSQL, MySQL)
- [ ] NoSQL Database (MongoDB, DynamoDB)
- [ ] Serverless (Supabase, Firebase)
- [ ] File Storage needed
- [ ] No preference - let architect decide

### Data Privacy Considerations

- What user data is collected:
- Data retention policy:
- Data deletion requirements:

---

## 6. User Experience Requirements

### Design Constraints

**Brand Guidelines**: [Link to brand guidelines or describe]

**Design System Preference**:
- [ ] Custom design
- [ ] Use existing design system (specify: )
- [ ] No preference - let designer decide

**Accessibility Requirements**:
- [ ] WCAG 2.1 AA compliance
- [ ] Screen reader support
- [ ] Keyboard navigation
- [ ] Color contrast compliance
- [ ] No specific requirements

### Key User Flows

**Flow 1: [Primary User Journey]**
1. User arrives at...
2. User clicks/taps...
3. System shows...
4. User completes...
5. Success state: ...

**Flow 2: [Secondary User Journey]**
1. ...

---

## 7. Business Requirements

### Monetization Model

- [ ] Free (no monetization)
- [ ] Freemium (free tier + paid features)
- [ ] Subscription (monthly/annual)
- [ ] One-time purchase
- [ ] Usage-based pricing
- [ ] Marketplace/commission
- [ ] Other:

**Pricing Tiers** (if applicable):
| Tier | Price | Features |
|------|-------|----------|
| Free |       |          |
| Pro  |       |          |
| Enterprise |  |         |

### Launch Requirements

**MVP Launch Date Target**:

**Launch Checklist**:
- [ ] Core features complete
- [ ] Basic documentation
- [ ] Error handling
- [ ] User onboarding flow
- [ ] Payment integration (if applicable)
- [ ] Analytics/tracking setup
- [ ] Legal pages (privacy, terms)

---

## 8. Success Metrics

### Launch Success (First 30 Days)

| Metric | Target | How Measured |
|--------|--------|-------------|
| Sign-ups |  |  |
| Active users |  |  |
| Conversion rate |  |  |
| Key feature usage |  |  |

### Growth Metrics (90 Days+)

| Metric | Target | How Measured |
|--------|--------|-------------|
| MRR |  |  |
| User retention |  |  |
| NPS Score |  |  |

---

## Summary for Agent-11

> *After completing the sections above, write a condensed summary (~600 tokens) that captures the essential requirements. This is what Agent-11 will use for context.*

**Requirements Summary**:
```
[PRODUCT]:
[PROBLEM]:
[SOLUTION]:
[TARGET USER]:

[MVP FEATURES]:
- F1:
- F2:
- F3:
- F4:
- F5:

[TECH STACK]:
- Platform:
- Database:
- Key Integrations:

[CONSTRAINTS]:
-
-

[OUT OF SCOPE]:
-
-

[SUCCESS CRITERIA]:
- Launch:
- 30 days:
- 90 days:

[MONETIZATION]:
[LAUNCH TARGET]:
```

---

## Checklist Before Development

- [ ] MVP scope is realistic for timeline
- [ ] Features are prioritized (P0/P1/P2)
- [ ] Each feature has clear acceptance criteria
- [ ] Technical constraints are documented
- [ ] Out of scope items are explicit
- [ ] Success metrics are measurable
- [ ] Summary captures essence in ~600 tokens
- [ ] Vision document is complete (foundation-vision.md)

---

## Related Documents

- **Vision & Mission**: `foundation-vision.md`
- **Architecture**: `architecture.md` (generated by Agent-11)
- **User Stories**: `user-stories.md` (generated by @strategist)

---

*Template Version: 1.0 | Compatible with Agent-11 /foundations command*
