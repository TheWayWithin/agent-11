# Sprint 5a: Install Upgrade Path — Hardened v5→v6 for Existing Repos

**Part of**: Agent-11 v6.0 post-launch maintenance
**Predecessor**: Sprint 4h — Validation + Migration ✅ (v6.0 shipped 2026-05-03)
**Successor**: Sprint 5b — bulk-migration of Jamie's 17 active priority repos using the install.sh shipped here
**Status**: Spec revised post dev + architect review (path A). Ready for execution on Jamie's approval.
**Target release**: **v6.1.0 (minor)** — auto-migrate is new behaviour, not a bug-fix-only patch

---

## Goal

Make `install.sh` capable of taking a v5.x repo to a clean v6.0 state via a single explicit command (`bash install.sh --upgrade`), including settings.json merge, with a documented rollback path and graceful behaviour on the realistic edge cases that exist in the wild.

## Why This Sprint

Three concrete observations from migrating `JamieWatters` on 2026-05-03:

1. **The two-script flow is brittle.** Users must know to run `migrate-v5-to-v6.sh` *before* `install.sh`. Jamie ran install first, ended up in a hybrid state (v6 library deployed, v5 residue still on disk), and only the migration script then knew how to clean up.

2. **`install.sh` refuses to update existing settings.json.** Current behaviour: detect existing `.claude/settings.json`, log a warning, move on. But the post-install summary then prints `✓ Tool deferring enabled (ENABLE_TOOL_SEARCH=auto in .claude/settings.json)` — which is **false** when settings.json wasn't actually updated.

3. **`migrate-v5-to-v6.sh` UX is confusing on a successful run.** Output after a real migration is identical to the no-op case — the user can't tell whether work was done.

These are not blockers for v6.0 itself. They are blockers for the **upgrade path** that v5.x users need.

## Why v6.1.0, not v6.0.1

Per semver, patch releases are bug-fix-only. This sprint adds:
- New CLI flags (`--upgrade`, `--dry-run`, `--non-interactive`)
- Auto-migration behaviour gated behind opt-in flag
- Settings.json merge logic that mutates user files
- Documented rollback workflow

That is **new behaviour with destructive operations**. Minor version bump is correct.

## Scope (in)

- `project/deployment/scripts/install.sh` — main behavioural changes
- `project/deployment/scripts/migrate-v5-to-v6.sh` — UX fixes + idempotency contract
- New helper for JSON merging (Python 3 with documented bash fallback)
- Test fixtures covering the realistic v5→v6 variants
- Rollback documentation (script + manual recovery flow)
- Public docs that mention the upgrade flow (README v5.x section, MCP-GUIDE migration section, RELEASE-HISTORY for the v6.1.0 entry)

## Scope (out — explicit)

