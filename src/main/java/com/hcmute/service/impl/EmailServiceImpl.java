package com.hcmute.service.impl;

import com.hcmute.config.EmailConfig;
import com.hcmute.service.EmailService;
import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

public class EmailServiceImpl implements EmailService {

    private static final Logger LOGGER = Logger.getLogger(EmailServiceImpl.class.getName());

    @Override
    public boolean isConfigured() {
        return EmailConfig.isConfigured();
    }

    @Override
    public void sendOtpEmail(String toEmail, String otpCode, String purpose) throws Exception {
        if (!isConfigured()) {
            throw new IllegalStateException(
                "Dịch vụ gửi email chưa được cấu hình. Vui lòng thiết lập MAIL_USERNAME và MAIL_PASSWORD (mật khẩu ứng dụng Gmail) trong file .env."
            );
        }

        String host = EmailConfig.getHost();
        int port = EmailConfig.getPort();
        String username = EmailConfig.getUsername();
        String password = EmailConfig.getPassword();
        String from = EmailConfig.getFrom();

        Properties props = new Properties();
        props.put("mail.smtp.auth", String.valueOf(EmailConfig.isAuth()));
        props.put("mail.smtp.starttls.enable", String.valueOf(EmailConfig.isStartTls()));
        props.put("mail.smtp.host", host);
        props.put("mail.smtp.port", String.valueOf(port));
        props.put("mail.smtp.ssl.protocols", "TLSv1.2 TLSv1.3");
        props.put("mail.smtp.ssl.trust", "*");
        props.put("mail.smtp.connectiontimeout", "15000");
        props.put("mail.smtp.timeout", "15000");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(username, password);
            }
        });

        try {
            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(from, "ProductManager", "UTF-8"));
            message.setRecipient(Message.RecipientType.TO, new InternetAddress(toEmail));

            String subject;
            String actionDesc;
            if ("FORGOT_PASSWORD".equalsIgnoreCase(purpose)) {
                subject = "[ProductManager] Mã OTP đặt lại mật khẩu";
                actionDesc = "đặt lại mật khẩu";
            } else {
                subject = "[ProductManager] Mã OTP xác thực đăng ký tài khoản";
                actionDesc = "kích hoạt tài khoản";
            }

            message.setSubject(subject, "UTF-8");
            message.setSentDate(new java.util.Date());
            message.setHeader("MIME-Version", "1.0");

            String htmlContent = "<div style=\"font-family: Arial, sans-serif; max-width: 520px; margin: 0 auto; border: 1px solid #e0e0e0; border-radius: 6px; overflow: hidden;\">"
                    + "<div style=\"background-color: #0080ff; color: #ffffff; padding: 20px; text-align: center;\">"
                    + "<h2 style=\"margin: 0; font-size: 22px;\">ProductManager</h2>"
                    + "<p style=\"margin: 5px 0 0 0; font-size: 13px; opacity: 0.9;\">Hệ thống Quản lý Sản phẩm</p>"
                    + "</div>"
                    + "<div style=\"padding: 25px 20px; background-color: #ffffff; color: #333333;\">"
                    + "<p style=\"font-size: 14px;\">Xin chào,</p>"
                    + "<p style=\"font-size: 14px; line-height: 1.5;\">Bạn vừa thực hiện yêu cầu <strong>" + actionDesc + "</strong> trên hệ thống ProductManager. Đây là mã OTP xác thực của bạn:</p>"
                    + "<div style=\"text-align: center; margin: 25px 0;\">"
                    + "<span style=\"display: inline-block; font-size: 32px; font-weight: bold; letter-spacing: 8px; color: #0080ff; background-color: #f0f7ff; padding: 12px 24px; border: 1px dashed #0080ff; border-radius: 6px;\">"
                    + otpCode
                    + "</span>"
                    + "</div>"
                    + "<p style=\"font-size: 13px; color: #d9534f; margin-bottom: 8px;\"><strong>* Lưu ý quan trọng:</strong></p>"
                    + "<ul style=\"font-size: 13px; color: #555555; padding-left: 20px; margin-top: 0;\">"
                    + "<li>Mã OTP này có hiệu lực trong vòng <strong>5 phút</strong>.</li>"
                    + "<li>Mỗi mã OTP chỉ có thể sử dụng <strong>01 lần duy nhất</strong>.</li>"
                    + "<li>Tuyệt đối <strong>không chia sẻ</strong> mã OTP này cho bất kỳ ai để đảm bảo an toàn cho tài khoản của bạn.</li>"
                    + "</ul>"
                    + "<p style=\"font-size: 12px; color: #888888; margin-top: 25px; border-top: 1px solid #eeeeee; padding-top: 15px;\">Nếu bạn không thực hiện yêu cầu này, vui lòng bỏ qua email hoặc thông báo cho quản trị viên.</p>"
                    + "</div>"
                    + "</div>";

            message.setContent(htmlContent, "text/html; charset=UTF-8");

            Transport.send(message);
            LOGGER.log(Level.INFO, "Gửi email OTP thành công tới địa chỉ {0} cho mục đích {1}", new Object[]{toEmail, purpose});
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Gửi email OTP thất bại tới " + toEmail + ". Chi tiết lỗi: " + e.getMessage(), e);
            throw e;
        }
    }
}
