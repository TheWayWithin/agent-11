# Library Review: AGENT-11 v6.1.1

Review date: 2026-05-10. Reviewer: Claude (with Jamie). Reference framework: Addy Osmani, "Agent Skills" (https://addyosmani.com/blog/agent-skills/).

## Terminology note

The brief asked to review `library/`. That directory currently contains two files: `library/CLAUDE.md` (78 lines, deployed to user projects post-install) and `library/settings.json.template`. The actual skill content lives in `project/skills/` (7 deployable SaaS skills) and `.claude/skills/` (the same 7 plus `meta-dev/`). I have read all 8 SKILL.md files plus relevant agent prompts, the lean `library/CLAUDE.md`, the changelog, and Addy's article. The review below treats "library" as the skills + library/CLAUDE.md surface that gets deployed to users, plus the agent prompts that interact with skills at runtime. The internal `.claude/agents/` working squad and `.claude/commands/` are out of scope unless explicitly noted.

---

## 1. Library Inventory

### Skills (deployable, `project/skills/`)

| Skill | Purpose | Lines | Declared tokens | Specialist | Last modified |
|---|---|---|---|---|---|
| saas-auth | Email/password, OAuth, sessions, password reset | 644 | 3,800 | @developer | within v5/v6 |
| saas-payments | Stripe checkout, subscriptions, webhooks | 727 | 4,200 | @developer | within v5/v6 |
| saas-multitenancy | RLS, tenant context, org/team hierarchy | 312 | 4,100 | @architect | within v5/v6 |
| saas-billing | Plans, quotas, trials, upgrades, dunning | 370 | 3,900 | @developer | within v5/v6 |
| saas-email | Transactional email (Resend/Postmark) with queues | 374 | 3,200 | @developer | within v5/v6 |
| saas-onboarding | Multi-step wizards, activation tracking | 437 | 3,500 | @developer | within v5/v6 |
| saas-analytics | PostHog event tracking, key metrics | 472 | 3,600 | @analyst | within v5/v6 |
| meta-dev (internal) | Routes edits to library vs working squad | 90 | 1,200 | @developer | v6.0 (Sprint 4d) |

Total content: 3,426 lines across 8 files. Declared token weight (sum) is ~27,500 across the 7 deployable skills. The actual rendered token cost when one is loaded is broadly consistent with declarations, so the platform-side load decision is honest.

### Library CLAUDE.md

`library/CLAUDE.md` (78 lines). Functions as a router: points at the Karpathy constitution (`.claude/agents/coordinator.md`), the mission table (`.claude/commands/coord.md`), tracking files, foundation docs, the skills system, MCP tool deferring, hooks, security, plan-driven workflow. No anti-rationalization. No process content. It is correctly scoped as a session-start primer, not a reference essay.

### Coverage by SDLC phase

If we map to Addy's six phases (Define, Plan, Build, Verify, Review, Ship):

| Phase | Coverage in skills/ | Coverage elsewhere in AGENT-11 |
|---|---|---|
| Define | None | `@strategist` agent + `dev-alignment`, `mvp` missions + `/foundations` |
| Plan | None | `@strategist` + `/bootstrap` + `project-plan.md` discipline + `mission-architecture.md` |
| Build | All 7 SaaS skills (vertical, by domain) | `@developer` agent + `mission-build`, `mission-mvp` |
| Verify | None | `@tester` agent + Karpathy "verify by running" + quality gates (`project/gates/`) |
| Review | None | `@designer` design-review skill + `@security-review` (referenced) |
| Ship | None | `@operator` agent + `mission-deploy`, `mission-release` + Routines |

The 7 SaaS skills are a **vertical** library (by domain), not a **horizontal** one (by phase). They give an agent the patterns and code for a Stripe integration; they do not give it a workflow for *how to add Stripe to a system safely*. That work is done by agents and missions.

### Gaps

- **No skill enforces a process.** None of the seven SaaS skills check "did you write a failing test first" or "did you run the build before declaring done". All process discipline lives in Karpathy + agents.
- **No anti-rationalization tables anywhere as a routine pattern.** A grep for "anti-rationaliz", "excuses", "rebuttal" across `project/agents/`, `project/skills/`, `library/`, and `project/field-manual/` returned zero matches. Note: the developer and tester agents have *anti-hallucination* operating-discipline sections (`project/agents/specialists/developer.md`:19-31, `project/agents/specialists/tester.md`:18-31) that are anti-rationalization in spirit, but they target a different failure mode (write-without-reading) than Addy's process-shortcut excuses ("I'll write tests later").
- **No commit/PR-discipline content.** Nothing on conventional commits, PR sizing, granular history, or how to handle a stack of changes.
- **No scope-discipline meta-skill.** Karpathy principles 3 ("Prefer minimal diffs") and 5 ("Avoid speculative refactors") cover scope at a behavioural level, but no skill or agent enforces it as a checkpoint before edits.

### Overlaps

- `saas-payments` (Stripe API integration) and `saas-billing` (plan/quota/trial logic) overlap on subscription state. Both touch `subscriptionId`, `subscriptionStatus`, plan changes. The boundary is plausible (one is the payment provider integration, the other is the SaaS-side billing logic), but a developer reading both will get duplicated webhook code and proration logic. Boundary is fuzzy enough to confuse.
- `saas-analytics` and `saas-onboarding` both cover activation tracking. Onboarding has its own activation events (line 240+), analytics has its own event catalogue (line 146+). A skilled developer would unify these; the skills do not.

---

## 2. Quality Assessment per Skill

Scoring 1 (terrible) to 5 (excellent) on each of the five Addy principles. Scores reflect *fitness for the principle*, not overall skill quality.

| Skill | Process vs prose | Anti-rationalization | Verification | Progressive disclosure | Scope discipline | Total |
|---|---|---|---|---|---|---|
| saas-auth | 2 | 2 | 2 | 2 | 2 | 10/25 |
| saas-payments | 2 | 2 | 2 | 1 | 2 | 9/25 |
| saas-multitenancy | 2 | 3 | 2 | 4 | 3 | 14/25 |
| saas-billing | 2 | 3 | 2 | 4 | 3 | 14/25 |
| saas-email | 2 | 2 | 2 | 4 | 3 | 13/25 |
| saas-onboarding | 2 | 2 | 2 | 3 | 2 | 11/25 |
| saas-analytics | 2 | 3 | 2 | 3 | 3 | 13/25 |
| meta-dev | 4 | 4 | 4 | 5 | 5 | 22/25 |

### Why these scores

**Process vs prose (uniformly 2/5 for the SaaS skills).** Every SaaS skill follows the same template: Capability, Use Cases, Patterns (each pattern = brief "When to use" + code block), Stack-Specific Implementation, Quality Checklist, Anti-Patterns, References. There are no numbered steps, no checkpoints, no "STOP. Did you do X before continuing". They read like the SDK README of a vertical product, packaged for an agent. They tell an agent *what good looks like*, not *what to do step by step*. This is fine for what they are (reference packs), but they fail Addy's process-over-prose test. `meta-dev` is the exception: it is short, has a verification command (line 64: `grep -n "$(basename your-file)" project/deployment/scripts/install.sh`), and routes behaviour rather than teaching.

**Anti-rationalization (2-3/5 for the SaaS skills).** Each SaaS skill has an "Anti-Patterns" section. The format is "Why it's bad / Instead". Example from saas-payments:618-621: "Skipping Webhook Signature Verification. Why it's bad: Anyone can POST fake events to your webhook endpoint. Instead: Always call `stripe.webhooks.constructEvent()` with your webhook secret." This is *educational* (here's a pitfall and the right pattern), not *adversarial* (pre-empting an excuse the agent will use to skip the discipline). The Addy form would be "Excuse: 'webhooks are a niche edge case, I'll add signature verification later.' Rebuttal: there is no later. Without verification this endpoint is a public RPC into your database. Add the four lines now." Multitenancy's "Anti-Patterns" (line 280+) come closest to the Addy form because they pair a specific WRONG / RIGHT code example with the rationalization the developer would have used. saas-billing line 354+ does the same. Auth and payments do it least well.

**Verification (uniformly 2/5).** Every SaaS skill has a "Quality Checklist". These read as audit lists ("Passwords hashed with bcrypt", "Webhook signature verification implemented"). They are not exit criteria tied to evidence. There is no "before declaring this complete: paste the output of `npm test` showing the auth tests pass, paste the curl trace showing the webhook returns 200 on signed payloads". A coordinator cannot use a quality checklist as a phase gate; they can only use it as a self-report. This is a real weakness across all 7.

**Progressive disclosure (mixed).** AGENT-11 already has progressive disclosure at the platform level: skills are loaded by `description` field matching via the Skill tool, and `ENABLE_TOOL_SEARCH=auto` defers MCP tool loading until needed. So the platform-side architecture passes Addy's test. The per-skill score reflects whether each skill is the right *size* for on-demand loading. saas-payments (727 lines, ~7K+ tokens of actual content) and saas-auth (644 lines) are too big. When loaded they dominate the window. Multitenancy (312) and billing (370) are reasonable. Email (374) is reasonable. Onboarding (437) is borderline. Analytics (472) is borderline. The bloat in payments/auth is mostly stack-specific code (Next.js + Supabase, then Remix + Lucia). Splitting those into a `references/` subdirectory the agent can load if and only if the project uses that stack would cut the always-loaded part roughly in half.

**Scope discipline (2-3/5).** None of the SaaS skills enforce "touch only what you're asked to touch". Several encourage the opposite. saas-auth runs from registration through OAuth through password reset through rate limiting in one document; once loaded it gives the agent permission to touch all of them. A developer asked to "add password reset" would, given saas-auth, also see opinions on session expiry, rate limiting, OAuth, and feel licensed to refactor any of them. Multitenancy and billing are tighter, in part because they are shorter. The library agents (`project/agents/specialists/developer.md`, `project/agents/specialists/tester.md`) inherit Karpathy principle 5 ("Avoid speculative refactors") which does enforce scope; the skills themselves do not reinforce it.

### Worst offenders

1. **saas-payments (9/25).** Largest skill, weakest progressive disclosure, anti-pattern section is teaching-tone, no verification exit criteria. When loaded, dominates context with stack-specific code. Highest impact-per-line for a fix.
2. **saas-auth (10/25).** Same shape as payments. 644 lines, mostly Next.js + Remix code samples. Anti-pattern section is informational.
3. **saas-onboarding (11/25).** Reasonable length but conflates wizard mechanics, activation tracking, and tooltip patterns into one skill. Boundary with saas-analytics' activation tracking is fuzzy.

### Best in class

**meta-dev (22/25).** Should be the model for what a skill looks like in this framework. 90 lines. Concrete verification command. Decision tables. Anti-pattern catalogue framed as "anti-patterns to catch" with specific failure modes ("Editing `.claude/agents/coordinator.md` thinking you're improving the deployed coordinator → wrong file"). It is short, opinionated, and does work.

---

## 3. Architectural Fit

AGENT-11 is a coordination architecture. Addy's project is a workflow library a generic agent loads on demand. These are different shapes and the differences cut both ways.

### Where AGENT-11 makes Addy's recommendations redundant

**SDLC phase coverage by specialist.** Addy's slash commands (`/spec`, `/plan`, `/build`, `/test`, `/review`, `/ship`) map directly onto AGENT-11's existing structure:

| Addy slash command | AGENT-11 equivalent |
|---|---|
| `/spec` | `@strategist` + `dev-alignment` mission + `/foundations` for BOS-AI handoff |
| `/plan` | `@strategist` + `/bootstrap` + `project-plan.md` workflow |
| `/build` | `@developer` + `mission-build` / `mission-mvp` |
| `/test` | `@tester` + the verify-by-running Karpathy principle |
| `/review` | `@designer`'s `/design-review` + `/security-review` skill (already in user-invocable list) |
| `/ship` | `@operator` + `mission-deploy` / `mission-release` |

Adopting Addy's slash commands wholesale would create two routing systems that disagree on phase boundaries. Don't.

**Karpathy already covers most of "five non-negotiables".** I initially recommended adding the five non-negotiables to CLAUDE.md or the coordinator. Reading library/CLAUDE.md:6-13 against Addy's list, the overlap is large:

| Addy non-negotiable | Karpathy principle | Coverage |
|---|---|---|
| Surface assumptions before building | "State assumptions explicitly" | Direct |
| Stop and ask when requirements conflict | "When uncertain, present both interpretations briefly and choose one" | Partial. Karpathy says present and choose, Addy says stop and ask. Slight philosophical difference. |
| Push back when warranted | (none explicit) | **Genuine gap.** |
| Prefer boring obvious solutions | "Choose the lightest valid execution path" + "Prefer minimal diffs" | Direct |
| Touch only what you're asked to touch | "Prefer minimal diffs" + "Avoid speculative refactors" | Direct |

The genuine gap is "push back when warranted". Karpathy does not have it. The coordinator and several specialists implicitly do (the strategist's "Start with the problem, not the solution" is close), but no agent has explicit "if the user asks for something stupid, say so". This is worth adding, but as a single principle, not as five.

**Anti-hallucination is already addressed in the two highest-risk specialists.** `project/agents/specialists/developer.md`:19-31 and `project/agents/specialists/tester.md`:18-31 have explicit `OPERATING DISCIPLINE` ("READ FIRST, VERIFY BEFORE RETURNING") sections that pre-empt the most expensive failure modes (writing edits against imagined file contents, generating tests against imagined endpoints) and cite the specific v5.2 baseline failures that motivated them. This is anti-rationalization in spirit. It is targeted at the engineering failure mode (assume-don't-read), not the process-shortcut failure mode ("I'll write tests later"). Both matter. The first is already covered. The second is not.

### Where AGENT-11 has a genuine gap

**Anti-rationalization for process shortcuts.** Addy's strongest contribution is pre-written rebuttals to "this task is too simple to need a spec" / "I'll write tests later" / "tests pass, ship it" / "let me just clean this up while I'm here". None of these are addressed in AGENT-11. The developer's operating-discipline section addresses *don't-write-without-reading*; it does not address *don't-skip-tests-because-it-feels-fine*. The tester's operating-discipline section addresses *don't-test-against-imagined-code*; it does not address *don't-claim-pass-without-verifying-runtime*. These are the specific moments where agents (and tired engineers) cut corners. Adding short, specific anti-rationalization tables to the four most-used specialists (strategist, developer, tester, coordinator) is the highest-leverage change available.

**Skills as workflow vs skills as domain libraries.** AGENT-11 has chosen domain libraries (saas-auth, saas-payments, etc.). That is a defensible commercial choice; these are the skills that differentiate AGENT-11 for SaaS founders. Addy has chosen process libraries (TDD, code-review, scope-discipline, deprecation, git-workflow). The two are complementary, not exclusive. AGENT-11 *could* add 2-3 process skills (e.g., a `commit-discipline` skill, a `tdd-loop` skill, a `pr-sizing` skill) and it would not collide with the existing set. But: most of that content already lives in the agents and missions, and adding it as skills risks duplication. If this gets added, it should be as one or two minimal routing skills that point at agent-side content, not as essays.

**Verification exit criteria.** This is a structural gap across all 7 SaaS skills. "Quality Checklist" is not "Exit Criteria". Quality gates exist as a separate system (`project/gates/run-gates.py`) and the coordinator runs them at phase boundaries. Wiring each skill's checklist into a runnable gate would convert paper checklists into evidence. This is a sprint-sized change worth doing.

### Where skills should be agent-prompt additions, not standalone files

**Anti-rationalization tables.** These belong inside the agent that needs them: `project/agents/specialists/tester.md` gets the test-related rebuttals, `project/agents/specialists/developer.md` gets the scope-and-shortcut rebuttals, `project/agents/specialists/strategist.md` gets the spec-and-scoping rebuttals, `project/agents/specialists/coordinator.md` gets the phase-gate rebuttals. Putting them in standalone skills would mean they only fire when the skill loads, which is the wrong pattern; these need to be live in every session of the agent.

**Push-back-when-warranted.** Belongs in the coordinator's prompt and in each specialist as a one-line behavioural rule.

**Scope discipline reminders.** Belong as preamble in the library developer agent (`project/agents/specialists/developer.md`). Already partly there via Karpathy principle 5; could be sharpened to "before any edit, name the scope you were given and confirm your edit fits inside it".

---

## 4. Concrete Proposal

12 items, ordered by impact-to-effort ratio. Each is sprint-implementable. Numbers are independent. This is not a phased plan, it is a backlog.

### Top tier (do these first)

**1. Anti-rationalization tables in 4 specialists.**
- Rationale: Highest behavioural change per token spent. Pre-empts the specific shortcuts that ship bad code. Karpathy already covers behavioural fundamentals; this layer addresses process-shortcut excuses Karpathy does not name. Files: `project/agents/specialists/developer.md`, `project/agents/specialists/tester.md`, `project/agents/specialists/strategist.md`, `project/agents/specialists/coordinator.md`. Format: short table per agent (3-5 rows), placed near the top of the existing OPERATING DISCIPLINE or BEHAVIORAL GUIDELINES sections. Example for tester: "Excuse: tests pass, ship it. Rebuttal: passing tests are evidence, not proof. Did you check the runtime? Did you verify user-visible behaviour? Did a human read the diff?"
- Effort: S
- Impact: High
- Dependencies: None
- Risks: Tone collision with existing prose. Mitigate by matching the existing "OPERATING DISCIPLINE" tone in `project/agents/specialists/developer.md` / `project/agents/specialists/tester.md`, which already does this well.

**2. Repo-root hygiene pass.**
- Rationale: 12 CLAUDE.md backups (`CLAUDE.md.backup-20251008_213735` through `CLAUDE.md.backup-20260106_060812`), 8+ stale architecture docs from August 2025 (`AGENT-11.md`, `BOS-AI-AGENT-11-INTEGRATION-ARCHITECTURE.md`, `BOS-AI-Architecture-Analysis.md`, `BOS-AI-INTEGRATION-IMPLEMENTATION-PLAN.md`, `BOS-AI-INTEGRATION.md`, `INSTALLATION.md`, `DEPLOYMENT.md`, `INTEGRATION-GUIDE.md`, `INTEGRATION-STANDARDS.md`, `MCP-SYSTEM-IMPLEMENTATION-PLAN.md`, `AGENT-11 MCP System Specification (Documentation-Only).md`), plus dated sprint artefacts (`CRITICAL-UPDATE-2025-11-12.md`). These confuse fresh contributors and any tool that tries to summarise the repo. Move to `archive/` or delete. Confirm none are referenced by `install.sh`.
- Effort: S (one afternoon, careful grep first)
- Impact: Medium
- Dependencies: None
- Risks: Deleting something live. Run `grep -rn "filename" .` for each candidate before removal. Prefer move-to-archive over delete for the first pass.

**3. Convert SaaS skill "Quality Checklist" into "Exit Criteria" tied to evidence.**
- Rationale: Verification is the structural gap across all 7 SaaS skills. Current checklists are self-report audit lists; rewriting them as exit criteria with evidence requirements ("paste output of X", "screenshot of Y", "trace from runtime Z") makes them gateable. Where possible, wire to existing `project/gates/` infrastructure.
- Effort: M (per-skill rewrite, ~1-2 hours each = full sprint)
- Impact: High
- Dependencies: Decide whether to ship as skill-internal change or as a new gate config. Recommend skill-internal, with optional gate hookup as item 11.
- Risks: Coordinator mission flow assumes checklists. Test in the build mission first.

**4. Reframe "Anti-Patterns" sections from teaching-tone to excuse-rebuttal tone.**
- Rationale: Same content, sharper effect. Current form ("Why it's bad / Instead") teaches; Addy form ("Excuse / Rebuttal") pre-empts. Multitenancy:280+ already does the WRONG/RIGHT code split well; extend the headline framing to be the excuse the developer would use.
- Effort: S (~1 hour per skill)
- Impact: Medium
- Dependencies: None
- Risks: Voice consistency across 7 skills. Write one (saas-payments is the worst offender, fix it first), use as template.

### Middle tier

**5. Compress saas-payments and saas-auth.**
- Rationale: 727 + 644 lines is too much for on-demand loading. Most of the bloat is stack-specific code (Next.js + Supabase, then Remix + Lucia). Move stack-specific code into `project/skills/saas-payments/references/nextjs-supabase.md` and `references/remix-railway.md`. The main SKILL.md becomes provider-agnostic patterns + a pointer to the right reference for the project's stack. Anthropic's Agent Skills standard supports this resources/ pattern.
- Effort: M (~half day per skill)
- Impact: Medium-High (cuts loaded tokens roughly in half for the two largest skills)
- Dependencies: Confirm Skill tool can load resources/ files on demand. Likely yes.
- Risks: Existing references to specific line numbers or sections will break. Acceptable cost.

**6. Add a single "push back when warranted" line to library/CLAUDE.md and the coordinator.**
- Rationale: The one Addy non-negotiable Karpathy does not cover. One line in `library/CLAUDE.md` near the constitution block: "8. Push back when the ask conflicts with the constraints. Do not silently absorb contradictions." Mirror in `project/agents/specialists/coordinator.md`.
- Effort: S
- Impact: Medium
- Dependencies: None
- Risks: Minimal. Karpathy is presented as 7 principles; a constitutional amendment to 8 is a small but real signalling change. Frame as "Karpathy + 1" rather than rewriting the constitution.

**7. Audit field-manual/ for prose-vs-workflow.**
- Rationale: 30+ files in `project/field-manual/`. Some are workflows (`mission-execution-cheatsheet.md`, `file-operation-quickref.md`, `quality-gates-guide.md`). Some are essays (`architectural-principles.md`, `enhanced-prompting-guide.md`, `architecture-sop.md`, `extended-thinking-guide.md`). The essay-shaped ones either need conversion to checkpointed flow OR retirement-as-redundant. Inventory first, then decide.
- Effort: M (audit) → varies (conversion). Inventory is one afternoon.
- Impact: Medium (reduces context-window pollution and contributor confusion)
- Dependencies: None
- Risks: Some essay-shaped files may be load-bearing reference material. Keep what gets cited from agents/missions; demote what doesn't.

**8. Tighten saas-payments / saas-billing boundary.**
- Rationale: Both touch subscription state, plan changes, and webhook handling. A developer reading both gets duplicate proration code and webhook code. Either: (a) merge into one skill with a clear internal split, or (b) make saas-payments strictly the Stripe API integration layer and saas-billing strictly the SaaS-side plan/quota logic, with a one-paragraph "where each skill ends" preamble in both. (b) is less risky.
- Effort: S
- Impact: Low-Medium
- Dependencies: None
- Risks: Existing skill consumers depend on current content shape. Backwards-compatible to add boundary preamble.

### Lower tier (worth doing, less urgent)

**9. Add "When NOT to use this skill" sections.**
- Rationale: Each SaaS skill has a "Use Cases" section. None has a boundary statement. Adding one short "When NOT to use" section per skill prevents over-eager loading and adjacent-system creep. Example for saas-auth: "Do not use for SSO/SAML enterprise integration; that needs a dedicated skill. Do not use for OAuth-as-a-provider (you issuing tokens to third parties); different shape."
- Effort: S
- Impact: Low-Medium
- Dependencies: None
- Risks: None.

**10. Add a `commit-discipline` micro-skill OR a section in the library developer agent.**
- Rationale: Granular commits, conventional commit messages, PR sizing. None of this is in the current library or agents. Decide: as a 60-line skill (Addy-style), or as a new section in `project/agents/specialists/developer.md` (AGENT-11-style). Recommend the developer.md section, because commit discipline applies to every developer task and should not need to be loaded.
- Effort: S
- Impact: Medium
- Dependencies: None
- Risks: None.

**11. Wire SaaS skill Exit Criteria into project/gates/.**
- Rationale: If item 3 lands, gate templates can encode skill-specific exit checks. e.g., a `saas-payments` gate that fails the build phase if the test suite does not include a webhook signature verification test. Genuine teeth.
- Effort: M
- Impact: Medium-High
- Dependencies: Item 3 must land first.
- Risks: Coupling skills to gates means changing one breaks the other. Acceptable for v1; design with a clear interface.

**12. Document the v6.0 platform-side progressive disclosure decisions.**
- Rationale: AGENT-11 v6.0 already gets progressive disclosure right at the platform level (Skill tool description matching, `ENABLE_TOOL_SEARCH=auto`). This is invisible to readers of `library/CLAUDE.md`. A short note in field-manual or skills-guide.md explaining "AGENT-11 does not load all skills at session start; the Skill tool selects on demand based on description match" would prevent contributors from re-implementing it badly.
- Effort: S
- Impact: Low
- Dependencies: None
- Risks: None.

### What I'm consciously not proposing

- A `using-skills` router skill (Addy's `using-agent-skills`). Anthropic's Agent Skills standard already routes via `description`, so a router would duplicate the platform.
- Five-non-negotiables verbatim copy. Karpathy + one new principle covers the same ground.
- Wholesale adoption of Addy's 20 skills. Most are redundant with AGENT-11 missions and agents.
- A scope-discipline standalone skill. Belongs in `project/agents/specialists/developer.md` as one rule, not as a 60-line file.

---

## 5. What to Explicitly NOT Do

1. **Do not install Addy's marketplace plugin alongside AGENT-11.** Two routing systems. `/coord` and Addy's `/spec /plan /build /test /review /ship` would compete for the same intents. Pick one. AGENT-11 already has this layer.

2. **Do not copy Addy's 20 skills wholesale.** They are designed for a generic agent without specialists. AGENT-11's `/coord build`, `mission-build.md`, `@developer`, `@tester`, and `@operator` already encode the SDLC. Adopting Addy's skills creates four-way duplication: skill says one thing, mission says another, agent prompt says a third, coordinator says a fourth.

3. **Do not add `/spec`, `/plan`, `/build`, `/test`, `/review`, `/ship` slash commands.** These are mode-aliases for `/coord [mission]`. The mission table already covers them. Adding them creates two ways to do the same thing.

4. **Do not rewrite Karpathy as Addy's five non-negotiables.** Karpathy is the constitutional layer for AGENT-11 specialists. It is in flight, working, and aligned with how the coordinator delegates. Replacing it would invalidate every specialist prompt that cites it. Add the missing principle ("push back when warranted") as an amendment.

5. **Do not expand the skills library before consolidating field-manual.** field-manual/ has 30+ files of varying shape and quality. Adding more skills before auditing what is already there compounds the problem.

6. **Do not promote anti-rationalization tables to standalone skills.** They need to be in agent prompts, not in lazy-loaded files. The agent that should not skip tests is the one needing the rebuttal, every session, before any task.

7. **Do not delete any skill in the proposed pass.** All 7 SaaS skills serve a real commercial use case. The work is reshaping them, not pruning. Pruning is for `field-manual/` and the repo root, not the skills.

8. **Do not enforce verification exit criteria via blocking gates without warning users.** Item 3 + item 11 should ship as advisory first, then promote to blocking in a later release with an explicit notice. Hard-blocking on day one would break in-flight missions.

---

## 6. Resolutions

The 8 open questions are resolved here. Decisions reflect Jamie's preference for the strategic full-fix over tactical scopes.

**1. Scope: full library surface plus repo hygiene.** Sprint touches the deployable library (`project/skills/`, `project/agents/specialists/`, `project/commands/`, `project/missions/`, `project/field-manual/`, `library/CLAUDE.md`, `templates/`) and includes repo root cleanup. All 12 proposal items are in scope.

**2. test-projects/ status: t1-t5 are stale, install-fixtures is live.** `test-projects/install-fixtures/` is Sprint 5a T6 install-test infrastructure with `run-all.sh`; keep as-is. `test-projects/t1-greenfield-run/` through `t5-commit-review-run/` are baseline-v5.2 validation runs from 2026-04-19 (provenance: `project/validation/baseline-v5.2.md`). They are run output, not source. Decision: move them to `project/validation/baseline-runs/v5.2/` so they sit next to their provenance document. Add `test-projects/install-fixtures/run-output/` and similar transient paths to `.gitignore` going forward.

**3. CLAUDE.md backups: no in-repo source, delete and prevent recurrence.** A grep of `.claude/` and `project/` for any script that writes `CLAUDE.md.backup-*` returns zero matches. `project/deployment/scripts/backup-manager.sh` backs up `.claude/agents/`, not the root CLAUDE.md. Timestamps cluster around major manual edits, suggesting these were hand-saved or written by an external tool (possibly a Cowork / pre-edit hook outside this repo). Decision: delete all 13 root `CLAUDE.md.backup-*` files; git history is the canonical source. Add `CLAUDE.md.backup-*` to `.gitignore`. If they reappear, the source is external tooling and Jamie can fix at that layer.

**4. Field-manual audit: same sprint, dedicated phase.** Phase 3 of the sprint plan below carries it as a first-class block. Inventory all 30+ files; classify each as workflow / essay / pointer / dead. Convert workflows to checkpointed form, retire essays that duplicate agent or mission content, keep pointers slim.

**5. saas-payments / saas-billing: keep separate, tighten the boundary explicitly.**

  - `project/skills/saas-payments/` owns the **Stripe API surface**: checkout sessions, customer creation, webhook signature verification, raw subscription mutations, metered usage reporting. Patterns describe what we say to Stripe.
  - `project/skills/saas-billing/` owns **product-side billing logic**: plan definitions, feature gating, quota tracking, trial state machine, downgrade orchestration, dunning. Patterns describe what our product does given subscription state.
  - Boundary rule: webhook handlers live in payments; they receive Stripe events and call into billing's update functions. Plan-change orchestration lives in billing; it calls payments' Stripe API primitives. Both skills get a one-paragraph "Where this skill ends" preamble at the top stating this rule.
  - Removes the current overlap (both currently define `changePlan` and webhook state-sync code).

**6. Anti-rationalization anchor incidents: documented in baseline-v5.2.md.** Each agent-side rebuttal in proposal item 1 will cite a real incident from `project/validation/baseline-v5.2.md`. Anchors:

  | Agent | Excuse | Anchor incident |
  |---|---|---|
  | tester | "tests pass, ship it" | T1 tester "produced output referencing code/files that did not match reality"; coordinator caught 4 issues mid-task |
  | tester | "I'll test this against the spec, the code'll match" | T1 + T2 + T4 hallucination pattern: tests written against imagined endpoints |
  | developer | "I'll just clean this up while I'm here" | T4 refactor with 6+ minute ceremony overhead vs T3's 1:30 minimal-diff fix |
  | developer | "I know what the file says, I'll write the edit from memory" | T2 + T4 developer subagent "0 tool uses" returns and inaccurate `old_string` reconstructions |
  | strategist | "this task is too simple to need a spec" | T1's "scope creep, drizzle-kit bug, wrong test endpoints" caught mid-task because no upfront acceptance criteria pinned the scope |
  | coordinator | "I'll skip the tracking files, this one's small" | T5 coordinator skipped tracking machinery and the review was fine; T4 maintained all 4 files for a 6-min task. Inconsistency is the failure mode, not either choice. Rule: tracking ceremony scales with mission mode (already in v6.0). |

**7. Push-back principle wording: sharpened.** Final wording: "Push back when the ask conflicts with constraints, evidence, or earlier decisions. Do not silently absorb contradictions." Adds "evidence, or earlier decisions" to catch push-back-against-stale-instructions and push-back-against-asks-that-ignore-prior-findings, not only constraint conflicts. Lands as principle 8 in `library/CLAUDE.md`, mirrored at the top of `project/agents/specialists/coordinator.md`.

**8. Single comprehensive sprint, four phases.** All 12 items in one sprint with a phase structure (below) that bundles related work and sequences dependencies (anchor incidents must land before anti-rationalization tables; exit criteria must land before gate wiring). No phased delivery across multiple sprints; the items are too inter-dependent to split cleanly.

---

## 7. Sprint Plan

12 items, 4 phases, dependency-ordered. Each phase has a clear exit before the next begins. Phases are sequential, not parallel.

### Phase 1: Behavioural surface (items 1, 4, 6: anti-rationalization, principle, anchors)

Goal: every specialist and the framework constitution have explicit, anchored rebuttals to the shortcuts that ship bad code.

**Tasks:**
- Add principle 8 to `library/CLAUDE.md` Karpathy block: "Push back when the ask conflicts with constraints, evidence, or earlier decisions. Do not silently absorb contradictions."
- Mirror principle 8 at the top of `project/agents/specialists/coordinator.md`.
- Add anti-rationalization tables to `project/agents/specialists/developer.md`, `tester.md`, `strategist.md`, `coordinator.md`. Each table has 3-5 excuse / rebuttal rows, anchored to a specific baseline-v5.2 incident (per resolution 6 above). Format matches the existing OPERATING DISCIPLINE sections in developer.md:19-31 and tester.md:18-31.
- Reframe the "Anti-Patterns" sections in all 7 SaaS skills from teaching-tone ("Why it's bad / Instead") to excuse-rebuttal tone ("Excuse / Rebuttal"). Same content, sharper effect. saas-payments first as the worst offender; use as template for the other six.

**Phase 1 exit:** every library agent has an anti-rationalization table tied to a specific incident; principle 8 is in library/CLAUDE.md and coordinator.md; all 7 SaaS skills' Anti-Patterns sections are in excuse-rebuttal voice.

### Phase 2: Verification surface (items 3, 5, 8, 11: exit criteria, compression, boundary, gates)

Goal: every skill terminates in evidence, the two largest skills load lighter, and exit criteria are wired to the gate runner.

**Tasks:**
- For each of the 7 SaaS skills, replace "Quality Checklist" with "Exit Criteria". Each criterion ties to evidence: command to run, output to paste, file to verify. Where applicable, the criterion is gateable (item 11 below).
- Compress `project/skills/saas-payments/SKILL.md` (currently 727 lines) and `project/skills/saas-auth/SKILL.md` (644 lines) by moving stack-specific code blocks (Next.js + Supabase, Remix + Lucia, etc.) into `references/` subdirectories. Main SKILL.md keeps provider-agnostic patterns plus a pointer to the right reference for the project's stack.
- Tighten `saas-payments` / `saas-billing` boundary per resolution 5. Add "Where this skill ends" preamble to both. Remove the duplicate `changePlan` / webhook-state-sync code; canonicalise each function to the skill that owns it.
- Wire the new Exit Criteria into `project/gates/`. Add `saas-payments`, `saas-auth`, `saas-billing` gate templates that the `build` and `test` phases can run. Ship as **advisory** (`|| true`) for v6.2; promote to blocking in v6.3 with explicit release-note warning.

**Phase 2 exit:** all 7 SaaS skills have evidence-tied Exit Criteria; payments and auth main SKILL.md files are under 350 lines; saas-payments / saas-billing have non-overlapping content; gate runner can execute skill-derived gates as advisory.

### Phase 3: Library housekeeping (items 2, 7: repo root, field-manual)

Goal: contributors and tools opening the repo see a clean state. Field-manual content is workflow-shaped or retired.

**Tasks:**
- Repo root cleanup:
  - Delete 13 `CLAUDE.md.backup-*` files. Add `CLAUDE.md.backup-*` to `.gitignore`.
  - Move `test-projects/t1-greenfield-run/` through `t5-commit-review-run/` to `project/validation/baseline-runs/v5.2/`. Update `project/validation/baseline-v5.2.md` to reference the new location.
  - Move stale top-level architecture docs to `archive/`: `AGENT-11.md`, `AGENT-11 MCP System Specification (Documentation-Only).md`, `BOS-AI-AGENT-11-INTEGRATION-ARCHITECTURE.md`, `BOS-AI-Architecture-Analysis.md`, `BOS-AI-INTEGRATION-IMPLEMENTATION-PLAN.md`, `BOS-AI-INTEGRATION.md`, `MCP-SYSTEM-IMPLEMENTATION-PLAN.md`, `CLAUDE-MD-INTEGRATION-GUIDE.md`, `CLAUDE-MD-SAFETY.md`, `CRITICAL-UPDATE-2025-11-12.md`, `DEPLOYMENT-SAFETY-VERIFICATION.md`, `DEPLOYMENT.md`, `INSTALLATION.md`, `INTEGRATION-GUIDE.md`, `INTEGRATION-STANDARDS.md`, `MCP-INTEGRATION-SUMMARY.md`. For each, grep first to confirm not referenced by `install.sh`, README, or active docs before moving.
  - Verify `.mcp.json` symlink (`-> .mcp-profiles/fullstack.json`) is intact; the v6.0 changelog says profile system was retired but the symlink still exists. Remove symlink if `.mcp-profiles/` is gone.
- Field-manual audit:
  - Inventory all `project/field-manual/*.md` (currently 32 entries plus subdirs). Classify each: **workflow** (numbered steps with exit criteria), **essay** (prose reference), **pointer** (slim cross-link), **dead** (duplicates content already in agent or mission file).
  - Convert essays the framework cites into workflows. Retire essays that duplicate. Keep pointers slim.
  - Output: a `project/field-manual/AUDIT.md` summary mapping each file to its disposition + action taken.

**Phase 3 exit:** repo root has only canonical files (README, CLAUDE.md, CHANGELOG, LICENSE, install scripts entry points, current sprint specs); test-projects/ is one directory (install-fixtures) plus baseline-runs moved out; field-manual AUDIT.md exists with every file classified and acted on.

### Phase 4: Discipline + documentation (items 9, 10, 12)

Goal: small but real additions that catch shortcuts and document the platform-side wins v6.0 already shipped.

**Tasks:**
- Add "When NOT to use this skill" sections to all 7 SaaS skills. Short. Specific examples for each (e.g. saas-auth: "not for SSO/SAML enterprise; not for OAuth-as-provider").
- Add a `commit-discipline` section to `project/agents/specialists/developer.md`. Covers granular commits, conventional commit messages, PR sizing, never amending pushed commits without explicit ask, never `--no-verify` without explicit ask. Plus excuse/rebuttal pair: "this is one logical change, just one commit" / "this is three logical changes that landed together; split them".
- Add a "Progressive disclosure in AGENT-11" section to `project/field-manual/skills-guide.md` (or create if absent) documenting that AGENT-11 v6.0 already does progressive disclosure at the platform level via Skill tool description matching and `ENABLE_TOOL_SEARCH=auto`. Prevents future contributors from re-implementing it badly.

**Phase 4 exit:** each SaaS skill has a "When NOT to use" section; developer.md has a commit-discipline section with anchored rebuttals; skills-guide.md documents v6.0's platform-side progressive disclosure decisions.

### Sprint exit (all phases complete)

- 12 items landed against their phase exits.
- Diff stat: ~1500-2500 net lines added across agent prompts and skill files; ~3000-5000 net lines removed from repo root and field-manual.
- All Phase 1 anti-rationalization tables anchored to specific baseline-v5.2 incidents.
- All 7 SaaS skills evidence-tied; saas-payments / saas-billing non-overlapping; saas-payments and saas-auth under 350 lines main file.
- Repo root clean; baseline-runs relocated; field-manual audited.
- v6.2 release notes flag exit-criteria gates as advisory and announce v6.3 promotion to blocking.

### Sequencing notes

- Phase 1 can begin immediately (no dependencies).
- Phase 2 depends on Phase 1's principle 8 landing (so the constitution amendment is in place before exit criteria reference it). Exit-criteria rewrite (item 3) precedes gate wiring (item 11) within Phase 2.
- Phase 3 is independent of Phases 1-2 in terms of code, but should follow them so the cleaned tree reflects the new content. Field-manual audit in Phase 3 may surface essays that should have informed Phase 1 anti-rationalization; if so, fold findings back into Phase 1 outputs before sprint exit.
- Phase 4 depends on Phase 1 (commit-discipline rebuttals share format with Phase 1 tables) and Phase 2 (when-not-to-use sections sit alongside Exit Criteria).

---

End of review.
