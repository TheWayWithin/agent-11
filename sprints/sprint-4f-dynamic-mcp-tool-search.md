# Sprint 4f: Dynamic MCP Tool Search

**Part of**: Agent-11 v6.0 Evolution (Sprint 4 umbrella)
**Predecessor**: Sprint 4e — Context Consolidation ✅ (T1, T3-T6, T8 shipped; T7 deferred)
**Successor**: Sprint 4g — Skills + Routines
**Status**: Recalibrated 2026-04-26 after T1 audit revealed schema mismatch; execution in progress

**Reference**: `Ideation/Dynamic MCP Tooling for Agent-11_ Context Optimization and Agent Routing.md` (note: ideation doc is based on Claude API schema, not Claude Code — see T1 finding below)

---

## Goal

Reduce MCP context cost at session start from ~51K tokens to <8K, leveraging Claude Code's **native** auto-deferring behaviour rather than a custom per-tool config.

## T1 Finding That Changed Scope (2026-04-26)

Sprint 4f originally planned to wire `project/mcp/dynamic-mcp.json` as the canonical `.mcp.json`. **That doesn't work**: the file uses the Claude API schema (`toolsets`, per-tool `defer_loading`), not the Claude Code schema (`mcpServers` registry only). Claude Code would not understand it.

**What actually works in Claude Code**:
- `.mcp.json` is the server registry (stdio commands, args, env). Existing `.mcp.json.template` is correct.
- Tool deferring is **automatic** — Claude Code auto-manages context when tool count is high.
- The user-tunable lever is `ENABLE_TOOL_SEARCH=auto` in `.claude/settings.json` (threshold-based loading).
- `tool_search_tool_regex_20251119` is the runtime discovery primitive specialists already know how to use (it's referenced in coordinator.md's DYNAMIC MCP TOOL DISCOVERY section).

