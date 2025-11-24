const fs = require('fs');
const path = require('path');
const Medication = require('../models/Medication');
const { GoogleGenerativeAI } = require("@google/generative-ai");

// SỬA Ở ĐÂY: Lấy key từ file .env
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

exports.scanPrescription = async (req, res) => {
    console.log('Received scan request');
    
    if (!req.file) {
        return res.status(400).json({ msg: 'No file uploaded' });
    }

    try {
        // 1. Xử lý MimeType
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

        // 2. Cấu hình Model & Prompt
        // SỬ DỤNG ĐÚNG MODEL GEMINI 2.5 FLASH
        const model = genAI.getGenerativeModel({ 
            model: "gemini-2.5-flash", // Đã cập nhật theo yêu cầu
            generationConfig: {
                responseMimeType: "application/json" // Ép buộc trả về JSON
            }
        });

        const prompt = `
        Bạn là chuyên gia y tế. Hãy phân tích hình ảnh toa thuốc và trả về JSON theo đúng cấu trúc sau.
        
        Yêu cầu tách biệt rõ ràng:
        1. "ghi_chu_rieng": Chỉ những lưu ý dành riêng cho thuốc đó (VD: lắc kỹ, uống lúc đói).
        2. "loi_dan_chung": Những lời dặn dò tổng quát cho bệnh nhân (VD: Kiêng rượu bia, ăn nhạt, chế độ tập luyện).

        Cấu trúc JSON bắt buộc:
        {
            "don_thuoc": [
                {
                    "ten_thuoc": "Tên thuốc + hàm lượng",
                    "lieu_luong": "Số lượng/Liều lượng",
                    "cach_dung": "Cách dùng cụ thể",
                    "ghi_chu_rieng": "Ghi chú riêng của thuốc này (để trống nếu không có)"
                }
            ],
            "thong_tin_chung": {
                "ngay_tai_kham": "Ngày hoặc khoảng thời gian (hoặc null)",
                "noi_tai_kham": "Tên cơ sở y tế (hoặc null)",
                "loi_dan_chung": "Các lời dặn dò chung, chế độ ăn uống, sinh hoạt..."
            }
        }
        `;

        console.log('Sending to Gemini 2.5 Flash...');
        const result = await model.generateContent([prompt, image]);
        const response = await result.response;
        const text = response.text();

        console.log('Gemini Response:', text);

        let parsedData;
        try {
            parsedData = JSON.parse(text);
        } catch (e) {
            // Fallback phòng khi JSON bị lỗi nhẹ (ít khi xảy ra với mode json)
            const cleanText = text.replace(/```json/g, '').replace(/```/g, '').trim();
            parsedData = JSON.parse(cleanText);
        }

        // 3. Xử lý dữ liệu trả về cho Frontend
        const ttChung = parsedData.thong_tin_chung || {};
        
        // Logic hiển thị lịch tái khám (như cũ)
        let taiKhamDisplay = "Không có thông tin tái khám";
        if (ttChung.ngay_tai_kham && ttChung.noi_tai_kham) {
            taiKhamDisplay = `${ttChung.ngay_tai_kham} tại ${ttChung.noi_tai_kham}`;
        } else if (ttChung.ngay_tai_kham) {
            taiKhamDisplay = ttChung.ngay_tai_kham;
        } else if (ttChung.noi_tai_kham) {
            taiKhamDisplay = `Tại ${ttChung.noi_tai_kham}`;
        }

        // Cấu trúc Final Response gửi về Frontend
        // Frontend sẽ nhận được 2 cục: 'medications' (list thuốc) và 'generalInfo' (thông tin chung)
        const finalResponse = {
            medications: (parsedData.don_thuoc || []).map(med => ({
                ten_thuoc: med.ten_thuoc || "Đang cập nhật",
                lieu_luong: med.lieu_luong || "",
                cach_dung: med.cach_dung || "",
                ghi_chu_rieng: med.ghi_chu_rieng || "" // Frontend check field này, nếu có text thì hiện icon/text note
            })),
            generalInfo: {
                lich_tai_kham: taiKhamDisplay,
                loi_dan_chung: ttChung.loi_dan_chung || "Không có lời dặn đặc biệt." // Frontend hiện cái này ở khu vực riêng
            }
        };

        if (fs.existsSync(req.file.path)) fs.unlinkSync(req.file.path);
        
        res.json(finalResponse);

    } catch (err) {
        console.error('Scan error:', err);
        if (req.file && fs.existsSync(req.file.path)) fs.unlinkSync(req.file.path);
        res.status(500).json({ msg: 'Lỗi khi quét toa thuốc', error: err.message });
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