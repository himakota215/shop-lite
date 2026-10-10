const request = require('supertest');
const app = require('../src/app');
const db = require('../src/config/database');
const orderRepository = require('../src/repositories/order_repository');

describe('Orders API & Checkout Flow', () => {
  afterEach(() => {
    jest.restoreAllMocks();
  });

  afterAll(async () => {
    await db.closePool();
  });

  describe('Validation on POST /api/orders', () => {
    it('should reject request when customer details are missing', async () => {
      const res = await request(app).post('/api/orders').send({
        items: [{ productId: 1, quantity: 1 }]
      });

      expect(res.statusCode).toBe(400);
      expect(res.body.success).toBe(false);
      expect(res.body.details).toContain('Customer details are required');
    });

    it('should reject request when phone number is invalid', async () => {
      const res = await request(app).post('/api/orders').send({
        customer: {
          name: 'Jane Doe',
          phone: '123', // too short
          address: '123 Market Street, City'
        },
        items: [{ productId: 1, quantity: 1 }]
      });

      expect(res.statusCode).toBe(400);
      expect(res.body.details).toContain('A valid phone number (between 7 and 20 digits/characters) is required');
    });

    it('should reject request with empty cart items', async () => {
      const res = await request(app).post('/api/orders').send({
        customer: {
          name: 'Jane Doe',
          phone: '9876543210',
          address: '123 Market Street, City'
        },
        items: []
      });

      expect(res.statusCode).toBe(400);
      expect(res.body.details).toContain('Cart items array is required and must contain at least one item');
    });

    it('should reject request with negative or zero quantity', async () => {
      const res = await request(app).post('/api/orders').send({
        customer: {
          name: 'Jane Doe',
          phone: '9876543210',
          address: '123 Market Street, City'
        },
        items: [{ productId: 1, quantity: 0 }]
      });

      expect(res.statusCode).toBe(400);
    });
  });

  describe('Transactional Order Placement & Stock Validation', () => {
    it('should return 400 when product has insufficient stock', async () => {
      const mockConnection = {
        beginTransaction: jest.fn().mockResolvedValue(),
        execute: jest.fn().mockImplementation((sql) => {
          if (sql.includes('FOR UPDATE')) {
            // Return locked product with only 2 in stock
            return [[{
              id: 1,
              name: 'SonicPro Headphones',
              description: 'Desc',
              price: '100.00',
              category: 'Electronics',
              image_url: 'img',
              rating: '4.5',
              stock_quantity: 2
            }]];
          }
          return [{}];
        }),
        commit: jest.fn().mockResolvedValue(),
        rollback: jest.fn().mockResolvedValue(),
        release: jest.fn()
      };

      jest.spyOn(db, 'getConnection').mockResolvedValue(mockConnection);

      const res = await request(app).post('/api/orders').send({
        customer: {
          name: 'Jane Doe',
          phone: '9876543210',
          address: '123 Market Street, City'
        },
        items: [{ productId: 1, quantity: 5 }] // Requests 5, but stock is 2
      });

      expect(res.statusCode).toBe(400);
      expect(res.body.code).toBe('INSUFFICIENT_STOCK');
      expect(mockConnection.rollback).toHaveBeenCalled();
      expect(mockConnection.commit).not.toHaveBeenCalled();
      expect(mockConnection.release).toHaveBeenCalled();
    });

    it('should successfully place order, calculate server-side price, and commit', async () => {
      const mockConnection = {
        beginTransaction: jest.fn().mockResolvedValue(),
        execute: jest.fn().mockImplementation((sql, params) => {
          if (sql.includes('FOR UPDATE')) {
            return [[{
              id: 1,
              name: 'SonicPro Headphones',
              description: 'Desc',
              price: '120.00',
              category: 'Electronics',
              image_url: 'img',
              rating: '4.5',
              stock_quantity: 10
            }]];
          }
          if (sql.includes('INSERT INTO orders')) {
            // Verify calculated total in params: 2 * 120.00 = 240.00
            expect(params[3]).toBe(240);
            return [{ insertId: 42 }];
          }
          if (sql.includes('INSERT INTO order_items')) {
            return [{ insertId: 101 }];
          }
          if (sql.includes('UPDATE products')) {
            return [{ affectedRows: 1 }];
          }
          return [{}];
        }),
        commit: jest.fn().mockResolvedValue(),
        rollback: jest.fn().mockResolvedValue(),
        release: jest.fn()
      };

      jest.spyOn(db, 'getConnection').mockResolvedValue(mockConnection);
      jest.spyOn(orderRepository, 'findById').mockResolvedValue({
        id: 42,
        customer: {
          name: 'Jane Doe',
          phone: '9876543210',
          address: '123 Market Street, City'
        },
        totalAmount: 240.00,
        status: 'CONFIRMED',
        createdAt: '2026-10-10 12:00:00',
        items: [
          {
            id: 101,
            productId: 1,
            productName: 'SonicPro Headphones',
            productImageUrl: 'img',
            quantity: 2,
            unitPrice: 120.00,
            lineTotal: 240.00
          }
        ]
      });

      const res = await request(app).post('/api/orders').send({
        customer: {
          name: 'Jane Doe',
          phone: '9876543210',
          address: '123 Market Street, City'
        },
        // Deliberately pass fake total to verify backend ignores client total
        totalAmount: 9.99,
        items: [{ productId: 1, quantity: 2 }]
      });

      expect(res.statusCode).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.data.id).toBe(42);
      expect(res.body.data.totalAmount).toBe(240.00);
      expect(mockConnection.commit).toHaveBeenCalled();
      expect(mockConnection.rollback).not.toHaveBeenCalled();
      expect(mockConnection.release).toHaveBeenCalled();
    });

    it('should rollback transaction if an error occurs during processing', async () => {
      const mockConnection = {
        beginTransaction: jest.fn().mockResolvedValue(),
        execute: jest.fn().mockRejectedValue(new Error('Simulated database execution failure')),
        commit: jest.fn().mockResolvedValue(),
        rollback: jest.fn().mockResolvedValue(),
        release: jest.fn()
      };

      jest.spyOn(db, 'getConnection').mockResolvedValue(mockConnection);

      const res = await request(app).post('/api/orders').send({
        customer: {
          name: 'Jane Doe',
          phone: '9876543210',
          address: '123 Market Street, City'
        },
        items: [{ productId: 1, quantity: 1 }]
      });

      expect(res.statusCode).toBe(500);
      expect(mockConnection.rollback).toHaveBeenCalled();
      expect(mockConnection.release).toHaveBeenCalled();
    });

    it('should place order successfully and commit even if email notification fails', async () => {
      const emailService = require('../src/services/email_service');
      jest.spyOn(emailService, 'sendOrderNotification').mockRejectedValue(new Error('SMTP unreachable'));

      const mockConnection = {
        beginTransaction: jest.fn().mockResolvedValue(),
        execute: jest.fn().mockImplementation((sql) => {
          if (sql.includes('FOR UPDATE')) {
            return [[{
              id: 1,
              name: 'SonicPro Headphones',
              description: 'Desc',
              price: '120.00',
              category: 'Electronics',
              image_url: 'img',
              rating: '4.5',
              stock_quantity: 10
            }]];
          }
          if (sql.includes('INSERT INTO orders')) {
            return [{ insertId: 55 }];
          }
          if (sql.includes('INSERT INTO order_items')) {
            return [{ insertId: 102 }];
          }
          if (sql.includes('UPDATE products')) {
            return [{ affectedRows: 1 }];
          }
          return [{}];
        }),
        commit: jest.fn().mockResolvedValue(),
        rollback: jest.fn().mockResolvedValue(),
        release: jest.fn()
      };

      jest.spyOn(db, 'getConnection').mockResolvedValue(mockConnection);
      jest.spyOn(orderRepository, 'findById').mockResolvedValue({
        id: 55,
        customer: {
          name: 'Jane Doe',
          phone: '9876543210',
          address: '123 Market Street, City'
        },
        totalAmount: 120.00,
        status: 'CONFIRMED',
        items: []
      });

      const res = await request(app).post('/api/orders').send({
        customer: {
          name: 'Jane Doe',
          phone: '9876543210',
          address: '123 Market Street, City'
        },
        items: [{ productId: 1, quantity: 1 }]
      });

      expect(res.statusCode).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.data.id).toBe(55);
      expect(mockConnection.commit).toHaveBeenCalled();
      expect(mockConnection.rollback).not.toHaveBeenCalled();
    });
  });

  describe('GET /api/orders/:id', () => {
    it('should retrieve existing order by ID', async () => {
      jest.spyOn(orderRepository, 'findById').mockResolvedValue({
        id: 42,
        customer: {
          name: 'Jane Doe',
          phone: '9876543210',
          address: '123 Market Street, City'
        },
        totalAmount: 240.00,
        status: 'CONFIRMED',
        items: []
      });

      const res = await request(app).get('/api/orders/42');
      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.id).toBe(42);
    });

    it('should return 404 for non-existent order ID', async () => {
      jest.spyOn(orderRepository, 'findById').mockResolvedValue(null);

      const res = await request(app).get('/api/orders/999');
      expect(res.statusCode).toBe(404);
      expect(res.body.code).toBe('ORDER_NOT_FOUND');
    });

    it('should return 400 for non-integer order ID', async () => {
      const res = await request(app).get('/api/orders/abc');
      expect(res.statusCode).toBe(400);
      expect(res.body.error).toBe('Invalid order ID');
    });
  });
});
