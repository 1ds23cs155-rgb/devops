const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const swaggerUi = require('swagger-ui-express');
const swaggerJsdoc = require('swagger-jsdoc');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;
const ENV = process.env.NODE_ENV || 'development';

// Swagger Documentation
const swaggerOptions = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'DevOps Demo API',
      version: '1.0.0',
      description: 'Enterprise-grade DevOps application with monitoring and security'
    },
    servers: [
      {
        url: `http://localhost:${PORT}`,
        description: 'Development server'
      }
    ],
    components: {
      schemas: {
        HealthCheck: {
          type: 'object',
          properties: {
            status: { type: 'string', example: 'healthy' },
            timestamp: { type: 'string', format: 'date-time' },
            uptime: { type: 'number' }
          }
        },
        AppInfo: {
          type: 'object',
          properties: {
            app: { type: 'string' },
            version: { type: 'string' },
            environment: { type: 'string' },
            message: { type: 'string' }
          }
        }
      }
    }
  },
  apis: ['./app/server.js', './app/server-enhanced.js']
};

const specs = swaggerJsdoc(swaggerOptions);

// Security & Middleware
app.use(helmet());
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  credentials: true
}));
app.use(morgan('combined'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Swagger UI
app.use('/api/docs', swaggerUi.serve, swaggerUi.setup(specs));

// Prometheus metrics endpoint
app.get('/metrics', (req, res) => {
  res.set('Content-Type', 'text/plain');
  res.send(`# HELP app_info Application information
# TYPE app_info gauge
app_info{version="1.0.0",environment="${ENV}"} 1

# HELP nodejs_memory_heap_used_bytes Heap used memory
# TYPE nodejs_memory_heap_used_bytes gauge
nodejs_memory_heap_used_bytes ${Math.round(process.memoryUsage().heapUsed)}

# HELP nodejs_memory_heap_total_bytes Heap total memory
# TYPE nodejs_memory_heap_total_bytes gauge
nodejs_memory_heap_total_bytes ${Math.round(process.memoryUsage().heapTotal)}

# HELP process_uptime_seconds Process uptime
# TYPE process_uptime_seconds gauge
process_uptime_seconds ${process.uptime()}
`);
});

/**
 * @swagger
 * /health:
 *   get:
 *     summary: Health check endpoint
 *     tags:
 *       - Health
 *     responses:
 *       200:
 *         description: Application is healthy
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/HealthCheck'
 */
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: ENV
  });
});

/**
 * @swagger
 * /api/info:
 *   get:
 *     summary: Get application information
 *     tags:
 *       - Info
 *     responses:
 *       200:
 *         description: Application information
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/AppInfo'
 */
app.get('/api/info', (req, res) => {
  res.json({
    app: 'DevOps Demo Application (Enhanced)',
    version: '1.0.0',
    environment: ENV,
    message: 'Welcome to the enterprise-grade DevOps project!',
    features: [
      'Docker & Docker Compose',
      'CI/CD with GitHub Actions',
      'Unit Testing & Code Quality',
      'API Documentation (Swagger)',
      'Prometheus Monitoring',
      'Kubernetes Ready',
      'Terraform IaC',
      'Security Hardening'
    ]
  });
});

/**
 * @swagger
 * /:
 *   get:
 *     summary: Home page
 *     tags:
 *       - Home
 *     responses:
 *       200:
 *         description: Welcome page
 *         content:
 *           text/html:
 *             schema:
 *               type: string
 */
