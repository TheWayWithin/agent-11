# Fixture 02: v5 + user-customised settings.json

## Pre-state

A v5 install with a user-customised `.claude/settings.json` that has:
- A custom `permissions` block (allow + deny lists)
- Custom `env` keys (not just AGENT-11 defaults)
- A `_comment` describing the user's intent

The settings.json predates v6 — it has neither `ENABLE_TOOL_SEARCH` nor `hooks`.

## Run

```bash
bash install.sh --upgrade
```

## Expected post-state

The merge contract: **user values win, template only fills gaps**. After the run:
- All custom permissions preserved (allow + deny)
- All custom env keys preserved
- `_comment` preserved
- `ENABLE_TOOL_SEARCH=auto` added to env (alongside the user's keys)
- `hooks` block added from the template
- Backup of the original settings.json present at `.claude/settings.json.backup-*`
- Summary says "Tool deferring enabled"

This guards against the worst-case regression: silent overwriting of user customisations.
