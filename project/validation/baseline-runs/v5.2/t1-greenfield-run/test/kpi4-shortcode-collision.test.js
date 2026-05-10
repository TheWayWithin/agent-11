// test/kpi4-shortcode-collision.test.js
//
// KPI 4 — short-code collision handling.
//
// Architecture.md §5 says: try insert, on UNIQUE collision, retry. Bound
// retries to 5. Reserved-words filter skips route names.
//
// Test approach: monkey-patch crypto.randomBytes to drive deterministic
// candidate generation:
//   - First N attempts produce an already-occupied code → expect retry +
//     eventual success with a different code.
//   - All 5 attempts produce occupied codes → expect SHORTCODE_EXHAUSTED.
//   - First attempt produces a reserved-word code → expect retry to skip it.
//
// The `_generateCandidate` and `_RESERVED_WORDS` are exported for test use
// per shortcode.js comments.

'use strict';

const { test, before, beforeEach, after, describe } = require('node:test');
const assert = require('node:assert/strict');
const crypto = require('crypto');

const { setupTestEnv, resetTables, teardown } = require('./helpers/env');
const ctx = setupTestEnv('kpi4');

const path = require('path');
const PROJECT_ROOT = path.join(__dirname, '..');
const { getDb } = require(path.join(PROJECT_ROOT, 'db'));
const shortcode = require(path.join(PROJECT_ROOT, 'lib', 'shortcode'));
const { generateAndInsert, _generateCandidate, _RESERVED_WORDS } = shortcode;

let db;
let userId;
const originalRandomBytes = crypto.randomBytes;

before(() => {
  db = getDb();
});

beforeEach(() => {
  resetTables(db);
  // Insert a user — links require a valid owner_id (FK constraint).
  const info = db
    .prepare(
      'INSERT INTO users (email, password_hash, created_at) VALUES (?, ?, ?)'
    )
    .run('shortcode-test@example.com', 'fake-hash', Date.now());
  userId = info.lastInsertRowid;
  // Always restore in case a prior test threw before its restore.
  crypto.randomBytes = originalRandomBytes;
});

after(() => {
  crypto.randomBytes = originalRandomBytes;
  teardown({ db, dir: ctx.dir });
});

/**
 * Convert a 6-char code into a 6-byte buffer that, when each byte goes
 * through `byte % 62`, reproduces the code's alphabet indices. The
 * shortcode generator does:
 *   ALPHABET[bytes[i] % 62] for i in 0..5
 * so we need a byte whose %62 equals the alphabet index of each char.
 *
 * The alphabet is 'A-Za-z0-9' (62 chars). Index of 'A' = 0, 'Z' = 25,
 * 'a' = 26, 'z' = 51, '0' = 52, '9' = 61.
 */
const ALPHABET =
  'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

function bytesForCode(code) {
  if (code.length !== 6) throw new Error('code must be 6 chars');
  const buf = Buffer.alloc(6);
  for (let i = 0; i < 6; i++) {
    const idx = ALPHABET.indexOf(code[i]);
    if (idx < 0) throw new Error('char not in alphabet: ' + code[i]);
    buf[i] = idx; // any byte where % 62 === idx works; idx itself is fine.
  }
  return buf;
}

/**
 * Sequence-driven mock: returns precomputed buffers in order. After the
 * sequence is exhausted, returns "ZZZZZZ" forever (so any extra attempts
 * after the planned ones still produce a deterministic result).
 */
function mockRandomBytes(sequence) {
  const queue = sequence.slice();
  return (n) => {
    if (n !== 6) {
      // Anything other than 6 — fall through to the real implementation
      // (e.g. session secret generation, if any path needs it).
      return originalRandomBytes(n);
    }
    if (queue.length === 0) {
      return Buffer.alloc(6, 25); // 'Z' index
    }
    const next = queue.shift();
    return next;
  };
}

