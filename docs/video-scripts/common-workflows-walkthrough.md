# Video Script: Common Workflows Walkthrough

**Duration**: 15 minutes
**Target Audience**: Users ready to apply AGENT-11 to real projects
**Purpose**: Demonstrate bug fixes, feature development, and design reviews
**Tone**: Practical, experienced, helpful

---

## Opening (45 seconds)

### [00:00] Title Screen
**[SCREEN: "Common Workflows with AGENT-11"]**

**Narration:**
"You've installed AGENT-11 and completed your first mission. Now let's explore the three most common workflows you'll use day-to-day: fixing bugs, building new features, and reviewing designs. These are the workflows that will make up 80% of your development work."

**[ON-SCREEN TEXT:]**
Today's Workflows:
1. Bug Fix (3 min) - Quick issue resolution
2. Feature Development (5 min) - Structured feature building
3. Design Review (4 min) - UI/UX audit and improvement

**[SCREEN: Show mission library]**

**Narration:**
"Each workflow uses AGENT-11's mission system to orchestrate multiple agents. We'll see exactly what happens at each step, what you'll get, and how to handle common issues."

---

## Workflow 1: Bug Fixes (4 minutes)

### [00:45] The Bug Fix Workflow
**[SCREEN: Terminal with project open]**

**Narration:**
"Let's start with the most common scenario - you found a bug and need to fix it fast. AGENT-11 has a mission specifically for this called `mission-fix`."

### [01:00] Creating a Bug Report
**[SCREEN: Text editor with bug-report.md]**

**Narration:**
"First, document the bug. Create a simple bug report file - I'll call this `bug-task-assignment.md`."

**[TYPE in editor:]**
```markdown
# Bug Report: Task Assignment Not Saving

## Description
When assigning a task to a user, the assignment doesn't persist
after page refresh. The task reverts to "unassigned" state.

## Steps to Reproduce
1. Open task detail page (any task)
2. Click "Assign to" dropdown
3. Select a team member
4. Click "Save"
5. Refresh the page
6. Bug: Assignment is lost, task shows as unassigned

## Expected Behavior
Task should remain assigned to the selected team member after
page refresh. Assignment should persist in database.

## Actual Behavior
Task shows as unassigned after refresh. Assignment is lost.

## Environment
- Browser: Chrome 118
- OS: macOS Sonoma
- User role: Project Admin
- Database: PostgreSQL 15

## Impact
- High priority: Breaks core functionality
- Affects: All users trying to assign tasks
- Workaround: None currently available
```

**[SCREEN: Save file]**

**[ON-SCREEN TEXT:]**
Good Bug Reports Include:
✅ Clear description
✅ Reproduction steps
✅ Expected vs actual behavior
✅ Environment details
✅ Impact assessment

**Narration:**
"The more specific your bug report, the faster your agents can diagnose and fix. Think of it like explaining the problem to a junior developer."

### [02:00] Running the Fix Mission
**[SCREEN: Terminal]**

**Narration:**
"Now let's run the fix mission."

**[TYPE: `/coord fix bug-task-assignment.md`]**
**[PRESS: Enter]**

**[SCREEN: Show coordinator starting]**

**Narration:**
"The coordinator reads your bug report and creates a fix plan. Let's watch what happens."

**[SCREEN: Show tester being delegated to first]**

**Narration:**
"Interestingly, the coordinator starts with the tester, not the developer. Why? Because we need to reproduce the bug first and create a failing test."

**[SCREEN: Show tester analyzing bug report]**

**Narration:**
"The tester creates a test case that reproduces the bug. This serves two purposes: it confirms the bug exists, and it prevents regression after we fix it."

**[SCREEN: Show test file creation]**
```typescript
// backend/__tests__/routes/tasks.test.ts

describe('Task Assignment', () => {
  it('should persist task assignment after save', async () => {
    const task = await createTask({ title: 'Test Task' });
    const user = await createUser({ email: 'test@example.com' });

    // Assign task to user
    const response = await request(app)
      .patch(`/api/tasks/${task.id}`)
      .send({ assignee_id: user.id });

    expect(response.status).toBe(200);

    // Fetch task again to verify persistence
    const fetchedTask = await request(app)
      .get(`/api/tasks/${task.id}`);

    expect(fetchedTask.body.assignee_id).toBe(user.id); // ❌ This will fail
  });
});
```

