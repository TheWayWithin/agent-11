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
   - `.context/structured/prd.yaml` exists (REQUIRED)
   - `.context/structured/vision.yaml` exists (recommended)
   - `.context/structured/roadmap.yaml` exists (optional - provides strategic context)

2. **PRD contains tech stack hints**
   - Frontend framework mentioned
   - Database preference indicated
   - Key integrations identified

**Context Sources Used:**
- `prd.yaml` → Features, tech stack preferences, integrations
- `vision.yaml` → Hedgehog concept, value proposition (informs architectural priorities)
- `roadmap.yaml` → Keystone products, implementation framework (informs build sequence)

## EXECUTION PROTOCOL

**CRITICAL**: This command MUST prompt for mode selection before doing any work (unless `--mode` flag is provided).

### Step 1: Check for --mode Flag

If `--mode auto` → Skip to AUTO MODE section
If `--mode engaged` → Skip to ENGAGED MODE section
If no --mode flag → Continue to Step 2

### Step 2: Present Mode Selection (MANDATORY)

**Use AskUserQuestion tool** to present this choice:

```
question: "How would you like to design your architecture?"
header: "Mode"
options:
  - label: "Engaged Mode (Recommended)"
    description: "Walk through each decision together - I'll explain trade-offs and you make informed choices"
  - label: "Auto Mode"
    description: "Generate architecture automatically from PRD tech stack hints using sensible defaults"
```

**WAIT for user response before proceeding.**

### Step 3: Execute Selected Mode

- If user selects "Engaged Mode" → Execute ENGAGED MODE section
- If user selects "Auto Mode" → Execute AUTO MODE section

---

## MODE SELECTION REFERENCE

When you run `/architect` without flags, this is what the user sees:

```
┌─────────────────────────────────────────────────────────────────┐
│ 🏛️ Architect: System Design                                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ How would you like to design your architecture?                 │
│                                                                 │
│ ○ Engaged Mode (Recommended)                                    │
│   Walk through each decision together                           │
│   I'll explain trade-offs and you make informed choices         │
│   Produces architecture tailored to your specific needs         │
│                                                                 │
│ ○ Auto Mode                                                     │
│   Generate architecture from PRD tech stack hints               │
│   Uses sensible defaults for unspecified decisions              │
│   Fast, but you may want to review decisions afterward          │
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

Engaged Mode walks through **8 architectural decision areas** plus validation. **For each decision:**

1. **Read relevant context** from `.context/structured/prd.yaml` and `.context/structured/vision.yaml`
2. **Present the decision** using AskUserQuestion with:
   - Context from PRD (what was specified)
   - Your recommendation with reasoning
   - 2-4 options with trade-offs explained
3. **Wait for user response** before proceeding to next decision
4. **Record the decision** for final architecture.md generation

**IMPORTANT**: Do NOT batch decisions. Present ONE decision at a time, get user input, then proceed.

---

### STEP 0: PRD CONTEXT EXTRACTION (MANDATORY)

Before presenting any decisions, extract and display key context from the PRD:

```
┌─────────────────────────────────────────────────────────────────┐
│ 📋 PRD Context Extraction                                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ Extracting key data from .context/structured/prd.yaml...       │
│                                                                 │
│ PRICING TIERS FOUND:                                            │
│   → free, solo, growth, pro  (4 tiers)                          │
│                                                                 │
│ DATA MODEL ENTITIES:                                            │
│   → 22 entities across 6 domains                                │
│   → Portfolio: User, Product, Function, UseCase                 │
│   → Model: ModelMaker, Model, Provider, Pricing, Capability     │
│   → Trust: TrustDimension, ModelTrustScore, ProviderTrustScore  │
│   → Action: Opportunity, SanityCheck, Savings, Alert            │
│   → Account: Subscription, NotificationPrefs, UsageTracking     │
│   → Admin: AuditLog, PromotionCode                              │
│                                                                 │
│ STATE MACHINES FOUND:                                           │
│   → Subscription: 6 states, 10 transitions                      │
│   → Opportunity: 5 states, 6 transitions                        │
│   → Product/Function: 3 states, 4 transitions                   │
│                                                                 │
│ BUSINESS RULES: 30 rules defined                                │
│ FEATURES: 24 P0, 12 P1                                          │
│                                                                 │
│ ⚠️  Architecture MUST use exact PRD terminology                 │
│ ⚠️  Schema MUST include tables for ALL 22 entities              │
│ ⚠️  State machines MUST have complete state coverage            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Store this extracted data** - it will be used for:
- Displaying context in each decision
- Validation pass after decisions complete
- Schema completeness checking

