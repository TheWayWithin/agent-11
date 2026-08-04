/**
 * fleet-audit — audit every active fleet repo for AGENT-11 deployment drift.
 *
 * INTERNAL to the agent-11 repo. Not deployed to users: `.claude/` here is the working
 * squad's surface, and the fleet registry it reads is Jamie's, not a library concept.
 *
 * WHY THIS ONE FIRST. `sprints/sprint-6-fanout-scope.md` assessed every coordinator phase,
 * all 18 library missions and three non-mission jobs against the T1/T2/T3 fan-out test.
 * Two missions passed and neither passed whole. The fleet audit passed cleanly and won the
 * first build for one specific reason: its unit boundary ALREADY EXISTS IN A FILE. The
 * registry's `tier: active` entries are stable between runs and maintained for other
 * reasons, so the fan-out needs no partitioning judgement at all. Release-diff review is
 * worth more per run and lost precisely because its partition must be invented every time,
 * and a wrong split breaks T1 without saying so.
 *
 * WHAT IT DOES NOT DO, and these are constraints, not preferences:
 *   - It writes NOTHING. No auto-merge, no auto-fix, no remediation. Every finding is a
 *     hypothesis; a human decides; the fix happens in a normal session afterwards. This is
 *     why the first fan-out is read-only — it removes the worktree-isolation problem from
 *     the build entirely. Workflow subagents auto-approve file edits regardless of session
 *     permission mode, so the read-only guarantee comes from not ASKING them to write,
 *     never from a permission setting.
 *   - The verify stage runs a different model to the audit stage. Non-negotiable: a critic
 *     sharing the generator's weights returns agreement rather than verification.
 *   - No finding without file:line and a verbatim quote.
 *   - It reads `registry.yaml` and the audited repos. Nothing else under ~/shared is opened.
 *
 * A CORRECTION TO THE SCOPE DOC. Its skeleton read the registry inline
 * (`const REPOS = args?.repos ?? [...]`). Workflow scripts have no filesystem access, so a
 * script cannot parse the registry itself. Discovery is therefore an agent — which is
 * better anyway, because the alternative was a hardcoded repo list: a fifth hand-kept list
 * to drift, in a repo that has now been bitten twice by exactly that (A11-ISS-13, A11-ISS-17).
 *
 * Usage:
 *   /fleet-audit                        every tier: active repo
 *   /fleet-audit ["agent-11","scanner"] only those registry names
 */

export const meta = {
  name: 'fleet-audit',
  description: 'Audit every active fleet repo for AGENT-11 deployment drift (read-only)',
  whenToUse: 'Per-release or scheduled. Too expensive to run per-commit — a bounded 13-agent fan-out in this repo measured ~597k subagent tokens and 5 minutes.',
  phases: [
    { title: 'Discover', detail: 'read registry.yaml for tier: active repos' },
    { title: 'Audit', detail: 'one agent per repo, mechanical file inspection' },
    { title: 'Verify', detail: 'refute each high-severity finding on a different model' },
    { title: 'Report', detail: 'one ranked report from surviving findings' },
  ],
}

const REGISTRY = '~/Shared/tools/agent-11-fleet/registry.yaml'

// Workflow subagents are not AGENT-11 specialists and do not inherit the library's
// ## ORIENTATION PROTOCOL. Pasted, because the measured pilot's agents made 105 Bash calls
// against 35 Reads — searching by shell — precisely because nobody told them not to.
const ORIENTATION = `
ORIENTATION — MAP FIRST, READ NARROWLY. Orientation is the expensive step, not the answer.
1. Glob/Grep to locate before you Read. Find the path and line number first.
2. Read only the lines you need: use offset and limit.
3. Never read a whole file to find one symbol.
4. Do not re-read what you have already read.
Prefer Glob/Grep/Read over shell equivalents (find, grep, cat, ls).`

const READ_ONLY = `
READ-ONLY. Do not create, edit, move or delete any file, anywhere, for any reason. You are
producing a report, not a fix. If you believe something should change, say so in a finding
with a remediation string; do not perform it. Do not run any command that writes.`

const DISCOVERY_SCHEMA = {
  type: 'object',
  required: ['repos'],
  properties: {
    repos: {
      type: 'array',
      items: {
        type: 'object',
        required: ['name', 'path'],
        properties: {
          name: { type: 'string' },
          path: { type: 'string', description: 'absolute path' },
        },
      },
    },
    registry_readable: { type: 'boolean' },
    note: { type: 'string' },
  },
}

