const db = require('../config/database');

async function getHealth(req, res) {
  const dbHealth = await db.checkConnection();

  const isHealthy = dbHealth.connected;
  const statusCode = isHealthy ? 200 : 503;

  return res.status(statusCode).json({
    status: isHealthy ? 'healthy' : 'degraded',
    service: 'shop-lite-backend',
    timestamp: new Date().toISOString(),
    database: {
      status: dbHealth.connected ? 'connected' : 'disconnected',
      latencyMs: dbHealth.latencyMs !== undefined ? dbHealth.latencyMs : null
    }
  });
}

module.exports = {
  getHealth
};
