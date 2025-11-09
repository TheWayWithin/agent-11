# Foundation Document Guardrails Design
## Complete Protocol Design for Implementation

**Mission**: FOUNDATION-GUARDRAILS-2025-11-09
**Designer**: @architect (Extended Thinking Mode: ultrathink)
**Status**: Complete - Ready for Implementation
**Target**: All 11 library agents in `project/agents/specialists/`

---

## EXECUTIVE SUMMARY

This design creates a mandatory Foundation Document Adherence Protocol that mirrors the proven Context Preservation Protocol. It addresses the critical gap where 100% of agents have context preservation but 0% have foundation document verification.

**Key Innovation**: Extends the proven context preservation pattern to foundation documents with mandatory language, verification checkpoints, and escalation protocols.

**Impact**: Prevents architectural drift, ensures product deliverables match specifications, restores user confidence in consistency.

---

## 1. FOUNDATION DOCUMENT PROTOCOL (Universal Section)

### Protocol Text (Insert after Context Preservation Protocol in all agents)

```markdown
## FOUNDATION DOCUMENT ADHERENCE PROTOCOL

**Critical Principle**: Foundation documents (architecture.md, ideation.md, PRD, product-specs.md) are the SOURCE OF TRUTH. Context files summarize them but are NOT substitutes. When in doubt, consult the foundation.

**Before making design or implementation decisions:**
1. **MUST** read relevant foundation documents:
   - **architecture.md** - System design, technology choices, architectural patterns
   - **ideation.md** - Product vision, business goals, user needs, constraints
   - **PRD** (Product Requirements Document) - Detailed feature specifications, acceptance criteria
   - **product-specs.md** - Brand guidelines, positioning, messaging (if applicable)

2. **Verify alignment** with foundation specifications:
   - Does this decision match the documented architecture?
   - Is this consistent with the product vision in ideation.md?
   - Does this satisfy the requirements in the PRD?
   - Does this respect documented constraints and design principles?

3. **Escalate when unclear**:
   - Foundation document missing → Request creation from coordinator
   - Foundation unclear or ambiguous → Escalate to coordinator for clarification
   - Foundation conflicts with requirements → Escalate to user for resolution
   - Foundation appears outdated → Flag to coordinator for update

**Standard Foundation Document Locations**:
- Primary: `/architecture.md`, `/ideation.md`, `/PRD.md`, `/product-specs.md`
- Alternative: `/docs/architecture/`, `/docs/ideation/`, `/docs/requirements/`
- Discovery: Check root directory first, then `/docs/` subdirectories
- Missing: If foundation doc not found, check agent-context.md for reference or escalate

**After completing your task:**
1. Verify your work aligns with ALL relevant foundation documents
2. Document any foundation document updates needed in handoff-notes.md
3. Flag if foundation documents appear outdated or incomplete

**Foundation Documents vs Context Files**:
- **Foundation Docs** = Authoritative source (architecture.md, PRD, ideation.md)
- **Context Files** = Mission execution state (agent-context.md, handoff-notes.md)
- **Rule**: When foundation and context conflict, foundation wins → escalate immediately
```

**Rationale**: This protocol uses the EXACT same structure and mandatory language ("MUST", "Verify", "Escalate when") as the proven context preservation protocol. It's clear, actionable, and creates a verification habit.

---

## 2. VERIFICATION CHECKPOINT ENHANCEMENTS

### 2.1 Developer Strategic Solution Checklist Enhancement

**Current** (developer.md lines 159-164):
```markdown
STRATEGIC SOLUTION CHECKLIST (Before every implementation):
- ✅ Does this maintain all security requirements?
- ✅ Is this the architecturally correct solution?
- ✅ Will this create technical debt?
- ✅ Are there better long-term solutions?
- ✅ Have I understood the original design intent?
```

**Enhanced**:
```markdown
STRATEGIC SOLUTION CHECKLIST (Before every implementation):
- ✅ Does this maintain all security requirements?
- ✅ Is this the architecturally correct solution per architecture.md?
- ✅ Does this match the PRD requirements and acceptance criteria?
- ✅ Is this consistent with the product vision in ideation.md?
- ✅ Will this create technical debt?
- ✅ Are there better long-term solutions?
- ✅ Have I understood the original design intent from foundation documents?
```

**Changes**: Added explicit architecture.md, PRD, and ideation.md references to items 2, 3, 4, and 7.

---

