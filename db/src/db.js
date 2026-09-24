import Database from "better-sqlite3";
import { fileURLToPath } from "node:url";
import path from "node:path";

const DEFAULT_DB_PATH = path.join(
  path.dirname(fileURLToPath(import.meta.url)),
  "..",
  "cualerts.sqlite"
);

/**
 * Opens (and migrates) the SQLite database. Pass ":memory:" in tests so
 * runs don't touch the file on disk or leak state between them.
 */
export function openDatabase(dbPath = process.env.DB_PATH || DEFAULT_DB_PATH) {
  const db = new Database(dbPath);
  db.pragma("journal_mode = WAL");
  migrate(db);
  return db;
}

function migrate(db) {
  db.exec(`
    CREATE TABLE IF NOT EXISTS users (
      id TEXT PRIMARY KEY,
      email TEXT NOT NULL UNIQUE,
      password_hash TEXT NOT NULL,
      name TEXT NOT NULL,
      created_at TEXT NOT NULL
    );

    CREATE TABLE IF NOT EXISTS reports (
      id TEXT PRIMARY KEY,
      category TEXT NOT NULL,
      latitude REAL NOT NULL,
      longitude REAL NOT NULL,
      note TEXT NOT NULL DEFAULT '',
      created_at TEXT NOT NULL
    );

    CREATE INDEX IF NOT EXISTS idx_reports_created_at ON reports (created_at);
  `);
}
