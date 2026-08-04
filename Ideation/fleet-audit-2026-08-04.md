# Fleet audit — AGENT-11 deployment drift, 2026-08-04

**Produced by**: `/fleet-audit` (`.claude/workflows/fleet-audit.js`), the first fan-out built under
T-362. Read-only: no repo was modified, no remediation was run.
**Run**: 61 agents (1 discovery, 20 audit on sonnet, 39 verify on opus, 1 report), 2,401,672 subagent
tokens, 8m 44s, 576 tool calls, 0 errors.
**Status**: findings are **hypotheses awaiting a human decision**. Nothing here has been applied.

> **Read the run's own caveats first.** This run had two defects in the workflow script, both since
> fixed, and both affect how you should read the numbers below:
>
> 1. **It was invoked with a one-repo filter and audited all 20 anyway.** `args` arrived as a JSON
>    string rather than an array, the filter silently evaluated to "no narrowing requested", and the
>    run widened instead of narrowing. Nothing was written — the workflow is read-only by shape — but
>    a filter that fails open is the same class of defect as a silently truncated cap. Narrowing now
>    fails closed: an unparseable argument stops the run.
> 2. **It declared a 10-verification cap and then ran 39.** The cap was computed after the fact and
>    only logged, never applied. It is now enforced in the stage. So the coverage below is *wider*
>    than the stated cap, not narrower — but a cap that is announced and not applied is exactly the
>    defect this workflow's own rules forbid.
>
> **And a signal worth naming: 39 of 39 verifications confirmed, 0 refuted.** A 0% refutation rate is
> not a quality result. Here it is probably honest — most findings are "this file does not exist",
> which is trivially checkable — but unanimity is a correlated-bias signal, and the workflow now
> flags it rather than reporting it as a clean sweep.

---

## 1. The read-only quality gate does not exist anywhere in the fleet (19 of 19 reachable repos)

One root cause, one decision, not nineteen. Every reachable repo is missing all four shipped deny
rules from `.claude/settings.json` `permissions.deny`:

```
Edit(.quality-gates.json)
Edit(**/*.quality-gates.json)
Edit(gates/**)
Edit(.gates/**)
```

Every reachable repo is also missing `.claude/hooks/gate-guard.sh` and its PreToolUse Bash wiring; in
most, `.claude/hooks/` does not exist at all.

**Why it matters**: 16 of these repos have a live root-level `gates/` directory with `run-gates.py`
and `gate-types.yaml`. Agents working in them can rewrite the criteria that judge their own work, by
Edit or by Bash, with nothing refusing it. Both layers are absent, so the template's documented
fallback ("the Edit deny rules still hold") does not apply.

**This is not a broken framework.** The shipped settings in these repos date to 7-10 May 2026,
predating the Sprint 6a/6c gate work. A11-ISS-10 fixed the propagation mechanism on 2026-07-23; what
has not happened is the sweep that applies it. **That sweep is T-245, which this run was explicitly
told not to touch.** These findings are its evidence base, not its execution.

Affected: SEOAgent, aisearchmastery, freecalchub, BOS-AI, aimpactscanner-mvp, Trader-7,
llm-txt-mastery, aisearcharena, aimpactmonitor, PlebTest, ISOTracker, JamieWatters, modeloptix,
solomarket, evolve-7, agent-11-website, mastery-ai Framework.

## 2. Ten repos run with `defaultMode: bypassPermissions`

`.claude/settings.local.json` sets `"defaultMode": "bypassPermissions"`, usually alongside bare
`Bash`/`Edit`/`Write` allows. **This is the finding T-245's sweep will not fix**, because
`settings.local.json` is user-owned and `merge-settings.py` does not manage it. Restoring the deny
rules in item 1 will not achieve what you expect until this is reviewed.

SEOAgent, aisearchmastery, freecalchub, BOS-AI, aimpactscanner-mvp, llm-txt-mastery, JamieWatters,
solomarket, evolve-7, agent-11-website.

Worth noting that agent-11's own `validate-sprint6-closeout.sh` treats `bypassPermissions` as a gate
breach when it appears in the shipped template. Ten deployed repos set it locally.

## 3. Eleven repos allow-list broad JSON writes (corrected from three)

| Repo | Evidence |
|---|---|
| JamieWatters | `settings.json:23` `Edit(**/*.json)`, `:28` `Write(**/*.json)` |
| aisearchmastery | `settings.json:23` `Edit(**/*.json)` |
| solomarket | `settings.json:22-23` `Edit(*.json)`, `Edit(**/*.json)` |

**Two corrections, 2026-08-04 evening.**

**The count is wrong: it is 11, not 3.** That exact allow block (`Edit(*.json)`, `Edit(**/*.json)`,
`Edit(**/package.json)`, `Write(*.md)`, `Write(**/*.md)`, `Write(*.json)`, `Write(**/*.json)`,
`Write(**/package.json)`) is byte-identical in **every one of the 11 repos that has a
`settings.json` at all** — only agent-11 lacks one, because it gitignores it. The "3" was an artefact
of the top-3-findings-per-repo cap: eight repos had it dropped in favour of something rated higher.
Counted directly, not sampled.

**The severity is wrong too, in the other direction: this is not a bypass.** The auditing agent
called it "worse than a missing deny rule". It is not. Deny is evaluated before allow and specificity
never reorders it, so once item 1's rules land, `Edit(gates/**)` beats `Edit(**/*.json)` for a file
under `gates/`. Verified against the documentation, not reasoned: "Rules are evaluated in order:
deny, then ask, then allow." These grants are broad and worth narrowing on their own merits, but they
will not defeat a gate rule, and they are deliberately *not* flagged by
`scripts/validate-fleet-permissions.sh` — which fails only on grants that restrict nothing at all
(bare `Edit`, `Edit(**)`, `Edit(//**)`, `Edit(~/**)`).

