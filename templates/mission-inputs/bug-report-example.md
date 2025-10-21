# Bug Report: Authentication Token Expiry Not Handled

## Bug Summary

### Issue Title
Authentication tokens expire silently causing API 401 errors without user notification

### Priority Level
- [x] **P1 - High**: Core functionality broken, significant user impact
- [ ] **P0 - Critical**: System down, data loss, security breach
- [ ] **P2 - Medium**: Important feature not working, workaround exists
- [ ] **P3 - Low**: Minor issue, cosmetic problem, edge case

### Severity Impact
- [ ] **Blocker**: Prevents release/deployment
- [x] **Critical**: Major functionality affected
- [ ] **Major**: Important functionality affected
- [ ] **Minor**: Small functionality affected
- [ ] **Trivial**: Cosmetic or very minor issue

## Problem Description

### What Happened?
Users who have been logged in for more than 60 minutes suddenly lose access to all features. When they try to perform actions (save, submit, delete), they receive generic error messages like "Something went wrong" without being redirected to login. The application doesn't detect that the JWT token has expired and doesn't refresh it or prompt re-authentication.

### What Should Happen?
When a JWT token expires:
1. The application should detect the 401 response from the API
2. Automatically attempt to refresh the token using the refresh token
3. If refresh succeeds, retry the original request transparently
4. If refresh fails, show friendly message: "Your session has expired. Please log in again."
5. Redirect user to login page while preserving their current page location
6. After re-auth, return user to the page they were on

### When Did This Start?
- [ ] Just noticed
- [x] Started October 15, 2025 (2 days ago)
- [x] After deployment v2.4.0 that added JWT authentication
- [ ] Intermittent issue since [date]

## Reproduction Steps

### Environment Details
- **Browser**: Chrome 119, Firefox 120, Safari 17 (all affected)
- **Operating System**: macOS 14, Windows 11, iOS 17 (all affected)
- **Device**: Desktop, Mobile, Tablet (all affected)
- **Screen Resolution**: Any (not visual issue)
- **User Account Type**: All authenticated users (Admin, Regular User)

### Step-by-Step Reproduction
1. **Step 1**: Log in to the application with valid credentials
2. **Step 2**: Keep browser tab open for 65 minutes (token expiry is 60 min)
3. **Step 3**: Try to perform any action (create task, update profile, save settings)
4. **Result**: Error toast shows "Something went wrong" and action fails silently
5. **Expected**: Should either auto-refresh token OR show session expired message with redirect

### Frequency
- [x] **Always**: Happens every time (100% reproducible after token expiry)
- [ ] **Often**: Happens most of the time (>75%)
- [ ] **Sometimes**: Happens occasionally (25-75%)
- [ ] **Rarely**: Happens infrequently (<25%)

## Technical Details

### Error Messages
```
Browser Console Error:
POST https://api.taskmanager.com/tasks 401 (Unauthorized)
Error: Request failed with status code 401
    at createError (utils.js:123)
    at settle (settle.js:19)
    at XMLHttpRequest.handleLoad (xhr.js:77)

Response Body:
{
  "error": "TokenExpiredError",
  "message": "jwt expired",
  "expiredAt": "2025-10-18T14:30:00.000Z"
}
```

### URLs Affected
- **Primary URL**: All API endpoints requiring authentication
- **Related URLs**:
  - POST /api/tasks (create task)
  - PUT /api/users/profile (update profile)
  - DELETE /api/projects/:id (delete project)
  - GET /api/dashboard (dashboard data)
- **API Endpoints**: Any authenticated endpoint after 60 minute token expiry

### Browser Console Errors
```javascript
// From Chrome DevTools Console:
api-client.js:45 POST https://api.taskmanager.com/tasks 401 (Unauthorized)
auth-interceptor.js:12 Uncaught (in promise) Error: jwt expired
    at handleTokenExpiry (auth-interceptor.js:12:15)
    at XMLHttpRequest.onreadystatechange (axios-wrapper.js:89:23)

// Network Tab shows:
Request Headers:
  Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

Response Headers:
  Status: 401 Unauthorized
  WWW-Authenticate: Bearer error="invalid_token", error_description="The access token expired"
```

### Network Requests
- **Failed Requests**: All POST/PUT/DELETE requests after token expiry (401 status)
- **Response Codes**: 401 Unauthorized (should trigger token refresh)
- **Request Headers**: Authorization header present but token expired
- **Response Time**: ~200ms (API responds quickly with 401)

