#!/usr/bin/env python3
"""
test-validate-content-commands.py — prove validate-content-commands.sh bites.

A11-ISS-29. A validator that has only ever been seen passing is not evidence.
Each mutation below re-introduces one of the seven divergences the review found
(insights/blog-dailyreport-vs-content-standard-2026-08.md) into a throwaway copy
of the two command files; the validator must fail on every one, and pass on the
unmutated copy.

Usage:  python3 scripts/test-validate-content-commands.py
Exits 0 and prints a PASS line per case; 1 if any mutation slips through.
"""
import os
import shutil
import subprocess
import sys
import tempfile

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(REPO, "project", "commands")
VALIDATOR = os.path.join(REPO, "scripts", "validate-content-commands.sh")
FILES = ("blog.md", "dailyreport.md")

# (label, file, find, replace) — each undoes one fix from A11-ISS-29.
MUTATIONS = [
    ("all-platforms flag restored in the handoff", "blog.md",
     "  jpub ~/shared/content/drafts/YYYY-MM-DD-slug.md --blog",
     "  jpub ~/shared/content/drafts/YYYY-MM-DD-slug --all --dry-run"),
    ("social handoff no longer gated to a second message", "blog.md",
     "### Step 13: The social handoff — SECOND MESSAGE ONLY",
     "### Step 13: The social handoff"),
    ("topics dropped from the frontmatter spec", "blog.md",
     "topics: [building]", "categories: [building]"),
    ("controlled topic vocabulary left unstated", "blog.md",
     "`open-source`", "open source"),
    ("staging back to a repo-local directory", "dailyreport.md",
     "~/shared/content/drafts/", "progress/"),
    ("Output 5 image specs removed", "dailyreport.md",
     "-images.md", "-notes.md"),
    ("single tweet instead of a thread", "dailyreport.md",
     "**6-10 tweets**", "**one tweet**, 180-260 characters"),
    ("LinkedIn back to the non-standard length", "dailyreport.md",
     "**200-400 words.**", "800-1000 characters."),
    ("titles invented locally again", "blog.md",
     "jamie-titles", "the rules below"),
    ("voice resolved to the bundled copy", "blog.md",
     "skills/user/jamie-voice/references/jamie-watters-voice-guide.md",
     ".claude/data/voice-guide-default.md"),
    ("WIP tag derived from the repo name", "blog.md",
     "#jamiewatters", "#derivedfromrepo"),
]


def build(root):
    """Fresh copy of both files into lib/ and work/ under root."""
    dirs = {}
    for sub in ("lib", "work"):
        d = os.path.join(root, sub)
        shutil.rmtree(d, ignore_errors=True)
        os.makedirs(d)
        for name in FILES:
            shutil.copy(os.path.join(SRC, name), os.path.join(d, name))
        dirs[sub] = d
    return dirs


def run(dirs):
    env = dict(os.environ,
               CONTENT_CMD_LIB_DIR=dirs["lib"],
               CONTENT_CMD_WORK_DIR=dirs["work"])
    p = subprocess.run([VALIDATOR], capture_output=True, text=True, env=env)
    return p.returncode, p.stdout


def main():
    failures = 0
    with tempfile.TemporaryDirectory(prefix="a11-iss-29-") as root:
        dirs = build(root)
        code, out = run(dirs)
        ok = code == 0
        print(f"{'PASS' if ok else 'FAIL'}  unmutated copy passes (exit {code})")
        if not ok:
            failures += 1
            print(out)

        for label, name, old, new in MUTATIONS:
            dirs = build(root)
            found = True
            for sub in ("lib", "work"):
                path = os.path.join(dirs[sub], name)
                with open(path) as fh:
                    text = fh.read()
                if old not in text:
                    print(f"FAIL  {label}: anchor {old!r} no longer in {name}")
                    failures += 1
                    found = False
                    break
                with open(path, "w") as fh:
                    fh.write(text.replace(old, new))
            if not found:
                continue
            code, out = run(dirs)
            caught = code != 0
            print(f"{'PASS' if caught else 'FAIL'}  caught: {label} (exit {code})")
            if not caught:
                failures += 1

        # Drift between the library and working copies is its own defect.
        dirs = build(root)
        with open(os.path.join(dirs["work"], "blog.md"), "a") as fh:
            fh.write("\nAn edit made only in the working copy.\n")
        code, out = run(dirs)
        caught = code != 0 and "differ" in out
        print(f"{'PASS' if caught else 'FAIL'}  caught: the two copies drifted apart (exit {code})")
        if not caught:
            failures += 1
            print(out)

    print("\n" + ("all mutations caught" if failures == 0
                  else f"{failures} case(s) NOT caught"))
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
