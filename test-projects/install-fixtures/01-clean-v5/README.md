# Fixture 01: Clean v5 install

## Pre-state

A minimal v5.x AGENT-11 install:
- All 4 v5 marker files present (`handoff-notes.md`, `.mcp-profiles/`, `mcp/dynamic-mcp.json`, `templates/handoff-notes-template.md`)
- `.claude/agents/coordinator.md` (so `migrate-v5-to-v6.sh`'s `detect_agent11` returns true)
- **No** existing `.claude/settings.json` (greenfield-style for the settings step)

## Run

```bash
bash install.sh --upgrade
```

## Expected post-state

- All 4 v5 markers removed
- `agent-context.md` created (folded from `handoff-notes.md`)
- Migration backup directory present at `.claude/backups/v5-to-v6-*/`
- 11 specialists deployed under `.claude/agents/`
- `.claude/settings.json` deployed verbatim with `ENABLE_TOOL_SEARCH=auto` and `hooks` block
- Post-install summary says "Tool deferring enabled"
- `bash run-test.sh` exits 0
