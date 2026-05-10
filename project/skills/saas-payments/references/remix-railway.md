# saas-payments — Remix + Railway reference

Stack-specific implementation for Remix on Railway with PostgreSQL. Load this only when the project's stack matches. The main `SKILL.md` carries the stack-agnostic patterns; this file fills in the framework-specific glue.

## Setup

```typescript
// app/lib/stripe.server.ts
import Stripe from 'stripe';

export const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2024-06-20',
});
```

## Checkout action

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

## Webhook handler

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

## Required environment variables

```
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
APP_URL=
DATABASE_URL=
```

## Webhook endpoint to register in Stripe Dashboard

`https://yourdomain.com/api/webhooks/stripe`

Subscribe to: `customer.subscription.created`, `customer.subscription.updated`, `customer.subscription.deleted`, `invoice.payment_succeeded`, `invoice.payment_failed`.
