import cors from "cors";
import express from "express";
import { authRoutes } from "./auth/routes.js";
import { reportRoutes } from "./reports/routes.js";

/** Builds the Express app against a given (already-migrated) database. */
export function createApp(db) {
  const app = express();
  app.use(cors());
  app.use(express.json());

  app.get("/health", (req, res) => res.json({ ok: true }));

  app.use("/api/auth", authRoutes(db));
  app.use("/api/reports", reportRoutes(db));

  app.use((req, res) => res.status(404).json({ error: "Not found." }));

  // Express error handler — kept last, four args are required for Express
  // to treat this as the error handler rather than ordinary middleware.
  app.use((err, req, res, next) => {
    console.error(err);
    res.status(500).json({ error: "Internal server error." });
  });

  return app;
}
