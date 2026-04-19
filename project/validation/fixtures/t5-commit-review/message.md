security: Add install integrity verification, lockfile, terminal detection, and CI hardening

Sprint 2 of security audit findings:
- Add secure-install.sh with SHA-256 checksum verification (replaces raw curl|bash)
- Generate install.sh.sha256 for integrity verification
- Update one-line-install.sh to recommend secure installer
- Add concurrent execution lockfile to prevent install corruption
- Add terminal detection to disable ANSI colors when piped (5 scripts)
- Pin all GitHub Actions to commit SHAs for supply-chain hardening
- Upgrade actions/checkout v3->v4.2.2, setup-node v3->v4.4.0,
  github-script v6->v7.0.1, upload-artifact v3->v4.6.2

Note: T2 (git clone verification), T3 (nullglob), T5 (sort -V), T8 (::set-output)
were found to be N/A after verifying actual code - the audit agent reported issues
in code patterns that don't exist in the current codebase.

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>

