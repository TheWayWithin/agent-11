# Fixture 03: v5 + malformed settings.json

## Pre-state

A v5 install with a `.claude/settings.json` that contains a trailing comma — invalid JSON per RFC, rejected by `python3 -m json.tool`.

## Run

```bash
bash install.sh --upgrade
```

## Expected post-state

The merge step should fail clearly without corrupting state:
- v5 markers still get cleaned (migration runs as a separate step)
- `merge-settings.py` rejects the malformed input with an explanatory error
- Original (still-malformed) `.claude/settings.json` restored from backup
- Backup file present at `.claude/settings.json.backup-*`
- Post-install summary says "Tool deferring NOT enabled"
- Pointer to `docs/UPGRADE.md` and the restore script in the summary
- The rest of the install (agents, missions, etc.) completes
- `bash run-test.sh` exits 0 (the merge failure is expected)

This protects against the architect's worst-case scenario: silent settings.json corruption that Claude Code then ignores.
