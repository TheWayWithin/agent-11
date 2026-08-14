# `/blog` and `/dailyreport` vs the canonical content standard

**Date**: 2026-08-14
**Reviewed**: `project/commands/blog.md`, `project/commands/dailyreport.md` (both identical to their
`.claude/commands/` and per-repo deployed copies as at 2026-08-14).
**Compared against**: `~/shared/reference/content-standard.md` (canonical, drives the Content Studio
Project) and the four user skills in `~/shared/skills/user/` — `jamie-content`, `jamie-voice`,
`jamie-titles`, `jamie-publish`.
**Method**: not a read-through. Every gap below was either hit live while running `/blog` on
2026-08-13 in Trader-7, or verified by grep against both command files.

---

## The one that matters

**`/blog` Step 10 and `/dailyreport:534` both print `jpub <path> --all`.**

The content standard forbids exactly this, and says why:

> **Give the blog command ONLY. Do not print the social command in the same message (ISS-45).**
>
> On 2026-08-03 this handoff printed both commands together with the words "review everything before
> it ships" — and the social went out in the same breath as the post, unreviewed. Jamie runs the
> first runnable command he is given; that is how the handoff is meant to work, so a warning next to
> a command is not a gate, it is decoration.

The asymmetry is the point. A blog post is recoverable, because `jpub` upserts by slug and a fix is a
re-publish. A tweet, a LinkedIn post and a WIP todo are not: they are seen, cached and indexed the
moment they land, and LinkedIn cannot even be read back to confirm what went out.

**On 2026-08-13 I gave Jamie `--all` and he ran `--blog`.** That is luck, not design. The command
told him to do the irreversible thing and he happened not to.

The same rule is in `skills/user/jamie-publish/SKILL.md`. Both commands predate it and neither was
updated.

**Fix**: Step 10 prints the `--blog` command only, then stops. The social command is given in a
separate message after the live page has been read. Not "review it first" — the second command is
simply not printed yet.

---

## Gaps, in the order they bite

### 1. Titles are invented rather than delegated

`jamie-titles`'s own frontmatter: *"jamie-content and jamie-voice must call this skill rather than
inventing titles themselves."* `/blog` Step 4 instead carries its own two-line title guidance and
never mentions the skill.

Proven live: the title `/blog` produced on 2026-08-13 scored **3/5** against the skill's own rubric
(no verified number; sold one control when the piece covered twenty-six). The skill discards anything
at 3 or below. Jamie had to ask for the skill by name to get a title that passed.

**Fix**: Step 4 calls `jamie-titles` and presents its scored candidates. Delete the local title rules
so there is one rubric, not two.

### 2. Image specs are missing entirely

`content-standard.md` defines **five** outputs. `/blog` produces four and never mentions images. The
missing one is Output 5, `YYYY-MM-DD-slug-images.md`, carrying placement, purpose, how it gets made,
alt text and filename per image, with a routing rule for choosing the generation method.

Proven live: the post shipped with no image until Jamie asked. There was also no filename convention
to follow, so it was written as `-image-spec.md` (singular) against the standard's `-images.md`.

This matters beyond tidiness. `jpub` attaches the hero image to the X and LinkedIn posts and uploads
it to R2; a package without one publishes text-only social, silently.

**Fix**: add Output 5 to both commands, matching the standard's filename and required fields.

### 3. Staging location disagrees three ways

- Standard: `~/shared/content/drafts/<slug>`, published with an absolute `~/shared/...` path.
- `/blog`: writes to `blog/` inside the current repo.
- What actually happened on 2026-08-13: the files had to be hand-copied to `~/shared/content/blog/`
  so the Mac mini could reach them for a scheduled social post, inventing a **third** location.

The repo-local default is not merely non-standard, it is unreachable. `~/DevProjects/` does not sync
between Jamie's machines; `~/shared/` does. Anything scheduled on the Mini cannot see a package that
only exists in a repo.