### 2.2 Architect Pre-Handoff Checklist Enhancement

**Current** (architect.md lines 415-421):
```markdown
**Pre-Handoff Checklist**:
- [ ] All architectural decisions from task prompt documented with rationale
- [ ] Trade-offs explicitly stated (pros, cons, alternatives considered)
- [ ] Security implications analyzed and addressed
- [ ] Scalability requirements evaluated (current and 10x growth)
- [ ] handoff-notes.md updated with architecture decisions for implementation team
- [ ] architecture.md created/updated with complete system design
```

**Enhanced**:
```markdown
**Pre-Handoff Checklist**:
- [ ] Existing architecture.md reviewed for consistency (if exists)
- [ ] Design aligns with product vision from ideation.md
- [ ] All architectural decisions from task prompt documented with rationale
- [ ] Trade-offs explicitly stated (pros, cons, alternatives considered)
- [ ] Security implications analyzed and addressed
- [ ] Scalability requirements evaluated (current and 10x growth)
- [ ] Foundation documents updated if architecture evolved
- [ ] handoff-notes.md updated with architecture decisions for implementation team
- [ ] architecture.md created/updated with complete system design
```

**Changes**: Added foundation document review BEFORE design (items 1-2) and update verification (item 7).

---

### 2.3 Designer RECON Protocol Enhancement

**Current** (designer.md lines 167-267 - RECON Protocol):
The RECON Protocol currently has 8 phases but NO foundation document verification.

**Enhancement** (Add as Phase 0.5 - after Preparation, before Interaction Reconnaissance):

```markdown
PHASE 0.5: FOUNDATION VERIFICATION
- Review product-specs.md for brand guidelines (colors, typography, tone)
- Check PRD for feature requirements and user flow specifications
- Verify ideation.md for product positioning and target user personas
- Note any design system constraints from architecture.md
- Flag if foundation documents missing or unclear (escalate before proceeding)
```

**Also enhance Phase 3 (Visual Inspection)**:
```markdown
PHASE 3: VISUAL INSPECTION
- Assess layout alignment and spacing consistency
- Verify typography hierarchy and legibility
- Check color palette consistency and contrast
- Ensure visual hierarchy guides attention
- **Validate brand compliance per product-specs.md**
- **Verify design matches product positioning from ideation.md**
```

**Changes**: Added foundation verification as explicit RECON phase and enhanced visual inspection to reference foundation docs.

---

### 2.4 Coordinator Task Completion Verification Enhancement

**Current** (coordinator.md lines 243-285):
```markdown
TASK COMPLETION VERIFICATION (After each specialist response):
1. Task Tool Response Received
2. Deliverable Verification
3. Handoff Documentation Check
4. Quality Spot-Check
5. Dependency Check
6. Security Principles Maintained
```

**Enhanced**:
```markdown
TASK COMPLETION VERIFICATION (After each specialist response):
1. Task Tool Response Received
2. Deliverable Verification
3. Handoff Documentation Check
4. Quality Spot-Check
5. Dependency Check
6. Security Principles Maintained
7. **Foundation Alignment Check**:
   - Did specialist verify against architecture.md/PRD/ideation.md?
   - Does deliverable align with foundation specifications?
   - Are foundation documents updated if design evolved?
   - If no foundation verification mentioned, ask specialist to verify
```

**Changes**: Added mandatory Foundation Alignment Check as step 7 with explicit verification questions.

---

### 2.5 Strategist Pre-Task Protocol (NEW)

**Current**: Strategist has no explicit foundation reading requirement before creating strategy.

**Enhancement** (Add after Context Preservation Protocol):

```markdown
## FOUNDATION REVIEW PROTOCOL

**Before strategic planning or PRD creation:**
1. **Read ideation.md** for original product vision and business goals
2. **Review existing PRD** (if exists) to understand current requirements
3. **Check architecture.md** for technical constraints and system design
4. Ensure new strategy EVOLVES foundation, doesn't ignore it

**When creating requirements:**
- New PRD should EXTEND ideation.md, not contradict it
- Document if strategic pivot needed (requires user approval)
- Maintain consistency with product vision while adapting to market
```

**Rationale**: Strategist currently creates PRDs but has no instruction to review existing foundation. This ensures strategic consistency.

---

### 2.6 Marketer & Analyst Foundation Context (NEW)

**Current**: Both agents have zero foundation document mentions.

**Enhancement** (Add after Context Preservation Protocol for both):