---

### Decision Flow Example

For each decision, use AskUserQuestion like this:
```
question: "Decision 1/8: Application Architecture - Your PRD indicates [features]. Which architecture pattern?"
header: "Architecture"
options:
  - label: "Monolith (Recommended)"
    description: "Fast to build, easy to deploy. Best for MVP - can refactor later"
  - label: "Modular Monolith"
    description: "Clear module boundaries. Easier to split into services later"
  - label: "Microservices"
    description: "⚠️ Adds operational complexity. Usually overkill for MVP"
```

---

### The 8 Decisions

### Decision 1: Application Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│ 🏗️ Decision 1/8: Application Architecture                      │
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
│ 🎨 Decision 2/8: Frontend Stack                                 │
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
│ 🗄️ Decision 3/8: Backend & Database                            │
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
│ 🔐 Decision 4/8: Authentication                                 │
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
│ 🔌 Decision 5/8: External Integrations                          │
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
│ ☁️ Decision 6/8: Infrastructure & Deployment                    │
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
│ 🛡️ Decision 7/8: Security & Observability                      │
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

### Decision 8: Production Readiness Patterns

**Why This Decision Matters**: Generic patterns often fail in production due to race conditions, scaling issues, or restart scenarios. This decision forces explicit consideration of production failure modes.

```
┌─────────────────────────────────────────────────────────────────┐
│ 🏭 Decision 8/8: Production Readiness Patterns                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ These patterns prevent production failures. Choose carefully.   │
│                                                                 │
│ JOB/TASK LOCKING (prevents duplicate execution):                │
│                                                                 │
│   1. ⚠️ Unique Index Lock                                       │
│      Partial unique index on running jobs                       │
│      Simple but has race window on check-then-insert            │
│                                                                 │
│   2. Advisory Locks (Recommended for PostgreSQL)                │
│      pg_advisory_lock - Survives crashes, no race condition     │
│      Best for: Single-region, PostgreSQL-based systems          │
│                                                                 │
│   3. Redis Redlock                                              │
│      Distributed lock via Redis - Works multi-region            │
│      Best for: Multi-region, high availability requirements     │
│                                                                 │
│   4. FOR UPDATE SKIP LOCKED                                     │
│      Queue-style processing with row-level locks                │
│      Best for: Work queues with many concurrent workers         │
│                                                                 │
│ RATE LIMITING (prevents abuse, enforces tier limits):           │
│                                                                 │
│   1. ⚠️ In-Memory                                               │
│      Lost on restart, doesn't work with multiple instances      │
│      Only use for: Single instance, dev/testing                 │
│                                                                 │
│   2. Upstash Redis (Recommended)                                │
│      Survives restarts, works distributed, free tier available  │
│      Best for: Most production SaaS applications                │
│                                                                 │
│   3. Database-Backed Counters                                   │
│      No external dependency, but adds DB load                   │
│      Best for: Low-traffic apps, simplicity priority            │
│                                                                 │
│   4. Edge-Level (Cloudflare/Vercel)                             │
│      Stops abuse before hitting your servers                    │
│      Best for: DDoS protection, global rate limiting            │
│                                                                 │
│ WEBHOOK IDEMPOTENCY (prevents duplicate processing):            │
│                                                                 │
│   1. Event ID Deduplication Table (Recommended)                 │
│      Store processed event IDs, check before processing         │
│      Required for: Stripe, payment webhooks                     │
│                                                                 │
│   2. Content-Hash Deduplication                                 │
│      Hash payload, dedupe on hash                               │
│      Best for: Webhooks without unique IDs                      │
│                                                                 │
│ GRACEFUL DEGRADATION (when dependencies fail):                  │
│                                                                 │
│   For each external service, define fallback:                   │
│   • LLM Provider → [Queue & Retry / Fallback Model / Error]     │
│   • Payment Provider → [Retry Queue / Graceful Error]           │
│   • Email Provider → [Queue for Later / Skip Non-Critical]      │
│   • Database → [Circuit Breaker / Read Replica / Cache]         │
│                                                                 │
│ CDN STRATEGY (frontend delivery):                               │
│                                                                 │
│   1. Static Assets Only (JS/CSS/Images)                         │
│      Minimal config, works with any hosting                     │
│                                                                 │
│   2. Edge Caching with ISR/Revalidation                         │
│      Cache pages at edge, revalidate on interval                │
│      Best for: Marketing pages, semi-static content             │
│                                                                 │
│   3. Full CDN with Purge on Deploy                              │
│      Maximum performance, requires cache invalidation           │
│      Best for: High-traffic, globally distributed users         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Use AskUserQuestion** for each production concern:

```
question: "Job Locking - How should we prevent duplicate job execution across instances?"
header: "Job Lock"
options:
  - label: "Advisory Locks (Recommended)"
    description: "pg_advisory_lock - Works with PostgreSQL, survives crashes, no external deps"
  - label: "Redis Redlock"
    description: "Distributed lock via Redis - Best for multi-region, requires Redis"
  - label: "FOR UPDATE SKIP LOCKED"
    description: "Queue-style with row locks - Best for work queues with many workers"
  - label: "Unique Index Lock"
    description: "⚠️ Simple but has race window - only for low-traffic, single instance"
