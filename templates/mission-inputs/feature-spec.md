# Feature Specification: Advanced Search with Filters

## Feature Overview

### Feature Name
Advanced Search and Filtering System

### Feature Type
- [x] **New Feature** - Adding net-new capability
- [ ] **Enhancement** - Improving existing feature
- [ ] **Refactor** - Improving code without changing behavior
- [ ] **Integration** - Connecting with external service

### Business Justification
**Problem**: Users spend 15+ minutes finding specific tasks in large projects (500+ tasks). Current search only matches task titles, missing descriptions, comments, assignees, and tags. Users report this as #2 pain point (after real-time notifications).

**Solution**: Comprehensive search with filters (status, assignee, tags, date range, priority) and smart results ranking (recently updated, exact matches, relevance score).

**Impact**:
- **Time savings**: Reduce search time from 15 min to 30 seconds (97% improvement)
- **User satisfaction**: Address #2 user complaint (mentioned in 87 support tickets)
- **Competitive parity**: Match Asana, Monday.com, and Linear search capabilities
- **Revenue impact**: Prevent churn of 5 enterprise customers threatening to leave over search limitations

**Success Metrics**:
- 80% of searches return relevant results in top 5 results
- Average search completion time <30 seconds
- 50% reduction in "can't find my task" support tickets

## User Stories & Use Cases

### Primary User Story
**As a** project manager with 500+ tasks across multiple projects
**I want** to search for tasks using multiple criteria (assignee, status, tags, date range)
**So that** I can quickly find specific tasks without manually scrolling through hundreds of items

**Acceptance Criteria:**
- [ ] Search bar accepts text queries up to 500 characters
- [ ] Search returns results within 500ms for projects with <1000 tasks
- [ ] Results highlight matched text (task title, description, comments)
- [ ] Can filter by: status (any/todo/in-progress/done), assignee (single or multiple), priority (P0-P3)
- [ ] Can filter by tags (AND/OR logic: "must have tag X AND Y" or "has tag X OR Y")
- [ ] Can filter by date range (created date, due date, last updated)
- [ ] Filters are additive (all must match)
- [ ] "No results" state shows helpful suggestions ("Try: remove filters, check spelling, search different project")

### Secondary User Story
**As a** team member searching for my assigned tasks
**I want** saved filter presets (e.g., "My P0 tasks due this week")
**So that** I can quickly access common searches without recreating filters each time

**Acceptance Criteria:**
- [ ] Can save current filter combination as preset with custom name
- [ ] Can save up to 10 presets per user
- [ ] Presets show in dropdown menu for quick access
- [ ] Clicking preset applies all filters instantly
- [ ] Can edit preset name and filters
- [ ] Can delete presets
- [ ] Presets sync across devices (stored in user account)