```markdown
## FOUNDATION CONTEXT PROTOCOL

**Before campaign planning or analysis:**
1. **Read product-specs.md** for brand guidelines, positioning, messaging
2. **Review PRD** to understand product features and target users
3. **Check ideation.md** for business goals and success metrics

**Campaign/Analysis Alignment**:
- Marketing campaigns must match brand voice from product-specs.md
- Analytics should measure goals defined in ideation.md and PRD
- Escalate if foundation documents unclear or missing
```

**Rationale**: Marketing and analysis disconnected from product vision leads to off-brand campaigns and irrelevant insights.

---

### 2.7 Tester, Documenter, Operator, Support (Lower-Risk Agents)

**Enhancement** (Add simplified version after Context Preservation Protocol):

```markdown
## FOUNDATION REFERENCE PROTOCOL

**Before starting work:**
1. **Check architecture.md** for system design context (if applicable)
2. **Review PRD** for feature requirements and acceptance criteria (if applicable)
3. Verify your work aligns with documented specifications

**When unclear:**
- Escalate to coordinator if foundation context needed but missing
```

**Rationale**: Lower-risk agents still benefit from foundation awareness but need lighter protocol since they don't make primary design decisions.

---

## 3. DELEGATION PROTOCOL ENHANCEMENT (Coordinator)

### 3.1 Delegation Template Enhancement

**Current** (coordinator.md - Task tool delegation example):
```markdown
Task(
  subagent_type="developer",
  prompt="First read agent-context.md and handoff-notes.md for mission context.
          CRITICAL: Follow Critical Software Development Principles.
          [Specific task instructions].
          Update handoff-notes.md with your findings."
)
```

**Enhanced**:
```markdown
Task(
  subagent_type="developer",
  prompt="First read agent-context.md and handoff-notes.md for mission context.

          FOUNDATION ADHERENCE: Review architecture.md (system design), PRD (requirements),
          and ideation.md (product vision) before implementing. Your solution MUST align
          with these specifications. Escalate if foundation docs unclear or missing.

          CRITICAL: Follow Critical Software Development Principles.
          [Specific task instructions].

          VERIFICATION: Confirm your implementation matches architecture.md and PRD requirements.
          Update handoff-notes.md with your findings and any foundation alignment issues."
)
```

**Changes**: Added explicit foundation document reading requirement with escalation instruction, and post-verification requirement.

---

### 3.2 Coordinator Delegation Verification (NEW)

**Add to Coordinator Operational Guidelines**:

```markdown
## FOUNDATION CONTEXT IN DELEGATIONS

**Every Task delegation MUST include:**
1. Explicit instruction to read relevant foundation documents
2. Which specific foundation docs to consult (architecture.md, PRD, ideation.md)
3. Escalation instruction if foundation unclear
4. Verification instruction to confirm alignment

**Template Structure**:
```
Task(
  subagent_type="[agent]",
  prompt="[Context files instruction]

          FOUNDATION ADHERENCE: Review [specific docs] before [action].
          Your solution MUST align with these specifications.
          Escalate if foundation docs unclear or missing.

          [Task instructions]

          VERIFICATION: Confirm alignment with [specific docs].
          [Handoff instruction]"
)
```

**Post-Delegation Verification**:
- When specialist completes task, verify they mentioned foundation docs
- If no foundation verification, ask: "Did you verify this against architecture.md/PRD?"
- Don't mark task complete until foundation alignment confirmed
```

**Rationale**: Coordinator is the enforcement point - must pass foundation context explicitly and verify specialists actually consulted it.

---

## 4. ESCALATION PROTOCOL DESIGN

### 4.1 Escalation Decision Tree

