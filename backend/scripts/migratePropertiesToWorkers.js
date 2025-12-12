const connectDB = require('../config/db');
const mongoose = require('mongoose');
const Property = require('../models/Property');
const Worker = require('../models/Worker');

async function migrate() {
  try {
    await connectDB();
    console.log('Connected to DB for migration.');

    const properties = await Property.find({}).lean();
    console.log(`Found ${properties.length} properties to inspect.`);

    let copied = 0;
    for (const prop of properties) {
      const exists = await Worker.exists({ _id: prop._id });
      if (exists) continue;

      // Remove mongoose-specific fields from object we will pass to Worker.create
      const obj = { ...prop };
      delete obj.__v; // optional

      // create using same _id so references remain valid
      await Worker.create(obj);
      copied++;
    }

    console.log(`Migration complete. Copied ${copied} documents to workers collection.`);
    await mongoose.disconnect();
    process.exit(0);
  } catch (err) {
    console.error('Migration error:', err);
    try { await mongoose.disconnect(); } catch(e) {}
    process.exit(1);
  }
}

migrate();
