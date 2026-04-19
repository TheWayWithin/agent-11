# Agent-11 v6.0 Validation Harness

**Purpose**: a small, fixed set of tasks that we run on every v6.0 milestone to prove each sprint's change is an improvement — not a theoretical one.

**Used by**: Sprint 4a T2 (baseline on v5.2), every subsequent sprint's closing measurement task, and Sprint 4h for final v6.0-vs-v5.2 comparison.

**Design rules**:
- Tasks must be fully reproducible (same fixture, same prompt, every run).
- Metrics must be capturable without special tooling — just Claude Code + a stopwatch + a notes file.
- Scope is five tasks. Five is enough to cover the main Agent-11 use cases; more is ceremony.

---

## Metrics (5)

| # | Metric | Definition | How Captured |
|---|--------|------------|--------------|
| M1 | Task completion time | Wall-clock from "first prompt sent" to "task done or abandoned" | Stopwatch, log start/end in notes |
| M2 | Session-start tokens | Context-window tokens used immediately after `claude` starts, before any user message | Run `/context` as the first command; record the reported total |
| M3 | Delegation count | Number of Task-tool subagent invocations during the task | Count in the session transcript (grep `subagent_type`) |
| M4 | Human interventions | Number of times the human had to redirect, correct, or unblock the agent to continue | Tally in real time while running the task |
| M5 | Restart / recovery success | Whether the task can be paused via `/clear` mid-flight and resumed from files only | Boolean: yes / no / not-attempted (only tested on tasks 1 and 2) |

**Secondary capture** (useful, non-blocking): total tokens at task end; number of `gh` / `git` commands executed; number of files created vs files verified.

---

## Tasks (5)

Each task has a self-contained fixture under `project/validation/fixtures/<task-id>/`. Fixtures are prepared once and committed; runs start from a clean copy.

### Task 1 — Greenfield Bootstrap

**Fixture**: `fixtures/t1-greenfield/ideation.md` — a 1-page ideation doc for a simple SaaS (proposal: a "tiny link shortener with login and per-user stats" because it touches auth, DB, and a minimal UI without requiring niche domain knowledge).

**Starting state**: empty `test-projects/t1-greenfield/` directory; ideation doc copied in; `claude` started there.

**Initial prompt** (verbatim):
```
/coord build ideation.md
```
(On v6.0 this becomes `/coord build ideation.md` per the new router; same prompt.)

**Success criteria**:
- `project-plan.md` exists and has phased tasks.
- At least one specialist has been delegated to.
- Work has started on scaffolding (files created in the project root).

**Stop criteria**: Either success criteria met, or 30 minutes elapsed, or 3 consecutive human interventions needed.

**M5 eligible**: Yes — pause after phase 1 completes, `/clear`, restart, resume.

---

### Task 2 — Feature Addition on Existing Codebase

**Fixture**: `fixtures/t2-feature-add/` — a small TypeScript project with an existing `package.json`, a couple of routes, and a `CLAUDE.md`. Tracked in-repo; runs start from a clean copy.

**Starting state**: fixture copied to `test-projects/t2-feature-add/`; `claude` started there.

**Initial prompt** (verbatim):
```
/coord refactor Add a /health endpoint that returns { status: "ok", uptime: <seconds> }. Add a test for it. Follow existing code style.
```

**Success criteria**:
- `/health` endpoint exists and returns the required shape.
- Test for `/health` exists and passes.
- No unrelated files modified.

**Stop criteria**: 20 minutes or 3 interventions.

**M5 eligible**: Yes.

---

### Task 3 — Bug Fix (Single File)

**Fixture**: `fixtures/t3-bug-fix/` — same small TypeScript project as T2 but with a **seeded bug**: an off-by-one error in a pagination helper plus a failing test that pinpoints it.

**Starting state**: fixture copied; `claude` started there.

**Initial prompt** (verbatim):
```
/coord fix The pagination test is failing. Make it pass without weakening the test.
```

**Success criteria**:
- Failing test now passes.
- Test file unchanged (no weakening).
- Only the pagination helper modified.

**Stop criteria**: 10 minutes or 2 interventions.

**M5 eligible**: No — too short for pause/resume to matter.

---

### Task 4 — Refactor (2-3 Files)

**Fixture**: `fixtures/t4-refactor/` — TypeScript project where three routes each re-implement the same auth check inline. Goal: extract to a middleware.

**Starting state**: fixture copied; `claude` started there.

**Initial prompt** (verbatim):
```
/coord refactor Extract the repeated auth check from the three route files into a single middleware. Tests must still pass.
```

**Success criteria**:
- One middleware file created.
- Three route files use it.
- All existing tests pass.

