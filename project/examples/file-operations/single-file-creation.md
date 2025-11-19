# Example: Single File Creation

## Overview

This example demonstrates the Sprint 2 file persistence pattern for creating a single file. We'll walk through creating architecture documentation for an authentication service, showing the complete workflow from user request to automatic verification.

## Scenario

**User Goal**: Create comprehensive architecture documentation for the authentication service in a new SaaS application.

**Context**: The user is starting a new project and needs to document the authentication architecture before implementation begins. This is a common kickoff task in the dev-setup or dev-alignment missions.

**File to Create**: `/docs/architecture/auth-service.md`

---

## Complete Workflow

### Step 1: User Delegates to Coordinator

User invokes the coordinator with a clear request:

```
/coord "Create architecture documentation for our authentication service.
It should cover JWT-based auth, refresh tokens, OAuth2 integration with
Google/GitHub, and our password policy."
```

### Step 2: Coordinator Delegates to Specialist

The coordinator analyzes the request and delegates to @architect with Sprint 2 structured prompt:

```python
Task(
  subagent_type="architect",
  description="Create authentication service architecture documentation",
  prompt="""Create architecture documentation for authentication service.

  REQUIREMENTS:
  - JWT-based authentication with access/refresh tokens
  - OAuth2 integration (Google, GitHub providers)
  - Password policy and security best practices
  - Session management and token rotation
  - Security considerations and threat model

  OUTPUT FORMAT (JSON only):
  {
    "file_operations": [
      {
        "operation": "create",
        "file_path": "/absolute/path/to/file.md",
        "content": "COMPLETE file content here",
        "description": "Brief description of file",
        "verify_content": true
      }
    ],
    "specialist_summary": "Brief summary of what was created"
  }

  File path: /Users/jamiewatters/DevProjects/my-saas-app/docs/architecture/auth-service.md

  Provide ONLY valid JSON. I will parse and execute automatically.
  """
)
```

### Step 3: Specialist Returns Structured JSON

The @architect agent analyzes requirements and returns complete JSON:

```json
{
  "file_operations": [
    {
      "operation": "create",
      "file_path": "/Users/jamiewatters/DevProjects/my-saas-app/docs/architecture/auth-service.md",
      "content": "# Authentication Service Architecture\n\n## Overview\n\nThe authentication service provides secure user authentication and authorization for the SaaS platform. It implements industry-standard JWT-based authentication with OAuth2 social login integration.\n\n## Architecture Components\n\n### 1. Authentication Flow\n\n```mermaid\nsequenceDiagram\n    participant User\n    participant Frontend\n    participant AuthService\n    participant Database\n    participant OAuthProvider\n\n    User->>Frontend: Login Request\n    Frontend->>AuthService: POST /auth/login\n    AuthService->>Database: Verify Credentials\n    Database-->>AuthService: User Data\n    AuthService-->>Frontend: Access Token + Refresh Token\n    Frontend->>Frontend: Store Tokens\n```\n\n### 2. Token Management\n\n**Access Tokens**:\n- **Type**: JWT (JSON Web Token)\n- **Lifetime**: 15 minutes\n- **Payload**: User ID, email, roles, permissions\n- **Signature**: HMAC SHA256 with secret key\n\n**Refresh Tokens**:\n- **Type**: Opaque token (UUID v4)\n- **Lifetime**: 30 days\n- **Storage**: Database with user association\n- **Rotation**: New refresh token issued on each use\n\n**Token Structure**:\n```json\n{\n  \"access_token\": {\n    \"header\": {\n      \"alg\": \"HS256\",\n      \"typ\": \"JWT\"\n    },\n    \"payload\": {\n      \"sub\": \"user-uuid\",\n      \"email\": \"user@example.com\",\n      \"roles\": [\"user\", \"premium\"],\n      \"permissions\": [\"read:profile\", \"write:profile\"],\n      \"iat\": 1704067200,\n      \"exp\": 1704068100\n    }\n  },\n  \"refresh_token\": \"550e8400-e29b-41d4-a716-446655440000\"\n}\n```\n\n[... complete authentication architecture content continues ...]",
      "description": "Architecture documentation for authentication service with JWT, OAuth2, and security best practices",
      "verify_content": true
    }
  ],
  "specialist_summary": "Created comprehensive authentication service architecture documentation covering JWT implementation, OAuth2 integration, password policies, session management, token rotation, security considerations, and implementation guidelines."
}
```

### Step 4: Coordinator Automatic Execution

Coordinator parses JSON and executes file operation:

```python
import json

