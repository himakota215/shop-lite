const mysql = require('mysql2/promise');
const config = require('./env');

let pool = null;

function getPool() {
  if (!pool) {
    pool = mysql.createPool({
      host: config.db.host,
      port: config.db.port,
      user: config.db.user,
      password: config.db.password,
      database: config.db.database,
      waitForConnections: config.db.waitForConnections,
      connectionLimit: config.db.connectionLimit,
      queueLimit: config.db.queueLimit,
      decimalNumbers: config.db.decimalNumbers,
      timezone: 'Z',
      dateStrings: true
    });
  }
  return pool;
}

/**
 * Set an explicit pool instance (useful for unit/integration testing with mocks)
 */
function setPool(customPool) {
  pool = customPool;
}

/**
 * Execute a parameterized query using the pool
 */
async function query(sql, params = []) {
  const currentPool = getPool();
  const [rows] = await currentPool.execute(sql, params);
  return rows;
}

/**
 * Get a connection from the pool for transactions
 */
async function getConnection() {
  const currentPool = getPool();
  return await currentPool.getConnection();
}

/**
 * Check database connectivity without leaking credentials or internals
 */
async function checkConnection() {
  const startTime = Date.now();
  try {
    const currentPool = getPool();
    const [rows] = await currentPool.query('SELECT 1 AS alive');
    const latencyMs = Date.now() - startTime;
    return {
      connected: Boolean(rows && rows[0] && rows[0].alive === 1),
      latencyMs
    };
  } catch (err) {
    return {
      connected: false,
      error: 'Database connection failed'
    };
  }
}

/**
 * Close the connection pool gracefully
 */
async function closePool() {
  if (pool) {
    await pool.end();
    pool = null;
  }
}

module.exports = {
  getPool,
  setPool,
  query,
  getConnection,
  checkConnection,
  closePool
};
