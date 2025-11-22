const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const dotenv = require('dotenv');
const User = require('./models/User');

dotenv.config();

const createDoctor = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URI, {
            useNewUrlParser: true,
            useUnifiedTopology: true
        });
        console.log('MongoDB Connected');

        const email = 'doctor@example.com';
        const phoneNumber = '0999999999';
        const password = 'password123';

        let user = await User.findOne({ email });
        if (user) {
            console.log('Doctor account already exists:');
            console.log(`Email: ${email}`);
            console.log(`Phone: ${phoneNumber}`);
            console.log(`Password: ${password} (if not changed)`);
            process.exit();
        }

        user = new User({
            fullName: 'Bác sĩ Demo',
            email,
            phoneNumber,
            password,
            role: 'doctor',
            guardianCode: 'DOC123'
        });

        const salt = await bcrypt.genSalt(10);
        user.password = await bcrypt.hash(password, salt);

        await user.save();

        console.log('Doctor account created successfully!');
        console.log(`Email: ${email}`);
        console.log(`Phone: ${phoneNumber}`);
        console.log(`Password: ${password}`);

        process.exit();
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
};

createDoctor();
