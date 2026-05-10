---
name: saas-payments
description: Integrate Stripe payments and subscriptions for SaaS applications — checkout flows, subscription billing, webhooks, customer portal, invoices, and refunds. Use when building Stripe checkout, subscription, payment, or billing integration features.
version: 1.0.0
category: payments
triggers:
  - stripe
  - payments
  - payment
  - checkout
  - subscription
  - subscriptions
  - billing
  - invoice
  - pricing
  - plan
  - plans
  - metered billing
  - usage billing
  - customer portal
  - payment method
specialist: "@developer"
stack_aware: true
complexity: advanced
estimated_tokens: 4200
dependencies:
  - saas-auth
---

# SaaS Payments & Stripe Integration

## Where this skill ends

This skill owns the **Stripe API surface**: checkout sessions, customer creation, webhook signature verification, raw subscription mutations, metered usage reporting. The patterns describe what we say to Stripe.

This skill does NOT own:

- Plan definitions, feature gating, or quota tracking. Use `saas-billing`.
- Trial state machines or downgrade orchestration. Use `saas-billing`.
- The product-side response to webhook events (updating internal state beyond the simple `profiles` row write shown in references). Use `saas-billing`.

When implementing a flow that crosses both skills (e.g. user upgrades plan): orchestration logic lives in `saas-billing` and calls into the primitives here. Webhook handlers live here and call `saas-billing` update functions for product-side state.

## Capability

Implement production-ready payment processing with Stripe including one-time payments, recurring subscriptions, customer portal, metered billing, and webhook handling. This skill covers the complete billing lifecycle from checkout through subscription management.

## Use Cases

- One-time product purchases with Checkout
- Subscription plans with monthly/yearly billing
- Customer self-service portal for billing management
- Usage-based/metered billing for API products
- Invoice generation and payment tracking
- Handling failed payments and dunning
- Upgrading/downgrading subscription plans

## When NOT to use this skill

This skill covers Stripe Checkout, subscriptions, webhooks, customer portal, and metered usage for typical SaaS apps. It is not the right fit for:

- **E-commerce for physical goods.** Use Shopify, WooCommerce, or BigCommerce. The fulfilment, shipping, and tax patterns are not in scope.
- **Regulated payments** (gambling, securities, crypto custody, money transmission). Stripe is not the right backend; engage a regulated processor.
- **Custodial wallets or stored-value accounts.** Different compliance regime; not Stripe Checkout territory.
- **Marketplaces with split payments at scale.** Use Stripe Connect (different SDK, different patterns) or Adyen MarketPay.
- **Pure ACH / direct-debit at high volume.** Stripe ACH works but the patterns here are card-default; volume ACH usually wants GoCardless or a bank API directly.

## Patterns

### Stripe Checkout for One-Time Payments

**When to use**: Single purchases, credits, one-time fees

**Implementation**: Create Checkout session server-side, redirect customer to Stripe-hosted page.

```typescript
// Create checkout session for one-time payment
async function createCheckoutSession(userId: string, priceId: string, quantity = 1) {
  // Get or create Stripe customer
  const customer = await getOrCreateStripeCustomer(userId);

  const session = await stripe.checkout.sessions.create({
    customer: customer.id,
    mode: 'payment',
    line_items: [
      {
        price: priceId, // price_xxx from Stripe Dashboard
        quantity,
      },
    ],
    success_url: `${process.env.APP_URL}/checkout/success?session_id={CHECKOUT_SESSION_ID}`,
    cancel_url: `${process.env.APP_URL}/checkout/cancel`,
    metadata: {
      userId, // Store for webhook processing
    },
    // Enable invoice for one-time payments
    invoice_creation: {
      enabled: true,
    },
  });

  return { url: session.url };
}

// Get or create Stripe customer linked to user
async function getOrCreateStripeCustomer(userId: string) {
  const user = await db.user.findUnique({ where: { id: userId } });

  if (user.stripeCustomerId) {
    return await stripe.customers.retrieve(user.stripeCustomerId);
  }

  const customer = await stripe.customers.create({
    email: user.email,
    name: user.name,
    metadata: {
      userId,
    },
  });

  await db.user.update({
    where: { id: userId },
    data: { stripeCustomerId: customer.id },
  });

  return customer;
}
```

### Subscription Checkout

**When to use**: Recurring monthly/yearly subscriptions

**Implementation**: Create subscription checkout session with trial period support.

