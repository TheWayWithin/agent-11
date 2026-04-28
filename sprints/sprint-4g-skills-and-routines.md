# Sprint 4g: Skills + Routines

**Part of**: Agent-11 v6.0 Evolution (Sprint 4 umbrella)
**Predecessor**: Sprint 4f — Dynamic MCP Tool Search ✅ (T1, T2, T3, T5, T6, T8 shipped; T7 deferred)
**Successor**: Sprint 4h — Validation + Migration
**Status**: Spec recalibrated 2026-04-27 after pre-execution platform check; execution in progress

---

## Goal

Two parallel structural moves:

1. **Adopt the 3-tier skills architecture** with Anthropic's Agent Skills open standard (`SKILL.md`). Existing AGENT-11 skills already use a SKILL.md-shaped frontmatter — verify alignment with the open standard, document the tier model, position Tier 3 (marketplace) skills for future publishing.
2. **Integrate Claude Code Routines for Mode C** (operational) work. Daily reports, PR reviews, nightly QA — these don't need a human-driven session. Produce **prompt templates** users paste into `claude.ai/code/routines` to set up scheduled cloud-hosted agents. `/coord` detects operational intent and outputs the prompt template instead of executing the work itself.

## Pre-Execution Platform Check (2026-04-27)

Before designing T4-T7, verified Claude Code Routines' actual mechanism (per [docs](https://code.claude.com/docs/en/routines)):

- **Routines are live and stable** (research preview phase, production-ready for Pro/Max/Team/Enterprise).
- **Run on Anthropic-managed cloud**, not locally.
- **Created via three paths to the same cloud account**: web UI at `claude.ai/code/routines`, `/schedule` slash command, or desktop app.
- **No JSON/YAML config files**. Web form collects: prompt (natural language), repos, environment (network/env vars/setup script), triggers (schedule/API/GitHub webhooks), connectors (MCP), permissions.

This corrected the original "paste JSON config" framing. Templates are now **prompt text** plus setup notes for the UI fields users will fill in.

## Why This Sprint

Three observations:

1. **Skills already exist but aren't formalised.** AGENT-11 ships 7 SaaS skills (auth, payments, multitenancy, billing, email, onboarding, analytics). They use SKILL.md frontmatter and load on trigger keywords (Sprint 4d/4e left this in place). What's missing: explicit tier classification, alignment with Anthropic's published spec, and a clean migration path if/when AGENT-11 publishes Tier 3 skills to a marketplace.
2. **Mode C work is consuming session-cost it shouldn't.** Daily reports, scheduled triage, PR review — these are operational workflows that fire on a clock or a webhook, not on user prompts. Running them as `/coord` invocations costs context and human attention that Routines would handle natively.
3. **The blueprint says paste, not commit.** Confirmed by the platform check: Routines accept a prompt typed into a web form. We don't ship in-repo configs that get loaded by the runtime; we ship prompt templates as documentation that users copy-paste.

## Scope Reminder

Library surface only: `project/skills/`, `project/routines/` (new), `library/CLAUDE.md`, `field-manual/`. Working squad untouched.

---

## Tasks

### T1. Audit existing skills against the open standard

**Deliverable**: a status table for each of the 7 SaaS skills, plus any `project/skills/` we've added since, against Anthropic's published Agent Skills spec.

**Approach**:
1. Fetch the canonical SKILL.md spec (Anthropic docs).
2. For each skill in `project/skills/*/SKILL.md`, compare:
   - Frontmatter fields (name, description, triggers, etc.)
   - Body structure (Use Cases / Patterns / Quality Checklist sections)
   - Required vs optional fields per the spec
3. Identify gaps and produce a remediation list.

**Recommendation** (likely outcome): existing skills are 80-90% aligned. Small gaps in `description` field requirements (spec wants a one-sentence pitch, ours have detailed docs) and possibly the `category`/`tags` taxonomy. No structural rewrites needed.

**Acceptance**: Status table committed (in progress.md or a dedicated audit file). Per-skill remediation items listed.

---

### T2. Define and document the 3-tier model

**Deliverable**: a clear tier classification published in `field-manual/skills-guide.md` (already deployed).

**Tiers**:

| Tier | What | Where it lives | Example |
|------|------|----------------|---------|
| **Tier 1 — Behavioural** | Cross-cutting principles applied by every specialist | `.claude/CLAUDE.md` Karpathy constitution (already shipped 4d) | "Read before writing" |
| **Tier 2 — Project Domain** | Project-specific decisions, conventions, business logic | User project's local `skills/` directory (created post-install if needed) | "We use Drizzle, not Prisma" |
| **Tier 3 — Marketplace** | Curated reusable patterns | `project/skills/` shipped by AGENT-11 (the 7 SaaS skills) | `saas-auth`, `saas-payments` |

