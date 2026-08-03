#!/usr/bin/env bash
#
# validate-sprint6-closeout.sh — algorithmic oracle for the PRJ-5 / Sprint 6 close-out.
#
# Proves three things by exit code. Prints NOTHING and exits 0 when compliant;
# prints one diagnostic line per breach to stderr and exits 1 otherwise.
#
#   1. ORIENTATION  Every library agent and every executable mission file carries the
#                   map-first orientation instruction, verbatim and uncountermanded.
#   2. GATES        The read-only gate surface is intact: unchanged against HEAD, the four
#                   deny rules still deny, no allow rule or permission mode undoes them,
#                   and the Bash gate-guard still blocks writes to gate paths.
#   3. MEMO         sprints/sprint-6-workflows-decision.md exists and records an actual
#                   verdict for each of the four tasks it is required to rule on.
#
# WHAT THIS CANNOT DO, stated plainly because the alternative is the kind of false
# enforcement claim this close-out exists to correct. This is a drift detector, not a
# security boundary. Anyone with write access to the repo can defeat it deliberately:
# hide a change from git, tailor a stub to satisfy the probes, or rewrite the check
# itself. It catches accident, regression and careless edits. It does not catch an
# adversary, and no script run from inside the tree it is checking could.
#
# Usage:  scripts/validate-sprint6-closeout.sh          (silent = compliant)
#         scripts/validate-sprint6-closeout.sh -v       (list what was checked)
#
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO" || exit 1

VERBOSE=0
[ "${1:-}" = "-v" ] && VERBOSE=1

fail=0
breach() { printf '%s\n' "$*" >&2; fail=1; }
note()   { [ "$VERBOSE" -eq 1 ] && printf '%s\n' "$*"; return 0; }

# ---------------------------------------------------------------------------
# 1. Orientation instruction
#
# Target set: every deployable specialist agent, and every mission file that
# directs work on an existing codebase. README.md and library.md are catalogues
# of missions: they list, they do not read code, so they are out of scope.
#
# The set is pinned by name, not counted. A count alone lets a real mission be
# deleted and a placeholder added in its place.
# ---------------------------------------------------------------------------
EXPECTED_AGENTS=(analyst architect coordinator designer developer documenter marketer
                 operator strategist support tester)
EXPECTED_MISSIONS=(connect-mcp dev-alignment dev-setup mission-architecture mission-build
                   mission-deploy mission-document mission-fix mission-integrate
                   mission-migrate mission-mvp mission-optimize mission-product-description
                   mission-refactor mission-release mission-security operation-genesis
                   operation-recon)

CANONICAL_BLOCK="$(cat <<'CANON'
## ORIENTATION PROTOCOL — MAP FIRST, READ NARROWLY

Orientation is the expensive step, not the edit. On a large repo the bottleneck is finding what to change, not changing it, and the tokens spent reading files that turned out to be irrelevant are the largest avoidable cost in a session. These four rules are requirements, not preferences.

1. **Glob/Grep to locate before you Read.** Find the path and the line number first: `Glob` for file paths, `Grep` for symbols, strings and call sites. Do not open a file to discover what is in it.
2. **Read only the lines you need.** Use `offset` and `limit` on Read. A 40-line window around a confirmed match beats a 900-line whole-file read.
3. **Never read a whole file to find one symbol.** Grep for the symbol, then read its neighbourhood. Read a file end to end only when you are about to change it end to end.
4. **Do not re-read what you have already read.** Every re-read re-pays the whole file as input tokens and crowds out the context you still need.

If you read a whole file, be able to state why a narrower read would not have worked.
CANON
)"

targets=()
for a in "${EXPECTED_AGENTS[@]}"; do targets+=("project/agents/specialists/$a.md"); done
for m in "${EXPECTED_MISSIONS[@]}"; do targets+=("project/missions/$m.md"); done

