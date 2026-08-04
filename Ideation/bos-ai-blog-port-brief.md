# Mission: Port /blog command and convert /dailyreport to Claude-native

**Target repo**: https://github.com/TheWayWithin/BOS-AI (BOS-AI library)
**Reference repo**: https://github.com/TheWayWithin/agent-11 (canonical implementation)
**Authored**: 2026-04-11 — paste this whole file as a single prompt into a Claude Code
session running in the BOS-AI repo.

---

## Goal

Two changes to the BOS-AI library:

1. **Add a new `/blog` command** — Claude-native slash command that drafts a long-form
   blog post plus Twitter/X and LinkedIn versions on any topic, using a shared voice
   guide file.

2. **Rewrite `/dailyreport` as Claude-native** — BOS-AI currently uses a Python script
   (`enhance_dailyreport.py`) that calls the OpenAI API via gpt-4o-mini. Replace the
   entire pipeline with a pure Claude Code slash command. Delete the Python script.
   Remove `OPENAI_API_KEY` from any env templates that only referenced it for this
   purpose.

Both commands share a single voice guide file so one edit updates both. This is the
same pattern agent-11 now uses — BOS-AI is being brought into line.

**Why**: Claude Opus/Sonnet 4.6 are materially better at voice adherence than
gpt-4o-mini, there's no API key friction, no per-report cost, and the scrub pass
becomes a rewrite pass (not just a warning) because Claude has full edit control.

---

## CRITICAL: Which directory you are working on

BOS-AI is a library that deploys to user projects, and it uses agent-11 internally
for its own development. This means there are TWO separate directories in the repo:

- **BOS-AI library directory** (the TARGET of this work) — the files BOS-AI deploys
  to its users. Typically under `project/` or similar. Discover the exact structure
  by looking at the BOS-AI install script and existing command files.
- **`.claude/`** (DO NOT MODIFY) — agent-11's working squad, used internally to
  develop BOS-AI. Mirrors of agent-11 commands live here. Changes here affect only
  BOS-AI development, NOT what BOS-AI ships to its users.

Before starting, verify which directory is the library. A reliable test: open the
BOS-AI install script and grep for "commands". Files that install.sh references
ARE library files. Files it doesn't reference are internal tooling.

**Your work targets the library. Do not touch `.claude/` except to ignore it.**

---

## Reference implementation

The canonical implementation lives in the agent-11 repository. Port these files
(adapt to BOS-AI's directory layout — the structure may differ, the content will not):

1. `project/commands/blog.md` — new `/blog` command (Claude-native, 10-step agent
   protocol, reads voice guide, drafts blog + Twitter + LinkedIn, writes to `blog/`)
2. `project/commands/dailyreport.md` — rewritten `/dailyreport` (Claude-native, reads
   `progress.md`, creates/updates `progress/YYYY-MM-DD.md`, drafts all three derived
   outputs, writes to `progress/`)
3. `project/data/voice-guide-default.md` — shared default voice guide. **Lives OUTSIDE
   the commands directory** so Claude Code's harness doesn't auto-index it as a skill
   in the command palette. This matters — putting it inside `commands/` or any
   subdirectory of `commands/` causes a cosmetic skill entry like
   `data:voice-guide-default` to appear in the palette of every deployed repo.
4. `project/deployment/scripts/install.sh` — look at the block that installs
   `voice-guide-default.md` into `$CLAUDE_DIR/data/`. Replicate the equivalent in
   BOS-AI's install script.

Read all four files in the agent-11 repo before making any changes. The command
markdown files are long (each has a detailed agent protocol) but they are the spec
— your port should match them closely.

---

## Voice guide decision (already made)

**Use Jamie's voice verbatim.** Copy `voice-guide-default.md` from agent-11 to BOS-AI
unchanged. No adaptation, no tuning, no rewriting. Jamie is the primary user of both
libraries and wants the same default voice across all his repos. BOS-AI users who need
a different voice can drop their own `voice-guide.md` in their project root — the
resolution chain in the `/dailyreport` and `/blog` command specs handles that override
automatically.

Do not spend time debating or customising the default voice guide. Byte-identical copy.

---

## Steps

1. **Discover BOS-AI's library layout.** Find where BOS-AI's commands live, where its
   install script is, and what directory in the repo corresponds to agent-11's
   `project/`. Report back with the paths before making changes.

2. **Read the four reference files** from the agent-11 repo listed in the Reference
   Implementation section above. Use git, curl, or GitHub's raw content URL — whichever
   your environment supports.

3. **Find and read BOS-AI's current `/dailyreport` command file and the
   `enhance_dailyreport.py` script** to understand what's being replaced. Note
   anything BOS-AI-specific (e.g. custom output format, additional metadata,
   BOS-AI-specific progress structure) that needs to survive the port.

4. **Port `blog.md`** — copy verbatim from agent-11 to BOS-AI's command directory.
   The content is implementation-independent; it should work without modification.

5. **Port `dailyreport.md`** — replace BOS-AI's existing file with the agent-11
   version. Do NOT try to preserve the old version's structure. The new version is
   a complete rewrite. If step 3 identified BOS-AI-specific behaviours, flag them
   to Jamie before making any adaptations — don't silently add custom logic.

6. **Port `voice-guide-default.md`** — copy to a `data/` directory that sits OUTSIDE
   BOS-AI's commands directory, parallel to commands. When install.sh runs, this file
   must end up at `.claude/data/voice-guide-default.md` in the user's deployed project.
   If BOS-AI's library structure is `project/commands/`, put the source file at
   `project/data/`. Do NOT put it at `project/commands/data/` or
   `project/commands/scripts/` — both of those cause the skill-palette indexing issue.

7. **Delete `enhance_dailyreport.py`** from BOS-AI's library (and any `__pycache__`
   directories). Delete any empty `scripts/` directories left behind if the script was
   the only file there.

