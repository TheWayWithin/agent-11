# Sprint 6c: Coordinator Phase-Gated Meta-Loop — Detailed Spec

**Part of**: Sprint 6 — Loop Discipline & Read-Only Verification (umbrella → v6.2.0)
**Predecessor**: Sprint 6b — Ratchet loops ✅ (implemented 2026-06-19)
**Successor**: Sprint 6d — Consolidation & public comms (outline until 6c closes)
**Status**: ✅ COMPLETE 2026-06-20. T1–T6 implemented + verified. Gate-route test resolved by static analysis (Bash route found, hook built).
**Target release**: folds into **v6.2.0** with the rest of Sprint 6.

---

## Goal

Formalise the loop the coordinator already half-runs into a disciplined, phase-gated meta-loop
that sits on top of 6a's read-only gates and 6b's ratchet primitives. The coordinator becomes
the outer loop: it advances a phase only on evidence, runs each phase to convergence rather than
a fixed number of attempts, spends a bounded error budget before escalating to the human, keeps
its own context clean by taking condensed returns from specialists, and treats `project-plan.md`
as the durable recovery point so a restart resumes from the last passed gate.

## Why this sprint

6a made the judge read-only. 6b gave us bounded, logged, reverted-unless-better inner loops
(the ratchet, the scored review loop). 6c is the outer loop that orchestrates them safely across
a multi-phase mission. Without it, the coordinator still runs phases on prose convention —
"looks done, proceed" — which is the same reward-hacking surface 6a closed at the file level,
left open at the orchestration level. 6c closes it: a phase passes only on captured evidence,
loops only as long as its error budget allows, and survives a restart because state lives in
files, not in the coordinator's context window.

The 6b watched run (T5) produces the first real **token-cost-per-converged-loop** number. That
number is the input to 6c's error budgets — without it, per-phase cycle caps are guesses. So 6c
should be specced now but **executed after at least one 6b watched run has produced that number**.

## Design decisions (open questions from the outline, now resolved — review these)

1. **Where the meta-loop lives** → **`project/agents/specialists/coordinator.md`, extending the
   existing `/coord continue` execution loop** (the one 6a already made evidence-gated). Augment,
   don't replace. The phase gate stays; we add convergence, error budget, condensed returns, and
   restart-from-state around it.

2. **Convergence condition** → **two clean rounds OR error budget exhausted**, mirroring 6b. A
   "round" at the meta level = one full delegate→verify cycle for the phase's open work. Two
   consecutive rounds with no new failing criteria = phase converged.

3. **Error budget unit** → **cycles per phase**, defaulted from the 6b token-cost number, not an
   arbitrary integer. Default proposal: max 3 delegate→verify cycles per phase before mandatory
   human escalation. Overridable per mission. Burning the budget escalates; it never auto-advances.

4. **Condensed subagent returns** → specialists return a **1000–2000 token structured summary**
   (what changed, evidence captured, open issues, handoff delta) to the coordinator, not full
   transcripts. Full detail stays in handoff-notes.md / evidence-repository.md on disk. Keeps the
   orchestrator's context clean across a long build. This is a delegation-prompt convention plus a
   return-format the coordinator enforces.

5. **Restart / recovery point** → **`project-plan.md` is the durable state.** A restart reads the
   plan, finds the last phase whose gate passed on evidence, and resumes from the next phase — not
   from scratch, and never re-running a phase already marked `[x]` with a verified timestamp. The
   `.loops/` logs and evidence-repository.md are the supporting recovery artifacts.

6. **Unanimous-agreement flag** → when multiple judges/criteria all pass on the first try with no
   findings, the coordinator logs it as a **possible correlated-bias signal** to surface to the
   human, NOT as a quality bonus. Cheap to add, honest about the research caveat.

7. **Hook-level enforcement (the 6a stretch item)** → **decide in 6c, build only if needed.**
   First, adversarially test whether 6a's `permissions.deny` can be routed around (symlink, path
   normalisation, alternate write tool). If a route exists, add a pre-tool-use hook that blocks
   writes to the read-only set at the filesystem layer. If denials hold, document the test result
   and drop the hook. Default-fail: assume a route exists until the test proves otherwise.

## Scope (in)

- `project/agents/specialists/coordinator.md` — extend the `/coord continue` execution loop with:
  convergence-on-two-clean-rounds, per-phase error budget with human escalation, condensed-return
  enforcement in the delegation template, and explicit restart-from-last-passed-gate logic. Add
  the unanimous-agreement correlated-bias flag.
