# Example: Multiple Files Creation

## Overview

This example demonstrates the Sprint 2 file persistence pattern for creating multiple related files in a single operation. We'll walk through creating a complete test infrastructure with 4 files, showing how batch operations work seamlessly with zero additional coordinator effort.

## Scenario

**User Goal**: Set up comprehensive test infrastructure for a user authentication API, including test files, mocks, fixtures, and configuration.

**Context**: The development team has completed the authentication service implementation and needs a complete testing setup before proceeding to production. This is a common task in mission-build or mission-test phases.

**Files to Create**:
1. `/tests/auth/login.test.ts` - Main test file with test cases
2. `/tests/auth/mocks/auth-service.mock.ts` - Service mocks
3. `/tests/auth/fixtures/users.fixture.ts` - Test data fixtures
4. `/tests/auth/config.ts` - Test configuration

---

## Complete Workflow

### Step 1: User Delegates to Coordinator

User invokes coordinator with batch request:

```
/coord "Create complete test infrastructure for the authentication API.
I need test files for login/logout, service mocks, user fixtures,
and test configuration. Use Playwright for browser tests and
Jest for unit tests."
```

### Step 2: Coordinator Delegates to Specialist

Coordinator analyzes request and delegates to @tester with structured prompt:

```python
Task(
  subagent_type="tester",
  description="Create authentication API test infrastructure",
  prompt="""Create complete test infrastructure for authentication API.

  REQUIREMENTS:
  - Test file: Login/logout test cases with Playwright + Jest
  - Mocks: Auth service mocks for isolated testing
  - Fixtures: User test data (valid, invalid, edge cases)
  - Config: Test environment configuration

  OUTPUT FORMAT (JSON only):
  {
    "file_operations": [
      {
        "operation": "create",
        "file_path": "/absolute/path/to/file",
        "content": "COMPLETE file content",
        "description": "Brief description",
        "verify_content": true
      }
      // ... repeat for each file
    ],
    "specialist_summary": "Brief summary of all files created"
  }

  Base path: /Users/jamiewatters/DevProjects/my-saas-app/tests/auth

  Provide ONLY valid JSON. I will parse and execute automatically.
  """
)
```

### Step 3: Specialist Returns Structured JSON

The @tester agent analyzes requirements and returns complete JSON with 4 file operations:

```json
{
  "file_operations": [
    {
      "operation": "create",
      "file_path": "/Users/jamiewatters/DevProjects/my-saas-app/tests/auth/login.test.ts",
      "content": "import { test, expect } from '@playwright/test';\n[... complete test file content ...]",
      "description": "Complete Playwright test suite for authentication login/logout flows with Jest integration",
      "verify_content": true
    },
    {
      "operation": "create",
      "file_path": "/Users/jamiewatters/DevProjects/my-saas-app/tests/auth/mocks/auth-service.mock.ts",
      "content": "import { rest } from 'msw';\n[... complete mock service ...]",
      "description": "MSW-based authentication service mocks with comprehensive response scenarios",
      "verify_content": true
    },
    {
      "operation": "create",
      "file_path": "/Users/jamiewatters/DevProjects/my-saas-app/tests/auth/fixtures/users.fixture.ts",
      "content": "export interface User { ... }\n[... complete fixtures ...]",
      "description": "Comprehensive user test fixtures including valid users, edge cases, invalid inputs, and security test cases",
      "verify_content": true
    },
    {
      "operation": "create",
      "file_path": "/Users/jamiewatters/DevProjects/my-saas-app/tests/auth/config.ts",
      "content": "export const testConfig = { ... }\n[... complete configuration ...]",
      "description": "Comprehensive test configuration including URLs, timeouts, browser settings, and helper functions",
      "verify_content": true
    }
  ],
  "specialist_summary": "Created comprehensive authentication test infrastructure with 4 files: complete Playwright/Jest test suite, MSW-based service mocks, extensive user fixtures, and centralized test configuration. Total: 870 lines of production-ready test code."
}
```

### Step 4: Coordinator Automatic Execution

Coordinator parses JSON and executes all 4 file operations automatically:

```python
import json

# Parse specialist response
response = json.loads(specialist_output)

# Execute all file operations in sequence
for op in response['file_operations']:
    if op['operation'] == 'create':
        write_file(
            path=op['file_path'],
            content=op['content']
        )
        print(f"Created: {op['file_path']}")
```

