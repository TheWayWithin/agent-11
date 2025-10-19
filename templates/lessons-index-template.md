# Lessons Learned Index

**Project**: [Project Name]
**Created**: [YYYY-MM-DD]
**Last Updated**: [YYYY-MM-DD]
**Total Lessons**: [X]

---

## 📚 Quick Navigation

- [By Category](#by-category)
- [By Severity](#by-severity)
- [By Frequency](#by-frequency)
- [Recent Lessons](#recent-lessons)
- [Search Guide](#search-guide)

---

## By Category

### 🔧 Technical Lessons ([X] total)

#### Authentication & Security ([X] lessons)
- **L-SEC-001**: [JWT Token Refresh Implementation] - `critical`
  - **Problem**: Users logged out unexpectedly after 5 minutes
  - **Solution**: Implement refresh token rotation with localStorage
  - **Keywords**: `authentication`, `jwt`, `token-refresh`, `session-management`
  - **File**: `lessons/security/jwt-token-refresh.md`
  - **Applied**: [X] times in [X] missions

- **L-SEC-002**: [CSP strict-dynamic with Third-Party Scripts] - `high`
  - **Problem**: Analytics scripts blocked by Content Security Policy
  - **Solution**: Use nonce-based script loading with strict-dynamic
  - **Keywords**: `csp`, `security`, `xss-prevention`, `third-party-scripts`
  - **File**: `lessons/security/csp-strict-dynamic.md`
  - **Applied**: [X] times

#### Database & Data Persistence ([X] lessons)
- **L-DB-001**: [Postgres Connection Pooling for Serverless] - `critical`
  - **Problem**: Database connection exhaustion in serverless environment
  - **Solution**: Use connection pooling with pgBouncer or Supabase pooling
  - **Keywords**: `postgres`, `connection-pooling`, `serverless`, `database`
  - **File**: `lessons/technical/postgres-connection-pooling.md`
  - **Applied**: [X] times

#### API Design & Integration ([X] lessons)
- **L-API-001**: [REST API Error Handling Patterns] - `high`
  - **Problem**: Inconsistent error responses across endpoints
  - **Solution**: Standardized error response format with error codes
  - **Keywords**: `api`, `error-handling`, `rest`, `standardization`
  - **File**: `lessons/technical/api-error-handling.md`
  - **Applied**: [X] times

#### Frontend Performance ([X] lessons)
- **L-FE-001**: [React Component Lazy Loading] - `medium`
  - **Problem**: Initial bundle size too large (>1MB)
  - **Solution**: Code-splitting with React.lazy() and Suspense
  - **Keywords**: `react`, `performance`, `lazy-loading`, `code-splitting`
  - **File**: `lessons/performance/react-lazy-loading.md`
  - **Applied**: [X] times

---

### 📋 Process Lessons ([X] total)

#### Testing & QA ([X] lessons)
- **L-PROC-001**: [Test Data Management Strategy] - `high`
  - **Problem**: Tests failing due to shared test data conflicts
  - **Solution**: Isolated test data per test with cleanup hooks
  - **Keywords**: `testing`, `test-data`, `isolation`, `cleanup`
  - **File**: `lessons/process/test-data-management.md`
  - **Applied**: [X] times

#### Deployment & DevOps ([X] lessons)
- **L-OPS-001**: [Zero-Downtime Deployment Pattern] - `critical`
  - **Problem**: Service interruption during deployments
  - **Solution**: Blue-green deployment with health checks
  - **Keywords**: `deployment`, `devops`, `zero-downtime`, `blue-green`
  - **File**: `lessons/process/zero-downtime-deployment.md`
  - **Applied**: [X] times

#### Code Review ([X] lessons)
- **L-PROC-002**: [Security-First Code Review Checklist] - `critical`
  - **Problem**: Security issues missed in code reviews
  - **Solution**: Mandatory security checklist with automated scanning
  - **Keywords**: `code-review`, `security`, `checklist`, `automation`
  - **File**: `lessons/process/security-code-review.md`
  - **Applied**: [X] times

---

### 🏗️ Architectural Lessons ([X] total)

#### System Design ([X] lessons)
- **L-ARCH-001**: [Microservices vs Monolith Decision Framework] - `critical`
  - **Problem**: Premature microservices causing complexity overhead
  - **Solution**: Start monolith, extract services based on team/domain boundaries
  - **Keywords**: `architecture`, `microservices`, `monolith`, `decision-framework`
  - **File**: `lessons/architectural/microservices-decision.md`
  - **Applied**: [X] times

#### Data Architecture ([X] lessons)
- **L-ARCH-002**: [Event Sourcing for Audit Requirements] - `high`
  - **Problem**: Unable to reconstruct data history for compliance
  - **Solution**: Event sourcing pattern with event store
  - **Keywords**: `architecture`, `event-sourcing`, `audit`, `compliance`
  - **File**: `lessons/architectural/event-sourcing-audit.md`
  - **Applied**: [X] times

#### Integration Patterns ([X] lessons)
- **L-ARCH-003**: [API Gateway Pattern for Microservices] - `high`
  - **Problem**: Frontend managing multiple service endpoints
  - **Solution**: API gateway for routing and aggregation
  - **Keywords**: `architecture`, `api-gateway`, `microservices`, `integration`
  - **File**: `lessons/architectural/api-gateway-pattern.md`
  - **Applied**: [X] times

---

### 🔒 Security Lessons ([X] total)

#### Authentication & Authorization ([X] lessons)
- **L-SEC-003**: [OAuth 2.0 PKCE for SPAs] - `critical`
  - **Problem**: Authorization code interception in single-page apps
  - **Solution**: Use PKCE (Proof Key for Code Exchange) flow
  - **Keywords**: `oauth`, `pkce`, `spa`, `security`, `authentication`
  - **File**: `lessons/security/oauth-pkce-spa.md`
  - **Applied**: [X] times

#### Data Protection ([X] lessons)
- **L-SEC-004**: [Encryption at Rest for PII] - `critical`
  - **Problem**: Unencrypted personally identifiable information in database
  - **Solution**: Field-level encryption with key rotation
  - **Keywords**: `encryption`, `pii`, `data-protection`, `compliance`
  - **File**: `lessons/security/encryption-at-rest.md`
  - **Applied**: [X] times

#### Vulnerability Prevention ([X] lessons)
- **L-SEC-005**: [SQL Injection Prevention Patterns] - `critical`
  - **Problem**: Potential SQL injection via user input
  - **Solution**: Parameterized queries and ORM usage
  - **Keywords**: `sql-injection`, `security`, `parameterized-queries`, `orm`
  - **File**: `lessons/security/sql-injection-prevention.md`
  - **Applied**: [X] times

---

### ⚡ Performance Lessons ([X] total)

#### Database Performance ([X] lessons)
- **L-PERF-001**: [Database Indexing Strategy] - `high`
  - **Problem**: Slow queries on large tables
  - **Solution**: Strategic indexing based on query patterns
  - **Keywords**: `database`, `indexing`, `performance`, `optimization`
  - **File**: `lessons/performance/database-indexing.md`
  - **Applied**: [X] times

#### Caching Strategies ([X] lessons)
- **L-PERF-002**: [Redis Caching for API Responses] - `high`
  - **Problem**: High latency on frequently accessed data
  - **Solution**: Redis cache with TTL and invalidation strategy
  - **Keywords**: `caching`, `redis`, `performance`, `api`
  - **File**: `lessons/performance/redis-caching.md`
  - **Applied**: [X] times

#### Frontend Optimization ([X] lessons)
- **L-PERF-003**: [Image Optimization Pipeline] - `medium`
  - **Problem**: Large images causing slow page loads
  - **Solution**: Automated image compression and WebP conversion
  - **Keywords**: `images`, `optimization`, `webp`, `performance`
  - **File**: `lessons/performance/image-optimization.md`
  - **Applied**: [X] times

---

### 💬 Communication Lessons ([X] total)

#### Team Coordination ([X] lessons)
- **L-COMM-001**: [Context Preservation in Handoffs] - `critical`
  - **Problem**: Work lost between specialist handoffs
  - **Solution**: Mandatory handoff-notes.md updates before task completion
  - **Keywords**: `handoff`, `context`, `coordination`, `documentation`
  - **File**: `lessons/communication/context-handoffs.md`
  - **Applied**: [X] times

#### Documentation ([X] lessons)
- **L-COMM-002**: [Architecture Decision Records (ADRs)] - `high`
  - **Problem**: Forgotten rationale for technical decisions
  - **Solution**: Document decisions with context and alternatives
  - **Keywords**: `adr`, `documentation`, `decisions`, `rationale`
  - **File**: `lessons/communication/architecture-decision-records.md`
  - **Applied**: [X] times

---

## By Severity

### 🔴 Critical (Must Know) - [X] lessons

Lessons that prevent major failures or security breaches:

1. **L-SEC-001** - JWT Token Refresh Implementation
2. **L-DB-001** - Postgres Connection Pooling for Serverless
3. **L-OPS-001** - Zero-Downtime Deployment Pattern
4. **L-ARCH-001** - Microservices vs Monolith Decision Framework
5. **L-SEC-003** - OAuth 2.0 PKCE for SPAs
6. **L-SEC-004** - Encryption at Rest for PII
7. **L-SEC-005** - SQL Injection Prevention Patterns
8. **L-PROC-002** - Security-First Code Review Checklist
9. **L-COMM-001** - Context Preservation in Handoffs

[View all critical lessons →](lessons/by-severity/critical.md)

---

### 🟡 High (Should Know) - [X] lessons

Lessons that improve quality and prevent common issues:

1. **L-SEC-002** - CSP strict-dynamic with Third-Party Scripts
2. **L-API-001** - REST API Error Handling Patterns
3. **L-PROC-001** - Test Data Management Strategy
4. **L-ARCH-002** - Event Sourcing for Audit Requirements
5. **L-ARCH-003** - API Gateway Pattern for Microservices
6. **L-PERF-001** - Database Indexing Strategy
7. **L-PERF-002** - Redis Caching for API Responses
8. **L-COMM-002** - Architecture Decision Records

[View all high-priority lessons →](lessons/by-severity/high.md)

---

### 🟢 Medium (Good to Know) - [X] lessons

Lessons that optimize performance and developer experience:

1. **L-FE-001** - React Component Lazy Loading
2. **L-PERF-003** - Image Optimization Pipeline

[View all medium-priority lessons →](lessons/by-severity/medium.md)

---

### 🔵 Low (Nice to Have) - [X] lessons

Lessons for edge cases and optimizations:

[View all low-priority lessons →](lessons/by-severity/low.md)

---

## By Frequency

### Common Issues (>5 occurrences)

Issues encountered frequently across missions:

1. **L-SEC-001** - JWT Token Refresh ([X] times)
2. **L-DB-001** - Postgres Connection Pooling ([X] times)
3. **L-PROC-001** - Test Data Management ([X] times)

### Occasional Issues (2-5 occurrences)

Issues seen occasionally:

1. **L-SEC-002** - CSP strict-dynamic ([X] times)
2. **L-PERF-001** - Database Indexing ([X] times)

### Rare Issues (<2 occurrences)

Issues rarely encountered:

1. **L-ARCH-002** - Event Sourcing ([X] times)

---

## Recent Lessons

### Last 30 Days

- **[YYYY-MM-DD]** - L-[CAT]-[NUM]: [Lesson Title]
  - **Discovered in**: [mission-name]
  - **Impact**: [Brief description]
  - **Status**: [New | Updated | Revalidated]

- **[YYYY-MM-DD]** - L-[CAT]-[NUM]: [Lesson Title]
  - **Discovered in**: [mission-name]
  - **Impact**: [Brief description]
  - **Status**: [New | Updated]

### Last 90 Days

[List of lessons from last 90 days]

---

## Search Guide

### Search by Keyword

Common keywords and where to find them:

**Authentication**:
- `authentication`, `jwt`, `oauth`, `pkce`, `session`
- Files: L-SEC-001, L-SEC-003

**Database**:
- `database`, `postgres`, `sql`, `connection-pooling`, `indexing`
- Files: L-DB-001, L-PERF-001, L-SEC-005

**Performance**:
- `performance`, `optimization`, `caching`, `lazy-loading`
- Files: L-PERF-001, L-PERF-002, L-PERF-003, L-FE-001

**Security**:
- `security`, `encryption`, `xss`, `sql-injection`, `csp`
- Files: L-SEC-001 through L-SEC-005

**Architecture**:
- `architecture`, `microservices`, `event-sourcing`, `api-gateway`
- Files: L-ARCH-001, L-ARCH-002, L-ARCH-003

### Search Commands

```bash
# Search all lessons for keyword
grep -r "keyword" lessons/

# Find lessons by category
ls lessons/security/

# Find critical lessons
grep "Severity: Critical" lessons/**/*.md

# Find recent lessons (last modified)
ls -lt lessons/**/*.md | head -10

# Search by keyword in filenames
find lessons/ -name "*authentication*.md"

# Full-text search in lesson content
grep -r "root cause" lessons/ -l

# Find lessons applied in specific mission
grep "mission-name" lessons/**/*.md
```

### Quick Keyword Index

- **authentication**: L-SEC-001, L-SEC-003
- **api**: L-API-001, L-ARCH-003, L-PERF-002
- **caching**: L-PERF-002
- **csp**: L-SEC-002
- **database**: L-DB-001, L-PERF-001, L-SEC-005
- **deployment**: L-OPS-001
- **encryption**: L-SEC-004
- **event-sourcing**: L-ARCH-002
- **indexing**: L-PERF-001
- **jwt**: L-SEC-001
- **microservices**: L-ARCH-001, L-ARCH-003
- **oauth**: L-SEC-003
- **performance**: L-PERF-001, L-PERF-002, L-PERF-003, L-FE-001
- **postgres**: L-DB-001
- **react**: L-FE-001
- **redis**: L-PERF-002
- **security**: L-SEC-001 through L-SEC-005, L-PROC-002
- **sql-injection**: L-SEC-005
- **testing**: L-PROC-001
- **zero-downtime**: L-OPS-001

---

## Statistics

### Lessons by Category
- **Technical**: [X] lessons ([Y]%)
- **Process**: [X] lessons ([Y]%)
- **Architectural**: [X] lessons ([Y]%)
- **Security**: [X] lessons ([Y]%)
- **Performance**: [X] lessons ([Y]%)
- **Communication**: [X] lessons ([Y]%)

### Lessons by Severity
- **Critical**: [X] lessons ([Y]%)
- **High**: [X] lessons ([Y]%)
- **Medium**: [X] lessons ([Y]%)
- **Low**: [X] lessons ([Y]%)

### Application Rate
- **Frequently Applied** (>5 times): [X] lessons
- **Occasionally Applied** (2-5 times): [X] lessons
- **Rarely Applied** (<2 times): [X] lessons
- **Never Applied** (0 times): [X] lessons

### Growth Over Time
- **Last 30 days**: [X] new lessons
- **Last 90 days**: [X] new lessons
- **Last 6 months**: [X] new lessons
- **All time**: [X] total lessons

---

## How to Add New Lessons

### Step-by-Step Process

1. **Create Lesson File**:
   ```bash
   # Use the lesson template
   cp templates/lesson-template.md lessons/[category]/[short-name].md
   ```

2. **Fill Out Lesson**:
   - Use template structure from `templates/lesson-template.md`
   - Assign Lesson ID: `L-[CATEGORY]-[NUMBER]`
   - Set severity: Critical, High, Medium, Low
   - Add 5+ relevant keywords
   - Link related issues from progress.md

3. **Update This Index**:
   - Add to appropriate category section
   - Add to severity section
   - Add to recent lessons
   - Update keywords index
   - Update statistics

4. **Cross-Reference**:
   - Link related lessons to each other
   - Reference in progress.md
   - Update CLAUDE.md if system-level learning

5. **Verify**:
   - Test search commands work
   - Verify file path correct
   - Check lesson ID unique
   - Confirm keywords added

### Lesson ID Format

`L-[CATEGORY]-[NUMBER]`

**Categories**:
- `SEC` - Security
- `DB` - Database
- `API` - API Design
- `FE` - Frontend
- `PROC` - Process
- `OPS` - Operations
- `ARCH` - Architecture
- `PERF` - Performance
- `COMM` - Communication

**Numbering**: Sequential within category (001, 002, 003, ...)

**Examples**:
- `L-SEC-001` - First security lesson
- `L-DB-002` - Second database lesson
- `L-ARCH-005` - Fifth architecture lesson

---

## Maintenance

### Regular Updates

**After Each Mission**:
- [ ] Extract lessons from progress.md
- [ ] Create lesson files for significant findings
- [ ] Update category sections
- [ ] Update severity sections
- [ ] Add to recent lessons
- [ ] Update statistics
- [ ] Update keyword index

**Monthly Review**:
- [ ] Review lesson application counts
- [ ] Identify lessons not being applied (why?)
- [ ] Update severity if lessons prove more/less critical
- [ ] Consolidate similar lessons
- [ ] Archive outdated lessons
- [ ] Improve search keywords

**Quarterly Audit**:
- [ ] Full content review of all lessons
- [ ] Update with new insights from missions
- [ ] Add related lessons cross-references
- [ ] Verify all file paths valid
- [ ] Check for duplicate lessons
- [ ] Update statistics and trends

### Quality Checks

- [ ] All lessons have unique IDs
- [ ] All lessons categorized correctly
- [ ] All lessons have severity assigned
- [ ] All lessons have 5+ keywords
- [ ] All lessons linked in index
- [ ] All file paths valid
- [ ] Search commands work
- [ ] Statistics up-to-date

---

## Related Documentation

- **templates/lesson-template.md** - Template for individual lessons
- **templates/progress-template.md** - Source of lessons (progress.md)
- **project/field-manual/project-lifecycle-guide.md** - Lesson extraction process
- **CLAUDE.md** - System-level learnings location

---

**Index Last Updated**: [YYYY-MM-DD]
**Total Lessons Indexed**: [X]
**Most Recent Lesson**: [Lesson ID and title]
**Next Review Due**: [YYYY-MM-DD]