```

**Production Pattern Code Templates** (include in architecture.md):

```typescript
// ADVISORY LOCK PATTERN (Production-safe for PostgreSQL)
async function runJobWithAdvisoryLock(jobName: string, fn: () => Promise<void>) {
  const lockId = hashStringToInt(jobName); // Stable integer from job name

  // Try to acquire advisory lock (non-blocking)
  const lockResult = await db.query(
    `SELECT pg_try_advisory_lock($1) as acquired`,
    [lockId]
  );

  if (!lockResult.rows[0].acquired) {
    console.log(`Job ${jobName} already running on another instance`);
    return;
  }

  try {
    // Record job start for monitoring
    const jobRun = await db.query(
      `INSERT INTO job_runs (job_name, status, started_at)
       VALUES ($1, 'running', NOW())
       RETURNING id`,
      [jobName]
    );

    await fn();

    await db.query(
      `UPDATE job_runs SET status = 'completed', finished_at = NOW()
       WHERE id = $1`,
      [jobRun.rows[0].id]
    );
  } catch (error) {
    await db.query(
      `UPDATE job_runs SET status = 'failed', error = $2, finished_at = NOW()
       WHERE id = $1`,
      [jobRun.rows[0].id, error.message]
    );
    throw error;
  } finally {
    // Always release advisory lock
    await db.query(`SELECT pg_advisory_unlock($1)`, [lockId]);
  }
}

// UPSTASH RATE LIMITING (Production-safe for distributed)
import { Ratelimit } from '@upstash/ratelimit';
import { Redis } from '@upstash/redis';

const redis = new Redis({
  url: process.env.UPSTASH_REDIS_REST_URL,
  token: process.env.UPSTASH_REDIS_REST_TOKEN,
});

// Tier-based rate limits
const tierLimits = {
  free: Ratelimit.slidingWindow(10, '1 h'),
  solo: Ratelimit.slidingWindow(100, '1 h'),
  growth: Ratelimit.slidingWindow(500, '1 h'),
  pro: Ratelimit.slidingWindow(2000, '1 h'),
};

async function checkRateLimit(userId: string, tier: string): Promise<boolean> {
  const limiter = new Ratelimit({
    redis,
    limiter: tierLimits[tier] || tierLimits.free,
    prefix: `ratelimit:${tier}`,
  });

  const { success } = await limiter.limit(userId);
  return success;
}

