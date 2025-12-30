const mongoose = require('mongoose');
const User = require('./models/User');

const MONGO_URI = "mongodb://localhost:27017/skillLink_dv";

const fixPasswords = async () => {
    try {
        await mongoose.connect(MONGO_URI);
        console.log('Connected to MongoDB');

        const emails = ['worker1@skilllink.com', 'hirer1@skilllink.com'];
        const plaintextPassword = 'password123';

        for (const email of emails) {
            const user = await User.findOne({ email });
            if (user) {
                // We set the password to the plaintext version.
                // The User model's pre-save middleware will detect the modification
                // and hash it automatically.
                user.password = plaintextPassword;
                await user.save();
                console.log(`Reset password for ${email} to '${plaintextPassword}' (will be hashed by model)`);
            } else {
                console.log(`User not found: ${email}`);
            }
        }

        console.log('Password correction complete.');
        process.exit(0);

    } catch (error) {
        console.error('Password correction failed:', error);
        process.exit(1);
    }
};

fixPasswords();
