/**
 * Only @colorado.edu addresses may register — this is a CU Boulder campus
 * app, and gating registration to a real student email is the entire
 * anti-abuse story for now (see db/README.md "Known gaps").
 */
export const ALLOWED_EMAIL_DOMAIN = process.env.ALLOWED_EMAIL_DOMAIN || "colorado.edu";

export const JWT_SECRET = process.env.JWT_SECRET || "dev-secret-change-me";

export const JWT_EXPIRES_IN = "30d";
