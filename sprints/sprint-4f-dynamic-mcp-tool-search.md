# Sprint 4f: Dynamic MCP Tool Search

**Part of**: Agent-11 v6.0 Evolution (Sprint 4 umbrella)
**Predecessor**: Sprint 4e — Context Consolidation ✅ (T1, T3-T6, T8 shipped; T7 deferred)
**Successor**: Sprint 4g — Skills + Routines
**Status**: Detailed spec ready for Jamie's review; execution can start once Sprint 4e is committed

**Reference**: `Ideation/Dynamic MCP Tooling for Agent-11_ Context Optimization and Agent Routing.md`

---

## Goal

Replace static MCP tool loading with **deferred loading + tool search**, so MCP context cost drops from ~51K tokens at session start to ~3-8K. Tools are discovered on demand via `tool_search_tool_regex_20251119` and loaded lazily when the regex matches.

The plumbing already exists at `project/mcp/dynamic-mcp.json` and is deployed by install.sh (Sprint 11). What's missing: it isn't wired in as the canonical `.mcp.json`, specialist prompts don't use the Tool Search workflow, and there's no measurement against the baseline.

## Why This Sprint

Three observations:

1. **MCP token cost dominates session-start budget.** Per the Dynamic MCP doc, loading all 7 configured MCP servers' full tool sets costs ~51K tokens at startup. That's roughly the size of the v5.2 baseline's *entire* CLAUDE.md + coordinator + specialists combined. After 4d's CLAUDE.md shrink and 4e's context consolidation, MCP is the single biggest remaining session-start cost.
2. **Static profile switching was the v5.x answer; native deferred loading is the v6.0 answer.** Claude Code's `defer_loading` + Tool Search make profile switching obsolete. Specialists pull what they need when they need it; the rest sits unloaded.
3. **The dynamic config already exists** (`project/mcp/dynamic-mcp.json`) but isn't connected — install.sh deploys it to `mcp/` but the canonical `.mcp.json` is the static one downloaded from `main`. Sprint 4f finishes the wiring.

## Scope Reminder

Library surface only: `project/mcp/`, `project/agents/specialists/`, `project/commands/`, `project/deployment/`, `library/CLAUDE.md`. No working-squad changes.

---

## Tasks

### T1. Audit current MCP deployment vs dynamic-mcp.json

**Deliverable**: a clear delta between what `install.sh` currently deploys and what the dynamic config requires. Identify which file becomes the canonical `.mcp.json` post-4f.