```markdown
## FOUNDATION DOCUMENT ESCALATION PROTOCOL

**When to Escalate** (Immediate coordinator escalation):

1. **Foundation Document Missing**:
   - Symptom: architecture.md or PRD not found in expected locations
   - Action: "Cannot proceed - foundation document [name] required. Checked [locations]."
   - Coordinator Response: Create via dev-setup/dev-alignment or delegate to appropriate specialist

2. **Foundation Document Unclear/Ambiguous**:
   - Symptom: Specification contradictory or insufficient detail
   - Action: "Foundation unclear - [specific ambiguity]. Need clarification before proceeding."
   - Coordinator Response: Clarify with user or delegate to strategist/architect for update

3. **Foundation Documents Conflict**:
   - Symptom: architecture.md conflicts with PRD, or ideation.md contradicts requirements
   - Action: "Foundation conflict detected - [describe conflict]. User decision needed."
   - Coordinator Response: Escalate to user for resolution, update foundation docs

4. **Foundation Document Outdated**:
   - Symptom: Foundation doesn't reflect current system state or decisions
   - Action: "Foundation appears outdated - [specific inconsistency]. Update needed."
   - Coordinator Response: Delegate foundation update to architect/strategist

5. **Task Requires Foundation Change**:
   - Symptom: Implementing task would violate foundation specifications
   - Action: "Task requires architecture change - [describe needed change]. User approval needed?"
   - Coordinator Response: Get user approval for foundation evolution, then update docs

**Escalation Format**:
"🚨 FOUNDATION ESCALATION: [Type]
Foundation Doc: [architecture.md/PRD/ideation.md]
Issue: [Specific problem]
Context: [What you were trying to do]
Attempted: [What you checked]
Needed: [What resolution looks like]"
```

**Rationale**: Clear decision tree prevents agents from improvising when foundation unclear. Mandatory escalation ensures consistency.

---

### 4.2 Coordinator Escalation Handling

**Add to Coordinator's Operational Guidelines**:

```markdown
## HANDLING FOUNDATION ESCALATIONS

**When specialist escalates foundation issue:**

1. **Acknowledge immediately**: "Foundation escalation received. Investigating [issue]."

2. **Assess root cause**:
   - Is foundation doc truly missing or just in unexpected location?
   - Is ambiguity real or does specialist need more context?
   - Is conflict real or misunderstanding of specs?

3. **Resolution paths**:
   - **Missing foundation**: Create via dev-setup/alignment or delegate creation
   - **Unclear foundation**: Clarify from agent-context.md or escalate to user
   - **Conflicting foundation**: User decision required - present conflict clearly
   - **Outdated foundation**: Delegate update to architect/strategist
   - **Foundation evolution needed**: Get user approval, coordinate updates

4. **Update specialist**: Provide resolution, verify understanding, allow work to continue

5. **Document in progress.md**: Log escalation, resolution, prevention strategy

**Never allow specialists to proceed without foundation clarity** - this is critical enforcement point.
```

**Rationale**: Coordinator is the arbiter of foundation adherence - must have clear protocol for handling escalations.

---

## 5. IMPLEMENTATION PLAN (Risk-Based Phasing)

### Phase 1: CRITICAL RISK AGENTS (Implement First)
**Priority**: Highest impact, most likely to deviate
**Agents**: developer, architect, designer, coordinator
**Timeline**: Week 1

**Modifications**:
1. **developer.md**:
   - Add Foundation Document Adherence Protocol (universal section)
   - Enhance Strategic Solution Checklist (items 2, 3, 4, 7)
   - Add foundation verification to Pre-Handoff Checklist
   - Lines changed: ~60 lines added

2. **architect.md**:
   - Add Foundation Document Adherence Protocol (universal section)
   - Enhance Pre-Handoff Checklist (items 1, 2, 7)
   - Add foundation review to Root Cause Analysis protocol
   - Lines changed: ~65 lines added

3. **designer.md**:
   - Add Foundation Document Adherence Protocol (universal section)
   - Add RECON Phase 0.5 (Foundation Verification)
   - Enhance RECON Phase 3 (Visual Inspection brand validation)
   - Lines changed: ~70 lines added

4. **coordinator.md**:
   - Add Foundation Document Adherence Protocol (universal section)
   - Enhance Task Completion Verification (add step 7)
   - Add Delegation Protocol Enhancement section
   - Add Foundation Context in Delegations guidelines
   - Add Handling Foundation Escalations section
   - Lines changed: ~120 lines added

**Validation**: Test with realistic scenarios where agents must consult foundation docs. Verify they actually escalate when unclear.

---

### Phase 2: MODERATE RISK AGENTS (Implement Second)
**Priority**: Medium impact, moderate deviation risk
**Agents**: strategist, marketer, analyst
**Timeline**: Week 2

**Modifications**:
1. **strategist.md**:
   - Add Foundation Document Adherence Protocol (universal section)
   - Add Foundation Review Protocol (before strategic planning)
   - Enhance Pre-Task protocol with ideation.md review
   - Lines changed: ~70 lines added

2. **marketer.md**:
   - Add Foundation Document Adherence Protocol (universal section)
   - Add Foundation Context Protocol (before campaigns)
   - Add brand alignment to Pre-Handoff Checklist
   - Lines changed: ~60 lines added

