#!/usr/bin/env python3
"""
AGENT-11 Quality Gate Runner

Executes quality gates and reports results for mission orchestration.
Pure Python implementation with no external dependencies.

Usage:
    python run-gates.py --config .quality-gates.json --phase implementation
    python run-gates.py --gate pre-deploy --verbose
    python run-gates.py --list

Exit Codes:
    0 - All blocking gates passed
    1 - One or more blocking gates failed
    2 - Configuration or runtime error
"""

import argparse
import json
import os
import subprocess
import sys
import time
from dataclasses import dataclass, field
from datetime import datetime
from enum import Enum
from pathlib import Path
from typing import Optional


# =============================================================================
# Constants and Configuration
# =============================================================================

VERSION = "1.0.0"
DEFAULT_TIMEOUT = 300  # 5 minutes
DEFAULT_CONFIG = ".quality-gates.json"


class Severity(Enum):
    """Check severity levels."""
    CRITICAL = "critical"
    WARNING = "warning"
    INFO = "info"


class CheckStatus(Enum):
    """Result status for individual checks."""
    PASS = "pass"
    FAIL = "fail"
    WARN = "warn"
    SKIP = "skip"
    ERROR = "error"


# =============================================================================
# Data Classes
# =============================================================================

@dataclass
class CheckResult:
    """Result of a single check execution."""
    check_id: str
    name: str
    status: CheckStatus
    command: str
    duration: float
    exit_code: Optional[int] = None
    output: str = ""
    error: str = ""
    severity: Severity = Severity.CRITICAL
    remediation: list = field(default_factory=list)
    skip_reason: str = ""


@dataclass
class GateResult:
    """Result of a complete gate execution."""
    gate_id: str
    name: str
    gate_type: str
    phase: str
    trigger: str
    blocking: bool
    checks: list
    passed: bool
    duration: float
    timestamp: str


# =============================================================================
# Core Functions
# =============================================================================

def load_gate_config(config_path: str) -> dict:
    """
    Load and parse gate configuration from JSON file.

    Args:
        config_path: Path to the configuration file

    Returns:
        Parsed configuration dictionary

    Raises:
        FileNotFoundError: If config file doesn't exist
        json.JSONDecodeError: If config is invalid JSON
        ValueError: If config structure is invalid
    """
    path = Path(config_path)

    if not path.exists():
        raise FileNotFoundError(f"Configuration file not found: {config_path}")

    with open(path, 'r', encoding='utf-8') as f:
        config = json.load(f)

    # Validate required fields
    if 'version' not in config:
        raise ValueError("Configuration missing required 'version' field")
    if 'gates' not in config or not config['gates']:
        raise ValueError("Configuration missing required 'gates' array")

    return config


def should_skip_check(check: dict, env: dict) -> tuple:
    """
    Determine if a check should be skipped based on skip_if condition.

    Args:
        check: Check configuration dictionary
        env: Environment variables for execution

    Returns:
        Tuple of (should_skip: bool, reason: str)
    """
    skip_if = check.get('skip_if')
    if not skip_if:
        return False, ""

    try:
        result = subprocess.run(
            skip_if,
            shell=True,
            capture_output=True,
            timeout=30,
            env=env
        )
        if result.returncode == 0:
            return True, f"Skip condition met: {skip_if}"
    except subprocess.TimeoutExpired:
        pass
    except Exception:
        pass

    return False, ""


def expand_env_vars(command: str, env: dict) -> str:
    """
    Expand environment variables in command string.
    Supports ${VAR:-default} syntax.

    Args:
        command: Command string with potential env vars
        env: Environment dictionary

    Returns:
        Command with expanded variables
    """
    import re

    def replace_var(match):
        var_expr = match.group(1)
        if ':-' in var_expr:
            var_name, default = var_expr.split(':-', 1)
            return env.get(var_name, os.environ.get(var_name, default))
        else:
            return env.get(var_expr, os.environ.get(var_expr, ''))

    # Match ${VAR} or ${VAR:-default}
    pattern = r'\$\{([^}]+)\}'
    return re.sub(pattern, replace_var, command)


