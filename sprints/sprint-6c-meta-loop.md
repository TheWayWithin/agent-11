# Sprint 6c: Coordinator Phase-Gated Meta-Loop — Outline Only

**Part of**: Sprint 6 — Loop Discipline & Read-Only Verification (umbrella → v6.2.0)
**Predecessor**: Sprint 6b — Ratchet loops
**Status**: OUTLINE ONLY. Detailed spec produced as the closing task of Sprint 6b, per the
Rolling Wave Protocol. Do not execute from this file.

---

## Intent

Formalise the loop the coordinator already half-runs (`coordinator.md` execution loop:
run gate → pass advances / fail stops) into a disciplined phase-gated meta-loop, using the
read-only gates (6a) and the ratchet primitives (6b) as building blocks.

Additions over today's behaviour:

- **Convergence conditions over fixed counts.** A phase passes on "two clean rounds", not an
  arbitrary number of attempts.
- **Error budget per phase.** A maximum number of cycles after which the coordinator
  escalates to the human instead of burning forward.
- **Condensed subagent returns.** Specialists return 1000–2000 token summaries to the
  coordinator, not full transcripts, keeping the orchestrator's context clean across a long
  build.
- **Externalised state as the recovery point.** `project-plan.md` is the durable state; a
  restart resumes from the last passed gate, not from scratch.
- **Watch for unanimous agreement** among any judges as a correlated-bias flag, not a quality
  signal.

## Possible stretch item carried from 6a

Hook-level (pre-tool-use) enforcement of read-only gate paths, if 6a's tool-permission
denials prove insufficient under adversarial testing.

## Metric justification

Improves restart/recovery success rate and human intervention rate on multi-phase missions.
Architectural enabler.
