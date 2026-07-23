# Upgrading AGENT-11 v5.x → v6.0

This guide covers upgrading an existing v5.x install to v6.0. For a fresh install, see [GETTING-STARTED.md](GETTING-STARTED.md).

## TL;DR

From the root of your project (the directory that contains `.claude/`):

```bash
bash <(curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/install.sh) --upgrade
```

That's it. The installer detects the v5 markers, runs the migration, then deploys v6.0.

If you want to see what would happen first, add `--dry-run`.

## Why a flag is required

v6.0 retired several v5 components (the `.mcp-profiles/` profile-switching system, the standalone `handoff-notes.md` workflow, `mcp/dynamic-mcp.json`, and the `handoff-notes-template.md`). Migrating off these involves moving and deleting files, so the installer requires explicit consent via `--upgrade`.

If you run `bash install.sh` without the flag on a v5 install, it detects the v5 markers and exits with instructions rather than silently mutating your project.

## What the upgrade does

1. **Folds `handoff-notes.md` into `agent-context.md`** (Sprint 4e — single accumulator file)
2. **Removes `.mcp-profiles/`** (Sprint 4f — replaced by dynamic tool search)
3. **Removes `mcp/dynamic-mcp.json`** (wrong schema for Claude Code)
4. **Removes `templates/handoff-notes-template.md`**
5. **Merges v6 settings** into your existing `.claude/settings.json`:
   - Adds `env.ENABLE_TOOL_SEARCH = "auto"`
   - Adds the `hooks` block (advisory `tsc`/`ruff`/`rubocop` + destructive-command prompt)
   - **v6.2.0**: adds the **read-only quality gates** `permissions.deny` block (makes `.quality-gates.json` and `gates/` unwritable by agents via Edit/Write/MultiEdit) and a blocking **PreToolUse "read-only gate guard"** hook (refuses Bash writes to gate paths; the guard logic lives in `.claude/hooks/gate-guard.sh`, deployed alongside)
   - **Refreshes AGENT-11-shipped hooks** (A11-ISS-9): a hook entry that is byte-identical to a version AGENT-11 shipped is upgraded to the current version. Hooks you added yourself — or shipped hooks you edited (e.g. promoted from advisory to blocking) — are preserved exactly as you left them, never duplicated or reverted
   - **Preserves all your existing keys** — user values win on conflict for `env`, `permissions` and everything else; the template only fills gaps
6. **Re-deploys the v6 library**: 11 specialists, missions, templates, field-manual, MCP setup, skills, schemas, gates

### v6.2.0: changing a quality gate deliberately

After upgrading, agents can no longer edit `.quality-gates.json` or anything under `gates/` — that is the point (an agent must not be able to loosen the criteria that judge its own work). To change a gate **as a deliberate human action**, temporarily remove the relevant `permissions.deny` rules from `.claude/settings.json`, make the edit yourself, then restore the rules. Never let an agent revise a gate mid-mission to make a phase pass.

## What gets backed up

Two backup locations are created during upgrade:

| Backup | Contents | Created by |
|---|---|---|
| `.claude/backups/v5-to-v6-<timestamp>/` | All v5 files removed by the migration | `migrate-v5-to-v6.sh` |
| `.claude/settings.json.backup-<timestamp>` | Your previous settings.json before the merge | `install.sh` |

Both are preserved indefinitely. Delete them once you're satisfied the upgrade went well.

## Preview the plan first

```bash
bash install.sh --upgrade --dry-run
```

This prints what would happen without making any changes:
- Whether v5 markers are detected (and which ones)
- What the settings.json merger would do (verbatim deploy / merge / no-op / fall back to `.new` file)
- The list of files that would be deployed

For migration-script details specifically:

```bash
bash migrate-v5-to-v6.sh --dry-run
```

## Rolling back

If something goes wrong (or you change your mind), use the restore script:

```bash
# List available backups
bash <(curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/restore-pre-upgrade.sh) --list

# Restore the most recent migration backup interactively
bash <(curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/restore-pre-upgrade.sh)

# Or non-interactively
bash restore-pre-upgrade.sh --latest --yes
```

