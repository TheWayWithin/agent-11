# Agent Context

The single accumulated context file for this mission. Every specialist reads this at task start and appends a **Phase Handoff** block at task end. The coordinator owns the file's structural integrity.

This file replaces the v5.x split between `agent-context.md` and `handoff-notes.md` — phase-end content that used to live in handoff-notes is now a structured Phase Handoff block here.

---

## Mission Overview

**Mission Code**: [MISSION_CODE]
**Started**: [YYYY-MM-DD HH:MM]
**Mode**: [A — Greenfield | B1 — Surgical | B2 — Maintenance]
**Current Phase**: [PHASE_NAME]
**Overall Status**: [IN_PROGRESS | BLOCKED | COMPLETING | COMPLETE]

## Mission Objectives

- [ ] Objective 1
- [ ] Objective 2
- [ ] Objective 3

## Critical Constraints

Important limitations and requirements to maintain:
- Constraint 1
- Constraint 2

## Technical Context

### Architecture Decisions
- Decision 1: [What and why]

### Technology Stack
- Framework: [Name and version]
- Database: [Type and configuration]

### Implementation Patterns
- Pattern 1: [Description and usage]

## Active Issues & Blockers

1. **Issue**: [Description]
   - **Impact**: [How it affects the mission]
   - **Workaround**: [If any]
   - **Owner**: [Who's resolving]

## Dependencies

- Component 1 must complete before Component 2
- External: Service A requires Service B configuration

---

## Phase Handoffs

Each closed phase appends a Phase Handoff block here using the 5-field schema below. New blocks go at the **bottom** (chronological order). Specialists read the **most recent** block to pick up context; older blocks remain for audit and pause/resume continuity.

### Phase Handoff Schema (mandatory at phase close)

```markdown
## Phase Handoff — [Phase Name]

**Closed**: [YYYY-MM-DD HH:MM]
**By**: @[specialist or coordinator]

### Findings
- [What was discovered, what worked, what didn't]
- [Technical details that affect later phases]

### Decisions
- [Decision]: [rationale]
- [Decision]: [rationale]

### Warnings & Gotchas
- [Things the next phase needs to know — failure modes, hidden constraints, surprising behaviour]

### Open Items
- [Unresolved questions or work that carries to the next phase]

### Evidence
- [Pointer to evidence-repository.md entry, e.g., `evidence-repository.md → auth/jwt-test-results.md`]
- [Or: "None" if no evidence captured]
```

### Example Phase Handoff

```markdown
## Phase Handoff — Auth Implementation

**Closed**: 2026-04-26 14:30
**By**: @developer

### Findings
- JWT library `jsonwebtoken` chosen; HS256 sufficient for MVP scale
- Refresh tokens stored in HTTP-only cookies (XSS-safe)
- bcrypt cost factor 12 for password hashing

### Decisions
- HTTP-only cookies over localStorage: prevents XSS exfiltration of session tokens
- 15-minute access token TTL with 7-day refresh: balances UX and revocation latency

### Warnings & Gotchas
- Refresh token rotation interval 15min; re-evaluate under realistic load before launch
- Cookie SameSite=Lax — confirm this works with the planned OAuth provider redirect flow

### Open Items
- Rate limiting on `/auth/login` not implemented (deferred to Phase 3 hardening)
- MFA flow not yet scoped — needs strategist input

### Evidence
- evidence-repository.md → auth-implementation/jwt-test-results.md
```

---

## Phase Handoff History

*Append new Phase Handoff blocks here at phase close. Most recent at the bottom.*

[Phase Handoff blocks accumulate below this line]

---

*This file is the single source of accumulated context for the mission. Read it at task start; append a Phase Handoff block at task close. The coordinator verifies the Phase Handoff block exists before marking a phase complete.*
