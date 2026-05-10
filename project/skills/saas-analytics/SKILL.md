---
name: saas-analytics
description: Implement product analytics for SaaS applications using PostHog or similar — event tracking, funnels, retention cohorts, feature adoption metrics, and dashboard wiring. Use when building analytics, event tracking, metrics, conversion, retention, or PostHog integration features.
version: 1.0.0
category: analytics
triggers:
  - analytics
  - tracking
  - metrics
  - events
  - usage tracking
  - product analytics
  - user analytics
  - posthog
  - mixpanel
  - amplitude
  - segment
specialist: "@analyst"
stack_aware: true
complexity: intermediate
estimated_tokens: 3600
dependencies: []
---

# SaaS Product Analytics

## Capability

Implement product analytics for understanding user behavior, tracking key metrics, and making data-driven decisions. Covers event tracking, user identification, cohort analysis, and integration with analytics platforms like PostHog, Mixpanel, or custom solutions.

## Use Cases

- Track user actions and feature usage
- Measure activation and retention metrics
- Identify power users and at-risk accounts
- A/B test experiments tracking
- Funnel analysis and conversion tracking
- Custom dashboard metrics

## Patterns

### Analytics Service Abstraction

**When to use**: Provider-agnostic analytics with consistent API

**Implementation**: Abstract analytics behind unified interface for easy provider switching.

```typescript
// Analytics interface
interface AnalyticsService {
  identify(userId: string, traits: Record<string, unknown>): Promise<void>;
  track(userId: string, event: string, properties?: Record<string, unknown>): Promise<void>;
  page(userId: string, name: string, properties?: Record<string, unknown>): Promise<void>;
  group(userId: string, groupId: string, traits: Record<string, unknown>): Promise<void>;
}

// PostHog implementation
class PostHogAnalytics implements AnalyticsService {
  private client: PostHog;

  constructor(apiKey: string, host?: string) {
    this.client = new PostHog(apiKey, { host: host || 'https://app.posthog.com' });
  }

  async identify(userId: string, traits: Record<string, unknown>) {
    this.client.identify({
      distinctId: userId,
      properties: traits
    });
  }

  async track(userId: string, event: string, properties?: Record<string, unknown>) {
    this.client.capture({
      distinctId: userId,
      event,
      properties: {
        ...properties,
        timestamp: new Date().toISOString()
      }
    });
  }

  async page(userId: string, name: string, properties?: Record<string, unknown>) {
    this.client.capture({
      distinctId: userId,
      event: '$pageview',
      properties: { $current_url: name, ...properties }
    });
  }

  async group(userId: string, groupId: string, traits: Record<string, unknown>) {
    this.client.groupIdentify({
      groupType: 'organization',
      groupKey: groupId,
      properties: traits
    });
    this.client.capture({
      distinctId: userId,
      event: '$groupidentify',
      properties: { $group_type: 'organization', $group_key: groupId }
    });
  }

  shutdown() {
    this.client.shutdown();
  }
}

// Usage
const analytics = new PostHogAnalytics(process.env.POSTHOG_API_KEY);

// Identify user
await analytics.identify(user.id, {
  email: user.email,
  name: user.name,
  plan: user.plan,
  createdAt: user.createdAt
});

// Track event
await analytics.track(user.id, 'project_created', {
  projectId: project.id,
  projectType: project.type
});
```

### Event Schema & Naming Conventions

**When to use**: Maintain consistent, queryable analytics data

**Implementation**: Define standard event schema with naming conventions.

```typescript
// Event naming convention: object_action
// Examples: project_created, user_invited, feature_used

// Standard event properties
interface BaseEventProperties {
  timestamp: string;
  sessionId?: string;
  source?: 'web' | 'api' | 'mobile';
  version?: string;
}

// Event catalog with type safety
const EVENTS = {
  // Auth events
  user_signed_up: (props: { method: 'email' | 'google' | 'github' }) => props,
  user_logged_in: (props: { method: string }) => props,
  user_logged_out: () => ({}),

  // Onboarding events
  onboarding_started: () => ({}),
  onboarding_step_completed: (props: { step: string; duration: number }) => props,
  onboarding_completed: (props: { totalDuration: number }) => props,
  onboarding_skipped: (props: { lastStep: string }) => props,

  // Core feature events
  project_created: (props: { projectId: string; template?: string }) => props,
  project_deleted: (props: { projectId: string }) => props,
  feature_used: (props: { feature: string; context?: string }) => props,

  // Team events
  team_member_invited: (props: { role: string }) => props,
  team_member_joined: (props: { inviteId: string }) => props,

  // Billing events
  plan_viewed: (props: { currentPlan: string }) => props,
  plan_selected: (props: { plan: string; interval: 'monthly' | 'yearly' }) => props,
  checkout_started: (props: { plan: string }) => props,
  subscription_created: (props: { plan: string; mrr: number }) => props,
  subscription_cancelled: (props: { plan: string; reason?: string }) => props
} as const;

// Type-safe track function
async function trackEvent<E extends keyof typeof EVENTS>(
  userId: string,
  event: E,
  properties: ReturnType<typeof EVENTS[E]>
) {
  await analytics.track(userId, event, {
    ...properties,
    timestamp: new Date().toISOString()
  });
}

// Usage with full type safety
await trackEvent(user.id, 'project_created', {
  projectId: project.id,
  template: 'starter'
});
```

