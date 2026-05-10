---
name: saas-billing
description: Implement SaaS billing logic — pricing plans, usage metering, quota enforcement, free trials, plan upgrades and downgrades, prorations, and dunning. Use when building billing, plan, quota, trial, upgrade, downgrade, or subscription-management features (works alongside saas-payments for the Stripe integration layer).
version: 1.0.0
category: payments
triggers:
  - billing
  - subscription
  - plan
  - pricing
  - upgrade
  - downgrade
  - trial
  - quota
  - usage limit
  - plan limit
  - subscription management
  - billing portal
specialist: "@developer"
stack_aware: true
complexity: intermediate
estimated_tokens: 3900
dependencies:
  - saas-payments
  - saas-multitenancy
---

# SaaS Billing & Subscription Management

## Where this skill ends

This skill owns **product-side billing logic**: plan definitions, feature gating, quota tracking, trial state machine, downgrade orchestration, dunning. The patterns describe what our product does given subscription state.

This skill does NOT own:

- Stripe API calls (creating customers, mutating subscriptions, verifying webhooks). Use `saas-payments`.
- Webhook signature verification or event delivery. Use `saas-payments`.

When implementing a flow that crosses both skills: orchestration logic lives here and calls into `saas-payments` primitives. Webhook handlers live in `saas-payments` and call into update functions defined here.

## Capability

Implement subscription lifecycle management, plan enforcement, usage tracking, and billing operations. Covers trial periods, plan changes, quota enforcement, and subscription status synchronization with payment providers.

## Use Cases

- Trial period management with conversion tracking
- Plan upgrades and downgrades with proration
- Usage quota tracking and enforcement
- Subscription status webhooks handling
- Billing history and invoice access
- Failed payment recovery (dunning)

## Patterns

### Plan Definition & Enforcement

**When to use**: Enforce feature access and limits based on subscription tier

**Implementation**: Define plans with features and limits, check against current subscription.

```typescript
// Plan definitions
const PLANS = {
  free: {
    id: 'free',
    name: 'Free',
    price: 0,
    limits: {
      projects: 3,
      teamMembers: 1,
      storageGb: 1,
      apiRequestsPerMonth: 1000
    },
    features: ['basic_analytics']
  },
  pro: {
    id: 'pro',
    name: 'Pro',
    stripePriceId: 'price_pro_monthly',
    price: 29,
    limits: {
      projects: 25,
      teamMembers: 10,
      storageGb: 50,
      apiRequestsPerMonth: 50000
    },
    features: ['basic_analytics', 'advanced_analytics', 'api_access', 'priority_support']
  },
  enterprise: {
    id: 'enterprise',
    name: 'Enterprise',
    stripePriceId: 'price_enterprise_monthly',
    price: 99,
    limits: {
      projects: -1, // unlimited
      teamMembers: -1,
      storageGb: 500,
      apiRequestsPerMonth: -1
    },
    features: ['basic_analytics', 'advanced_analytics', 'api_access', 'priority_support', 'sso', 'audit_logs', 'custom_integrations']
  }
} as const;

// Check feature access
function hasFeature(orgPlan: string, feature: string): boolean {
  const plan = PLANS[orgPlan];
  return plan?.features.includes(feature) ?? false;
}

// Check limit
function checkLimit(orgPlan: string, resource: string, current: number): boolean {
  const plan = PLANS[orgPlan];
  const limit = plan?.limits[resource];
  if (limit === -1) return true; // unlimited
  return current < limit;
}

// Middleware for feature gating
async function requireFeature(feature: string) {
  return async (req: Request, next: NextFunction) => {
    const org = req.tenant;
    if (!hasFeature(org.plan, feature)) {
      throw new PaymentRequiredError(
        `Upgrade to access ${feature}`,
        { requiredPlan: getMinimumPlanForFeature(feature) }
      );
    }
    return next();
  };
}
```

### Trial Period Management

**When to use**: Offer time-limited full access before requiring payment

**Implementation**: Track trial start/end, send reminders, handle expiration.

