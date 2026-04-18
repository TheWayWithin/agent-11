# Sprint 4g: Skills + Routines

**Part of**: Agent-11 v6.0 Evolution (Sprint 4 umbrella)
**Predecessor**: Sprint 4f — Dynamic MCP Tool Search
**Successor**: Sprint 4h — Validation + Migration
**Status**: Outline only — detailed spec produced as the final task of Sprint 4f

---

## Goal (provisional)

Adopt the 3-tier skills architecture with the Agent Skills open standard (`SKILL.md`). Integrate Claude Code Routines for Mode C operational work so daily reports, blog posts, and PR reviews don't require a human-driven session.

## Scope Outline (to be refined in detailed spec)

**Skills (3-tier structure)**:
- **Tier 1 — Behavioural**: Karpathy constitution in `.claude/CLAUDE.md` (already done in 4d)
- **Tier 2 — Project Domain**: Project-specific decisions in `skills/` formatted to SKILL.md standard
- **Tier 3 — Marketplace**: Curated SaaS skills (auth, billing, analytics, email, onboarding, multi-tenancy, payments) reformatted to open standard for future publishing

**Routines (Mode C automation)**:
- `pr-review` — triggered by GitHub webhook on PR open
- `nightly-qa` — scheduled tester/designer sweep
- `backlog-triage` — scheduled strategist sweep of issues and proposals
- `/coord` outputs ready-to-import Routine config (JSON + prompt snippet) when it detects operational intent — user pastes into web UI.

## Acceptance (provisional)

- All existing skills reformatted to SKILL.md standard and load correctly.
- 3 Routine config templates produced, tested by Jamie in web UI at least once.
- `/coord` detects operational intent (e.g., "run daily report") and outputs Routine config instead of executing.
- Documentation updated: deployed `library/CLAUDE.md` includes skills tier guidance.

## First Task of This Sprint

Produce detailed spec for this sprint.

## Final Task of This Sprint

Produce detailed spec for Sprint 4h.

## Open Questions

- Do Routines ship as committed configs in-repo, or as paste-from-docs snippets only? Blueprint leans paste.
- Which existing skills are good candidates for Tier 3 marketplace vs Tier 2 project-specific?
- How does a Routine share context with a `/coord` session, or do they stay isolated?
