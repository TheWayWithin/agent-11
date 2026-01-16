# Foundations Enhancement Sprint

**Sprint Goal**: Fix ModelOptix prd.yaml quality issues AND enhance /foundations command to prevent similar issues in future extractions.

**Created**: 2026-01-16
**Updated**: 2026-01-16 (Added BOS-AI review findings)
**Status**: Draft - Pending Approval

---

## Executive Summary

This sprint addresses quality issues discovered during prd.yaml review for ModelOptix. The work has two tracks:
1. **Immediate Fix**: Correct the ModelOptix prd.yaml file
2. **Systemic Improvement**: Enhance /foundations command to generate better YAML for ALL document types

**Key Insight**: The /foundations command lacks schema enforcement validation. It extracts content well but doesn't verify the output matches the expected schema structure.

### Analysis Sources

This sprint incorporates findings from two independent reviews:

| Reviewer | Focus | Key Findings |
|----------|-------|--------------|
| **AGENT-11 Coordinator** | Schema compliance, structure | Schema mismatch, missing glossary, acceptance criteria |
| **BOS-AI Project Agent** | Domain completeness | Missing entities, privacy requirements, tier success criteria |

**Agreement on High-Priority Items**:
- State machines (both flagged as critical)
- Missing business rules BR-015-018, BR-024-028
- Edge cases and testing sections
- Integration test scenarios

---

## Phase 1: Fix ModelOptix prd.yaml (Immediate Value)

### Objective
Produce a corrected prd.yaml that follows the schema and includes all missing sections.

### Tasks

#### 1.1 Restructure to Match Schema
- [ ] Rename `problem_statement` → `problem` with correct sub-fields
- [ ] Restructure `target_users` → `users` array format
- [ ] Restructure `features` to use flat `p0_must_have`, `p1_should_have` arrays
- [ ] Add missing `phases` array from milestones/roadmap data

**Acceptance**: YAML validates against `foundation-prd.schema.yaml`

#### 1.2 Add Missing Glossary Section
- [ ] Extract all 12 terms from Section 2.1 Glossary
- [ ] Format as array of `{term, definition}` objects
- [ ] Add to prd.yaml under new `glossary` key

**Source**: PRD Section 2.1 - Product, Function, Use Case, Model, Model Maker, Provider, Capability, Trust Score, Trust Dimension, Recommendation, Opportunity, Savings, Savings to Date, Sanity Check, Alert, Portfolio

#### 1.3 Add State Machines (HIGH PRIORITY - Both Reviews)
- [ ] Extract Subscription State Machine (6 states, 10 transitions)
- [ ] Extract Opportunity State Machine (5 states, 6 transitions)
- [ ] Extract Product/Function State Machine (3 states, 4 transitions)
- [ ] Format as structured YAML with states, transitions, descriptions

**Schema addition needed**: `state_machines` array

**Why Critical**: Developers need these to implement correct status transitions. Without them, they'll have to dig through the PRD.

#### 1.4 Extract Feature Acceptance Criteria
- [ ] For each P0 feature (F-001 to F-023), extract Given/When/Then criteria
- [ ] For each P1 feature (F-024 to F-035), extract Given/When/Then criteria
- [ ] Add `acceptance_criteria` array to each feature
- [ ] Add `touched_entities` array to each feature

**Example**:
```yaml
- id: "F-011"
  name: "Run Sanity Check"
  priority: "P0"
  user_story: "As a user, I want to test my prompts..."
  acceptance_criteria:
    - "Given I'm on Opportunity Detail, When I click 'Run Sanity Check', Then I see a prompt input form"
    - "Given I've run sanity checks before, When the form loads, Then I see my previous prompts available for reuse"
    # ... all 9 criteria
  touched_entities: ["SanityCheck", "Opportunity", "UseCase", "UsageTracking"]
```

#### 1.5 Add Critical User Journeys
- [ ] Extract all 13 user journeys from Section 4.2
- [ ] Include features involved and success criteria
- [ ] Format as `critical_journeys` array

**Journeys to extract**:
1. New User → First Savings
2. Trial → Paid Conversion
3. Upgrade/Downgrade
4. Trust Investigation
5. Model Discovery
6. Alert Response
7. Account Deletion
8. Proactive Opportunity Review
9. Update Use Case
10. Add New Feature
11. No Opportunities Found
12. Billing Issue Resolution
13. Recommendation Rejection

