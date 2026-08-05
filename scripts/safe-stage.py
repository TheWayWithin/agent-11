#!/usr/bin/env python3
"""
safe-stage.py — stage untracked files for commit, refusing the ones that must never be committed.

    python3 scripts/safe-stage.py <repo-path>                  # classify only, stage nothing
    python3 scripts/safe-stage.py <repo-path> --stage          # stage the SAFE files
    python3 scripts/safe-stage.py <repo-path> --stage -m "..." # stage and commit with a real message

WHY THIS EXISTS (A11W-ISS-18, 2026-08-05).

During the fleet tidy on 2026-08-05 an ad-hoc script walked 17 repos, took whatever
`git status` reported as untracked, filtered build artefacts, and committed the rest
under a generated message. In agent-11-website that swept `tests/_poll.spec.ts`, a
throwaway diagnostic spec, into a public repo under the message "add 1 untracked
files written over past months" — a message that is both wrong about the count and
silent about the content. The repo's own agent raised it as a high-severity issue.

The sweep was wrong in three ways, and only the first is obvious:

1. It committed files nobody had looked at. "Untracked" means unexamined, not wanted.
2. Its commit message was generated from a count, so it could not describe what it
   was committing, which is exactly when a reviewer stops reading.
3. It relied on the gitleaks pre-commit hook as the backstop against secrets.

The third is the dangerous one, and it is measured rather than assumed. In a scratch
repo with the real global hook active (core.hooksPath=~/.git-hooks), a `.env`
containing:

    DB_PASSWORD=hunter2
    SMTP_PASS=letmein123

**committed cleanly**. gitleaks detects secrets that match a known SHAPE — an
sk_live_ prefix, a JWT, an AWS key id. A bare password has no shape, so nothing
fires. `~/DevProjects/CLAUDE.md` says this outright after the ISS-15 breach: the
hook "misses unpatterned secrets (bare passwords)" and is "NOT permission to be
careless". A sweep that trusts it is trusting a filter with a known hole.

So refusal here is by FILENAME, independent of content, because the content check
provably does not catch this class. A file named `.env` is refused whether it holds
a live key, a bare password, or nothing at all.

Nothing is ever deleted. Refused files stay exactly where they are, untracked; the
script only declines to stage them and says why.
"""

import argparse
import os
import re
import subprocess
import sys

# ---------------------------------------------------------------------------
# NEVER STAGE. Filename-based and content-independent, for the reason above.
# ---------------------------------------------------------------------------
SECRET = [
    # .env and every variant, EXCEPT the documented placeholder forms, which are
    # meant to be committed and contain no values.
    (r'(^|/)\.env($|\.)(?!.*\b(example|template|sample|dist)\b)', 'env file: may hold credentials'),
    (r'(^|/)\.(npmrc|pypirc|netrc|htpasswd)$',                    'holds a registry or auth token'),
    (r'\.(pem|key|p12|pfx|jks|keystore|kdbx|ppk)$',               'private key or keystore'),
    (r'(^|/)id_(rsa|dsa|ecdsa|ed25519)$',                         'ssh private key'),
    (r'(^|/)(credentials|secrets?)\.(json|ya?ml|toml|ini|txt)$',  'credentials file'),
    (r'service[-_]?account.*\.json$',                             'cloud service-account key'),
    (r'\.tfstate(\.backup)?$',                                    'terraform state: stores secrets in clear'),
    (r'(^|/)\.(aws|ssh|gnupg)/',                                  'credential directory'),
    (r'(^|/)\.git-credentials$',                                  'stored git credentials'),
]

# Scratch work. Real to whoever made it, not to the repo's history.
THROWAWAY = [
    (r'(^|/)_[^/]*\.(spec|test)\.[jt]sx?$', 'underscore-prefixed spec: the A11W-ISS-18 file'),
    (r'(^|/)(tmp|temp|scratch|diag|debug)[-_.][^/]*$', 'scratch filename prefix'),
    (r'[-_](tmp|temp|scratch|diag|debug)\.[^/]+$',     'scratch filename suffix'),
    (r'\.(bak|orig|rej|swp|swo)$|~$',                  'editor or merge leftover'),
    (r'(^|/)(untitled|new file|copy of )',             'unnamed placeholder'),
]

# Regenerated output. Safe, but noise in a diff.
ARTEFACT = [
    (r'(^|/)(node_modules|\.next|dist|build|coverage|__pycache__|\.venv|venv)/', 'build output'),
    (r'(^|/)(test-results|playwright-report|\.playwright-mcp|Logs|\.temp)[-\w]*/', 'test or tool output'),
    (r'(^|/)\.DS_Store$|\.(log|pyc|pyo)$',            'os or interpreter litter'),
    (r'\.backup-\d|(^|/)backups?/',                   'install backup'),
    (r'(^|/)\.mcp-status\.md$',                       'generated status file'),
]