**[SCREEN: Show test running and failing]**
```
FAIL backend/__tests__/routes/tasks.test.ts
  Task Assignment
    ✕ should persist task assignment after save (45 ms)

Expected: "user-123"
Received: null
```

**[HIGHLIGHT: Test failure]**

**Narration:**
"Perfect. The test confirms the bug. Now the tester updates handoff notes for the developer with the root cause hypothesis."

### [03:00] Developer Fixes the Bug
**[SCREEN: Show developer reading handoff notes and test]**

**Narration:**
"The developer reviews the failing test and investigates the code. They discover the issue - the API endpoint isn't saving the assignee_id to the database."

**[SCREEN: Show problematic code]**
```typescript
// backend/src/routes/tasks.ts (BEFORE)

router.patch('/api/tasks/:id', async (req, res) => {
  const { title, description, status, priority } = req.body;
  // ❌ BUG: assignee_id not extracted from req.body

  const updated = await db.query(
    'UPDATE tasks SET title = $1, description = $2, status = $3 WHERE id = $4',
    [title, description, status, req.params.id]
    // ❌ BUG: assignee_id not included in UPDATE
  );

  res.json(updated.rows[0]);
});
```

**[SCREEN: Show developer fixing code]**
```typescript
// backend/src/routes/tasks.ts (AFTER)

router.patch('/api/tasks/:id', async (req, res) => {
  const { title, description, status, priority, assignee_id } = req.body;
  // ✅ FIX: Extract assignee_id from request body

  const updated = await db.query(
    'UPDATE tasks SET title = $1, description = $2, status = $3, assignee_id = $4 WHERE id = $5',
    [title, description, status, assignee_id, req.params.id]
    // ✅ FIX: Include assignee_id in UPDATE query
  );

  res.json(updated.rows[0]);
});
```

**[SCREEN: Show test re-running and passing]**
```
PASS backend/__tests__/routes/tasks.test.ts
  Task Assignment
    ✓ should persist task assignment after save (38 ms)
```

**[HIGHLIGHT: Green checkmark]**

**Narration:**
"The fix is in! The test now passes. The developer also adds the fix to progress.md so you have a record of what was changed and why."

### [03:45] Deliverables
**[SCREEN: Show files created/modified]**

**[ON-SCREEN TEXT:]**
Bug Fix Deliverables:
✅ Failing test created (confirms bug)
✅ Root cause identified (missing field in UPDATE)
✅ Code fixed (assignee_id now saved)
✅ Test passing (prevents regression)
✅ Progress log updated (documents fix)

**Narration:**
"Total time: 1-2 hours. Much faster than debugging alone because the tester handles reproduction and the developer focuses only on the fix."

---

## Workflow 2: Feature Development (5 minutes 30 seconds)

### [04:30] The Build Workflow
**[SCREEN: Terminal ready]**

**Narration:**
"Now let's build a new feature from scratch. We'll add task comments - users can leave comments on tasks to discuss work."

### [04:45] Writing Feature Requirements
**[SCREEN: Text editor with feature-comments.md]**

**Narration:**
"Start with a feature spec. This is more detailed than a bug report - you're describing new functionality."

**[TYPE in editor:]**
```markdown
# Feature: Task Comments

## User Story
As a team member, I want to add comments to tasks so I can discuss
details, ask questions, and provide updates with my team.

## Acceptance Criteria

### Comment Creation
- Users can add text comments to any task
- Comments support markdown formatting
- Comments show author name and timestamp
- Comments appear in chronological order (newest first)

### Comment Display
- Task detail page shows all comments
- Each comment shows: author, timestamp, content
- Author can edit their own comments
- Author can delete their own comments

### Notifications (Future)
- Not included in MVP
- Phase 2: Email notifications when mentioned

## Technical Notes
- Store comments in `task_comments` table
- Link to `tasks` table via foreign key
- Author field links to `users` table
- Support markdown rendering in frontend
- Real-time updates not required for MVP

## UI/UX Considerations
- Comments section appears below task details
- Simple textarea for comment entry
- "Add Comment" button to submit
- Inline edit mode for existing comments
- Delete confirmation modal for safety
```