const UNIT_SCHEMA = {
  type: 'object',
  required: ['repo', 'path', 'reachable', 'findings', 'total_found'],
  properties: {
    repo: { type: 'string' },
    path: { type: 'string' },
    reachable: { type: 'boolean', description: 'false if the path is missing; everything below is then null' },
    agent11_version: { type: ['string', 'null'], description: 'expect null: install.sh writes no version marker today' },
    gate_rules_present: { type: 'array', items: { type: 'string' } },
    gate_rules_missing: { type: 'array', items: { type: 'string' } },
    gate_guard_installed: { type: 'boolean', description: 'file exists AND is wired as a PreToolUse hook on Bash' },
    missions_deployed: { type: 'integer' },
    missions_expected: { type: 'integer' },
    orientation_present: { type: 'boolean' },
    findings: {
      type: 'array',
      maxItems: 3,
      items: {
        type: 'object',
        required: ['severity', 'claim', 'evidence', 'remediation'],
        properties: {
          severity: { type: 'string', enum: ['high', 'medium', 'low'] },
          claim: { type: 'string' },
          evidence: { type: 'string', description: 'file:line plus a verbatim quote. No quote, no finding.' },
          remediation: { type: 'string', description: 'what a human would run. NOT run by this workflow.' },
        },
      },
    },
    total_found: { type: 'integer', description: 'honest count before the top-3 cap' },
    dropped_note: { type: 'string', description: 'what the cap dropped; empty if nothing' },
  },
}

const VERDICT_SCHEMA = {
  type: 'object',
  required: ['refuted', 'reasoning'],
  properties: {
    refuted: { type: 'boolean', description: 'true if the finding does not hold. Default true when uncertain.' },
    reasoning: { type: 'string' },
    counter_evidence: { type: 'string', description: 'file:line + quote that settles it, either way' },
  },
}

// install.sh deploys 20 files to missions/: the 18 executable missions plus README.md and
// library.md. Comparing against 18 makes every repo report a false mismatch.
const MISSIONS_EXPECTED = 20

const GATE_RULES = [
  'Edit(.quality-gates.json)',
  'Edit(**/*.quality-gates.json)',
  'Edit(gates/**)',
  'Edit(.gates/**)',
]

const VERIFY_CAP = 10

phase('Discover')
const discovery = await agent(
  `${ORIENTATION}\n${READ_ONLY}

Read the AGENT-11 fleet registry at ${REGISTRY} and return every entry whose tier is
"active", with its registry name and its absolute path. Read ONLY that file — do not open
anything else under ~/shared, and do not enter any of the repos. If the file is missing or
unparseable, return an empty repos array, registry_readable false, and say why in note.`,
  { label: 'discover:registry', phase: 'Discover', schema: DISCOVERY_SCHEMA },
)

if (!discovery || !discovery.registry_readable || !discovery.repos?.length) {
  log(`fleet-audit: no active repos discovered (${discovery?.note ?? 'discovery agent returned nothing'}). Stopping.`)
  return { repos_audited: 0, reason: discovery?.note ?? 'discovery failed' }
}

// An explicit narrowing is honoured; a silent one is not. Whatever the run covers, it says so.
const requested = Array.isArray(args) ? args : args?.repos
let repos = discovery.repos
if (requested?.length) {
  repos = repos.filter((r) => requested.includes(r.name))
  log(`fleet-audit: narrowed by args to ${repos.length} of ${discovery.repos.length} active repos: ${repos.map((r) => r.name).join(', ')}`)
} else {
  log(`fleet-audit: auditing all ${repos.length} tier:active repos. Caps in force: top 3 findings per repo, at most ${VERIFY_CAP} high-severity findings verified.`)
}

if (!repos.length) {
  log('fleet-audit: the args filter matched no registry entry. Stopping rather than silently auditing everything.')
  return { repos_audited: 0, reason: 'args matched no registry entry' }
}

