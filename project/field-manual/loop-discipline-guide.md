# Loop Discipline Guide

When to run an agent in a loop, when not to, and how to do it safely. This is the field manual
behind `mission-optimize` (the ratchet) and the `code-review-loop` skill (the scored critic→
fixer→re-audit loop). Read it before your first loop on any repo.

## The one idea

A loop is worth running only when "better" is a **number you can trust** and "worse" **reverts
itself**. Everything else in this guide follows from that. A loop without a fixed, cheap signal
for "done" does not converge — it just spends tokens until a cap stops it.

## The five-gate "loop or not" test

Run a loop only if you can answer yes to all five. Any no → do a single pass instead, or build
the missing piece first.

1. **Fixed signal.** Is there one cheap, deterministic command that scores the work? (A test
   suite, a gate, a benchmark that prints one number.) If "good" is taste, there is no loop.
2. **Read-only judge.** Is the thing that scores the work uneditable by the thing doing it? If
   the agent can edit its own metric/gate/test, it will pass by editing it. (Sprint 6a.)
3. **Cheap iteration.** Does one attempt cost seconds-to-minutes, not hours? Loops multiply
   cost; an expensive signal makes a loop unaffordable.
4. **Bounded surface.** Is there ONE named file or folder the loop may change? Unbounded scope
   never converges.
5. **Revertable.** Can a worse attempt be hard-reverted with no side effects? Worktree
   isolation + git makes this true; live mutations to shared state do not.

## The ratchet (mission-optimize)

The safe shape for metric-driven optimisation:

1. **Isolate** — a git worktree, never the main checkout.
2. **Baseline** — median of 3 runs of the metric command. This is the noise floor; it stops a
   single lucky run ratcheting in.
3. **One change, named surface** — one hypothesis per attempt, confined to the named surface.
4. **Re-measure** — median of 3 again.
5. **Keep-or-revert** — keep only if it beats baseline by more than observed variance AND no
   gate/test regression; otherwise hard-revert.
6. **Log** — append one JSONL line per attempt to `.loops/`. Keep or revert, always log.
7. **Caps** — max attempts, wall-clock, diff size, token ceiling. Escalate on triggers.

## The scored review loop (code-review-loop skill)

The safe shape for "iterate to clean":

- **Critic** is read-only: scores the diff, raises evidence-backed findings (file:line +
  why), never edits code.
- **Fixer** is read-write on the surface only: addresses ONLY raised findings, never the gate.
- **Re-audit** until two consecutive clean rounds or a cap.

Deterministic-first: when a gate or test exists, that is the score. Reach for an LLM critic with
a numeric score only when no deterministic signal exists.

## The coordinator meta-loop (Sprint 6c)

The ratchet and the scored review loop are *inner* loops over one surface. The coordinator is the *outer* loop that runs a multi-phase mission, and it composes the inner loops under four disciplines:

- **Convergence over fixed counts.** A phase advances when a verify round finds no new failing criteria twice running, not after a set number of attempts. New work resets the counter; two clean rounds is the signal it is genuinely done.
- **Per-phase error budget.** A cap (default 3) on delegate→verify cycles per phase. When spent, the coordinator escalates to the human instead of burning forward. A too-small budget escalates noise; too-large burns tokens. Seed the number from a real harness-run loop's measured token cost, then tune.
- **Condensed returns.** Specialists hand back a 1000–2000 token structured summary (changed / evidence + where it lives / open issues / handoff delta), never a full transcript. Detail stays on disk so the orchestrator's context stays clean across a long build.
- **Externalised state is the recovery point.** `project-plan.md` is durable truth. A restart resumes from the last phase whose gate passed *on evidence*, never from scratch and never re-running a verified-complete phase. A `[x]` without attached evidence is re-verified before anything builds on it.

Plus the **unanimous-agreement flag**: when several judges or criteria all pass first-try with zero findings, treat it as a possible correlated-bias signal to surface to the human, not a quality bonus. Sometimes the work is just clean; the human decides.

The mechanics live in `coordinator.md` (the `/coord continue` execution loop and its "Phase-gated meta-loop" subsection).

## The watched-first-run rule

The first time any loop runs on a repo, a human watches it end to end: one repo, one worktree,
a capped number of experiments, **nothing merged automatically**, the human reads the `.loops/`
log as a list of hypotheses. Trust is earned per repo through watched runs. Never unattended on
a live repo before then. Every kept change is a hypothesis the human merges, not a fact the loop
asserts.

## Cost guardrails (non-negotiable)

- **Caps are mandatory**, not advisory: attempts, wall-clock, diff size, token ceiling. A loop
  with no cap is a runaway bill.
- **Log tokens per run.** The `.loops/` log records token cost so the meter is visible. On a
  watched run, Jamie sees it live.
- **Loops cost multiples of a single pass.** A 10-attempt ratchet is ~10× the cost of one
  edit. Only spend it where the measured gain justifies it.
- **Escalate, don't grind.** 3 consecutive failures on the same idea, a diff-cap breach, or any
  attempt to touch the read-only set → stop and ask a human. Burning forward is the expensive
  failure mode.

## Honest limits (from the research)

- **Goodhart's law.** The loop optimises the metric, not your intent. Median-of-3 plus
  human-merge review are the guards; they do not make overfitting impossible.
- **Greedy / local search.** Keep-if-better is hill-climbing. It tunes well; it will not find a
  structural win that needs a step down first. This is diligent iteration, not invention.
- **Correlated judges.** If several judges agree unanimously, treat it as a possible
  correlated-bias flag, not proof of quality.

## Where the pieces live

| Piece | Location |
|-------|----------|
| Ratchet mission | `project/missions/mission-optimize.md` |
| Scored review loop | `project/skills/code-review-loop/SKILL.md` |
| Input template | `templates/mission-optimize-input-template.md` |
| Read-only gate contract | `project/gates/README.md` (Sprint 6a) |
| Logs | `.loops/<loop-name>.log` (append-only JSONL) |