**Documentation deliverable**: `field-manual/skills-guide.md` updated with the tier table, examples of when each tier applies, and a note that Tier 3 skills are positioned for future marketplace publishing (format-only intent — no public marketplace yet).

**Acceptance**: skills-guide.md reflects the 3-tier model. The lean library CLAUDE.md's existing skills paragraph (Sprint 4d) gets a one-line tier reference.

---

### T3. Apply skill remediation per T1 audit

**Deliverable**: each existing skill's frontmatter and body brought into alignment with the open standard. Likely small edits per skill.

**Approach**:
1. For each gap identified in T1, propose a minimal patch.
2. Apply patches to all 7 SaaS skills.
3. Verify each skill still loads correctly via the existing skill-loading protocol (coordinator reads triggers from frontmatter).

**Acceptance**: All 7 SaaS skills pass spec validation. No regression in trigger matching (verified by inspection — skill triggers used in coordinator delegation patterns still resolve).

---

### T4. Routine prompt template — pr-review

**Deliverable**: `project/routines/pr-review.md` — a markdown file containing a paste-ready prompt for the user to drop into `claude.ai/code/routines`, plus setup notes for the UI fields.

**Content** (the file users read; the prompt block is what they paste):
- **Prompt** (natural language, self-contained — copy this into the web UI form): how to review the PR, what specialists' lenses to apply (code, test coverage, design impact), the structure of the GitHub PR review comment to post.
- **Setup notes** for the form's other fields:
  - Repos: which repos the routine should watch.
  - Trigger: GitHub webhook on PR open or PR push.
  - Connectors: GitHub MCP required.
  - Permissions: comment-only on PRs, no merges or branch pushes.
  - Environment: standard.

**Format**: prose explanation followed by a fenced code block containing only the prompt. User copies the prompt block; the rest is documentation.

**Acceptance**: `pr-review.md` ships a working prompt that produces a useful PR review when pasted into a routine. Setup notes cover all UI fields.

---

### T5. Routine prompt template — nightly-qa

**Deliverable**: `project/routines/nightly-qa.md` — paste-ready prompt + setup notes for a scheduled QA sweep.

**Content**:
- **Prompt**: instructs the routine to run smoke tests on critical paths (tester lens), do a visual regression spot-check (designer lens), check deployment health (operator lens), and post findings to a designated location.
- **Setup notes**:
  - Trigger: schedule, default cron 02:00 daily.
  - Connectors: Playwright MCP (testing), Railway/Netlify MCP (deployment), optionally Slack (output).
  - Permissions: read-only (no PRs created).
  - Environment: setup script installs Playwright dependencies if needed.
  - Output destination: `qa-reports/YYYY-MM-DD.md` in the configured repo, or post to a Slack channel.

**Acceptance**: `nightly-qa.md` ships a working prompt + setup notes. Cron syntax matches Claude Code Routines' scheduling format (per docs).

---

### T6. Routine prompt template — backlog-triage

**Deliverable**: `project/routines/backlog-triage.md` — paste-ready prompt + setup notes for a scheduled backlog sweep.

**Content**:
- **Prompt**: instructs the routine to review open issues and recent feedback (strategist lens for priority, analyst lens for usage data, support lens for recurring complaints) and produce a prioritised triage list.
- **Setup notes**:
  - Trigger: schedule, default cron Monday 09:00 weekly.
  - Connectors: GitHub MCP (issues), optionally Linear/Notion MCP if user has them, optionally Slack (output).
  - Permissions: comment-only on issues, no closures.
  - Output destination: GitHub Project board, Slack thread, or `triage/YYYY-MM-DD.md` in the configured repo.

**Acceptance**: `backlog-triage.md` ships a working prompt + setup notes.

---

### T7. `/coord` operational-intent detection

**Deliverable**: `/coord` recognises operational-intent prompts and points the user to Routines instead of executing once.

**Trigger phrases** (initial set — refine during execution):
- Cadence keywords: "daily", "weekly", "monthly", "hourly", "every Monday/Tuesday/...", "every N hours/days"
- Set-up keywords paired with cadence: "schedule", "set up", "automatic", "recurring"
- Common operational phrases: "run a daily report", "weekly triage", "nightly QA", "PR review"

**Behaviour**: when a trigger phrase is detected, `/coord` does NOT delegate. Instead it prints:

```
This looks like recurring/operational work. Claude Code Routines handle this
natively (cloud-hosted, scheduled, no local session needed).

Closest matching template: project/routines/[NAME].md

To set up:
1. Open claude.ai/code/routines and click "New routine".
2. Paste the prompt block from project/routines/[NAME].md into the prompt field.
3. Configure repos, trigger (schedule/webhook), connectors per the setup notes.

Or run once now (no schedule): /coord [mission] (without cadence keywords).
```

