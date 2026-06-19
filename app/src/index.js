const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const { v4: uuidv4 } = require('uuid');
const jwt = require('jsonwebtoken');
const _ = require('lodash');
const axios = require('axios');

const app = express();
const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || 'devsecops-demo-secret-key';

// Middleware
app.use(cors());
app.use(helmet());
app.use(morgan('combined'));
app.use(express.json());

// In-memory storage (for demo purposes)
const tasks = new Map();
const users = new Map();

// ============================================
// Health & Info Endpoints
// ============================================

app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: process.env.npm_package_version || '1.0.0',
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development',
  });
});

app.get('/info', (req, res) => {
  res.json({
    name: 'DevSecOps Supply Chain Security Demo',
    description: 'A simple task management API used to demonstrate SBOM generation, vulnerability scanning, and artifact signing.',
    team: 'Kelompok 8',
    members: ['Dian (A)', 'Tsll (B)', 'Acin (C)', 'Callista (D)'],
    features: [
      'Task CRUD operations',
      'JWT-based authentication',
      'Health monitoring',
      'RESTful API design',
    ],
  });
});

// ============================================
// Authentication Endpoints
// ============================================

app.post('/auth/register', (req, res) => {
  const { username, email } = req.body;

  if (!username || !email) {
    return res.status(400).json({ error: 'Username and email are required' });
  }

  if (users.has(username)) {
    return res.status(409).json({ error: 'Username already exists' });
  }

  const user = {
    id: uuidv4(),
    username,
    email,
    createdAt: new Date().toISOString(),
  };

  users.set(username, user);

  const token = jwt.sign(
    { userId: user.id, username: user.username },
    JWT_SECRET,
    { expiresIn: '24h' }
  );

  res.status(201).json({ user, token });
});

app.post('/auth/login', (req, res) => {
  const { username } = req.body;

  if (!username) {
    return res.status(400).json({ error: 'Username is required' });
  }

  const user = users.get(username);
  if (!user) {
    return res.status(404).json({ error: 'User not found' });
  }

  const token = jwt.sign(
    { userId: user.id, username: user.username },
    JWT_SECRET,
    { expiresIn: '24h' }
  );

  res.json({ user, token });
});

// ============================================
// Auth Middleware
// ============================================

const authenticate = (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Authorization token required' });
  }

  try {
    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({ error: 'Invalid or expired token' });
  }
};

// ============================================
// Task CRUD Endpoints (Protected)
// ============================================

// Create a task
app.post('/tasks', authenticate, (req, res) => {
  const { title, description, priority } = req.body;

  if (!title) {
    return res.status(400).json({ error: 'Title is required' });
  }

  const task = {
    id: uuidv4(),
    title: _.trim(title),
    description: description ? _.trim(description) : '',
    priority: priority || 'medium',
    status: 'todo',
    createdBy: req.user.username,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };

  tasks.set(task.id, task);
  res.status(201).json(task);
});

// Get all tasks
app.get('/tasks', authenticate, (req, res) => {
  const { status, priority, sortBy } = req.query;
  let taskList = Array.from(tasks.values());

  // Filter by status
  if (status) {
    taskList = _.filter(taskList, { status });
  }

  // Filter by priority
  if (priority) {
    taskList = _.filter(taskList, { priority });
  }

  // Sort
  if (sortBy) {
    taskList = _.sortBy(taskList, [sortBy]);
  }

  res.json({
    total: taskList.length,
    tasks: taskList,
  });
});

// Get a specific task
app.get('/tasks/:id', authenticate, (req, res) => {
  const task = tasks.get(req.params.id);

  if (!task) {
    return res.status(404).json({ error: 'Task not found' });
  }

  res.json(task);
});

// Update a task
app.put('/tasks/:id', authenticate, (req, res) => {
  const task = tasks.get(req.params.id);

  if (!task) {
    return res.status(404).json({ error: 'Task not found' });
  }

  const { title, description, priority, status } = req.body;

  const updatedTask = _.merge({}, task, {
    ...(title && { title: _.trim(title) }),
    ...(description !== undefined && { description: _.trim(description) }),
    ...(priority && { priority }),
    ...(status && { status }),
    updatedAt: new Date().toISOString(),
  });

  tasks.set(req.params.id, updatedTask);
  res.json(updatedTask);
});

// Delete a task
app.delete('/tasks/:id', authenticate, (req, res) => {
  if (!tasks.has(req.params.id)) {
    return res.status(404).json({ error: 'Task not found' });
  }

  tasks.delete(req.params.id);
  res.status(204).send();
});

// ============================================
// Statistics Endpoint
// ============================================

app.get('/stats', authenticate, (req, res) => {
  const taskList = Array.from(tasks.values());

  const stats = {
    total: taskList.length,
    byStatus: _.countBy(taskList, 'status'),
    byPriority: _.countBy(taskList, 'priority'),
    recentTasks: _.chain(taskList)
      .sortBy('createdAt')
      .reverse()
      .take(5)
      .value(),
  };

  res.json(stats);
});

// ============================================
// External API Integration (demo dependency usage)
// ============================================

app.get('/external/status', async (req, res) => {
  try {
    const response = await axios.get('https://httpbin.org/status/200', {
      timeout: 5000,
    });
    res.json({
      externalService: 'reachable',
      statusCode: response.status,
    });
  } catch (error) {
    res.json({
      externalService: 'unreachable',
      error: error.message,
    });
  }
});

// ============================================
// Error Handling
// ============================================

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: `Route ${req.method} ${req.path} not found`,
  });
});

// Global error handler
app.use((err, req, res, _next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({
    error: 'Internal Server Error',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong',
  });
});

// ============================================
// Server Start
// ============================================

app.listen(PORT, () => {
  console.log(`
╔══════════════════════════════════════════════════════════╗
║  DevSecOps Supply Chain Security Demo API               ║
║  Running on port ${PORT}                                    ║
║  Environment: ${(process.env.NODE_ENV || 'development').padEnd(10)}                          ║
║  Health check: http://localhost:${PORT}/health               ║
╚══════════════════════════════════════════════════════════╝
  `);
});

module.exports = app;
