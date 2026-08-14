---
name: dailyreport
description: Generate a daily progress report plus a voice-aligned post, X thread, LinkedIn post, WIP line and image specs from your project's progress logs
---

# /dailyreport Command

Turn today's work from `progress.md` into a structured daily report, then into a publishable
package: a long-form post, an X thread, a LinkedIn post, a WIP.co line and the image specs.
Voice-aligned, Claude-native, no API keys required.

`/dailyreport` is the progress-log counterpart to `/blog`. Where `/blog` takes any topic you
want to write about, `/dailyreport` parses your structured changelog and narrates the day.
Both commands share the same voice guide, the same package shape and the same publish
handoff.

**Canonical spec.** When `~/shared/reference/content-standard.md` is present on this
machine, it is the source of truth for the package: the five outputs, the frontmatter, the
social shapes and the publish handoff. This command implements it. Where this file
deliberately differs, the divergence is marked **DIVERGENCE** and says why. Anything else
that disagrees with the standard is a bug in this file, not a local exception
(A11-ISS-29).

## USAGE

```bash
/dailyreport
```

No arguments. Reads the current day's work from `progress.md`, creates or updates the
daily report, regenerates the package.

## WHAT IT DOES

### First run of the day

Creates `progress/YYYY-MM-DD.md` capturing:

- **Completed milestones** grouped by category (features, fixes, infrastructure, docs)
- **Issues encountered** with root-cause analysis when available
- **Lessons learned** and patterns noticed
- **Metrics** when present in the source logs
- **Next steps** for tomorrow

Then generates the publishable package from that report.

### Subsequent runs the same day

Updates the existing `progress/YYYY-MM-DD.md` with new work added since the last run,
then regenerates the package so it reflects the full day.

## OUTPUT FILES

**The raw daily report stays in the repo.** It is project state, not content:

```
progress/
└── 2026-04-11.md            # Raw daily report (source of truth for the day)
```

**The package is staged where the publish tool can reach it** — five files, all in the same
directory, because jpub finds companions beside the post:

```
~/shared/content/drafts/
├── 2026-04-11-cron-job-ate-my-inbox.md            # The post
├── 2026-04-11-cron-job-ate-my-inbox-twitter.md    # X thread
├── 2026-04-11-cron-job-ate-my-inbox-linkedin.md   # LinkedIn post
├── 2026-04-11-cron-job-ate-my-inbox-wip.md        # WIP.co lines
└── 2026-04-11-cron-job-ate-my-inbox-images.md     # Image specs
```

File naming: `YYYY-MM-DD-slug.md`, where the slug comes from the title (see Step 6), not
from the date alone. A package named after the date alone publishes at a URL nobody can
read.

### Where the package is staged

Resolution order (first hit wins):

1. `$CONTENT_DRAFTS_DIR` env var, if set
2. `~/shared/content/drafts/` when `~/shared/content/` exists — **the default**
3. `progress/` inside the current repo, with a printed warning

Why the vault path is the default: `~/DevProjects/` does not sync between machines and
`~/shared/` does. A package staged inside a repo cannot be reached from another machine, so
anything scheduled elsewhere cannot publish it. On 2026-08-13 a package written to a repo
had to be hand-copied into the vault before a scheduled social post could see it.

**DIVERGENCE (deliberate):** entries 1 and 3, the env override and the repo-local fallback,
are not in the standard, which stages to the vault path and nowhere else. Both exist because
this command deploys to projects that have no `~/shared/` at all. When the fallback fires,
say so in the report — a repo-local package is not reachable from another machine.

## VOICE ALIGNMENT

The package is drafted to match a voice profile loaded from a markdown file. Resolution
order (first hit wins):

1. **`DAILYREPORT_VOICE_GUIDE` env var** — absolute or relative path to any markdown file
2. **`voice-guide.md`** in project root
3. **`.claude/voice-guide.md`**
4. **`docs/voice-guide.md`**
5. **The canonical guide** — `~/DevProjects/JamieWatters/Documents/Foundation/jamie-watters-voice-guide.md`
6. **Its synced mirror** — `~/shared/skills/user/jamie-voice/references/jamie-watters-voice-guide.md`
7. **Bundled fallback** — `.claude/data/voice-guide-default.md` (ships with AGENT-11)

