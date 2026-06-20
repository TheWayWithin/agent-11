# Sprint 6b: Ratchet Loops — Detailed Spec

**Part of**: Sprint 6 — Loop Discipline & Read-Only Verification (umbrella → v6.2.0)
**Predecessor**: Sprint 6a — Read-only gates ✅ (implemented + live-demoed 2026-06-16)
**Successor**: Sprint 6c — Coordinator phase-gated meta-loop
**Status**: ✅ COMPLETE 2026-06-20. T1–T4, T6 implemented + verified; T5 watched run executed on aimpactmonitor (loop proven, two findings folded back into mission-optimize).
**Target release**: folds into **v6.2.0** with the rest of Sprint 6.

---

## Goal

Give agent-11 the loop capability the research describes, on the read-only-gate foundation
6a established. Two deliverables:

1. **`mission-optimize` rewritten as the Karpathy ratchet** — autonomous, metric-driven,
   keep-or-revert-in-a-worktree, fully logged, hard-capped.
2. **A scored code-review loop skill** — the canonical working loop (read-only critic →
   read-write fixer → re-audit until converged or capped).

Both depend on 6a: the metric/gate/critic that judges the work is read-only to the agent
doing it. 6b is what 6a was built to make safe.

## Why this sprint

From the research (`knowledge/Karpathy autoresearch.md`, `knowledge/Claude agentic loops.md`):
a loop only earns its keep with a fixed, cheap signal for "done", and it is only safe when
the judge is read-only and every attempt is reverted-unless-better in an isolated worktree
with a logged trail. 6a gave us the read-only judge. 6b gives us the ratchet and the
canonical scored-review loop that sit on top of it. Without 6b, 6a is a safety rail with
nothing yet running behind it.

## Design decisions (open questions from the outline, now resolved — review these)

1. **Rewrite vs augment `mission-optimize`** → **Augment, don't gut. ✅ CONFIRMED by Jamie
   2026-06-16.** Keep a lightweight analysis front-end (identify ONE target + ONE cheap
   measurable metric), then replace the current vague phases 3–6 with the disciplined ratchet
   loop as the execution core. The profiling/strategy value of the current mission is retained
   as "decide what to optimise"; the ratchet is "iterate on it safely."

2. **Critic type for the code-review loop** → **Deterministic-first, LLM-fallback.** Prefer
   the existing quality gates / test suite as the score when they exist (cheap, objective).
   Use an LLM critic with a numeric score only when no deterministic signal is available.
   Critic is read-only (no Edit/Write tools), reusing the 6a separation.

3. **Convergence** → **Two clean rounds OR cap**, not a fixed count. Stops when the work is
   actually done, with a turn cap as the circuit breaker.

4. **Log location + schema** → `.loops/<loop-name>.log`, append-only JSONL, one line per
   attempt: `{commit, metric, median_of_3, baseline, status: keep|revert|crash, diff_lines,
   tokens, desc}`. The log is the research memory; the agent reads it to avoid re-running
   dead ends, the human reads it to audit.

5. **Caps (library defaults, all overridable)** → max attempts 10, max wall-clock 1h, max
   diff 1000 lines per iteration, token ceiling logged per run, escalate after 3 consecutive
   failures or any attempt that would require touching a read-only gate.

6. **Editable surface** → named explicitly as a mission input (one file or folder). Enforced
   by worktree isolation + the diff-size cap + the 6a read-only set (gates/tests/metric
   unreachable). Scope-creep beyond the named surface is an escalation trigger, not a silent
   widening.

## Scope (in)

- `project/missions/mission-optimize.md` — rewrite execution core as the ratchet (worktree →
  baseline median-of-3 → one change on named surface → re-measure median-of-3 → keep if it
  beats baseline past a noise-floor threshold with no regressions, else hard-revert → append
  to log → repeat within caps → escalate on triggers). Every kept change framed as a
  hypothesis the human merges, never auto-merged.
- `project/skills/code-review-loop/SKILL.md` — new deployable skill: scored critic→fixer→
  re-audit loop, evidence-gated, diff <1000 lines, converge-or-cap, tokens logged.
- `project/deployment/scripts/install.sh` — register the new skill in the install list, and
  **update `install.sh.sha256`** (CI guard blocks otherwise).
- `project/field-manual/` — a short "loop discipline" guide (ratchet mechanics, when to loop
  vs not, the five-gate decision test, cost guardrails). Could extend `quality-gates-guide.md`
  or be its own page.
- `templates/` — a `mission-optimize` input template naming target / metric / surface / caps.

## Scope (out — explicit)