// WEBHOOK IDEMPOTENCY (Prevents duplicate processing)
async function processWebhook(eventId: string, handler: () => Promise<void>) {
  // Check if already processed
  const existing = await db.query(
    `SELECT id FROM webhook_events WHERE id = $1`,
    [eventId]
  );

  if (existing.rows.length > 0) {
    return { status: 'already_processed' };
  }

  // Mark as processing BEFORE handling (prevents race)
  await db.query(
    `INSERT INTO webhook_events (id, status, created_at)
     VALUES ($1, 'processing', NOW())`,
    [eventId]
  );

  try {
    await handler();
    await db.query(
      `UPDATE webhook_events SET status = 'completed', processed_at = NOW()
       WHERE id = $1`,
      [eventId]
    );
  } catch (error) {
    await db.query(
      `UPDATE webhook_events SET status = 'failed', error = $2 WHERE id = $1`,
      [eventId, error.message]
    );
    throw error;
  }
}
```

---

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
│ Production Patterns:                                            │
│   Job Locking: Advisory locks (pg_advisory_lock)                │
│   Rate Limiting: Upstash Redis (distributed)                    │
│   Idempotency: Event ID deduplication table                     │
│   CDN: Cloudflare (static assets + edge caching)                │
│                                                                 │
│ PRD Validation: ✅ All 22 entities mapped                        │
│ State Machines: ✅ 3 complete (Subscription, Opportunity, etc.)  │
│ Schema Check: ✅ 100% entity coverage                            │
│                                                                 │
│ File to create: architecture.md (~500 lines)                    │
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
- **Production patterns**: Advisory locks, Upstash rate limiting, webhook idempotency

**Auto Mode ALSO runs**:
- PRD Cross-Reference Validation Pass
- Schema Completeness Check
- State Machine Extraction

---

## PRD CROSS-REFERENCE VALIDATION (MANDATORY - Both Modes)

**This validation runs AFTER all decisions are made, BEFORE generating architecture.md.**

### Purpose

Prevents architecture-PRD mismatches by validating:
- Terminology consistency (tier names, state names)
- Entity coverage (all PRD entities have tables)
- State machine completeness (all states represented)

### Validation Steps

#### Step V1: Extract PRD Reference Data

Parse from `.context/structured/prd.yaml`:

```yaml
# Extract from PRD
TIER_NAMES: [free, solo, growth, pro]  # from pricing.tiers keys
ENTITIES: [User, Product, Function, ...]  # from data_model.entities
STATE_MACHINES:
  - name: Subscription
    states: [trial, trial_cancelled, active, past_due, cancelled, free]
    transitions: [...]
```

#### Step V2: Validate Terminology

Check that architecture uses **EXACT** PRD terminology:

```
┌─────────────────────────────────────────────────────────────────┐
│ 🔍 Terminology Validation                                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ TIER NAMES:                                                     │
│   PRD defines: free, solo, growth, pro                          │
│   Schema uses: free, solo, growth, pro                          │
│   Status: ✅ MATCH                                               │
│                                                                 │
│ SUBSCRIPTION STATES:                                            │
│   PRD defines: trial, trial_cancelled, active, past_due,        │
│                cancelled, free  (6 states)                      │
│   Schema uses: trial, active, past_due, cancelled, free         │
│   Status: ❌ MISSING: trial_cancelled                            │
│                                                                 │
│ OPPORTUNITY STATES:                                             │
│   PRD defines: active, dismissed, accepted, expired, superseded │
│   Schema uses: active, dismissed, accepted, expired             │
│   Status: ❌ MISSING: superseded                                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**If mismatches found**: STOP and fix before generating architecture.md.

#### Step V3: Generate Validation Report

