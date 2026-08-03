# Sprint 6 close-out: dynamic workflows decision memo

**Written**: 2026-08-03
**Scope**: closes the "Sharper Ways of Working" initiative (PRJ-5) in the agent-11 repo
**Decides**: nothing about the coordinator. Task 6 is a recommendation only; that call is Jamie's, and
nothing in the coordinator's logic was changed by this close-out.
**Evidence**: one measured dynamic-workflow pilot, run in this repo on 2026-08-03. Raw run in
`~/.claude/projects/<session>/subagents/workflows/wf_d9ffb63e-a20/`: `journal.jsonl` carries one result
per agent, the `agent-*.jsonl` transcripts carry per-agent token usage and tool calls, and the token
and wall-clock totals are in the sibling `workflows/wf_d9ffb63e-a20.json`.

---

## The answer first

**Dynamic workflows do not supersede tasks 3, 4 or 6.** The hypothesis that they might was reasonable
in principle and does not survive contact with the mechanisms, for three reasons. None of the three came
from the pilot, and saying otherwise would be the exact fault this memo goes on to find in
`mission-optimize.md`. What the pilot did was price the option and test whether Sprint 6's prose
mechanisms hold; the section "What this evidence cannot support" below draws the line explicitly.

1. **All three tasks are sequential loops, not fan-outs.** A workflow buys parallel breadth across
   independent units. A critic/fixer loop, a ratchet, and a coordinator advancing through phase gates
   have no independent units to spread. This is analytic, not measured: it follows from reading the
   three mechanisms, and it would be true whatever the pilot had returned.
2. **A workflow script has no way to make an agent read-only.** Sprint 6's entire premise is that the
   thing which judges the work is read-only to the thing doing it. The `agent()` API offers no tool
   restriction: a script can only *tell* an agent not to edit. And the current documentation is
   explicit that "the subagents the workflow spawns always run in `acceptEdits` mode and inherit your
   tool allowlist, regardless of your session's mode. File edits are auto-approved."

   Be precise about what that does and does not mean, because it is easy to overstate. The same page
   also says a workflow's "agents' tool calls receive the same permission checks and sandboxing as any
   other tool call in the session", so the four `permissions.deny` rules and the `gate-guard.sh` hook
   **do** still apply inside a workflow: the gate files stay protected. What is lost is the
   interactive approval step, and with it any way to hold a critic to "edit nothing at all this
   round" without pre-declaring every path it must not touch. That property is exactly what a
   read-only critic needs and exactly what a script cannot express.

   So a workflow does not strengthen the read-only judge, and on the one dimension that matters for a
   critic it weakens it. This claim comes from the documentation, not from the pilot, and is flagged
   as such.
3. **A workflow has no mid-run steering.** Only a permission prompt can pause one; there is no way to
   inject a correction into a running script. This matters least for task 3, where the loop is short,
   and most for task 6, where the coordinator is the layer Jamie actually interrupts. Documented, and
   the most consistent independent criticism of the feature in the wild.

**And a correction to the premise.** The initiative was being carried as five open tasks. Verified on
disk on 2026-08-03: tasks 3 and 4 shipped in commit `c6c6f62` on **2026-06-19** and were closed out on
2026-06-20 (`edf4a9f`, the watched-run findings); task 6 shipped in Sprint 6c. All were released as
v6.2.0 (tag `v6.2.0-loop-discipline`). What was stale was the record, not the work. The vault's
`02-PROJECTS.md → PRJ-5` table still says "6b/6c/6d outline only"; the repo shows all three shipped,
tagged and deployed. The re-scope-or-kill question that has been hanging over PRJ-5 since July rested
on that stale table.

So the honest framing of this memo is not "rewrite or drop", it is: **given that these mechanisms
already shipped as prose, does converting any of them to deterministic workflow code earn its bill?**
The answer is no, and the pilot's role in reaching it is bounded: it priced a fan-out and stress-tested
the prose, it did not and could not falsify the structural case. One exception survives, and it is a
bug fix rather than a rewrite.

---

## The pilot: what it was

One workflow, run against real agent-11 work: an adversarial review of the Sprint 6 loop-discipline
surface across four independent dimensions, with every finding then attacked by a verifier running a
**different model** to the reviewer that produced it.