The `jamie-voice` skill describes itself as the voice authority and the other content
skills call it rather than carrying their own rules. Entry 5 is the canonical file that
skill was built from, which is what `jamie-content` reads in Claude Code. Entry 6 is the
skill's own copy of it, checked byte-identical by `~/shared/scripts/sync-audit.sh` and
reachable from every machine because `~/shared/` syncs where `~/DevProjects/` does not — so
on a machine without the site repo, entry 6 is the one that resolves. Entry 7 is a copy that
ships inside AGENT-11: copies drift silently, so it is the fallback for installs that reach
neither of the others, not a peer. Say which one was loaded, and when the bundled fallback
is used, say that it is a copy.

**DIVERGENCE (deliberate):** entries 1 to 4 outrank the authority. The standard simply says
to apply `jamie-voice`. A project-level override exists because this command deploys to
other people's repos, which have their own voice. On a machine where the authority is
reachable, a stray `voice-guide.md` in the repo silently wins, so say which file loaded
every time.

Whichever guide loads, it enforces:

- **British spelling** throughout (colour, realise, favour, practise)
- **No AI-tell vocabulary** — banned list includes delve, tapestry, pivotal, leverage,
  foster, harness, empower, streamline, transformative, game-changing, seamless, robust,
  moreover, furthermore, and 30+ others
- **No stock AI constructions** — no "it's not just X, it's Y," no rule-of-three
  adjective stacks, no em dashes in published prose, no bullet-point-with-bolded-headers
- **Varied sentence and paragraph length** — short punches mixed with longer lines
- **Dry, understated humour** delivered straight (Adams/Pratchett/Vonnegut/Heller)
- **Pub test**: if you wouldn't say it out loud to a friend, it doesn't ship

### Writing your own voice guide

Copy the bundled fallback to your project root and adapt it:

```bash
cp .claude/data/voice-guide-default.md voice-guide.md
# Then edit voice-guide.md to reflect your own voice
```

Both `/dailyreport` and `/blog` read from the same chain, so one edit updates both
commands. The file is passed verbatim to Claude as drafting instructions — be specific.

## SOCIAL LINK STRUCTURE

**The post URL is mandatory in all three social outputs.** The standard gives it no
condition, and a tweet with no route back to the post is the irreversible half of the
package going out for nothing.

**X thread:** the last tweet **ends** with the post URL, `<base-url>/journey/<slug>`. No
label, no hashtags.

**LinkedIn:** the post ends with `Full piece: <base-url>/journey/<slug>` on its own line,
then a final line of exactly three PascalCase hashtags.

**WIP:** the line carries the post URL.

The base URL comes from `DAILYREPORT_BASE_URL` at write time and must include the scheme.
If the value has none, write `https://` in front of it: `jamiewatters.work/journey/x` is
not the form the standard specifies and is not reliably a link. The path is
`/journey/<slug>`, which is where `jpub` publishes. Never `/progress/<date>`.

**If `DAILYREPORT_BASE_URL` is unset, do not guess a domain.** Write the social files
without the URL, say so at the top of the report, and **do not offer the social handoff at
all** until it is set. An unlinked social package is not publishable, so the second message
in Step 15 does not happen.

**DIVERGENCE (deliberate):** the social outputs may carry an optional `Try it:
<product-url>` line, which the standard does not have. This command deploys into product
repos where the day's work is about a live thing the reader can use. It is written only when
`PRODUCT_URL` is set — on the final tweet for X, mid-post for LinkedIn — and omitted
entirely otherwise. On X it goes **before** the post URL: the tweet still ends with the
URL.

## AGENT INSTRUCTIONS

When the user invokes `/dailyreport`, you (Claude) execute the following steps directly.
Do not delegate. Do not call any Python script. Do not use an external API.

### Step 1: Determine today's date

Use the current date in `YYYY-MM-DD` format. This drives the report filename and the
package's date prefix.

### Step 1.5: Resolve environment and the staging directory