```
┌─────────────────────────────────────────────────────────────────┐
│ PRD CROSS-REFERENCE VALIDATION                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ Entities: 22 defined / 22 mapped ✅                             │
│ State Machines: 3 defined / 3 complete ✅                       │
│ Tier Names: Match PRD exactly ✅                                │
│ State Names: Match PRD exactly ✅                               │
│ Business Rules: 30 rules, 28 covered ⚠️                         │
│                                                                 │
│ [PASSED] Architecture validated against PRD                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**OR if issues found:**

```
┌─────────────────────────────────────────────────────────────────┐
│ ⚠️ PRD VALIDATION FAILED - REVIEW REQUIRED                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ Missing Tables (5):                                             │
│   • ModelMaker → Need model_makers table                        │
│   • Capability → Need capabilities table                        │
│   • Session → Need sessions table                               │
│   • Savings → Need savings table                                │
│   • AuditLog → Need audit_logs table                            │
│                                                                 │
│ Terminology Mismatches (2):                                     │
│   • PRD: 'trial_cancelled' → Schema: missing                    │
│   • PRD: 'superseded' → Schema: missing                         │
│                                                                 │
│ Options:                                                        │
│   1. Fix automatically (add missing tables and states)          │
│   2. Review and fix manually                                    │
│   3. Acknowledge and document gaps in Decision Log              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## STATE MACHINE EXTRACTION (MANDATORY)

**For each state machine in PRD, generate complete state coverage.**

### Purpose

Ensures all PRD-defined states are represented in schema with proper ENUMs and transition logic.

### Extraction Process

#### Step SM1: Parse State Machines from PRD

```yaml
# From prd.yaml state_machines section
subscription_state_machine:
  entity: Subscription
  states:
    - name: trial
      description: "7-day trial period"
    - name: trial_cancelled
      description: "User cancelled during trial"
    - name: active
      description: "Paid subscription active"
    - name: past_due
      description: "Payment failed, grace period"
    - name: cancelled
      description: "User cancelled, active until period end"
    - name: free
      description: "Free tier"
  transitions:
    - from: trial, to: active, trigger: "Day 8 payment succeeds"
    - from: trial, to: trial_cancelled, trigger: "User cancels during trial"
    - from: trial, to: free, trigger: "Day 8 payment fails after retry"
    # ... etc
```

#### Step SM2: Generate State Transition Table

```
┌─────────────────────────────────────────────────────────────────┐
│ 📊 State Machine: Subscription                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ States (6):                                                     │
│ ┌────────────────┬───────────────────────────────────────────┐  │
│ │ State          │ Description                               │  │
│ ├────────────────┼───────────────────────────────────────────┤  │
│ │ trial          │ 7-day trial period                        │  │
│ │ trial_cancelled│ User cancelled during trial               │  │
│ │ active         │ Paid subscription active                  │  │
│ │ past_due       │ Payment failed, grace period              │  │
│ │ cancelled      │ User cancelled, active until period end   │  │
│ │ free           │ Free tier with limited features           │  │
│ └────────────────┴───────────────────────────────────────────┘  │
│                                                                 │
│ Transitions (10):                                               │
│ ┌────────────────┬────────────────┬──────────────────────────┐  │
│ │ From           │ To             │ Trigger                  │  │
│ ├────────────────┼────────────────┼──────────────────────────┤  │
│ │ trial          │ active         │ Day 8 payment succeeds   │  │
│ │ trial          │ trial_cancelled│ User cancels in trial    │  │
│ │ trial          │ free           │ Day 8 payment fails      │  │
│ │ trial_cancelled│ free           │ Trial period ends        │  │
│ │ active         │ past_due       │ Renewal payment fails    │  │
│ │ active         │ cancelled      │ User cancels             │  │
│ │ past_due       │ active         │ Payment succeeds         │  │
│ │ past_due       │ free           │ All retries exhausted    │  │
│ │ cancelled      │ free           │ Period ends              │  │
│ │ free           │ trial          │ User starts trial        │  │
│ └────────────────┴────────────────┴──────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

#### Step SM3: Generate PostgreSQL ENUM

```sql
-- Subscription status ENUM (6 states from PRD)
CREATE TYPE subscription_status AS ENUM (
  'trial',
  'trial_cancelled',
  'active',
  'past_due',
  'cancelled',
  'free'
);

