# Sprint 6d: Consolidation & Public Comms — Detailed Spec

**Part of**: Sprint 6 — Loop Discipline & Read-Only Verification (umbrella → v6.2.0)
**Predecessor**: Sprint 6c — Coordinator phase-gated meta-loop ✅ (implemented 2026-06-20)
**Successor**: none — this is the umbrella's closing sprint. Sprint 6 ends here; 6d's closing task proposes the next umbrella, it does not pre-spec one.
**Status**: ✅ COMPLETE 2026-06-20. T1–T6 done. Docs consolidated + pushed; website deployed (agent-11.com); v6.2.0 released. **Sprint 6 umbrella fully closed.**
**Target release**: **v6.2.0** — released as tag `v6.2.0-loop-discipline` (GitHub release live).

---

## Goal

Tell the world, once and coherently, what Sprint 6 built. Public docs are updated as a single consolidated pass (not per sub-sprint), reading the User-Facing Changes running list accumulated in `progress.md` across 6a–6c. Cut the v6.2.0 release.

## Why this sprint exists

Per the standing rule (`project-plan.md` → "Documentation & Release Communications"): public-facing docs change **once as a consolidated effort**. 6a–6c logged their user-facing changes to the running list; 6d turns that list into the README/CHANGELOG/RELEASE-HISTORY/website update and the version cut. Mirrors how Sprint 4h consolidated the v6.0 docs.

## Gate — now satisfied

The outline said: do not start until 6a is live-demoed and 6b/6c are shipped. Status at spec time:
- **6a** ✅ implemented + live-demoed (2026-06-16): agent blocked from editing `.quality-gates.json`.
- **6b** ✅ shipped + watched validation run executed (2026-06-20) on aimpactmonitor.
- **6c** ✅ implemented (2026-06-20): phase-gated meta-loop + Bash gate-guard hook.

Gate met. 6d is genuinely ready to run.

## The feature set to communicate (from the running list)

1. **Read-only quality gates** — `.quality-gates.json` / `gates/**` unwritable by every agent (`permissions.deny`), enforced at the tool layer. The positioning line: *your agents can't game their own success criteria.*
2. **Bash gate-guard hook (6c)** — closes the Bash-write route the deny rules don't cover.
3. **Default-fail verification** — every success criterion starts failing, flips to pass only on captured command output.
4. **Ratchet `mission-optimize` (6b)** — worktree-isolated, median-of-3 baseline, keep-or-revert, logged, capped, human-merged.
5. **`code-review-loop` skill (6b)** — read-only critic → read-write fixer → re-audit, converge-or-cap.
6. **Phase-gated meta-loop (6c)** — convergence over fixed counts, per-phase error budget, condensed returns, restart-from-last-passed-gate.
7. **New docs** — `loop-discipline-guide.md`, `mission-optimize` input template.

## Design decisions (resolved — review these)