```typescript
// Create subscription checkout
async function createSubscriptionCheckout(userId: string, priceId: string) {
  const customer = await getOrCreateStripeCustomer(userId);

  // Check if already subscribed
  const existingSubscriptions = await stripe.subscriptions.list({
    customer: customer.id,
    status: 'active',
    limit: 1,
  });

  if (existingSubscriptions.data.length > 0) {
    // Redirect to customer portal for upgrades
    return createPortalSession(userId);
  }

  const session = await stripe.checkout.sessions.create({
    customer: customer.id,
    mode: 'subscription',
    line_items: [
      {
        price: priceId,
        quantity: 1,
      },
    ],
    success_url: `${process.env.APP_URL}/dashboard?upgraded=true`,
    cancel_url: `${process.env.APP_URL}/pricing`,
    subscription_data: {
      trial_period_days: 14, // Optional trial
      metadata: {
        userId,
      },
    },
    // Allow promotion codes
    allow_promotion_codes: true,
    // Collect billing address for tax
    billing_address_collection: 'required',
    // Enable automatic tax calculation
    automatic_tax: { enabled: true },
  });

  return { url: session.url };
}
```

### Customer Portal

**When to use**: Allow customers to manage their own billing

**Implementation**: Create portal session for subscription management.

```typescript
// Create customer portal session
async function createPortalSession(userId: string) {
  const user = await db.user.findUnique({ where: { id: userId } });

  if (!user.stripeCustomerId) {
    throw new Error('No billing account found');
  }

  const session = await stripe.billingPortal.sessions.create({
    customer: user.stripeCustomerId,
    return_url: `${process.env.APP_URL}/dashboard/billing`,
  });

  return { url: session.url };
}
```

**Portal Configuration** (via Stripe Dashboard > Settings > Billing > Customer Portal):
- Enable subscription cancellation
- Enable plan switching
- Enable payment method updates
- Enable invoice history
- Configure cancellation reasons

### Webhook Handling

**When to use**: Process Stripe events to sync subscription state

**Implementation**: Verify webhook signature, handle events idempotently.

```typescript
// Webhook handler - CRITICAL for subscription state
async function handleWebhook(request: Request) {
  const sig = request.headers.get('stripe-signature');
  const body = await request.text();

  // Verify webhook signature - NEVER SKIP THIS
  let event;
  try {
    event = stripe.webhooks.constructEvent(
      body,
      sig,
      process.env.STRIPE_WEBHOOK_SECRET
    );
  } catch (err) {
    console.error('Webhook signature verification failed:', err.message);
    return new Response('Invalid signature', { status: 400 });
  }

  // Handle event idempotently
  const idempotencyKey = event.id;
  const processed = await db.processedWebhook.findUnique({
    where: { eventId: idempotencyKey },
  });

  if (processed) {
    return new Response('Already processed', { status: 200 });
  }

  try {
    switch (event.type) {
      case 'checkout.session.completed':
        await handleCheckoutComplete(event.data.object);
        break;

      case 'customer.subscription.created':
      case 'customer.subscription.updated':
        await handleSubscriptionChange(event.data.object);
        break;

      case 'customer.subscription.deleted':
        await handleSubscriptionCanceled(event.data.object);
        break;

      case 'invoice.payment_failed':
        await handlePaymentFailed(event.data.object);
        break;

      case 'invoice.payment_succeeded':
        await handlePaymentSucceeded(event.data.object);
        break;
    }

    // Mark as processed
    await db.processedWebhook.create({
      data: {
        eventId: idempotencyKey,
        type: event.type,
        processedAt: new Date(),
      },
    });

    return new Response('OK', { status: 200 });
  } catch (err) {
    console.error('Webhook processing error:', err);
    return new Response('Processing error', { status: 500 });
  }
}

// Handle subscription state changes
async function handleSubscriptionChange(subscription: Stripe.Subscription) {
  let userId = subscription.metadata.userId;

  if (!userId) {
    // Try to get from customer
    const customer = await stripe.customers.retrieve(subscription.customer as string);
    userId = (customer as Stripe.Customer).metadata.userId;
  }

  const priceId = subscription.items.data[0].price.id;
  const plan = getPlanFromPriceId(priceId);

  await db.user.update({
    where: { id: userId },
    data: {
      subscriptionId: subscription.id,
      subscriptionStatus: subscription.status,
      plan: plan,
      currentPeriodEnd: new Date(subscription.current_period_end * 1000),
      cancelAtPeriodEnd: subscription.cancel_at_period_end,
    },
  });
}

// Handle payment failure
async function handlePaymentFailed(invoice: Stripe.Invoice) {
  const subscription = await stripe.subscriptions.retrieve(
    invoice.subscription as string
  );
  const userId = subscription.metadata.userId;

  // Send email about failed payment
  await sendEmail({
    to: invoice.customer_email,
    template: 'payment-failed',
    data: {
      amount: formatCurrency(invoice.amount_due),
      nextAttempt: invoice.next_payment_attempt
        ? new Date(invoice.next_payment_attempt * 1000)
        : null,
      updatePaymentUrl: await createPortalSession(userId),
    },
  });

  // Update user record
  await db.user.update({
    where: { id: userId },
    data: {
      subscriptionStatus: 'past_due',
    },
  });
}
```

