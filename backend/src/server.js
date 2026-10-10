const app = require('./app');
const config = require('./config/env');
const db = require('./config/database');

const HOST = '0.0.0.0'; // Bind to all network interfaces for Android device/LAN access
const PORT = config.port;

const server = app.listen(PORT, HOST, async () => {
  console.log(`====================================================`);
  console.log(` ShopLite Backend Server running`);
  console.log(` Local:            http://localhost:${PORT}`);
  console.log(` Network Bind:     http://${HOST}:${PORT}`);
  console.log(` Health Endpoint:  http://localhost:${PORT}/api/health`);
  console.log(` Environment:      ${config.nodeEnv}`);
  console.log(` Database Host:    ${config.db.host}:${config.db.port}`);
  console.log(`====================================================`);

  // Verify initial database connection asynchronously
  const health = await db.checkConnection();
  if (health.connected) {
    console.log(`[DB] Successfully connected to MySQL database: ${config.db.database}`);
  } else {
    console.warn(`[DB WARNING] Unable to connect to MySQL database at startup: ${health.error}`);
    console.warn(`[DB WARNING] The server will still serve requests, and retry DB connections dynamically.`);
  }
});

// Configure server timeout (30 seconds)
server.timeout = 30000;

// Graceful shutdown handling
async function shutdown(signal) {
  console.log(`\nReceived ${signal}. Shutting down gracefully...`);

  server.close(async () => {
    console.log('HTTP server closed.');
    try {
      await db.closePool();
      console.log('Database connection pool closed.');
      process.exit(0);
    } catch (err) {
      console.error('Error while closing database pool:', err);
      process.exit(1);
    }
  });

  // Force shutdown after 10 seconds timeout
  setTimeout(() => {
    console.error('Forced shutdown due to timeout.');
    process.exit(1);
  }, 10000);
}

process.on('SIGINT', () => shutdown('SIGINT'));
process.on('SIGTERM', () => shutdown('SIGTERM'));
