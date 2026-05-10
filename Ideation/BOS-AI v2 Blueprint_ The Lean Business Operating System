# BOS-AI v2 Blueprint: The Lean Business Operating System

**Date**: April 17, 2026
**Author**: Manus AI

---

I have completed a deep dive into the `BOS-AI` repository. Like Agent-11 and SEO-Agent, it is currently suffering from severe prompt bloat and context micromanagement. 

However, BOS-AI is fundamentally different from the other two tools: **it is a document generation engine, not a code generation engine.** Its primary value is taking your raw ideas and structuring them into the Foundation Documents (Vision, PRD, Marketing Bible) that Agent-11 needs to actually build the software.

Here is how we apply the Agent-11 v6 lessons to BOS-AI to make it faster, cheaper, and more effective for your solopreneur workflow.

---

## 1. The Core Problem: The "Context Preservation" Tax

Currently, the `/coord` command in BOS-AI forces every one of the 30 agents to read and write to multiple workspace files (`business-plan.md`, `agent-context.md`, `handoff-notes.md`, `chassis-metrics.md`) before and after every single task. It also creates a new `checkpoint-[timestamp].md` file after every agent turn.

**The Agent-11 Lesson:** This is a massive token tax that Opus 4.7 does not need. Claude Code natively handles context much better now.

**The Fix for BOS-AI:**
* **Delete the Checkpoint System:** Claude Code's native history handles recovery. You don't need to generate hundreds of checkpoint markdown files.
* **Shrink to 2 Workspace Files:** Keep `business-plan.md` (for the checklist) and `agent-context.md` (for the actual data/findings). Delete the mandatory handoff and metrics files.
* **Remove the "Mandatory Protocol":** Delete the 4 ASCII box gates in `coord.md` and the 20+ lines of "MANDATORY CONTEXT PROTOCOL" from the top of all 30 specialist agents.

---

## 2. The Dead Weight: The XML Memory System

BOS-AI currently creates 12 XML files in the `/memories/` folder (e.g., `vision.xml`, `markets.xml`, `decisions.xml`) filled with `PLACEHOLDER_` text. The agents are instructed to read and update these files to maintain "institutional memory."

**The Agent-11 Lesson:** LLMs are terrible at maintaining structured XML databases via prompt instructions. It wastes tokens and rarely works reliably.

**The Fix for BOS-AI:**
* **Delete the XML Memory System entirely.** 
* **Rely on the Foundation Documents:** The actual source of truth for your business isn't a hidden XML file; it's the markdown files in `/documents/foundation/` (like the PRD and Vision documents). When an agent needs context, it should just read those markdown files directly.

---

## 3. Elevating the Real Value: Foundation Documents & Routines

The most valuable parts of BOS-AI are the Foundation Document pipeline (specifically the PRD v3.1 with the System Skeleton) and the operational commands (`/dailyreport` and `/blog`).

**The Agent-11 Lesson:** Shift from prompt-based orchestration to native tools and operational routines.

**The Fix for BOS-AI:**
* **Automate Mode C Work:** The `/dailyreport` and `/blog` commands are perfect examples of "Mode C" operational work. Instead of running them manually, convert them into Claude Code Routines that run automatically at the end of every day.
* **Streamline the Foundation Pipeline:** The `vision-mission-creation` and `prd-creation` missions are currently bogged down by the multi-agent handoff ceremony. Rewrite these missions to be single-agent, deep-thinking tasks using Opus 4.7. The "Auto vs Engaged" mode selection is a great UX pattern and should be kept.

---

## 4. The Karpathy Business Constitution

Just as Agent-11 got a slimmed-down constitution, BOS-AI needs a specific set of behavioral rules tailored to business strategy and document generation.

**The Fix for BOS-AI:**
Replace the bloated `CLAUDE.md` with a slim <80-line file containing these core rules:
1. **Read the Foundation First:** Always check `/documents/foundation/` before making strategic recommendations.
2. **Prioritize the Chassis:** When optimizing, always focus on the weakest multiplier in the Business Chassis formula.
3. **Solopreneur Voice:** Always write in the first person ("I", "my"), never corporate speak ("we", "our team").
4. **Smart Brevity:** Keep all generated documents concise and actionable. Avoid fluff and filler.
5. **No Code:** Never write code or technical architecture. That is Agent-11's job.

---

## Summary of Action Items

If you want to upgrade BOS-AI to the v2 (Agent-11 v6 style) architecture, here is the immediate hit list:

1. **Delete the 12 XML memory files** and remove all references to them in the agent prompts.
2. **Strip the "Mandatory Context Protocol" and ASCII boxes** out of `coord.md` and all 30 agent prompts.
3. **Consolidate the workspace files** down to just `business-plan.md` and `agent-context.md`.
4. **Rewrite `CLAUDE.md`** to feature the Karpathy Business Constitution.
5. **Convert `/dailyreport` and `/blog`** into automated Claude Code Routines.