## Impact Assessment

### Users Affected
- **Number of Users**: ~500 daily active users (100% affected)
- **User Types**: All authenticated users (admins, regular users)
- **Geographic Impact**: Global (all regions)
- **Time Pattern**: Affects users who stay logged in >60 minutes (estimated 80% of active sessions)

### Business Impact
- **Revenue Impact**: $0 direct (freemium model, but affects conversion)
- **User Experience**: Severe degradation - users lose unsaved work, can't complete actions
- **Support Tickets**: 23 tickets in last 2 days (300% increase)
  - "Why can't I save my tasks?"
  - "Everything stopped working"
  - "I keep getting error messages"
- **Reputation Risk**: Medium - users complaining on Twitter, Reddit (4 posts identified)
- **Churn Risk**: High - frustration may cause users to switch to competitors

### Functional Impact
- **Features Broken**:
  - Task creation and editing
  - Profile updates
  - Project management
  - Settings changes
  - Any authenticated API call
- **Workflows Affected**:
  - New user onboarding (can't complete profile setup)
  - Daily task management (core use case broken)
  - Team collaboration (can't share or assign tasks)
- **Data Integrity**: No data loss, but unsaved work is lost when operations fail

## Debugging Information

### Logs and Screenshots
```
Server Logs (from logs/api-2025-10-18.log):
[2025-10-18 14:30:15] ERROR: JWT verification failed - TokenExpiredError: jwt expired
[2025-10-18 14:30:15] INFO: User ID 12345 attempted action with expired token
[2025-10-18 14:30:15] DEBUG: Token expired at 2025-10-18T14:30:00.000Z, current time: 2025-10-18T14:30:15.234Z
[2025-10-18 14:30:15] INFO: Responded with 401 Unauthorized

Application Logs (from frontend console):
[14:30:15] API request failed: POST /api/tasks
[14:30:15] Error: 401 Unauthorized
[14:30:15] User shown generic error toast
[14:30:15] No token refresh attempted
```

**Screenshots/Videos**:
- [x] Screenshot attached showing generic error message (see `/evidence/auth-error-toast.png`)
- [x] Video recording of reproduction steps (see `/evidence/token-expiry-repro.mp4`)
- [x] Network tab showing 401 response (see `/evidence/network-tab-401.png`)

### System State
- **Database Status**: Normal, no connection issues
- **Cache Status**: Redis operational, refresh tokens stored correctly
- **External Services**: All third-party APIs operational
- **Resource Usage**: CPU 15%, Memory 45%, Disk 60% (normal ranges)

### Recent Changes
- **Last Deployment**: October 15, 2025, 9:00 AM PST
  - Commit: `abc123f` "Implement JWT authentication with 60-minute expiry"
  - PR: #456 "Add JWT token-based auth system"
- **Configuration Changes**:
  - Added `JWT_EXPIRY=3600` (60 minutes)
  - Added `REFRESH_TOKEN_EXPIRY=604800` (7 days)
- **Database Migrations**:
  - Added `refresh_tokens` table
  - Added `last_login` column to users table
- **Dependency Updates**:
  - Added `jsonwebtoken@9.0.2`
  - Added `axios-auth-refresh@3.3.6` (not configured!)

## Workarounds & Temporary Fixes

### Current Workarounds
1. **Manual Page Refresh**: Users can refresh the page to trigger re-authentication (poor UX)
2. **Stay Active**: Users who interact with app every 30 minutes avoid issue (unrealistic)
3. **Logout/Login**: Users can manually log out and back in every hour (terrible UX)

### Immediate Mitigations
- [x] **Rollback Option**: Can revert to v2.3.0 (session-based auth) if critical
- [x] **Feature Flag**: Can disable JWT auth and revert to sessions temporarily
- [ ] **Cache Clear**: Not applicable - token expiry is time-based
- [ ] **Service Restart**: Won't help - this is client-side behavior issue

**Recommended Immediate Action**: Deploy hotfix to implement axios-auth-refresh interceptor

## Investigation Notes

### Hypothesis
The `axios-auth-refresh` package was added to dependencies but never configured in the API client. The frontend has no token refresh logic, so when the 60-minute JWT expires, all API requests fail with 401 errors. The error handling in the API client catches the 401 but only shows a generic error message instead of triggering token refresh or redirecting to login.

### Related Issues
- **Similar Bugs**:
  - Issue #234: "Users losing session randomly" (closed, was different issue)
  - Stack Overflow: "How to handle JWT expiry in React apps" (multiple solutions)
- **Previous Fixes**:
  - We previously used session-based auth with 24-hour expiry
  - Switched to JWT for better scalability
- **Known Issues**:
  - `axios-auth-refresh` v3.3.6 has known issue with refresh loop (should use v3.3.7)
  - Our refresh token endpoint `/api/auth/refresh` exists but isn't called by frontend

### Investigation Steps Taken
- [x] Checked application logs - confirmed 401 errors after 60 minutes
- [x] Reviewed recent code changes - JWT implementation PR #456
- [x] Tested in different environments - staging and production both affected
- [x] Verified database integrity - refresh tokens are stored correctly
- [x] Checked external service status - all APIs operational
- [x] Tested refresh token endpoint manually - works correctly via Postman
- [x] Reviewed axios-auth-refresh docs - found we never configured interceptor

## Fix Requirements

### Definition of Done
- [x] **Root Cause Identified**: Missing axios-auth-refresh interceptor configuration
- [ ] **Fix Implemented**: Configure axios interceptor to auto-refresh tokens
- [ ] **Testing Complete**: Verified token refresh works after 60 minutes
- [ ] **No Regression**: Existing auth functionality (login, logout) still works
- [ ] **Documentation Updated**: Added token refresh flow to architecture docs

### Testing Requirements
- [ ] **Unit Tests**:
  - Test token refresh interceptor catches 401 errors
  - Test successful token refresh flow
  - Test failed token refresh redirects to login
  - Test original request is retried after refresh
- [ ] **Integration Tests**:
  - Test end-to-end user session lasting >60 minutes
  - Test multiple concurrent requests during token refresh
  - Test refresh token expiry after 7 days
- [ ] **Manual Testing**:
  - QA team validates fix in staging
  - Product team verifies user experience improvements
  - Security team reviews token refresh implementation
- [ ] **Performance Testing**:
  - Token refresh adds <100ms latency to failed requests
  - No request duplication or infinite loops

### Deployment Considerations
- [ ] **Database Migration**: Not needed - schema already supports refresh tokens
- [ ] **Configuration Updates**:
  - Verify `REFRESH_TOKEN_EXPIRY` is set correctly (7 days)
  - Add `TOKEN_REFRESH_BUFFER` for refresh 5 minutes before expiry
- [ ] **Cache Invalidation**:
  - Clear any cached 401 error responses
  - Invalidate any stale token metadata
- [ ] **Monitoring**:
  - Add metric for token refresh success/failure rate
  - Alert if refresh failure rate exceeds 5%
  - Track time-to-refresh latency

## Prevention Measures

### Root Cause Analysis
- **Primary Cause**: Incomplete implementation - axios-auth-refresh library added but never configured
- **Contributing Factors**:
  - Code review didn't catch missing interceptor configuration
  - No integration test for token expiry scenario
  - Rushed deployment to meet deadline
  - Developer unfamiliar with axios interceptor patterns
- **Prevention Strategy**:
  - Add integration test for auth token lifecycle (login → expire → refresh → continue)
  - Create authentication implementation checklist for future auth changes
  - Require security team review for all auth-related PRs

### Process Improvements
- [x] **Code Review**: Add auth implementation checklist to PR template
- [x] **Testing Coverage**: Add integration test for token refresh scenarios
- [x] **Monitoring**: Add alerts for elevated 401 error rates (>5% of requests)
- [x] **Documentation**: Update architecture docs with token refresh flow diagram

---

## 🚨 Ready to Fix This Bug?

**Save this file and run:**
```bash
/coord fix bug-report-example.md
```

**Expected resolution time:** 2-4 hours
**Estimated cost:** $1.50 in API credits

**What will happen:**
1. @coordinator reads bug report and creates fix plan
2. @developer implements axios-auth-refresh interceptor
3. @tester validates token refresh works correctly
4. @documenter updates architecture docs with refresh flow

**Deliverables:**
- Token refresh interceptor configured
- Integration tests for auth lifecycle
- Updated architecture documentation
- Deployment verification checklist
