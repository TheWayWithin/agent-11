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

## 3. Three repos allow-list the edits the gate is meant to deny

| Repo | Evidence |
|---|---|
| JamieWatters | `settings.json:23` `Edit(**/*.json)`, `:28` `Write(**/*.json)` |
| aisearchmastery | `settings.json:23` `Edit(**/*.json)` |
| solomarket | `settings.json:22-23` `Edit(*.json)`, `Edit(**/*.json)` |

**Read this one carefully rather than at face value.** The auditing agent called it "worse than a
missing deny rule". That is true only while the deny rules are absent, which they currently are. In
Claude Code deny takes precedence over allow, so once item 1's rules land these globs should be
overridden rather than winning. Verify that precedence on one repo before assuming the sweep fixes
it — the claim that it does is reasoning, not something this audit tested.

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
