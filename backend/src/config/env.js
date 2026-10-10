const path = require('path');
const dotenv = require('dotenv');

// Load .env from backend root if it exists
dotenv.config({ path: path.resolve(__dirname, '../../.env') });

const config = {
  port: parseInt(process.env.PORT, 10) || 3000,
  nodeEnv: process.env.NODE_ENV || 'development',
  db: {
    host: process.env.DB_HOST || '127.0.0.1',
    port: parseInt(process.env.DB_PORT, 10) || 3306,
    database: process.env.DB_NAME || 'shoplite_db',
    user: process.env.DB_USER || 'shoplite_user',
    password: process.env.DB_PASSWORD || '',
    connectionLimit: parseInt(process.env.DB_CONNECTION_LIMIT, 10) || 10,
    waitForConnections: true,
    queueLimit: 0,
    decimalNumbers: true
  },
  email: {
    smtpHost: process.env.SMTP_HOST || '',
    smtpPort: parseInt(process.env.SMTP_PORT, 10) || 587,
    smtpSecure: process.env.SMTP_SECURE === 'true',
    smtpUser: process.env.SMTP_USER || '',
    smtpPass: process.env.SMTP_PASS || '',
    fromAddress: process.env.SMTP_FROM || 'no-reply@shoplite.local',
    notificationRecipient: process.env.ORDER_NOTIFICATION_EMAIL || ''
  }
};

module.exports = config;
