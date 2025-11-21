const HealthMetric = require('../models/HealthMetric');

exports.addMetric = async (req, res) => {
    const { type, value, unit } = req.body;

    try {
        const newMetric = new HealthMetric({
            user: req.user.id,
            type,
            value,
            unit
        });

        const metric = await newMetric.save();
        res.json(metric);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

exports.getMetrics = async (req, res) => {
    try {
        // Get latest metrics for each type? Or all history?
        // For dashboard, we usually want latest. For history, all.
        // Let's return all for now, sorted by date desc.
        const metrics = await HealthMetric.find({ user: req.user.id }).sort({ timestamp: -1 });
        res.json(metrics);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

// Get latest metrics for dashboard
exports.getLatestMetrics = async (req, res) => {
    try {
        // Aggregate to find the latest document for each type
        // This is a bit complex in Mongo, so for simplicity, let's just fetch all and filter in JS or use a simple query if volume is low.
        // Better approach:
        const types = ['weight', 'bp', 'hr', 'hrv', 'spo2', 'sleep'];
        const latestMetrics = {};

        for (const type of types) {
            const metric = await HealthMetric.findOne({ user: req.user.id, type }).sort({ timestamp: -1 });
            if (metric) {
                latestMetrics[type] = metric.value; // Or full object
            }
        }
        res.json(latestMetrics);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};