Read these env vars with Bash (use `echo` so an unset var returns empty):

```bash
echo "DAILYREPORT_BASE_URL=$DAILYREPORT_BASE_URL"
echo "PRODUCT_URL=$PRODUCT_URL"
echo "CONTENT_DRAFTS_DIR=$CONTENT_DRAFTS_DIR"
```

Then resolve the staging directory by the order in "Where the package is staged" above,
and check whether `~/shared/content/` exists before falling back.

**Never guess or hallucinate a URL.** If an env var is unset, the line is simply not
written. For the post URL, see the mandatory-link rule above: an unlinked social package is
written but never handed to the publish step.

### Step 2: Load the voice guide

Walk the resolution order in the Voice Alignment section above and read the first file that
exists. If an env var is set but the file is missing, print a warning and fall through to
the next entry rather than stopping.

Announce which guide was loaded and its path:

```
🎙️  Voice guide: <source description> → <path>
```

Examples:
```
🎙️  Voice guide: env DAILYREPORT_VOICE_GUIDE → /home/alice/my-voice.md
🎙️  Voice guide: project file → ./voice-guide.md
🎙️  Voice guide: canonical → ~/DevProjects/JamieWatters/Documents/Foundation/jamie-watters-voice-guide.md
🎙️  Voice guide: synced mirror (jamie-voice skill) → ~/shared/skills/user/jamie-voice/references/jamie-watters-voice-guide.md
🎙️  Voice guide: bundled fallback copy → .claude/data/voice-guide-default.md
```

If nothing resolves at all, print a warning saying so and fall back to the scrub rules in
Step 13, which are an echo of the guide's own lists. Do not invent a voice — the rules are
specific and belong to the guide.

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

Write to `progress/YYYY-MM-DD.md` in the repo. If the file already exists, merge new work
in — don't wipe prior content. Structure:

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

### Step 6: Title the post through `jamie-titles`

**Do not invent the title here.** `jamie-titles` owns the title rubric. Load it — invoke the
skill if it is registered in this session, otherwise read
`~/shared/skills/user/jamie-titles/SKILL.md` directly, which is how Claude Code reaches it —
then apply its rubric and present its five scored candidates with the one it recommends.
That skill's own frontmatter requires the content commands to call it rather than writing
their own rules, and a second rubric in this file would be a second source of truth. On
2026-08-13 a title written locally scored 3 out of 5 against that skill's rubric, below its
own discard threshold, and had to be redone.

If `jamie-titles` is not on this machine at all, apply its published gate as a minimum:
name the subject nouns and the actual finding, front-load the searchable terms in the first
sixty characters, use a real verified number or none at all, and never a curiosity gap with
no subject ("What I learned from…"). Say that the skill was unavailable.

"Daily Update — April 11" is not a title. The slug comes from the chosen title: lowercase,
hyphenated, 3-6 words.

### Step 7: Draft the post

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
- **Length**: 700-1500 words. Shorter if the day doesn't justify more. Respect the
  reader's time.
- **Markdown**: H2 headers (`##`) only when the reader genuinely needs a signpost.
  `---` for major shifts. Code fences for code or command lines. No bold-header
  bullet lists. No emoji in headers.
- **Do not repeat the title as an H1.** The frontmatter title is the heading.
- **No author-bio or contact footer in the body.** The site template renders the
  canonical bio on every post.
- **Close with a concrete action or a flat statement.** Never a rhetorical question,
  never a motivational flourish, never a summary that restates what the reader just read.
- **Never invent a relative time reference.** If a date is in the source, use the date.
- **Report observed behaviour, not intent.** When writing up what a tool actually does, say
  what was observed and under what conditions. Do not impute malice to a default. This
  applies to all tool-testing and privacy content.

### Step 8: Derive the X thread

Derive it from the post. Do not chop the post up.

- **6-10 tweets**, separated by `---` on its own line, compressed hard.
- Each tweet **under 280 raw characters**. Count the URL exactly as written; never assume
  link shortening will save you.
- The first tweet is a standalone hook. Every tweet stands alone — someone seeing the
  fourth in isolation must get something from it.
