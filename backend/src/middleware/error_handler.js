const config = require('../config/env');

function errorHandler(err, req, res, next) { // eslint-disable-line no-unused-vars
  // Determine appropriate HTTP status
  let statusCode = err.statusCode || 500;
  let clientMessage = err.message || 'An unexpected server error occurred';
  const code = err.code || 'INTERNAL_ERROR';

  // Handle MySQL-specific errors securely without exposing schema details or credentials
  if (err.code === 'ER_ACCESS_DENIED_ERROR' || err.code === 'ECONNREFUSED' || err.code === 'PROTOCOL_CONNECTION_LOST') {
    statusCode = 503;
    clientMessage = 'Database service is currently unavailable. Please try again shortly.';
  } else if (err.code === 'ER_NO_REFERENCED_ROW_2' || err.code === 'ER_NO_REFERENCED_ROW') {
    statusCode = 400;
    clientMessage = 'One or more referenced entities do not exist.';
  } else if (err.code === 'ER_DUP_ENTRY') {
    statusCode = 409;
    clientMessage = 'A resource with these attributes already exists.';
  } else if (err.type === 'entity.parse.failed') {
    statusCode = 400;
    clientMessage = 'Malformed JSON payload in request.';
  }

  // Log error internally on server
  if (statusCode >= 500) {
    console.error(`[ERROR] [${req.method}] ${req.originalUrl} - ${err.message}`, {
      code: err.code,
      stack: config.nodeEnv === 'development' ? err.stack : undefined
    });
  }

  return res.status(statusCode).json({
    success: false,
    error: clientMessage,
    code,
    ...(err.details ? { details: err.details } : {})
  });
}

function notFoundHandler(req, res) {
  res.status(404).json({
    success: false,
    error: `Route not found: ${req.method} ${req.originalUrl}`,
    code: 'NOT_FOUND'
  });
}

module.exports = {
  errorHandler,
  notFoundHandler
};