# Parse specialist response
response = json.loads(specialist_output)

# Execute file operations
for op in response['file_operations']:
    if op['operation'] == 'create':
        write_file(
            path=op['file_path'],
            content=op['content']
        )
```

**No manual intervention required**. Coordinator executes automatically.

### Step 5: Automatic Verification

Coordinator verifies file creation:

```bash
$ ls -lh /Users/jamiewatters/DevProjects/my-saas-app/docs/architecture/auth-service.md
-rw-r--r--  1 jamie  staff   8.2K Jan 12 14:23 auth-service.md

$ head -n 10 /Users/jamiewatters/DevProjects/my-saas-app/docs/architecture/auth-service.md
# Authentication Service Architecture

## Overview

The authentication service provides secure user authentication and authorization for the SaaS platform. It implements industry-standard JWT-based authentication with OAuth2 social login integration.

## Architecture Components

### 1. Authentication Flow
```

**Verification Status**: ✅ File exists, content verified

### Step 6: Automatic Logging

Coordinator updates progress.md:

```markdown
### [2024-01-12 14:23] Architecture Documentation Created

**Deliverable**: Authentication service architecture documentation
**File**: `/docs/architecture/auth-service.md` (8.2K)
**Specialist**: @architect

**Content**:
- JWT-based authentication with access/refresh tokens
- OAuth2 integration (Google, GitHub)
- Password policy and Argon2 hashing
- Session management with Redis
- Token rotation and security considerations
- Complete API endpoint specifications
- Database schema with audit logging
- Implementation checklist and references

**Verification**: ✅ File created and content verified at 2024-01-12 14:23:45
```

### Step 7: Coordinator Response to User

```
✅ Authentication service architecture documentation created successfully.

File: /docs/architecture/auth-service.md (8.2K)

The documentation includes:
- JWT token management (15min access, 30 day refresh)
- OAuth2 integration with Google and GitHub
- Argon2 password hashing with security parameters
- Session management using Redis
- Token rotation with reuse detection
- Security considerations and threat model
- Complete API endpoints and database schema
- Implementation checklist

Next steps:
1. Review the security requirements
2. Set up OAuth2 applications with providers
3. Configure JWT signing keys
4. Begin implementation of auth service

Ready to proceed with implementation?
```

---

## Key Observations

### Zero Manual Steps
- User makes single request
- Coordinator handles all execution
- Automatic verification
- Automatic logging
- User gets immediate confirmation

### Architectural Guarantee
- Specialist cannot skip file operations
- JSON structure enforces completeness
- Coordinator verifies before marking complete
- File persistence guaranteed by architecture

### Efficiency
- Single round-trip (user → coordinator → specialist → done)
- No back-and-forth verification loops
- No manual "please check if file exists" steps
- No manual progress.md updates

---

## Sprint 1 vs Sprint 2 Comparison

### Sprint 1 Workflow (BROKEN)

```
1. User: "Create auth docs"
2. Coordinator → @architect via Task tool
3. @architect: "I've created auth-service.md with [describes content]"
4. Coordinator: "Great! ✅"
5. User checks filesystem: File doesn't exist
6. User: "The file wasn't created"
7. Coordinator: "Let me check... you're right"
8. Coordinator manually creates file from architect's description
9. Coordinator verifies with ls
10. Coordinator manually updates progress.md
11. Finally done

Problem: 11 steps, manual intervention required, file persistence not guaranteed
```

### Sprint 2 Workflow (FIXED)

```
1. User: "Create auth docs"
2. Coordinator → @architect with structured prompt
3. @architect returns JSON with complete file content
4. Coordinator auto-executes Write tool
5. Coordinator auto-verifies with ls/head
6. Coordinator auto-logs to progress.md
7. Coordinator confirms to user with details

Result: 7 steps, zero manual intervention, architectural guarantee
```

### Improvement Metrics

- **Steps reduced**: 11 → 7 (36% reduction)
- **Manual interventions**: 4 → 0 (100% elimination)
- **File persistence**: 0% → 100% reliability
- **User wait time**: ~5 minutes → ~30 seconds
- **Coordinator cognitive load**: High → Minimal

---

## When to Use This Pattern

**Ideal for**:
- Architecture documentation
- Configuration files
- README creation
- Component scaffolding
- API documentation
- Any single-file deliverable

**Benefits**:
- Simplest pattern to understand
- Fast execution
- Clear success/failure
- Easy to verify
- Low cognitive overhead

**Next**: See `multiple-files.md` for batch operations pattern.
