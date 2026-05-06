#!/usr/bin/env python3
"""
merge-settings.py — Merge AGENT-11 v6.0 template into an existing user
.claude/settings.json.

Sprint 5a, T3. Called from install.sh when the user already has a
settings.json that lacks v6 signals (ENABLE_TOOL_SEARCH and/or hooks).

Merge contract (locked in sprint spec):
  - User value wins. Template only fills gaps.
  - Add env.ENABLE_TOOL_SEARCH = "auto" if missing.
  - Add full hooks block from template if user has no hooks key.
  - Preserve all other user keys ($schema, _comment, permissions, custom).
  - No-op if user already has both ENABLE_TOOL_SEARCH and hooks.

Edge cases handled:
  - UTF-8 BOM stripped before parse.
  - Duplicate top-level keys rejected with clear error (Python defaults to
    last-wins, which silently mutates user state — we surface it instead).
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

import json
import os
import sys

STATUS_MERGED = "MERGED"
STATUS_NOOP_ALREADY_V6 = "NOOP_ALREADY_V6"


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

    if has_tool_search and has_hooks:
        print(STATUS_NOOP_ALREADY_V6)
        return 0

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

    if not has_hooks and "hooks" in template:
        user["hooks"] = template["hooks"]

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
