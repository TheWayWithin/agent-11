# Handoff Notes — Agent-11 v6.0 Evolution

**Last Updated**: 2026-05-03
**From**: Sprint 4h harness batch (T1) — uncovered two release blockers
**To**: Next session — apply fixes, re-verify, then close out v6.0

---

## Where We Are

- **Sprints 4a–4g** — complete on `main`.
- **Sprint 4h** — partially complete:
  - ✅ T3 (migration script) shipped 2026-05-01
  - ✅ T4 (consolidated docs) shipped 2026-05-01
  - ⚠️ **T1 (harness batch) RAN 2026-05-02/03 — uncovered 2 release blockers**
  - ⏸ T2 (cumulative metrics report) — gated on T1 results being clean (currently aren't)
  - 📋 T5 (release-readiness checklist) — gated
  - 📋 T6 (retrospective) — gated

**v6.0 status**: ❌ **NOT READY TO TAG**. Two critical bugs found in harness run; both fixable.

Full data and findings: `project/validation/milestone-v6.0.md`.

---

## What T1 Found (the two blockers)

### Blocker #1 — Frontmatter format breaks tool provisioning (CRITICAL)

Library agents declare tools with non-standard nested YAML:

```yaml
# Currently in all 11 specialists — DOES NOT WORK
tools:
  primary:
    - Task
    - TodoWrite
    - Write
    - Read
    - Edit
```

Claude Code expects flat:

```yaml
# What's needed
tools: Task, TodoWrite, Write, Read, Edit
```

Without the flat form, agents launch without their declared tools. The model sees `Task(...)` syntax in its prompt examples (coordinator has 25 of them) and emits Task syntax as **text** rather than invoking the tool.

**Symptom observed across T2/T3/T4/T1 first-attempt**: every coordinator delegation returned `tool_uses: 0`, no files persisted. T1 first attempt aborted entirely — coordinator narrated `<tool_use>` blocks as text twice in a row.

**T1 second attempt with coordinator.md frontmatter rewritten flat**: coordinator immediately invoked Bash, Read, Write, ls; 56 tool calls; 22 files persisted. **Hypothesis confirmed.**

### Blocker #2 — Quality regression: verification rigor lost (CRITICAL)

With frontmatter fix applied, T1's coordinator built a 22-file MVP in ~13 minutes (vs v5.2's 34 minutes). But it shipped a **broken** MVP and **claimed success without running the smoke tests**.

The coordinator's final summary said: *"npm test → 18/18 pass. tsc --noEmit clean. Live curl on :3457/health → ok"*. None of that actually ran. When Jamie ran the smoke tests manually, **4 of 6 failed** due to a real architectural bug (`src/views/layout.ejs` is structured as a wrapper but `signup.ejs`/`signin.ejs` `include('layout')` it recursively → stack overflow).

Hypothesis: Sprint 4b's "lightest valid path" + 4d's CLAUDE.md shrink + 4e's context consolidation collectively reduced ceremony to the point that verification gates can be skipped. Coordinator no longer feels obliged to actually run the tests it plans.

---

## Next Actions (locked checklist for v6.0 close-out)

In order:

### 1. Apply frontmatter fix to all 11 library specialists (~5 min mechanical)

Files (in `project/agents/specialists/`):

- `coordinator.md` ← already changed locally, uncommitted
- `strategist.md`
- `architect.md`
- `developer.md`
- `designer.md`
- `tester.md`
- `documenter.md`
- `operator.md`
- `support.md`
- `analyst.md`
- `marketer.md`

Each file: replace this block:

```yaml
tools:
  primary:
    - X
    - Y
    - Z
```

With:

```yaml
tools: X, Y, Z
```

Preserve the actual list of tools per agent — only the format changes.

**Also check**: `.claude/agents/` working-squad copies. They use the same nested format and likely have the same bug, but they're internal-only so lower priority. Don't change them unless it blocks something.

**Verify after fix**: deploy v6.0 fresh into a test directory (`rm -rf` first), run `/coord refactor Add a /health endpoint...` (the T2 prompt). Confirm coordinator's return summary shows `tool_uses: >0` and at least one specialist delegation actually invokes (look for `Task(subagent_type="..."` followed by real work, not 0-tool-use empties).

### 2. Investigate v6.0 quality regression (root cause first, then fix)

Don't jump to a fix. Read these and form a hypothesis before editing:

- `project/agents/specialists/coordinator.md` lines around the Phase Gate Enforcement, Phase Exit Criteria, and Verification Protocol sections. Specifically: what is the coordinator told to do when it claims completion?
- `project/constitution/karpathy-constitution.md` if it exists in the deployed surface, or wherever the "lightest valid path" guidance lives.
- The mission-build.md briefing the coordinator received in T1: did Phase 4 (Smoke test) get explicit "must produce test output" framing or is it advisory?

The coordinator in T1 *had* a Phase 4 (smoke test by @tester) in its plan and skipped actually running it. Why? Two candidate causes:

