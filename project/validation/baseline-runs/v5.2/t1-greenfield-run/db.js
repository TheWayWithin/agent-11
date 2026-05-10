// db.js
// better-sqlite3 connection + idempotent schema migration.
// Per architecture.md §2: users / links / clicks tables, all timestamps as INTEGER ms epochs.

'use strict';

const path = require('path');
const fs = require('fs');
const Database = require('better-sqlite3');

let db = null;

/**
 * Open (or open-and-create) the SQLite database at DB_PATH and run the
 * idempotent schema migration. Subsequent calls return the same instance.
 */
function getDb() {
  if (db) return db;

  const dbPath = process.env.DB_PATH || './data/tinylink.db';

  // Ensure the directory exists (e.g. ./data on first local-dev run).
  const dir = path.dirname(dbPath);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }

  db = new Database(dbPath);

  // Pragmas: WAL gives better concurrency for the redirect path; foreign_keys
  // must be enabled per-connection (off by default in SQLite).
  db.pragma('journal_mode = WAL');
  db.pragma('foreign_keys = ON');

  migrate(db);
  return db;
}

/**
 * Idempotent schema migration. Safe to run on every startup.
 * Uses CREATE TABLE/INDEX IF NOT EXISTS — no schema_version table needed
 * for MVP scale.
 */
function migrate(database) {
  database.exec(`
    CREATE TABLE IF NOT EXISTS users (
      id            INTEGER PRIMARY KEY AUTOINCREMENT,
      email         TEXT    NOT NULL UNIQUE,
      password_hash TEXT    NOT NULL,
      created_at    INTEGER NOT NULL
    );

    CREATE TABLE IF NOT EXISTS links (
      id          INTEGER PRIMARY KEY AUTOINCREMENT,
      code        TEXT    NOT NULL UNIQUE,
      long_url    TEXT    NOT NULL,
      owner_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
      created_at  INTEGER NOT NULL,
      deleted_at  INTEGER
    );

    CREATE INDEX IF NOT EXISTS idx_links_owner_active
      ON links(owner_id, deleted_at, created_at DESC);

    CREATE TABLE IF NOT EXISTS clicks (
      id         INTEGER PRIMARY KEY AUTOINCREMENT,
      link_id    INTEGER NOT NULL REFERENCES links(id) ON DELETE RESTRICT,
      clicked_at INTEGER NOT NULL
    );

    CREATE INDEX IF NOT EXISTS idx_clicks_link ON clicks(link_id);
  `);
}

module.exports = { getDb };