# Nothing unexpected may appear in either directory either, or a renamed file could
# silently drop out of the checked set.
actual_agents=$(ls -1 project/agents/specialists/*.md 2>/dev/null | wc -l | tr -d ' ')
actual_missions=$(ls -1 project/missions/*.md 2>/dev/null | grep -vE '/(README|library)\.md$' | wc -l | tr -d ' ')
[ "$actual_agents" = "${#EXPECTED_AGENTS[@]}" ] || \
  breach "ORIENTATION: project/agents/specialists holds $actual_agents files, expected ${#EXPECTED_AGENTS[@]} — update this check deliberately if the roster changed"
[ "$actual_missions" = "${#EXPECTED_MISSIONS[@]}" ] || \
  breach "ORIENTATION: project/missions holds $actual_missions executable missions, expected ${#EXPECTED_MISSIONS[@]} — update this check deliberately if the set changed"

expected_norm="$(printf '%s' "$CANONICAL_BLOCK" | sed -e 's/[[:space:]]*$//' | tr -s '\n')"

for f in "${targets[@]}"; do
  if [ ! -f "$f" ]; then
    breach "ORIENTATION: $f is missing"
    continue
  fi

  # Exactly one heading, so a second copy cannot be used to shadow the first.
  heads=$(grep -c '^## ORIENTATION PROTOCOL' "$f")
  if [ "$heads" -ne 1 ]; then
    breach "ORIENTATION: $f has $heads ORIENTATION PROTOCOL headings, expected exactly 1"
    continue
  fi

  # The section must match the canonical text verbatim.
  actual="$(awk '/^## ORIENTATION PROTOCOL/{f=1} f&&/^## /&&!/^## ORIENTATION PROTOCOL/{exit} f{print}' "$f" \
    | sed -e 's/[[:space:]]*$//' | tr -s '\n')"
  if [ "$actual" != "$expected_norm" ]; then
    breach "ORIENTATION: $f has an ORIENTATION PROTOCOL section that does not match the canonical text"
  fi

  # Nothing anywhere in the file may countermand it. Matching the block verbatim is no
  # use if a line above it says to ignore the block.
  if grep -qiE '(obsolete|deprecated|superseded|ignore|disregard|must not be followed|do not follow|no longer applies)[^.]{0,80}orientation' "$f" \
     || grep -qiE 'orientation[^.]{0,80}(is obsolete|is deprecated|is superseded|must not be followed|should be ignored|no longer applies|does not apply)' "$f"; then
    breach "ORIENTATION: $f contains text that countermands the orientation protocol"
  fi
done
note "orientation: ${#EXPECTED_AGENTS[@]} agents and ${#EXPECTED_MISSIONS[@]} missions carry the canonical block verbatim and uncountermanded"

# The deployed global instruction file must carry the rule too, so agents that are not
# in the specialist set still inherit it.
grep -qF -- 'Glob/Grep to locate before you Read' library/CLAUDE.md || \
  breach "ORIENTATION: library/CLAUDE.md does not state the orientation rule"

# ---------------------------------------------------------------------------
# 2. Gate surface intact
#
# `.quality-gates.json` is a per-project file that does not exist in this framework
# repo, and `gates/` here is framework source rather than live gate config, so checking
# only those two paths would pass on any state where nobody had reason to touch them.
# The check therefore covers the files that carry the enforcement into deployed
# projects, and asserts the mechanism rather than the bytes.
# ---------------------------------------------------------------------------
GATE_PATHS=(".quality-gates.json" "gates" "library/settings.json.template" "library/hooks/gate-guard.sh")
GATE_FILES=("library/settings.json.template" "library/hooks/gate-guard.sh")

if git rev-parse --git-dir >/dev/null 2>&1; then
  dirty="$(git status --porcelain -- "${GATE_PATHS[@]}" 2>/dev/null)"
  if [ -n "$dirty" ]; then
    while IFS= read -r line; do
      breach "GATES: uncommitted change to a read-only gate path: $line"
    done <<< "$dirty"
  fi

  # git status consults the index, so `git update-index --assume-unchanged` hides an
  # edit from it. Compare content hashes directly instead, which the index cannot mask.
  for gf in "${GATE_FILES[@]}"; do
    if [ -f "$gf" ]; then
      head_blob="$(git rev-parse "HEAD:$gf" 2>/dev/null || echo missing)"
      work_blob="$(git hash-object "$gf" 2>/dev/null || echo unreadable)"
      if [ "$head_blob" != "missing" ] && [ "$head_blob" != "$work_blob" ]; then
        breach "GATES: $gf differs from HEAD (content hash mismatch; not visible to git status if assume-unchanged is set)"
      fi
    fi
  done
  note "gates: no change under ${GATE_PATHS[*]}, by status and by content hash"
else
  breach "GATES: not a git repository — cannot prove the gate files are unchanged"
fi

# The deny rules are the mechanism, not the file. Assert they deny, that nothing in the
# same file undoes them, and that the permission mode is not one that ignores them.
python3 - <<'PY' >&2 || fail=1
import json, sys
REQUIRED = [
    "Edit(.quality-gates.json)",
    "Edit(**/*.quality-gates.json)",
    "Edit(gates/**)",
    "Edit(.gates/**)",
]
path = "library/settings.json.template"
try:
    cfg = json.load(open(path))
