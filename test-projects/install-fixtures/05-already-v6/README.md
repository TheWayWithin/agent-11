# Fixture 05: Already on v6 — shipped hooks propagate, then idempotent

Reworked for A11-ISS-9: a `hooks` key in the user's settings.json no longer
short-circuits the merge. Shipped AGENT-11 hooks are managed — the merger
upgrades stale shipped entries and fills missing ones, while user-added or
user-edited hooks are preserved byte-identical.

## Pre-state

A directory already on v6:
- No v5 markers
- `.claude/settings.json` has `ENABLE_TOOL_SEARCH` and a `hooks` key with
  empty event lists (a v6 repo that predates the current shipped hooks)
- `.claude/agents/coordinator.md` (so it's a real install, not greenfield)
- A user `permissions.allow` entry (must survive)

## Run

```bash
bash install.sh --upgrade   # run twice
```

## Expected post-state

Run 1 (hooks propagate):
- No migration runs (no markers detected)
- Merger reports `MERGED` — current template hooks land in the empty lists
- `.claude/settings.json` now contains the gate-guard hook and
  `.claude/hooks/gate-guard.sh` is deployed
- User `permissions.allow` entry preserved
- 11 specialists deployed; summary says "Tool deferring enabled"

Run 2 (idempotency):
- Merger reports `NOOP_ALREADY_V6`
- `settings.json` content unchanged between run 1 and run 2 (semantic hash)

This guards against two regressions: shipped-hook fixes failing to reach
already-deployed repos (A11-ISS-9), and repeat upgrades mutating settings.
Merger-level cases (stale-guard replacement, user-edited hooks, invalid
JSON) live in `project/deployment/scripts/test-merge-settings.sh`.
