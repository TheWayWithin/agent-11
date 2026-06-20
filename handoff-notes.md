# Handoff Notes — Agent-11 (Sprint 6c complete)

**Last Updated**: 2026-06-20
**From**: Sprint 6c session — phase-gated meta-loop (convergence, per-phase error budget, condensed returns, restart-from-last-passed-gate) wired into `coordinator.md`; T4 found the Bash gate-route and shipped a blocking PreToolUse hook; Sprint 6d promoted to a detailed spec.
**To**: Next session — Sprint 6d (consolidation + v6.2.0 release) on Jamie's approval. Gate met (6a/6b/6c all shipped).

## Sprint 6c current state (2026-06-20) — COMPLETE
- `coordinator.md`: `/coord continue` is now a phase-gated meta-loop. Condensed returns + restart-from-last-passed-gate added.
- `settings.json.template`: blocking "read-only gate guard" PreToolUse hook closes the Bash write route the 6a deny rules missed. JSON valid.
- Docs: `library/CLAUDE.md`, `coord.md`, `loop-discipline-guide.md` updated.
- `sprints/sprint-6d-consolidation-comms.md`: detailed spec, ready for approval.
- **Open for 6d**: `PHASE_ERROR_BUDGET` default 3 needs tuning from a harness-run loop's real token cost (6b T5 was manual). 6d cuts v6.2.0.
- Committed + pushed to main this session.

---

## Sprint 6b current state (2026-06-19)

**Done + verified on disk** (uncommitted, NOT pushed — awaiting Jamie's review):
- `project/missions/mission-optimize.md` — rewritten as the ratchet (augment-not-gut): analysis front-end (Phases 1–2) + ratchet core (Phase 3: worktree → median-of-3 baseline → keep-or-revert → `.loops/` JSONL log → caps → escalation) + human-merge (Phase 4). 33 ratchet markers.
- `project/skills/code-review-loop/SKILL.md` — new scored critic→fixer→re-audit loop, read-only critic / read-write fixer, converge on two clean rounds or cap.
- `project/field-manual/loop-discipline-guide.md` — five-gate test + mechanics + cost guardrails.
- `templates/mission-optimize-input-template.md` — surface/metric/caps/read-only-set/watched-run.
- `project/deployment/scripts/install.sh` — `code-review-loop` in `skill_dirs`; guide + template in the enumerated arrays; `install.sh.sha256` regenerated (`af254f94…`), syntax + checksum verified.
- `sprints/sprint-6c-meta-loop.md` — promoted outline → detailed spec.
- Tracking updated: project-plan.md (6b ✅, 6c spec-ready), progress.md (2026-06-19 entry), CHANGELOG `[Unreleased]`, sprint-6b spec task markers.

**T5 watched validation run — ✅ DONE (2026-06-20)**: executed on aimpactmonitor (AISearchArena's benchmark was broken). Loop proven end-to-end; kept a lazy-load bundle change (on aimpactmonitor `develop`). Two findings folded into mission-optimize (metric-must-match-intent; worktree breaks on JS/Turbopack → use branch-in-place). No clean token-per-loop number (manual run) — 6c should seed its error budget from a harness-run loop. **Sprint 6b is fully closed.**

**Not committed**: per Jamie's standing rule, nothing committed/pushed without explicit confirmation.

**Next step options for Jamie**: (1) commit 6b; (2) schedule the T5 watched run; (3) approve 6c to start (after T5 ideally). Rolling-wave: 6b's spec-closing task (6c detailed spec) is done, so 6b is formally complete bar the watched run.

---

## (Prior) Sprint 6a state (2026-06-16) — COMPLETE

**Done + verified on disk** (uncommitted, NOT pushed — awaiting Jamie's review):
- `library/settings.json.template` — `permissions.deny` block (enforcement). JSON valid.
- `coordinator.md`, `tester.md`, `developer.md` — default-fail contract + read-only-gate rule.
- `library/CLAUDE.md`, `project/gates/README.md`, `quality-gates-guide.md` — docs.
- Sprint 6 registered in `project-plan.md`; spec files in `sprints/sprint-6{a,b,c}-*.md`.

**Mechanism note**: enforcement is `permissions.deny` in settings (file-level, native), NOT agent frontmatter — the frontmatter `tools:` field is a whole-tool allowlist and can't do path rules. See progress.md 2026-06-16 entry for the full root-cause.

**6a live demo (T5) ✅ DONE 2026-06-16**: test project `/tmp/agent11-gate-test/` (deny block as `.claude/settings.json`); a Claude session there was blocked from editing `.quality-gates.json` (`Error editing file`) and refused to route around it. Enforcement proven end to end. Evidence logged in progress.md + sprint-6a spec.

**Remaining for 6a**:
- **T6**: draft the Sprint 6b detailed spec (ratchet `mission-optimize` + scored code-review loop), review with Jamie. Rolling-wave rule: 6a isn't formally complete until 6b's spec is approved.
- Optional: full-harness intervention-rate measurement (deferred to Sprint 6 close, non-blocking).
- Test harness `/tmp/agent11-gate-test/` can be deleted once no longer needed.

**Not committed**: per Jamie's standing rule, nothing committed/pushed without explicit confirmation.

---

## (Prior) Bulk-ops toolkit shipped 2026-05-10

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
