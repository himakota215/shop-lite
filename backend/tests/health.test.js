const request = require('supertest');
const app = require('../src/app');
const db = require('../src/config/database');

describe('GET /api/health', () => {
  afterEach(() => {
    jest.restoreAllMocks();
  });

  afterAll(async () => {
    await db.closePool();
  });

  it('should return 200 and healthy status when database is connected', async () => {
    jest.spyOn(db, 'checkConnection').mockResolvedValue({
      connected: true,
      latencyMs: 3
    });

    const res = await request(app).get('/api/health');
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe('healthy');
    expect(res.body.service).toBe('shop-lite-backend');
    expect(res.body.database.status).toBe('connected');
    expect(res.body.database.latencyMs).toBe(3);
  });

  it('should return 503 and degraded status when database is disconnected', async () => {
    jest.spyOn(db, 'checkConnection').mockResolvedValue({
      connected: false,
      error: 'Connection refused'
    });

    const res = await request(app).get('/api/health');
    expect(res.statusCode).toBe(503);
    expect(res.body.status).toBe('degraded');
    expect(res.body.database.status).toBe('disconnected');
  });
});
