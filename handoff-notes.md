# Handoff Notes — Agent-11 (Bulk-ops toolkit shipped)

**Last Updated**: 2026-05-10
**From**: Bulk-ops toolkit session — productised the Sprint 5b patterns into reusable scripts; dogfood-tested across 19 repos
**To**: Next session — open threads only (no active sprint queued)

---

## Bulk-ops toolkit shipped 2026-05-10

The Sprint 5b bulk-migration capability is now a permanent feature, not a one-off scramble.

**What ships** (commit `21555a7`):
- `project/deployment/bulk/audit.sh` — read-only fleet status (v5 markers, library drift, branch, uncommitted count, status flag) per repo
- `project/deployment/bulk/apply-file.sh` — deploy one library file across the fleet, with stash → rebase → push fallback. Idempotent
- `project/deployment/bulk/apply-upgrade.sh` — bulk `install.sh --upgrade` with the proven Sprint 5b commit allowlist + smart D-vs-M check on v5 marker paths
- `project/deployment/bulk/lib/parse-registry.py` — hand-rolled minimal YAML parser (no PyYAML dependency)
- `project/deployment/bulk/lib/registry-template.yaml` — starter template for other agent-11 users
- `project/deployment/bulk/README.md` — usage, tier behaviour table, troubleshooting

**Jamie-personal data** (not in framework repo):
- `~/shared/tools/agent-11-fleet/registry.yaml` — 23-repo fleet (17 active, 2 local-only, 2 dormant, 1 sandbox, 1 skip)
- `~/shared/tools/agent-11-fleet/README.md` — explains the split (registry here, scripts in framework)

