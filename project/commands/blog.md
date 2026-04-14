---
name: blog
description: Draft a voice-aligned blog post (plus Twitter/X and LinkedIn versions) on any topic, pulling context from the repo
---

# /blog Command

Generate a long-form blog post and matching social posts (Twitter/X + LinkedIn) on any
topic you specify. Unlike `/dailyreport` — which turns a structured progress log into a
build-in-public update — `/blog` is for free-form writing: thought pieces, tutorials,
opinion posts, deep dives, explainers, anything that isn't tied to a daily changelog.

`/blog` is Claude-native. No Python script, no API key required. Claude reads the
voice guide, pulls relevant context from the repo, and drafts all three artifacts
directly. `/dailyreport` works the same way — both commands share the same voice
guide file and drafting pipeline.

## USAGE

```bash
# Inline topic — quick ideas
/blog why I stopped using feature flags for small teams

# Brief file — longer, structured inputs
/blog briefs/refactor-postmortem.md

# Topic with explicit context files
/blog the coffee button bug story --context progress/2025-11-19.md src/coffee.ts
```

**Argument forms:**
- **Inline topic** — a short phrase describing what to write about
- **Brief file** — path to a markdown file containing a longer brief (bullet points,
  outline, supporting notes, quotes, whatever you want to feed in)
- **Optional `--context <files...>`** — extra files Claude should read before drafting
  (code, logs, notes, prior posts). Claude will also autoload `README.md` and
  `CLAUDE.md` if present.

## WHAT IT DOES

When you run `/blog <topic>`, Claude will:

1. **Resolve the voice guide** — same chain as `/dailyreport`:
   - `DAILYREPORT_VOICE_GUIDE` env var (shared across both commands)
   - `voice-guide.md` / `.claude/voice-guide.md` / `docs/voice-guide.md` in project root
   - Built-in default (Jamie Watters voice)
2. **Gather context** — read `README.md`, `CLAUDE.md`, the brief file (if given), any
   `--context` files, and anything the topic obviously depends on (e.g. if you're
   writing about a bug, Claude reads `progress.md` for the fix history).
3. **Draft the long-form post** — a full blog post following the voice guide to the
   letter. No preamble, concrete specifics, varied sentence length, no AI-tell
   vocabulary, ends with action or a genuine question.
4. **Derive the Twitter/X version** — hook + one concrete detail, 180-260 chars,
   dual-link structure (product link first, article link last for OG preview).
5. **Derive the LinkedIn version** — 800-1000 char sweet spot, first 140 chars as a
   standalone hook, short one-idea-per-line paragraphs, genuine closing question.
6. **Derive the wip.co post** — one short "shipped" update for the build-in-public
   community, tied to a project hashtag.
7. **Write all four to disk** and print file paths.

## OUTPUT FILES

Blog artifacts land in a `blog/` directory (created if missing):

```
blog/
├── 2026-04-11-feature-flags-small-teams.md           # Long-form blog post
├── 2026-04-11-feature-flags-small-teams-twitter.md   # Twitter/X (copy-paste ready)
├── 2026-04-11-feature-flags-small-teams-linkedin.md  # LinkedIn (copy-paste ready)
└── 2026-04-11-feature-flags-small-teams-wip.md       # wip.co post (copy-paste ready)
```

File naming: `YYYY-MM-DD-slug.md` where slug is derived from the topic (lowercased,
hyphenated, stop-words removed, capped at ~60 chars).

## VOICE ALIGNMENT

