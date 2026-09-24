import { randomUUID } from "node:crypto";
import { Router } from "express";
import { requireAuth } from "../auth/routes.js";

// Mirrors ReportCategory.swift — keep these in sync (see shared/api-contract.md).
const VALID_CATEGORIES = new Set([
  "Safety Concern",
  "Medical",
  "Fire / Smoke",
  "Suspicious Activity",
  "Hazard",
  "Crime in Progress",
  "Other",
]);

const MAX_NOTE_LENGTH = 500;

export function reportRoutes(db) {
  const router = Router();

  // Reads and writes both require a valid session (a real @colorado.edu
  // account), but writes are stored anonymously — no user id is kept
  // alongside the report. See db/README.md.
  router.use(requireAuth);

  router.get("/", (req, res) => {
    const rows = db
      .prepare("SELECT id, category, latitude, longitude, note, created_at FROM reports ORDER BY created_at DESC")
      .all();
    return res.json({ reports: rows.map(toPublicReport) });
  });

  router.post("/", (req, res) => {
    const { category, latitude, longitude, note } = req.body ?? {};

    if (typeof category !== "string" || !VALID_CATEGORIES.has(category)) {
      return res.status(400).json({ error: "Unknown report category." });
    }
    if (typeof latitude !== "number" || latitude < -90 || latitude > 90) {
      return res.status(400).json({ error: "Invalid latitude." });
    }
    if (typeof longitude !== "number" || longitude < -180 || longitude > 180) {
      return res.status(400).json({ error: "Invalid longitude." });
    }
    if (note !== undefined && (typeof note !== "string" || note.length > MAX_NOTE_LENGTH)) {
      return res.status(400).json({ error: `Note must be a string under ${MAX_NOTE_LENGTH} characters.` });
    }

    const report = {
      id: randomUUID(),
      category,
      latitude,
      longitude,
      note: note ?? "",
      createdAt: new Date().toISOString(),
    };

    db.prepare(
      "INSERT INTO reports (id, category, latitude, longitude, note, created_at) VALUES (@id, @category, @latitude, @longitude, @note, @createdAt)"
    ).run(report);

    return res.status(201).json({ report: toPublicReport(camelRow(report)) });
  });

  return router;
}

function toPublicReport(row) {
  return {
    id: row.id,
    category: row.category,
    latitude: row.latitude,
    longitude: row.longitude,
    note: row.note,
    createdAt: row.created_at ?? row.createdAt,
  };
}

function camelRow(report) {
  return { ...report, created_at: report.createdAt };
}
