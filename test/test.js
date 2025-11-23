const { spawnSync } = require("child_process");

const child = spawnSync("node", ["./src/index.js"], { encoding: "utf8", timeout: 5000 });
if (child.error) {
  console.error("Failed to run app:", child.error);
  process.exit(2);
}
const out = (child.stdout || "") + (child.stderr || "");
// Check for the main header printed by the app
if (!out.includes("Mind-Xai Scaffold App Starting")) {
  console.error("Smoke test failed: expected header not found. Output:\n", out);
  process.exit(1);
}
console.log("App smoke test passed");