**Schema addition needed**: `critical_journeys` array

#### 1.6 Add Edge Cases & Boundary Conditions
- [ ] Extract tier limit edge cases (8 scenarios)
- [ ] Extract tier feature restriction cases (4 scenarios)
- [ ] Extract auth edge cases (8 scenarios)
- [ ] Extract payment edge cases (14 scenarios)
- [ ] Extract data edge cases (10 scenarios)
- [ ] Format as `edge_cases` object with categories

**Schema addition needed**: `edge_cases` object

#### 1.7 Complete Business Rules (Both Reviews)
- [ ] Add missing rules BR-015 to BR-018 (downgrade behavior):
  - BR-015: Downgrade impact display and freeze logic
  - BR-016: Frozen products behavior (read-only, no new opportunities)
  - BR-017: Re-upgrade instant restoration
  - BR-018: Cancelled subscription grace period
- [ ] Add missing rules BR-024 to BR-028 (alert rules):
  - BR-024: Free tier weekly digest only
  - BR-025: Paid tier real-time alerts
  - BR-026: Alert types
  - BR-027: User preference configuration
  - BR-028: Alert read marking
- [ ] Add enforcement location to each rule (Backend, Frontend, Stripe, Policy)

#### 1.8 Add Integration Test Scenarios
- [ ] Extract OAuth test scenarios (7 scenarios)
- [ ] Extract Payment/Stripe scenarios (7 scenarios)
- [ ] Extract LLM API scenarios (4 scenarios)
- [ ] Extract Webhook scenarios (3 scenarios)
- [ ] Extract Email scenarios (2 scenarios)
- [ ] Extract Compliance validation scenarios (12 scenarios)

**Schema addition needed**: `integration_tests` array

#### 1.9 Add Missing Data Model Entities (BOS-AI Finding)
- [ ] Add `PromotionCode` entity (referenced in F-035)
  - Attributes: id, code, discount_type, discount_amount, applicable_tiers, usage_limit, per_user_limit, expiration_date, minimum_commitment, status, created_at
- [ ] Add `AuditLog` entity (referenced in admin features F-031, F-032, F-033, F-034)
  - Attributes: id, admin_id, action, affected_entity_type, affected_entity_id, previous_value, new_value, timestamp
- [ ] Add `Session` entity (referenced in F-020)
  - Attributes: id, user_id, device, location, ip_address, last_active, created_at

#### 1.10 Add Additional Privacy & Compliance Requirements (BOS-AI Finding)
- [ ] Add Prompt Data Disclosure warning requirement
  - "Your prompt will be sent to [provider]. Do not include PII or sensitive data."
  - User must acknowledge before Sanity Check
- [ ] Add Third-party LLM Data Processing DPAs requirement
  - Maintain DPAs with LLM providers (OpenAI, Anthropic, etc.)
  - Document in Privacy Policy which providers receive prompt data
- [ ] Add Portfolio Data Confidentiality classification
  - Classify as confidential
  - Never share, sell, or use for marketing
  - State explicitly in Privacy Policy
- [ ] Add Trust Score Disclaimer requirement
  - Terms of Service: "Trust scores are ModelOptix assessments based on available data. They are not guarantees."
- [ ] Add Admin Audit Logging requirement
  - Log all admin actions: who, what, when, affected user
  - Retain logs for 2 years

#### 1.11 Add Success Criteria by Tier (BOS-AI Finding)
- [ ] Extract Free tier success indicators:
  - First product added within 1 hour: 70%
  - Upgrades to paid within 60 days: 15%
  - Reactivation to paid within 180 days: 20%
- [ ] Extract Solo tier success indicators:
  - Trust Dashboard view (monthly active): 70%
  - Sanity check used in first 30 days: 60%
  - Upgrades to Growth within 90 days: 12%
  - 12-month retention rate: 75%
- [ ] Extract Growth tier success indicators:
  - Week 1 payback achieved: 80%
  - Acted on recommendation monthly: 50%
  - Upgrades to Pro within 6 months: 10%
  - 12-month retention rate: 85%
