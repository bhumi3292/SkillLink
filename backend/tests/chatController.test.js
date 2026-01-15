
const request = require('supertest');
const mongoose = require('mongoose');
const app = require('../index');
const User = require('../models/User');

let user1Token;

describe('Chat API Tests', () => {
  beforeAll(async () => {
    process.env.MONGO_URI = 'mongodb://localhost:27017/SkillLink_test_chat_v2';
    process.env.JWT_SECRET = "testsecretkey123";

    if (mongoose.connection.readyState === 0 || mongoose.connection.name !== 'SkillLink_test_chat_v2') {
      if (mongoose.connection.readyState === 1) await mongoose.disconnect();
      await mongoose.connect(process.env.MONGO_URI);
    }
    await mongoose.connection.dropDatabase();

    await request(app).post("/api/auth/register").send({
      fullName: "Chat User 1",
      email: "chat1@test.com",
      phoneNumber: "9800000008",
      stakeholder: "Hirer",
      password: "password123",
      confirmPassword: "password123",
    });
    const login = await request(app).post("/api/auth/login").send({
      email: "chat1@test.com",
      password: "password123",
    });
    user1Token = login.body.token;
  });

  afterAll(async () => {
    await mongoose.disconnect();
  });

  test('should fetch user chats (empty list)', async () => {
    const res = await request(app).get('/api/chats')
      .set('Authorization', `Bearer ${user1Token}`);

    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body.data)).toBe(true);
  });

  // We can add create chat test if we have a second user, but fetching empty list confirms auth works and route exists.
});