# Handoff Notes — Agent-11 v6.0 Evolution

**Last Updated**: 2026-04-27
**From**: Sprint 4g close-out (T1-T8, T10 shipped solo)
**To**: Next session — Sprint 4h (the close-out sprint)

---

## Where We Are

- **Sprint 4a** (Baseline + Great Deletion) — complete.
- **Sprint 4b** (Prompt Hygiene & Budget Controls) — complete.
- **Sprint 4c** (Universal Router) — T1-T6, T8 shipped (`ec5745a`); T7 parked.
- **Sprint 4d** (Native Primitives + CLAUDE.md Shrink) — T1-T6, T8 shipped (`3165f3d`); T7 parked. Smoke-tested ✓.
- **Sprint 4e** (Context Consolidation 5→3) — T1, T3-T6, T8 shipped (`9e4acf9`); T7 parked.
- **Sprint 4f** (Dynamic MCP Tool Search) — T1, T2, T3, T5, T6, T8 shipped (`4a3962a`); T7 parked. Recalibrated mid-sprint.
- **Sprint 4g** (Skills + Routines) — **T1-T8, T10 complete (2026-04-27)**. T9 parked. Recalibrated pre-execution.
- **Sprint 4h** (Validation + Migration) — detailed spec written, ready for review.

**v6.0 status**: 7 of 8 sub-sprints complete. Sprint 4h is the final close-out.

---

## What Sprint 4g Shipped

**Pre-execution platform check**: verified Claude Code Routines run on Anthropic-managed cloud (not local), use prompt-text + UI form (not JSON config). Spec recalibrated before any code shipped — same lesson as Sprint 4f.

**Substantive deliverables**:

- All 7 SaaS skills (`project/skills/saas-*/SKILL.md`) gained a `description` field aligned with [Anthropic's Agent Skills open standard](https://agentskills.io/specification). Hybrid format: open-standard description + AGENT-11 custom fields kept for backward-compat.
- `project/field-manual/skills-guide.md` documents the 3-tier model (behavioural / project-domain / marketplace) and the hybrid open-standard alignment.
- `project/routines/` directory created with 4 files:
  - `pr-review.md` — GitHub-webhook-triggered multi-disciplinary code review.
  - `nightly-qa.md` — scheduled smoke-test + visual regression + deployment health.
  - `backlog-triage.md` — weekly priority review + usage signal + customer impact.
  - `README.md` — overview, how-to-use, links to canonical Routines docs.
- `project/commands/coord.md` — `## Routine Detection` section added. Cadence keywords (daily/weekly/every Monday/schedule/nightly/etc.) trigger a pointer to the matching Routine template instead of delegation. coord.md is now 134 lines (was 91 in 4c, 549 originally).
- `library/CLAUDE.md` — Skills section describes 3-tier model; new Routines section (one paragraph). Still 78 lines.

Full close-out in `progress.md` under `[2026-04-27] — Sprint 4g (T1-T8, T10) Complete`.

---

## Next Actions

1. **Review Sprint 4h detailed spec** at `sprints/sprint-4h-validation-and-migration.md`. 7 tasks; this is the close-out sprint — no new structural changes, everything is measurement + migration + docs + beta + retrospective.
2. **Sprint 4h T1 (harness batch)**: gating task. Five milestone documents to produce (`milestone-4c.md` through `milestone-4g.md`) against the v5.2 baseline. This is where all four parked T7s + 4g's T9 collapse into one terminal session. Without this measurement we can't validate v6.0.
3. **After T1**: T2 (cumulative metrics report) + T3 (migration script) + T4 (docs consolidation) can run partially in parallel. T5-T7 (beta + release readiness + retrospective) are sequential.

---

## Open Items for Jamie

1. **Approve Sprint 4h scope** before execution. The big design calls in 4h are the migration script's destructive-op safeguards (T3) and the beta cohort's feedback channel (T5 recommendation: GitHub Discussions).
2. **Schedule the harness batch** — Sprint 4h T1 is genuinely terminal-required. The window for that batch determines when v6.0 can ship.
3. **No new design questions surfaced** in 4g's recalibration. The skills hybrid format and the Routines paste pattern both follow verified canonical sources.

---

## Key Files

| File | Purpose |
|------|---------|
| `project-plan.md` | v6.0 evolution overview, 8-sprint roadmap |
| `sprints/sprint-4g-skills-and-routines.md` | Just-completed sprint — T9 still open |
| `sprints/sprint-4h-validation-and-migration.md` | **Detailed spec, ready for review — final v6.0 sprint** |
| `project/validation/harness-spec.md` | How the harness works |
| `project/validation/baseline-v5.2.md` | v5.2 baseline (the target to beat) |
| `project/validation/milestone-4b.md` | Sprint 4b's harness results (the only v6.0 harness run so far) |
| `project/validation/run-playbook.md` | Step-by-step runbook for any milestone harness run |
| `library/CLAUDE.md` | 78 lines — deployed user-facing instructions |
| `library/settings.json.template` | Default advisory hooks + `ENABLE_TOOL_SEARCH=auto` |
| `project/routines/` | New directory: 3 Routine prompt templates + README |
| `project/field-manual/skills-guide.md` | 3-tier skills model + open-standard alignment |
| `templates/agent-context-template.md` | Includes Phase Handoff schema (5 fields) |
| `.claude/skills/meta-dev/SKILL.md` | Repo orientation skill (working-squad exception) |
| `.archive/2026-04-26-pre-4f/` | dynamic-mcp.json, mcp-optimization-guide.md, validate-mcp-profiles.sh |
| `.archive/2026-04-26-pre-4e/` | handoff-notes-template.md |
| `.archive/2026-04-17-pre-v6/` | Pre-v6 plan, sprints, progress, context |

---

## Notes for Fresh Session

- Scope rule: edits target library surface. The one v6.0 working-squad exception is `.claude/skills/meta-dev/` (created in 4d).
- Docs strategy: public-facing docs updated **once in Sprint 4h** (T4). Per-sprint user-facing changes have been logged in `progress.md` under "User-Facing Changes" headings — Sprint 4h's T4 reads that running list.
- Jamie prefers brief context + specific steps (ADHD). One task at a time, fully closed before moving on.
- **Instruction ordering**: never put caveats or "wait before X" *after* the step they qualify; trailing instructions are missed (memory-saved 2026-04-26).
- **Schema verification**: when an audit references "the spec" or "the schema", fetch canonical docs before acting. Sprints 4f and 4g both recalibrated mid-execution from verification findings — pattern works.
- British English by default.
- Instructions must be anchored to what Jamie sees on screen right now — don't require him to coordinate multiple windows without explicit consent.
