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
        const patients = await User.find({ role: 'patient' }).select('-password').populate('guardians', 'fullName phoneNumber email');
        const result = [];

        for (const patient of patients) {
            // Lấy dữ liệu ĐÃ ĐƯỢC LƯU từ User Model
            // Không cần query HealthMetric để tính lại nữa -> Nhanh hơn và Đồng bộ
            // [SỬA 2] Logic hiển thị Người giám hộ thông minh hơn
            let guardianDisplay = 'Không có';
            
            // Kiểm tra xem có liên kết tài khoản người giám hộ nào không
            if (patient.guardians && patient.guardians.length > 0) {
                const g = patient.guardians[0]; // Lấy người giám hộ đầu tiên
                guardianDisplay = `${g.fullName} - ${g.phoneNumber}`;
            } else if (patient.guardianPhone) {
                // Fallback: Nếu không có link, dùng số điện thoại nhập tay (nếu có)
                guardianDisplay = patient.guardianPhone;
            }

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
                guardianPhone: guardianDisplay,
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

// GET /api/staff/patient/:id/info - Lấy thông tin profile và status mới nhất
router.get('/patient/:id/info', async (req, res) => {
    try {
        const user = await User.findById(req.params.id).select('-password');
        if (!user) return res.status(404).json({ msg: 'User not found' });
        
        // Trả về cấu trúc giống danh sách dashboard để frontend dễ map
        res.json({
            id: user._id,
            name: user.fullName,
            status: user.currentHealthStatus || 'stable', // Lấy status mới nhất từ DB
            lastAlert: user.lastAiAlert || '',
            criticalValue: user.criticalValue,
            criticalMetric: user.criticalMetric,
            lastUpdate: user.lastHealthUpdate,
            phoneNumber: user.phoneNumber,
            email: user.email,
            guardianPhone: user.guardianPhone
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ msg: 'Server Error' });
    }
});

module.exports = router;