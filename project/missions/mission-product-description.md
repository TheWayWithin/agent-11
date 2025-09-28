# Mission: PRODUCT-DESCRIPTION 📋
## Create or Update Comprehensive Product Description with Risk Management

**Mission Code**: PRODUCT-DESCRIPTION  
**Estimated Duration**: 2-3 hours  
**Complexity**: Medium  
**Squad Required**: Strategist, Analyst, Marketer, Documenter

## Mission Briefing

Create a comprehensive product description document that captures your product's value proposition, features, pricing strategy, technology stack, and critically, risk management strategies. This mission produces a product-description.md that serves as the definitive reference for product positioning, financial planning, and risk mitigation. Essential for investor discussions, team alignment, and strategic planning.

## Required Inputs

1. **Product Vision or PRD** (required) - Product requirements, vision document, or existing description
2. **Market Research** (optional) - Competitor analysis, market sizing, user research
3. **Technical Architecture** (optional) - Technology choices and infrastructure details
4. **Financial Model** (optional) - Pricing strategy, unit economics, cost projections

## Mission Phases

### Phase 1: Product Analysis (30 minutes) - IMMEDIATE ACTION

**Lead**: @strategist  
**Objective**: Understand product vision and core value proposition

**COORDINATOR PROTOCOL**:
1. **UPDATE project-plan.md** with Phase 1 tasks:
   ```markdown
   ## Mission: PRODUCT-DESCRIPTION Documentation
   
   ### Phase 1: Product Analysis (In Progress)
   - [ ] Analyze product vision and requirements (assigned to @strategist)
   - [ ] Define core value propositions (assigned to @strategist)
   - [ ] Identify target customer segments (assigned to @strategist)
   - [ ] Map feature sets to customer needs (assigned to @strategist)
   - [ ] Define success metrics and KPIs (assigned to @strategist)
   ```

2. **IMMEDIATELY CALL @strategist** - do not plan or wait

```bash
@strategist Analyze the product requirements and:
1. Define the core product vision and mission
2. Identify unique value propositions with supporting evidence
3. Map target customer segments and their pain points
4. Prioritize features by customer value and differentiation
5. Define measurable success metrics and KPIs
6. Outline the product roadmap and strategic priorities
```

3. **WAIT FOR @strategist RESPONSE**
4. **UPDATE project-plan.md** mark completed tasks [x] and add Phase 2 tasks
5. **LOG TO progress.md** any issues encountered during this phase

**Deliverables**:
- Product vision statement
- Value proposition matrix
- Customer segment analysis
- Feature prioritization
- Success metrics defined

### Phase 2: Market & Competitive Analysis (30-45 minutes) - IMMEDIATE ACTION

**Lead**: @marketer  
**Support**: @analyst  
**Objective**: Position product in market context

**COORDINATOR ACTION**: After @strategist completes, immediately call @marketer

```bash
@marketer Conduct market analysis:
1. Research and analyze direct and indirect competitors
2. Create competitive feature matrix and pricing comparison
3. Identify market gaps and opportunities
4. Define go-to-market strategy and channels
5. Develop pricing tiers with clear value progression
6. Create customer acquisition and retention strategies
7. Define brand positioning and messaging
```

**WAIT FOR @marketer RESPONSE** before proceeding to Phase 3

**Deliverables**:
- Competitive analysis matrix
- Market opportunity assessment
- Pricing strategy
- Go-to-market plan
- Brand positioning

### Phase 3: Risk Assessment & Financial Analysis (30-45 minutes)

**Lead**: @analyst  
**Support**: @strategist  
**Objective**: Identify risks and create mitigation strategies

```bash
@analyst Perform comprehensive risk and financial analysis:
1. Calculate unit economics for each pricing tier
2. Identify API and infrastructure cost risks
3. Ensure operational costs stay below 60% of revenue per tier
4. Assess technical risks (dependencies, scaling, security)
5. Evaluate market risks (competition, regulation, pricing pressure)
6. Create financial projections and break-even analysis
7. Develop risk mitigation strategies for each identified risk
8. Define cost control mechanisms and monitoring approach
```

**Deliverables**:
- Unit economics model
- Risk assessment matrix
- Cost control strategies
- Financial projections
- Mitigation plans

