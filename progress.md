# AGENT-11 v6.0 Evolution — Progress Log

Fresh log starting at the close of Sprint 4a T6 (2026-04-19). Historic log preserved at `.archive/2026-04-17-pre-v6/progress-historic.md`.

This file tracks the v6.0 evolution only. Per the v6.0 plan (`project-plan.md` → "Context Consolidation"), `progress.md` is retained as a backward-looking changelog but will be moved out of the active-context default in Sprint 4e.

---

## 📦 Recent Deliverables

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

### [2026-04-19] — v6.0 Evolution Kickoff

Continuing from the v6.0 planning session committed in `aa6ecdb`. Historic context (pre-v6 plan, Sprint 9/11 work) preserved in `.archive/2026-04-17-pre-v6/`.
