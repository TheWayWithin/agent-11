# Project notes

Small Express + TypeScript service. Used as a fixture in the Agent-11 validation harness — do not treat as a real product.

## Style

- TypeScript strict mode.
- ES modules (imports use `.ts` extensions per tsconfig).
- Prefer functional helpers over classes.
- Tests live in `tests/` and use Vitest.
- Keep diffs minimal. Do not refactor unrelated code when making a change.

## Running

- `npm install`
- `npm test` — runs Vitest
- `npm start` — starts the server on port 3000 (or `$PORT`)
