---
date: 2026-06-20
slug: loops-hype-vs-real-engineering
title: "Everyone's selling autonomous AI agents. I built one, and the real lesson was 20 years old."
tags: [AI, SoftwareEngineering, BuildInPublic, AgenticAI, Verification]
image: /images/blog/2026-06-20-loops-hype-vs-real-engineering.webp
imageAlt: "A craftsman's workbench with hand tools and wood shavings beside a brass measuring gauge sealed under a glass dome with a wax seal"
---

An AI agent spent an afternoon optimising one of my apps. It tried a change, measured it, kept the one that was genuinely faster, reverted three that weren't, and logged every attempt. Textbook agentic loop. It worked exactly as promised.

It saved about eight kilobytes.

That gap, between the loop running perfectly and the loop achieving almost nothing, is the most useful thing I learned this month.

For a while now the talk has been agentic loops and "autoresearch": point an AI at a problem, let it run for hours, watch it improve its own work. Karpathy's version did the rounds. The unspoken bit, as always, is that if you're not running autonomous loops you're already behind. I wanted to know how much of that was real, so I built it into AGENT-11, my open-source squad of Claude Code agents, and shipped it as v6.2.0.

Here is what building it actually taught me.

The loop is the easy part. A try-measure-keep-or-revert loop is a weekend of work. What it taught me is that a loop chases exactly the number you give it, and nothing else. I gave mine "total JavaScript size" when what I actually wanted was "how fast the page loads". It lazy-loaded a charting library, which barely moved total size but genuinely sped up the load. The loop did its job. I'd picked the wrong number. The agent wasn't cheating. It was being diligent about the wrong thing, because that was the thing I told it to chase.

So a loop is only worth anything if you can trust the thing that judges it. This is where it stops being about AI and starts being engineering you'd recognise from twenty years ago. If an agent can edit the test that grades its work, it will eventually pass by editing the test instead of doing the work. Not out of malice. Because that path is cheaper, and the loop rewards cheap paths. The fix is separation of duties. I made the quality gates physically unwritable by the agents. The thing that judges the work cannot be touched by the thing doing it. Auditors have applied that rule to money for centuries. Turns out money and AI agents need the same rule.

"Done" has to mean evidence, not opinion. Every check now starts as a failure and only flips to pass when there is real command output behind it. An agent saying "the code looks correct" counts as a fail. That single change caught more nonsense than anything clever I added.

And the unglamorous stuff is what actually decides whether you can loop at all. Before any of the clever work paid off, I hit a benchmark that didn't run and a worktree that broke because of the build tool. You cannot loop on a number you cannot measure. Up close, the frontier is mostly plumbing.

Here is the part that matters more than any feature I shipped.

The loops-and-autoresearch story is sold as a new way to build. It isn't. The valuable bit sitting underneath the hype is old: write a clear spec of what "better" means, make the thing that verifies it trustworthy and impossible to game, and revert anything that doesn't measurably help. That is not a breakthrough. It is software engineering with the discipline turned up. The new capability is real, but it only pays off bolted onto the boring fundamentals.

And this is the bit I keep coming back to. As the models get better at writing code, those fundamentals get more important, not less. The bottleneck stops being "can the AI build it" and becomes "can I say precisely what I want and prove I got it". Specifying and verifying are human judgement. The machine gets a vote on what to try. It never gets a vote on what is true.

So my honest take, after building it rather than tweeting about it: take the discipline, skip the autonomy for now. I run these loops watched, and nothing merges without me looking at it. Autonomy is earned one project at a time, not assumed. The whole thing is open if you want to see how it works or pull it apart.

The agents will keep getting better at the typing. The job that's left, and the job that's quietly getting harder, is knowing what to ask for and checking that you got it. That part was never theirs to do.
