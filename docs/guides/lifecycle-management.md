# Project Lifecycle Management

## Overview

AGENT-11 projects accumulate significant context over time through `project-plan.md` and `progress.md`. Without cleanup, these files can grow from 200 lines to 20,000+ lines, causing **context pollution** where agents get buried in historical details instead of focusing on current work.

This guide provides a **three-tier cleanup strategy** to keep your project context lean while preserving all valuable lessons.

## The Context Pollution Problem

### Without Cleanup (Real Example)

**After 3 months of active development**:
- `project-plan.md`: 8,500 lines (original: 150 lines)
- `progress.md`: 12,000 lines (original: 50 lines)
- **Total context**: 20,500 lines to read before every mission

**Impact**:
- Agents spend 20% of time reading old context
- Relevant current tasks buried in completed history
- Token costs increase 300%
- Mission start time: 5 minutes → 25 minutes
- Increased risk of agents missing critical current context

---

### With Cleanup (AGENT-11 Approach)

**After 3 months with quarterly cleanup**:
- `project-plan.md`: 180 lines (current quarter only)
- `progress.md`: 150 lines (current quarter only)
- `/archive/`: 20,000+ lines (searchable history)
- `/lessons/`: 500 lines (extracted patterns)
- **Active context**: 330 lines

**Impact**:
- Agents focus on current work (not history)
- Critical context immediately visible
- Token costs remain constant
- Mission start time: 5 minutes (consistent)
- Lessons searchable by category when needed

## Three-Tier Cleanup Strategy

### Option 1: Milestone Transition (Recommended Every 2-4 Weeks)

**When to use**:
- Completed major feature or phase
- Preparing for next development milestone
- Files exceeding 200-300 lines

**Time required**: 30 minutes

**What to archive**:
- Completed tasks from project-plan.md
- Resolved issues from progress.md
- Old deliverables (code shipped to production)

**What to preserve**:
- Current sprint/milestone tasks
- Active issues and blockers
- Recent lessons (last 2 weeks)
- Ongoing work context

**Process**:
```bash
# 1. Create milestone archive
mkdir -p archive/milestone-1-auth-system
cd archive/milestone-1-auth-system

# 2. Extract completed work
# Move completed sections from project-plan.md
# Move resolved issues from progress.md

# 3. Update current files
# Keep only active tasks in project-plan.md
# Keep only current issues in progress.md

# 4. Extract lessons
mkdir -p ../../lessons/authentication
# Document patterns learned → lessons/authentication/
```

**Example**:

**Before cleanup** (`project-plan.md` - 450 lines):
```markdown
## Phase 1: Authentication (COMPLETED ✅)
- [x] Setup JWT library (done 2025-09-15)
- [x] Implement login endpoint (done 2025-09-16)
- [x] Add password hashing (done 2025-09-17)
- [x] Create refresh token system (done 2025-09-18)

## Phase 2: User Profiles (COMPLETED ✅)
- [x] Database schema (done 2025-09-20)
- [x] Profile CRUD APIs (done 2025-09-22)
- [x] Avatar uploads (done 2025-09-24)

## Phase 3: Dashboard (IN PROGRESS)
- [x] Dashboard layout (done 2025-10-01)
- [ ] Data visualization components (in progress)
- [ ] Real-time updates (pending)

## Phase 4: Notifications (PLANNED)
- [ ] Email notifications
- [ ] Push notifications
- [ ] Notification preferences
```

**After cleanup** (`project-plan.md` - 80 lines):
```markdown
## Current Sprint: Dashboard Features (Week 10-11)
- [x] Dashboard layout (completed 2025-10-01)
- [ ] Data visualization components (in progress, @developer)
- [ ] Real-time updates (pending dependency: WebSocket setup)

## Next Sprint: Notifications (Week 12-13)
- [ ] Email notifications (using SendGrid)
- [ ] Push notifications (Firebase Cloud Messaging)
- [ ] Notification preferences UI

## Recently Completed (Last 2 Weeks)
- Profile avatar uploads (2025-09-24)
- Profile CRUD APIs (2025-09-22)

---
*For complete project history, see /archive/*
```

**Archive** (`archive/milestone-1-auth-system/README.md`):
```markdown
# Milestone 1: Authentication System

**Duration**: September 15-18, 2025 (4 days)
**Status**: Completed ✅

## Deliverables
- JWT authentication with refresh tokens
- Password hashing (bcrypt cost 12+)
- Login/logout endpoints
- Token refresh endpoint

## Key Decisions
- Used refresh token rotation for security
- 15-minute access tokens, 7-day refresh tokens
- httpOnly cookies for XSS protection

## Lessons Learned
See: /lessons/authentication/jwt-implementation.md

## Complete Task History
[Full detailed history from original project-plan.md]
```

