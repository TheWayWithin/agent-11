# Harness Run Playbook

Step-by-step instructions to run the 5 harness tasks against any version of Agent-11. Use this for the v5.2 baseline (Sprint 4a T2) and every later milestone.

All 5 tasks are independent — you can run them in any order across multiple sittings. Each task is self-contained and starts from a clean copy of its fixture.

**Executor stance**: "Claude drives" (Option B from Sprint 4a). Jamie's active role is: open a terminal, copy the fixture, start `claude`, paste the verbatim prompt, observe, record. The fresh Claude session does the work.

---

## One-time setup (before first run)

From the `agent-11` repo root:

```bash
mkdir -p test-projects
```

That's it. `test-projects/` is gitignored; fixtures get copied here per run so the source fixtures stay pristine.

---

## What version of Agent-11 is being tested

The harness measures the version of Agent-11 **deployed into each run directory**, not the version of agent-11 running in this planning window. For the baseline, we deploy from `main` (v5.2). For later milestones, deploy from the sprint branch or tag.

Install command used throughout this playbook:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/secure-install.sh)
```

---

## Per-task procedure

Each task follows the same shape:

1. **Prep** — copy fixture, `git init`, deploy Agent-11 into the run directory.
2. **Start session** — `claude` from inside the run directory.
3. **Capture M2 (session-start tokens)** — first thing, run `/context` and record the reported total.
4. **Start timer** — stopwatch on your phone or `date +%s`.
5. **Paste the verbatim prompt** — exactly as below, no edits.
6. **Tally interventions (M4)** — count every time you have to redirect, correct, or unblock the agent. Leaving it alone to think is not an intervention.
7. **Stop when** success criteria met OR stop criteria hit.
8. **Capture M3 (delegation count)** — scroll back through session, count `subagent_type=` occurrences.
9. **Capture M5 (restart) on Tasks 1 and 2 only** — mid-task, do `/clear`, restart `claude`, prompt "continue", see if it picks up. Boolean pass/fail.
10. **Record** — fill the row in `baseline-v5.2.md` (or the milestone results file).

---

## Task 1 — Greenfield Bootstrap

**Prep** (copy fixture, init git, deploy Agent-11, then start):
```bash
mkdir -p test-projects
cp -R project/validation/fixtures/t1-greenfield test-projects/t1-greenfield-run
cd test-projects/t1-greenfield-run
git init -q && git add . && git commit -q -m "fixture: t1 greenfield initial state"
bash <(curl -fsSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/secure-install.sh)
claude
```

**First command in the Claude session**: `/context` — record M2.

**Prompt (paste verbatim)**:
```
/coord build ideation.md
```

**Success criteria**: `project-plan.md` exists and has phased tasks; at least one specialist delegated to; scaffolding files created.

**Stop criteria**: success OR 30 minutes OR 3 consecutive interventions needed.

**M5 check** (required): partway through (after phase 1 completes, or at the 15-min mark), run `/clear`. Exit, re-run `claude` in the same directory. Prompt: "continue". Did it resume from files correctly? Boolean.

---

## Task 2 — Feature Addition

**Prep**:
```bash
mkdir -p test-projects
cp -R project/validation/fixtures/t2-feature-add test-projects/t2-feature-add-run
cd test-projects/t2-feature-add-run
git init -q && git add . && git commit -q -m "fixture: t2 feature-add initial state"
bash <(curl -fsSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/secure-install.sh)
claude
```

**First command**: `/context` — record M2.

**Prompt (paste verbatim)**:
```
/coord refactor Add a /health endpoint that returns { status: "ok", uptime: <seconds> }. Add a test for it. Follow existing code style.
```

**Success criteria**: `/health` endpoint exists returning the required shape; passing test for `/health`; no unrelated files modified.

**Stop criteria**: 20 minutes OR 3 interventions.

**M5 check** (required): midway, `/clear`, restart, prompt "continue".

---

## Task 3 — Bug Fix

**Prep**:
```bash
mkdir -p test-projects
cp -R project/validation/fixtures/t3-bug-fix test-projects/t3-bug-fix-run
cd test-projects/t3-bug-fix-run
git init -q && git add . && git commit -q -m "fixture: t3 bug-fix initial state"
bash <(curl -fsSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/secure-install.sh)
claude
```

**First command**: `/context` — record M2.

**Prompt (paste verbatim)**:
```
/coord fix The pagination test is failing. Make it pass without weakening the test.
```

**Success criteria**: tests pass; test file unchanged; only `src/utils/paginate.ts` modified.

**Stop criteria**: 10 minutes OR 2 interventions.

**M5 check**: skip — task too short to matter.

---

## Task 4 — Refactor

**Prep**:
```bash
mkdir -p test-projects
cp -R project/validation/fixtures/t4-refactor test-projects/t4-refactor-run
cd test-projects/t4-refactor-run
git init -q && git add . && git commit -q -m "fixture: t4 refactor initial state"
bash <(curl -fsSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/secure-install.sh)
claude
```

**First command**: `/context` — record M2.

**Prompt (paste verbatim)**:
```
/coord refactor Extract the repeated auth check from the three route files into a single middleware. Tests must still pass.
```

**Success criteria**: one middleware file created; three route files use it; all tests pass.

**Stop criteria**: 25 minutes OR 3 interventions.

**M5 check**: skip — atomic by nature.

---

## Task 5 — Commit Review

Runs in a clean deployed Agent-11 project so the test reflects normal-user experience (not the agent-11 repo itself).

**Prep**:
```bash
mkdir -p test-projects
cp -R project/validation/fixtures/t5-commit-review test-projects/t5-commit-review-run
cd test-projects/t5-commit-review-run
git init -q && git add . && git commit -q -m "fixture: t5 commit-review initial state"
bash <(curl -fsSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/secure-install.sh)
claude
```

**First command**: `/context` — record M2.

**Prompt (paste verbatim)**:
```
/coord Please review the commit at diff.md against the description in message.md. List concerns grouped by severity: blocker, concern, nit. Read-only — do not modify files.
```

**Success criteria**: review produced with blocker / concern / nit groupings; at least one real observation; zero files modified.

**Stop criteria**: 15 minutes.

**M5 check**: skip — read-only.

**Cleanup**: exit the Claude session without letting it commit or modify anything.

---

## Between runs

After each task, before starting the next:

```bash
cd /Users/jamiewatters/DevProjects/agent-11
```

(Run directories in `test-projects/` are disposable — leave them; next run will overwrite or use a new name.)

---

## Recording results

Fill in one row per task in the active results file:
- Baseline: `project/validation/baseline-v5.2.md`
- Sprint milestones: `project/validation/milestone-sprint-<X>.md`

Both follow the template in `harness-spec.md` → "Results File Format".
