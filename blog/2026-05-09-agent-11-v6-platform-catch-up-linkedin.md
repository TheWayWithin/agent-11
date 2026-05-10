---
platform: linkedin
char_count: 1063
hook_length: 120
---

Half of agent-11 v6 was scaffolding the platform now provides. I shipped v6 last month. The biggest change was deletion.

CLAUDE.md: 250 lines → under 80. The MCP profile system, six JSON files and three commands, binned in favour of one config flag. Five context files → three. ~80% context reduction on MCP sessions.

Claude Code didn't have hooks, subagents, or Tool Search when I started agent-11. You built that scaffolding yourself, and every line cost context on every call.

If you've built an agent framework recently, some of it is probably now technical debt. Not because you did anything wrong. The platform underneath you grew up.

The other half of v6 is Karpathy posture: PAUSE-AND-PLAN before non-trivial changes, state assumptions out loud, prefer minimal diffs. Eighty lines of behavioural defaults replaced ~150 lines of "always do X" rules. The agents move slower at the start of a task and faster overall.

30-minute exercise: open your system prompt. Find every 'Always' or 'Never' sentence. Ask if it's enforceable as a hook. If yes, move it.

What's worth keeping isn't orchestration. It's behavioural discipline, domain skills, and a clean upgrade path.

What's the oldest scaffolding in your framework?

Full post: jamiewatters.work/journey/agent-11-v6-platform-catch-up

#BuildInPublic #AgentEngineering #ClaudeCode