---

### Option 2: Project Completion (When Shipping to Production)

**When to use**:
- MVP complete and shipped
- Major version release
- Handing off to maintenance mode

**Time required**: 1-2 hours

**What to archive**:
- Entire project-plan.md (100% of completed work)
- Entire progress.md (all resolved issues)
- Development documentation (now in `/docs/`)

**What to preserve**:
- Active bugs and issues
- Maintenance roadmap
- Production monitoring alerts
- Known technical debt

**Process**:
```bash
# 1. Create production archive
mkdir -p archive/v1.0-launch
cd archive/v1.0-launch

# 2. Archive complete project files
cp ../../project-plan.md ./project-plan-complete.md
cp ../../progress.md ./progress-complete.md

# 3. Extract comprehensive lessons
mkdir -p ../../lessons
# Organize by category (see Lessons Repository section)

# 4. Reset for maintenance mode
# Create minimal project-plan.md for maintenance
# Create fresh progress.md for production issues
```

**New project-plan.md for maintenance**:
```markdown
# Task Manager - Maintenance Mode

## Production Health
- [ ] Monitor error rates (< 0.1%)
- [ ] Track performance metrics (p95 < 500ms)
- [ ] Review security logs weekly

## Known Technical Debt
- [ ] Refactor user profile API (high complexity)
- [ ] Add database indexes for search (performance)
- [ ] Migrate to new auth library (security)

## Planned Enhancements
- [ ] Dark mode support (user request)
- [ ] Export to CSV (user request)
- [ ] Mobile app (Phase 2 roadmap)

---
*For complete development history, see /archive/v1.0-launch/*
```

---

### Option 3: Continue Active Work (No Cleanup Needed)

**When to use**:
- Files still under 200 lines
- Current phase ongoing (not yet completed)
- Recent project (< 2 weeks old)

**What to do**: Nothing! Keep working.

**When to reconsider**:
- Files exceed 200 lines
- Completed major milestone
- Preparing for next phase

**Monitoring threshold**:
```bash
# Check file sizes
wc -l project-plan.md progress.md

# If combined > 400 lines, consider cleanup
# If individual file > 200 lines, definitely cleanup
```

## Lessons Repository Structure

As you archive completed work, extract reusable patterns into organized lessons:

```
/lessons/
├── README.md                          # Lessons catalog
├── security/
│   ├── authentication-patterns.md     # JWT, OAuth, session management
│   ├── xss-prevention.md              # Input sanitization, CSP
│   ├── api-security.md                # Rate limiting, CORS
│   └── secrets-management.md          # Environment variables, vaults
├── performance/
│   ├── database-optimization.md       # Indexes, query patterns, N+1
│   ├── caching-strategies.md          # Redis, CDN, memoization
│   ├── frontend-performance.md        # Code splitting, lazy loading
│   └── api-performance.md             # Pagination, compression
├── architecture/
│   ├── microservices-patterns.md      # Service boundaries, communication
│   ├── state-management.md            # Redux, Context API
│   ├── api-design.md                  # REST, GraphQL, versioning
│   └── database-design.md             # Schema patterns, migrations
├── process/
│   ├── debugging-workflows.md         # Systematic problem-solving
│   ├── testing-strategies.md          # Unit, integration, E2E
│   ├── deployment-procedures.md       # CI/CD, rollback
│   └── code-review.md                 # Standards, checklists
├── integrations/
│   ├── stripe-payment.md              # Payment processing
│   ├── sendgrid-email.md              # Email delivery
│   ├── aws-s3-storage.md              # File uploads
│   └── oauth-providers.md             # Google, GitHub auth
└── common-errors/
    ├── jwt-token-expiry.md            # Token refresh issues
    ├── n-plus-one-queries.md          # ORM performance
    ├── cors-errors.md                 # Cross-origin requests
    └── memory-leaks.md                # Event listeners, closures
```

### Lessons Catalog Example

