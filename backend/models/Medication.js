const mongoose = require('mongoose');

const MedicationSchema = new mongoose.Schema({
    user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    name: {
        type: String,
        required: true
    },
    dosage: {
        type: String,
        required: true
    },
    time: {
        type: String,
        required: true
    },
    quantity: {
        type: Number,
        required: true
    },
    session: {
        type: String, // 'morning', 'evening'
        enum: ['morning', 'noon', 'afternoon', 'evening'],
        required: true
    },
    isTaken: {
        type: Boolean,
        default: false
    },
    lastTakenDate: {
        type: Date
    }
});

module.exports = mongoose.model('Medication', MedicationSchema);