**Approach**:
1. Inspect existing `.mcp.json` (downloaded from `main` branch by install.sh) and `project/deployment/templates/.mcp.json.template`.
2. Compare with `project/mcp/dynamic-mcp.json` (the dynamic config Sprint 11 added but didn't activate).
3. Document the deltas — fields, server entries, tool entries.
4. Decide: does dynamic-mcp.json **replace** `.mcp.json`, or does install.sh **transform** it into `.mcp.json` shape?

**Recommendation**: dynamic-mcp.json **replaces** the old `.mcp.json`. The static file is retired. install.sh deploys dynamic-mcp.json directly as `.mcp.json` (or symlinks). One source of truth.

**Acceptance**: Audit document or commit message lists the deltas, names the canonical file, and confirms no broken references.

---

### T2. Wire dynamic-mcp.json as the canonical .mcp.json

**Deliverable**: `install.sh` deploys `project/mcp/dynamic-mcp.json` to `.mcp.json` in user projects. The old static `.mcp.json` download from `main` is retired.

**Changes**:
- `install.sh` `setup_mcp_configuration()` function: deploy `project/mcp/dynamic-mcp.json` → `<project-root>/.mcp.json`. Backup any existing user `.mcp.json` before overwrite.
- Retire the curl-from-main download for `.mcp.json` (the static config).
- Keep the `.env.mcp.template` deployment unchanged — that's API keys, separate concern.
- Update `project/deployment/templates/.mcp.json.template` to match dynamic-mcp.json schema (or delete if redundant).
- Regenerate `install.sh.sha256`.

**Acceptance**: Smoke test (same pattern as 4d): fresh install on a scratch dir produces `.mcp.json` with `defer_loading: true` entries. Existing user `.mcp.json` is backed up before overwrite.

---

### T3. Update specialist prompts with Tool-Centric Workflow

**Deliverable**: each specialist that uses MCP tools has a clear Tool Search workflow in its prompt:

```
1. Identify the capability you need.
2. Search for tools: `tool_search_tool_regex_20251119(pattern="mcp__supabase")`.
3. Load matching tools (automatic on first use).
4. Execute the task.
5. /clear or move on — tools stay in session context but unused tools don't reload.
```

**Specialist mapping** (search patterns each specialist uses by default):

| Specialist | Primary patterns | Use cases |
|------------|------------------|-----------|
| @developer | `mcp__supabase`, `mcp__context7`, `mcp__github` | DB ops, library docs, repo work |
| @tester | `mcp__playwright` | Browser automation |
| @operator | `mcp__railway`, `mcp__netlify`, `mcp__github` | Deployment, CI/CD |
| @architect | `mcp__context7`, `mcp__github`, `mcp__firecrawl` | Architecture research |
| @analyst | `mcp__supabase`, `mcp__firecrawl` | Data analysis |
| @marketer | `mcp__firecrawl`, `mcp__stripe` | Research, revenue |
| @designer | `mcp__playwright`, `mcp__firecrawl` | Visual checks, competitor research |

**Coordinator changes**: the existing `DYNAMIC MCP TOOL DISCOVERY` section (already in coordinator.md) is canonical. Specialists reference it; their own prompts get a 3-line Tool Search hint, not a duplicate.

**Acceptance**: Each specialist's MCP-related guidance is one short paragraph + a search pattern. No long static lists of MCP tools in specialist prompts.

---

### T4. Pre-loaded discovery vs deferred execution split

**Deliverable**: confirm or refine the discovery/execution split in `dynamic-mcp.json`. Each MCP server has 1-2 lightweight "discovery" tools pre-loaded; everything else is deferred.

**Current split** (from `project/mcp/dynamic-mcp.json` audit):
- context7: `resolve-library-id` pre-loaded; `get-library-docs` deferred.
- firecrawl: `firecrawl_scrape`, `firecrawl_batch_scrape` pre-loaded; crawl/map deferred.
- playwright: `browser_navigate` pre-loaded; the rest deferred.
- supabase: `list-tables` pre-loaded; CRUD deferred.
- github: `search_repositories` pre-loaded; everything else deferred.
- railway: `list-projects` pre-loaded; deploy/logs/services deferred.
- stripe: `search_customers` pre-loaded; create/list deferred.

**Open question**: is the firecrawl pre-load (`scrape` + `batch_scrape`) too heavy? Each is several hundred tokens. Recommendation: keep both initially; revisit after T6 measurement if MCP cost is still high.

**Acceptance**: Split documented in `field-manual/mcp-integration.md` (or replacement). Specialists know which tools they get for free vs need to load.

---

### T5. Retire profile-switching command stubs

**Deliverable**: any remaining v5.x MCP profile-switching artefacts are removed.

**Inventory** (verify during execution):
- Sprint 4a deleted: `.mcp-profiles/`, root `mcp-setup.sh`, `.claude/commands/mcp-{switch,status,list}.md`. ✅ already gone.
- Check for residue: `grep -r "mcp-switch\|mcp-list\|mcp-status\|.mcp-profiles" project/ library/ templates/ 2>/dev/null` — any hits get cleaned up.
- The deployed README mentions `.mcp-profiles/` in its post-install guidance — update to describe dynamic loading instead.

**Acceptance**: `grep -r "mcp-profile" library/ project/ 2>/dev/null` returns zero results. install.sh post-install message describes Tool Search, not profile switching.

---

### T6. Update lean library/CLAUDE.md

**Deliverable**: the MCP section in lean CLAUDE.md describes the dynamic loading model concisely.

**Diff** (from current 4d/4e shape):
- The current "Tools are deferred and discovered on demand via Tool Search" line is already correct.
- Add a one-line note that `.mcp.json` ships with `defer_loading` enabled and tools auto-load on Tool Search match.
- Confirm the search-pattern table is current.

**Acceptance**: Lean CLAUDE.md still under 80 lines after the edit. MCP section is one short paragraph + the pattern table.

---

### T7. Re-run harness and measure

**Subset**: Tasks 1 (bootstrap), 2 (feature build), 3 (bug fix). Bootstrap exercises the fresh install of the dynamic config; feature build is the long-horizon test where MCP tools get loaded on demand; bug fix confirms light-context paths don't accidentally trigger MCP loads.

**Deliverable**: `project/validation/milestone-4f.md` with results compared to milestone-4e baseline.

**Success criteria**:
- M2 (session-start tokens) drops measurably on all three tasks. Target: ≥30K reduction vs the v5.2 baseline of ~49K (per the reference doc's projection).
- Specialists successfully discover and load MCP tools mid-task via Tool Search (observed in harness recordings).
- No regression in MCP-using task outcomes — Supabase queries, GitHub PR creation, browser tests still work.
- M4 (human interventions) does not increase due to "tool not found" friction.

---

### T8. Write Sprint 4g detailed spec

**Deliverable**: replace the outline at `sprints/sprint-4g-skills-and-routines.md` with a detailed spec.

The spec should cover:
- The SKILL.md open standard (Anthropic's spec): how to format library skills, what triggers loading, how to publish.
- Three priority Routines for Mode C (operational) work: PR review, nightly QA, backlog triage. Decide cadence, where they run (web UI paste vs in-repo configs), and how they integrate with the v6.0 surface.
- The format-only intent for Tier 3 SaaS skills — publish later, not now.
- Migration: existing project/skills/ → SKILL.md format if differences exist.

**Acceptance**: Sprint 4g detailed spec written; Jamie has reviewed and approved scope.

---

## Definition of Done

- [ ] T1: dynamic-mcp.json vs static .mcp.json delta documented; canonical file decided
- [ ] T2: install.sh deploys dynamic-mcp.json as `.mcp.json`; smoke test confirms `defer_loading` shipped
- [ ] T3: All 7 MCP-using specialists have a Tool-Centric Workflow paragraph + search pattern
- [ ] T4: Discovery/execution split confirmed; documented in field-manual
- [ ] T5: No `mcp-profile` residue in library; post-install README updated
- [ ] T6: Lean library/CLAUDE.md MCP section reflects dynamic loading; <80 lines
- [ ] T7: Harness subset re-run; milestone-4f.md committed; M2 drops ≥30K vs v5.2 baseline
- [ ] T8: Sprint 4g detailed spec written and approved

---

## Risks & Watch-Items

- **Tool Search regex misses.** A specialist searches for `mcp__supabase` and Tool Search returns nothing because the regex pattern requires escaping. Mitigation: T3 includes specific working patterns in each specialist; T7 verifies they resolve on a fresh install.
- **Pre-loaded discovery tools still expensive.** If the 7 pre-loaded tools collectively cost 5-8K tokens, that's still a meaningful chunk of session-start. Mitigation: T4 reviews the split; T7 measures actual cost; if too high, prune to 1 tool per server.
- **User custom `.mcp.json` overwrite.** install.sh deploys dynamic-mcp.json as `.mcp.json` — if a user customised theirs, we shouldn't overwrite. Mitigation: T2 backs up before overwrite, prints a notice, leaves user files alone if they exist (same pattern as 4d settings.json).
- **MCP server availability.** dynamic-mcp.json references 7 servers (context7, firecrawl, playwright, supabase, github, railway, stripe). Not every user has API keys for all. Mitigation: deferred loading means missing-key servers don't break — they just don't appear in Tool Search results.
- **Specialist prompt churn.** T3 touches all 7 MCP-using specialists. Risk of breaking subtle MCP-related instructions. Mitigation: targeted edits, not bulk replace; review each specialist diff individually.

---

## Open Design Questions (to resolve in T1-T2)

- **Replace or merge `.mcp.json`?** Recommendation: replace. dynamic-mcp.json becomes the single source of truth. Static `.mcp.json` is retired.
- **Pre-loaded count per server?** Recommendation: 1 lightweight discovery tool per server is the floor; 2 max only if both serve distinct discovery needs (e.g., firecrawl scrape + batch_scrape).
- **Where does the Tool Search regex pattern catalogue live?** Options: `field-manual/mcp-integration.md` (already exists, deployed in 4d), inside coordinator.md's DYNAMIC MCP TOOL DISCOVERY section, or both. Recommendation: field-manual is canonical; coordinator references it.

---

## Notes for Execution

- T1 is the audit task — get the file inventory clear before any edits.
- T2 is the highest-risk task (affects every install). Smoke test is mandatory — same pattern as 4d's smoke test.
- T3 is the largest task by file count (7 specialists). Targeted edits only.
- T7 is mandatory — Sprint 4f's whole value is the M2 reduction; no measurement, no claim.
- Sprint 4f is the last *technical* sprint of v6.0. Sprints 4g and 4h are skills/routines and validation — neither touches the runtime context surface significantly.