**`/lessons/README.md`**:
```markdown
# Lessons Repository

Searchable knowledge base of patterns, solutions, and best practices learned during development.

## Quick Index

**Authentication & Security**:
- [JWT Token Implementation](security/authentication-patterns.md) - Refresh tokens, rotation, httpOnly cookies
- [XSS Prevention](security/xss-prevention.md) - Input sanitization, CSP headers
- [API Security](security/api-security.md) - Rate limiting, CORS, input validation

**Performance Optimization**:
- [Database Optimization](performance/database-optimization.md) - Indexes, query patterns, N+1 prevention
- [Caching Strategies](performance/caching-strategies.md) - Redis, CDN, memoization patterns
- [Frontend Performance](performance/frontend-performance.md) - Code splitting, lazy loading, image optimization

**Common Errors**:
- [JWT Token Expiry Issues](common-errors/jwt-token-expiry.md) - Silent logout, refresh race conditions
- [N+1 Query Problems](common-errors/n-plus-one-queries.md) - ORM eager loading, query optimization
- [CORS Configuration](common-errors/cors-errors.md) - Preflight requests, credential handling

## Search by Keyword

```bash
# Find all lessons about authentication
grep -r "authentication" lessons/

# Find all performance issues
grep -r "performance" lessons/

# Find specific error patterns
grep -r "JWT" lessons/
```

## Contributing New Lessons

When you solve a non-trivial problem:
1. Document the complete journey (what worked, what didn't)
2. Extract the pattern/principle
3. Add to appropriate category
4. Update this index

**Template**: See [lesson-template.md](lesson-template.md)
```

### Individual Lesson Example

**`/lessons/common-errors/jwt-token-expiry.md`**:
```markdown
# JWT Token Expiry Issues

## Problem Pattern

Users get unexpectedly logged out after 60 minutes, even with "remember me" checked.

## Symptoms

- User completes authentication successfully
- After 60 minutes, API requests return 401 Unauthorized
- User redirected to login without warning
- No indication of token expiry

## Root Causes

1. **Access tokens only** (no refresh tokens)
   - Access token expires after 60 minutes
   - No mechanism to get new token without re-login
   - Common in early MVP implementations

2. **Refresh token not stored**
   - Refresh token generated but not saved in database
   - Token rotation fails on subsequent refreshes
   - Security audit catches this

3. **Race conditions in refresh logic**
   - Multiple API calls trigger simultaneous refresh
   - Second refresh invalidates first token
   - User gets logged out despite valid session

## Solutions (Tried and Tested)

### ❌ Solution 1: Increase Access Token Expiry

```javascript
const accessToken = jwt.sign(payload, secret, {
  expiresIn: '24h' // Too long!
})
```

**Why it doesn't work**:
- Security risk (compromised token valid for 24 hours)
- Fails security audits (OWASP recommendation: 15-30 minutes)
- Doesn't solve the underlying problem

**When attempted**: Initial fix attempt, rejected by security team

---

### ❌ Solution 2: Sliding Window Without Refresh Tokens

```javascript
// Extend expiry on every request
if (tokenAge < maxAge) {
  const newToken = jwt.sign(payload, secret, {
    expiresIn: '1h'
  })
  res.setHeader('X-New-Token', newToken)
}
```

**Why it doesn't work**:
- Frontend must handle token rotation on every request
- Race conditions with concurrent requests
- Token gets invalidated mid-request
- Adds complexity to every API call

**When attempted**: Second attempt, caused more bugs than it solved

---

### ✅ Solution 3: Refresh Token Rotation

```javascript
// Access token: Short-lived (15 minutes)
const accessToken = jwt.sign(payload, secret, {
  expiresIn: '15m'
})

// Refresh token: Long-lived (7 days), stored in database
const refreshToken = crypto.randomBytes(40).toString('hex')
await db.refreshTokens.create({
  userId: user.id,
  token: refreshToken,
  expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
})

// Return both tokens (access in response, refresh in httpOnly cookie)
res.cookie('refreshToken', refreshToken, {
  httpOnly: true,
  secure: true,
  sameSite: 'strict',
  maxAge: 7 * 24 * 60 * 60 * 1000
})

