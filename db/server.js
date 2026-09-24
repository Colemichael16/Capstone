import { createApp } from "./src/app.js";
import { openDatabase } from "./src/db.js";

const PORT = process.env.PORT || 3000;

const db = openDatabase();
const app = createApp(db);

app.listen(PORT, () => {
  console.log(`CU Alerts API listening on http://localhost:${PORT}`);
});
