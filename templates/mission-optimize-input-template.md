# mission-optimize — Input Template

Fill this in before running `/coord optimize`. If you cannot complete the first three fields in
one sentence each, you are not ready to loop: build the metric command first.

---

## 1. Named editable surface (required)

The ONE file or folder the loop may change. Everything else is off-limits.

```
surface: <e.g. src/search/ranker.ts>
```

## 2. Metric command (required)

One cheap, deterministic command that prints a single number.

```
metric_command: <e.g. node bench/rank.js --json | jq .p95_ms>
direction:      <lower-is-better | higher-is-better>
```

Confirm before running:
- [ ] Command runs and prints one number.
- [ ] It is cheap (seconds, not minutes).
- [ ] Run-to-run variance across 3 runs is smaller than the gain you are chasing.

## 3. Baseline and goal (optional)

```
current_baseline: <number, or "measure it">
target:           <number or %, or "report gains as %">
```

## 4. Caps (optional — defaults shown)

```
max_attempts:   10
max_wallclock:  1h
max_diff_lines: 1000
token_ceiling:  <set a number, or "log only">
```

## 5. Read-only set (do not edit — confirm you understand)

The loop may never touch these:
- `.quality-gates.json`, `gates/**`, `**/*.quality-gates.json` — **already enforced** by the four
  shipped `permissions.deny` rules and the Bash gate guard.
- The metric command, the benchmark, any test that defines "better" — **not enforced until you add
  a rule for it**. Phase 2 adds `Edit(path)` deny rules for these and proves they refuse an edit.
- Anything outside the named surface — **not enforced**; caught after the fact by the Phase 3
  check that `git diff --stat` stays confined to the surface.

- [ ] I understand an attempt that needs to touch these is an escalation, not a scope change.
- [ ] I have named the metric/benchmark files that Phase 2 must add deny rules for, or recorded
      that the metric is a shell one-liner with no file to protect (in which case the run is
      watched throughout).

## 6. Watched-first-run (required for a repo's first loop)

- [ ] This is the repo's first loop → a human watches end to end, nothing auto-merges.
- [ ] OR this repo has earned trust through prior watched runs (note them):

```
prior_watched_runs: <dates / log references, or "none — this is the first">
```

---

**Run with**: `/coord optimize <surface> "<metric_command>" [baseline-goal]`

See `field-manual/loop-discipline-guide.md` for the ratchet mechanics and the five-gate test.
