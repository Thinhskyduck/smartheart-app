const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
    fullName: {
        type: String,
        required: true
    },
    email: {
        type: String,
        sparse: true, // Allow null but unique if provided
        unique: true
    },
    phoneNumber: {
        type: String,
        required: true,
        unique: true
    },
    password: {
        type: String,
        required: true
    },
    role: {
        type: String,
        enum: ['patient', 'doctor', 'guardian'],
        default: 'patient'
    },
    guardianCode: {
        type: String
    },
    guardians: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
    }],
    patients: [{ // For guardians/doctors to track patients
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
    }],
    createdAt: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model('User', UserSchema);
