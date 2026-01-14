const mongoose = require('mongoose');
const User = require('./models/User');

const MONGO_URI = "mongodb://localhost:27017/skillLink_dv";

const findAdmin = async () => {
    try {
        await mongoose.connect(MONGO_URI);
        console.log('Connected to MongoDB');

        const admins = await User.find({ role: 'admin' });
        
        if (admins.length > 0) {
            console.log('--- FOUND ADMIN USERS ---');
            admins.forEach(admin => {
                console.log(`Email: ${admin.email}`);
                // We cannot show password as it is hashed
            });
        } else {
            console.log('No users with role "admin" found.');
        }

        process.exit(0);
    } catch (error) {
        console.error('Error:', error);
        process.exit(1);
    }
};

findAdmin();
