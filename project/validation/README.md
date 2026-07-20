# Validation harness

Internal validation infrastructure for the AGENT-11 framework. Nothing in this
directory is deployed by `install.sh`.

| Path | Status | Purpose |
|------|--------|---------|
| `fixtures/` | Committed | Canonical task fixtures (t1–t5). Prepared once, runs start from a clean copy (see `harness-spec.md`). |
| `baseline-runs/` | **Gitignored — never commit** | Generated run output (sample apps produced by validation runs). Write runs here locally; they stay out of version control. |
| `baseline-v5.2.md`, `milestone-*.md` | Committed | Baseline and milestone result documents. |
| `run-playbook.md`, `harness-spec.md` | Committed | How to run the harness. |

## Why baseline-runs is gitignored (ISS-6)

The v5.2 baseline run outputs were committed and grew to ~15MB / 938 files —
roughly half the "code" in the repo by node count, all of it throwaway output
that polluted clones and code analysis. They were removed from version control
on branch `fix/iss-6-baseline-runs-bloat` (2026-07-20). The historical runs are
recoverable from git history at the parent of that removal commit.

A guard script blocks accidental re-commits: `project/validation/check-no-run-output.sh`
fails if any run output is staged. Run it manually or from a pre-commit hook.
