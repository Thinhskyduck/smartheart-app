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
    guardianPhone: {
        type: String
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
    },
    usagePurpose: {
        type: String,
        enum: ['diagnosed', 'monitoring']
    },
    heartFailureStage: {
        type: String,
        enum: ['stage1', 'stage2']
    },
    // --- THÊM CÁC TRƯỜNG NÀY ĐỂ ĐỒNG BỘ AI ---
    currentHealthStatus: { type: String, enum: ['stable', 'warning', 'danger'], default: 'stable' },
    lastAiAlert: { type: String, default: '' },       // Nội dung cảnh báo (VD: Nhịp tim cao)
    criticalMetric: { type: String, default: '' },    // Chỉ số gây báo động (VD: HR)
    criticalValue: { type: String, default: '' },     // Giá trị cụ thể (VD: 120 bpm)
    lastHealthUpdate: { type: Date, default: Date.now }
});

module.exports = mongoose.model('User', UserSchema);
