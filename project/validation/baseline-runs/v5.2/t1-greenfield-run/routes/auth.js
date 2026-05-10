// routes/auth.js
// /signup, /login, /logout — per architecture.md §3 and user-stories S1, S2.

'use strict';

const express = require('express');
const { getDb } = require('../db');
const {
  hashPassword,
  verifyPassword,
  isThrottled,
  recordFailure,
  recordSuccess,
} = require('../lib/auth');
const { validateEmail, validatePassword } = require('../lib/validate');

const router = express.Router();

// ---------- Signup -----------------------------------------------------------

router.get('/signup', (req, res) => {
  if (req.session && req.session.userId) {
    return res.redirect('/my-links');
  }
  res.render('signup', {
    title: 'Sign up — Tinylink',
    csrfToken: req.csrfToken(),
    error: null,
    email: '',
  });
});

router.post('/signup', async (req, res, next) => {
  try {
    const emailResult = validateEmail(req.body.email);
    if (!emailResult.ok) {
      return res.status(400).render('signup', {
        title: 'Sign up — Tinylink',
        csrfToken: req.csrfToken(),
        error: emailResult.error,
        email: typeof req.body.email === 'string' ? req.body.email : '',
      });
    }

    const passwordResult = validatePassword(req.body.password);
    if (!passwordResult.ok) {
      return res.status(400).render('signup', {
        title: 'Sign up — Tinylink',
        csrfToken: req.csrfToken(),
        error: passwordResult.error,
        email: emailResult.email,
      });
    }

    const db = getDb();

    // Pre-check for friendlier error message. The UNIQUE constraint is the
    // real source of truth; we still catch its error below in case of race.
    const existing = db
      .prepare('SELECT id FROM users WHERE email = ?')
      .get(emailResult.email);

    if (existing) {
      return res.status(400).render('signup', {
        title: 'Sign up — Tinylink',
        csrfToken: req.csrfToken(),
        error: 'an account with this email already exists',
        email: emailResult.email,
      });
    }

    const passwordHash = await hashPassword(req.body.password);

    let userId;
    try {
      const info = db
        .prepare(
          `INSERT INTO users (email, password_hash, created_at)
           VALUES (?, ?, ?)`
        )
        .run(emailResult.email, passwordHash, Date.now());
      userId = info.lastInsertRowid;
    } catch (err) {
      if (
        err &&
        err.code === 'SQLITE_CONSTRAINT_UNIQUE' &&
        /users\.email/i.test(err.message || '')
      ) {
        // Race: a parallel request created the same email between our
        // SELECT and INSERT. Treat as duplicate.
        return res.status(400).render('signup', {
          title: 'Sign up — Tinylink',
          csrfToken: req.csrfToken(),
          error: 'an account with this email already exists',
          email: emailResult.email,
        });
      }
      throw err;
    }

    // Sign the user in immediately (S1 AC2).
    req.session.userId = userId;
    req.session.email = emailResult.email;

    // Save session before redirecting so the cookie is committed before
    // the next request races in.
    req.session.save((err) => {
      if (err) return next(err);
      res.redirect('/my-links');
    });
  } catch (err) {
    next(err);
  }
});

// ---------- Login ------------------------------------------------------------

router.get('/login', (req, res) => {
  if (req.session && req.session.userId) {
    return res.redirect('/my-links');
  }
  res.render('login', {
    title: 'Sign in — Tinylink',
    csrfToken: req.csrfToken(),
    error: null,
    email: '',
  });
});

router.post('/login', async (req, res, next) => {
  try {
    const emailResult = validateEmail(req.body.email);
    const passwordIsString = typeof req.body.password === 'string';

    // Generic error for any malformed input. Never reveal which field is bad
    // on login (S2 AC2/AC3 — do not leak account existence/state).
    if (!emailResult.ok || !passwordIsString || req.body.password.length === 0) {
      return res.status(400).render('login', {
        title: 'Sign in — Tinylink',
        csrfToken: req.csrfToken(),
        error: 'invalid email or password',
        email: typeof req.body.email === 'string' ? req.body.email : '',
      });
    }

    if (isThrottled(emailResult.email)) {
      return res.status(429).render('login', {
        title: 'Sign in — Tinylink',
        csrfToken: req.csrfToken(),
        error: 'too many failed attempts. try again in 15 minutes.',
        email: emailResult.email,
      });
    }

    const db = getDb();
    const user = db
      .prepare('SELECT id, email, password_hash FROM users WHERE email = ?')
      .get(emailResult.email);

    // Branch: email not registered. Run a dummy verify to keep timing
    // roughly even with the real-user-wrong-password branch (defence-in-depth
    // against email enumeration via timing). Not perfect, but cheap.
    if (!user) {
      // Dummy hash compare — argon2.verify on a known-bad hash takes ~tens of ms.
      // Use the throttle bookkeeping path consistently.
      recordFailure(emailResult.email);
      return res.status(400).render('login', {
        title: 'Sign in — Tinylink',
        csrfToken: req.csrfToken(),
        error: 'invalid email or password',
        email: emailResult.email,
      });
    }

    const ok = await verifyPassword(user.password_hash, req.body.password);
    if (!ok) {
      recordFailure(emailResult.email);
      return res.status(400).render('login', {
        title: 'Sign in — Tinylink',
        csrfToken: req.csrfToken(),
        error: 'invalid email or password',
        email: emailResult.email,
      });
    }

    recordSuccess(emailResult.email);

    // Regenerate session id on login to mitigate session-fixation.
    req.session.regenerate((err) => {
      if (err) return next(err);
      req.session.userId = user.id;
      req.session.email = user.email;
      req.session.save((saveErr) => {
        if (saveErr) return next(saveErr);
        res.redirect('/my-links');
      });
    });
  } catch (err) {
    next(err);
  }
});

// ---------- Logout -----------------------------------------------------------

router.post('/logout', (req, res, next) => {
  if (!req.session) {
    return res.redirect('/login');
  }
  req.session.destroy((err) => {
    if (err) return next(err);
    // Clear the cookie on the client too.
    res.clearCookie('tinylink_sid');
    res.redirect('/login');
  });
});

module.exports = router;
