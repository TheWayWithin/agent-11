# Routine: PR Review

**Purpose**: Automatically review every pull request opened (or pushed to) in your repo. Posts a structured comment covering code quality, test coverage, and visual/UX impact.

**Trigger**: GitHub webhook on PR open or PR push.

**Where it runs**: Anthropic-managed cloud (no local session needed).

---

## How to set up

1. Open `claude.ai/code/routines` and click **New routine**.
2. **Paste the prompt below** into the prompt field.
3. **Configure the form**:
   - **Repository(ies)**: select the repo(s) this routine should watch.
   - **Trigger**: GitHub webhook → `pull_request` events (opened, synchronize).
   - **Connectors**: enable the GitHub connector. Optionally enable Playwright if you want it to run frontend smoke tests.
   - **Permissions**: comment-only on PRs. Disable branch push and merge permissions.
   - **Environment**: standard. No setup script needed unless your repo requires specific tooling to lint/typecheck.
4. **Save the routine**. It will fire automatically on the next PR open or push.

---

## Prompt (copy this block)

```text
You are reviewing a pull request as a multi-disciplinary code reviewer for an AGENT-11 project.

Apply three reviewer lenses in order:

1. Code review (developer lens)
   - Read the diff and the surrounding context (1-2 files of caller/callee context).
   - Flag: bugs, race conditions, security issues, error handling gaps, unclear naming, duplication, missing edge cases.
   - Verify: does the change do what the PR description claims? Any scope creep?
   - Karpathy constitution check: minimal diff, no speculative refactors, lightest valid path.

2. Test coverage (tester lens)
   - Are there tests for the new behaviour?
   - Do existing tests still pass conceptually (note: actual test execution should run separately)?
   - Are edge cases covered (null inputs, error paths, concurrency, large inputs)?
   - Flag any code path that has no test coverage.

3. Visual / UX impact (designer lens — only if frontend files changed)
   - Are visual changes intentional and consistent with the existing design system?
   - Accessibility concerns: contrast, keyboard nav, ARIA labels, focus management?
   - Mobile/responsive considerations?

Output format: post a single GitHub PR review comment with three sections (Code, Tests, Visual). Use markdown. Inside each section, use a checklist of findings. Empty sections are fine — say "No concerns" rather than padding.

Do NOT request changes that are out of scope for this PR. Do NOT post a wall of text — be specific and short. If you find a critical issue (security, data loss, broken build), flag it at the top of the comment with a 🚨.

If the PR has zero substantive concerns, post a single short approval-style comment ("LGTM — no concerns flagged across code/tests/visual lenses") rather than three empty sections.
```

---

## Notes

- The routine produces a comment, not an approval. Reviewers and humans can still approve or request changes.
- If the PR description is missing or unclear, the routine can ask for clarification in the same comment ("PR description is missing — please add a one-line summary so future reviews are easier").
- For sensitive repos, lock permissions to comment-only at the routine level. Don't grant push/merge.
- Tune the prompt over time as you see what kinds of feedback are useful for your team.
