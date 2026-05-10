// lib/auth.js
// Password hashing (argon2id), in-memory login throttle, requireAuth middleware.
// Per architecture.md §4.

'use strict';

const argon2 = require('argon2');

// argon2id with library defaults — OWASP-recommended.
const HASH_OPTIONS = { type: argon2.argon2id };

async function hashPassword(plaintext) {
  return argon2.hash(plaintext, HASH_OPTIONS);
}

/**
 * Verify a password against a stored hash. Returns boolean.
 * Wrapped to swallow argon2's "invalid hash" errors and treat them as
 * verification failures (defensive — should not happen with our own hashes,
 * but never let an exception become a 500 on the login path).
 */
async function verifyPassword(hash, plaintext) {
  try {
    return await argon2.verify(hash, plaintext);
  } catch (_e) {
    return false;
  }
}

// ---------------------------------------------------------------------------
// Login throttle (in-memory, per architecture.md §4)
//
// 5 consecutive failures per email within 15 minutes → 429.
// Successful login or window expiry resets the counter.
//
// Limitation: does not survive process restart and does not work across
// multiple processes. Acceptable for single-process MVP per architecture.md.
// ---------------------------------------------------------------------------

const THROTTLE_MAX_FAILURES = 5;
const THROTTLE_WINDOW_MS = 15 * 60 * 1000;

// Map<emailLower, { count: number, firstFailureAt: number }>
const failureMap = new Map();

function isThrottled(email) {
  const entry = failureMap.get(email);
  if (!entry) return false;

  // Window expired → drop and allow.
  if (Date.now() - entry.firstFailureAt > THROTTLE_WINDOW_MS) {
    failureMap.delete(email);
    return false;
  }
  return entry.count >= THROTTLE_MAX_FAILURES;
}

function recordFailure(email) {
  const entry = failureMap.get(email);
  const now = Date.now();
  if (!entry || now - entry.firstFailureAt > THROTTLE_WINDOW_MS) {
    failureMap.set(email, { count: 1, firstFailureAt: now });
  } else {
    entry.count += 1;
  }
}

function recordSuccess(email) {
  failureMap.delete(email);
}

// ---------------------------------------------------------------------------
// requireAuth middleware
// ---------------------------------------------------------------------------

/**
 * Require an authenticated session. For unauthenticated requests:
 *   - GET → 302 redirect to /login
 *   - POST/other → 401
 * (S5 edge case "redirects to /login OR returns 401" — we apply both
 * appropriately based on method.)
 */
function requireAuth(req, res, next) {
  if (req.session && req.session.userId) {
    return next();
  }
  if (req.method === 'GET') {
    return res.redirect('/login');
  }
  return res.status(401).send('Unauthorized');
}

module.exports = {
  hashPassword,
  verifyPassword,
  isThrottled,
  recordFailure,
  recordSuccess,
  requireAuth,
};
