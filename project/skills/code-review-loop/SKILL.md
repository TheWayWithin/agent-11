---
name: code-review-loop
description: Run a scored, converge-or-cap code-review loop on a diff or surface — a read-only critic raises evidence-backed findings, a read-write fixer addresses only those findings, then re-audit until two clean rounds or a cap. Use when reviewing a PR, hardening a changed file, or iterating to a clean bill of health without reward-hacking.
version: 1.0.0
category: quality
triggers:
  - code review
  - review loop
  - review this pr
  - review the diff
  - harden
  - clean up findings
  - iterate to clean
  - critic loop
  - fix review comments
specialist: "@tester"
stack_aware: false
complexity: intermediate
estimated_tokens: 3200
dependencies: []
---

# Code Review Loop

## Capability

Run the canonical working loop from the loops/autoresearch research: a **read-only critic**
scores a diff and raises evidence-backed findings, a **read-write fixer** addresses ONLY those
findings, then the critic **re-audits**. Repeat until two consecutive clean rounds or a cap.
The separation is the whole point — the thing that judges the code cannot edit the code, so it
cannot pass the review by loosening it (the Sprint 6a read-only principle, applied to review).

## Use Cases

- Reviewing a pull request to a converged, clean state.
- Hardening one changed file or surface before merge.
- Turning a pile of review comments into addressed-and-re-verified findings.
- Any "iterate until clean" task where "clean" is a checkable signal, not a vibe.

## When NOT to use this skill

- **No checkable signal for "done".** If "good" is subjective taste with no test, gate, or
  rubric, a loop just burns tokens. Do a single review pass instead.
- **Green-field authoring.** This loop reviews and fixes an existing diff; it does not design
  features from scratch.
- **Structural rewrites.** The fixer addresses raised findings on a named surface. A loop will
  not invent an architecture change that needs a step backwards first.
- **Unbounded scope.** If every round surfaces a brand-new area, the surface is too big. Narrow
  it first.

## The two roles (never the same agent on the same turn)

| Role | Tools | Job |
|------|-------|-----|
| **Critic** | Read-only (Read, Grep, Bash for *running* checks — NO Edit/Write) | Score the diff, raise findings with file:line + evidence. Never edits code. |
| **Fixer** | Read-write (Edit/Write on the named surface only) | Address ONLY the raised findings. Never edits the gate, the test, or the critic's rubric. |

Deterministic-first: when a test suite or quality gate exists, **that is the critic's score**
(cheap, objective). Use an LLM critic with a numeric score (0-100 or findings-count) only when
no deterministic signal is available.

## The loop

```
CODE-REVIEW LOOP:
  baseline:
    - Identify the named surface (file/folder/diff). Everything else is off-limits.
    - Critic runs deterministic checks (gates/tests) if they exist; records the score.
  repeat (until 2 clean rounds OR cap):
    1. CRITIC (read-only): produce findings. Each finding = {file:line, severity, evidence,
       why-it-matters}. A claim with no evidence is dropped, not raised (default-fail).
       If findings == 0 → increment clean-round counter; else reset it to 0.
    2. If clean-round counter == 2 → STOP "converged".
    3. FIXER (read-write, surface only): address ONLY the raised findings. No opportunistic
       edits, no touching gates/tests/rubric. If a fix needs to leave the surface → escalate.
    4. Re-run deterministic checks. Append one JSONL line to .loops/review-<surface>.log.
    5. CAP CHECK: stop "capped" if rounds ≥ max (default 5) or diff ≥ 1000 lines or tokens ≥
       ceiling. Escalate on 3 consecutive rounds with the same unresolved finding.
```

**Log schema** (`.loops/review-<surface>.log`, append-only JSONL, one line per round):

```json
{"round": 2, "findings": 3, "resolved": 3, "score": 96, "diff_lines": 54, "tokens": 3100, "status": "fixing", "note": "null-check + 2 error-path tests"}
```

## Caps (library defaults — overridable)

| Cap | Default | Why |
|-----|---------|-----|
| Max rounds | 5 | Convergence is 2 clean rounds; 5 total bounds a thrashing loop. |
| Max diff / round | 1000 lines | Keeps each round reviewable and the fixer honest. |
| Token ceiling | Logged per run | Loops cost multiples of a single review; the human sees the meter. |
| Clean rounds to converge | 2 | One clean round can be luck; two is the signal. |

## Exit Criteria

Run each check and paste the output. "Looks reviewed" is not sufficient.

| # | Check | Verification | Pass condition |
|---|-------|-------------|----------------|
| 1 | Critic never edited code | `git log --author` / diff authorship on the surface | Only the fixer's commits touch code. |
| 2 | Findings are evidence-backed | Read the log's finding entries | Every raised finding cites file:line + evidence; none are bare assertions. |
| 3 | Fixer stayed on surface | `git diff --stat` | All changes confined to the named surface. |
| 4 | Gates/tests not edited | `git diff -- gates/ '**/*.quality-gates.json'` | Empty. The judge was never touched. |
| 5 | Converged or capped explicitly | Last log line | `status` is `converged` or `capped`, never an open loop. |
| 6 | Token cost recorded | `.loops/review-<surface>.log` | Final round logs cumulative tokens. |

If any check fails, do not declare done. Fix and re-run.

## Integration Points

- **mission-optimize**: same `.loops/` log discipline and read-only set; optimize ratchets a
  metric, this loop ratchets review findings to zero.
- **project/gates/**: the deterministic critic score comes from here when gates exist.
- **quality-gates-guide / loop-discipline-guide**: the read-only and default-fail contract this
  skill enforces.

## Anti-Patterns (Excuse / Rebuttal)

### Excuse: "Let the reviewing agent also fix what it finds — one pass, less overhead."

**Rebuttal**: The moment the judge can edit the code, it can pass the review by editing the
code instead of fixing it, or by quietly relaxing what it flags. Keeping critic read-only and
fixer read-write is the entire anti-reward-hacking mechanism. The extra turn is cheap; a review
that grades its own homework is worthless.

### Excuse: "The critic is sure there's a bug; raise it even without a specific line."

**Rebuttal**: A finding with no file:line and no evidence is a guess, and the fixer will either
chase a phantom or "fix" the wrong thing. Default-fail: an unevidenced finding is dropped, not
raised. If it is real, find the line.

### Excuse: "While we're in here, let's clean up that other file too."

**Rebuttal**: Opportunistic edits outside the named surface break the loop's bound, balloon the
diff, and make the re-audit meaningless. The fixer addresses raised findings on the surface and
nothing else. The other file is a separate loop.

### Excuse: "It's been five rounds and one finding won't die; just mark it done."

**Rebuttal**: That is the escalation case, not the done case. A finding that survives three
rounds means the fixer can't resolve it within the surface, or the finding is wrong. Escalate
to a human with the log; don't paper over it by redefining clean.

## References

- `project/field-manual/loop-discipline-guide.md` — the five-gate "loop or not" test and ratchet mechanics.
- `project/gates/README.md` — the read-only gate contract (Sprint 6a).
- Karpathy autoresearch / Claude agentic loops research cards — the source discipline.
