const express = require('express');
const cors = require('cors');

const requestLogger = require('./middleware/request_logger');
const { errorHandler, notFoundHandler } = require('./middleware/error_handler');

const healthRoutes = require('./routes/health_routes');
const productRoutes = require('./routes/product_routes');
const categoryRoutes = require('./routes/category_routes');
const orderRoutes = require('./routes/order_routes');

const app = express();

// Basic security & header settings
app.disable('x-powered-by');
app.use((req, res, next) => {
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('X-XSS-Protection', '1; mode=block');
  next();
});

// Enable CORS for Flutter Web, mobile apps, and emulator development
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept']
}));

// Request body parser with payload size limit
app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true, limit: '1mb' }));

// Logging middleware
app.use(requestLogger);

// API route mounts
app.use('/api/health', healthRoutes);
app.use('/api/products', productRoutes);
app.use('/api/categories', categoryRoutes);
app.use('/api/orders', orderRoutes);

// Root informational endpoint
app.get('/', (req, res) => {
  res.status(200).json({
    name: 'ShopLite REST API',
    version: '1.0.0',
    documentation: '/api/health'
  });
});

// 404 handler for unknown routes
app.use(notFoundHandler);

// Centralized error handling
app.use(errorHandler);

module.exports = app;
