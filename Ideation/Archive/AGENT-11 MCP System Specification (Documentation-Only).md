# AGENT-11 MCP System Specification (Documentation-Only)

**Version:** 3.0  
**Date:** October 2025  
**Architecture:** Documentation-based (No Runtime Code)  
**Implementation Time:** 1-2 days

---

## Executive Summary

This specification redesigns the AGENT-11 MCP system using **pure documentation** and **Claude Code's native capabilities** - no JavaScript runtime required. The solution leverages Claude Code's existing MCP management and agent prompts to provide intelligent MCP recommendations and multi-environment guidance.

### Key Insight

**Agent-11 is a library of agent prompts, not an application.** Therefore, the MCP system should be:
- **Documentation-driven** - Agents guide users on which MCPs to connect
- **Claude Code native** - Use built-in `/mcp` commands, not custom JavaScript
- **Profile-aware** - Agents know which MCPs they need
- **Environment-smart** - Agents warn about staging vs production

---

## Current Architecture (What Agent-11 Actually Is)

```
agent-11/
├── .claude/
│   └── agents/           # Agent prompt files (.md)
│       ├── coordinator.md
│       ├── strategist.md
│       ├── developer.md
│       ├── tester.md
│       └── ...
├── missions/             # Mission workflow files (.md)
│   ├── test.md
│   ├── deploy.md
│   └── ...
├── .mcp.json            # Static MCP configuration
├── .env.mcp.template    # Environment variable template
└── README.md            # Documentation
```

**No runtime code. Just documentation and prompts.**

---

## Problems with Previous Spec

