const express = require('express');
const router = express.Router();
const healthController = require('../controllers/healthController');
const auth = require('../middleware/authMiddleware');

// @route   POST api/health
// @desc    Add a health metric
// @access  Private
router.post('/', auth, healthController.addMetric);

// @route   GET api/health
// @desc    Get all health metrics
// @access  Private
router.get('/', auth, healthController.getMetrics);

// @route   GET api/health/latest
// @desc    Get latest metrics for dashboard
// @access  Private
router.get('/latest', auth, healthController.getLatestMetrics);

module.exports = router;