8. **Update BOS-AI's install script**:
   - Remove the block that installs `enhance_dailyreport.py`
   - Add a block that creates `$CLAUDE_DIR/data/` and copies `voice-guide-default.md`
     into it (both local and remote execution paths — reference the agent-11
     `install.sh` for the exact pattern)
   - Ensure the new `blog.md` is added to the list of command files to install

9. **Remove `OPENAI_API_KEY` from BOS-AI's env templates** (e.g. `.env.mcp.template` or
   equivalent) if it was only there for `/dailyreport`. If BOS-AI uses OpenAI elsewhere,
   leave the variable but remove any comment that says it's for `/dailyreport`.

10. **Update BOS-AI's README** (if it documents `/dailyreport`) to reflect the
    Claude-native architecture: no API keys, no costs, shared voice guide with `/blog`.
    Use agent-11's README `/dailyreport` section as a template.

---

## Verification checklist

After completing the port, verify:

- [ ] `blog.md` exists in BOS-AI's library commands directory
- [ ] `dailyreport.md` in BOS-AI's library is the new Claude-native version (no
      mention of OpenAI, no references to a Python script)
- [ ] `voice-guide-default.md` exists in BOS-AI's library at a location parallel to
      commands (e.g. `project/data/`), NOT inside the commands directory
- [ ] `enhance_dailyreport.py` is deleted from BOS-AI's library
- [ ] BOS-AI's install script creates `.claude/data/` and installs the voice guide
- [ ] BOS-AI's install script installs `blog.md` alongside other commands
- [ ] Running the updated install script in a fresh test directory produces a
      `.claude/data/voice-guide-default.md` and both `blog.md` and `dailyreport.md` in
      `.claude/commands/`
- [ ] No references to `OPENAI_API_KEY`, `DAILYREPORT_MODEL`, or
      `DAILYREPORT_ENABLE_SOCIAL` remain in deployable content
- [ ] The `.claude/` directory in the BOS-AI repo itself was NOT modified
- [ ] A git diff shows only library files changed, not working squad files
- [ ] After install in a test directory, running Claude Code should NOT show a
      `data:voice-guide-default` or similar entry in the skills palette — the voice
      guide must be outside `.claude/commands/` to stay hidden from the harness

---

## Report back with

- The exact paths you changed (before and after)
- Any places where BOS-AI's library layout required adapting the agent-11 pattern
- Any BOS-AI-specific behaviour from the old `/dailyreport` that you noticed and
  whether you preserved it, dropped it, or flagged it
- A summary of what would happen when a user runs BOS-AI's install script after
  these changes
- Confirmation that the working squad (`.claude/` in the BOS-AI repo) was not modified

---

## Notes and gotchas

- The agent-11 install script uses `$CLAUDE_DIR/data/` (via the global `CLAUDE_DIR`
  variable). BOS-AI's install script may use a different variable name — adapt
  accordingly, but the deployed path should always end up at `.claude/data/` relative
  to the user's project root.
- The voice guide resolution chain in `dailyreport.md` and `blog.md` checks, in order:
  `$DAILYREPORT_VOICE_GUIDE` env var → `./voice-guide.md` → `./.claude/voice-guide.md`
  → `./docs/voice-guide.md` → `.claude/data/voice-guide-default.md`. Do not change
  this chain. BOS-AI users who want a custom voice drop `voice-guide.md` in their
  project root.
- The environment variable is called `DAILYREPORT_VOICE_GUIDE` (not `BLOG_VOICE_GUIDE`
  or `VOICE_GUIDE_PATH`) for historical reasons. Both commands share it. Do not rename.
- Both command files include a mandatory voice scrub pass that rewrites any AI-tell
  vocabulary before writing the output file. This is a rewrite pass, not a warning
  — Claude has edit control, use it.
- Output directories are `progress/` (for `/dailyreport`) and `blog/` (for `/blog`).
  Neither command should write outside these directories.
