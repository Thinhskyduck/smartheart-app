const express = require('express');
const router = express.Router();
const Medication = require('../models/Medication');
const User = require('../models/User');

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

module.exports = router;
