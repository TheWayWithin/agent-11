---
date: 2026-06-21
slug: coding-harness-vs-agent-11
title: "How to trust AI-written code you didn't read line by line"
excerpt: "AI can write working code in minutes. The hard part is trusting it without reading every line. Here's what actually makes AI-built code trustworthy."
tags: [ai, software-engineering, agent-11, ai-agents, verification]
image: /images/blog/2026-06-21-coding-harness-vs-agent-11.webp
imageAlt: "On the left, a lone clamp gripping a single tool; on the right, an organised wall of specialist tools around a small instrument sealed under glass with a wax seal."
---

An AI agent can write you a few hundred lines of working code in a couple of minutes. It runs. The tests are green. Here's the question the demos never answer: do you trust it enough to ship without reading every line yourself?

Most days, honestly, no. And reading every line defeats the point of having the AI write it.

So the real problem isn't getting AI to write code. That's close to solved. The problem is trusting what it hands back. After building with this for months, I've landed on an uncomfortable answer: you can't trust the model. You trust the process around it. And most AI coding tools don't give you a process, they give you a wrapper.

A wrapper (the polite word is "harness") is the thin layer that runs the prompts, holds the tools, and passes the output back. Useful, and a commodity, and it trusts the model completely. Whatever the model says is done, is done. That is exactly the thing you cannot afford to believe.

Here's what I built instead, and the one rule that does most of the work.

The checks that grade the work cannot be edited by the agent doing the work. If a test says the code passed, the agent physically cannot soften that test to make it pass. I tested it the obvious way: I told an agent to set a quality threshold to zero so everything would sail through. It couldn't. The rule blocked the edit, and then it told me, unprompted, that zeroing the threshold would disable the check and that I should authorise that myself if I really meant it. That is the whole game. An agent chasing "done" will lower the bar instead of clearing it, unless it physically cannot reach the bar. (Why that one matters on its own, I wrote up [last week](https://jamiewatters.work/journey/loops-hype-vs-real-engineering).)

Everything else hangs off the same principle: the thing being judged does not get to move the goalposts.

So "done" means evidence, not opinion. Every check starts failing and only flips to passed when there's real command output behind it. "The code looks correct" counts as not done.

When an agent tunes performance, it keeps only what is measurably better. I pointed it at one of my own apps last week. It made a change, measured it, and kept it only because the bundle actually got smaller. Anything that hadn't beaten the baseline would have been reverted on the spot, with every attempt logged. No "trust me, it's faster" with nothing behind it.

Review is split between two agents. One finds the problems, read-only. A different one fixes them. They can't be the same agent, because an agent that finds and fixes its own work is marking its own homework.

And a long job has to prove each stage before it moves on. If it can't, it stops and asks me, instead of building three more things on a cracked foundation.

None of this is the AI model. It's the process around it, and it has a name: agent-11, my open-source Claude Code framework. Eleven specialist agents, thirteen repeatable missions, and the checks above. A wrapper has none of it.

I'll be honest about the cost: this is more machinery than firing off a single prompt, and for a throwaway script it's overkill. I run it on the work I actually need to trust.

Here's why I think this gets more important, not less, as the models improve.

Right now a lot of tools compete on the wrapper: better scaffolding, better raw output. But the models are getting good at writing code, fast. Soon "can it write the code" won't be the interesting question, because the answer will usually be yes. The question left is the one I started with: can you trust what it produced without reading every line? That has nothing to do with how clever the model is. It's about process, and verification you can't fake.

The wrapper becomes a commodity. The thing that makes the output trustworthy becomes the whole value.

Here's the test I'd run on any AI coding setup, including mine: if the agent can change the thing that judges its work, you don't have verification. You have theatre.

I'm not selling anything. agent-11 is open and free, it's the squad I build my own products with, and the checks are the first place I'd look: [github.com/TheWayWithin/agent-11](https://github.com/TheWayWithin/agent-11). Pull it apart and tell me where it's wrong.

I write these as field reports from inside the problem: building real things with AI without quietly handing my judgement to the machine, what held, what broke, what I changed. The model will keep getting better at the typing. I'm spending my time on the part that won't: saying exactly what I want, and being able to prove I got it.
