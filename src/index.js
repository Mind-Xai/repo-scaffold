// Minimal entry point used for basic scaffold and CI validation
function main() {
  console.log("Hello from repo scaffold");
}

if (require.main === module) {
  main();
}

module.exports = { main };
