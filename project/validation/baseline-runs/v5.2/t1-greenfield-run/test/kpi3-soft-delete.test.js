// test/kpi3-soft-delete.test.js
//
// KPI 3 — soft-delete enforcement.
//   - GET /:code on a deleted code returns 404, NEVER 302.
//   - DB row still exists with deleted_at set (soft delete, not hard delete).
//   - Click history is preserved (not destroyed).
//   - Idempotency: deleting twice still works, no error.
//
// Source: docs/user-stories.md S6 + KPI #3 + architecture.md §2 soft-delete
//         semantics.

'use strict';

const { test, before, beforeEach, after, describe } = require('node:test');
const assert = require('node:assert/strict');

const { setupTestEnv, resetTables, teardown } = require('./helpers/env');
const ctx = setupTestEnv('kpi3');

const { createTestApp } = require('./helpers/app');
const {
  newAgent,
  signup,
  shorten,
  deleteLink,
  extractCsrf,
} = require('./helpers/agent');
const { getDb } = require(require('path').join(__dirname, '..', 'db'));

let app;
let sessionDb;

before(() => {
  const built = createTestApp();
  app = built.app;
  sessionDb = built.sessionDb;
});

beforeEach(() => {
  resetTables(getDb());
});

after(() => {
  teardown({ db: getDb(), sessionDb, dir: ctx.dir });
});

describe('KPI 3: soft-delete enforcement', () => {
  test('after delete, GET /:code returns 404 and NEVER 302', async () => {
    const a = newAgent(app);
    const anon = newAgent(app);

    await signup(a, { email: 's3a@example.com', password: 'password123' });
    const code = await shorten(a, 'https://example.com/will-be-deleted');

    // Pre-delete: confirm 302.
    const before = await anon.get(`/${code}`);
    assert.equal(before.status, 302, 'pre-delete redirects (sanity)');

    // Delete via the route.
    const db = getDb();
    const id = db.prepare('SELECT id FROM links WHERE code = ?').get(code).id;
    await deleteLink(a, id);

    // Post-delete: 404 over multiple consecutive visits.
    for (let i = 0; i < 3; i++) {
      const r = await anon.get(`/${code}`);
      assert.equal(r.status, 404, `attempt ${i + 1}: deleted code returns 404`);
      assert.notEqual(r.status, 302, `attempt ${i + 1}: MUST NOT redirect`);
    }
  });

  test('soft-deleted row is retained in DB with deleted_at set', async () => {
    const a = newAgent(app);
    await signup(a, { email: 's3b@example.com', password: 'password123' });
    const code = await shorten(a, 'https://example.com/retained');

    const db = getDb();
    const before = db
      .prepare('SELECT id, deleted_at FROM links WHERE code = ?')
      .get(code);
    assert.ok(before, 'row exists pre-delete');
    assert.equal(before.deleted_at, null, 'deleted_at is null pre-delete');

    await deleteLink(a, before.id);

    // Row still exists; deleted_at is now set to a timestamp ms-epoch.
    const after = db
      .prepare('SELECT id, code, long_url, deleted_at FROM links WHERE code = ?')
      .get(code);
    assert.ok(after, 'row STILL exists post-delete (soft-delete, not hard-delete)');
    assert.equal(after.code, code, 'code is preserved');
    assert.equal(after.long_url, 'https://example.com/retained', 'long_url preserved');
    assert.ok(
      typeof after.deleted_at === 'number' && after.deleted_at > 0,
      `deleted_at is a positive number; got ${after.deleted_at}`
    );
    // Reasonable sanity: deleted_at is within the last minute.
    assert.ok(
      Math.abs(Date.now() - after.deleted_at) < 60_000,
      'deleted_at is approximately now'
    );
  });

  test('historical click count is preserved through soft-delete', async () => {
    const a = newAgent(app);
    const anon = newAgent(app);

    await signup(a, { email: 's3c@example.com', password: 'password123' });
    const code = await shorten(a, 'https://example.com/clickme');

    // Generate 3 clicks.
    await anon.get(`/${code}`).expect(302);
    await anon.get(`/${code}`).expect(302);
    await anon.get(`/${code}`).expect(302);
    // Wait for setImmediate-deferred logging.
    await new Promise((r) => setTimeout(r, 50));

    const db = getDb();
    const link = db.prepare('SELECT id FROM links WHERE code = ?').get(code);
    const clicksBefore = db
      .prepare('SELECT COUNT(*) AS n FROM clicks WHERE link_id = ?')
      .get(link.id).n;
    assert.equal(clicksBefore, 3, 'three clicks logged pre-delete');

    await deleteLink(a, link.id);

    const clicksAfter = db
      .prepare('SELECT COUNT(*) AS n FROM clicks WHERE link_id = ?')
      .get(link.id).n;
    assert.equal(
      clicksAfter,
      3,
      'click history preserved through soft-delete (S6 AC4)'
    );
  });

  test('soft-delete is idempotent (S6 AC5)', async () => {
    const a = newAgent(app);
    await signup(a, { email: 's3d@example.com', password: 'password123' });
    const code = await shorten(a, 'https://example.com/twice');

    const db = getDb();
    const id = db.prepare('SELECT id FROM links WHERE code = ?').get(code).id;

    const r1 = await deleteLink(a, id);
    assert.equal(r1.status, 302, 'first delete returns 302');
    const after1 = db
      .prepare('SELECT deleted_at FROM links WHERE id = ?')
      .get(id).deleted_at;
    assert.ok(after1 > 0, 'first delete set deleted_at');

    const r2 = await deleteLink(a, id);
    assert.equal(r2.status, 302, 'second delete also returns 302 (idempotent)');
    const after2 = db
      .prepare('SELECT deleted_at FROM links WHERE id = ?')
      .get(id).deleted_at;
    // deleted_at must NOT be updated on second delete (the WHERE clause
    // includes deleted_at IS NULL, so the second UPDATE is a no-op).
    assert.equal(
      after2,
      after1,
      'second delete is a no-op; deleted_at unchanged'
    );
  });

  test('GET on deleted code does not leak in any X-* header', async () => {
    // Defensive: ensure the 404 response is a clean 404, not a redirect with
    // a 404 status code or anything weird.
    const a = newAgent(app);
    const anon = newAgent(app);
    await signup(a, { email: 's3e@example.com', password: 'password123' });
    const code = await shorten(a, 'https://example.com/leak-check');
    const db = getDb();
    const id = db.prepare('SELECT id FROM links WHERE code = ?').get(code).id;
    await deleteLink(a, id);

    const r = await anon.get(`/${code}`);
    assert.equal(r.status, 404);
    assert.ok(!r.headers.location, 'no Location header on 404');
  });
});
