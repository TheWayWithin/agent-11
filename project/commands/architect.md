---
name: architect
description: Generate architecture.md with system design decisions from foundation documents
arguments:
  prd_file:
    type: string
    required: false
    description: Optional path to PRD document (overrides extraction)
flags:
  --mode:
    type: string
    values: [auto, engaged]
    description: Skip mode selection and use specified mode directly
  --stack:
    type: string
    values: [nextjs-supabase, remix-railway, sveltekit-supabase, custom]
    description: Use predefined stack profile
  --output:
    type: string
    default: architecture.md
    description: Output file path
model: opus
---

# /architect Command

## PURPOSE

Generate a comprehensive `architecture.md` document that captures all system design decisions before project planning begins. This bridges the gap between "what to build" (PRD) and "how to build it" (project-plan.md).

**Why This Matters**: PRDs define features but often hand-wave technical decisions. Architecture documentation ensures:
- Tech stack decisions are explicit and justified
- Integration patterns are defined before coding
- Data models are designed before implementation
- Security and scalability are addressed upfront
- Trade-offs are documented for future reference

## WORKFLOW POSITION

```
/foundations init → /architect → /bootstrap → /coord continue
       ↓                ↓              ↓              ↓
   Extract PRD    Design System    Create Plan    Build It
```

**/architect is REQUIRED before /bootstrap** - you can't plan tasks without knowing the architecture.

## PREREQUISITES

Before running `/architect`, ensure:

1. **`/foundations init` has completed successfully**
   - `.context/structured/prd.yaml` exists
   - `.context/structured/vision.yaml` exists (recommended)

2. **PRD contains tech stack hints**
   - Frontend framework mentioned
   - Database preference indicated
   - Key integrations identified

## MODE SELECTION

When you run `/architect` without flags:

```
┌─────────────────────────────────────────────────────────────────┐
│ 🏛️ Architect: System Design                                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ How would you like to proceed?                                  │
│                                                                 │
│ ○ Auto Mode                                                     │
│   Generates architecture from PRD tech stack hints              │
│   Uses sensible defaults for unspecified decisions              │
│                                                                 │
│ ○ Engaged Mode (Recommended)                                    │
│   Walks through each architectural decision                     │
│   Explains trade-offs and asks for your input                   │
│   Produces architecture tailored to your needs                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Skip mode selection**: Use `--mode` flag:
```bash
/architect --mode auto       # Use PRD defaults
/architect --mode engaged    # Interactive design session
```

---

## ENGAGED MODE (Interactive Design Session)

Engaged Mode walks through 7 architectural decision areas:

### Decision 1: Application Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│ 🏗️ Decision 1/7: Application Architecture                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ Your PRD indicates a web application with these features:       │
│   - User authentication                                         │
│   - Dashboard with data visualization                           │
│   - AI-powered features                                         │
│   - Subscription billing                                        │
│                                                                 │
│ Recommended Architecture: Monolithic with Service Extraction    │
│                                                                 │
│ Options:                                                        │
│   1. Monolith (Recommended for MVP)                             │
│      Fast to build, easy to deploy, refactor later              │
│                                                                 │
│   2. Modular Monolith                                           │
│      Clear boundaries, easier to split later                    │
│                                                                 │
│   3. Microservices                                              │
│      ⚠️ Overkill for MVP - adds operational complexity          │
│                                                                 │
│ Select [1/2/3] or describe custom:                              │
└─────────────────────────────────────────────────────────────────┘
```

### Decision 2: Frontend Stack