-- Use in table
ALTER TABLE user_profiles
  ALTER COLUMN subscription_status TYPE subscription_status
  USING subscription_status::subscription_status;
```

#### Step SM4: Generate Transition Validation Code

```typescript
// Valid transitions map (from PRD state machine)
const VALID_TRANSITIONS: Record<SubscriptionStatus, SubscriptionStatus[]> = {
  'trial': ['active', 'trial_cancelled', 'free'],
  'trial_cancelled': ['free'],
  'active': ['past_due', 'cancelled'],
  'past_due': ['active', 'free'],
  'cancelled': ['free'],
  'free': ['trial'],
};

function canTransition(from: SubscriptionStatus, to: SubscriptionStatus): boolean {
  return VALID_TRANSITIONS[from]?.includes(to) ?? false;
}

async function transitionSubscription(
  userId: string,
  newStatus: SubscriptionStatus,
  trigger: string
): Promise<void> {
  const current = await getSubscriptionStatus(userId);

  if (!canTransition(current, newStatus)) {
    throw new InvalidTransitionError(`Cannot transition from ${current} to ${newStatus}`);
  }

  await db.transaction(async (tx) => {
    // Update status
    await tx.query(
      `UPDATE user_profiles SET
         subscription_status = $1,
         subscription_status_changed_at = NOW()
       WHERE id = $2`,
      [newStatus, userId]
    );

    // Log transition for audit
    await tx.query(
      `INSERT INTO subscription_transitions
       (user_id, from_status, to_status, trigger, created_at)
       VALUES ($1, $2, $3, $4, NOW())`,
      [userId, current, newStatus, trigger]
    );
  });
}
```

#### Step SM5: Generate State Diagram (for architecture.md)

```
Subscription State Machine
━━━━━━━━━━━━━━━━━━━━━━━━━━

                      ┌─────────────┐
                      │   trial     │
                      └──────┬──────┘
                             │
            ┌────────────────┼────────────────┐
            ▼                ▼                ▼
     ┌──────────────┐ ┌────────────┐   ┌──────────┐
     │trial_cancelled│ │   active   │   │   free   │
     └───────┬──────┘ └─────┬──────┘   └────┬─────┘
             │              │               │
             │         ┌────┴────┐          │
             ▼         ▼         ▼          │
                  ┌─────────┐ ┌──────────┐  │
                  │past_due │ │cancelled │  │
                  └────┬────┘ └────┬─────┘  │
                       │           │        │
                       └─────┬─────┘        │
                             ▼              │
                        ┌────────┐          │
                        │  free  │◄─────────┘
                        └────────┘
```

---

## SCHEMA COMPLETENESS CHECKLIST (MANDATORY)

**Auto-generated from PRD data_model.entities to ensure no tables are missing.**

### Purpose

Catches missing database tables before implementation begins.

### Checklist Format

```
┌─────────────────────────────────────────────────────────────────┐
│ 📋 Schema Completeness Check                                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ Domain: portfolio                                               │
│ ├── [x] User → user_profiles                                    │
│ ├── [x] Product → products                                      │
│ ├── [x] Function → functions                                    │
│ └── [x] UseCase → use_cases                                     │
│                                                                 │
│ Domain: model                                                   │
│ ├── [ ] ModelMaker → ❌ MISSING                                  │
│ ├── [x] Model → models                                          │
│ ├── [x] Provider → providers                                    │
│ ├── [x] ModelProviderPricing → model_provider_pricing           │
│ ├── [ ] Capability → ❌ MISSING                                  │
│ └── [ ] ModelCapability → ❌ MISSING                             │
│                                                                 │
│ Domain: trust                                                   │
│ ├── [ ] TrustDimension → ❌ MISSING                              │
│ ├── [x] ModelTrustScore → model_trust_scores                    │
│ └── [ ] ProviderTrustScore → ❌ MISSING                          │
│                                                                 │
│ Domain: action                                                  │
│ ├── [x] Opportunity → opportunities                             │
│ ├── [x] SanityCheck → sanity_checks                             │
│ ├── [ ] Savings → ❌ MISSING                                     │
│ └── [x] Alert → alerts                                          │
│                                                                 │
│ Domain: account                                                 │
│ ├── [x] Subscription → user_profiles (embedded)                 │
│ ├── [x] NotificationPreferences → notification_preferences      │
│ ├── [x] UsageTracking → usage_tracking                          │
│ └── [ ] Session → ❌ MISSING                                     │
│                                                                 │
│ Domain: admin                                                   │
│ ├── [ ] AuditLog → ❌ MISSING                                    │
│ └── [ ] PromotionCode → ❌ MISSING                               │
│                                                                 │
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│ Summary: 22 entities → 13 mapped, 9 missing                     │
│ Status: ❌ INCOMPLETE - Action required before proceeding        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Handling Missing Tables