- No `1/9` numbering. No hashtags unless riding a specific trending tag.
- The last tweet **ends** with the post URL, `<base-url>/journey/<slug>`, scheme included.
- Optional `Try it: <product-url>` on that last tweet when `PRODUCT_URL` is set, placed
  before the post URL so the tweet still ends with it.
- **No templates**: no "Shipped X today 🚀", no "Learned Y the hard way". Write fresh.

### Step 9: Derive the LinkedIn post

- **200-400 words.** Longer than a tweet, shorter than the post.
- Open with the most arresting line of the day — a counter-intuitive claim, a surprising
  finding, the thing that broke. Not preamble. The first 140 characters (what shows before
  "see more") must carry weight on their own. No "Excited to share...".
- Short paragraphs. One idea per line. White space is a feature.
- Register: smart colleague sharing a real lesson. Not thought leader dropping wisdom.
- It must resolve as a **complete read on its own**. The link is for people who want more.
- Optional `Try it: <product-url>` mid-post when `PRODUCT_URL` is set.
- End with `Full piece: <base-url>/journey/<slug>` on its own line.
- Final line: exactly **3 PascalCase hashtags** (1 broad + 2 niche), each with `#`. No
  emoji anywhere in the body.

### Step 10: Derive the WIP.co lines

WIP.co is a build-in-public community where members post short "shipped" updates tied to
project hashtags. The convention is a public changelog line per completed item — "Fixed
login bug #myapp" not "Working on auth later".

**Write one line by default: the publication line.** It announces the post and carries its
URL, exactly as the standard's Output 4 does:

`Published a new post: <title>. <one-line hook>. <base-url>/journey/<slug> #tag`

Every line in this file becomes a separate public todo the moment `--wip` runs, and the
review gate is the live blog page, not this file. So a day with nine milestones does not
silently become nine public posts. **Extra milestone lines are written only when the user
asks for them**, and when they do, draw from the milestone sections of the raw report
(Features, Fixes, Infrastructure) and never from Lessons Learned, unresolved issues or Next
Steps, because those are not completed work.

Each line must:
- Be **under 200 characters** (shorter is fine — aim for 40-150)
- Start with a past-tense action verb: Published, Shipped, Fixed, Deployed, Added, Deleted,
  Refactored, Wrote, Merged, Rewrote, Converted, Removed, Renamed
- Describe **what was completed** in one specific sentence
- Carry the post URL, which the standard requires and which is what makes the todo checkable
- Carry the hashtag at the end
- Follow the voice guide for spelling (British) and banned vocabulary
- Be a single line, no newlines within a post

**Hashtag resolution** (first hit wins):

1. `WIP_PROJECT_HASHTAG` env var
2. A tag from the known product list (`#aimpactscanner`, `#plebtest`, `#modeloptix`,
   `#isotracker`, `#llmtrader7`, `#llmtxtmastery`, `#aisearchmastery`) **only when the work
   genuinely is about that product**
3. `#jamiewatters` when publishing to `jamiewatters.work` — the writing project (blog,
   videos, books), and the default for work that is not about a product
4. `#buildinpublic` otherwise

On WIP the hashtag is what files the todo under a project, so a wrong tag misfiles it and no
tag merely leaves it unattached. **Never derive the tag from the repo or directory name.** A
day of work that merely happened inside a product's repo is not necessarily work on that
product, and that derivation is the inversion this ordering fixes.

**DIVERGENCE (deliberate):** entries 1 and 4 are not in the standard, which gives the
closed product list and `#jamiewatters`. They exist because this command deploys to other
people's repos, where neither the product list nor Jamie's writing tag means anything.

### Step 11: Write the image specs

Specs, not files — the image is produced downstream, but the spec must exist. Without it a
package ships with no image, and `jpub` then publishes text-only social silently.

Per image, supply:
- **placement** — hero, after section N, or which tweet
- **purpose** — one line on what it informs. "Breaks up text" is not a purpose.
- **how it gets made** — by the routing rule below
- **alt text**
- **filename** — `post-slug.png` for the hero, `post-slug-2.png`, `-3`… for inline

