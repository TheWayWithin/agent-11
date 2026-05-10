// lib/shortcode.js
// Generate-then-INSERT short codes per architecture.md §5.
// 6-char [A-Za-z0-9], crypto.randomBytes (NEVER Math.random),
// retry on UNIQUE collision, max 5 attempts, reserved-words filter.

'use strict';

const crypto = require('crypto');

const ALPHABET =
  'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

const RESERVED_WORDS = new Set([
  'signup',
  'login',
  'logout',
  'my-links',
  'shorten',
  'links',
]);

const MAX_ATTEMPTS = 5;

/**
 * Generate a 6-character base62 code from cryptographically random bytes.
 * We sample 6 bytes, then for each byte index into the 62-char alphabet
 * with `byte % 62`. This is very slightly biased (256 % 62 = 8 — first 8
 * chars of the alphabet are slightly over-represented) but at the scale
 * of personal use (tens to hundreds of links) it is irrelevant. Address
 * space is 62^6 ≈ 5.7e10 either way.
 */
function generateCandidate() {
  const bytes = crypto.randomBytes(6);
  let out = '';
  for (let i = 0; i < 6; i++) {
    out += ALPHABET[bytes[i] % 62];
  }
  return out;
}

/**
 * Generate a short code and INSERT a links row in a single transaction
 * style: try insert, on UNIQUE collision (or reserved-word match), retry.
 * Up to 5 attempts. Returns the new row's { id, code }.
 *
 * @param {Database} db          better-sqlite3 instance
 * @param {object}   args
 * @param {string}   args.longUrl   already-validated, normalised long URL
 * @param {number}   args.ownerId   session.userId
 * @returns {{ id: number, code: string }}
 * @throws  Error('SHORTCODE_EXHAUSTED') after 5 unsuccessful attempts
 */
function generateAndInsert(db, { longUrl, ownerId }) {
  const insert = db.prepare(
    `INSERT INTO links (code, long_url, owner_id, created_at)
     VALUES (?, ?, ?, ?)`
  );

  for (let attempt = 0; attempt < MAX_ATTEMPTS; attempt++) {
    const code = generateCandidate();

    if (RESERVED_WORDS.has(code.toLowerCase())) {
      // Vanishingly unlikely — generator is random and the reserved set is
      // tiny — but architecture.md §5 calls this out explicitly.
      continue;
    }

    try {
      const info = insert.run(code, longUrl, ownerId, Date.now());
      return { id: info.lastInsertRowid, code };
    } catch (err) {
      // SQLITE_CONSTRAINT_UNIQUE on links.code → retry.
      // Anything else → re-raise (programmer error or DB problem).
      if (
        err &&
        err.code === 'SQLITE_CONSTRAINT_UNIQUE' &&
        /links\.code/i.test(err.message || '')
      ) {
        continue;
      }
      throw err;
    }
  }

  const exhausted = new Error('SHORTCODE_EXHAUSTED');
  exhausted.code = 'SHORTCODE_EXHAUSTED';
  throw exhausted;
}

module.exports = {
  generateAndInsert,
  // Exported for unit tests / debugging only.
  _generateCandidate: generateCandidate,
  _RESERVED_WORDS: RESERVED_WORDS,
};
