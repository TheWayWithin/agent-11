# STANDARDS.md - Quality & Consistency Standards

*Authoritative guide for code quality, documentation, and operational standards in AGENT-11 projects*

## Code Quality Standards

### General Principles

1. **Readability > Cleverness**: Write code for humans first, computers second
2. **Explicit > Implicit**: Be clear about intentions and avoid magic
3. **Consistency > Personal Preference**: Follow project conventions
4. **Tested > Assumed Working**: All critical paths must have tests
5. **Documented > Self-Documenting**: Complex logic needs comments

### Language-Specific Standards

#### JavaScript/TypeScript

**File Organization**:
```javascript
// 1. Imports (grouped and sorted)
import React from 'react';
import { useEffect, useState } from 'react';

import { authService } from '@/services/auth';
import { Button } from '@/components/ui';

import type { User } from '@/types';

// 2. Type definitions
interface Props {
  user: User;
  onUpdate: (user: User) => void;
}

// 3. Constants
const MAX_RETRIES = 3;

// 4. Main component/function
export function UserProfile({ user, onUpdate }: Props) {
  // Implementation
}

// 5. Helper functions
function validateUser(user: User): boolean {
  // Validation logic
}
```

**Naming Conventions**:
- Components: PascalCase (UserProfile)
- Functions: camelCase (getUserData)
- Constants: UPPER_SNAKE_CASE (MAX_RETRIES)
- Files: kebab-case (user-profile.tsx)
- Interfaces: PascalCase with 'I' prefix optional

**Best Practices**:
- Use async/await over promises
- Prefer const over let
- Use optional chaining (?.)
- Implement proper error boundaries
- Never use any without justification

#### Python

**File Organization**:
```python
"""Module docstring describing purpose."""

# 1. Standard library imports
import os
import sys
from typing import List, Optional

# 2. Third-party imports
import requests
from fastapi import FastAPI

# 3. Local imports
from app.models import User
from app.services import auth_service

# 4. Constants
MAX_RETRIES = 3

# 5. Classes and functions
class UserService:
    """Service for user management."""
    
    def get_user(self, user_id: str) -> Optional[User]:
        """Get user by ID."""
        pass
```

**Naming Conventions**:
- Classes: PascalCase (UserService)
- Functions: snake_case (get_user_data)
- Constants: UPPER_SNAKE_CASE (MAX_RETRIES)
- Private: Leading underscore (_internal_method)

**Best Practices**:
- Use type hints always
- Docstrings for all public functions
- Follow PEP 8
- Use pathlib for file operations
- Handle exceptions explicitly

#### SQL

**Query Format**:
```sql
-- Clear, readable queries
SELECT 
    u.id,
    u.email,
    u.created_at,
    COUNT(o.id) as order_count
FROM 
    users u
    LEFT JOIN orders o ON u.id = o.user_id
WHERE 
    u.status = 'active'
    AND u.created_at >= '2024-01-01'
GROUP BY 
    u.id, u.email, u.created_at
ORDER BY 
    u.created_at DESC;
```

**Best Practices**:
- Use meaningful table aliases
- Uppercase SQL keywords
- One condition per line in WHERE
- Explicit JOIN types
- Comment complex logic

### Error Handling Standards

#### Error Response Format
```javascript
{
  "error": {
    "code": "AUTH_FAILED",
    "message": "Authentication failed",
    "details": "Invalid credentials provided",
    "timestamp": "2024-12-27T10:30:00Z",
    "requestId": "req_abc123"
  }
}
```

#### Error Handling Patterns
```javascript
// JavaScript/TypeScript
try {
  const result = await riskyOperation();
  return { success: true, data: result };
} catch (error) {
  logger.error('Operation failed', { error, context });
  
  // Specific error handling
  if (error instanceof ValidationError) {
    return { success: false, error: 'Invalid input', code: 'VALIDATION_ERROR' };
  }
  
  // Generic fallback
  return { success: false, error: 'Operation failed', code: 'UNKNOWN_ERROR' };
}
```

```python
# Python
try:
    result = risky_operation()
    return {"success": True, "data": result}
except ValidationError as e:
    logger.error(f"Validation failed: {e}")
    return {"success": False, "error": str(e), "code": "VALIDATION_ERROR"}
except Exception as e:
    logger.error(f"Operation failed: {e}")
    return {"success": False, "error": "Operation failed", "code": "UNKNOWN_ERROR"}
```

## Testing Standards

### Test Coverage Requirements

- **Critical Paths**: 100% coverage required
- **Business Logic**: >90% coverage
- **Utilities**: >80% coverage
- **UI Components**: >70% coverage
- **Experimental**: >50% coverage

### Test Organization

```
tests/
├── unit/           # Fast, isolated tests
├── integration/    # Component interaction tests
├── e2e/           # End-to-end user flows
└── fixtures/      # Test data and mocks
```

### Test Naming Convention

```javascript
describe('UserService', () => {
  describe('createUser', () => {
    it('should create a new user with valid data', async () => {
      // Test implementation
    });
    
    it('should throw ValidationError when email is invalid', async () => {
      // Test implementation
    });
    
    it('should handle database connection errors gracefully', async () => {
      // Test implementation
    });
  });
});
```

