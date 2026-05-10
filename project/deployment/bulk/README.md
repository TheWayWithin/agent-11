# Bulk-Ops Toolkit

Scripts for managing a fleet of agent-11-using repos. Designed for users with multiple projects who want one command to roll a framework update across all of them.

## What's here

```
project/deployment/bulk/
├── audit.sh         # Read-only fleet status report
├── apply-file.sh    # Deploy one library file across the fleet
├── apply-upgrade.sh # Run install.sh --upgrade across the fleet
└── lib/
    └── parse-registry.py   # Minimal YAML parser for the fleet registry
```

## How it works

The bulk scripts read a **registry file** that lists every repo you want to manage, with metadata (path, branch, tier, notes). The registry is *yours*: it lives outside this repo so it doesn't get versioned alongside the framework.

Default registry location: `~/shared/tools/agent-11-fleet/registry.yaml` (override via the `AGENT11_FLEET_REGISTRY` env var).

A starter registry template is included at `lib/registry-template.yaml`. Copy it to your preferred location and edit.

## Tier behaviour

Every repo in the registry has a `tier:` field. Each tier behaves differently across the operations:

| Tier | audit | apply-file | apply-upgrade |
|---|---|---|---|
| `active` | included | included, push enabled | included, push enabled |
| `local-only` | included | commit only (no push) | commit only (no push) |
| `dormant` | included | skipped (`--include-dormant` opts in) | skipped (`--include-dormant` opts in) |
| `sandbox` | excluded by default | skipped | skipped |
| `skip` | excluded | skipped | skipped |
| `different-framework` | excluded | skipped | skipped |

Use `tier: skip` rather than deleting old entries — preserves history and prevents repos drifting back into the fleet later.

## Operations

### `audit.sh`

Read-only. Reports per-repo state: path existence, v5 markers, library drift (deployed `.claude/CLAUDE.md` hash vs source), branch, uncommitted file count, computed status flag.

```bash
bash audit.sh                            # default tiers (active, local-only, dormant)
bash audit.sh --tier=active              # active only
bash audit.sh --tier=active,local-only,dormant,sandbox  # everything
```

Exit code: 0 if everything is ok, 1 if any repo needs upgrade or has drifted.

### `apply-file.sh`

Deploy one library file across the fleet. The path argument is *library-relative* (e.g. `project/field-manual/foo.md`); the script computes the target path in each repo by stripping the `project/` prefix (matching install.sh's deploy convention).

```bash
# Dry-run first
bash apply-file.sh project/field-manual/model-selection-guide.md --dry-run

# Deploy for real
bash apply-file.sh project/field-manual/model-selection-guide.md

# Custom commit message
bash apply-file.sh project/field-manual/model-selection-guide.md \
  --message="docs(field-manual): bump model tier to Claude Opus 5"
```

Per-repo behaviour:
1. Skips if file already matches (idempotent — safe to re-run)
2. Stashes any unstaged tracked changes
3. Stages just the one file
4. Commits with the generated or custom message
5. Pushes (with one rebase retry if rejected)
6. Pops the stash

Use this for surgical updates: a single doc change, a bug fix in one library file, etc. For full framework upgrades, use `apply-upgrade.sh`.

### `apply-upgrade.sh`

Bulk `install.sh --upgrade --non-interactive` across the fleet. Designed for major framework releases (e.g. v5 → v6, v6 → v7).

```bash
# Dry-run first — strongly recommended
bash apply-upgrade.sh --dry-run

# Run for real
bash apply-upgrade.sh

# Include dormant repos
bash apply-upgrade.sh --include-dormant
```

Per-repo behaviour:
1. Runs `install.sh --upgrade --non-interactive` (logs to per-repo file)
2. Stages migration paths only (proven Sprint 5b allowlist)
3. Smart D-vs-M check on v5 marker paths (handles repos that re-introduced same-named files as project content; example: Trader-7 with a project `handoff-notes.md`)
4. Audits staging — aborts commit if user-content files or backup artefacts got staged
5. Commits with framework upgrade message
6. Stash → pull-rebase → push → pop dance for repos with divergent remotes

Backup of pre-upgrade state lands in each repo's `.claude/backups/v5-to-v6-<timestamp>/` for rollback via `restore-pre-upgrade.sh`.

## Safety properties

- **Idempotent**: running `apply-file` twice with the same source has no effect on the second run
- **Local-first**: `--dry-run` shows what would happen; commit-only for repos without remotes
- **Whitelist-based commit staging**: framework files only; never commits user content
- **Audit guards**: every script aborts a commit if it detects backup artefacts or user-content paths in the staged set
- **Per-repo logs**: full output of each operation lands in `/tmp/agent11-<op>-<timestamp>/<repo>.log` for post-hoc review

## Prerequisites

- Bash 4+ (macOS default Bash 3 works for these scripts)
- Python 3 (used by `lib/parse-registry.py`)
- Git
- A populated registry at the default location or pointed to via `AGENT11_FLEET_REGISTRY`

No external Python packages required — the registry parser is hand-rolled.

## Adding a new repo to the fleet

1. Run `bash <(curl -sSL ...install.sh)` in the new repo to deploy agent-11
2. Add an entry to your registry:
   ```yaml
   - name: my-new-repo
     path: /Users/me/DevProjects/my-new-repo
     remote: https://github.com/me/my-new-repo.git
     branch: main
     tier: active
     notes: ""
   ```
3. Run `bash audit.sh` to confirm it's picked up

## Troubleshooting

**Audit shows "drift" but I just upgraded that repo.** The library hash changed in the source repo (e.g. you edited `library/CLAUDE.md` after deploying). Re-run `apply-upgrade.sh` to sync.

**`apply-upgrade` reports "needs upgrade" for a repo with no v5 markers.** Likely a project re-introduced a file that shares a v5 marker name (e.g. Trader-7's project-content `handoff-notes.md`). The D-vs-M check inside `apply-upgrade` handles this correctly — the audit just reports honestly.

**Push fails on a repo with no remote.** Mark it `tier: local-only` in the registry. The script will commit but skip the push.

**Stash failed.** Likely your working tree has changes the script can't auto-stash. Manually commit or stash, then re-run.
