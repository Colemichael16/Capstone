import { randomUUID } from "node:crypto";
import bcrypt from "bcryptjs";
import { Router } from "express";
import jwt from "jsonwebtoken";
import { ALLOWED_EMAIL_DOMAIN, JWT_EXPIRES_IN, JWT_SECRET } from "../config.js";

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

export function authRoutes(db) {
  const router = Router();

  router.post("/register", (req, res) => {
    const { email, password, name } = req.body ?? {};

    if (typeof email !== "string" || !EMAIL_RE.test(email)) {
      return res.status(400).json({ error: "Enter a valid email address." });
    }
    if (!email.toLowerCase().endsWith(`@${ALLOWED_EMAIL_DOMAIN}`)) {
      return res.status(400).json({ error: `Registration requires a @${ALLOWED_EMAIL_DOMAIN} email.` });
    }
    if (typeof password !== "string" || password.length < 8) {
      return res.status(400).json({ error: "Password must be at least 8 characters." });
    }
    if (typeof name !== "string" || name.trim().length === 0) {
      return res.status(400).json({ error: "Name is required." });
    }

    const normalizedEmail = email.toLowerCase();
    const existing = db.prepare("SELECT id FROM users WHERE email = ?").get(normalizedEmail);
    if (existing) {
      return res.status(409).json({ error: "An account with that email already exists." });
    }

    const user = {
      id: randomUUID(),
      email: normalizedEmail,
      passwordHash: bcrypt.hashSync(password, 10),
      name: name.trim(),
      createdAt: new Date().toISOString(),
    };

    db.prepare(
      "INSERT INTO users (id, email, password_hash, name, created_at) VALUES (@id, @email, @passwordHash, @name, @createdAt)"
    ).run(user);

    return res.status(201).json({ token: issueToken(user), user: toPublicUser(user) });
  });

  router.post("/login", (req, res) => {
    const { email, password } = req.body ?? {};
    if (typeof email !== "string" || typeof password !== "string") {
      return res.status(400).json({ error: "Email and password are required." });
    }

    const row = db.prepare("SELECT * FROM users WHERE email = ?").get(email.toLowerCase());
    if (!row || !bcrypt.compareSync(password, row.password_hash)) {
      return res.status(401).json({ error: "Incorrect email or password." });
    }

    const user = { id: row.id, email: row.email, name: row.name, passwordHash: row.password_hash };
    return res.json({ token: issueToken(user), user: toPublicUser(user) });
  });

  router.get("/me", requireAuth, (req, res) => {
    const row = db.prepare("SELECT id, email, name FROM users WHERE id = ?").get(req.userId);
    if (!row) return res.status(404).json({ error: "User not found." });
    return res.json({ user: row });
  });

  return router;
}

function issueToken(user) {
  return jwt.sign({ sub: user.id }, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });
}

function toPublicUser(user) {
  return { id: user.id, email: user.email, name: user.name };
}

/** Express middleware: requires a valid `Authorization: Bearer <token>` header. */
export function requireAuth(req, res, next) {
  const header = req.headers.authorization ?? "";
  const [scheme, token] = header.split(" ");
  if (scheme !== "Bearer" || !token) {
    return res.status(401).json({ error: "Missing or malformed Authorization header." });
  }

  try {
    const payload = jwt.verify(token, JWT_SECRET);
    req.userId = payload.sub;
    return next();
  } catch {
    return res.status(401).json({ error: "Invalid or expired token." });
  }
}