describe('KPI 4: short-code collision retry', () => {
  test('candidate with all-zero bytes produces "AAAAAA"', () => {
    // Sanity-check our byte→code understanding.
    crypto.randomBytes = () => Buffer.alloc(6, 0);
    assert.equal(_generateCandidate(), 'AAAAAA');
  });

  test('byte 25 in every position produces "ZZZZZZ"', () => {
    crypto.randomBytes = () => Buffer.alloc(6, 25);
    assert.equal(_generateCandidate(), 'ZZZZZZ');
  });

  test('reserved-words filter is wired (lowercase set check)', () => {
    // The reserved set is lowercase; the filter compares code.toLowerCase().
    // Since codes are 6 alphanumeric chars and our reserved words are
    // 'signup', 'login', 'logout', 'my-links', 'shorten', 'links', the only
    // 6-char candidate that could match is 'signup' or 'logout' or
    // 'shorten' (and only the second when code.toLowerCase() === 'signup',
    // i.e. the random bytes happened to spell 'SIGNUP' / 'signup' / etc).
    //
    // We can't trigger this through generateAndInsert without driving a
    // collision-shaped test (covered below), but we CAN verify the set
    // contains the documented words.
    for (const word of ['signup', 'login', 'logout', 'my-links', 'shorten', 'links']) {
      assert.ok(_RESERVED_WORDS.has(word), `reserved set includes ${word}`);
    }
  });

  test('forced collision on attempt 1 retries to attempt 2 and succeeds', () => {
    // Pre-insert a link with code 'AAAAAA'. The generator's first attempt
    // (bytes all zero) will produce 'AAAAAA', INSERT will fail with
    // SQLITE_CONSTRAINT_UNIQUE, and retry should succeed with bytes for 'BBBBBB'.
    db.prepare(
      `INSERT INTO links (code, long_url, owner_id, created_at)
       VALUES ('AAAAAA', 'https://example.com/seed', ?, ?)`
    ).run(userId, Date.now());

    crypto.randomBytes = mockRandomBytes([
      Buffer.alloc(6, 0), // 'AAAAAA' → collides
      bytesForCode('BBBBBB'), // succeeds
    ]);

    const result = generateAndInsert(db, {
      longUrl: 'https://example.com/retry-test',
      ownerId: userId,
    });
    assert.equal(result.code, 'BBBBBB', 'retry produced second candidate');
    assert.ok(typeof result.id === 'number' && result.id > 0, 'inserted row id returned');

    const inserted = db
      .prepare('SELECT code, long_url FROM links WHERE id = ?')
      .get(result.id);
    assert.equal(inserted.code, 'BBBBBB');
    assert.equal(inserted.long_url, 'https://example.com/retry-test');
  });

  test('multiple consecutive collisions are handled (4 collide, 5th succeeds)', () => {
    // Pre-insert 4 codes that the generator will produce in sequence.
    const occupied = ['AAAAAA', 'BBBBBB', 'CCCCCC', 'DDDDDD'];
    for (const code of occupied) {
      db.prepare(
        `INSERT INTO links (code, long_url, owner_id, created_at)
         VALUES (?, 'https://example.com/seed', ?, ?)`
      ).run(code, userId, Date.now());
    }

    crypto.randomBytes = mockRandomBytes([
      bytesForCode('AAAAAA'),
      bytesForCode('BBBBBB'),
      bytesForCode('CCCCCC'),
      bytesForCode('DDDDDD'),
      bytesForCode('EEEEEE'), // wins on attempt 5
    ]);

    const result = generateAndInsert(db, {
      longUrl: 'https://example.com/4-collisions',
      ownerId: userId,
    });
    assert.equal(result.code, 'EEEEEE', 'fifth attempt wins');
  });

  test('all 5 attempts collide → throws SHORTCODE_EXHAUSTED', () => {
    // Pre-insert 5 codes covering all the candidates the generator will produce.
    const occupied = ['AAAAAA', 'BBBBBB', 'CCCCCC', 'DDDDDD', 'EEEEEE'];
    for (const code of occupied) {
      db.prepare(
        `INSERT INTO links (code, long_url, owner_id, created_at)
         VALUES (?, 'https://example.com/seed', ?, ?)`
      ).run(code, userId, Date.now());
    }

    crypto.randomBytes = mockRandomBytes([
      bytesForCode('AAAAAA'),
      bytesForCode('BBBBBB'),
      bytesForCode('CCCCCC'),
      bytesForCode('DDDDDD'),
      bytesForCode('EEEEEE'),
    ]);

    assert.throws(
      () =>
        generateAndInsert(db, {
          longUrl: 'https://example.com/exhausted',
          ownerId: userId,
        }),
      (err) => {
        assert.equal(err.message, 'SHORTCODE_EXHAUSTED', 'error message');
        assert.equal(err.code, 'SHORTCODE_EXHAUSTED', 'error code property');
        return true;
      },
      'expected SHORTCODE_EXHAUSTED after 5 collisions'
    );

    // No row inserted for the exhausted attempt.
    const count = db
      .prepare(
        "SELECT COUNT(*) AS n FROM links WHERE long_url = 'https://example.com/exhausted'"
      )
      .get().n;
    assert.equal(count, 0, 'no link row created on exhaustion');
  });

  test('reserved-word candidate is skipped, retry succeeds', () => {
    // Force first attempt to produce 'logout' (a reserved word; the filter
    // does code.toLowerCase() so any case works). Second attempt succeeds.
    //
    // 'logout' = lowercase letters → indices 'l'=37,'o'=40,'g'=32,'o'=40,'u'=46,'t'=45.
    crypto.randomBytes = mockRandomBytes([
      bytesForCode('logout'),
      bytesForCode('NNNNNN'),
    ]);

    const result = generateAndInsert(db, {
      longUrl: 'https://example.com/reserved',
      ownerId: userId,
    });
    assert.equal(result.code, 'NNNNNN', 'reserved candidate skipped, retry won');

    const stored = db
      .prepare('SELECT code FROM links WHERE id = ?')
      .get(result.id);
    assert.equal(stored.code, 'NNNNNN');

    // Confirm 'logout' was NOT inserted.
    const ghost = db
      .prepare("SELECT id FROM links WHERE code = 'logout'")
      .get();
    assert.equal(ghost, undefined, '"logout" never reached the DB');
  });
});