❌ Assumed Node.js runtime (agent-11 is documentation-only)  
❌ Created 13 JavaScript files (unnecessary complexity)  
❌ Custom `/mcp-connect` command (Claude Code doesn't support custom commands)  
❌ Dynamic `.mcp.json` generation (requires runtime)  
❌ Complex state management (overkill for documentation)

---

## New Approach: Documentation-Driven MCP Management

### Core Principle

**Agents tell users which MCPs to connect, users use native Claude Code commands.**

Instead of:
```bash
/mcp-connect testing  # Custom command (doesn't exist)
```

We use:
```bash
# Agent recommends:
"I need Playwright for testing. Please run:
  claude mcp add --transport stdio playwright -- npx @playwright/mcp@latest
Then restart: /exit && claude"
```

---

## Solution Architecture

### 1. Multiple `.mcp.json` Profile Files

**Instead of:** Dynamic generation  
**We use:** Static profile files that users can symlink

```
agent-11/
├── .mcp-profiles/
│   ├── core.json           # Essential only
│   ├── testing.json        # Core + Playwright
│   ├── database.json       # Core + Supabase
│   ├── payments.json       # Core + Stripe
│   ├── deployment.json     # Core + Netlify + Railway
│   └── fullstack.json      # All MCPs
├── .mcp.json -> .mcp-profiles/core.json  # Symlink to active profile
└── .env.mcp
```

**User switches profiles:**
```bash
# Switch to testing profile
ln -sf .mcp-profiles/testing.json .mcp.json
/exit && claude

# Switch to database profile
ln -sf .mcp-profiles/database.json .mcp.json
/exit && claude
```

---

### 2. Smart Agent Prompts

**Agents include MCP awareness in their prompts:**

**File:** `.claude/agents/tester.md`

```markdown
# Tester Agent

You are the Testing Specialist for AGENT-11.

## Required MCPs

**Essential:**
- playwright (browser automation for E2E tests)

**Current Status:**
Before starting work, check if Playwright is connected:
- Run: /mcp
- Look for "playwright" in the list

**If Playwright is NOT connected:**
Tell the user:
"I need Playwright MCP for automated testing. Please connect it:

Option 1 (Recommended - uses testing profile):
  ln -sf .mcp-profiles/testing.json .mcp.json
  /exit && claude

Option 2 (Add Playwright only):
  claude mcp add --transport stdio playwright -- npx @playwright/mcp@latest
  /exit && claude
"

## Your Responsibilities
- Write and run automated tests
- E2E testing with Playwright
- Integration testing
- Unit test validation
- Test coverage reporting

## Testing Protocol
1. **Check MCP Status**
   - Verify Playwright is connected
   - If not, guide user to connect it

2. **Run Tests**
   - Unit tests first
   - Then integration tests
   - Finally E2E tests with Playwright

3. **Report Results**
   - Pass/fail summary
   - Coverage metrics
   - Screenshots of failures

## Working with Playwright
When Playwright is connected, you can:
- Navigate to URLs
- Click elements
- Fill forms
- Take screenshots
- Run E2E test scenarios

Always verify Playwright is available before attempting browser automation.
```

---

### 3. Multi-Environment via Multiple Config Files

**For Supabase staging vs production:**

```
agent-11/
├── .mcp-profiles/
│   ├── database-staging.json      # Supabase staging
│   └── database-production.json   # Supabase production (read-only)
└── .env.mcp
```

**File:** `.mcp-profiles/database-staging.json`
```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["@context7/mcp-server"],
      "env": { "CONTEXT7_API_KEY": "${CONTEXT7_API_KEY}" }
    },
    "github": {
      "command": "npx",
      "args": ["@edjl/github-mcp"],
      "env": { "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_PERSONAL_ACCESS_TOKEN}" }
    },
    "filesystem": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-filesystem", "${HOME}/DevProjects"]
    },
    "supabase-staging": {
      "command": "npx",
      "args": [
        "@supabase/mcp-server",
        "--access-token", "${SUPABASE_STAGING_TOKEN}",
        "--project-ref", "${SUPABASE_STAGING_REF}"
      ]
    }
  }
}
```

**File:** `.mcp-profiles/database-production.json`
```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["@context7/mcp-server"],
      "env": { "CONTEXT7_API_KEY": "${CONTEXT7_API_KEY}" }
    },
    "github": {
      "command": "npx",
      "args": ["@edjl/github-mcp"],
      "env": { "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_PERSONAL_ACCESS_TOKEN}" }
    },
    "filesystem": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-filesystem", "${HOME}/DevProjects"]
    },
    "supabase-production": {
      "command": "npx",
      "args": [
        "@supabase/mcp-server",
        "--access-token", "${SUPABASE_PRODUCTION_TOKEN}",
        "--project-ref", "${SUPABASE_PRODUCTION_REF}",
        "--read-only"
      ]
    }
  }
}
```

**Agent warns about environment:**

```markdown
# Developer Agent

## Database Operations

**CRITICAL: Check which database you're connected to**

Before any database operation, verify environment:
1. Check .mcp.json symlink: `ls -l .mcp.json`
2. If pointing to database-production.json: **READ-ONLY MODE**
3. If pointing to database-staging.json: **READ/WRITE MODE**

**To switch environments:**

Staging (read/write):
  ln -sf .mcp-profiles/database-staging.json .mcp.json
  /exit && claude

Production (read-only):
  ln -sf .mcp-profiles/database-production.json .mcp.json
  /exit && claude

**Always confirm with user before switching to production.**
```

---

### 4. Mission Documentation with MCP Requirements

**Missions document which profile to use:**

**File:** `missions/test.md`

```markdown
# Test Mission

## Required MCP Profile
**testing** (core + playwright)

## Before Starting
Ensure you're using the testing profile:
```bash
ls -l .mcp.json
# Should point to: .mcp-profiles/testing.json
```

If not, switch to testing profile:
```bash
ln -sf .mcp-profiles/testing.json .mcp.json
/exit && claude
```

## Mission Brief
Run comprehensive test suite including unit, integration, and E2E tests.

## Execution Steps
1. **Verify MCP Status**
   - Check Playwright is connected: /mcp
   - If not connected, guide user to switch profile

2. **Run Unit Tests**
   - Execute Jest/Vitest tests
   - Generate coverage report

3. **Run Integration Tests**
   - Test API endpoints
   - Test database operations

4. **Run E2E Tests (Playwright)**
   - Test user flows
   - Test critical paths
   - Capture screenshots on failure

5. **Report Results**
   - Aggregate test results
   - Generate HTML report
   - Update documentation

## Success Criteria
- All tests pass
- Coverage > 80%
- No E2E failures
```

---

## Complete Implementation

### File Structure (Documentation Only)

```
agent-11/
├── .claude/
│   └── agents/                    # Updated with MCP awareness
│       ├── coordinator.md         # Updated
│       ├── tester.md              # Updated with Playwright requirements
│       ├── developer.md           # Updated with DB environment warnings
│       └── ...
│
├── .mcp-profiles/                 # NEW: Profile configurations
│   ├── core.json                  # Essential MCPs only
│   ├── testing.json               # Core + Playwright
│   ├── database-staging.json      # Core + Supabase staging
│   ├── database-production.json   # Core + Supabase production (read-only)
│   ├── payments.json              # Core + Stripe
│   ├── deployment.json            # Core + Netlify + Railway
│   └── fullstack.json             # All MCPs
│
├── docs/
│   ├── MCP-GUIDE.md               # NEW: User guide for MCP management
│   ├── MCP-PROFILES.md            # NEW: Profile descriptions
│   └── MCP-TROUBLESHOOTING.md     # NEW: Common issues
│
├── missions/                      # Updated with profile requirements
│   ├── test.md                    # Updated
│   ├── deploy.md                  # Updated
│   └── ...
│
├── .mcp.json -> .mcp-profiles/core.json  # Symlink (not committed)
├── .env.mcp.template              # Updated with staging/production vars
├── .gitignore                     # Updated to ignore .mcp.json
└── README.md                      # Updated with MCP instructions
```

---

## Implementation Details

### 1. MCP Profile Files

#### Core Profile (Always Loaded)

**File:** `.mcp-profiles/core.json`

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["@context7/mcp-server"],
      "env": {
        "CONTEXT7_API_KEY": "${CONTEXT7_API_KEY}"
      }
    },
    "github": {
      "command": "npx",
      "args": ["@edjl/github-mcp"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_PERSONAL_ACCESS_TOKEN}"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-filesystem", "${HOME}/DevProjects"]
    }
  }
}
```

**Context:** ~3,000 tokens  
**Use:** Default profile for all work

---

#### Testing Profile

**File:** `.mcp-profiles/testing.json`

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["@context7/mcp-server"],
      "env": {
        "CONTEXT7_API_KEY": "${CONTEXT7_API_KEY}"
      }
    },
    "github": {
      "command": "npx",
      "args": ["@edjl/github-mcp"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_PERSONAL_ACCESS_TOKEN}"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-filesystem", "${HOME}/DevProjects"]
    },
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  }
}
```