**[SCREEN: Save file]**

**Narration:**
"Notice how specific this is. We're clear about what's in MVP and what's future. This helps agents scope the work correctly."

### [05:30] Running the Build Mission
**[SCREEN: Terminal]**

**[TYPE: `/coord build feature-comments.md`]**
**[PRESS: Enter]**

**[SCREEN: Show coordinator creating project plan]**

**Narration:**
"The build mission has four phases: requirements analysis, system design, implementation, and testing. Let's see each phase."

### [06:00] Phase 1: Requirements Analysis
**[SCREEN: Show strategist working]**

**Narration:**
"The strategist reviews your spec and creates detailed user stories with acceptance criteria. They also identify edge cases you might have missed."

**[SCREEN: Show requirements.md update]**
```markdown
## User Stories (Added)

### US-015: Add Comment to Task
As a team member, I want to add comments to tasks,
so I can communicate with my team about task details.

**Acceptance Criteria:**
- Comment text area visible on task detail page
- Markdown syntax supported (bold, italic, links, code blocks)
- Comment saves immediately on "Add Comment" click
- New comment appears at top of comment list
- Author name and timestamp display automatically
- Character limit: 2000 chars (with counter)

**Edge Cases:**
- Empty comment submission blocked (show validation error)
- Very long comments (>2000 chars) rejected with clear message
- Network failure during save (show retry option)
- Deleted user comments show "[deleted user]" as author
```

**[HIGHLIGHT: Edge Cases section]**

**Narration:**
"See those edge cases? The strategist thought through failure modes you might not have considered. This prevents bugs before they happen."

### [07:00] Phase 2: System Design
**[SCREEN: Show architect working]**

**Narration:**
"The architect designs the database schema, API endpoints, and React components needed for comments."

**[SCREEN: Show architecture.md additions]**
```markdown
## Database Schema (Added)

```sql
CREATE TABLE task_comments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  author_id UUID NOT NULL REFERENCES users(id),
  content TEXT NOT NULL CHECK (length(content) <= 2000),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_task_comments_task ON task_comments(task_id);
CREATE INDEX idx_task_comments_created ON task_comments(created_at DESC);
```

## API Endpoints (Added)

**GET /api/tasks/:id/comments**
Returns all comments for a task, ordered by created_at DESC.

**POST /api/tasks/:id/comments**
Creates a new comment. Requires authentication.
Body: `{ content: string }`

**PATCH /api/comments/:id**
Updates a comment. Only author can edit.
Body: `{ content: string }`

**DELETE /api/comments/:id**
Deletes a comment. Only author can delete.
```

**Narration:**
"The architect also designs the React component structure and identifies which existing components can be reused."

### [08:00] Phase 3: Implementation
**[SCREEN: Show developer working]**

**Narration:**
"The developer implements the feature using the architecture design. They create the database migration, API routes, and React components."

**[SCREEN: Show file creation sped up]**
```
Files Created/Modified:
✅ database/migrations/003_add_task_comments.sql
✅ backend/src/routes/comments.ts
✅ backend/src/models/Comment.ts
✅ frontend/src/components/CommentList.tsx
✅ frontend/src/components/CommentForm.tsx
✅ frontend/src/hooks/useComments.ts
```

