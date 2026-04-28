# Sprint 4h: Validation + Migration

**Part of**: Agent-11 v6.0 Evolution (Sprint 4 umbrella)
**Predecessor**: Sprint 4g — Skills + Routines ✅ (T1-T8, T10 shipped; T9 deferred)
**Successor**: None (final v6.0 sprint — hands off to ongoing maintenance / post-v6 backlog)
**Status**: Detailed spec ready for Jamie's review; execution can start once Sprint 4g is committed

---

## Goal

Prove v6.0 is materially better than the v5.2 baseline, ship it publicly, and provide existing users a one-command migration path. This is the close-out sprint — every loose thread from 4a-4g either gets pulled or explicitly deferred.

## Why This Sprint

Three observations:

1. **Five harness re-runs are parked across 4c, 4d, 4e, 4f.** None have been run since Sprint 4b's milestone-4b.md. We've shipped 4 sprints of structural changes on the assumption they deliver M2 reductions. Sprint 4h's first job is the actual measurement.
2. **v5.x users on `main` need a migration path.** The cumulative changes (handoff-notes folded, profile-switching retired, hooks added, lean CLAUDE.md, etc.) require coordinated changes to a deployed user project. Manual `mv` instructions exist in CLAUDE.md but a one-command migration is friendlier.
3. **Documentation has been deliberately deferred per sprint** to a single consolidated pass here. Time to honour that commitment.

## Scope Reminder

Library surface: `library/CLAUDE.md`, `project/deployment/scripts/`, public-facing docs (`README.md`, `CHANGELOG.md`, `docs/`). One new internal artefact allowed: a v6.0 retrospective doc in `.archive/`.

---

## Tasks

### T1. Run the parked harness batch — measurement against v5.2 baseline

**Deliverable**: 5 milestone documents in `project/validation/`:
- `milestone-4c.md` — Tasks 3, 4, 5 (router + dynamic context loading)
- `milestone-4d.md` — Tasks 1, 2, 5 (lean CLAUDE.md + hooks)
- `milestone-4e.md` — Tasks 1, 2, 3 (3-file context model)
- `milestone-4f.md` — Tasks 1, 2, 3 (`ENABLE_TOOL_SEARCH=auto` + Tool Search workflow)
- `milestone-4g.md` — Tasks 4, 5 (skills audit no-regression check)

**Approach**:
1. Use `project/validation/run-playbook.md` for each task.
2. Capture M1 (wall-clock), M2 (session-start tokens), M3 (unnecessary delegations), M4 (human interventions), M5 (recovery success) per task.
3. Compare each metric against the v5.2 baseline.
4. Flag any unexpected regressions for follow-up before closing the sprint.

**This is the parked T7 batch from Sprints 4c-4f, plus a small T9 from 4g.** Best run as a single terminal session if scope allows — they all measure against the same baseline.

**Acceptance**: All 5 milestone docs committed. Each document compares the post-sprint state to the v5.2 baseline with absolute and percentage deltas.

---

### T2. v6.0 cumulative metrics report

**Deliverable**: `project/validation/v6.0-summary.md` — a Jamie-readable summary stating what moved, by how much, and whether the v6.0 evolution targets were met.

