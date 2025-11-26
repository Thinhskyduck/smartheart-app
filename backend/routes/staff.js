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
            const metrics = await HealthMetric.find({ user: patient._id })
                .sort({ timestamp: -1 })
                .limit(50); // Lấy nhiều hơn chút để chắc chắn đủ type

            // [SỬA LỖI QUAN TRỌNG TẠI ĐÂY]
            // App gửi lên là 'spo2', 'hr', 'hrv'... chứ không phải 'BLOOD_OXYGEN'
            const latestSpO2 = metrics.find(m => m.type === 'spo2');
            const latestHR = metrics.find(m => m.type === 'hr');
            const latestHRV = metrics.find(m => m.type === 'hrv'); // Đã thêm HRV

            let status = 'stable';
            let lastAlert = 'Các chỉ số ổn định';
            let criticalValue = null;
            let criticalMetric = null;
            let lastUpdate = patient.createdAt; 

            if (metrics.length > 0) {
                lastUpdate = metrics[0].timestamp;
            }

            // --- 1. LOGIC SPO2 ---
            if (latestSpO2) {
                const spo2Val = parseFloat(latestSpO2.value);
                if (spo2Val < 90) {
                    status = 'danger';
                    lastAlert = 'SpO2 xuống thấp nguy hiểm';
                    criticalValue = `${spo2Val}%`;
                    criticalMetric = 'SpO2';
                } else if (spo2Val < 95) {
                    if (status !== 'danger') { // Ưu tiên danger
                        status = 'warning';
                        lastAlert = 'SpO2 thấp';
                        criticalValue = `${spo2Val}%`;
                        criticalMetric = 'SpO2';
                    }
                }
            }

            // --- 2. LOGIC HRV (MỚI THÊM ĐỂ ĐỒNG BỘ AI) ---
            // AI thường báo đỏ nếu HRV rất thấp (dưới 20-25ms)
            if (latestHRV) {
                const hrvVal = parseFloat(latestHRV.value);
                if (hrvVal < 25) { // Ngưỡng nguy hiểm
                     status = 'danger';
                     lastAlert = 'Biến thiên tim (HRV) quá thấp';
                     criticalValue = `${hrvVal} ms`;
                     criticalMetric = 'HRV';
                } else if (hrvVal < 40) {
                    if (status !== 'danger') {
                        status = 'warning';
                        lastAlert = 'Biến thiên tim (HRV) thấp';
                        criticalValue = `${hrvVal} ms`;
                        criticalMetric = 'HRV';
                    }
                }
            }

            // --- 3. LOGIC NHỊP TIM (HR) ---
            if (latestHR) {
                const hrVal = parseFloat(latestHR.value);
                if (hrVal > 120 || hrVal < 40) {
                    if (status !== 'danger') { // Chỉ ghi đè nếu chưa phải danger do SpO2/HRV
                        status = 'danger';
                        lastAlert = 'Nhịp tim bất thường';
                        criticalValue = `${hrVal} bpm`;
                        criticalMetric = 'HR';
                    }
                } else if (hrVal > 100 || hrVal < 50) {
                    if (status === 'stable') {
                        status = 'warning';
                        lastAlert = 'Nhịp tim cần chú ý';
                        criticalValue = `${hrVal} bpm`;
                        criticalMetric = 'HR';
                    }
                }
            }

            result.push({
                id: patient._id,
                name: patient.fullName || 'Không tên',
                status: status,
                lastAlert: lastAlert,
                criticalValue: criticalValue,
                criticalMetric: criticalMetric,
                lastUpdate: lastUpdate,
                phoneNumber: patient.phoneNumber,
                guardianPhone: patient.guardianPhone,
                email: patient.email
            });
        }

        // Sắp xếp: Nguy hiểm lên đầu
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