**[SCREEN: Show key component code]**
```typescript
// frontend/src/components/CommentForm.tsx

export const CommentForm: React.FC<{ taskId: string }> = ({ taskId }) => {
  const [content, setContent] = useState('');
  const { mutate: addComment, isLoading } = useAddComment(taskId);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!content.trim()) return;

    addComment({ content }, {
      onSuccess: () => setContent(''),
      onError: (error) => toast.error('Failed to add comment')
    });
  };

  return (
    <form onSubmit={handleSubmit}>
      <textarea
        value={content}
        onChange={(e) => setContent(e.target.value)}
        placeholder="Add a comment (Markdown supported)..."
        maxLength={2000}
      />
      <div className="flex justify-between">
        <span className="text-sm text-gray-500">
          {content.length}/2000
        </span>
        <button type="submit" disabled={isLoading || !content.trim()}>
          Add Comment
        </button>
      </div>
    </form>
  );
};
```

**[HIGHLIGHT: Character counter and validation]**

**Narration:**
"Notice the developer implemented those edge cases - character counter, empty comment validation, loading states. This comes from the strategist's acceptance criteria."

### [09:00] Phase 4: Testing
**[SCREEN: Show tester working]**

**Narration:**
"Finally, the tester creates comprehensive tests - unit tests for the API, component tests for React, and an end-to-end test for the complete flow."

**[SCREEN: Show test file creation]**
```
Tests Created:
✅ backend/__tests__/routes/comments.test.ts (API tests)
✅ frontend/__tests__/components/CommentForm.test.tsx (Component tests)
✅ e2e/task-comments.spec.ts (E2E test)
```

**[SCREEN: Show E2E test running]**
```typescript
// e2e/task-comments.spec.ts

test('user can add, edit, and delete comments', async ({ page }) => {
  await page.goto('/tasks/task-123');

  // Add comment
  await page.fill('[data-testid="comment-input"]', 'Great work!');
  await page.click('[data-testid="add-comment-btn"]');

  // Verify comment appears
  await expect(page.locator('text=Great work!')).toBeVisible();
  await expect(page.locator('text=just now')).toBeVisible();

  // Edit comment
  await page.click('[data-testid="edit-comment-btn"]');
  await page.fill('[data-testid="comment-input"]', 'Excellent work!');
  await page.click('[data-testid="save-comment-btn"]');

  // Verify edit
  await expect(page.locator('text=Excellent work!')).toBeVisible();

  // Delete comment
  await page.click('[data-testid="delete-comment-btn"]');
  await page.click('[data-testid="confirm-delete-btn"]');

  // Verify deletion
  await expect(page.locator('text=Excellent work!')).not.toBeVisible();
});
```

**[SCREEN: Show all tests passing]**

**Narration:**
"All tests pass. The feature is complete and verified."

### [09:45] Feature Complete
**[SCREEN: Show deliverables summary]**

**[ON-SCREEN TEXT:]**
Feature Development Deliverables:
✅ Detailed requirements with edge cases
✅ Complete system design (DB, API, components)
✅ Database migration script
✅ Backend API routes with validation
✅ React components with hooks
✅ Comprehensive test suite (unit, component, E2E)
✅ Documentation in progress.md

**Narration:**
"Total time: 4-8 hours for a complete feature with tests. Compare this to 2-3 days if you were doing everything solo."

---

## Workflow 3: Design Review (4 minutes)

### [10:00] The Design Review Workflow
**[SCREEN: Browser showing task management app]**

**Narration:**
"Your app is working, but is the design actually good? Let's use AGENT-11's design review workflow to audit the UI and get specific improvement recommendations."

### [10:15] Running Design Review
**[SCREEN: Terminal]**

**Narration:**
"The design review command is special - it uses the designer agent's RECON Protocol to systematically evaluate your UI."

**[TYPE: `/design-review`]**
**[PRESS: Enter]**

**[SCREEN: Show designer starting]**

**Narration:**
"The designer asks for the URL to review. This works on localhost during development or production URLs."

**[TYPE: `http://localhost:3000/tasks`]**
**[PRESS: Enter]**

**[SCREEN: Show browser opening automatically (if Playwright MCP available)]**

**Narration:**
"If you have the Playwright MCP configured, the designer can actually navigate your app and take screenshots. Otherwise, you can provide screenshots manually."

