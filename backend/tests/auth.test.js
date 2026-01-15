
const request = require("supertest");
const mongoose = require("mongoose");
const jwt = require("jsonwebtoken");
const app = require("../index");
const User = require("../models/User");

let workerTokenAuthDB;
let categoryIdAuthDB;

describe("Auth, Category, and Basic Worker API Tests", () => {
    beforeAll(async () => {
        process.env.MONGO_URI = "mongodb://localhost:27017/SkillLink_test_auth";
        process.env.JWT_SECRET = "testsecretkey123";

        if (mongoose.connection.readyState === 1 && mongoose.connection.name !== 'SkillLink_test_auth') {
            await mongoose.disconnect();
        }
        if (mongoose.connection.readyState === 0 || mongoose.connection.name !== 'SkillLink_test_auth') {
            await mongoose.connect(process.env.MONGO_URI);
        }

        await mongoose.connection.dropDatabase();

        const workerRegisterRes = await request(app).post("/api/auth/register").send({
            fullName: "Test worker Auth DB",
            email: "worker@auth.com",
            phoneNumber: "9800000000",
            stakeholder: "worker",
            password: "password123",
            confirmPassword: "password123",
        });

        const workerLoginRes = await request(app).post("/api/auth/login").send({
            email: "worker@auth.com",
            password: "password123",
        });
        workerTokenAuthDB = workerLoginRes.body.token;
    });

    afterAll(async () => {
        await mongoose.disconnect();
    });

    describe("User Authentication API", () => {
        test("should validate missing fields while creating user", async () => {
            const res = await request(app).post("/api/auth/register").send({
                fullName: "Ram Bahadur",
                email: "ramtemp@gmail.com",
                phoneNumber: "9800000000",
                stakeholder: "Hirer",
            });
            expect(res.statusCode).toBe(400);
            expect(res.body.success).toBe(false);
        });

        test("should create a user with all fields", async () => {
            const res = await request(app).post("/api/auth/register").send({
                fullName: "Ram Singh",
                email: "ramsingh@auth.com",
                phoneNumber: "9800000001",
                stakeholder: "Hirer",
                password: "password123",
                confirmPassword: "password123",
            });
            expect(res.statusCode).toBe(201);
            expect(res.body.success).toBe(true);
        });

        test("should login a user with valid credentials (worker)", async () => {
            const res = await request(app).post("/api/auth/login").send({
                email: "worker@auth.com",
                password: "password123",
            });
            expect(res.statusCode).toBe(200);
            expect(res.body.success).toBe(true);
            expect(typeof res.body.token).toBe("string");
        });
    });

    // Password Reset Flow - Skipped to avoid external dependency issues in test environment
    // describe("Password Reset Flow", () => { ... });

    describe("Category API", () => {
        test("should create a new category", async () => {
            const res = await request(app)
                .post("/api/category")
                .set("Authorization", `Bearer ${workerTokenAuthDB}`)
                .send({ name: "Category For Auth Test" });
            expect(res.statusCode).toBe(201);
            categoryIdAuthDB = res.body.data._id;
        });

        test("should fetch all categories", async () => {
            const res = await request(app).get("/api/category");
            expect(res.statusCode).toBe(200);
            expect(Array.isArray(res.body.data)).toBe(true);
        });
    });
});
