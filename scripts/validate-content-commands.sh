#!/usr/bin/env bash
#
# validate-content-commands.sh — /blog and /dailyreport must not drift from the
# canonical content standard (~/shared/reference/content-standard.md).
#
# A11-ISS-29. Seven divergences were found on 2026-08-14, six of them proven by
# a live run rather than inferred. The one that mattered: both commands printed
# `jpub <path> --all`, which publishes the blog AND the tweet AND the LinkedIn
# post AND the WIP todo in one irreversible go. The standard forbids exactly
# that (ISS-45): the blog is recoverable because jpub upserts by slug, while a
# tweet, a LinkedIn post and a WIP todo are seen, cached and indexed the moment
# they land. On 2026-08-03 both commands were printed together and the social
# went out unreviewed; on 2026-08-13 the command file said to do it again.
#
# A warning next to a command is decoration, not a gate. So the invariant this
# script enforces is structural: the all-platforms flag cannot appear in either
# command file at all, and the social flags may only appear inside a block
# explicitly marked SECOND MESSAGE ONLY.
#
# Usage:  scripts/validate-content-commands.sh
# Exits 0 and silent when every check passes; 1 with detail otherwise.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

# Overridable so the script can be pointed at a fixture and negative-tested. A
# validator nobody has watched fail is not evidence of anything.
LIB_DIR="${CONTENT_CMD_LIB_DIR:-project/commands}"
WORK_DIR="${CONTENT_CMD_WORK_DIR:-.claude/commands}"
COMMANDS=(blog dailyreport)
fail=0

report() {
  printf 'FAIL  %s: %s\n' "$1" "$2"
  fail=1
}

# must_contain <file> <label> <fixed-string>
must_contain() {
  grep -qF -- "$3" "$1" || report "$1" "$2 (missing: $3)"
}

# must_not_contain <file> <label> <fixed-string>
must_not_contain() {
  if grep -qF -- "$3" "$1"; then
    report "$1" "$2 (found: $3)"
  fi
}

# ── 1. The irreversible-by-default handoff ──────────────────────────────────
# --all publishes every platform at once. There is no context in which either
# command should hand Jamie that flag, so the literal string is banned outright;
# the prohibition itself is worded as "the all-platforms flag" so that the file
# can say what it forbids without containing it.
check_publish_gate() {
  local f="$1"

  must_not_contain "$f" "all-platforms flag must never appear" "--all"
  must_not_contain "$f" "there is no --social flag in jpub" "--social"

  # The first jpub command in document order is the one the reader runs. It must
  # be the reversible one. Only flag-carrying lines count as commands; prose that
  # merely names the tool does not.
  local first
  first="$(grep -nE 'jpub .*--' "$f" | head -1)"
  if [ -z "$first" ]; then
    report "$f" "no jpub publish handoff found at all"
  else
    case "$first" in
      *--blog*) ;;
      *) report "$f" "first jpub command is not --blog: ${first}" ;;
    esac
    case "$first" in
      *--x*|*--linkedin*|*--wip*)
        report "$f" "first jpub command carries a social flag: ${first}" ;;
    esac
  fi

  # Any jpub line carrying a social flag must sit under the SECOND MESSAGE ONLY
  # marker, within 15 lines of it.
  local line_no line
  while IFS=: read -r line_no line; do
    case "$line" in
      *--x*|*--linkedin*|*--wip*) ;;
      *) continue ;;
    esac
    local start=$(( line_no - 15 ))
    [ "$start" -lt 1 ] && start=1
    if ! sed -n "${start},${line_no}p" "$f" | grep -qF 'SECOND MESSAGE ONLY'; then
      report "$f" "ungated social command at line ${line_no}: ${line}"
    fi
  done < <(grep -nE 'jpub .*--' "$f")
}

# ── 2. Frontmatter the site's taxonomy actually indexes on ──────────────────
# jpub.js drops any topic outside this list and defaults a missing editorialType
# to build-log, both silently. A post without topics is findable only by direct
# link.
check_frontmatter() {
  local f="$1"
  must_contain "$f" "frontmatter must specify topics" "topics:"
  must_contain "$f" "frontmatter must specify editorialType" "editorialType"
  must_contain "$f" "editorial types must be named" "build-log"
  must_contain "$f" "editorial types must be named" "essay"
  # Each of the seven must appear as a backticked literal, so that the
  # vocabulary is stated in the file rather than guessed at write time.
  local t
  for t in ai ai-search building open-source trading thinking business; do
    grep -qF -- "\`${t}\`" "$f" \
      || report "$f" "controlled topic vocabulary incomplete (missing: \`${t}\`)"
  done
}

# ── 3. Staging location ─────────────────────────────────────────────────────
# ~/DevProjects does not sync between Jamie's machines; ~/shared does. A package
# staged inside a repo cannot be reached by anything scheduled on the Mac mini.
check_staging() {
  local f="$1"
  must_contain "$f" "package must stage to the synced vault path" "~/shared/content/drafts/"
  must_not_contain "$f" "retired repo-local staging default" 'land in a `blog/` directory'
  must_not_contain "$f" "retired repo-local staging default" "progress/YYYY-MM-DD-blog.md"
}