**Context:** ~5,500 tokens  
**Use:** Automated testing with Playwright

---

#### Database Staging Profile

**File:** `.mcp-profiles/database-staging.json`

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["@context7/mcp-server"],
      "env": {
        "CONTEXT7_API_KEY": "${CONTEXT7_API_KEY}"
      }
    },
    "github": {
      "command": "npx",
      "args": ["@edjl/github-mcp"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_PERSONAL_ACCESS_TOKEN}"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-filesystem", "${HOME}/DevProjects"]
    },
    "supabase-staging": {
      "command": "npx",
      "args": [
        "@supabase/mcp-server",
        "--access-token", "${SUPABASE_STAGING_TOKEN}",
        "--project-ref", "${SUPABASE_STAGING_REF}"
      ]
    }
  }
}
```

**Context:** ~8,000 tokens  
**Use:** Database work on staging (read/write)

---

#### Database Production Profile

**File:** `.mcp-profiles/database-production.json`

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["@context7/mcp-server"],
      "env": {
        "CONTEXT7_API_KEY": "${CONTEXT7_API_KEY}"
      }
    },
    "github": {
      "command": "npx",
      "args": ["@edjl/github-mcp"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_PERSONAL_ACCESS_TOKEN}"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-filesystem", "${HOME}/DevProjects"]
    },
    "supabase-production": {
      "command": "npx",
      "args": [
        "@supabase/mcp-server",
        "--access-token", "${SUPABASE_PRODUCTION_TOKEN}",
        "--project-ref", "${SUPABASE_PRODUCTION_REF}",
        "--read-only"
      ]
    }
  }
}
```

**Context:** ~8,000 tokens  
**Use:** Database queries on production (read-only)

---

#### Payments Profile

**File:** `.mcp-profiles/payments.json`

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["@context7/mcp-server"],
      "env": {
        "CONTEXT7_API_KEY": "${CONTEXT7_API_KEY}"
      }
    },
    "github": {
      "command": "npx",
      "args": ["@edjl/github-mcp"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_PERSONAL_ACCESS_TOKEN}"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-filesystem", "${HOME}/DevProjects"]
    },
    "stripe": {
      "command": "npx",
      "args": ["@stripe/mcp-server"],
      "env": {
        "STRIPE_API_KEY": "${STRIPE_API_KEY}"
      }
    }
  }
}
```

**Context:** ~7,000 tokens  
**Use:** Payment integration with Stripe

---

#### Deployment Profile

**File:** `.mcp-profiles/deployment.json`

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["@context7/mcp-server"],
      "env": {
        "CONTEXT7_API_KEY": "${CONTEXT7_API_KEY}"
      }
    },
    "github": {
      "command": "npx",
      "args": ["@edjl/github-mcp"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_PERSONAL_ACCESS_TOKEN}"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-filesystem", "${HOME}/DevProjects"]
    },
    "netlify": {
      "command": "npx",
      "args": ["-y", "@netlify/mcp"],
      "env": {
        "NETLIFY_ACCESS_TOKEN": "${NETLIFY_ACCESS_TOKEN}"
      }
    },
    "railway": {
      "command": "npx",
      "args": ["-y", "@railway/mcp-server"],
      "env": {
        "RAILWAY_API_TOKEN": "${RAILWAY_API_TOKEN}"
      }
    }
  }
}
```

