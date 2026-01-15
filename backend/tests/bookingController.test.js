
const request = require('supertest');
const mongoose = require('mongoose');
const app = require('../index');
const User = require('../models/User');
const Worker = require('../models/Worker');
const Category = require('../models/Category');
const Booking = require('../models/Booking');

let hirerToken, workerToken, workerId, bookingId;

describe('Booking API Tests', () => {
  beforeAll(async () => {
    process.env.MONGO_URI = 'mongodb://localhost:27017/SkillLink_test_booking_v2';
    process.env.JWT_SECRET = "testsecretkey123";

    if (mongoose.connection.readyState === 0 || mongoose.connection.name !== 'SkillLink_test_booking_v2') {
      if (mongoose.connection.readyState === 1) await mongoose.disconnect();
      await mongoose.connect(process.env.MONGO_URI);
    }
    await mongoose.connection.dropDatabase();

    // Hirer
    await request(app).post("/api/auth/register").send({
      fullName: "Hirer Booking",
      email: "hirer@book.com",
      phoneNumber: "9800000001",
      stakeholder: "hirer",
      password: "password123",
      confirmPassword: "password123",
    });
    const nirerLogin = await request(app).post("/api/auth/login").send({
      email: "hirer@book.com",
      password: "password123",
    });
    hirerToken = nirerLogin.body.token;

    // Worker
    await request(app).post("/api/auth/register").send({
      fullName: "Worker Booking",
      email: "worker@book.com",
      phoneNumber: "9800000002",
      stakeholder: "worker",
      password: "password123",
      confirmPassword: "password123",
    });
    const workerLogin = await request(app).post("/api/auth/login").send({
      email: "worker@book.com",
      password: "password123",
    });
    workerToken = workerLogin.body.token;

    // Category & Listing
    const cat = await Category.create({ category_name: "Booking Cat" });
    const workerUser = await User.findOne({ email: "worker@book.com" });
    const listing = await Worker.create({
      title: "Booking Service",
      description: "Service description",
      price: 500,
      minPrice: 500,
      maxPrice: 1000,
      experience: 2,
      licenseUrl: "lic.jpg",
      identityCardUrl: "id.jpg",
      images: ["img.jpg"],
      location: {
        type: 'Point',
        coordinates: [85.3240, 27.7172]
      },
      categoryId: cat._id,
      worker: workerUser._id
    });
    workerId = listing._id;
  });

  afterAll(async () => {
    await mongoose.disconnect();
  });

  test('should create a booking', async () => {
    const res = await request(app).post('/api/bookings')
      .set('Authorization', `Bearer ${hirerToken}`)
      .send({
        workerListingId: workerId,
        date: new Date().toISOString(),
        timeSlot: "10:00 AM"
      });

    expect([200, 201]).toContain(res.statusCode);
    bookingId = res.body.data._id;
  });

  test('should get bookings for hirer', async () => {
    const res = await request(app).get('/api/bookings')
      .set('Authorization', `Bearer ${hirerToken}`);

    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body.data)).toBe(true);
    expect(res.body.data.length).toBeGreaterThan(0);
  });

  // Check availability update or similar if applicable
});