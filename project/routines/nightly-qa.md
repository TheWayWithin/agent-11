# Routine: Nightly QA

**Purpose**: Scheduled smoke test of critical paths, visual regression spot-check, and deployment health verification. Posts a daily QA report.

**Trigger**: Schedule (default: 02:00 daily, project timezone).

**Where it runs**: Anthropic-managed cloud.

---

## How to set up

1. Open `claude.ai/code/routines` and click **New routine**.
2. **Paste the prompt below** into the prompt field.
3. **Configure the form**:
   - **Repository(ies)**: select the repo(s) the routine should test against.
   - **Trigger**: Schedule → cron `0 2 * * *` (daily at 02:00). Adjust timezone if needed.
   - **Connectors**:
     - **Playwright** — required for browser-based smoke tests.
     - **Railway** or **Netlify** — required for deployment health checks (whichever your hosting uses).
     - **Slack** — optional, for posting reports.
   - **Permissions**: read-only against the deployed environment. No PRs created. No branch pushes.
   - **Environment**: standard. If your tests need specific dependencies (e.g., Playwright browsers), include a setup script.
4. **Save the routine**.

---

## Prompt (copy this block)

```text
You are running nightly QA for an AGENT-11 project.

Apply three QA lenses in sequence and produce a single report.

1. Smoke test critical paths (tester lens)
   - Identify the project's critical user paths from the README, documentation, or recent commits. Examples: signup, login, primary dashboard load, key purchase/checkout flow.
   - Use Playwright to automate each path on the deployed staging environment (URL: from environment variables, e.g., STAGING_URL).
   - Record: pass/fail per path, console errors, network failures, response times >2s.

2. Visual regression spot-check (designer lens)
   - Take Playwright screenshots of 3-5 key pages (home, signup, dashboard, settings, pricing).
   - Compare against the baseline screenshots in qa-reports/baseline/ if present. If no baseline exists, save the current run as the new baseline.
   - Flag: layout shifts, missing assets, unexpected colour changes, broken responsive behaviour.

3. Deployment health (operator lens)
   - Use the deployment connector (Railway/Netlify) to verify: latest deployment status, error rate trend over the past 24h, key metric thresholds (response time, uptime).
   - Flag any anomaly that wasn't present yesterday.

Output format: write a markdown report to qa-reports/YYYY-MM-DD.md in the configured repo. Sections: Critical Paths, Visual, Deployment. Use a checklist format with ✅/⚠️/❌ markers. End with a "Severity" line: GREEN (no issues), YELLOW (minor concerns), or RED (critical regression).

If RED, also post a Slack message (if Slack connector is configured) tagging the on-call channel.

Do NOT auto-create PRs. Do NOT modify production data. Read-only operations only.
```

---

## Notes

- Adjust the cron schedule per timezone preference (Anthropic Routines support standard cron syntax).
- The first run creates the baseline screenshots; subsequent runs compare against them. Reset the baseline manually after intentional UI changes.
- For projects without a Slack connector, skip the Slack step; the routine still writes the markdown report.
- If you have a separate staging vs production environment, run the routine against staging only — don't risk hitting production with smoke tests.
- Add or remove critical paths over time as the product evolves.