### Test Best Practices

1. **Arrange, Act, Assert** pattern
2. **One assertion per test** (when possible)
3. **Descriptive test names** that explain the scenario
4. **Mock external dependencies**
5. **Use fixtures for test data**
6. **Clean up after tests**

## Documentation Standards

### Code Comments

#### When to Comment
- Complex algorithms or business logic
- Non-obvious design decisions
- Workarounds or temporary fixes
- Performance optimizations
- Security considerations

#### Comment Format
```javascript
// Single line for brief explanations

/*
 * Multi-line for longer explanations
 * that need more context or detail
 */

/**
 * JSDoc for functions and classes
 * @param {string} userId - The user's ID
 * @returns {Promise<User>} The user object
 * @throws {NotFoundError} If user doesn't exist
 */
```

### API Documentation

#### Endpoint Documentation
```yaml
/api/users/{userId}:
  get:
    summary: Get user by ID
    parameters:
      - name: userId
        in: path
        required: true
        schema:
          type: string
    responses:
      200:
        description: User found
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/User'
      404:
        description: User not found
```

### README Structure

Every project must have a README with:

1. **Project Title & Description**
2. **Prerequisites & Requirements**
3. **Installation Instructions**
4. **Configuration Guide**
5. **Usage Examples**
6. **API Documentation** (or link to it)
7. **Testing Instructions**
8. **Deployment Guide**
9. **Contributing Guidelines**
10. **License Information**

## Security Standards

### Never Commit These

- API keys and secrets
- Database credentials
- Private certificates
- Personal information
- Internal URLs or IPs

### Security Best Practices

1. **Input Validation**: Always validate and sanitize user input
2. **Authentication**: Use proven libraries (JWT, OAuth2)
3. **Authorization**: Implement proper access controls
4. **Encryption**: Use HTTPS everywhere, encrypt sensitive data
5. **Dependencies**: Keep dependencies updated
6. **Logging**: Never log sensitive information
7. **Error Messages**: Don't expose system details

### Environment Variables

```bash
# .env.example (commit this)
DATABASE_URL=postgresql://user:pass@localhost/dbname
JWT_SECRET=your-secret-key-here
API_KEY=your-api-key-here

# .env (never commit this)
DATABASE_URL=postgresql://prod:actualpass@prod.db/proddb
JWT_SECRET=actual-secret-key
API_KEY=actual-api-key
```

## Performance Standards

### Response Time Targets

- API endpoints: <200ms p95
- Page load: <3s on 3G
- Database queries: <100ms
- Background jobs: <30s

### Optimization Priorities

1. **Measure first**: Profile before optimizing
2. **Optimize critical paths**: Focus on user-facing features
3. **Cache appropriately**: Use Redis/memory caching
4. **Batch operations**: Reduce N+1 queries
5. **Async when possible**: Don't block on I/O

## Git Standards

### Commit Messages

Format: `type(scope): description`

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting
- `refactor`: Code restructuring
- `test`: Testing
- `chore`: Maintenance

Examples:
```
feat(auth): add JWT refresh token support
fix(api): handle null user gracefully
docs(readme): update installation instructions
```

### Branch Naming

- Feature: `feature/user-authentication`
- Bugfix: `fix/login-error`
- Hotfix: `hotfix/security-patch`
- Release: `release/v1.2.0`

### Pull Request Standards

PR must include:
1. Clear title and description
2. Link to issue/ticket
3. Test results
4. Screenshots (if UI changes)
5. Breaking changes noted
6. Review checklist completed

## Monitoring Standards

### Required Metrics

1. **Application Metrics**:
   - Request rate
   - Error rate
   - Response time
   - Active users

2. **System Metrics**:
   - CPU usage
   - Memory usage
   - Disk I/O
   - Network traffic

3. **Business Metrics**:
   - Conversion rate
   - User engagement
   - Feature adoption
   - Revenue impact

### Logging Standards

```javascript
// Structured logging
logger.info('User action', {
  action: 'login',
  userId: user.id,
  timestamp: Date.now(),
  ip: request.ip,
  userAgent: request.headers['user-agent']
});

// Error logging
logger.error('Operation failed', {
  error: error.message,
  stack: error.stack,
  context: {
    userId: user.id,
    operation: 'updateProfile'
  }
});
```

### Alert Thresholds

- Error rate > 1%: Warning
- Error rate > 5%: Critical
- Response time > 1s: Warning
- Response time > 3s: Critical
- CPU > 80%: Warning
- Memory > 90%: Critical

## Review Checklist

Before marking any task complete, verify:

- [ ] Code follows style guidelines
- [ ] Tests written and passing
- [ ] Documentation updated
- [ ] Security considerations addressed
- [ ] Performance impact assessed
- [ ] Error handling implemented
- [ ] Logging added appropriately
- [ ] No sensitive data exposed
- [ ] Dependencies documented
- [ ] Breaking changes noted

---

*These standards ensure consistent, high-quality deliverables across all AGENT-11 projects. All agents must adhere to these standards.*