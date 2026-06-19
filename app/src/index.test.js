const request = require('supertest');
const app = require('./index');

describe('Health Check', () => {
  it('GET /health should return healthy status', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe('healthy');
    expect(res.body).toHaveProperty('timestamp');
    expect(res.body).toHaveProperty('uptime');
    expect(res.body).toHaveProperty('version');
  });
});

describe('Info Endpoint', () => {
  it('GET /info should return app information', async () => {
    const res = await request(app).get('/info');
    expect(res.statusCode).toBe(200);
    expect(res.body.name).toBe('DevSecOps Supply Chain Security Demo');
    expect(res.body.team).toBe('Kelompok 8');
    expect(res.body.members).toHaveLength(4);
  });
});

describe('Authentication', () => {
  let token;

  it('POST /auth/register should create a new user', async () => {
    const res = await request(app)
      .post('/auth/register')
      .send({ username: 'testuser', email: 'test@example.com' });
    expect(res.statusCode).toBe(201);
    expect(res.body).toHaveProperty('token');
    expect(res.body.user.username).toBe('testuser');
    token = res.body.token;
  });

  it('POST /auth/register should reject duplicate username', async () => {
    const res = await request(app)
      .post('/auth/register')
      .send({ username: 'testuser', email: 'test2@example.com' });
    expect(res.statusCode).toBe(409);
  });

  it('POST /auth/register should require username and email', async () => {
    const res = await request(app)
      .post('/auth/register')
      .send({});
    expect(res.statusCode).toBe(400);
  });

  it('POST /auth/login should return token for existing user', async () => {
    const res = await request(app)
      .post('/auth/login')
      .send({ username: 'testuser' });
    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty('token');
  });

  it('POST /auth/login should reject unknown user', async () => {
    const res = await request(app)
      .post('/auth/login')
      .send({ username: 'nonexistent' });
    expect(res.statusCode).toBe(404);
  });
});

describe('Task CRUD', () => {
  let token;
  let taskId;

  beforeAll(async () => {
    const res = await request(app)
      .post('/auth/register')
      .send({ username: 'taskuser', email: 'taskuser@example.com' });
    token = res.body.token;
  });

  it('POST /tasks should create a new task', async () => {
    const res = await request(app)
      .post('/tasks')
      .set('Authorization', `Bearer ${token}`)
      .send({
        title: 'Test Task',
        description: 'A test task for unit testing',
        priority: 'high',
      });
    expect(res.statusCode).toBe(201);
    expect(res.body.title).toBe('Test Task');
    expect(res.body.status).toBe('todo');
    expect(res.body.priority).toBe('high');
    taskId = res.body.id;
  });

  it('POST /tasks should require title', async () => {
    const res = await request(app)
      .post('/tasks')
      .set('Authorization', `Bearer ${token}`)
      .send({ description: 'No title' });
    expect(res.statusCode).toBe(400);
  });

  it('POST /tasks should require auth', async () => {
    const res = await request(app)
      .post('/tasks')
      .send({ title: 'Unauthorized Task' });
    expect(res.statusCode).toBe(401);
  });

  it('GET /tasks should return all tasks', async () => {
    const res = await request(app)
      .get('/tasks')
      .set('Authorization', `Bearer ${token}`);
    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty('total');
    expect(res.body).toHaveProperty('tasks');
    expect(Array.isArray(res.body.tasks)).toBe(true);
  });

  it('GET /tasks/:id should return a specific task', async () => {
    const res = await request(app)
      .get(`/tasks/${taskId}`)
      .set('Authorization', `Bearer ${token}`);
    expect(res.statusCode).toBe(200);
    expect(res.body.id).toBe(taskId);
  });

  it('GET /tasks/:id should return 404 for non-existent task', async () => {
    const res = await request(app)
      .get('/tasks/non-existent-id')
      .set('Authorization', `Bearer ${token}`);
    expect(res.statusCode).toBe(404);
  });

  it('PUT /tasks/:id should update a task', async () => {
    const res = await request(app)
      .put(`/tasks/${taskId}`)
      .set('Authorization', `Bearer ${token}`)
      .send({ status: 'in-progress', priority: 'low' });
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe('in-progress');
    expect(res.body.priority).toBe('low');
  });

  it('DELETE /tasks/:id should delete a task', async () => {
    const res = await request(app)
      .delete(`/tasks/${taskId}`)
      .set('Authorization', `Bearer ${token}`);
    expect(res.statusCode).toBe(204);
  });

  it('DELETE /tasks/:id should return 404 for non-existent task', async () => {
    const res = await request(app)
      .delete(`/tasks/${taskId}`)
      .set('Authorization', `Bearer ${token}`);
    expect(res.statusCode).toBe(404);
  });
});

describe('Statistics', () => {
  let token;

  beforeAll(async () => {
    const res = await request(app)
      .post('/auth/register')
      .send({ username: 'statsuser', email: 'stats@example.com' });
    token = res.body.token;

    // Create some tasks for stats
    await request(app)
      .post('/tasks')
      .set('Authorization', `Bearer ${token}`)
      .send({ title: 'Task 1', priority: 'high' });
    await request(app)
      .post('/tasks')
      .set('Authorization', `Bearer ${token}`)
      .send({ title: 'Task 2', priority: 'low' });
  });

  it('GET /stats should return task statistics', async () => {
    const res = await request(app)
      .get('/stats')
      .set('Authorization', `Bearer ${token}`);
    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty('total');
    expect(res.body).toHaveProperty('byStatus');
    expect(res.body).toHaveProperty('byPriority');
    expect(res.body).toHaveProperty('recentTasks');
  });
});

describe('404 Handler', () => {
  it('should return 404 for unknown routes', async () => {
    const res = await request(app).get('/unknown-route');
    expect(res.statusCode).toBe(404);
    expect(res.body.error).toBe('Not Found');
  });
});
