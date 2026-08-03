# Mission: OPTIMIZE ⚡
## Metric-Driven Ratchet Optimization

**Mission Code**: OPTIMIZE
**Estimated Duration**: 2-6 hours (watched first run; faster once trusted)
**Complexity**: Medium to High
**Squad Required**: Analyst (pick the target), Developer (run the ratchet), Architect (sanity-check the strategy)

## ORIENTATION PROTOCOL — MAP FIRST, READ NARROWLY

Orientation is the expensive step, not the edit. On a large repo the bottleneck is finding what to change, not changing it, and the tokens spent reading files that turned out to be irrelevant are the largest avoidable cost in a session. These four rules are requirements, not preferences.

1. **Glob/Grep to locate before you Read.** Find the path and the line number first: `Glob` for file paths, `Grep` for symbols, strings and call sites. Do not open a file to discover what is in it.
2. **Read only the lines you need.** Use `offset` and `limit` on Read. A 40-line window around a confirmed match beats a 900-line whole-file read.
3. **Never read a whole file to find one symbol.** Grep for the symbol, then read its neighbourhood. Read a file end to end only when you are about to change it end to end.
4. **Do not re-read what you have already read.** Every re-read re-pays the whole file as input tokens and crowds out the context you still need.

If you read a whole file, be able to state why a narrower read would not have worked.

## Mission Briefing

Improve one measurable thing about a system without breaking anything else, by running a
disciplined **ratchet loop**: isolate the work, establish a noise-floor baseline, make ONE
change on a NAMED surface, re-measure, and **keep the change only if it beats the baseline —
otherwise hard-revert.** Every attempt is logged. Every kept change is a hypothesis the human
merges, never an auto-merge.

This is the Karpathy autoresearch discipline applied to a single repo: diligent hill-climbing
with a hard floor against regressions and reward-hacking, not open-ended autonomy.

### What changed (Sprint 6b)

Earlier versions of this mission profiled a system and then asked specialists to "optimise
the code" across five vague phases. That produced unmeasured, unreverted, hard-to-audit
changes. The mission now keeps the useful front-end — **decide what to optimise** — and
replaces the execution core with the ratchet — **iterate on it safely**. Read
`field-manual/loop-discipline-guide.md` before running this for the first time.

## Required Inputs

1. **Named editable surface** (required) — the ONE file or folder the loop may change.
   Everything else is off-limits. Example: `src/search/ranker.ts` or `app/api/feed/`.
2. **Metric command** (required) — one cheap, deterministic command that prints a single
   number, lower-is-better or higher-is-better (state which). Example:
   `node bench/rank.js --json | jq .p95_ms`. If there is no such command, you are not ready
   to loop — build the benchmark first.
   - **The metric must measure the intent, not a proxy for it.** Field-tested 2026-06: a run
     targeting "faster page load" used *total JS bytes on disk* as the metric. Lazy-loading a
     heavy chart library barely moved that number (the library is still shipped, just in a
     deferred chunk) even though the actual initial-load win was real. The metric should have
     been the route's **First Load JS**, not total disk size. Before you loop, ask: "if this
     number drops, did the thing I actually care about improve?" If not, pick a different
     number. This is Goodhart's law (see caveats); the wrong metric makes the loop optimise
     the wrong thing diligently.
3. **Baseline / goal** (optional) — current number and a target. If omitted, the loop measures
   the baseline itself and reports gains as percentages.
4. **Caps** (optional, defaults below) — max attempts, wall-clock, diff size, token ceiling.

> If you cannot name the surface and the metric command in one sentence each, STOP. The loop
> has no fixed signal for "done" and will waste tokens. Go build the signal first.

## The Read-Only Set (inherited from Sprint 6a — non-negotiable)

The loop may NEVER edit the things that judge it:

- `.quality-gates.json`, `gates/**`, `**/*.quality-gates.json`
- The metric command, the benchmark, or any test that defines "better"
- Any file outside the named editable surface

An attempt that would require touching any of them is an **escalation trigger**, not a quiet
widening of scope. An agent that can edit its own success metric will eventually pass by editing it.

