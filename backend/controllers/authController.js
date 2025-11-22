const User = require('../models/User');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { sendOTPEmail, verifyOTP } = require('../services/emailService');

// Temporary OTP storage (in production, use Redis or database)
const otpStore = new Map();

// Send OTP for registration
exports.sendOTP = async (req, res) => {
    const { email, fullName } = req.body;

    try {
        // Check if email already exists
        let user = await User.findOne({ email });
        if (user) {
            return res.status(400).json({ msg: 'Email đã được đăng ký' });
        }

        // Send OTP email
        const result = await sendOTPEmail(email, fullName);

        if (result.success) {
            // Store OTP with timestamp
            otpStore.set(email, {
                otp: result.otp,
                timestamp: Date.now(),
                userData: { fullName, email }
            });

            // Auto-delete OTP after 10 minutes
            setTimeout(() => {
                otpStore.delete(email);
            }, 10 * 60 * 1000);

            res.json({
                success: true,
                msg: 'Mã OTP đã được gửi đến email của bạn',
                messageId: result.messageId
            });
        } else {
            res.status(500).json({
                success: false,
                msg: 'Không thể gửi email. Vui lòng thử lại.',
                error: result.error
            });
        }
    } catch (err) {
        console.error(err.message);
        res.status(500).json({ msg: 'Server error', error: err.message });
    }
};

// Verify OTP and complete registration
exports.verifyOTPAndRegister = async (req, res) => {
    const { email, otp, phoneNumber, password, role, guardianCode } = req.body;

    try {
        // Get stored OTP
        const storedData = otpStore.get(email);

        if (!storedData) {
            return res.status(400).json({ msg: 'Mã OTP đã hết hạn hoặc không tồn tại' });
        }

        // Verify OTP
        const verification = verifyOTP(otp, storedData.otp, storedData.timestamp);

        if (!verification.valid) {
            return res.status(400).json({ msg: verification.message });
        }

        // Check if phone number already exists
        let user = await User.findOne({ phoneNumber });
        if (user) {
            return res.status(400).json({ msg: 'Số điện thoại đã được đăng ký' });
        }

        // Create new user
        user = new User({
            fullName: storedData.userData.fullName,
            email: email,
            phoneNumber,
            password,
            role,
            guardianCode: guardianCode || Math.floor(100000 + Math.random() * 900000).toString()
        });

        const salt = await bcrypt.genSalt(10);
        user.password = await bcrypt.hash(password, salt);

        await user.save();

        // Remove OTP from store
        otpStore.delete(email);

        const payload = {
            user: {
                id: user.id
            }
        };

        jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: 360000 }, (err, token) => {
            if (err) throw err;
            res.json({
                success: true,
                token,
                msg: 'Đăng ký thành công!'
            });
        });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

// Original register (keep for backward compatibility)
exports.register = async (req, res) => {
    const { fullName, phoneNumber, password, role } = req.body;

    try {
        let user = await User.findOne({ phoneNumber });
        if (user) {
            return res.status(400).json({ msg: 'User already exists' });
        }

        user = new User({
            fullName,
            phoneNumber,
            password,
            role
        });

        const salt = await bcrypt.genSalt(10);
        user.password = await bcrypt.hash(password, salt);

        user.guardianCode = Math.floor(100000 + Math.random() * 900000).toString();

        await user.save();

        const payload = {
            user: {
                id: user.id
            }
        };

        jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: 360000 }, (err, token) => {
            if (err) throw err;
            res.json({ token });
        });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

exports.login = async (req, res) => {
    const { phoneNumber, password } = req.body;

    try {
        let user = await User.findOne({ phoneNumber });
        if (!user) {
            return res.status(400).json({ msg: 'Invalid Credentials' });
        }

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(400).json({ msg: 'Invalid Credentials' });
        }

        const payload = {
            user: {
                id: user.id
            }
        };

        jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: 360000 }, (err, token) => {
            if (err) throw err;
            res.json({ token });
        });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

exports.getMe = async (req, res) => {
    try {
        const user = await User.findById(req.user.id).select('-password');
        res.json(user);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};
