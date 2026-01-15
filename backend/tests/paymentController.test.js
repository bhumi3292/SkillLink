
const request = require('supertest');
const mongoose = require('mongoose');
const app = require('../index');
const User = require('../models/User');

let hirerToken, userId;

describe('Payment API Tests', () => {
  beforeAll(async () => {
    process.env.MONGO_URI = 'mongodb://localhost:27017/SkillLink_test_payment';
    process.env.JWT_SECRET = "testsecretkey123";

    if (mongoose.connection.readyState === 0 || mongoose.connection.name !== 'SkillLink_test_payment') {
      if (mongoose.connection.readyState === 1) await mongoose.disconnect();
      await mongoose.connect(process.env.MONGO_URI);
    }
    await mongoose.connection.dropDatabase();

    await request(app).post("/api/auth/register").send({
      fullName: "Payment User",
      email: "pay@user.com",
      phoneNumber: "9800000005",
      stakeholder: "hirer",
      password: "password123",
      confirmPassword: "password123",
    });
    const login = await request(app).post("/api/auth/login").send({
      email: "pay@user.com",
      password: "password123",
    });
    hirerToken = login.body.token;
    const user = await User.findOne({ email: "pay@user.com" });
    userId = user._id; // Implicit global variable usage, need to define it first or just attach to test context
  });

  afterAll(async () => {
    await mongoose.disconnect();
  });

  test('should get payment history', async () => {
    const res = await request(app).get(`/api/payments/history/${userId}`)
      .set('Authorization', `Bearer ${hirerToken}`);

    expect([200, 404]).toContain(res.statusCode);
  });
});