```typescript
// Start trial on org creation
async function startTrial(organizationId: string, trialDays = 14) {
  const trialEnd = new Date();
  trialEnd.setDate(trialEnd.getDate() + trialDays);

  await db.update(organizations)
    .set({
      plan: 'pro', // Full access during trial
      trialEndsAt: trialEnd,
      trialStartedAt: new Date()
    })
    .where(eq(organizations.id, organizationId));

  // Schedule trial reminder emails
  await scheduleTrialReminders(organizationId, trialEnd);
}

// Check trial status
async function getSubscriptionStatus(org: Organization) {
  if (org.stripeSubscriptionId) {
    return { status: 'active', plan: org.plan };
  }

  if (org.trialEndsAt) {
    const now = new Date();
    if (now < org.trialEndsAt) {
      const daysLeft = Math.ceil(
        (org.trialEndsAt.getTime() - now.getTime()) / (1000 * 60 * 60 * 24)
      );
      return { status: 'trialing', plan: org.plan, daysLeft };
    }
    return { status: 'trial_expired', plan: 'free' };
  }

  return { status: 'free', plan: 'free' };
}

// Handle trial expiration
async function handleTrialExpired(organizationId: string) {
  await db.update(organizations)
    .set({ plan: 'free' })
    .where(eq(organizations.id, organizationId));

  // Notify org admins
  await notifyTrialExpired(organizationId);
}
```

### Usage Tracking & Quotas

**When to use**: Track and limit resource consumption per plan

**Implementation**: Increment usage counters, check against limits before operations.

```typescript
// Usage tracking table
const usage = pgTable('usage', {
  id: uuid('id').primaryKey().defaultRandom(),
  organizationId: uuid('organization_id').references(() => organizations.id),
  resource: text('resource').notNull(), // 'api_requests', 'storage_bytes', etc.
  count: integer('count').default(0),
  periodStart: timestamp('period_start').notNull(),
  periodEnd: timestamp('period_end').notNull()
});

// Increment usage
async function trackUsage(orgId: string, resource: string, amount = 1) {
  const period = getCurrentBillingPeriod(orgId);

  await db.insert(usage)
    .values({
      organizationId: orgId,
      resource,
      count: amount,
      periodStart: period.start,
      periodEnd: period.end
    })
    .onConflictDoUpdate({
      target: [usage.organizationId, usage.resource, usage.periodStart],
      set: { count: sql`${usage.count} + ${amount}` }
    });
}

// Check quota before operation
async function checkQuota(orgId: string, resource: string): Promise<boolean> {
  const org = await db.query.organizations.findFirst({
    where: eq(organizations.id, orgId)
  });

  const plan = PLANS[org.plan];
  const limit = plan.limits[resource];
  if (limit === -1) return true;

  const currentUsage = await getCurrentUsage(orgId, resource);
  return currentUsage < limit;
}

// Middleware for quota enforcement
async function enforceQuota(resource: string) {
  return async (req: Request, next: NextFunction) => {
    const canProceed = await checkQuota(req.tenantId, resource);
    if (!canProceed) {
      throw new QuotaExceededError(
        `${resource} quota exceeded for your plan`,
        { currentPlan: req.tenant.plan, upgradeUrl: '/settings/billing' }
      );
    }
    await trackUsage(req.tenantId, resource);
    return next();
  };
}
```

### Plan Changes (Upgrade/Downgrade)

**When to use**: Allow users to switch between subscription tiers

**Implementation**: Handle proration, immediate vs end-of-period changes.

```typescript
// Orchestration entry point. Stripe API calls live in saas-payments;
// this function decides what should happen, then calls into the
// payments primitive to make it happen at Stripe.
async function changePlan(
  organizationId: string,
  newPlanId: string,
  options: { immediate?: boolean } = {}
) {
  const org = await db.query.organizations.findFirst({
    where: eq(organizations.id, organizationId)
  });

  const newPlan = PLANS[newPlanId];
  if (!newPlan.stripePriceId) {
    throw new Error('Cannot subscribe to free plan via Stripe');
  }

  const isUpgrade = newPlan.price > PLANS[org.plan].price;

  // Delegate the Stripe mutation to saas-payments.
  // updateStripeSubscriptionPrice() is the Stripe API primitive defined there.
  await updateStripeSubscriptionPrice({
    subscriptionId: org.stripeSubscriptionId,
    newPriceId: newPlan.stripePriceId,
    prorationBehavior: isUpgrade ? 'always_invoice' : 'create_prorations',
    billingCycleAnchor: options.immediate ? 'now' : 'unchanged',
  });

  // Product-side state. The webhook from Stripe will also fire and
  // confirm; this is an optimistic update for snappier UX.
  await db.update(organizations)
    .set({ plan: newPlanId })
    .where(eq(organizations.id, organizationId));

  // Downgrade enforcement is product logic, lives here.
  if (!isUpgrade) {
    await enforceDowngradeLimits(organizationId, newPlanId);
  }

  return { success: true, newPlan: newPlanId };
}

// Handle limit violations on downgrade
async function enforceDowngradeLimits(orgId: string, newPlanId: string) {
  const limits = PLANS[newPlanId].limits;

  // Check project limit
  const projectCount = await db.query.projects.count({
    where: eq(projects.organizationId, orgId)
  });

  if (limits.projects !== -1 && projectCount > limits.projects) {
    // Mark excess projects as archived (don't delete)
    // Notify user they need to archive projects
    await notifyLimitExceeded(orgId, 'projects', projectCount, limits.projects);
  }

  // Similar checks for other resources...
}
```

