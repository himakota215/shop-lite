const emailService = require('../src/services/email_service');
const config = require('../src/config/env');

describe('Email Notification Service', () => {
  const originalRecipient = config.email.notificationRecipient;
  const originalHost = config.email.smtpHost;

  afterEach(() => {
    config.email.notificationRecipient = originalRecipient;
    config.email.smtpHost = originalHost;
    emailService.setTransporter(null);
    jest.restoreAllMocks();
  });

  const sampleOrder = {
    id: 99,
    customer: {
      name: 'Alex Developer',
      phone: '+1 555-123-4567',
      address: '742 Evergreen Terrace, Springfield'
    },
    totalAmount: 189.98,
    status: 'CONFIRMED',
    items: [
      {
        id: 1,
        productId: 1,
        productName: 'SonicPro Wireless Headphones',
        quantity: 1,
        unitPrice: 129.99,
        lineTotal: 129.99
      },
      {
        id: 2,
        productId: 5,
        productName: 'Urban Classic Denim Jacket',
        quantity: 1,
        unitPrice: 59.99,
        lineTotal: 59.99
      }
    ]
  };

  it('should format and send email notification using configured transporter', async () => {
    config.email.notificationRecipient = 'orders@shoplite.com';
    config.email.smtpHost = 'smtp.testserver.local';

    const sendMailMock = jest.fn().mockResolvedValue({ messageId: '<test-msg-123@shoplite>' });
    const mockTransporter = { sendMail: sendMailMock };
    emailService.setTransporter(mockTransporter);

    const result = await emailService.sendOrderNotification(sampleOrder);

    expect(result.sent).toBe(true);
    expect(result.messageId).toBe('<test-msg-123@shoplite>');
    expect(sendMailMock).toHaveBeenCalledTimes(1);

    const mailOptions = sendMailMock.mock.calls[0][0];
    expect(mailOptions.to).toBe('orders@shoplite.com');
    expect(mailOptions.subject).toContain('#99');
    expect(mailOptions.subject).toContain('$189.98');
    expect(mailOptions.html).toContain('Alex Developer');
    expect(mailOptions.html).toContain('+1 555-123-4567');
    expect(mailOptions.html).toContain('SonicPro Wireless Headphones');
    expect(mailOptions.html).toContain('Urban Classic Denim Jacket');
    expect(mailOptions.text).toContain('742 Evergreen Terrace');
  });

  it('should skip sending if ORDER_NOTIFICATION_EMAIL is empty', async () => {
    config.email.notificationRecipient = '';

    const sendMailMock = jest.fn();
    emailService.setTransporter({ sendMail: sendMailMock });

    const result = await emailService.sendOrderNotification(sampleOrder);

    expect(result.sent).toBe(false);
    expect(result.reason).toBe('NO_RECIPIENT_CONFIGURED');
    expect(sendMailMock).not.toHaveBeenCalled();
  });

  it('should skip sending if SMTP host is not configured', async () => {
    config.email.notificationRecipient = 'orders@shoplite.com';
    config.email.smtpHost = '';
    emailService.setTransporter(null);

    const result = await emailService.sendOrderNotification(sampleOrder);

    expect(result.sent).toBe(false);
    expect(result.reason).toBe('NO_SMTP_CONFIGURED');
  });

  it('should handle SMTP failure gracefully without throwing', async () => {
    config.email.notificationRecipient = 'orders@shoplite.com';
    config.email.smtpHost = 'smtp.testserver.local';

    const sendMailMock = jest.fn().mockRejectedValue(new Error('Connection to SMTP server timed out'));
    emailService.setTransporter({ sendMail: sendMailMock });

    // Ensure it resolves without throwing
    const result = await emailService.sendOrderNotification(sampleOrder);

    expect(result.sent).toBe(false);
    expect(result.error).toContain('Connection to SMTP server timed out');
  });
});