**Only the first line is enforced when you start.** The four `permissions.deny` rules shipped with
AGENT-11 cover `.quality-gates.json`, `**/*.quality-gates.json`, `gates/**` and `.gates/**`, and a
PreToolUse hook catches the common Bash write forms against the same paths (not all of them: see A11-ISS-16). The metric command, the benchmark and
"everything outside the named surface" are chosen fresh at Phase 1 of every run, so no shipped rule
can possibly cover them. Nothing writes one for you.

That gap is the whole reward-hacking surface of this mission: the one file the loop is most rewarded
for editing is the one that decides whether it succeeded, and by default nothing stops it. **Phase 2
therefore closes it by hand, and the mission does not proceed until it has.**

## Mission Phases

### Phase 1: Pick the target and the signal (20-40 minutes)
**Lead**: @analyst
**Support**: @architect
**Objective**: Reduce the whole system to ONE surface and ONE number.

**Tasks**:
- Profile only enough to find the single highest-leverage bottleneck. Do not boil the ocean.
- Name the ONE editable surface (file or folder) the loop will change.
- Name the ONE metric command that prints the signal, and its direction (lower/higher better).
- Confirm the metric is cheap (seconds, not minutes) and deterministic enough to median over.

**Success Criteria** (default-fail — each starts `false`, flips only on evidence):
- [ ] Editable surface named and confirmed to exist (`ls` output attached).
- [ ] Metric command runs and prints a single number (command output attached).
- [ ] Direction stated. Noise observed across 3 runs is smaller than the gain you are chasing.

### Phase 2: Set up the ratchet (15-30 minutes)
**Lead**: @developer
**Support**: @architect
**Objective**: Build the isolated harness and the noise-floor baseline.

**Tasks**:
- Create an isolated **git worktree** for the loop. The main checkout is never touched.
  - **JS/TS projects need a dependency strategy.** Field-tested 2026-06: a separate-directory
    worktree fails on Next.js/Turbopack (and similar) because the build rejects a symlinked
    `node_modules` ("points out of the filesystem root"), and a full copy is gigabytes. Pick
    one: (a) `npm install` inside the worktree (clean but slow), (b) hardlink deps into the
    worktree (`rsync -a --link-dest`), or (c) for a single serial loop, skip the separate
    directory and isolate with a **disposable branch in the main checkout** — equally safe
    when all real work is already committed and pushed (hard-revert with `git checkout -- .`,
    keep with a branch commit, never touch the base branch). Worktree isolation is the goal;
    a disposable branch achieves it for serial loops.
- Run the metric command **3 times** on the unchanged code; record the **median** as the
  baseline. This median-of-3 is the noise floor — it stops a lucky single run ratcheting in.
- Set the **noise-floor threshold**: a change must beat the baseline by more than observed
  run-to-run variance to count as real.
- Create the append-only log `.loops/optimize-<surface>.log` (JSONL, schema below).
- Confirm caps (defaults: 10 attempts, 1h wall-clock, 1000-line diff/iteration, token ceiling
  logged).
- **Write the deny rules for THIS run's read-only set, then prove they bite.** The shipped rules
  cover the gate paths only; the metric and the benchmark named in Phase 1 are covered by nothing
  until you add them. Append an `Edit(path)` rule to `permissions.deny` in the project's
  `.claude/settings.json` for the metric command's script or binary, for the benchmark or test
  file that defines "better", and for any fixture the metric reads. Use the `Edit(path)` form:
  `Write()` and `MultiEdit()` rule forms are silently ignored (A11-ISS-7), while `Edit(path)`
  applies to every file-editing tool.

  ```jsonc
  // .claude/settings.json — added for this run, removed when the mission ends
  "permissions": {
    "deny": [
      "Edit(.quality-gates.json)",        // shipped
      "Edit(**/*.quality-gates.json)",    // shipped
      "Edit(gates/**)",                   // shipped
      "Edit(.gates/**)",                  // shipped
      "Edit(bench/rank.js)",              // THIS RUN: the metric command
      "Edit(bench/fixtures/**)"           // THIS RUN: what the metric reads
    ]
  }
  ```

  The two `THIS RUN` entries are the point: no shipped rule covers a metric command, so until you
  add one it is not enforced by anything. You are creating the enforcement, not invoking it.

  Then verify with evidence, because an unverified deny rule is worth nothing: attempt one edit to
  the metric file and attach the refusal. A rule you did not watch refuse something is a guess.

  If the metric is a shell one-liner rather than a file, there is nothing to deny. Say so
  explicitly in the log, and treat the run as **watched** for its whole duration: the enforcement
  you do not have is replaced by a human who is looking.