Implication: **`project/mcp/dynamic-mcp.json` is obsolete cruft from Sprint 11** (built on misreading of Claude Code's schema). It gets archived. The actual sprint deliverable is much smaller than originally scoped.

Reference: [Connect Claude Code to tools via MCP](https://code.claude.com/docs/en/mcp).

## Why This Sprint

Three observations:

1. **MCP token cost dominates session-start budget.** Per the Dynamic MCP ideation doc, loading all 7 configured MCP servers' full tool sets costs ~51K tokens at startup. After 4d's CLAUDE.md shrink and 4e's context consolidation, MCP is the single biggest remaining session-start cost.
2. **Claude Code now auto-defers tools natively** when many MCP servers are configured. We don't need to build per-tool config; we need to **enable** the native behaviour and **teach specialists** to use Tool Search instead of assuming all tools are pre-loaded.
3. **The Sprint 11 dynamic-mcp.json was built on a misreading of the schema** (T1 finding above). Archiving it removes confusion and gets us to the simpler, correct design.

## Scope Reminder

Library surface only: `project/mcp/`, `project/agents/specialists/`, `project/commands/`, `project/deployment/`, `library/CLAUDE.md`. No working-squad changes.

---

## Tasks

### T1. Audit MCP file schemas (✅ COMPLETED 2026-04-26)

**Finding**: see "T1 Finding That Changed Scope" above. `dynamic-mcp.json` uses Claude API schema, not Claude Code. Recalibration done.

**Status**: complete.

---

### T2. Enable native tool deferring + archive obsolete config

**Deliverable**: Claude Code's `ENABLE_TOOL_SEARCH=auto` ships in the deployed `settings.json` template; the obsolete `dynamic-mcp.json` is archived and removed from `install.sh`'s deployment list.

**Changes**:
- `library/settings.json.template`: add `"env": {"ENABLE_TOOL_SEARCH": "auto"}` block (or merge with existing env if present). This is the actual lever that triggers threshold-based tool loading in Claude Code.
- Archive `project/mcp/dynamic-mcp.json` to `.archive/2026-04-26-pre-4f/` (it's based on the wrong schema and was never wired in usefully).
- Remove the dynamic-mcp.json deployment from `install.sh` (the `setup_mcp_configuration()` function around line 1276).
- The existing static `.mcp.json` curl-download stays — it's the correct server registry that Claude Code reads.
- Regenerate `install.sh.sha256`.

**What this does NOT touch**:
- The static `.mcp.json` server registry (curl from main) — already correct, Claude Code parses it natively.
- `.env.mcp.template` — separate concern (API keys).

**Acceptance**: Smoke test (same pattern as 4d): fresh install produces `.claude/settings.json` with `ENABLE_TOOL_SEARCH=auto`. `mcp/dynamic-mcp.json` is no longer deployed. Existing static `.mcp.json` deployment unchanged.

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

### T4. ~~Pre-loaded discovery vs deferred execution split~~

**REMOVED** during recalibration (2026-04-26). Per T1 finding, Claude Code does not accept per-tool defer_loading config in `.mcp.json` — that's a Claude API feature. Tool deferring is auto-managed natively when `ENABLE_TOOL_SEARCH=auto` is set (T2). No per-tool split to configure.

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

- [x] T1: Schema audit complete; finding documented (dynamic-mcp.json uses Claude API schema, not Claude Code)
- [ ] T2: `ENABLE_TOOL_SEARCH=auto` shipped in `library/settings.json.template`; `dynamic-mcp.json` archived; install.sh updated
- [ ] T3: All 7 MCP-using specialists have a Tool-Centric Workflow paragraph + search pattern
- [ ] ~~T4~~: REMOVED — Claude Code auto-manages, no per-tool config exists in `.mcp.json`
- [ ] T5: No `mcp-profile` residue in library; post-install README updated
- [ ] T6: Lean library/CLAUDE.md MCP section reflects native auto-deferring; <80 lines
- [ ] T7: Harness subset re-run; milestone-4f.md committed; M2 drops measurably
- [ ] T8: Sprint 4g detailed spec written and approved

---

## Risks & Watch-Items

- **Tool Search regex misses.** A specialist searches for `mcp__supabase` and Tool Search returns nothing because the regex pattern requires escaping. Mitigation: T3 includes specific working patterns in each specialist; T7 verifies they resolve on a fresh install.
- **`ENABLE_TOOL_SEARCH=auto` threshold not aggressive enough.** Claude Code's auto-defer threshold may not kick in until users have many MCP servers configured. Mitigation: T7 measures actual M2 reduction; if insufficient, the next sprint can revisit (e.g., set explicit threshold env var if Claude Code supports one).
- **MCP server availability.** Static `.mcp.json` references 7 servers (context7, firecrawl, playwright, supabase, github, railway, stripe). Not every user has API keys for all. Mitigation: missing-key servers fail gracefully at server start — they just don't appear in Tool Search results.
- **Specialist prompt churn.** T3 touches all 7 MCP-using specialists. Risk of breaking subtle MCP-related instructions. Mitigation: targeted edits, not bulk replace; review each specialist diff individually.

---

## Open Design Questions (resolved during review 2026-04-26)

- **Replace or merge `.mcp.json`?** Resolved (then mooted by T1 finding): originally chose side-by-side. Now: there's nothing to replace — the static `.mcp.json` is correct as-is. `dynamic-mcp.json` is archived.
- **Pre-loaded count per server?** Resolved (then mooted by T1 finding): originally chose strict 1-per-server. Now: per-tool config is a Claude API feature, not Claude Code. Native auto-deferring handles this.
- **Where does the Tool Search regex pattern catalogue live?** Resolved: coordinator.md's DYNAMIC MCP TOOL DISCOVERY section is canonical (already there); lean CLAUDE.md keeps the at-a-glance pattern table; `field-manual/mcp-integration.md` is the deeper reference.

---

## Notes for Execution

- T1 is the audit task — get the file inventory clear before any edits.
- T2 is the highest-risk task (affects every install). Smoke test is mandatory — same pattern as 4d's smoke test.
- T3 is the largest task by file count (7 specialists). Targeted edits only.
- T7 is mandatory — Sprint 4f's whole value is the M2 reduction; no measurement, no claim.
- Sprint 4f is the last *technical* sprint of v6.0. Sprints 4g and 4h are skills/routines and validation — neither touches the runtime context surface significantly.
