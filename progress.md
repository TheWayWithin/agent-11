# AGENT-11 v6.0 Evolution — Progress Log

Fresh log starting at the close of Sprint 4a T6 (2026-04-19). Historic log preserved at `.archive/2026-04-17-pre-v6/progress-historic.md`.

This file tracks the v6.0 evolution only. Per the v6.0 plan (`project-plan.md` → "Context Consolidation"), `progress.md` is retained as a backward-looking changelog but will be moved out of the active-context default in Sprint 4e.

---

## 📦 Recent Deliverables

### [2026-07-23] — A11-ISS-9: install.sh --upgrade now propagates shipped-hook fixes ✅

**Root cause**: `merge-settings.py` no-opped whenever the user settings had any `hooks` key, so template hook fixes (e.g. the A11-ISS-4 gate-guard rework) never reached deployed repos — blocking the T-245 fleet sweep.

**Fix (fingerprint-based managed hooks)**: the merger now carries `STALE_SHIPPED_HOOKS`, a catalogue of superseded shipped hook entries (git history shows exactly one: the f575973 fail-open if-glob gate guard). On merge, entries byte-matching a stale fingerprint are replaced by the current template version and missing template entries are added; anything unrecognised is user-authored/user-edited and preserved byte-identical. Identity across versions is `statusMessage`, so a user-EDITED shipped hook (e.g. advisory promoted to blocking, which the template invites) is kept and never duplicated. NOOP now means "nothing to change". Status contract (`MERGED`/`NOOP_ALREADY_V6`) unchanged → install.sh untouched, sha256 verified unchanged. Maintenance rule documented in the module docstring: when a shipped hook changes in the template, append the outgoing version to the catalogue. `docs/UPGRADE.md` merge section updated.

**Proof**: new rerunnable `project/deployment/scripts/test-merge-settings.sh` — 19/19: (a) genuine v6.2.0 settings → guard replaced, no `if` field; (b) user custom hooks + custom SessionStart group byte-identical; (c) no hooks → full add; (d) already-current → NOOP, byte-unchanged; (e) invalid JSON → exit 1, untouched, no litter; (f) promoted tsc hook kept, exactly one. End-to-end: fixture 05 reworked (9/9) — real `install.sh --upgrade` lands the gate-guard hook + `.claude/hooks/gate-guard.sh`, preserves user permissions, second run is a stable NOOP. Full install-fixture suite 01–05 all pass.

---

### [2026-07-23] — A11-ISS-6: /bootstrap lite-tier gaps closed ✅

**Three gaps from the PRJ-14 digital-estate pilot, all in `project/commands/bootstrap.md`**:
1. **Type enum had no CLI-toolkit fit** — added `tool` (CLI toolkit / library / local utility): flag enum, inference rules (no hosted service, no business model, developer audience; gates build/test/lint), inference-prompt return values, low-confidence override option, and a `tool` quality-gate template block (with a note that gate commands are stack-appropriate, not npm-specific).
2. **vision.yaml demanded from lite projects** — the Phase-1 validation check contradicted the PREREQUISITES header ("REQUIRED for saas-* types"): it unconditionally failed on a missing vision.yaml. Now required only for saas-* types; tool/api proceed from prd.yaml with a warning; Phase-2 read and the missing-prereqs error text updated to match.
3. **phase-1-context.yaml prescribed even when phase 1 was complete at bootstrap time** — Phase 5/6 now generate the context file for the **first incomplete phase** (`phase-N-context.yaml`), marking already-done work `[x]`/complete from repo evidence (Engaged Mode may ask; default remains Phase 1 when uncertain).

**Proof**: dry-run of a lite fixture (CLI-toolkit prd.yaml, no vision.yaml, phase-1 scope already implemented) through old vs new doc. Old: no type matches ("user must specify --type" from an enum with no fit) and phase-1-context.yaml prescribed. New: prerequisites pass with warning, `type: tool` assigned on all four conditions, `phase-2-context.yaml` generated.

**Follow-up raised**: `templates/` has plan-saas-mvp/saas-full/api.yaml but no plan-tool.yaml — designing one (phase templates, agent distribution, timeline) is a separate design task.

---

### [2026-07-23] — A11-ISS-5: /foundations PRD extraction de-SaaS-biased for lite tier ✅

**Root cause**: the PRD extraction prompt in `project/commands/foundations.md` treated every category as mandatory — BR-XXX counts, subscription state machines, per-tier success metrics, payment edge cases — so a lite-tier PRD (CLI tool, library) validated against SaaS expectations that are structurally N/A (PRJ-14 digital-estate pilot feedback).

**Fix** (source-driven, so full SaaS PRDs are unchanged): a SCOPE RULE prepended to the PRD prompt — categories apply only where the source contains that content; absence is not-applicable, never invented, never a failure. Items 7/10/11/14 annotated conditional ("[SaaS-shaped]", "if the source uses BR-XXX IDs"), VALIDATION CHECK lines made conditional, Business Rules post-check gains an explicit "none in source - N/A - pass" path, FAIL conditions 2/5 scoped to sources that contain rules/state machines.

**Proof**: dry-run of a minimal lite-tier CLI-toolkit PRD fixture through old vs new instructions (headless Claude). Old: verdict **FAIL**, demanding BR-XXX rules, state machines, compliance sections. New: verdict **PASS**, SaaS-shaped checks reported as acceptable/N-A per scope rule, while genuine gaps (missing edge cases, unversioned PyInstaller) are still surfaced.

---

### [2026-07-23] — A11-ISS-3: install.sh no longer writes a GitHub 404 body into .mcp.json ✅

**Root cause**: `setup_mcp_configuration` used `curl -sSL` (no `-f`) straight onto the destination. On HTTP 404 curl exits 0 and writes the error body — and `.mcp.json` is gitignored in the source repo, so its raw URL **always** 404s on fresh installs. The junk file then also defeated the intended `.mcp.json.template` fallback (`[[ ! -f .mcp.json ]]`).

