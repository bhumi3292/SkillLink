
const request = require('supertest');
const mongoose = require('mongoose');
const app = require('../index');
const User = require('../models/User');

let adminToken;

describe('Admin API Tests', () => {
    beforeAll(async () => {
        process.env.MONGO_URI = 'mongodb://localhost:27017/SkillLink_test_admin';
        process.env.JWT_SECRET = "testsecretkey123";

        if (mongoose.connection.readyState === 0 || mongoose.connection.name !== 'SkillLink_test_admin') {
            if (mongoose.connection.readyState === 1) await mongoose.disconnect();
            await mongoose.connect(process.env.MONGO_URI);
        }
        await mongoose.connection.dropDatabase();

        // Register
        await request(app).post("/api/auth/register").send({
            fullName: "Admin User",
            email: "admin@skilllink.com",
            phoneNumber: "9800000000",
            stakeholder: "Hirer", // Register as Hirer first
            password: "adminpassword",
            confirmPassword: "adminpassword",
        });

        // Force update role to admin
        const user = await User.findOne({ email: "admin@skilllink.com" });
        if (user) {
            user.role = 'admin';
            await user.save();
        }

        // Login
        const login = await request(app).post("/api/auth/login").send({
            email: "admin@skilllink.com",
            password: "adminpassword",
        });
        adminToken = login.body.token;
    });

    afterAll(async () => {
        await mongoose.disconnect();
    });

    test('should fetch dashboard stats', async () => {
        const res = await request(app).get('/api/admin/dashboard-stats')
            .set('Authorization', `Bearer ${adminToken}`);

        expect(res.statusCode).toBe(200);
        expect(res.body.data).toBeDefined();
    });

    test('should fetch pending workers', async () => {
        const res = await request(app).get('/api/admin/workers/pending')
            .set('Authorization', `Bearer ${adminToken}`);

        expect(res.statusCode).toBe(200);
        expect(Array.isArray(res.body.data)).toBe(true);
    });
});
