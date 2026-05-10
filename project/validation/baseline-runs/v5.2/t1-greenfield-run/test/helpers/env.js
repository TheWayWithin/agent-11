// test/helpers/env.js
// Per-test-file unique DB paths in os.tmpdir(). Must be required BEFORE
// any project module that reads DB_PATH / SESSION_DB_PATH (i.e. db.js,
// app.js helper, anything in routes/).

'use strict';

const os = require('os');
const path = require('path');
const fs = require('fs');
const crypto = require('crypto');

/**
 * Set DB_PATH and SESSION_DB_PATH to unique tmp paths for this test file.
 * Returns the paths so tests can poke at the DB directly if needed.
 *
 * Idempotent: if already set (e.g. caller seeded env), returns those.
 */
function setupTestEnv(label) {
  if (!process.env.SESSION_SECRET) {
    process.env.SESSION_SECRET =
      'test-only-secret-not-for-production-use-1234567890abcdef';
  }
  process.env.NODE_ENV = 'test';

  const id = `${label || 'test'}-${process.pid}-${crypto
    .randomBytes(4)
    .toString('hex')}`;
  const dir = path.join(os.tmpdir(), 'tinylink-tests', id);
  fs.mkdirSync(dir, { recursive: true });

  const dbPath = path.join(dir, 'tinylink.db');
  const sessionDbPath = path.join(dir, 'sessions.db');

  process.env.DB_PATH = dbPath;
  process.env.SESSION_DB_PATH = sessionDbPath;

  return { dir, dbPath, sessionDbPath };
}

/**
 * Wipe all rows from app tables. Use in beforeEach to reset between tests
 * within the same file (DB connection is reused; only data is cleared).
 *
 * Caller passes the better-sqlite3 Database instance from getDb().
 */
function resetTables(db) {
  // Order matters for FK RESTRICT — clicks → links → users.
  db.exec('DELETE FROM clicks; DELETE FROM links; DELETE FROM users;');
  // Also reset autoincrement counters so tests get predictable IDs.
  db.exec(
    "DELETE FROM sqlite_sequence WHERE name IN ('users', 'links', 'clicks');"
  );
}

/**
 * Wipe sessions for clean cookie state between tests.
 * better-sqlite3-session-store uses a `sessions` table (default name).
 */
function resetSessions(sessionDb) {
  try {
    sessionDb.exec('DELETE FROM sessions;');
  } catch (_e) {
    // Table may not exist yet on first call — ignore.
  }
}

/**
 * Tear down: close DB handles and remove the tmp dir. Call in after().
 * Failures are non-fatal — the OS will GC tmpdir eventually.
 */
function teardown({ db, sessionDb, dir }) {
  try {
    if (db && db.open) db.close();
  } catch (_e) {}
  try {
    if (sessionDb && sessionDb.open) sessionDb.close();
  } catch (_e) {}
  try {
    if (dir && fs.existsSync(dir)) {
      fs.rmSync(dir, { recursive: true, force: true });
    }
  } catch (_e) {}
}

module.exports = { setupTestEnv, resetTables, resetSessions, teardown };