### Edge Cases
1. **No results found**: Show clear message with suggestions, don't leave user stranded
2. **Search query too broad**: Return top 100 results, suggest refining filters
3. **Special characters in search**: Handle quotes, wildcards, regex patterns gracefully
4. **Very long task titles**: Truncate in results, show full title in preview
5. **Deleted tasks**: Exclude from search unless "Include archived" filter enabled
6. **Permissions**: Only show tasks user has access to (team members don't see admin tasks)

## Technical Specification

### Architecture Overview
```
┌─────────────┐
│   Frontend  │ React Search Component
│   (Vercel)  │ - SearchBar (input + autocomplete)
│             │ - FilterPanel (status, assignee, tags, dates)
│             │ - ResultsList (infinite scroll)
└──────┬──────┘
       │ HTTP POST /api/search
       ↓
┌─────────────┐
│   Backend   │ Node.js + Express API
│  (Railway)  │ - /api/search endpoint
│             │ - SearchService (query parsing, filters)
│             │ - ElasticsearchClient (if >5000 tasks)
└──────┬──────┘
       │ SQL Query or Elasticsearch Query
       ↓
┌─────────────┐
│  Database   │ PostgreSQL (main data store)
│ (Railway)   │ - tasks table (title, description, status, assignee_id, etc.)
│             │ - task_tags table (many-to-many relationship)
│             │ - Full-text search indexes on title, description
│             │
│             │ OR Elasticsearch (if >5000 tasks per project)
│             │ - tasks index with analyzers for relevance ranking
└─────────────┘
```

### Data Models

#### Search Request Payload
```typescript
interface SearchRequest {
  query: string;                  // User's search text
  filters?: {
    status?: Array<'todo' | 'in_progress' | 'done'>;
    assigneeIds?: number[];       // User IDs
    tags?: {
      operator: 'AND' | 'OR';
      tagIds: number[];
    };
    priority?: Array<'P0' | 'P1' | 'P2' | 'P3'>;
    dateRange?: {
      field: 'created_at' | 'due_date' | 'updated_at';
      from?: string;              // ISO 8601 date
      to?: string;                // ISO 8601 date
    };
    includeArchived?: boolean;    // Default: false
  };
  pagination?: {
    page: number;                 // Default: 1
    limit: number;                // Default: 20, max: 100
  };
  projectId: number;              // Required: limit search to project
}
```

#### Search Response Payload
```typescript
interface SearchResponse {
  results: Array<{
    taskId: number;
    title: string;
    description: string;          // Truncated to 200 chars
    status: 'todo' | 'in_progress' | 'done';
    assignee: {
      id: number;
      name: string;
      avatarUrl: string;
    } | null;
    priority: 'P0' | 'P1' | 'P2' | 'P3';
    tags: Array<{ id: number; name: string; color: string }>;
    createdAt: string;            // ISO 8601
    updatedAt: string;            // ISO 8601
    dueDate: string | null;       // ISO 8601
    matchedFields: Array<'title' | 'description' | 'comments'>; // Where query matched
    highlightedTitle: string;     // Title with <mark> tags around matches
    relevanceScore: number;       // 0-100, for ranking
  }>;
  pagination: {
    page: number;
    limit: number;
    totalResults: number;
    totalPages: number;
    hasNext: boolean;
    hasPrevious: boolean;
  };
  searchMetadata: {
    queryProcessingTime: number;  // milliseconds
    suggestions?: string[];       // Alternative queries if no results
  };
}
```

### API Endpoints

#### POST /api/search
**Description**: Search tasks with filters
**Authentication**: Required (JWT token)
**Rate Limit**: 100 requests per minute per user

**Request Body**:
```json
{
  "query": "authentication bug",
  "filters": {
    "status": ["todo", "in_progress"],
    "assigneeIds": [123, 456],
    "tags": {
      "operator": "AND",
      "tagIds": [10, 20]
    },
    "priority": ["P0", "P1"],
    "dateRange": {
      "field": "due_date",
      "from": "2025-10-01",
      "to": "2025-10-31"
    }
  },
  "pagination": {
    "page": 1,
    "limit": 20
  },
  "projectId": 42
}
```

**Response (200 OK)**:
```json
{
  "results": [
    {
      "taskId": 789,
      "title": "Fix authentication token expiry bug",
      "description": "Users are experiencing authentication issues after 60 minutes...",
      "status": "in_progress",
      "assignee": {
        "id": 123,
        "name": "Jane Developer",
        "avatarUrl": "https://cdn.example.com/avatars/jane.jpg"
      },
      "priority": "P0",
      "tags": [
        { "id": 10, "name": "bug", "color": "#FF4444" },
        { "id": 20, "name": "security", "color": "#FF8800" }
      ],
      "createdAt": "2025-10-15T10:30:00Z",
      "updatedAt": "2025-10-18T14:22:00Z",
      "dueDate": "2025-10-20T23:59:59Z",
      "matchedFields": ["title", "description"],
      "highlightedTitle": "Fix <mark>authentication</mark> token expiry <mark>bug</mark>",
      "relevanceScore": 95
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "totalResults": 37,
    "totalPages": 2,
    "hasNext": true,
    "hasPrevious": false
  },
  "searchMetadata": {
    "queryProcessingTime": 247
  }
}
```

**Error Responses**:
- **400 Bad Request**: Invalid query format, filters, or pagination params
- **401 Unauthorized**: Missing or invalid JWT token
- **403 Forbidden**: User doesn't have access to specified project
- **429 Too Many Requests**: Exceeded rate limit (100/minute)
- **500 Internal Server Error**: Database or search service unavailable

### Database Schema Changes

#### Add Full-Text Search Indexes (PostgreSQL)
```sql
-- Add GIN index for full-text search on title and description
CREATE INDEX idx_tasks_fulltext_search ON tasks
USING gin(to_tsvector('english', title || ' ' || description));

-- Add index for common filter combinations
CREATE INDEX idx_tasks_filters ON tasks (project_id, status, assignee_id, priority, due_date);

-- Add index for date range queries
CREATE INDEX idx_tasks_dates ON tasks (created_at, updated_at, due_date);
```

#### Search Analytics Table (Track search queries for optimization)
```sql
CREATE TABLE search_analytics (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id),
  project_id INTEGER NOT NULL REFERENCES projects(id),
  query TEXT NOT NULL,
  filters JSONB,
  results_count INTEGER NOT NULL,
  query_time_ms INTEGER NOT NULL,
  clicked_result_id INTEGER REFERENCES tasks(id),  -- Which result user clicked
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_search_analytics_queries ON search_analytics (query);
CREATE INDEX idx_search_analytics_user ON search_analytics (user_id, created_at);
```

### Frontend Components

#### SearchBar Component
```typescript
interface SearchBarProps {
  placeholder?: string;
  onSearch: (query: string) => void;
  autoFocus?: boolean;
  showShortcuts?: boolean;  // Show keyboard shortcuts (Cmd+K to focus)
}

// Features:
// - Debounced input (300ms) to avoid excessive API calls
// - Autocomplete suggestions based on recent searches
// - Keyboard shortcuts (Cmd+K or Ctrl+K to focus)
// - Clear button to reset query
// - Loading indicator during search
```

#### FilterPanel Component
```typescript
interface FilterPanelProps {
  filters: SearchFilters;
  onFiltersChange: (filters: SearchFilters) => void;
  availableTags: Tag[];
  availableAssignees: User[];
  projectId: number;
}

// Features:
// - Collapsible sections (Status, Assignee, Tags, Priority, Dates)
// - Multi-select dropdowns (Ctrl+Click for multiple assignees/tags)
// - Date range picker with presets ("Last 7 days", "This month", "Custom")
// - Active filter badges (show count: "3 filters active")
// - Clear all filters button
// - Save as preset button
```

#### ResultsList Component
```typescript
interface ResultsListProps {
  results: SearchResult[];
  loading: boolean;
  onResultClick: (taskId: number) => void;
  onLoadMore: () => void;
  hasMore: boolean;
}

// Features:
// - Infinite scroll (load more as user scrolls)
// - Highlighted search terms in results
// - Result preview with truncated description
// - Metadata display (assignee, tags, due date)
// - Empty state with helpful suggestions
// - Loading skeleton for smooth UX
```

### Performance Optimization

#### Caching Strategy
- **Client-side cache**: Store last 10 search queries + results in React state (5-minute TTL)
- **Server-side cache**: Redis cache for common searches (15-minute TTL)
  - Cache key format: `search:{projectId}:{query}:{filtersHash}`
  - Invalidate cache when tasks created/updated/deleted in project
- **Database query optimization**: Use prepared statements, limit subqueries

#### Search Algorithm
For **PostgreSQL** (projects with <5000 tasks):
1. Use `ts_query` for full-text search on title + description
2. Rank results by:
   - Exact title match (100 points)
   - Title contains query (80 points)
   - Description contains query (50 points)
   - Recently updated (10 points per day within last week)
3. Apply filters with indexed columns (status, assignee, priority, dates)
4. Limit to 100 results per query

For **Elasticsearch** (projects with >5000 tasks):
1. Use multi-match query with field boosting:
   - title^3 (3x weight)
   - description^1 (1x weight)
   - comments^0.5 (0.5x weight)
2. Apply filters as Elasticsearch filters (status, assignee, etc.)
3. Use Elasticsearch relevance scoring with decay function for recency
4. Limit to 100 results per query

**When to use Elasticsearch**: Projects with >5000 tasks or search latency >500ms

### Security Considerations

#### Input Validation
- **SQL Injection Prevention**: Use parameterized queries, never concatenate user input
- **XSS Prevention**: Sanitize search query before displaying highlighted results
- **NoSQL Injection**: Validate filter values against allowed enums (status, priority)
- **Query Length Limit**: Max 500 characters to prevent DoS via long queries

#### Authorization
- **Project Access**: Verify user has read access to project before searching
- **Task Visibility**: Only return tasks user has permission to view (no admin-only tasks for regular users)
- **Rate Limiting**: Max 100 searches per minute per user to prevent abuse

#### Data Privacy
- **Audit Logging**: Log all searches (user, query, timestamp) for security audits
- **PII Protection**: Don't log sensitive task content in search analytics
- **Compliance**: Ensure search respects data retention policies (don't search archived projects beyond retention period)

## User Interface Design

### Search Experience Flow

**Step 1: User opens search**
- Press `Cmd+K` (Mac) or `Ctrl+K` (Windows/Linux) to open search modal
- Modal overlays current page, dims background
- Search bar auto-focused, cursor ready to type

**Step 2: User enters query**
- Type "authentication bug"
- As user types, show autocomplete suggestions from recent searches
- Debounce input (300ms) to avoid excessive API calls
- Show loading indicator in search bar

**Step 3: Results appear**
- Display results within 500ms
- Show top 20 results (infinite scroll for more)
- Highlight matched terms in task titles
- Show result metadata: assignee avatar, tags, due date
- Display result count: "37 results found in 247ms"

**Step 4: User applies filters**
- Click "Filters" button to expand filter panel
- Select "Status: In Progress, To Do"
- Select "Assignee: Jane Developer"
- Select "Priority: P0, P1"
- Results update immediately (live filtering)
- Active filters shown as badges: "3 filters active"

**Step 5: User saves preset**
- Click "Save as preset" button
- Enter preset name: "My P0 bugs"
- Preset appears in dropdown menu
- Next time, click "My P0 bugs" preset → instant results

**Step 6: User clicks result**
- Click task from results list
- Task details modal opens
- Search modal remains in background (can return to results)
- Task title in results list shows "visited" state (purple color)

### Visual Design Specs

#### Search Modal
- **Dimensions**: 800px wide × 600px tall (centered on screen)
- **Background**: White with subtle shadow, rounded corners (8px border-radius)
- **Search Bar**:
  - Height: 50px
  - Font: 16px Inter (400 weight)
  - Placeholder: "Search tasks... (Cmd+K)"
  - Icon: Magnifying glass (left side), clear X button (right side)
- **Results List**:
  - Max height: 400px (scrollable)
  - Each result: 80px height, white background, hover state (light gray)
  - Result title: 18px Inter (500 weight), truncate after 2 lines
  - Result description: 14px Inter (400 weight), truncate after 2 lines, gray color
- **Filter Panel**:
  - Slide in from right side (300ms animation)
  - Width: 320px
  - Background: Light gray (#F5F5F5)

#### Mobile Responsiveness
- **Phones (<640px)**: Full-screen search modal, filters as bottom sheet
- **Tablets (640-1024px)**: 90% screen width, filters collapse by default
- **Desktops (>1024px)**: Fixed 800px width, filters expand inline

### Accessibility (WCAG AA Compliance)

- **Keyboard Navigation**:
  - `Tab` to move between search bar, filters, results
  - `Arrow keys` to navigate results list
  - `Enter` to open selected result
  - `Esc` to close search modal
- **Screen Reader Support**:
  - ARIA labels on all interactive elements
  - Live region announces result count: "37 results found"
  - Focus management (focus returns to trigger button when modal closes)
- **Contrast Ratios**:
  - Text on background: 4.5:1 minimum (AA standard)
  - Interactive elements: 3:1 minimum
- **Focus Indicators**: 2px blue outline on focused elements

## Testing Requirements

### Unit Tests
- **SearchService**: Query parsing, filter building, result ranking
- **SearchController**: Request validation, authorization checks, error handling
- **SearchBar Component**: Debouncing, autocomplete, keyboard shortcuts
- **FilterPanel Component**: Filter selection, state management, presets

**Target Coverage**: 90%+ for search logic

### Integration Tests
1. **Search without filters**: Query returns expected results
2. **Search with status filter**: Only tasks with matching status returned
3. **Search with multiple filters**: All filters applied correctly (AND logic)
4. **Search with saved preset**: Preset applies correct filters
5. **Search with invalid query**: Returns 400 error with helpful message
6. **Search without authorization**: Returns 403 error
7. **Search on archived project**: Returns empty results (unless includeArchived=true)

### Performance Tests
1. **Load test**: 100 concurrent users searching simultaneously
   - **Target**: <500ms p95 latency, no errors
2. **Stress test**: 1000 searches per minute
   - **Target**: Rate limiting triggers at 100/min per user, no crashes
3. **Large dataset test**: Search project with 10,000 tasks
   - **Target**: <1 second latency, accurate results

### User Acceptance Testing
**Beta Test Plan**:
- **Participants**: 10 internal users, 10 customer beta testers
- **Duration**: 1 week
- **Scenarios**:
  1. Find a specific task by title
  2. Find all tasks assigned to you with P0 priority
  3. Find tasks with specific tag created last week
  4. Save a preset and use it to search again
  5. Search on mobile device
- **Success Criteria**: 80%+ users report "very satisfied" or "satisfied"

## Deployment Plan

### Rollout Strategy
**Phase 1: Internal Beta (Week 1)**
- Deploy to staging environment
- Enable for internal team only (20 users)
- Monitor search latency, error rates
- Collect feedback on UX

**Phase 2: Customer Beta (Week 2)**
- Deploy to production with feature flag
- Enable for 10 beta customer accounts
- Monitor usage metrics: searches per user, filter usage, preset creation
- Iterate on feedback

**Phase 3: Gradual Rollout (Week 3-4)**
- Enable for 10% of users (Week 3)
- Monitor for 3 days, check metrics
- Enable for 50% of users (Week 4)
- Monitor for 3 days, check metrics
- Enable for 100% of users (Week 4 end)

### Rollback Plan
**Criteria for rollback**:
- Search error rate >5% (normal: <0.5%)
- Search latency >2 seconds p95 (normal: <500ms)
- Critical bugs reported by >10 users

**Rollback procedure** (15 minutes):
1. Disable feature flag in production
2. Users see old search UI (simple text search)
3. Investigate root cause in staging
4. Fix issue, re-test, re-deploy

### Monitoring & Alerts

**Metrics to Track**:
- **Search latency**: p50, p95, p99 (target: p95 <500ms)
- **Search error rate**: % of failed searches (target: <0.5%)
- **Search usage**: Searches per user per day (expected: 10-15)
- **Filter usage**: % of searches using filters (target: >40%)
- **Preset usage**: % of users creating presets (target: >20%)
- **Result relevance**: % of searches where user clicks a result (target: >60%)

**Alerts**:
- **Critical**: Search error rate >5% (page on-call engineer)
- **Critical**: Search latency >2 seconds p95 (page on-call engineer)
- **Warning**: Search usage drops >30% day-over-day (notify PM)
- **Warning**: Elasticsearch cluster CPU >80% (notify DevOps)

**Dashboards**:
- Real-time search metrics (Datadog or Grafana)
- Search analytics (query frequency, popular filters, top searches)
- User engagement (searches per user, preset usage, CTR on results)

## Dependencies & Risks

### Technical Dependencies
1. **PostgreSQL full-text search** (for <5000 tasks)
   - Dependency: PostgreSQL 14+ with GIN indexes
   - Risk: Slow queries on large datasets → **Mitigation**: Benchmark with 10k tasks, have Elasticsearch ready
2. **Elasticsearch** (for >5000 tasks, optional)
   - Dependency: Elasticsearch 8.x cluster (Railway addon: $50/month)
   - Risk: Additional infrastructure cost → **Mitigation**: Only enable for large projects
3. **Redis caching** (for performance)
   - Dependency: Redis 7+ instance (already in use for other features)
   - Risk: Cache invalidation bugs → **Mitigation**: Conservative TTL (15 minutes), monitor cache hit rate

### Project Risks

**Risk 1: Search relevance not good enough**
- **Impact**: Users frustrated by irrelevant results
- **Probability**: Medium (40%)
- **Mitigation**: Beta test with real users, iterate on ranking algorithm, add feedback mechanism ("Was this result helpful?")
- **Contingency**: Allow users to switch to "simple search" mode (exact match only)

**Risk 2: Performance issues at scale**
- **Impact**: Slow searches lead to poor UX
- **Probability**: Medium (30%)
- **Mitigation**: Load test with 10k tasks, have Elasticsearch ready as fallback, implement aggressive caching
- **Contingency**: Limit search to title-only for large projects, add "advanced search" opt-in

**Risk 3: Low adoption (users don't use filters)**
- **Impact**: Feature underutilized
- **Probability**: Low (20%)
- **Mitigation**: Strong onboarding (show filter benefits), default to useful filters (e.g., "My tasks"), track usage and iterate
- **Contingency**: Simplify filter UI based on usage patterns

## Success Criteria & Acceptance

### Definition of Done
- [x] All acceptance criteria met for primary and secondary user stories
- [ ] Unit test coverage >90% for search logic
- [ ] Integration tests pass (all search scenarios)
- [ ] Performance tests pass (latency <500ms p95)
- [ ] Security review completed (no vulnerabilities)
- [ ] Beta testing completed (>80% satisfaction)
- [ ] Documentation complete (API docs, user guide)
- [ ] Monitoring and alerts configured
- [ ] Rollback plan tested in staging

### Launch Criteria
- [ ] Feature flag ready for gradual rollout
- [ ] All P0/P1 bugs resolved
- [ ] Load testing passed (100 concurrent users)
- [ ] Mobile responsiveness validated (iOS, Android)
- [ ] Accessibility audit passed (WCAG AA)
- [ ] Search latency <500ms p95 in staging
- [ ] Zero critical bugs in beta testing

### Post-Launch Success Metrics (30 days)
- [ ] **Adoption**: 70%+ of users perform at least 1 search
- [ ] **Engagement**: Average 10-15 searches per user per day
- [ ] **Performance**: Search latency <500ms p95
- [ ] **Relevance**: 60%+ of searches result in user clicking a result
- [ ] **Support reduction**: 50%+ fewer "can't find task" tickets

---

## 🚀 Ready to Build This Feature?

**Save this file and run:**
```bash
/coord build feature-spec.md
```

**Expected timeline:** 3-4 weeks (2 weeks dev + 1 week QA + 1 week beta)
**Estimated cost:** $15,000 development + $50/month infrastructure (if using Elasticsearch)

**What will happen:**
1. @strategist analyzes feature spec → breaks down into tasks
2. @architect designs search architecture → database indexes, caching strategy, Elasticsearch vs PostgreSQL decision
3. @developer implements search → backend API, frontend UI, filters, presets
4. @tester validates quality → unit tests, integration tests, performance tests, accessibility audit
5. @operator deploys gradually → 10% → 50% → 100% rollout with monitoring

**Deliverables:**
- Advanced search with filters (status, assignee, tags, priority, dates)
- Saved filter presets
- Search analytics tracking
- Mobile-responsive UI
- Accessibility compliant (WCAG AA)
- Complete test suite (90%+ coverage)
- API documentation
- User guide with screenshots
- Monitoring dashboard
- Rollback plan (tested)
