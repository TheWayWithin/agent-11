// routes/links.js
// /my-links, /shorten, /links/:id/delete — per architecture.md §3
// and user-stories S3, S5, S6.
//
// Per-user isolation: every query filters by owner_id = req.session.userId
// AND deleted_at IS NULL. Route params are NEVER trusted for ownership.

'use strict';

const express = require('express');
const { getDb } = require('../db');
const { requireAuth } = require('../lib/auth');
const { validateLongUrl } = require('../lib/validate');
const { generateAndInsert } = require('../lib/shortcode');

const router = express.Router();

// ---------- /my-links --------------------------------------------------------

router.get('/my-links', requireAuth, (req, res, next) => {
  try {
    const db = getDb();

    // Most-recent-first per S5 edge case "sort order: most recent first".
    // No pagination per architecture.md §9 ("Pagination on /my-links" out of scope).
    const links = db
      .prepare(
        `SELECT
            l.id,
            l.code,
            l.long_url,
            l.created_at,
            (SELECT COUNT(*) FROM clicks c WHERE c.link_id = l.id) AS click_count
         FROM links l
         WHERE l.owner_id = ? AND l.deleted_at IS NULL
         ORDER BY l.created_at DESC`
      )
      .all(req.session.userId);

    res.render('my-links', {
      title: 'My links — Tinylink',
      csrfToken: req.csrfToken(),
      email: req.session.email,
      baseUrl: process.env.BASE_URL || `http://localhost:${process.env.PORT || 3000}`,
      links,
      error: null,
      longUrlInput: '',
    });
  } catch (err) {
    next(err);
  }
});

// ---------- /shorten ---------------------------------------------------------

router.post('/shorten', requireAuth, (req, res, next) => {
  try {
    const result = validateLongUrl(req.body.long_url);

    if (!result.ok) {
      // Re-render /my-links with the error and the user's existing links.
      const db = getDb();
      const links = db
        .prepare(
          `SELECT
              l.id,
              l.code,
              l.long_url,
              l.created_at,
              (SELECT COUNT(*) FROM clicks c WHERE c.link_id = l.id) AS click_count
           FROM links l
           WHERE l.owner_id = ? AND l.deleted_at IS NULL
           ORDER BY l.created_at DESC`
        )
        .all(req.session.userId);

      return res.status(400).render('my-links', {
        title: 'My links — Tinylink',
        csrfToken: req.csrfToken(),
        email: req.session.email,
        baseUrl: process.env.BASE_URL || `http://localhost:${process.env.PORT || 3000}`,
        links,
        error: result.error,
        longUrlInput: typeof req.body.long_url === 'string' ? req.body.long_url : '',
      });
    }

    const db = getDb();

    try {
      generateAndInsert(db, {
        longUrl: result.url,
        ownerId: req.session.userId,
      });
    } catch (err) {
      if (err && err.code === 'SHORTCODE_EXHAUSTED') {
        return res
          .status(500)
          .send('could not generate a unique short code after 5 attempts');
      }
      throw err;
    }

    res.redirect('/my-links');
  } catch (err) {
    next(err);
  }
});

// ---------- /links/:id/delete (soft-delete, idempotent) ----------------------

router.post('/links/:id/delete', requireAuth, (req, res, next) => {
  try {
    const id = parseInt(req.params.id, 10);
    if (!Number.isInteger(id) || id <= 0) {
      // Bad id format — treat as not-found rather than 400 to avoid leaking
      // anything about valid id ranges.
      return res.redirect('/my-links');
    }

    const db = getDb();

    // Soft-delete: set deleted_at if not already set, scoped to this user.
    // Idempotent — running twice is a no-op (already-deleted rows are
    // excluded by the deleted_at IS NULL filter).
    //
    // Cross-user attempt: the WHERE owner_id = ? clause means another user's
    // link will simply not match. We always redirect to /my-links per
    // S6 acceptance criteria + architecture.md "soft-delete is idempotent".
    db.prepare(
      `UPDATE links
       SET deleted_at = ?
       WHERE id = ? AND owner_id = ? AND deleted_at IS NULL`
    ).run(Date.now(), id, req.session.userId);

    res.redirect('/my-links');
  } catch (err) {
    next(err);
  }
});

module.exports = router;
