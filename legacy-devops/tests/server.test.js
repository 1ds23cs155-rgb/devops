const request = require('supertest');

// Mock app for testing
const express = require('express');

const createApp = () => {
  const app = express();

  app.get('/health', (req, res) => {
    res.json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      uptime: process.uptime()
    });
  });

  app.get('/api/info', (req, res) => {
    res.json({
      app: 'DevOps Demo Application',
      version: '1.0.0',
      environment: process.env.NODE_ENV || 'development',
      message: 'Welcome to the DevOps project!'
    });
  });

  app.get('/', (req, res) => {
    res.send('<h1>DevOps Demo Application</h1>');
  });

  return app;
};

describe('DevOps Application Tests', () => {
  let app;

  beforeEach(() => {
    app = createApp();
  });

  describe('GET /', () => {
    it('should return 200 and HTML content', async () => {
      const response = await request(app).get('/');
      expect(response.status).toBe(200);
      expect(response.text).toContain('DevOps Demo Application');
    });
  });

  describe('GET /health', () => {
    it('should return 200 with healthy status', async () => {
      const response = await request(app).get('/health');
      expect(response.status).toBe(200);
      expect(response.body.status).toBe('healthy');
    });

    it('should include timestamp and uptime', async () => {
      const response = await request(app).get('/health');
      expect(response.body).toHaveProperty('timestamp');
      expect(response.body).toHaveProperty('uptime');
      expect(typeof response.body.uptime).toBe('number');
    });
  });

  describe('GET /api/info', () => {
    it('should return 200 with app info', async () => {
      const response = await request(app).get('/api/info');
      expect(response.status).toBe(200);
      expect(response.body.app).toBe('DevOps Demo Application');
      expect(response.body.version).toBe('1.0.0');
    });

    it('should include environment information', async () => {
      const response = await request(app).get('/api/info');
      expect(response.body).toHaveProperty('environment');
    });
  });

  describe('Error Handling', () => {
    it('should return 404 for unknown routes', async () => {
      const response = await request(app).get('/unknown-route');
      expect(response.status).toBe(404);
    });
  });
});
