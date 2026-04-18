# Sprint 4h: Validation + Migration

**Part of**: Agent-11 v6.0 Evolution (Sprint 4 umbrella)
**Predecessor**: Sprint 4g — Skills + Routines
**Successor**: none (final v6.0 sprint — hands off to ongoing maintenance / post-v6 backlog)
**Status**: Outline only — detailed spec produced as the final task of Sprint 4g

---

## Goal (provisional)

Prove v6.0 is materially better than v5.2 baseline, then ship it to a private beta cohort. Produce a migration script for existing users so upgrading is one command, not a manual rewrite.

## Scope Outline (to be refined in detailed spec)

- **Full harness run on v6.0** — all 5 representative tasks.
- **Metric comparison** — v6.0 vs v5.2 baseline on task time, session-start tokens, unnecessary delegations, intervention rate, recovery success.
- **Summary report** — short, Jamie-readable document stating: what moved, by how much, and whether the sprint targets were met.
- **Migration script** `v5.2 → v6.0`:
  - Compacts existing 5-file context model into 3 files
  - Backs up existing `.claude/CLAUDE.md` before shrinking
  - Updates `.mcp.json` to dynamic tool-search format
  - Installs new coordinator / specialist prompts
  - Verifies integrity before and after
- **Consolidated documentation update** — single coordinated pass across all user-facing docs (see "README & Docs" below).
- **Private beta** — invite 5–10 solo founders who've previously used Agent-11. Collect feedback for 2–4 weeks before public release.

## README & Docs (Consolidated Update for v6.0)

Per the plan's Documentation & Release Communications strategy, all user-facing docs are updated once here using the "User-Facing Changes" running list accumulated across Sprints 4a–4g in `progress.md`.

**Deliverables**:
- `README.md` — rewritten to describe v6.0: Universal Router (`/coord [mission]`), Karpathy discipline, 3-file context model, dynamic MCP tool search, Routines for Mode C.
- `CHANGELOG.md` — v6.0 entry: breaking changes, new features, deprecations, migration pointer.
- `docs/RELEASE-HISTORY.md` — v6.0 summary block (what, why, metrics moved).
- `MCP-GUIDE.md` — new tool-search workflow.
- `library/CLAUDE.md` install-time message — brief guidance for users on new-vs-old differences.
- Migration notes embedded alongside the migration script.

**Acceptance**: a new user can install v6.0 and get started purely from the README without consulting v5.x docs. Existing users can run the migration script and find every breaking change documented in CHANGELOG.

## Acceptance (provisional)

- Harness metrics improved on ≥3 of 5 dimensions vs baseline. No regression >10% on any dimension (or regression is justified and documented).
- Migration script tested on a fresh clone and on Jamie's own projects — no data loss.
- 5+ beta users onboarded without manual intervention.
- Public release notes drafted but not yet published.

## First Task of This Sprint

Produce detailed spec for this sprint.

## Final Task of This Sprint

Post-mortem and retrospective on the full v6.0 evolution — write to `.archive/2026-XX-XX-v6-retro/` for future reference. Decide what belongs in post-v6 backlog.

## Open Questions

- What feedback channels for beta — GitHub issues, private Slack, direct email?
- What's the rollback plan if a beta user hits a blocker — is the migration reversible?
- When does v6.0 become `main` — after beta, or during? And who cuts the v5.x long-term support line, if any?