- **Bulk migration of Jamie's 17 priority repos** — that's Sprint 5b. This sprint produces the tool; the next runs it.
- **Greenfield install behaviour changes.** install.sh on a fresh repo continues to behave exactly as today. Upgrade path only kicks in with `--upgrade` flag.
- **Refactor of install.sh internals.** Surgical additions only.
- **Default-on auto-detection of v5.** Deferred to v6.2 after `--upgrade` validates in production.
- **`bin/agent-11` CLI with subcommands** (architect's larger-fix proposal) — deferred to v7.0 design discussion.
- **`agent-11` repo's own `.claude/`** — working squad, out of scope.

---

## Tasks

### T1. Detect v5.x markers + gate behind `--upgrade` flag

**What**: Early in `install.sh`, after the existing `.claude/agents/` detection, scan for v5 markers. Behaviour depends on `--upgrade` flag.

**Markers** (same set as `migrate-v5-to-v6.sh` already uses):
- `handoff-notes.md` (root)
- `.mcp-profiles/` directory
- `mcp/dynamic-mcp.json`
- `templates/handoff-notes-template.md`

**Behaviour matrix**:

| v5 markers? | `--upgrade` flag? | Behaviour |
|---|---|---|
| No | — | Normal greenfield/v6 reinstall flow (unchanged from today) |
| Yes | No | **Detect-and-warn**: print clear notice that v5 residue exists, instruct user to re-run with `--upgrade`, exit non-zero |
| Yes | Yes | Run migration as subprocess (T2), then continue install |

**Why opt-in**: Auto-migrate without explicit consent is risky for first release. Detect-and-warn surfaces the problem without silently mutating user state. Users explicitly opt in via `--upgrade` once they've read the notice.

**Acceptance**:
- v5-marker repo + no flag → script exits with clear migration instructions, no mutation
- v5-marker repo + `--upgrade` → migration runs, install continues, ends in clean v6 state
- Greenfield repo (no markers) → flag is silently ignored, normal install runs
- All paths idempotent (re-runs safe)

### T2. Invoke migrate-v5-to-v6.sh as subprocess (single source of truth)

**Decision: A — invoke, don't inline.** Locked.

**Implementation contract**:
1. install.sh resolves migrate-v5-to-v6.sh path:
   - First check: same directory as install.sh
   - Fallback: download from `main` branch of GitHub if missing (curl-streamed install case)
2. Invoke as subprocess with explicit `--yes` flag
3. **Subprocess error handling** (dev review concern):
   - `set -e` does NOT propagate through subprocess — must check `$?` explicitly
   - On non-zero exit: abort install with clear error, point at migration log
4. **Working-directory contract**: install.sh and migrate-v5-to-v6.sh both treat `$(pwd)` as the target repo root. Document this explicitly in both scripts.

**Acceptance**:
- Subprocess failure aborts install cleanly with diagnostic
- Re-running install.sh after a failed migration does the right thing (idempotency)
- Both scripts behave identically when invoked from any working directory inside the target repo (top level only — subdirs out of scope)

### T3. Settings.json surgical merge with validation + auto-restore

**What**: When existing `.claude/settings.json` is found *without* v6 signals (no `ENABLE_TOOL_SEARCH`, no `hooks` key), perform a surgical merge instead of leaving-and-warning.

**Merge contract**:
- **Preserve**: existing `permissions` block (allow/ask/deny), any existing `env` keys, any custom keys not in the template
- **Add**: `ENABLE_TOOL_SEARCH: "auto"` to `env`
- **Add**: full `hooks` block from template if not present
- **Conflict resolution** (architect concern): when v5 and v6 both define a key (e.g. `mcpServers.github`), **user value wins**. Template only fills gaps. Document this.
- **Skip merge if**: settings.json already has both `ENABLE_TOOL_SEARCH` AND `hooks` (already on v6)

**JSON edge cases** (dev review concern — these exist in real user files):
- Trailing commas → reject with clear error, don't try to parse
- `_comment` keys → preserve
- BOM-prefixed files → strip BOM before parse
- `$schema` keys → preserve
- Duplicate keys → reject with error (Python's `json.load` already does this; surface it cleanly)

**Implementation**:
- **Primary**: Python 3 with `json` module (deterministic, no external deps when present)
- **Fallback when Python 3 missing** (architect concern — Alpine, minimal Debian, pre-12.3 macOS):
  - Write merged template as `.claude/settings.json.new` alongside the original
  - Print clear instructions: "Python 3 not available. Settings template written to settings.json.new. Manually merge: <link to docs>"
  - Exit non-zero so the install summary can flag this
- **Detection**: `command -v python3 >/dev/null 2>&1` before attempting merge

**Validation + auto-restore** (architect concern — silent corruption is worst-case failure):
1. Always backup settings.json to `.claude/.backups/settings.json.<timestamp>` before merge
2. After merge, validate output: `python3 -m json.tool < settings.json >/dev/null`
3. If validation fails: restore from backup automatically, log error, exit non-zero
4. Document restore command in T7 rollback docs

**Bash portability** (dev concern):
- Use `sed -i.bak` form (works on both macOS and GNU sed) where any sed is needed
- No bash-4-only features (associative arrays, `${var,,}`)

**Acceptance**:
- Test fixture: pre-v6 settings.json with rich permissions → post-install settings.json has all original permissions PLUS env updated PLUS hooks block, valid JSON
- Test fixture: settings.json already on v6 → no-op (no unnecessary backup, no diff)
- Test fixture: malformed settings.json → install fails clearly, doesn't corrupt state
- Test fixture: Python 3 unavailable → settings.json.new written, install exits non-zero with clear message
- Test fixture: user-customised mcpServers.github → user value preserved, not overwritten
- Test fixture: post-merge corruption → backup auto-restored, install fails cleanly

### T4. Fix the post-install summary lie

**What**: The "✓ Tool deferring enabled" message must reflect actual state.

**Fix**: Track `SETTINGS_HAS_V6_FEATURES=true|false` flag during install. Summary conditionally renders:
- True → `✓ Tool deferring enabled`
- False → `⚠ Tool deferring NOT enabled — settings.json was preserved without changes. See: <link to manual merge instructions>`

**Acceptance**: No test run prints "✓ Tool deferring enabled" when ENABLE_TOOL_SEARCH is not actually set in the on-disk file.

### T5. Migration script output clarity

**What**: Fix the confusing post-success message in `migrate-v5-to-v6.sh`.

**Fix**: Track whether migration actually performed work. Distinguish:
- **Ran and succeeded**: `[SUCCESS] Migration complete — v5.x markers cleaned, handoff folded into agent-context.md. Backup: <path>`
- **Already on v6 (no-op)**: `[SUCCESS] No v5.x markers detected. Already on v6.0 — no migration needed.`
- **Idempotent re-run after partial migration**: clear message about what was completed vs skipped

**Acceptance**: Output unambiguously distinguishes the three cases above.

### T6. Test fixtures — five variants

**Single happy-path fixture is insufficient** (both reviewers flagged). Build five fixtures under `test-projects/`:

1. **`t1-v5-upgrade-clean/`** — minimal v5 install, default settings.json, the happy path. Must end in clean v6.
2. **`t1-v5-upgrade-custom-mcp/`** — v5 with user-customised mcpServers.github + custom permissions. Asserts user values preserved through merge.
3. **`t1-v5-upgrade-malformed-json/`** — settings.json with trailing comma. Asserts install fails cleanly without corrupting state.
4. **`t1-v5-upgrade-partial/`** — partially migrated repo (v5 markers gone, v5 settings.json still present). Asserts idempotent recovery.
5. **`t1-v5-upgrade-already-v6/`** — repo already on v6. Asserts true no-op (no backup created, no diff).

**Each fixture has**:
- README.md describing the scenario and expected outcome
- Assertion script (`run-test.sh`) that runs install.sh and checks all post-conditions
- Reference snapshot of expected post-state (where determinism allows)

**This expanded fixture set is the acceptance gate for shipping v6.1.0.**

### T7. Rollback documentation + restore command

**What**: Document and ship a restore path. Backups exist; the restore flow does not.

**Deliverables**:
1. **Restore command**: small helper script `project/deployment/scripts/restore-pre-upgrade.sh` that:
   - Lists available backups in `.claude/.backups/`
   - Restores selected backup with confirmation
   - Reports what was restored
2. **Doc section** in `docs/MCP-GUIDE.md` (or new `docs/UPGRADE.md`):
   - When to roll back
   - How to roll back manually (the file moves)
   - How to roll back via the restore script
   - What the restore does NOT recover (e.g. uncommitted edits to deleted files)
3. **install.sh references** rollback in its post-install summary on any non-clean exit

**Acceptance**: Test the restore flow against fixture 3 (malformed JSON aborted install). User can return to pre-install state in one command.

### T8. CLI flag surface — `--upgrade`, `--dry-run`, `--non-interactive`

**What**: Add three flags to install.sh. Document in `--help`.

- **`--upgrade`** (T1): explicit opt-in for v5→v6 auto-migration
- **`--dry-run`** (dev's quick-win): scan, plan, report — make zero changes. Prints what would happen and exits 0.
- **`--non-interactive`** / **`--batch-safe`** (architect's 5a→5b seam): no prompts, no TTY-only behaviour, exit non-zero on any condition that would require human input. Sprint 5b's bulk wrapper depends on this contract.

**Acceptance**:
- `--help` documents all three flags + the existing ones
- `--dry-run` produces a deterministic plan (same input → same output) and never mutates
- `--non-interactive` fails fast on any prompt path; CI-friendly exit codes
- All three composable: `--upgrade --dry-run --non-interactive` valid combination

### T9. Public release v6.1.0

**What**:
- README v5.x → v6.0 section: replace two-step with `bash install.sh --upgrade`
- `docs/MCP-GUIDE.md` migration section: same simplification + rollback link
- `docs/RELEASE-HISTORY.md`: v6.1.0 minor entry
- `CHANGELOG.md`: v6.1.0 entry covering T1–T8
- New tag `v6.1.0` and GitHub release

**Acceptance**: Public-facing docs accurate. Release notes flag `--upgrade` as opt-in for first release with rationale.

---

## Decisions (locked)

1. **Version label**: **v6.1.0 minor** (not v6.0.1 patch). Auto-migrate is new behaviour with destructive ops.
2. **Auto-migrate consent**: **Opt-in via `--upgrade` flag** for first release. Default-on auto-detection deferred to v6.2 after production validation.
3. **JSON merge tool**: **Python 3** primary, with `.settings.json.new` fallback when Python 3 missing.
4. **Conflict resolution**: **User value wins** when v5 and v6 both define a key. Template fills gaps only.
5. **Single source of truth**: install.sh invokes migrate-v5-to-v6.sh as subprocess (decision A); does not inline.
6. **Subprocess error handling**: explicit `$?` check; do not rely on `set -e` propagation.
7. **Working-directory contract**: both scripts treat `$(pwd)` as target repo root.
8. **Backup-and-validate**: settings.json mutations always backup-then-validate-then-restore-on-fail.

## Deferred (not this sprint)

- **Default-on auto-detection** of v5 markers → v6.2.0 after `--upgrade` validates
- **`bin/agent-11` CLI with subcommands** (architect's larger fix) → v7.0 design discussion
- **Sprint 5b** bulk migration tooling — depends on `--non-interactive` flag landing here

---

## Acceptance Criteria (sprint-level)

- [ ] All 5 test fixtures pass independently
- [ ] No "settings.json lie" in post-install summary
- [ ] Migration script output unambiguously distinguishes "migrated" / "already migrated" / "partial recovery"
- [ ] Rollback documented + restore script tested against fixture 3
- [ ] `--upgrade`, `--dry-run`, `--non-interactive` flags work and compose
- [ ] Python 3 fallback path tested (manual: invoke with PATH excluding python3)
- [ ] Public docs updated; v6.1.0 tagged + released
- [ ] Sprint 5b ready to start with documented `--non-interactive` contract

## Out-of-Sprint Follow-ups

- **Sprint 5b — Bulk migration**: 17 priority repos using `--upgrade --non-interactive` in a small batch wrapper
- **BusinessProjects triage**: 14 repos with `.claude/` deployed in `~/BusinessProjects/` — state unknown
- **Default-on auto-detection** for v6.2.0 — re-evaluate after `--upgrade` data
- **`bin/agent-11` CLI** — design discussion for v7.0

---

**Ready for review. On approval, execution starts with T1 + T6 (fixtures 1 + 5) in parallel — build the detection path and test it against the easiest cases first, then layer in T2/T3 with the harder fixtures.**
