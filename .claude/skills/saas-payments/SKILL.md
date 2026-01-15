---
name: saas-payments
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

### Plan Upgrades/Downgrades

**When to use**: Changing subscription plans mid-cycle

**Implementation**: Use Stripe's proration or let users manage via portal.

```typescript
// Upgrade/downgrade subscription
async function changePlan(userId: string, newPriceId: string) {
  const user = await db.user.findUnique({ where: { id: userId } });

  if (!user.subscriptionId) {
    throw new Error('No active subscription');
  }

  const subscription = await stripe.subscriptions.retrieve(user.subscriptionId);

  // Update subscription with proration
  const updated = await stripe.subscriptions.update(user.subscriptionId, {
    items: [
      {
        id: subscription.items.data[0].id,
        price: newPriceId,
      },
    ],
    proration_behavior: 'create_prorations', // or 'none', 'always_invoice'
  });

  // Database update happens via webhook
  return { subscription: updated };
}
```

## Stack-Specific Implementation

### nextjs-supabase

**Setup**: Install Stripe, configure webhooks, set up API routes.

```bash
npm install stripe
```

```typescript
// lib/stripe.ts
import Stripe from 'stripe';

export const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2024-06-20',
  typescript: true,
});
```

```typescript
// app/api/checkout/route.ts
import { createClient } from '@/lib/supabase/server';
import { stripe } from '@/lib/stripe';
import { NextResponse } from 'next/server';

export async function POST(request: Request) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  const { priceId } = await request.json();

  // Get or create customer
  const { data: profile } = await supabase
    .from('profiles')
    .select('stripe_customer_id')
    .eq('id', user.id)
    .single();

  let customerId = profile?.stripe_customer_id;

  if (!customerId) {
    const customer = await stripe.customers.create({
      email: user.email,
      metadata: { userId: user.id },
    });
    customerId = customer.id;

    await supabase
      .from('profiles')
      .update({ stripe_customer_id: customerId })
      .eq('id', user.id);
  }

  // Create checkout session
  const session = await stripe.checkout.sessions.create({
    customer: customerId,
    mode: 'subscription',
    line_items: [{ price: priceId, quantity: 1 }],
    success_url: `${process.env.NEXT_PUBLIC_APP_URL}/dashboard?upgraded=true`,
    cancel_url: `${process.env.NEXT_PUBLIC_APP_URL}/pricing`,
    subscription_data: {
      metadata: { userId: user.id },
    },
  });

  return NextResponse.json({ url: session.url });
}
```

```typescript
// app/api/webhooks/stripe/route.ts
import { stripe } from '@/lib/stripe';
import { createClient } from '@supabase/supabase-js';
import { headers } from 'next/headers';
import { NextResponse } from 'next/server';
import Stripe from 'stripe';

// Use service role for webhook (no user context)
const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

export async function POST(request: Request) {
  const body = await request.text();
  const headersList = await headers();
  const sig = headersList.get('stripe-signature')!;

  let event: Stripe.Event;

  try {
    event = stripe.webhooks.constructEvent(
      body,
      sig,
      process.env.STRIPE_WEBHOOK_SECRET!
    );
  } catch (err) {
    return NextResponse.json({ error: 'Invalid signature' }, { status: 400 });
  }

  switch (event.type) {
    case 'customer.subscription.created':
    case 'customer.subscription.updated': {
      const subscription = event.data.object as Stripe.Subscription;
      const userId = subscription.metadata.userId;

      await supabase
        .from('profiles')
        .update({
          subscription_id: subscription.id,
          subscription_status: subscription.status,
          plan: getPlanFromPrice(subscription.items.data[0].price.id),
          current_period_end: new Date(
            subscription.current_period_end * 1000
          ).toISOString(),
        })
        .eq('id', userId);
      break;
    }

    case 'customer.subscription.deleted': {
      const subscription = event.data.object as Stripe.Subscription;
      const userId = subscription.metadata.userId;

      await supabase
        .from('profiles')
        .update({
          subscription_status: 'canceled',
          plan: 'free',
        })
        .eq('id', userId);
      break;
    }
  }

  return NextResponse.json({ received: true });
}
```

### remix-railway

**Setup**: Configure Stripe with Remix action handlers.

```typescript
// app/lib/stripe.server.ts
import Stripe from 'stripe';

export const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2024-06-20',
});
```