## Stack Implementations

### {{stack.frontend.framework}} + Stripe

**Billing Page Component**:
```typescript
// Billing settings page
export default async function BillingPage() {
  const org = await getCurrentOrg();
  const status = await getSubscriptionStatus(org);
  const usage = await getCurrentUsageStats(org.id);

  return (
    <div>
      <CurrentPlanCard plan={status.plan} status={status.status} />
      {status.status === 'trialing' && (
        <TrialBanner daysLeft={status.daysLeft} />
      )}
      <UsageStats usage={usage} limits={PLANS[status.plan].limits} />
      <PlanSelector currentPlan={status.plan} />
      <BillingPortalButton />
    </div>
  );
}
```

## Exit Criteria

Before declaring this skill's work complete, run each check below and paste the output. "Looks right" is not sufficient. Items marked **gateable** can be wired into `project/gates/` for automated phase-exit checks.

| # | Check | Verification | Pass condition | Gateable |
|---|-------|-------------|----------------|----------|
| 1 | Plan limits enforced server-side, not just UI | `grep -rEn "enforceQuota\|requireFeature\|checkLimit" --include="*.ts" --include="*.js" --include="*.py" .` | Match in API route handlers, not only React components. | yes |
| 2 | Usage counters increment on each gated action | Read API handler for one gated action; trace path. | `trackUsage(...)` called inside the handler before returning. | manual |
| 3 | Trial expiration triggers plan downgrade | `grep -rEn "trialEndsAt\|trial_ends_at\|handleTrialExpired" --include="*.ts" --include="*.js" --include="*.py" .` | Job/cron entry that runs daily, downgrades expired-trial orgs to free. | yes |
| 4 | Downgrade enforces limits without hard delete | `grep -rEn "deleteExcessProjects\|hard.*delete.*projects" --include="*.ts" --include="*.js" --include="*.py" .` | Zero matches; archival/grace-period pattern only. | yes |
| 5 | Webhook updates subscription state | `grep -rEn "subscription_status\|subscriptionStatus" --include="*.ts" --include="*.js" --include="*.py" . \| grep -i webhook` | Webhook handler writes subscription status; matches saas-payments contract. | manual |
| 6 | Failed payment recovery wired | `grep -rEn "invoice.payment_failed\|past_due\|dunning" --include="*.ts" --include="*.js" --include="*.py" .` | Match in webhook handler with notification + grace period. | yes |
| 7 | Plan change audit logged | `grep -rEn "audit.*log.*plan\|plan.*change.*log" --include="*.ts" --include="*.js" --include="*.py" .` | Entry in audit table on plan change. | manual |
| 8 | Quota errors communicate the upgrade path | Read one quota-exceeded error response. | Includes `currentPlan`, `upgradeUrl`, or equivalent so the client can present the call to action. | manual |
| 9 | Tests cover trial-expired and downgrade-with-limits | `npm test -- --testPathPattern=billing` or equivalent. | Tests for expired trial → free, and downgrade where org exceeds new limits. | yes |

If any check fails, do not declare done. Fix and re-run.

## Anti-Patterns (Excuse / Rebuttal)

### Excuse: "Hiding the upgrade button in the UI is enough; users on the free plan won't access pro features."

**Rebuttal**: They will, via direct API calls, third-party clients, or by editing the JSX in DevTools. UI gating is for guidance, not enforcement. Every plan gate must be enforced in the API layer, where the request actually does something.

```typescript
// WRONG: Only hiding buttons in frontend
{plan === 'pro' && <CreateProjectButton />}

// RIGHT: Enforce in API
app.post('/projects', enforceQuota('projects'), createProject);
```

### Excuse: "On downgrade we should just delete the projects over the limit; the user knows what they signed up for."

**Rebuttal**: Hard-deleting customer data without consent is a support nightmare and, in some jurisdictions, a legal one. Archive instead, notify the user, give them a grace period to either upgrade back or pick which projects to keep. Restore is cheap; recovery from a deleted-by-mistake escalation is not.

```typescript
// WRONG: Delete user's projects immediately
await deleteExcessProjects(orgId, limits.projects);

// RIGHT: Archive with grace period, notify user
await archiveExcessProjects(orgId, limits.projects);
await sendDowngradeNotification(orgId);
```
