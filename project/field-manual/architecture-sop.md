# Architecture Documentation Standard Operating Procedure (SOP)

## Table of Contents
1. [Purpose & Scope](#purpose--scope)
2. [Document Structure Template](#document-structure-template)
3. [Content Guidelines for Each Section](#content-guidelines-for-each-section)
4. [Visual Documentation Standards](#visual-documentation-standards)
5. [Technical Detail Guidelines](#technical-detail-guidelines)
6. [Maintenance & Versioning](#maintenance--versioning)
7. [Quality Checklist](#quality-checklist)
8. [Templates & Examples](#templates--examples)
9. [Common Pitfalls to Avoid](#common-pitfalls-to-avoid)
10. [Integration with Other Docs](#integration-with-other-docs)

---

## Purpose & Scope

### Why Architecture Documentation Matters

Architecture documentation serves as the **single source of truth** for your system's design and evolution. It:

- **Reduces onboarding time** for new team members from weeks to days
- **Prevents architectural drift** by documenting intentional design decisions
- **Enables confident changes** by showing system boundaries and dependencies
- **Facilitates incident response** through clear system understanding
- **Supports scaling decisions** with documented bottlenecks and capacity limits
- **Preserves institutional knowledge** beyond individual team members

### Who Should Use This SOP

**Primary Audiences:**
- **Architects & Technical Leads** - Creating and maintaining architecture docs
- **Senior Developers** - Contributing to architectural decisions and documentation
- **Engineering Managers** - Ensuring documentation standards are met
- **DevOps/Platform Engineers** - Documenting infrastructure and deployment

**Secondary Audiences:**
- **Product Managers** - Understanding technical constraints and capabilities
- **New Team Members** - Learning system design and implementation
- **External Stakeholders** - Understanding system capabilities and limitations

### When to Create/Update Architecture Docs

**Create New Documentation:**
- ✅ New project or major system redesign
- ✅ Migrating from undocumented legacy system
- ✅ Onboarding new team with existing undocumented system
- ✅ Preparing for major scaling or technology changes

**Update Existing Documentation:**
- ✅ **Immediately after** architectural changes are deployed
- ✅ **Before major releases** that change system behavior
- ✅ **Quarterly reviews** to catch drift and improvements
- ✅ **After incidents** that reveal documentation gaps
- ✅ **When onboarding feedback** identifies confusing or missing sections

---

## Document Structure Template

### Required Core Sections (Every Project)

```markdown
# System Architecture - [Project Name]

## 1. Executive Summary
## 2. System Overview  
## 3. Infrastructure Architecture
## 4. Application Architecture
## 5. Data Architecture
## 6. Architecture Decisions
## 7. Current Limitations
## 8. Next Steps
```

### Optional Sections (Based on Project Needs)

```markdown
## Security Architecture        [Required for: user data, payments, compliance]
## Integration Architecture     [Required for: external APIs, microservices]
## Development Architecture     [Required for: teams >5 people, complex builds]
## Monitoring & Performance     [Required for: production systems, SLAs]
## Scaling Strategy             [Required for: growth systems, variable load]
## Lessons Learned              [Recommended for: mature systems, post-incidents]
## Disaster Recovery            [Required for: critical systems, data protection]
## Compliance & Governance      [Required for: regulated industries, enterprise]
```

### Section Ordering Best Practices

1. **Start with Why** - Executive Summary explains purpose and value
2. **Big Picture First** - System Overview before detailed components
3. **Outside-In Flow** - Infrastructure → Application → Data
4. **Decisions Last** - Architecture Decisions after showing current state
5. **Forward-Looking** - Limitations and Next Steps conclude the document

---

## Content Guidelines for Each Section

### 1. Executive Summary

**Purpose:** 30-second overview for busy stakeholders
**Length:** 150-300 words
**Audience:** All stakeholders, especially non-technical

**Must Include:**
- System purpose and primary users
- Key business capabilities enabled
- Major technology choices (1-2 sentences)
- Current scale metrics (users, requests, data)
- Team size and ownership

**Template:**
```markdown
## Executive Summary

[Project Name] is a [type of system] that enables [primary business value] for [target users]. 

**Core Capabilities:**
- [Primary capability 1]
- [Primary capability 2]
- [Primary capability 3]

**Technology Stack:** [Primary language/framework], [Database type], [Deployment platform]

**Current Scale:** [X users/month], [Y requests/day], [Z GB data], maintained by [N] engineers

**Key Architectural Strengths:** [Security/Performance/Scalability highlight]
```

### 2. System Overview

**Purpose:** Visual and conceptual understanding of major components
**Length:** 300-500 words + diagram
**Audience:** Technical team members, architects

**Must Include:**
- System boundary diagram showing major components
- External dependencies and integrations
- User journey through the system
- Key data flows between components

**Template:**
```markdown
## System Overview

### High-Level Architecture
[ASCII or embedded diagram showing major components]

### Core Components
- **[Component 1]**: [Purpose and key responsibilities]
- **[Component 2]**: [Purpose and key responsibilities]
- **[Component 3]**: [Purpose and key responsibilities]

### External Dependencies
- **[Service 1]**: [Purpose and integration method]
- **[Service 2]**: [Purpose and integration method]

### User Journey
1. [Step 1 description]
2. [Step 2 description]
3. [Step 3 description]
```

### 3. Infrastructure Architecture

**Purpose:** Deployment, networking, and operational environment
**Length:** 400-600 words
**Audience:** DevOps, platform engineers, architects

**Must Include:**
- Deployment environments (dev, staging, prod)
- Infrastructure providers and services used
- Networking and security boundaries
- Scalability and availability characteristics
- Cost optimization strategies

**Template:**
```markdown
## Infrastructure Architecture

### Deployment Environments
- **Production**: [Platform] - [URL/access method]
- **Staging**: [Platform] - [URL/access method]  
- **Development**: [Platform] - [URL/access method]

### Core Infrastructure
- **Compute**: [Service type, sizing, auto-scaling rules]
- **Database**: [Type, provider, backup strategy]
- **Storage**: [Type, purpose, retention policies]
- **CDN/Cache**: [Service, configuration, cache strategy]

### Network Architecture
[Diagram or description of network topology]
- Load balancing strategy
- Security groups/firewalls
- Service discovery method

### Operational Characteristics
- **Availability**: [SLA/uptime target]
- **Scalability**: [Current capacity, scaling triggers]
- **Backup/Recovery**: [Strategy, RTO/RPO targets]
- **Cost Management**: [Current monthly cost, optimization strategies]
```

### 4. Application Architecture

**Purpose:** Software components, patterns, and code organization
**Length:** 500-800 words
**Audience:** Developers, technical leads

**Must Include:**
- Application layers and their responsibilities
- Key architectural patterns used
- Service boundaries and communication
- Code organization and module structure
- Framework and library choices with rationale

**Template:**
```markdown
## Application Architecture

### Technology Stack
- **Frontend**: [Framework/version, key libraries]
- **Backend**: [Framework/version, key libraries]
- **Language(s)**: [Versions and rationale]

### Application Layers
```
[Frontend Layer]
    ↓ API calls
[API Layer]
    ↓ Business logic
[Service Layer]  
    ↓ Data access
[Data Layer]
```

### Service Architecture
- **[Service 1]**: [Purpose, API surface, dependencies]
- **[Service 2]**: [Purpose, API surface, dependencies]

### Key Patterns & Practices
- **Authentication**: [Method and flow]
- **Error Handling**: [Strategy and logging]
- **API Design**: [REST/GraphQL, versioning strategy]
- **State Management**: [Client and server patterns]

### Code Organization
```
project/
├── client/          # Frontend application
├── server/          # Backend API
├── shared/          # Shared types/utilities
├── database/        # Migrations and schema
└── infrastructure/  # Deployment configs
```
```

### 5. Data Architecture

**Purpose:** Data models, storage, and flow patterns
**Length:** 400-600 words
**Audience:** Developers, data engineers, architects

**Must Include:**
- Database schema overview
- Data flow between components
- Storage strategy and rationale
- Data governance and privacy considerations
- Backup and recovery procedures

**Template:**
```markdown
## Data Architecture

### Database Schema
**Primary Database**: [Type/provider]

**Core Entities:**
- **[Entity 1]**: [Purpose, key fields, relationships]
- **[Entity 2]**: [Purpose, key fields, relationships]
- **[Entity 3]**: [Purpose, key fields, relationships]

### Data Flow
```
[User Input] → [Validation] → [Business Logic] → [Database]
                    ↓
[External APIs] ← [Processing] ← [Event System]
```

### Storage Strategy
- **Transactional Data**: [Database choice, consistency model]
- **Analytics Data**: [Warehouse/lake, processing pipeline]
- **File Storage**: [Provider, access patterns, retention]
- **Caching**: [Strategy, invalidation, performance impact]

### Data Governance
- **Privacy Compliance**: [GDPR/CCPA considerations]
- **Data Retention**: [Policies and automated cleanup]
- **Access Control**: [Who can access what data]
- **Audit Logging**: [What changes are tracked]

### Backup & Recovery
- **Backup Frequency**: [Schedule and retention]
- **Recovery Procedures**: [RTO/RPO, testing frequency]
- **Disaster Recovery**: [Cross-region, failover strategy]
```

### 6. Architecture Decisions

**Purpose:** Record and rationale for major technical choices
**Length:** Variable, 100-200 words per decision
**Audience:** Technical team, future maintainers

**Must Include:**
- Date and context of decision
- Options considered
- Decision made and rationale
- Trade-offs and implications
- Review trigger conditions

**Template:**
```markdown
## Architecture Decisions

### ADR-001: Database Technology Choice
**Date**: [YYYY-MM-DD]  
**Status**: Accepted  
**Context**: [Problem that needed solving]

**Options Considered:**
1. **[Option 1]**: [Pros and cons]
2. **[Option 2]**: [Pros and cons]
3. **[Option 3]**: [Pros and cons]

**Decision**: [Chosen option and key reasons]

**Consequences:**
- **Positive**: [Benefits realized]
- **Negative**: [Trade-offs accepted]
- **Neutral**: [Things to monitor]

**Review Trigger**: [When to reconsider this decision]

---

### ADR-002: [Next Decision]
[Follow same template]
```

### 7. Current Limitations

**Purpose:** Known constraints and technical debt
**Length:** 200-400 words
**Audience:** Product managers, technical leads, stakeholders

**Must Include:**
- Performance bottlenecks
- Scalability constraints  
- Technical debt priorities
- Resource limitations
- Known bugs or workarounds

**Template:**
```markdown
## Current Limitations

### Performance Constraints
- **[Bottleneck 1]**: [Impact and current mitigation]
- **[Bottleneck 2]**: [Impact and current mitigation]

### Scalability Limits
- **Users**: Current capacity [X], breaks at [Y]
- **Requests**: Current [X/sec], max tested [Y/sec]
- **Data**: Current [X GB], performance degrades at [Y GB]

### Technical Debt
**Priority 1 (Blocking Growth):**
- [Item 1]: [Impact and effort estimate]
- [Item 2]: [Impact and effort estimate]

**Priority 2 (Maintenance Burden):**
- [Item 1]: [Impact and effort estimate]

### Resource Constraints
- **Budget**: [Monthly costs approaching limits]
- **Team Capacity**: [Areas needing more expertise]
- **Infrastructure**: [Services approaching quotas]
```

### 8. Next Steps

**Purpose:** Planned improvements and evolution path
**Length:** 200-300 words
**Audience:** Product managers, technical leads, executives

**Must Include:**
- Prioritized improvements
- Timeline and resource estimates
- Success metrics
- Dependencies and risks

**Template:**
```markdown
## Next Steps

### Immediate Priorities (Next Quarter)
1. **[Priority 1]**: [Description, effort, success metric]
2. **[Priority 2]**: [Description, effort, success metric]
3. **[Priority 3]**: [Description, effort, success metric]

### Medium-term Goals (6 months)
- **[Goal 1]**: [Why important, dependencies]
- **[Goal 2]**: [Why important, dependencies]

### Long-term Vision (12+ months)
- **[Vision item 1]**: [Strategic importance]
- **[Vision item 2]**: [Strategic importance]

### Success Metrics
- [Metric 1]: Current [X], target [Y]
- [Metric 2]: Current [X], target [Y]

### Key Dependencies
- **External**: [What we're waiting for]
- **Internal**: [Team capacity, other projects]
- **Technical**: [Platform upgrades, migrations]
```

---

## Visual Documentation Standards

### ASCII Diagram Templates

**System Overview Template:**
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Frontend  │───▶│   Backend   │───▶│  Database   │
│   (React)   │    │ (Express)   │    │(PostgreSQL)│
└─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   
       ▼                   ▼                   
┌─────────────┐    ┌─────────────┐              
│     CDN     │    │  External   │              
│  (Cloudflare)│    │   APIs      │              
└─────────────┘    └─────────────┘              
```

**Data Flow Template:**
```
User Input ──▶ Validation ──▶ Business Logic ──▶ Database
    │               │               │               │
    ▼               ▼               ▼               ▼
  UI State    Error Handling   Event System    Audit Log
```

**Deployment Architecture Template:**
```
Production Environment
┌─────────────────────────────────────────────────────────┐
│  Load Balancer                                          │
│       │                                                 │
│    ┌──▼──┐  ┌─────┐  ┌─────┐                           │
│    │ App │  │ App │  │ App │                           │
│    │ VM1 │  │ VM2 │  │ VM3 │                           │
│    └─────┘  └─────┘  └─────┘                           │
│                │                                        │
│    ┌───────────▼───────────┐      ┌─────────────────┐   │
│    │      Database         │      │   File Storage  │   │
│    │    (PostgreSQL)       │      │      (S3)       │   │
│    └───────────────────────┘      └─────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

### When to Use Diagrams vs Text

**Use Diagrams When:**
- ✅ Showing relationships between 3+ components
- ✅ Illustrating data flow or user journey
- ✅ Explaining deployment topology
- ✅ Demonstrating service interactions
- ✅ Complex decision trees or state machines

**Use Text When:**
- ✅ Listing configuration options
- ✅ Explaining rationale or trade-offs
- ✅ Providing step-by-step procedures
- ✅ Documenting environment variables
- ✅ Simple linear processes

### Diagram Complexity Guidelines

**Simple (Preferred):**
- Maximum 7 components
- Single level of abstraction
- Clear labels and arrows
- One primary message

**Medium (Acceptable):**
- 8-15 components
- Two levels of abstraction
- Grouped related items
- Multiple related messages

**Complex (Avoid):**
- 16+ components
- Three+ levels of abstraction
- No clear grouping
- Multiple unrelated concepts

---

## Technical Detail Guidelines

### Detail Level by Audience

**Executive Summary (Non-Technical Stakeholders):**
- High-level business capabilities
- Major technology choices only
- Scale and performance in business terms
- Costs and timeline implications

**System Overview (Technical Managers):**
- Component responsibilities
- Technology stack with versions
- Integration points
- Performance characteristics

**Implementation Details (Developers):**
- Code organization patterns
- Configuration specifics
- Development workflow
- Debugging and troubleshooting

### When to Include Code Examples

**Include Code Examples For:**
- ✅ Non-obvious configuration patterns
- ✅ Critical integration points
- ✅ Security implementation details
- ✅ Performance optimization techniques
- ✅ Error handling strategies

**Example - Good Code Inclusion:**
```markdown
### Authentication Flow

Users authenticate via JWT tokens with refresh rotation:

```javascript
// Token validation middleware
const authenticateToken = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  
  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) return res.sendStatus(403);
    req.user = user;
    next();
  });
};
```
```

**Avoid Code Examples For:**
- ❌ Standard framework usage
- ❌ Basic CRUD operations  
- ❌ Trivial configuration
- ❌ Implementation details that change frequently

### Configuration and Environment Documentation

**Always Document:**
- Required environment variables
- Configuration file locations
- Default values and valid ranges
- Security-sensitive settings
- Environment-specific differences

**Template:**
```markdown
### Environment Configuration

**Required Environment Variables:**
```bash
# Database
DATABASE_URL=postgresql://user:pass@host:5432/db
DATABASE_SSL=true

# Authentication  
JWT_SECRET=your-256-bit-secret
JWT_EXPIRES_IN=1h

# External Services
STRIPE_SECRET_KEY=sk_test_...
SENDGRID_API_KEY=SG....
```

**Configuration Files:**
- `config/database.js` - Database connection settings
- `config/auth.js` - Authentication configuration
- `.env.example` - Template for local development
```

---

## Maintenance & Versioning

### Update Triggers and Frequency

**Immediate Updates Required:**
- ✅ **Breaking changes** to APIs or data schemas
- ✅ **New major components** added to the system
- ✅ **Infrastructure changes** (database migration, service provider)
- ✅ **Security changes** to authentication or authorization
- ✅ **Major dependency updates** that change behavior

**Scheduled Updates:**
- ✅ **Monthly**: Review for drift and minor corrections
- ✅ **Quarterly**: Comprehensive review of all sections
- ✅ **After incidents**: Update lessons learned and limitations
- ✅ **Before major releases**: Ensure documentation reflects changes

### Version Numbering Scheme

**Use Semantic Versioning for Architecture Docs:**

```markdown
# System Architecture - [Project Name] v2.1.0
**Last Updated**: 2024-03-15
**Document Version**: 2.1.0
**System Version**: v1.8.3
```

**Version Increment Rules:**
- **Major (X.0.0)**: Fundamental architecture changes, new system paradigm
- **Minor (x.Y.0)**: New components, significant changes to existing sections
- **Patch (x.y.Z)**: Bug fixes, clarifications, minor updates

### Review and Approval Process

**For Major Changes (Version X.Y.0+):**
1. **Author** creates draft with changes highlighted
2. **Technical Lead** reviews technical accuracy
3. **Architect** approves architectural consistency
4. **Team Review** in architecture meeting
5. **Final Approval** from engineering manager

**For Minor Updates (Version x.y.Z):**
1. **Author** updates relevant sections
2. **Peer Review** from one team member
3. **Direct Merge** with notification to team

**Review Template:**
```markdown
## Review Checklist for Architecture Doc v[X.Y.Z]

### Technical Accuracy
- [ ] All components and versions are current
- [ ] Diagrams match actual implementation
- [ ] Configuration examples are tested
- [ ] Links and references are valid

### Completeness
- [ ] New features are documented
- [ ] Deprecated features are marked
- [ ] All ADRs have rationale
- [ ] Limitations section is current

### Clarity
- [ ] Section headings are descriptive
- [ ] Technical jargon is explained
- [ ] Diagrams support the text
- [ ] Examples are realistic

**Reviewer**: [Name]
**Date**: [YYYY-MM-DD]
**Approval**: ✅ Approved / ⏳ Changes Requested / ❌ Rejected
```

### Documentation Ownership

**Primary Owner (Architect/Technical Lead):**
- Overall document quality and consistency
- Major architectural decision documentation
- Quarterly comprehensive reviews
- Final approval on major changes

**Contributing Owners (Senior Developers):**
- Section expertise (frontend, backend, data, etc.)
- Implementation detail accuracy
- Code example maintenance
- Regular minor updates

**Review Contributors (All Team Members):**
- Accuracy feedback from daily usage
- Onboarding experience insights
- Missing information identification
- Clarity improvement suggestions

---

## Quality Checklist

### Pre-Publication Review Items

**Content Quality:**
- [ ] **Executive Summary** explains value in business terms
- [ ] **System Overview** diagram shows actual components
- [ ] **All sections** follow the template structure
- [ ] **Code examples** are tested and current
- [ ] **Configuration** examples match actual environments
- [ ] **ADRs** have clear rationale and trade-offs documented

**Technical Accuracy:**
- [ ] **Component versions** match current implementation
- [ ] **API endpoints** and schemas are current
- [ ] **Infrastructure** reflects actual deployment
- [ ] **Database schema** matches current migrations
- [ ] **External dependencies** are current and correct

**Usability:**
- [ ] **Table of contents** is complete and linked
- [ ] **Section headings** are descriptive and scannable
- [ ] **Diagrams** are clearly labeled with proper flow
- [ ] **Links** work and point to current resources
- [ ] **Formatting** is consistent throughout

### Completeness Criteria

**Minimum Viable Documentation:**
- [ ] Purpose and scope clearly stated
- [ ] System boundary and major components identified
- [ ] Current deployment architecture documented
- [ ] Key architectural decisions with rationale
- [ ] Known limitations and constraints listed
- [ ] Contact information for questions

**Comprehensive Documentation:**
- [ ] All template sections completed appropriately
- [ ] Visual diagrams for complex relationships
- [ ] Code examples for non-trivial patterns
- [ ] Environment-specific configuration details
- [ ] Monitoring and operational procedures
- [ ] Disaster recovery and backup procedures

### Accuracy Validation Steps

**Technical Validation:**
1. **Code Examples**: Run all code snippets in appropriate environment
2. **Configuration**: Test environment setup from documentation
3. **Links**: Verify all internal and external links resolve
4. **Versions**: Cross-check component versions with package files
5. **Diagrams**: Walk through diagrams with actual system behavior

**User Validation:**
1. **Onboarding Test**: Have new team member follow documentation
2. **Stakeholder Review**: Non-technical stakeholders review summary
3. **Expert Review**: Subject matter experts validate their sections
4. **Incident Response**: Use docs during simulated incident

**Automated Validation:**
```bash
# Example validation script
#!/bin/bash

echo "Validating architecture documentation..."

# Check for broken links
markdown-link-check ARCHITECTURE.md

# Validate code examples
./scripts/test-code-examples.sh

# Check for outdated version references
./scripts/check-versions.sh

# Validate configuration examples
./scripts/validate-configs.sh

echo "Validation complete!"
```

---

## Templates & Examples

### Complete Minimal Template

```markdown
# System Architecture - [Project Name]

**Last Updated**: [YYYY-MM-DD]  
**Document Version**: 1.0.0  
**Author**: [Name/Team]

## Executive Summary

[Project Name] is a [system type] that [primary purpose] for [target users].

**Key Capabilities:** [List 3-4 main features]
**Technology Stack:** [Primary tech stack]
**Scale:** [Current metrics]
**Team:** [Size and structure]

## System Overview

### Architecture Diagram
```
[Simple ASCII diagram of major components]
```

### Core Components
- **[Component 1]**: [Purpose and responsibilities]
- **[Component 2]**: [Purpose and responsibilities]

## Infrastructure Architecture

**Environments:**
- Production: [Platform and access]
- Staging: [Platform and access]

**Key Infrastructure:**
- Compute: [Service and sizing]
- Database: [Type and provider]
- Storage: [Type and purpose]

## Application Architecture

**Technology Stack:**
- Frontend: [Framework/version]
- Backend: [Framework/version]
- Database: [Type/version]

**Key Patterns:**
- Authentication: [Method]
- API Design: [Style and versioning]

## Data Architecture

**Database Schema:**
[Brief entity description]

**Data Flow:**
[Simple flow description]

## Architecture Decisions

### ADR-001: [Decision Title]
**Date**: [YYYY-MM-DD]
**Context**: [Problem]
**Decision**: [Solution chosen]
**Rationale**: [Why this choice]

## Current Limitations

- [Limitation 1]: [Impact]
- [Limitation 2]: [Impact]

## Next Steps

### Immediate (Next Quarter)
1. [Priority 1]
2. [Priority 2]

### Medium-term (6 months)
- [Goal 1]
- [Goal 2]
```

### Good Example - E-commerce Platform

```markdown
# System Architecture - ShopFast E-commerce Platform

**Last Updated**: 2024-03-15  
**Document Version**: 2.1.0  
**Author**: Platform Team

## Executive Summary

ShopFast is a B2B e-commerce platform that enables mid-market retailers to manage inventory, process orders, and analyze sales performance. The platform serves 500+ active retailers processing $2M+ in monthly transactions.

**Key Capabilities:**
- Multi-tenant inventory management with real-time stock tracking
- Automated order processing with 3rd-party fulfillment integration  
- Advanced analytics dashboard with custom reporting
- Mobile-responsive admin interface for on-the-go management

**Technology Stack:** Node.js/React, PostgreSQL, AWS infrastructure
**Scale:** 15,000 orders/day, 50TB product data, 99.9% uptime SLA
**Team:** 8 engineers across frontend, backend, and DevOps

## System Overview

### Architecture Diagram
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Admin     │    │   Customer  │    │  Partner    │
│   Portal    │    │   Storefront│    │   APIs      │
│  (React)    │    │  (React)    │    │             │
└──────┬──────┘    └──────┬──────┘    └──────┬──────┘
       │                  │                  │
       └──────────────────┼──────────────────┘
                          │
    ┌─────────────────────▼─────────────────────┐
    │           API Gateway                     │
    │        (Express.js + Auth)                │
    └─────────────────────┬─────────────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
   ┌────▼────┐    ┌───────▼──────┐   ┌─────▼─────┐
   │Inventory│    │ Order Mgmt   │   │ Analytics │
   │Service  │    │ Service      │   │ Service   │
   └────┬────┘    └───────┬──────┘   └─────┬─────┘
        │                 │                │
    ┌───▼─────────────────▼────────────────▼───┐
    │         PostgreSQL Database              │
    │    (Multi-tenant with row-level security)│
    └──────────────────────────────────────────┘
```

### Core Components
- **Admin Portal**: Multi-tenant React SPA for retailer management
- **Customer Storefront**: Public-facing product catalog and checkout
- **API Gateway**: Authentication, rate limiting, and request routing
- **Inventory Service**: Real-time stock management with reservation system
- **Order Management**: Processing pipeline with fulfillment partner integration
- **Analytics Service**: Real-time reporting with data aggregation

### External Dependencies
- **Stripe**: Payment processing with webhook-based order confirmation
- **ShipStation**: Fulfillment API for automated shipping label generation
- **SendGrid**: Transactional email service for order notifications
- **CloudFlare**: CDN and DDoS protection for public storefront

## Infrastructure Architecture

### Deployment Environments
- **Production**: AWS ECS Fargate - https://app.shopfast.com
- **Staging**: AWS ECS Fargate - https://staging.shopfast.com
- **Development**: Local Docker Compose + shared AWS RDS

### Core Infrastructure
- **Compute**: ECS Fargate (2-8 tasks auto-scaling based on CPU/memory)
- **Database**: RDS PostgreSQL 13.7 (Multi-AZ, 4vCPU, 16GB RAM)
- **Storage**: S3 for product images, RDS for structured data
- **CDN/Cache**: CloudFlare CDN + Redis ElastiCache for session storage

### Network Architecture
```
Internet ──▶ CloudFlare CDN ──▶ Application Load Balancer
                                        │
                    ┌───────────────────┼───────────────────┐
                    │                   │                   │
              Private Subnet A    Private Subnet B    Private Subnet C
                    │                   │                   │
              ┌─────▼─────┐       ┌─────▼─────┐       ┌─────▼─────┐
              │ECS Tasks  │       │ECS Tasks  │       │    RDS    │
              │ (App)     │       │ (App)     │       │(Database) │
              └───────────┘       └───────────┘       └───────────┘
```

### Operational Characteristics
- **Availability**: 99.9% SLA with automated failover
- **Scalability**: Auto-scales 2-8 containers based on 70% CPU threshold
- **Backup/Recovery**: Daily RDS snapshots, 7-day retention, 4-hour RTO
- **Cost Management**: $3,200/month, optimized with Reserved Instances

## Application Architecture

### Technology Stack
- **Frontend**: React 18.2, TypeScript, Tailwind CSS, React Query
- **Backend**: Node.js 18, Express.js 4.18, TypeScript
- **Database**: PostgreSQL 13.7 with Drizzle ORM
- **Language**: TypeScript throughout for type safety

### Application Layers
```
React Frontend (Admin + Storefront)
    ↓ REST API calls
Express.js API Layer  
    ↓ Service calls
Business Logic Layer (Services)
    ↓ ORM queries  
Data Access Layer (Drizzle ORM)
    ↓ SQL queries
PostgreSQL Database
```

### Service Architecture
- **Authentication Service**: JWT-based with refresh tokens, role-based access
- **Inventory Service**: Stock tracking with reservation system for concurrent orders
- **Order Service**: State machine pattern (pending → confirmed → fulfilled → shipped)
- **Payment Service**: Stripe integration with webhook event processing
- **Notification Service**: Multi-channel (email, SMS, in-app) notification system

### Key Patterns & Practices
- **Authentication**: JWT access tokens (15min) + refresh tokens (7 days)
- **Error Handling**: Global error middleware with structured logging
- **API Design**: RESTful with OpenAPI 3.0 specification, semantic versioning
- **State Management**: React Query for server state, Context API for UI state
- **Testing**: Jest unit tests, Cypress E2E tests, 85% code coverage

## Data Architecture

### Database Schema
**Primary Database**: PostgreSQL 13.7 on AWS RDS

**Core Entities:**
- **tenants**: Multi-tenant isolation with row-level security policies
- **products**: Product catalog with variants, pricing, and inventory levels
- **orders**: Order lifecycle with status tracking and audit trail
- **users**: Authentication and authorization with role-based permissions
- **analytics_events**: Event sourcing for real-time reporting and analytics

### Data Flow
```
User Action ──▶ API Validation ──▶ Business Logic ──▶ Database Transaction
                    ↓                      ↓                    ↓
              Error Response         Event Publishing      Analytics Event
                                           ↓
                              ┌────────────▼────────────┐
                              │   Background Jobs       │
                              │ (Email, Fulfillment)   │
                              └─────────────────────────┘
```

### Storage Strategy
- **Transactional Data**: PostgreSQL with ACID compliance and foreign key constraints
- **Analytics Data**: Same PostgreSQL with materialized views for performance
- **File Storage**: S3 for product images with CloudFlare CDN caching
- **Session Storage**: Redis ElastiCache for user sessions and rate limiting

### Data Governance
- **Privacy Compliance**: GDPR-compliant with data retention policies and deletion endpoints
- **Data Retention**: Order data (7 years), analytics events (2 years), user sessions (30 days)
- **Access Control**: Row-level security ensuring tenants can only access their data
- **Audit Logging**: All data changes tracked with user attribution and timestamps

## Architecture Decisions

### ADR-001: Multi-tenant Database Strategy
**Date**: 2023-08-15  
**Status**: Accepted  
**Context**: Need to isolate customer data while maintaining operational efficiency

**Options Considered:**
1. **Separate Database per Tenant**: Maximum isolation but high operational overhead
2. **Shared Database with Tenant ID**: Simple but risk of data leakage
3. **PostgreSQL Row-Level Security**: Balance of isolation and efficiency

**Decision**: PostgreSQL Row-Level Security with tenant-based policies

**Consequences:**
- **Positive**: Strong data isolation with shared operational infrastructure
- **Negative**: Complex migration procedures, requires careful policy management
- **Neutral**: Team needs PostgreSQL expertise for policy debugging

**Review Trigger**: When reaching 1000+ tenants or if security audit finds issues

### ADR-002: Frontend State Management
**Date**: 2023-09-22  
**Status**: Accepted  
**Context**: React application growing complex with multiple data sources

**Decision**: React Query for server state, Context API for UI-only state

**Rationale**: React Query provides excellent caching and synchronization for server data, while Context API handles simple UI state without additional complexity.

## Current Limitations

### Performance Constraints
- **Database Queries**: Complex analytics queries can take 3-5 seconds during peak hours
- **Image Loading**: Product images >500KB cause slow page loads on mobile

### Scalability Limits
- **Concurrent Users**: Current infrastructure supports ~500 concurrent users
- **Database Connections**: PostgreSQL connection limit of 100 becomes bottleneck
- **Background Jobs**: Single Redis queue can process ~1000 jobs/minute

### Technical Debt
**Priority 1 (Blocking Growth):**
- **Database Query Optimization**: Slow analytics queries affecting user experience (2 weeks effort)
- **Connection Pooling**: Implement pgbouncer to handle more concurrent users (1 week effort)

**Priority 2 (Maintenance Burden):**
- **Legacy API Endpoints**: 15% of endpoints still use old validation patterns (1 month effort)

## Next Steps

### Immediate Priorities (Next Quarter)
1. **Database Performance**: Implement query optimization and connection pooling
2. **Mobile Performance**: Implement image optimization and lazy loading
3. **Monitoring Improvements**: Add application-level metrics and alerting

### Medium-term Goals (6 months)
- **Microservices Migration**: Extract inventory service to separate deployment
- **Advanced Analytics**: Real-time dashboard with streaming data pipeline
- **API v2**: New API version with improved consistency and performance

### Success Metrics
- **Response Time**: 95th percentile API response time <500ms (current: 1.2s)
- **Availability**: Maintain 99.9% uptime during scaling improvements
- **User Experience**: Mobile page load time <3s (current: 5.2s)

### Key Dependencies
- **External**: Stripe API v2 migration required for advanced payment features
- **Internal**: DevOps capacity needed for infrastructure automation
- **Technical**: PostgreSQL 14 upgrade planned for Q2 for improved performance
```

### Bad Example - What NOT to Do

```markdown
# System Architecture - Our App

## Overview
Our app is built with modern technologies and is really scalable.

## Tech Stack
- Frontend: React (latest version)
- Backend: Node.js with Express
- Database: PostgreSQL
- Deployment: Cloud

## How it works
Users log in and then they can do stuff. The frontend talks to the backend which saves data to the database. We use microservices architecture for scalability.

## Database
We have tables for users, products, and orders. Everything is normalized and follows best practices.

## Security
We use JWT tokens and everything is secure. Passwords are hashed.

## Performance
The app is fast and can handle lots of users. We use caching.
```

**Problems with this example:**
- ❌ No specific version numbers or technical details
- ❌ Vague descriptions without actionable information  
- ❌ No diagrams or visual architecture representation
- ❌ Missing operational details (deployment, monitoring)
- ❌ No architectural decisions or trade-offs explained
- ❌ Claims without evidence or metrics
- ❌ No limitations or next steps identified

---

## Common Pitfalls to Avoid

### Documentation Anti-Patterns

**The "Perfect World" Fallback:**
- ❌ **Problem**: Documenting ideal architecture that doesn't exist yet
- ✅ **Solution**: Document current state with clear roadmap to ideal state
- ✅ **Example**: "Currently using monolith (performance issues), migrating to microservices Q2 2024"

**The "Implementation Manual" Trap:**
- ❌ **Problem**: Step-by-step code implementation instead of architectural overview
- ✅ **Solution**: Focus on components, interfaces, and design decisions
- ✅ **Example**: "Authentication uses JWT pattern" vs. "Copy this 50-line auth middleware"

**The "Everything is Important" Syndrome:**
- ❌ **Problem**: Documenting every minor detail without prioritization
- ✅ **Solution**: Use progressive disclosure - overview first, details linked
- ✅ **Example**: High-level system diagram with links to detailed service docs

**The "Set and Forget" Mindset:**
- ❌ **Problem**: Writing documentation once and never updating
- ✅ **Solution**: Build updates into development workflow and quarterly reviews
- ✅ **Example**: Architecture review required for all major PRs

### How to Prevent Documentation Drift

**Development Integration:**
```markdown
## Definition of Done Checklist
- [ ] Code reviewed and approved
- [ ] Tests passing
- [ ] **Architecture doc updated if component/integration changes**
- [ ] Deployment successful
```

**Automated Drift Detection:**
- Version references in docs vs. actual package.json
- API endpoint documentation vs. OpenAPI spec
- Environment variable docs vs. actual .env files
- Infrastructure diagrams vs. actual AWS/deployment config

**Regular Maintenance Schedule:**
```markdown
## Documentation Maintenance Calendar

**Monthly (1st Tuesday):**
- Review for minor updates and corrections
- Update version numbers and metrics
- Check for broken links

**Quarterly (Start of quarter):**
- Comprehensive section-by-section review
- Update roadmap and priorities
- Architecture decision review

**After incidents:**
- Update limitations and lessons learned
- Document new monitoring or alerting
- Revise disaster recovery procedures
```

### Avoiding Over/Under Documentation

**Over-Documentation Warning Signs:**
- Documentation takes longer to read than to understand the code
- Multiple documents covering the same concepts
- Detailed documentation for simple, standard patterns
- Documentation updated more often than the system itself

**Under-Documentation Warning Signs:**
- New team members need >1 week to understand system basics
- Frequent questions about basic system operation
- No clear system boundaries or component responsibilities
- Architectural decisions made without documented rationale

**Right-Sizing Guidelines:**
- **Core Architecture**: Always document fully
- **Standard Patterns**: Document deviations, not standard usage
- **Implementation Details**: Document non-obvious or critical patterns only
- **Configuration**: Document all required settings and non-obvious options

---

## Integration with Other Docs

### Document Hierarchy

```
📁 docs/
├── 📄 README.md                    # Project overview and quick start
├── 📄 ARCHITECTURE.md              # System design and components (THIS DOC)
├── 📄 API.md                       # API reference and examples
├── 📄 DEPLOYMENT.md                # Deployment procedures and infrastructure
├── 📄 CONTRIBUTING.md              # Development workflow and standards
├── 📄 CHANGELOG.md                 # Version history and breaking changes
├── 📁 adr/                         # Architecture Decision Records
│   ├── 📄 001-database-choice.md
│   ├── 📄 002-frontend-framework.md
│   └── 📄 template.md
├── 📁 runbooks/                    # Operational procedures
│   ├── 📄 incident-response.md
│   ├── 📄 deployment-procedures.md
│   └── 📄 monitoring-alerts.md
└── 📁 guides/                      # How-to guides and tutorials
    ├── 📄 local-development.md
    ├── 📄 testing-guide.md
    └── 📄 onboarding.md
```

### Cross-Referencing Standards

**From Architecture Doc TO Other Docs:**
```markdown
## Detailed References

**Implementation Details**: See [API Documentation](API.md) for endpoint specifications
**Deployment Procedures**: See [Deployment Guide](DEPLOYMENT.md) for step-by-step deployment
**Development Setup**: See [Contributing Guide](CONTRIBUTING.md) for local environment setup
**Operational Procedures**: See [Runbooks](runbooks/) for incident response and maintenance
```

**FROM Other Docs TO Architecture Doc:**
```markdown
# API Documentation

## System Context
This API is part of the larger system architecture described in [ARCHITECTURE.md](ARCHITECTURE.md#api-gateway).

## Authentication
Uses JWT-based authentication as described in [Architecture - Security](ARCHITECTURE.md#security-architecture).
```

### Avoiding Documentation Duplication

**Single Source of Truth Principle:**
- **Architecture Doc**: High-level design, component relationships, major decisions
- **API Doc**: Endpoint specifications, request/response formats, authentication details  
- **Deployment Doc**: Infrastructure setup, environment configuration, deployment procedures
- **Runbooks**: Operational procedures, incident response, troubleshooting steps

**Linking Strategy:**
```markdown
<!-- In Architecture Doc -->
## Database Architecture
Our PostgreSQL database uses multi-tenant row-level security. For detailed schema information and migration procedures, see [Database Schema Guide](guides/database-schema.md).

<!-- In Database Schema Guide -->  
# Database Schema Guide
This document provides implementation details for the database architecture described in [ARCHITECTURE.md](../ARCHITECTURE.md#data-architecture).
```

**Content Ownership Matrix:**
| Content Type | Primary Doc | Secondary References |
|--------------|-------------|---------------------|
| System Components | ARCHITECTURE.md | README.md (overview) |
| API Endpoints | API.md | ARCHITECTURE.md (integration points) |
| Database Schema | Database Guide | ARCHITECTURE.md (high-level design) |
| Deployment Steps | DEPLOYMENT.md | ARCHITECTURE.md (infrastructure overview) |
| Config Variables | Environment Guide | ARCHITECTURE.md (major settings) |

### Documentation Review Integration

**PR Template Addition:**
```markdown
## Architecture Impact Checklist
- [ ] No architectural changes (skip remaining checklist)
- [ ] New components added - update system overview diagram
- [ ] External dependencies added - update integration architecture  
- [ ] Database schema changed - update data architecture section
- [ ] Major technology decisions made - add new ADR
- [ ] Performance characteristics changed - update limitations section
- [ ] Infrastructure requirements changed - update deployment architecture
```

**Architecture Review Meeting Agenda:**
```markdown
# Monthly Architecture Review - [Date]

## 1. Documentation Drift Assessment (15 min)
- Recent changes not reflected in architecture doc
- Outdated diagrams or component descriptions
- Missing architectural decisions

## 2. New Architecture Decisions (20 min)
- Recent technology choices needing documentation
- Trade-offs and alternatives considered
- Impact on existing architecture

## 3. Forward-Looking Updates (15 min)
- Upcoming changes requiring architecture updates
- Planned technology migrations or upgrades
- Capacity and scaling considerations

## 4. Documentation Quality (10 min)
- Feedback from new team member onboarding
- Sections needing clarification or examples
- Process improvements for maintenance

## Action Items
- [ ] [Owner] [Description] [Due Date]
```

---

## Conclusion

This SOP provides a comprehensive framework for creating and maintaining excellent architecture documentation. The key to success is:

1. **Start with your audience** - Write for the people who need to understand and use your system
2. **Keep it current** - Build documentation updates into your development workflow  
3. **Focus on decisions** - Explain not just what you built, but why you built it that way
4. **Use progressive disclosure** - Provide overview first, details on demand
5. **Make it actionable** - Include enough detail for someone to actually use the information

Remember: **Good architecture documentation is a force multiplier for your entire engineering organization**. The time invested in clear, current, and comprehensive documentation pays dividends in faster onboarding, better architectural decisions, and more confident system evolution.

**Questions or suggestions for this SOP?** Open an issue or submit a pull request - great documentation is always evolving!