**Fix**: write the package to `~/shared/content/drafts/` and emit absolute `~/shared/...` paths in the
publish handoff. If a repo-local copy is wanted for version control, it is a copy, not the source.

### 4. Frontmatter omits the two fields the site actually indexes on

`/blog` specifies `date`, `slug`, `title`, `excerpt`, `tags`. The site's taxonomy uses **`topics`**
(1-2 from a controlled seven, `jpub.js:472`) and **`editorialType`** (`essay` | `build-log`). Neither
appears in either command.

Proven live: `jpub --dry-run` reported `Topics: (none — will not appear on topic pages)`. The post
would have published and been findable only by direct link.

**Fix**: add both to the frontmatter spec, with the controlled vocabulary inline so it cannot be
guessed: `ai, ai-search, building, open-source, trading, thinking, business`.

### 5. The X output is a different artifact from the standard's

- Standard: an X **thread**, 6-10 tweets separated by `---`, each under 280 raw characters, each
  standing alone, last tweet ending with the post URL.
- `/blog`: a **single tweet**, 180-260 characters, with a `Try it:` line and a `Full post:` line.

Neither is wrong in isolation, but they are not the same product, and a reader comparing two posts
would see two different formats. LinkedIn diverges too: standard is 200-400 words ending `Full
piece:` plus exactly three PascalCase hashtags; `/blog` says 800-1000 characters, `Full post:`, and
2-3 hashtags.

**Fix**: pick one. If the single tweet is the deliberate choice for build-log posts, say so in both
documents and note the divergence, rather than leaving two canonical-sounding specs.

### 6. WIP hashtag default is inverted

Standard: default `#jamiewatters` (the writing project), and use a product tag **only when the post
genuinely is about that product**, because on WIP the hashtag files the todo under a project and a
wrong tag misfiles it. `/blog` derives the tag from the repo's project name, so it defaults to the
product tag and never considers `#jamiewatters`.

**Fix**: invert the default; derive a product tag only when the post is about the product.

### 7. Two sources of voice truth

`jamie-voice` is described in its own frontmatter as *"the VOICE AUTHORITY"*, called by the other
content skills. `/blog` instead resolves a chain ending at
`.claude/data/voice-guide-default.md`, a copy that ships inside AGENT-11.

The copy is good and was followed correctly on 2026-08-13. The problem is that it is a second copy.
`jamie-titles` already carries a header warning that its claude.ai duplicate *"is a paste and drifts
silently"* — the same failure mode, already known, already burned.

**Fix**: point the resolution chain at the skill, and keep the bundled file only as the fallback for
installs with no access to `~/shared/skills/`.

---

## What is already right

Worth saying, so a fix does not regress it:

- Both commands correctly forbid `/blog/<slug>` URLs and use `/journey/<slug>`.
- Both derive the URL from the frontmatter `slug`, not the filename, and say why (the date prefix
  produces a 404).
- The AI-tell blacklist and the banned-constructions list are thorough and were effective in practice.
- The character-limit validation step caught a real overrun on 2026-08-13 (a tweet at 360 characters).
- The plain-language / cold-read check is a genuinely good addition that the standard does not have.

---

## Suggested order

1. **The `--all` handoff.** One line each, removes an irreversible-by-default instruction that has
   already caused one unreviewed social post.
2. **Staging to `~/shared/content/drafts/`.** Unblocks scheduling and stops the third location from
   spreading.
3. **`topics` + `editorialType`.** Two frontmatter lines; without them posts do not appear on topic
   pages.
4. **Call `jamie-titles`.** Deletes a duplicate rubric.
5. **Add Output 5 image specs.**
6. **Reconcile the X/LinkedIn shapes and the WIP default.**
7. **Point the voice chain at the skill.**

Items 1-4 are small and each closes a proven failure. Items 5-7 are larger and are about two
documents drifting rather than a specific incident.