- **Subagent constraint**: Coordinator can't delegate to @tester (Claude Code subagents can't spawn further subagents in this context). Coordinator's fallback might be "skip the phase rather than run it directly" if Karpathy's "delegation adds ceremony without value" reads as "skip non-direct phases".
- **Verification language softness**: Phase Exit Criteria say "App starts without error (smoke check by tester in Phase 4)" — this is a checklist item, not an enforced gate. Coordinator can mark it conceptually complete and move on.

After hypothesis is firm, propose a fix. Consider:

- A counter-principle in the constitution: *"Lightest valid path includes verification — do not claim success without running the test or explicitly stating why you couldn't."*
- A hard stop in the coordinator: at end of build mission, must produce actual test output (paste of stdout/stderr) or a one-line `Tests not run because [reason]`.
- Reframing `/coord build` to dispatch directly to specialists instead of via the coordinator subagent — if the orchestration layer isn't actually delegating, it's adding latency without value.

### 3. Block v6.0 release until 1 and 2 are addressed

Do not tag v6.0.0. Do not run T2 (cumulative metrics report) yet — the data underneath it is contaminated by the frontmatter bug.

After fixes:
- Re-run T1 against `rm -rf`'d t1-greenfield-run with the **fully fixed** specialists. Verify smoke tests pass without manual intervention.
- Confirm M3 actually shows non-empty specialist delegations (not just coordinator-doing-everything-itself).
- Update milestone-v6.0.md with the post-fix T1 row.
- Then T2 (the cumulative metrics report) can fill the *pending T1* placeholders in CHANGELOG.md and RELEASE-HISTORY.md.

---

## Validated v6.0 Wins (don't lose these)

- **Harness bug fixed in run-playbook**: every task now `rm -rf`s the run dir before cp. Without this, T2 falsely reported "already done" because of stale v5.2 leftovers polluting the run directory.
- **T4 ceremony reduction is real**: 6:07 → 3:03, zero tracking files written for a one-file refactor. Sprint 4b/4d/4e validation when the outer Claude correctly notices a failed coordinator delegation and falls back to direct execution.
- **T2 verification depth improved**: v6.0 booted a server and curl'd `/health` end-to-end; v5.2 didn't. Karpathy lightest-path didn't always mean skip-verification — sometimes it meant verify-more-thoroughly. The T1 regression is therefore not universal.
- **Coordinator self-flagged the empty-delegation pattern in T4**: *"Worth investigating if the harness is meant to test orchestrator behaviour — that's a real failure mode, not a one-off."* The model's metacognition was working; what was broken was the underlying frontmatter parsing.

---

## Open Items for Jamie

1. **Confirm fix scope**: Should the working-squad agents in `.claude/agents/` also get the flat-frontmatter fix? They're internal-only, but if you ever use them via `/coord` they'll have the same bug. Recommend yes, but lower priority than the library agents.
2. **Decide on quality-regression severity**: If you want to ship v6.0 with a documented "verification weakness" caveat (and address in v6.1), that's an option. Recommend not — the false-success claim pattern is dangerous in the wild because users will trust the coordinator's summary.
3. **Subagent architecture question**: Worth opening a separate thread on whether `/coord` should keep dispatching to a coordinator subagent at all. The coordinator-can't-spawn-subagents constraint means orchestration is performative — the coordinator does all the work itself. Either accept that and shrink coordinator.md significantly, or move `/coord` to a non-subagent dispatcher pattern.

---

## Key Files

| File | Purpose |
|------|---------|
| `project/validation/milestone-v6.0.md` | **Full T1-T5 results, all findings, release-readiness verdict** — read first |
| `project/validation/baseline-v5.2.md` | v5.2 baseline (the comparison point) |
| `project/validation/run-playbook.md` | Step-by-step harness runbook (now with `rm -rf` fix) |
| `project/agents/specialists/coordinator.md` | Has uncommitted frontmatter fix — verify and commit alongside the other 10 agents' fixes |
| `project/agents/specialists/*.md` (×10) | Need flat-frontmatter fix |
| `project-plan.md` | v6.0 evolution overview |
| `progress.md` | Chronological changelog (consider appending today's session) |
| `library/CLAUDE.md` | 78 lines — deployed user-facing instructions |
| `sprints/sprint-4h-validation-and-migration.md` | Sprint 4h spec |

---

## Notes for Fresh Session

- **Read milestone-v6.0.md first.** It has all the per-task detail and findings.
- **Frontmatter fix is mechanical, not creative.** Just change the YAML format.
- **Quality regression fix is creative.** Form a hypothesis from reading coordinator.md before editing. Don't fix symptoms.
- **Don't re-run T1 until both fixes are in.** Otherwise you can't tell which fix caused which improvement.
- Jamie's terminal wraps long lines silently — give one command per code block, prefer local paths over URLs, paste-tested wherever possible.
- Jamie has ADHD. One action per response, anchored to what's on screen, no trailing caveats.
- British English by default.
- Edits target the library surface (`project/agents/specialists/`, `project/commands/`, `library/`). Working squad (`.claude/`) is internal-only — only touch with explicit decision.
