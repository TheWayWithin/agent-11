# Sprint 6d: Consolidation & Public Comms — Outline Only

**Part of**: Sprint 6 — Loop Discipline & Read-Only Verification (umbrella → v6.2.0)
**Predecessor**: Sprint 6c — Coordinator phase-gated meta-loop
**Status**: OUTLINE ONLY. This is the umbrella's closing sprint. Detailed spec produced after
6c lands. Do not execute from this file.

---

## Why this sprint exists

Per the repo's standing rule (`project-plan.md` → "Documentation & Release Communications"):
public-facing docs are updated **once as a consolidated effort, not per-sprint**. Sub-sprints
6a–6c log user-facing changes to the running list in `progress.md`; 6d reads that list and
produces the single coherent doc + comms update for the whole Sprint 6 feature set.

This mirrors how Sprint 4h consolidated the v6.0 docs.

## Why public docs were NOT touched in 6a–6c

1. User-facing docs should reflect the **shipped** state of Sprint 6, not its in-flight
   evolution.
2. One consolidated edit is cheaper and more coherent than several small ones.
3. Truth over hype: the read-only-gates claim ("agents can't game their own tests") is only
   honest to publish *after* the live-demo evidence exists (6a T5) and the loop capability
   (6b/6c) is real.

## Scope (when specced)

- **`README.md`** (1880 lines) — add read-only gates + default-fail verification + the loop
  capability (ratchet `mission-optimize`, scored code-review loop) to the Features &
  Capabilities surface. Frame as the "your agents can't game their own success criteria"
  positioning. Reuse the running list in `progress.md`.
- **`CHANGELOG.md`** — finalise the `[Unreleased]` block into the v6.2.0 release section.
- **`docs/RELEASE-HISTORY.md`** — v6.2.0 entry.
- **Upgrade/deployment docs** — note the new `permissions.deny` block users receive, and the
  "deliberately changing a gate" workflow.
- **agent-11 website** (separate repo — `agent-11-website`) — review and update feature
  messaging to match. SEPARATE REPO: scope its content as the first task of this sprint; do
  not assume what it currently says. Coordinate so README and website ship the same story.

## Gate before publishing

Do not start 6d until: 6a live-demo evidence exists, and 6b/6c are shipped. Announcing a
half-built umbrella is the "built but broken at the front door" failure the research warns
against.

## Metric justification

Comms/enabler. No harness-metric target; justified as the umbrella's release-communications
task.