**Context:** ~6,000 tokens  
**Use:** Deploying to Netlify and Railway

---

#### Fullstack Profile

**File:** `.mcp-profiles/fullstack.json`

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["@context7/mcp-server"],
      "env": {
        "CONTEXT7_API_KEY": "${CONTEXT7_API_KEY}"
      }
    },
    "github": {
      "command": "npx",
      "args": ["@edjl/github-mcp"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_PERSONAL_ACCESS_TOKEN}"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-filesystem", "${HOME}/DevProjects"]
    },
    "supabase-staging": {
      "command": "npx",
      "args": [
        "@supabase/mcp-server",
        "--access-token", "${SUPABASE_STAGING_TOKEN}",
        "--project-ref", "${SUPABASE_STAGING_REF}"
      ]
    },
    "stripe": {
      "command": "npx",
      "args": ["@stripe/mcp-server"],
      "env": {
        "STRIPE_API_KEY": "${STRIPE_API_KEY}"
      }
    },
    "netlify": {
      "command": "npx",
      "args": ["-y", "@netlify/mcp"],
      "env": {
        "NETLIFY_ACCESS_TOKEN": "${NETLIFY_ACCESS_TOKEN}"
      }
    },
    "railway": {
      "command": "npx",
      "args": ["-y", "@railway/mcp-server"],
      "env": {
        "RAILWAY_API_TOKEN": "${RAILWAY_API_TOKEN}"
      }
    }
  }
}
```

**Context:** ~15,000 tokens  
**Use:** Full-stack development (use sparingly)

---

### 2. Updated Agent Prompts

#### Coordinator Agent (MCP-Aware)

**File:** `.claude/agents/coordinator.md`

```markdown
# Coordinator Agent

You are the Mission Coordinator for AGENT-11.

## MCP Profile Management

Before starting any mission, check which MCP profile is active:
```bash
ls -l .mcp.json
```

**Profile Recommendations by Mission:**
- **test**: testing profile (core + playwright)
- **db-migrate**: database-staging profile
- **deploy**: deployment profile
- **payment-integration**: payments profile

**If wrong profile is active:**
Guide the user to switch:
```bash
ln -sf .mcp-profiles/testing.json .mcp.json
/exit && claude
```

## Your Responsibilities
- Orchestrate multi-agent missions
- Ensure correct MCP profile is active
- Coordinate agent handoffs
- Track mission progress
- Ensure quality deliverables

## Mission Execution Protocol

1. **Check MCP Profile**
   - Verify correct profile for mission
   - Guide user to switch if needed

2. **Assign Agents**
   - Determine which agents are needed
   - Ensure agents have required MCPs

3. **Coordinate Work**
   - Manage agent handoffs
   - Track progress
   - Resolve conflicts

4. **Deliver Results**
   - Aggregate deliverables
   - Verify quality
   - Update documentation

## Profile Switching Guide

**For Testing:**
```bash
ln -sf .mcp-profiles/testing.json .mcp.json
/exit && claude
```

**For Database (Staging):**
```bash
ln -sf .mcp-profiles/database-staging.json .mcp.json
/exit && claude
```

**For Database (Production - READ ONLY):**
```bash
ln -sf .mcp-profiles/database-production.json .mcp.json
/exit && claude
```

**For Deployment:**
```bash
ln -sf .mcp-profiles/deployment.json .mcp.json
/exit && claude
```

Always confirm with user before switching profiles.
```

---

#### Tester Agent (Playwright-Aware)

**File:** `.claude/agents/tester.md`

```markdown
# Tester Agent

You are the Testing Specialist for AGENT-11.

## Required MCP Profile
**testing** (core + playwright)

## Before Starting Work

Check if correct profile is active:
```bash
ls -l .mcp.json
# Should point to: .mcp-profiles/testing.json
```

If not, guide user:
"I need the testing profile for Playwright. Please run:
```bash
ln -sf .mcp-profiles/testing.json .mcp.json
/exit && claude
```"

## Verify Playwright Connection

Check Playwright is available:
```bash
/mcp
```

Look for "playwright" in the list. If not present, the profile switch didn't work.

## Your Responsibilities
- Write and run automated tests
- E2E testing with Playwright
- Integration testing
- Unit test validation
- Test coverage reporting

## Testing Protocol

