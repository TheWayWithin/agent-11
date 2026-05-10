---
name: dailyreport
description: Generate a daily progress report plus voice-aligned blog and social media posts from your project's progress logs
---

# /dailyreport Command

Turn today's work from `progress.md` into a structured daily report, a long-form blog
post, and copy-paste-ready Twitter/X and LinkedIn posts for build-in-public sharing.
Voice-aligned, Claude-native, no API keys required.

`/dailyreport` is the progress-log counterpart to `/blog`. Where `/blog` takes any topic
you want to write about, `/dailyreport` parses your structured changelog and narrates
the day. Both commands share the same voice guide system.

## USAGE

```bash
/dailyreport
```

No arguments. Reads the current day's work from `progress.md`, creates or updates the
daily report, regenerates all three outputs.

## WHAT IT DOES

### First run of the day

Creates `progress/YYYY-MM-DD.md` capturing:

- **Completed milestones** grouped by category (features, fixes, infrastructure, docs)
- **Issues encountered** with root-cause analysis when available
- **Lessons learned** and patterns noticed
- **Metrics** when present in the source logs
- **Next steps** for tomorrow

Then generates the blog post and social posts from that report.

### Subsequent runs the same day

Updates the existing `progress/YYYY-MM-DD.md` with new work added since the last run,
then regenerates all three derived outputs so they reflect the full day.

## OUTPUT FILES

Five files per day, all in the `progress/` directory:

```
progress/
├── 2026-04-11.md            # Raw daily report (source of truth)
├── 2026-04-11-blog.md       # Long-form blog post (voice-aligned)
├── 2026-04-11-twitter.md    # Twitter/X post (copy-paste ready)
├── 2026-04-11-linkedin.md   # LinkedIn post (copy-paste ready)
└── 2026-04-11-wip.md        # wip.co posts (one per shipped milestone)
```

## VOICE ALIGNMENT

Blog and social posts are drafted to match a specific voice profile loaded from a
markdown file. Resolution order (first hit wins):

1. **`DAILYREPORT_VOICE_GUIDE` env var** — absolute or relative path to any markdown file
2. **`voice-guide.md`** in project root
3. **`.claude/voice-guide.md`**
4. **`docs/voice-guide.md`**
5. **Default** — `.claude/data/voice-guide-default.md` (ships with AGENT-11)

The default voice guide is tuned for authentic, non-AI-sounding build-in-public writing.
It enforces:

- **British spelling** throughout (colour, realise, favour, practise)
- **No AI-tell vocabulary** — banned list includes delve, tapestry, pivotal, leverage,
  foster, harness, empower, streamline, transformative, game-changing, seamless, robust,
  moreover, furthermore, and 30+ others
- **No stock AI constructions** — no "it's not just X, it's Y," no rule-of-three
  adjective stacks, no em-dash overuse, no bullet-point-with-bolded-headers
- **Varied sentence and paragraph length** — short punches mixed with longer lines
- **Dry, understated humour** delivered straight (Adams/Pratchett/Vonnegut/Heller)
- **Pub test**: if you wouldn't say it out loud to a friend, it doesn't ship

### Writing your own voice guide

Copy the default to your project root and adapt it:

```bash
cp .claude/data/voice-guide-default.md voice-guide.md
# Then edit voice-guide.md to reflect your own voice
```

Both `/dailyreport` and `/blog` read from the same guide, so one edit updates both
commands. The file is passed verbatim to Claude as drafting instructions — be specific.

### Setting the voice guide via env var

```bash
# Point at any markdown file, anywhere
export DAILYREPORT_VOICE_GUIDE=/path/to/my-voice.md
```

If the env var is set but points at a missing file, `/dailyreport` prints a loud warning
and falls back to the default rather than silently using the wrong voice.

## DUAL-LINK STRUCTURE (SOCIAL POSTS)

Social posts include two links in a specific order so the last one wins the OG preview
card — blog link goes last so your branded preview image shows.

**Twitter/X:**
```
<hook + specific detail>

Try it: <product-url>

Full writeup: <DAILYREPORT_BASE_URL>/journey/<blog-slug>

#BuildInPublic #AlgoTrading #Refactoring
```

