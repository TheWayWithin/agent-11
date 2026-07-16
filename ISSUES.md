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
## Recently closed

| ID | Title | Status | Commit | Detail |
|----|-------|--------|--------|--------|
| A11-ISS-2 | Two competing BOS-AI handoff conventions coexist: documents/foundations/+/foundations (current) vs ideation/+dev-setup (bos-ai-integration-guide, quickstart) — field-manual routes users away from /foundations | Resolved 2026-07-16 | 4adc939 | Legacy guides (bos-ai-integration-guide.md, bos-ai-quickstart.md) deleted; replaced by new canonical field-manual/bos-ai-handoff.md (two tiers + ownership-transfer rule, deployed via install.sh). README relinked (4 spots), root INTEGRATION-GUIDE.md slimmed to a pointer, 3 root design docs banner-marked as archive, example converted ideation/→documents/foundations/ with mapper-compatible filenames, dev-setup/dev-alignment missions given BOS-AI routing notes. PRJ-14 tasks 2–3. |
| A11-ISS-1 | install.sh omits foundation-*.schema.yaml (all 9) and validate_foundations.py — /foundations references dangling project/schemas/ paths in deployed projects | Resolved 2026-07-16 | 4adc939 | Schemas: all 9 added to install.sh schema_files, verified via test install (16 schemas land in ./schemas/). Dangling `project/schemas/` refs fixed → `schemas/` in foundations.md, plan.md, bootstrap.md, stack-profiles README. validate_foundations.py NOT deployed by decision: referenced nowhere, and stale (knows 5 of 9 categories) — stays internal. install.sh.sha256 regenerated. |