3. **analyst.md**:
   - Add Foundation Document Adherence Protocol (universal section)
   - Add Foundation Context Protocol (before analysis)
   - Add goal alignment to Pre-Handoff Checklist
   - Lines changed: ~60 lines added

**Validation**: Test strategist creating PRD that conflicts with ideation.md - should escalate. Test marketer with off-brand campaign.

---

### Phase 3: LOWER RISK AGENTS (Implement Third)
**Priority**: Lower impact, less likely to cause architectural drift
**Agents**: tester, documenter, operator, support
**Timeline**: Week 3

**Modifications**:
1. **tester.md**:
   - Add Foundation Document Adherence Protocol (universal section - simplified)
   - Add Foundation Reference Protocol (lightweight)
   - Add PRD verification to Pre-Handoff Checklist
   - Lines changed: ~50 lines added

2. **documenter.md**:
   - Add Foundation Document Adherence Protocol (universal section - simplified)
   - Add Foundation Reference Protocol (lightweight)
   - Lines changed: ~50 lines added

3. **operator.md**:
   - Add Foundation Document Adherence Protocol (universal section - simplified)
   - Add Foundation Reference Protocol (lightweight)
   - Add architecture.md verification for infrastructure decisions
   - Lines changed: ~55 lines added

4. **support.md**:
   - Add Foundation Document Adherence Protocol (universal section - simplified)
   - Add Foundation Reference Protocol (lightweight)
   - Lines changed: ~50 lines added

**Validation**: Test tester validating requirements from PRD. Test documenter writing docs consistent with architecture.

---

### Total Implementation Impact

**Summary**:
- **Agents Modified**: 11 (all library agents)
- **Total Lines Added**: ~780 lines across all agents
- **Average per Agent**: ~71 lines
- **Heaviest Impact**: coordinator.md (+120 lines), designer.md (+70 lines)
- **Lightest Impact**: support.md, tester.md, documenter.md (+50 lines each)

**Backward Compatibility**: 100% - all additions, zero breaking changes. Existing missions continue to work.

**Performance Impact**: Minimal - foundation document reading adds ~5-10 seconds per task (agents already read context files).

---

## 6. STANDARD FOUNDATION DOCUMENT STRUCTURE

### 6.1 What Constitutes Foundation Documents

**Definition**: Foundation documents are authoritative specifications that define WHAT should be built and HOW it should be architected.

**Core Foundation Documents**:
1. **ideation.md** - Product vision, business goals, user needs, constraints
2. **architecture.md** - System design, technology stack, architectural patterns
3. **PRD (Product Requirements Document)** - Feature specifications, acceptance criteria, user stories
4. **product-specs.md** - Brand guidelines, positioning, messaging, design system (optional)

**Not Foundation Documents** (Mission execution files):
- agent-context.md (mission state, accumulated findings)
- handoff-notes.md (task-to-task context)
- evidence-repository.md (artifacts and screenshots)
- project-plan.md (forward-looking task list)
- progress.md (backward-looking changelog)

---

### 6.2 Standard Locations and Discovery

**Primary Locations** (Check first):
```
/architecture.md
/ideation.md
/PRD.md
/product-specs.md
```

**Alternative Locations** (Check if not in root):
```
/docs/architecture.md
/docs/ideation.md
/docs/requirements/PRD.md
/docs/brand/product-specs.md
```

**Discovery Protocol**:
1. Check root directory (`/architecture.md`, etc.)
2. Check `/docs/` subdirectories
3. Check agent-context.md for references to foundation doc locations
4. If still not found, escalate to coordinator

**Missing Foundation Documents**:
- **Greenfield projects** (new): Created during dev-setup mission
- **Brownfield projects** (existing): Created during dev-alignment mission
- **Mid-mission**: Coordinator delegates creation if foundation gaps discovered

---

### 6.3 Foundation Document Lifecycle

**Creation** (When foundation documents are generated):
- **dev-setup mission** (greenfield): Coordinator delegates creation of all foundation docs
- **dev-alignment mission** (brownfield): Architect analyzes codebase, creates architecture.md
- **PRD creation**: Strategist creates/updates PRD based on ideation.md and user requirements

**Updates** (When foundation documents evolve):
- **Architecture decisions**: Architect updates architecture.md when system design changes
- **Requirement changes**: Strategist updates PRD when features added/modified
- **Vision evolution**: User updates ideation.md when product pivot occurs (coordinator facilitates)

