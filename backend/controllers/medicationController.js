const fs = require('fs');
const path = require('path');
const Medication = require('../models/Medication');
const { GoogleGenerativeAI } = require("@google/generative-ai");

// SỬA Ở ĐÂY: Lấy key từ file .env
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

exports.scanPrescription = async (req, res) => {
    console.log('Received scan request');
    
    if (!req.file) {
        console.log('No file uploaded');
        return res.status(400).json({ msg: 'No file uploaded' });
    }

    try {
        console.log('File received:', req.file.path);
        
        // --- Xử lý MimeType ---
        let mimeType = req.file.mimetype;
        if (mimeType === 'application/octet-stream') {
            const ext = path.extname(req.file.originalname).toLowerCase();
            if (ext === '.png') mimeType = 'image/png';
            else if (ext === '.webp') mimeType = 'image/webp';
            else mimeType = 'image/jpeg';
        }

        const fileData = fs.readFileSync(req.file.path);
        const image = {
            inlineData: {
                data: fileData.toString("base64"),
                mimeType: mimeType,
            },
        };

        const prompt = `
Bạn là chuyên gia y tế. Hãy:
1. OCR toàn bộ nội dung trong ảnh toa thuốc.
2. Chuẩn hóa lại thông tin.
3. Summarize thành format sau:

Ví dụ:
        - Tên thuốc 1 (có thể là vật tư y tế,...)
          •  Liều lượng: ...mg, ... viên.
          •  Cách dùng: Uống (1/0.5/...) viên/lần, ngày (1-2...) lần vào buổi (sáng/trưa/chiều/tối) (sau/trước) ăn.
        
        - Tên thuốc 2 (có thể là vật tư y tế,...)
          •  Liều lượng: ...mg, ... viên.
          •  Cách dùng: Uống (1/0.5/...) viên/lần, ngày (1-2...) lần vào buổi (sáng/trưa/chiều/tối) (sau/trước) ăn.
        
        - Lịch tái khám: (nếu không có thì ghi 'Không có thông tin.').
        
        - Nơi tái khám: rrwrewqrq (nếu không có thì hãy ghi 'Cơ sở y tế đã khám bệnh.').
        
        - Ghi chú & lời dặn quan trọng:
          • Ghi chú 1.
          • Ghi chú 2.
          ...
          
Trả lời bằng tiếng Việt, ngắn gọn, chính xác và chỉ trả về đúng định dạng của ví dụ, không được trả về text khác.
`;

        console.log('Sending to Gemini API...');
        
        // Vẫn dùng model 2.5 flash như bạn muốn
        const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });

        const result = await model.generateContent([prompt, image]);
        const response = await result.response;
        const text = response.text();

        console.log('Gemini Response:', text);

        // --- Parse Data ---
        const medications = [];
        let followUpSchedule = "Không có thông tin.";
        let followUpLocation = "Cơ sở y tế đã khám bệnh.";
        let notes = "";

        const lines = text.split('\n');
        let currentMed = null;

        for (let line of lines) {
            line = line.trim();
            if (!line) continue;

            if (line.startsWith('- Lịch tái khám:')) {
                followUpSchedule = line.replace('- Lịch tái khám:', '').trim();
                currentMed = null;
            } else if (line.startsWith('- Nơi tái khám:')) {
                followUpLocation = line.replace('- Nơi tái khám:', '').trim();
                currentMed = null;
            } else if (line.startsWith('- Ghi chú & lời dặn quan trọng:')) {
                currentMed = null;
            } else if (line.startsWith('- ')) {
                if (currentMed) medications.push(currentMed);
                currentMed = {
                    'Tên thuốc': line.replace('- ', '').trim(),
                    'Liều lượng chính': '',
                    'Cách dùng cơ bản': ''
                };
            } else if (line.startsWith('• Liều lượng:')) {
                if (currentMed) currentMed['Liều lượng chính'] = line.replace('• Liều lượng:', '').trim();
            } else if (line.startsWith('• Cách dùng:')) {
                if (currentMed) currentMed['Cách dùng cơ bản'] = line.replace('• Cách dùng:', '').trim();
            } else if (line.startsWith('• ')) {
                if (!currentMed) notes += line.replace('• ', '').trim() + '\n';
            }
        }
        if (currentMed) medications.push(currentMed);

        const finalResponse = medications.map(med => ({
            ...med,
            'Lịch tái khám': followUpSchedule,
            'Nơi tái khám': followUpLocation,
            'Các ghi chú quan trọng, nhắc nhở': notes.trim()
        }));

        if (fs.existsSync(req.file.path)) fs.unlinkSync(req.file.path);

        res.json(finalResponse);

    } catch (err) {
        console.error('Scan error:', err);
        if (req.file && fs.existsSync(req.file.path)) fs.unlinkSync(req.file.path);
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
            user: req.user.id, name, dosage, time, quantity, session
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
        if (medication.user.toString() !== req.user.id) return res.status(401).json({ msg: 'Not authorized' });

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
        if (medication.user.toString() !== req.user.id) return res.status(401).json({ msg: 'Not authorized' });

        await Medication.findByIdAndDelete(req.params.id);
        res.json({ msg: 'Medication removed' });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};