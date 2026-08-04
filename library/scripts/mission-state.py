#!/usr/bin/env python3
"""mission-state.py — the coordinator's phase counters, on disk (T-363).

WHY THIS EXISTS. Before this script the meta-loop's counters (`cycles_this_phase`,
`clean_rounds`, `PHASE_ERROR_BUDGET`) lived only in the coordinator's pseudocode, which
means they lived only in the model's head. A counter the model reports is a CLAIM. A
counter on disk is a FACT. That distinction is not academic: `claude auth status`
reported `loggedIn: true` for three weeks on a dead credential because nothing checked
the thing it was reporting.

WHAT IT ACTUALLY CHANGES, as opposed to what a state file alone would change:

  1. `cycle` INCREMENTS the counter itself and EXITS 3 when the per-phase error budget
     is spent. Escalation stops depending on the coordinator remembering to count. A
     non-zero exit is a fact the orchestrator cannot narrate its way past.
  2. `clean-round` REFUSES a clean round with no `--evidence`. The default-fail contract
     says a criterion flips to pass only on captured tool output; here that contract is
     the argument parser's job, not a paragraph's.
  3. Every mutation appends to a JSONL log, so the run's history is auditable after the
     fact rather than reconstructed from a transcript.
  4. `resume` prints the last phase whose gate passed ON EVIDENCE, giving a mission that
     dies mid-phase a recovery point that survives `/clear`, a crash, or a new session.

WHAT IT DOES NOT DO, stated plainly because overclaiming enforcement is the exact defect
this repo spent two sprints removing:

  - It does not stop an agent lying to it. Whoever calls `clean-round --evidence "..."`
    chooses that string, and nothing here re-runs the command or checks the output is
    real. It moves the counter out of the model's head; it does not move the JUDGEMENT
    out. Evidence quality is still the phase gate's problem.
  - It is not protected by the gate deny rules. `.claude/state/` is not a gate path, so
    an agent can rewrite this file. It is an honest bookkeeper, not a boundary.
  - It does not run itself. If the coordinator never calls it, the counters are absent
    rather than wrong, which is why `show` reports "no state" loudly instead of zeros.

Usage:
  mission-state.py init --mission build [--budget 3] [--phases 5]
  mission-state.py phase-start 2 [--name "Core implementation"]
  mission-state.py cycle                       # exit 3 = budget spent, ESCALATE
  mission-state.py clean-round --evidence "pytest -q: 41 passed"   # exit 4 = converged
  mission-state.py gate-pass --evidence "..."  # record phase gate passed on evidence
  mission-state.py show [--json]
  mission-state.py resume
  mission-state.py reset-clean                 # new work invalidates convergence

Exit codes:
  0  fine, carry on
  1  usage or state error
  3  per-phase error budget spent — STOP and escalate to the human
  4  phase converged (two clean rounds) — advance to the next phase
"""

import argparse
import json
import os
import sys
from datetime import datetime, timezone

STATE_DIR = os.environ.get("AGENT11_STATE_DIR", ".claude/state")
STATE_FILE = os.path.join(STATE_DIR, "mission-state.json")
LOG_FILE = os.path.join(STATE_DIR, "mission-state.log")

CONVERGENCE_ROUNDS = 2  # two clean verify rounds, per the Sprint 6c meta-loop


def now():
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


def load():
    if not os.path.exists(STATE_FILE):
        return None
    try:
        with open(STATE_FILE, encoding="utf-8") as fh:
            return json.load(fh)
    except (OSError, ValueError) as exc:
        print(f"mission-state: {STATE_FILE} is unreadable ({exc}). "
              "Refusing to guess the counters — re-init or repair it by hand.",
              file=sys.stderr)
        sys.exit(1)


def save(state, event, **detail):
    os.makedirs(STATE_DIR, exist_ok=True)
    state["updated_at"] = now()
    tmp = STATE_FILE + ".tmp"
    with open(tmp, "w", encoding="utf-8") as fh:
        json.dump(state, fh, indent=2, sort_keys=True)
        fh.write("\n")
    os.replace(tmp, STATE_FILE)  # atomic: a crash mid-write cannot truncate the counters

    entry = {"at": state["updated_at"], "event": event,
             "phase": state.get("active_phase"),
             "cycles_this_phase": state.get("cycles_this_phase"),
             "clean_rounds": state.get("clean_rounds")}
    entry.update(detail)
    with open(LOG_FILE, "a", encoding="utf-8") as fh:
        fh.write(json.dumps(entry, sort_keys=True) + "\n")


def require(state):
    if state is None:
        print("mission-state: no state file. Run `mission-state.py init --mission <name>` "
              "at mission start. Absent counters are reported as absent, never as zero.",
              file=sys.stderr)
        sys.exit(1)
    return state


def cmd_init(args):
    state = {
        "mission": args.mission,
        "started_at": now(),
        "updated_at": now(),
        "phase_error_budget": args.budget,
        "total_phases": args.phases,
        "active_phase": 1,
        "active_phase_name": args.name or "",
        "cycles_this_phase": 0,
        "clean_rounds": 0,
        "last_evidence_passed_phase": 0,
        "gate_evidence": {},
        "escalations": [],
    }
    save(state, "init", mission=args.mission, budget=args.budget)
    print(f"mission-state: {args.mission} initialised at phase 1, "
          f"error budget {args.budget} cycles/phase -> {STATE_FILE}")
    return 0


def cmd_phase_start(args):
    state = require(load())
    state["active_phase"] = args.phase
    state["active_phase_name"] = args.name or ""
    state["cycles_this_phase"] = 0
    state["clean_rounds"] = 0
    save(state, "phase-start", phase_name=args.name or "")
    print(f"mission-state: phase {args.phase} started; counters reset "
          f"(budget {state['phase_error_budget']} cycles)")
    return 0