**Validation** (When foundation documents are reviewed):
- **Before each mission phase**: Specialists read relevant foundation docs
- **During task execution**: Specialists verify alignment continuously
- **After major changes**: Coordinator triggers foundation doc review

**Archiving** (Foundation documents are NEVER archived):
- Foundation docs are living documents - always current
- Historical versions in git history
- Never "archive and create new" - UPDATE existing docs to maintain continuity

---

## 7. VALIDATION STRATEGY

### 7.1 Functional Testing Scenarios

**Test 1: Developer Deviates from Architecture**
- **Setup**: Create architecture.md specifying REST API architecture
- **Task**: Ask developer to implement feature using GraphQL
- **Expected**: Developer reads architecture.md, escalates conflict before implementing
- **Pass Criteria**: Developer mentions architecture.md and escalates decision to coordinator

**Test 2: Designer Ignores Brand Guidelines**
- **Setup**: Create product-specs.md with specific color palette
- **Task**: Ask designer to create UI with different colors
- **Expected**: Designer reads product-specs.md via RECON Phase 0.5, escalates brand conflict
- **Pass Criteria**: Designer references brand guidelines and requests clarification

**Test 3: Architect Designs Without Foundation Context**
- **Setup**: Create existing architecture.md with microservices approach
- **Task**: Ask architect to design new monolithic architecture
- **Expected**: Architect reads existing architecture.md, notes architectural shift, escalates for approval
- **Pass Criteria**: Architect explicitly reviews existing foundation before proposing changes

**Test 4: Coordinator Delegates Without Foundation Context**
- **Setup**: Foundation docs exist (architecture.md, PRD.md)
- **Task**: Coordinator delegates feature implementation
- **Expected**: Coordinator includes foundation doc references in Task delegation
- **Pass Criteria**: Delegation prompt explicitly mentions which foundation docs to consult

**Test 5: Strategist Creates Conflicting Requirements**
- **Setup**: Create ideation.md with B2B SaaS vision
- **Task**: Ask strategist to create PRD for B2C mobile app
- **Expected**: Strategist reads ideation.md, identifies vision conflict, escalates
- **Pass Criteria**: Strategist references ideation.md and asks for strategic pivot approval

**Test 6: Foundation Document Missing**
- **Setup**: Remove architecture.md from project
- **Task**: Ask architect to design new feature
- **Expected**: Architect attempts to find architecture.md, escalates when missing
- **Pass Criteria**: Architect escalates with specific escalation format

**Test 7: Marketer Creates Off-Brand Campaign**
- **Setup**: Create product-specs.md with formal B2B messaging
- **Task**: Ask marketer to create casual social media campaign
- **Expected**: Marketer reads product-specs.md, identifies tone mismatch, escalates or adjusts
- **Pass Criteria**: Marketer references brand guidelines in campaign strategy

---

### 7.2 Edge Case Testing

**Edge Case 1: Foundation Documents in Non-Standard Location**
- Test discovery protocol when docs in `/docs/architecture/` instead of root

**Edge Case 2: Multiple PRDs Exist**
- Test handling when both `/PRD.md` and `/docs/requirements/PRD-v2.md` present

**Edge Case 3: Foundation Documents Outdated**
- Test agent recognizing architecture.md doesn't match current codebase state

**Edge Case 4: Foundation Documents Conflict**
- Test escalation when PRD requirements violate architecture.md constraints

**Edge Case 5: Mid-Mission Foundation Creation**
- Test specialist requesting foundation doc creation when none exists

---

### 7.3 Success Metrics

**Quantitative Metrics**:
- **Foundation Reading Rate**: % of tasks where agent mentions reading foundation docs (Target: >90%)
- **Escalation Rate**: % of foundation conflicts that get escalated vs improvised (Target: 100%)
- **Alignment Verification**: % of Pre-Handoff Checklists with foundation verification marked (Target: >95%)
- **False Escalations**: % of escalations that were actually non-issues (Target: <10%)

**Qualitative Metrics**:
- User reports of architectural drift (Target: 0 reports)
- User reports of off-spec implementations (Target: 0 reports)
- Agent confidence in foundation adherence (Target: High)
- Coordinator burden of foundation enforcement (Target: Low - automated via protocol)

---

## 8. DOCUMENTATION REQUIREMENTS

