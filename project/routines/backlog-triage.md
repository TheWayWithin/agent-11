# Routine: Backlog Triage

**Purpose**: Weekly sweep of open issues, recent feedback, and product signals. Produces a prioritised triage list so the human reviewer sees what to act on first.

**Trigger**: Schedule (default: Monday 09:00 weekly, project timezone).

**Where it runs**: Anthropic-managed cloud.

---

## How to set up

1. Open `claude.ai/code/routines` and click **New routine**.
2. **Paste the prompt below** into the prompt field.
3. **Configure the form**:
   - **Repository(ies)**: select the repo(s) the routine should triage. Multi-repo is supported if you want a cross-product view.
   - **Trigger**: Schedule → cron `0 9 * * 1` (Monday 09:00). Adjust timezone.
   - **Connectors**:
     - **GitHub** — required for issues/discussions/PRs.
     - **Linear** or **Notion** — optional, if your team tracks work outside GitHub.
     - **Slack** — optional, for posting the triage summary.
   - **Permissions**: comment-only on issues. No closures, no auto-assignment, no PR creation.
   - **Environment**: standard.
4. **Save the routine**.

---

## Prompt (copy this block)

```text
You are running weekly backlog triage for an AGENT-11 project.

Apply three lenses to the open backlog and produce a prioritised triage list.

1. Priority review (strategist lens)
   - Read all open GitHub issues and discussions opened or updated in the past 7 days.
   - Read the project's vision/strategy documents (project-plan.md if present, or README).
   - Categorise each item: P0 (blocker / critical bug), P1 (important / should ship soon), P2 (nice-to-have), P3 (likely to defer or close).
   - Flag items that conflict with stated strategy or are explicitly out of scope.

2. Usage signal (analyst lens)
   - Identify items that reference recurring customer feedback, repeated bug reports, or features mentioned in multiple issues.
   - Flag items that have multiple users reporting them — these often warrant priority elevation.
   - Note any item that has been open >30 days with no activity (candidate for explicit close-or-commit).

3. Customer impact (support lens)
   - Identify items linked to active customer escalations or support tickets.
   - Flag any P2/P3 item where customer-facing impact suggests promotion to P1.

Output format: write a markdown report to triage/YYYY-MM-DD.md in the configured repo. Structure:
- **Top 5 actions this week** (your top picks across the lenses, with one-line rationale each)
- **P0** (full list with one-line summary)
- **P1** (full list)
- **P2** (full list)
- **Defer / close candidates** (>30 days inactive)
- **Strategy concerns** (items that conflict with stated direction)

If a Slack connector is configured, also post the "Top 5 actions this week" section to the configured channel as a thread starter.

Do NOT close issues, change labels, or assign people automatically. Surface, don't decide.
```

---

## Notes

- The routine is a *recommender*, not a decision-maker. The human reviewer decides what to act on; the routine does the triage research that takes 30 minutes by hand.
- For projects without `project-plan.md` or a stated strategy, the routine focuses on customer signal and recency. Add a strategy doc to get better priority calls.
- If your project has zero issues opened in the past week, the routine writes a short report ("No new activity — backlog stable") rather than padding.
- Adjust the cron to a different day if Monday morning doesn't fit your team rhythm. Some teams prefer Friday afternoon (close-out review).
