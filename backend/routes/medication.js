const express = require('express');
const router = express.Router();
const medicationController = require('../controllers/medicationController');
const auth = require('../middleware/authMiddleware');

// @route   GET api/medications
// @desc    Get all medications
// @access  Private
router.get('/', auth, medicationController.getMedications);

// @route   POST api/medications
// @desc    Add new medication
// @access  Private
router.post('/', auth, medicationController.addMedication);

// @route   PUT api/medications/:id
// @desc    Update medication
// @access  Private
router.put('/:id', auth, medicationController.updateMedication);

// @route   DELETE api/medications/:id
// @desc    Delete medication
// @access  Private
router.delete('/:id', auth, medicationController.deleteMedication);

module.exports = router;