# ── 4. Output 5, the image specs ────────────────────────────────────────────
# The standard defines five outputs. Without the fifth, a package ships with no
# image and jpub then posts text-only social, silently.
check_images() {
  local f="$1"
  must_contain "$f" "Output 5 image specs missing" "-images.md"
  must_not_contain "$f" "wrong image spec filename" "-image-spec"
  must_contain "$f" "hero must live where jpub looks for it" "~/shared/content/blog/images/"
}

# ── 5. One title rubric, one voice authority ────────────────────────────────
# jamie-titles' own frontmatter requires the content commands to call it. The
# title produced on 2026-08-13 scored 3/5 against that skill's rubric, below its
# own discard threshold. jamie-voice calls itself the VOICE AUTHORITY; a bundled
# copy is a second source of truth and drifts silently.
check_single_source() {
  local f="$1"
  must_contain "$f" "titles must be delegated to the skill" "jamie-titles"
  must_contain "$f" "voice must resolve to the authority skill" "jamie-voice"
  must_contain "$f" "voice authority path" "skills/user/jamie-voice/references/jamie-watters-voice-guide.md"
}

# ── 6. Social shapes ────────────────────────────────────────────────────────
# The standard specifies an X thread and a 200-400 word LinkedIn post. Both
# commands specified a single tweet and an 800-1000 character LinkedIn post.
check_social_shape() {
  local f="$1"
  must_contain "$f" "X output must be a thread" "6-10 tweets"
  must_not_contain "$f" "single-tweet spec is retired" "180-260 characters"
  must_contain "$f" "LinkedIn length per the standard" "200-400 words"
  must_not_contain "$f" "retired LinkedIn length" "800-1000 characters"
  must_contain "$f" "LinkedIn hashtag count per the standard" "3 PascalCase hashtags"
}

# ── 7. WIP hashtag default ──────────────────────────────────────────────────
# On WIP the hashtag files the todo under a project, so a wrong one misfiles it.
# Deriving a product tag from the repo name inverts the standard's default.
check_wip_hashtag() {
  local f="$1"
  must_contain "$f" "WIP default must be the writing project" "#jamiewatters"
  must_contain "$f" "product tag must be gated on the post's subject" "genuinely is about"
}

# ── 8. What two independent reads found after the first pass ────────────────
# Each of these was a real gap between the commands and the standard, found by
# critics that were given the standard and the files and nothing else.
check_second_pass() {
  local f="$1"
  # The standard puts no condition on the post URL in any social output.
  must_contain "$f" "post URL must be mandatory in the social outputs" \
    "The post URL is mandatory in all three social outputs"
  must_contain "$f" "WIP line must carry the post URL" "carries the post URL"
  # A repo-derived tag is the exact misfiling vector the ordering exists to fix.
  must_contain "$f" "repo-name hashtag derivation must be banned outright" \
    "Never derive the tag from the repo or directory name"
  # jpub's image directory is hardcoded, so the repo-local fallback cannot
  # produce a working hero and must say so rather than publish text-only.
  must_contain "$f" "no-vault image case must be reported" "the hero will not upload from here"
  # Fields the standard and the skills allow, which an "exactly these" list bars.
  must_contain "$f" "imageCaption is a real field" "imageCaption"
  must_contain "$f" "draft is a real field" "draft: true"
  # Output 5's palette requirement applies to every route, not just prompts.
  must_contain "$f" "brand palette must be stated per image" "one warm accent, one cool accent"
  must_contain "$f" "the SVG renderer must be named" "svg-to-png.sh"
  # A canonical body rule that was not carried across.
  must_contain "$f" "framing guard missing" "Report observed behaviour, not intent"
  # --wip with no file makes jpub invent a public todo.
  must_contain "$f" "social handoff must drop --wip when no file was written" "Drop \`--wip\`"
  # The two commands must not give different limits for the same output.
  must_contain "$f" "WIP length must match across both commands" "under 200 characters"
}

for name in "${COMMANDS[@]}"; do
  lib="${LIB_DIR}/${name}.md"
  work="${WORK_DIR}/${name}.md"

  for f in "$lib" "$work"; do
    if [ ! -f "$f" ]; then
      report "$f" "file is missing"
      continue
    fi
    check_publish_gate "$f"
    check_frontmatter "$f"
    check_staging "$f"
    check_images "$f"
    check_single_source "$f"
    check_social_shape "$f"
    check_wip_hashtag "$f"
    check_second_pass "$f"
  done

  # ── 8. The two copies must not drift apart ────────────────────────────────
  if [ -f "$lib" ] && [ -f "$work" ]; then
    if ! diff -q "$lib" "$work" >/dev/null; then
      report "$lib" "library and working copies differ from ${work}"
    fi
  fi
done

if [ "$fail" -eq 0 ]; then
  exit 0
fi
printf '\n%s\n' "See insights/blog-dailyreport-vs-content-standard-2026-08.md (A11-ISS-29)."
exit 1