**Routing rule, decided per image before any prompt is written.** Does the image contain a
count, a label, or a specific relationship between parts?

- **Yes → build it as SVG**, then render to PNG with `~/shared/scripts/svg-to-png.sh` where
  that exists (Chrome headless at 2x, downsampled, pngquant), otherwise say which renderer
  to use. Image models cannot hold exact counts, labels or arrow directions; they
  approximate, and an approximated diagram is a wrong diagram. Keep the `.svg` source beside
  the drafts so labels stay editable.
- **No, it is a mood or metaphor with no exact content → image model.** Write the
  generation prompt: brand style block plus the post's metaphor.
- **It is a real thing that exists → screenshot or data viz.** Supply a source pointer,
  not a prompt. A daily report usually has one: the terminal output, the failing test, the
  dashboard.

**Brand style block, required on every route, not just the image-model one.** State the
palette explicitly in the spec — background, ink, muted text, rules,
one warm accent, one cool accent — and say what each accent *means* in that image. There is no single recorded
palette yet, so each post decides and records its own.

**How many:** hero + `floor(section_count / 2)`, clamped to 1-5, where sections are major
breaks after the intro. **The gate, per image: does it teach something?** Build-log posts
dense with diagrams or screenshots may exceed the cap — those carry real information. Cut
any image that does not inform.

**Format:** the hero ships as a raster PNG, roughly 16:9 (~1200×675), under ~300KB. Never
reference a `.svg` from frontmatter. The hero goes in frontmatter (`image:` + `imageAlt:`);
inline images are referenced in the body as `![alt](/images/blog/post-slug-N.png)` at their
placement points. The `/images/blog/` prefix is mandatory — `jpub` resolves images through
that fixed prefix and any other prefix uploads nothing, silently.

**Where the image files go:** `~/shared/content/blog/images/<name>.png`. That directory is
hardcoded in `jpub`, so it applies wherever the markdown lives. On publish, `jpub` uploads
the hero and every inline body image to R2 and rewrites the body paths. A file missing from
that folder prints a warning and 404s on the live page; publishing still succeeds. R2
caching is immutable: a regenerated image needs a NEW filename (`post-slug-v2.png`).

**On a machine with no `~/shared/`** — the same case that triggers the repo-local staging
fallback — there is nowhere for `jpub` to find an image, because that path is hardcoded and
this command cannot change it. Write the specs anyway, keep any produced files beside the
package, and say plainly in the report that the hero will not upload from here. A silent
text-only publish is the failure this avoids.

### Step 12: Write the package

Write the five files to the staging directory resolved in Step 1.5, creating it if missing.
The raw report from Step 5 stays in the repo.

**The post** — `YYYY-MM-DD-slug.md`, frontmatter exactly these fields:

```yaml
---
title: "The afternoon the cron job ate my inbox"
slug: "cron-job-ate-my-inbox"
excerpt: "What the reader walks away with, and why this piece is not the other hundred."
tags: [cron, incident-response]
topics: [building]
editorialType: build-log
image: /images/blog/cron-job-ate-my-inbox.png
imageAlt: "A scheduled job deleting mail faster than the alert can fire"
---
```

- **`topics`** — 1-2 values from the controlled seven: `ai`, `ai-search`, `building`,
  `open-source`, `trading`, `thinking`, `business`. This is what the site's topic pages
  index on. `jpub` silently drops anything outside the list, and a post with no valid topic
  is findable only by direct link. Free-form colour goes in `tags`, never here.
- **`editorialType`** — `build-log` for a daily report, which is what this command makes.
  Use `essay` only when the day's write-up is genuinely a curated argument rather than a
  field report. `jpub` defaults a missing value to `build-log`.
- **`excerpt`** — the dek, and the one field that sells the click. It becomes the meta
  description, the RSS description and the card line. Write it as overt benefit plus
  dramatic difference: what the reader walks away with, and why this piece is not the
  hundred others. 1-3 sentences, under ~320 characters. Test: reading only the title and
  the dek, does a stranger know what they GET?
