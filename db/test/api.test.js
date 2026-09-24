import assert from "node:assert/strict";
import { after, before, test } from "node:test";
import { createApp } from "../src/app.js";
import { openDatabase } from "../src/db.js";

let server;
let baseUrl;

before(() => {
  const db = openDatabase(":memory:");
  const app = createApp(db);
  server = app.listen(0);
  const { port } = server.address();
  baseUrl = `http://localhost:${port}`;
});

after(() => {
  server.close();
});

function api(path, options = {}) {
  return fetch(`${baseUrl}${path}`, {
    ...options,
    headers: { "Content-Type": "application/json", ...options.headers },
  });
}

async function registerStudent(email = "student@colorado.edu") {
  const res = await api("/api/auth/register", {
    method: "POST",
    body: JSON.stringify({ email, password: "password123", name: "Student" }),
  });
  const body = await res.json();
  return { res, body };
}

test("health check responds ok", async () => {
  const res = await api("/health");
  assert.equal(res.status, 200);
  assert.deepEqual(await res.json(), { ok: true });
});

test("registration rejects a non-CU email domain", async () => {
  const res = await api("/api/auth/register", {
    method: "POST",
    body: JSON.stringify({ email: "student@gmail.com", password: "password123", name: "Student" }),
  });
  assert.equal(res.status, 400);
});

test("registration rejects a short password", async () => {
  const res = await api("/api/auth/register", {
    method: "POST",
    body: JSON.stringify({ email: "shortpw@colorado.edu", password: "short", name: "Student" }),
  });
  assert.equal(res.status, 400);
});

test("registration succeeds with a valid CU email and returns a token", async () => {
  const { res, body } = await registerStudent("valid@colorado.edu");
  assert.equal(res.status, 201);
  assert.equal(body.user.email, "valid@colorado.edu");
  assert.ok(body.token);
});

test("registering the same email twice is rejected", async () => {
  await registerStudent("dupe@colorado.edu");
  const { res } = await registerStudent("dupe@colorado.edu");
  assert.equal(res.status, 409);
});

test("login succeeds with correct credentials and fails with wrong ones", async () => {
  await registerStudent("login@colorado.edu");

  const ok = await api("/api/auth/login", {
    method: "POST",
    body: JSON.stringify({ email: "login@colorado.edu", password: "password123" }),
  });
  assert.equal(ok.status, 200);

  const bad = await api("/api/auth/login", {
    method: "POST",
    body: JSON.stringify({ email: "login@colorado.edu", password: "wrong-password" }),
  });
  assert.equal(bad.status, 401);
});

test("reports endpoints require authentication", async () => {
  const getRes = await api("/api/reports");
  assert.equal(getRes.status, 401);

  const postRes = await api("/api/reports", {
    method: "POST",
    body: JSON.stringify({ category: "Safety Concern", latitude: 40, longitude: -105 }),
  });
  assert.equal(postRes.status, 401);
});

test("an authenticated user can file and then list a report", async () => {
  const { body: auth } = await registerStudent("reporter@colorado.edu");
  const headers = { Authorization: `Bearer ${auth.token}` };

  const post = await api("/api/reports", {
    method: "POST",
    headers,
    body: JSON.stringify({
      category: "Medical",
      latitude: 40.0077,
      longitude: -105.2693,
      note: "test report",
    }),
  });
  assert.equal(post.status, 201);
  const { report } = await post.json();
  assert.equal(report.category, "Medical");
  assert.ok(report.id);
  // The report is stored without any link back to the submitting user.
  assert.equal("userId" in report, false);

  const list = await api("/api/reports", { headers });
  assert.equal(list.status, 200);
  const { reports } = await list.json();
  assert.ok(reports.some((r) => r.id === report.id));
});

test("filing a report rejects an unknown category", async () => {
  const { body: auth } = await registerStudent("badcategory@colorado.edu");
  const res = await api("/api/reports", {
    method: "POST",
    headers: { Authorization: `Bearer ${auth.token}` },
    body: JSON.stringify({ category: "Not A Real Category", latitude: 40, longitude: -105 }),
  });
  assert.equal(res.status, 400);
});

test("an invalid token is rejected", async () => {
  const res = await api("/api/reports", {
    headers: { Authorization: "Bearer not-a-real-token" },
  });
  assert.equal(res.status, 401);
});
