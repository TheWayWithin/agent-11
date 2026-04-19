# t4-refactor fixture

Small Express + TypeScript service with three authenticated routes: `/users`, `/orders`, `/reports`. Each route currently re-implements the same bearer-token auth check inline.

Fixture for Agent-11 validation harness — Task 4 (refactor: extract duplicated auth into a single middleware without breaking the tests).

See `CLAUDE.md` for style notes. See `project/validation/harness-spec.md` in the parent agent-11 repo for full task definition.
