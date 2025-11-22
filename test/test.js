const assert = require("assert");
const { main } = require("../src/index");

// Basic smoke test: ensure main is a function
assert.strictEqual(typeof main, "function", "main should be a function");
console.log("Basic test passed");