`/blog` uses the same voice guide system as `/dailyreport`. See the
[Voice Alignment section of /dailyreport](dailyreport.md#voice-alignment) for the full
resolution chain and how to customise it. Short version:

- Drop a `voice-guide.md` in your project root and it's picked up automatically
- Or set `DAILYREPORT_VOICE_GUIDE=/path/to/guide.md` to point anywhere
- Or rely on the built-in default (Jamie Watters voice — British, working-class, dry
  humour, no AI tells, pub test applied)

Custom voice guides written for `/dailyreport` work for `/blog` without any changes.
One guide, both commands.

## DUAL-LINK STRUCTURE (SOCIAL POSTS)

Same OG-preview optimisation as `/dailyreport`: social posts include two links ordered
so the last one wins the preview card.

**Twitter/X:**
```
<hook + specific detail>

Try it: <product-url>

Full post: <DAILYREPORT_BASE_URL>/journey/2026-04-11-feature-flags-small-teams

#buildinpublic
```

**LinkedIn:**
```
<140-char hook that stands alone>

<short paragraphs, one idea per line>
<concrete detail, named tool, number>

Try it: <product-url>

<plain closing or genuine question>

Full post: <DAILYREPORT_BASE_URL>/journey/2026-04-11-feature-flags-small-teams
```

Both URLs are resolved from env vars at write time:
- Product URL → `PRODUCT_URL` env var. If unset, the "Try it:" line is omitted.
- Blog base URL → `DAILYREPORT_BASE_URL` env var. If unset, the "Full post:" line is omitted. The path is `/journey/<slug>` (matches where `jpub` publishes).

If an env var is missing, the corresponding line is **omitted entirely** — never guessed, never left as a placeholder.

## AGENT INSTRUCTIONS

When the user invokes `/blog`, you (Claude) perform the following steps directly.
Do not delegate. Do not call a Python script. Do not use the OpenAI API.

### Step 1: Parse the argument

- If the argument is a file path that exists → treat it as a brief. Read it.
- Otherwise → treat the whole argument as an inline topic string.
- Extract any `--context <files...>` tokens separately and resolve each to a file path.

### Step 1.5: Resolve URL environment variables

Before drafting anything, read these env vars with Bash calls (use `echo` so an unset var returns empty):

```bash
echo "DAILYREPORT_BASE_URL=$DAILYREPORT_BASE_URL"
echo "PRODUCT_URL=$PRODUCT_URL"
```

Record the values. They affect the social posts:
- `DAILYREPORT_BASE_URL` → used to construct `Full post: <DAILYREPORT_BASE_URL>/journey/<slug>`. If empty, **omit the "Full post:" line entirely**.
- `PRODUCT_URL` → used to construct `Try it: <PRODUCT_URL>`. If empty, **omit the "Try it:" line entirely**.

**Never guess or hallucinate these URLs.** If an env var is unset, the line is simply not written. The reader sees a clean post without the link rather than a broken link to a made-up domain.

### Step 2: Load the voice guide

Resolution order (first hit wins):

1. `$DAILYREPORT_VOICE_GUIDE` env var → read that file if it exists
2. `./voice-guide.md` → read it
3. `./.claude/voice-guide.md` → read it
4. `./docs/voice-guide.md` → read it
5. **Default voice guide** — read `.claude/data/voice-guide-default.md`
   (ships with AGENT-11). Both `/blog` and `/dailyreport` read from this same file,
   so whatever is documented there is the authoritative default voice.

If step 5 fails because the file is missing (unusual — only happens if the install is
corrupted or incomplete), print a warning and use your best understanding of the
voice alignment rules documented in `.claude/commands/dailyreport.md`. Do not invent
a voice — the rules are specific and must come from the guide file.

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

### Step 3: Gather context

Always attempt to read (ignore quietly if missing):
- `README.md`
- `CLAUDE.md`
- `.claude/CLAUDE.md`

Always read (fail loudly if missing):
- The brief file, if the argument was a path
- Every file passed via `--context`

Intelligently read (use judgment based on topic):
- If the topic mentions a bug, a fix, or an incident → read `progress.md`
- If the topic mentions a specific file, module, or feature → read that file
- If the topic mentions a recent change → check `git log --oneline -20` for context
- If the topic mentions an architectural decision → read `architecture.md` if present

Do not read the entire repo. Be surgical. The goal is enough context to write with
concrete specifics, not a full audit.

### Step 4: Draft the long-form blog post

Apply the voice guide as your system prompt — every rule in it applies to this draft,
no exceptions.

Structural requirements:
- **Open in the middle of something** — tension, a decision, the moment something
  broke or clicked. No preamble. No "In this post I will..." No "Today I want to
  talk about..."
- **Systems-first** — show how the pieces connect before zooming into details
- **Concrete specifics** — numbers, tool names, dates, quotes, file names. Never use
  a vague adjective where a specific noun would do.
- **Varied sentence and paragraph length** — mix short punches with longer textured
  lines. At least one single-sentence paragraph if the piece runs over 300 words.
- **Length**: 400-1200 words. Shorter if the topic doesn't justify more. Respect the
  reader's time.
- **Markdown**: H2 headers (`##`) only when the reader genuinely needs a signpost.
  `---` for major shifts. Code fences for code. No bold-header bullet lists. No
  emoji in headers.
- **Close with a concrete next step, a genuine question, or a plain statement of
  where things stand.** Never a motivational flourish. Never a summary that restates
  what the reader just read.

**Title**: a specific hook, not a template. "The afternoon the cron job ate my inbox"
beats "Thoughts on Automation." Make it something someone would click.

### Step 5: Derive the Twitter/X version

- Read the long-form post. Pull the sharpest single idea.
- First line is the hook. Specific and slightly surprising. No emoji in the hook.
- One concrete detail from the post. A number, a tool name, what actually happened.
- 180-260 characters (280 is the hard limit — use the room you have).
- Dual-link structure:
  1. `Try it: <product-url>` — resolve from `PRODUCT_URL` env var. If unset,
     omit this line entirely rather than leaving a placeholder.
  2. Blog link last (for OG preview): `Full post: <base-url>/journey/<slug>`
     - Resolve `<base-url>` from the `DAILYREPORT_BASE_URL` env var at write time (read it with a quick `Bash` call like `echo "$DAILYREPORT_BASE_URL"`)
     - If `DAILYREPORT_BASE_URL` is unset or empty, **omit the "Full post:" line entirely** rather than inventing a URL
     - The path is `/journey/<slug>` to match where `jpub` publishes blog posts (`jamiewatters.work/journey/<slug>`). Do NOT use `/blog/<slug>` — that is not where published posts live.
- One hashtag, maybe two, from: `#buildinpublic #solofounder #indiehacker #devlog`
- **No templates**: no "Shipped X today 🚀", no "Learned Y the hard way". Write fresh.

### Step 6: Derive the LinkedIn version

- 800-1000 characters sweet spot. 3000 is the hard ceiling.
- First 140 characters are the hook (what shows before "see more"). Must carry
  weight on their own. No "Excited to share...", no throat-clearing.
- Short paragraphs. One idea per line. White space is a feature.
- Register: smart colleague sharing a real lesson. Not thought leader dropping wisdom.
- Dual-link structure:
  1. `Try it: <product-url>` mid-post — resolve from `PRODUCT_URL` env var. If
     unset, omit this line entirely rather than leaving a placeholder.
  2. Blog link at the end (for OG preview): `Full post: <base-url>/journey/<slug>`
     - Same resolution rules as the Twitter/X link: read `DAILYREPORT_BASE_URL`, omit the line if unset, use `/journey/<slug>` path.
- 0-2 hashtags at the very end. LinkedIn penalises spam.
- Close with a genuine question the reader might actually answer, or a plain
  statement. Never manufactured engagement ("What do you think? Drop a comment below!").

### Step 7: Derive the wip.co post

wip.co is a build-in-public community where members post short "shipped" updates
tied to project hashtags. The convention is a public changelog line per completed
item — "Fixed login bug #myapp" not "Working on auth later".

For `/blog`, generate **one** wip post. Choose the framing that fits the topic:

- **Process/work topics** (describing something you did or shipped): frame as a
  completed action. Example: `Deleted 600 lines of Python from /dailyreport #agent11`
- **Opinion/thinking topics** (describing something you realised or argued): frame
  as a publication. Example: `Published "Why I stopped using feature flags" #agent11`
  followed by the blog URL on a second line if space allows.

The post must:
- Be **under 200 characters** (aim for 50-150)
- Start with a past-tense action verb where possible
- Include the project hashtag at the end
- Follow the voice guide for spelling and banned vocabulary
- Be a single line (or two if including a URL)

**Project hashtag resolution** (same as `/dailyreport`, first hit wins):
1. `WIP_PROJECT_HASHTAG` env var
2. Derive from CLAUDE.md project name (lowercase, remove non-alphanumeric, prefix `#`)
3. Fall back to `#buildinpublic`

### Step 8: Write all four files

- Compute slug from topic: lowercase, strip punctuation, replace spaces with
  hyphens, remove stop words (a, an, the, of, for, to, in, on, and, or), cap at
  60 characters.
- Compute date: today's date in `YYYY-MM-DD` format.
- Create `blog/` directory if it doesn't exist.
- Write four files:
  - `blog/YYYY-MM-DD-slug.md` — long-form post with frontmatter (`date`, `slug`,
    `title`)
  - `blog/YYYY-MM-DD-slug-twitter.md` — Twitter/X post with character count
  - `blog/YYYY-MM-DD-slug-linkedin.md` — LinkedIn post with character count and
    hook length
  - `blog/YYYY-MM-DD-slug-wip.md` — wip.co post with character count and hashtag

### Step 9: Voice scrub

After drafting, scan all four outputs for any word on the AI-tell blacklist:

> delve, tapestry, intricate, pivotal, underscore, foster, testament, multifaceted,
> comprehensive, myriad, leverage (as verb), embark, realm, beacon, paradigm, synergy,
> unlock, harness, empower, streamline, spearhead, cornerstone, linchpin, bedrock,
> hallmark, catalyst, transformative, game-changing, revolutionary, cutting-edge,
> robust, seamless, holistic, groundbreaking, ever-evolving, moreover, furthermore

If any survived, **rewrite** the affected sentence before writing the file. Do not
just warn — this is a slash command, you have full edit control. Fix it now.

Also check for: rule-of-three adjective stacks, "it's not just X, it's Y"
constructions, em dashes more than twice per 500 words, bullet points starting with
bolded phrases that the following sentence restates. Fix each one by rewriting.

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

### Step 10: Report to the user

Print:

```
✅ Blog post created: blog/YYYY-MM-DD-slug.md (<word count> words)
  🐦 Twitter/X: blog/YYYY-MM-DD-slug-twitter.md (<char count>/280)
  💼 LinkedIn: blog/YYYY-MM-DD-slug-linkedin.md (<char count>/3000, hook <n>/140)
  🚢 wip.co: blog/YYYY-MM-DD-slug-wip.md (<char count>, <hashtag>)
  🎙️  Voice guide: <source>

📋 Ready to publish:

  jpub <ABSOLUTE_PATH_TO_REPO>/blog/YYYY-MM-DD-slug --all --dry-run

Remove --dry-run when you're happy with the preview.
```

Where `<ABSOLUTE_PATH_TO_REPO>` is the real absolute path to the current working
directory (from `pwd` or equivalent), and `YYYY-MM-DD-slug` is the blog post's
filename without the `.md` extension. For example:
`jpub /Users/jamiewatters/DevProjects/BOS-AI/blog/2026-04-12-my-post --all --dry-run`

Then show a preview of the Twitter/X post inline so the user can eyeball it without
opening the file.

## CONFIGURATION

`/blog` shares configuration with `/dailyreport`. Environment variables in `.env.mcp`:

```bash
# Voice guide override (shared with /dailyreport)
DAILYREPORT_VOICE_GUIDE=/path/to/voice-guide.md

# Base URL for blog links in social posts (shared with /dailyreport).
# Social posts will contain `Full post: <DAILYREPORT_BASE_URL>/journey/<slug>`.
# If unset, the "Full post:" line is omitted rather than guessing a URL.
DAILYREPORT_BASE_URL=jamiewatters.work

# Product URL for social posts (e.g. modeloptix.com). If unset, the
# "Try it:" line is omitted rather than leaving a placeholder.
PRODUCT_URL=yourdomain.com

# wip.co project hashtag (shared with /dailyreport). If unset, derived from
# the project name in CLAUDE.md (e.g. "AGENT-11" → #agent11)
WIP_PROJECT_HASHTAG=#myproject
```

No `OPENAI_API_KEY` required — `/blog` runs entirely through Claude.

## WHEN TO USE /blog VS /dailyreport

| Situation | Command |
|-----------|---------|
| End-of-day progress update from `progress.md` | `/dailyreport` |
| Build-in-public changelog narrative | `/dailyreport` |
| Structured capture of milestones, issues, next steps | `/dailyreport` |
| Opinion piece on a topic you care about | `/blog` |
| Tutorial or explainer | `/blog` |
| Post-mortem story (beyond the raw `/pmd` output) | `/blog` |
| Deep dive on an architectural decision | `/blog` |
| Reaction to something in the industry | `/blog` |
| Any writing that isn't tied to a daily log | `/blog` |

Both commands write in the same voice. Both produce matching social posts. The
difference is the shape of the input: `/dailyreport` parses structured progress logs,
`/blog` takes any topic you want to write about.

## PUBLISHING WORKFLOW

Same as `/dailyreport`:

1. Run the `jpub` command shown at the end of the output with `--dry-run` to preview
2. Remove `--dry-run` and run again to publish to all platforms
3. Or publish manually: open each file, copy the content between the `---` markers, paste into the platform

## EXAMPLES

**Inline topic:**
```bash
/blog why I stopped using feature flags for small teams
```

**Brief file** (`briefs/cron-incident.md`):
```markdown
# The cron job that ate my inbox

## What happened
- Scheduled cleanup job ran with wrong filter
- Deleted 8,000 emails in 90 seconds
- Recovery took 4 hours

## Key lesson
- Never run destructive jobs without a dry-run flag
- Alerting caught it too late — the damage was done before the alert fired

## Tone
- Painful but funny, lesson for other solo founders
```

```bash
/blog briefs/cron-incident.md
```

**Topic with explicit context:**
```bash
/blog the file persistence bug that nearly broke the sprint --context progress/2025-11-19.md post-mortem-analysis.md
```

## TROUBLESHOOTING

**Voice guide not loading?**
- Check the announcement line: `🎙️  Voice guide: <source>`
- If it says "built-in default" but you expected a custom guide, verify the file
  exists and the path resolution matches one of the search locations
- If `DAILYREPORT_VOICE_GUIDE` is set but points at a missing file, you'll see a
  warning and a fallback to default

**Output doesn't sound like your voice?**
- Drop a `voice-guide.md` in the project root with your own rules
- Or edit the existing one — more specific rules produce more specific output
- The voice guide is passed as the system prompt, so every rule in it is binding

**Slug is weird or too long?**
- Pass a shorter topic, or specify a brief file with a clean title

**Files not written?**
- Check the `blog/` directory exists and is writable
- Claude will create it, but if the parent directory is read-only the write fails

## INTEGRATION WITH AGENT-11

`/blog` works alongside:
- **`/dailyreport`** — same voice guide, same social post format, different input shape
- **`/pmd`** — run `/pmd` first for root cause analysis, then `/blog` to turn the
  post-mortem into a public-facing story
- **`voice-guide.md`** — your project's voice file, used by both `/blog` and `/dailyreport`

---

*`/blog` turns any topic into a voice-aligned long-form post plus matching social
versions, using the same voice guide system as `/dailyreport`. No Python script, no
OpenAI key — pure Claude.*