**Tier model** (drives every script's behaviour):

| Tier | audit | apply-file | apply-upgrade |
|---|---|---|---|
| `active` | ✓ | ✓ | ✓ |
| `local-only` | ✓ | commit only | commit only |
| `dormant` | ✓ | skipped (`--include-dormant` opts in) | skipped |
| `sandbox` | excluded | skipped | skipped |
| `skip` | skipped | skipped | skipped |
| `different-framework` | skipped | skipped | skipped |

**Dogfood result (apply-file live)**: deployed `project/field-manual/model-selection-guide.md` (the Opus 4.6 → 4.7 / Sonnet 4.5 → 4.6 bump) across the fleet. **19/19 succeeded** in ~60 seconds. 17 pushed, 2 local-only committed. 0 stash conflicts, 0 rebase fallbacks needed, 0 errors. Same operation took 90+ minutes of bespoke scripting in Sprint 5b.

**Why this matters for next time**:
- New agent-11 release? `apply-upgrade.sh --dry-run` then `apply-upgrade.sh` rolls it across the fleet
- Single-file fix? `apply-file.sh path/to/file`
- Need fleet status? `audit.sh`
- Onboarding a new repo? Add to registry, run `audit.sh` to confirm

**Override convention**: `AGENT11_FLEET_REGISTRY` env var points at any registry; default is `~/shared/tools/agent-11-fleet/registry.yaml`.

---

## Where We Are

**v6.1.0 SHIPPED 2026-05-07.** Tag `v6.1.0-hardened-upgrade-path`, GitHub release: https://github.com/TheWayWithin/agent-11/releases/tag/v6.1.0-hardened-upgrade-path

Sprint 5a delivered the single-command v5→v6 upgrade path that v5.x users now need. Nine commits, ~1,974 lines, 5 canonical test fixtures (43/43 checks passing), three new scripts, one new user-facing doc.

### What v6.1.0 ships

- `bash install.sh --upgrade` — single-command v5→v6 upgrade (opt-in)
- `bash install.sh --dry-run` — preview before running
- `bash install.sh --non-interactive` (or `--batch-safe`) — bulk-mode contract for 5b
- Settings.json surgical merge (Python 3 helper, user values win, full edge-case handling, backup→validate→auto-restore)
- `restore-pre-upgrade.sh` — first-class rollback (list, latest, --backup <path>, --settings <path>)
- `docs/UPGRADE.md` — focused upgrade guide
- `migrate-v5-to-v6.sh` — output clarity (3 distinct re-run scenarios), itemised actions

### Default behaviour on a v5.x install (no flag)

Detect-and-warn-and-exit. Preserves user agency. Auto-on detection deferred to v6.2 after `--upgrade` validates in production.

---

## Sprint 5b — Bulk migration + push (CLOSED 2026-05-09)

**Local migration sweep (2026-05-07)**: 17/17 priority repos migrated to v6.1.1, plus 2 stragglers (ASMGE, SoloCMD) added during push phase. All 19: `rc=0`, markers gone, settings preserved where existing, 0/15 stale-advisory regressions (v6.1.1 fix held in real-world bulk).

**Push phase (2026-05-09)**: 17/19 pushed to github. Hardened staging script (`/tmp/agent11-bulk-5b/push-migration.sh`) used a strict allowlist + per-repo audit; smart D-vs-M check on v5 marker paths correctly handled the Trader-7 case (handoff-notes.md re-introduced as Sprint 141 project content stayed unstaged).

**Status**:
- **Pushed (17)**: SEOAgent, aisearchmastery, freecalchub, BOS-AI, aimpactscanner-mvp, Trader-7, llm-txt-mastery, aisearcharena (rebased), aimpactmonitor (develop), PlebTest (develop), ISOTracker (rebased), modeloptix (develop), solomarket (rebased), evolve-7 (rebased), agent-11-website, mastery-ai Framework, ASMGE.
- **Local-only (2)**: Socrates, SoloCMD — no `origin` configured. Migration commits sit on local main waiting for a remote (user decision).
- **Deferred (3)**: mcp-7, mcp-11, test-project — older / sandbox-like, not actively used.

**4 repos needed a stash → pull-rebase → push → stash-pop dance**: aisearcharena, ISOTracker, solomarket, evolve-7 had a "feat: add CI failure alert" commit on remote (likely scheduled job). Resolved cleanly. Stash was needed because user-content files we deliberately left unstaged (`progress.md`, `project-plan.md`, root `CLAUDE.md`) blocked rebase.

**Logs**: `/tmp/agent11-bulk-5b/` (dry-run + real per-repo + push + rebase + stash logs).

**Naming notes for future reference**:
- "ai-search-arena" in earlier handoff = `/Users/jamiewatters/DevProjects/aisearcharena` (no hyphens).
- "Trader-7" = `/Users/jamiewatters/DevProjects/Trader-7` (was previously also called "llm-trading-system").
- `mastery-ai Framework` has a literal space in the directory name — quote when scripting.

**Skip (still applies if any future bulk sweep)**: geo-benchmark-framework — no `.claude/` deployed.

**BusinessProjects with `.claude/`**: Those are BOS-AI projects (different framework), NOT agent-11. They do not need agent-11 v5→v6 migration.

**Side deliverable in agent-11 repo**: `project/field-manual/model-selection-guide.md` bumped to Opus 4.7 / Sonnet 4.6 (commit `43b2011`). Doc-rot fix only — library agents use model aliases that already auto-resolve.

---

## Other open threads

- **BOS-AI v2 evolution**: Blueprint at `Ideation/BOS-AI v2 Blueprint_ The Lean Business Operating System` (still uncommitted). Earlier in this conversation we identified ~7 empirical lessons from agent-11 v6.0 sprints that the Blueprint missed. Refinement deferred until BOS-AI is checked out locally for codebase assessment.
- **Dogfooding gap**: this repo (agent-11) still has both `agent-context.md` AND `handoff-notes.md` at root. We retired `handoff-notes.md` in user installs (Sprint 4e) but the agent-11 dev repo itself still uses both. Flag if Jamie wants to self-migrate — the new `bash install.sh --upgrade` would handle it now.

---

## Key Files

| File | Purpose |
|------|---------|
| `sprints/sprint-5a-install-upgrade-path.md` | Sprint 5a spec (closed) |
| `progress.md` | Chronological log; T9 close-out entry dated 2026-05-07 |
| `project-plan.md` | v6.0 evolution overview |
| `library/CLAUDE.md` | 78 lines — deployed user-facing instructions (now v6.1) |
| `library/settings.json.template` | v6.0 settings template (used by T3 merger) |
| `project/deployment/scripts/install.sh` | Now ~1,884 lines — adds T1/T2/T3/T4/T8 |
| `project/deployment/scripts/migrate-v5-to-v6.sh` | UX-clarified per T5 |
| `project/deployment/scripts/merge-settings.py` | NEW — surgical settings merge (T3) |
| `project/deployment/scripts/restore-pre-upgrade.sh` | NEW — rollback (T7) |
| `docs/UPGRADE.md` | NEW — focused v5→v6 guide (T7) |
| `test-projects/install-fixtures/` | 5 canonical end-to-end fixtures + run-all.sh (T6) |

---

## Notes for Fresh Session

- `origin/main` is at the v6.1.0 tag. Working tree clean (modulo BOS-AI Blueprint untracked).
- Jamie's terminal wraps long lines silently — one command per code block; prefer local paths over URLs; split long URLs into shell vars if needed.
- Jamie has ADHD. One action per response. Anchored to what's on screen now. No trailing caveats. When deciding: 2-3 options with trade-offs, help him choose. Brief context, specific steps.
- British English by default.
- **Library vs working squad**: edits target `project/agents/specialists/`, `project/commands/`, `library/` (deployed). `.claude/agents/` and `.claude/commands/` are internal — only touch with explicit decision.
- **Never commit, push, or deploy without explicit confirmation**. Same for any destructive git op.
- **No active sprint queued.** Open threads above are the only candidates. v6.2 (auto-on detection of v5 markers without `--upgrade` flag) was deferred from Sprint 5a pending production validation of `--upgrade`; that validation now exists (17 successful real-world upgrades), so v6.2 is unblocked when ready.
