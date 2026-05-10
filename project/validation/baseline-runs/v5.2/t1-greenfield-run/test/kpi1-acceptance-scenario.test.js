// test/kpi1-acceptance-scenario.test.js
//
// KPI 1 — full acceptance scenario.
// signup -> login -> shorten -> visit short URL anonymously
// -> see click count = 1 on owner's /my-links -> delete -> short URL = 404.
//
// Source: docs/user-stories.md "Success metrics / KPIs" #1.

'use strict';

const { test, before, after, describe } = require('node:test');
const assert = require('node:assert/strict');

const { setupTestEnv, teardown } = require('./helpers/env');
const ctx = setupTestEnv('kpi1');

const { createTestApp } = require('./helpers/app');
const {
  newAgent,
  signup,
  login,
  shorten,
  deleteLink,
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

describe('KPI 1: full acceptance scenario', () => {
  test('signup -> shorten -> anon visit -> count=1 -> delete -> 404', async () => {
    const owner = newAgent(app);
    const anon = newAgent(app); // separate cookie jar — no session

    // 1. Signup. Lands on /my-links.
    await signup(owner, { email: 'kpi1@example.com', password: 'password123' });

    // 2. Logout and log back in (exercises the login path on a known user).
    const myLinks = await owner.get('/my-links').expect(200);
    const csrf = /name="_csrf"\s+value="([^"]+)"/.exec(myLinks.text)[1];
    await owner
      .post('/logout')
      .type('form')
      .send({ _csrf: csrf })
      .expect(302)
      .expect('Location', '/login');
    await login(owner, {
      email: 'kpi1@example.com',
      password: 'password123',
    });

    // 3. Shorten a long URL.
    const code = await shorten(owner, 'https://example.com/some/long/path');
    assert.match(code, /^[A-Za-z0-9]{6}$/, 'short code is 6 alphanumeric chars');

    // 4. Visit the short URL anonymously (no session cookie).
    const redirect = await anon.get(`/${code}`);
    assert.equal(redirect.status, 302, 'anon visit returns 302');
    assert.equal(
      redirect.headers.location,
      'https://example.com/some/long/path',
      'redirect target is the original long URL'
    );

    // 5. Click logging is fire-and-forget via setImmediate. Wait briefly
    //    so the click row is committed before we count it.
    await new Promise((r) => setImmediate(r));
    await new Promise((r) => setTimeout(r, 50));

    // 6. Owner's /my-links shows click count = 1.
    const afterClick = await owner.get('/my-links').expect(200);
    // The page renders click_count in a <td class="num"> column. Confirm
    // the number 1 appears in the same row as the new code.
    // Most robust: pull from the DB directly.
    const db = getDb();
    const row = db
      .prepare(
        'SELECT id, (SELECT COUNT(*) FROM clicks c WHERE c.link_id = links.id) AS n FROM links WHERE code = ?'
      )
      .get(code);
    assert.ok(row, 'link row exists for code');
    assert.equal(row.n, 1, 'exactly one click logged');

    // Also confirm the rendered page contains the count.
    assert.match(
      afterClick.text,
      /<td class="num">1<\/td>/,
      'rendered page shows click count of 1'
    );

    // 7. Delete the link.
    const linkId = row.id;
    const delRes = await deleteLink(owner, linkId);
    assert.equal(delRes.status, 302);
    assert.equal(delRes.headers.location, '/my-links');

    // 8. Visiting the short URL now returns 404 (not 302).
    const after404 = await anon.get(`/${code}`);
    assert.equal(after404.status, 404, 'deleted code returns 404');
    assert.notEqual(
      after404.status,
      302,
      'deleted code MUST NOT redirect (S6 AC2)'
    );

    // 9. Link no longer appears on /my-links.
    const finalPage = await owner.get('/my-links').expect(200);
    assert.doesNotMatch(
      finalPage.text,
      new RegExp(`/${code}\\b`),
      'deleted code is gone from the listing'
    );
  });
});
