# Creating Custom Missions 🚀

## Overview

While AGENT-11 provides core missions for common scenarios, you can create custom missions tailored to your specific workflows, industry needs, or unique processes. This guide shows you how to design and implement your own missions.

## Mission Anatomy

Every mission consists of:

1. **Mission Metadata** - Code, duration, complexity, squad
2. **Mission Briefing** - Clear objective and context
3. **Required Inputs** - Documents and context needed
4. **Mission Phases** - Step-by-step execution plan
5. **Success Criteria** - Measurable completion markers
6. **Coordination Notes** - Process guidance

## Creating Your First Mission

### Step 1: Identify the Need

Ask yourself:
- What repetitive multi-agent workflow do I have?
- What complex process needs standardization?
- What would benefit from systematic execution?

### Step 2: Design the Mission

Use the template at `/templates/mission-template.md`:

```bash
cp templates/mission-template.md missions/mission-[yourname].md
```

### Step 3: Define Mission Metadata

```markdown
**Mission Code**: LAUNCH  
**Estimated Duration**: 4-6 hours  
**Complexity**: High  
**Squad Required**: Strategist, Marketer, Developer, Analyst
```

Choose:
- **Code**: Short, memorable (4-8 letters)
- **Duration**: Realistic estimates
- **Complexity**: Low/Medium/High
- **Squad**: Only essential agents

### Step 4: Write Mission Briefing

Be clear and compelling:

```markdown
## Mission Briefing

Launch a new product feature with coordinated marketing, 
technical deployment, and analytics tracking. This mission 
ensures synchronized release across all channels with 
proper measurement and rollback capabilities.
```

### Step 5: Define Required Inputs

```markdown
## Required Inputs

1. **Feature Specification** (required) - What's being launched
2. **Marketing Plan** (required) - Launch messaging and channels
3. **Target Metrics** (optional) - Success measurement criteria
```

### Step 6: Design Mission Phases

Each phase needs:
- Clear owner (Lead agent)
- Time estimate
- Specific objectives
- Concrete deliverables

Example phase:

```markdown
### Phase 1: Launch Preparation (1 hour)

**Lead**: @marketer  
**Support**: @strategist  
**Objective**: Prepare all launch materials

\`\`\`bash
@marketer Create launch materials:
1. Write announcement blog post
2. Create social media content calendar
3. Design email campaign
4. Prepare press release
5. Set up landing page
\`\`\`

**Deliverables**:
- Blog post draft
- Social media assets
- Email templates
- Press release
- Landing page
```

### Step 7: Define Success Criteria

Make them measurable:

```markdown
## Success Criteria

- [ ] Feature deployed to production
- [ ] All marketing materials published
- [ ] Analytics tracking verified
- [ ] Team notifications sent
- [ ] Rollback plan documented
- [ ] Success metrics dashboard live
```

### Step 8: Add Mission to Library

Update `/missions/library.md`:

```markdown
#### 🚀 LAUNCH - Product Feature Launch
**File**: `mission-launch.md`  
**Purpose**: Coordinated feature release  
**Duration**: 4-6 hours  
**Required**: Feature spec and marketing plan  
**Squad**: Full marketing and technical team
```

## Mission Design Patterns

### Sequential Pattern
Best for: Linear processes with dependencies

```
Phase 1 → Phase 2 → Phase 3 → Complete
```

Example: Build → Test → Deploy

### Parallel Pattern
Best for: Independent workstreams

```
      ┌→ Phase 2A ─┐
Phase 1            → Phase 4
      └→ Phase 2B ─┘
```

Example: Dev + Docs simultaneously

### Iterative Pattern
Best for: Refinement processes

```
Phase 1 → Phase 2 ⟲ (repeat until criteria met) → Phase 3
```

Example: Design → Review → Refine

### Checkpoint Pattern
Best for: Quality gates

```
Phase 1 → Checkpoint → Phase 2 → Checkpoint → Phase 3
```

Example: Implement → Verify → Continue

## Best Practices

### Mission Scope
- **Do**: Focus on 3-8 phases
- **Don't**: Create 20+ phase missions
- **Do**: Clear handoffs between agents
- **Don't**: Vague responsibilities