### [10:45] RECON Protocol in Action
**[SCREEN: Show designer analysis output]**

**Narration:**
"The designer uses the RECON Protocol - a systematic UI/UX assessment framework. Let's see the findings."

**[SCREEN: Show design-review-report.md]**
```markdown
# Design Review Report: TaskFlow

**Reviewed**: Task List Page (http://localhost:3000/tasks)
**Date**: 2025-10-20
**Protocol**: RECON (Reconnaissance for Excellence in Digital Operations)

## Executive Summary
Overall Grade: **B- (Good foundation, needs polish)**

**Strengths:**
- Clear information hierarchy
- Functional task actions
- Mobile-responsive layout

**Critical Issues:**
- Low contrast ratios fail WCAG AA
- No loading states on actions
- Inconsistent spacing throughout

## Detailed Findings

### 1. Visual Hierarchy (C+)

**Issues:**
- Task titles use same font weight as descriptions (no differentiation)
- Priority indicators too subtle (small colored dots)
- "Add Task" button not prominent enough (lost in header)

**Recommendations:**
1. Increase task title font weight: 400 → 600
2. Replace priority dots with colored left border (4px wide)
3. Make "Add Task" button primary color with icon

**Impact**: Users struggle to scan tasks quickly. Priority is unclear at a glance.
```

**[SCREEN: Show before/after mockup]**

**Narration:**
"Notice the designer doesn't just say 'improve hierarchy' - they give exact changes: font weight 600, 4px colored border, specific button styling."

**[SCREEN: Continue showing report]**
```markdown
### 2. Accessibility (D)

**Critical Issues:**
❌ Text contrast ratio: 3.2:1 (WCAG requires 4.5:1)
❌ No keyboard navigation for task actions
❌ Form inputs missing aria-labels
❌ Focus indicators barely visible

**Recommendations:**
1. Change text color: #6B7280 → #374151 (achieves 7:1 ratio)
2. Add keyboard shortcuts: Enter to edit, Delete to remove
3. Add aria-labels: "Task title", "Assign to user", etc.
4. Increase focus ring: 1px → 3px with high contrast color

**Impact**: App unusable for keyboard-only users. Difficult for low-vision users.

### 3. User Experience (B)

**Good:**
✅ Task creation flow is simple (2 clicks)
✅ Drag-and-drop reordering works smoothly
✅ Inline editing prevents page navigation

**Issues:**
- No confirmation on task deletion (accidental deletes likely)
- No undo after actions
- Loading states missing (users unsure if action worked)
- Error messages too technical ("Error 500" not helpful)

**Recommendations:**
1. Add delete confirmation modal: "Delete task '[title]'? This cannot be undone."
2. Implement toast notifications with undo: "Task deleted. [Undo]"
3. Show spinner on buttons during API calls: "Saving..."
4. Replace technical errors: "Failed to save. Please try again."

### 4. Mobile Experience (B+)

**Good:**
✅ Responsive layout works down to 320px
✅ Touch targets meet 44x44px minimum
✅ Text remains readable on small screens

**Issues:**
- Dropdown menus difficult to use on mobile (too small)
- Multi-select actions awkward on touch devices
- Horizontal scrolling on very small screens (<350px)

**Recommendations:**
1. Replace dropdowns with bottom sheet on mobile (<768px)
2. Add swipe actions for common tasks (swipe right to complete)
3. Test and fix horizontal scroll on iPhone SE (375px width)
```

**[HIGHLIGHT: Specific pixel values and breakpoints]**

**Narration:**
"Every issue includes specific impact and exact fixes. The designer even gives you WCAG contrast ratios and pixel values."

### [12:30] Implementation Priority
**[SCREEN: Show priority matrix in report]**

