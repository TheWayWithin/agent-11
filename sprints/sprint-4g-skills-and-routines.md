# Sprint 4g: Skills + Routines

**Part of**: Agent-11 v6.0 Evolution (Sprint 4 umbrella)
**Predecessor**: Sprint 4f — Dynamic MCP Tool Search ✅ (T1, T2, T3, T5, T6, T8 shipped; T7 deferred)
**Successor**: Sprint 4h — Validation + Migration
**Status**: Detailed spec ready for Jamie's review; execution can start once Sprint 4f is committed

---

## Goal

Two parallel structural moves:

1. **Adopt the 3-tier skills architecture** with Anthropic's Agent Skills open standard (`SKILL.md`). Existing AGENT-11 skills already use a SKILL.md-shaped frontmatter — verify alignment with the open standard, document the tier model, position Tier 3 (marketplace) skills for future publishing.
2. **Integrate Claude Code Routines for Mode C** (operational) work. Daily reports, blog posts, PR reviews, nightly QA — these don't need a human-driven session. Produce Routine configs the user pastes into the web UI. `/coord` detects operational intent and outputs the Routine config instead of executing the work itself.

## Why This Sprint

Three observations:

1. **Skills already exist but aren't formalised.** AGENT-11 ships 7 SaaS skills (auth, payments, multitenancy, billing, email, onboarding, analytics). They use SKILL.md frontmatter and load on trigger keywords (Sprint 4d/4e left this in place). What's missing: explicit tier classification, alignment with Anthropic's published spec, and a clean migration path if/when AGENT-11 publishes Tier 3 skills to a marketplace.
2. **Mode C work is consuming session-cost it shouldn't.** Daily reports, blog generation, scheduled triage — these are operational workflows that fire on a clock or a webhook, not on user prompts. Running them as `/coord` invocations costs context and human attention that Routines would handle natively.
3. **The blueprint says paste, not commit.** Routines run from configs the user pastes into the Claude Code web UI. We don't ship them in-repo as the canonical artefact; we ship the *snippet* and the user pastes. This matches the v6.0 "platform-native primitives over custom frameworks" direction.

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

### T4. Routine config templates — pr-review

**Deliverable**: `project/routines/pr-review.md` — a paste-ready Routine config for GitHub-PR-triggered code review.

**Content**:
- Trigger: GitHub webhook on PR open or PR push.
- Specialists invoked: developer (code review), tester (test coverage), designer (visual changes if frontend touched).
- Output format: GitHub PR review comment with structured findings.
- Stop conditions: review complete, or 3+ specialists provided no actionable feedback.

**Format**: a markdown file containing the JSON config + a prose explanation. User copies the JSON, pastes into Claude Code web UI's Routines panel, fills in API keys.

**Acceptance**: `pr-review.md` is paste-ready. Jamie can copy it into the web UI without manual transformation.

---

### T5. Routine config templates — nightly-qa

**Deliverable**: `project/routines/nightly-qa.md` — paste-ready Routine for scheduled QA sweep.

**Content**:
- Trigger: cron, e.g., 02:00 daily.
- Specialists: tester (smoke test all critical paths), designer (visual regression spot-check), operator (deployment health check).
- Output: post to a configured Slack channel or write to `qa-reports/YYYY-MM-DD.md`.
- Stop conditions: all checks complete, or critical regression found (escalate).

**Acceptance**: `nightly-qa.md` paste-ready; specifies cron syntax expected by Claude Code Routines; identifies any prerequisites (Slack webhook URL, target environment).

---

### T6. Routine config templates — backlog-triage

**Deliverable**: `project/routines/backlog-triage.md` — paste-ready Routine for scheduled backlog sweep.

**Content**:
- Trigger: cron, e.g., Monday 09:00 weekly.
- Specialists: strategist (priority review), analyst (data on what's been used recently), support (recent issues).
- Output: prioritised triage list posted to a designated location (Slack thread, GitHub Project board, or `triage/YYYY-MM-DD.md`).
- Stop conditions: triage complete; if zero new issues, exit silently.

**Acceptance**: `backlog-triage.md` paste-ready; cron + outputs documented.

---

### T7. `/coord` operational-intent detection

**Deliverable**: `/coord` recognises operational-intent prompts and outputs a Routine config snippet instead of executing the workflow.

**Trigger phrases** (initial set — refine during execution):
- "run daily report" / "run a daily report"
- "schedule a weekly triage"
- "set up automatic PR review"
- "every Monday do X"
- Any prompt mentioning a cadence (daily, weekly, hourly, every N hours).

**Behaviour**: when a trigger phrase is detected, `/coord` does NOT delegate. Instead it prints:

```
This looks like recurring/operational work. Routines handle this natively.

Suggested Routine config (paste into Claude Code web UI):

[CONFIG SNIPPET — based on closest matching template from project/routines/]

Or run once now: /coord [mission] (without the cadence).
```

**Coordinator changes**:
- Add a "ROUTINE DETECTION" section to `coordinator.md` (or the `/coord` command) describing the trigger phrases and the response template.

**Acceptance**: `/coord set up nightly QA` outputs the nightly-qa Routine config. `/coord every Monday triage backlog` outputs backlog-triage. `/coord build feature` (no cadence) executes normally.

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