- **`tags`** — free-form, lowercase, hyphenated if multi-word.
- **`image` / `imageAlt`** — the hero, whenever there is one. **`imageCaption`** is optional
  and has its own database column; prefer it to an italic caption in the body.
- **`draft: true`** is optional and hides the post. Use it to stage something that must not
  appear yet.
- **`readTime`** — omit it. `jpub` computes it from the body, which beats a guess. Write it
  only as a deliberate override, knowing it silently wins.
- Do **not** write `date`, `project`, `author` or `coverImage`. `jpub` ignores all four, and
  the publish date comes from the filename and the publish run.

**The three social files** — plain text, exactly what gets published and nothing else:

- `YYYY-MM-DD-slug-twitter.md` — the tweets, separated by `---` on its own line. No
  frontmatter, no heading, no character counts, no commentary. The file must not begin
  with `---`.
- `YYYY-MM-DD-slug-linkedin.md` — the post text. No frontmatter, no heading.
- `YYYY-MM-DD-slug-wip.md` — one todo per line. Lines starting `#` are skipped.

**This format is load-bearing, and it is what makes the thread possible.** `jpub` publishes
a social file one of two ways. A file whose first line is a `# Twitter/X`-style heading is
read as "everything between the first and second `---`" — which silently truncates a thread
to its first tweet, because the separators between tweets are those same `---` lines. A
file with no heading is read whole and split on `---` into the full thread. Confirmed by dry
run on 2026-08-14: the same three-tweet content reports `X/Twitter: 1 tweet` with a heading
and `X/Twitter: 3 tweets` without one. So: no heading,
no metadata, nothing before the first tweet. Character counts go in the report to the user,
never into the file. Anything you put in the file, `jpub` publishes.

**The image specs** — `YYYY-MM-DD-slug-images.md`, one file for every image in the package,
in the Step 11 shape. `jpub` ignores this file; it is for whoever makes the images.

### Step 13: Voice scrub and checks

The loaded voice guide is binding, and its blacklist is the live one. The list below is an
echo of it, kept here so an install that resolves nothing still has something to scrub
against — where the two differ, **the guide wins**. This is the one place the file repeats a
rubric it does not own, and it is a fallback rather than a second authority.

Scan every written output for any word on the AI-tell blacklist:

> delve, tapestry, intricate, pivotal, underscore, foster, testament, multifaceted,
> comprehensive, myriad, leverage (as verb), embark, realm, beacon, paradigm, synergy,
> unlock, harness, empower, streamline, spearhead, cornerstone, linchpin, bedrock,
> hallmark, catalyst, transformative, game-changing, revolutionary, cutting-edge,
> robust, seamless, holistic, groundbreaking, ever-evolving, moreover, furthermore

If any survived, **rewrite** the affected sentence before writing the file. Do not
just warn — you have full edit control. Fix it now.

Also check and rewrite: rule-of-three adjective stacks, "it's not just X, it's Y"
constructions, em dashes anywhere in published prose, bullet points starting with
bolded phrases that the following sentence restates.

**Truth check.** Never write a number, date, duration, quantity or price that was not given
or verified. The daily report is full of real numbers; use those, and write
`[VERIFY: what is missing]` rather than an estimate for anything that is not in the log.

**Plain-language / cold-read check.** Read every sentence as someone who does NOT know the
project, the jargon, or the references. Flag and rewrite:
- Named laws, theories or concepts used as shorthand ("Goodhart's law", "the Pareto
  frontier"). Explain the idea in plain words or cut the name.
- Insider metaphors that only land if you built the thing ("a gate the agent can't edit").
  Say what it actually is.
- Any sentence that is clever before it is clear. Clear wins. Apply the pub test.

**URL consistency check** — the URL in every social file must use the *slug only*, not the
file name. The `<slug>` is the value of the `slug:` field in the post's frontmatter (no
date prefix, no `.md` extension).

1. Extract the URL after `/journey/` from each social file.
2. Compare it to `slug:` in the post frontmatter.
3. If they differ — typically the social URL has a date prefix (`2026-05-09-my-post`)
   while the actual slug has none (`my-post`) — rewrite the social URL and re-save.

