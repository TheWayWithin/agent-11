# Brief: agent-11.com updates after the Sprint 6 ship

**Written**: 2026-08-03, from the agent-11 repo, for a session in `~/DevProjects/agent-11-website`.
**Why now**: agent-11 `main` moved 22 commits today. The site states several things the product now
contradicts, and one of them is the exact overclaim the product spent today removing.
**Status**: nothing has been changed on the site. This is the work list.

**Ground truth** is `~/DevProjects/agent-11/` on `main`, verified 2026-08-03: 11 specialists,
**18 runnable missions** (20 files land in `missions/` but `README.md` and `library.md` are
catalogues, not runnable), 14 slash commands, 8 skills (7 SaaS + `code-review-loop`), 31 field-manual
guides, 4 `permissions.deny` rules.

> One correction to note before starting: an earlier draft of this brief suggested using "20
> missions" to match the old README. Use **18**. The repo README was rewritten today and now says 18
> runnable missions, which is the honest number: you cannot `/coord library`.

---

## A. Factual errors, highest severity first

### A1. The deny-rule code sample on the site would not work if copied (HIGH)

`src/components/sections/TechnicalConfidence.tsx:135-145` shows `Edit(.quality-gates.json)`,
`Write(.quality-gates.json)`, `Edit(gates/**)`, `Write(gates/**)`.

The product ships **no `Write()` forms at all**. A11-ISS-7 established that Claude Code ignores
`Write()` and `MultiEdit()` rule forms with a session-start warning; only `Edit(path)` is honoured,
and it covers every file-editing tool. Publishing a config with `Write()` rules teaches readers a
setting that silently does nothing.

Replace with the four literal rules from `library/settings.json.template`:

```json
"deny": [
  "Edit(.quality-gates.json)",
  "Edit(**/*.quality-gates.json)",
  "Edit(gates/**)",
  "Edit(.gates/**)"
]
```

### A2. "Agents cannot game their own tests" (HIGH, five places)

`components/sections/Hero.tsx:21`, `app/features/page.tsx:351`, `app/features/page.tsx:377`
("No agent can rewrite its own success criteria"), `app/pricing/page.tsx:97`,
`app/portfolio/page.tsx:31`.

This is the claim the product removed from eleven places today. The four rules cover
`.quality-gates.json`, `**/*.quality-gates.json`, `gates/**` and `.gates/**`. An acceptance-criteria
test living anywhere else, a benchmark, or a metric command is covered by **no rule**: agents are
instructed not to touch it and generally comply, but nothing refuses them.

Suggested replacement: **"Agents cannot edit the gate files that judge them."** Then, where there is
room for a second line: "Gate files are unwritable at the tool layer. Anything outside them is
instruction, not enforcement."

### A3. "The files that judge an agent's work are off limits to the agent" (HIGH)

`app/features/page.tsx:364`. Same defect, worth its own line because "the files that judge an agent's
work" is broader than the gate files and reads as a total guarantee.

Suggested: "The gate files, `.quality-gates.json` and `gates/`, are off limits at the tool layer. A
test elsewhere that acts as acceptance criteria is not covered by any shipped rule."

### A4. The site frames the Bash guard as a backstop that it is not (HIGH)

Two places credit the guard with a completeness it does not have: `app/features/page.tsx:373`
("A Bash-write guard hook backs up the permission block") and
`components/sections/TechnicalConfidence.tsx:124`.

The guard's own header now says the opposite: it is a speed bump, not a security boundary, and it
does not close the Bash route. It carries 12 detection branches (redirection, `tee`, `sed -i`, `cp`, `mv`,
`rm`, `truncate`, `shred`, `unlink`, `dd of=`, `ln -s`, in-place `perl`/`ruby`), but an
interpreter-mediated write (`python3 -c "open(path,'w')"`) or a path held in a variable passes
straight through, and no shell hook can catch those.

Suggested: "A Bash guard hook blocks the common Bash write forms against gate paths. It narrows the Bash
route rather than closing it: the enforceable guarantee is the `Edit()` deny rules."

### A5. "13 missions" is wrong site-wide (HIGH)

`Hero.tsx:39`; `app/features/page.tsx:238` plus the 13-item `missions` array at `:21-178`;
`app/features/layout.tsx:7`; `app/documentation/layout.tsx:7`; `app/documentation/page.tsx:56`;
`app/pricing/page.tsx:94`; `app/pricing/layout.tsx:7`; `components/sections/SocialProof.tsx:35,37,38,75`;
`components/sections/GetStarted.tsx:15`; `components/sections/GetStartedGuide.tsx:431,486`;
`app/changelog/page.tsx:106`.

Use **18**. The missions array is missing five runnable missions: CONNECT-MCP, OPERATION-RECON,
OPERATION-GENESIS, ARCHITECTURE, PRODUCT-DESCRIPTION. (Do not add cards for `library.md` or
`README.md`: they are the catalogue, not missions.) CONNECT-MCP and OPERATION-RECON are worth a
mention in the changelog entry too, because until today they existed in the library but were never
deployed to anyone.

