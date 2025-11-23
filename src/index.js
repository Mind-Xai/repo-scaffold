const os = require('os');

console.log("--- Mind-Xai Scaffold App Starting ---");
console.log(`Timestamp: ${new Date().toISOString()}`);
console.log(`Platform:  ${os.platform()} ${os.release()}`);
console.log(`Memory:    ${Math.round(os.totalmem() / 1024 / 1024)} MB`);
console.log("--------------------------------------");
