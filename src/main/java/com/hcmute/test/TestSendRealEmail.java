package com.hcmute.test;

import com.hcmute.config.EmailConfig;
import com.hcmute.service.EmailService;
import com.hcmute.service.impl.EmailServiceImpl;

public class TestSendRealEmail {

    public static void main(String[] args) {
        System.out.println("========== KIỂM THỬ KẾT NỐI VÀ GỬI EMAIL THẬT QUA GMAIL SMTP ==========");

        System.out.println("1. Kiểm tra cấu hình nạp từ EmailConfig:");
        System.out.println("   - Host: " + EmailConfig.getHost());
        System.out.println("   - Port: " + EmailConfig.getPort());
        System.out.println("   - Username: " + EmailConfig.getUsername());
        System.out.println("   - From: " + EmailConfig.getFrom());
        System.out.println("   - Password length: " + EmailConfig.getPassword().length() + " ký tự (không in mật khẩu)");
        System.out.println("   - isConfigured: " + EmailConfig.isConfigured());

        if (!EmailConfig.isConfigured()) {
            System.err.println("[LỖI] EmailConfig chưa nhận diện được cấu hình!");
            System.exit(1);
        }

        EmailService emailService = new EmailServiceImpl();
        String targetEmail = EmailConfig.getUsername(); // Gửi thử trực tiếp đến hòm thư người dùng

        System.out.println("\n2. Đang gửi email xác thực OTP thử nghiệm đến: " + targetEmail + "...");
        try {
            long start = System.currentTimeMillis();
            emailService.sendOtpEmail(targetEmail, "888999", "REGISTER");
            long duration = System.currentTimeMillis() - start;
            System.out.println("\n[THÀNH CÔNG RỰC RỠ] Đã gửi email OTP thực tế qua Gmail SMTP thành công!");
            System.out.println("Thời gian gửi: " + duration + " ms");
            System.out.println("Vui lòng mở hộp thư " + targetEmail + " để kiểm tra email OTP vừa gửi đến!");
        } catch (Exception e) {
            System.err.println("\n[LỖI GỬI EMAIL] Chi tiết lỗi kết nối Gmail SMTP:");
            e.printStackTrace();
            System.exit(2);
        }
    }
}
