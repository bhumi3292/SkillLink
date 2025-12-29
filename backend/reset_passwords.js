const mongoose = require('mongoose');
const User = require('./models/User');

const MONGO_URI = "mongodb://localhost:27017/skillLink_dv";

const resetPasswords = async () => {
    try {
        await mongoose.connect(MONGO_URI);
        console.log('Connected to MongoDB');

        const usersToReset = [];
        for (let i = 1; i <= 5; i++) {
            usersToReset.push(`worker${i}@skilllink.com`);
            usersToReset.push(`hirer${i}@skilllink.com`);
        }

        // Also add the explicit one from logs just in case
        usersToReset.push("hirer1@skilllink.com");

        console.log(`Resetting passwords for ${usersToReset.length} users to 'password123'...`);

        for (const email of usersToReset) {
            const user = await User.findOne({ email });
            if (user) {
                user.password = 'password123'; // Pre-save hook will hash this
                await user.save();
                console.log(`Password reset for: ${email}`);
            } else {
                console.log(`User not found: ${email}`);
            }
        }

        console.log('Password Reset Completed!');
        process.exit(0);

    } catch (error) {
        console.error('Reset Failed:', error);
        process.exit(1);
    }
};

resetPasswords();