### 8.1 Field Manual Update

**New Section**: `/project/field-manual/foundation-adherence-guide.md`

**Contents**:
1. Why Foundation Documents Matter (user-facing explanation)
2. Foundation Document Structure (what each doc contains)
3. Creating Foundation Documents (dev-setup/dev-alignment)
4. Updating Foundation Documents (when and how)
5. Agent Foundation Adherence (how agents use foundation docs)
6. Troubleshooting (when agents escalate foundation issues)

---

### 8.2 Mission Documentation Update

**Update**: `/project/missions/dev-setup.md` and `/project/missions/dev-alignment.md`

**Add Foundation Creation Steps**:
- dev-setup: Explicitly create all 4 foundation documents
- dev-alignment: Analyze and document existing architecture, create missing foundations

---

### 8.3 CLAUDE.md Update

**Add Section**: "Foundation Document System"

**Contents**:
- Overview of foundation document hierarchy
- When agents must consult foundation docs
- Escalation protocol for foundation issues
- Foundation document lifecycle

---

## 9. RISK MITIGATION

### 9.1 Implementation Risks

**Risk 1: Agents Over-Escalate (False Positives)**
- **Mitigation**: Clear escalation decision tree, examples of when NOT to escalate
- **Fallback**: Coordinator coaching via handoff-notes.md when over-escalation observed

**Risk 2: Foundation Document Reading Slows Tasks**
- **Mitigation**: Agents read foundation docs once per mission, reference in memory
- **Fallback**: Foundation summary in agent-context.md for quick reference (but NOT substitute)

**Risk 3: Users Don't Create Foundation Documents**
- **Mitigation**: dev-setup/dev-alignment automatically create foundations
- **Fallback**: Agents escalate immediately if foundations missing, blocking work until created

**Risk 4: Foundation Documents Become Stale**
- **Mitigation**: Agents flag outdated foundations during verification
- **Fallback**: Coordinator delegates foundation updates when staleness detected

**Risk 5: Breaking Existing Missions**
- **Mitigation**: All changes are additive, zero breaking changes
- **Fallback**: Existing missions continue working, new protocol applies to future work

---

### 9.2 Rollback Plan

**If Implementation Fails**:
1. **Identify**: Which agents are over-escalating or blocking work inappropriately
2. **Adjust**: Soften mandatory language to optional ("SHOULD" vs "MUST")
3. **Iterate**: Keep protocol but reduce enforcement strictness
4. **Fallback**: Revert to context-file-only approach (current state)

**Rollback Triggers**:
- >30% false escalation rate (agents blocking work unnecessarily)
- >50% user complaints about agent rigidity
- Coordinator overwhelmed with foundation escalations (>10 per mission)

---

## 10. LONG-TERM EVOLUTION

### 10.1 Future Enhancements (Post-Implementation)

**Enhancement 1: Foundation Document Validation Tool**
- Automated tool to check foundation document completeness
- Flags missing sections, outdated content, conflicts
- Runs during dev-setup/dev-alignment

**Enhancement 2: Foundation Document Templates**
- Structured templates for architecture.md, PRD, ideation.md
- Ensures consistency across projects
- Available in `/templates/` directory

**Enhancement 3: Foundation Diff Detection**
- Agents automatically detect when foundation docs changed since last read
- Prompt to re-review updated sections before proceeding

**Enhancement 4: Foundation Document Caching**
- Memory tool integration to cache foundation doc summaries
- Reduces reading burden while maintaining source-of-truth integrity

---

### 10.2 Success Indicators (Post-Launch)

**Within 1 Month**:
- Zero user reports of architectural drift
- >80% of tasks include foundation document references
- Escalation protocol used correctly (low false positive rate)

