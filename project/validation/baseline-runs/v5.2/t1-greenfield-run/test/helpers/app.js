// test/helpers/app.js
// Thin wrapper around server.js's `createApp` factory that supplies test-only
// defaults: a known secret, the per-file SESSION_DB_PATH the env helper sets,
// and `sessionStoreClearTimer: false` so the periodic-cleanup interval doesn't
// keep the test runner alive after assertions finish.
//
// Single source of truth for middleware/route order: server.js. Phase 5
// finding #1 (helper drift) is fixed by this; do not reintroduce duplicated
// wiring here.

'use strict';

const path = require('path');
const { createApp } = require('../../server');

const PROJECT_ROOT = path.join(__dirname, '..', '..');

/**
 * Build a fresh test app instance. Caller MUST set process.env.DB_PATH and
 * process.env.SESSION_DB_PATH to unique paths first (see test/helpers/env.js).
 *
 * @returns {{ app: import('express').Express, sessionDb: import('better-sqlite3').Database }}
 */
function createTestApp() {
  if (!process.env.SESSION_DB_PATH) {
    throw new Error('test setup error: SESSION_DB_PATH must be set');
  }
  return createApp({
    sessionSecret:
      process.env.SESSION_SECRET || 'test-only-secret-not-for-production-use-12345',
    sessionDbPath: process.env.SESSION_DB_PATH,
    nodeEnv: 'test',
    sessionStoreClearTimer: false,
  });
}

module.exports = { createTestApp, PROJECT_ROOT };
