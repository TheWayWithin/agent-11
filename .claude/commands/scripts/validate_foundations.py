#!/usr/bin/env python3
"""Validation script for AGENT-11 foundations workflow.

Validates the presence and structure of foundation documents
and the handoff manifest for project initialization.
"""

import json
import os
import sys
from pathlib import Path
from typing import Dict, List, Optional, Tuple

# Document category patterns
CATEGORY_PATTERNS: Dict[str, List[str]] = {
    "prd": ["prd.md", "requirements.md", "product-requirements.md"],
    "vision": ["vision-mission.md", "vision.md", "strategic-plan.md"],
    "icp": ["client-success-blueprint.md", "icp.md", "personas.md"],
    "brand": ["brand-style-guidelines.md", "brand.md", "style-guide.md"],
    "marketing": ["marketing-bible.md", "marketing.md", "positioning.md"],
}

REQUIRED_CATEGORIES = ["prd", "vision"]
ADVISABLE_CATEGORIES = ["icp", "brand", "marketing"]


def categorize_file(filename: str) -> Optional[str]:
    """Determine the category of a foundation document by filename."""
    filename_lower = filename.lower()
    for category, patterns in CATEGORY_PATTERNS.items():
        if filename_lower in patterns:
            return category
    return None


def find_foundations_dir(start_path: Path) -> Optional[Path]:
    """Find the foundations directory, searching up from start_path."""
    current = start_path.resolve()

    # Check common locations
    candidates = [
        current / "documents" / "foundations",
        current / "docs" / "foundations",
        current / "foundations",
    ]

    for candidate in candidates:
        if candidate.exists() and candidate.is_dir():
            return candidate

    # Search up the directory tree
    while current != current.parent:
        for subdir in ["documents/foundations", "docs/foundations", "foundations"]:
            candidate = current / subdir
            if candidate.exists() and candidate.is_dir():
                return candidate
        current = current.parent

    return None


def scan_documents(foundations_dir: Path) -> Dict[str, Tuple[str, str]]:
    """Scan the foundations directory and categorize documents.

    Returns:
        Dict mapping category to (filename, category_type) where
        category_type is 'REQUIRED' or 'ADVISABLE'
    """
    found: Dict[str, Tuple[str, str]] = {}

    if not foundations_dir.exists():
        return found

    for filepath in foundations_dir.glob("*.md"):
        filename = filepath.name
        category = categorize_file(filename)

        if category:
            cat_type = "REQUIRED" if category in REQUIRED_CATEGORIES else "ADVISABLE"
            # Only keep first match per category
            if category not in found:
                found[category] = (filename, cat_type)

    return found


def validate_manifest(manifest_path: Path) -> Tuple[bool, str]:
    """Validate the handoff manifest structure.

    Returns:
        Tuple of (is_valid, message)
    """
    if not manifest_path.exists():
        return False, "handoff-manifest.json not found (run /foundations init)"

    try:
        with open(manifest_path, "r") as f:
            manifest = json.load(f)
    except json.JSONDecodeError as e:
        return False, f"Invalid JSON: {e}"

    # Check required fields
    required_fields = ["meta", "documents"]
    missing_fields = [field for field in required_fields if field not in manifest]

    if missing_fields:
        return False, f"Missing required fields: {', '.join(missing_fields)}"

    # Validate documents structure
    docs = manifest.get("documents", [])
    if not isinstance(docs, list):
        return False, "'documents' must be an array"

    # Check for at least one document
    if not docs:
        return False, "No documents registered in manifest"

    # Validate each document entry
    for i, doc_info in enumerate(docs):
        if not isinstance(doc_info, dict):
            return False, f"Document at index {i} must be an object"

        doc_required = ["filename", "path", "category", "status"]
        doc_missing = [f for f in doc_required if f not in doc_info]
        if doc_missing:
            return False, f"Document at index {i} missing fields: {', '.join(doc_missing)}"

    return True, f"Valid manifest with {len(docs)} document(s)"


def print_report(
    foundations_dir: Optional[Path],
    found_docs: Dict[str, Tuple[str, str]],
    manifest_result: Tuple[bool, str],
    all_files: List[str]
) -> int:
    """Print the validation report and return exit code."""
    print("\n" + "=" * 40)
    print("=== FOUNDATIONS VALIDATION REPORT ===")
    print("=" * 40 + "\n")

    # Directory status
    if foundations_dir:
        print(f"Directory: {foundations_dir}")
        print(f"  Status: EXISTS\n")
    else:
        print("Directory: documents/foundations/")
        print("  Status: NOT FOUND\n")
        print("Run '/foundations init' to create the foundations directory.\n")
        print("RESULT: NOT READY (foundations directory missing)")
        return 1

    # Documents found
    print("Documents Found:")
    if all_files:
        for filename in sorted(all_files):
            category = categorize_file(filename)
            if category:
                cat_type = "REQUIRED" if category in REQUIRED_CATEGORIES else "ADVISABLE"
                print(f"  - {filename} -> category: {category} [{cat_type}]")
            else:
                print(f"  - {filename} -> category: unknown")
    else:
        print("  (no markdown files found)")
    print()

    # Required check
    print("Required Check:")
    required_pass = True
    for category in REQUIRED_CATEGORIES:
        if category in found_docs:
            filename, _ = found_docs[category]
            print(f"  [PASS] {category}: {filename}")
        else:
            print(f"  [MISS] {category}: not found")
            required_pass = False
    print()

    # Advisable check
    print("Advisable Check:")
    advisable_missing = 0
    for category in ADVISABLE_CATEGORIES:
        if category in found_docs:
            filename, _ = found_docs[category]
            print(f"  [PASS] {category}: {filename}")
        else:
            print(f"  [MISS] {category}: not found")
            advisable_missing += 1
    print()

    # Manifest validation
    print("Manifest Validation:")
    is_valid, message = manifest_result
    if manifest_result[1].startswith("handoff-manifest.json not found"):
        print(f"  [SKIP] {message}")
    elif is_valid:
        print(f"  [PASS] {message}")
    else:
        print(f"  [FAIL] {message}")
    print()

    # Final result
    if not required_pass:
        print("RESULT: NOT READY (missing required documents)")
        return 1
    elif advisable_missing > 0:
        print(f"RESULT: READY ({advisable_missing} advisable document(s) missing)")
        return 0
    else:
        print("RESULT: FULLY READY (all documents present)")
        return 0


def main() -> int:
    """Main entry point for foundations validation."""
    # Determine starting path
    start_path = Path.cwd()
    if len(sys.argv) > 1:
        start_path = Path(sys.argv[1])

    # Find foundations directory
    foundations_dir = find_foundations_dir(start_path)

    # Scan for documents
    found_docs: Dict[str, Tuple[str, str]] = {}
    all_files: List[str] = []

    if foundations_dir:
        found_docs = scan_documents(foundations_dir)
        all_files = [f.name for f in foundations_dir.glob("*.md")]

    # Check for manifest
    manifest_path = foundations_dir / "handoff-manifest.json" if foundations_dir else Path("handoff-manifest.json")
    manifest_result = validate_manifest(manifest_path)

    # Print report and get exit code
    return print_report(foundations_dir, found_docs, manifest_result, all_files)


if __name__ == "__main__":
    sys.exit(main())