### Metered/Usage-Based Billing

**When to use**: API calls, storage, compute time billing

**Implementation**: Report usage to Stripe, let them handle invoicing.

```typescript
// Report usage for metered billing
async function reportUsage(subscriptionItemId: string, quantity: number, timestamp: number) {
  // Use idempotency key to prevent duplicate charges
  const idempotencyKey = `usage-${subscriptionItemId}-${timestamp}`;

  await stripe.subscriptionItems.createUsageRecord(
    subscriptionItemId,
    {
      quantity,
      timestamp: Math.floor(timestamp / 1000),
      action: 'increment', // or 'set' to override
    },
    {
      idempotencyKey,
    }
  );
}

// Batch report usage (more efficient)
async function reportDailyUsage() {
  const yesterday = new Date();
  yesterday.setDate(yesterday.getDate() - 1);
  yesterday.setHours(0, 0, 0, 0);

  // Get all active metered subscriptions
  const subscriptions = await db.user.findMany({
    where: {
      subscriptionStatus: 'active',
      plan: 'metered',
    },
  });

  for (const user of subscriptions) {
    // Get usage from your system
    const usage = await db.apiUsage.aggregate({
      where: {
        userId: user.id,
        createdAt: {
          gte: yesterday,
          lt: new Date(yesterday.getTime() + 24 * 60 * 60 * 1000),
        },
      },
      _sum: {
        count: true,
      },
    });

    if (usage._sum.count > 0) {
      await reportUsage(
        user.subscriptionItemId,
        usage._sum.count,
        yesterday.getTime()
      );
    }
  }
}
```

### Plan Upgrades/Downgrades (Stripe primitive)

**When to use**: This is the Stripe API primitive. `saas-billing` calls into it from its `changePlan` orchestration. Do not duplicate the orchestration here; this function takes Stripe inputs and returns the Stripe response.

**Implementation**: Mutate the subscription, return the result. Proration choices and product-side state changes belong to the caller.

```typescript
// Stripe primitive: update a subscription's price.
// Called by saas-billing's changePlan orchestration.
async function updateStripeSubscriptionPrice(params: {
  subscriptionId: string;
  newPriceId: string;
  prorationBehavior: 'create_prorations' | 'always_invoice' | 'none';
  billingCycleAnchor: 'now' | 'unchanged';
}) {
  const subscription = await stripe.subscriptions.retrieve(params.subscriptionId);

  const updated = await stripe.subscriptions.update(params.subscriptionId, {
    items: [
      {
        id: subscription.items.data[0].id,
        price: params.newPriceId,
      },
    ],
    proration_behavior: params.prorationBehavior,
    billing_cycle_anchor: params.billingCycleAnchor,
  });

  return { subscription: updated };
}
```

## Stack-Specific Implementation

Stack-specific code is held in `references/`. Load only the file matching the project's stack:

- `references/nextjs-supabase.md` for Next.js 14+ with Supabase Auth.
- `references/remix-railway.md` for Remix with Railway PostgreSQL.

For other stacks (Express, Fastify, Django, Rails, etc.) apply the patterns above using the framework's idioms: a server-side handler that creates a Stripe customer if absent, creates a checkout session with `customer:` set, and a webhook route that verifies the signature before processing events.

## Exit Criteria

Before declaring this skill's work complete, run each check below and paste the output. "Looks right" is not sufficient. Items marked **gateable** can be wired into `project/gates/` for automated phase-exit checks.

