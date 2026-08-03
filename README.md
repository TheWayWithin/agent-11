<div align="center">

# AGENT-11™

### The development squad I actually build with. Open to inspect, fork, and use.

[![Claude Code Compatible](https://img.shields.io/badge/Claude%20Code-Native-blue?style=for-the-badge)](https://claude.ai)
[![Agents](https://img.shields.io/badge/Agents-11%20Specialists-red?style=for-the-badge)](project/agents/specialists/)
[![Missions](https://img.shields.io/badge/Missions-18%20Workflows-purple?style=for-the-badge)](project/missions/)
[![Version](https://img.shields.io/badge/Version-v6.2.0-green?style=for-the-badge)](docs/RELEASE-HISTORY.md)
[![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)](LICENSE)

[![GitHub stars](https://img.shields.io/github/stars/TheWayWithin/agent-11?style=social)](https://github.com/TheWayWithin/agent-11/stargazers)
[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-Support-yellow?logo=buy-me-a-coffee&style=flat)](https://buymeacoffee.com/jamiewatters)

**Build to learn, not to sell. The code is open. If I recommend it, I'm using it.**

[Install](#install) · [First mission](#your-first-mission) · [What you get](#what-you-get) · [How it works](#how-it-works) · [Commands](#command-reference) · [Docs](#documentation)

</div>

---

## What is AGENT-11?

AGENT-11 deploys 11 specialist AI agents into your project and coordinates them through pre-built missions. Instead of prompting Claude Code task by task, you run `/coord build` and a coordinator plans the work, delegates it, checks the result against evidence, and keeps a project plan up to date across sessions.

It installs into an existing repo in one command and adds no runtime dependency: everything is markdown instructions, a settings file and a few shell scripts that Claude Code reads.

**Why it's open:** I build to learn, not to sell, and I give the code away. The value is the knowledge, the judgement and the trust, not the tool. If it is here, I am using it; if it broke, you will hear why. This is the squad behind my own builds (Trader-7 and the AI Search Mastery tools); the build story lives at [jamiewatters.work](https://jamiewatters.work).

**Honest positioning.** There are no benchmark numbers in this README because I do not have any I would stand behind. What I can tell you is what it does, how it is built, and where it breaks: see [Where it struggles](#where-it-struggles).

---

## Install

Requires [Claude Code](https://claude.ai/code) and a project directory with a git repo, a README, or a package file (`package.json`, `requirements.txt`, etc.).

```bash
cd /path/to/your/project

# Downloads, verifies its checksum, then installs
bash <(curl -fsSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/secure-install.sh)

# Restart Claude Code so it picks up the new agents
/exit
claude
```

Verify it landed:

```bash
ls .claude/agents/     # 11 specialists: analyst.md, architect.md, coordinator.md, ...
ls .claude/commands/   # 14 slash commands
ls missions/           # mission library, at the project root
```

Note the mission **files** are named `mission-build.md`, `mission-fix.md` and so on, but you invoke
them by the bare name: `/coord build`, `/coord fix`.

**The same command upgrades an existing installation.** Your own `/CLAUDE.md` at the repo root is never touched. AGENT-11 writes agents and commands into `.claude/`, and puts `missions/`, `templates/` and `field-manual/` at the project root; an existing `.claude/CLAUDE.md` is backed up before it is updated. [Two-file architecture →](CLAUDE-MD-INTEGRATION-GUIDE.md) · [Upgrade notes →](docs/UPGRADE.md)

---

## Your first mission

Pick the one that matches where you are.

**Existing codebase, want the squad to understand it:**

```
/coord dev-alignment
```

Reads the repo, writes `project-plan.md`, `architecture.md` and a context file so later missions start informed.

**New project, have an idea document:**

```
/coord dev-setup ideation.md
```

Scaffolds the project and produces a plan you can start building against.

**Just want to see it work:**

```bash
echo "The login button does nothing on mobile. Expected: submits the form." > bug.md
```
```
/coord fix bug.md
```

The shortest real mission. You will see the coordinator delegate, the developer change one thing,
and the tester verify with real command output before it is called done. `/coord` takes a mission
name and an optional input **file**; it will not infer a mission from free text, by design.

Missions write progress to `project-plan.md` as they go, so you can stop and resume. `/coord continue` picks up from the last passed phase gate.

---

## What you get

### 11 specialists

| Agent | What it is for |
|-------|----------------|
| `@coordinator` | Orchestrates missions, delegates, holds the phase gates. The one you talk to. |
| `@strategist` | Requirements, user stories, scope |
| `@architect` | System design, technology choices, API shape |
| `@developer` | Implementation |
| `@tester` | Test suites, edge cases, evidence-backed verdicts |
| `@designer` | UI/UX, design systems, accessibility |
| `@documenter` | READMEs, API docs, guides |
| `@operator` | Deployment, CI/CD, infrastructure |
| `@analyst` | Metrics, KPIs, data |
| `@marketer` | Positioning, launch, copy |
| `@support` | Bug triage, user feedback |

Call one directly with `@developer add rate limiting to the login route`, or let `/coord` route the work.

### 18 missions

**13 run with `/coord <mission> [input-file]`.** `/coord` validates the name against a fixed routing
table and stops on anything it does not recognise; it will not guess. Durations are each mission
file's own estimate, not a measurement.

| Mission | Does | Typical |
|---------|------|---------|
| `dev-setup` | Greenfield project initialisation | 30-45 min |
| `dev-alignment` | Understand an existing codebase | 45-60 min |
| `build` | New feature, end to end | 4-8 hrs |
| `fix` | Bug resolution | 10-30 min scoped, up to 3 hrs |
| `refactor` | Code quality, no behaviour change | 15 min targeted, up to 4 hrs |
| `mvp` | Minimum viable product | 1-3 days |
| `deploy` | Production deployment | 1-2 hrs |
| `document` | Documentation | 2-4 hrs |
| `migrate` | System or platform migration | 4-8 hrs |
| `optimize` | Metric-driven ratchet optimisation | 2-6 hrs |
| `security` | Security audit and remediation | 4-6 hrs |
| `integrate` | Third-party integration | 3-6 hrs |
| `release` | Version release management | 2-4 hrs |

**Five more ship but are not on the `/coord` routing table yet.** They install, and you can run them
by opening the mission file and following it, or by handing it to the coordinator directly
(`@coordinator run the mission in missions/mission-architecture.md`). `operation-recon` also has its
own command, `/recon`. This gap is tracked as **A11-ISS-17**; it is stated here rather than papered
over, because `/coord architecture` currently returns an error rather than running anything.

| Mission | Does | How to run |
|---------|------|-----------|
| `connect-mcp` | Discover and connect MCP servers | mission file |
| `architecture` | Architecture documentation | mission file |
| `product-description` | Product definition with risk register | mission file |
| `operation-genesis` | Full feature, concept to production | mission file |
| `operation-recon` | UI/UX reconnaissance | `/recon` |

[Full mission library →](project/missions/)

### 8 skills

Opinionated implementations Claude loads on demand: `saas-auth`, `saas-billing`, `saas-payments`, `saas-email`, `saas-analytics`, `saas-onboarding`, `saas-multitenancy`, plus [`code-review-loop`](project/skills/code-review-loop/SKILL.md), where a read-only critic scores a diff, a read-write fixer addresses only what was raised, and the critic re-audits until two clean rounds or a cap.

Browse and install the seven SaaS skills with `/skills`. `code-review-loop` installs with AGENT-11 and is not in that catalogue; read its SKILL.md and invoke it directly.

---

## How it works

**The coordinator is the loop.** `/coord` starts a mission; `/coord continue` resumes it. It reads `project-plan.md` for state, delegates one task at a time to a specialist, and refuses to advance past a phase gate until that phase's criteria pass on evidence. It converges on two clean verification rounds rather than counting to a fixed number, and escalates to you when a phase burns its error budget.

**State lives in files, not in the conversation.** `project-plan.md` (what is done, what is next), `progress.md` (a changelog), and per-phase context files. That is what lets a mission survive a restart, and what lets you read what happened without scrolling a transcript.

**Verification is default-fail.** Every success criterion starts `false` and flips to `true` only when a command run block with real output is attached. "The code looks correct" is recorded as a guess, and a guess counts as a failure. This is the single behaviour that most changes the quality of what you get back.

**The thing that judges the work is read-only to the thing doing it.** Be precise about what that buys you, because the gap is where reward-hacking happens:

| What | Enforced? | By what |
|------|-----------|---------|
| `.quality-gates.json` anywhere in the tree | **Yes** | Two of the four `permissions.deny` rules, plus the PreToolUse Bash hook |
| `gates/` and `.gates/` **at the repo root** | **Yes** | The other two rules, plus the same hook |
| A `gates/` directory **nested** deeper, e.g. `packages/api/gates/` | **No** | `Edit(gates/**)` is root-anchored. Add a rule for it if you have one |
| A test elsewhere that serves as acceptance criteria | **No** | Nothing. Agents are instructed not to edit it and generally comply; nothing refuses them |
| A benchmark or metric command that defines "better" | **No** | Nothing, unless you add an `Edit(path)` rule for it yourself |

The rules use the `Edit(path)` form, which Claude Code applies to Edit, Write, MultiEdit and
NotebookEdit alike. `Write()` and `MultiEdit()` rule forms are silently ignored, so do not write them.

The Bash hook is a speed bump, not a boundary: it catches redirection, `tee`, `sed -i`, `cp`, `mv`, `rm`, `truncate`, `shred`, `unlink`, `dd of=`, `ln -s` and in-place `perl`/`ruby` edits, but a write through an interpreter or a path held in a variable passes through, and no shell hook can catch those. The enforceable guarantee is the deny rules.

[Quality gates guide →](project/field-manual/quality-gates-guide.md) · [Loop discipline guide →](project/field-manual/loop-discipline-guide.md)

**Orientation is a stated rule, not a habit.** Every specialist and mission carries the same instruction: Glob/Grep to locate before you Read, read only the lines you need, never read a whole file to find one symbol, do not re-read what you have already read. Finding what to change is the expensive step on a large repo, and this is the cheapest lever on what a session costs you.

---

## Command reference

| Command | Does |
|---------|------|
| `/coord [mission] [file]` | Run a mission. `/coord continue` resumes; `/coord` alone lists missions |
| `/meeting @agent [topic]` | Conversational session with one specialist, no mission structure |
| `/plan` | Show or update project state |
| `/report [since]` | Progress report for a date range |
| `/skills` | Discover and install SaaS skills |
| `/foundations` | Process BOS-AI foundation documents into structured YAML |
| `/architect` | System design session |
| `/bootstrap` | Turn foundation documents into `project-plan.md` |
| `/design-review` | UI/UX review of pending branch changes |
| `/recon` | UI/UX reconnaissance sweep |
| `/pmd` | Post-mortem: analyse a failure, propose process fixes |
| `/dailyreport` | Daily progress report plus draft social posts |
| `/blog` | Draft a blog post from repo context |
| `/planarchive` | Archive completed work out of `project-plan.md` |

---

## Is AGENT-11 right for you?

**A good fit if you** work solo or in a very small team, build with Claude Code already, want structure and an audit trail rather than one-off prompting, and are willing to read a plan file.

**Not the right tool if you** want a no-code builder, need a hosted service (this is files in your repo, nothing runs on my machines), work in a large team with an established process this would fight, or want an agent that ships unattended without you reading anything.

### Where it struggles

- **Large codebases.** Whole-repo analysis on a big project will exhaust context. Scope missions to a directory or a named surface.
- **Long autonomous runs.** Missions are designed to be watched, especially the first run in a new repo. Nothing auto-merges.
- **Judgement calls.** The coordinator escalates rather than guessing, which means it will stop and wait for you more often than a fully autonomous tool would. That is deliberate.
- **The read-only gates do not cover everything**, as the table above sets out. If a particular test or benchmark matters, add a deny rule for it.
- **MCP servers are optional and unmanaged.** If you connect them, credentials are yours to handle.

---

## Upgrading

Re-run the install command from any project root. It merges settings rather than overwriting: your own keys win on conflict, hooks you wrote or edited are preserved, and only hook entries byte-identical to a version AGENT-11 shipped are updated.

Managing several repos? The bulk-ops toolkit under `project/deployment/bulk/` applies an upgrade across a fleet in one pass.

[Upgrade guide →](docs/UPGRADE.md) · [Release history →](docs/RELEASE-HISTORY.md) · [Changelog →](CHANGELOG.md)

---

## Documentation

**Start here:** [Quick start](QUICK-START.md) · [Installation](INSTALLATION.md) · [Troubleshooting](TROUBLESHOOTING.md)

**Working with it:** [Mission library](project/missions/) · [Agent roster](project/agents/specialists/) · [Field manual](project/field-manual/) · [MCP integration](project/field-manual/mcp-integration.md)

**Design and discipline:** [Quality gates](project/field-manual/quality-gates-guide.md) · [Loop discipline](project/field-manual/loop-discipline-guide.md) · [CLAUDE.md architecture](CLAUDE-MD-INTEGRATION-GUIDE.md)

**Using it with BOS-AI:** AGENT-11 is the technical execution arm of the BOS-AI ecosystem: BOS-AI plans the business, AGENT-11 builds the software. It works standalone. [Handoff guide →](project/field-manual/bos-ai-handoff.md)

---

## Contributing and support

Issues and pull requests are welcome. The library is curated rather than open-by-default: if you want to add an agent or a mission, open an issue describing it and why it belongs before writing the PR, so the design gets discussed first.

If AGENT-11 has been useful, [starring the repo](https://github.com/TheWayWithin/agent-11) helps other people find it, and [a coffee](https://buymeacoffee.com/jamiewatters) is always welcome.

## License

MIT. See [LICENSE](LICENSE).

---

<div align="center">

**Built by [Jamie Watters](https://jamiewatters.work). Used daily on real products.**

</div>