```
┌─────────────────────────────────────────────────────────────────┐
│ 🎨 Decision 2/7: Frontend Stack                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ Your PRD mentions: "Next.js"                                    │
│                                                                 │
│ Confirming Frontend Stack:                                      │
│                                                                 │
│ Framework: Next.js                                              │
│   Version? [14 (App Router) / 13 (Pages) / Latest]              │
│                                                                 │
│ Rendering Strategy:                                             │
│   1. SSR + Client Components (Recommended for SaaS)             │
│   2. Full SSR (SEO-heavy sites)                                 │
│   3. SPA mode (Dashboard-only apps)                             │
│                                                                 │
│ Styling:                                                        │
│   1. Tailwind CSS (Recommended)                                 │
│   2. CSS Modules                                                │
│   3. Styled Components                                          │
│   4. Other: ___                                                 │
│                                                                 │
│ Component Library:                                              │
│   1. shadcn/ui (Recommended - customizable)                     │
│   2. Radix UI (Primitives only)                                 │
│   3. None (Custom components)                                   │
│   4. Other: ___                                                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Decision 3: Backend & Database

```
┌─────────────────────────────────────────────────────────────────┐
│ 🗄️ Decision 3/7: Backend & Database                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ Your PRD mentions: "Supabase"                                   │
│                                                                 │
│ Database Configuration:                                         │
│                                                                 │
│ Provider: Supabase (PostgreSQL)                                 │
│   ✓ Row Level Security (RLS) - Enabled by default               │
│   ✓ Real-time subscriptions - Available                         │
│   ✓ Edge Functions - Available                                  │
│                                                                 │
│ Multi-tenancy Strategy:                                         │
│   1. Schema-based (tenant_id column + RLS)  [Recommended]       │
│   2. Separate schemas per tenant                                │
│   3. Separate databases per tenant                              │
│   4. N/A - Single tenant application                            │
│                                                                 │
│ API Layer:                                                      │
│   1. Supabase Client (Direct DB access with RLS)                │
│   2. Next.js API Routes (Custom endpoints)                      │
│   3. Hybrid (Supabase + custom API routes)  [Recommended]       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Decision 4: Authentication

```
┌─────────────────────────────────────────────────────────────────┐
│ 🔐 Decision 4/7: Authentication                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ Your PRD mentions: "Clerk"                                      │
│                                                                 │
│ Auth Provider: Clerk                                            │
│   ✓ Pre-built UI components                                     │
│   ✓ Social logins (Google, GitHub, etc.)                        │
│   ✓ Multi-factor authentication                                 │
│   ✓ Organization/team support                                   │
│                                                                 │
│ Auth Methods to Enable:                                         │
│   [x] Email/Password                                            │
│   [x] Google OAuth                                              │
│   [ ] GitHub OAuth                                              │
│   [ ] Magic Links                                               │
│   [ ] Phone/SMS                                                 │
│                                                                 │
│ Session Strategy:                                               │
│   1. JWT (Stateless) [Recommended for SaaS]                     │
│   2. Session cookies                                            │
│                                                                 │
│ Role Hierarchy:                                                 │
│   Define roles for your app:                                    │
│   - admin: Full access                                          │
│   - member: Standard user access                                │
│   - viewer: Read-only access                                    │
│   [Add more / Edit / Accept]                                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Decision 5: External Integrations

```
┌─────────────────────────────────────────────────────────────────┐
│ 🔌 Decision 5/7: External Integrations                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ From your PRD, I identified these integrations:                 │
│                                                                 │
│ PAYMENTS: Stripe                                                │
│   Billing Model:                                                │
│     1. Subscription only (Monthly/Yearly)                       │
│     2. Usage-based (Metered billing)                            │
│     3. Hybrid (Subscription + usage add-ons) [Recommended]      │
│                                                                 │
│   Webhook Events to Handle:                                     │
│     [x] checkout.session.completed                              │
│     [x] customer.subscription.updated                           │
│     [x] customer.subscription.deleted                           │
│     [x] invoice.payment_failed                                  │
│                                                                 │
│ AI MODELS: "GPT-4 and Claude"                                   │
│   Select specific models:                                       │
│     [x] GPT-4o (OpenAI)                                         │
│     [ ] GPT-4 Turbo (OpenAI)                                    │
│     [x] Claude 3.5 Sonnet (Anthropic)                           │
│     [ ] Claude 3 Opus (Anthropic)                               │
│                                                                 │
│   Rate Limiting Strategy:                                       │
│     1. Per-user limits (X requests/minute)                      │
│     2. Token bucket (burst + sustained)                         │
│     3. Credit-based (deduct from balance)                       │
│                                                                 │
│   Fallback Strategy:                                            │
│     1. Fail with error                                          │
│     2. Queue and retry                                          │
│     3. Fallback to alternative model [Recommended]              │
│                                                                 │
│ EMAIL: (Not specified in PRD)                                   │
│   Add transactional email?                                      │
│     1. Resend (Recommended)                                     │
│     2. SendGrid                                                 │
│     3. AWS SES                                                  │
│     4. Skip for now                                             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Decision 6: Infrastructure & Deployment

