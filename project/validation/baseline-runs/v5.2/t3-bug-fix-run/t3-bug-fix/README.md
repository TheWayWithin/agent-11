# t3-bug-fix fixture

Small Express + TypeScript service with a paginated `/items` endpoint and a Vitest test suite.

The pagination helper (`src/utils/paginate.ts`) contains a seeded off-by-one bug. `npm test` produces failing tests.

Fixture for Agent-11 validation harness — Task 3 (bug fix, single file).

See `CLAUDE.md` for style notes. See `project/validation/harness-spec.md` in the parent agent-11 repo for full task definition.