**Fix**: new `download_mcp_file()` helper — `curl -fsSL` into a mktemp file, moved into place only on success (chmod 644 for parity); on failure the destination, including any existing user file, is untouched. All four downloads in `setup_mcp_configuration` converted; `.mcp.json` failure now warns "Skipping .mcp.json download (not published in the repo) - will create it from .mcp.json.template". `install.sh.sha256` regenerated.

**Proof**: old behavior reproduced live (curl exit 0, `404: Not Found` body). New helper: bogus URL → rc=1, no file created; existing file byte-identical. Real `setup_mcp_configuration` run in an empty dir: `.mcp.json` 404 skipped with the warning, templates + mcp-setup.sh downloaded, `.mcp.json` created from template and validated as JSON.

---

### [2026-07-23] — A11-ISS-4: read-only gate guard false positives fixed ✅

**Root cause**: the 6c gate guard matched via a hook `if` glob filter, which Claude Code evaluates **fail-open** on complex Bash (multi-line loops, redirections) — so ordinary non-gate commands triggered the block (field report: a python-detection for-loop during `/foundations` in digital-estate).

**Fix**: guard decision moved into a real script, `library/hooks/gate-guard.sh` (deployed to `.claude/hooks/gate-guard.sh` by `install_settings_template`). It reads the hook JSON on stdin, extracts the actual command (jq → python3 → raw fallback), and blocks (exit 2) only genuine gate writes: redirection/tee/sed -i/cp/mv onto `*quality-gates*`, `gates/`, `.gates/` — same vector scope as before. The unreliable `if` filter is removed; if the script is absent the hook allows (Edit deny rules still hold). `install.sh.sha256` regenerated.

**Proof**: 18/18 script-level cases (incl. `delegates/` non-match, gate reads allowed, heredoc + multi-line gate writes blocked). End-to-end with headless Claude Code: OLD settings blocked the harmless for-loop (bug reproduced); NEW settings pass it and still block `echo hacked > .quality-gates.json` (file verified absent).

**Side finding** (separate issue raised): Claude Code reports the template's `Write(...)`/`MultiEdit(...)` deny rules as no-ops — only `Edit(path)` rules match file tools. Edit rules are present for every gate path, so no coverage gap.

---

### [2026-06-20] — Sprint 6d: Consolidation & v6.2.0 release ✅ (T1–T6 complete; Sprint 6 umbrella closed)

**Summary**: Consolidated the public docs for the whole Sprint 6 umbrella and prepared the v6.2.0 release, reading the User-Facing Changes running list. Two outward-facing steps (website deploy, release tag) held for Jamie's explicit confirmation per the standing publish rule.

**Done + pushed (agent-11 repo)**:
- `README.md` — Current Version block rewritten to **v6.2.0 — Loop Discipline & Read-Only Verification** (trust-led: "your agents can't game their own success criteria"), honest watched-first framing, v6.0 foundation retained; loop-discipline line added to Advanced Capabilities. No em-dashes (publishing rule).
- `CHANGELOG.md` — added the 6c entry, then finalised `[Unreleased]` → `[6.2.0] - 2026-06-20`; fresh empty `[Unreleased]` left on top. (v6.2.0 bundles 6a–6c + the prior unreleased bulk-ops toolkit.)
- `docs/RELEASE-HISTORY.md` — v6.2.0 entry (headline changes, honest framing, why-minor-not-patch).
- `docs/UPGRADE.md` — the v6.2.0 `permissions.deny` + Bash gate-guard delivered on `--upgrade`, and the deliberately-change-a-gate human workflow.

**Scoped, not yet changed (T1)**: `agent-11-website` is a Next.js site (deploys to agent-11.com). v6.2.0 messaging lives in `src/app/changelog/page.tsx` (structured version array — clean prepend), `src/components/sections/Hero.tsx`, and the features page.

