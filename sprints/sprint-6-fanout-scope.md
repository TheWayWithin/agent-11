# Where a workflow belongs: scope for the coordinator's first fan-out

**Written**: 2026-08-03
**Follows**: `sprints/sprint-6-workflows-decision.md`, and Jamie's 3 Aug decision **not** to rewrite
the coordinator as a workflow. The coordinator stays the orchestrator and gains the ability to *call*
a workflow for phases that are genuinely fan-out-shaped.
**Scope**: analysis and specification. No workflow is built here, and the coordinator's logic is not
changed.

---

## 1. The test

A phase or mission is fan-out-shaped only if **all three** hold. One failure is the answer; there is
no partial credit and no averaging.

**T1. Independent units.** The work divides into N pieces that do not need to see each other's
results. If handling unit B correctly depends on what unit A found, it is a sequence wearing a
fan-out's clothes.

**T2. Checkable per-unit verdict.** Each unit yields a result that can be judged right or wrong on
its own, against evidence, without reference to the other units. "Better", "cleaner" and "improved"
are not verdicts. `file:line + quoted evidence + severity` is.

**T3. No mid-run human judgement.** Nothing in it needs a decision only the operator can make while
it is running. A dynamic workflow cannot be steered once launched: only a permission prompt can pause
one, and there is no way to inject a correction. If the phase has a go/no-go in the middle, it fails.

Two further conditions do not decide the shape but constrain the build:

**C1. Isolation.** If the units mutate files, each needs its own git worktree
(`opts.isolation: 'worktree'`). Workflow subagents run with file edits auto-approved regardless of
session permission mode, so "read-only by prompt" is a behaviour, not a guarantee. Read-only fan-outs
skip this.

**C2. Worth the bill.** The measured cost of a 13-agent bounded fan-out in this repo was ~597k
subagent tokens and 5 minutes. Work that recurs per-commit cannot carry that. Work that recurs
per-release or on a schedule can.

**How to apply it.** Take the candidate, name the unit out loud ("one agent handles one ___"). If you
cannot finish that sentence with a noun that already exists somewhere enumerable, T1 has already
failed. Then ask what the unit returns and whether you could tell a wrong answer from a right one
without looking at the others. Then ask whether anyone has to decide anything halfway through.

---

## 2. Every candidate assessed

### The coordinator's phase-gated meta-loop

| Stage | Verdict | Fails | Why |
|-------|---------|-------|-----|
| Mission start, parse state from `project-plan.md` | **No** | T1 | One read producing one state object. There is no N. |
| Find next task, smart delegation routing | **No** | T1 | The loop finds the *next* incomplete task. Serial by construction. |
| Delegate, await, verify deliverables | **No** | T1 | One specialist per task, and the convergence counter resets on each, so rounds are causally chained. |
| **Phase gate verification** | **Yes** | none | Each acceptance criterion is a separate evidence check that passes only on real command output. Unit = one gate criterion. Read-only, so no C1. **But C2 fails**: this runs every cycle, and ~597k tokens per cycle is not affordable. Right shape, wrong cadence. |
| Update `project-plan.md` | **No** | T1 | Single-file mutation with ordering semantics. |
| `/coord complete phase N` context generation | **No** | T1 | `phase-(N+1)-context.yaml` summarises everything phase N did. Dependent by definition. |

**Reading**: the coordinator has exactly one fan-out-shaped stage and it is disqualified on cost, not
on shape. This is the concrete evidence for the decision not to convert the coordinator: there is
almost nothing in it to parallelise.

### The 18 library missions