- [ ] Extract Pro tier success indicators:
  - Renewal rate: 90%+
  - Expansion (team members - future): 20% in Year 2

### Phase 1 Deliverables
- [ ] Updated `/Users/jamiewatters/DevProjects/ModelOptix/.context/structured/prd.yaml`
- [ ] Schema validation passes
- [ ] All 36 features have acceptance criteria (24 P0 + 12 P1)
- [ ] State machines documented (3 machines)
- [ ] Edge cases documented (~44 scenarios)
- [ ] Business rules complete (30 rules)
- [ ] All entities documented (including PromotionCode, AuditLog, Session)
- [ ] Privacy/compliance requirements complete
- [ ] Success criteria by tier documented

---

## Phase 2: Update PRD Schema (Enable Rich Extraction)

### Objective
Extend `foundation-prd.schema.yaml` to support the additional sections discovered in comprehensive PRDs.

### Tasks

#### 2.1 Add Glossary Schema Section
```yaml
glossary:
  type: array
  description: "Domain-specific terms and definitions"
  items:
    type: object
    required: [term, definition]
    properties:
      term:
        type: string
      definition:
        type: string
      aliases:
        type: array
        items:
          type: string
```

#### 2.2 Add State Machines Schema Section
```yaml
state_machines:
  type: array
  description: "System state machines for key entities"
  items:
    type: object
    required: [name, entity, states, transitions]
    properties:
      name:
        type: string
      entity:
        type: string
        description: "Entity this state machine applies to"
      states:
        type: array
        items:
          type: object
          properties:
            name:
              type: string
            description:
              type: string
      transitions:
        type: array
        items:
          type: object
          properties:
            from:
              type: string
            to:
              type: string
            trigger:
              type: string
            description:
              type: string
```

#### 2.3 Add Critical Journeys Schema Section
```yaml
critical_journeys:
  type: array
  description: "End-to-end user journeys for testing"
  items:
    type: object
    required: [name, features_involved, success_criteria]
    properties:
      name:
        type: string
      description:
        type: string
      features_involved:
        type: array
        items:
          type: string
        description: "Feature IDs (e.g., 'F-001', 'F-004')"
      success_criteria:
        type: string
```

#### 2.4 Add Edge Cases Schema Section
```yaml
edge_cases:
  type: object
  description: "Boundary conditions and edge case scenarios"
  properties:
    tier_limits:
      type: array
      items:
        type: object
        properties:
          scenario:
            type: string
          expected_behavior:
            type: string
    tier_features:
      type: array
      items:
        $ref: "#/properties/edge_cases/properties/tier_limits/items"
    authentication:
      type: array
      items:
        $ref: "#/properties/edge_cases/properties/tier_limits/items"
    payment:
      type: array
      items:
        $ref: "#/properties/edge_cases/properties/tier_limits/items"
    data:
      type: array
      items:
        $ref: "#/properties/edge_cases/properties/tier_limits/items"
```

#### 2.5 Add Integration Tests Schema Section
```yaml
integration_tests:
  type: array
  description: "Integration test scenarios by external system"
  items:
    type: object
    required: [integration, scenarios]
    properties:
      integration:
        type: string
        description: "External system (OAuth, Stripe, LLM API, etc.)"
      scenarios:
        type: array
        items:
          type: object
          properties:
            name:
              type: string
            success_criteria:
              type: string
```

#### 2.6 Enhance Feature Schema
Add to existing feature item schema:
```yaml
acceptance_criteria:
  type: array
  description: "Given/When/Then acceptance criteria"
  items:
    type: string
touched_entities:
  type: array
  description: "Data model entities affected by this feature"
  items:
    type: string
```

#### 2.7 Add Success Criteria by Tier Schema Section (NEW)
```yaml
success_criteria_by_tier:
  type: object
  description: "Tier-specific success indicators and targets"
  properties:
    free:
      type: array
      items:
        type: object
        properties:
          indicator:
            type: string
          target:
            type: string
          timeframe:
            type: string
    solo:
      type: array
      items:
        $ref: "#/properties/success_criteria_by_tier/properties/free/items"
    growth:
      type: array
      items:
        $ref: "#/properties/success_criteria_by_tier/properties/free/items"
    pro:
      type: array
      items:
        $ref: "#/properties/success_criteria_by_tier/properties/free/items"
```

