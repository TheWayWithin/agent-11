# Fixture 04: Partial-migration recovery

## Pre-state

A directory in inconsistent v5 state — simulating an earlier migration that was interrupted partway:
- Some v5 markers already removed (e.g. `handoff-notes.md` is gone)
- Other v5 markers still present (e.g. `templates/handoff-notes-template.md` still there)
- A stale `.claude/backups/v5-to-v6-<old-timestamp>/` directory from the prior interrupted run
- Valid `.claude/settings.json` (no v6 features yet)

## Run

```bash
bash install.sh --upgrade
```

## Expected post-state

The migration should be idempotent and recover gracefully:
- "Prior migration backup found" notice in the migration output
- "completing the remaining migration steps" notice
- All remaining v5 markers cleaned up
- A new backup directory created for THIS run (the old one preserved)
- Settings merged successfully
- 11 specialists deployed
- Summary says "Tool deferring enabled"