| Mission | Verdict | Fails | Why |
|---------|---------|-------|-----|
| mission-architecture | No | T1 | Phase 3 validates the architecture Phase 2 designed. |
| mission-build | No | T1 | Seven phases chained strategy → architecture → design → implementation → QA. |
| mission-deploy | No | T1, T3 | Staging gates production, and deployment failure is a human go/no-go mid-run. |
| mission-document | No | T1, T2 | Phase 1's audit defines the structure Phases 2-5 write against, and doc quality has no per-unit right or wrong. |
| mission-fix | No | T1 | Root cause determines the fix. One causal chain is the whole mission. |
| mission-integrate | No | T1 | Auth setup gates core development; the wrapper wraps what was just built. |
| mission-migrate | No | T1, T3 | Mapping consumes the assessment, and production cutover needs a human execute decision. |
| mission-mvp | No | T1 | Eight phases, concept validation through deployment. |
| mission-optimize | No | T1 | Explicitly a ratchet: each round's baseline is the previous round's measured metric. This is the clearest failure in the set. |
| mission-product-description | No | T1 | Risk and financial analysis consumes the market analysis. |
| mission-refactor | No | T1 | Strategy from analysis, tests before refactor, validation after. |
| mission-release | No | T1, T3 | Build → docs → execute is chained, and shipping is a human call. (Its QA phase alone is fan-out-ish.) |
| **mission-security** | **Yes**, audit half only | none | Code, infrastructure and data-privacy audits are independent surfaces, each ending in severity-categorised findings. Unit = one audit surface, or one OWASP category. Read-only, no C1. **The remediation phase is not fan-out** and must stay outside any workflow. |
| operation-genesis | No | T1 | Nine chained phases, same shape as build. |
| **operation-recon** | **Yes**, Phases 1-2 only | none | Of the 8 RECON items, item 1 (PREPARATION) is setup that the rest depend on and produces no findings, so the fan-out is the **7** sweeps (interaction, responsive, visual, accessibility, robustness, code inspection, console) plus Phase 2's viewport/browser matrix. Those are mutually blind and each returns severity-tagged findings with screenshot evidence. Unit = one sweep dimension or one (viewport × browser) pair. Read-only, but needs separate browser contexts. **Phases 0, 3, 4 and 5 are not fan-out**: intelligence gathering precedes everything, and threat assessment, evidence collection and report compilation each synthesise what the earlier phases produced. |
| dev-setup | No | T1 | Each phase consumes the previous artefact: MCP → GitHub → ideation → architecture → plan. |
| dev-alignment | No | T3 | Its discovery path is a live interview with the operator. |
| connect-mcp | No | T3 | Writing `.mcp.json` needs real credentials from the human mid-run. (Its connection-testing step alone would pass.) |

**Reading**: 2 of 18 pass, and **neither passes whole**. Both are missions with a fan-out-shaped
audit or sweep phase bolted to sequential phases either side of it, which is worth stating as a
general finding rather than a footnote on two rows: the unit of conversion is a *phase*, never a
mission. Anyone reading this table as "these two missions could become workflows" has misread it.

That ratio is the point. A scope document that found fan-out everywhere would be telling you the
test does not discriminate.

### Jobs the coordinator could delegate that are not missions

| Candidate | Verdict | Why |
|-----------|---------|-----|
| **Fleet-wide audit** | **Yes** | `~/Shared/tools/agent-11-fleet/registry.yaml` carries **20 entries at `tier: active`**, each with an absolute `path`. One repo's audit never needs another's result. Unit = one repo. Read-only, so no C1. Per-release or scheduled cadence clears C2. |
| **Release-diff review** | **Yes, conditionally** | Unit = one changed file or named surface, each yielding `file:line` findings. T1 holds *only if* the surfaces partition cleanly; cross-file semantic breakage leaks between units and needs a separate whole-diff pass. The partition has to be invented per run, and a wrong split silently breaks T1. |
| `code-review-loop` skill | **No** | It *is* a loop. Round N+1's fixer addresses round N's critic findings, converging on two clean rounds. Dependent by design, which is the design working. |

---

## 3. Build this one first: the fleet-wide audit

**Why it beats the runner-up.** Release-diff review is higher value per run, but its unit boundary
has to be invented every time and a bad partition breaks T1 without saying so. The fleet audit's unit
boundary **already exists in a file**: 20 `tier: active` entries with absolute paths, stable between
runs, maintained for other reasons. The fan-out needs no partitioning judgement at all, which is
exactly the property that makes a first build small. It is also the job that currently costs the most
by hand: `fleet-sync.sh` plus manual per-repo inspection.

### Shape

**Units.** One agent per `tier: active` repo, read from `registry.yaml`. 20 units against a
16-concurrent runtime cap, so it runs in two waves. Well inside the medium size guideline if the
verify stage is bounded (below).

**What each unit checks.** Deployment drift, which is the question `fleet-sync.sh` answers slowly:
which AGENT-11 version the repo has, whether the four gate deny rules are present, whether
`gate-guard.sh` is installed and wired, whether the mission set is complete, and whether the
orientation protocol reached its agents. All answerable from files, all evidence-backed.

**Per-unit schema.** Structured output, so the script gets validated objects rather than prose:

