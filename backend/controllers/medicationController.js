const Medication = require('../models/Medication');
const axios = require('axios');
const FormData = require('form-data');
const fs = require('fs');

exports.scanPrescription = async (req, res) => {
    if (!req.file) {
        return res.status(400).json({ msg: 'No file uploaded' });
    }

    try {
        const formData = new FormData();
        formData.append('file', fs.createReadStream(req.file.path));

        const response = await axios.post('https://thinhskyduck-prescription-scanner.hf.space/scan', formData, {
            headers: {
                ...formData.getHeaders()
            }
        });

        // Clean up uploaded file
        fs.unlinkSync(req.file.path);

        res.json(response.data);
    } catch (err) {
        console.error('Scan error:', err.message);
        // Clean up file if error
        if (req.file && fs.existsSync(req.file.path)) {
            fs.unlinkSync(req.file.path);
        }
        res.status(500).json({ msg: 'Error scanning prescription', error: err.message });
    }
};

exports.getMedications = async (req, res) => {
    try {
        const medications = await Medication.find({ user: req.user.id });
        res.json(medications);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

exports.addMedication = async (req, res) => {
    const { name, dosage, time, quantity, session } = req.body;

    try {
        const newMedication = new Medication({
            user: req.user.id,
            name,
            dosage,
            time,
            quantity,
            session
        });

        const medication = await newMedication.save();
        res.json(medication);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

exports.updateMedication = async (req, res) => {
    const { name, dosage, time, quantity, session, isTaken } = req.body;

    // Build object to update
    const medicationFields = {};
    if (name) medicationFields.name = name;
    if (dosage) medicationFields.dosage = dosage;
    if (time) medicationFields.time = time;
    if (quantity) medicationFields.quantity = quantity;
    if (session) medicationFields.session = session;
    if (isTaken !== undefined) medicationFields.isTaken = isTaken;

    try {
        let medication = await Medication.findById(req.params.id);

        if (!medication) return res.status(404).json({ msg: 'Medication not found' });

        // Make sure user owns medication
        if (medication.user.toString() !== req.user.id) {
            return res.status(401).json({ msg: 'Not authorized' });
        }

        medication = await Medication.findByIdAndUpdate(
            req.params.id,
            { $set: medicationFields },
            { new: true }
        );

        res.json(medication);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

exports.deleteMedication = async (req, res) => {
    try {
        let medication = await Medication.findById(req.params.id);

        if (!medication) return res.status(404).json({ msg: 'Medication not found' });

        // Make sure user owns medication
        if (medication.user.toString() !== req.user.id) {
            return res.status(401).json({ msg: 'Not authorized' });
        }

        await Medication.findByIdAndRemove(req.params.id);

        res.json({ msg: 'Medication removed' });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};