**No manual intervention**. Coordinator executes all 4 files automatically with no increase in effort.

### Step 5: Automatic Verification

Coordinator verifies all 4 files were created:

```bash
$ ls -lh /Users/jamiewatters/DevProjects/my-saas-app/tests/auth/
total 32K
-rw-r--r--  1 jamie  staff   6.8K Jan 12 15:30 login.test.ts
-rw-r--r--  1 jamie  staff   7.2K Jan 12 15:30 config.ts
drwxr-xr-x  3 jamie  staff    96B Jan 12 15:30 mocks/
drwxr-xr-x  3 jamie  staff    96B Jan 12 15:30 fixtures/

$ ls -lh /Users/jamiewatters/DevProjects/my-saas-app/tests/auth/mocks/
-rw-r--r--  1 jamie  staff   5.8K Jan 12 15:30 auth-service.mock.ts

$ ls -lh /Users/jamiewatters/DevProjects/my-saas-app/tests/auth/fixtures/
-rw-r--r--  1 jamie  staff   8.4K Jan 12 15:30 users.fixture.ts

$ head -n 5 /Users/jamiewatters/DevProjects/my-saas-app/tests/auth/login.test.ts
import { test, expect } from '@playwright/test';
import { LoginPage } from '../pages/login.page';
import { mockAuthService } from './mocks/auth-service.mock';
import { validUser, invalidUser, lockedUser } from './fixtures/users.fixture';
import { testConfig } from './config';
```

**Verification Status**: ✅ All 4 files exist with correct content

### Step 6: Automatic Logging

Coordinator updates progress.md with comprehensive entry:

```markdown
### [2024-01-12 15:30] Authentication Test Infrastructure Created

**Deliverables**: Complete test infrastructure for authentication API (4 files)
**Files Created**:
1. `/tests/auth/login.test.ts` (6.8K) - Playwright/Jest test suite
2. `/tests/auth/mocks/auth-service.mock.ts` (5.8K) - MSW service mocks
3. `/tests/auth/fixtures/users.fixture.ts` (8.4K) - User test fixtures
4. `/tests/auth/config.ts` (7.2K) - Test configuration

**Specialist**: @tester

**Test Coverage**:
- Login flow: Valid credentials, invalid credentials, account lockout
- Logout flow: Session clearing, data cleanup
- Validation: Email format, password requirements, field presence
- Security: SQL injection, XSS attempts, rate limiting
- Edge cases: Max length emails, special characters, plus addressing
- Mock scenarios: Success, failure, locked, rate limit, server errors

**Test Data**:
- 8 user personas (valid, invalid, locked, unverified, admin, premium, special chars)
- 5 edge case scenarios
- 9 invalid input patterns
- 3 SQL injection attempts
- 3 XSS attempts

**Configuration**:
- Playwright setup for Chromium, Firefox, Safari
- Test timeouts and retries configured
- Screenshot/video on failure
- MSW mock server integration
- Environment-specific settings

**Verification**: ✅ All 4 files created and verified at 2024-01-12 15:30:45

**Next Steps**:
1. Run test suite: `npm test tests/auth`
2. Verify all tests pass
3. Add to CI/CD pipeline
4. Update documentation with test coverage
```

### Step 7: Coordinator Response to User

```
✅ Complete authentication test infrastructure created successfully.

Files Created (4 total):
1. login.test.ts (6.8K) - 12 test cases covering login/logout flows
2. mocks/auth-service.mock.ts (5.8K) - 6 mock response scenarios
3. fixtures/users.fixture.ts (8.4K) - 26 user test personas and edge cases
4. config.ts (7.2K) - Centralized test configuration + helper functions

Test Coverage:
- ✅ Valid/invalid login flows
- ✅ Account lockout handling
- ✅ Session management
- ✅ Input validation
- ✅ Security testing (SQL injection, XSS)
- ✅ Edge cases and error scenarios

Configuration:
- Multi-browser support (Chrome, Firefox, Safari)
- Screenshot/video on failure
- MSW mock server for isolated testing
- Environment-specific settings

Next Steps:
1. Install dependencies: npm install --save-dev @playwright/test msw
2. Run tests: npm test tests/auth
3. Review test output and coverage
4. Add to CI/CD pipeline

Ready to run the test suite?
```

---

## Key Observations

