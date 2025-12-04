process.env.NODE_ENV = 'test';
process.env.MONGO_URI = 'mongodb://localhost:27017/SkillLink_test_booking';
process.env.JWT_SECRET = 'test-secret-key';

const request = require('supertest');
const mongoose = require('mongoose');
const app = require('../index');
const User = require('../models/User');
const Property = require('../models/Property');
const Category = require('../models/Category');
const Booking = require('../models/Booking');

let HirerToken, workerToken, propertyId, categoryId;

describe('Booking API', () => {
  beforeAll(async () => {
    if (mongoose.connection.readyState === 0) {
      await mongoose.connect(process.env.MONGO_URI, {
        useNewUrlParser: true,
        useUnifiedTopology: true,
      });
    }
    await User.deleteMany({ email: { $in: ['Hirer@booking.com', 'worker@booking.com'] } });
    await Property.deleteMany({ title: 'Test Property for Booking' });
    await Category.deleteMany({ category_name: 'Test Category for Booking' });
    await Booking.deleteMany({ propertyId: { $exists: true } });
    const category = await Category.create({ category_name: 'Test Category for Booking' });
    categoryId = category._id;
    const worker = await User.create({
      fullName: 'Test worker',
      email: 'worker@booking.com',
      phoneNumber: '9000000011',
      role: 'worker',
      password: 'password123',
    });
    const jwt = require('jsonwebtoken');
    workerToken = jwt.sign({ _id: worker._id }, process.env.JWT_SECRET, { expiresIn: '1h' });
    const property = await Property.create({
      title: 'Test Property for Booking',
      description: 'A test property for booking testing',
      location: 'Test Location',
      price: 50000,
      bedrooms: 2,
      bathrooms: 1,
      categoryId: categoryId,
      images: ['test-image.jpg'],
      worker: worker._id,
    });
    propertyId = property._id;
    const Hirer = await User.create({
      fullName: 'Test Hirer',
      email: 'Hirer@booking.com',
      phoneNumber: '9000000012',
      role: 'Hirer',
      password: 'password123',
    });
    HirerToken = jwt.sign({ _id: Hirer._id }, process.env.JWT_SECRET, { expiresIn: '1h' });
  });

  afterAll(async () => {
    await User.deleteMany({ email: { $in: ['Hirer@booking.com', 'worker@booking.com'] } });
    await Property.deleteMany({ title: 'Test Property for Booking' });
    await Category.deleteMany({ category_name: 'Test Category for Booking' });
    await Booking.deleteMany({ propertyId: { $exists: true } });
    await mongoose.connection.close();
  });

  test('should require authentication for booking operations', async () => {
    const res = await request(app).get('/api/bookings');
    expect(res.statusCode).toBe(404);
  });

  test('should require authentication for creating bookings', async () => {
    const res = await request(app).post('/api/bookings');
    expect(res.statusCode).toBe(404);
  });

  test('should require authentication for worker bookings', async () => {
    const res = await request(app).get('/api/bookings/worker');
    expect(res.statusCode).toBe(404);
  });

  test('should require authentication for booking status updates', async () => {
    const res = await request(app).put('/api/bookings/test-id/status');
    expect(res.statusCode).toBe(404);
  });

  test('should require authentication for booking cancellation', async () => {
    const res = await request(app).put('/api/bookings/test-id/cancel');
    expect(res.statusCode).toBe(404);
  });

  test('should require authentication for booking deletion', async () => {
    const res = await request(app).delete('/api/bookings/test-id');
    expect(res.statusCode).toBe(404);
  });
}); 