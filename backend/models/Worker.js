const mongoose = require('mongoose');
const Property = require('./Property');

// Create (or reuse) a `Worker` model that uses the same schema as `Property`
// but stores documents in the `workers` collection. This allows Worker CRUD
// to operate against a dedicated `workers` collection while reusing the
// existing property schema.
module.exports = mongoose.models.Worker || mongoose.model('Worker', Property.schema, 'workers');