1. **Verify MCP Status**
   - Confirm testing profile is active
   - Confirm Playwright is connected

2. **Run Tests**
   - Unit tests first
   - Then integration tests
   - Finally E2E tests with Playwright

3. **Report Results**
   - Pass/fail summary
   - Coverage metrics
   - Screenshots of failures

## Playwright Capabilities

When Playwright is connected, you can:
- Navigate to URLs
- Click elements
- Fill forms
- Take screenshots
- Run E2E test scenarios
- Test responsive design
- Validate accessibility

## If Playwright is Not Available

If you try to use Playwright and it's not connected:
1. Stop the current task
2. Tell the user: "Playwright MCP is not connected. Please switch to testing profile."
3. Provide the switch command
4. Wait for user to restart Claude Code

Never attempt browser automation without Playwright connected.
```

---

#### Developer Agent (Database-Aware)

**File:** `.claude/agents/developer.md`

```markdown
# Developer Agent

You are the Development Specialist for AGENT-11.

## Database Operations Safety

**CRITICAL: Always check which database environment you're connected to**

Before any database operation:
```bash
ls -l .mcp.json
```

**If pointing to database-production.json:**
- ⚠️ **PRODUCTION DATABASE**
- **READ-ONLY MODE**
- No writes allowed
- Only queries and analysis

**If pointing to database-staging.json:**
- ✅ **STAGING DATABASE**
- Read/write mode
- Safe for development

## Environment Switching

**To Staging (read/write):**
```bash
ln -sf .mcp-profiles/database-staging.json .mcp.json
/exit && claude
```

**To Production (read-only):**
```bash
ln -sf .mcp-profiles/database-production.json .mcp.json
/exit && claude
```

**Always confirm with user before switching to production.**

## Your Responsibilities
- Implement features
- Write clean code
- Database operations
- API integration
- Code review

## Database Operation Protocol

1. **Check Environment**
   - Verify which database is connected
   - Confirm with user if production

2. **Execute Operation**
   - Staging: Full read/write access
   - Production: Read-only queries

3. **Verify Results**
   - Test changes in staging
   - Validate data integrity

## If User Needs Production Access

If user requests production database operation:
1. Confirm it's necessary
2. Warn about read-only mode
3. Guide to switch profile
4. Remind them to switch back to staging after

## MCP Profile Recommendations

- **Database work**: database-staging profile
- **Production queries**: database-production profile
- **Payment integration**: payments profile
- **General development**: core profile

Always verify correct profile is active before starting work.
```

---

### 3. Updated Environment Variables

**File:** `.env.mcp.template`

```bash
# =====================================================
# AGENT-11 MCP Environment Variables
# =====================================================
# Copy this file to .env.mcp and fill in your values
# CRITICAL: Keep .env.mcp in .gitignore

# ─────────────────────────────────────────────────────
# Core MCPs (Required)
# ─────────────────────────────────────────────────────

# Context7 - Documentation & Code Analysis
CONTEXT7_API_KEY=your_context7_api_key_here

# GitHub - Repository Management
# Get from: https://github.com/settings/tokens
# Scopes: repo, workflow
GITHUB_PERSONAL_ACCESS_TOKEN=your_github_pat_here

# ─────────────────────────────────────────────────────
# Database MCPs (Optional)
# ─────────────────────────────────────────────────────

# Supabase Staging (read/write)
# Get from: https://app.supabase.com/project/_/settings/api
SUPABASE_STAGING_TOKEN=your_staging_service_role_key_here
SUPABASE_STAGING_REF=your_staging_project_ref_here

# Supabase Production (read-only)
SUPABASE_PRODUCTION_TOKEN=your_production_service_role_key_here
SUPABASE_PRODUCTION_REF=your_production_project_ref_here

# ─────────────────────────────────────────────────────
# Payment MCPs (Optional)
# ─────────────────────────────────────────────────────

# Stripe - Payment Processing
# Get from: https://dashboard.stripe.com/apikeys
# Use test keys for development
STRIPE_API_KEY=sk_test_your_stripe_test_key_here

# ─────────────────────────────────────────────────────
# Deployment MCPs (Optional)
# ─────────────────────────────────────────────────────

# Netlify - Frontend Deployment
NETLIFY_ACCESS_TOKEN=your_netlify_access_token_here

# Railway - Backend Deployment
RAILWAY_API_TOKEN=your_railway_api_token_here