Using the file name produces a 404, because `jpub` publishes at `/journey/<slug>` read from
frontmatter. Never emit a `/blog/<slug>` or `/progress/<date>` URL.

**Character and length validation** — count actual characters, not words:
- **X**: every tweet under 280. If one is over, rewrite it to fit while keeping the hook
  and a concrete detail. Do not just trim.
- **LinkedIn**: 200-400 words, under 3000 characters. The first 140 characters must be a
  complete thought; if the hook is cut mid-sentence, rewrite the opening. Exactly three
  hashtags on the final line.
- **WIP**: each line under 200 characters, and each carries the post URL.

If any limit is breached, rewrite and recount before writing the file.

### Step 14: Report, and hand over the blog command ONLY

Print a summary:

```
✅ progress/YYYY-MM-DD.md
  📊 <N> milestones across <M> categories
  🐛 <N> issues with <M> resolved
  ✨ Post: <staging-dir>/YYYY-MM-DD-slug.md (<word count> words)
  🐦 X thread: <staging-dir>/YYYY-MM-DD-slug-twitter.md (<n> tweets, longest <char>/280)
  💼 LinkedIn: <staging-dir>/YYYY-MM-DD-slug-linkedin.md (<words> words, hook <n>/140)
  🚢 WIP.co: <staging-dir>/YYYY-MM-DD-slug-wip.md (<N> lines, <hashtag>)
  🖼️  Image specs: <staging-dir>/YYYY-MM-DD-slug-images.md (<n> images)
  🎙️  Voice guide: <source>

📋 Publish the post:

  jpub <staging-dir>/YYYY-MM-DD-slug.md --blog

Then open <base-url>/journey/<slug> and read it. When it's right, say "ship the social"
and I'll give you that command.
```

`<staging-dir>` is the directory resolved in Step 1.5, written out in full — normally
`~/shared/content/drafts/`. Always the absolute path, never a relative one, so the command
works from any terminal tab. Then show the first tweet inline as a preview:

```
X thread, tweet 1:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
<actual tweet content>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Stop there. Do not print the social command in this message.**

Why, and why "review it first" is not enough: on 2026-08-03 a handoff printed the post and
social commands together with the words "review everything before it ships", and the social
went out in the same breath as the post, unreviewed. Jamie runs the first runnable command
he is given; that is how the handoff is meant to work, so a warning beside a command is not
a gate, it is decoration. The asymmetry is the reason. The post is recoverable — `jpub`
upserts by slug, so a fix is a re-publish. A tweet, a LinkedIn post and a WIP todo are not:
they are seen, cached and indexed the moment they land, and LinkedIn cannot be read back to
confirm what went out.

**The rule: never put an irreversible command in front of the user before the reversible
one has been checked.** Post first, eyes on the live page, social second, in a separate
message. Never offer the all-platforms flag at all — there is no context in which this
command should hand over one invocation that publishes everything. The same rule lives in
`~/shared/skills/user/jamie-publish/SKILL.md`.

### Step 15: The social handoff — SECOND MESSAGE ONLY

Only after the user has read the live page and asked for it, in a message of its own:

```
  jpub <staging-dir>/YYYY-MM-DD-slug.md --x --linkedin --wip
```

Add `--dry-run` first if the user wants a preview. Never print this block in the same
message as Step 14.

Two cases where this step does not happen:
- **No base URL was configured**, so the social files carry no link to the post. Say the
  package is not shippable until `DAILYREPORT_BASE_URL` is set, and stop.
- **No WIP file was written.** Drop `--wip` from the command. `jpub` auto-generates a todo
  when the flag is passed with no file, which posts publicly something nobody wrote.

## CONFIGURATION

No API keys required. Optional environment variables in `.env.mcp`:

```bash
# Voice guide override (shared with /blog)
DAILYREPORT_VOICE_GUIDE=/path/to/voice-guide.md

# Where the content package is staged. Defaults to ~/shared/content/drafts/
# when ~/shared/content/ exists, then to a repo-local progress/ directory.
CONTENT_DRAFTS_DIR=/path/to/drafts