- **Coordinator convergence/error-budget formalisation** — Sprint 6c.
- **README / website / public comms** — Sprint 6d consolidation.
- **Multi-agent / parallel optimisation** — single-surface, single-loop only for 6b. Breadth
  comes later if earned.
- **Auto-merge of any kind.** The human is the judge at merge time. Non-negotiable for 6b.
- **Self-improving agent-11** (loops editing agent-11's own definitions/gates). The whole
  research verdict is "adopt the discipline, avoid the autonomy." Out, permanently.

## Tasks

### T1. Rewrite `mission-optimize.md` execution core as the ratchet — ✅ DONE (2026-06-19)
Augment-not-gut per decision 1. Front-end (Phases 1–2) picks target + metric; execution core
(Phase 3) runs the ratchet with worktree isolation, median-of-3 noise floor, keep-or-revert,
JSONL log, caps table, escalation triggers; Phase 4 is human-merge of kept hypotheses. Read-only
set + watched-first-run rule embedded. 33 ratchet markers verified in file.

### T2. Build the `code-review-loop` skill — ✅ DONE (2026-06-19)
`project/skills/code-review-loop/SKILL.md` created (7.5KB). Read-only critic (deterministic-
first) → read-write fixer (surface only) → re-audit → converge on two clean rounds or cap.
Two-roles table, log schema, caps, exit-criteria table, anti-patterns. Frontmatter matches the
skill schema (name, triggers, specialist, etc.).

### T3. Register the skill in install.sh + update SHA256 — ✅ DONE (2026-06-19)
Added `code-review-loop` to `skill_dirs`; regenerated `install.sh.sha256`
(`af254f94…`); `bash -n` syntax OK; checksum MATCH verified.

### T4. Loop-discipline field-manual guide + input template — ✅ DONE (2026-06-19)
`project/field-manual/loop-discipline-guide.md` (five-gate test, ratchet + scored-loop
mechanics, watched-first-run, cost guardrails, honest limits) and
`templates/mission-optimize-input-template.md`. Both registered in install.sh enumerated arrays
(field_manual_files, template_files) so they deploy in remote mode; SHA re-regenerated after.

### T5. Closing task 1 — watched validation run — ✅ DONE (2026-06-20)
Executed on **aimpactmonitor** (not AISearchArena — its benchmark was broken; see the journey in
progress.md). Metric: JS bundle size from `next build` + `du`. Baseline 2176 kB; one attempt
(lazy-load recharts on the dashboard via `dynamic()`) passed the build gate and kept at 2168 kB.
Loop mechanics proven end-to-end, watched, nothing auto-merged. **Two field findings folded back
into `mission-optimize.md`**: (1) the metric must measure the intent, not a proxy — total-disk-JS
undersold a lazy-load that genuinely improves First Load JS (Goodhart, live); (2) a separate-dir
worktree breaks on JS/Turbopack (symlinked `node_modules` rejected) — use npm-install-in-worktree,
hardlinks, or a disposable branch in place. No clean token-per-loop number (manual run); 6c should
seed its error budget from a harness-run loop. Kept change lives on aimpactmonitor `develop`.

### T6. Closing task 2 — produce the detailed Sprint 6c spec and review with Jamie — ✅ DONE (2026-06-19)
`sprints/sprint-6c-meta-loop.md` promoted from outline to detailed spec (7 resolved design
decisions, T1–T6, scope in/out, risks). Notes 6c execution is gated on the T5 watched-run number.

## Success metric

Improves task-completion time and human-intervention rate on iterative work (optimise,
review). New capability — also justifiable as enabler. The watched run (T5) produces the
first real token-cost-per-converged-loop number for agent-11, which feeds 6c.

## Deliverables

- `mission-optimize.md` ratchet rewrite (worktree, noise floor, keep-or-revert, log, caps).
- `project/skills/code-review-loop/SKILL.md` + install.sh registration + SHA update.
- Loop-discipline guide + input template.
- Evidence from the watched validation run: the `.loops/` log + a human read of it.
- Sprint 6c detailed spec drafted and approved.

## Risks / honest caveats (carried from the research)

- **Overfitting / Goodhart.** The ratchet optimises the metric, not the intent. Every kept
  change is a hypothesis, reviewed at merge. The noise-floor median-of-3 stops lucky seeds
  ratcheting in.
- **Greedy/local search.** Keep-if-better is hill-climbing; it won't find structural wins
  that need a step down first. Set expectations: this is diligent tuning, not invention.
- **Cost.** Loops cost multiples of a single pass. Caps + token logging are non-negotiable;
  on a watched run Jamie sees the meter.
- **Never unattended on live repos** until the watched runs have earned trust, repo by repo.