```jsonc
{
  "repo": "string",                    // registry name
  "path": "string",                    // absolute path audited
  "reachable": true,                   // false if the path is missing; everything below then null
  "agent11_version": "string|null",    // from the deployed CLAUDE.md or install marker
  "gate_rules_present": ["string"],    // the Edit() rules actually found in .claude/settings.json
  "gate_rules_missing": ["string"],    // of the four expected
  "gate_guard_installed": true,        // .claude/hooks/gate-guard.sh exists AND is wired PreToolUse
  "missions_deployed": 0,              // count found under missions/
  "missions_expected": 18,
  "orientation_present": true,         // specialists carry ## ORIENTATION PROTOCOL
  "findings": [                        // at most 3, highest severity first
    {
      "severity": "high|medium|low",
      "claim": "string",
      "evidence": "string",            // file:line + verbatim quote. No quote, no finding.
      "remediation": "string"          // what a human would run; NOT run by the workflow
    }
  ],
  "total_found": 0,                    // honest count before the cap
  "dropped_note": "string"             // what the cap dropped, empty if nothing
}
```

**Stages and models.**

| Stage | Agents | Model | Job |
|-------|--------|-------|-----|
| Audit | 20 (one per active repo) | `haiku` or `sonnet` | Mechanical file inspection against the schema. Cheap by design: this stage reads and reports, it does not judge. |
| Verify | ≤1 per high-severity finding, capped at 10 | **`opus`** | Adversarially refute each high finding by re-reading the repo itself. Different model to the audit stage, non-negotiable. |
| Synthesise | 1 | `opus` | One ranked fleet report from surviving findings, plus the refuted list. |

Roughly 20 + 10 + 1 = 31 agents at the ceiling. That exceeds the medium guideline deliberately and
should be run with the guideline raised, or split into two runs of ten repos. Say which, out loud, in
the run: a silent cap reads as full coverage when it is not.

**Why the audit stage is the cheap model.** The measured pilot's finder stage produced 14 candidate
defects of which one survived. Fan-out output is noisy, and paying top-tier rates for noise is the
expensive mistake. Put the money in the verifier.

**Where the orientation rules go.** Into the agent prompts, pasted. Workflow subagents are not
agent-11 specialists and do not inherit `## ORIENTATION PROTOCOL`. The pilot's agents made 105 Bash
calls against 35 Reads, largely searching by shell, precisely because nobody told them not to.

### What it must not do

1. **No auto-merge, no auto-fix, no writes of any kind.** Every finding is a hypothesis. The audit
   reports; a human decides; remediation happens in a normal session afterwards. This is the whole
   reason the first fan-out is read-only: it removes C1 from the build entirely.
2. **The verify stage runs a different model to the finding stage.** A critic sharing the generator's
   weights inherits its blind spots and returns agreement rather than verification. This is the same
   rule now shipped in the `code-review-loop` skill and it is not optional here either.
3. **No finding without quoted evidence.** `file:line` plus a verbatim quote, or it does not get
   reported. A finding with no evidence is a guess.
4. **Declare every cap out loud.** Top-3 findings per repo, 10 verifications, two waves: whatever the
   run does, the report says so. A silent truncation reads as complete coverage.
5. **Read-only means read-only in the prompt AND in the shape.** Workflow subagents auto-approve file
   edits, so the guarantee has to come from not asking them to write anything. If a later version
   does write, it needs `opts.isolation: 'worktree'` per unit before anything else.
6. **Do not let it touch the vault.** `registry.yaml` is read. Nothing else under `~/shared` is
   opened.

### What "done" looks like

A saved project-scoped workflow at `.claude/workflows/` invoked as `/fleet-audit`, taking an optional
`args` list of repo names to narrow the run, returning one ranked report. The coordinator gains one
line saying that a fleet audit is delegated to `/fleet-audit` rather than walked by hand. That line is
the only coordinator change this document contemplates, and it is a routing entry, not a rewrite.

---

## 4. What this document deliberately does not do

It does not build the workflow. It does not change the coordinator. It does not recommend converting
any mission, because 16 of 18 fail the test and the two that pass are worth doing after the fleet
audit has proved the pattern, not before.

The honest limit: the test above is a judgement instrument, not a measurement. Two of its three
conditions (T1, T3) are answered by reading a file and thinking, and reasonable people could disagree
about `mission-release`'s QA phase or `connect-mcp`'s testing step, both of which are fan-out-shaped
in isolation but sit inside missions that are not. Where that ambiguity exists it is named in the
table rather than resolved silently.