res.json({ accessToken })
```

**Why it works**:
- Short access tokens limit compromise window
- Refresh tokens enable seamless re-authentication
- httpOnly cookies prevent XSS attacks
- Database storage enables revocation
- Rotation prevents replay attacks

**Implementation time**: 2 hours
**Security audit**: Passed ✅

## Implementation Checklist

- [ ] Generate short-lived access tokens (15-30 minutes)
- [ ] Generate long-lived refresh tokens (7-30 days)
- [ ] Store refresh tokens in database with expiry
- [ ] Implement refresh endpoint with token rotation
- [ ] Add mutex to prevent concurrent refresh
- [ ] Use httpOnly cookies for refresh tokens
- [ ] Implement token revocation on logout
- [ ] Add refresh token cleanup job (expired tokens)

## Code Example

**Backend (Node.js + Express)**:

```javascript
// POST /auth/refresh
router.post('/refresh', async (req, res) => {
  const { refreshToken } = req.cookies

  if (!refreshToken) {
    return res.status(401).json({ error: 'No refresh token' })
  }

  // Verify refresh token exists and not expired
  const storedToken = await db.refreshTokens.findOne({
    where: { token: refreshToken, expiresAt: { $gt: new Date() } }
  })

  if (!storedToken) {
    return res.status(401).json({ error: 'Invalid refresh token' })
  }

  // Generate new access token
  const user = await db.users.findById(storedToken.userId)
  const newAccessToken = jwt.sign(
    { userId: user.id, email: user.email },
    process.env.JWT_SECRET,
    { expiresIn: '15m' }
  )

  // Rotate refresh token (optional but recommended)
  const newRefreshToken = crypto.randomBytes(40).toString('hex')
  await db.refreshTokens.update(storedToken.id, {
    token: newRefreshToken,
    expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
  })

  res.cookie('refreshToken', newRefreshToken, {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'strict',
    maxAge: 7 * 24 * 60 * 60 * 1000
  })

  res.json({ accessToken: newAccessToken })
})
```

**Frontend (React + Axios)**:

```javascript
import axios from 'axios'

// Axios interceptor for automatic token refresh
axios.interceptors.response.use(
  response => response,
  async error => {
    const originalRequest = error.config

    // If 401 and not already retried
    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true

      try {
        // Request new access token using refresh token
        const { data } = await axios.post('/auth/refresh', {}, {
          withCredentials: true // Send httpOnly cookie
        })

        // Update authorization header
        originalRequest.headers['Authorization'] = `Bearer ${data.accessToken}`

        // Store new token
        localStorage.setItem('accessToken', data.accessToken)

        // Retry original request
        return axios(originalRequest)
      } catch (refreshError) {
        // Refresh failed, redirect to login
        localStorage.removeItem('accessToken')
        window.location.href = '/login'
        return Promise.reject(refreshError)
      }
    }

    return Promise.reject(error)
  }
)
```

## Prevention Strategy

**For new projects**:
1. Include refresh token pattern in auth setup checklist
2. Document token lifecycle in CLAUDE.md
3. Add to authentication starter template
4. Include in code review checklist

**Security considerations**:
- Never store refresh tokens in localStorage (XSS vulnerability)
- Always use httpOnly cookies for refresh tokens
- Implement token rotation on refresh (prevents replay)
- Add refresh token revocation on logout
- Cleanup expired tokens regularly

**Performance considerations**:
- Refresh token lookups should use indexed queries
- Consider caching valid refresh tokens (Redis)
- Add mutex to prevent concurrent refresh (race conditions)

## Related Patterns

- [Authentication Best Practices](../security/authentication-patterns.md)
- [Session Management](../security/session-management.md)
- [API Security](../security/api-security.md)

## References

- OWASP Token Best Practices: https://owasp.org/www-project-cheat-sheets/
- JWT RFC 7519: https://tools.ietf.org/html/rfc7519
- OAuth 2.0 RFC 6749: https://tools.ietf.org/html/rfc6749

---

*Pattern identified: 2025-09-18*
*Last updated: 2025-10-15*
*Times encountered: 3 (all resolved with refresh token pattern)*
```

## Cleanup Execution Checklist

Use this checklist when performing cleanup:

**Before Cleanup**:
- [ ] Verify git working directory is clean
- [ ] Create backup: `cp project-plan.md project-plan.backup`
- [ ] Create backup: `cp progress.md progress.backup`
- [ ] Note current line counts for comparison

**During Cleanup**:
- [ ] Create archive directory with descriptive name
- [ ] Move completed tasks from project-plan.md
- [ ] Move resolved issues from progress.md
- [ ] Extract lessons to `/lessons/` repository
- [ ] Update lessons catalog (`/lessons/README.md`)
- [ ] Add cross-references between lessons

**After Cleanup**:
- [ ] Verify project-plan.md contains only active work
- [ ] Verify progress.md contains only recent issues
- [ ] Verify archive contains complete history
- [ ] Verify lessons are searchable
- [ ] Commit changes: `git add . && git commit -m "chore: archive completed milestone"`
- [ ] Verify agents can read current context quickly