```
┌─────────────────────────────────────────────────────────────────┐
│ ☁️ Decision 6/7: Infrastructure & Deployment                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ Frontend Hosting:                                               │
│   1. Vercel (Recommended for Next.js)                           │
│   2. Netlify                                                    │
│   3. Cloudflare Pages                                           │
│   4. Self-hosted                                                │
│                                                                 │
│ Backend/API Hosting:                                            │
│   1. Vercel Serverless (Same as frontend)                       │
│   2. Railway (Long-running processes)                           │
│   3. Fly.io (Edge deployment)                                   │
│   4. AWS/GCP/Azure                                              │
│                                                                 │
│ Database Hosting:                                               │
│   → Supabase (Already selected)                                 │
│   Region: [us-east-1 / eu-west-1 / ap-southeast-1]              │
│                                                                 │
│ CI/CD Pipeline:                                                 │
│   1. GitHub Actions [Recommended]                               │
│   2. Vercel Auto-deploy                                         │
│   3. GitLab CI                                                  │
│   4. Custom                                                     │
│                                                                 │
│ Environments:                                                   │
│   [x] Development (local)                                       │
│   [x] Staging (preview deployments)                             │
│   [x] Production                                                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Decision 7: Security & Observability

```
┌─────────────────────────────────────────────────────────────────┐
│ 🛡️ Decision 7/7: Security & Observability                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ SECURITY:                                                       │
│                                                                 │
│ API Security:                                                   │
│   [x] Rate limiting (per IP and per user)                       │
│   [x] Input validation (Zod schemas)                            │
│   [x] CORS configuration                                        │
│   [x] CSRF protection                                           │
│                                                                 │
│ Data Security:                                                  │
│   [x] Encryption at rest (Supabase default)                     │
│   [x] Encryption in transit (HTTPS)                             │
│   [x] PII handling policy                                       │
│   [ ] GDPR compliance features                                  │
│   [ ] SOC2 requirements                                         │
│                                                                 │
│ OBSERVABILITY:                                                  │
│                                                                 │
│ Error Tracking:                                                 │
│   1. Sentry [Recommended]                                       │
│   2. LogRocket                                                  │
│   3. Bugsnag                                                    │
│   4. Skip for MVP                                               │
│                                                                 │
│ Analytics:                                                      │
│   1. PostHog [Recommended - self-hostable]                      │
│   2. Mixpanel                                                   │
│   3. Amplitude                                                  │
│   4. Google Analytics                                           │
│                                                                 │
│ Logging:                                                        │
│   1. Structured JSON logs [Recommended]                         │
│   2. Plain text logs                                            │
│   Log aggregator: [Axiom / Datadog / None for MVP]              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Final Summary

```
┌─────────────────────────────────────────────────────────────────┐
│ ✅ Architecture Summary                                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ Application: Monolithic with clear module boundaries            │
│                                                                 │
│ Frontend:                                                       │
│   Next.js 14 (App Router) + Tailwind + shadcn/ui                │
│   SSR + Client Components                                       │
│                                                                 │
│ Backend:                                                        │
│   Supabase (PostgreSQL + RLS + Edge Functions)                  │
│   Hybrid API (Supabase client + Next.js routes)                 │
│                                                                 │
│ Auth: Clerk (Email + Google, JWT sessions)                      │
│   Roles: admin, member, viewer                                  │
│                                                                 │
│ Integrations:                                                   │
│   Payments: Stripe (Hybrid billing)                             │
│   AI: GPT-4o + Claude 3.5 Sonnet (with fallback)                │
│   Email: Resend                                                 │
│                                                                 │
│ Infrastructure:                                                 │
│   Frontend: Vercel                                              │
│   Backend: Vercel Serverless                                    │
│   Database: Supabase (us-east-1)                                │
│   CI/CD: GitHub Actions                                         │
│                                                                 │
│ Security: Rate limiting, input validation, RLS                  │
│ Observability: Sentry + PostHog                                 │
│                                                                 │
│ File to create: architecture.md (~400 lines)                    │
│                                                                 │
│ [Generate Architecture] [Start Over] [Cancel]                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## AUTO MODE

Auto Mode generates architecture.md using:
1. Tech stack from PRD extraction
2. Sensible defaults for unspecified decisions
3. Common patterns for the detected project type

**Best for**: Experienced developers who know what they want, or when regenerating after minor PRD changes.

**Defaults Applied**:
- Next.js 14 with App Router (if Next.js mentioned)
- SSR + Client Components rendering
- Tailwind CSS + shadcn/ui
- Supabase with RLS and tenant_id pattern
- JWT sessions
- Vercel deployment
- GitHub Actions CI/CD
- Sentry + PostHog for observability

---

## OUTPUT: architecture.md

The generated architecture.md follows the template in `templates/architecture.md` and includes:

1. **Executive Summary** - High-level architecture overview
2. **System Overview** - ASCII diagram of components
3. **Infrastructure Architecture** - Deployment and hosting
4. **Application Architecture** - Frontend and backend details
5. **Data Architecture** - Database schema and relationships
6. **Integration Architecture** - External services and APIs
7. **Security Architecture** - Auth, encryption, compliance
8. **Observability** - Logging, monitoring, error tracking
9. **Decision Log** - Why each choice was made

---

## EXAMPLES

### Example 1: Interactive Design Session

```bash
/architect
```

**Output**:
```
🏛️ Architect: System Design
============================

