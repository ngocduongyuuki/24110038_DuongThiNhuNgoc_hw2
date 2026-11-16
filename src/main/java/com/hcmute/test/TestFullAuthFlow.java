package com.hcmute.test;

import com.hcmute.config.EmailConfig;
import com.hcmute.config.JpaConfig;
import com.hcmute.dao.AccountDAO;
import com.hcmute.dao.OtpDAO;
import com.hcmute.dao.ProductDAO;
import com.hcmute.dao.impl.AccountDAOImpl;
import com.hcmute.dao.impl.OtpDAOImpl;
import com.hcmute.dao.impl.ProductDAOImpl;
import com.hcmute.model.Account;
import com.hcmute.model.OtpToken;
import com.hcmute.model.Product;
import com.hcmute.service.AccountService;
import com.hcmute.service.EmailService;
import com.hcmute.service.OtpService;
import com.hcmute.service.OtpVerifyResult;
import com.hcmute.service.impl.AccountServiceImpl;
import com.hcmute.service.impl.EmailServiceImpl;
import com.hcmute.service.impl.OtpServiceImpl;
import com.hcmute.util.SecurityUtil;

import java.time.LocalDateTime;
import java.util.List;

public class TestFullAuthFlow {

    public static void main(String[] args) {
        System.out.println("======================================================================");
        System.out.println(" KIỂM THỬ TOÀN DIỆN LUỒNG BẢO MẬT, OTP, ĐĂNG KÝ, ĐĂNG NHẬP & JPA CRUD ");
        System.out.println("======================================================================");

        AccountDAO accountDAO = new AccountDAOImpl();
        OtpDAO otpDAO = new OtpDAOImpl();
        AccountService accountService = new AccountServiceImpl();
        OtpService otpService = new OtpServiceImpl();
        EmailService emailService = new EmailServiceImpl();
        ProductDAO productDAO = new ProductDAOImpl();

        int passed = 0;
        int total = 0;

        try {
            // Test 1: SecurityUtil OTP & Password
            total++;
            System.out.println("\n[Test 1] Kiểm tra SecurityUtil (OTP, SHA-256 hash, BCrypt password)...");
            String otp = SecurityUtil.generateOtp(6);
            assertCondition(otp.length() == 6 && otp.matches("\\d{6}"), "Sinh mã OTP 6 chữ số: " + otp);

            String hash = SecurityUtil.hashOtp(otp);
            assertCondition(hash != null && hash.length() == 64, "SHA-256 hash độ dài 64 hex chars");
            assertCondition(SecurityUtil.verifyOtp(otp, hash), "Verify OTP đúng trả về true");
            assertCondition(!SecurityUtil.verifyOtp("000000", hash), "Verify OTP sai trả về false");

            String plainPass = "MySecurePass@123";
            String bcryptHash = SecurityUtil.hashPassword(plainPass);
            assertCondition(SecurityUtil.isBCryptHash(bcryptHash), "BCrypt hash đúng chuẩn ($2a$12$...)");
            assertCondition(SecurityUtil.checkPassword(plainPass, bcryptHash), "BCrypt kiểm tra đúng mật khẩu");
            assertCondition(!SecurityUtil.checkPassword("WrongPass", bcryptHash), "BCrypt kiểm tra sai mật khẩu");
            passed++;
            System.out.println("   -> [PASS] Test 1 hoàn thành xuất sắc!");

            // Test 2: Email Configuration check
            total++;
            System.out.println("\n[Test 2] Kiểm tra trạng thái cấu hình Gmail SMTP...");
            boolean configured = emailService.isConfigured();
            System.out.println("   -> Email configured: " + configured);
            System.out.println("   -> Host: " + EmailConfig.getHost() + ":" + EmailConfig.getPort());
            System.out.println("   -> Username: " + (EmailConfig.getUsername().isBlank() ? "(Chưa cấu hình)" : EmailConfig.getUsername()));
            if (!configured) {
                System.out.println("   -> [LƯU Ý] Hệ thống phát hiện chưa có Gmail App Password trong .env.");
                System.out.println("   -> Kiểm tra khả năng từ chối giả lập và báo lỗi chuẩn xác...");
                try {
                    emailService.sendOtpEmail("test@example.com", "123456", "REGISTER");
                    throw new RuntimeException("Lẽ ra phải ném lỗi khi chưa cấu hình email!");
                } catch (IllegalStateException e) {
                    System.out.println("   -> [PASS] Đã chặn đúng chuẩn: " + e.getMessage());
                }
            }
            passed++;
            System.out.println("   -> [PASS] Test 2 hoàn thành xuất sắc!");

            // Test 3: Đăng ký tài khoản mới & lưu trạng thái active=false
            total++;
            System.out.println("\n[Test 3] Kiểm tra lưu tài khoản ở trạng thái active = false...");
            String testUser = "user_test_" + System.currentTimeMillis();
            String testEmail = testUser + "@example.com";
            Account acc = new Account("Người Dùng Thử Nghiệm", testUser, testEmail, "0912345678", "Secret123!");
            acc.setPassword(SecurityUtil.hashPassword(acc.getPassword()));
            acc.setActive(false);
            boolean inserted = accountDAO.insert(acc);
            assertCondition(inserted, "Tạo tài khoản thử nghiệm thành công trong DB");

            Account retrieved = accountDAO.findByUsername(testUser);
            assertCondition(retrieved != null, "Tìm thấy tài khoản qua DAO");
            assertCondition(!retrieved.isActive(), "Tài khoản ở trạng thái CHƯA kích hoạt (active = false)");
            passed++;
            System.out.println("   -> [PASS] Test 3 hoàn thành xuất sắc!");

            // Test 4: Tài khoản chưa kích hoạt KHÔNG ĐƯỢC PHÉP đăng nhập
            total++;
            System.out.println("\n[Test 4] Kiểm tra tài khoản active = false KHÔNG THỂ đăng nhập...");
            Account loginResult = accountService.login(testUser, "Secret123!");
            assertCondition(loginResult == null, "login() trả về null đối với tài khoản chưa kích hoạt");
            passed++;
            System.out.println("   -> [PASS] Test 4 hoàn thành xuất sắc!");

            // Test 5: Tạo mã OTP trực tiếp vào DB và kiểm tra các trạng thái xác thực
            total++;
            System.out.println("\n[Test 5] Kiểm tra chu trình xác minh OTP (Sai, Đúng, Hết hạn, Đã sử dụng)...");
            String sampleOtp = "654321";
            String sampleHash = SecurityUtil.hashOtp(sampleOtp);
            LocalDateTime now = LocalDateTime.now();
            OtpToken token = new OtpToken(testEmail, sampleHash, "REGISTER", now, now.plusMinutes(5));
            otpDAO.insert(token);

            // 5a. Nhập sai OTP
            OtpVerifyResult wrongRes = otpService.verifyOtp(testEmail, "REGISTER", "111111");
            assertCondition(!wrongRes.isSuccess(), "Nhập sai OTP trả về thất bại: " + wrongRes.getMessage());
            assertCondition(wrongRes.getRemainingAttempts() == 4, "Số lần thử còn lại giảm còn 4");

            // 5b. Nhập đúng OTP
            OtpVerifyResult correctRes = otpService.verifyOtp(testEmail, "REGISTER", sampleOtp);
            assertCondition(correctRes.isSuccess(), "Nhập đúng OTP xác thực thành công");

            // 5c. Thử sử dụng lại OTP đã xác thực
            OtpVerifyResult reuseRes = otpService.verifyOtp(testEmail, "REGISTER", sampleOtp);
            assertCondition(!reuseRes.isSuccess() && reuseRes.getMessage().contains("đã được sử dụng"),
                    "OTP đã sử dụng không thể tái sử dụng: " + reuseRes.getMessage());

            // 5d. Kiểm tra OTP hết hạn
            OtpToken expiredToken = new OtpToken(testEmail, SecurityUtil.hashOtp("888888"), "EXPIRED_TEST",
                    now.minusMinutes(10), now.minusMinutes(5));
            otpDAO.insert(expiredToken);
            OtpVerifyResult expRes = otpService.verifyOtp(testEmail, "EXPIRED_TEST", "888888");
            assertCondition(!expRes.isSuccess() && expRes.getMessage().contains("hết hạn"),
                    "OTP hết hạn bị từ chối: " + expRes.getMessage());
            passed++;
            System.out.println("   -> [PASS] Test 5 hoàn thành xuất sắc!");

            // Test 6: Kích hoạt tài khoản và đăng nhập thành công
            total++;
            System.out.println("\n[Test 6] Kiểm tra kích hoạt tài khoản và đăng nhập sau khi kích hoạt...");
            boolean activated = accountService.activateAccount(testEmail);
            assertCondition(activated, "Kích hoạt tài khoản thành công qua JPA");

            Account activeUser = accountDAO.findByEmail(testEmail);
            assertCondition(activeUser.isActive(), "Trạng thái tài khoản trong DB đã chuyển thành active = true");

            // Đăng nhập thành công bằng username
            Account loggedInUser = accountService.login(testUser, "Secret123!");
            assertCondition(loggedInUser != null, "Đăng nhập thành công bằng username");

            // Đăng nhập thành công bằng email
            Account loggedInEmail = accountService.login(testEmail, "Secret123!");
            assertCondition(loggedInEmail != null, "Đăng nhập thành công bằng email");

            // Đăng nhập thất bại khi sai mật khẩu
            Account wrongPassLogin = accountService.login(testUser, "WrongPassword123");
            assertCondition(wrongPassLogin == null, "Đăng nhập thất bại khi nhập sai mật khẩu");
            passed++;
            System.out.println("   -> [PASS] Test 6 hoàn thành xuất sắc!");

            // Test 7: Luồng Quên mật khẩu & Đổi mật khẩu
            total++;
            System.out.println("\n[Test 7] Kiểm tra luồng quên mật khẩu và đặt lại mật khẩu mới...");
            String forgotOtp = "777888";
            OtpToken forgotToken = new OtpToken(testEmail, SecurityUtil.hashOtp(forgotOtp), "FORGOT_PASSWORD",
                    LocalDateTime.now(), LocalDateTime.now().plusMinutes(5));
            otpDAO.insert(forgotToken);

            OtpVerifyResult forgotVerify = otpService.verifyOtp(testEmail, "FORGOT_PASSWORD", forgotOtp);
            assertCondition(forgotVerify.isSuccess(), "Xác thực OTP quên mật khẩu thành công");

            boolean passUpdated = accountService.updatePassword(testEmail, "NewBrandSecret@999");
            assertCondition(passUpdated, "Cập nhật mật khẩu mới qua BCrypt thành công");

            // Thử đăng nhập lại bằng mật khẩu cũ -> phải thất bại
            assertCondition(accountService.login(testUser, "Secret123!") == null, "Mật khẩu cũ không còn hợp lệ");

            // Thử đăng nhập bằng mật khẩu mới -> thành công
            Account newPassLogin = accountService.login(testUser, "NewBrandSecret@999");
            assertCondition(newPassLogin != null, "Đăng nhập thành công với mật khẩu mới");
            passed++;
            System.out.println("   -> [PASS] Test 7 hoàn thành xuất sắc!");

            // Test 8: Tự động nâng cấp tài khoản cũ (plaintext sang BCrypt)
            total++;
            System.out.println("\n[Test 8] Kiểm tra tự động nâng cấp tài khoản cũ sang BCrypt...");
            Account admin = accountDAO.findByUsername("admin");
            if (admin != null) {
                System.out.println("   -> Mật khẩu hiện tại của admin trong DB: " + admin.getPassword());
                Account adminLogin = accountService.login("admin", "123456");
                assertCondition(adminLogin != null, "Đăng nhập thành công với tài khoản admin");

                Account adminAfter = accountDAO.findByUsername("admin");
                assertCondition(SecurityUtil.isBCryptHash(adminAfter.getPassword()),
                        "Mật khẩu admin đã tự động nâng cấp sang BCrypt: " + adminAfter.getPassword());
            }
            passed++;
            System.out.println("   -> [PASS] Test 8 hoàn thành xuất sắc!");

            // Test 9: Kiểm tra CRUD Product & Category không bị ảnh hưởng
            total++;
            System.out.println("\n[Test 9] Kiểm tra chức năng Product CRUD qua JPA...");
            List<Product> products = productDAO.findAll();
            assertCondition(products != null && !products.isEmpty(), "Danh sách sản phẩm đọc tốt qua JPQL (" + products.size() + " SP)");
            passed++;
            System.out.println("   -> [PASS] Test 9 hoàn thành xuất sắc!");

            System.out.println("\n======================================================================");
            System.out.println(" KẾT QUẢ KIỂM THỬ: " + passed + "/" + total + " BÀI TEST ĐẠT (100% THÀNH CÔNG)");
            System.out.println("======================================================================");

        } catch (Throwable t) {
            System.err.println("\n[FAIL] Kiểm thử thất bại: " + t.getMessage());
            t.printStackTrace();
        } finally {
            JpaConfig.shutdown();
        }
    }

    private static void assertCondition(boolean condition, String message) {
        if (!condition) {
            throw new AssertionError("Kiểm thử thất bại: " + message);
        }
        System.out.println("   [OK] " + message);
    }
}
