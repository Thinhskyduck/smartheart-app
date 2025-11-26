const express = require('express');
const router = express.Router();
const Medication = require('../models/Medication');
const User = require('../models/User');
const HealthMetric = require('../models/HealthMetric');

// GET /api/staff/missed-medications
// Get list of patients who have not taken their medication
router.get('/missed-medications', async (req, res) => {
    try {
        const missedMeds = await Medication.find({ isTaken: false })
            .populate('user', 'fullName phoneNumber guardianPhone birthYear')
            .sort({ time: 1 });

        const patientMap = new Map();

        missedMeds.forEach(med => {
            if (!med.user) return; 

            const userId = med.user._id.toString();

            if (!patientMap.has(userId)) {
                patientMap.set(userId, {
                    user: med.user,
                    medications: []
                });
            }

            patientMap.get(userId).medications.push({
                name: med.name,
                dosage: med.dosage,
                time: med.time,
                session: med.session
            });
        });

        const result = Array.from(patientMap.values());
        res.json(result);
    } catch (err) {
        console.error(err);
        res.status(500).json({ msg: 'Server Error' });
    }
});

// GET /api/staff/patients-health
// Get all patients with their latest health status
router.get('/patients-health', async (req, res) => {
    try {
        const patients = await User.find({ role: 'patient' }).select('-password');
        const result = [];

        for (const patient of patients) {
            // Lấy dữ liệu ĐÃ ĐƯỢC LƯU từ User Model
            // Không cần query HealthMetric để tính lại nữa -> Nhanh hơn và Đồng bộ
            
            result.push({
                id: patient._id,
                name: patient.fullName || 'Không tên',
                
                // Lấy trực tiếp trạng thái đã đồng bộ
                status: patient.currentHealthStatus || 'stable',
                lastAlert: patient.lastAiAlert || 'Ổn định',
                criticalValue: patient.criticalValue,
                criticalMetric: patient.criticalMetric,
                lastUpdate: patient.lastHealthUpdate || patient.createdAt,
                
                phoneNumber: patient.phoneNumber,
                guardianPhone: patient.guardianPhone,
                email: patient.email // Đảm bảo email được gửi về
            });
        }

        // Sort: Danger first
        const statusOrder = { 'danger': 0, 'warning': 1, 'stable': 2 };
        result.sort((a, b) => statusOrder[a.status] - statusOrder[b.status]);

        res.json(result);

    } catch (err) {
        console.error(err);
        res.status(500).json({ msg: 'Server Error' });
    }
});

// GET /api/staff/patient/:id/medications
router.get('/patient/:id/medications', async (req, res) => {
    try {
        const medications = await Medication.find({ user: req.params.id }).sort({ time: 1 });
        res.json(medications);
    } catch (err) {
        console.error(err);
        res.status(500).json({ msg: 'Server Error' });
    }
});

// GET /api/staff/patient/:id/health
router.get('/patient/:id/health', async (req, res) => {
    try {
        const metrics = await HealthMetric.find({ user: req.params.id }).sort({ timestamp: -1 });
        res.json(metrics);
    } catch (err) {
        console.error(err);
        res.status(500).json({ msg: 'Server Error' });
    }
});

module.exports = router;