- `project/commands/coord.md` — document the meta-loop behaviour (error budget, convergence,
  restart) so users understand what `/coord continue` now does.
- `project/field-manual/` — extend `loop-discipline-guide.md` (or a short new section) with the
  meta-loop: how the outer loop composes the inner loops, error budgets, restart semantics.
- **Adversarial test of 6a denials** (the gate-route test) + hook-level enforcement ONLY if the
  test finds a route. If built: a pre-tool-use hook shipped via the library, registered in
  install.sh + SHA update.

## Scope (out — explicit)

- **README / website / public comms** — Sprint 6d consolidation.
- **Multi-coordinator / parallel-phase orchestration** — single coordinator, sequential phases.
- **Auto-merge / unattended multi-phase runs on live repos** — same rule as 6b: watched until
  trust is earned per repo.
- **Self-improving agent-11** (loops editing agent-11's own definitions/gates) — out, permanently.
- **agent-11's own `.claude/` working squad** — library only.

## Tasks

**All tasks ✅ DONE (2026-06-20):** T1 convergence + per-phase error budget wired into the `/coord continue` loop in `coordinator.md`; T2 condensed-returns requirement added to the context-preservation protocol; T3 restart-from-last-passed-gate added to session resumption; T4 gate-route test resolved by static analysis (the 6a deny rules cover Edit/Write/MultiEdit but NOT Bash → real route → built a blocking PreToolUse "read-only gate guard" hook in `settings.json.template`, no separate script so no install.sh/SHA churn); T5 unanimous-agreement flag + meta-loop section in `loop-discipline-guide.md` + `coord.md`; T6 this file's successor (Sprint 6d) promoted to a detailed spec.

### T1. Extend the coordinator execution loop with convergence + error budget
Augment `/coord continue` in `coordinator.md`: a phase loops delegate→verify until two clean
rounds (converged) or the per-phase cycle budget is spent (escalate to human). Evidence-gated
advance is retained from 6a. Default budget seeded from the 6b token-cost number.

### T2. Enforce condensed subagent returns
Update the delegation template so every Task delegation requests a 1000–2000 token structured
summary (changed / evidence / open issues / handoff delta); full detail to disk, not to the
coordinator's context. Coordinator rejects a return that dumps a full transcript.

### T3. Restart-from-last-passed-gate
Add explicit logic: on resume, read `project-plan.md`, find the last phase with an evidence-
verified `[x]` gate, resume from the next phase. Never re-run a verified-complete phase. Document
the recovery point in the session-resumption protocol.

### T4. Adversarial gate-route test + conditional hook
Test whether 6a's `permissions.deny` can be circumvented (symlink, `../` path, alternate tool).
If a route is found, build a pre-tool-use hook that blocks writes to the read-only set at the
filesystem layer; register it + update install.sh SHA256. If no route, document the negative
result and drop the hook. Default-fail until proven safe.

### T5. Correlated-bias flag + meta-loop field-manual section
Add the unanimous-agreement flag to the coordinator. Extend the loop-discipline guide with the
meta-loop: outer loop composing inner loops, error budgets, restart semantics.

### T6. Closing task — produce the detailed Sprint 6d spec and review with Jamie.

## Success metric

Improves **restart/recovery success rate** and **human-intervention rate** on multi-phase
missions (fewer phases re-run from scratch after an interruption; fewer "it advanced but the work
wasn't done" catches). Architectural enabler. Pre-condition: at least one 6b watched run has
produced the token-cost-per-loop number that seeds the error budget.

## Deliverables

- Coordinator execution loop with convergence, error budget, condensed returns, restart-from-state.
- `coord.md` documents the new behaviour.
- Loop-discipline guide extended with the meta-loop.
- Gate-route test result documented; hook shipped only if the test found a route.
- Sprint 6d detailed spec drafted and approved.

## Risks / honest caveats (carried from the research)

- **Externalised state can drift from reality.** If `project-plan.md` says `[x]` but the work
  regressed, restart resumes on a false premise. Mitigated by 6a's evidence-gating: a `[x]` must
  carry a verified timestamp + attached evidence, not an assertion.
- **Error budgets can mask a real block.** A phase that exhausts its budget escalates — that is
  the design — but a too-small budget escalates noise, a too-large one burns tokens. The 6b
  number seeds it; tune on watched runs.
- **Condensed returns can drop signal.** A 1000–2000 token summary that omits a real finding is a
  silent loss. The full detail stays on disk; the summary must name where to find it.
- **Unanimous agreement is a flag, not a fault.** Surface it; don't auto-fail on it. Sometimes the
  work is just clean.
