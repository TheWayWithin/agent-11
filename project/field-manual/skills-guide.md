# Skills Guide

**Version**: 2.0.0 (Sprint 4g — v6.0 evolution)
**Last Updated**: 2026-04-27

## Overview

Skills are domain-specific knowledge packages that the Coordinator loads based on task context. They provide production-ready code patterns, best practices, and implementation guidance for common features.

## 3-Tier Architecture

AGENT-11 organises skills in three tiers:

| Tier | What | Where it lives | Audience |
|------|------|----------------|----------|
| **Tier 1 — Behavioural** | Cross-cutting principles every specialist applies | `.claude/CLAUDE.md` (Karpathy constitution — shipped Sprint 4d) | Framework-internal |
| **Tier 2 — Project Domain** | Project-specific decisions, conventions, business logic | User project's local `skills/` directory (create post-install if needed) | Project-specific |
| **Tier 3 — Marketplace** | Curated reusable patterns | `.claude/skills/` (shipped by AGENT-11 install.sh) | Library users |

The 7 SaaS skills documented below are **Tier 3**. They align with Anthropic's [Agent Skills open standard](https://agentskills.io/specification): each ships with `name` + `description` in frontmatter (the spec's required fields), plus AGENT-11-specific custom fields (`triggers`, `specialist`, `complexity`, etc.) that our coordinator's loading mechanism uses today.

