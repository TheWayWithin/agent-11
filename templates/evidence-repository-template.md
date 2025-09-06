# Evidence Repository

## Mission: [MISSION_CODE]
**Purpose**: Centralized collection of all artifacts, screenshots, and supporting materials for the mission

## Screenshots & Visual Evidence

### UI/UX Screenshots
| Timestamp | Agent | Description | File/Location | Notes |
|-----------|-------|-------------|---------------|-------|
| [TIME] | @designer | Homepage layout | `/screenshots/homepage-v1.png` | Initial design concept |
| [TIME] | @tester | Bug reproduction | `/screenshots/bug-auth-error.png` | Shows error state |

### Performance Metrics
| Timestamp | Agent | Metric | Value | Evidence | Notes |
|-----------|-------|--------|-------|----------|-------|
| [TIME] | @operator | Load time | 2.3s | `/perf/lighthouse-report.html` | Baseline measurement |
| [TIME] | @developer | API response | 150ms | `/logs/api-benchmark.json` | After optimization |

## Code Snippets & Examples

### Critical Code Sections
```javascript
// Location: src/auth/handler.js
// Added by: @developer
// Purpose: Authentication flow fix
// Timestamp: [TIME]

function authenticateUser(credentials) {
  // Critical implementation that affects multiple components
  // This pattern is used throughout the authentication system
  ...
}
```

### Configuration Changes
```yaml
# Location: config/production.yml
# Modified by: @operator
# Purpose: Performance tuning
# Timestamp: [TIME]

database:
  pool_size: 20  # Increased from 10
  timeout: 5000  # Reduced from 10000
```

## Test Results

### Automated Test Runs
| Timestamp | Agent | Test Suite | Results | Report Location | Notes |
|-----------|-------|------------|---------|-----------------|-------|
| [TIME] | @tester | Unit tests | 48/50 PASS | `/reports/unit-test-001.xml` | 2 known failures |
| [TIME] | @tester | E2E tests | 15/15 PASS | `/reports/e2e-test-001.html` | All green |

### Manual Testing Evidence
| Timestamp | Agent | Test Case | Result | Evidence | Notes |
|-----------|-------|-----------|--------|----------|-------|
| [TIME] | @tester | Login flow | PASS | Video: `/recordings/login-test.mp4` | Tested edge cases |
| [TIME] | @designer | Mobile responsive | FAIL | Screenshots: `/screenshots/mobile-issues/` | Layout breaks at 320px |

## API Responses & Data Samples

### API Response Examples
```json
// Endpoint: GET /api/users
// Captured by: @developer
// Timestamp: [TIME]
// Purpose: Document current response structure

{
  "users": [
    {
      "id": "123",
      "name": "Example User",
      "created_at": "2024-01-15T10:00:00Z"
    }
  ],
  "pagination": {
    "total": 100,
    "page": 1
  }
}
```

### Database Queries
```sql
-- Query for performance issue investigation
-- Captured by: @analyst
-- Timestamp: [TIME]
-- Execution time: 2.5s (needs optimization)

SELECT u.*, COUNT(o.id) as order_count 
FROM users u 
LEFT JOIN orders o ON u.id = o.user_id 
GROUP BY u.id 
HAVING order_count > 10;
```

## Error Logs & Stack Traces

### Production Errors
```
Error ID: ERR_001
Timestamp: [TIME]
Captured by: @support
Frequency: 15 times in last hour

Stack Trace:
TypeError: Cannot read property 'id' of undefined
    at processUser (src/handlers/user.js:45:23)
    at async handleRequest (src/middleware/auth.js:12:5)
    ...

Context: Happens when user session expires during checkout
```

## External Resources

### Documentation References
| Resource | URL/Location | Relevant To | Added By | Notes |
|----------|--------------|-------------|----------|-------|
| API Docs | `https://api.service.com/docs` | Integration | @architect | v2.0 breaking changes |
| Design System | `/docs/design-system.md` | UI components | @designer | Component library reference |

### Third-party Service Responses
```json
// Service: Payment Gateway
// Captured by: @developer
// Timestamp: [TIME]
// Purpose: Document integration response format

{
  "transaction_id": "txn_1234567",
  "status": "success",
  "amount": 9999,
  "currency": "USD",
  "metadata": {
    "customer_id": "cust_abc123"
  }
}
```

## Decisions & Rationale

### Architecture Decisions
| Decision | Rationale | Evidence | Made By | Timestamp |
|----------|-----------|----------|---------|-----------|
| Use PostgreSQL | Better JSON support needed | Benchmark: `/benchmarks/db-comparison.md` | @architect | [TIME] |
| Implement caching | Reduce API load by 60% | Metrics: `/metrics/before-after-cache.png` | @operator | [TIME] |

## Meeting Notes & Communications

### Stakeholder Feedback
```
Date: [DATE]
Participants: @strategist, @marketer, Client Team
Key Points:
- Feature X is critical for Q2 launch
- Performance must be under 2s load time
- Mobile experience is priority

Action Items:
- @developer: Implement Feature X by [date]
- @operator: Set up performance monitoring
```

## File Change History

### Critical File Modifications
| File | Agent | Change Type | Timestamp | Backup Location | Rollback Commands |
|------|-------|-------------|-----------|-----------------|-------------------|
| `src/core/auth.js` | @developer | Security fix | [TIME] | `/backups/auth-backup-001.js` | `git checkout abc123 src/core/auth.js` |
| `config/prod.yml` | @operator | Config update | [TIME] | `/backups/prod-yml-001.yml` | `cp /backups/prod-yml-001.yml config/prod.yml` |

## Quality Metrics

### Code Quality
- Coverage: 78% (screenshot: `/metrics/coverage-report.png`)
- Complexity: Average 3.2 (report: `/metrics/complexity-analysis.html`)
- Linting: 0 errors, 15 warnings (log: `/reports/eslint-output.txt`)

### Performance Benchmarks
- Load time: 1.8s (Lighthouse: `/reports/lighthouse-latest.html`)
- API response: 120ms average (Grafana: `/screenshots/api-metrics.png`)
- Database queries: All under 100ms (Query log: `/logs/slow-query.log`)

---
*This repository contains all evidence and artifacts from the mission. Each entry should include timestamp, agent, and location for full traceability.*