**LinkedIn:**
```
<140-char hook that stands alone>

<short paragraphs, one idea per line>

Try it: <product-url>

<plain closing or genuine question>

Full writeup: <DAILYREPORT_BASE_URL>/journey/<blog-slug>
```

Both URLs are resolved from env vars at write time:
- Product URL → `PRODUCT_URL`. If unset, the "Try it:" line is omitted.
- Blog base URL → `DAILYREPORT_BASE_URL`. If unset, the "Full writeup:" line is omitted. The path is `/journey/<blog-slug>` to match where `jpub` publishes. Do NOT use `/progress/<date>`.

If an env var is missing, the corresponding line is **omitted entirely** — never guessed, never left as a placeholder.

## AGENT INSTRUCTIONS

When the user invokes `/dailyreport`, you (Claude) execute the following steps directly.
Do not delegate. Do not call any Python script. Do not use an external API.

### Step 1: Determine today's date

Use the current date in `YYYY-MM-DD` format. This drives the output filenames.

### Step 1.5: Resolve URL environment variables

Before drafting social posts, read these env vars with Bash (use `echo` so an unset var returns empty):

```bash
echo "DAILYREPORT_BASE_URL=$DAILYREPORT_BASE_URL"
echo "PRODUCT_URL=$PRODUCT_URL"
```

Record the values. They affect the Twitter/X and LinkedIn posts:
- `DAILYREPORT_BASE_URL` → `Full writeup: <DAILYREPORT_BASE_URL>/journey/<blog-slug>`. If empty, **omit the "Full writeup:" line entirely**.
- `PRODUCT_URL` → `Try it: <PRODUCT_URL>`. If empty, **omit the "Try it:" line entirely**.

**Never guess or hallucinate these URLs.** If an env var is unset, the line is simply not written.

### Step 2: Load the voice guide

Resolution order (first hit wins):

1. `$DAILYREPORT_VOICE_GUIDE` env var → read that file if it exists
2. `./voice-guide.md`
3. `./.claude/voice-guide.md`
4. `./docs/voice-guide.md`
5. **Default** — read `.claude/data/voice-guide-default.md`

If the env var is set but the file is missing, print a warning and fall through to the
project-file search. If step 5 fails because the file is missing (unusual — only
happens if the install is corrupted), print a warning and use your best understanding
of the voice rules documented in the Voice Alignment section above.

Announce which guide was loaded and its path:

```
🎙️  Voice guide: <source description> → <path>
```

Examples:
```
🎙️  Voice guide: env DAILYREPORT_VOICE_GUIDE → /home/alice/my-voice.md
🎙️  Voice guide: project file → ./voice-guide.md
🎙️  Voice guide: built-in default → .claude/data/voice-guide-default.md
```

### Step 3: Gather progress context

Read (always):
- `progress.md` — primary source of truth for what happened today
- `CLAUDE.md` — project name and context
- `project-plan.md` if it exists — secondary source for task completion status
- `progress/YYYY-MM-DD.md` if it already exists — the current state of today's report

