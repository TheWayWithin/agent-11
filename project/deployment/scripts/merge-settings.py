#!/usr/bin/env python3
"""
merge-settings.py — Merge the AGENT-11 settings template into an existing
user .claude/settings.json.

Sprint 5a, T3. Reworked for A11-ISS-9. Called from install.sh whenever the
user already has a settings.json.

Merge contract:
  - User value wins for env and every non-hooks key. Template only fills
    gaps ($schema, _comment, permissions, custom keys are never touched).
  - Add env.ENABLE_TOOL_SEARCH = "auto" if missing.
  - Add full hooks block from template if user has no hooks key.
  - A11-ISS-9 — shipped hooks are MANAGED: within hooks, entries that
    byte-match a historically shipped AGENT-11 hook (STALE_SHIPPED_HOOKS
    below) are replaced by the current template version, and current
    template entries missing from the user file are added. Entries the
    catalogue does not recognise are user-authored or user-edited and are
    preserved byte-identical. Identity across versions of the same shipped
    hook is its statusMessage (fallback: whole-entry equality), so a
    user-EDITED shipped hook (e.g. promoted from advisory to blocking, as
    the template comment invites) is kept as-is and never duplicated.
  - No-op only if ENABLE_TOOL_SEARCH is present AND hooks need no change.

MAINTENANCE RULE: whenever a shipped hook entry in
library/settings.json.template is modified, append the OUTGOING version of
that entry to STALE_SHIPPED_HOOKS below — that is what lets upgrades
replace it in the field. project/deployment/scripts/test-merge-settings.sh
exercises this contract.

Edge cases handled:
  - UTF-8 BOM stripped before parse.
  - Duplicate top-level keys rejected with clear error (Python defaults to
    last-wins, which silently mutates user state — we surface it instead).
  - Malformed hook shapes in the user file (non-dict groups, non-list
    entries) are left untouched rather than guessed at.
  - Atomic write: write to <path>.new, validate by re-parsing, then replace.

Usage:
  merge-settings.py <user_settings_path> <template_path>

Exit codes:
  0  Success — see stdout for status (MERGED or NOOP_ALREADY_V6).
  1  User file has invalid JSON or wrong shape; left untouched.
  2  Template file is invalid; user file left untouched.
  3  Merge produced invalid output (post-write validation failed); user
     file left untouched.
  4  IO error reading or writing files.
"""

import copy
import json
import os
import sys

STATUS_MERGED = "MERGED"
STATUS_NOOP_ALREADY_V6 = "NOOP_ALREADY_V6"

# Every superseded version of a shipped AGENT-11 hook entry, exactly as it
# appeared in library/settings.json.template at release time. An entry in a
# user's settings.json is only ever replaced if it byte-matches one of
# these (canonical JSON comparison) — anything else is treated as the
# user's own and preserved. See MAINTENANCE RULE in the module docstring.
STALE_SHIPPED_HOOKS = [
    # v6.2.0 read-only gate guard (f575973): matched via a hook 'if' glob,
    # which Claude Code evaluates fail-open on complex Bash — replaced in
    # A11-ISS-4 (b941a19) by the .claude/hooks/gate-guard.sh script call.
    {
        "type": "command",
        "if": "Bash(* > *quality-gates.json*)|Bash(*>> *quality-gates.json*)|Bash(*tee *quality-gates*)|Bash(*sed -i*quality-gates*)|Bash(*cp * *quality-gates.json*)|Bash(*mv * *quality-gates.json*)|Bash(* > gates/*)|Bash(*>> gates/*)|Bash(*tee *gates/*)|Bash(*sed -i*gates/*)|Bash(*cp * gates/*)|Bash(*mv * gates/*)|Bash(* > .gates/*)|Bash(*tee *.gates/*)",
        "command": "echo 'BLOCKED (Sprint 6a/6c read-only gates): refusing a Bash write to a quality-gate path. The criteria that judge the work are not agent-editable. The Edit/Write deny rules do not cover Bash redirection, so this hook closes that route. To change a gate, do it as a deliberate human action.' >&2; exit 2",
        "statusMessage": "read-only gate guard",
        "timeout": 10,
    },
]


def canon(entry):
    """Canonical form of a hook entry for equality comparison."""
    return json.dumps(entry, sort_keys=True)


STALE_CANON = {canon(e) for e in STALE_SHIPPED_HOOKS}


def identity(entry):
    """Stable identity of a shipped hook across its versions."""
    status = entry.get("statusMessage") if isinstance(entry, dict) else None
    if isinstance(status, str) and status:
        return ("statusMessage", status)
    return ("canon", canon(entry))