**[ON-SCREEN TEXT:]**
```markdown
## Priority Matrix

### Critical (Fix Immediately)
1. Text contrast (accessibility violation)
2. Loading states (users confused)
3. Error messages (poor UX)

### High (Fix This Week)
4. Delete confirmation (prevents accidents)
5. Focus indicators (keyboard accessibility)
6. Priority visual design (usability)

### Medium (Fix This Month)
7. Undo functionality (power user feature)
8. Mobile dropdowns (touch UX improvement)
9. Keyboard shortcuts (efficiency)

### Low (Nice to Have)
10. Additional micro-interactions
11. Advanced animations
12. Dark mode support
```

**Narration:**
"The designer prioritizes fixes by impact. You don't have to fix everything at once - start with critical accessibility issues, then improve UX."

### [13:00] Code-Level Fixes
**[SCREEN: Show designer providing actual code changes]**

**Narration:**
"The best part? The designer gives you the exact code changes for high-priority fixes."

**[SCREEN: Show code examples in report]**
```typescript
// BEFORE (Low Contrast - Fails WCAG)
<p className="text-gray-500">Task description here</p>
// Contrast ratio: 3.2:1 ❌

// AFTER (High Contrast - Passes WCAG AA)
<p className="text-gray-700">Task description here</p>
// Contrast ratio: 7.1:1 ✅

// BEFORE (No Loading State)
<button onClick={handleSave}>Save Task</button>

// AFTER (Clear Loading State)
<button onClick={handleSave} disabled={isLoading}>
  {isLoading ? (
    <><Spinner /> Saving...</>
  ) : (
    'Save Task'
  )}
</button>

// BEFORE (No Delete Confirmation)
<button onClick={() => deleteTask(task.id)}>Delete</button>

// AFTER (Safe Delete with Confirmation)
<button onClick={() => setShowDeleteModal(task.id)}>Delete</button>
{showDeleteModal && (
  <ConfirmModal
    title="Delete task?"
    message={`Delete "${task.title}"? This cannot be undone.`}
    onConfirm={() => deleteTask(showDeleteModal)}
    onCancel={() => setShowDeleteModal(null)}
  />
)}
```

**[HIGHLIGHT: Before/after comparisons]**

**Narration:**
"You can copy-paste these improvements directly. No guesswork needed."

### [13:45] Design Review Complete
**[SCREEN: Show full deliverables]**

**[ON-SCREEN TEXT:]**
Design Review Deliverables:
✅ Complete UI/UX audit (RECON Protocol)
✅ Accessibility violations identified (WCAG compliance)
✅ Prioritized fix list (critical → low priority)
✅ Code-level fixes (copy-paste ready)
✅ Before/after mockups (visual guide)
✅ Impact assessment (why each fix matters)

**Narration:**
"Total time: 1-2 hours for a comprehensive design audit. Now you can improve your UI systematically instead of guessing what users need."

---

## Recovery Protocols (2 minutes)

### [14:00] When Things Go Wrong
**[SCREEN: Terminal with error message]**

**Narration:**
"Let's talk about what to do when missions don't go as planned. AGENT-11 has built-in recovery protocols."

### [14:15] Common Issues and Fixes

**[SCREEN: Show common issue 1]**

**Narration:**
"**Issue 1: Mission produces incorrect output.**"

**[ON-SCREEN TEXT:]**
```
Problem: Architect designed wrong database schema
Solution: Direct feedback to specialist
```

**[TYPE: `@architect The database schema is missing the 'priority' field on tasks. Please add: priority VARCHAR(20) DEFAULT 'medium'`]**

**Narration:**
"Just tell the specialist what's wrong. They'll read the feedback and revise their output."

**[SCREEN: Show common issue 2]**

**Narration:**
"**Issue 2: Tests fail after implementation.**"

**[ON-SCREEN TEXT:]**
```
Problem: Developer's code doesn't pass tests
Solution: Re-run fix mission with test failures as bug report
```

**[TYPE: `/coord fix test-failures.md`]**

**Narration:**
"Treat failing tests like bugs. Create a bug report with the test output and run the fix mission."

**[SCREEN: Show common issue 3]**

**Narration:**
"**Issue 3: Mission interrupted or incomplete.**"

**[ON-SCREEN TEXT:]**
```
Problem: Mission stopped mid-execution
Solution: Check handoff-notes.md and continue manually
```