Read (if relevant to the day's work):
- `git log --since="today" --oneline` — commits made today
- `architecture.md` — if today's work involves architectural decisions
- Specific files mentioned in progress.md entries — for concrete specifics

Do not read the entire repo. Be surgical. The goal is enough context to narrate the
day with concrete specifics.

### Step 4: Extract today's work

From `progress.md`, identify entries dated today (or since the last update if an
existing `progress/YYYY-MM-DD.md` has a timestamp). Group them into:

- **Completed milestones** — what shipped, what got fixed, what was built. Categorise
  by context (features, bug fixes, infrastructure, documentation, refactors).
- **Issues encountered** — problems that surfaced, including failed fix attempts and
  their learnings. Include root cause when documented.
- **Lessons learned** — patterns noticed, "next time we'll..." style observations.
- **Next steps** — what's queued for tomorrow or this week.
- **Metrics** — any numbers, counts, performance deltas, costs, durations.

If there's nothing in `progress.md` for today, say so plainly and stop — do not invent
content.

### Step 5: Create or update the raw daily report

Write to `progress/YYYY-MM-DD.md`. If the file already exists, merge new work in —
don't wipe prior content. Structure:

```markdown
# <Project Name> Progress

**Date**: YYYY-MM-DD
**Last Updated**: HH:MM

## Summary
<2-3 sentence summary of the day's work>

## Milestones

### Features
- **<short title>**: <one-line description with specifics>

### Fixes
- **<short title>**: <what broke, how it was fixed>

### Infrastructure
- **<short title>**: <what changed>

## Issues
### <Issue title>
**Symptom**: <what went wrong>
**Attempts**: <what was tried, including failures>
**Resolution**: <final fix, or "still open">
**Root cause**: <if known>
**Learning**: <what this teaches>

## Lessons Learned
- <pattern or observation>

## Next Steps
- <next task>
```

Omit sections that don't have content. Don't pad with empty headers.

### Step 6: Draft the blog post

Apply the voice guide as your drafting rules — every rule in it is binding.

Structural requirements:
- **Open in the middle of something** — a specific moment from today, a decision
  point, the second something broke or clicked. No "Today I worked on..." No
  "In this update..." No preamble.
- **Systems-first** — show how the pieces connect before zooming into details
- **Concrete specifics** — numbers, tool names, file paths, commit hashes, exact
  error messages. Never use a vague adjective where a specific noun would do.
- **Include the fumbles** — failed attempts teach more than clean wins. If a fix
  took three tries, say so.
- **Varied sentence and paragraph length** — mix short punches with longer lines.
  At least one single-sentence paragraph if the piece runs over 300 words.
- **Length**: 400-700 words. Shorter if the day doesn't justify more. Respect the
  reader's time.
- **Markdown**: H2 headers (`##`) only when the reader genuinely needs a signpost.
  `---` for major shifts. Code fences for code or command lines. No bold-header
  bullet lists. No emoji in headers.
- **Close with a concrete next step, a genuine question, or a plain statement.**
  Never a motivational flourish. Never a summary that restates what the reader
  just read.

**Title**: specific to today's work, not a template. "The afternoon the cron job ate
my inbox" beats "Daily Update — April 11." Make it something someone would click.

Write to `progress/YYYY-MM-DD-blog.md` with frontmatter:

```markdown
---
date: YYYY-MM-DD
project: <project name>
tags: [Tag1, Tag2, Tag3]
---

# <specific title>

<post content>
```

`tags` is a YAML list of 3-5 topic tags in TitleCase derived from the day's work
(e.g. `[AlgoTrading, Crypto, BuildInPublic]`). These become blog tags on the
published site — keep them consistent with the hashtags used in the social posts.

### Step 7: Derive the Twitter/X post

- Pull the sharpest single idea from the blog post
- First line is the hook — specific and slightly surprising. No emoji in the hook.
- One concrete detail (number, tool name, what actually happened)
- 180-260 characters (280 is the hard limit — use the room you have)
- Dual-link structure (include both only if a product URL is configured):
  1. `Try it: <product-url>` — resolve from `PRODUCT_URL` env var. If unset, omit
     this line entirely rather than leaving a placeholder.
  2. Link to today's report last (OG preview): `Full writeup: <DAILYREPORT_BASE_URL>/journey/<blog-slug>`
     - Resolve `<DAILYREPORT_BASE_URL>` by reading the env var at write time (`echo "$DAILYREPORT_BASE_URL"` via Bash). If empty, **omit the "Full writeup:" line entirely** — never guess.
     - `<blog-slug>` is the slug of the blog post you generated in Step 6 (derived from the first `# heading` of the blog file, lowercased, hyphenated). This must match the slug `jpub` will use at publish time.
     - The path is `/journey/<slug>` to match where `jpub` publishes (`jamiewatters.work/journey/<slug>`). Do NOT use `/progress/<date>` — that is not where published reports live.
- **Hashtags: 2-4 total, TitleCase/PascalCase for readability.**
  - Pick 1 community tag from: `#BuildInPublic #SoloFounder #IndieHacker #DevLog`
  - Plus 1-3 topic-specific tags derived from the day's work (e.g. `#AlgoTrading #Crypto #Security #Refactoring #Auth #Postgres #LLMs`)
  - Always TitleCase: `#BuildInPublic` not `#buildinpublic`, `#AlgoTrading` not `#algotrading`
  - Topic tags come from what actually shipped — no generic filler
- **No templates**: no "Shipped X today 🚀", no "Learned Y the hard way". Write fresh.

Write to `progress/YYYY-MM-DD-twitter.md`:

```markdown
# Twitter/X Post — <formatted date>

**Project**: <project name>
**Characters**: <count>/280

---

<post content>

---

**Copy-paste ready** ⬆️

## Optimization Notes
- Character count: <count>/280 <✅ or ⚠️>
- Link included: Yes
```

### Step 8: Derive the LinkedIn post

- 800-1000 characters sweet spot. 3000 is the hard ceiling.
- First 140 characters are the hook (shown before "see more"). Must carry weight on
  their own. No "Excited to share...", no throat-clearing.
- Short paragraphs. One idea per line. White space is a feature.
- Register: smart colleague sharing a real lesson. Not thought leader dropping wisdom.
- Dual-link structure (include both only if a product URL is configured):
  1. `Try it: <product-url>` mid-post — resolve from `PRODUCT_URL` env var. If
     unset, omit this line entirely rather than leaving a placeholder.
  2. Report link at the end (OG preview): `Full writeup: <DAILYREPORT_BASE_URL>/journey/<blog-slug>`
     - Same resolution rules as the Twitter/X link: read `DAILYREPORT_BASE_URL` from env, omit the line if unset, use `/journey/<blog-slug>` path. Slug must match the blog file you generated in Step 6.
- **Hashtags: 2-3 total at the very end, TitleCase (LinkedIn penalises spam — fewer hashtags than Twitter/X).**
  - Use the same TitleCase convention: `#BuildInPublic`, `#AlgoTrading`, `#Security`
  - Mix community tag + topic-specific tags derived from the day's work
- Close with a genuine question the reader might actually answer, or a plain statement.
  Never manufactured engagement ("What do you think? Drop a comment below!").

Write to `progress/YYYY-MM-DD-linkedin.md`:

```markdown
# LinkedIn Post — <formatted date>

**Project**: <project name>
**Characters**: <count>/3000
**Hook Length**: <hook_length>/140 chars

---

<post content>

---

**Copy-paste ready** ⬆️

## Optimization Notes
- Total characters: <count>/3000 <✅ or ⚠️>
- Hook length: <hook_length>/140 <✅ or ⚠️>
- Link included: Yes
```

### Step 9: Derive the wip.co posts

wip.co is a build-in-public community where members post short "shipped" updates
tied to project hashtags. The convention is a public changelog line per completed
item — "Fixed login bug #myapp" not "Working on auth later". Multiple small posts
per day are normal and encouraged.

Generate **one post per meaningful shipped milestone** from the raw daily report
(step 5). One post per item, not a single combined post. Draw from the milestones
sections (Features, Fixes, Infrastructure, etc.) — do NOT include items from
Lessons Learned, open issues without resolution, or Next Steps, because those
are not completed work.

Each post must:
- Be **under 150 characters** (shorter is fine — aim for 40-120)
- Start with a past-tense action verb: Shipped, Fixed, Deployed, Added,
  Deleted, Refactored, Wrote, Merged, Rewrote, Converted, Removed, Renamed
- Describe **what was completed** in one specific sentence
- Include the project hashtag at the end
- Follow the voice guide for spelling (British) and banned vocabulary
- Be a single line, no newlines within a post

**Project hashtag resolution** (first hit wins):
1. `WIP_PROJECT_HASHTAG` env var (e.g. `WIP_PROJECT_HASHTAG=#agent11`)
2. Derive from the project name in CLAUDE.md by lowercasing the name, removing
   non-alphanumeric characters, and prefixing `#`. Examples:
   - "AGENT-11" → `#agent11`
   - "BOS-AI" → `#bosai`
   - "ISOTracker" → `#isotracker`
3. Fall back to `#buildinpublic`

If the day has no completed milestones (rare), write a single post saying so with
the hashtag, or skip the file entirely with a note in the final report.

Write to `progress/YYYY-MM-DD-wip.md` using this structure (replace angle-bracket
placeholders with real values):

````markdown
# wip.co Posts — <formatted date>

**Project**: <project name>
**Hashtag**: <hashtag>
**Post count**: <N>

---

<post 1>

<post 2>

<post 3>

---

**Copy-paste ready** ⬆️ (one post at a time)

## Posting Options
- **Web**: homepage "Ship something..." input at wip.co
- **Telegram**: DM @wipbot with `/done <post text>`
- **Menubar app**: if installed

## Optimization Notes
- <N> posts generated from today's completed milestones
- Longest post: <max> chars
- Shortest post: <min> chars
- Post one at a time throughout the day, or batch at the end
````

### Step 10: Voice scrub (rewrite pass)

Scan all four drafts (blog, Twitter, LinkedIn, wip) for any word on the AI-tell blacklist:

> delve, tapestry, intricate, pivotal, underscore, foster, testament, multifaceted,
> comprehensive, myriad, leverage (as verb), embark, realm, beacon, paradigm, synergy,
> unlock, harness, empower, streamline, spearhead, cornerstone, linchpin, bedrock,
> hallmark, catalyst, transformative, game-changing, revolutionary, cutting-edge,
> robust, seamless, holistic, groundbreaking, ever-evolving, moreover, furthermore

If any survived, **rewrite** the affected sentence before writing the file. Do not
just warn — you have full edit control. Fix it now.

Also check and rewrite: rule-of-three adjective stacks, "it's not just X, it's Y"
constructions, em dashes more than twice per 500 words, bullet points starting with
bolded phrases that the following sentence restates.

**Character limit validation** — count the actual characters (not words) in each
social post's content (the text between the `---` markers, excluding metadata):
- **Twitter/X**: must be under 280. If over, shorten the post and recount. Do not
  just trim — rewrite to fit while keeping the hook and a concrete detail.
- **LinkedIn**: must be under 3000. Hook (first 140 chars) must be a complete
  thought. If the hook is cut mid-sentence, rewrite the opening.
- **wip.co**: each post should be under 150. If over, split into two posts or
  compress the verb + description.

If any limit is breached, rewrite and recount before writing the file. Do not
publish a character count in the metadata that you haven't actually verified.

### Step 11: Report to the user

Print a summary:

```
✅ progress/YYYY-MM-DD.md
  📊 <N> milestones across <M> categories
  🐛 <N> issues with <M> resolved
  ✨ Blog post: progress/YYYY-MM-DD-blog.md (<word count> words)
  🐦 Twitter/X: progress/YYYY-MM-DD-twitter.md (<char>/280)
  💼 LinkedIn: progress/YYYY-MM-DD-linkedin.md (<char>/3000, hook <n>/140)
  🚢 wip.co: progress/YYYY-MM-DD-wip.md (<N> posts, <hashtag>)
  🎙️  Voice guide: <source>

📋 Ready to publish:

  jpub <ABSOLUTE_PATH_TO_REPO>/progress/YYYY-MM-DD --all --dry-run

Remove --dry-run when you're happy with the preview.
```

Where `<ABSOLUTE_PATH_TO_REPO>` is the real absolute path to the current working
directory (from `pwd` or equivalent), so the command works from any terminal tab.
For example: `jpub /Users/jamiewatters/DevProjects/BOS-AI/progress/2026-04-12 --all --dry-run`

Then show the Twitter/X post inline as a preview so the user can eyeball it without
opening the file:

```
Twitter Preview:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
<actual post content>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## CONFIGURATION

No API keys required. Optional environment variables in `.env.mcp`:

```bash
# Voice guide override (shared with /blog)
DAILYREPORT_VOICE_GUIDE=/path/to/voice-guide.md

# Base URL for blog links in social posts.
# Social posts will contain `Full writeup: <DAILYREPORT_BASE_URL>/journey/<blog-slug>`.
# If unset, the "Full writeup:" line is omitted rather than guessing a URL.
DAILYREPORT_BASE_URL=jamiewatters.work

# Product URL for social posts (e.g. modeloptix.com, plebtest.com).
# If unset, the "Try it:" line is omitted from social posts rather
# than leaving a placeholder.
PRODUCT_URL=yourdomain.com

# wip.co project hashtag (shared with /blog). If unset, derived from
# the project name in CLAUDE.md (e.g. "AGENT-11" → #agent11)
WIP_PROJECT_HASHTAG=#agent11
```

That's the whole config surface. `/dailyreport` no longer uses `OPENAI_API_KEY`,
`DAILYREPORT_MODEL`, or `DAILYREPORT_ENABLE_SOCIAL` — those were relics of the old
Python-script pipeline. Claude Code does the writing now.

## PUBLISHING WORKFLOW

### Twitter/X

1. Open `progress/YYYY-MM-DD-twitter.md`
2. Copy the post text (between the dashed lines)
3. Paste into Twitter/X compose and post

### LinkedIn

1. Open `progress/YYYY-MM-DD-linkedin.md`
2. Copy the post text (between the dashed lines)
3. Paste into LinkedIn compose and post

### Blog

1. Open `progress/YYYY-MM-DD-blog.md`
2. Review, edit anything that still sounds off
3. Publish to your blog platform
4. Confirm the URL matches what you used in the social posts (so the OG preview works)

### wip.co

1. Open `progress/YYYY-MM-DD-wip.md`
2. Copy each post one at a time (they're between the dashed lines)
3. Post via web (homepage "Ship something..." box), Telegram (`/done <text>` to @wipbot), or menubar app
4. Post throughout the day or batch at the end — multiple small posts per day are normal on wip

## TROUBLESHOOTING

**Nothing in progress.md for today?**
- `/dailyreport` won't invent content. Log your work to `progress.md` first, then run
  `/dailyreport`. The `/coord` and `/pmd` commands both write to `progress.md`
  automatically.

**Output doesn't sound like your voice?**
- Drop a `voice-guide.md` in your project root with your own rules
- The voice guide is passed to Claude as drafting instructions — more specific rules
  produce more specific output
- Use the default as a template: `cp .claude/data/voice-guide-default.md voice-guide.md`

**Voice guide not loading?**
- Check the announcement line: `🎙️  Voice guide: <source>`
- If it says "built-in default" but you expected a custom guide, verify the file exists
  at one of the search locations or that your env var points at an existing file

**Twitter post too long?**
- Claude drafts under 280 — if it's over, it's a mistake, re-run the command
- If it keeps happening, your voice guide or context is pushing too much detail — trim
  the raw daily report and re-run

## INTEGRATION WITH AGENT-11

`/dailyreport` works alongside:

- **`progress.md`** — primary data source for all logged work and issues
- **`project-plan.md`** — secondary source for task completion verification
- **`CLAUDE.md`** — project context and name
- **`/blog`** — complementary command for topic-driven posts (same voice guide, same
  social post format, different input shape)
- **`/report`** — longer-form stakeholder progress reports
- **`/pmd`** — root cause analysis that feeds into the issue log

## QUICK REFERENCE

| Task | Command/Setting |
|------|-----------------|
| Create or update daily report | `/dailyreport` |
| Set custom voice guide path | `DAILYREPORT_VOICE_GUIDE=/path/to/file.md` |
| Set custom domain for links | `DAILYREPORT_BASE_URL=yourdomain.com` |
| Copy default voice to project | `cp .claude/data/voice-guide-default.md voice-guide.md` |
| View today's report | `cat progress/$(date +%Y-%m-%d).md` |
| View today's twitter post | `cat progress/$(date +%Y-%m-%d)-twitter.md` |
| View today's linkedin post | `cat progress/$(date +%Y-%m-%d)-linkedin.md` |
| View today's wip posts | `cat progress/$(date +%Y-%m-%d)-wip.md` |
| Set wip.co project hashtag | `WIP_PROJECT_HASHTAG=#myproject` |

---

*`/dailyreport` turns structured progress logs into a daily report plus voice-aligned
blog, social, and wip.co posts, using the same voice guide system as `/blog`. Pure
Claude-native, no API keys required.*