# =====================================================
# MCP Profile Guide
# =====================================================
#
# Switch profiles with symlinks:
#
# Core (default):
#   ln -sf .mcp-profiles/core.json .mcp.json
#
# Testing (Playwright):
#   ln -sf .mcp-profiles/testing.json .mcp.json
#
# Database Staging (read/write):
#   ln -sf .mcp-profiles/database-staging.json .mcp.json
#
# Database Production (read-only):
#   ln -sf .mcp-profiles/database-production.json .mcp.json
#
# Payments (Stripe):
#   ln -sf .mcp-profiles/payments.json .mcp.json
#
# Deployment (Netlify + Railway):
#   ln -sf .mcp-profiles/deployment.json .mcp.json
#
# After switching, restart Claude Code:
#   /exit && claude
#
# =====================================================
```

---

### 4. User Documentation

**File:** `docs/MCP-GUIDE.md`

```markdown
# AGENT-11 MCP Management Guide

## Overview

AGENT-11 uses **MCP profiles** to optimize context usage. Instead of loading all MCPs at once, you switch between profiles based on your current work.

## Quick Start

### 1. Check Current Profile

```bash
ls -l .mcp.json
```

Shows which profile is currently active.

### 2. Switch Profile

```bash
# Switch to testing profile
ln -sf .mcp-profiles/testing.json .mcp.json

# Restart Claude Code
/exit && claude
```

### 3. Verify MCPs

```bash
/mcp
```

Shows all connected MCPs.

---

## Available Profiles

### Core (Default)
**MCPs:** context7, github, filesystem  
**Context:** ~3,000 tokens  
**Use:** General development work

```bash
ln -sf .mcp-profiles/core.json .mcp.json
/exit && claude
```

---

### Testing
**MCPs:** core + playwright  
**Context:** ~5,500 tokens  
**Use:** Automated testing, E2E tests

```bash
ln -sf .mcp-profiles/testing.json .mcp.json
/exit && claude
```

**When to use:**
- Running `/coord test` mission
- E2E testing with Playwright
- Browser automation

---

### Database Staging
**MCPs:** core + supabase-staging  
**Context:** ~8,000 tokens  
**Use:** Database development (read/write)

```bash
ln -sf .mcp-profiles/database-staging.json .mcp.json
/exit && claude
```

**When to use:**
- Database migrations
- Schema changes
- Development queries
- Testing database operations

---

### Database Production
**MCPs:** core + supabase-production  
**Context:** ~8,000 tokens  
**Use:** Production queries (read-only)

```bash
ln -sf .mcp-profiles/database-production.json .mcp.json
/exit && claude
```

**⚠️ READ-ONLY MODE**
- No writes allowed
- Only for queries and analysis
- Use staging for development

**When to use:**
- Analyzing production data
- Debugging production issues
- Generating reports

---

### Payments
**MCPs:** core + stripe  
**Context:** ~7,000 tokens  
**Use:** Payment integration

```bash
ln -sf .mcp-profiles/payments.json .mcp.json
/exit && claude
```

**When to use:**
- Stripe integration
- Payment processing
- Subscription management

---

### Deployment
**MCPs:** core + netlify + railway  
**Context:** ~6,000 tokens  
**Use:** Deploying applications

```bash
ln -sf .mcp-profiles/deployment.json .mcp.json
/exit && claude
```

**When to use:**
- Deploying to Netlify
- Deploying to Railway
- Running `/coord deploy` mission

---

### Fullstack
**MCPs:** core + supabase + stripe + netlify + railway  
**Context:** ~15,000 tokens  
**Use:** Comprehensive full-stack work

```bash
ln -sf .mcp-profiles/fullstack.json .mcp.json
/exit && claude
```

**⚠️ HIGH CONTEXT USAGE**
- Only use when you need multiple services
- Consider using specific profiles instead

---

## Profile Switching Workflow

### Scenario 1: Running Tests

```bash
# 1. Switch to testing profile
ln -sf .mcp-profiles/testing.json .mcp.json
/exit && claude

# 2. Run test mission
/coord test

# 3. After testing, switch back to core
ln -sf .mcp-profiles/core.json .mcp.json
/exit && claude
```

---

### Scenario 2: Database Migration

```bash
# 1. Switch to database staging
ln -sf .mcp-profiles/database-staging.json .mcp.json
/exit && claude

# 2. Run migration
/coord db-migrate

# 3. Verify in production (read-only)
ln -sf .mcp-profiles/database-production.json .mcp.json
/exit && claude

# 4. Check production data
@developer "Query the users table and show me the schema"

# 5. Switch back to staging
ln -sf .mcp-profiles/database-staging.json .mcp.json
/exit && claude
```

---

### Scenario 3: Full Deployment