```typescript
// app/routes/api.checkout.ts
import { ActionFunctionArgs, json } from '@remix-run/node';
import { stripe } from '~/lib/stripe.server';
import { requireAuth } from '~/lib/session.server';
import { db } from '~/lib/db.server';

export async function action({ request }: ActionFunctionArgs) {
  const { user } = await requireAuth(request);
  const formData = await request.formData();
  const priceId = formData.get('priceId') as string;

  // Get or create customer
  let customerId = user.stripeCustomerId;

  if (!customerId) {
    const customer = await stripe.customers.create({
      email: user.email,
      metadata: { userId: user.id },
    });
    customerId = customer.id;

    await db.user.update({
      where: { id: user.id },
      data: { stripeCustomerId: customerId },
    });
  }

  const session = await stripe.checkout.sessions.create({
    customer: customerId,
    mode: 'subscription',
    line_items: [{ price: priceId, quantity: 1 }],
    success_url: `${process.env.APP_URL}/dashboard?upgraded=true`,
    cancel_url: `${process.env.APP_URL}/pricing`,
    subscription_data: {
      metadata: { userId: user.id },
    },
  });

  return json({ url: session.url });
}
```

```typescript
// app/routes/api.webhooks.stripe.ts
import { ActionFunctionArgs } from '@remix-run/node';
import { stripe } from '~/lib/stripe.server';
import { db } from '~/lib/db.server';

export async function action({ request }: ActionFunctionArgs) {
  const payload = await request.text();
  const sig = request.headers.get('stripe-signature')!;

  let event;

  try {
    event = stripe.webhooks.constructEvent(
      payload,
      sig,
      process.env.STRIPE_WEBHOOK_SECRET!
    );
  } catch (err) {
    return new Response('Invalid signature', { status: 400 });
  }

  switch (event.type) {
    case 'customer.subscription.updated': {
      const subscription = event.data.object;
      await db.user.update({
        where: { id: subscription.metadata.userId },
        data: {
          subscriptionId: subscription.id,
          subscriptionStatus: subscription.status,
          currentPeriodEnd: new Date(subscription.current_period_end * 1000),
        },
      });
      break;
    }
    // Handle other events...
  }

  return new Response('OK', { status: 200 });
}
```

## Quality Checklist

- [ ] Webhook signature verification implemented (NEVER trust unverified webhooks)
- [ ] Idempotency keys used for all mutations (prevent duplicate charges)
- [ ] Test mode verification before any production deployment
- [ ] Card failure error handling with user-friendly messages
- [ ] Subscription state synced via webhooks (not checkout success page)
- [ ] Customer portal configured for self-service
- [ ] Price IDs stored as environment variables (not hardcoded)
- [ ] Stripe API version pinned in client initialization
- [ ] Failed payment email notifications configured
- [ ] Subscription cancellation grace period set
- [ ] Tax calculation enabled if required by jurisdiction
- [ ] PCI compliance maintained (no card data on your servers)

## Integration Points

- **saas-auth**: Link Stripe customer to authenticated user, require auth for checkout
- **saas-database**: Store subscription state, handle webhook updates
- **saas-email**: Send payment receipts, failed payment notices, cancellation confirmations
- **saas-api**: Gate API access based on subscription plan/status

## Anti-Patterns

### Trusting Client-Side Prices

**Why it's bad**: Users can modify JavaScript to send any price. You'll charge wrong amounts.

**Instead**: Always use price IDs created in Stripe Dashboard. Never accept amounts from the client.

### Skipping Webhook Signature Verification

**Why it's bad**: Anyone can POST fake events to your webhook endpoint.

**Instead**: Always call `stripe.webhooks.constructEvent()` with your webhook secret. Reject invalid signatures.

### Hardcoding API Keys

**Why it's bad**: Keys in code get committed to git, exposed in builds, leaked in logs.

**Instead**: Use environment variables. Use restricted keys with minimal permissions.

### Relying on Checkout Success Page

**Why it's bad**: Users may close browser before redirect. Success page may not load.

**Instead**: Use webhooks as source of truth. Success page should just say "processing" until webhook confirms.

### Not Handling Failed Payments

**Why it's bad**: Users with failed payments continue using service. Revenue lost.

**Instead**: Listen for `invoice.payment_failed`, notify users, implement grace period, then restrict access.

### Manual Subscription State

**Why it's bad**: Your database and Stripe get out of sync. Users access features they shouldn't.

**Instead**: Sync ALL subscription state changes via webhooks. Stripe is the source of truth.

## References

- [Stripe Checkout Documentation](https://stripe.com/docs/checkout) - official-docs
- [Stripe Webhooks Best Practices](https://stripe.com/docs/webhooks/best-practices) - official-docs
- [Stripe Billing Documentation](https://stripe.com/docs/billing) - official-docs
- [Stripe Testing](https://stripe.com/docs/testing) - official-docs
- [PCI Compliance](https://stripe.com/docs/security) - security-guidelines
