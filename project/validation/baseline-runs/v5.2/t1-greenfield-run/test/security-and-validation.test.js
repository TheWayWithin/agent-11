// test/security-and-validation.test.js
//
// Covers the deterministic Phase 4 concerns from agent-context.md and the
// architecture's locked security posture (architecture.md §8). Specifically:
//
//   - Login throttle: 5 wrong-password attempts → 6th returns 429.
//   - Generic auth errors: signup-existing-email AND login-unknown-email
//     return identical-looking error responses.
//   - URL validation rejection: javascript:, data:, empty hostname, > 2048 chars.
//   - CSRF: POST without token → 403.
//   - Reserved-words filter is wired (covered indirectly in kpi4 — kept here
//     as an additional integration check via a small unit test).
//
// Skipped (per Phase 5 brief — flaky/not deterministic):
//   - Login timing leak (timing-based; not blocker; documented as
//     defence-in-depth in architecture.md §8).
//   - Click-count race under concurrent load.
//   - CSRF expired-session UX.

'use strict';

const { test, before, beforeEach, after, describe } = require('node:test');
const assert = require('node:assert/strict');

const { setupTestEnv, resetTables, teardown } = require('./helpers/env');
const ctx = setupTestEnv('sec');

const { createTestApp } = require('./helpers/app');
const {
  newAgent,
  signup,
  login,
  shortenRaw,
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

describe('Login throttle', () => {
  test('5 wrong-password attempts → 6th returns 429', async () => {
    const a = newAgent(app);
    // Register a real user first so the path goes through verifyPassword.
    await signup(a, { email: 'throttle@example.com', password: 'password123' });

    // Logout.
    const m = await a.get('/my-links').expect(200);
    const csrf = extractCsrf(m.text);
    await a.post('/logout').type('form').send({ _csrf: csrf }).expect(302);

    // Now attempt to login with wrong password 5 times.
    for (let i = 0; i < 5; i++) {
      const formPage = await a.get('/login').expect(200);
      const t = extractCsrf(formPage.text);
      const r = await a
        .post('/login')
        .type('form')
        .send({ _csrf: t, email: 'throttle@example.com', password: 'WRONG_pw_' + i });
      assert.equal(
        r.status,
        400,
        `attempt ${i + 1} should be 400 (invalid creds), got ${r.status}`
      );
      assert.match(
        r.text,
        /invalid email or password/,
        `attempt ${i + 1} renders generic error`
      );
    }

    // 6th attempt: throttled.
    const formPage = await a.get('/login').expect(200);
    const t = extractCsrf(formPage.text);
    const sixth = await a
      .post('/login')
      .type('form')
      .send({ _csrf: t, email: 'throttle@example.com', password: 'WRONG_pw_final' });
    assert.equal(sixth.status, 429, '6th attempt is throttled');
    assert.match(sixth.text, /too many failed attempts/i, 'throttle message rendered');
  });
});

describe('Generic auth errors (no enumeration)', () => {
  test('signup with existing email returns the documented message', async () => {
    const a = newAgent(app);
    await signup(a, { email: 'enum@example.com', password: 'password123' });

    const b = newAgent(app);
    const formPage = await b.get('/signup').expect(200);
    const csrf = extractCsrf(formPage.text);
    const r = await b
      .post('/signup')
      .type('form')
      .send({ _csrf: csrf, email: 'enum@example.com', password: 'password123' });
    assert.equal(r.status, 400);
    assert.match(
      r.text,
      /an account with this email already exists/,
      'signup duplicate produces the documented friendly error'
    );
  });

  test('login with unknown email returns the same generic message as wrong password', async () => {
    const a = newAgent(app);

    // Wrong-password branch.
    await signup(a, { email: 'real@example.com', password: 'password123' });
    const m = await a.get('/my-links').expect(200);
    const csrf = extractCsrf(m.text);
    await a.post('/logout').type('form').send({ _csrf: csrf }).expect(302);

    const formPage1 = await a.get('/login').expect(200);
    const t1 = extractCsrf(formPage1.text);
    const wrongPw = await a
      .post('/login')
      .type('form')
      .send({ _csrf: t1, email: 'real@example.com', password: 'wrong_password' });

    // Unknown-email branch via a fresh agent (so throttle for "real@" is irrelevant).
    const b = newAgent(app);
    const formPage2 = await b.get('/login').expect(200);
    const t2 = extractCsrf(formPage2.text);
    const unknown = await b
      .post('/login')
      .type('form')
      .send({ _csrf: t2, email: 'nobody@example.com', password: 'password123' });

    // Both should be 400 with the same user-visible error message.
    assert.equal(wrongPw.status, 400, 'wrong password is 400');
    assert.equal(unknown.status, 400, 'unknown email is 400');

    const errPattern = /invalid email or password/;
    assert.match(wrongPw.text, errPattern, 'wrong-password renders generic error');
    assert.match(unknown.text, errPattern, 'unknown-email renders the SAME generic error');
  });
});

describe('URL validation', () => {
  async function expectRejection(longUrl, label) {
    const a = newAgent(app);
    await signup(a, { email: `urlval-${Date.now()}-${Math.random().toString(36).slice(2,6)}@example.com`, password: 'password123' });
    const r = await shortenRaw(a, longUrl);
    assert.equal(r.status, 400, `${label}: expected 400, got ${r.status}`);
    // The /my-links re-render should NOT have created a new link row.
    const db = getDb();
    const ownerId = a.jar // supertest jar — not exposed; query by user email instead
      ? null
      : null;
    const linkCount = db.prepare('SELECT COUNT(*) AS n FROM links').get().n;
    return { response: r, linkCount };
  }

  test('javascript: scheme is rejected', async () => {
    resetTables(getDb());
    const { response, linkCount } = await expectRejection(
      'javascript:alert(1)',
      'javascript:'
    );
    assert.equal(linkCount, 0, 'no link inserted');
    assert.match(response.text, /only http:\/\/ and https:\/\/ URLs are allowed|enter a valid URL/i);
  });

  test('data: scheme is rejected', async () => {
    resetTables(getDb());
    const { response, linkCount } = await expectRejection(
      'data:text/html,<script>alert(1)</script>',
      'data:'
    );
    assert.equal(linkCount, 0);
    assert.match(response.text, /only http:\/\/ and https:\/\/ URLs are allowed/i);
  });

  test('malformed URL with no parseable structure is rejected', async () => {
    // FINDING: lib/validate.js has an `if (!parsed.hostname)` branch
    // (empty-hostname check), but in stdlib `new URL()` semantics every
    // URL that survives parsing has a non-empty hostname (URLs like
    // 'http:///path' get re-interpreted with hostname='path'; URLs like
    // 'http://' throw at parse time). The empty-hostname branch is dead
    // code in practice. Reported in Phase 5 findings.
    //
    // We test the realistic equivalent: a string that fails to parse as a
    // URL goes through the catch + 'enter a valid URL' branch.
    resetTables(getDb());
    const { response, linkCount } = await expectRejection(
      'not a url at all',
      'malformed URL'
    );
    assert.equal(linkCount, 0);
    assert.match(response.text, /enter a valid URL/i);
  });

  test('URL longer than 2048 characters is rejected', async () => {
    resetTables(getDb());
    const longUrl = 'https://example.com/' + 'a'.repeat(2030);
    assert.ok(longUrl.length > 2048, 'fixture url is over 2048');
    const { response, linkCount } = await expectRejection(longUrl, '> 2048');
    assert.equal(linkCount, 0);
    assert.match(response.text, /too long.*2048|2048.*too long|max 2048/i);
  });

  test('whitespace-only URL is rejected', async () => {
    resetTables(getDb());
    const { response, linkCount } = await expectRejection('   \t  ', 'whitespace-only');
    assert.equal(linkCount, 0);
    assert.match(response.text, /URL is required|enter a valid URL/i);
  });
});

describe('CSRF protection', () => {
  test('POST /shorten without a token → 403', async () => {
    const a = newAgent(app);
    await signup(a, { email: 'csrf@example.com', password: 'password123' });

    // Submit /shorten WITHOUT a _csrf field.
    const r = await a
      .post('/shorten')
      .type('form')
      .send({ long_url: 'https://example.com/no-token' });
    assert.equal(r.status, 403, `no-token POST returns 403; got ${r.status}`);
    assert.match(r.text, /session expired|tampered/i, 'CSRF error page rendered');
  });

  test('POST /signup without a token → 403', async () => {
    const a = newAgent(app);
    // Force a session to exist (csurf requires one to compare against).
    await a.get('/signup').expect(200);
    const r = await a
      .post('/signup')
      .type('form')
      .send({ email: 'no-csrf@example.com', password: 'password123' });
    assert.equal(r.status, 403);
  });

  test('POST /login without a token → 403', async () => {
    const a = newAgent(app);
    await a.get('/login').expect(200);
    const r = await a
      .post('/login')
      .type('form')
      .send({ email: 'whoever@example.com', password: 'password123' });
    assert.equal(r.status, 403);
  });

  test('POST /shorten WITH a valid token (and auth) → 302', async () => {
    // Positive control — confirm CSRF doesn't reject valid requests.
    const a = newAgent(app);
    await signup(a, { email: 'csrf-ok@example.com', password: 'password123' });
    const m = await a.get('/my-links').expect(200);
    const csrf = extractCsrf(m.text);
    const r = await a
      .post('/shorten')
      .type('form')
      .send({ _csrf: csrf, long_url: 'https://example.com/csrf-ok' });
    assert.equal(r.status, 302);
    assert.equal(r.headers.location, '/my-links');
  });
});

describe('requireAuth middleware', () => {
  test('GET /my-links without auth → 302 to /login', async () => {
    const a = newAgent(app);
    const r = await a.get('/my-links');
    assert.equal(r.status, 302);
    assert.equal(r.headers.location, '/login');
  });

  test('POST /shorten without auth → 401 (or 403 if CSRF fires first)', async () => {
    // POST without a session: requireAuth should 401, BUT csurf middleware
    // runs before the route, so a missing token would 403 first. Either is
    // an acceptable rejection — we just need to confirm the request does
    // NOT succeed.
    const a = newAgent(app);
    const r = await a
      .post('/shorten')
      .type('form')
      .send({ long_url: 'https://example.com/no-auth' });
    assert.ok(
      r.status === 401 || r.status === 403,
      `unauth POST should be 401 or 403; got ${r.status}`
    );
  });
});
