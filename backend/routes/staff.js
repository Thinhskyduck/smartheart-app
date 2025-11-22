const express = require('express');
const router = express.Router();
const Medication = require('../models/Medication');
const User = require('../models/User');
const HealthMetric = require('../models/HealthMetric');

// GET /api/staff/missed-medications
// Get list of patients who have not taken their medication
router.get('/missed-medications', async (req, res) => {
    try {
        // Find medications that are NOT taken
        // In a real app, we would also check if the time has passed
        const missedMeds = await Medication.find({ isTaken: false })
            .populate('user', 'fullName phoneNumber guardianPhone birthYear')
            .sort({ time: 1 });

        // Group by user
        const patientMap = new Map();

        missedMeds.forEach(med => {
            if (!med.user) return; // Skip if user deleted

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
        // 1. Get all patients
        const patients = await User.find({ role: 'patient' }).select('-password');

        const result = [];

        for (const patient of patients) {
            // 2. Get latest metrics for each patient
            // We want latest SpO2 and Heart Rate for status calculation
            const metrics = await HealthMetric.find({ user: patient._id })
                .sort({ timestamp: -1 })
                .limit(20); // Get last 20 to find specific types

            const latestSpO2 = metrics.find(m => m.type === 'BLOOD_OXYGEN');
            const latestHR = metrics.find(m => m.type === 'HEART_RATE');
            const latestHRV = metrics.find(m => m.type === 'HEART_RATE_VARIABILITY_RMSSD');

            // 3. Determine Status
            let status = 'stable';
            let lastAlert = 'Các chỉ số ổn định';
            let criticalValue = null;
            let criticalMetric = null;
            let lastUpdate = patient.createdAt; // Default to created time

            if (metrics.length > 0) {
                lastUpdate = metrics[0].timestamp;
            }

            // Simple Logic for Status
            if (latestSpO2) {
                const spo2Val = parseFloat(latestSpO2.value);
                if (spo2Val < 90) {
                    status = 'danger';
                    lastAlert = 'SpO2 xuống thấp nguy hiểm';
                    criticalValue = `${spo2Val}%`;
                    criticalMetric = 'SpO2';
                } else if (spo2Val < 95) {
                    status = 'warning';
                    lastAlert = 'SpO2 thấp';
                    criticalValue = `${spo2Val}%`;
                    criticalMetric = 'SpO2';
                }
            }

            if (status !== 'danger' && latestHR) {
                const hrVal = parseFloat(latestHR.value);
                if (hrVal > 120 || hrVal < 40) {
                    status = 'danger';
                    lastAlert = 'Nhịp tim bất thường';
                    criticalValue = `${hrVal} bpm`;
                    criticalMetric = 'HR';
                } else if (hrVal > 100 || hrVal < 50) {
                    status = 'warning';
                    lastAlert = 'Nhịp tim cần chú ý';
                    criticalValue = `${hrVal} bpm`;
                    criticalMetric = 'HR';
                }
            }

            result.push({
                id: patient._id,
                name: patient.fullName || 'Không tên',
                status: status, // stable, warning, danger
                lastAlert: lastAlert,
                criticalValue: criticalValue,
                criticalMetric: criticalMetric,
                lastUpdate: lastUpdate,
                phoneNumber: patient.phoneNumber,
                guardianPhone: patient.guardianPhone
            });
        }

        // Sort: Danger first, then Warning, then Stable
        const statusOrder = { 'danger': 0, 'warning': 1, 'stable': 2 };
        result.sort((a, b) => statusOrder[a.status] - statusOrder[b.status]);

        res.json(result);

    } catch (err) {
        console.error(err);
        res.status(500).json({ msg: 'Server Error' });
    }
});

module.exports = router;