**Within 3 Months**:
- Foundation adherence becomes habitual (agents don't need reminders)
- Foundation documents routinely updated (living docs, not static)
- Users trust agents to maintain consistency

**Within 6 Months**:
- Foundation adherence protocol considered core AGENT-11 feature
- User testimonials about product consistency and architectural integrity
- Foundation protocol copied by other AI agent frameworks

---

## HANDOFF TO DEVELOPER

### Implementation Checklist

**Phase 1 (Week 1) - Critical Risk Agents**:
- [ ] Implement Foundation Document Adherence Protocol in developer.md
- [ ] Enhance Strategic Solution Checklist in developer.md
- [ ] Implement Foundation Document Adherence Protocol in architect.md
- [ ] Enhance Pre-Handoff Checklist in architect.md
- [ ] Implement Foundation Document Adherence Protocol in designer.md
- [ ] Add RECON Phase 0.5 and enhance Phase 3 in designer.md
- [ ] Implement Foundation Document Adherence Protocol in coordinator.md
- [ ] Enhance Task Completion Verification in coordinator.md
- [ ] Add Delegation Protocol Enhancement to coordinator.md
- [ ] Add Foundation Context in Delegations to coordinator.md
- [ ] Add Handling Foundation Escalations to coordinator.md

**Phase 2 (Week 2) - Moderate Risk Agents**:
- [ ] Implement Foundation Document Adherence Protocol in strategist.md
- [ ] Add Foundation Review Protocol to strategist.md
- [ ] Implement Foundation Document Adherence Protocol in marketer.md
- [ ] Add Foundation Context Protocol to marketer.md
- [ ] Implement Foundation Document Adherence Protocol in analyst.md
- [ ] Add Foundation Context Protocol to analyst.md

**Phase 3 (Week 3) - Lower Risk Agents**:
- [ ] Implement simplified Foundation Document Adherence Protocol in tester.md
- [ ] Implement simplified Foundation Document Adherence Protocol in documenter.md
- [ ] Implement simplified Foundation Document Adherence Protocol in operator.md
- [ ] Implement simplified Foundation Document Adherence Protocol in support.md

**Validation**:
- [ ] Run all 7 functional test scenarios
- [ ] Test all 5 edge cases
- [ ] Measure foundation reading rate (target >90%)
- [ ] Verify escalation protocol works correctly

**Documentation**:
- [ ] Create foundation-adherence-guide.md in field-manual
- [ ] Update dev-setup.md with foundation creation steps
- [ ] Update dev-alignment.md with foundation creation steps
- [ ] Update CLAUDE.md with foundation document system overview

### Key Files with Line-by-Line Insertions

**All protocol text above is ready for copy-paste insertion.**

Exact insertion points:
1. **Universal Protocol**: Insert after "CONTEXT PRESERVATION PROTOCOL" section in all agents
2. **Verification Enhancements**: Replace/enhance existing checklist sections with enhanced versions
3. **Delegation Enhancement**: Insert in coordinator.md operational guidelines section
4. **Escalation Protocol**: Insert in coordinator.md after delegation protocols

### Critical Implementation Notes

1. **Mandatory Language Consistency**: Use exact same imperatives ("MUST", "ALWAYS", "REQUIRED") as context preservation protocol
2. **Insertion Order**: Add Universal Protocol FIRST, then verification enhancements - ensures foundation protocol visible before checklists reference it
3. **Testing Priority**: Phase 1 agents MUST be tested first - they're the primary deviation vectors
4. **Backward Compatibility**: All changes additive - existing missions unaffected

---

## DESIGN RATIONALE SUMMARY

**Why This Works**:
1. **Mirrors Proven Pattern**: Uses exact structure as context preservation protocol (100% adoption rate)
2. **Mandatory Language**: Clear imperatives prevent ambiguity ("MUST read", "Verify alignment")
3. **Multi-Layer Enforcement**: Protocol + Checklists + Delegation + Escalation = comprehensive coverage
4. **Risk-Based Phasing**: Highest-impact agents first, ensures critical gaps closed immediately
5. **Clear Escalation Path**: Agents know exactly when and how to escalate unclear foundations
6. **Coordinator as Arbiter**: Central enforcement point prevents coordination chaos
7. **Lightweight for Low-Risk**: Doesn't burden agents that don't make primary design decisions

**Why It Won't Fail**:
1. **No improvisation allowed**: Explicit escalation protocol eliminates "agent makes something up"
2. **Source-of-truth hierarchy**: Foundation docs > context files prevents drift
3. **Verification at every stage**: Pre-task, during-task, post-task checks
4. **Coordinator oversight**: Every task completion verified for foundation alignment
5. **Clear discovery protocol**: Agents know exactly where to find foundation docs

**Expected Outcome**:
- 0% architectural drift (down from current user-reported issues)
- >90% foundation reading rate (up from current 0% explicit reading)
- 100% escalation compliance (agents escalate instead of improvise)
- User confidence restored in agent consistency and spec adherence

---

**Design Complete**: 2025-11-09
**Status**: Ready for developer implementation
**Next Agent**: @developer (implement Phase 1 first, validate, then Phases 2-3)