| Stage | Agents | Model | Job |
|-------|--------|-------|-----|
| Find | 4 | sonnet | one per dimension: gate mechanism, ratchet, code-review loop, coordinator meta-loop. Read-only. Every finding must quote file, line and verbatim text. |
| Verify | 8 | **opus** | one per returned finding. Prompted to *refute*, defaulting to refuted unless the file text forces otherwise. Re-reads the files itself. |
| Synthesise | 1 | opus | reconciles survivors and refutations into prose. |

The cross-model requirement is not decoration. The research note this initiative came from
(`~/shared/knowledge/Dynamic workflows.md`) carries the
correction explicitly: its own "6/6 adversarial verifications confirmed" was six verifiers sharing one
model and one source set, which is a consistency check, not verification. A critic sharing the
generator's weights returns agreement. This pilot's verify stage was therefore routed to a different
model via `opts.model`, and the result below is the first number this repo has on what that changes.

Every agent in the run was instructed read-only, and the transcripts confirm none of them called a
write tool: 105 Bash, 35 Read, 12 StructuredOutput, zero Edit/Write/MultiEdit/NotebookEdit across all
13 agents. Nothing found by the pilot has been applied; every finding is a hypothesis, logged as an
issue, not merged.

**One thing the design got wrong, worth recording.** Those 105 Bash calls against 35 Reads mean the
reviewers largely searched via shell rather than via Glob and Grep. The orientation block this same
close-out shipped tells agents to Glob/Grep to locate before they Read. Workflow subagents do not
inherit that block, because they are not agent-11 specialists. Any saved agent-11 workflow should
paste the orientation rules into its agent prompts, exactly as this one pasted its read-only
constraint.

---

## The pilot: what it cost

