#!/usr/bin/env bash
# Run every install-fixture test, aggregate pass/fail.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'

PASSED=()
FAILED=()

for fixture in "$SCRIPT_DIR"/*/run-test.sh; do
    name="$(basename "$(dirname "$fixture")")"
    echo
    echo "================================"
    if bash "$fixture"; then
        PASSED+=("$name")
    else
        FAILED+=("$name")
    fi
done

echo
echo "================================"
echo "Aggregate"
echo "================================"
echo -e "${GREEN}Passed${NC} (${#PASSED[@]}):"
for n in "${PASSED[@]}"; do echo "  - $n"; done
if [[ ${#FAILED[@]} -gt 0 ]]; then
    echo
    echo -e "${RED}Failed${NC} (${#FAILED[@]}):"
    for n in "${FAILED[@]}"; do echo "  - $n"; done
    exit 1
fi
echo
echo -e "${GREEN}All fixtures passed.${NC}"