### Time Estimates
- Be realistic but aggressive
- Include buffer for reviews
- Consider agent response time
- Account for iterations

### Agent Selection
- Only include necessary agents
- Define clear lead/support roles
- Avoid agent overload
- Consider expertise overlap

### Input Requirements
- Specify format expectations
- Note optional vs required
- Provide example inputs
- Consider input validation

## Advanced Mission Features

### Conditional Phases

```markdown
### Phase 3: UI Design (1-2 hours) *[If UI Required]*

**Lead**: @designer  
**Objective**: Create interface designs

[Phase only executes if UI changes needed]
```

### Mission Variations

```markdown
## Common Variations

### Quick Launch (2 hours)
- Skip press release
- Minimal social media
- Focus on user notification

### Enterprise Launch (8+ hours)
- Add compliance review
- Include partner coordination
- Extended QA phase
```

### Dynamic Inputs

```markdown
## Required Inputs

1. **Config File** (required) - JSON/YAML with:
   - target_environment
   - feature_flags
   - notification_list
```

### Phase Dependencies

```markdown
### Phase 4: Deployment (30 min)

**Requires**: Phase 3 completion + approval
**Lead**: @operator  
**Objective**: Production deployment
```

## Testing Your Mission

### Dry Run Protocol

1. Execute with test inputs
2. Monitor phase transitions
3. Verify deliverables
4. Check time estimates
5. Validate success criteria

### Iteration Process

1. Run mission 3-5 times
2. Note common issues
3. Adjust phase timing
4. Refine agent instructions
5. Update based on feedback

### Quality Checklist

- [ ] Mission completes in estimated time
- [ ] All deliverables produced
- [ ] Agents have clear instructions
- [ ] Handoffs work smoothly
- [ ] Success criteria measurable

## Common Mission Types to Create

### For SaaS Products
- USER_ONBOARD: New customer setup
- FEATURE_FLAG: Gradual feature rollout
- API_UPDATE: Versioned API deployment
- BILLING_CHANGE: Pricing model updates

### For E-commerce
- PRODUCT_LAUNCH: New product listing
- SALE_PREP: Campaign preparation
- INVENTORY_SYNC: Multi-channel updates
- REVIEW_RESPONSE: Customer feedback handling

### For Agencies
- CLIENT_ONBOARD: New client setup
- CAMPAIGN_CREATE: Marketing campaign
- REPORT_MONTHLY: Client reporting
- PITCH_PREP: Proposal creation

### For Open Source
- RELEASE_PREP: Version release
- CONTRIB_REVIEW: PR evaluation
- DOCS_UPDATE: Documentation refresh
- COMMUNITY_EVENT: Event organization

## Mission Maintenance

### Regular Reviews
- Monthly mission effectiveness review
- Update time estimates based on actuals
- Refine based on agent evolution
- Archive unused missions

### Version Control
- Track mission changes in git
- Document why changes made
- Tag stable mission versions
- Allow mission rollback

### Sharing Missions
- Export successful missions
- Share with AGENT-11 community
- Import missions from others
- Build mission marketplace

## Troubleshooting Custom Missions

### Common Issues

**"Phase taking too long"**
- Break into smaller phases
- Parallelize where possible
- Refine agent instructions
- Check input quality

**"Agents confused on handoffs"**
- Clarify deliverables
- Specify format expectations
- Add validation steps
- Improve phase transitions

**"Mission not completing"**
- Review success criteria
- Check for blocking phases
- Validate input requirements
- Add timeout handling

## Examples of Great Missions

### CONTENT_SPRINT
Weekly content creation workflow with research, writing, editing, and distribution phases.

### SECURITY_AUDIT
Quarterly security assessment with vulnerability scanning, remediation, and compliance reporting.

### FEATURE_EXPERIMENT
A/B testing workflow with hypothesis, implementation, measurement, and decision phases.

### CUSTOMER_RESCUE
High-touch customer recovery with analysis, solution design, implementation, and follow-up.

---

*Your workflows are unique. Your missions should be too. Start creating with `/missions/mission-template.md`*