| Measure | Value |
|---------|-------|
| Agents spawned | **13** (4 find, 8 verify, 1 synthesise). 0 errored, 0 skipped, 0 empty. |
| Subagent tokens (harness figure) | **596,827** (the runtime's own `totalTokens`) |
| Raw transcript tokens | 62,802 output; 1,284,607 cache-creation input; 9,013,024 cache-read input; 504 uncached input |
| Wall-clock | **5 min 00 s** (300,149 ms) |
| Tool calls | 152 |
| Findings raised | **14** (3 gates, 4 ratchet, 4 review-loop, 3 meta-loop) |
| Findings verified | **8** (top 2 per dimension; the cap is mine, see below) |
| Findings surviving verification | **1** |
| Findings refuted | **7** (87.5% of those verified) |
| Cost per surviving finding | **~597k subagent tokens, 13 agents, 5 minutes** |

**The cap, stated rather than hidden.** Each reviewer was told to return at most its two
highest-severity findings while reporting `total_found` honestly and naming what it dropped. That
denominator is therefore self-reported by the same capped agent, not independently counted, and it
should be read as "fourteen things four reviewers were willing to call defects", not as a census. Six
findings were raised but never verified. Their substance is recorded in the run journal;
the most interesting are that `git checkout -- <surface>` does not remove newly-created untracked
files so a "reverted" attempt can leave residue in the next baseline, and that the convergence and cap
checks in both the ratchet and the review loop are narrated self-monitoring with no counter external
to the agent. Neither has been verified by a second model and neither should be treated as established.

**A warning about the token figure.** The runtime's headline 596,827 reconciles with neither the raw
sum of every usage object (10,360,937 including cache reads) nor the non-cache-read sum (1,347,913).
Its exact definition is not documented anywhere I could find, so treat it as the runtime's own
accounting unit, useful for comparing runs on the same surface and not safe to compare against
figures produced by a different tool. Both numbers are printed above so nothing is hidden behind the
convenient one.

**Comparison anchors**, for scale only, from the research note (`~/shared/knowledge/Dynamic workflows.md`, a vault file, so a reader inside this repo cannot check them): a published 5-agent head-to-head ran
6m59s on ~109k subagent tokens; the note's own 9-agent research run took ~14 minutes and ~366k tokens.
Neither states its accounting method, so the comparison is indicative and nothing in this memo turns
on it. This pilot sits above both on tokens for a shorter wall-clock, which is what 8 concurrent opus
verifiers re-reading source files buys.

---

## The pilot: what it found

**A note on line numbers before the finding itself.** The orientation change landed before the pilot
ran, so every line number the pilot cites is offset by the 11 lines that block adds. The surviving
finding cites `mission-optimize.md:70`, which is correct against the working tree; the same line is
`:59` at HEAD. Anyone checking these citations against git history should expect that shift.

**One finding survived.** `project/missions/mission-optimize.md:70` tells the operator that the
mission's read-only set is "enforced by `permissions.deny` in `.claude/settings.json`". The read-only
set it sits under has three items: the gate config, the metric command or benchmark that defines
"better", and any file outside the named editable surface. Only the first is enforced. The only deny
rules agent-11 ever writes are the four static ones in `library/settings.json.template`
(`Edit(.quality-gates.json)`, `Edit(**/*.quality-gates.json)`, `Edit(gates/**)`, `Edit(.gates/**)`).
The metric command and the editable surface are chosen fresh at Phase 1 of every run and no step in
Phases 1 or 2 writes or verifies a rule covering them. The same overclaim is propagated to the user in
`templates/mission-optimize-input-template.md:48` and widened further in
`project/field-manual/quality-gates-guide.md:14`.

The verifier tried three ways to refute it and could not, but downgraded it from high to medium on
compensating controls it found that the reviewer had missed: the Phase 3 criterion that `git diff
--stat` stays confined to the named surface, the mandated watched first run per repo, and human review
of every kept change before merge. So the defect is a **false enforcement claim in shipped
documentation**, not an unguarded loop. That distinction matters and the verifier is the reason the
memo can make it.

**Seven were refuted, and the pattern in the refutations is the more useful result.** Five of the
seven restated a documented, deliberate design decision as a defect, and in each case the verifier
could quote the document saying so: `gate-guard.sh` covers four Bash write verbs by its own stated
contract, narrowed for cause after A11-ISS-4 blocked legitimate commands; root-anchored `gates/**` is
specified in the sprint file; the coordinator having no Bash access is the stated pure-delegation
model. The secondary pattern is thinner reviewers: several findings died because the sonnet reviewer
had not read one adjacent file that supplied the missing control.

**The refutation rate, and why it will not carry as much weight as it first appears to.** Seven of the
eight verified findings were refuted: 87.5%. The one published figure in the research note
(`~/shared/knowledge/Dynamic workflows.md`, tagged there as T2 / single-source) for a
same-model adversarial pass is 26 findings cut to 16, about 38%. The tempting reading is that
cross-model verification is more than twice as ruthless as same-model verification. That reading does
not survive scrutiny, and four things sit against it:

- **The verifiers were told to refute.** The script instructs each one: "Your job is to REFUTE it, not
  to agree with it. Default to refuted=true unless the file text forces the opposite conclusion." A
  strong prior towards refutation is the most parsimonious explanation of a high kill rate, and the
  38% comparator carried no such prior. Attributing the difference to the model split would be
  attributing to the design what the prompt already caused.
- **The confound of strength.** The verify model was also the stronger model, so some unknown share is
  capability rather than independence.
- **The sample is eight.** 7/8 has a 95% confidence interval running roughly 47% to 99%. It does not
  reliably distinguish itself from 38%.
- **The instrument was primed.** Each of the four reviewers was handed a pre-written "claim under
  test" naming a specific mechanism I already had opinions about, and told to hunt for defects in it.
  That is a directed search for evidence against four suspected claims, not an open sweep, and a
  directed search will produce a high false-positive rate whether or not fan-out is any good at
  finding novel defects. This is the sharpest objection to the number and it applies to the "mostly
  noise" reading below just as much as to the 87.5%.

What survives all four objections is narrower but still useful, and it is a statement about this
repo rather than about verification in general: **of the eight findings that were actually put to a
verifier, one was real.** Fourteen were raised; six were never verified because of my own cap, so the
denominator that can be defended is eight, not fourteen. Whether the filter that established that was the model
split, the refute-first prompt or both, the filter earned its place. A run of these four reviewers
with no verify stage would have handed over eight findings, seven of them wrong, against shipped
mechanisms Jamie would then have spent a morning "fixing".

**One inference to avoid, because the first draft of this memo made it.** It is tempting to say the
value came from verification and not from fan-out. That is a category error. Verification produced
zero findings; it filtered what the fan-out produced, and it had nothing else to work on. The honest
statement is that the fan-out's raw output had a poor signal-to-noise ratio and the verify stage is
what made it usable. Both stages were necessary. What the numbers do bear on is the *price*: one real
finding for 13 agents, ~597k subagent tokens and five minutes.

---

## What this evidence cannot support

Stated before the decisions, not after, because a memo that buries its limits under its conclusions is
doing the thing this initiative exists to prevent.

- **n=1.** One workflow, one task shape, one repo, one afternoon. Nothing here generalises to a claim
  about dynamic workflows as a feature. It is a claim about this repo's four Sprint 6 mechanisms.
- **The 87.5% kill rate has a confound.** The verify model was both *different from* and *stronger
  than* the find model. Some unknown share of the kill rate is capability, not cross-model
  independence. A clean test would route find and verify to two models of comparable strength.
- **Six of fourteen findings were never verified**, because of my own top-2-per-dimension cap. If the
  dropped six had a higher survival rate than the verified eight, the survivor count is an
  underestimate and the "one real finding" headline is too harsh on the fan-out.
- **The comparison figures cannot be checked from inside this repo.** The 38% same-model refutation
  rate, the 109k/6m59s and 366k/14min scale anchors, and the acceptEdits behaviour all come from
  `~/shared/knowledge/Dynamic workflows.md`, a vault file, or from Anthropic's workflow documentation.
  A reader with only this repo cannot verify any of them. That is the same category of defect as the
  one this pilot found in `mission-optimize.md`, and it is named here rather than left for someone
  else to notice. Nothing in the headline verdicts turns on those figures; the two secondary
  recommendation about giving the coordinator a workflow to call leans on the token figure rather than
  on the 38%, and the recommendation to split critic and fixer across models is deliberately grounded
  in the documented principle instead. Nothing in this memo now rests on the 38%.
- **The pilot did not test the workflow substrate.** Everything the run did (parallel read-only
  reviewers, per-finding verifiers on a different model, a synthesiser) could have been done with
  the `Task` tool the coordinator already has. What was measured is the cost and yield of thirteen
  subagents doing an audit. Whether a *workflow* specifically adds anything over thirteen Task calls
  is untested here, and the memo's recommendations do not claim otherwise.
- **The recommendations do not rest on the measurement alone.** Three load-bearing facts come from
  elsewhere and are flagged where they appear: that workflow subagents run acceptEdits with edits
  auto-approved (documentation), that interdependent coding is a documented poor fit
  (documentation plus independent practitioner reports), and that these three mechanisms are
  sequential rather than fan-out-shaped (reading the files, not running the pilot). The pilot's job
  was to price the option and to test whether Sprint 6's prose mechanisms hold up. It did both.
- **What would have changed the answer, stated without wanting it both ways.** An earlier draft
  claimed both that task 4 would have flipped to rewrite on a different result *and* that the
  headline verdict would survive any survivor count. Those cannot both be true, and the second is the
  accurate one. The structural arguments (no independent units, no tool restriction in the script,
  no mid-run steering) hold whatever the pilot returned, so the headline verdicts for tasks 3, 4 and
  6 are not falsifiable by this measurement. That is a limitation of the pilot's design, not a virtue
  of the argument.

  What the numbers do decide, and would genuinely have flipped: the two secondary recommendations.
  Giving the coordinator a workflow to *call* for fan-out phases rests on the price of a fan-out
  being roughly 600k tokens for a bounded review, which is affordable per release and not per commit;
  a figure ten times higher would kill it. The recommendation to split critic and fixer across models
  rests on the documented principle rather than on this run's refutation rate, for the reason given
  under task 3, so it is the weaker of the two claims to evidence. The headline verdicts change on
  nothing this pilot could have returned, and a reader should discount them accordingly and weigh the
  structural arguments on their own merits.

- **The strongest untested hypothesis, stated because it is the best argument against this memo.**
  The pilot ran a *fan-out audit*. Tasks 3, 4 and 6 would, if converted, be *sequential loops run as
  workflow scripts*. Those are different things, and nothing here tested the second. A workflow could
  in principle help a sequential loop for a reason that has nothing to do with breadth: deterministic
  control flow. A script can guarantee the revert step fires, that the round counter increments
  outside the agent's own narration, and that the cap actually stops the loop. The single most
  interesting thing the top-2 cap dropped from verification was precisely that these counters are
  narrated self-monitoring today. So the case this memo closes out is not airtight; it is closed on
  cost and on the absence of any independent units, with the control-flow hypothesis untested.

  What would test it: convert *one* mechanism, the ratchet, into a workflow script, run it against
  the same repo and target that the June watched run used, and compare token cost and whether the
  revert and cap actually fired. That is a PRJ-15-style A/B and it is a day's work. It is
  deliberately not recommended here, because the surviving finding says the ratchet's real gap is a
  false enforcement claim that a mission step closes for an hour's work, and that fix should land
  and be lived with before anyone spends a day measuring an alternative architecture. If Jamie wants
  the control-flow question settled rather than deferred, this is the experiment.

- **The same acceptEdits objection applies to what this memo recommends.** If a script's inability to
  restrict a critic's tools is a reason not to convert a single-repo review loop, it is a larger
  reason to be careful about a fan-out audit over the fleet's 20 active repos, where the same auto-approved
  edits apply across every one of them. The distinction the memo relies on is that the pilot's agents
  were read-only by prompt and, on inspection of the diff, none wrote anything: `git status` showed
  no change attributable to them. But `git status` is weak evidence here, since the parent session
  was writing to the same tree during the run. The sound evidence is the transcripts: across all 13
  agents the tool calls were 105 Bash, 35 Read and 12 StructuredOutput, and **zero** Edit, Write,
  MultiEdit or NotebookEdit. Even so, that is an observation about what these agents did, not a
  guarantee about what a workflow agent can do. Any fleet-wide workflow
  should run against clean checkouts or worktrees so the guarantee is structural rather than
  behavioural. That constraint belongs on the recommendation and is stated here as part of it.

---

## The decisions

The spec asks for one of two verdicts per task: **rewrite as a saved workflow script**, or **drop as
solved**. Tasks 3 and 4 get exactly that. Task 5 is a design principle rather than a mechanism, so it
gets the verdict plus a statement of how it survives. Task 6 is recommend-only by the spec's own
constraint, so it gets a recommendation and no decision.

### Task 3, the scored code-review loop: **drop as solved**

Solved by Sprint 6b, not by the platform. `project/skills/code-review-loop/SKILL.md` (150 lines)
shipped on 2026-06-19 and is registered in `install.sh:1229`: read-only critic, read-write fixer,
5-turn cap, 1000-line diff bound, JSONL log at `.loops/review-<surface>.log`.

**Do not rewrite it as a workflow.** Three reasons. None of the three is a pilot measurement: the
first is analytic, the second is documentation, the third is a judgement about where a cost guardrail
belongs. The pilot's contribution to this task is the price tag and the refutation pattern, both of
which sit in the sections above.

- **No fan-out to exploit.** Critic then fixer then critic is strictly sequential. The pilot's own
  result says the fan-out stage is where the noise came from and the verification stage is where the
  value was. A code-review loop is already all verification and no fan-out. There is nothing for a
  workflow to parallelise.
- **A script cannot make the critic read-only.** The `agent()` API has no tool-restriction option, and
  workflow subagents run acceptEdits with file edits auto-approved. The shipped skill runs in a
  session where the specialist agent definitions carry their own `tools:` allowlists (the tester's,
  for instance, is `Read, Bash, Grep, Glob, Task`), which is a real per-agent restriction with no
  equivalent in the workflow API. Note carefully: the pilot's verifier did make a related point when
  refuting a finding against this skill, but it was about those existing allowlists, not about
  workflow permission mode. The workflow claim is documentation, not measurement, and the two should
  not be run together.
- **The 5-turn cap is a human cost guardrail.** An overrun means "stop and look", which is exactly
  the mid-run steering a workflow structurally lacks.

One free improvement: the skill should recommend that critic and fixer run **different models**. A
one-line change to a shipped skill, not a rewrite. Be careful about what backs it. Not the 87.5%
figure: the section above spends four bullets explaining why that number cannot support a
comparative claim, and it would be incoherent to demolish it there and spend it here. What backs it is
the documented principle (a critic sharing the generator's weights returns agreement, not
verification) plus a weaker but real observation from this run: the cross-model verify stage
discriminated. It did not rubber-stamp. It returned substantive refutations for seven findings and
refused to refute the eighth after three attempts, quoting the file text each way. That is an
existence proof that the arrangement does something, not a measurement of how much better it is than
the alternative. Logged as **A11-ISS-14**.

### Task 4, the `mission-optimize` ratchet: **drop as solved**, then fix the overclaim

Solved by Sprint 6b. `project/missions/mission-optimize.md` (271 lines; the orientation block landed
before the pilot ran, so this is the file the pilot reviewed, and it is 260 lines at HEAD) is the
Karpathy ratchet:
worktree, median-of-three noise-floor baseline, keep-or-revert, JSONL log, caps, nothing auto-merged.

**Do not rewrite it as a workflow.** Same shape as task 3: one surface, one metric, strictly
sequential attempts, and a keep-or-revert decision that only means anything against a measured
baseline the previous attempt produced. There are no independent units.

But this is the one task where the pilot found deterministic code would genuinely beat prose, and it
is worth being precise about how narrow that is. The mission already collects the metric command and
the named editable surface as structured Required Inputs at Phase 1. Those values therefore exist, in
a known form, at a known moment. A script could take them, emit the matching `permissions.deny` rules
before Phase 2 begins, and assert their presence: a deterministic write-and-verify step. That is not a
workflow. It is a missing mission step plus a settings write, and it closes the surviving finding at
the mechanism level rather than the wording level.

Three follow-ups, logged as repo issues rather than applied, because a workflow finding is a hypothesis
and nothing from this run is merged automatically:

- **A11-ISS-11** correct the false enforcement claim at `mission-optimize.md:70`, plus its copies in
  `templates/mission-optimize-input-template.md:48` and
  `project/field-manual/quality-gates-guide.md:14`. Say what is actually enforced.
- **A11-ISS-15** the same claim, in its broadest form, at `project/agents/specialists/coordinator.md:265`.
  Found by the review of this memo rather than by the pilot, which is itself worth noting: the pilot's
  reviewers were pointed at four named surfaces and this instance sits outside all of them.
- **A11-ISS-12** add a Phase 2 step that writes and verifies deny rules for the run's declared metric
  command and editable surface, so the claim becomes true rather than softened.

### Task 5, every agent as a loop with a read-only judge: **drop as solved, keep as principle**

This is a design principle, not a mechanism, and the question asked of it was how it survives whichever
way tasks 3 and 4 go. The pilot answers that directly and the answer is sharper than it was in June.

The principle survives unchanged, because **its enforcement point was never the loop.** It is the
harness: `permissions.deny` in `library/settings.json.template`, the `gate-guard.sh` PreToolUse hook
closing the Bash route, and the default-fail evidence contract in the tester, developer and coordinator
(criteria start `false`, flip only on attached tool output). None of that depends on how tasks 3 and 4
are implemented, which is why both can stay as they are.

What the pilot adds is a strengthening and a warning:

- **Strengthening: the judge should be a different model.** On the documented principle, not on this
  run's refutation rate, for the reason given under task 3. Wire it into the loop-discipline guide as
  the default, not an option.
- **Warning: the pilot's own survivor is a documentation overclaim, not a missing control.** The
  failure mode this repo is actually exposed to is not an unguarded agent. It is a document telling
  the operator that something is enforced when it is a convention. There are now four known
  instances of exactly this one claim, and the fourth was found by this review rather than by the
  pilot: `mission-optimize.md:70`, `templates/mission-optimize-input-template.md:48`,
  `project/field-manual/quality-gates-guide.md:14`, and `project/agents/specialists/coordinator.md:265`,
  which states the broadest version of all ("any test that serves as a task's acceptance criteria
  are read-only to every agent, enforced by `permissions.deny`"). Four instances of one false claim
  is a pattern, not a typo. Every future claim of the form "enforced by X" in a mission, agent or
  field-manual file should be greppable back to the rule that enforces it. That is worth a standing
  check, and it would have caught all four on day one.

### Task 6, the coordinator as a phase-gated meta-loop: **recommendation only, Jamie decides**

**Status first, because it was not open.** The meta-loop shipped in Sprint 6c and is
live in `/coord continue`: convergence over fixed counts, per-phase error budget defaulting to 3,
condensed 1000 to 2000 token subagent returns, externalised state as the restart point, plus a
correlated-bias flag for unanimous judge agreement. It lives inside
`project/agents/specialists/coordinator.md`, which is 2,945 lines at HEAD (2,956 in the working tree,
for the same orientation-block reason).

**Recommendation: do not rewrite the coordinator as a workflow.** Three reasons, not five. An earlier
draft listed five and ordered them by how much the pilot supported them; review found that two were
restatements of the others and that the cost figure had no business leading. Three distinct reasons,
strongest first, plus one figure that is kept for a narrower purpose.

**Why the cost figure does not lead.** The pilot spawned 13 agents to do a fan-out audit. Converting
the coordinator to a workflow would not spawn 13 agents; a phase-gated loop spawns roughly what it
spawns today, because a workflow changes *control flow*, not agent count. Worse, every element of the
pilot (parallel read-only reviewers, per-finding verifiers, cross-model routing, a synthesiser) is
expressible with the `Task` tool the coordinator already has. So 596,827 tokens is the price of
thirteen subagents doing an audit. It is not the price of the workflow substrate, and it is not an
estimate of what converting the coordinator would cost. Leading with it would be exactly the move
this memo is meant to avoid. It is kept below, demoted, because it does bound one thing honestly: the
cost of adding a fan-out stage, which is the specific thing recommended at the end of this section.

1. **No mid-run steering exists in a workflow.** Documented, and the strongest independent critique of
   workflows in the wild. The coordinator is precisely the layer Jamie interrupts. A phase-gated
   meta-loop whose gates he cannot step into mid-run is worse than one he can, whatever it costs.
2. **Build work is interdependent.** Also documented as a poor fit. Orchestrator-worker wins on
   breadth-first independent strands and loses on coding, where the strands must see each other.
3. **A workflow script cannot restrict an agent's tools.** Same point as task 3, and it bites here
   because a coordinator that cannot be held to "delegate, do not edit" is a different animal. Note
   again that the deny rules and the hook would still fire; what is missing is any per-agent
   restriction and any approval step.
**And the one figure, kept for a narrower purpose.** Thirteen read-only agents ranging across
`mission-optimize.md`, the code-review-loop skill, `coordinator.md`, `coord.md`, `install.sh`,
`gate-guard.sh`, the settings template and the loop-discipline guide cost 596,827 subagent tokens and
five minutes. That is not a reason against conversion, for the reason given above. It is the right
number for the *other* decision in this section: whether to let the coordinator call a workflow for a
fan-out phase. Roughly 600k tokens for a bounded fan-out is affordable per release and not per commit,
and that is what makes the recommendation below a modest one rather than an open cheque.

**What to do instead, if the meta-loop is to get stronger.** Two things, both cheaper than a rewrite:

- **Give the coordinator the ability to launch a workflow for fan-out-shaped phases only**: review,
  audit, sweep, and above all a fleet-wide pass over the fleet registry's 20 active repos, which is the one
  genuinely independent-unit job in this ecosystem. The coordinator stays the orchestrator and gains a
  tool. This is the shape the pilot supports.
- **Externalise the counters.** The most interesting thing the cap dropped from verification was that
  the error budget and convergence checks are narrated self-monitoring with no counter outside the
  agent. A coordinator that writes its phase counter to `project-plan.md` and reads it back is a small
  change to an existing file and closes the same gap a rewrite would, without the bill. Note this is
  an unverified finding: it was raised, capped out, and never attacked by a second model. Treat it as
  a lead, not a fact.

---

## Where dynamic workflows *are* worth it in agent-11

The pilot argues against three conversions. It argues for one shape, and it is the shape the research
note predicted: many independent units with a checkable per-unit verdict, plus verification.

- **Fleet audit.** The 20 active repos in `~/Shared/tools/agent-11-fleet/registry.yaml` (28 entries in
  total, counted 2026-08-03), one agent each, structured findings, cross-model verify.
  Genuinely independent units. This is the killer application and it is not any of tasks 3 to 6.
  With one condition attached, for the reason given in the limits section: run it against clean
  checkouts or worktrees, because workflow subagents auto-approve file edits and "read-only by
  prompt" across 20 live repos is a behaviour, not a guarantee.
- **Release-diff review before a version ships.** A bounded, high-value, fan-out-shaped job where a
  ~600k-token bill is defensible once per release and unaffordable per commit.
- **The pattern to reuse from this run**: cheap model finds, expensive different model refutes,
  everything read-only, cap declared out loud. Saving the pilot script as a project-scoped
  `/release-review` is the cheapest way to keep it. That is deliberately not done here: nothing from
  this run has been saved, merged or auto-applied.

Nothing was adopted before this run. There were no saved workflows on this machine, no workflow
settings set, and no pilot. This memo is the first measurement; it is one measurement, and it should
be treated as such.

---

## What this close-out changed

- `project/agents/specialists/*.md` (11 files) and `project/missions/*.md` (18 files, excluding the
  two catalogue files) each gained an `## ORIENTATION PROTOCOL` section: Glob/Grep to locate before
  Read, read only the lines needed, never read a whole file to find one symbol, do not re-read.
  `library/CLAUDE.md` states the rule globally. The block deliberately carries **no statistic**. An
  earlier draft opened with "roughly 70% of tokens are waste", which is a real figure from the source
  research but one a deployed user cannot trace to anything. Shipping an unsourced number to every
  agent in every project, in the same close-out whose one verified finding is an unsourceable
  enforcement claim, would have reproduced the defect it found. The number came out.
- `scripts/validate-sprint6-closeout.sh` checks by exit code that all 29 named agent and mission files
  carry the canonical orientation block verbatim with nothing in the file countermanding it; that the
  gate surface matches HEAD by content hash as well as by `git status`, that the four deny rules still
  deny, that no allow rule or default permission mode undoes them, and that `gate-guard.sh` blocks six
  distinct shell write forms while still permitting unrelated writes; and that each of the four task
  headings in this memo records a decision rather than a hedge or a restatement of the menu. Silent and
  exit 0 when compliant.

  **What that check is not.** It is a drift detector, not a security boundary, and its own header says
  so. Three rounds of adversarial review found nine ways to pass an earlier version of it while the
  thing it claims to prove was false: a grep for the deny rules that passed when all four were moved
  into `permissions.allow`; a hook check satisfied by a comment mentioning the filename; a stub guard
  tailored to the single probe it was tested with; a change hidden from `git status` with
  `git update-index --assume-unchanged`; a countermanding sentence placed above the orientation
  heading; a real mission deleted and a placeholder added to restore the count; and a memo whose
  headings said "undecided between rewrite as a workflow and drop as solved". All nine now fail it, and
  each is re-tested in the write-up rather than asserted. But an adversary with commit access can still
  defeat any script that lives in the tree it checks, and saying otherwise would be the same false
  enforcement claim this memo's one surviving finding is about.
- `project-plan.md` Sprint 6 and the vault's `products/agent-11.md` now state what actually shipped,
  including v6.2.0, which neither recorded.
- The gate surface was not touched. Stated precisely, because the weak version of this claim is
  near-vacuous: `.quality-gates.json` does not exist in this framework repo and `gates/` here is
  framework source rather than live gate config, so checking only those two paths would pass on any
  state. The check therefore also covers `library/settings.json.template` and
  `library/hooks/gate-guard.sh`, the two files that carry the enforcement into deployed projects, and
  asserts that all four `Edit()` deny rules are still present in the template. All clean.
- **The coordinator's logic was not touched.** `project/agents/specialists/coordinator.md` does show
  as modified, because it received the same `## ORIENTATION PROTOCOL` block as the other ten
  specialists. Nothing in its meta-loop, phase gates, error budget, delegation rules or gate-refusal
  behaviour was changed, and no recommendation in this memo has been implemented.
- **Five issues were raised and none was fixed.** A11-ISS-11 and A11-ISS-12 from the pilot's surviving
  finding; A11-ISS-15 for the fourth instance of the same overclaim, found reviewing this memo;
  A11-ISS-14 for defaulting the code-review loop's critic and fixer to different models; and
  A11-ISS-13, unrelated to the pilot, for `install.sh`'s mission list omitting `connect-mcp.md` and
  `operation-recon.md` so two library missions never reach a deployed project.
- Nothing was merged, committed or pushed. Every issue raised is logged in
  `ISSUES.md` and left open.

## What is left

One thing: **Jamie's call on task 6.** The recommendation above is do not rewrite; give the
coordinator a workflow to call for fan-out phases, and externalise its counters. Once that is decided,
Sharper Ways of Working closes.
