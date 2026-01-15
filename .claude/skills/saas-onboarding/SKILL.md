---
name: saas-onboarding
version: 1.0.0
category: infrastructure
triggers:
  - onboarding
  - user onboarding
  - setup wizard
  - getting started
  - first run
  - activation
  - aha moment
  - checklist
  - tour
  - walkthrough
specialist: "@developer"
stack_aware: true
complexity: intermediate
estimated_tokens: 3500
dependencies:
  - saas-auth
---

# SaaS User Onboarding

## Capability

Implement effective user onboarding flows that drive activation and reduce churn. Covers setup wizards, progress checklists, contextual tooltips, and tracking of key activation milestones. Focus on getting users to their "aha moment" quickly.

## Use Cases

- Multi-step setup wizard after signup
- Onboarding checklist with progress tracking
- Contextual tooltips and feature tours
- Activation milestone tracking
- Re-engagement for incomplete onboarding
- Team member onboarding variations

## Patterns

### Onboarding State Machine

**When to use**: Track user progress through onboarding steps

**Implementation**: Persist onboarding state with completed steps and progress.

```typescript
// Onboarding state schema
const onboardingStates = pgTable('onboarding_states', {
  id: uuid('id').primaryKey().defaultRandom(),
  userId: uuid('user_id').references(() => users.id).unique(),
  currentStep: text('current_step').notNull().default('welcome'),
  completedSteps: jsonb('completed_steps').$type<string[]>().default([]),
  stepData: jsonb('step_data').$type<Record<string, unknown>>().default({}),
  startedAt: timestamp('started_at').defaultNow(),
  completedAt: timestamp('completed_at'),
  skippedAt: timestamp('skipped_at')
});

// Onboarding steps definition
const ONBOARDING_STEPS = [
  { id: 'welcome', title: 'Welcome', required: true },
  { id: 'profile', title: 'Complete Profile', required: true },
  { id: 'create_project', title: 'Create First Project', required: true },
  { id: 'invite_team', title: 'Invite Team Members', required: false },
  { id: 'connect_integration', title: 'Connect Integration', required: false },
  { id: 'explore_features', title: 'Explore Features', required: false }
] as const;

// Get onboarding status
async function getOnboardingStatus(userId: string) {
  const state = await db.query.onboardingStates.findFirst({
    where: eq(onboardingStates.userId, userId)
  });

  if (!state) {
    // Initialize onboarding
    const [newState] = await db.insert(onboardingStates)
      .values({ userId })
      .returning();
    return formatOnboardingStatus(newState);
  }

  return formatOnboardingStatus(state);
}

function formatOnboardingStatus(state: OnboardingState) {
  const totalRequired = ONBOARDING_STEPS.filter(s => s.required).length;
  const completedRequired = state.completedSteps
    .filter(stepId => ONBOARDING_STEPS.find(s => s.id === stepId)?.required)
    .length;

  return {
    currentStep: state.currentStep,
    completedSteps: state.completedSteps,
    progress: Math.round((completedRequired / totalRequired) * 100),
    isComplete: state.completedAt !== null,
    isSkipped: state.skippedAt !== null,
    steps: ONBOARDING_STEPS.map(step => ({
      ...step,
      completed: state.completedSteps.includes(step.id),
      current: state.currentStep === step.id
    }))
  };
}
```

### Step Wizard Component

**When to use**: Guide users through multi-step setup process

**Implementation**: Step-by-step wizard with progress indicator and step validation.