**Coordinator changes**:
- Add a "ROUTINE DETECTION" section to `project/commands/coord.md` describing the trigger phrases and the response template.
- The coordinator specialist itself does not need to know about Routines — the dispatch happens in the `/coord` command, before the coordinator is invoked.

**Acceptance**: `/coord set up nightly QA` outputs the pointer to `project/routines/nightly-qa.md`. `/coord every Monday triage backlog` points to `backlog-triage.md`. `/coord build feature` (no cadence) executes normally.

---

### T8. Update lean library/CLAUDE.md

**Deliverable**: lean CLAUDE.md mentions:
- The 3-tier skills model (one line + pointer to field-manual/skills-guide.md).
- Routines as Mode C primitive (one line + pointer to project/routines/).

**Acceptance**: lean CLAUDE.md still under 80 lines after the edit. Both additions are one line each.

---

### T9. Re-run harness and measure

**Subset**: Tasks 4 (refactor) and 5 (commit review). Both exercise specialist delegation; the skill remediation should not introduce regressions.

**Deliverable**: `project/validation/milestone-4g.md` with results compared to milestone-4f baseline.

**Success criteria**:
- No regression in M1 (wall-clock time).
- Skills load correctly when triggered (observed in harness recordings).
- M2 (session-start tokens) within ±10% of milestone-4f — skills remediation should be cosmetic on token cost.
- `/coord set up nightly QA` (manual test, not necessarily harness) outputs Routine config not delegations.

---

### T10. Write Sprint 4h detailed spec

**Deliverable**: replace the outline at `sprints/sprint-4h-validation-and-migration.md` with a detailed spec.

The spec should cover:
- Final harness run on full v6.0 surface vs v5.2 baseline (all 5 tasks, not subsets).
- Migration script: detect a v5.x install (presence of `handoff-notes.md`, `.mcp-profiles/`, etc.) and offer to convert.
- Documentation consolidation per the strategy in project-plan.md (README, CHANGELOG, MCP-GUIDE, deployment docs).
- Private beta: who tries v6.0 first, what feedback channel, what graduation criteria.
- v6.0 release tagging and rollout plan.

**Acceptance**: Sprint 4h detailed spec written; Jamie has reviewed and approved scope.

---

## Definition of Done

- [ ] T1: Skills audit complete; remediation list produced
- [ ] T2: 3-tier model documented in skills-guide.md
- [ ] T3: All 7 SaaS skills patched per audit
- [ ] T4: pr-review Routine config paste-ready
- [ ] T5: nightly-qa Routine config paste-ready
- [ ] T6: backlog-triage Routine config paste-ready
- [ ] T7: `/coord` operational-intent detection live; outputs Routine config for matching triggers
- [ ] T8: Lean library/CLAUDE.md mentions tiers + Routines; <80 lines
- [ ] T9: Harness subset re-run; milestone-4g.md committed; no regressions
- [ ] T10: Sprint 4h detailed spec written and approved

---

## Risks & Watch-Items

- **Skill spec drift.** Anthropic's Agent Skills spec may change between writing this and execution. T1 should fetch the current spec; lock to whatever is canonical at execution time.
- **Routine config drift.** Claude Code Routines are a relatively new platform feature; their config schema may evolve. Templates should be marked with the spec version they target. Smoke-test once with Jamie pasting into web UI before considering "done".
- **Operational-intent detection too aggressive.** If `/coord` over-detects cadences, users get Routine output when they wanted execution. Mitigation: trigger phrases require explicit cadence words ("daily", "weekly", "every X"); plain `/coord build` etc. is unaffected.
- **Tier 3 marketplace publishing premature.** v6.0 plan explicitly says "format for the standard, don't publish yet". Ensure no language in skills-guide.md implies a live marketplace exists.

---

## Open Design Questions

- **Routines: ship in-repo (committed configs) or paste-from-docs only?** Recommendation: **paste-from-docs**. Per the v6.0 blueprint, Routines are user-owned and run in the web UI. We ship the *templates* in `project/routines/` as paste-ready files, but they're documentation, not active code. Users copy what they want.
- **`/coord` operational-intent threshold?** Recommendation: only trigger on explicit cadence keywords. False negatives ("schedule a weekly triage" → executes once) are recoverable; false positives ("set up the auth flow" → outputs Routine when user wanted execution) are confusing.
- **Tier 2 skills location in user projects?** Recommendation: `skills/` at user project root (NOT `.claude/skills/` since those are framework-shipped). User skills are project-specific and tracked in their repo.

---

## Notes for Execution

- T1 is the gating audit. Get the spec right before patching.
- T4-T6 (Routine templates) can run in parallel.
- T7 ('/coord' detection) is the trickiest behavioural change in 4g — small change in coordinator prompts; test with multiple phrasings.
- T9 is mandatory but low-stakes (skills are already loading; this verifies no regression).
- Sprint 4g is the second-to-last v6.0 sprint. Save the heavier validation for 4h.
