# Hook-entity ontology — what the hooks actually reason over

Two shipped bugs (A11-ISS-4, A11-ISS-7) came from the same defect class: a hook or
permission rule reasoned over an entity that was never formally defined. The same class
cost Mission Control 17 completions on 22 July (hand-written status strings vs the enum
`mc-shipped.py` parses). This note writes the contracts down, derived from the shipped
files, so v6 planning inherits definitions rather than assumptions.

Sources: `library/settings.json.template`, `library/hooks/gate-guard.sh`,
`project/deployment/scripts/install.sh` (lines 810-817, deploys the guard to
`.claude/hooks/gate-guard.sh`), `ISSUES.md` (A11-ISS-4, A11-ISS-7, A11-ISS-10).

## Entity 1: the gate operation (gate-guard.sh)

The PreToolUse Bash hook must decide "is this Bash call a gate write?". A11-ISS-4:
before the definition existed, a settings.json `if` glob approximated it and failed open
on complex commands (a multi-line python-detection for-loop was blocked during
`/foundations` in digital-estate). The fix moved the decision into
`library/hooks/gate-guard.sh`, which inspects the real `tool_input.command` from hook
stdin. The formal entity, as the shipped script defines it:

| Component | Contract (from gate-guard.sh) |
|---|---|
| Gate path, file | any token matching `[^[:space:]"']*quality-gates` (regex `qg`, line 40) — `.quality-gates.json` and variants |
| Gate path, dir | a path starting `gates/` or `.gates/`, optionally `./`-prefixed (regex `gd='(\./)?\.?gates/'`, line 41); `delegates/` must NOT match |
| Write verb 1 | shell redirection into a gate path: `[0-9]?>>?` before `gd` or `qg.json` (line 45) |
| Write verb 2 | `tee` (incl. `-a`) with a gate path argument (line 48) |
| Write verb 3 | `sed -i` on a gate path (line 51) |
| Write verb 4 | `cp` or `mv` onto a gate path (line 54) |
| Fast allow | payload not containing the literal `gates` → exit 0 before parsing (line 21) |
| Verdicts | exit 0 = allow; exit 2 = block, stderr fed back to the model |
| Absent script | hook wrapper in settings.json.template line 57 skips it — fail-open by design; Edit deny rules still hold |

Definition: a **gate operation** is a Bash command whose text matches one of the four
write-verb patterns against a gate path. Everything else is ordinary Bash. A read
(`cat gates/x`), a mention (`echo gates`), or any non-Bash tool is not a gate operation.

## Entity 2: the tool entity model (permission rules)

A11-ISS-7: the template shipped `Write(path)` and `MultiEdit(path)` deny rules on the
assumption that each file tool matches its own rule name. Wrong model: Claude Code
matches ONLY `Edit(path)` rules for file tools (one `Edit` rule covers Edit, Write,
MultiEdit, NotebookEdit); `Write()`/`MultiEdit()` forms are ignored with a session-start
warning (confirmed empirically on claude 2.1.218). The rules no-opped — no security gap
only because the four `Edit` rules already covered every gate path.

| Facet | Contract |
|---|---|
| File-tool identity | one entity, named `Edit` in permission rules, regardless of which editing tool fires |
| Shipped deny set | `Edit(.quality-gates.json)`, `Edit(**/*.quality-gates.json)`, `Edit(gates/**)`, `Edit(.gates/**)` (settings.json.template lines 10-13) |
| Bash rules | `Bash(pattern*)` prefix match on the command string, e.g. `Bash(git push --force*)` (line 51); Edit rules never cover Bash, hence the gate-guard hook |
| Hook matchers | `matcher` field is a regex-alternation over tool names: `"Edit|Write|MultiEdit"`, `"Bash"` (lines 19, 47) — a different namespace from permission rules |
| MCP tools | named `mcp__server__tool`; matched literally, not covered by `Edit` file-tool folding |
| Wildcards | `*`/`**` glob inside the parens (paths) or trailing `*` (Bash prefixes); no wildcarding of the tool name itself |
| Invalid rule behaviour | silently inert bar a startup warning — a wrong tool name is a no-op, not an error (the A11-ISS-7 failure mode) |

A11-ISS-10 extended the fix: `merge-settings.py` now removes the stale
`Write()`/`MultiEdit()` forms and lands the four `Edit` rules on `--upgrade`.

## Lessons graft for v6 (T-139/T-130 lineage)

Rule: **any entity a hook or rule reasons over must have a written contract — an enum,
pattern set, or schema — that deterministic code checks; never an implicit shared
understanding.** A11-ISS-4 was a missing gate-operation contract; A11-ISS-7 a missing
tool-entity contract; Mission Control's lost 17 completions a missing status-enum
contract (sibling fix: T-269 ontology hardening on the vault side, from the Frank Coyle
distil). For v6: every new hook, matcher, or rule ships with its entity definition in a
doc like this one, plus a fixture that proves the deterministic check against real
payloads — the A11-ISS-4/7 resolutions already model that proof style.