## 4. Two registry entries have no AGENT-11 deployment at all

- **executor-file** — no `.claude/`, no `missions/`, no agents. Its own CLAUDE.md records why: it was
  the goal-first arm of the PRJ-15 A/B, won, and became the product repo. It was never a deployment
  target, but `registry.yaml:147` marks it `tier: active`.
- **executor-file-site** — same. The `.mirror/tree/CLAUDE.md` in its tree is a build-time mirror of
  the other repo, not a deployment.

Registry-vs-reality mismatch, not a regression. Binary decision: deploy, or reclassify the tier.
Until then they inflate every fleet metric. **`registry.yaml` lives in the vault and was not edited.**

## 5. Mission payload drift: 14 repos are short

Expected 20 files in `missions/` (18 executable missions plus `README.md` and `library.md`).

- **18 of 20** (13 repos): aisearchmastery, freecalchub, Trader-7, aisearcharena, aimpactmonitor,
  PlebTest, ISOTracker, JamieWatters, modeloptix, solomarket, evolve-7, agent-11-website,
  mastery-ai Framework. Where identified, the missing pair was consistently `connect-mcp.md` and
  `operation-recon.md` — the two A11-ISS-13 fixed in the library on 2026-08-03 but which have not
  been redeployed anywhere.
- **19 of 20**: llm-txt-mastery. **20 of 20**: SEOAgent, BOS-AI, aimpactscanner-mvp.
- **0 of 20**: executor-file, executor-file-site (item 4).

Completeness gap, not a control gap. Same root cause as items 1 and 6.

## 6. No agent anywhere carries the ORIENTATION PROTOCOL

`orientation_present: false` in all 19 reachable repos. Verified in detail on aimpactscanner-mvp: all
14 agent files lack it and still carry the predecessor heading `## OPERATING DISCIPLINE — READ FIRST,
VERIFY BEFORE RETURNING` in the same slot. The library source has it in 11 of 11 specialists.
Expected: the orientation work shipped 2026-08-03 and nothing has been redeployed since.

## 7. ASMGE — unreachable, state unknown

Not audited. **Unassessed, not passing.**

---

## What the caps cut

Per-repo audits reported only their top 3 findings. Gathered:

- Mission-count drift was the most commonly dropped finding (13 repos), deprioritised behind the gate
  findings. Reported in full in item 5, so nothing is lost.
- ISOTracker and mastery-ai Framework dropped the ORIENTATION finding to fit; both are in item 6.
- executor-file dropped "`.claude/agents/` does not exist" as a duplicate of item 4.
- aimpactscanner-mvp dropped two minor items: project-local `progress.md`/`project-plan.md` sitting
  inside `missions/`, and six stale timestamped backups under `.claude/backups/agent-11/` (expected
  upgrade-flow behaviour, just clutter).
- modeloptix collapsed 11 near-identical per-agent orientation findings into one.

## Suggested order of human attention

1. **Decide the registry status of executor-file and executor-file-site** (item 4). It changes what
   "fleet clean" even means, and it is a two-line edit.
2. **Review `bypassPermissions` in the ten repos** (item 2). This blunts any gate fix, and the sweep
   will not touch it.
3. **Then the fleet redeployment** (item 1), which sweeps up items 3, 5 and 6 with it. That is T-245,
   and it deserves its own run and its own care: it runs `install.sh --upgrade` across ~20 repos.
4. **Reach ASMGE and re-audit.**

---

## Addendum, 2026-08-04 evening: items 2 and 4 closed, and item 2's mechanism corrected

**A11-ISS-18 (item 2 above) is fixed in all twelve repos** — the audit said ten; an independent
count found twelve, because it missed `test-project` and `agent-11` itself. All twelve had
`permissions.defaultMode: bypassPermissions` plus blanket allows for bare `Bash`, `Edit` and `Write`
in `.claude/settings.local.json`. Now `acceptEdits`, with the blanket write grants removed and every
specific grant, `env` block and MCP allow preserved.

**The mechanism this document asserted was wrong, and the correction matters.** Item 2 said
`bypassPermissions` "defeats the deny rules". Checked against the official documentation:

- Deny rules apply in **every** mode. "These controls apply in every mode, including
  `bypassPermissions`: deny rules and explicit ask rules, which apply to every tool."
- A blanket `Edit` allow does **not** override `Edit(gates/**)`. Deny is evaluated before allow and
  specificity does not reorder it. Under `bypassPermissions`, allow rules have no effect at all.

So the deny rules were never being ignored. **What is actually true is worse.** `.claude` is a
*protected path*. Protected-path writes are **allowed without a prompt** under `bypassPermissions`
and **prompted** under `acceptEdits`. Under the old setting an agent could not edit a gate file
directly — the deny rule held — but it could rewrite `.claude/settings.json`, delete the deny rules,
and then edit the gate. Two steps, no prompt at either. That is the defeat, and `acceptEdits` closes
it by restoring the prompt on the first step.

**A11-ISS-19 (item 4) is fixed**: `executor-file` and `executor-file-site` moved from `tier: active`
to `tier: skip`, with notes recording that agent-11 is not installed and that deploying it is an open
product decision. Neither repo was touched.

**What this does NOT mean.** Passing `validate-fleet-permissions.sh` does not mean the gates are
enforced anywhere. It means nothing is neutralising them. **The four deny rules are still absent from
every reachable repo except `digital-estate` (archived)** — item 1 above is untouched and remains
T-245's work. The fix removes the thing that would have made that sweep pointless; it is not the
sweep.