except Exception as e:
    print(f"GATES: {path} is not parseable JSON: {e}")
    sys.exit(1)

bad = False
perms = cfg.get("permissions") or {}
deny = perms.get("deny") or []
allow = perms.get("allow") or []

for rule in REQUIRED:
    if rule not in deny:
        print(f"GATES: {path} permissions.deny no longer contains {rule}")
        bad = True
    if rule in allow:
        print(f"GATES: {path} permissions.allow contains {rule} — the gate is inverted")
        bad = True

# An allow rule that reaches a gate path, or a blanket wildcard, undoes the deny list
# just as effectively as deleting it.
for rule in allow:
    low = str(rule).lower()
    if "gates" in low or "quality-gates" in low:
        print(f"GATES: {path} permissions.allow reaches a gate path: {rule}")
        bad = True
    if any(low.startswith(p) for p in ("bash(*", "write(*", "edit(*", "bash(**", "write(**", "edit(**")):
        print(f"GATES: {path} permissions.allow contains a blanket rule that swallows the gate deny: {rule}")
        bad = True

mode = str(cfg.get("defaultMode", "")) or str(perms.get("defaultMode", ""))
if mode.lower() in ("bypasspermissions", "bypass"):
    print(f"GATES: {path} sets defaultMode={mode} — permission rules, including the gate deny, are not consulted")
    bad = True

# The Bash route must be wired as a PreToolUse hook. A grep for the filename is
# satisfied by a comment that merely mentions it, so check the structure.
pre = (cfg.get("hooks") or {}).get("PreToolUse") or []
if not any("gate-guard.sh" in json.dumps(h.get("hooks", h)) and "Bash" in str(h.get("matcher", "")) for h in pre):
    print(f"GATES: {path} has no PreToolUse hook on Bash that invokes gate-guard.sh")
    bad = True

sys.exit(1 if bad else 0)
PY
note "gates: deny rules deny, no allow rule or default mode undoes them, hook is wired"

# The guard itself must actually block. One probe would let a stub special-case it, so
# exercise several distinct shell write forms against several gate path spellings.
if [ ! -s library/hooks/gate-guard.sh ]; then
  breach "GATES: library/hooks/gate-guard.sh is missing or empty"
