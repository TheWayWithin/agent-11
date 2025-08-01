# Field Notes

- Correlation isn't causation, but it's a good start
- Focus on metrics you can actually influence
- Cohort analysis reveals truth over time
- Small sample sizes lie - wait for significance
- The best metric is the one that changes behavior

## Sample Output Format

### Growth Report
```markdown
# Weekly Growth Report - Week of Jan 8, 2024

## Executive Summary
**Growth Rate**: +12% WoW (accelerating)
**Key Win**: New onboarding flow increased activation by 23%
**Concern**: Churn increasing in Starter plan (action needed)

## Key Metrics

### Acquisition
- New Users: 324 (+12% WoW)
- Top Source: Organic search (42%)
- CAC: $45 (-10% improvement)
- Best Channel: Content marketing ($25 CAC)

### Activation (First Value)
- Rate: 67% (+23% after onboarding update)
- Time to Activate: 3.2 hours (-45%)
- Key Action: Creating first project

### Revenue
- MRR: $24,500 (+15% WoW)
- ARPU: $75 (stable)
- LTV:CAC: 3.2:1 (healthy)

### Retention
- 30-day: 78% (good)
- 90-day: 45% (concerning - down from 52%)
- Churn Reason #1: "Too expensive for features offered"

## Insights & Actions

1. **Double Down on Content**
   - Lowest CAC channel
   - Highest quality users (85% retention)
   - Action: Increase content production 2x

2. **Fix Starter Plan Churn**
   - 65% cite price/value mismatch
   - Action: Add more value or adjust pricing
   - Test: Usage-based pricing model

3. **Optimize Activation Flow**
   - New flow working well
   - Action: A/B test progress indicators
   - Target: 75% activation rate

## Cohort Analysis
```
| Cohort | Users | Day 1 | Day 7 | Day 30 | Day 90 |
|--------|-------|-------|-------|--------|--------|
| Oct    | 250   | 58%   | 42%   | 38%    | 35%    |
| Nov    | 287   | 62%   | 48%   | 42%    | 39%    |
| Dec    | 312   | 67%   | 55%   | 48%    | 45%    |
| Jan    | 324   | 71%   | 62%   | TBD    | TBD    |
```

## Next Week Focus
1. Launch pricing page A/B test
2. Implement deeper funnel tracking
3. Survey churned users
4. Analyze feature usage vs retention
```

### Dashboard Schema
```yaml
# Real-time Dashboard Configuration

overview:
  - metric: "Active Users"
    query: "COUNT(DISTINCT user_id) WHERE last_seen > NOW() - INTERVAL 5 MINUTE"
    display: number
    trend: true
    
  - metric: "MRR"
    query: "SUM(subscription_amount) WHERE status = 'active'"
    display: currency
    trend: true
    
  - metric: "Conversion Rate"
    query: "COUNT(paid) / COUNT(signups) * 100"
    display: percentage
    trend: true

charts:
  - title: "User Growth"
    type: line
    metrics: ["new_users", "active_users", "paying_users"]
    period: 30_days
    
  - title: "Revenue Breakdown"
    type: donut
    segments: ["Starter", "Pro", "Enterprise"]
    
  - title: "Feature Adoption"
    type: bar
    features: ["Feature A", "Feature B", "Feature C"]
    metric: usage_percentage
```

## Analytics Stack

### Essential Tools (Free/Cheap)
1. **Google Analytics 4**: General analytics
2. **Hotjar**: User behavior recording
3. **Mixpanel**: Product analytics (generous free tier)
4. **Google Sheets**: Custom analysis

### Tracking Plan
```javascript
// User Events
analytics.track('Signed Up', {
  source: 'organic',
  referrer: document.referrer,
  plan: 'free'
});

analytics.track('Feature Used', {
  feature: 'export_data',
  success: true,
  duration_ms: 1234
});

analytics.track('Subscription Started', {
  plan: 'pro',
  interval: 'monthly',
  amount: 49,
  trial: false
});