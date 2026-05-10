---
date: 2026-05-09
slug: agent-11-v6-platform-catch-up
title: Half of agent-11 was scaffolding the platform now provides
image: /images/blog/2026-05-09-agent-11-v6-platform-catch-up.jpg
tags: [AgentEngineering, ClaudeCode, BuildInPublic, AgentFramework, PromptEngineering]
---

# Half of agent-11 was scaffolding the platform now provides

I shipped v6 of agent-11 last month. The biggest single change was deletion. The deployed `CLAUDE.md` went from roughly 250 lines to under 80. The MCP profile system, six hand-rolled JSON files and three custom commands, got binned in favour of one config flag. The `handoff-notes.md` workflow I built two sprints earlier got folded into a single accumulator file. The active context shrank from five files to three.

This was not regret. It was platform catch-up.

When I started agent-11, Claude Code didn't have hooks. It didn't have first-class subagents. It didn't have Tool Search with `defer_loading`. To run a real engineering squad you had to build that scaffolding yourself: prompt-engineered quality gates, prompt-engineered context loading, prompt-engineered profile switching. Every line of that scaffolding cost context budget on every call. By the time v5.2 shipped I was paying tens of thousands of tokens per session for ceremony that did less work, less reliably, than three native primitives that didn't exist when I started.

The lesson generalises. If you've built an agent framework in the last eighteen months, a custom orchestration layer, a pile of prompt templates, a way of routing tasks to specialised agents, there is a strong chance some of it is now technical debt. Not because you did anything wrong. Because the platform underneath you grew up.

Here is what to look for.

## Things worth deleting first

Inference-based dispatch. v5's `/coord` read your free-text intent and inferred which mission to run. v6 replaced it with `/coord build`, `/coord fix`, `/coord mvp`. Explicit mission names. Deterministic routing. The NLP version sometimes routed correctly; the keyword version always does. Reliability beats cleverness when the cost of being wrong is a wasted ten-minute mission run.

Prompt-based quality gates. "Always run tests before claiming done." "Always update progress.md." If you've written sentences like that into your system prompt, they're hooks now. Move them. A `PostToolUse` hook that runs `pnpm test` is enforced. A sentence in the prompt is a suggestion the model often ignores under load.

Static MCP tool loading. Shipping a hundred MCP tools into every session is how you burn 30% of the context window before the model has read a single user message. Tool Search plus `defer_loading` lets you deliver a regex of tools the agent can pull on demand. The saving on a typical session is roughly 80% context reduction on MCP-heavy work. That budget goes back to the user's actual problem.

Multi-file context choreography. v5 had five mandatory context files. Most of the value lived in two of them. The other three were ceremony, kept because deleting them felt risky. v6 has three: `project-plan.md`, `agent-context.md`, `evidence-repository.md`. The missions still work fine. If a file isn't being read by anyone, it isn't context. It's tax.

## The discipline that replaces the ceremony

The other half of v6 isn't deletion. It's a different kind of agent posture, lifted from Andrej Karpathy's writing on how to actually work with these things.

Most agent frameworks have an eagerness problem. The agent reads the task, picks the first plausible interpretation, starts doing the thing. By the time you notice, three files have been edited and a wrong assumption is baked into the diff. Adding more "always check X before Y" rules doesn't fix this. The model treats those as suggestions and does the action anyway when the prompt is long enough.

The Karpathy constitution in v6 changes posture instead of adding guardrails:

- PAUSE-AND-PLAN before any non-trivial change. State the plan. Wait for confirmation.
- State assumptions out loud rather than silently picking one.
- Prefer minimal diffs. The cleanest fix is the smallest one that closes the issue.
- Refuse to roleplay completion. If something didn't work, say so and stop.

That fits in eighty lines of `CLAUDE.md`. It replaced about a hundred and fifty lines of "always X / never Y" rules from v5. The agents move slower at the start of a task and faster overall, because they're not undoing the wrong thing twice.

If you take one thing from v6, take this. Behavioural defaults beat behavioural rules. Move your framework from "always do X" sentences to a posture that runs by default, and most of the rules become redundant.

## What's left after the deletion

Two other things stay.

Domain-specific skills the platform's defaults don't ship with. For me that's seven SaaS skills (auth, billing, multitenancy, payments, onboarding, analytics, email) and the BOS-AI pipeline for going from foundation docs to a buildable spec.

Migration mechanics for the framework itself. People treat agent frameworks like prompt templates and discover, painfully, that they're closer to infrastructure. I learned this the hard way during v5 to v6. I shipped the new framework first and only realised three weeks later that no v5 user could upgrade without manually moving files. v6.1 added a single command (`bash install.sh --upgrade`) that does the migration, backs everything up, and rolls back on failure. If your framework has more than three users, you owe them this.

## What this looks like in practice

If you're maintaining an agent framework right now, here is a thirty-minute exercise.

Open your system prompt. Find every sentence that starts with "Always" or "Never." For each one, ask: is this enforceable as a hook? If yes, move it. The prompt gets shorter and the rule gets stronger.

Then count the files you ask the agent to read at the start of every session. If the number is over three, you are choreographing for choreography's sake. Drop one and see what breaks. Probably nothing.

Then look at your tool list. If the agent has more than fifty tools loaded by default, you have a context economy problem. The fix is `defer_loading` plus a tool-search regex, not pruning the list down to ten and missing the long tail.

You will probably find, as I did, that you cut more than you expected. The first instinct is that everything is load-bearing. The second instinct, after deletion, is to wonder why you were carrying half of it.

The platform under you is going to keep growing. That is the bet you implicitly took when you started building on it. Treat each major Claude Code release as an invitation to delete. Not because the old work was wrong. Because the floor moved.

The good news is that the parts the platform won't take from you (the opinions, the discipline, the domain knowledge) are also the parts that were never about scaffolding in the first place.

Those are the bits worth pouring effort into.

## If you want to try it (or steal from it)

The framework is open source: [github.com/TheWayWithin/agent-11](https://github.com/TheWayWithin/agent-11).

Fresh install in any Claude Code project:

```
bash <(curl -sSL https://raw.githubusercontent.com/TheWayWithin/agent-11/main/project/deployment/scripts/install.sh)
```

If you're already on v5.x, the same command with `--upgrade` appended does the migration. Settings.json gets merged surgically (your values win), backups land in `.claude/backups/`, and there's a one-command rollback if anything goes sideways.

The Karpathy constitution lives in `project/constitution/karpathy-constitution.md`. The mission system is in `project/missions/`. The skills tier is in `project/skills/`. If you only want the postures and not the framework, lift those three directories straight out of the repo.

Borrow whatever's useful. Leave the rest.

If the post saved you an afternoon, [a coffee](https://buymeacoffee.com/jamiewatters) is appreciated but not required.