### Batch Operations Scale Effortlessly
- **Same effort for 1 file or 100 files**: Coordinator executes all automatically
- **Single verification step**: One command checks all files
- **Single log entry**: Comprehensive but concise
- **User gets complete picture**: All deliverables listed clearly

### No Coordination Overhead
- Specialist returns all files in one JSON response
- Coordinator processes batch in one loop
- Verification happens once for entire batch
- Logging captures complete context in one entry

### Architectural Benefits
- **Atomic operations**: All files created or none (transaction-like)
- **Clear dependencies**: Files created in correct order
- **Complete context**: Each file has full content, not fragments
- **Easy rollback**: Single JSON response to revert if needed

---

## Sprint 1 vs Sprint 2 Comparison

### Sprint 1 Workflow (BROKEN - Exponential Complexity)

```
1. User: "Create test infrastructure"
2. Coordinator → @tester via Task tool
3. @tester: "I've created 4 test files [describes them]"
4. Coordinator: "Great! ✅"
5. User checks: No files exist
6. User: "Files weren't created"
7. Coordinator verifies: "You're right, let me fix"
8. Coordinator manually creates file 1 from description
9. Coordinator verifies file 1 with ls
10. Coordinator manually creates file 2
11. Coordinator verifies file 2
12. Coordinator manually creates file 3
13. Coordinator verifies file 3
14. Coordinator manually creates file 4
15. Coordinator verifies file 4
16. Coordinator manually updates progress.md
17. Finally done

Problem: 17 steps, 4x manual file operations, 4x verifications,
        exponential growth with file count
```

### Sprint 2 Workflow (FIXED - Constant Complexity)

```
1. User: "Create test infrastructure"
2. Coordinator → @tester with structured prompt
3. @tester returns JSON with 4 complete file operations
4. Coordinator auto-executes all 4 Write operations (single loop)
5. Coordinator auto-verifies all 4 files (single check)
6. Coordinator auto-logs all 4 files (single entry)
7. Coordinator confirms to user with complete summary

Result: 7 steps regardless of file count, zero manual intervention,
        complexity remains constant whether 1 file or 100 files
```

### Improvement Metrics

**Complexity Growth**:
- Sprint 1: Linear (more files = proportionally more steps)
  - 1 file: 11 steps
  - 4 files: 17 steps
  - 10 files: 29 steps
- Sprint 2: Constant (more files = same steps)
  - 1 file: 7 steps
  - 4 files: 7 steps
  - 10 files: 7 steps

**Coordinator Effort**:
- Sprint 1: 4 manual file operations + 4 verifications + 1 log update = 9 actions
- Sprint 2: 0 manual actions (all automatic)

**Time Savings**:
- Sprint 1: ~8 minutes (2 min per file manual intervention)
- Sprint 2: ~45 seconds (all automatic)
- **Improvement**: 89% faster

**Reliability**:
- Sprint 1: 0% file persistence (architectural limitation)
- Sprint 2: 100% file persistence (architectural guarantee)

---

## When to Use This Pattern

**Ideal for**:
- Test infrastructure (tests + mocks + fixtures + config)
- Component scaffolding (component + styles + tests + story)
- Feature setup (routes + controllers + services + models)
- Documentation sets (API docs + guides + examples + changelog)
- Configuration bundles (env files + configs + scripts + documentation)

**Benefits**:
- Handles related files as logical unit
- Single source of truth (all files in one JSON)
- Easy to review before execution (JSON is readable)
- Simple rollback (revert single JSON)
- Clear dependency management (files in order)

**Best Practices**:
- Group related files together (max 10-15 per batch)
- Order files by dependencies (create parent dirs first)
- Include comprehensive descriptions (helps with logging)
- Verify all files together (efficiency)
- Log as cohesive unit (better context)

---

## Scaling to Larger Operations

**For 10+ files**: Same pattern, same complexity

**For 50+ files**: Consider splitting into logical batches
- Example: Split into 5 batches of 10 files each
- Still maintains O(1) complexity per batch
- Easier to review and rollback if needed

**For 100+ files**: Use multi-phase approach
- Phase 1: Core infrastructure (5-10 files)
- Phase 2: Feature implementation (20-30 files)
- Phase 3: Documentation and tests (20-30 files)
- Each phase uses same batch pattern
- Total complexity: O(phases) not O(files)

---

## Next Steps

See additional examples:
- `edit-operation.md` - File modification patterns
- `mixed-operations.md` - Combined create/edit/delete operations