**Success Criteria**:
- [ ] Worktree created (`git worktree list` output attached).
- [ ] Baseline = median of 3 runs, all 3 numbers logged.
- [ ] Noise-floor threshold set above observed variance.
- [ ] `.loops/optimize-<surface>.log` exists and is writable.
- [ ] Deny rules for this run's metric and benchmark are present in `.claude/settings.json`
      (the file's `permissions.deny` array attached), **or** the log records why no file-level
      rule is possible and that the run is watched throughout.
- [ ] The added rules were tested: an attempted edit to the metric file was refused, and the
      refusal is attached.

### Phase 3: Run the ratchet loop (the execution core)
**Lead**: @developer
**Support**: @architect (only on escalation)
**Objective**: Climb the metric one reverted-unless-better step at a time.

This phase IS the mission. Repeat until two consecutive attempts yield no improvement, or a cap
or escalation trigger fires.

```
RATCHET LOOP (per attempt):
  1. Read .loops/optimize-<surface>.log. Do not repeat a change already logged as revert.
  2. Form ONE hypothesis. Make ONE change, confined to the named surface only.
  3. If the diff exceeds the cap (default 1000 lines), STOP — revert and escalate.
  4. Re-measure: run the metric command 3 times, take the median.
  5. KEEP-OR-REVERT:
       - KEEP   if median beats baseline by more than the noise-floor threshold
                AND no gate/test regression (run gates; default-fail on no evidence).
                → commit in the worktree, set baseline = new median, status: "keep".
       - REVERT otherwise. → `git checkout -- <surface>` (hard revert), status: "revert".
  6. Append one JSONL line to the log (schema below). Always log, keep or revert.
  7. CONVERGENCE / CAP CHECK:
       - Stop "converged" after 2 consecutive non-improving attempts.
       - Stop "capped" if attempts ≥ max, wall-clock ≥ max, or tokens ≥ ceiling.
       - ESCALATE to human if: 3 consecutive crashes/reverts on the same idea, the diff cap
         would be exceeded, or any change would require touching the read-only set.
```

**Log schema** (`.loops/optimize-<surface>.log`, one JSON object per line):

```json
{"commit": "<sha-in-worktree-or-null>", "metric": 142.3, "median_of_3": 142.3, "baseline": 150.1, "status": "keep", "diff_lines": 38, "tokens": 4200, "desc": "memoise ranker score lookup"}
```

The log is the loop's memory: the agent reads it to avoid re-running dead ends; the human reads
it as a list of hypotheses to review at merge time.

**Success Criteria**:
- [ ] Every attempt produced exactly one log line (keep or revert), evidence = the log file.
- [ ] No change landed outside the named surface (`git diff --stat` confined to surface).
- [ ] Loop stopped on convergence, cap, or escalation — never ran unbounded.

### Phase 4: Read the log and decide (human merge — 15-30 minutes)
**Lead**: @analyst presents; **human decides**
**Objective**: Treat kept changes as hypotheses, not facts.

**Tasks**:
- Summarise the log: baseline → best median, total attempts, kept vs reverted, tokens spent.
- For each kept change, present the diff and the measured gain as a hypothesis to merge.
- The human merges the worktree commits they accept. Nothing merges automatically.
- Record the token-cost-per-converged-loop number (feeds Sprint 6c error budgets).

**Success Criteria**:
- [ ] Log summarised with before/after numbers and token cost.
- [ ] Each kept change reviewed as a diff by the human before merge.
- [ ] Worktree cleaned up after merge decision (`git worktree remove`).

## Caps and Escalation (library defaults — all overridable per run)

| Cap | Default | Why |
|-----|---------|-----|
| Max attempts | 10 | Bounds cost; most gains land early or not at all. |
| Max wall-clock | 1 hour | Circuit breaker on a stuck loop. |
| Max diff / iteration | 1000 lines | Keeps each change reviewable and confined. |
| Token ceiling | Logged per run | Jamie sees the meter; loops cost multiples of a single pass. |

**Escalate to human (do not push forward) when**:
- 3 consecutive crashes or reverts on the same hypothesis.
- A change would exceed the diff cap or reach outside the named surface.
- Any change would require editing the read-only set (gates/tests/metric).

## Watched-first-run rule (trust is earned per repo)

The first time this mission runs on any repo, a human watches it end to end: ONE repo, ONE
worktree, up to TEN experiments, **nothing merged automatically**, the human reads the log as a
list of hypotheses. Only after a repo has earned trust through watched runs does anyone consider
running it less closely. Never unattended on a live repo before then.

## Honest caveats (carried from the research)

- **Goodhart / overfitting**: the ratchet optimises the metric, not the intent. Every kept
  change is reviewed at merge; the median-of-3 stops lucky-seed wins.
- **Greedy / local search**: keep-if-better is hill-climbing. It tunes; it does not invent
  structural rewrites that need a step down first. Set expectations accordingly.
- **Cost**: loops cost multiples of a single pass. Caps and token logging are mandatory.

## Optimization Categories (reference — where to point the loop)

### Frontend Performance
- Bundle splitting, lazy loading, tree shaking; critical CSS; image compression; HTTP/2, CDN.

### Backend Performance
- API response time and payload; query optimisation and indexing; algorithm complexity.

### Infrastructure Performance
- Caching layers, connection pooling, resource reuse, response-size trimming.

Pick ONE of these as the named surface per run. The ratchet does single-surface, single-loop
work; breadth comes from running the mission again, not from widening one loop.

## Tools and Technologies

- **Profiling (Phase 1)**: Chrome DevTools, Lighthouse, `node --prof`, query EXPLAIN plans, APM.
- **Metric command (the signal)**: any script that prints one number — `k6`, `lighthouse-ci`,
  a custom `bench/*.js`, `pytest-benchmark`, a `time`-wrapped command piped through `jq`.
- **Isolation**: `git worktree` (mandatory), never the main checkout.

---

**Mission Command**: `/coord optimize <editable-surface> <metric-command> [baseline-goal]`

*"A loop only earns its keep when 'better' is a number you can trust and 'worse' reverts itself."*

---

## Post-Mission Cleanup Decision

After completing this mission, decide on cleanup approach based on project status:

### ✅ Milestone Transition (Every 2-4 weeks)
**When**: This mission completes a major project milestone, but more work remains.

**Actions** (30-60 min):
1. Extract lessons to `lessons/[category]/` from progress.md and the `.loops/` log.
2. Archive milestone-relevant Phase Handoff blocks from agent-context.md if needed.
3. Clean agent-context.md (retain essentials, archive historical details).
4. Continue using agent-context.md (Phase Handoff blocks accumulate across milestones).
5. Update project-plan.md with next milestone tasks.

**See**: `templates/cleanup-checklist.md` Section A for detailed steps

### 🎯 Project Completion (Mission accomplished!)
**When**: All project objectives achieved, ready for new mission.

**Actions** (1-2 hours):
1. Extract ALL lessons from entire progress.md to `lessons/`.
2. Create mission archive in `archives/missions/mission-[name]-YYYY-MM-DD/`.
3. Update CLAUDE.md with system-level learnings.
4. Archive all tracking files (project-plan.md, progress.md, `.loops/` logs).
5. Prepare fresh start for next mission.

**See**: `templates/cleanup-checklist.md` Section B for detailed steps

### 🔄 Continue Active Work (No cleanup needed)
**When**: Mission complete but continuing active development in same phase.

**Actions**: Update progress.md and project-plan.md, continue working.

---

**Reference**: See `project/field-manual/project-lifecycle-guide.md` for complete lifecycle management procedures, and `project/field-manual/loop-discipline-guide.md` for the ratchet mechanics.
