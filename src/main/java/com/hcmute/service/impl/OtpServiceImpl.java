package com.hcmute.service.impl;

import com.hcmute.dao.OtpDAO;
import com.hcmute.dao.impl.OtpDAOImpl;
import com.hcmute.model.OtpToken;
import com.hcmute.service.EmailService;
import com.hcmute.service.OtpService;
import com.hcmute.service.OtpVerifyResult;
import com.hcmute.util.SecurityUtil;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.logging.Level;
import java.util.logging.Logger;

public class OtpServiceImpl implements OtpService {

    private static final Logger LOGGER = Logger.getLogger(OtpServiceImpl.class.getName());
    private static final int COOLDOWN_SECONDS = 60;
    private static final int OTP_EXPIRY_MINUTES = 5;

    private final OtpDAO otpDAO = new OtpDAOImpl();
    private final EmailService emailService = new EmailServiceImpl();

    @Override
    public String generateAndSendOtp(String email, String purpose) {
        if (email == null || email.isBlank()) {
            return "Email không hợp lệ.";
        }
        email = email.trim();

        // 1. Kiểm tra thời gian chờ (cooldown 60s)
        long remainingCooldown = getRemainingCooldownSeconds(email, purpose);
        if (remainingCooldown > 0) {
            return "Vui lòng đợi " + remainingCooldown + " giây trước khi yêu cầu gửi lại mã OTP.";
        }

        // 2. Tạo mã OTP 6 chữ số bằng SecureRandom và hash SHA-256
        String plainOtp = SecurityUtil.generateOtp(6);
        String hashedOtp = SecurityUtil.hashOtp(plainOtp);

        LocalDateTime now = LocalDateTime.now();
        LocalDateTime expiresAt = now.plusMinutes(OTP_EXPIRY_MINUTES);

        // 3. Gửi email trước: nếu gửi thất bại thì KHÔNG lưu token hợp lệ
        try {
            emailService.sendOtpEmail(email, plainOtp, purpose);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Gửi email OTP thất bại tới " + email + ": " + e.getMessage(), e);
            String errDetail = e.getMessage() != null ? e.getMessage() : "Lỗi kết nối máy chủ SMTP";
            return "Không thể gửi email OTP: " + errDetail + ". Vui lòng kiểm tra cấu hình Gmail trong file .env.";
        }

        // 4. Vô hiệu hóa các OTP chưa dùng trước đó và lưu OTP mới vào DB
        otpDAO.invalidatePreviousOtps(email, purpose);

        OtpToken token = new OtpToken(email, hashedOtp, purpose, now, expiresAt);
        boolean saved = otpDAO.insert(token);
        if (!saved) {
            return "Không thể lưu thông tin xác thực OTP vào cơ sở dữ liệu.";
        }

        return null; // Thành công!
    }

    @Override
    public OtpVerifyResult verifyOtp(String email, String purpose, String inputOtp) {
        if (email == null || email.isBlank()) {
            return OtpVerifyResult.fail("Email không hợp lệ.", 0);
        }
        if (inputOtp == null || inputOtp.trim().length() != 6) {
            return OtpVerifyResult.fail("Mã OTP phải gồm 6 chữ số.", 0);
        }

        email = email.trim();
        inputOtp = inputOtp.trim();

        OtpToken token = otpDAO.findLatestByEmailAndPurpose(email, purpose);
        if (token == null) {
            return OtpVerifyResult.fail("Không tìm thấy mã OTP cho email này. Vui lòng yêu cầu gửi mã mới.", 0);
        }

        if (token.isUsed()) {
            return OtpVerifyResult.fail("Mã OTP này đã được sử dụng. Vui lòng nhấn 'Gửi lại mã OTP'.", 0);
        }

        if (token.isExpired()) {
            return OtpVerifyResult.fail("Mã OTP đã hết hạn (" + OTP_EXPIRY_MINUTES + " phút). Vui lòng nhấn 'Gửi lại mã OTP'.", 0);
        }

        if (token.getAttempts() >= token.getMaxAttempts()) {
            return OtpVerifyResult.fail("Bạn đã nhập sai mã OTP quá 5 lần. Mã này đã bị khóa, vui lòng nhấn 'Gửi lại mã OTP'.", 0);
        }

        boolean matched = SecurityUtil.verifyOtp(inputOtp, token.getOtpHash());
        if (!matched) {
            int newAttempts = token.getAttempts() + 1;
            token.setAttempts(newAttempts);
            otpDAO.update(token);

            int remaining = token.getMaxAttempts() - newAttempts;
            if (remaining <= 0) {
                return OtpVerifyResult.fail("Mã OTP không chính xác. Bạn đã nhập sai quá 5 lần, mã bị vô hiệu hóa. Vui lòng gửi lại mã mới.", 0);
            }
            return OtpVerifyResult.fail("Mã OTP không chính xác. Bạn còn " + remaining + " lần thử.", remaining);
        }

        // OTP đúng -> đánh dấu đã sử dụng
        token.setUsed(true);
        otpDAO.update(token);

        return OtpVerifyResult.ok("Xác thực OTP thành công!");
    }

    @Override
    public long getRemainingCooldownSeconds(String email, String purpose) {
        if (email == null || email.isBlank()) return 0;
        OtpToken latest = otpDAO.findLatestByEmailAndPurpose(email.trim(), purpose);
        if (latest == null) return 0;

        long elapsed = ChronoUnit.SECONDS.between(latest.getCreatedAt(), LocalDateTime.now());
        if (elapsed < COOLDOWN_SECONDS) {
            return COOLDOWN_SECONDS - elapsed;
        }
        return 0;
    }
}
