#!/usr/bin/env python3
"""
parse-registry.py — minimal YAML parser for the agent-11 fleet registry.

Avoids the PyYAML dependency by hand-rolling. Only handles the registry's
flat structure: list of dicts with simple key:value fields. Comments are
stripped, quoted values unquoted, indentation respected.

Usage:
    python3 parse-registry.py <registry_path> [--tier=active,local-only,...]

Outputs tab-separated rows: name<TAB>path<TAB>remote<TAB>branch<TAB>tier<TAB>notes
One row per repo matching the tier filter. Notes have tabs/newlines stripped.

Exit non-zero on parse error or missing file.
"""

import argparse
import re
import sys


def parse_registry(path):
    """Parse the registry. Return list of dicts."""
    with open(path) as f:
        lines = f.readlines()

    repos = []
    current = None
    in_repos = False

    for raw in lines:
        # Strip trailing whitespace and inline comments (only when comment is preceded by space, to avoid breaking URLs)
        line = re.sub(r"\s+#.*$", "", raw.rstrip())

        # Skip blank lines and full-line comments
        if not line.strip() or line.lstrip().startswith("#"):
            continue

        # Detect entry into the repos: section
        if line.rstrip() == "repos:":
            in_repos = True
            continue
        if not in_repos:
            continue

        # Top-level key (no leading space) ends the repos: section
        if line and not line[0].isspace():
            in_repos = False
            continue

        # New repo entry
        m = re.match(r"^  - name:\s*(.*)$", line)
        if m:
            if current is not None:
                repos.append(current)
            current = {"name": _unquote(m.group(1))}
            continue

        # Field within current repo
        m = re.match(r"^    (\w+):\s*(.*)$", line)
        if m and current is not None:
            current[m.group(1)] = _unquote(m.group(2))

    if current is not None:
        repos.append(current)

    return repos


def _unquote(val):
    """Strip surrounding quotes if present."""
    val = val.strip()
    if (val.startswith('"') and val.endswith('"')) or (
        val.startswith("'") and val.endswith("'")
    ):
        val = val[1:-1]
    return val


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("registry", help="Path to registry.yaml")
    ap.add_argument(
        "--tier",
        default="active,local-only",
        help="Comma-separated tier filter (default: active,local-only)",
    )
    args = ap.parse_args()

    try:
        repos = parse_registry(args.registry)
    except FileNotFoundError:
        print(f"ERROR: registry not found: {args.registry}", file=sys.stderr)
        sys.exit(2)
    except Exception as e:
        print(f"ERROR: parse failed: {e}", file=sys.stderr)
        sys.exit(2)

    tiers = set(t.strip() for t in args.tier.split(","))

    for r in repos:
        if r.get("tier") not in tiers:
            continue
        # TSV-safe: strip tabs and newlines from notes
        notes = r.get("notes", "").replace("\t", " ").replace("\n", " ")
        print(
            "\t".join(
                [
                    r.get("name", ""),
                    r.get("path", ""),
                    r.get("remote", ""),
                    r.get("branch", ""),
                    r.get("tier", ""),
                    notes,
                ]
            )
        )


if __name__ == "__main__":
    main()
