process.env.NODE_ENV = 'test';
process.env.MONGO_URI = 'mongodb://localhost:27017/SkillLink_test_calendar';
process.env.JWT_SECRET = 'test-secret-key';

const request = require('supertest');
const mongoose = require('mongoose');
const app = require('../index');
const User = require('../models/User');
const Property = require('../models/Property');
const Category = require('../models/Category');
const Calendar = require('../models/calendar');

let workerToken, propertyId, categoryId;

describe('Calendar API', () => {
  beforeAll(async () => {
    if (mongoose.connection.readyState === 0) {
      await mongoose.connect(process.env.MONGO_URI, {
        useNewUrlParser: true,
        useUnifiedTopology: true,
      });
    }
    await User.deleteMany({ email: 'worker@calendar.com' });
    await Property.deleteMany({ title: 'Test Property for Calendar' });
    await Category.deleteMany({ category_name: 'Test Category for Calendar' });
    await Calendar.deleteMany({ propertyId: { $exists: true } });
    const category = await Category.create({ category_name: 'Test Category for Calendar' });
    categoryId = category._id;
    const worker = await User.create({
      fullName: 'Test worker',
      email: 'worker@calendar.com',
      phoneNumber: '9000000013',
      role: 'worker',
      password: 'password123',
    });
    const jwt = require('jsonwebtoken');
    workerToken = jwt.sign({ _id: worker._id }, process.env.JWT_SECRET, { expiresIn: '1h' });
    const property = await Property.create({
      title: 'Test Property for Calendar',
      description: 'A test property for calendar testing',
      location: 'Test Location',
      price: 50000,
      bedrooms: 2,
      bathrooms: 1,
      categoryId: categoryId,
      images: ['test-image.jpg'],
      worker: worker._id,
    });
    propertyId = property._id;
  });

  afterAll(async () => {
    await User.deleteMany({ email: 'worker@calendar.com' });
    await Property.deleteMany({ title: 'Test Property for Calendar' });
    await Category.deleteMany({ category_name: 'Test Category for Calendar' });
    await Calendar.deleteMany({ propertyId: { $exists: true } });
    await mongoose.connection.close();
  });

  test('should require authentication for calendar operations', async () => {
    const res = await request(app).post('/api/calendar');
    expect(res.statusCode).toBe(401);
  });

  test('should require authentication for calendar updates', async () => {
    const res = await request(app).put('/api/calendar/test-id');
    expect(res.statusCode).toBe(401);
  });

  test('should require authentication for calendar deletion', async () => {
    const res = await request(app).delete('/api/calendar/test-id');
    expect(res.statusCode).toBe(401);
  });

  test('should require authentication for calendar range queries', async () => {
    const res = await request(app).get('/api/calendar/test-id/range');
    expect(res.statusCode).toBe(401);
  });

  test('should validate calendar endpoints require authentication', async () => {
    const res = await request(app).get('/api/calendar/test-id');
    expect(res.statusCode).toBe(401);
  });
}); 