### Phase 4: Technical & Operational Planning (30 minutes)

**Lead**: @analyst  
**Support**: @architect (if available)  
**Objective**: Document technology stack and operational considerations

```bash
@analyst Document technical and operational aspects:
1. Outline technology stack choices with rationale
2. Map external service integrations and dependencies
3. Define performance metrics and SLA targets
4. Document security and compliance requirements
5. Create scalability roadmap with capacity planning
6. Identify operational risks and monitoring needs
```

**Deliverables**:
- Technology stack documentation
- Integration architecture
- Performance targets
- Security requirements
- Scalability plan

### Phase 5: Documentation Generation (30-45 minutes)

**Lead**: @documenter  
**Support**: @strategist  
**Objective**: Create comprehensive product description document

```bash
@documenter Using the product-description-template.md and all gathered information:
1. Generate complete product-description.md document
2. Ensure risk management section is thoroughly documented
3. Create clear pricing tier comparisons with value justification
4. Document all features with user benefits
5. Include competitive analysis and market positioning
6. Add financial projections and unit economics
7. Ensure consistency and completeness across all sections
8. Add glossary and appendices as needed
```

**Deliverables**:
- Complete product-description.md document
- Risk management documentation
- Pricing and feature matrices
- Market positioning statement

### Phase 6: Final Review (15-30 minutes)

**Lead**: @strategist  
**Support**: @analyst, @marketer  
**Objective**: Ensure document accuracy and strategic alignment

```bash
@strategist Perform final review:
1. Verify product vision alignment throughout document
2. Validate risk assessments and mitigation strategies
3. Ensure financial models are realistic and sustainable
4. Confirm competitive positioning is accurate
5. Check that all sections support the value proposition
6. Approve document for stakeholder distribution
```

**Deliverables**:
- Reviewed and approved product-description.md
- Executive summary
- Next steps and action items

## Success Criteria

- [ ] Complete product-description.md document created/updated
- [ ] Clear value proposition with supporting evidence
- [ ] Comprehensive risk management section with mitigation strategies
- [ ] API and operational costs mapped to < 60% of tier revenue
- [ ] Competitive analysis and market positioning documented
- [ ] Pricing tiers with clear value progression defined
- [ ] Technology stack and architecture outlined
- [ ] Financial projections and unit economics calculated
- [ ] Document reviewed and approved by team

## Common Variations

### New Product Launch
- Greater emphasis on market validation
- More detailed competitive analysis
- Focus on MVP feature set
- Include launch strategy

### Existing Product Update
- Focus on current metrics and performance
- Emphasize growth strategies
- Document lessons learned
- Include migration paths

### Enterprise Product
- Detailed compliance and security sections
- Enterprise pricing and licensing models
- Integration and customization capabilities
- Support and SLA definitions

## Special Considerations

### Risk Management Focus
- Always calculate cost-to-revenue ratios
- Include multiple fallback strategies
- Document monitoring and alert thresholds
- Plan for worst-case scenarios

### Investor Readiness
- Include TAM, SAM, SOM analysis
- Show clear path to profitability
- Demonstrate defensibility
- Include growth projections

### Team Alignment
- Ensure all stakeholders review relevant sections
- Create different versions for different audiences
- Include clear action items and ownership
- Plan for regular updates

## Coordination Notes

- Use product-description-template.md from templates directory
- Risk management section is mandatory and critical
- Ensure financial sustainability at every tier
- Balance ambition with realistic projections
- Keep focus on customer value and differentiation

## Common Patterns

### API Cost Management
- Implement aggressive caching
- Use batch processing where possible
- Set hard limits with graceful degradation
- Monitor usage in real-time

### Pricing Strategy Evolution
- Start with simple tiers
- Add usage-based components over time
- Consider freemium carefully
- Plan for enterprise negotiations

### Risk Mitigation Patterns
- Multi-provider strategies for critical services
- Progressive enhancement approaches
- Feature flags for controlled rollouts
- Regular disaster recovery testing

---

*Transform your product vision into a comprehensive blueprint that aligns teams, attracts investors, and manages risks proactively. Your product description becomes the strategic north star for sustainable growth.*

*Begin with `/coord product-description [vision-document]`*