This hybrid format keeps skills forward-compatible with future marketplace publishing (the `description` field embeds trigger keywords for Anthropic's progressive-disclosure loading) while remaining fully functional under our existing `triggers`-array matching.

**Note on publishing**: v6.0 formats Tier 3 skills for the open standard but does **not** publish to a public marketplace. Publishing is a future decision.

## Progressive Disclosure in AGENT-11

A common question when reviewing skills: "should we add a router skill that decides which skills to load?" The answer is no, because progressive disclosure already happens at the platform level. Future contributors should understand this before reimplementing it.

### What v6.0 already does

1. **Skills are loaded on demand by the Skill tool, not at session start.** The Skill tool inspects each skill's `description` frontmatter against the user's intent and loads only the matching skills. None of the 7 SaaS skills sit in context until a task triggers them.
2. **MCP tools defer-load via `ENABLE_TOOL_SEARCH=auto`** (set in `.claude/settings.json`). Specialists discover MCP tools at runtime via `tool_search_tool_regex_20251119(pattern="mcp__SERVERNAME")`. This is documented in `library/CLAUDE.md` and `field-manual/mcp-integration.md`.
3. **Coordinator context loading is mode-aware.** Mode A (greenfield) reads `project-plan.md` + `agent-context.md` + mission file; Mode B1 (surgical) reads only the bug report; Mode B2 (maintenance) reads `project-plan.md` if present. `evidence-repository.md` and `progress.md` are on-demand only. See `project/agents/specialists/coordinator.md` `DYNAMIC CONTEXT LOADING` section.
4. **Specialists carry tool allowlists in frontmatter.** Each specialist declares only the tools it can call (`tools: Read, Bash, Task` for the developer, etc.); the platform enforces the allowlist.

### What this means for skill authors

- **Do not write a "router skill" or `using-skills` meta-skill.** The Skill tool's description-matching is the router. A handwritten router would duplicate it and fight for control.
- **Make the `description` field carry the trigger semantics.** That is the field the platform matches against. A vague description means the skill fires too often or too rarely.
- **Keep the main `SKILL.md` lean.** Stack-specific or framework-specific code belongs in `references/` subfolders that the agent loads only when the project's stack matches. `saas-payments` and `saas-auth` follow this pattern (`references/nextjs-supabase.md`, `references/remix-railway.md`).
- **Trust the platform's lazy-load on MCP tools.** Do not pre-load `mcp__supabase` references inside a skill; the agent will discover them at runtime when needed.

### Anti-pattern

Writing a "skill router" skill that contains a decision tree for which skill to load. This duplicates the platform layer and adds tokens to every session without paying back.

## Available Skills

| Skill | Triggers | Specialist | Tokens |
|-------|----------|------------|--------|
| `saas-auth` | auth, login, oauth, password | @developer | ~3,800 |
| `saas-payments` | stripe, checkout, subscription | @developer | ~4,200 |
| `saas-multitenancy` | tenant, org, rls, workspace | @architect | ~4,100 |
| `saas-billing` | billing, plan, quota, trial | @developer | ~3,900 |
| `saas-email` | email, resend, notification | @developer | ~3,200 |
| `saas-onboarding` | onboarding, wizard, activation | @developer | ~3,500 |
| `saas-analytics` | analytics, tracking, posthog | @analyst | ~3,600 |

## Quick Start

### Automatic Loading

Skills load automatically when task descriptions contain trigger keywords:

```markdown
# In project-plan.md
- [ ] Implement user authentication with OAuth (@developer)
```

The Coordinator detects "authentication" and "OAuth" → loads `saas-auth` skill → delegates to @developer with skill context.

### Manual Discovery

```bash
# List all skills
/skills

# Show skill details
/skills saas-auth

# Find matching skills for a task
/skills match "implement stripe payments"

# Show current stack profile
/skills stack
```

## Skill Structure

Each skill is a `SKILL.md` file in `project/skills/[skill-name]/`:

```yaml
---
name: saas-auth
version: 1.0.0
category: authentication
triggers:
  - auth
  - login
  - oauth
  - password
specialist: "@developer"
complexity: intermediate
estimated_tokens: 3800
dependencies: []
---

# Authentication Patterns

## Capability
What this skill enables...

## Patterns
### Pattern 1: Email/Password
Code and implementation details...

### Pattern 2: OAuth
Code and implementation details...

## Stack Implementations
### Next.js + Supabase
Specific implementation...

### Remix + Lucia
Specific implementation...

## Quality Checklist
- [ ] Password hashing uses bcrypt/argon2
- [ ] Sessions have appropriate expiry
- [ ] OAuth state parameter validated
```

## Skill Contents

### 1. saas-auth

**Purpose**: User authentication and session management

**Patterns**:
- Email/Password authentication
- OAuth (Google, GitHub)
- Magic link authentication
- Session management
- Password reset flows

**Stack Support**:
- Next.js + Supabase Auth
- Remix + Lucia Auth
- SvelteKit + Supabase Auth

### 2. saas-payments

**Purpose**: Stripe integration for payments

**Patterns**:
- Checkout Session creation
- Subscription management
- Webhook handling
- Customer portal
- Metered billing

**Stack Support**:
- All stacks with Stripe SDK

### 3. saas-multitenancy

**Purpose**: Multi-tenant architecture with RLS

**Patterns**:
- Organization/Workspace model
- Row-Level Security policies
- Tenant isolation
- Member management
- Role-based access

**Stack Support**:
- Supabase RLS
- PostgreSQL policies

### 4. saas-billing

**Purpose**: Subscription and usage tracking

**Patterns**:
- Plan management
- Usage quotas
- Trial periods
- Plan upgrades/downgrades
- Billing cycles

**Stack Support**:
- Stripe Billing
- Custom usage tracking

### 5. saas-email

**Purpose**: Transactional email

**Patterns**:
- Email verification
- Password reset emails
- Welcome emails
- Notification emails
- Email templates

**Stack Support**:
- Resend
- SendGrid
- AWS SES

### 6. saas-onboarding

**Purpose**: User onboarding flows

**Patterns**:
- Welcome wizard
- Profile completion
- Feature tours
- Progress tracking
- Activation metrics

**Stack Support**:
- React state management
- Database progress tracking

### 7. saas-analytics

**Purpose**: Product analytics

**Patterns**:
- Event tracking
- User identification
- Feature usage
- Funnel analysis
- Custom dashboards

**Stack Support**:
- PostHog
- Mixpanel
- Custom analytics

## Stack Profiles

Skills use stack profiles for multi-framework support.

### Available Profiles

| Profile | Frontend | Backend | Auth | Database |
|---------|----------|---------|------|----------|
| `nextjs-supabase` | Next.js 14 | Supabase | Supabase Auth | PostgreSQL |
| `remix-railway` | Remix | Railway | Lucia | PostgreSQL |
| `sveltekit-supabase` | SvelteKit | Supabase | Supabase Auth | PostgreSQL |

### Setting Your Stack

Create `.stack-profile.yaml` in your project root:

```yaml
extends: nextjs-supabase
overrides:
  backend:
    hosting: vercel  # Override default
```

### Stack Interpolation

Skills use `{{stack.*}}` placeholders:

```typescript
// In skill template
import { {{stack.backend.auth_provider}} } from '{{stack.backend.auth_import}}'

// Rendered for nextjs-supabase
import { createClient } from '@supabase/supabase-js'
```

## Token Management

Skills declare their token budget:

```yaml
estimated_tokens: 3800
```

The Coordinator respects a 15K token budget per delegation:
- Maximum 3 skills per delegation
- Skills sorted by relevance
- Lower-priority skills trimmed if over budget

## Creating Custom Skills

### 1. Create Skill Directory

```bash
mkdir -p project/skills/my-custom-skill
```

### 2. Create SKILL.md

```yaml
---
name: my-custom-skill
version: 1.0.0
category: custom
triggers:
  - keyword1
  - keyword2
specialist: "@developer"
complexity: beginner
estimated_tokens: 2000
dependencies: []
---

# My Custom Skill

## Capability
Describe what this skill enables.

## Patterns

### Pattern Name
Description and code examples.

## Quality Checklist
- [ ] Check 1
- [ ] Check 2
```

### 3. Add Stack Implementations (Optional)

```markdown
## Stack Implementations

### Next.js + Supabase
```typescript
// Implementation for this stack
```

### Remix + Railway
```typescript
// Implementation for this stack
```
```

### 4. Register Triggers

Triggers are automatically detected from the YAML frontmatter. Choose keywords that:
- Are specific to your domain
- Won't conflict with other skills
- Reflect how users naturally describe tasks

## Best Practices

### 1. Write Production-Ready Code

Skills should provide code that can be used directly:

```typescript
// Good - Complete, secure, typed
export async function createUser(email: string, password: string) {
  const hashedPassword = await bcrypt.hash(password, 12)
  return db.user.create({
    data: { email, password: hashedPassword }
  })
}

// Bad - Incomplete, insecure
function createUser(email, password) {
  return db.user.create({ email, password })  // Plain text password!
}
```

### 2. Include Error Handling

```typescript
try {
  const session = await stripe.checkout.sessions.create(...)
  return { success: true, url: session.url }
} catch (error) {
  if (error instanceof Stripe.errors.StripeError) {
    return { success: false, error: error.message }
  }
  throw error
}
```

### 3. Provide Quality Checklists

Help specialists verify their implementation:

```markdown
## Quality Checklist
- [ ] Passwords hashed with bcrypt (cost factor >= 12)
- [ ] Sessions expire after 7 days of inactivity
- [ ] OAuth state parameter prevents CSRF
- [ ] Email verification required before access
- [ ] Rate limiting on auth endpoints
```

### 4. Document Stack Variations

Different frameworks need different approaches:

```markdown
### Next.js App Router
Use Server Actions for form handling...

### Remix
Use action functions with redirect...

### SvelteKit
Use form actions with enhance...
```

## Troubleshooting

### "Skill not loading"

Check triggers match task description:
```bash
/skills match "your task description"
```

### "Wrong skill loaded"

Be more specific in task description or use explicit skill reference:
```markdown
- [ ] Implement auth using saas-auth skill (@developer)
```

### "Skill code doesn't match my stack"

Set your stack profile:
```bash
echo "extends: nextjs-supabase" > .stack-profile.yaml
```

### "Token budget exceeded"

Reduce skill complexity or split into smaller tasks:
```markdown
# Instead of:
- [ ] Implement full auth with OAuth, email, and MFA

# Use:
- [ ] Implement email/password auth
- [ ] Add OAuth providers
- [ ] Implement MFA
```

## Related Guides

- [Plan-Driven Development](./plan-driven-development.md) - Overall workflow
- [Coordinator Commands](./coordinator-commands.md) - Command reference
- [Quality Gates Guide](./quality-gates-guide.md) - Gate configuration