```tsx
// Onboarding wizard component
'use client';

import { useState } from 'react';

interface OnboardingWizardProps {
  initialStatus: OnboardingStatus;
  onComplete: () => void;
}

export function OnboardingWizard({ initialStatus, onComplete }: OnboardingWizardProps) {
  const [status, setStatus] = useState(initialStatus);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const currentStepIndex = status.steps.findIndex(s => s.current);
  const currentStep = status.steps[currentStepIndex];

  async function completeStep(stepData?: Record<string, unknown>) {
    setIsSubmitting(true);

    const response = await fetch('/api/onboarding/complete-step', {
      method: 'POST',
      body: JSON.stringify({
        stepId: currentStep.id,
        data: stepData
      })
    });

    const newStatus = await response.json();
    setStatus(newStatus);
    setIsSubmitting(false);

    if (newStatus.isComplete) {
      onComplete();
    }
  }

  async function skipOnboarding() {
    await fetch('/api/onboarding/skip', { method: 'POST' });
    onComplete();
  }

  return (
    <div className="max-w-2xl mx-auto p-8">
      {/* Progress bar */}
      <div className="mb-8">
        <div className="flex justify-between mb-2">
          <span className="text-sm font-medium">Setup Progress</span>
          <span className="text-sm text-gray-500">{status.progress}%</span>
        </div>
        <div className="h-2 bg-gray-200 rounded-full">
          <div
            className="h-2 bg-blue-600 rounded-full transition-all"
            style={{ width: `${status.progress}%` }}
          />
        </div>
      </div>

      {/* Step indicators */}
      <div className="flex gap-2 mb-8">
        {status.steps.filter(s => s.required).map((step, i) => (
          <div
            key={step.id}
            className={`flex-1 h-1 rounded ${
              step.completed ? 'bg-green-500' :
              step.current ? 'bg-blue-500' : 'bg-gray-200'
            }`}
          />
        ))}
      </div>

      {/* Current step content */}
      <OnboardingStepContent
        step={currentStep}
        onComplete={completeStep}
        isSubmitting={isSubmitting}
      />

      {/* Skip option for optional steps */}
      {!currentStep.required && (
        <button
          onClick={() => completeStep()}
          className="text-sm text-gray-500 mt-4"
        >
          Skip this step
        </button>
      )}

      {/* Skip all option */}
      <button
        onClick={skipOnboarding}
        className="text-sm text-gray-400 mt-8 block"
      >
        Skip setup, I'll explore on my own
      </button>
    </div>
  );
}

// Individual step content
function OnboardingStepContent({ step, onComplete, isSubmitting }) {
  switch (step.id) {
    case 'welcome':
      return <WelcomeStep onComplete={onComplete} />;
    case 'profile':
      return <ProfileStep onComplete={onComplete} isSubmitting={isSubmitting} />;
    case 'create_project':
      return <CreateProjectStep onComplete={onComplete} isSubmitting={isSubmitting} />;
    case 'invite_team':
      return <InviteTeamStep onComplete={onComplete} isSubmitting={isSubmitting} />;
    default:
      return null;
  }
}
```

### Activation Tracking

**When to use**: Measure and optimize time-to-value

**Implementation**: Track key activation events and milestones.

```typescript
// Activation events
const ACTIVATION_EVENTS = {
  signed_up: { weight: 1, milestone: false },
  completed_profile: { weight: 1, milestone: false },
  created_first_project: { weight: 3, milestone: true },
  invited_team_member: { weight: 2, milestone: true },
  used_core_feature: { weight: 3, milestone: true }, // "Aha moment"
  upgraded_plan: { weight: 5, milestone: true }
} as const;

// Track activation event
async function trackActivation(userId: string, event: string, metadata?: Record<string, unknown>) {
  const eventConfig = ACTIVATION_EVENTS[event];
  if (!eventConfig) return;

  // Store event
  await db.insert(activationEvents).values({
    userId,
    event,
    metadata,
    weight: eventConfig.weight,
    createdAt: new Date()
  });

  // Check if this completes activation
  if (eventConfig.milestone) {
    await checkActivationComplete(userId);
  }

  // Analytics
  await analytics.track(userId, 'activation_event', { event, ...metadata });
}

// Check if user is "activated"
async function checkActivationComplete(userId: string) {
  const events = await db.query.activationEvents.findMany({
    where: eq(activationEvents.userId, userId)
  });

  const completedMilestones = events
    .filter(e => ACTIVATION_EVENTS[e.event]?.milestone)
    .map(e => e.event);

  // Activated = used core feature (aha moment)
  const isActivated = completedMilestones.includes('used_core_feature');

  if (isActivated) {
    await db.update(users)
      .set({ activatedAt: new Date() })
      .where(eq(users.id, userId));

    // Trigger post-activation flow
    await triggerActivationCelebration(userId);
  }

  return isActivated;
}

// API endpoint for tracking
app.post('/api/track/activation', async (req, res) => {
  const { event, metadata } = req.body;
  await trackActivation(req.userId, event, metadata);
  res.json({ success: true });
});
```