**Use AskUserQuestion** when tables are missing:

```
question: "9 PRD entities are missing database tables. How should we proceed?"
header: "Schema"
options:
  - label: "Generate Missing Tables (Recommended)"
    description: "Auto-create table definitions from PRD entity attributes"
  - label: "Review Individually"
    description: "Show each missing entity and decide one by one"
  - label: "Mark as Intentional Omissions"
    description: "Document why these entities are excluded (e.g., embedded in other tables)"
```

### Auto-Generated Table Stubs

If user selects "Generate Missing Tables":

```sql
-- Auto-generated from PRD entity: ModelMaker
CREATE TABLE model_makers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  website TEXT,
  description TEXT,
  hq_country TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Auto-generated from PRD entity: Savings
CREATE TABLE savings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
  function_id UUID REFERENCES functions(id) ON DELETE CASCADE,
  opportunity_id UUID REFERENCES opportunities(id),
  previous_model_id UUID REFERENCES models(id),
  new_model_id UUID REFERENCES models(id),
  monthly_savings_amount DECIMAL(10,2),
  annual_savings_projection DECIMAL(10,2),
  switched_at TIMESTAMPTZ DEFAULT NOW()
);

-- Auto-generated from PRD entity: Session
CREATE TABLE sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
  started_at TIMESTAMPTZ DEFAULT NOW(),
  ended_at TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT TRUE
);

-- Auto-generated from PRD entity: AuditLog
CREATE TABLE audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES user_profiles(id),
  action TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_id UUID,
  old_values JSONB,
  new_values JSONB,
  ip_address TEXT,
  user_agent TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Auto-generated from PRD entity: PromotionCode
CREATE TABLE promotion_codes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT UNIQUE NOT NULL,
  discount_type TEXT NOT NULL,  -- 'percentage' or 'fixed'
  discount_value DECIMAL(10,2) NOT NULL,
  valid_from TIMESTAMPTZ,
  valid_until TIMESTAMPTZ,
  max_uses INTEGER,
  current_uses INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

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

Starting Engaged Mode (8 decision areas + validation)...

[...walks through all 8 decisions...]
[...runs PRD validation, state machine extraction, schema check...]

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
- Engaged Mode takes 15-20 minutes but prevents costly rework
- Auto Mode uses sensible defaults but STILL runs validation passes
- architecture.md becomes the source of truth for implementation
- Update architecture.md when making significant technical changes

### Key Improvements (v2.0)

1. **PRD Cross-Reference Validation** - Ensures architecture uses exact PRD terminology (tier names, states, entity names)
2. **Production Readiness Decision** - Forces explicit choices for job locking, rate limiting, idempotency, CDN
3. **State Machine Extraction** - Generates complete state ENUMs and transition validation code
4. **Schema Completeness Checklist** - Auto-verifies all PRD entities have database tables
5. **Enhanced PRD Context** - Shows extracted PRD data at each decision point

### Validation Gate

**Architecture generation will STOP if validation fails:**
- Missing entities must be addressed
- Terminology mismatches must be fixed
- Incomplete state machines must be completed

---

*Good architecture is invisible when it works and obvious when it doesn't. PRD validation ensures you don't miss anything.*
