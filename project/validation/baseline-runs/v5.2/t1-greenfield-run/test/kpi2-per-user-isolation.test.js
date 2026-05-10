// test/kpi2-per-user-isolation.test.js
//
// KPI 2 — per-user isolation.
// User A creates a link. User B logs in and:
//   (a) cannot see A's link on /my-links,
//   (b) cannot delete A's link via POST /links/:id/delete (link must remain),
//   (c) the link still works (302 redirect) after B's failed delete attempt.
//
// Source: docs/user-stories.md "KPIs" #2 + S5 AC3 + S6 cross-user edge case
//         + architecture.md §8 "Cross-user access".

'use strict';

const { test, before, after, describe } = require('node:test');
const assert = require('node:assert/strict');

const { setupTestEnv, teardown } = require('./helpers/env');
const ctx = setupTestEnv('kpi2');

const { createTestApp } = require('./helpers/app');
const {
  newAgent,
  signup,
  login,
  shorten,
  deleteLink,
  listCodes,
  listLinkIds,
} = require('./helpers/agent');
const { getDb } = require(require('path').join(__dirname, '..', 'db'));

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

describe('KPI 2: per-user isolation', () => {
  test('user B cannot see, delete, or break user A\'s link', async () => {
    const a = newAgent(app);
    const b = newAgent(app);
    const anon = newAgent(app);

    // User A signs up and creates a link.
    await signup(a, { email: 'alice@example.com', password: 'password123' });
    const codeA = await shorten(a, 'https://example.com/alices-page');

    // User B signs up.
    await signup(b, { email: 'bob@example.com', password: 'password123' });

    // (a) B's /my-links must not contain A's code.
    const bMyLinks = await b.get('/my-links').expect(200);
    const bCodes = listCodes(bMyLinks.text);
    assert.equal(
      bCodes.length,
      0,
      `B should see no links; saw ${JSON.stringify(bCodes)}`
    );
    assert.ok(
      !bMyLinks.text.includes('alices-page'),
      "B's /my-links must not leak A's long URL"
    );

    // (b) B attempts to delete A's link via direct POST. The architecture
    //     locks this behaviour: cross-user delete is a no-op + redirect to
    //     /my-links (S6 AC: "404 preferable — but architecture chose
    //     idempotent redirect"). Either way the link MUST NOT be deleted.
    const db = getDb();
    const linkA = db
      .prepare('SELECT id, deleted_at FROM links WHERE code = ?')
      .get(codeA);
    assert.ok(linkA, 'A\'s link exists');
    assert.equal(linkA.deleted_at, null, 'A\'s link is not deleted (precondition)');

    const delResp = await deleteLink(b, linkA.id);
    // Per architecture/code review: route returns 302 redirect to /my-links
    // for any input (success path or no-match path). What matters is that
    // the DB row is untouched.
    assert.ok(
      delResp.status === 302 || delResp.status === 404,
      `cross-user delete should redirect or 404; got ${delResp.status}`
    );

    const linkAAfter = db
      .prepare('SELECT deleted_at FROM links WHERE code = ?')
      .get(codeA);
    assert.equal(
      linkAAfter.deleted_at,
      null,
      "B's delete attempt MUST NOT have set deleted_at on A's link"
    );

    // (c) Anonymous visit to /codeA still 302-redirects to A's long URL.
    const visit = await anon.get(`/${codeA}`);
    assert.equal(visit.status, 302, 'A\'s link still works');
    assert.equal(
      visit.headers.location,
      'https://example.com/alices-page',
      'redirect target unchanged'
    );

    // (d) A still sees their own link on /my-links.
    const aMyLinks = await a.get('/my-links').expect(200);
    const aCodes = listCodes(aMyLinks.text);
    assert.deepEqual(aCodes, [codeA], "A still sees their own link");

    // (e) B's /my-links must not include A's link's id either.
    const bMyLinks2 = await b.get('/my-links').expect(200);
    const bIds = listLinkIds(bMyLinks2.text);
    assert.ok(
      !bIds.includes(linkA.id),
      `B's page must not render a delete form for A's link id (${linkA.id})`
    );
  });

  test('user B logging in does not inherit A\'s session or links', async () => {
    // This test catches regressions where session.userId is somehow shared
    // across cookie jars (would indicate a global rather than per-session
    // state).
    const a = newAgent(app);
    const b = newAgent(app);

    // Ensure clean DB for this scenario by wiping (we share DB across tests
    // in this file).
    const db = getDb();
    db.exec('DELETE FROM clicks; DELETE FROM links; DELETE FROM users;');

    await signup(a, { email: 'a2@example.com', password: 'password123' });
    await shorten(a, 'https://example.com/a2-page');

    await signup(b, { email: 'b2@example.com', password: 'password123' });

    // B logs in (already signed in from signup, but explicit re-login should
    // not magically expose A's data either).
    // Logout B first.
    const m = await b.get('/my-links').expect(200);
    const csrf = /name="_csrf"\s+value="([^"]+)"/.exec(m.text)[1];
    await b
      .post('/logout')
      .type('form')
      .send({ _csrf: csrf })
      .expect(302);

    await login(b, { email: 'b2@example.com', password: 'password123' });
    const bPage = await b.get('/my-links').expect(200);
    assert.equal(
      listCodes(bPage.text).length,
      0,
      'B sees no links after re-login'
    );
    assert.ok(
      !bPage.text.includes('a2-page'),
      'B\'s page must not contain A\'s long URL'
    );
  });
});