phase('Audit')
const audited = await pipeline(
  repos,
  (repo) =>
    agent(
      `${ORIENTATION}\n${READ_ONLY}

Audit the repository "${repo.name}" at ${repo.path} for AGENT-11 deployment drift. This is
mechanical file inspection: read and report, do not judge. Answer only from files you have
actually opened; if you cannot determine something, say so rather than inferring it.

Check, and quote what you find:
1. Do the four gate deny rules appear in .claude/settings.json permissions.deny?
   ${GATE_RULES.map((r) => `   - ${r}`).join('\n')}
   Report which are present and which are missing, verbatim.
2. Does .claude/hooks/gate-guard.sh exist, AND is it wired as a PreToolUse hook on the Bash
   matcher in .claude/settings.json? Both are required — the hook fails open without the
   script, and the script does nothing unwired.
3. How many .md files are in missions/? Expected ${MISSIONS_EXPECTED} (18 executable missions
   plus README.md and library.md). Report the actual count.
4. Do the specialist agents in .claude/agents/ carry a "## ORIENTATION PROTOCOL" section?
5. Is there any AGENT-11 version marker? Expect null — install.sh writes none today.

If ${repo.path} does not exist or cannot be read, set reachable false and leave the rest null.

Return at most your 3 highest-severity findings, but report total_found honestly and name
what the cap dropped in dropped_note. Every finding needs file:line and a verbatim quote in
evidence — no quote, no finding. remediation says what a HUMAN would run; you do not run it.`,
      { label: `audit:${repo.name}`, phase: 'Audit', model: 'sonnet', schema: UNIT_SCHEMA },
    ),
  // Verification is nested inside the pipeline so repo 2 can be verifying while repo 7 is
  // still being audited. A barrier here would waste the fast repos' wall-clock for nothing:
  // no finding needs to see another finding to be refuted.
  (unit) => {
    if (!unit || !unit.reachable) return unit
    const high = (unit.findings ?? []).filter((f) => f.severity === 'high')
    if (!high.length) return { ...unit, verdicts: [] }
    return parallel(
      high.map((f) => () =>
        agent(
          `${ORIENTATION}\n${READ_ONLY}

A cheaper model audited the repository "${unit.repo}" at ${unit.path} and raised this finding.
Your job is to REFUTE it. Re-read the repository yourself; do not take the claim on trust.

  Claim:     ${f.claim}
  Evidence:  ${f.evidence}

Set refuted true unless the file text forces the opposite. Default to refuted when uncertain:
a finding that cannot be substantiated from the files is noise, and noise that survives
verification is worse than a finding that never got raised. Quote file:line in
counter_evidence either way.`,
          { label: `verify:${unit.repo}`, phase: 'Verify', model: 'opus', schema: VERDICT_SCHEMA },
        ).then((v) => ({ finding: f, verdict: v })),
      ),
    ).then((verdicts) => ({ ...unit, verdicts: verdicts.filter(Boolean) }))
  },
)

const units = audited.filter(Boolean)
const unreachable = units.filter((u) => !u.reachable)
const allVerdicts = units.flatMap((u) => u.verdicts ?? [])
const survived = allVerdicts.filter((v) => v.verdict && !v.verdict.refuted)
const refuted = allVerdicts.filter((v) => v.verdict && v.verdict.refuted)
const totalRaised = units.reduce((n, u) => n + (u.total_found ?? 0), 0)
const highRaised = units.reduce((n, u) => n + (u.findings ?? []).filter((f) => f.severity === 'high').length, 0)

if (highRaised > VERIFY_CAP) {
  log(`fleet-audit: ${highRaised} high-severity findings raised but only ${VERIFY_CAP} were budgeted for verification. Unverified findings are NOT confirmed.`)
}

phase('Report')
const report = await agent(
  `Write one ranked fleet report for a human who will decide what to act on. You are
summarising an audit that has already happened; do not open any repository yourself, and do
not add findings of your own.

Findings that SURVIVED adversarial verification on a different model (${survived.length}):
${JSON.stringify(survived, null, 2)}

Findings that were REFUTED (${refuted.length}) — list these separately and briefly, because a
refuted finding is information about the auditor, not about the repo:
${JSON.stringify(refuted.map((r) => ({ claim: r.finding.claim, why: r.verdict.reasoning })), null, 2)}

Per-repo state:
${JSON.stringify(units.map((u) => ({
    repo: u.repo, reachable: u.reachable, gate_rules_missing: u.gate_rules_missing,
    gate_guard_installed: u.gate_guard_installed, missions_deployed: u.missions_deployed,
    missions_expected: u.missions_expected, orientation_present: u.orientation_present,
    total_found: u.total_found, dropped_note: u.dropped_note,
  })), null, 2)}

Rank by what a human should look at first. State every cap out loud: top 3 findings per repo,
at most ${VERIFY_CAP} high-severity findings verified, ${unreachable.length} repo(s) unreachable.
Say plainly that nothing here has been applied and that every item is a hypothesis awaiting a
human decision. Do not recommend running anything automatically.`,
  { label: 'report:fleet', phase: 'Report', model: 'opus' },
)

// The run reports its real cost. A fan-out that hides its bill cannot be judged worth it.
return {
  report,
  cost: {
    agents_spawned: 1 + units.length + allVerdicts.length + 1,
    repos_audited: units.length,
    repos_unreachable: unreachable.length,
    findings_raised_self_reported: totalRaised,
    high_severity_raised: highRaised,
    high_severity_verified: allVerdicts.length,
    findings_surviving: survived.length,
    findings_refuted: refuted.length,
  },
  caps_applied: {
    findings_per_repo: 3,
    verifications: VERIFY_CAP,
    note: 'total_found is self-reported by the same capped agent, so it is not a census.',
  },
}