def run_check(check: dict, defaults: dict, verbose: bool = False) -> CheckResult:
    """
    Execute a single check and return the result.

    Args:
        check: Check configuration dictionary
        defaults: Default configuration values
        verbose: Whether to print verbose output

    Returns:
        CheckResult with execution details
    """
    check_id = check.get('id', check.get('type', 'unknown'))
    name = check.get('name', check_id)
    severity = Severity(check.get('severity', 'critical'))
    timeout = check.get('timeout', defaults.get('timeout', DEFAULT_TIMEOUT))
    expected_exit = check.get('expected_exit_code', 0)
    remediation_data = check.get('remediation', {})

    # Handle remediation as dict or list
    if isinstance(remediation_data, dict):
        remediation = remediation_data.get('manual_steps', [])
    elif isinstance(remediation_data, list):
        remediation = remediation_data
    else:
        remediation = []

    # Build environment
    env = os.environ.copy()
    env.update(defaults.get('env', {}))
    env.update(check.get('env', {}))

    # Check skip condition
    should_skip, skip_reason = should_skip_check(check, env)
    if should_skip:
        return CheckResult(
            check_id=check_id,
            name=name,
            status=CheckStatus.SKIP,
            command=check.get('command', ''),
            duration=0.0,
            severity=severity,
            skip_reason=skip_reason
        )

    # Expand command variables
    command = expand_env_vars(check.get('command', ''), env)

    # Determine working directory
    working_dir = check.get('working_dir', defaults.get('working_dir', '.'))

    if verbose:
        print(f"  Running: {command}")
        print(f"  Timeout: {timeout}s")

    start_time = time.time()

    try:
        result = subprocess.run(
            command,
            shell=True,
            capture_output=True,
            timeout=timeout,
            cwd=working_dir,
            env=env,
            text=True
        )

        duration = time.time() - start_time

        if result.returncode == expected_exit:
            status = CheckStatus.PASS
        elif severity == Severity.WARNING:
            status = CheckStatus.WARN
        elif severity == Severity.INFO:
            status = CheckStatus.PASS
        else:
            status = CheckStatus.FAIL

        return CheckResult(
            check_id=check_id,
            name=name,
            status=status,
            command=command,
            duration=duration,
            exit_code=result.returncode,
            output=result.stdout,
            error=result.stderr,
            severity=severity,
            remediation=remediation
        )

    except subprocess.TimeoutExpired:
        duration = time.time() - start_time
        return CheckResult(
            check_id=check_id,
            name=name,
            status=CheckStatus.ERROR,
            command=command,
            duration=duration,
            error=f"Command timed out after {timeout} seconds",
            severity=severity,
            remediation=["Increase timeout or investigate slow execution"] + remediation
        )

    except FileNotFoundError as e:
        duration = time.time() - start_time
        return CheckResult(
            check_id=check_id,
            name=name,
            status=CheckStatus.ERROR,
            command=command,
            duration=duration,
            error=f"Command not found: {e}",
            severity=severity,
            remediation=["Verify command is installed and in PATH"] + remediation
        )

    except Exception as e:
        duration = time.time() - start_time
        return CheckResult(
            check_id=check_id,
            name=name,
            status=CheckStatus.ERROR,
            command=command,
            duration=duration,
            error=str(e),
            severity=severity,
            remediation=remediation
        )


def run_gate(gate: dict, defaults: dict, verbose: bool = False) -> GateResult:
    """
    Execute all checks in a gate and return the aggregate result.

    Args:
        gate: Gate configuration dictionary
        defaults: Default configuration values
        verbose: Whether to print verbose output

    Returns:
        GateResult with all check results
    """
    gate_id = gate.get('name', gate.get('id', 'unknown'))
    name = gate.get('name', gate_id)
    gate_type = gate.get('type', 'custom')
    phase = gate.get('phase', 'unknown')
    trigger = gate.get('trigger', 'manual')
    blocking = gate.get('blocking', True)

    checks = gate.get('checks', [])
    check_results = []

    start_time = time.time()

    for check in checks:
        result = run_check(check, defaults, verbose)
        check_results.append(result)

    duration = time.time() - start_time

    # Gate passes if no blocking checks failed
    blocking_failures = [
        r for r in check_results
        if r.status in (CheckStatus.FAIL, CheckStatus.ERROR)
        and r.severity == Severity.CRITICAL
    ]
    passed = len(blocking_failures) == 0

    return GateResult(
        gate_id=gate_id,
        name=name,
        gate_type=gate_type,
        phase=phase,
        trigger=trigger,
        blocking=blocking,
        checks=check_results,
        passed=passed,
        duration=duration,
        timestamp=datetime.now().isoformat()
    )


# =============================================================================
# Output Formatting
# =============================================================================

def get_status_icon(status: CheckStatus) -> str:
    """Get display icon for check status."""
    icons = {
        CheckStatus.PASS: "[PASS]",
        CheckStatus.FAIL: "[FAIL]",
        CheckStatus.WARN: "[WARN]",
        CheckStatus.SKIP: "[SKIP]",
        CheckStatus.ERROR: "[ERR!]"
    }
    return icons.get(status, "[????]")


