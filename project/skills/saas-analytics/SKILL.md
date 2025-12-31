---
name: saas-analytics
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

## Quality Checklist

- [ ] Analytics abstracted from provider
- [ ] Consistent event naming convention
- [ ] User identification on signup/login
- [ ] Organization/group association for B2B
- [ ] Server-side tracking for critical events
- [ ] Client-side tracking for UI interactions
- [ ] Key metrics calculated and stored daily
- [ ] Event schema documented for team
- [ ] PII handling compliant with privacy laws
- [ ] Analytics disabled in development/test

## Anti-Patterns

### Tracking Everything
```typescript
// WRONG: Noise drowns out signal
track('button_hovered');
track('scroll_position_changed');
track('mouse_moved');

// RIGHT: Track meaningful actions
track('feature_used', { feature: 'export', format: 'csv' });
```

### No User Context
```typescript
// WRONG: Can't attribute to user
analytics.track('project_created');

// RIGHT: Always include user
analytics.track(userId, 'project_created', { projectId });
```

### Inconsistent Naming
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
