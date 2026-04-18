/**
 * API REST - Proyecto Semana 02
 * Bootcamp Docker Zero to Hero
 */

const express = require('express');

const app = express();
const PORT = process.env.PORT || 3000;
const APP_NAME = process.env.APP_NAME || 'API Optimizada';
const APP_VERSION = process.env.APP_VERSION || '1.0.0';
const NODE_ENV = process.env.NODE_ENV || 'development';

// Middleware para JSON
app.use(express.json());

// Endpoint raíz
app.get('/', (req, res) => {
  res.json({
    message: '¡Bienvenido a la API REST Optimizada!',
    endpoints: {
      health: '/health',
      info: '/info',
      echo: '/echo (POST)',
    },
  });
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
  });
});

// Info endpoint
app.get('/info', (req, res) => {
  res.json({
    name: APP_NAME,
    version: APP_VERSION,
    environment: NODE_ENV,
    nodeVersion: process.version,
    uptime: process.uptime(),
    memoryUsage: process.memoryUsage(),
    timestamp: new Date().toISOString(),
  });
});

// Echo endpoint (POST)
app.post('/echo', (req, res) => {
  res.json({
    received: req.body,
    timestamp: new Date().toISOString(),
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    path: req.path,
  });
});

// Iniciar servidor
app.listen(PORT, '0.0.0.0', () => {
  console.log('━'.repeat(50));
  console.log(`🚀 ${APP_NAME} v${APP_VERSION}`);
  console.log(`📡 Servidor corriendo en puerto ${PORT}`);
  console.log(`🌍 Entorno: ${NODE_ENV}`);
  console.log(`📦 Node.js: ${process.version}`);
  console.log('━'.repeat(50));
});
