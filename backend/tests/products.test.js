const request = require('supertest');
const app = require('../src/app');
const db = require('../src/config/database');

describe('Products & Categories API', () => {
  afterEach(() => {
    jest.restoreAllMocks();
  });

  afterAll(async () => {
    await db.closePool();
  });

  const sampleDbProducts = [
    {
      id: 1,
      name: 'SonicPro Wireless Headphones',
      description: 'Noise cancelling headphones',
      price: '129.99',
      category: 'Electronics',
      image_url: 'https://images.unsplash.com/sample1',
      rating: '4.8',
      stock_quantity: 15,
      created_at: '2026-01-01 10:00:00',
      updated_at: '2026-01-01 10:00:00'
    },
    {
      id: 2,
      name: 'Urban Classic Denim Jacket',
      description: 'Relaxed fit jacket',
      price: '64.00',
      category: 'Fashion',
      image_url: 'https://images.unsplash.com/sample2',
      rating: '4.4',
      stock_quantity: 20,
      created_at: '2026-01-01 10:00:00',
      updated_at: '2026-01-01 10:00:00'
    }
  ];

  describe('GET /api/products', () => {
    it('should return 200 and product list', async () => {
      jest.spyOn(db, 'query').mockResolvedValue(sampleDbProducts);

      const res = await request(app).get('/api/products');
      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.count).toBe(2);
      expect(res.body.data[0].name).toBe('SonicPro Wireless Headphones');
      expect(res.body.data[0].price).toBe(129.99);
      expect(res.body.data[0].stockQuantity).toBe(15);
    });

    it('should pass search and category filters to query', async () => {
      const querySpy = jest.spyOn(db, 'query').mockResolvedValue([sampleDbProducts[0]]);

      const res = await request(app)
        .get('/api/products?search=headphones&category=Electronics');

      expect(res.statusCode).toBe(200);
      expect(res.body.count).toBe(1);
      expect(querySpy).toHaveBeenCalled();
      const calledSql = querySpy.mock.calls[0][0];
      const calledParams = querySpy.mock.calls[0][1];

      expect(calledSql).toContain('LOWER(category) = LOWER(?)');
      expect(calledParams).toContain('Electronics');
      expect(calledParams).toContain('%headphones%');
    });

    it('should return 400 for overly long search string', async () => {
      const longString = 'a'.repeat(101);
      const res = await request(app).get(`/api/products?search=${longString}`);
      expect(res.statusCode).toBe(400);
      expect(res.body.error).toBe('Invalid query parameters');
    });
  });

  describe('GET /api/products/:id', () => {
    it('should return 200 and single product when found', async () => {
      jest.spyOn(db, 'query').mockResolvedValue([sampleDbProducts[0]]);

      const res = await request(app).get('/api/products/1');
      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.id).toBe(1);
      expect(res.body.data.name).toBe('SonicPro Wireless Headphones');
    });

    it('should return 404 when product is not found', async () => {
      jest.spyOn(db, 'query').mockResolvedValue([]);

      const res = await request(app).get('/api/products/999');
      expect(res.statusCode).toBe(404);
      expect(res.body.code).toBe('PRODUCT_NOT_FOUND');
    });

    it('should return 400 for non-numeric product ID', async () => {
      const res = await request(app).get('/api/products/invalid-id');
      expect(res.statusCode).toBe(400);
      expect(res.body.error).toBe('Invalid product ID');
    });
  });

  describe('GET /api/categories', () => {
    it('should return list of unique categories', async () => {
      jest.spyOn(db, 'query').mockResolvedValue([
        { name: 'Accessories', productCount: 4 },
        { name: 'Electronics', productCount: 4 }
      ]);

      const res = await request(app).get('/api/categories');
      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data).toHaveLength(2);
      expect(res.body.data[0].name).toBe('Accessories');
      expect(res.body.data[0].productCount).toBe(4);
    });
  });
});
