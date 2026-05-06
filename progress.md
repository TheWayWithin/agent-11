# AGENT-11 v6.0 Evolution — Progress Log

Fresh log starting at the close of Sprint 4a T6 (2026-04-19). Historic log preserved at `.archive/2026-04-17-pre-v6/progress-historic.md`.

This file tracks the v6.0 evolution only. Per the v6.0 plan (`project-plan.md` → "Context Consolidation"), `progress.md` is retained as a backward-looking changelog but will be moved out of the active-context default in Sprint 4e.

---

## 📦 Recent Deliverables

### [2026-05-06] — Sprint 5a T1+T2: install.sh v5→v6 upgrade detection ✅

**Summary**: install.sh now detects v5.x markers at entry and either warns-and-exits (default — preserves user agency) or runs migrate-v5-to-v6.sh as a subprocess (`--upgrade` flag, opt-in for v6.1.0 first release). T2's subprocess invocation contract — local-first script lookup with GitHub fallback, explicit `$?` check rather than relying on `set -e` propagation, working-directory contract documented — landed alongside T1 since the two are joined at the hip.

**Deliverables**:
- `project/deployment/scripts/install.sh` — three new helper functions (`detect_v5_markers_in_cwd`, `find_or_fetch_migrate_script`, `run_v5_to_v6_migration`); main() args parser rewritten to handle flags + legacy positional; v5-detection branch with three behaviours per spec matrix.
- New CLI surface: `--upgrade`, `--help`, unknown-flag rejection. (`--dry-run` and `--non-interactive` deferred to T8.)

**Verified end-to-end** (fixture at `~/sprint-5a-test/v5-fixture`):
- `bash -n` syntax clean.
- `--help` → prints flag doc, exits 0.
- `--bogus` → "Unknown flag" error, exits 1.
- v5 fixture, no flag → warns with all 4 markers listed, suggests `--upgrade` and curl-fallback, exits 1.
- v5 fixture + `--upgrade` → migration subprocess runs, all 4 markers cleaned, agent-context.md created from folded handoff-notes, install resumes and deploys all 11 specialists + missions/templates/field-manual end-to-end.