#### 2.8 Add Additional Compliance Schema Section (NEW)
```yaml
additional_compliance:
  type: object
  description: "Privacy and compliance requirements beyond basic GDPR/CCPA"
  properties:
    prompt_data_disclosure:
      type: object
      properties:
        warning_text:
          type: string
        acknowledgment_required:
          type: boolean
    third_party_data_processing:
      type: array
      description: "DPA requirements with external providers"
      items:
        type: object
        properties:
          provider_type:
            type: string
          requirement:
            type: string
          documentation:
            type: string
    data_confidentiality:
      type: array
      items:
        type: object
        properties:
          data_type:
            type: string
          classification:
            type: string
          restrictions:
            type: array
            items:
              type: string
    disclaimers:
      type: array
      items:
        type: object
        properties:
          name:
            type: string
          text:
            type: string
          location:
            type: string
    audit_logging:
      type: object
      properties:
        required:
          type: boolean
        what_to_log:
          type: array
          items:
            type: string
        retention_period:
          type: string
```

### Phase 2 Deliverables
- [ ] Updated `project/schemas/foundation-prd.schema.yaml`
- [ ] Schema is backwards compatible (new fields optional)
- [ ] Schema includes comments explaining each section
- [ ] New sections: glossary, state_machines, critical_journeys, edge_cases, integration_tests, success_criteria_by_tier, additional_compliance

---

## Phase 3: Enhance /foundations Command (Systemic Fix)

### Objective
Improve /foundations command to generate schema-compliant, complete YAML for ALL document types.

### Tasks

#### 3.1 Add Schema Validation Step (ALL DOCUMENT TYPES)
After extraction, validate output against schema:
```
For each extracted YAML:
1. Load corresponding schema from project/schemas/
2. Validate YAML structure against schema
3. Report missing required fields
4. Report incorrect field types
5. FAIL extraction if validation fails (don't silently produce bad output)
```

**Implementation location**: `project/commands/foundations.md` - Add Phase 3.5 between extraction and manifest generation

#### 3.2 Add Output Structure Enforcement (ALL DOCUMENT TYPES)
Update extraction prompts to explicitly require schema-compliant output:
```
CRITICAL: Your output MUST match this exact schema structure.

Schema: {include actual schema YAML}

DO NOT invent new field names.
DO NOT change nesting structure.
USE the exact field names from the schema.
```

#### 3.3 Enhance PRD Extraction Prompt
Add to the PRD extraction template in foundations.md:

```
ADDITIONAL PRD EXTRACTION RULES:

6. GLOSSARY - Extract ALL defined terms:
   - Look for "Glossary" section or term definitions
   - Extract term, definition, and any aliases
   - Format as glossary array

7. STATE MACHINES - Extract ALL state diagrams:
   - Look for state machine diagrams (ASCII or described)
   - Extract states with descriptions
   - Extract transitions with triggers
   - Common entities: Subscription, Order, User, Opportunity, Product

8. ACCEPTANCE CRITERIA - For EACH feature:
   - Extract ALL Given/When/Then statements
   - These are in "Acceptance Criteria" subsections
   - Count criteria in source, verify count in output

9. CRITICAL JOURNEYS - Extract end-to-end flows:
   - Look for "User Journey" or "Critical Path" sections
   - Extract journey name, involved features, success criteria

10. EDGE CASES - Extract boundary conditions:
    - Look for "Edge Cases" or "Boundary Conditions" sections
    - Group by category (tier_limits, tier_features, auth, payment, data)
    - Include scenario AND expected behavior

11. INTEGRATION TESTS - Extract external system tests:
    - Look for "Integration Test" sections
    - Group by integration (OAuth, Stripe, LLM, Webhooks, Email)
    - Include scenario AND success criteria

12. DATA MODEL COMPLETENESS - Verify ALL entities:
    - Check for entities mentioned in features but not in data_model
    - Common missing: PromotionCode, AuditLog, Session
    - Add any missing entities with attributes

13. ADDITIONAL COMPLIANCE - Extract beyond GDPR/CCPA:
    - Prompt data disclosure requirements
    - Third-party DPA requirements
    - Data confidentiality classifications
    - Disclaimer requirements
    - Audit logging requirements

14. SUCCESS CRITERIA BY TIER - Extract tier-specific metrics:
    - Look for "Success Criteria by Tier" or similar sections
    - Extract indicators, targets, and timeframes per tier
```

