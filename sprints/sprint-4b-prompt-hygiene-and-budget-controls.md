# Sprint 4b: Prompt Hygiene & Budget Controls

**Part of**: Agent-11 v6.0 Evolution (Sprint 4 umbrella)
**Predecessor**: Sprint 4a — Baseline + Great Deletion
**Successor**: Sprint 4c — The Universal Router
**Status**: Outline only — detailed spec produced as the final task of Sprint 4a

---

## Goal (provisional)

Shift specialist and coordinator prompts from forced-immediacy ("NO WAITING / DELEGATE IMMEDIATELY") to Karpathy-aligned discipline (state assumptions, prefer minimal diffs, choose the lightest valid execution path). Add explicit budget controls so Opus 4.7's extended thinking doesn't run away.

## Scope Outline (to be refined in detailed spec)

- **Karpathy Constitution** drafted and placed in `.claude/CLAUDE.md` (final home confirmed in 4d).
- **PAUSE-AND-PLAN** replaces forced-immediacy language across coordinator and specialists.
- **3-phase prompt minimization pass**:
  1. Delete ASCII / emoji decoration (leftover from 4a if any).
  2. Collapse overlapping checklists.
  3. Relax forced-immediacy language — 4.7 reasons internally.
- **Budget controls** in mission frontmatter for `/coord build`, `/coord fix`, `/coord mvp`.
- **Fallback behaviour** if budget is hit: summarise to context.md, mark next step in project-plan.md, stop cleanly.

## Acceptance (provisional)

- Re-run a subset of harness tasks against 4b changes.
- At least one metric improves vs 4a baseline (likely: session-start tokens or unnecessary delegations).
- No regressions in task completion.

## First Task of This Sprint

**Produce detailed spec for this sprint** (this file, rewritten with full task breakdown).

## Final Task of This Sprint

Produce detailed spec for Sprint 4c.

## Open Questions

- Budget control mechanism: `/effort`, `MAX_THINKING_TOKENS`, or both?
- Does the Karpathy constitution live in `.claude/CLAUDE.md` from day 1 of this sprint, or wait for Sprint 4d when that file is shrunk?
- Do we apply minimization to all 11 specialists in this sprint, or just the coordinator + high-touch specialists (developer, tester) and defer the rest?
