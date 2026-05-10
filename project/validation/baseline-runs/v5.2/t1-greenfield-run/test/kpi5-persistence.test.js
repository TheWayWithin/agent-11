// test/kpi5-persistence.test.js
//
// KPI 5 — persistence across restart.
//
// We can't fork a real process here, but we CAN simulate the only thing
// "restart" actually does for a SQLite-backed app: drop the in-memory state
// (db.js singleton + Express app) and open a brand-new better-sqlite3
// connection to the same file. If the data is on disk, the new connection
// sees it.
//
// Coverage:
//   - users/links/clicks rows survive a fresh DB connection.
//   - Sessions table (separate file) is also persisted on disk; we open it
//     fresh and confirm the row is there.
//   - Sessions persist across "restart" via cookie+session-store: out of
//     scope for this test (would require driving a real HTTP cookie through
//     two distinct Express app instances pointing at the same session DB).
//     Flagged in test report as a real-process regression test (Phase 4
//     concern #9).

'use strict';

const { test, before, after, describe } = require('node:test');
const assert = require('node:assert/strict');
const path = require('path');
const Database = require('better-sqlite3');

const { setupTestEnv, teardown } = require('./helpers/env');
const ctx = setupTestEnv('kpi5');

const PROJECT_ROOT = path.join(__dirname, '..');
const { createTestApp } = require('./helpers/app');
const { newAgent, signup, shorten } = require('./helpers/agent');
const { getDb } = require(path.join(PROJECT_ROOT, 'db'));

let app;
let sessionDb;

before(() => {
  const built = createTestApp();
  app = built.app;
  sessionDb = built.sessionDb;
});

after(() => {
  teardown({ db: getDb(), sessionDb, dir: ctx.dir });
});

describe('KPI 5: persistence across restart', () => {
  test('user, link, and click rows survive a fresh DB connection', async () => {
    // 1. Create state through the app.
    const a = newAgent(app);
    const anon = newAgent(app);
    await signup(a, { email: 'persist@example.com', password: 'password123' });
    const code = await shorten(a, 'https://example.com/persisted');

    await anon.get(`/${code}`).expect(302);
    await anon.get(`/${code}`).expect(302);
    await new Promise((r) => setTimeout(r, 50)); // setImmediate click flush.

    // 2. Capture snapshot through the existing connection.
    const before = getDb()
      .prepare(
        `SELECT
            (SELECT COUNT(*) FROM users WHERE email = 'persist@example.com') AS u,
            (SELECT COUNT(*) FROM links WHERE code = ?) AS l,
            (SELECT COUNT(*) FROM clicks
              WHERE link_id = (SELECT id FROM links WHERE code = ?)
            ) AS c`
      )
      .get(code, code);
    assert.equal(before.u, 1);
    assert.equal(before.l, 1);
    assert.equal(before.c, 2);

    // 3. Open a SECOND, independent connection to the same file. This is
    //    what a process restart looks like to SQLite: same file, brand new
    //    handle, no cached data.
    const fresh = new Database(ctx.dbPath, { readonly: true });
    fresh.pragma('foreign_keys = ON');

    try {
      const after = fresh
        .prepare(
          `SELECT
              (SELECT email FROM users LIMIT 1) AS email,
              (SELECT code FROM links WHERE code = ?) AS code,
              (SELECT long_url FROM links WHERE code = ?) AS long_url,
              (SELECT COUNT(*) FROM clicks
                WHERE link_id = (SELECT id FROM links WHERE code = ?)
              ) AS click_count`
        )
        .get(code, code, code);

      assert.equal(after.email, 'persist@example.com', 'user persisted');
      assert.equal(after.code, code, 'link code persisted');
      assert.equal(
        after.long_url,
        'https://example.com/persisted',
        'long_url persisted'
      );
      assert.equal(after.click_count, 2, 'click count persisted');
    } finally {
      fresh.close();
    }
  });

  test('soft-deleted state survives a fresh DB connection', async () => {
    // Restart-survival of deleted_at: the soft-delete is a normal row update,
    // so this is mostly a "nothing weird is happening" test.
    const a = newAgent(app);
    const db = getDb();

    // Reset for this scenario.
    db.exec('DELETE FROM clicks; DELETE FROM links; DELETE FROM users;');

    await signup(a, { email: 'p2@example.com', password: 'password123' });
    const code = await shorten(a, 'https://example.com/persist-deleted');
    const linkId = db.prepare('SELECT id FROM links WHERE code = ?').get(code).id;

    // Direct UPDATE — soft delete.
    db.prepare('UPDATE links SET deleted_at = ? WHERE id = ?').run(
      Date.now(),
      linkId
    );

    const fresh = new Database(ctx.dbPath, { readonly: true });
    try {
      const row = fresh
        .prepare('SELECT code, deleted_at FROM links WHERE id = ?')
        .get(linkId);
      assert.equal(row.code, code, 'soft-deleted row still on disk');
      assert.ok(
        typeof row.deleted_at === 'number' && row.deleted_at > 0,
        'deleted_at persisted'
      );
    } finally {
      fresh.close();
    }
  });

  test('sessions DB has session rows on disk after signup', async () => {
    // The session store writes session records to ctx.sessionDbPath. After
    // an authenticated request, opening that file fresh should reveal at
    // least one session row.
    //
    // This is a partial validation of S2 AC5. A full restart test would
    // require us to spawn a fresh Express app, point it at the same
    // sessions.db, and replay the cookie. That's possible but involves
    // re-loading routes (which load db.js, which singletons), so we'd need
    // to clear require.cache. Out of scope for this regression suite —
    // flagged in the test report.

    const a = newAgent(app);
    const db = getDb();
    db.exec('DELETE FROM clicks; DELETE FROM links; DELETE FROM users;');

    await signup(a, { email: 'sess@example.com', password: 'password123' });

    // Open the sessions file fresh.
    const fresh = new Database(ctx.sessionDbPath, { readonly: true });
    try {
      // better-sqlite3-session-store creates a `sessions` table by default.
      const tableInfo = fresh
        .prepare(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'sessions'"
        )
        .get();
      assert.ok(tableInfo, 'sessions table exists on disk');

      const rowCount = fresh.prepare('SELECT COUNT(*) AS n FROM sessions').get().n;
      assert.ok(
        rowCount >= 1,
        `sessions table has at least one row; got ${rowCount}`
      );
    } finally {
      fresh.close();
    }
  });
});