### Server-Side Tracking

**When to use**: Track events from API routes and server actions

**Implementation**: Middleware and helpers for consistent server tracking.

```typescript
// Analytics context in request
declare global {
  namespace Express {
    interface Request {
      analytics: {
        userId: string;
        sessionId: string;
        track: (event: string, properties?: Record<string, unknown>) => Promise<void>;
      };
    }
  }
}

// Analytics middleware
async function analyticsMiddleware(req: Request, res: Response, next: NextFunction) {
  const userId = req.session?.userId;
  const sessionId = req.cookies?.sessionId || generateSessionId();

  req.analytics = {
    userId,
    sessionId,
    track: async (event, properties) => {
      if (!userId) return; // Don't track anonymous
      await analytics.track(userId, event, {
        ...properties,
        sessionId,
        path: req.path,
        method: req.method
      });
    }
  };

  // Track page view for GET requests
  if (req.method === 'GET' && userId) {
    await analytics.page(userId, req.path);
  }

  next();
}

// Usage in API route
app.post('/api/projects', async (req, res) => {
  const project = await createProject(req.body);

  await req.analytics.track('project_created', {
    projectId: project.id,
    projectType: project.type
  });

  res.json(project);
});
```

### Client-Side Tracking

**When to use**: Track UI interactions and page views

**Implementation**: React hooks and components for frontend tracking.

```tsx
// Analytics context provider
'use client';

import { createContext, useContext, useEffect } from 'react';
import posthog from 'posthog-js';

const AnalyticsContext = createContext<{
  track: (event: string, properties?: Record<string, unknown>) => void;
  identify: (userId: string, traits: Record<string, unknown>) => void;
} | null>(null);

export function AnalyticsProvider({ children }: { children: React.ReactNode }) {
  useEffect(() => {
    posthog.init(process.env.NEXT_PUBLIC_POSTHOG_KEY!, {
      api_host: process.env.NEXT_PUBLIC_POSTHOG_HOST
    });
  }, []);

  const track = (event: string, properties?: Record<string, unknown>) => {
    posthog.capture(event, properties);
  };

  const identify = (userId: string, traits: Record<string, unknown>) => {
    posthog.identify(userId, traits);
  };

  return (
    <AnalyticsContext.Provider value={{ track, identify }}>
      {children}
    </AnalyticsContext.Provider>
  );
}

export function useAnalytics() {
  const context = useContext(AnalyticsContext);
  if (!context) throw new Error('useAnalytics must be used within AnalyticsProvider');
  return context;
}

// Usage in component
function CreateProjectButton() {
  const { track } = useAnalytics();

  const handleClick = async () => {
    track('create_project_clicked', { location: 'dashboard' });
    // ... create project
    track('project_created', { projectId: newProject.id });
  };

  return <button onClick={handleClick}>Create Project</button>;
}

// Auto-track page views
function PageViewTracker() {
  const pathname = usePathname();
  const { track } = useAnalytics();

  useEffect(() => {
    track('$pageview', { path: pathname });
  }, [pathname, track]);

  return null;
}
```

### Key Metrics Tracking

**When to use**: Track SaaS health metrics

**Implementation**: Calculate and store key metrics for dashboards.

```typescript
// Daily metrics aggregation job
async function calculateDailyMetrics(date: Date) {
  const startOfDay = new Date(date.setHours(0, 0, 0, 0));
  const endOfDay = new Date(date.setHours(23, 59, 59, 999));

  // Active users (logged in today)
  const dau = await db.query.sessions.count({
    where: and(
      gte(sessions.createdAt, startOfDay),
      lte(sessions.createdAt, endOfDay)
    )
  });

  // New signups
  const newUsers = await db.query.users.count({
    where: and(
      gte(users.createdAt, startOfDay),
      lte(users.createdAt, endOfDay)
    )
  });

  // Activated users (completed key action)
  const activatedUsers = await db.query.users.count({
    where: and(
      gte(users.activatedAt, startOfDay),
      lte(users.activatedAt, endOfDay)
    )
  });

  // MRR (Monthly Recurring Revenue)
  const mrr = await calculateMRR();

  // Store metrics
  await db.insert(dailyMetrics).values({
    date: startOfDay,
    dau,
    newUsers,
    activatedUsers,
    activationRate: newUsers > 0 ? activatedUsers / newUsers : 0,
    mrr,
    churnRate: await calculateChurnRate(startOfDay)
  });
}

// Key metrics dashboard API
app.get('/api/admin/metrics', async (req, res) => {
  const { period = '30d' } = req.query;
  const days = parseInt(period) || 30;

  const metrics = await db.query.dailyMetrics.findMany({
    where: gte(dailyMetrics.date, subDays(new Date(), days)),
    orderBy: asc(dailyMetrics.date)
  });

  // Calculate trends
  const currentPeriod = metrics.slice(-days / 2);
  const previousPeriod = metrics.slice(0, days / 2);

  res.json({
    metrics,
    summary: {
      totalDAU: sum(currentPeriod, 'dau'),
      dauTrend: calculateTrend(previousPeriod, currentPeriod, 'dau'),
      currentMRR: metrics[metrics.length - 1]?.mrr || 0,
      mrrGrowth: calculateGrowth(previousPeriod, currentPeriod, 'mrr'),
      avgActivationRate: average(currentPeriod, 'activationRate')
    }
  });
});
```

