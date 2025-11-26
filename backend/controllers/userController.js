const User = require('../models/User');

exports.updateProfile = async (req, res) => {
    const { fullName, phoneNumber, usagePurpose, heartFailureStage } = req.body;

    // Build object to update
    const userFields = {};
    if (fullName) userFields.fullName = fullName;
    if (phoneNumber) userFields.phoneNumber = phoneNumber;
    if (usagePurpose) userFields.usagePurpose = usagePurpose;
    if (heartFailureStage) userFields.heartFailureStage = heartFailureStage;

    try {
        let user = await User.findById(req.user.id);

        if (!user) return res.status(404).json({ msg: 'User not found' });

        user = await User.findByIdAndUpdate(
            req.user.id,
            { $set: userFields },
            { new: true }
        ).select('-password');

        res.json(user);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

exports.linkGuardian = async (req, res) => {
    const { guardianCode } = req.body;

    try {
        // Find the guardian by code
        const guardian = await User.findOne({ guardianCode });

        if (!guardian) {
            return res.status(404).json({ msg: 'Guardian code not found' });
        }

        // Add guardian to user's guardians list
        const user = await User.findById(req.user.id);

        // Check if already linked
        if (user.guardians.includes(guardian.id)) {
            return res.status(400).json({ msg: 'Guardian already linked' });
        }

        user.guardians.push(guardian.id);
        await user.save();

        // Add user to guardian's patients list
        guardian.patients.push(user.id);
        await guardian.save();

        res.json({ msg: 'Guardian linked successfully', guardianName: guardian.fullName });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

// Get list of guardians for current patient
exports.getGuardians = async (req, res) => {
    try {
        const user = await User.findById(req.user.id)
            .populate('guardians', 'fullName phoneNumber email');

        res.json(user.guardians || []);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

// Get list of patients for current guardian/doctor
exports.getPatients = async (req, res) => {
    try {
        const user = await User.findById(req.user.id)
            .populate('patients', 'fullName phoneNumber email guardianCode');

        res.json(user.patients || []);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

// THÊM HÀM NÀY VÀO CUỐI FILE
exports.updateHealthStatus = async (req, res) => {
    const { status, alert, metric, value } = req.body;

    try {
        await User.findByIdAndUpdate(req.user.id, {
            currentHealthStatus: status,
            lastAiAlert: alert,
            criticalMetric: metric,
            criticalValue: value,
            lastHealthUpdate: Date.now()
        });
        res.json({ msg: 'Health status updated' });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};