**Quality Checks**:
- [ ] Can you find the current sprint tasks in < 30 seconds?
- [ ] Are all active issues visible without scrolling?
- [ ] Can you search lessons by keyword?
- [ ] Is archive organized logically?
- [ ] Did line count reduce by 50%+ ?

## Tools and Scripts

### Check Current Context Size

```bash
#!/bin/bash
# check-context-size.sh

echo "Current context size:"
echo "---"
echo "project-plan.md: $(wc -l < project-plan.md) lines"
echo "progress.md: $(wc -l < progress.md) lines"
echo "Total: $(($(wc -l < project-plan.md) + $(wc -l < progress.md))) lines"
echo "---"

if [ $(($(wc -l < project-plan.md) + $(wc -l < progress.md))) -gt 400 ]; then
  echo "⚠️  WARNING: Context exceeds 400 lines. Consider cleanup."
fi
```

### Archive Milestone

```bash
#!/bin/bash
# archive-milestone.sh <milestone-name>

MILESTONE=$1
ARCHIVE_DIR="archive/${MILESTONE}-$(date +%Y%m%d)"

mkdir -p "$ARCHIVE_DIR"
cp project-plan.md "$ARCHIVE_DIR/project-plan-complete.md"
cp progress.md "$ARCHIVE_DIR/progress-complete.md"

echo "✅ Archived to $ARCHIVE_DIR"
echo "Next: Extract lessons and update current files"
```

### Extract Lesson

```bash
#!/bin/bash
# extract-lesson.sh <category> <lesson-name>

CATEGORY=$1
LESSON=$2
LESSON_DIR="lessons/$CATEGORY"

mkdir -p "$LESSON_DIR"
touch "$LESSON_DIR/$LESSON.md"

echo "# $LESSON" > "$LESSON_DIR/$LESSON.md"
echo "" >> "$LESSON_DIR/$LESSON.md"
echo "## Problem Pattern" >> "$LESSON_DIR/$LESSON.md"
echo "" >> "$LESSON_DIR/$LESSON.md"
echo "## Solutions Tried" >> "$LESSON_DIR/$LESSON.md"
echo "" >> "$LESSON_DIR/$LESSON.md"
echo "## What Worked" >> "$LESSON_DIR/$LESSON.md"
echo "" >> "$LESSON_DIR/$LESSON.md"
echo "---" >> "$LESSON_DIR/$LESSON.md"
echo "*Pattern identified: $(date +%Y-%m-%d)*" >> "$LESSON_DIR/$LESSON.md"

echo "✅ Created lesson template: $LESSON_DIR/$LESSON.md"
```

## Common Questions

### Q: How often should I clean up?

**A**: Every 2-4 weeks when completing major milestones, OR when combined file size exceeds 400 lines.

**Rule of thumb**: If you're scrolling to find current tasks, it's time to clean up.

---

### Q: Will I lose important information?

**A**: No! Everything gets archived, not deleted. You can always search archive for historical context.

**Best practice**: Extract important patterns to `/lessons/` before archiving.

---

### Q: Do agents need historical context?

**A**: Rarely. Agents need:
- Current tasks and blockers (from project-plan.md)
- Recent issues and patterns (from progress.md)
- Extracted lessons when relevant (from /lessons/)

Historical "how we got here" details are rarely needed after milestone completion.

---

### Q: What if I'm mid-feature when cleanup is due?

**A**: Wait until feature is complete. Don't cleanup during active work on a feature.

**Alternative**: If files are huge, archive completed OTHER features but keep current work active.

---

### Q: Should I cleanup progress.md differently than project-plan.md?

**A**: Yes:
- **project-plan.md**: Archive all completed tasks (keep only active work)
- **progress.md**: Extract lessons first, then archive resolved issues

Progress.md contains more valuable patterns to extract.

---

## Summary

**The Power of Strategic Cleanup**:
- **Without cleanup**: 20,000 lines of context, agents buried in history
- **With cleanup**: 300 lines of current context, 20,000 lines searchable when needed

**Time Investment**: 30 minutes every 2-4 weeks
**Time Saved**: 5-10 minutes per mission start (20+ missions = 2-4 hours)

**Compound Effect**: Context stays lean, agents stay focused, knowledge becomes searchable.

---

*Last Updated: 2025-10-20*
*Part of AGENT-11 Documentation System*

[→ Progress Tracking Guide](progress-tracking.md) | [→ Cleanup Checklist](/templates/cleanup-checklist.md)
