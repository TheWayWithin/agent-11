# agent-11 — Issue & Project Register

**This is the single source of truth for what is open in this repo.** One row per
issue/project. Detail lives in the linked doc; this file is the index the Mission
Control reconcile (`repo-reconcile.py`) reads and mirrors to the cockpit.

## ID convention (collision-safe)

Mission Control owns the bare `ISS-`/`PRJ-`/`T-` namespaces. **Every agent-11 ID
carries the `A11-` prefix** so it can never collide with a Mission-Control-native
ID or another repo's. Raise issues here with `python3 ~/shared/scripts/repo-issue.py`.

---

## Open

| ID | Title | Status | Severity | Detail | MC-SYNC |
|----|-------|--------|----------|--------|---------|
| A11-ISS-8 | No plan-tool.yaml template: templates/ has plan-saas-mvp/saas-full/api.yaml (deployed via install.sh) but the new tool project type (A11-ISS-6) has no counterpart - needs a designed phase/agent-distribution/timeline template for CLI toolkits and libraries | Open | low | — | pending |
| A11-ISS-7 | settings.json.template Write()/MultiEdit() permission deny rules are no-ops — Claude Code only matches Edit(path) rules for file tools (warnings at session start); Edit rules already cover every gate path so no security gap, but the dead rules should be pruned to silence the warnings | Open | low | — | pending |
| A11-ISS-6 | /bootstrap lite-tier gaps: type enum (saas-mvp/saas-full/api) has no CLI-toolkit fit, prerequisites demand vision.yaml lite projects lack, and it prescribes phase-1-context.yaml even when phase 1 is already complete at bootstrap time — PRJ-14 pilot feedback (digital-estate) | ✅ Resolved 2026-07-23 — Added tool project type (enum+inference+gates), vision.yaml now saas-*-only (tool/api proceed from PRD with warning), phase context targets first incomplete phase not unconditionally phase-1. Proven via lite fixture dry-run old-vs-new. Commit 995eb32. | low | — | pending |
| A11-ISS-5 | /foundations PRD extraction prompt is SaaS-biased for lite-tier projects (tier metrics, BR-XXX counts, pricing checks all N/A for a CLI toolkit; worked but most validation is vestigial) — PRJ-14 lite pilot feedback | ✅ Resolved 2026-07-23 — PRD extraction now source-driven: SCOPE RULE + conditional SaaS-shaped items (BR-XXX, state machines, tier metrics); FAIL conditions scoped. Proven via lite CLI-toolkit PRD dry-run: old FAIL -> new PASS with N/A checks. Commit 21eae2a. | low | — | pending |
| A11-ISS-4 | PreToolUse read-only gate guard false-positives on non-gate Bash (blocked a python-detection for-loop during /foundations init in digital-estate) | ✅ Resolved 2026-07-23 — Guard decision moved to .claude/hooks/gate-guard.sh (inspects real Bash command from hook stdin); fail-open if-glob removed. Proven: for-loop passes, genuine gate writes still blocked, end-to-end via headless Claude. Commit b941a19. | medium | — | pending |
| A11-ISS-3 | install.sh writes GitHub 404 body into .mcp.json — file is gitignored in source repo so download always fails; should skip instead of writing error body | ✅ Resolved 2026-07-23 — download_mcp_file() helper: curl -fsSL via temp file, dest untouched on failure, clear skip warning; .mcp.json now falls through to template as designed. Proven live (real 404 + bogus URL + success path). Commit 2d6a803. | low | — | pending |
## Recently closed

| ID | Title | Status | Commit | Detail |
|----|-------|--------|--------|--------|
| A11-ISS-2 | Two competing BOS-AI handoff conventions coexist: documents/foundations/+/foundations (current) vs ideation/+dev-setup (bos-ai-integration-guide, quickstart) — field-manual routes users away from /foundations | Resolved 2026-07-16 | 4adc939 | Legacy guides (bos-ai-integration-guide.md, bos-ai-quickstart.md) deleted; replaced by new canonical field-manual/bos-ai-handoff.md (two tiers + ownership-transfer rule, deployed via install.sh). README relinked (4 spots), root INTEGRATION-GUIDE.md slimmed to a pointer, 3 root design docs banner-marked as archive, example converted ideation/→documents/foundations/ with mapper-compatible filenames, dev-setup/dev-alignment missions given BOS-AI routing notes. PRJ-14 tasks 2–3. |
| A11-ISS-1 | install.sh omits foundation-*.schema.yaml (all 9) and validate_foundations.py — /foundations references dangling project/schemas/ paths in deployed projects | Resolved 2026-07-16 | 4adc939 | Schemas: all 9 added to install.sh schema_files, verified via test install (16 schemas land in ./schemas/). Dangling `project/schemas/` refs fixed → `schemas/` in foundations.md, plan.md, bootstrap.md, stack-profiles README. validate_foundations.py NOT deployed by decision: referenced nowhere, and stale (knows 5 of 9 categories) — stays internal. install.sh.sha256 regenerated. |
