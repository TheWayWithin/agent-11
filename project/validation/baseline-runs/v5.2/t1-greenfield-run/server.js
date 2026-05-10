// server.js
// Tinylink entry point. Exports a `createApp(options)` factory; binds a port
// only when invoked directly (i.e. via `npm start`), so tests can require this
// module without it grabbing a port. See `test/helpers/app.js`.
//
// Route order is load-bearing — see "ROUTE ORDER" comment below.

'use strict';

require('dotenv').config();

const path = require('path');
const fs = require('fs');
const express = require('express');
const cookieParser = require('cookie-parser');
const session = require('express-session');
const csrf = require('csurf');
const SqliteStoreFactory = require('better-sqlite3-session-store');
const Database = require('better-sqlite3');

const { getDb } = require('./db');
const authRoutes = require('./routes/auth');
const linkRoutes = require('./routes/links');
const redirectRoutes = require('./routes/redirect');

/**
 * Build a fully wired Express app. Does not call `listen()`.
 *
 * Production callers omit `options`; everything is read from env. Tests pass
 * an object to override the defaults (test-only secret, alt session-DB path,
 * disable the periodic session-cleanup timer that would keep the test runner
 * alive after assertions finish).
 *
 * @param {Object} [options]
 * @param {string} [options.sessionSecret=process.env.SESSION_SECRET]
 * @param {string} [options.sessionDbPath=process.env.SESSION_DB_PATH || './data/sessions.db']
 * @param {string} [options.nodeEnv=process.env.NODE_ENV || 'development']
 * @param {boolean} [options.sessionStoreClearTimer=true]  pass false in tests
 * @returns {{ app: import('express').Express, sessionDb: Database.Database }}
 */
function createApp(options = {}) {
  const {
    sessionSecret = process.env.SESSION_SECRET,
    sessionDbPath = process.env.SESSION_DB_PATH || './data/sessions.db',
    nodeEnv = process.env.NODE_ENV || 'development',
    sessionStoreClearTimer = true,
  } = options;

  if (!sessionSecret) {
    throw new Error(
      'SESSION_SECRET is not set. Copy .env.example to .env and set a real secret.'
    );
  }

  const app = express();

  // Required for `secure` cookies behind Railway's TLS terminator
  // (architecture.md §8 — Railway sets X-Forwarded-Proto: https).
  app.set('trust proxy', 1);

  // Initialise main DB (this also runs the idempotent migration).
  getDb();

  // Initialise sessions DB (separate file per architecture.md §7).
  const sessionDir = path.dirname(sessionDbPath);
  if (!fs.existsSync(sessionDir)) {
    fs.mkdirSync(sessionDir, { recursive: true });
  }
  const sessionDb = new Database(sessionDbPath);
  const SqliteStore = SqliteStoreFactory(session);

  // View engine.
  app.set('view engine', 'ejs');
  app.set('views', path.join(__dirname, 'views'));

  // ---------- Middleware (order matters) ---------------------------------------

  // Static assets: served before session/CSRF so they don't get a session
  // cookie or a CSRF token they don't need.
  app.use(express.static(path.join(__dirname, 'public')));

  // Form bodies only — no JSON API in MVP.
  app.use(express.urlencoded({ extended: false }));

  // Cookie parser is required by csurf (it reads the signed cookie).
  app.use(cookieParser(sessionSecret));

  // Sessions.
  app.use(
    session({
      name: 'tinylink_sid',
      secret: sessionSecret,
      resave: false,
      saveUninitialized: false,
      rolling: true, // sliding 30-day expiry
      store: new SqliteStore({
        client: sessionDb,
        expired: sessionStoreClearTimer
          ? { clear: true, intervalMs: 15 * 60 * 1000 }
          : { clear: false },
      }),
      cookie: {
        httpOnly: true,
        secure: nodeEnv === 'production',
        sameSite: 'lax',
        signed: true,
        maxAge: 30 * 24 * 60 * 60 * 1000, // 30 days
      },
    })
  );

  // CSRF protection. Must come AFTER session and cookieParser.
  // Mounted globally so every page render has access to req.csrfToken();
  // the redirect route (/:code) is GET-only and unaffected.
  app.use(csrf());

  // ---------- Routes -----------------------------------------------------------
  //
  // ROUTE ORDER (architecture.md §3 "Route ordering note"):
  //   1. Root /
  //   2. Named /signup, /login, /logout, /my-links, /shorten, /links/:id/...
  //   3. /:code  (LAST — broadest pattern, must not shadow named routes)
  //
  // If you reorder these, /login becomes a short-code lookup. Do not.

  app.get('/', (req, res) => {
    if (req.session && req.session.userId) {
      return res.redirect('/my-links');
    }
    res.redirect('/login');
  });

  app.use(authRoutes);
  app.use(linkRoutes);
  app.use(redirectRoutes); // /:code — LAST

  // ---------- Error handlers ---------------------------------------------------

  // CSRF errors render a friendly page rather than a stack trace.
  app.use((err, req, res, next) => {
    if (err && err.code === 'EBADCSRFTOKEN') {
      return res.status(403).render('error', {
        title: 'Session expired',
        message:
          'your session expired or the form was tampered with. please reload the page and try again.',
      });
    }
    return next(err);
  });

  // 404 handler (anything that fell through). /:code already returns its own
  // 404 page; this catches genuinely unknown paths like POST /weird.
  app.use((req, res) => {
    res.status(404).render('error', {
      title: 'Not found',
      message: 'page not found',
    });
  });

  // Generic 500 handler.
  // eslint-disable-next-line no-unused-vars
  app.use((err, req, res, _next) => {
    // eslint-disable-next-line no-console
    console.error('server_error', err);
    res.status(500).render('error', {
      title: 'Server error',
      message: 'something went wrong. please try again.',
    });
  });

  return { app, sessionDb };
}

module.exports = { createApp };

// ---------- Start (only when run directly via `npm start`) -------------------

if (require.main === module) {
  const PORT = parseInt(process.env.PORT, 10) || 3000;
  const NODE_ENV = process.env.NODE_ENV || 'development';

  let app;
  try {
    ({ app } = createApp());
  } catch (err) {
    // eslint-disable-next-line no-console
    console.error('FATAL:', err.message);
    process.exit(1);
  }

  app.listen(PORT, () => {
    // eslint-disable-next-line no-console
    console.log(`Tinylink listening on http://localhost:${PORT} (${NODE_ENV})`);
  });
}
