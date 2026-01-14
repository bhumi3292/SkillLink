const mongoose = require('mongoose');
const User = require('./models/User');

const MONGO_URI = "mongodb://localhost:27017/skillLink_dv";

const resetAdminPassword = async () => {
    try {
        await mongoose.connect(MONGO_URI);
        console.log('Connected to MongoDB');

        const email = 'bhumisubedi2018@gmail.com';
        const newPassword = 'password123';

        const user = await User.findOne({ email });

        if (user) {
            user.password = newPassword;
            await user.save();
            console.log(`Password for Admin ${email} has been reset to '${newPassword}'`);
        } else {
            console.log(`Admin user ${email} not found.`);
        }

        process.exit(0);
    } catch (error) {
        console.error('Error:', error);
        process.exit(1);
    }
};

resetAdminPassword();
