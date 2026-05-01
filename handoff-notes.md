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

## Next Actions (locked checklist for v6.0 close-out)

Sprint 4h is **6 tasks** (T5 beta cohort dropped on 2026-04-27 — wrong fit for solo OSS context).

**Sprint 4h progress**:
- ✅ **T3 — v5→v6 migration script** shipped 2026-05-01 (out-of-order; doesn't depend on T1). Tested across 4 scenarios. See progress.md `[2026-05-01] — Sprint 4h T3` for details.

**Remaining**:
1. **You** — run the harness batch (T1) in terminal against v5.2 baseline. Five milestones to produce: 4c (Tasks 3, 4, 5), 4d (Tasks 1, 2, 5), 4e (Tasks 1, 2, 3), 4f (Tasks 1, 2, 3), 4g (Tasks 4, 5). Splittable across multiple sessions; produce them in any order.
2. **Me** — draft T2 (cumulative v6.0 metrics report) from your T1 results. Solo, fast.
3. **Me** — ship T4 (consolidated docs) — README/CHANGELOG/MCP-GUIDE/RELEASE-HISTORY pass. Solo, mostly mechanical. Some metric references need T2 data; rest is structural.
4. **You + me** — T5 (release-readiness checklist sync). One short pass before tagging v6.0.0.
5. **Me** — T6 (v6.0 retrospective + post-v6 backlog). Solo close-out.

**v6.0 ships when T6 commits.** No beta gate, no formal cohort recruitment.

---

## Open Items for Jamie

1. **Schedule the harness batch (T1)**. Genuinely terminal-required and gating for everything downstream. The window for that batch determines when v6.0 can ship.
2. **Migration script destructive-op safeguards (T3)**: spec defaults to backup-before-anything + refuse-on-unrecognised-state. If you want different paranoia level, flag before T3 starts.
3. **No new design questions surfaced** in 4g's recalibration or 4h's T5 trim. Skills hybrid format and Routines paste pattern both follow verified canonical sources.

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
