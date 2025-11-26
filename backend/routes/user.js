const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const auth = require('../middleware/authMiddleware');

// @route   PUT api/user/profile
// @desc    Update user profile
// @access  Private
router.put('/profile', auth, userController.updateProfile);

// @route   POST api/user/link-guardian
// @desc    Link a guardian using code
// @access  Private
router.post('/link-guardian', auth, userController.linkGuardian);

// @route   GET api/user/guardians
// @desc    Get list of guardians for current patient
// @access  Private
router.get('/guardians', auth, userController.getGuardians);

// @route   GET api/user/patients
// @desc    Get list of patients for current guardian/doctor
// @access  Private
router.get('/patients', auth, userController.getPatients);

module.exports = router;
