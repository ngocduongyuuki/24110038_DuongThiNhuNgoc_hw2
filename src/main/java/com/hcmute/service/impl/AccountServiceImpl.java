package com.hcmute.service.impl;

import com.hcmute.dao.AccountDAO;
import com.hcmute.dao.impl.AccountDAOImpl;
import com.hcmute.model.Account;
import com.hcmute.service.AccountService;

public class AccountServiceImpl implements AccountService {

    private final AccountDAO accountDAO = new AccountDAOImpl();

    @Override
    public Account login(String username, String password) {
        if (username == null || password == null) return null;

        Account account = accountDAO.findByUsername(username.trim());
        if (account != null && account.getPassword().equals(password)) {
            return account;
        }
        return null;
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
        if (account.getPassword() == null || account.getPassword().length() < 6) {
            return "Mật khẩu phải có ít nhất 6 ký tự.";
        }
        if (!account.getPassword().equals(confirmPassword)) {
            return "Mật khẩu xác nhận không khớp.";
        }
        if (accountDAO.findByUsername(account.getUsername()) != null) {
            return "Tên đăng nhập đã tồn tại.";
        }
        if (accountDAO.findByEmail(account.getEmail()) != null) {
            return "Email đã được sử dụng.";
        }

        boolean success = accountDAO.insert(account);
        return success ? null : "Đăng ký thất bại, vui lòng thử lại.";
    }
}