### A6. "6 slash commands" (MEDIUM)

`app/pricing/page.tsx:95` and the `app/features/page.tsx` heading "6 Slash Commands for Workflow
Automation". There are **14**: `/coord`, `/meeting`, `/design-review`, `/recon`, `/report`, `/pmd`,
`/dailyreport`, `/blog`, `/planarchive`, `/foundations`, `/bootstrap`, `/plan`, `/skills`,
`/architect`.

### A7. "32 Field Guides" (MEDIUM)

`Hero.tsx:70`, `app/pricing/page.tsx:100`, `components/sections/CaseStudy.tsx:77`. There are **31**.

---

## B. Stale but not false

### B1. The changelog page stops at v6.2.0 (HIGH)

`src/app/changelog/page.tsx:33` is the newest entry. Today's `[Unreleased]` section is missing
entirely. Add a block covering: map-first orientation across all 11 specialists and 18 missions;
`connect-mcp` and `operation-recon` finally deploying; the Bash guard widened from 5 to 12 forms;
`code-review-loop` defaulting critic and fixer to different models; three validation scripts; and
the enforcement claims scoped to what the rules actually cover.

Source text is in `agent-11/CHANGELOG.md` under `## [Unreleased]`.

### B2. The `code-review-loop` card omits the model split (MEDIUM)

`app/features/page.tsx:433-448`. Add: "Critic and fixer default to different models. A critic
sharing the generator's weights returns agreement rather than verification."

### B3. Map-first orientation appears nowhere on the site (MEDIUM)

Nothing in `src/` mentions it. It is the headline item of today's release and the clearest
cost story the product has: finding what to change is the expensive step on a large repo, and every
specialist and mission now carries the same stated rule about it. Worth a card in the features loop
section.

### B4. No upgrade path surfaced for existing users (LOW)

`app/documentation/page.tsx` install section says how to install, not how to upgrade. Existing users
need to re-run the same command to pick up the two missions that never deployed. One line.

---

## C. Unsourced numbers still on the site

A previous pass stripped fabricated stats and a fake testimonial, and none have crept back. These
four survived it and have no artefact behind them.

| Where | Claim | Problem | Suggested |
|-------|-------|---------|-----------|
| `Hero.tsx:66` | "26 Templates" | `project/templates/` has 4; `templates/` has 31; install deploys 6. No source for 26 | "6 templates deployed", or drop the tile |
| `Hero.tsx:52` | "1,370+ Line Field Manual" | Actual field-manual total is 13,759 lines; the old README said 3,750+. Three numbers, none matching | "31-guide field manual", no line count |
| `Hero.tsx:81` | "100% Schema Validation" | Nothing backs a 100% figure | Drop the tile |
| `app/documentation/page.tsx:46` | "47 tests passed" in a simulated terminal | Fabricated specific | "All tests passed, security validated" |
| `Hero.tsx:74`, `SocialProof.tsx:77` | "<1s Deploy Time" | Not measured anywhere | "One command" |

The same rule the product now applies to itself applies here: if a number cannot be traced to
something in the repo, it does not ship.

---

## D. Broken or dead

None found. No `/discord` or `/blog` references survive, every internal `href` resolves,
`secure-install.sh` and `WORKFLOWS.md` both exist on `main`, and the sitemap lists only real routes.

---

## Already correct: do not churn these

- 11 specialists everywhere, and the "coordinator included" note at `app/pricing/page.tsx:88-93`.
- "7 SaaS skills shipped: auth, payments, multitenancy, billing, email, onboarding, analytics"
  (`app/features/page.tsx:692`). Exact. Note `code-review-loop` is an eighth skill but not a SaaS one,
  so the sentence is right as written.
- The install command string in all 8 places matches `secure-install.sh`.
- `FRAMEWORK_VERSION = '6.2.0'` and `FRAMEWORK_RELEASED = '2026-06-20'` in `lib/seo.ts:29-30`, and
  everything derived from them. Today's work is unreleased, so the version does not move yet.
- `ProofOfSpeed.tsx:106` honest-speed framing and `SocialProof.tsx:11-50`.
- `CaseStudy.tsx:285`, which warns against unsourced numbers, and the qualitative metrics table.
- The security tab's honesty about Anthropic processing (`TechnicalConfidence.tsx:129-133`).

---

## Suggested order of work

1. **A1 to A4 first.** They are the same defect class the product spent today removing, and A1 is
   actively misleading anyone who copies it.
2. **A5 to A7**, the counts, which are mechanical.
3. **B1**, the changelog, so the site reflects what shipped.
4. **C**, the unsourced tiles.
5. **B2 to B4**, the additions.

Nothing here requires a version bump: today's work is in `[Unreleased]`, so `FRAMEWORK_VERSION`
stays at 6.2.0 until a release is cut.
