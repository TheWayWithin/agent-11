# Bug Report Template

## Bug Summary

### Issue Title
[Concise, descriptive title of the problem]

### Priority Level
- [ ] **P0 - Critical**: System down, data loss, security breach
- [ ] **P1 - High**: Core functionality broken, significant user impact
- [ ] **P2 - Medium**: Important feature not working, workaround exists
- [ ] **P3 - Low**: Minor issue, cosmetic problem, edge case

### Severity Impact
- [ ] **Blocker**: Prevents release/deployment
- [ ] **Critical**: Major functionality affected
- [ ] **Major**: Important functionality affected
- [ ] **Minor**: Small functionality affected
- [ ] **Trivial**: Cosmetic or very minor issue

## Problem Description

### What Happened?
[Clear description of the unexpected behavior]

### What Should Happen?
[Expected behavior or outcome]

### When Did This Start?
- [ ] Just noticed
- [ ] Started [date/time]
- [ ] After [specific change/deployment]
- [ ] Intermittent issue since [date]

## Reproduction Steps

### Environment Details
- **Browser**: [Chrome 120, Safari 17, etc.]
- **Operating System**: [macOS 14, Windows 11, etc.]
- **Device**: [Desktop, Mobile, Tablet]
- **Screen Resolution**: [1920x1080, mobile viewport, etc.]
- **User Account Type**: [Admin, Regular User, Guest]

### Step-by-Step Reproduction
1. **Step 1**: [specific action taken]
2. **Step 2**: [specific action taken]
3. **Step 3**: [specific action taken]
4. **Result**: [what actually happened]

### Frequency
- [ ] **Always**: Happens every time
- [ ] **Often**: Happens most of the time (>75%)
- [ ] **Sometimes**: Happens occasionally (25-75%)
- [ ] **Rarely**: Happens infrequently (<25%)

## Technical Details

### Error Messages
```
[Paste exact error messages, console logs, or stack traces here]
```

### URLs Affected
- **Primary URL**: [specific page where issue occurs]
- **Related URLs**: [other affected pages]
- **API Endpoints**: [if backend issue]

### Browser Console Errors
```javascript
// Paste any JavaScript console errors here
```

### Network Requests
- **Failed Requests**: [any 404s, 500s, timeouts]
- **Response Codes**: [unexpected status codes]
- **Request Headers**: [if relevant to issue]

## Impact Assessment

### Users Affected
- **Number of Users**: [estimated count or percentage]
- **User Types**: [which user segments are impacted]
- **Geographic Impact**: [specific regions if applicable]

### Business Impact
- **Revenue Impact**: $[estimated loss] per [time period]
- **User Experience**: [specific UX degradation]
- **Support Tickets**: [increase in customer complaints]
- **Reputation Risk**: [public visibility of issue]

### Functional Impact
- **Features Broken**: [list of non-functional features]
- **Workflows Affected**: [user journeys that fail]
- **Data Integrity**: [any data corruption or loss]

## Debugging Information

### Logs and Screenshots
```
[Paste relevant server logs, database logs, or application logs]
```

**Screenshots/Videos**:
- [ ] Screenshot attached showing the issue
- [ ] Video recording of reproduction steps
- [ ] Before/after comparison images

### System State
- **Database Status**: [any relevant DB state]
- **Cache Status**: [Redis, CDN, application cache]
- **External Services**: [third-party API status]
- **Resource Usage**: [CPU, memory, disk if relevant]

### Recent Changes
- **Last Deployment**: [date and commit hash]
- **Configuration Changes**: [any recent config updates]
- **Database Migrations**: [recent schema changes]
- **Dependency Updates**: [library or framework updates]

## Workarounds & Temporary Fixes

### Current Workarounds
1. **Workaround 1**: [temporary solution users can use]
2. **Workaround 2**: [alternative approach]

### Immediate Mitigations
- [ ] **Rollback Option**: [can we revert recent changes?]
- [ ] **Feature Flag**: [can we disable problematic feature?]
- [ ] **Cache Clear**: [will clearing cache help?]
- [ ] **Service Restart**: [will restart resolve issue?]

## Investigation Notes

### Hypothesis
[Initial theory about what might be causing the issue]

### Related Issues
- **Similar Bugs**: [links to related issues]
- **Previous Fixes**: [past solutions that might apply]
- **Known Issues**: [documented problems in dependencies]

### Investigation Steps Taken
- [ ] Checked application logs
- [ ] Reviewed recent code changes
- [ ] Tested in different environments
- [ ] Verified database integrity
- [ ] Checked external service status

## Fix Requirements

### Definition of Done
- [ ] **Root Cause Identified**: Understanding of why issue occurred
- [ ] **Fix Implemented**: Code changes to resolve issue
- [ ] **Testing Complete**: Verified fix works in all scenarios
- [ ] **No Regression**: Existing functionality still works
- [ ] **Documentation Updated**: Issue and solution documented

### Testing Requirements
- [ ] **Unit Tests**: [specific test cases needed]
- [ ] **Integration Tests**: [end-to-end scenarios to verify]
- [ ] **Manual Testing**: [user acceptance testing requirements]
- [ ] **Performance Testing**: [if performance related issue]

### Deployment Considerations
- [ ] **Database Migration**: [any schema changes needed]
- [ ] **Configuration Updates**: [environment variable changes]
- [ ] **Cache Invalidation**: [clear caches after deployment]
- [ ] **Monitoring**: [additional logging or alerts needed]

## Prevention Measures

### Root Cause Analysis
- **Primary Cause**: [fundamental reason for the issue]
- **Contributing Factors**: [conditions that enabled the issue]
- **Prevention Strategy**: [how to avoid similar issues]

### Process Improvements
- [ ] **Code Review**: [additional review requirements]
- [ ] **Testing Coverage**: [gaps in test suite to address]
- [ ] **Monitoring**: [alerts or dashboards to add]
- [ ] **Documentation**: [knowledge gaps to fill]

---

## 🚨 Template Usage Instructions

1. **Fill in ALL relevant sections** - Complete information speeds resolution
2. **Be specific and detailed** - Vague reports slow down debugging
3. **Include exact error messages** - Copy/paste, don't paraphrase
4. **Provide reproduction steps** - Must be able to recreate the issue
5. **Assess impact accurately** - Helps prioritize fix timeline

**Ready to fix this bug?** Save this file and run: `/coord fix bug-report.md`