| # | Check | Verification | Pass condition | Gateable |
|---|-------|-------------|----------------|----------|
| 1 | Webhook signature verification implemented | `grep -rn "stripe.webhooks.constructEvent" --include="*.ts" --include="*.js" .` | At least one match in webhook handler; verify it raises on failure. | yes |
| 2 | No client-supplied prices | `grep -rEn "stripe.checkout.sessions.create" -A 20 --include="*.ts" --include="*.js" . \| grep -E "price_data\|amount.*req\.body"` | Zero matches (only `price:` references, no `price_data` or amount-from-request). | yes |
| 3 | Idempotency keys on mutations | `grep -rn "idempotencyKey\|idempotency_key" --include="*.ts" --include="*.js" .` | Match in usage reporting and any retried mutation path. | yes |
| 4 | Test mode key in dev/staging | `printenv STRIPE_SECRET_KEY \| head -c 8` in dev; `sk_test_` prefix expected. | Output begins `sk_test_` in dev; `sk_live_` only in production. | yes |
| 5 | API version pinned | `grep -rn "apiVersion:" --include="*.ts" --include="*.js" . \| grep -i stripe` | Explicit `apiVersion:` string set; no implicit defaults. | yes |
| 6 | Subscription state synced via webhook, not success page | Read the success page handler (`/api/checkout/success` or equivalent). | Handler does not write subscription state; only displays status while webhook lands. | manual |
| 7 | Failed payment handler exists | `grep -rn "invoice.payment_failed" --include="*.ts" --include="*.js" .` | Match in webhook handler with notification + grace period logic. | yes |
| 8 | Customer portal configured | Stripe Dashboard → Settings → Billing → Customer portal: subscription cancellation, plan switching, payment method updates enabled. | Manual screenshot or settings export. | manual |
| 9 | No card data stored locally | `grep -rEn "card_number\|cvv\|card.*token" --include="*.ts" --include="*.js" .` | Zero matches in application code (Stripe.js / Elements only). | yes |
| 10 | Price IDs in env, not source | `grep -rn "price_[A-Za-z0-9]\{14,\}" --include="*.ts" --include="*.js" . \| grep -v ".test.\|.spec." \| grep -v "process.env"` | Zero non-test, non-env matches. | yes |

If any check fails, do not declare done. Fix and re-run.

## Integration Points

- **saas-auth**: Link Stripe customer to authenticated user, require auth for checkout
- **saas-database**: Store subscription state, handle webhook updates
- **saas-email**: Send payment receipts, failed payment notices, cancellation confirmations
- **saas-api**: Gate API access based on subscription plan/status

## Anti-Patterns (Excuse / Rebuttal)

### Excuse: "I'll trust the client to send the right price; we control the JavaScript."

**Rebuttal**: You don't control the JavaScript at runtime. Users can modify any value in DevTools. Accept only price IDs created in the Stripe Dashboard server-side; never accept an amount from the client. The day you accept a client-supplied amount is the day someone buys the enterprise plan for £0.01.

### Excuse: "Webhook signature verification is overkill; we're behind a private gateway."

**Rebuttal**: The gateway is one config change away from being public, and the webhook URL is going to leak into Stripe-side logs and your error tracker regardless. Your handler is a public RPC into your subscription database. Add the four lines: `stripe.webhooks.constructEvent(body, signature, secret)` and reject failures. There is no scenario where skipping this saves more time than it costs.

### Excuse: "I'll hardcode the API key for now and clean it up before commit."

**Rebuttal**: You will not. Hardcoded keys reach git, then build artefacts, then logs, then the public internet. Use environment variables from the first line of code, and use restricted keys (separate read, write, webhook) so a leak has bounded blast radius.

### Excuse: "The checkout success page handler is fine; users always get redirected back."

**Rebuttal**: They don't. Browsers crash, networks drop, users close the tab between the Stripe redirect and your success page. If the success page is your only place that records "they paid", you will silently lose subscriptions. Webhooks are the source of truth; the success page should display "processing your subscription" until the webhook confirms.

### Excuse: "Failed payments are rare, I'll handle them when it happens."

**Rebuttal**: Failed payments are not rare; they are 5-10% of recurring SaaS volume. Without `invoice.payment_failed` handling, those users continue accessing your product while their payment lapses, and you find out at month-end when MRR drops. Wire the event now: notify the user, set a grace period, restrict access at the end of it. Three event handlers, ~30 lines.

### Excuse: "I'll keep subscription state in our database and update it manually when things change."

**Rebuttal**: Your database and Stripe will drift the first time a webhook fails or a manual change happens via the Stripe Dashboard. Stripe is the source of truth; sync every state change via webhooks (`customer.subscription.created`, `updated`, `deleted`, `invoice.payment_succeeded`, `invoice.payment_failed`). Your database stores what Stripe last told you, never anything Stripe didn't.

## References

- [Stripe Checkout Documentation](https://stripe.com/docs/checkout) - official-docs
- [Stripe Webhooks Best Practices](https://stripe.com/docs/webhooks/best-practices) - official-docs
- [Stripe Billing Documentation](https://stripe.com/docs/billing) - official-docs
- [Stripe Testing](https://stripe.com/docs/testing) - official-docs
- [PCI Compliance](https://stripe.com/docs/security) - security-guidelines