# Base URL for post links in social posts.
# The path is <DAILYREPORT_BASE_URL>/journey/<slug>.
# If unset, the URL is omitted rather than guessed.
DAILYREPORT_BASE_URL=jamiewatters.work

# Product URL for the optional "Try it:" line (e.g. modeloptix.com, plebtest.com).
# If unset, the line is omitted rather than leaving a placeholder.
PRODUCT_URL=yourdomain.com

# WIP.co project hashtag (shared with /blog). Only set this when the repo's
# posts genuinely are about that product — see Step 10.
WIP_PROJECT_HASHTAG=#agent11
```

That's the whole config surface. `/dailyreport` no longer uses `OPENAI_API_KEY`,
`DAILYREPORT_MODEL`, or `DAILYREPORT_ENABLE_SOCIAL` — those were relics of the old
Python-script pipeline. Claude Code does the writing now.

## PUBLISHING WORKFLOW

1. Publish the post: `--blog`. It writes to the database and uploads the hero and every
   inline body image. Nothing to commit, no deploy.
2. Open `<base-url>/journey/<slug>` and read the live page.
3. Only then publish the social, as a separate step.

Re-running the post publish on an existing slug updates it rather than duplicating it, so a
mistake caught on the live page is a re-publish. The social posts have no such undo.

To post by hand instead: open each social file and copy its whole contents. They contain
nothing but the text that gets published.

## TROUBLESHOOTING

**Nothing in progress.md for today?**
- `/dailyreport` won't invent content. Log your work to `progress.md` first, then run
  `/dailyreport`. The `/coord` and `/pmd` commands both write to `progress.md`
  automatically.

**Output doesn't sound like your voice?**
- Drop a `voice-guide.md` in your project root with your own rules
- The voice guide is passed to Claude as drafting instructions — more specific rules
  produce more specific output

**Voice guide not loading?**
- Check the announcement line: `🎙️  Voice guide: <source>`
- If it says "bundled fallback copy" on a machine that has `~/shared/`, the authority path
  is wrong or unreadable — fix that rather than editing the copy, which drifts silently

**Post published but not on any topic page?**
- `topics` was missing or held a value outside the controlled seven. `jpub` prints
  `Topics: (none — will not appear on topic pages)` on a dry run; that line is the check.

**Only the first tweet went out?**
- The twitter file had a heading before the first tweet, so `jpub` read only the block
  between the first two `---`. Remove everything above the first tweet.

**Package staged in the repo instead of the vault?**
- `~/shared/content/` was not found. The package is not reachable from another machine
  until it is moved there.

## INTEGRATION WITH AGENT-11

`/dailyreport` works alongside:

- **`progress.md`** — primary data source for all logged work and issues
- **`project-plan.md`** — secondary source for task completion verification
- **`CLAUDE.md`** — project context and name
- **`/blog`** — complementary command for topic-driven posts (same voice guide, same
  package shape, different input)
- **`/report`** — longer-form stakeholder progress reports
- **`/pmd`** — root cause analysis that feeds into the issue log
- **`jamie-titles`** — owns the title rubric (Step 6)
- **`jamie-voice`** — the voice authority (Step 2)
- **`jamie-publish`** — owns the publish mechanics and the same blog-first gate

## QUICK REFERENCE

| Task | Command/Setting |
|------|-----------------|
| Create or update daily report | `/dailyreport` |
| Set custom voice guide path | `DAILYREPORT_VOICE_GUIDE=/path/to/file.md` |
| Set custom domain for links | `DAILYREPORT_BASE_URL=yourdomain.com` |
| Stage the package elsewhere | `CONTENT_DRAFTS_DIR=/path/to/drafts` |
| Copy fallback voice to project | `cp .claude/data/voice-guide-default.md voice-guide.md` |
| View today's report | `cat progress/$(date +%Y-%m-%d).md` |
| Set WIP.co project hashtag | `WIP_PROJECT_HASHTAG=#myproject` |

---

*`/dailyreport` turns structured progress logs into a daily report plus a voice-aligned
post, X thread, LinkedIn post, WIP line and image specs, staged where the publish tool can
reach them. Pure Claude-native, no API keys required.*
