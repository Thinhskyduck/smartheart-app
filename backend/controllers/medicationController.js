const Medication = require('../models/Medication');

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