**Stop criteria**: 25 minutes or 3 interventions.

**M5 eligible**: No — atomic by nature.

---

### Task 5 — Commit Review (Read-Only)

**Rationale for shape**: Jamie is a solo developer who pushes straight to `main` rather than raising PRs. "Review a substantive commit" matches his real workflow better than "review a PR".

**Fixture**: `fixtures/t5-commit-review/` containing:
- `diff.md` — the full diff from agent-11 commit `d501ca9` (security: Add install integrity verification, lockfile, terminal detection, and CI hardening). Generated with `git show d501ca9 > diff.md`.
- `message.md` — the commit message from `d501ca9` as the "change description".

**Starting state**: a fresh run directory with the fixture copied in, `git init`ed, Agent-11 installed via `secure-install.sh`; `claude` started there.

**Initial prompt** (verbatim):
```
/coord Please review the commit at diff.md against the description in message.md. List concerns grouped by severity: blocker, concern, nit. Read-only — do not modify files.
```

**Success criteria**:
- Review produced with blocker / concern / nit groupings.
- At least one real observation (verifiable by re-reading the diff).
- Zero files modified in the repo.

**Stop criteria**: 15 minutes.

**M5 eligible**: No — read-only.

---

## Run Procedure

For one harness run (either baseline v5.2 or any later milestone):

1. **Prepare**. From a clean working tree on the target version, for each task:
   - Copy the fixture to `test-projects/<task-id>/`.
   - Ensure no stale session state (`rm -rf` of any `.claude/` history for that project).
2. **Execute each task sequentially**:
   - Start `claude` in the task's directory.
   - Immediately run `/context` — record M2.
   - Start stopwatch — note start time.
   - Paste the verbatim initial prompt.
   - Tally interventions (M4) while working.
   - When success or stop criteria reached, note end time (M1).
   - Before exiting, check session transcript / save for delegation count (M3).
   - If M5 eligible and baseline/target run — midway, do `/clear`, restart, and see if task resumes. Note boolean (M5).
3. **Record** results per task in the run's results file (`baseline-v5.2.md` for the baseline; `milestone-<sprint>.md` for later runs).

---

## Results File Format

Each run produces one markdown file with a table per task. Template:

```markdown
# Harness Results — <run-name> — <date>

**Version / Sprint**: <e.g., v5.2 baseline, or "post-4b">
**Executor**: <name>
**Notes**: <setup notes, anomalies, etc.>

## Task 1 — Greenfield Bootstrap
| Metric | Value |
|--------|-------|
| M1 completion time | <mm:ss or "abandoned"> |
| M2 session-start tokens | <number> |
| M3 delegation count | <number> |
| M4 human interventions | <number> |
| M5 restart success | yes / no / n/a |
| Outcome | success / partial / abandoned |
| Notes | <1-3 lines on what was notable> |

## Task 2 — ...
```

---

## What Gets Compared

Every later sprint writes its own results file and compares to the baseline. The sprint's success depends on what it claims to improve:

| Sprint | Primary metric(s) expected to move |
|--------|------------------------------------|
| 4a (this sprint) | Baseline only — no target to beat |
| 4b (prompt hygiene) | M2 session-start tokens, M4 interventions |
| 4c (router) | M2 for Mode B1/C tasks (3, 5); M3 for all |
| 4d (native primitives) | M4 (hooks catching what the coord was nagging about) |
| 4e (context consolidation) | M2 across all tasks; M5 still yes |
| 4f (dynamic MCP) | M2 massively (blueprint target: ~80% reduction) |
| 4g (skills + routines) | M1 on Task 1 (skills compress boilerplate) |
| 4h (final) | All metrics vs baseline; sprint-level attribution |

---

## Out of Scope

- Automated metrics collection (nice-to-have, out-of-scope for v6.0).
- Multi-run averaging (single run per task per milestone is enough for solo-founder signal).
- Cross-model comparison (Opus vs Sonnet) — keep Opus 4.7 throughout for consistency.

---

## Locked Decisions (2026-04-18)

1. **Task 1 fixture**: tiny link shortener with login and per-user stats (chosen over "gated landing page with Mailchimp subscribe").
2. **Task 5 fixture**: agent-11 commit `d501ca9` (security hardening). Framing shifted from "PR review" to "commit review" to match Jamie's actual workflow (solo dev pushing to main, no PRs).
3. **M5 scope**: restart/recovery tested only on Tasks 1 and 2.
4. **Executor for baseline run (T2)**: Option B — Claude drives all 5. Implications and caveats will be documented in the baseline results file so later sprint comparisons use the same executor stance.
