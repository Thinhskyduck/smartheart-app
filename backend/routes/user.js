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

module.exports = router;