def cmd_cycle(args):
    state = require(load())
    state["cycles_this_phase"] += 1
    # New work invalidates convergence: the two clean rounds must be consecutive and
    # must follow the last change, or they are counting a stale build.
    state["clean_rounds"] = 0
    spent = state["cycles_this_phase"] > state["phase_error_budget"]
    if spent:
        state["escalations"].append({"at": now(), "phase": state["active_phase"],
                                     "cycles": state["cycles_this_phase"],
                                     "note": args.note or ""})
    save(state, "cycle", budget_spent=spent, note=args.note or "")
    used, budget = state["cycles_this_phase"], state["phase_error_budget"]
    if spent:
        print(f"mission-state: ESCALATE. Phase {state['active_phase']} has used {used} of "
              f"{budget} delegate->verify cycles. The budget is spent. Stop and hand back "
              f"to the human — do not burn forward.", file=sys.stderr)
        return 3
    print(f"mission-state: phase {state['active_phase']} cycle {used}/{budget}")
    return 0


def cmd_clean_round(args):
    state = require(load())
    evidence = (args.evidence or "").strip()
    if not evidence:
        print("mission-state: refusing to record a clean round with no evidence. A gate "
              "flips to pass on captured tool output, never on assertion. Pass the "
              "command and its result via --evidence.", file=sys.stderr)
        return 1
    state["clean_rounds"] += 1
    save(state, "clean-round", evidence=evidence)
    rounds = state["clean_rounds"]
    if rounds >= CONVERGENCE_ROUNDS:
        print(f"mission-state: phase {state['active_phase']} CONVERGED "
              f"({rounds} consecutive clean verify rounds). Advance.")
        return 4
    print(f"mission-state: clean round {rounds}/{CONVERGENCE_ROUNDS} on phase "
          f"{state['active_phase']}. Run one more verify round.")
    return 0


def cmd_reset_clean(args):
    state = require(load())
    state["clean_rounds"] = 0
    save(state, "reset-clean", note=args.note or "")
    print(f"mission-state: convergence counter reset on phase {state['active_phase']}")
    return 0


def cmd_gate_pass(args):
    state = require(load())
    evidence = (args.evidence or "").strip()
    if not evidence:
        print("mission-state: refusing to record a gate pass with no evidence.",
              file=sys.stderr)
        return 1
    phase = state["active_phase"]
    state["last_evidence_passed_phase"] = phase
    state["gate_evidence"][str(phase)] = {"at": now(), "evidence": evidence}
    save(state, "gate-pass", evidence=evidence)
    print(f"mission-state: phase {phase} gate recorded as passed on evidence. "
          f"Recovery point is now phase {phase}.")
    return 0


def cmd_show(args):
    state = load()
    if state is None:
        print("mission-state: no state file at " + STATE_FILE, file=sys.stderr)
        return 1
    if args.json:
        json.dump(state, sys.stdout, indent=2, sort_keys=True)
        sys.stdout.write("\n")
        return 0
    print(f"mission        {state['mission']}")
    print(f"active phase   {state['active_phase']} {state.get('active_phase_name', '')}".rstrip())
    print(f"cycles         {state['cycles_this_phase']}/{state['phase_error_budget']}")
    print(f"clean rounds   {state['clean_rounds']}/{CONVERGENCE_ROUNDS}")
    print(f"recovery point phase {state['last_evidence_passed_phase']} "
          f"(last gate passed on evidence)")
    if state.get("escalations"):
        print(f"escalations    {len(state['escalations'])}")
    return 0


def cmd_resume(args):
    state = load()
    if state is None:
        print("mission-state: no state file — start from the top, or run init.",
              file=sys.stderr)
        return 1
    last = state["last_evidence_passed_phase"]
    print(f"Resume {state['mission']} at phase {last + 1}. "
          f"Phases 1-{last} passed their gates on evidence and must not be re-run.")
    if state["cycles_this_phase"]:
        print(f"Phase {state['active_phase']} was mid-flight: "
              f"{state['cycles_this_phase']}/{state['phase_error_budget']} cycles used, "
              f"{state['clean_rounds']}/{CONVERGENCE_ROUNDS} clean rounds.")
    return 0


def main(argv=None):
    p = argparse.ArgumentParser(prog="mission-state.py", description=__doc__,
                               formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = p.add_subparsers(dest="cmd", required=True)

    s = sub.add_parser("init"); s.set_defaults(fn=cmd_init)
    s.add_argument("--mission", required=True)
    s.add_argument("--budget", type=int, default=3)
    s.add_argument("--phases", type=int, default=0)
    s.add_argument("--name", default="")

    s = sub.add_parser("phase-start"); s.set_defaults(fn=cmd_phase_start)
    s.add_argument("phase", type=int)
    s.add_argument("--name", default="")

    s = sub.add_parser("cycle"); s.set_defaults(fn=cmd_cycle)
    s.add_argument("--note", default="")

    s = sub.add_parser("clean-round"); s.set_defaults(fn=cmd_clean_round)
    s.add_argument("--evidence", default="")

    s = sub.add_parser("reset-clean"); s.set_defaults(fn=cmd_reset_clean)
    s.add_argument("--note", default="")

    s = sub.add_parser("gate-pass"); s.set_defaults(fn=cmd_gate_pass)
    s.add_argument("--evidence", default="")

    s = sub.add_parser("show"); s.set_defaults(fn=cmd_show)
    s.add_argument("--json", action="store_true")

    s = sub.add_parser("resume"); s.set_defaults(fn=cmd_resume)

    args = p.parse_args(argv)
    return args.fn(args)


if __name__ == "__main__":
    sys.exit(main())
