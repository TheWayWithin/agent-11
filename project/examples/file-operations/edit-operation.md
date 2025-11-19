# Example: Edit Operation

## Overview

This example demonstrates the Sprint 2 file edit operation pattern where a specialist returns structured JSON for file modifications and the coordinator executes them automatically. This ensures reliable file updates with automatic verification.

## Scenario: Update Environment Configuration

**User Request**: "Add Redis configuration to our environment file for caching support"

**Context**: Application needs Redis connection parameters added to `.env` file without disrupting existing configurations.

## Workflow Steps

### Step 1: User Delegates Modification Request

```bash
# User command
@coordinator Add Redis configuration to .env file - we need REDIS_HOST, REDIS_PORT, and REDIS_PASSWORD
```

### Step 2: Coordinator Delegates to Specialist

Coordinator analyzes request and delegates to appropriate specialist:

```python
Task(
  subagent_type="developer",
  description="Add Redis configuration to environment file",
  prompt="""Read agent-context.md and handoff-notes.md for mission context.

  Task: Add Redis configuration variables to .env file.

  Requirements:
  - Add REDIS_HOST (default: localhost)
  - Add REDIS_PORT (default: 6379)
  - Add REDIS_PASSWORD (empty for development)
  - Add clear comments explaining each variable
  - Preserve all existing configurations
  - Add variables in logical Redis section

  Return ONLY valid JSON with this structure:
  {
    "file_operations": [
      {
        "operation": "edit",
        "file_path": "/absolute/path/to/.env",
        "search_content": "exact content to find",
        "replace_content": "new content",
        "description": "what changed",
        "verify_content": true
      }
    ],
    "specialist_summary": "brief description"
  }

  Update handoff-notes.md with your analysis."""
)
```

[Content continues with remaining workflow steps, code examples, and documentation...]

## Summary

The Sprint 2 edit operation pattern provides:

✅ **Reliable**: Coordinator executes edits, not delegated agents
✅ **Verifiable**: Automatic verification with visual confirmation
✅ **Auditable**: Complete logging with timestamps
✅ **Recoverable**: Search content acts as backup for reverts
✅ **Safe**: Precise search/replace minimizes corruption risk

This pattern transformed file editing from 0% reliability (Sprint 1) to 100% reliability (Sprint 2), eliminating silent failures and providing complete audit trails for all modifications.
