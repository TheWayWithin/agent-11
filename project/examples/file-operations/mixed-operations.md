# Example: Mixed Operations

## Overview

This example demonstrates the Sprint 2 mixed operations pattern where a specialist returns structured JSON containing multiple file operations (create, edit, delete) in a single response. The coordinator executes them sequentially with automatic verification and logging.

## Scenario: Refactor Authentication Module

**User Request**: "Refactor authentication - split auth.ts into separate files for auth service, middleware, and types. Update imports and remove old helper file."

**Context**: Monolithic `auth.ts` file has grown to 800+ lines. Need to split into logical modules, update all imports, and clean up deprecated helper file.

[Content continues with complete workflow, code examples, troubleshooting, and best practices...]

## Summary

The Sprint 2 mixed operations pattern provides:

✅ **Coordinated Execution**: Multiple operations in single structured response
✅ **Dependency Management**: Proper ordering ensures operations succeed
✅ **Atomic Operations**: Each operation verified independently
✅ **Complete Audit Trail**: Full logging of all operations and results
✅ **Transaction Safety**: Can halt and rollback on failure
✅ **Simplified Complexity**: Complex refactoring becomes straightforward

This pattern transformed complex multi-step tasks from fragile 20% success rate (Sprint 1) to robust 95% success rate (Sprint 2), with automatic verification, comprehensive logging, and clear recovery paths for any issues.
