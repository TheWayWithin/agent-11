// lib/validate.js
// Validators for email, password, URL.
// Per architecture.md §4 (auth), §8 (security), and user-stories §S1, §S3 edge cases.

'use strict';

// RFC 5322 is not worth the regex. Pragmatic check: contains exactly one @,
// non-empty local part, non-empty host with at least one dot. We also lowercase
// + trim before storage (architecture.md §2 users.email "stored lowercase, trimmed").
const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

/**
 * Normalise (trim + lowercase) and validate an email.
 * @returns {{ ok: true, email: string } | { ok: false, error: string }}
 */
function validateEmail(input) {
  if (typeof input !== 'string') {
    return { ok: false, error: 'email is required' };
  }
  const email = input.trim().toLowerCase();
  if (email.length === 0) {
    return { ok: false, error: 'email is required' };
  }
  if (email.length > 254) {
    return { ok: false, error: 'email is too long' };
  }
  if (!EMAIL_RE.test(email)) {
    return { ok: false, error: 'enter a valid email address' };
  }
  return { ok: true, email };
}

/**
 * Validate password. Min 8 chars, no upper bound or composition rules
 * (NIST 800-63B style — length is what matters).
 * @returns {{ ok: true } | { ok: false, error: string }}
 */
function validatePassword(input) {
  if (typeof input !== 'string') {
    return { ok: false, error: 'password is required' };
  }
  if (input.length < 8) {
    return { ok: false, error: 'password must be at least 8 characters' };
  }
  // Argon2 itself can hash arbitrary length, but a sanity ceiling avoids
  // an attacker submitting a multi-megabyte "password" to chew CPU.
  if (input.length > 1024) {
    return { ok: false, error: 'password is too long' };
  }
  return { ok: true };
}

/**
 * Validate and normalise a long URL.
 * Per architecture.md §8 + user-stories S3 edge cases:
 *   - trim whitespace
 *   - max 2048 chars
 *   - parseable via `new URL(...)`
 *   - protocol must be `http:` or `https:`
 *   - hostname must be non-empty
 * @returns {{ ok: true, url: string } | { ok: false, error: string }}
 */
function validateLongUrl(input) {
  if (typeof input !== 'string') {
    return { ok: false, error: 'URL is required' };
  }
  const trimmed = input.trim();
  if (trimmed.length === 0) {
    return { ok: false, error: 'URL is required' };
  }
  if (trimmed.length > 2048) {
    return { ok: false, error: 'URL is too long (max 2048 characters)' };
  }

  let parsed;
  try {
    parsed = new URL(trimmed);
  } catch (_e) {
    return { ok: false, error: 'enter a valid URL (must include http:// or https://)' };
  }

  if (parsed.protocol !== 'http:' && parsed.protocol !== 'https:') {
    return { ok: false, error: 'only http:// and https:// URLs are allowed' };
  }
  if (!parsed.hostname || parsed.hostname.length === 0) {
    return { ok: false, error: 'URL must have a hostname' };
  }

  // Re-stringify so we store the canonical form (trims fragments inconsistencies, etc.).
  return { ok: true, url: parsed.toString() };
}

module.exports = {
  validateEmail,
  validatePassword,
  validateLongUrl,
};