app.get('/', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html>
    <head>
      <title>DevOps Demo App - Enterprise Version</title>
      <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
          font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          min-height: 100vh;
          display: flex;
          align-items: center;
          justify-content: center;
        }
        .container { 
          max-width: 900px; 
          width: 90%;
          background: white;
          border-radius: 10px;
          box-shadow: 0 20px 60px rgba(0,0,0,0.3);
          padding: 40px;
        }
        h1 { 
          color: #333; 
          margin-bottom: 10px;
          font-size: 28px;
        }
        .subtitle {
          color: #666;
          margin-bottom: 30px;
          font-size: 14px;
        }
        .feature-grid {
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
          gap: 20px;
          margin: 30px 0;
        }
        .feature-card {
          background: #f8f9fa;
          border-left: 4px solid #667eea;
          padding: 20px;
          border-radius: 5px;
        }
        .feature-card h3 {
          color: #667eea;
          margin-bottom: 10px;
          font-size: 16px;
        }
        .feature-card p {
          color: #666;
          font-size: 13px;
          line-height: 1.6;
        }
        .endpoints {
          background: #f0f4ff;
          padding: 20px;
          border-radius: 5px;
          margin-top: 30px;
        }
        .endpoints h3 {
          color: #333;
          margin-bottom: 15px;
        }
        .endpoint {
          margin: 10px 0;
          padding: 10px;
          background: white;
          border-radius: 3px;
          font-family: 'Courier New', monospace;
          font-size: 12px;
        }
        .endpoint a {
          color: #667eea;
          text-decoration: none;
        }
        .endpoint a:hover {
          text-decoration: underline;
        }
        .badge {
          display: inline-block;
          background: #667eea;
          color: white;
          padding: 5px 10px;
          border-radius: 20px;
          font-size: 11px;
          margin-right: 10px;
          margin-bottom: 10px;
        }
        .environment {
          text-align: center;
          margin-top: 30px;
          padding-top: 20px;
          border-top: 1px solid #eee;
          color: #999;
          font-size: 12px;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <h1>🚀 DevOps Demo Application</h1>
        <p class="subtitle">Enterprise-Grade Infrastructure with Full DevOps Stack</p>
        
        <div>
          <span class="badge">Docker</span>
          <span class="badge">Kubernetes</span>
          <span class="badge">CI/CD</span>
          <span class="badge">Monitoring</span>
          <span class="badge">Security</span>
          <span class="badge">Testing</span>
        </div>

        <div class="feature-grid">
          <div class="feature-card">
            <h3>🐳 Containerization</h3>
            <p>Multi-stage Docker builds, Docker Compose, Kubernetes ready</p>
          </div>
          <div class="feature-card">
            <h3>🔄 CI/CD Pipeline</h3>
            <p>GitHub Actions automation with staging/production deployments</p>
          </div>
          <div class="feature-card">
            <h3>📊 Monitoring</h3>
            <p>Prometheus metrics, health checks, performance tracking</p>
          </div>
          <div class="feature-card">
            <h3>🔒 Security</h3>
            <p>Helmet.js, CORS, JWT auth, encrypted passwords</p>
          </div>
          <div class="feature-card">
            <h3>✅ Testing</h3>
            <p>Jest unit tests, code coverage, quality gates</p>
          </div>
          <div class="feature-card">
            <h3>📚 Documentation</h3>
            <p>Swagger API docs, architecture guides, setup instructions</p>
          </div>
        </div>

        <div class="endpoints">
          <h3>Available Endpoints</h3>
          <div class="endpoint">📍 <a href="/">GET /</a> - Home page</div>
          <div class="endpoint">💚 <a href="/health">GET /health</a> - Health check</div>
          <div class="endpoint">ℹ️ <a href="/api/info">GET /api/info</a> - API information</div>
          <div class="endpoint">📈 <a href="/metrics">GET /metrics</a> - Prometheus metrics</div>
          <div class="endpoint">📖 <a href="/api/docs">GET /api/docs</a> - Swagger documentation</div>
        </div>

        <div class="environment">
          Environment: <strong>${ENV}</strong> | Version: <strong>1.0.0</strong>
        </div>
      </div>
    </body>
    </html>
  `);
});

// 404 Handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    path: req.path,
    method: req.method
  });
});

// Error Handler
app.use((err, req, res, next) => {
  console.error(err);
  res.status(err.status || 500).json({
    error: err.message || 'Internal Server Error',
    status: err.status || 500
  });
});

app.listen(PORT, () => {
  console.log(`\n🚀 Server running on port ${PORT} in ${ENV} mode`);
  console.log(`📊 Metrics: http://localhost:${PORT}/metrics`);
  console.log(`📖 API Docs: http://localhost:${PORT}/api/docs`);
  console.log(`💚 Health: http://localhost:${PORT}/health\n`);
});

module.exports = app;
