// routes/redirect.js
// GET /:code — public short-URL redirect. Registered LAST in server.js.
// Per architecture.md §6 and user-stories S4.

'use strict';

const express = require('express');
const { getDb } = require('../db');

const router = express.Router();

// Reject patterns that obviously aren't short codes (e.g. /favicon.ico,
// paths with dots or slashes). The route param itself can't contain a
// slash, but we screen out anything that's clearly a static-asset request.
const CODE_RE = /^[A-Za-z0-9_-]{1,64}$/;

router.get('/:code', (req, res, next) => {
  try {
    const code = req.params.code;

    if (!CODE_RE.test(code)) {
      return res.status(404).render('error', {
        title: 'Not found',
        message: 'short link not found',
      });
    }

    const db = getDb();

    const row = db
      .prepare(
        `SELECT id, long_url
         FROM links
         WHERE code = ? AND deleted_at IS NULL`
      )
      .get(code);

    if (!row) {
      return res.status(404).render('error', {
        title: 'Not found',
        message: 'short link not found',
      });
    }

    // Send the redirect FIRST. Click logging happens after, fire-and-forget,
    // per architecture.md §6 — must not block the redirect path, must not
    // surface logging errors to the user.
    res.redirect(302, row.long_url);

    setImmediate(() => {
      try {
        db.prepare(
          'INSERT INTO clicks (link_id, clicked_at) VALUES (?, ?)'
        ).run(row.id, Date.now());
      } catch (err) {
        // Log only — never throw, the user already got their redirect.
        // eslint-disable-next-line no-console
        console.warn('click_log_failed', { code, error: err && err.message });
      }
    });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