**Done (outward-facing, Jamie-confirmed)**:
- **T5** ✅ — website edited (`changelog/page.tsx` v6.2.0 entry + `Hero.tsx` badge/subheadline), built clean, pushed → deployed to agent-11.com via Netlify. Commit contained only the two intended files (pre-existing uncommitted CLAUDE.md/template changes in that repo left untouched, not ours).
- **T6** ✅ — **v6.2.0 released**: tag `v6.2.0-loop-discipline` pushed + GitHub release created (https://github.com/TheWayWithin/agent-11/releases/tag/v6.2.0-loop-discipline). No install.sh version constant exists → no SHA churn.

**Sprint 6 umbrella CLOSED** (6a read-only gates, 6b ratchet loops, 6c meta-loop, 6d consolidation + v6.2.0 release).

**Next-direction note (for after Sprint 6)**: run a harness-driven loop to get a real token-cost-per-loop number and tune the 6c `PHASE_ERROR_BUDGET` default (3); optionally roll 6a–6c to the fleet via `apply-file.sh`.

---

### [2026-06-20] — Sprint 6c: Coordinator phase-gated meta-loop ✅ (T1–T6 complete)

**Summary**: Formalised the coordinator's outer loop on the 6a/6b foundation. The `/coord continue` loop is now phase-gated with convergence, a per-phase error budget, condensed returns, and evidence-based restart. Also closed a real gap in the 6a enforcement. Library surface only.

**Deliverables (verified)**:
- `project/agents/specialists/coordinator.md` — `/coord continue` execution loop rewritten: per-phase **error budget** (default 3 cycles → escalate, never burn forward), **convergence** on two clean verify rounds (not a fixed count), **unanimous-agreement flag** (correlated-bias signal, surfaced not auto-failed). New "Phase-gated meta-loop (6c)" subsection. **Condensed returns** (1000–2000 token structured summaries, detail to disk) added to the context-preservation protocol. **Restart-from-last-passed-gate** added to session resumption (resume from the last evidence-passed gate; never re-run a verified-complete phase; re-verify a `[x]` lacking evidence).
- `library/settings.json.template` — **T4 gate-route finding + fix**: the 6a `permissions.deny` rules cover Edit/Write/MultiEdit but NOT Bash, so `echo >`, `tee`, `sed -i`, `cp`, `mv` to a gate path bypassed them. Added a blocking **PreToolUse "read-only gate guard" hook** that refuses Bash writes to gate paths (exit 2). No separate script file → no install.sh / SHA churn. JSON validated.
- `library/CLAUDE.md`, `project/commands/coord.md`, `project/field-manual/loop-discipline-guide.md` — documented the Bash guard + the meta-loop (convergence, error budget, condensed returns, restart, unanimous flag).
- `sprints/sprint-6d-consolidation-comms.md` — promoted outline → detailed spec (6c closing task). Gate met: 6a live-demoed, 6b shipped+watched, 6c shipped.

**T4 method note**: the adversarial gate-route test was resolved by static analysis rather than a live agent session (a live deny-enforcement test needs a separate Claude Code instance, as in 6a). Static analysis is conclusive here: the deny block's tool list provably excludes Bash, so the route exists. Default-fail → built the hook rather than assuming safety. A behavioural confirmation can fold into 6d's smoke-test if wanted.

**Error budget caveat for tuning**: `PHASE_ERROR_BUDGET` default 3 is a placeholder. The real number should come from a harness-run loop's measured token cost (the 6b T5 run was manual, no clean number). Flagged in 6d's "what's next" task.

**User-Facing Changes (running list for Sprint 6d)** — append:
- `/coord continue` is now a phase-gated meta-loop (convergence, per-phase error budget with escalation, restart-from-last-passed-gate).
- Bash writes to gate paths are now blocked by a PreToolUse hook (closes the route the deny rules missed).

---

### [2026-06-20] — Sprint 6b T5: watched validation run executed ✅ (Sprint 6b fully closed)

**Summary**: Ran the ratchet end-to-end on a real repo (aimpactmonitor), watched by Jamie. The loop worked exactly as designed and surfaced two field findings now folded back into the mission. Sprint 6b is complete.

**The run**: target = aimpactmonitor JS bundle. Metric = `npm run build && du -sk .next/static/chunks | awk '{print $1}'` (kB, lower better), deterministic baseline 2176 kB. One attempt: lazy-load the recharts trend chart on the dashboard via `dynamic()`. Build gate passed; bundle 2176 → 2168 kB → KEEP, committed to a disposable branch, logged to `.loops/optimize-bundle.log`. Nothing auto-merged; Jamie's `develop` untouched throughout. Mechanics proven: isolate → baseline → one change → build-gated measure → keep-or-revert → log.

**Finding 1 — metric must match intent (Goodhart, live)**: the metric was *total JS bytes on disk*; lazy-loading only moved it 8 kB because recharts is still shipped (just deferred to its own chunk). The real initial-load win wasn't captured. Correct metric for "faster load" is the route's First Load JS, not total disk size. Folded into `mission-optimize.md` Required Inputs as a metric-selection caution.

**Finding 2 — worktree breaks on JS/Turbopack**: a separate-directory worktree fails because Turbopack rejects a symlinked `node_modules` ("points out of the filesystem root"); a full copy is gigabytes. Fell back to a disposable branch in the main checkout (equally safe when all real work is committed/pushed). Folded into `mission-optimize.md` Phase 2 as a JS-project dependency strategy (npm install / hardlink / branch-in-place).

**Cost note for 6c**: run was driven manually, so no clean token-per-loop number (dominant cost was build wall-time, ~4 builds). The 6c error budget should be seeded from a harness-run loop, not a hand-driven demo. Recorded as a 6c input.

**Outcome on the target repo**: the lazy-load change is a genuine best-practice improvement (charting lib off the dashboard's initial load); kept on aimpactmonitor `develop` for Jamie to ship via his normal flow.

**Deliverables touched**: `project/missions/mission-optimize.md` (both findings, field-tested 2026-06).

---

### [2026-06-19] — Sprint 6b: Ratchet loops ✅ (T1–T4, T6 implemented; T5 watched run staged)

**Summary**: Built the loop capability the research describes, on the 6a read-only-gate foundation. Two deliverables landed: `mission-optimize` rewritten as the Karpathy ratchet, and a new `code-review-loop` skill (the canonical scored critic→fixer→re-audit loop). Both depend on 6a — the metric/gate/critic that judges the work is read-only to the agent doing it. Library surface only; zero working-squad files touched.

**Deliverables (verified on disk)**:
- `project/missions/mission-optimize.md` — rewritten (augment-not-gut). Kept a tight analysis front-end (Phases 1–2: pick ONE surface + ONE cheap metric command), replaced the vague old phases 3–6 with the ratchet execution core (Phase 3: worktree → median-of-3 noise-floor baseline → one change on named surface → re-measure → keep-if-better-else-hard-revert → JSONL log → caps → escalation) and a human-merge phase (Phase 4). Read-only set, caps table, watched-first-run rule, honest caveats embedded. 33 ratchet markers confirmed.
- `project/skills/code-review-loop/SKILL.md` (new, 7.5KB) — read-only critic (deterministic-first; gate/test score preferred, LLM-critic fallback) → read-write fixer (named surface only) → re-audit, converge on two clean rounds or cap. Two-roles table, `.loops/` log schema, caps, exit-criteria table, four anti-patterns. Schema-conformant frontmatter.
- `project/field-manual/loop-discipline-guide.md` (new) — the five-gate "loop or not" test, ratchet + scored-loop mechanics, watched-first-run rule, cost guardrails, honest limits (Goodhart, greedy search, correlated judges).
- `templates/mission-optimize-input-template.md` (new) — names surface / metric / baseline / caps / read-only set / watched-run before a run.
- `project/deployment/scripts/install.sh` — registered `code-review-loop` in `skill_dirs`, plus the new guide and template in the enumerated `field_manual_files` / `template_files` arrays so they deploy in remote mode. `install.sh.sha256` regenerated (`af254f94…`); `bash -n` syntax OK; checksum MATCH verified.
- `sprints/sprint-6c-meta-loop.md` — promoted outline → detailed spec (T6 closing task).

**Decision held from spec**: augment `mission-optimize`, don't gut it (Jamie-confirmed 2026-06-16). Deterministic-critic-first. Converge on two clean rounds. `.loops/<name>.log` JSONL. Caps: 10 attempts / 1h / 1000-line diff / token ceiling. No auto-merge — every kept change is a human-merged hypothesis.

**T5 (watched validation run) deliberately NOT auto-run**: it requires Jamie present on a real repo (AISearchArena candidate), one worktree, up to 10 experiments, nothing merged automatically. It produces the first token-cost-per-converged-loop number, which seeds the 6c error budget. Staged, pending a watched block.

**User-Facing Changes (running list for Sprint 6d consolidation)** — append to the 6a list:
- `mission-optimize` is now a metric-driven ratchet (worktree-isolated, keep-or-revert, logged, capped) instead of a 6-phase profiling sweep. Document the new `/coord optimize <surface> "<metric-command>"` shape.
- New deployable skill `code-review-loop` (scored, converge-or-cap, read-only critic / read-write fixer).
- New field-manual page `loop-discipline-guide.md` + `mission-optimize-input-template.md`.
- Both new files deploy on next `install.sh --upgrade`.

---

### [2026-06-16] — Sprint 6a: Read-only gates + evidence-gated verification ✅ (implementation; live demo pending)

**Summary**: Implemented the highest-leverage move from the loops/autoresearch research — *the thing that judges the work must be read-only to the thing doing it*. Built on the existing `project/gates/` runner. Library surface only; zero working-squad files touched.

**Deliverables (7 files, all verified on disk)**:
- `library/settings.json.template` — added a `permissions.deny` block (10 rules) making `.quality-gates.json`, `**/*.quality-gates.json`, `gates/**`, `.gates/**` unwritable by every agent. JSON re-validated. **This is the enforcement.**
- `project/agents/specialists/coordinator.md` — TOOL PERMISSIONS now prohibits delegating any gate-criteria edit; `/coord continue` phase gate flips to pass only on captured command output (default-fail).
- `project/agents/specialists/tester.md`, `developer.md` — SELF-VERIFICATION PROTOCOLs open with the default-fail contract (criteria start `false`, flip only on attached tool-output evidence) + the read-only-gate rule.
- `library/CLAUDE.md`, `project/gates/README.md`, `project/field-manual/quality-gates-guide.md` — documented the contract, mechanism, and default-fail.

**Root-cause correction worth keeping** (per CLAUDE.md "understand before changing"): the 6a spec originally assumed gate denials would live in each agent's **tool-permission frontmatter**. That is mechanically wrong — the `tools:` field is a whole-tool allowlist (Read, Bash, Task…), not a path-level rule, so it cannot express "edit anything except the gate files." Caught during execution by inspecting actual specialist frontmatter before editing. Corrected to the native `permissions.deny` mechanism, which is file-level enforcement (refused at the tool layer), not a prompt convention — exactly what the research demands. Spec file updated to record the correction.

**Evidence standard (holding to our own default-fail rule)**: on-disk edits verified via grep, JSON validated, scope confirmed library-only. **Live refusal DEMONSTRATED (2026-06-16, T5 ✅)**: test project `/tmp/agent11-gate-test/` with the deny block as `.claude/settings.json`; a Claude Code session in that project asked to "set the threshold to 0" in `.quality-gates.json` got `Update(.quality-gates.json) ⎿ Error editing file` — blocked by `permissions.deny`. The agent also recognised unprompted that zeroing the threshold disables the gate and refused to route around it, asking for human authorisation. Enforcement + reward-hacking defence both proven end to end. Remaining for 6a: draft the 6b detailed spec (T6) per rolling-wave. Optional/deferred: full-harness intervention-rate measurement.

**User-Facing Changes (running list for Sprint 6d consolidation)**: Per the doc convention (`project-plan.md` → Documentation & Release Communications), public docs are NOT churned per sub-sprint. The following land in README / RELEASE-HISTORY / website in the Sprint 6d consolidation pass, once Sprint 6 is shipped and live-demoed:
- New default behaviour: deployed agents cannot edit `.quality-gates.json` or `gates/**` (read-only gates via `permissions.deny`). Document for users upgrading — they get the deny block on next `install.sh --upgrade` / `apply-file.sh` of `settings.json.template`. Note the "to change a gate deliberately, remove the deny rules as a human action" workflow.
- New verification posture: default-fail (evidence-gated) success criteria in tester/developer/coordinator.
- CHANGELOG `[Unreleased]` entry added now (2026-06-16); README + website deferred to 6d.
- 6b/6c will add further user-facing items (ratchet `mission-optimize`, scored code-review loop skill) — append here as they land.

---

### [2026-05-09] — Sprint 5b push phase complete: 17/19 user repos pushed to github ✅

**Summary**: After Sprint 5b's local migration sweep (2026-05-07) the 19 migrated repos sat with uncommitted working-tree changes. Today's session committed and pushed the migration upgrade to github across the available repos. Plus a small framework doc bump (model-selection-guide.md) and one straggler scope correction.

**Push results (19 repos)**:
- **Pushed to github (17)**: SEOAgent, aisearchmastery, freecalchub, BOS-AI, aimpactscanner-mvp, Trader-7, llm-txt-mastery, aisearcharena, aimpactmonitor, PlebTest, ISOTracker, modeloptix, solomarket, evolve-7, agent-11-website, mastery-ai Framework, ASMGE.
- **Local-only (2)**: Socrates, SoloCMD — no `origin` remote configured. User decision to leave the migration commits sitting on local main; no path to publish without setting up a remote.
- **Deferred (3, unchanged)**: mcp-7, mcp-11, test-project — older / sandbox-like, not actively used.

**Process notes worth keeping**:
- **Hardened staging script** (`/tmp/agent11-bulk-5b/push-migration.sh`) used a strict allowlist for migration paths (`.claude/agents`, `.claude/commands`, `.claude/CLAUDE.md`, `.claude/constitution`, `.claude/data`, `.claude/skills`, `.claude/settings.json`, `missions/`, `templates/`, `field-manual/`, `gates/`, `schemas/`, `stack-profiles/`, root MCP files, `docs/MCP-*`, `docs/UPGRADE.md`, `agent-context.md`). Per-repo audit confirmed: no backup artefacts staged, no user-content files (`progress.md`, `project-plan.md`, root `CLAUDE.md`, project ideation/) staged.
- **Trader-7 edge case handled correctly**: Jamie had recreated `handoff-notes.md` with new Sprint 141 content after the migration ran. The script's D-vs-M check (`stage_v5_marker_if_deleted`) only stages a v5-marker path when its git status is `D`, never `M` — so Trader-7's new project-content `handoff-notes.md` correctly stayed unstaged.
- **4 repos hit non-fast-forward push rejection** (aisearcharena, ISOTracker, solomarket, evolve-7) — remote had a "feat: add CI failure alert" commit pushed from elsewhere (likely scheduled job). Resolved with stash → `git pull --rebase origin main` → push → stash pop. Stash was needed because the user-content files we'd deliberately NOT staged still blocked rebase.
- **2 repos had no `origin`**: Socrates and SoloCMD are local-only repos. Migration commits sit on local main waiting for a remote.

**Commit SHAs (for traceability)**:
- SEOAgent: af65710 | aisearchmastery: 70f5e01 | freecalchub: 87f4d4a | BOS-AI: dcb592e | aimpactscanner-mvp: dcb1b94 | Trader-7: 6ac1dd7 | llm-txt-mastery: 39ffec4 | aisearcharena: e155ca4 (rebased) | aimpactmonitor: b289bb3 (develop) | PlebTest: 7003376 (develop) | ISOTracker: 41dc0e4 (rebased) | modeloptix: 4f9c14f (develop) | solomarket: c82dfab (rebased) | evolve-7: 6435bc0 (rebased) | agent-11-website: 25066f9 | mastery-ai Framework: d563ea8 | ASMGE: 545dd1a | (Socrates: b838f90 local-only) | (SoloCMD: fe2b703 local-only).

**Side deliverable**:
- `project/field-manual/model-selection-guide.md` — bumped Opus 4.6 → 4.7 and Sonnet 4.5 → 4.6 across 7 prose/table refs. Added v1.2.0 changelog entry (2026-05-09); preserved v1.1.0 and v1.0.0 historical entries. Library agents already use model aliases, so this is doc-rot only — no runtime effect.

**Sprint 5b status**: Fully closed. Bulk migration delivery confirmed end-to-end: dry-run survey → pilots → patch (v6.1.1) → real-run sweep → verification → commit → push.

---

### [2026-05-07] — Sprint 5b CLOSED: bulk v5→v6.1.1 migration of 17/17 priority repos ✅

**Summary**: Sprint 5b complete. After the v6.1.1 patch shipped, ran the bulk migration across the remaining 15 repos (top-priority subset minus the 2 pilots already done). Combined with the aisearchmastery and freecalchub pilots that drove the v6.1.1 advisory-cleanup patch, **17 of 17 priority repos** are now on v6.1.1.

**Repos migrated this sweep (15)**:
- Top 6: BOS-AI, aimpactscanner-mvp, Trader-7, llm-txt-mastery, aisearcharena, aimpactmonitor (run + verified, paused for go-ahead)
- Normal 8: PlebTest, SEOAgent, ISOTracker, modeloptix, solomarket, evolve-7, agent-11-website, Socrates
- Outlier 1: `mastery-ai Framework` (the 1-marker outlier from the 17-repo dry-run survey, plus a path-with-space — handled by the same code path)

**Pre-flight (dry-run sweep, 15/15)**:
- All 15 returned `rc=0` on `bash install.sh --upgrade --dry-run --non-interactive`.
- All 15 had v5 markers (uniform with the dry-run survey expectations).
- 9 had existing settings.json (would surgical-merge); 6 fresh-deploy. Matched real-run outcome 1:1.
- Dirty-tree state (uncommitted changes per repo before upgrade): ranged 0 to 141 (solomarket worst). Pilot results validated dirty trees up to 95 changes; held in this sweep too.

**Real-run outcome (15/15 clean)**:
- All 15: `rc=0` and 0 markers remaining post-install.
- All 15: per-repo backup directory created at `.claude/backups/v5-to-v6-<ts>/`.
- 9/9 settings merges: succeeded with `Merged v6 template into existing settings.json (user values preserved)`. Sample spot-check (BOS-AI): 31 allow + 1 ask + 13 deny + custom `AGENT_11_PROJECT` env var + hooks — all preserved.
- 6/6 fresh-deploy repos: clean install of v6 settings template, no merge needed.
- **0/15 repos showed the stale "Manual merge recommended" advisory** — v6.1.1 cosmetic fix held in real-world bulk run.
- mastery-ai Framework outlier (1 marker, path with space): clean — marker gone, settings merged, no advisory.

**Logs**: `/tmp/agent11-bulk-5b/` (dry-run + real per-repo).

**Out of scope, deferred**: BusinessProjects with `.claude/` deployed are BOS-AI projects (different framework), not agent-11 — no migration needed from this repo's installer. Earlier handoff line had this wrong; correcting in handoff-notes.md.

**Sprint 5b status**: CLOSED. The contract introduced in Sprint 5a (`--non-interactive` + `--dry-run`) worked exactly as designed for bulk use.

---

### [2026-05-07] — v6.1.1 patch: subprocess advisory cleanup ✅

**Summary**: Cosmetic patch surfaced during the first real-world v5→v6 pilot runs (aisearchmastery, freecalchub). `migrate-v5-to-v6.sh` was emitting a stale "Manual merge recommended" `[WARN]` immediately before install.sh's surgical merger ran and succeeded — the warning looked like a merge failure. Suppressed when migrate.sh is invoked as a subprocess of install.sh (gated by `AGENT11_INSTALL_INVOKED=1` env var). Standalone use still surfaces the advisory, now reworded to point at `install.sh --upgrade` as the recommended automatic path.

**Pilot results that drove this patch** (Sprint 5b dry-run survey + first two real-run pilots):
- 17-repo dry-run survey: all 17 confirmed on v5 (11 would-merge, 6 fresh-deploy, 0 already-v6, 0 python3 issues, 1 outlier — `mastery-ai Framework` with 1 marker, deferred for separate look).
- aisearchmastery pilot: 16/16 checks. Rich permissions (30+ allow rules + ask + deny + custom `AGENT_11_PROJECT` env var) all preserved through the surgical merge.
- freecalchub pilot: 15/15 checks. 31 permissions + env preserved.
- Both pilots had heavily dirty trees pre-upgrade (61 + 95 uncommitted changes respectively) — install correctly only mutated framework files and v5 markers, leaving genuine project content (Ideation/, Docs/, sitemap, etc.) untouched.

**Deliverables**:
- `project/deployment/scripts/install.sh` — sets `AGENT11_INSTALL_INVOKED=1` before invoking migrate-v5-to-v6.sh subprocess.
- `project/deployment/scripts/migrate-v5-to-v6.sh` — new conditional branch in the ENABLE_TOOL_SEARCH check: when invoked under install.sh, prints a single-line note instead of the stale advisory; standalone path reworded to point at `install.sh --upgrade` and `docs/UPGRADE.md`.
- `CHANGELOG.md` — v6.1.1 entry (Patch).
- `docs/RELEASE-HISTORY.md` — v6.1.1 section.

**Verified**:
- bash -n syntax clean on both modified scripts.
- Fixture 02 (custom-mcp regression) — 10/10.
- Subprocess mode: stale "Manual merge recommended" gone; new "install.sh will merge it next" note present; final summary truthful.
- Standalone mode: original advisory preserved (with new wording); install.sh --upgrade pointer present.

**Next**: tag v6.1.1, then resume bulk migration of remaining 15 repos.

---

### [2026-05-07] — Sprint 5a T9: v6.1.0 released ✅ (Sprint 5a CLOSED)

**Summary**: v6.1.0 — "Hardened Upgrade Path" — tagged and released. All 9 commits ahead of main pushed; tag `v6.1.0-hardened-upgrade-path` pushed; GitHub release live with full notes. Sprint 5a is closed.

**Release artefacts**:
- Tag: `v6.1.0-hardened-upgrade-path` (annotated, includes one-command upgrade snippet + doc pointers)
- GitHub release: https://github.com/TheWayWithin/agent-11/releases/tag/v6.1.0-hardened-upgrade-path
- CHANGELOG.md, docs/RELEASE-HISTORY.md dated 2026-05-07
- README.md: 3 surgical edits (v6.0 highlights bullet, v5.x upgrading section, MCP profile retirement note) — single-command upgrade replaces the two-step
- docs/MCP-GUIDE.md: migration section rewritten
- library/CLAUDE.md (deployed file): migration line updated to point at `bash install.sh --upgrade` (this ships in every new v6.1+ install)

**Sprint 5a final commit history** (9 commits on main):
- `94ad691` — spec hardened post-review (path A locked)
- `356e444` — T1+T2: install.sh detects v5, invokes migrate as subprocess
- `412ef2f` — T3+T4: settings.json surgical merge + truthful summary
- `532d913` — T5: migrate.sh output clarity
- `c8e58f8` — T7+T8: rollback restore script + CLI flags + upgrade docs
- `a0c336d` — T6: canonical install fixtures
- `29db9c4` — T9 docs prep
- `bd6412e` — date bump (2026-05-06 → 2026-05-07 to match tag day)
- (this entry)

**Sprint stats**:
- 9 commits / ~1,974 lines added / 25 files
- 3 new scripts: merge-settings.py (157 lines), restore-pre-upgrade.sh (247 lines), 5 fixture run-test.sh (~240 lines combined)
- 5 canonical end-to-end fixtures, 43/43 checks passing
- New user-facing doc: docs/UPGRADE.md (139 lines)

**Convergent review concerns from path-A spec — all addressed in shipped code**:
1. Wrong version label → v6.1.0 minor (not v6.0.1 patch) ✅
2. Auto-migrate without consent risky → opt-in via `--upgrade` flag ✅
3. Rollback path missing → `restore-pre-upgrade.sh` + UPGRADE.md rollback section ✅
4. T6 fixture too thin → 5 fixtures covering realistic v5 shapes ✅
Plus dev-specific edges: Python 3 fallback, JSON edge cases, conflict semantics, subprocess error handling, `--dry-run` flag ✅

**Next sprint (5b)**: bulk migration of Jamie's 17 active priority repos using `bash install.sh --upgrade --non-interactive` in a small batch wrapper. The `--non-interactive` flag was added in T8 specifically for this contract.

---

---

### [2026-05-06] — Sprint 5a T6: canonical install fixtures under test-projects/ ✅

**Summary**: Five canonical end-to-end test fixtures live under `test-projects/install-fixtures/`. Each spins up a self-contained pre-state under `mktemp -d`, runs `install.sh --upgrade`, and asserts post-conditions. The five scenarios were chosen post-review to cover the realistic shapes a v5→v6 upgrade hits in the wild — replacing the single happy-path fixture the original spec proposed.

**Deliverables**:
- `test-projects/install-fixtures/`:
  - `README.md` — index + scenario table + how-to-run + rationale for the five-fixture set
  - `run-all.sh` — aggregate runner; pass/fail summary
  - `01-clean-v5/` — minimal v5 install (4 markers, no settings.json) → asserts markers cleaned, agent-context.md created, 11 specialists deployed, settings.json deployed verbatim
  - `02-custom-mcp/` — v5 + user-customised settings.json (rich permissions, _comment, custom env keys) → asserts every user value survives the merge; ENABLE_TOOL_SEARCH and hooks added alongside
  - `03-malformed-json/` — v5 + settings.json with trailing comma → asserts merge fails cleanly, original restored from backup, summary truthful, rest of install completes
  - `04-partial-migration/` — interrupted prior migration (one marker remaining + stale backup directory) → asserts recovery notice in output, remaining marker cleaned, both backups preserved
  - `05-already-v6/` — fully v6 install → asserts no migration triggered, semantic-hash match on settings.json (content unchanged through the no-op merge), summary truthful
- Each fixture has its own `README.md` (scenario + expected outcome) and self-contained `run-test.sh` (sets up pre-state, runs installer, runs assertions, traps cleanup on exit)

**Verified**: 43/43 individual checks across 5 fixtures via `bash test-projects/install-fixtures/run-all.sh`. All workdirs cleaned up on exit.

**Why five not one**: Architect + dev review of the spec flagged that a single happy-path fixture was insufficient. These five cover the canonical happy path (01), the user-values-must-survive risk (02), bad-input handling without state corruption (03), idempotency of partial state (04), and true no-op on already-v6 (05). The runner fails if any regress in future sprints.

**Next**: T9 — v6.1.0 release (CHANGELOG entry, RELEASE-HISTORY entry, README v5.x section update, tag, GitHub release).

---

### [2026-05-06] — Sprint 5a T7+T8: rollback restore script + CLI flags + upgrade docs ✅

**Summary**: Added `restore-pre-upgrade.sh` to undo a v5→v6 upgrade from backups, `--dry-run` and `--non-interactive`/`--batch-safe` flags to install.sh, and a focused `docs/UPGRADE.md` covering the upgrade flow, backup contents, rollback procedures, and known limitations. install.sh and migrate.sh warning messages now point at the new doc and the restore script. The `--non-interactive` flag is the contract Sprint 5b's bulk wrapper depends on.

**Deliverables**:
- `project/deployment/scripts/restore-pre-upgrade.sh` (new, ~190 lines):
  - `--list` / interactive selector / `--latest` / `--backup <path>` modes
  - Known-mapping restore: handoff-notes.md, agent-context.md, .mcp-profiles/, dynamic-mcp.json (→ mcp/dynamic-mcp.json), handoff-notes-template.md (→ templates/), CLAUDE.md (→ .claude/), settings.json (→ .claude/)
  - Separate `--settings <path>` mode for restoring a single settings.json backup without touching v5 markers
  - TTY-aware confirmation; `--yes` for non-interactive use
- `project/deployment/scripts/install.sh`:
  - Three new flags: `--dry-run`, `--non-interactive`, `--batch-safe` (alias)
  - `print_dry_run_plan` function: inspects v5 markers, settings.json state, execution mode; itemises what would happen
  - `--help` rewritten with full flag table + examples
  - `docs/UPGRADE.md` added to both local-copy and GitHub-download branches of doc deployment
  - Warning messages now point at docs/UPGRADE.md and the curl-streamable restore script
- `project/deployment/scripts/migrate-v5-to-v6.sh`:
  - Final-summary "Rollback:" line now references the restore script + UPGRADE.md
- `docs/UPGRADE.md` (new):
  - TL;DR one-liner upgrade
  - Why `--upgrade` flag is required (explicit consent)
  - What the upgrade does (6 numbered steps)
  - Backup table (two locations, what's in each)
  - Preview / dry-run instructions
  - Rolling back via the restore script + manual recovery steps
  - Bulk-upgrade pattern using `--non-interactive`
  - Known limitations (Python 3 dep, lossy nested-file backup, opt-in rationale)
  - Troubleshooting section for the common failure modes

**Verified**:
- T7 — 19/19 checks across 4 fixtures: end-to-end migrate-then-restore (v5 markers come back, content matches, backup directory preserved); `--list` mode; `--settings` flag for settings-only restoration; clear error when no backups exist.
- T8 — 29/29 checks across 9 fixtures: `--help` shows all flags + examples; greenfield `--dry-run` correctly identifies "fresh install"; v5 fixture without `--upgrade` reports "would EXIT 1"; v5 fixture with `--upgrade` reports "would invoke migrate"; `--dry-run` against already-v6 settings.json reports "no-op"; `--dry-run` against custom settings.json reports "would merge"; `--non-interactive` and `--batch-safe` accepted; `--upgrade --dry-run --non-interactive` composable.
- Sanity check: T1's warn-and-exit still works correctly (exit 1) with the updated message pointing at docs/UPGRADE.md.

**Next**: T6 (canonicalise the test fixtures under `test-projects/` — currently testing happens via `/tmp` shell scripts), then T9 (release v6.1.0).

---

### [2026-05-06] — Sprint 5a T5: migrate.sh output clarity ✅

**Summary**: Three previously-ambiguous output cases now distinguished. The original UX wart: re-running the script after a successful migration produced output identical to the "you were always on v6" case. Users couldn't tell whether their previous migration had run. Fix detects the prior backup directory and tailors the message accordingly, plus the success summary now itemises what work actually got done.

**Deliverables**:
- `project/deployment/scripts/migrate-v5-to-v6.sh`:
  - Top-of-script: detect most-recent `v5-to-v6-*` backup directory if present.
  - No-markers branch: now distinguishes "completed previously (backup at <path>)" from "always on v6.0 — no migration needed".
  - Markers + prior backup branch: explicit "Prior migration backup found … completing the remaining migration steps" notice.
  - Each migration step pushes a label into `ACTIONS_PERFORMED[]` when it actually does work (skipping during `--dry-run`).
  - Final success summary: itemises `ACTIONS_PERFORMED` as bullets after "Migration complete". When the array is empty (e.g. all markers individually skipped), says so explicitly.

**Verified**: 15/15 checks across 4 fixtures:
- already-v6 / no prior backup → "Already on v6.0 — no migration needed"
- already-v6 / prior backup → "Migration was completed previously" + backup path
- v5 markers / fresh first run → "Performed:" list with all 3 actions
- v5 markers + prior backup (interrupted previous run) → "completing the remaining migration steps" notice + only-remaining-item in Performed list

**Next**: T8 (install.sh `--dry-run` + `--non-interactive` flags), then T7 (rollback restore script + docs), then T6 (canonical fixtures), then T9 (release).

---

### [2026-05-06] — Sprint 5a T3+T4: settings.json surgical merge + truthful summary ✅

**Summary**: `install.sh` now merges the v6 template into existing `settings.json` instead of leaving-and-warning. User values win on every conflict (template only fills gaps). Backup → merge → re-validate → auto-restore-on-fail protects against silent corruption. The post-install summary message is no longer a lie — it conditionally renders based on whether `ENABLE_TOOL_SEARCH` and `hooks` actually landed in the on-disk file.

**Deliverables**:
- `project/deployment/scripts/merge-settings.py` — new ~130-line Python 3 helper. Atomic write (`<path>.new` then `os.replace`). Edge cases handled: BOM stripped, trailing commas rejected, duplicate top-level keys rejected, `$schema`/`_comment`/custom keys preserved. Exit codes documented for install.sh consumption.
- `project/deployment/scripts/install.sh`:
  - Two new helper functions: `find_or_fetch_settings_merger`, `find_or_fetch_settings_template` (both follow the local-first / GitHub-fallback pattern from T2).
  - `install_settings_template` rewritten: existing settings.json → merge via Python helper, with bash-side re-validation and auto-restore on any failure.
  - `show_post_install_instructions` (T4): conditional on new `SETTINGS_HAS_V6_FEATURES` global. True → "Tool deferring enabled". False → "Tool deferring NOT enabled" + backup pointer + manual merge instructions.
  - Python 3 missing: graceful degradation — writes `settings.json.new` alongside original with manual merge instructions, sets flag false, summary flags clearly.

**Verified**:
- 9/9 unit tests on `merge-settings.py` (already-v6 / empty / permissions-only / custom-env / tool-search-only / hooks-only / trailing-comma / array-root / schema-comment).
- 20/20 integration checks across 4 realistic v5 fixtures:
  - Case A (rich permissions, no env/hooks): permissions allow/deny preserved, `_comment` preserved, ENABLE_TOOL_SEARCH + hooks added, summary truthful.
  - Case B (already on v6): noop, content unchanged.
  - Case C (trailing comma): merge fails, original preserved via auto-restore, backup file present, summary truthful ("NOT enabled").
  - Case D (custom env keys CUSTOM_VAR + ANOTHER): preserved alongside new ENABLE_TOOL_SEARCH; hooks added.
- Greenfield path (no existing settings.json) still deploys template verbatim, summary truthful.

**Deliberate deviation from spec wording**: spec said "Python 3 unavailable → install exits non-zero". Current implementation logs the warning, writes `settings.json.new`, sets the flag false, but **returns 0** so the rest of the install completes (agents/missions/templates still deploy). The intent of the spec line was "flag this clearly in the summary" — that intent is preserved via the SETTINGS_HAS_V6_FEATURES flag and the conditional summary message. A non-zero return would trigger the install pipeline's rollback, which is too aggressive for a missing optional dependency.

**Open from this task**: T6 fixture variants (5 of them) still need to be canonicalised under `test-projects/`. Current testing was via `/tmp` shell scripts.

**Next**: T5 (migrate-v5-to-v6.sh output clarity — distinguish "migrated" vs "already migrated" vs "partial recovery"); T6 (canonical fixtures); T7 (rollback docs + restore script); T8 (--dry-run + --non-interactive flags); T9 (release).

---

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

---

### [2026-07-16] — PRJ-14: BOS-AI handoff optimisation (tasks 1–5)

**Context**: Mission-control project PRJ-14 (`~/shared/mission-control/projects/PRJ-14-bos-ai-agent-11-handoff.md`). Review of the BOS-AI → AGENT-11 handoff found two competing conventions, installer gaps, and no documented ownership rule. ModelOptix pair audit proved the PRD's source of truth migrates to the dev repo once building starts — so the handoff is a one-time release, not a sync.

**Delivered (uncommitted, pending Jamie's commit approval)**:
1. **Installer (A11-ISS-1)**: all 9 `foundation-*.schema.yaml` added to install.sh `schema_files`; verified via test install (16 schemas land in `./schemas/`). Dangling `project/schemas/` refs → `schemas/` in foundations.md, plan.md, bootstrap.md, stack-profiles README. `validate_foundations.py` deliberately NOT deployed (unreferenced + stale, knows 5 of 9 categories — stays internal). Checksum regenerated.
2. **Single convention (A11-ISS-2)**: deleted `field-manual/bos-ai-integration-guide.md` + `bos-ai-quickstart.md`; new canonical `field-manual/bos-ai-handoff.md` (two entry tiers + ownership-transfer rule) written and added to install.sh field-manual deploy list (verified installs). README relinked/reworded (4 spots incl. the stale `ideation/` snippet at the BOS-AI Integration section). Root `INTEGRATION-GUIDE.md` slimmed to a pointer (the bundle/validation-gateway architecture it described was never implemented); archive banners on WORKFLOWS.md, INTEGRATION-STANDARDS.md, BOS-AI-AGENT-11-INTEGRATION-ARCHITECTURE.md. Example `examples/bos-ai-integration/` converted `ideation/` → `documents/foundations/` with mapper-compatible filenames (git mv) + README rewritten on the `/foundations` rail.
3. **Missions**: dev-setup + dev-alignment got BOS-AI routing notes (use `/foundations` rail when foundation docs exist; missions keep `ideation.md` for the no-foundation-docs case).
4. **Lite tier**: `/foundations` vision requirement relaxed — prd stays required; vision now "conditionally required" (error for saas builds since `/bootstrap` needs vision.yaml there; warning for tools/libraries/APIs). Enables PRD-only entry for ad-hoc builds.
5. **BOS-AI repo** (`~/DevProjects/BOS-AI/README.md`, uncommitted): ownership-transfer paragraph added to the AGENT-11 handoff section, linking to the new guide.

**Verification**: `bash -n` clean; two full test installs into scratchpad confirmed schemas + guide deploy; `shasum -c` OK; no dangling links to deleted guides outside historical audit docs.

**Next**: PRJ-14 task 6 — pilot the lite tier on the Digital Estate repo (PRJ-13) once created.
