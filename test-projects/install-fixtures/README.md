# Install fixtures (Sprint 5a T6)

End-to-end tests for `install.sh --upgrade` and supporting scripts. Each fixture spins up a self-contained pre-state under `mktemp -d`, runs the installer, and asserts post-conditions. Tests clean up after themselves on success.

## Running

All fixtures:

```bash
bash test-projects/install-fixtures/run-all.sh
```

Single fixture:

```bash
bash test-projects/install-fixtures/01-clean-v5/run-test.sh
```

## Fixtures

| # | Scenario | Asserts |
|---|---|---|
| 01 | Clean v5 install (4 markers, no settings.json) | Migration cleans markers; agents deploy; settings.json deployed verbatim with v6 features |
| 02 | v5 + user-customised settings.json (permissions + custom env keys) | User values preserved through merge; ENABLE_TOOL_SEARCH + hooks added |
| 03 | v5 + malformed settings.json (trailing comma) | Merge fails cleanly; original settings.json restored from backup; summary truthful ("NOT enabled"); rest of install completes |
| 04 | Partial-migration recovery (some markers gone, prior backup present) | Remaining markers cleaned; "completing remaining migration steps" notice; idempotent |
| 05 | Already on v6 (no markers, v6 settings.json) | No migration triggered; settings.json untouched; install proceeds normally |

## Convention

Each fixture has:
- `README.md` — scenario description + expected outcome
- `run-test.sh` — executable test (exits 0 on pass, 1 on fail)

`run-all.sh` runs every `run-test.sh` and reports an aggregate pass/fail count.

## Why these five

Architect + dev review of the Sprint 5a spec flagged that a single happy-path fixture was insufficient. These five cover:
- The canonical happy path (01)
- The "user values must be preserved" risk (02)
- Bad-input handling without state corruption (03)
- Idempotency of partial state (04)
- True no-op on already-v6 installs (05)

If any of these regress in future sprints, the runner will catch it.