else
  probes=(
    'echo x > .quality-gates.json'
    'echo x >> gates/gate-types.yaml'
    'sed -i "" s/a/b/ gates/run-gates.py'
    'cp /tmp/x .quality-gates.json'
    'mv /tmp/x gates/templates/minimal.json'
    'tee gates/README.md < /tmp/x'
  )
  for probe in "${probes[@]}"; do
    printf '{"tool_name":"Bash","tool_input":{"command":%s}}' "$(python3 -c 'import json,sys;print(json.dumps(sys.argv[1]))' "$probe")" \
      | sh library/hooks/gate-guard.sh >/dev/null 2>&1
    rc=$?
    if [ "$rc" -ne 2 ]; then
      breach "GATES: gate-guard.sh did not block \"$probe\" (exit $rc, expected 2)"
    fi
  done
  # And it must not block everything, which would be a different kind of broken.
  printf '{"tool_name":"Bash","tool_input":{"command":"echo hello > /tmp/harmless.txt"}}' \
    | sh library/hooks/gate-guard.sh >/dev/null 2>&1
  if [ $? -eq 2 ]; then
    breach "GATES: gate-guard.sh blocks an unrelated write — it is failing closed on everything"
  fi
  note "gates: gate-guard.sh blocks ${#probes[@]} distinct write forms and permits unrelated writes"
fi

# ---------------------------------------------------------------------------
# 3. Decision memo records a verdict for each of the four tasks
# ---------------------------------------------------------------------------
MEMO="sprints/sprint-6-workflows-decision.md"

if [ ! -f "$MEMO" ]; then
  breach "MEMO: $MEMO does not exist"
else
  # Each task needs its own heading carrying subject and verdict on the same line.
  # The verdict must be a decision: a heading that offers both options, or hedges, is
  # not a ruling, and the sentence that introduces the choice must not satisfy the check.
  HEDGE='undecided|unclear|not yet|tbd|to be decided|either|no recommendation|open question|shrug|deferred'
  check_task() {
    local label="$1" heading_re="$2" verdict_re="$3"
    local heading
    heading="$(grep -Ei -m1 -- "$heading_re" "$MEMO")"
    if [ -z "$heading" ]; then
      breach "MEMO: no section heading for $label matching /$heading_re/"
      return
    fi
    if ! printf '%s' "$heading" | grep -qEi -- "$verdict_re"; then
      breach "MEMO: the $label heading records no verdict: $heading"
      return
    fi
    if printf '%s' "$heading" | grep -qEi -- "$HEDGE"; then
      breach "MEMO: the $label heading hedges rather than decides: $heading"
    fi
    # "rewrite as X or drop as solved" in a heading is the menu, not a ruling.
    if printf '%s' "$heading" | grep -qEi -- 'rewrite as.*(or|/).*drop as solved|drop as solved.*(or|/).*rewrite as'; then
      breach "MEMO: the $label heading restates the choice instead of making it: $heading"
    fi
  }
  check_task "task 3" '^#+ .*task[ -]*3.*code[ -]?review loop' 'rewrite as|drop as solved'
  check_task "task 4" '^#+ .*task[ -]*4.*ratchet'              'rewrite as|drop as solved'
  check_task "task 5" '^#+ .*task[ -]*5.*read-only judge'      'rewrite as|drop as solved'
  check_task "task 6" '^#+ .*task[ -]*6.*coordinator'          'recommendation only|recommend only'

  # Task 6 is recommend-only by the spec, so the memo must state a clear position on
  # rewriting the coordinator and must not have implemented one. Require the decisive
  # sentence, not any sentence containing the words.
  if ! grep -qEi -- '(recommendation|recommend)[^.]{0,40}:?[^.]{0,20}do not rewrite the coordinator' "$MEMO" \
     && ! grep -qEi -- '^\*\*recommendation: do not rewrite the coordinator' "$MEMO"; then
    breach "MEMO: task 6 records no explicit recommendation on rewriting the coordinator"
  fi
  if grep -qEi -- '(it is not|not) yet clear whether.{0,60}rewrite the coordinator' "$MEMO"; then
    breach "MEMO: task 6 hedges on the coordinator instead of recommending"
  fi
  note "memo: all four task headings carry a subject and a decisive verdict"
fi

exit "$fail"