**[TYPE: `cat handoff-notes.md`]**

**Narration:**
"Handoff notes show exactly where the mission stopped. You can pick up from there by calling the next agent directly."

**[SCREEN: Show example handoff recovery]**
```bash
# handoff-notes.md shows:
# "Strategist completed requirements. Next: @architect for system design"

# Continue manually:
@architect Design the system architecture using requirements.md
```

### [15:00] Getting Unstuck
**[SCREEN: Terminal ready]**

**Narration:**
"If you're really stuck, use the support agent."

**[TYPE: `@support I'm stuck. The build mission created files but my app won't start. Here's the error: [paste error]`]**

**[SCREEN: Show support agent response]**

**Narration:**
"Support will help you diagnose the issue and either fix it or escalate to the right specialist."

---

## Closing (45 seconds)

### [15:15] Wrap Up
**[SCREEN: Summary slide]**

**[ON-SCREEN TEXT:]**
You've Learned:
✅ Bug Fix Workflow - Fast issue resolution with tests
✅ Feature Development - Complete features with architecture
✅ Design Review - Systematic UI/UX improvement
✅ Recovery Protocols - How to handle common issues

**Narration:**
"You now know the three most important workflows in AGENT-11. These will cover 80% of your development work. Bug fixes take 1-2 hours. Features take 4-8 hours. Design reviews take 1-2 hours. All with built-in quality assurance."

**[SCREEN: Next steps]**

**[ON-SCREEN TEXT:]**
What's Next:
- Try: `/coord refactor` for code quality improvements
- Try: `/coord security` for security audits
- Try: `/coord deploy` for production deployment
- Explore: All 20 missions in the mission library

**[SCREEN: AGENT-11 logo]**

**Narration:**
"Now go build amazing products with your elite squad. Happy shipping!"

**[FADE OUT]**

---

## Production Notes

### Visual Cues Reference
- **[SCREEN: ...]** = What's displayed
- **[TYPE: ...]** = Typed command/text
- **[HIGHLIGHT: ...]** = Visual emphasis
- **[ON-SCREEN TEXT:]** = Graphics overlay
- **[PRESS: Enter]** = Keyboard action

### Pacing Strategy
- Bug Fix section: Fast-paced (common task, keep it quick)
- Feature Development: Moderate pace (most complex, needs explanation)
- Design Review: Moderate-fast (visual content is self-explanatory)
- Recovery: Fast (reference material, not tutorial)

### Key Teaching Moments
1. **[02:00]** - Tester-first approach to bug fixing (shows quality focus)
2. **[07:00]** - Architect thinking through edge cases (shows intelligence)
3. **[10:45]** - RECON Protocol systematic approach (shows methodology)
4. **[13:00]** - Code-level fixes from designer (shows practicality)

### Screen Recording Tips
- Speed up file creation sequences (3x speed)
- Slow down code review moments (0.75x speed)
- Use split-screen to show before/after comparisons
- Highlight cursor movements for clarity

### Accessibility Considerations
- Read all code examples aloud (at least function names and key logic)
- Describe visual changes in design section (not just "see this")
- Provide alt text for all graphics
- Use high contrast for all text overlays

### Common User Questions to Address
- "How long do missions actually take?" → Show real-time estimates for each
- "What if the output is wrong?" → Show recovery protocols section
- "Can I customize workflows?" → Mention custom mission creation
- "Do I need all 11 agents?" → Explain core squad vs. full squad

---

## Script Metadata

**Created**: 2025-10-20
**Purpose**: Common workflows walkthrough for active users
**Target**: Users who completed first mission, ready for production use
**Success Metric**: 90%+ can execute all 3 workflows independently
**Dependencies**: Assumes installation and first-mission walkthroughs completed
**Update Frequency**: Review when mission workflows change significantly

---

*This script balances breadth (3 workflows) with depth (enough detail to replicate). Consider creating individual deep-dive videos for each workflow if users want more detail on specific workflows.*
