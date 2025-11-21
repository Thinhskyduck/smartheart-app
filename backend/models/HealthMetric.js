const mongoose = require('mongoose');

const HealthMetricSchema = new mongoose.Schema({
    user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    type: {
        type: String, // weight, bp, hr, hrv, spo2, sleep
        required: true
    },
    value: {
        type: String, // Storing as string to handle "120/80" for BP
        required: true
    },
    unit: {
        type: String,
        default: ''
    },
    timestamp: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model('HealthMetric', HealthMetricSchema);