```bash
# 1. Run tests first
ln -sf .mcp-profiles/testing.json .mcp.json
/exit && claude
/coord test

# 2. Switch to deployment
ln -sf .mcp-profiles/deployment.json .mcp.json
/exit && claude

# 3. Deploy
/coord deploy

# 4. Switch back to core
ln -sf .mcp-profiles/core.json .mcp.json
/exit && claude
```

---

## Troubleshooting

### Profile switch didn't work

**Problem:** Switched profile but MCPs didn't change

**Solution:**
```bash
# Make sure you restarted Claude Code
/exit
claude

# Verify symlink
ls -l .mcp.json

# Check MCPs
/mcp
```

---

### Missing environment variables

**Problem:** MCP won't connect, missing credentials

**Solution:**
```bash
# Check .env.mcp exists
ls .env.mcp

# If missing, copy template
cp .env.mcp.template .env.mcp

# Edit and add your API keys
nano .env.mcp
```

---

### Accidentally connected to production

**Problem:** Connected to production database, need to switch back

**Solution:**
```bash
# Immediately switch to staging
ln -sf .mcp-profiles/database-staging.json .mcp.json
/exit && claude

# Verify
ls -l .mcp.json
# Should point to database-staging.json
```

---

## Best Practices

1. **Start with core profile** - Only switch when needed
2. **Switch back after missions** - Return to core profile
3. **Never commit .mcp.json** - It's in .gitignore
4. **Verify environment** - Always check which database you're connected to
5. **Use staging for development** - Only use production for read-only queries

---

## Context Savings

| Profile | Context Usage | Savings vs Fullstack |
|---------|---------------|----------------------|
| Core | 3,000 tokens | 80% reduction |
| Testing | 5,500 tokens | 63% reduction |
| Database | 8,000 tokens | 47% reduction |
| Payments | 7,000 tokens | 53% reduction |
| Deployment | 6,000 tokens | 60% reduction |
| Fullstack | 15,000 tokens | Baseline |

By using specific profiles, you save **47-80% context** compared to loading all MCPs.
```

---

### 5. Updated Installation Script

**File:** `project/deployment/scripts/install.sh`

```bash
#!/bin/bash
# AGENT-11 Installation Script (Updated for MCP Profiles)

set -e

echo "🚀 Installing AGENT-11..."

# Create directory structure
mkdir -p .claude/agents
mkdir -p .mcp-profiles
mkdir -p missions
mkdir -p docs