1. **Version** → **v6.2.0** (minor). New behavioural constraints + new capabilities on deployed agents; not a bug fix. Confirmed across 6a–6c specs.
2. **Positioning** → lead with the *trust* story (read-only gates / can't-game-the-tests), not the loop mechanics. The loops are the payoff; the integrity guarantee is the hook. Truth-over-hype: every claim must trace to shipped, demoed behaviour (no "fully autonomous" overclaim — the watched-run discipline is the honest frame).
3. **Website repo** → **scope it first, assume nothing.** `agent-11-website` is a separate repo; task 1 reads its current feature messaging before any edit. README and website ship the same story.
4. **Honest caveats published, not hidden** → the docs state the limits the research names: loops are watched-first, human-merged, hill-climbing not invention; metric-must-match-intent; worktree needs a deps strategy on JS projects. Credibility comes from naming them.

## Scope (in)

- `README.md` (~1880 lines) — add the feature set to Features & Capabilities; the trust positioning; reuse the running list. No churn beyond Sprint 6 surface.
- `CHANGELOG.md` — finalise the `[Unreleased]` block into a dated `[6.2.0]` release section.
- `docs/RELEASE-HISTORY.md` — v6.2.0 entry.
- Upgrade/deployment docs (`docs/UPGRADE.md` or equivalent) — the new `permissions.deny` block + Bash guard users receive on upgrade, and the "deliberately change a gate" human workflow.
- `agent-11-website` (separate repo) — feature messaging updated to match, after scoping its current state.
- Version bump wherever the framework records its version (install banner / VERSION file if present).

## Scope (out — explicit)

- **Any new framework behaviour** — 6d is comms + release only. No agent/mission/skill logic changes.
- **Re-litigating 6a–6c decisions** — they are shipped.
- **agent-11's own `.claude/` working squad** — library + public docs only.
- **A successor sprint spec** — Sprint 6 closes; T6 proposes the next direction, does not pre-spec it.

## Tasks

**Status (2026-06-20): ALL ✅ DONE.** T1 website scoped. T2 README v6.2.0 block + Advanced Capabilities. T3 CHANGELOG `[6.2.0]` + RELEASE-HISTORY entry. T4 UPGRADE doc (deny block + Bash guard + deliberately-change-a-gate workflow). T5 website edited (`changelog/page.tsx` v6.2.0 entry + `Hero.tsx` badge/subheadline), built clean, pushed → deployed to agent-11.com via Netlify. T6 released: tag `v6.2.0-loop-discipline` pushed + GitHub release created (https://github.com/TheWayWithin/agent-11/releases/tag/v6.2.0-loop-discipline). No install.sh version constant exists → no SHA churn.

### T1. Scope the website repo
Read `agent-11-website`'s current feature/messaging surface. Produce a short diff-plan of what changes, so README and website tell one story. Assume nothing about current content.

### T2. README update
Add read-only gates + default-fail + ratchet + code-review loop + meta-loop to Features & Capabilities, led by the trust positioning. Reuse the `progress.md` running list. Include the honest caveats.

### T3. Finalise CHANGELOG + RELEASE-HISTORY
Convert `[Unreleased]` → `[6.2.0] - <date>`; add the RELEASE-HISTORY v6.2.0 entry. Verify every line traces to shipped behaviour.

### T4. Upgrade/deployment docs
Document the `permissions.deny` block + Bash gate guard delivered on `install.sh --upgrade`, and the deliberately-change-a-gate workflow.

### T5. Website update
Apply the T1 plan in `agent-11-website`. Coordinate so it ships the same story as the README. (Jamie confirms before any website publish/deploy.)

### T6. Closing task — cut v6.2.0 + propose next direction
Version bump, verify the install/upgrade path picks up everything (a clean install smoke-test like 6b T3), tag/release per Jamie's call, and write a short "what's next after Sprint 6" note (candidates: harness-run loop for the real token-cost number to tune the 6c error budget; rolling 6a–6c to the fleet). Do NOT pre-spec it.

## Success metric

Comms/release enabler. No harness-metric target. Done = v6.2.0 cut, public docs coherent and honest, website aligned, clean install delivers the whole Sprint 6 feature set.

## Deliverables

- README, CHANGELOG (v6.2.0), RELEASE-HISTORY, upgrade docs updated from the running list.
- `agent-11-website` aligned.
- v6.2.0 released (on Jamie's confirmation).
- "What's next after Sprint 6" note. Sprint 6 umbrella closed.

## Risks / honest caveats

- **Overclaiming.** The temptation is "fully autonomous self-improving agents." The truth is watched-first, human-merged, capped loops with read-only judges. Publish the truth; it is still a strong story and it is defensible.
- **Website drift.** Separate repo, easy to forget or let say something the README contradicts. T1 scopes it first for exactly this reason.
- **Stale running list.** If a user-facing change landed in 6a–6c but never hit the `progress.md` running list, it gets missed here. T2/T3 cross-check the list against the actual shipped diffs, not just the list.