### Contextual Tooltips

**When to use**: Highlight features as users navigate the app

**Implementation**: Show tooltips on first visit to features.

```tsx
// Tooltip state hook
function useFeatureTooltip(featureId: string) {
  const [dismissed, setDismissed] = useState(false);

  useEffect(() => {
    const seenFeatures = JSON.parse(
      localStorage.getItem('seen_features') || '[]'
    );
    if (seenFeatures.includes(featureId)) {
      setDismissed(true);
    }
  }, [featureId]);

  const dismiss = useCallback(() => {
    const seenFeatures = JSON.parse(
      localStorage.getItem('seen_features') || '[]'
    );
    localStorage.setItem(
      'seen_features',
      JSON.stringify([...seenFeatures, featureId])
    );
    setDismissed(true);

    // Track feature discovery
    fetch('/api/track/activation', {
      method: 'POST',
      body: JSON.stringify({ event: 'discovered_feature', metadata: { featureId } })
    });
  }, [featureId]);

  return { show: !dismissed, dismiss };
}

// Feature tooltip component
function FeatureTooltip({ featureId, title, description, children }) {
  const { show, dismiss } = useFeatureTooltip(featureId);

  if (!show) return children;

  return (
    <div className="relative">
      {children}
      <div className="absolute top-full left-0 mt-2 p-4 bg-blue-600 text-white rounded-lg shadow-lg z-50 w-64">
        <button onClick={dismiss} className="absolute top-2 right-2 text-white/60">×</button>
        <h4 className="font-semibold mb-1">{title}</h4>
        <p className="text-sm text-white/80">{description}</p>
        <button onClick={dismiss} className="mt-3 text-sm font-medium">Got it</button>
      </div>
    </div>
  );
}

// Usage
<FeatureTooltip
  featureId="analytics-dashboard"
  title="Your Analytics Dashboard"
  description="Track your key metrics here. Click any chart to dive deeper."
>
  <AnalyticsDashboard />
</FeatureTooltip>
```

## Stack Implementations

### {{stack.frontend.framework}} Integration

**Route Protection**:
```typescript
// Middleware to redirect incomplete onboarding
export async function middleware(request: NextRequest) {
  const session = await getSession(request);
  if (!session) return NextResponse.redirect('/login');

  const onboarding = await getOnboardingStatus(session.userId);

  // Redirect to onboarding if incomplete (except for onboarding routes)
  if (!onboarding.isComplete && !onboarding.isSkipped) {
    if (!request.nextUrl.pathname.startsWith('/onboarding')) {
      return NextResponse.redirect('/onboarding');
    }
  }

  return NextResponse.next();
}
```

## Quality Checklist

- [ ] Onboarding state persisted to database
- [ ] Progress visible to user at all times
- [ ] Skip option available (but discouraged)
- [ ] Steps can be resumed after browser close
- [ ] Different flows for different user types
- [ ] Activation events tracked to analytics
- [ ] Time-to-activation measured
- [ ] Re-engagement emails for incomplete onboarding
- [ ] Mobile-friendly wizard design
- [ ] A/B testing hooks for optimization

## Anti-Patterns

### Forcing All Steps
```typescript
// WRONG: No way to skip
const steps = [
  { id: 'profile', required: true },
  { id: 'connect_calendar', required: true }, // Not everyone uses calendars!
];

// RIGHT: Core steps required, extras optional
const steps = [
  { id: 'profile', required: true },
  { id: 'connect_calendar', required: false },
];
```

### Blocking App Access
```typescript
// WRONG: Can't use app until all steps done
if (!onboarding.isComplete) return <OnboardingWizard />;

// RIGHT: Allow exploration with gentle nudges
if (!onboarding.isComplete && !onboarding.isSkipped) {
  return <OnboardingWithExitOption onSkip={skipOnboarding} />;
}
```
