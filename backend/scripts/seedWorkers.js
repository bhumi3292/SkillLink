const connectDB = require('../config/db');
const mongoose = require('mongoose');
const Category = require('../models/Category');
const User = require('../models/User');
const Property = require('../models/Property');

async function seed() {
  try {
    // Connect using default dev URI from config
    const conn = await connectDB();

    console.log('Connected to DB for seeding.');

    // Create or get a Category
    const categoryName = 'Electrician';
    const category = await Category.findOneAndUpdate(
      { category_name: categoryName },
      { category_name: categoryName },
      { new: true, upsert: true }
    );
    console.log('Category ready:', category._id.toString());

    // Create a worker User (if not exists)
    const email = 'worker@example.com';
    let user = await User.findOne({ email });
    if (!user) {
      user = await User.create({
        fullName: 'Seed Worker',
        email,
        phoneNumber: '0000000000',
        role: 'worker',
        password: 'Password123' // will be hashed by model
      });
      console.log('Created user:', user._id.toString());
    } else {
      console.log('User exists:', user._id.toString());
    }

    // Create a sample worker/property document
    const sample = {
      images: ['seed_image_1.jpg'],
      videos: [],
      title: 'Sample Electrician Service',
      location: 'Sample City',
      bedrooms: undefined,
      bathrooms: undefined,
      categoryId: category._id,
      price: 500,
      description: 'Experienced electrician for home repairs.',
      worker: user._id
    };

    const created = await Property.create(sample);
    console.log('Created worker/property:', created._id.toString());

    console.log('Seeding complete.');
    await mongoose.disconnect();
    process.exit(0);
  } catch (err) {
    console.error('Seeding error:', err);
    try { await mongoose.disconnect(); } catch (e) {}
    process.exit(1);
  }
}

seed();