#### 3.4 Add Completeness Metrics (ALL DOCUMENT TYPES)
Enhance validation output to show completeness metrics:

```
EXTRACTION VALIDATION REPORT
============================
Document: ModelOptix-Core-PRD-FINAL.md
Category: prd
Mode: COMPLETENESS MODE

Schema Compliance:
  Required fields: 15/15 present ✅
  Optional fields: 18/22 present
  Unknown fields: 0 (no extras)

Content Metrics:
  Features extracted: 36 (24 P0 + 12 P1)
  Acceptance criteria: 156 total
  Business rules: 30
  State machines: 3
  Edge cases: 44
  Integration tests: 35
  Data model entities: 15
  Glossary terms: 12

List Completeness:
  Source lists: 52 → Output lists: 52 ✅

Status: PASS
```

#### 3.5 Add Schema Reference Loading
Update foundations.md to explicitly load and include schema in extraction prompt:

```bash
# Before extraction, load the schema
schema_content=$(cat project/schemas/foundation-{category}.schema.yaml)

# Include in extraction prompt
"Your output MUST conform to this schema:
$schema_content"
```

#### 3.6 Add Post-Extraction Diff Report
After extraction, show what was captured vs. what might be missing:

```
EXTRACTION COVERAGE REPORT
==========================

Sections Found & Extracted:
  ✅ Product Foundation (Section 1)
  ✅ System Skeleton (Section 2)
  ✅ Features & Requirements (Section 3)
  ✅ Testing & Validation (Section 4)
  ✅ Roadmap & Milestones (Section 5)
  ✅ Metrics & Success (Section 6)
  ✅ Handoff Readiness (Section 7)

Potential Gaps Detected:
  ⚠️ Found "Glossary" heading but no glossary in output
  ⚠️ Found "State Machine" content but no state_machines in output
  ⚠️ Found entities in features not in data_model: PromotionCode, AuditLog

Recommendation: Review source sections 2.1, 2.4, and feature touched_entities
```

#### 3.7 Add Entity Cross-Reference Check (NEW)
Verify all entities mentioned in features exist in data_model:

```
ENTITY CROSS-REFERENCE CHECK
============================

Entities in data_model: 12
Entities referenced in features (touched_entities): 15

Missing from data_model:
  ❌ PromotionCode (referenced in F-035)
  ❌ AuditLog (referenced in F-031, F-032, F-033, F-034)
  ❌ Session (referenced in F-020)

Action Required: Add missing entities to data_model section
```

### Phase 3 Deliverables
- [ ] Updated `project/commands/foundations.md` with enhanced extraction
- [ ] Schema validation step added
- [ ] Completeness metrics in validation output
- [ ] Coverage report shows extraction gaps
- [ ] Entity cross-reference check added
- [ ] Additional compliance extraction rules added

---

## Phase 4: Update Other Schemas (Quality Parity)

### Objective
Review and enhance other foundation schemas to match PRD schema quality.

### Tasks

#### 4.1 Review ICP Schema
- [ ] Verify persona extraction captures ALL fields
- [ ] Add anti-persona section if missing
- [ ] Add pain point severity levels
- [ ] Add jobs-to-be-done structure

#### 4.2 Review Pricing Schema
- [ ] Verify Marketing Physics extraction at tier level
- [ ] Add upgrade triggers section
- [ ] Add competitive comparison structure
- [ ] Add objection handling section

#### 4.3 Review Roadmap Schema
- [ ] Verify deliverables_list expansion works
- [ ] Add milestone dependencies section
- [ ] Add success_criteria array format

#### 4.4 Review Brand Schema
- [ ] Verify neutrals scale extraction
- [ ] Verify shadows/animations defaults added
- [ ] Add component state specifications

### Phase 4 Deliverables
- [ ] Updated schemas in `project/schemas/`
- [ ] Each schema has comments explaining fields
- [ ] Schemas tested against sample documents