# Copy agent files
echo "📦 Installing agents..."
cp -r agents/* .claude/agents/

# Copy MCP profile files
echo "📦 Installing MCP profiles..."
cp -r mcp-profiles/* .mcp-profiles/

# Copy mission files
echo "📦 Installing missions..."
cp -r missions/* missions/

# Copy documentation
echo "📖 Installing documentation..."
cp -r docs/* docs/

# Setup environment variables
if [ ! -f .env.mcp ]; then
  echo "📝 Creating .env.mcp from template..."
  cp .env.mcp.template .env.mcp
  echo "⚠️  Please edit .env.mcp and add your API keys"
fi

# Create symlink to core profile (default)
if [ ! -f .mcp.json ]; then
  echo "🔗 Setting up default MCP profile (core)..."
  ln -sf .mcp-profiles/core.json .mcp.json
fi

# Update .gitignore
if ! grep -q ".mcp.json" .gitignore 2>/dev/null; then
  echo "📝 Updating .gitignore..."
  cat >> .gitignore << EOF

# AGENT-11 MCP System
.mcp.json
.env.mcp
EOF
fi

echo ""
echo "✅ AGENT-11 installed successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Edit .env.mcp and add your API keys"
echo "2. Restart Claude Code: /exit && claude"
echo "3. Verify installation: /agents"
echo "4. Check MCP profile: ls -l .mcp.json"
echo "5. Check connected MCPs: /mcp"
echo ""
echo "📚 Documentation:"
echo "- MCP Guide: docs/MCP-GUIDE.md"
echo "- Profile Reference: docs/MCP-PROFILES.md"
echo "- Troubleshooting: docs/MCP-TROUBLESHOOTING.md"
echo ""
echo "🎯 Current profile: core (context7, github, filesystem)"
echo "   To switch profiles, see docs/MCP-GUIDE.md"
```

---

### 6. Updated .gitignore

**File:** `.gitignore`

```gitignore
# AGENT-11 MCP System
.mcp.json          # Symlink to active profile (user-specific)
.env.mcp           # Environment variables with API keys
```

---

## Implementation Steps

### Phase 1: Create Profile Files (1 hour)

1. Create `.mcp-profiles/` directory
2. Create all 7 profile JSON files:
   - `core.json`
   - `testing.json`
   - `database-staging.json`
   - `database-production.json`
   - `payments.json`
   - `deployment.json`
   - `fullstack.json`

**Validation:**
```bash
ls .mcp-profiles/
# Should show 7 .json files
```

---

### Phase 2: Update Agent Prompts (2 hours)

1. Update `coordinator.md` with MCP profile awareness
2. Update `tester.md` with Playwright requirements
3. Update `developer.md` with database environment warnings
4. Update other agents as needed

**Validation:**
```bash
grep "MCP Profile" .claude/agents/*.md
# Should show MCP awareness in agents
```

---

### Phase 3: Update Documentation (2 hours)

1. Create `docs/MCP-GUIDE.md`
2. Create `docs/MCP-PROFILES.md`
3. Create `docs/MCP-TROUBLESHOOTING.md`
4. Update `README.md` with MCP instructions

**Validation:**
```bash
ls docs/MCP-*.md
# Should show 3 documentation files
```

---

### Phase 4: Update Installation (1 hour)

1. Update `install.sh` to copy profile files
2. Update `.env.mcp.template` with staging/production vars
3. Update `.gitignore` to exclude `.mcp.json`

**Validation:**
```bash
./project/deployment/scripts/install.sh
ls -l .mcp.json
# Should be symlink to core.json
```

---

### Phase 5: Update Missions (1 hour)

1. Add profile requirements to mission files
2. Update mission documentation

**Validation:**
```bash
grep "Required MCP Profile" missions/*.md
# Should show profile requirements
```

---

### Phase 6: Testing (1 hour)

1. Test profile switching
2. Test with each profile
3. Test environment switching
4. Verify context savings

**Validation:**
```bash
# Switch to testing
ln -sf .mcp-profiles/testing.json .mcp.json
/exit && claude
/mcp
# Should show playwright

# Switch back to core
ln -sf .mcp-profiles/core.json .mcp.json
/exit && claude
/mcp
# Should NOT show playwright
```

---

## Total Implementation Time: 8 hours (1 day)

---

## Benefits of This Approach

### ✅ No Runtime Code
- Pure documentation
- No JavaScript files
- No complex state management
- Works with agent-11's architecture

### ✅ Uses Claude Code Native Features
- Standard `.mcp.json` format
- Native `/mcp` command
- No custom commands needed
- Symlinks for profile switching

### ✅ Simple Implementation
- 7 JSON profile files
- Update agent prompts
- Add documentation
- Update installation script

### ✅ User-Friendly
- Clear instructions in agent prompts
- Simple symlink switching
- Visual confirmation (ls -l)
- No complex commands

### ✅ Solves All Problems
- **Context waste:** 47-80% reduction
- **Multi-environment:** Separate staging/production profiles
- **Safety:** Read-only production enforced in config
- **UX:** Agents guide users through switching

---

## Migration from Current Setup

### For Existing Users

```bash
# 1. Backup current config
cp .mcp.json .mcp.json.backup

# 2. Pull latest agent-11
git pull origin main

# 3. Run installation
./project/deployment/scripts/install.sh

# 4. Update environment variables
cp .env.mcp.template .env.mcp
# Edit .env.mcp with your API keys

# 5. Restart Claude Code
/exit && claude

# 6. Verify
ls -l .mcp.json
# Should point to .mcp-profiles/core.json

/mcp
# Should show core MCPs only
```

### Rollback

```bash
# Restore backup
cp .mcp.json.backup .mcp.json
/exit && claude
```

---

## Comparison: Old vs New

| Aspect | Old Approach | New Approach |
|--------|--------------|--------------|
| **Architecture** | Single `.mcp.json` | Multiple profile files |
| **Context Usage** | 25,000 tokens (all MCPs) | 3,000-8,000 tokens (profile-based) |
| **Environment Switching** | Manual credential swap | Separate profile files |
| **Safety** | No read-only enforcement | Production profile is read-only |
| **User Action** | Edit `.mcp.json`, restart | Symlink switch, restart |
| **Agent Awareness** | None | Agents guide profile switching |
| **Implementation** | N/A | 8 hours (documentation only) |

---

## Conclusion

This documentation-only approach:
- ✅ Works with agent-11's architecture (no runtime code)
- ✅ Uses Claude Code's native capabilities
- ✅ Solves context waste (47-80% reduction)
- ✅ Enables multi-environment (staging/production)
- ✅ Enforces safety (read-only production)
- ✅ Simple to implement (8 hours)
- ✅ Easy to use (symlink switching)
- ✅ Agent-guided (prompts tell users what to do)

**Ready for implementation in 1 day.**

