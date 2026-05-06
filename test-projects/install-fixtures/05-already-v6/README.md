# Fixture 05: Already on v6 — no-op upgrade

## Pre-state

A directory already on v6:
- No v5 markers
- `.claude/settings.json` already has both `ENABLE_TOOL_SEARCH` and `hooks`
- `.claude/agents/coordinator.md` (so it's a real install, not greenfield)

## Run

```bash
bash install.sh --upgrade
```

## Expected post-state

The install should treat this as a normal v6 reinstall:
- No migration runs (no markers detected)
- `settings.json` content unchanged (merger reports `NOOP_ALREADY_V6`)
- No new `settings.json.backup-*` file is created (no merge happened)

  > Note: install.sh currently always backs up an existing settings.json before
  > inspection, even when the merger reports no-op. This is defensible (always-
  > backup-before-touch) but means the assertion below is "backup may exist or
  > may not" — we only assert content unchanged.

- 11 specialists deployed (or re-deployed)
- Summary says "Tool deferring enabled"

This guards against a regression where re-running on a v6 repo silently mutates settings.