def get_status_emoji(status: CheckStatus) -> str:
    """Get emoji for check status (markdown output)."""
    emojis = {
        CheckStatus.PASS: "PASS",
        CheckStatus.FAIL: "FAIL",
        CheckStatus.WARN: "WARN",
        CheckStatus.SKIP: "SKIP",
        CheckStatus.ERROR: "ERR!"
    }
    return emojis.get(status, "?")


def format_duration(seconds: float) -> str:
    """Format duration in human-readable form."""
    if seconds < 1:
        return f"{seconds*1000:.0f}ms"
    elif seconds < 60:
        return f"{seconds:.1f}s"
    else:
        minutes = int(seconds // 60)
        secs = seconds % 60
        return f"{minutes}m {secs:.0f}s"


def format_check_result(result: CheckResult, verbose: bool = False) -> str:
    """Format a single check result for console output."""
    lines = []

    icon = get_status_icon(result.status)
    duration = format_duration(result.duration)

    lines.append(f"{icon} {result.name} ({result.check_id})")
    lines.append(f"       Command: {result.command}")
    lines.append(f"       Duration: {duration}")

    if result.status == CheckStatus.SKIP:
        lines.append(f"       Reason: {result.skip_reason}")
    elif result.exit_code is not None and result.status != CheckStatus.PASS:
        lines.append(f"       Exit Code: {result.exit_code}")

    if result.status in (CheckStatus.FAIL, CheckStatus.ERROR) and result.remediation:
        lines.append("")
        lines.append("       REMEDIATION:")
        for step in result.remediation:
            lines.append(f"       - {step}")

    if verbose and result.error:
        lines.append("")
        lines.append("       STDERR:")
        for line in result.error.strip().split('\n')[:10]:
            lines.append(f"       | {line}")

    return '\n'.join(lines)


def format_gate_result(result: GateResult, verbose: bool = False) -> str:
    """Format complete gate result for console output."""
    lines = []
    separator = "=" * 70

    lines.append(separator)
    lines.append(f"QUALITY GATE: {result.gate_id}")
    lines.append(f"Phase: {result.phase} | Trigger: {result.trigger}")
    lines.append(separator)
    lines.append("")

    for check in result.checks:
        lines.append(format_check_result(check, verbose))
        lines.append("")

    lines.append(separator)

    if result.passed:
        lines.append(f"RESULT: PASSED - All checks completed successfully")
    else:
        failed_count = sum(
            1 for c in result.checks
            if c.status in (CheckStatus.FAIL, CheckStatus.ERROR)
            and c.severity == Severity.CRITICAL
        )
        if result.blocking:
            lines.append(f"RESULT: BLOCKED - {failed_count} blocking check(s) failed")
            lines.append("")
            lines.append("Cannot proceed until all blocking gates pass.")
        else:
            lines.append(f"RESULT: WARNING - {failed_count} check(s) failed (non-blocking)")

    lines.append(f"")
    lines.append(f"Total Duration: {format_duration(result.duration)}")
    lines.append(separator)

    return '\n'.join(lines)


def format_report(results: list, config: dict) -> str:
    """
    Format all gate results as markdown report for progress.md.

    Args:
        results: List of GateResult objects
        config: Original configuration

    Returns:
        Markdown-formatted report string
    """
    lines = []
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M")

    lines.append(f"## Quality Gate Report - {timestamp}")
    lines.append("")

    # Summary
    total_gates = len(results)
    passed_gates = sum(1 for r in results if r.passed)
    blocked = any(not r.passed and r.blocking for r in results)

    lines.append("### Summary")
    lines.append(f"- **Gates Executed**: {total_gates}")
    lines.append(f"- **Gates Passed**: {passed_gates}/{total_gates}")
    lines.append(f"- **Status**: {'BLOCKED' if blocked else 'PASSED'}")
    lines.append("")

    # Individual gates
    for result in results:
        status_icon = "PASS" if result.passed else "FAIL"
        lines.append(f"### Gate: {result.name} [{status_icon}]")
        lines.append(f"- **Type**: {result.gate_type}")
        lines.append(f"- **Phase**: {result.phase}")
        lines.append(f"- **Duration**: {format_duration(result.duration)}")
        lines.append("")

        lines.append("| Check | Status | Duration |")
        lines.append("|-------|--------|----------|")

        for check in result.checks:
            status = get_status_emoji(check.status)
            duration = format_duration(check.duration)
            lines.append(f"| {check.name} | {status} | {duration} |")

        lines.append("")

        # Failed checks details
        failed = [c for c in result.checks if c.status in (CheckStatus.FAIL, CheckStatus.ERROR)]
        if failed:
            lines.append("**Failed Checks:**")
            for check in failed:
                lines.append(f"- **{check.name}**: Exit code {check.exit_code}")
                if check.remediation:
                    for step in check.remediation:
                        lines.append(f"  - {step}")
            lines.append("")

    return '\n'.join(lines)


def list_gates(config: dict) -> str:
    """Format gate listing for --list option."""
    lines = []
    lines.append("Available Quality Gates:")
    lines.append("")

    for gate in config.get('gates', []):
        gate_id = gate.get('name', gate.get('id', 'unknown'))
        name = gate.get('name', gate_id)
        gate_type = gate.get('type', 'custom')
        phase = gate.get('phase', '-')
        blocking = "blocking" if gate.get('blocking', True) else "non-blocking"
        check_count = len(gate.get('checks', []))

        lines.append(f"  {gate_id}")
        lines.append(f"    Name: {name}")
        lines.append(f"    Type: {gate_type}")
        lines.append(f"    Phase: {phase}")
        lines.append(f"    Mode: {blocking}")
        lines.append(f"    Checks: {check_count}")
        lines.append("")

    return '\n'.join(lines)


# =============================================================================
# Main Entry Point
# =============================================================================

def main() -> int:
    """
    Main entry point for the gate runner.

    Returns:
        0 on success, 1 on blocking failure, 2 on error
    """
    parser = argparse.ArgumentParser(
        description="AGENT-11 Quality Gate Runner",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python run-gates.py --config .quality-gates.json --phase implementation
  python run-gates.py --gate pre-deploy --verbose
  python run-gates.py --list
  python run-gates.py --report-only > gate-report.md
        """
    )

    parser.add_argument(
        '--config', '-c',
        default=DEFAULT_CONFIG,
        help=f'Path to gate configuration file (default: {DEFAULT_CONFIG})'
    )

    parser.add_argument(
        '--gate', '-g',
        help='Run specific gate by name (runs all gates if not specified)'
    )

    parser.add_argument(
        '--phase', '-p',
        help='Run all gates for specific phase'
    )

    parser.add_argument(
        '--list', '-l',
        action='store_true',
        help='List all available gates and exit'
    )

    parser.add_argument(
        '--verbose', '-v',
        action='store_true',
        help='Enable verbose output'
    )

    parser.add_argument(
        '--report-only',
        action='store_true',
        help='Output markdown report only (for progress.md)'
    )

    parser.add_argument(
        '--version',
        action='version',
        version=f'AGENT-11 Gate Runner v{VERSION}'
    )

    args = parser.parse_args()

    # Load configuration
    try:
        config = load_gate_config(args.config)
    except FileNotFoundError as e:
        print(f"Error: {e}", file=sys.stderr)
        print(f"Create a gate configuration file or specify with --config", file=sys.stderr)
        return 2
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON in configuration file: {e}", file=sys.stderr)
        return 2
    except ValueError as e:
        print(f"Error: Invalid configuration: {e}", file=sys.stderr)
        return 2

    # List mode
    if args.list:
        print(list_gates(config))
        return 0

    # Get defaults
    defaults = config.get('defaults', config.get('global_options', {}))

    # Filter gates
    gates = config.get('gates', [])

    if args.gate:
        gates = [g for g in gates if g.get('name') == args.gate or g.get('id') == args.gate]
        if not gates:
            print(f"Error: Gate '{args.gate}' not found in configuration", file=sys.stderr)
            return 2

    if args.phase:
        gates = [g for g in gates if g.get('phase') == args.phase]
        if not gates:
            print(f"Error: No gates found for phase '{args.phase}'", file=sys.stderr)
            return 2

    if not gates:
        print("Error: No gates to run", file=sys.stderr)
        return 2

    # Run gates
    results = []

    for gate in gates:
        if not args.report_only:
            print(f"\nRunning gate: {gate.get('name', gate.get('id'))}...\n")

        result = run_gate(gate, defaults, args.verbose)
        results.append(result)

        if not args.report_only:
            print(format_gate_result(result, args.verbose))

    # Output report
    if args.report_only or len(results) > 1:
        report = format_report(results, config)
        if args.report_only:
            print(report)
        elif args.verbose:
            print("\n" + "=" * 70)
            print("MARKDOWN REPORT (for progress.md):")
            print("=" * 70 + "\n")
            print(report)

    # Determine exit code
    blocking_failures = [
        r for r in results
        if not r.passed and r.blocking
    ]

    if blocking_failures:
        return 1

    return 0


if __name__ == '__main__':
    sys.exit(main())