def merge_hooks(user_hooks, template_hooks):
    """Merge template hooks into user hooks in place.

    Returns True if user_hooks was modified. Only touches entries that
    byte-match STALE_SHIPPED_HOOKS (replaced) or template entries missing
    by identity (added). Unrecognised user entries are never modified,
    reordered relative to each other, or removed.
    """
    changed = False
    for event, template_groups in template_hooks.items():
        if not isinstance(template_groups, list):
            continue
        if event not in user_hooks:
            user_hooks[event] = copy.deepcopy(template_groups)
            changed = True
            continue
        user_groups = user_hooks[event]
        if not isinstance(user_groups, list):
            continue  # malformed user shape: leave untouched
        for tgroup in template_groups:
            if not isinstance(tgroup, dict):
                continue
            matcher = tgroup.get("matcher")
            ugroup = next(
                (
                    g
                    for g in user_groups
                    if isinstance(g, dict) and g.get("matcher") == matcher
                ),
                None,
            )
            if ugroup is None:
                user_groups.append(copy.deepcopy(tgroup))
                changed = True
                continue
            uentries = ugroup.get("hooks")
            tentries = [e for e in tgroup.get("hooks", []) if isinstance(e, dict)]
            if not isinstance(uentries, list):
                continue  # malformed user shape: leave untouched
            # 1. Drop stale shipped entries (recording where the first was).
            kept = []
            insert_at = None
            for e in uentries:
                if isinstance(e, dict) and canon(e) in STALE_CANON:
                    if insert_at is None:
                        insert_at = len(kept)
                    changed = True
                else:
                    kept.append(e)
            # 2. Add template entries whose identity is absent (a user-
            #    edited variant with the same statusMessage counts as
            #    present — keep theirs, never duplicate).
            present = {identity(e) for e in kept if isinstance(e, dict)}
            if insert_at is None:
                insert_at = len(kept)
            for te in tentries:
                if identity(te) not in present:
                    kept.insert(insert_at, copy.deepcopy(te))
                    insert_at += 1
                    changed = True
            ugroup["hooks"] = kept
    return changed


def strip_bom(text):
    if text.startswith("﻿"):
        return text[1:]
    return text


def reject_duplicate_keys(pairs):
    seen = set()
    result = {}
    for key, value in pairs:
        if key in seen:
            raise ValueError(f"duplicate key '{key}'")
        seen.add(key)
        result[key] = value
    return result


def load_json(path):
    with open(path, "r", encoding="utf-8") as f:
        raw = f.read()
    text = strip_bom(raw)
    return json.loads(text, object_pairs_hook=reject_duplicate_keys)


def main():
    if len(sys.argv) != 3:
        print("Usage: merge-settings.py <user_settings> <template>", file=sys.stderr)
        return 1

    user_path, template_path = sys.argv[1], sys.argv[2]

    try:
        user = load_json(user_path)
    except json.JSONDecodeError as e:
        print(
            f"ERROR: settings.json is not valid JSON: {e}\n"
            f"Common causes: trailing comma, unquoted key, missing brace, "
            f"single quotes instead of double.",
            file=sys.stderr,
        )
        return 1
    except ValueError as e:
        print(f"ERROR: settings.json has {e}", file=sys.stderr)
        return 1
    except (IOError, OSError) as e:
        print(f"ERROR: cannot read {user_path}: {e}", file=sys.stderr)
        return 4

    if not isinstance(user, dict):
        print(
            f"ERROR: settings.json must be a JSON object, got "
            f"{type(user).__name__}",
            file=sys.stderr,
        )
        return 1

    try:
        template = load_json(template_path)
    except (json.JSONDecodeError, ValueError, IOError, OSError) as e:
        print(f"ERROR: template is invalid: {e}", file=sys.stderr)
        return 2

    if not isinstance(template, dict):
        print("ERROR: template must be a JSON object", file=sys.stderr)
        return 2

    user_env = user.get("env") if isinstance(user.get("env"), dict) else None
    has_tool_search = bool(user_env and "ENABLE_TOOL_SEARCH" in user_env)
    has_hooks = "hooks" in user

    changed = False

    # User wins: only fill gaps.
    if not has_tool_search:
        if not isinstance(user.get("env"), dict):
            user["env"] = {}
        template_value = (
            template.get("env", {}).get("ENABLE_TOOL_SEARCH", "auto")
            if isinstance(template.get("env"), dict)
            else "auto"
        )
        user["env"]["ENABLE_TOOL_SEARCH"] = template_value
        changed = True

    template_hooks = template.get("hooks")
    if isinstance(template_hooks, dict):
        if not has_hooks:
            user["hooks"] = copy.deepcopy(template_hooks)
            changed = True
        elif isinstance(user.get("hooks"), dict):
            # A11-ISS-9: propagate shipped-hook updates, preserve user hooks.
            if merge_hooks(user["hooks"], template_hooks):
                changed = True
        # user has a "hooks" key of unexpected type: leave it untouched.

    if not changed:
        print(STATUS_NOOP_ALREADY_V6)
        return 0

    tmp_path = user_path + ".new"
    try:
        with open(tmp_path, "w", encoding="utf-8") as f:
            json.dump(user, f, indent=2)
            f.write("\n")
        # Re-parse to confirm we wrote valid JSON.
        with open(tmp_path, "r", encoding="utf-8") as f:
            json.load(f)
    except (IOError, OSError, json.JSONDecodeError) as e:
        print(f"ERROR: failed to write/validate merged settings: {e}", file=sys.stderr)
        try:
            os.remove(tmp_path)
        except OSError:
            pass
        return 3

    try:
        os.replace(tmp_path, user_path)
    except OSError as e:
        print(f"ERROR: cannot replace {user_path}: {e}", file=sys.stderr)
        return 4

    print(STATUS_MERGED)
    return 0


if __name__ == "__main__":
    sys.exit(main())
