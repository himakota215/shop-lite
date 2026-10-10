const nodemailer = require('nodemailer');
const config = require('../config/env');

class EmailService {
  constructor() {
    this._transporter = null;
  }

  /**
   * Set custom transporter (useful for unit testing with mocks or ethereal accounts)
   */
  setTransporter(customTransporter) {
    this._transporter = customTransporter;
  }

  /**
   * Get or create the Nodemailer transport instance
   */
  getTransporter() {
    if (this._transporter) {
      return this._transporter;
    }

    const { smtpHost, smtpPort, smtpSecure, smtpUser, smtpPass } = config.email;

    if (smtpHost) {
      this._transporter = nodemailer.createTransport({
        host: smtpHost,
        port: smtpPort,
        secure: smtpSecure,
        auth: smtpUser ? { user: smtpUser, pass: smtpPass } : undefined,
        tls: {
          rejectUnauthorized: config.nodeEnv === 'production'
        }
      });
    }

    return this._transporter;
  }

  /**
   * Send an automatic order confirmation email to the configured recipient.
   * Catches all exceptions to ensure email failures never fail or roll back the order.
   */
  async sendOrderNotification(order) {
    try {
      const recipient = config.email.notificationRecipient;

      if (!recipient || recipient.trim() === '') {
        console.log('[EmailService] ORDER_NOTIFICATION_EMAIL is not configured. Skipping email dispatch.');
        return { sent: false, reason: 'NO_RECIPIENT_CONFIGURED' };
      }

      const transporter = this.getTransporter();
      if (!transporter) {
        console.log('[EmailService] SMTP host is not configured. Skipping email dispatch.');
        return { sent: false, reason: 'NO_SMTP_CONFIGURED' };
      }

      const orderId = order.id;
      const customer = order.customer || {};
      const items = order.items || [];
      const totalAmount = Number(order.totalAmount).toFixed(2);

      // Generate HTML item rows
      const itemRowsHtml = items
        .map(
          (item) => `
            <tr>
              <td style="padding: 10px 12px; border-bottom: 1px solid #e0e0e0;">${item.productName || 'Product'}</td>
              <td style="padding: 10px 12px; border-bottom: 1px solid #e0e0e0; text-align: center;">${item.quantity}</td>
              <td style="padding: 10px 12px; border-bottom: 1px solid #e0e0e0; text-align: right;">$${Number(item.unitPrice).toFixed(2)}</td>
              <td style="padding: 10px 12px; border-bottom: 1px solid #e0e0e0; text-align: right; font-weight: bold;">$${Number(item.lineTotal).toFixed(2)}</td>
            </tr>
          `
        )
        .join('');

      // Generate Plaintext item rows
      const itemsText = items
        .map(
          (item) =>
            `- ${item.productName} | Qty: ${item.quantity} | Unit: $${Number(item.unitPrice).toFixed(2)} | Subtotal: $${Number(item.lineTotal).toFixed(2)}`
        )
        .join('\n');

      const subject = `[ShopLite] New Order Placed: #${orderId} ($${totalAmount})`;

      const htmlContent = `
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="utf-8">
          <style>
            body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; color: #333; line-height: 1.5; margin: 0; padding: 20px; background-color: #f8f9fa; }
            .container { max-width: 600px; margin: 0 auto; background: #ffffff; border-radius: 12px; overflow: hidden; border: 1px solid #e0e0e0; }
            .header { background: #1E7E34; color: #ffffff; padding: 24px; text-align: center; }
            .header h1 { margin: 0; font-size: 24px; font-weight: 700; }
            .content { padding: 24px; }
            .order-meta { background: #E8F5E9; padding: 14px 18px; border-radius: 8px; margin-bottom: 20px; }
            .section-title { font-size: 16px; font-weight: 700; color: #1E7E34; margin-top: 20px; margin-bottom: 10px; border-bottom: 2px solid #E8F5E9; padding-bottom: 4px; }
            table { width: 100%; border-collapse: collapse; margin-top: 10px; font-size: 14px; }
            th { background: #f1f3f5; padding: 10px 12px; text-align: left; font-weight: 600; }
            .total-row { font-size: 16px; font-weight: bold; color: #1E7E34; text-align: right; padding-top: 16px; }
            .footer { padding: 16px 24px; text-align: center; font-size: 12px; color: #777; background: #fafafa; border-top: 1px solid #eee; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1>New Order Confirmed</h1>
              <p style="margin: 6px 0 0 0; opacity: 0.9;">Order #${orderId}</p>
            </div>
            <div class="content">
              <div class="order-meta">
                <strong>Status:</strong> ${order.status || 'CONFIRMED'}<br>
                <strong>Order ID:</strong> #${orderId}<br>
                <strong>Timestamp:</strong> ${new Date().toISOString()}
              </div>

              <div class="section-title">Customer & Delivery Information</div>
              <p style="margin: 6px 0;"><strong>Name:</strong> ${customer.name || 'N/A'}</p>
              <p style="margin: 6px 0;"><strong>Phone:</strong> ${customer.phone || 'N/A'}</p>
              <p style="margin: 6px 0;"><strong>Delivery Address:</strong> ${customer.address || 'N/A'}</p>

              <div class="section-title">Ordered Products</div>
              <table>
                <thead>
                  <tr>
                    <th>Product</th>
                    <th style="text-align: center;">Qty</th>
                    <th style="text-align: right;">Price</th>
                    <th style="text-align: right;">Total</th>
                  </tr>
                </thead>
                <tbody>
                  ${itemRowsHtml}
                </tbody>
              </table>

              <div class="total-row">
                Grand Total: $${totalAmount}
              </div>
            </div>
            <div class="footer">
              ShopLite Automated Notification System • Powered by Express & MySQL
            </div>
          </div>
        </body>
        </html>
      `;

      const textContent = `
ShopLite - New Order Received: #${orderId}
==========================================
Status: ${order.status || 'CONFIRMED'}
Grand Total: $${totalAmount}
Timestamp: ${new Date().toISOString()}

Customer Details:
-----------------
Name: ${customer.name || 'N/A'}
Phone: ${customer.phone || 'N/A'}
Delivery Address: ${customer.address || 'N/A'}

Ordered Items:
--------------
${itemsText}

Total Amount: $${totalAmount}
==========================================
ShopLite Automated Notification
      `.trim();

      const mailOptions = {
        from: config.email.fromAddress,
        to: recipient,
        subject,
        text: textContent,
        html: htmlContent
      };

      const info = await transporter.sendMail(mailOptions);
      console.log(`[EmailService] Order notification email successfully sent for Order #${orderId} (MessageID: ${info.messageId})`);

      return {
        sent: true,
        messageId: info.messageId,
        recipient
      };
    } catch (err) {
      // Non-fatal error handling: Log warning, never throw to protect order completion
      console.warn(`[EmailService WARNING] Failed to send order notification email for Order #${order?.id}: ${err.message}`);
      return {
        sent: false,
        error: err.message
      };
    }
  }
}

module.exports = new EmailService();