**Locked decisions reflected in code**:
- Auto-migrate gated behind explicit `--upgrade` opt-in (architect's safety concern; default-on deferred to v6.2 after production validation).
- Single source of truth: install.sh invokes migrate-v5-to-v6.sh, does not inline.
- Subprocess error handling: explicit `rc=$?` check, abort install on non-zero with diagnostic.

**Next**: T3 (settings.json surgical merge — Python 3 with bash fallback, JSON edge-case handling, user-value-wins conflict rule, backup→validate→auto-restore).

---

### [2026-04-19] — Sprint 4a Complete ✅

**Summary**: Sprint 4a (Baseline + Great Deletion) complete. Harness spec locked, full v5.2 baseline measured across 5 tasks, MCP profile system deleted, `.backup` files removed, coordinator prompt stripped of ASCII decoration, historic context files archived, Sprint 4b detailed spec authored.

**Deliverables (T1–T7)**:
- `project/validation/harness-spec.md` — 5-task harness with metric definitions and capture method (T1)
- `project/validation/baseline-v5.2.md` — full v5.2 baseline results, 5 tasks run, summary observations captured (T2)
- MCP profile system deleted: `.mcp-profiles/`, root `mcp-setup.sh`, `.claude/commands/mcp-{switch,status,list}.md` (T3)
- 12 `.backup` files in `project/agents/specialists/` removed; `project/agents/specialists.backup-20251030-083005/` directory removed (T4)
- `project/agents/specialists/coordinator.md` de-decorated: 3,559 → 2,836 lines (~20% reduction); rules intact (T5)
- `progress.md`, `agent-context.md`, `handoff-notes.md` archived to `.archive/2026-04-17-pre-v6/*-historic.md`; fresh versions created (T6)
- `sprints/sprint-4b-prompt-hygiene-and-budget-controls.md` expanded from outline to detailed spec (T7)

**Baseline Key Findings (v5.2)**:
- M2 (session-start tokens) flat at ~49.4k across all 5 tasks — this is the number v6.0 must beat.
- Delegation is largely theatre: 3 of 5 tasks either didn't delegate or got empty responses from the called subagent, with the coordinator doing the work itself.
- Ceremony overhead is significant: Task 4 took 6:07 for work comparable to Task 3's 1:30. The gap is tracking-file creation.
- Subagent hallucinations are persistent (architect, tester, developer all produced output referencing code/files that didn't exist); coordinator's cross-checks caught them.
- M4 (human interventions) was zero across all tasks — the system is autonomous, just not efficient.

**User-Facing Changes** (for Sprint 4h docs consolidation):
- `/mcp-switch`, `/mcp-list`, `/mcp-status` commands retired. Replacement is dynamic tool search in Sprint 4f. Deprecation notice added to README.

---

### [2026-04-19] — Install Simplification: always install all 11 agents ✅

**Summary**: Retired the `install.sh [core|full|minimal]` squad selector. All installs now always deploy all 11 specialists. This fixes the class of bug that surfaced in the Task 5 baseline review (secure-install.sh dropped the squad argument) by removing the argument's meaning entirely.

**Rationale**: Having all 11 specialists installed costs approximately 1k tokens (lazy-loaded by Claude Code) and negligible disk space. The user benefit of "pick your squad" was notional — in practice, having more specialists available does not hurt and removes decisions users shouldn't have to make.

**Changes**:
- `project/deployment/scripts/install.sh`:
  - `SQUAD_CORE` and `SQUAD_MINIMAL` arrays removed; only `SQUAD_FULL` (11 agents) remains.
  - `install_squad`, `verify_installation`, `show_post_install_instructions` simplified to always use `SQUAD_FULL`; case statements on squad_type removed.
  - `main()` now accepts legacy `core|full|minimal` arguments with a yellow "deprecated" notice, but always installs all 11.
- `project/deployment/scripts/install.sh.sha256` regenerated (CI guard from `fea148d` enforced this).
- `README.md`: no change needed (install command already didn't pass a squad arg).
- `CHANGELOG.md`: entry under Unreleased → Changed/Deprecated.

**Verification**: `shasum -a 256 -c install.sh.sha256` passes. `bash -n install.sh` syntax-clean.

**User impact**:
- Fresh installs get all 11 specialists. Previously, the default was 4.
- Anyone passing `core` or `minimal` to `install.sh` gets a one-line deprecation notice and still gets all 11 (non-breaking).
- `secure-install.sh` squad-arg regression is moot — there is no squad arg any more.

---

### [2026-04-23] — Sprint 4b (T1-T5, T7) Complete — Harness Re-run (T6) Parked ✅

**Summary**: Executed six of seven Sprint 4b tasks solo (all tasks that don't require the harness terminal). T6 (harness re-run for measurement) is parked for a future session when Jamie has ~45 min of terminal time.

**Deliverables**:

- **T1** — `project/constitution/karpathy-constitution.md` created. Seven principles, standalone doc, referenced from specialists.

- **T2** — `project/agents/specialists/coordinator.md`:
  - New `OPERATING DISCIPLINE: PAUSE-AND-PLAN` section at the top, replacing the "You NEVER do specialist work yourself" forced-immediacy line (that claim was also false per baseline — coordinator doing work directly was observed and often correct).
  - Stripped decorative urgency labels (`[MANDATORY - RUN FIRST]`, `[BLOCKING - CANNOT BYPASS]`, etc.).
  - Replaced `NO WAITING` / `DELEGATE IMMEDIATELY` with neutral phrasing.

- **T3** — Pattern-based minimisation applied to all 11 specialists. Finding: the decorative urgency patterns live almost entirely in `coordinator.md` (already stripped 20% in Sprint 4a). Other 10 specialists are already clean. Net additional line reduction across the 10: ~0 lines. Documented, not a failure — just evidence that the mechanical minimisation target (≥10%) was satisfied in 4a and no further mechanical gains are available without semantic content edits (deferred to Sprint 4d).

- **T4** — Budget frontmatter added to three mission files:
  - `project/missions/mission-build.md`
  - `project/missions/mission-fix.md`
  - `project/missions/mission-refactor.md`
  - Each declares `expected_duration`, `expected_interactions`, `on_budget_exceeded`.
  - New `MISSION BUDGETS` section in `coordinator.md` explaining the advisory-not-hard-cap protocol.

- **T5** — Subagent hardening. New `OPERATING DISCIPLINE — READ FIRST, VERIFY BEFORE RETURNING` section added to:
  - `project/agents/specialists/architect.md`
  - `project/agents/specialists/developer.md`
  - `project/agents/specialists/tester.md`
  - Each specialist is now instructed to use the Read tool before producing edits or assertions that reference actual code; explicitly mark unverified output; refuse to "assume" or "infer" file contents. Directly addresses the hallucination pattern found across Tasks 1, 2, 4 in the v5.2 baseline.

- **T6** — **Parked.** Harness re-run (Tasks 3, 4, 5) against Sprint 4b changes requires Jamie's terminal (~45 min). Next session will execute this and write `project/validation/milestone-4b.md` with the comparison against baseline.

- **T7** — `sprints/sprint-4c-universal-router.md` expanded from outline to full 8-task spec. Open question "`/foundations` fold into `/bootstrap`?" resolved: keep separate (consider a `/kickoff` wrapper later if the sequential flow is common).

**User-Facing Changes** (for Sprint 4h docs consolidation):
- Mission files now carry YAML frontmatter with budget declarations. Backward-compatible — missions still work without frontmatter (coordinator falls back to judgement).
- Coordinator behaviour shifts from "always delegate, maintain all tracking files" to "choose the lightest valid path, sometimes do the work directly". Users may see less ceremony on small tasks.

**What's pending**:
- Sprint 4b T6 — harness re-run to measure impact of T1-T5 changes against v5.2 baseline. Requires Jamie's terminal.
- Sprint 4c execution — detailed spec ready; execution blocked on Sprint 4b T6 (so we have clean attribution of metric changes).

---

### [2026-04-26] — Sprint 4b T6: Harness Subset Re-Run COMPLETE ✅

**Summary**: Ran Tasks 3, 4, 5 against post-Sprint-4b state. All three succeeded. Sprint 4b's behavioural-change hypotheses all validated, with the headline result — Task 4 dropped from 6m 7s to 1m 33s, a **75% reduction** vs the ≥25% hypothesis.

**Headline numbers**:

| Task | M1 baseline | M1 4b | Δ |
|------|------------|-------|---|
| T3 (bug fix) | 1:30 | 0:43 | **-52%** |
| T4 (refactor) | 6:07 | 1:33 | **-75%** |
| T5 (commit review) | 1:37 | ~1:45 | flat |

M2 (session-start tokens) dropped 2.4% across all three. Modest — the bigger M2 cuts will come in Sprints 4d (CLAUDE.md shrink) and 4f (dynamic MCP).

**Qualitative wins**:

1. **The coordinator now articulates its discipline.** T5 review opened with "I'm doing this as a direct read-only review — no /coord orchestration overhead". T4 opened with a one-sentence plan before acting. PAUSE-AND-PLAN working as designed.
2. **Subagent hardening prevented a real failure mode.** During T3 setup, the prompt got pasted into the wrong fixture (t5-commit-review-run instead of t3-bug-fix-run). The new coordinator detected the mismatch and refused to fabricate work — it said "I'm not going to fabricate a pagination test or start a fix mission on a problem that doesn't exist here." v5.2 baseline coordinator would likely have either delegated to a developer that returned "0 tool uses" or hallucinated a test to "fix".
3. **Ceremony tax on small/medium tasks is gone.** T4 used to write 4 tracking files for a 3-file refactor. Now it writes none. The discipline change has direct, measurable impact.
4. **T4 solution is architecturally cleaner**. Baseline applied middleware via `router.use(requireAuth)` inside each route file. 4b applied it at mount-time in `app.ts`: `app.use("/users", requireAuth, usersRouter)`. Auth concerns live entirely outside the route files now.

**Deliverable**: `project/validation/milestone-4b.md` with full results, hypotheses scored, and qualitative observations.

**Sprint 4b status**: ✅ **Complete.** All 7 tasks delivered (T1-T5 and T7 in commit `747c072`; T6 here). Recommend proceeding to Sprint 4c.

**What's next**:
- Sprint 4c (Universal Router) execution per `sprints/sprint-4c-universal-router.md`. Most of it can run solo; T7 (harness re-run for milestone-4c) requires Jamie's terminal again.

---

### [2026-04-26] — Sprint 4c (T1-T6, T8) Complete — Harness Re-run (T7) Parked ✅

**Summary**: Universal Router shipped. `/coord` collapsed from a 549-line mission-activation briefing into a 91-line dispatcher with deterministic mission-based routing. Coordinator gained a DYNAMIC CONTEXT LOADING protocol so Mode B1 (`fix`) reads the bug report only, not the full tracking file set. Sprint 4d detailed spec authored.

**Deliverables**:

- `project/commands/coord.md` — rewritten 549 → 91 lines (T1, T2, T3, T5, T6).
  - Routing table: 13 missions mapped to Mode A / B1 / B2 with explicit context-loading rules.
  - Control commands (`continue`, `complete phase N`, `vision-check`) listed separately from missions.
  - Pipeline commands (`/foundations`, `/architect`, `/bootstrap`) explicitly noted as standalone (not routed via `/coord`).
  - `mode:greenfield|surgical|maintenance` override syntax for ambiguous tasks.
  - Unknown-mission fallback prints valid list and exits — no NLP "did you mean…" inference.
  - Old 549-line briefing deleted; coordinator-owned content (PAUSE-AND-PLAN, phase gates, file ops, etc.) is no longer duplicated in the command.
- `project/agents/specialists/coordinator.md` — DYNAMIC CONTEXT LOADING section added; SESSION RESUMPTION PROTOCOL rewritten (T4).
  - Mode A: project-plan.md, agent-context.md, mission file.
  - Mode B1: input file (e.g., bug report) only.
  - Mode B2: project-plan.md (if exists), mission file.
  - `evidence-repository.md` and `progress.md` are on-demand only — never loaded at session start.
  - Per-mission overrides for `dev-setup` (read ideation only) and `dev-alignment` (read existing codebase first).
  - Staleness check now scoped to resumed missions only (where tracking files exist), not run blindly on every fresh start.
  - Net coordinator delta: 2,869 → 2,888 lines (+19; structural change before Sprint 4d's shrink).
- `sprints/sprint-4d-native-primitives-and-claudemd-shrink.md` — outline replaced with detailed spec (T8).
  - 8 tasks defined: audit & relocation map, hook design, lean CLAUDE.md (<80 lines), Meta-Dev Skill, decentralisation, install.sh hook deployment, harness re-run (milestone-4d), Sprint 4e spec.
  - Default hooks proposed: PostToolUse for tsc/ruff on Edit-Write; PreToolUse for destructive Bash ops.
  - Open questions called out: blocking vs advisory hooks, Meta-Dev Skill trigger mechanism, where plan-driven docs live.

**Tasks parked for Jamie's terminal session**:
- **T7** (harness re-run for milestone-4c) — needs the validation harness runbook, deferred to a separate session.

**User-Facing Changes** (for Sprint 4h docs consolidation):
- `/coord` interface stable: existing calls like `/coord build prd.md` and `/coord fix bug-report.md` still work unchanged.
- New: `mode:` prefix for explicit mode override (`/coord mode:maintenance security`).
- New routing-table-explicit missions: `dev-alignment`, `document`, `security` are now first-class entries (previously implicit or absent).
- Behaviour change: `/coord fix` no longer reads project-plan.md / agent-context.md / handoff-notes.md by default. Users with a long-running plan and a small bug fix should expect lower session-start tokens; the coordinator can still load tracking files on demand if the fix grows.
- Behaviour change: unknown mission names now fail fast with a clear error and the valid list. No silent NLP-inference fallback.

**Files touched**:
- `project/commands/coord.md` — rewritten.
- `project/agents/specialists/coordinator.md` — DYNAMIC CONTEXT LOADING + SESSION RESUMPTION PROTOCOL replacement.
- `sprints/sprint-4d-native-primitives-and-claudemd-shrink.md` — detailed spec.
- `progress.md`, `handoff-notes.md`, `project-plan.md` — close-out updates.

**Sprint 4c status**: ✅ **Complete** for solo-executable scope (T1, T2, T3, T4, T5, T6, T8). T7 deferred. Recommend proceeding to Sprint 4d once Jamie has reviewed.

**What's next**:
- T7 (harness re-run): schedule a session with the validation harness; produce `project/validation/milestone-4c.md`.
- Sprint 4d (Native Primitives + CLAUDE.md Shrink) — detailed spec ready in `sprints/sprint-4d-native-primitives-and-claudemd-shrink.md`.

---

### [2026-04-26] — Sprint 4d (T1-T6, T8) Complete — Harness Re-run (T7) Parked ✅

**Summary**: `library/CLAUDE.md` shrunk **575 → 79 lines** (-86%) by deleting content that was duplicate of canonical sources elsewhere. Default `settings.json.template` shipped with advisory hooks for tsc/ruff/rubocop on Edit/Write and a confirm-prompt for destructive Bash. Karpathy constitution now deploys to `.claude/constitution/` (was previously referenced but not deployed). Meta-Dev skill added. Sprint 4e detailed spec authored.

**Deliverables**:

- `library/CLAUDE.md` — **575 → 79 lines** (-86%). Shape:
  - Karpathy Constitution (7 principles inline, 1-line each)
  - Mission table (Mode A/B1/B2)
  - Tracking files (4 files, 1 line each, full protocols pointed to coordinator.md)
  - Foundation files (one paragraph)
  - Skills (one paragraph)
  - MCP tools (search-pattern table, points to field-manual)
  - Hooks (one paragraph, advisory by default)
  - Security (3 bullets)
  - Plan-driven workflow (one sentence + pointer)
- `library/settings.json.template` — new file. Hooks:
  - PostToolUse on Edit/Write/MultiEdit:
    - `tsc --noEmit` for `*.ts/*.tsx` (only if `package.json` + `tsconfig.json` present)
    - `ruff check` for `*.py` (only if `pyproject.toml` present)
    - `rubocop` for `*.rb` (only if `Gemfile` present)
  - PreToolUse `prompt` on Bash matching `rm -rf *`, `git push --force*`, `git push -f *`, `git reset --hard*`, `git clean -f*`, `git branch -D*` — confirms before proceeding.
  - All command hooks `|| true` for advisory behaviour. Promote to blocking by changing to `|| exit 2`.
- `.claude/skills/meta-dev/SKILL.md` — new file. Triggers on `agent-11`, `library/CLAUDE.md`, `working squad`, `install.sh`, etc. Orients Claude correctly when working inside the framework repo (library vs working-squad distinction). Verified registered in skill list.
- `project/deployment/scripts/install.sh`:
  - New function `install_settings_template()` — deploys `library/settings.json.template` to `.claude/settings.json`. Fresh install copies verbatim; existing files left alone with backup + notice.
  - New function `install_constitution()` — deploys `project/constitution/karpathy-constitution.md` to `.claude/constitution/karpathy-constitution.md` (was missing from deployment).
  - Both wired into the install pipeline after `install_claude_md` and before `install_mission_system`.
  - `field_manual_files` list expanded to include `mcp-integration.md` (referenced by lean CLAUDE.md but not previously deployed).
  - `install.sh.sha256` regenerated; CI guard verified passing.
- `sprints/sprint-4e-context-consolidation.md` — outline replaced with detailed spec.
  - 8 tasks: Phase Handoff schema, rename `agent-context.md` → `context.md`, fold `handoff-notes.md` into `context.md`, demote `progress.md` to write-only, lean CLAUDE.md update, mission file updates, harness re-run, Sprint 4f spec.
  - Open questions resolved: progress.md stays at root (write-only); migration via manual `mv` documented in CLAUDE.md, no helper command yet.

**T1 Relocation Map** (audit deliverable):

| Old library/CLAUDE.md section | Action | Canonical home |
|---|---|---|
| Critical Software Dev Principles | DELETE | `coordinator.md` Karpathy Constitution |
| Ideation File Concept | KEEP compressed | (lean file) |
| Progress Tracking System | DELETE | `coordinator.md` |
| Design Review System | DELETE | `/design-review` cmd, @designer agent |
| Mission Documentation Standards | DELETE | duplicates progress tracking |
| Context Preservation System | DELETE | `coordinator.md` |
| Foundations v2.0 | DELETE | `project/commands/foundations.md` (1378 lines) |
| Coordinator Delegation Protocol | DELETE | `coordinator.md` + `field-manual/coordinator-protocol.md` |
| Common Tasks (dev-setup/alignment) | DELETE | `/coord` routing table (Sprint 4c) |
| MCP Integration | DELETE | `field-manual/mcp-integration.md` |
| Model Selection Guidelines | DELETE | `coordinator.md` + `field-manual/model-selection-guide.md` |
| MCP Setup | DELETE | `field-manual/mcp-integration.md` |
| Sprint 9 Plan-Driven Development | DELETE | `field-manual/plan-driven-development.md` (281 lines) |
| Available Commands | KEEP compressed (mission table) | (lean file) |
| Security Notes | KEEP compressed | (lean file) |

~95% of the old file was duplicate content. Lean file points at canonical sources, doesn't restate them.

**Open Decisions Made (per Jamie's "all defaults")**:

1. **Hooks**: advisory by default (`|| true` exit 0 + output). Users promote to blocking individually.
2. **Meta-Dev Skill trigger**: AGENT_11_PROJECT env var (already set in `.claude/settings.local.json`); skill description also matches the relevant repo terms.
3. **Plan-driven docs location**: kept in existing `field-manual/plan-driven-development.md` (already deployed); no new file needed.

**Tasks parked for Jamie's terminal session**:
- **T7** (harness re-run for milestone-4d) — needs validation harness runbook, deferred.
- T7 from Sprint 4c also remains parked. Both can be run in the same terminal session.

**User-Facing Changes** (for Sprint 4h docs consolidation):
- `.claude/CLAUDE.md` shrinks from 575 to 79 lines on next install. Existing users keep the old 575-line file until they reinstall or manually update.
- New install deploys `.claude/settings.json` with default advisory hooks for TS/Python/Ruby type/lint checks and destructive Bash confirmation. Users without the relevant toolchains see no-op behaviour (hooks skip cleanly when `package.json`/`pyproject.toml`/`Gemfile` absent).
- Karpathy constitution is now installed at `.claude/constitution/karpathy-constitution.md` (was referenced by coordinator but not deployed previously).
- `field-manual/mcp-integration.md` now installed (was missing from deploy list).
- Existing users with their own `.claude/settings.json` will not have it overwritten — installer leaves their file alone with a notice and writes a backup.

**Files touched**:
- `library/CLAUDE.md` — rewritten (-496 lines net).
- `library/settings.json.template` — new file.
- `.claude/skills/meta-dev/SKILL.md` — new file (working-squad exception per Sprint 4d scope rule).
- `project/deployment/scripts/install.sh` — added `install_settings_template`, `install_constitution`; expanded field-manual list.
- `project/deployment/scripts/install.sh.sha256` — regenerated.
- `sprints/sprint-4e-context-consolidation.md` — detailed spec.
- `progress.md`, `handoff-notes.md`, `project-plan.md` — close-out updates.

**Sprint 4d status**: ✅ **Complete** for solo-executable scope (T1, T2, T3, T4, T5, T6, T8). T7 deferred. Recommend proceeding to Sprint 4e once Jamie has reviewed.

**What's next**:
- T7 (harness re-run): schedule a terminal session; produce `project/validation/milestone-4d.md`.
- Sprint 4e (Context Consolidation 5→3) — detailed spec ready in `sprints/sprint-4e-context-consolidation.md`.

---

### [2026-04-26] — Sprint 4e (T1, T3-T6, T8) Complete — Harness Re-run (T7) Parked ✅

**Summary**: Active tracking surface cut from 5 files to 3. `handoff-notes.md` retired and folded into `agent-context.md` as structured Phase Handoff blocks (5-field schema). `progress.md` demoted to write-only. Smoke-tested install confirms 4d artefacts ship correctly. Sprint 4f detailed spec authored.

**Decisions made during review (2026-04-26)**:

1. **Skip the rename** of `agent-context.md` → `context.md` (T2 removed from sprint). The rename was the lowest-value item — added migration friction without proportional benefit. The fold (T3) and demotion (T4) carry the actual value.
2. **5-field Phase Handoff schema**: Findings, Decisions, Warnings & Gotchas, Open Items, Evidence. Mirrors current handoff-notes structure.
3. **Migration**: one-line `cat handoff-notes.md >> agent-context.md && rm handoff-notes.md` for v5.x users; documented in lean CLAUDE.md.
4. **`progress.md` location**: stays at root (not moved to `evidence/`).

**Deliverables**:

- `templates/agent-context-template.md` — restructured to make Phase Handoff blocks the recurring section pattern. Includes the 5-field schema with a worked example (auth implementation).
- `project/agents/specialists/coordinator.md` — DYNAMIC CONTEXT LOADING table updated:
  - Mode A reads `project-plan.md` + `agent-context.md` + mission file (no `progress.md`, no `handoff-notes.md`).
  - `progress.md` explicitly framed as **write-only by default**: append on issues/fixes/deliverables, read only for staleness checks or post-`/clear` reconstruction.
- All 11 specialist agents (`project/agents/specialists/*.md`) — context-reading instructions updated:
  - "First read agent-context.md and handoff-notes.md" → "First read agent-context.md (most recent Phase Handoff block)".
  - "Update handoff-notes.md with findings" → "Append a Phase Handoff block to agent-context.md with findings".
  - Numbering on Before/After Task Execution sections fixed where collapse left gaps.
- All 18 mission files (`project/missions/*.md`) — handoff-notes references removed; agent-context.md is the single context file.
- All commands and templates with handoff-notes references updated. `templates/handoff-notes-template.md` archived to `.archive/2026-04-26-pre-4e/handoff-notes-template.md`.
- 3 plan templates (`templates/plan-saas-mvp.yaml`, `plan-api.yaml`, `plan-saas-full.yaml`) — `handoff-notes.md` entry removed; `agent-context.md` updated to absorb both task-completion and phase-completion frequencies.
- `library/CLAUDE.md` — tracking-files section restructured: Active (project-plan.md, agent-context.md), On-demand (evidence-repository.md), Write-only (progress.md). Migration note for v5.x users included. **Still 78 lines** (under 80-line target).
- `project/deployment/scripts/install.sh` — `handoff-notes-template.md` removed from template-files list and verification list. SHA256 regenerated.
- `sprints/sprint-4e-context-consolidation.md` — spec updated to reflect "skip rename" decision; T2 marked REMOVED with rationale; open questions resolved inline.
- `sprints/sprint-4f-dynamic-mcp-tool-search.md` — outline replaced with detailed spec.
  - 8 tasks: audit dynamic-mcp.json vs static, wire as canonical .mcp.json, Tool-Centric Workflow in specialists, discovery/execution split, retire profile-switching residue, lean CLAUDE.md MCP section, harness, Sprint 4g spec.
  - Target: M2 drops ≥30K vs v5.2 baseline (per Dynamic MCP doc projection).

**Bulk replacement scope**:

- 316 `handoff-notes.md` references across the library surface reduced to 5 intentional migration notes (in lean CLAUDE.md, agent-context-template.md, and 3 YAML plan templates).
- 5 staged `sed` passes plus targeted Edit cleanups for grammar/numbering. Specialist frontmatter intact across all 11 specialists (verified).

**4d Smoke Test (Jamie's terminal, 2026-04-26)**:

- Install on fresh `/tmp/agent11-smoke` with `package.json` indicator: completed cleanly.
- `library/CLAUDE.md` deploys at 79 lines.
- `.claude/settings.json` deploys with valid JSON, 1.9 KB.
- `.claude/constitution/karpathy-constitution.md` deploys at 2.9 KB (was missing pre-4d).
- `field-manual/mcp-integration.md` deploys at 6.5 KB (was missing pre-4d).
- All 11 agents, 14 commands, 7 SaaS skills, 3 quality-gate templates, 3 stack profiles ship correctly.
- ✅ Sprint 4d install-side changes confirmed working.

**Tasks parked for Jamie's terminal session**:
- **T7** (harness re-run for milestone-4e) — joins parked T7s for 4c and 4d. All three can run in one batch session against the v5.2 baseline.

**User-Facing Changes** (for Sprint 4h docs consolidation):
- `handoff-notes.md` is retired in v6.0. Existing v5.x users migrate with one line: `cat handoff-notes.md >> agent-context.md && rm handoff-notes.md`. Documented in lean CLAUDE.md.
- `progress.md` is now write-only by default — appended when issues, fix attempts, or deliverables occur. Read only for staleness checks on resumed missions, or post-`/clear` context reconstruction.
- `agent-context.md` carries Phase Handoff blocks (5-field schema) at the bottom, accumulating across phases. Specialists read the most recent block to pick up context.
- `templates/handoff-notes-template.md` no longer ships. Use `templates/agent-context-template.md` (now includes Phase Handoff schema).

**Files touched**:
- `templates/agent-context-template.md` — restructured.
- `templates/handoff-notes-template.md` — archived to `.archive/2026-04-26-pre-4e/`.
- `project/agents/specialists/*.md` — 11 specialists, context-reading updates.
- `project/missions/*.md` — 18 mission files, handoff-notes references removed.
- `project/commands/*.md` — handoff-notes references updated/removed.
- `templates/plan-{saas-mvp,api,saas-full}.yaml` — handoff-notes file entry removed.
- `templates/{project-plan,cleanup-checklist,claude,progress,lessons-index}-template.md` — references updated.
- `library/CLAUDE.md` — tracking files section restructured.
- `project/deployment/scripts/install.sh` — handoff-notes-template.md removed; SHA regenerated.
- `sprints/sprint-4e-context-consolidation.md` — spec finalised post-review.
- `sprints/sprint-4f-dynamic-mcp-tool-search.md` — detailed spec.
- `progress.md`, `handoff-notes.md`, `project-plan.md` — close-out updates.

**Sprint 4e status**: ✅ **Complete** for solo-executable scope (T1, T3, T4, T5, T6, T8). T7 deferred. Recommend proceeding to Sprint 4f once Jamie has reviewed.

**What's next**:
- T7 batch (4c + 4d + 4e harness re-runs): schedule a terminal session; produce `milestone-4c.md`, `milestone-4d.md`, `milestone-4e.md` against the v5.2 baseline.
- Sprint 4f (Dynamic MCP Tool Search) — detailed spec ready. Target ≥30K M2 reduction vs baseline.

---

### [2026-04-26] — Sprint 4f (T1, T2, T3, T5, T6, T8) Complete — Recalibrated After Schema Audit ✅

**Summary**: T1 audit revealed Sprint 4f's original premise was wrong — `project/mcp/dynamic-mcp.json` (Sprint 11) uses the **Claude API** schema for per-tool `defer_loading`, not the **Claude Code** `.mcp.json` schema (which only accepts `mcpServers` registry). Recalibrated the sprint mid-execution: per-tool config is replaced by Claude Code's native `ENABLE_TOOL_SEARCH=auto` setting; `dynamic-mcp.json` archived; profile-switching residue retired. Specialists updated with concise Tool Search guidance.

**T1 Audit Finding** (the recalibration trigger):

Sprint 4f originally planned to "wire dynamic-mcp.json as the canonical .mcp.json". Investigation showed this would deploy a file Claude Code can't parse:
- `.mcp.json` (Claude Code): top-level `{"mcpServers": {"name": {"type": "stdio", "command": "...", "args": [...], "env": {...}}}}` — server registry only.
- `dynamic-mcp.json` (Claude API): top-level `{"discovery_tools": [...], "toolsets": [{"type": "mcp_toolset", "default_config": {"defer_loading": true}, "tools": [...]}]}` — per-tool defer_loading config.

The two systems are different. Per-tool defer_loading is a Claude API feature; Claude Code handles tool deferring **natively** when many tools are configured, controlled by `ENABLE_TOOL_SEARCH=auto`. Reference: https://code.claude.com/docs/en/mcp.

This finding mooted the original T2 (wire dynamic-mcp.json) and T4 (per-server preload split). The recalibrated sprint is significantly smaller and structurally simpler.

**Decisions made during recalibration (2026-04-26)**:

1. **Pre-T1**: Side-by-side ship dynamic-mcp.json as `.mcp.json.dynamic`. **Mooted by T1**: dynamic-mcp.json is wrong schema; archived instead.
2. **Pre-T1**: Strict 1-per-server preload. **Mooted by T1**: Claude Code auto-manages, no per-tool config.
3. **Recalibrated T2**: enable `ENABLE_TOOL_SEARCH=auto` in `library/settings.json.template`. Archive `dynamic-mcp.json`. Remove its install.sh deployment.
4. **T4 removed**: Claude Code handles per-tool deferring natively; nothing to configure.

**Deliverables**:

- `library/settings.json.template` — added `"env": {"ENABLE_TOOL_SEARCH": "auto"}`. This is the actual lever for threshold-based tool loading in Claude Code.
- `.archive/2026-04-26-pre-4f/dynamic-mcp.json` — Sprint 11 obsolete config archived (was based on Claude API schema, never wired in usefully).
- `.archive/2026-04-26-pre-4f/mcp-optimization-guide.md` — entirely about retired profile-switching, archived.
- `.archive/2026-04-26-pre-4f/validate-mcp-profiles.sh` — validates retired profiles, archived.
- `project/deployment/scripts/install.sh`:
  - `setup_mcp_configuration()`: removed dynamic-mcp.json deployment (replaced with comment explaining native auto-deferring).
  - `install_mcp_system()`: removed `.mcp-profiles/` install logic (replaced with comment).
  - Post-install message updated: no more "13 specialized profiles in .mcp-profiles/" or "Choose profile: ln -sf ..."; new message describes native tool deferring.
  - field-manual deployment list: removed `mcp-optimization-guide.md` (archived).
  - SHA256 regenerated; CI guard verified passing.
- All 7 MCP-using specialists (`developer`, `tester`, `operator`, `architect`, `analyst`, `marketer`, `designer`) updated:
  - 3 already had a `## DYNAMIC MCP TOOL DISCOVERY` section (verified accurate).
  - 4 needed the section's pattern table compressed and enriched with a Tool Search reference: architect, analyst, marketer, designer.
  - All 7 now have a concise (3-5 line) MCP guidance paragraph in their TOOL PERMISSIONS section pointing at Tool Search; long static MCP tool listings removed.
- 4 mission files (`mission-deploy.md`, `connect-mcp.md`, `library.md`, `dev-setup.md`) updated to remove `.mcp-profiles/` profile-switching references; replaced with Tool Search guidance or v6.0 retirement notes.
- `library/CLAUDE.md` MCP section: now says "MCP tools defer-load via `ENABLE_TOOL_SEARCH=auto`" + retains the search-pattern table + adds a one-line v5.x retirement note. Still 78 lines (under 80).
- `sprints/sprint-4f-dynamic-mcp-tool-search.md` — spec recalibrated to match what was actually built. T1 finding documented inline; T4 marked REMOVED with rationale; resolved Open Design Questions noted.
- `sprints/sprint-4g-skills-and-routines.md` — outline replaced with detailed spec.
  - 10 tasks: skills audit against open standard, 3-tier model documentation, skill remediation, 3 Routine config templates (pr-review, nightly-qa, backlog-triage), `/coord` operational-intent detection, lean CLAUDE.md update, harness, Sprint 4h spec.
  - Routines confirmed as paste-from-docs (per blueprint) — `project/routines/` ships templates; user pastes into Claude Code web UI.
  - Tier 3 (marketplace) skills positioned for *future* publishing — format-only intent in v6.0.

**Tasks parked for Jamie's terminal session**:
- **T7** (harness re-run for milestone-4f) — joins parked T7s for 4c, 4d, 4e. All four can run in one batch session against v5.2 baseline.

**User-Facing Changes** (for Sprint 4h docs consolidation):
- `.claude/settings.json` ships with `ENABLE_TOOL_SEARCH=auto` — Claude Code threshold-based tool deferring activated. Specialists discover MCP tools at runtime via `tool_search_tool_regex_20251119`.
- `.mcp-profiles/` profile-switching system **retired in v6.0**. Users no longer `ln -sf .mcp-profiles/X.json .mcp.json` to switch contexts. Tools auto-load when needed.
- `mcp-optimization-guide.md` removed from deployed `field-manual/` (it was about the retired profile-switching system). `mcp-integration.md` (deployed in 4d) is now the canonical MCP guide.
- `validate-mcp-profiles.sh` removed (validated retired profiles).
- Sprint 11's `mcp/dynamic-mcp.json` no longer ships — it was based on a misreading of Claude Code's schema and was never wired in.

**Files touched**:
- `library/settings.json.template` — added ENABLE_TOOL_SEARCH=auto env.
- `library/CLAUDE.md` — MCP section updated.
- All 7 MCP-using specialists (developer, tester, operator, architect, analyst, marketer, designer) — Tool-Centric Workflow guidance.
- 4 mission files (mission-deploy, connect-mcp, library, dev-setup) — profile references retired.
- `project/deployment/scripts/install.sh` — `install_mcp_system` and `setup_mcp_configuration` simplified; post-install message updated; field-manual list updated.
- `project/deployment/scripts/install.sh.sha256` — regenerated.
- `.archive/2026-04-26-pre-4f/` — `dynamic-mcp.json`, `mcp-optimization-guide.md`, `validate-mcp-profiles.sh` archived.
- `sprints/sprint-4f-dynamic-mcp-tool-search.md` — spec recalibrated.
- `sprints/sprint-4g-skills-and-routines.md` — detailed spec.
- `progress.md`, `handoff-notes.md`, `project-plan.md` — close-out updates.

**Sprint 4f status**: ✅ **Complete** for solo-executable scope (T1, T2, T3, T5, T6, T8). T4 removed during recalibration. T7 deferred. Recommend proceeding to Sprint 4g once Jamie has reviewed.

**Lessons captured**:

The Sprint 11 `dynamic-mcp.json` was a useful reminder that the Claude API's MCP schema and Claude Code's `.mcp.json` schema are different systems — easy to conflate when reading docs. T1 audit caught the mismatch before we shipped a file Claude Code couldn't parse. Adding "schema verification against canonical docs" to T1 audits going forward.

**What's next**:
- T7 batch (4c + 4d + 4e + 4f harness re-runs): schedule a terminal session; produce milestone files against v5.2 baseline.
- Sprint 4g (Skills + Routines) — detailed spec ready.

---

### [2026-04-27] — Sprint 4g (T1-T8, T10) Complete — Recalibrated After Pre-Execution Platform Check ✅

**Summary**: Skills audited against Anthropic's Agent Skills open standard ([agentskills.io/specification](https://agentskills.io/specification)) — required `description` field added to all 7 SaaS skills. 3-tier model documented in `field-manual/skills-guide.md`. Three Routine prompt templates shipped in `project/routines/` (pr-review, nightly-qa, backlog-triage). `/coord` now detects cadence keywords and points to the matching template instead of executing. Sprint 4h detailed spec authored.

**Pre-execution platform check (2026-04-27)**:

Before designing T4-T7, verified Claude Code Routines' actual mechanism (per [routines docs](https://code.claude.com/docs/en/routines)):
- Routines run on **Anthropic-managed cloud**, not locally. Live and stable (research preview phase).
- Created via three paths to the same cloud account: web UI at `claude.ai/code/routines`, `/schedule` slash command, or desktop app.
- **No JSON/YAML config files**. The web form collects: prompt (natural language), repos, environment (network/env vars/setup script), triggers (schedule/API/GitHub webhooks), connectors (MCP integrations), permissions.

This corrected the original "paste JSON config" framing in the spec. Templates are now **prompt text** + setup notes for the UI fields users will fill in. Same lesson as Sprint 4f's T1: verify platform mechanics against canonical docs before designing.

**Skills audit findings (T1)**:

Per the open standard:
- **Required frontmatter**: `name` (lowercase, hyphens, matches dir) + `description` (1-1024 chars, what + when, embeds trigger keywords for progressive-disclosure loading).
- **Optional frontmatter**: `license`, `compatibility`, `metadata`, `allowed-tools`.
- **Custom fields** (`triggers`, `specialist`, `complexity`, etc.) are NOT in the spec.

AGENT-11's existing 7 SaaS skills had `name` ✓ but were missing `description`. Custom fields are needed for AGENT-11's coordinator-driven trigger matching. **Hybrid approach**: add `description` to frontmatter (open-standard compliance + forward compatibility for marketplace publishing); keep custom fields for backward-compat with existing skill-loading.

**Deliverables**:

- `project/skills/saas-{auth,payments,multitenancy,billing,email,onboarding,analytics}/SKILL.md` — `description` field added to all 7 skills. Each description 1-1024 chars, includes trigger keywords, describes what + when. Verified all 7 have descriptions (script confirmed).
- `project/field-manual/skills-guide.md` — 3-tier model documented (Tier 1 behavioural / Tier 2 project-domain / Tier 3 marketplace), open-standard alignment explained, hybrid frontmatter format documented. v6.0 publishes for the standard but does NOT publish to a public marketplace (per project-plan.md's "format-only intent").
- `project/routines/pr-review.md` — paste-ready prompt template + setup notes for GitHub-PR-triggered code review. Multi-disciplinary (developer/tester/designer lenses).
- `project/routines/nightly-qa.md` — scheduled QA sweep prompt: smoke tests on critical paths (Playwright), visual regression spot-check, deployment health (Railway/Netlify connector). Cron `0 2 * * *` default.
- `project/routines/backlog-triage.md` — weekly backlog triage prompt: priority review (strategist lens), usage signal (analyst lens), customer impact (support lens). Cron `0 9 * * 1` default. Outputs prioritised list to `triage/YYYY-MM-DD.md` and optional Slack thread.
- `project/routines/README.md` — overview of the Routines directory, how to use templates, when /coord points users here, links to canonical docs.
- `project/commands/coord.md` — added `## Routine Detection (Mode C — operational work)` section. Cadence keywords (daily/weekly/monthly/hourly/nightly + "every Monday/...") and operational phrases (PR review, nightly QA, weekly triage) trigger a pointer to the matching Routine template instead of delegation. coord.md grew 91 → 134 lines (still well under v5.x's 549).
- `library/CLAUDE.md` — Skills section now describes the 3-tier model + open-standard alignment. New Routines section (one paragraph) describing Mode C work + template pointers. Still 78 lines.
- `sprints/sprint-4g-skills-and-routines.md` — spec recalibrated to match verified Routines mechanism. T4-T6 reframed as prompt templates (not JSON configs). T7 reframed as pointer output (not config snippet output).
- `sprints/sprint-4h-validation-and-migration.md` — outline replaced with detailed spec.
  - 7 tasks: harness batch (5 milestones for 4c, 4d, 4e, 4f, 4g), v6.0 cumulative metrics report, v5→v6 migration script, consolidated docs update (README/CHANGELOG/MCP-GUIDE/RELEASE-HISTORY), private beta cohort, release-readiness checklist, retrospective + post-v6 backlog.
  - 4h is the close-out sprint — no new structural changes; everything ships, gets measured, gets documented, gets tagged.

**Tasks parked for Jamie's terminal session**:
- **T9** (harness re-run for milestone-4g) — joins parked T7s for 4c, 4d, 4e, 4f. Sprint 4h's T1 batches them all.

**User-Facing Changes** (for Sprint 4h docs consolidation):
- All 7 SaaS skills now have a proper `description` field aligned with [Anthropic's Agent Skills spec](https://agentskills.io/specification). Forward-compatible with future marketplace publishing.
- 3-tier skills model documented in `field-manual/skills-guide.md`.
- `routines/` directory ships with 3 paste-ready Routine prompt templates. Users paste the prompt block into `claude.ai/code/routines` and configure repos/triggers/connectors via the form.
- `/coord` recognises cadence keywords (daily, weekly, every Monday, schedule, nightly, etc.) and recommends the matching Routine template instead of executing the work as a one-time delegation.
- `library/CLAUDE.md` mentions Routines and the 3-tier skills model; still 78 lines.

**Files touched**:
- `project/skills/saas-*/SKILL.md` × 7 — `description` field added.
- `project/field-manual/skills-guide.md` — 3-tier model + open-standard alignment.
- `project/routines/{pr-review,nightly-qa,backlog-triage,README}.md` × 4 — new directory of prompt templates.
- `project/commands/coord.md` — Routine Detection section added.
- `library/CLAUDE.md` — Skills + Routines sections updated.
- `sprints/sprint-4g-skills-and-routines.md` — spec recalibrated.
- `sprints/sprint-4h-validation-and-migration.md` — detailed spec.
- `progress.md`, `handoff-notes.md`, `project-plan.md` — close-out updates.

**Sprint 4g status**: ✅ **Complete** for solo-executable scope (T1-T8, T10). T9 parked. Recommend proceeding to Sprint 4h once Jamie has reviewed.

**v6.0 evolution status**: 7 of 8 sub-sprints complete. Sprint 4h is the close-out (validation, migration, beta, docs, retrospective). After 4h, v6.0 is shipped.

**What's next**:
- **Sprint 4h is the final v6.0 sprint.** T1 (the harness batch) is gating — without measurement we can't claim v6.0 delivers. T3 (migration script) is the ergonomic upgrade for v5.x users. T4 is the consolidated docs pass deferred since 4a.
- T9 from 4g rolls into 4h's T1 batch.

---

### [2026-05-01] — Sprint 4h T3: v5→v6 Migration Script Shipped ✅

**Summary**: `migrate-v5-to-v6.sh` shipped and tested across four scenarios. Solo work in parallel with parked T1 (harness batch). Users on v5.x can now run a one-command migration to bring their projects into v6.0 shape — handoff-notes folded into agent-context, .mcp-profiles/ retired, obsolete dynamic-mcp.json removed, all originals backed up.

**Deliverable**: `project/deployment/scripts/migrate-v5-to-v6.sh` — 218 lines, executable.

**What it does**:
1. Detects AGENT-11 install (refuses if not present).
2. Detects v5.x markers (`handoff-notes.md`, `.mcp-profiles/`, `mcp/dynamic-mcp.json`, `templates/handoff-notes-template.md`). Exits cleanly if none found ("already v6.0").
3. Confirms with the user before any destructive op (with `--yes` for automation, `--dry-run` for preview).
4. Backs up everything that will change to `.claude/backups/v5-to-v6-YYYYMMDD-HHMMSS/`.
5. Folds `handoff-notes.md` into `agent-context.md` (Sprint 4e) with a clear separator and timestamp; promotes handoff-notes to agent-context if no agent-context exists yet.
6. Retires `.mcp-profiles/` (Sprint 4f profile-switching system retired).
7. Removes obsolete `mcp/dynamic-mcp.json` (Sprint 4f schema-mismatch finding).
8. Retires `templates/handoff-notes-template.md` (Sprint 4e).
9. Checks `.claude/settings.json` for `ENABLE_TOOL_SEARCH`; warns if missing rather than overwriting user customisations.
10. Prints summary with backup location and rollback instructions.

**Safety properties**:
- `--dry-run` mode shows all planned operations without touching the filesystem.
- `--yes` mode skips interactive confirmation (for CI/automation).
- Refuses to run on directories without an AGENT-11 install (no `.claude/CLAUDE.md` or `.claude/agents/coordinator.md`).
- Refuses to run if backup directory cannot be written.
- Idempotent — running on an already-migrated v6.0 install detects no markers and exits cleanly.
- Never overwrites existing `.claude/settings.json` user customisations; warns and points at template instead.
- Never modifies `.mcp.json` (the server registry) — separate concern from the retired profile-switching system.
- Never modifies code files in user's project.
- All originals backed up before any destructive op.

**Test scenarios validated** (2026-05-01, on /tmp/ scratch dirs):

| Test | Setup | Expected | Actual |
|------|-------|----------|--------|
| 1 | Empty directory (no AGENT-11) | Refuse with clear error, exit 1 | ✓ Refused, exit 1 |
| 2 | `.claude/CLAUDE.md` only (no v5.x markers) | Detect already-v6.0, exit 0 | ✓ Detected, exit 0 |
| 3 (dry-run) | Full v5.x scenario (handoff-notes.md, .mcp-profiles/, dynamic-mcp.json, handoff-notes-template.md, settings.json with custom config) | Show all planned ops, change nothing | ✓ All ops listed, filesystem unchanged |
| 3 (real, --yes) | Same v5.x scenario | Backup all, fold handoff-notes, retire .mcp-profiles/, remove dynamic-mcp.json, warn on settings.json | ✓ All operations correct; agent-context.md correctly contains original content + appended handoff content with separator and timestamp |
| 4 (idempotency) | Re-run after Test 3 | Detect no v5.x markers, exit 0 | ✓ Clean exit |

**Initial bug found and fixed**: First test version of script tried to read confirmation from `/dev/tty` when stdin was piped, but failed in test environment with "Device not configured". Fixed by adding `--yes` flag for automation + cleaner branching: TTY-stdin → read from stdin; piped-stdin with TTY available → read from /dev/tty; neither → require `--yes` or error out.

**User-Facing Changes** (for Sprint 4h docs consolidation):
- New script: `project/deployment/scripts/migrate-v5-to-v6.sh` deployed alongside install.sh. v5.x users can run it standalone to upgrade their existing projects.
- Usage:
  - `bash migrate-v5-to-v6.sh` — interactive
  - `bash migrate-v5-to-v6.sh --dry-run` — preview without changes
  - `bash migrate-v5-to-v6.sh --yes` — skip confirmation (automation/CI)
- Migration is reversible: copy files from `.claude/backups/v5-to-v6-YYYYMMDD-HHMMSS/` back to project root.

**Files touched**:
- `project/deployment/scripts/migrate-v5-to-v6.sh` — new file (executable).
- `progress.md` — close-out entry.

**Sprint 4h status**: T3 complete. T1 still parked (harness batch — needs Jamie's terminal). T4 (docs consolidation) can run solo next session if Jamie wants forward motion before the harness session.

**What's next**:
- T1 (harness batch) — Jamie's terminal session.
- T4 (consolidated docs) — solo-doable; mostly mechanical README/CHANGELOG/MCP-GUIDE/RELEASE-HISTORY pass.
- T2 (cumulative metrics report) — gated on T1.

---

### [2026-05-01] — Sprint 4h T4: Consolidated docs pass shipped ✅

**Summary**: README, CHANGELOG, MCP-GUIDE, and RELEASE-HISTORY updated for v6.0. Pulls the "User-Facing Changes" running list from sprints 4a-4g into a coherent set of public-facing docs. Solo work in parallel with parked T1 (harness batch). Some metric references in RELEASE-HISTORY/CHANGELOG carry placeholders (`v6.0-summary.md` from T2) that will fill in after the harness session.

**Deliverables**:

- `CHANGELOG.md` — full v6.0.0 entry. Sections:
  - Migration pointer (one-line `bash <(curl -sSL ...)` for v5.x users)
  - Added: Universal Router, Karpathy constitution, Dynamic context loading, Phase Handoff blocks, Quality-gate hooks, Native MCP tool deferring, Routines (Mode C), 3-tier skills model, migrate-v5-to-v6.sh, mode override, Routine detection
  - Changed: line counts (`library/CLAUDE.md` 575 → 78; `coord.md` 549 → 134), session-start protocol, `progress.md` write-only, MCP server registry unchanged but profile-switching retired, all 7 MCP-using specialists, install.sh deploys settings.json/constitution/mcp-integration
  - Deprecated: `install.sh [core|full|minimal]` arguments
  - Removed: `handoff-notes.md`, `.mcp-profiles/`, `/mcp-switch`/`/mcp-list`/`/mcp-status`, `templates/handoff-notes-template.md`, `project/mcp/dynamic-mcp.json`, `mcp-optimization-guide.md`, `validate-mcp-profiles.sh`, root `mcp-setup.sh`
  - Architecture: 8-sprint summary covering 4a → 4h
- `docs/MCP-GUIDE.md` — rewritten for v6.0. **673 → 218 lines** (-68%). Sections:
  - What is MCP, common AGENT-11 MCP servers
  - How v6.0 loads MCP tools (native auto-deferring via `ENABLE_TOOL_SEARCH=auto` + Tool Search workflow)
  - Setup (4 steps: install, API keys, server packages, restart)
  - Verifying MCP tools (Tool Search examples)
  - Specialist → Server mapping table
  - v5.x → v6.0 migration (script + manual fallback)
  - Troubleshooting (Tool Search returns nothing, tool not found, hooks blocking, migration script refuses, stale agent context)
  - Reference + "what v6.0 does NOT do" (Sprint 4f schema-mismatch lesson captured)
- `docs/RELEASE-HISTORY.md` — v6.0 entry prepended. Headline changes, structural shifts, validation metrics (placeholder for T1 results), 8-sprint roadmap table, migration commands, links to CHANGELOG and MCP-GUIDE.
- `README.md` — targeted edits (1864-line file, not a full rewrite):
  - Version section bumped from v5.2.0 to **v6.0 — The Lean Orchestrator**, with the substantive v6.0 changes summarised in 6 bullets.
  - v5.x → v6.0 migration block added inline (one-command migrate + reinstall).
  - "Mission MCP Profile Guide" section heading and content replaced with "Mission MCP Tools (v6.0)" describing native deferring.
  - System Architecture diagram updated to show v6.0's 3-active-file model (project-plan.md, agent-context.md with Phase Handoff blocks, evidence-repository.md on-demand) plus progress.md as write-only.
  - Mission Workflow sequence diagram updated: removed `handoff-notes.md` participant; specialists now read agent-context.md and append Phase Handoff blocks.
  - Context Management diagram updated for the 3-file model with Phase Handoff schema.
  - Three remaining `handoff-notes.md` mentions are intentional v5.x→v6.0 migration context (not stale).
  - Bulk of README (mission descriptions, agent profiles, workflow examples, etc.) untouched — content is timeless and accurate under v6.0.

**What was deliberately NOT done**:
- Full README rewrite. The README is 1864 lines covering timeless concepts (what AGENT-11 is, agent profiles, mission descriptions). v6.0 doesn't change those. Targeted edits over rewrite.
- `library/CLAUDE.md` updates. Already lean at 78 lines (Sprint 4d/4g); Sprint 4h spec said "verify still accurate" — verified, no changes needed.
- Metrics filled into placeholders. Those need T1 harness results. Marked clearly with "*pending T1*" notes; T2 (cumulative metrics report) fills these in.
- Public release announcement. Per Sprint 4h spec, "handled separately, not in this sprint" — Jamie's voice, separate workstream.

**User-Facing Changes** (full list now lives in CHANGELOG.md v6.0 entry):
- README's version section reflects v6.0 with migration command for v5.x users
- CHANGELOG documents every breaking change, addition, and deprecation since v5.0
- MCP-GUIDE rewritten for native tool deferring; all `.mcp-profiles/` / profile-switching docs retired
- RELEASE-HISTORY surfaces the 8-sprint v6.0 roadmap and migration story

**Files touched**:
- `CHANGELOG.md` — full v6.0 entry (~70 lines added).
- `docs/MCP-GUIDE.md` — full rewrite (-455 lines).
- `docs/RELEASE-HISTORY.md` — v6.0 entry prepended (~70 lines added).
- `README.md` — targeted edits (version section, migration block, 3 diagrams, MCP profile section heading, 2 prose mentions).
- `progress.md` — close-out entry (this).

**Sprint 4h status**:
- ✅ T3 (migration script) — shipped 2026-05-01
- ✅ T4 (consolidated docs) — shipped 2026-05-01
- ⏸ T1 (harness batch) — terminal-required, parked
- ⏸ T2 (cumulative metrics report) — gated on T1
- 📋 T5 (release-readiness checklist) — gated on T1-T4
- 📋 T6 (retrospective) — gated on T1-T5

**v6.0 status**: structurally complete. T1 batch is the last terminal-required step. T2/T5/T6 are mostly close-out paperwork that I can ship solo after T1 results are in.

**What's next**:
- T1 harness batch in your terminal session — the gate for T2/T5/T6.

---

### [2026-05-03] — Sprint 4h T1: v6.0 harness re-verified ✅

**Summary**: Re-ran the greenfield T1 harness against the v6.0 build mission after both blocker fixes. Both held. `/coord build` completed cleanly through Phase 6 against the Tinylink fixture; 32/32 automated tests pass (870ms).

**Verification target**: `test-projects/t1-greenfield-run/` (greenfield Tinylink MVP fixture, gitignored — verification artefacts live there, key findings lifted here).

**Phases executed**:
1. ✅ Phase 1-2: Strategist + Architect (real specialist hops via direct Task tool spawning from top-level Claude — not via coordinator subagent)
2. ✅ Phase 3: Story locking
3. ✅ Phase 4: Developer — 20 files, EJS partials pattern honoured (no `views/layout.ejs` wrapper, locked architecture invariant held)
4. ✅ Phase 4 walkthrough: 8/8 manual acceptance steps green (signup → login → session persistence → shorten → incognito click count → soft-delete → 404)
5. ✅ Phase 5: Tester — 32/32 automated tests, 870ms, 6 KPI suites + 3 helpers
6. ✅ Phase 5 cleanup: `createApp` factory refactor (option C: kill the only real maintenance trap, accept 3 cosmetic findings as documented)
7. ✅ Phase 6: Documenter — README in place
8. ⏭ Phase 7: deploy artefacts deferred — no remote / Railway service yet; will run `/coord fix add-ci-and-dockerfile` when actually deploying

**Blocker validation**:
- **#1 (flat-frontmatter for tool provisioning)**: Held. Specialists spawned with correct tool sets each phase.
- **#2 (mission-complete verification + anti-fabrication)**: Gate fired correctly. After Phase 4 the outer Claude reported "20 files verified on disk" with specific evidence (ls -la, grep, node --check) and asked for browser walkthrough before declaring success — exactly the behaviour the fix was designed to produce.

**Process learning**: Top-level Claude spawning specialists directly via Task tool worked cleanly (~6.5 min Phase 4 implementation, no timeouts). Coordinator-as-subagent caused nested-Task / stream-timeout issues in earlier iterations — direct-spawn is the durable pattern.

**EJS lesson captured**: `views/layout.ejs` wrapper pattern forbidden; use `<%- include('partials/...') %>` partials. Saved to user memory so it carries to future EJS work.

**Sprint 4h status**: T1 complete. T2 (cumulative metrics) and T5 (release-readiness checklist) now unblocked.

**v6.0 status**: Release-ready. Remaining = T2/T5/T6 close-out paperwork plus release ceremony (tag, GitHub release, announce).

---

### [2026-04-19] — v6.0 Evolution Kickoff

Continuing from the v6.0 planning session committed in `aa6ecdb`. Historic context (pre-v6 plan, Sprint 9/11 work) preserved in `.archive/2026-04-17-pre-v6/`.