Prerequisites:
  [OK] prd.yaml found (extracted from PRD)
  [OK] vision.yaml found

How would you like to proceed?

  1. Auto Mode - Use PRD defaults
  2. Engaged Mode - Walk through decisions (recommended)

Select mode [1/2]: 2

Starting Engaged Mode (7 decision areas)...

[...walks through all 7 decisions...]

Architecture Summary:
  Stack: Next.js 14 + Supabase + Clerk + Stripe
  AI: GPT-4o + Claude 3.5 Sonnet
  Deploy: Vercel + GitHub Actions

Files Created:
  [OK] architecture.md (412 lines)

Next Steps:
  1. Review architecture.md
  2. Run /bootstrap to generate project plan
```

### Example 2: Auto Mode with Stack Profile

```bash
/architect --mode auto --stack nextjs-supabase
```

**Output**:
```
🏛️ Architect: Auto Mode
========================

Using stack profile: nextjs-supabase
Reading PRD for integrations...

Decisions Applied:
  ✓ Next.js 14 (App Router)
  ✓ Tailwind CSS + shadcn/ui
  ✓ Supabase (PostgreSQL + RLS)
  ✓ Vercel deployment

From PRD:
  ✓ Clerk authentication
  ✓ Stripe payments (subscription)
  ✓ AI: GPT-4, Claude (using GPT-4o + Claude 3.5 Sonnet)

Files Created:
  [OK] architecture.md (389 lines)

⚠️ Review architecture.md - auto mode used defaults.
   Run /architect --mode engaged to customize.
```

---

## ERROR HANDLING

### Missing PRD

```
Error: PRD extraction not found

/architect requires PRD data to make architecture decisions.

Run first:
  /foundations init

Or provide PRD directly:
  /architect ideation/PRD.md
```

### Conflicting Decisions

```
Warning: Conflicting tech stack detected

Your PRD mentions both "Supabase" and "Firebase" for database.

Options:
  1. Use Supabase (PostgreSQL, better for complex queries)
  2. Use Firebase (NoSQL, real-time focused)
  3. Let me explain trade-offs

Select [1/2/3]:
```

### Existing Architecture

```
Warning: architecture.md already exists

Options:
  1. Overwrite - Replace with new architecture
  2. Backup - Save as architecture.md.backup first
  3. Compare - Show diff with proposed changes
  4. Cancel

Select [1/2/3/4]:
```

---

## INTEGRATION WITH WORKFLOW

### Required By

- `/bootstrap` - Will check for architecture.md before generating plan
- `/coord build` - References architecture for implementation decisions

### Depends On

- `/foundations init` - PRD extraction provides tech stack hints

### Workflow Commands

```bash
# Full recommended workflow
/foundations init              # 1. Extract requirements
/architect --mode engaged      # 2. Design architecture
/bootstrap --mode engaged      # 3. Create project plan
/coord continue                # 4. Build it

# Quick workflow (experienced users)
/foundations init
/architect --mode auto
/bootstrap --mode auto
/coord continue
```

---

## NOTES

- Architecture decisions should be made BEFORE planning tasks
- Engaged Mode takes 10-15 minutes but prevents costly rework
- Auto Mode uses sensible defaults but may miss project-specific needs
- architecture.md becomes the source of truth for implementation
- Update architecture.md when making significant technical changes

---

*Good architecture is invisible when it works and obvious when it doesn't. Take time to get it right.*