## Stack Implementations

### {{stack.services.analytics}} Integration

**PostHog (Recommended for product analytics)**:
```typescript
import { PostHog } from 'posthog-node';
const posthog = new PostHog(process.env.POSTHOG_API_KEY);
```

**Mixpanel**:
```typescript
import Mixpanel from 'mixpanel';
const mixpanel = Mixpanel.init(process.env.MIXPANEL_TOKEN);
```

**Segment (for multi-destination)**:
```typescript
import Analytics from '@segment/analytics-node';
const analytics = new Analytics({ writeKey: process.env.SEGMENT_WRITE_KEY });
```

## Exit Criteria

Before declaring this skill's work complete, run each check below and paste the output. "Looks right" is not sufficient. Items marked **gateable** can be wired into `project/gates/` for automated phase-exit checks.

| # | Check | Verification | Pass condition | Gateable |
|---|-------|-------------|----------------|----------|
| 1 | Analytics behind a single abstraction | `grep -rEn "interface AnalyticsService\|class.*Analytics.*implements" --include="*.ts" --include="*.js" --include="*.py" .` | Match. Direct provider calls (`posthog.capture`, `mixpanel.track`, etc.) appear only in the implementation class. | yes |
| 2 | Direct provider calls only inside the abstraction | `grep -rEn "posthog\.|mixpanel\.|amplitude\.|@segment" --include="*.ts" --include="*.js" --include="*.py" . \| grep -v -E "AnalyticsService\|analytics/provider\|test\|spec"` | Zero matches outside the analytics module. | yes |
| 3 | Event names follow `object_action` snake_case | `grep -rEn "track\(['\"][A-Z]\|track\(['\"][a-z]+-" --include="*.ts" --include="*.js" .` | Zero matches (no PascalCase, no kebab-case events). | yes |
| 4 | User identified on signup and login | `grep -rEn "analytics\.identify\|posthog\.identify\|mixpanel\.identify" --include="*.ts" --include="*.js" --include="*.py" .` | Match in signup handler, login handler, session restore. | yes |
| 5 | All `track` calls include user ID server-side | Read 5 server-side `track` call sites. | Each passes a user ID as first argument; no anonymous server-side tracks. | manual |
| 6 | Server-side tracking for critical events | Read handler for: signup, plan_selected, subscription_created, project_created. | Each calls `analytics.track` server-side, not just client-side. | manual |
| 7 | Analytics off in dev/test | `grep -rEn "NODE_ENV.*test\|NODE_ENV.*development" --include="*.ts" --include="*.js" --include="*.py" . \| grep -i analytics` | Match: analytics initialisation gated on environment. | yes |
| 8 | PII not sent in event properties | Read 5 most common `track` call sites. | No raw email, password, payment details in `properties`; user ID only. | manual |

If any check fails, do not declare done. Fix and re-run.

## Anti-Patterns (Excuse / Rebuttal)

### Excuse: "We'll track everything now and decide what's useful later."

**Rebuttal**: Tracking everything produces a wall of noise nobody queries. Storage costs go up, your dashboards get slower, and the events that actually matter drown in mouse-move telemetry. Track meaningful actions, not interactions. If you cannot articulate a question the event answers, it is not worth tracking.

```typescript
// WRONG: Noise drowns out signal
track('button_hovered');
track('scroll_position_changed');
track('mouse_moved');

// RIGHT: Track meaningful actions
track('feature_used', { feature: 'export', format: 'csv' });
```

### Excuse: "Server-side tracking knows the user from the session, no need to pass it explicitly."

**Rebuttal**: It does not, reliably. Background jobs, webhook handlers, retry workers, anything that runs outside a request context loses the session and silently emits anonymous events. Always pass the user ID explicitly to `track`, even when it feels redundant. The cost of an extra parameter is zero; the cost of an unattributable event is the entire event.

```typescript
// WRONG: Can't attribute to user
analytics.track('project_created');

// RIGHT: Always include user
analytics.track(userId, 'project_created', { projectId });
```

### Excuse: "Each event name is fine on its own; consistency does not matter."

**Rebuttal**: It matters when you need to query. `UserCreatedProject`, `project-deleted`, and `BILLING_UPGRADED` all need different filters in your analytics tool, and joining them across funnels becomes a string-matching exercise. Pick `object_action` snake_case and stick to it from the first event. The cost of changing later is rewriting every dashboard.

```typescript
// WRONG: Inconsistent patterns
track('UserCreatedProject');
track('project-deleted');
track('BILLING_UPGRADED');

// RIGHT: Consistent object_action format
track('project_created');
track('project_deleted');
track('subscription_upgraded');
```
