#!/usr/bin/env bash
# ISS-6 guard: fail loudly if generated validation run output is staged.
# Run output is throwaway (see project/validation/README.md) and must never be committed.
set -u

staged=$(git diff --cached --name-only --diff-filter=d \
    | grep -E '^project/validation/baseline-runs/|^test-projects/' \
    | grep -v '^test-projects/install-fixtures/' || true)

if [ -n "$staged" ]; then
    echo "ERROR: generated validation run output is staged for commit:" >&2
    echo "$staged" | sed 's/^/  /' >&2
    echo "Unstage it (git restore --staged <path>) — run output stays out of version control (ISS-6)." >&2
    exit 1
fi
echo "OK: no validation run output staged."
