const express = require('express');
const app = express();

const PORT = process.env.PORT || 3000;
const ENV = process.env.NODE_ENV || 'development';

app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// API endpoint
app.get('/api/info', (req, res) => {
  res.json({
    app: 'DevOps Demo Application',
    version: '1.0.0',
    environment: ENV,
    message: 'Welcome to the DevOps project!'
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.html = true;
  res.send(`
    <!DOCTYPE html>
    <html>
    <head>
      <title>DevOps Demo App</title>
      <style>
        body { font-family: Arial, sans-serif; margin: 50px; }
        .container { max-width: 800px; margin: 0 auto; }
      </style>
    </head>
    <body>
      <div class="container">
        <h1>🚀 DevOps Demo Application</h1>
        <p>Welcome to the DevOps project!</p>
        <h2>Available Endpoints:</h2>
        <ul>
          <li><strong>/</strong> - This page</li>
          <li><strong>/health</strong> - Health check</li>
          <li><strong>/api/info</strong> - API information</li>
        </ul>
        <p>Environment: ${ENV}</p>
      </div>
    </body>
    </html>
  `);
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT} in ${ENV} mode`);
  console.log(`Health check: http://localhost:${PORT}/health`);
});
