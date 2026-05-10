// test/helpers/agent.js
// Helpers for driving the app via supertest with cookie + CSRF handling.
//
// CSRF NOTE:
// csurf binds the token to a "secret" stored in the session. To submit a
// valid POST, the test must:
//   1. GET the form page first (sets the session + secret).
//   2. Extract the _csrf token from the rendered HTML.
//   3. Submit POST with that token AND the same session cookie.
//
// supertest.agent() handles cookie persistence automatically; we just need
// to extract the token from the HTML.

'use strict';

const request = require('supertest');

const CSRF_RE = /name="_csrf"\s+value="([^"]+)"/;

/**
 * Extract the CSRF token from a rendered HTML page (signup, login, my-links).
 * Throws if no token is found — that means the page didn't render a form.
 */
function extractCsrf(html) {
  const m = CSRF_RE.exec(html);
  if (!m) {
    throw new Error(
      `CSRF token not found in response. First 500 chars: ${String(html).slice(0, 500)}`
    );
  }
  return m[1];
}

/**
 * Sign up a new user. Returns the agent (cookies preserved) once the
 * /signup -> /my-links redirect has been followed.
 */
async function signup(agent, { email, password }) {
  const formPage = await agent.get('/signup').expect(200);
  const csrf = extractCsrf(formPage.text);

  const res = await agent
    .post('/signup')
    .type('form')
    .send({ _csrf: csrf, email, password });

  if (res.status !== 302) {
    throw new Error(
      `signup expected 302, got ${res.status}. Body: ${String(res.text).slice(0, 500)}`
    );
  }
  if (res.headers.location !== '/my-links') {
    throw new Error(
      `signup expected redirect to /my-links, got ${res.headers.location}`
    );
  }
  return agent;
}

/**
 * Sign in an existing user. Returns the agent on successful 302 -> /my-links.
 */
async function login(agent, { email, password }) {
  const formPage = await agent.get('/login').expect(200);
  const csrf = extractCsrf(formPage.text);

  const res = await agent
    .post('/login')
    .type('form')
    .send({ _csrf: csrf, email, password });

  if (res.status !== 302) {
    throw new Error(
      `login expected 302, got ${res.status}. Body: ${String(res.text).slice(0, 500)}`
    );
  }
  return agent;
}

/**
 * Submit /shorten and follow the redirect. Returns the new short code by
 * scraping it from the redirected /my-links page.
 *
 * If you want to assert validation errors, use `shortenRaw` instead.
 */
async function shorten(agent, longUrl) {
  const myLinks = await agent.get('/my-links').expect(200);
  const csrf = extractCsrf(myLinks.text);
  const before = listCodes(myLinks.text);

  const res = await agent
    .post('/shorten')
    .type('form')
    .send({ _csrf: csrf, long_url: longUrl });
  if (res.status !== 302 || res.headers.location !== '/my-links') {
    throw new Error(
      `shorten expected 302 -> /my-links, got ${res.status} -> ${res.headers.location}. Body: ${String(res.text).slice(0, 500)}`
    );
  }

  const after = await agent.get('/my-links').expect(200);
  const afterCodes = listCodes(after.text);
  const newCodes = afterCodes.filter((c) => !before.includes(c));
  if (newCodes.length !== 1) {
    throw new Error(
      `expected exactly one new code, got ${JSON.stringify(newCodes)} (before=${JSON.stringify(before)} after=${JSON.stringify(afterCodes)})`
    );
  }
  return newCodes[0];
}

/**
 * Like shorten() but returns the raw response (no follow-up GET) so tests
 * can assert on validation failures.
 */
async function shortenRaw(agent, longUrl) {
  const myLinks = await agent.get('/my-links').expect(200);
  const csrf = extractCsrf(myLinks.text);
  return agent
    .post('/shorten')
    .type('form')
    .send({ _csrf: csrf, long_url: longUrl });
}

/**
 * Scrape short codes from a /my-links HTML page.
 *
 * The view renders `<a href="{baseUrl}/{code}">` where baseUrl includes the
 * protocol (e.g. http://localhost:3000). We match any href ending in /{code}
 * where code is exactly 6 alphanumeric chars — this matches the architecture
 * §5 short-code format.
 */
function listCodes(html) {
  const matches = String(html).matchAll(/href="[^"]*\/([A-Za-z0-9]{6})"/g);
  const codes = new Set();
  for (const m of matches) codes.add(m[1]);
  return [...codes];
}

/**
 * Get the link IDs visible on /my-links. Used by isolation tests to confirm
 * a delete form for a specific id is/isn't rendered.
 */
function listLinkIds(html) {
  const matches = String(html).matchAll(/action="\/links\/(\d+)\/delete"/g);
  const ids = new Set();
  for (const m of matches) ids.add(parseInt(m[1], 10));
  return [...ids];
}

/**
 * Soft-delete a link by id. Returns the response.
 */
async function deleteLink(agent, id) {
  const myLinks = await agent.get('/my-links').expect(200);
  const csrf = extractCsrf(myLinks.text);
  return agent
    .post(`/links/${id}/delete`)
    .type('form')
    .send({ _csrf: csrf });
}

/**
 * Build a fresh supertest agent on the given app instance.
 */
function newAgent(app) {
  return request.agent(app);
}

module.exports = {
  newAgent,
  signup,
  login,
  shorten,
  shortenRaw,
  deleteLink,
  extractCsrf,
  listCodes,
  listLinkIds,
};
