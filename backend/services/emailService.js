// services/emailService.js
const nodemailer = require('nodemailer');

// Email configuration với DEBUG
const transporter = nodemailer.createTransport({
  host: 'smtp.gmail.com',
  port: 587, // Đổi sang 587
  secure: false, // false cho cổng 587 (sẽ tự động nâng cấp lên TLS)
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASSWORD
  },
  // --- CẤU HÌNH FIX LỖI MẠNG ---
  tls: {
    ciphers: 'SSLv3', // Hỗ trợ các thuật toán mã hóa cũ nếu cần
    rejectUnauthorized: false // Bỏ qua lỗi chứng chỉ (quan trọng trên Render)
  },
  family: 4, // Ép buộc sử dụng IPv4 (Quan trọng!)
  // -----------------------------
  debug: true,
  logger: true,
  connectionTimeout: 30000,
  greetingTimeout: 30000,
  socketTimeout: 30000
});

// Kiểm tra kết nối ngay khi khởi động
transporter.verify(function (error, success) {
  if (error) {
    console.error('🔴 Lỗi kết nối SMTP ngay khi khởi động:', error);
  } else {
    console.log('🟢 Server đã sẵn sàng gửi email');
  }
});

// Generate 6-digit OTP
const generateOTP = () => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

// Beautiful HTML email template
const getOTPEmailTemplate = (otp, userName) => {
  return `
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Mã xác thực OTP</title>
</head>
<body style="margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f7fa;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #f4f7fa; padding: 40px 20px;">
    <tr>
      <td align="center">
        <table width="600" cellpadding="0" cellspacing="0" style="background-color: #ffffff; border-radius: 16px; box-shadow: 0 4px 20px rgba(0,0,0,0.08); overflow: hidden;">
          
          <tr>
            <td style="background: linear-gradient(135deg, #2260FF 0%, #1a4fd6 100%); padding: 40px 30px; text-align: center;">
              <h1 style="margin: 0; color: #ffffff; font-size: 28px; font-weight: 700; letter-spacing: -0.5px;">
                🏥 PentaPulse Health
              </h1>
              <p style="margin: 10px 0 0 0; color: #e3f2fd; font-size: 14px;">
                Nền tảng chăm sóc sức khỏe thông minh
              </p>
            </td>
          </tr>
          
          <tr>
            <td style="padding: 40px 30px;">
              <h2 style="margin: 0 0 20px 0; color: #1a1a1a; font-size: 24px; font-weight: 600;">
                Xin chào ${userName || 'bạn'}! 👋
              </h2>
              <p style="margin: 0 0 25px 0; color: #555555; font-size: 16px; line-height: 1.6;">
                Cảm ơn bạn đã đăng ký tài khoản PentaPulse. Để hoàn tất quá trình đăng ký, vui lòng sử dụng mã OTP bên dưới:
              </p>
              
              <table width="100%" cellpadding="0" cellspacing="0" style="margin: 30px 0;">
                <tr>
                  <td align="center">
                    <div style="background: linear-gradient(135deg, #f5f7fa 0%, #e3f2fd 100%); border: 2px dashed #2260FF; border-radius: 12px; padding: 25px; display: inline-block;">
                      <p style="margin: 0 0 10px 0; color: #666666; font-size: 14px; font-weight: 500; text-transform: uppercase; letter-spacing: 1px;">
                        Mã xác thực OTP
                      </p>
                      <p style="margin: 0; color: #2260FF; font-size: 42px; font-weight: 700; letter-spacing: 8px; font-family: 'Courier New', monospace;">
                        ${otp}
                      </p>
                    </div>
                  </td>
                </tr>
              </table>
              
              <div style="background-color: #fff3e0; border-left: 4px solid #ff9800; padding: 15px 20px; border-radius: 8px; margin: 25px 0;">
                <p style="margin: 0; color: #e65100; font-size: 14px; line-height: 1.5;">
                  ⚠️ <strong>Lưu ý:</strong> Mã OTP này có hiệu lực trong <strong>10 phút</strong>. Vui lòng không chia sẻ mã này với bất kỳ ai.
                </p>
              </div>
              
              <p style="margin: 25px 0 0 0; color: #555555; font-size: 15px; line-height: 1.6;">
                Nếu bạn không yêu cầu đăng ký tài khoản, vui lòng bỏ qua email này.
              </p>
            </td>
          </tr>
          
          <tr>
            <td style="background-color: #f8f9fa; padding: 30px; text-align: center; border-top: 1px solid #e0e0e0;">
              <p style="margin: 0 0 10px 0; color: #888888; font-size: 13px;">
                Bạn nhận được email này vì đã đăng ký tài khoản tại PentaPulse
              </p>
              <p style="margin: 0; color: #aaaaaa; font-size: 12px;">
                © 2025 PentaPulse Health. All rights reserved.
              </p>
              <div style="margin-top: 15px;">
                <a href="#" style="color: #2260FF; text-decoration: none; margin: 0 10px; font-size: 12px;">Chính sách bảo mật</a>
                <span style="color: #cccccc;">|</span>
                <a href="#" style="color: #2260FF; text-decoration: none; margin: 0 10px; font-size: 12px;">Điều khoản sử dụng</a>
              </div>
            </td>
          </tr>
          
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
  `;
};

// Send OTP email
const sendOTPEmail = async (email, userName) => {
  console.log(`🚀 Bắt đầu quy trình gửi email đến: ${email}`);
  try {
    const otp = generateOTP();

    const mailOptions = {
      from: {
        name: 'PentaPulse Health',
        address: 'shopthinhtan@gmail.com'
      },
      to: email,
      subject: '🔐 Mã xác thực OTP - PentaPulse Health',
      html: getOTPEmailTemplate(otp, userName)
    };

    console.log('📨 Đang gọi transporter.sendMail...');
    const info = await transporter.sendMail(mailOptions);
    console.log('✅ Email sent successfully. MessageID:', info.messageId);

    return {
      success: true,
      otp: otp, // Return OTP to store in database/session
      messageId: info.messageId
    };
  } catch (error) {
    console.error('❌ LỖI CHI TIẾT KHI GỬI MAIL:', error);
    return {
      success: false,
      error: error.message
    };
  }
};

// Verify OTP (compare with stored OTP)
const verifyOTP = (inputOTP, storedOTP, timestamp) => {
  const TEN_MINUTES = 10 * 60 * 1000; // 10 minutes in milliseconds
  const now = Date.now();

  if (now - timestamp > TEN_MINUTES) {
    return { valid: false, message: 'Mã OTP đã hết hạn' };
  }

  if (inputOTP === storedOTP) {
    return { valid: true, message: 'Xác thực thành công' };
  }

  return { valid: false, message: 'Mã OTP không chính xác' };
};

module.exports = {
  sendOTPEmail,
  verifyOTP,
  generateOTP
};