**Structure**:
- Executive summary (3-5 lines: what shipped, key metric movements)
- Metric-by-metric comparison table (v5.2 → v6.0, per task, with percentage delta)
- Wins (what worked beyond expectation)
- Misses (what didn't move as expected, why)
- Surprises (regressions or unexpected gains, with diagnosis)
- Recommendations (anything to tweak post-release)

**Acceptance**: Document is short (≤2 pages) and tells Jamie unambiguously whether v6.0 is ready to ship to beta users.

---

### T3. v5.2 → v6.0 migration script

**Deliverable**: `project/deployment/scripts/migrate-v5-to-v6.sh` — a one-command migration for users with an existing v5.x install.

**What it does**:
1. **Detect**: confirm the project is a v5.x AGENT-11 install (check for `handoff-notes.md`, `.mcp-profiles/`, old-format `.claude/CLAUDE.md`).
2. **Backup**: copy current `.claude/`, `field-manual/`, `templates/`, root tracking files to `.claude/backups/v5-to-v6-YYYYMMDD/`.
3. **Migrate context** (Sprint 4e):
   - Append `handoff-notes.md` content to `agent-context.md` if present.
   - Move `handoff-notes.md` to `.claude/backups/`.
   - Print: `progress.md` is now write-only — coordinator no longer reads at session start.
4. **Migrate MCP** (Sprint 4f):
   - Move `.mcp-profiles/` to `.claude/backups/` if present.
   - Confirm or create `.claude/settings.json` with `ENABLE_TOOL_SEARCH=auto`.
   - Note: existing user `.mcp.json` (server registry) is NOT modified.
5. **Reinstall library**: re-run `install.sh` to deploy the v6.0 library/CLAUDE.md, agents, commands, missions, templates, skills.
6. **Verify**: print a 5-line summary of what changed and what backups were created.

**Safety**:
- Confirm with the user before proceeding (`Continue with v5.x → v6.0 migration? [y/N]`).
- Refuse to migrate if backups directory can't be written.
- Refuse to migrate if no v5.x markers detected (avoids running on a fresh install).

**Acceptance**:
- Script tested on a scratch directory seeded with v5.x markers — migration completes without data loss.
- Script tested on a directory that's already v6.0 — script detects no migration needed and exits cleanly.
- Script tested on an unrelated directory (no AGENT-11 install) — script refuses to run.

---

### T4. Consolidated documentation update

**Deliverable**: a single coordinated documentation pass across all user-facing docs. Pulls the "User-Facing Changes" running list from `progress.md` (Sprints 4a-4g) into a consistent set of docs.

**Files**:
- `README.md` — rewrite the install/usage sections to describe v6.0:
  - Universal Router (`/coord [mission]`)
  - Karpathy operating discipline
  - 3-file context model (project-plan.md, agent-context.md, evidence-repository.md)
  - Native MCP tool deferring (no profile switching)
  - Routines for Mode C operational work
  - Hooks for quality gates
- `CHANGELOG.md` — v6.0 entry covering:
  - Breaking changes (handoff-notes.md retired, mcp-profiles retired, dynamic-mcp.json removed)
  - New features (Universal Router, Phase Handoff blocks, Routine templates, ENABLE_TOOL_SEARCH=auto, Karpathy constitution)
  - Deprecations (any v5.x patterns now discouraged)
  - Migration pointer (link to migrate-v5-to-v6.sh)
- `docs/RELEASE-HISTORY.md` — v6.0 summary block: what shipped, why, metrics moved (cite v6.0-summary.md from T2).
- `docs/MCP-GUIDE.md` — rewrite for the dynamic tool-search workflow. Retire all `.mcp-profiles/` references.
- `library/CLAUDE.md` — already lean (78 lines, Sprint 4g). Verify it's still accurate after migration script + docs update.
- One short post-install message in `install.sh` pointing first-time users at the README.

**Acceptance**:
- A new user can install v6.0 and get started purely from the README without consulting any v5.x docs.
- Existing users can run the migration script and find every breaking change documented in CHANGELOG.
- No v5.x patterns documented anywhere as "current best practice" — they're either retired with a deprecation note or removed.

---

### T5. ~~Private beta cohort~~

**REMOVED** during review (2026-04-27). Beta-cohort framing was lifted from a SaaS release playbook that doesn't fit AGENT-11's reality:

- Users on `main` already get v6.0 when they reinstall — there's no "release gate" they cross.
- Public-facing API is largely backwards-compatible (`/coord build` still works); v6.0's wins are mostly invisible structural improvements.
- The migration script (T3) does the upgrade automatically — if it works on Jamie's projects, it'll work on others'.
- The harness measurement (T1) is the empirical validation. Beta would mostly catch ergonomics, which surfaces in normal usage post-launch.
- Solo-founder bandwidth: formal beta = recruiting + supporting + triaging — overhead that doesn't fit IPP-90-days reality.

**What replaces it**: ship v6.0 publicly when T1-T4 are done. Respond to GitHub issues as they come up. Existing channels (X/Twitter, LinkedIn, blog) handle awareness without explicit recruitment.

---

### T5. Public release readiness (was T6)

**Deliverable**: a release readiness checklist that gates public v6.0 announcement.

**Checklist**:
- [ ] All 5 milestone harness docs committed and metrics meet v6.0 targets (per project-plan.md success criteria)
- [ ] Migration script tested on ≥3 distinct v5.x scenarios without data loss
- [ ] Documentation pass complete; no v5.x stale docs remain as "current best practice"
- [ ] CHANGELOG.md v6.0 entry finalised
- [ ] Release tag drafted (v6.0.0)
- [ ] Public announcement drafted (X/Twitter, LinkedIn, blog post per Jamie's voice — handled separately, not in this sprint)

**Acceptance**: Checklist committed to `project/validation/v6.0-release-readiness.md`. All items checked or explicitly deferred with rationale.

---

### T6. v6.0 retrospective + post-v6 backlog (was T7)

**Deliverable**: `.archive/2026-XX-XX-v6-retro/v6-retrospective.md` — a short retrospective on the full 8-sprint evolution.

**Structure**:
- What worked (rolling-wave protocol, mid-sprint recalibration, lean specs)
- What didn't (parked T7s, schema mismatches caught late, scope drift instances)
- Lessons captured (added to `.claude/skills/meta-dev/SKILL.md` if applicable; saved to memory if applicable)
- Post-v6 backlog: items deferred during the evolution (e.g., the agent-context.md → context.md rename considered but skipped; full Tier 3 marketplace publishing; routines that didn't fit the 3 templates)

**Acceptance**: Retrospective committed. Post-v6 backlog is clear about what's "next sprint candidate" vs "wishlist".

---

## Definition of Done

- [ ] T1: 5 milestone harness docs committed (4c, 4d, 4e, 4f, 4g)
- [ ] T2: v6.0-summary.md committed; readable in <5 minutes
- [ ] T3: migrate-v5-to-v6.sh works on test scenarios; no data loss
- [ ] T4: README, CHANGELOG, MCP-GUIDE, RELEASE-HISTORY updated for v6.0
- [ ] ~~T5~~: REMOVED — beta cohort was the wrong fit for solo OSS context
- [ ] T5: release-readiness.md committed; checklist either complete or items deferred with rationale
- [ ] T6: v6-retrospective.md committed; post-v6 backlog logged

---

## Risks & Watch-Items

- **Harness regressions discovered late.** If T1 reveals that one of 4c-4f silently regressed an existing metric, we have to choose: fix in 4h or defer to a 4i. Mitigation: run T1 first; review before committing to any later 4h tasks.
- **Migration script breaking on edge cases.** Real user projects have non-standard configurations. Mitigation: test on at least 3 distinct v5.x projects; refuse to run on unrecognised states; backup before any destructive op.
- **Beta cohort size.** If <5 beta installs materialise, we have insufficient signal to greenlight public release. Mitigation: T5 cohort recruitment runs in parallel with T1-T4; if response is thin, extend the recruitment window.
- **Documentation drift between docs.** README, CHANGELOG, MCP-GUIDE, lean CLAUDE.md must agree on the v6.0 surface. Mitigation: T4 is one coordinated pass, not separate edits; cross-reference each doc before commit.
- **Feature creep in 4h.** "While we're updating docs, can we also add X?" The answer is no — 4h is close-out. New features go to post-v6 backlog (T7).

---

## Open Design Questions (resolved during review 2026-04-27)

- **What if metrics don't hit v6.0 targets?** Resolved: ship anyway if regressions are within 10% and structural improvements are clear; document the misses in v6.0-summary.md and address in a post-v6 sprint.
- **Beta cohort feedback channel?** Resolved: T5 removed entirely. Beta-cohort framing was the wrong fit for a solo OSS project. Existing channels (GitHub issues, X/Twitter, LinkedIn, blog) handle post-launch feedback without explicit recruitment.
- **Rollback plan if a user hits a blocker after migration?** Resolved: backups created by `migrate-v5-to-v6.sh` are the rollback. Document the rollback steps in CHANGELOG and migration-script output.

---

## Notes for Execution

- T1 is gating. Without metrics, T2's summary is fiction.
- T3 (migration script) and T4 (docs) can run in parallel after T2.
- T6 (retrospective) is the literal last task of the v6.0 evolution. Don't skip — the captured lessons feed every future sprint.
- After T6, the v6.0 evolution is **complete**. Hand off to ongoing maintenance and any post-v6 backlog work as separate (non-Sprint-4) initiatives.
