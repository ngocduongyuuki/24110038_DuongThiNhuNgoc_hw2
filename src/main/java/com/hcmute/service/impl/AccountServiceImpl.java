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
        if (account.getFullName() == null || account.getFullName().isBlank()) {
            return "Họ và tên không được để trống.";
        }
        if (account.getUsername() == null || account.getUsername().isBlank()) {
            return "Tên đăng nhập không được để trống.";
        }
        if (account.getEmail() == null || account.getEmail().isBlank()) {
            return "Email không được để trống.";
        }
        String emailTrimmed = account.getEmail().trim();
        if (!EMAIL_PATTERN.matcher(emailTrimmed).matches()) {
            return "Địa chỉ email không đúng định dạng.";
        }
        if (account.getPassword() == null || account.getPassword().length() < 6) {
            return "Mật khẩu phải có ít nhất 6 ký tự.";
        }
        if (!account.getPassword().equals(confirmPassword)) {
            return "Mật khẩu xác nhận không khớp.";
        }

        String usernameTrimmed = account.getUsername().trim();
        Account existingUser = accountDAO.findByUsername(usernameTrimmed);
        if (existingUser != null && existingUser.isActive()) {
            return "Tên đăng nhập đã tồn tại.";
        }

        Account existingEmail = accountDAO.findByEmail(emailTrimmed);
        if (existingEmail != null && existingEmail.isActive()) {
            return "Email đã được sử dụng.";
        }

        String hashedPassword = SecurityUtil.hashPassword(account.getPassword());

        if (existingEmail != null && !existingEmail.isActive()) {
            // Tài khoản chưa kích hoạt trước đó với email này -> cập nhật lại thông tin mới
            existingEmail.setFullName(account.getFullName().trim());
            existingEmail.setUsername(usernameTrimmed);
            existingEmail.setPhone(account.getPhone() != null ? account.getPhone().trim() : null);
            existingEmail.setPassword(hashedPassword);
            accountDAO.update(existingEmail);
        } else if (existingUser != null && !existingUser.isActive()) {
            // Tài khoản chưa kích hoạt trước đó với username này -> cập nhật lại thông tin mới
            existingUser.setFullName(account.getFullName().trim());
            existingUser.setEmail(emailTrimmed);
            existingUser.setPhone(account.getPhone() != null ? account.getPhone().trim() : null);
            existingUser.setPassword(hashedPassword);
            accountDAO.update(existingUser);
        } else {
            // Lưu tài khoản mới ở trạng thái chưa kích hoạt (active = false)
            account.setFullName(account.getFullName().trim());
            account.setUsername(usernameTrimmed);
            account.setEmail(emailTrimmed);
            account.setPassword(hashedPassword);
            account.setActive(false);
            boolean inserted = accountDAO.insert(account);
            if (!inserted) {
                return "Đăng ký thất bại, không thể lưu dữ liệu vào cơ sở dữ liệu.";
            }
        }

        // Tạo mã OTP và gửi qua email
        String otpError = otpService.generateAndSendOtp(emailTrimmed, "REGISTER");
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
}