def classify(path):
    for pats, kind in ((SECRET, 'SECRET'), (THROWAWAY, 'THROWAWAY'), (ARTEFACT, 'ARTEFACT')):
        for rx, why in pats:
            if re.search(rx, path, re.I):
                return kind, why
    return 'SAFE', ''


def untracked(repo):
    # -z because git QUOTES paths containing spaces in its default output, and a
    # quoted path matches no real file. That bug silently staged nothing during
    # the same 2026-08-05 sweep.
    out = subprocess.run(['git', '-C', repo, 'status', '--porcelain', '-z', '--untracked-files=all'],
                         capture_output=True, text=True).stdout
    return [e[3:] for e in out.split('\0') if e.startswith('?? ')]


def main():
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[1])
    ap.add_argument('repo')
    ap.add_argument('--stage', action='store_true', help='actually stage the SAFE files')
    ap.add_argument('-m', '--message', help='commit message; required to commit, never generated')
    ap.add_argument('--include-artefacts', action='store_true',
                    help='also stage build output (rarely right; prefer .gitignore)')
    a = ap.parse_args()
    repo = os.path.expanduser(a.repo)

    if not os.path.isdir(os.path.join(repo, '.git')):
        print(f'not a git repo: {repo}', file=sys.stderr)
        return 2

    buckets = {'SAFE': [], 'SECRET': [], 'THROWAWAY': [], 'ARTEFACT': []}
    for f in untracked(repo):
        kind, why = classify(f)
        buckets[kind].append((f, why))

    name = os.path.basename(repo.rstrip('/'))
    print(f'\n{name}: {sum(len(v) for v in buckets.values())} untracked file(s)\n')

    for kind, headline in (
            ('SECRET',    'REFUSED — never committed, whatever the content'),
            ('THROWAWAY', 'REFUSED — scratch work, not repo history'),
            ('ARTEFACT',  'skipped — regenerated output, belongs in .gitignore'),
            ('SAFE',      'safe to stage')):
        items = buckets[kind]
        if not items:
            continue
        print(f'  {kind} ({len(items)}) — {headline}')
        for f, why in items[:12]:
            print(f'      {f}' + (f'   [{why}]' if why else ''))
        if len(items) > 12:
            print(f'      ... and {len(items) - 12} more')
        print()

    # A secret-shaped filename stops the run outright. It is never a judgement call,
    # and it must not be possible to proceed past it by not reading the output.
    if buckets['SECRET']:
        print('  STOPPING: a file whose NAME marks it as credential-bearing is present.')
        print('  gitleaks will not save you here — a bare password has no pattern to match,')
        print('  and this was measured, not assumed. Add it to .gitignore, or move the values')
        print('  into a real secret store. Nothing has been staged.\n')
        return 1

    to_stage = [f for f, _ in buckets['SAFE']]
    if a.include_artefacts:
        to_stage += [f for f, _ in buckets['ARTEFACT']]

    if not a.stage:
        print('  Classification only. Re-run with --stage to stage the SAFE files.\n')
        return 0
    if not to_stage:
        print('  Nothing safe to stage.\n')
        return 0

    subprocess.run(['git', '-C', repo, 'add', '--'] + to_stage, check=True)
    print(f'  staged {len(to_stage)} file(s)')

    if not a.message:
        print('  No -m given, so nothing was committed. A message is required and is never\n'
              '  generated from a file count: "add 1 untracked files" is what made A11W-ISS-18\n'
              '  unreviewable. Say what the files are and why they belong.\n')
        return 0

    r = subprocess.run(['git', '-C', repo, 'commit', '-m', a.message], capture_output=True, text=True)
    if r.returncode != 0:
        # Report the real reason. The 2026-08-05 sweep printed "committed" when a
        # hook had refused, which is how a blocked commit was reported as a success.
        print(f'  COMMIT REFUSED (exit {r.returncode}):')
        print('   ', (r.stdout + r.stderr).strip().replace('\n', '\n    ')[:600], '\n')
        return 1
    sha = subprocess.run(['git', '-C', repo, 'rev-parse', '--short', 'HEAD'],
                         capture_output=True, text=True).stdout.strip()
    print(f'  committed {sha}\n')
    return 0


if __name__ == '__main__':
    sys.exit(main())
