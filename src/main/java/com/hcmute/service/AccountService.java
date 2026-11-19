package com.hcmute.service;

import com.hcmute.model.Account;

public interface AccountService {
    Account login(String usernameOrEmail, String password);
    String register(Account account, String confirmPassword);
    Account findByUsernameOrEmail(String identifier);
    Account findByEmail(String email);
    Account findById(int id);
    boolean activateAccount(String email);
    boolean updatePassword(String email, String newPassword);
    /** Cập nhật fullName và phone cho tài khoản */
    String updateProfile(int accountId, String fullName, String phone);
    /** Cập nhật email sau khi OTP đã xác minh */
    boolean updateEmail(int accountId, String newEmail);
    /** Lưu URL ảnh đại diện từ Cloudinary */
    boolean updateProfileImage(int accountId, String imageUrl);
}
