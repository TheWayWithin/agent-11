# AGENT-11 MCP Configuration Update Specification

**Created**: 2024-12-14
**Completed**: 2025-12-14
**Priority**: High
**Status**: ✅ Implemented

## Problem Statement

AGENT-11's MCP configurations for Railway and Supabase are broken:
1. **Railway MCP** - Configured with API token but actually uses CLI authentication
2. **Supabase MCP** - References non-existent npm package `@supabase/mcp-server`

Users following AGENT-11 documentation will encounter connection failures.

## Root Cause Analysis

### Railway Issue
- **Current Config**: Uses `RAILWAY_API_TOKEN` environment variable
- **Actual Behavior**: Railway MCP uses Railway CLI authentication
- **Official Source**: https://docs.railway.com/reference/mcp-server
- **Prerequisite**: User must run `railway login` before MCP will work

### Supabase Issue
- **Current Config**: Uses `@supabase/mcp-server` (npm package)
- **Actual Behavior**: Package doesn't exist in npm registry
- **Official Source**: https://github.com/supabase-community/supabase-mcp
- **Correct Options**:
  1. HTTP hosted server: `https://mcp.supabase.com/mcp` (simpler)
  2. npm package: `@supabase/mcp-server-supabase` (local)

## Proposed Changes

### 1. Railway Configuration

**BEFORE (Broken)**:
```json
"railway": {
  "command": "npx",
  "args": ["-y", "@railway/mcp-server"],
  "env": {
    "RAILWAY_API_TOKEN": "${RAILWAY_API_TOKEN}"
  }
}
```

**AFTER (Working)**:
```json
"railway": {
  "command": "npx",
  "args": ["-y", "@railway/mcp-server"]
}
```

**Documentation Addition**:
> Railway MCP uses Railway CLI authentication. Run `railway login` before using.

### 2. Supabase Configuration

**Option A: HTTP Hosted Server (Recommended)**
```json
"supabase": {
  "type": "http",
  "url": "https://mcp.supabase.com/mcp?project_ref=${SUPABASE_PROJECT_REF}"
}
```

**Option B: Local npm Package**
```json
"supabase": {
  "command": "npx",
  "args": [
    "-y",
    "@supabase/mcp-server-supabase@latest",
    "--access-token", "${SUPABASE_ACCESS_TOKEN}",
    "--project-ref", "${SUPABASE_PROJECT_REF}"
  ]
}
```

**Recommendation**: Use HTTP option for simplicity; document both.

## Files Requiring Updates

### Configuration Files

| File | Changes Required |
|------|-----------------|
| `.mcp.json.template` | Fix Railway (remove token), fix Supabase package name |
| `.mcp-profiles/backend-deploy.json` | Fix Railway config |
| `.mcp-profiles/database-staging.json` | Fix Supabase package name |
| `.mcp-profiles/database-production.json` | Fix Supabase package name |
| `.mcp-profiles/deployment.json` | Fix Railway config |
| `.mcp-profiles/fullstack.json` | Fix both Railway and Supabase |
| `.mcp-profiles/db-read.json` | Fix Supabase if present |
| `.mcp-profiles/db-write.json` | Fix Supabase if present |
| `project/deployment/templates/.mcp.json.template` | Fix both |

### Documentation Files

| File | Changes Required |
|------|-----------------|
| `docs/MCP-GUIDE.md` | Update package names, add Railway CLI prereq |
| `docs/MCP-TROUBLESHOOTING.md` | Add Railway/Supabase specific troubleshooting |
| `docs/MCP-PROFILES.md` | Update configuration examples |
| `.env.mcp.template` | Remove RAILWAY_API_TOKEN, clarify Supabase vars |

### Setup Scripts

| File | Changes Required |
|------|-----------------|
| `project/deployment/scripts/mcp-setup.sh` | Update package installation list |
| `project/deployment/scripts/mcp-setup-v2.sh` | Update package installation list |

## Environment Variable Changes

### Remove
- `RAILWAY_API_TOKEN` - No longer needed (CLI auth)

### Clarify
- `SUPABASE_ACCESS_TOKEN` - Only needed if using npm package option
- `SUPABASE_PROJECT_REF` - Required for both options

### Add Documentation
- Railway CLI authentication requirement
- Supabase HTTP vs npm options

## Implementation Checklist

### Phase 1: Configuration Files
- [x] Update `.mcp.json.template` - Railway env removed
- [x] Update all `.mcp-profiles/*.json` files:
  - [x] `backend-deploy.json` - Railway env removed
  - [x] `deployment.json` - Railway env removed
  - [x] `database-staging.json` - Supabase package fixed
  - [x] `database-production.json` - Supabase package fixed
  - [x] `db-read.json` - Supabase package fixed
  - [x] `db-write.json` - Supabase package fixed
  - [x] `fullstack.json` - Rebuilt with correct configs
- [x] Update `project/deployment/templates/.mcp.json.template` - Railway env removed

### Phase 2: Documentation
- [x] Update `.env.mcp.template` - Railway CLI auth documented
- [ ] Update `docs/MCP-GUIDE.md` - Package names and prerequisites (if exists)
- [ ] Update `docs/MCP-TROUBLESHOOTING.md` - Add Railway/Supabase sections (if exists)
- [ ] Update `docs/MCP-PROFILES.md` - Configuration examples (if exists)

### Phase 3: Scripts
- [ ] Update `project/deployment/scripts/mcp-setup.sh`
- [ ] Update `project/deployment/scripts/mcp-setup-v2.sh`

### Phase 4: Verification
- [ ] Test Railway MCP connection (requires `railway login`)
- [ ] Test Supabase MCP connection (npm option)
- [ ] Verify all profiles load correctly

## Testing Verification

### Railway MCP Test
```bash
# Prerequisites
which railway  # Should show path
railway whoami  # Should show logged in user

# Test MCP loads
# Restart Claude Code with deployment profile
# Verify mcp__railway tools available
```

### Supabase MCP Test (HTTP)
```bash
# Set project ref in config
# Restart Claude Code with database profile
# Verify mcp__supabase tools available
```

## Rollback Plan

If issues arise:
1. Keep backup of all modified files before changes
2. Git branch: `fix/mcp-railway-supabase-config`
3. If broken, revert branch and investigate further

## References

- [Railway MCP Official Docs](https://docs.railway.com/reference/mcp-server)
- [Supabase MCP GitHub](https://github.com/supabase-community/supabase-mcp)
- [@supabase/mcp-server-supabase npm](https://www.npmjs.com/package/@supabase/mcp-server-supabase)
