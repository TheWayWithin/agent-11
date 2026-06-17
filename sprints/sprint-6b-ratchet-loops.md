# Sprint 6b: Ratchet Loops — Outline Only

**Part of**: Sprint 6 — Loop Discipline & Read-Only Verification (umbrella → v6.2.0)
**Predecessor**: Sprint 6a — Read-only gates
**Status**: OUTLINE ONLY. Detailed spec produced as the closing task of Sprint 6a, per the
Rolling Wave Protocol. Do not execute from this file.

---

## Intent

Give agent-11 the actual loop capability the research describes, built on the read-only
gate foundation from 6a. Two deliverables:

1. **Rewrite `mission-optimize.md` as the Karpathy ratchet.** Replace the current 6-phase
   human-paced mission with: isolated `git worktree` → record baseline (run check 3x, take
   median = noise floor) → one change on a named editable surface → re-run check 3x →
   keep-if-better-else-hard-revert → append every attempt to a log → repeat within hard
   turn/time/diff caps → escalate on scope-creep. Every kept change treated as a hypothesis,
   merged only by the human.

2. **Add a scored code-review loop skill.** The canonical working loop: read-only critic
   scores the diff and lists evidence-gated issues → read-write fixer addresses only those
   issues → critic re-audits → repeat until score clears threshold or N-turn cap. Diff kept
   under ~1000 lines. Tokens logged per run.

## Safety frame (from the autoresearch note)

First run is **watched, on one repo, ten experiments, nothing merged automatically**.
AISearchArena is the candidate (it already has a frozen benchmark the agent can't touch).
The autonomy slider starts near the bottom and only moves up when the log earns trust.

## Open questions to resolve in the detailed spec

- Where the per-attempt log lives and its schema (commit hash, metric, status, one-line desc).
- How the editable surface is named and enforced (mission input vs frontmatter).
- Whether the scored critic is deterministic (test suite) or an LLM judge, and the threshold.
- Cost ceiling and turn/time caps per loop.

## Metric justification

Improves task completion time and human intervention rate on iterative work (optimise,
review). New capability — also justifiable as enabler.