---

## Phase 5: Validation & Testing

### Objective
Verify all improvements work correctly on real documents.

### Tasks

#### 5.1 Test Fixed ModelOptix prd.yaml
- [ ] Run schema validation
- [ ] Verify all sections present
- [ ] Manual review for accuracy
- [ ] Verify entity cross-references complete

#### 5.2 Test /foundations refresh on ModelOptix
- [ ] Run `/foundations refresh` on ModelOptix project
- [ ] Verify improved extraction quality
- [ ] Compare before/after
- [ ] Verify completeness metrics accurate

#### 5.3 Test on Second Project (if available)
- [ ] Run `/foundations init` on another project
- [ ] Verify schema compliance
- [ ] Verify completeness metrics
- [ ] Verify coverage report accuracy

#### 5.4 Update Documentation
- [ ] Update /foundations command help text
- [ ] Add troubleshooting for common extraction issues
- [ ] Document new schema fields
- [ ] Add examples of well-extracted PRDs

### Phase 5 Deliverables
- [ ] All tests pass
- [ ] Documentation updated
- [ ] Ready for general use

---

## Success Criteria

### Immediate (Phase 1)
- [ ] ModelOptix prd.yaml validates against schema
- [ ] All 36 features have acceptance criteria extracted
- [ ] State machines documented (3)
- [ ] Glossary terms documented (12)
- [ ] Edge cases documented (~44 scenarios)
- [ ] Business rules complete (30)
- [ ] All entities documented (15 including PromotionCode, AuditLog, Session)
- [ ] Additional compliance requirements documented
- [ ] Success criteria by tier documented (4 tiers)

### Systemic (Phases 2-4)
- [ ] /foundations command validates output against schema
- [ ] Extraction prompts reference schema structure
- [ ] Completeness metrics reported after extraction
- [ ] Coverage report detects gaps
- [ ] Entity cross-reference check catches missing entities
- [ ] All foundation schemas reviewed and enhanced

### Quality Gates
- [ ] Zero schema validation errors on extraction
- [ ] 95%+ content preservation (list counts match)
- [ ] Coverage report shows no "potential gaps"
- [ ] Entity cross-reference shows no missing entities

---

## Estimated Effort

| Phase | Tasks | Complexity | Notes |
|-------|-------|------------|-------|
| Phase 1 | 11 | Medium | Manual YAML work, most critical |
| Phase 2 | 8 | Low | Schema additions |
| Phase 3 | 7 | High | Core command changes |
| Phase 4 | 4 | Medium | Schema reviews |
| Phase 5 | 4 | Low | Testing |

**Total**: 34 tasks

**Recommended approach**:
1. Phase 1 first (immediate value for ModelOptix)
2. Phases 2-3 in parallel (schema + command)
3. Phase 4-5 after core changes stable

---

## Cross-Reference: Issue Sources

| Issue | Coordinator | BOS-AI | Priority |
|-------|-------------|--------|----------|
| Schema non-compliance | ✅ | - | High |
| State machines missing | ✅ | ✅ | **Critical** |
| BR-015 to BR-018 missing | ✅ | ✅ | High |
| BR-024 to BR-028 missing | ✅ | ✅ | High |
| Glossary missing | ✅ | - | Medium |
| Acceptance criteria missing | ✅ | - | High |
| Critical journeys missing | ✅ | - | Medium |
| Edge cases missing | ✅ | ✅ | High |
| Integration tests missing | ✅ | ✅ | Medium |
| PromotionCode entity missing | - | ✅ | Medium |
| AuditLog entity missing | - | ✅ | Medium |
| Session entity missing | - | ✅ | Medium |
| Additional privacy requirements | ⚠️ Partial | ✅ | Medium |
| Success criteria by tier | - | ✅ | Low |
| Milestone dependencies | ✅ | ✅ | Low |

**Legend**: ✅ = Found, ⚠️ = Partial, - = Not found

---

## Approval Checklist

Before starting execution:

- [ ] Sprint scope approved (all 5 phases)
- [ ] Schema changes approved (backwards compatible)
- [ ] Validation strictness decided (FAIL vs WARN)
- [ ] Execution order confirmed (Phase 1 first)