To restore just the settings.json (keeping v6 library files):

```bash
bash restore-pre-upgrade.sh --settings .claude/settings.json.backup-<timestamp>
```

### What restore does NOT recover

- **Files added or modified after the migration** — the backup is a snapshot from the moment of the upgrade
- **Uncommitted edits to deleted files** — only the on-disk state at upgrade time was backed up
- **Library files deployed by install.sh** — restoring v5 markers brings the *project* back to v5 layout but doesn't redeploy the v5 library. To return fully to v5: restore + manually re-install v5.x from a previous tag

## Manual recovery (without the script)

The migration backups are plain directories — you can restore by hand:

```bash
# Bring the v5 files back
cp .claude/backups/v5-to-v6-<timestamp>/handoff-notes.md ./handoff-notes.md
cp -r .claude/backups/v5-to-v6-<timestamp>/.mcp-profiles ./.mcp-profiles
mkdir -p mcp && cp .claude/backups/v5-to-v6-<timestamp>/dynamic-mcp.json ./mcp/dynamic-mcp.json
mkdir -p templates && cp .claude/backups/v5-to-v6-<timestamp>/handoff-notes-template.md ./templates/

# Restore settings.json
cp .claude/settings.json.backup-<timestamp> .claude/settings.json
```

## Bulk upgrade (multiple repos)

If you run AGENT-11 across more than a handful of repos, use the [bulk-ops toolkit](../project/deployment/bulk/):

```bash
# Dry-run first to see what would happen across the fleet
bash project/deployment/bulk/apply-upgrade.sh --dry-run

# Run for real — handles stash/rebase/push for divergent remotes
bash project/deployment/bulk/apply-upgrade.sh
```

The toolkit reads a registry file you maintain yourself (template at `project/deployment/bulk/lib/registry-template.yaml`). Tier-aware (`active`, `local-only`, `dormant`, etc.) so dormant or non-agent-11 repos don't get swept up. Includes a smart D-vs-M check on retired v5 marker paths — handles repos that have re-introduced same-named files as project content. See [`project/deployment/bulk/README.md`](../project/deployment/bulk/README.md) for full usage.

For ad-hoc loops without the toolkit, the bare-bones pattern still works:

```bash
for repo in repo1 repo2 repo3; do
    cd "$repo"
    bash install.sh --upgrade --non-interactive || echo "FAILED: $repo"
    cd ..
done
```

`--non-interactive` makes the script fail fast on any condition that would have prompted for input — safe for CI / scripts.

## Known limitations

- **Python 3 required for settings.json merge.** If `python3` is not on PATH, the installer writes a `.claude/settings.json.new` file with merge instructions and continues. Install Python 3 (or merge manually using the `.new` file as reference) to enable v6 features.
- **Migration backup is structurally lossy for nested files.** `mcp/dynamic-mcp.json` is backed up as `dynamic-mcp.json` (basename only) — the restore script knows the mapping, but if you restore manually, place the file at `mcp/dynamic-mcp.json` not the project root.
- **Auto-detection of v5 is opt-in for v6.1.0.** Future versions may default-on after `--upgrade` validates in the wild.

## Troubleshooting

**"v5.x install detected. AGENT-11 v6.0 has retired several v5 components."**
You ran the installer without `--upgrade` on a v5 project. Re-run with the flag.

**"settings.json merge failed (exit 1):"**
Your existing settings.json has a JSON syntax error (commonly: trailing comma). Fix the JSON and re-run. The original file is preserved.

**"python3 not found — cannot perform automatic settings.json merge"**
Install Python 3, or merge `.claude/settings.json.new` into `.claude/settings.json` manually using a JSON editor.

**The migration script ran twice and reported "no markers detected" the second time.**
That's correct behaviour — the second run finds zero v5 markers because the first run cleaned them. From v6.1.0 onwards, the message distinguishes "completed previously" from "always on v6". Look for the `Most recent migration backup:` line.

For anything else, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md).
