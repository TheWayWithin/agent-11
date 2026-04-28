# Routines (Mode C — Operational Work)

This directory contains **prompt templates** for Claude Code Routines — scheduled cloud-hosted agents that handle recurring operational work without a human-driven session.

## What Routines are

Routines are Anthropic-managed cloud agents that run on a schedule, GitHub webhook, or API trigger. They're configured at `claude.ai/code/routines` (web UI), `/schedule` (CLI command), or the desktop app — all three write to the same cloud account.

The runtime accepts a **natural-language prompt** plus UI-selected fields (repos, environment, triggers, connectors, permissions). There's no JSON or YAML config to commit.

## What's in this directory

Three paste-ready templates covering common AGENT-11 use cases:

| Template | Trigger | What it does |
|----------|---------|--------------|
| [`pr-review.md`](pr-review.md) | GitHub webhook on PR | Multi-disciplinary code review (code, tests, visual) |
| [`nightly-qa.md`](nightly-qa.md) | Schedule (cron, daily) | Smoke tests + visual regression + deployment health |
| [`backlog-triage.md`](backlog-triage.md) | Schedule (cron, weekly) | Prioritised triage of open issues and customer feedback |

Each template ships:
- A **prompt block** to copy-paste into the Routine's prompt field.
- **Setup notes** for the form's other fields (trigger, connectors, permissions).
- **Notes** on customisation, edge cases, and safety.

## How to use a template

1. Open `claude.ai/code/routines` (or run `/schedule` from Claude Code).
2. Click **New routine**.
3. Open the template file in this directory and copy the prompt block.
4. Paste into the routine's prompt field.
5. Configure repos, trigger, connectors, and permissions per the template's setup notes.
6. Save.

## When `/coord` suggests a Routine

`/coord` detects operational/cadence keywords ("daily", "weekly", "schedule", "every Monday", etc.) and points you at the matching template instead of executing the work once. If you actually want to run something once now (no schedule), use `/coord [mission]` without cadence words.

## Notes

- **Routines run on Anthropic-managed cloud.** They don't share state with your local Claude Code sessions.
- **Treat templates as starting points.** Edit the prompt to match your project's specific patterns over time.
- **Routines are not configs you commit.** This directory ships templates as documentation; the live routines live in your Anthropic account.
- For multi-repo orgs, you can configure one routine to watch multiple repos.
- Reference: [Claude Code Routines docs](https://code.claude.com/docs/en/routines).
