---
date: 2026-04-12
platform: linkedin
character_count: 1088
hook_length: 85
---

I ran a security audit on my own AI agent framework. The findings were uncomfortable.

25 issues. Two critical. One was a curl-pipe-bash installer with zero integrity verification. The other was an rm -rf that would delete from root if a variable resolved to empty.

But the interesting finding wasn't in the shell scripts. It was in the agent prompts.

Every agent reads external documents: architecture files, PRDs, context handoffs. Every prompt said those documents were the "source of truth." Which means a malicious edit to ideation.md could hijack an agent's behaviour entirely.

We added explicit trust boundaries: agents now treat documents as data to analyse, not instructions to follow. It's a mitigation, not a cure, but the line between "data" and "instructions" matters.

Three sprints. Four commits. 30+ files. The whole audit took a single session with AI agents running the analysis in parallel.

If you're building tools that other developers install and run, do the audit. The findings take less time to fix than they do to explain after an incident.

#security #buildinpublic
