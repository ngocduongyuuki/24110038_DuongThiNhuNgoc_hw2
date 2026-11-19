package com.hcmute.service.impl;

import com.hcmute.dao.AccountDAO;
import com.hcmute.dao.impl.AccountDAOImpl;
import com.hcmute.model.Account;
import com.hcmute.service.AccountService;
import com.hcmute.service.OtpService;
import com.hcmute.util.SecurityUtil;

import java.util.regex.Pattern;

public class AccountServiceImpl implements AccountService {

    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}$");
    private static final Pattern USERNAME_PATTERN = Pattern.compile("^[A-Za-z0-9._-]+$");
    private static final Pattern PHONE_PATTERN = Pattern.compile("^[+0-9]{8,15}$");

    private final AccountDAO accountDAO = new AccountDAOImpl();
    private final OtpService otpService = new OtpServiceImpl();

    @Override
    public Account login(String usernameOrEmail, String password) {
        if (usernameOrEmail == null || password == null) return null;

        Account account = accountDAO.findByUsernameOrEmail(usernameOrEmail.trim());
        if (account == null) return null;

        // Chỉ cho phép tài khoản đã kích hoạt đăng nhập
        if (!account.isActive()) return null;

        boolean passwordMatch;
        if (SecurityUtil.isBCryptHash(account.getPassword())) {
            passwordMatch = SecurityUtil.checkPassword(password, account.getPassword());
        } else {
            // Tài khoản cũ dùng plaintext — so sánh trực tiếp
            // Nếu khớp, tự động nâng cấp lên BCrypt
            passwordMatch = account.getPassword().equals(password);
            if (passwordMatch) {
                account.setPassword(SecurityUtil.hashPassword(password));
                accountDAO.update(account);
            }
        }

        return passwordMatch ? account : null;
    }

    @Override
    public String register(Account account, String confirmPassword) {
        if (account == null) {
            return "Dữ liệu đăng ký không hợp lệ.";
        }

        // 1. Kiểm tra Họ và tên
        String fullName = account.getFullName();
        if (fullName == null || fullName.isBlank()) {
            return "Họ và tên không được để trống.";
        }
        fullName = fullName.trim();
        if (fullName.length() > 100) {
            return "Họ và tên không được vượt quá 100 ký tự.";
        }

        // 2. Kiểm tra Tên đăng nhập (username)
        String username = account.getUsername();
        if (username == null || username.isBlank()) {
            return "Tên đăng nhập không được để trống.";
        }
        username = username.trim();
        if (username.length() > 50) {
            return "Tên đăng nhập không được vượt quá 50 ký tự.";
        }
        if (!USERNAME_PATTERN.matcher(username).matches()) {
            return "Tên đăng nhập chỉ được chứa các ký tự chữ cái không dấu (a-z, A-Z), chữ số (0-9), dấu gạch dưới (_), gạch ngang (-) hoặc chấm (.).";
        }

        // 3. Kiểm tra Email
        String email = account.getEmail();
        if (email == null || email.isBlank()) {
            return "Email không được để trống.";
        }
        email = email.trim().toLowerCase();
        if (email.length() > 100) {
            return "Email không được vượt quá 100 ký tự.";
        }
        if (!EMAIL_PATTERN.matcher(email).matches()) {
            return "Địa chỉ email không đúng định dạng.";
        }

        // 4. Kiểm tra và chuẩn hóa Số điện thoại (phone)
        String phone = account.getPhone();
        if (phone != null && !phone.isBlank()) {
            phone = phone.trim().replaceAll("\\s+", "");
            if (phone.length() > 15) {
                return "Số điện thoại không được vượt quá 15 ký tự.";
            }
            if (!PHONE_PATTERN.matcher(phone).matches()) {
                return "Số điện thoại không đúng định dạng (chỉ chứa chữ số và dấu +, từ 8 đến 15 ký tự).";
            }
        } else {
            phone = null;
        }

        // 5. Kiểm tra Mật khẩu
        String password = account.getPassword();
        if (password == null || password.length() < 6) {
            return "Mật khẩu phải có ít nhất 6 ký tự.";
        }
        if (!password.equals(confirmPassword)) {
            return "Mật khẩu xác nhận không khớp.";
        }

        // 6. Kiểm tra tài khoản đã tồn tại trong database (cả active và inactive)
        Account existingUser = accountDAO.findByUsername(username);
        Account existingEmail = accountDAO.findByEmail(email);

        // Trường hợp A: Cả username và email cùng thuộc về một tài khoản CHƯA kích hoạt
        if (existingUser != null && existingEmail != null && existingUser.getId() == existingEmail.getId()) {
            if (existingUser.isActive()) {
                return "Tên đăng nhập đã tồn tại.";
            }
            // Tài khoản chưa kích hoạt trước đó -> Gửi lại mã OTP để kích hoạt
            // KHÔNG tạo thêm bản ghi trùng, không ghi đè dữ liệu khi chưa xác minh
            String otpError = otpService.generateAndSendOtp(email, "REGISTER");
            if (otpError != null) {
                return otpError;
            }
            return null; // Chuyển sang verify-otp thành công
        }

        // Trường hợp B: Tên đăng nhập đã tồn tại (thuộc tài khoản khác, dù active hay inactive)
        if (existingUser != null) {
            return "Tên đăng nhập đã tồn tại.";
        }

        // Trường hợp C: Email đã thuộc một tài khoản đã kích hoạt (active = true)
        if (existingEmail != null && existingEmail.isActive()) {
            return "Email đã được sử dụng.";
        }

        // Trường hợp D: Email thuộc tài khoản chưa kích hoạt (nhưng người dùng nhập username khác)
        if (existingEmail != null && !existingEmail.isActive()) {
            // Không tự ý ghi đè username tài khoản inactive bằng dữ liệu mới
            // Xử lý gửi lại mã OTP cho email đó để người dùng kích hoạt tài khoản đã tạo
            String otpError = otpService.generateAndSendOtp(email, "REGISTER");
            if (otpError != null) {
                return otpError;
            }
            return null; // Chuyển sang verify-otp
        }

        // Trường hợp E: Cả username và email đều chưa từng tồn tại -> Tạo tài khoản mới ở trạng thái inactive
        account.setFullName(fullName);
        account.setUsername(username);
        account.setEmail(email);
        account.setPhone(phone);
        account.setPassword(SecurityUtil.hashPassword(password));
        account.setActive(false);

        boolean inserted = accountDAO.insert(account);
        if (!inserted) {
            return "Đăng ký thất bại, không thể lưu dữ liệu vào cơ sở dữ liệu.";
        }

        // Chỉ gửi OTP sau khi lưu tài khoản thành công vào database
        String otpError = otpService.generateAndSendOtp(email, "REGISTER");
        if (otpError != null) {
            return otpError;
        }

        return null; // Đăng ký và gửi OTP thành công!
    }

    @Override
    public Account findByUsernameOrEmail(String identifier) {
        if (identifier == null || identifier.isBlank()) return null;
        return accountDAO.findByUsernameOrEmail(identifier.trim());
    }

    @Override
    public Account findByEmail(String email) {
        if (email == null || email.isBlank()) return null;
        return accountDAO.findByEmail(email.trim());
    }

    @Override
    public boolean activateAccount(String email) {
        if (email == null || email.isBlank()) return false;
        Account account = accountDAO.findByEmail(email.trim());
        if (account == null) return false;
        account.setActive(true);
        return accountDAO.update(account);
    }

    @Override
    public boolean updatePassword(String email, String newPassword) {
        if (email == null || newPassword == null || newPassword.length() < 6) return false;
        Account account = accountDAO.findByEmail(email.trim());
        if (account == null) return false;
        account.setPassword(SecurityUtil.hashPassword(newPassword));
        return accountDAO.update(account);
    }

    @Override
    public Account findById(int id) {
        return accountDAO.findById(id);
    }

    @Override
    public String updateProfile(int accountId, String fullName, String phone) {
        if (fullName == null || fullName.isBlank()) {
            return "Họ và tên không được để trống.";
        }
        fullName = fullName.trim();
        if (fullName.length() > 100) {
            return "Họ và tên không được vượt quá 100 ký tự.";
        }

        if (phone != null && !phone.isBlank()) {
            phone = phone.trim().replaceAll("\\s+", "");
            if (phone.length() > 15) {
                return "Số điện thoại không được vượt quá 15 ký tự.";
            }
            if (!PHONE_PATTERN.matcher(phone).matches()) {
                return "Số điện thoại không đúng định dạng (chỉ chứa chữ số và dấu +, từ 8 đến 15 ký tự).";
            }
        } else {
            phone = null;
        }

        Account account = accountDAO.findById(accountId);
        if (account == null) return "Tài khoản không tồn tại.";

        account.setFullName(fullName);
        account.setPhone(phone);
        boolean ok = accountDAO.update(account);
        return ok ? null : "Cập nhật thất bại, vui lòng thử lại.";
    }

    @Override
    public boolean updateEmail(int accountId, String newEmail) {
        if (newEmail == null || newEmail.isBlank()) return false;
        Account account = accountDAO.findById(accountId);
        if (account == null) return false;
        account.setEmail(newEmail.trim().toLowerCase());
        return accountDAO.update(account);
    }

    @Override
    public boolean updateProfileImage(int accountId, String imageUrl) {
        if (imageUrl == null || imageUrl.isBlank()) return false;
        Account account = accountDAO.findById(accountId);
        if (account == null) return false;
        account.setProfileImage(imageUrl.trim());
        return accountDAO.update(account);
    }
}
