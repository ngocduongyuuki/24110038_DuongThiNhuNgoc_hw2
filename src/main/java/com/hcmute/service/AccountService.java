package com.hcmute.service;

import com.hcmute.model.Account;

public interface AccountService {
    Account login(String usernameOrEmail, String password);
    String register(Account account, String confirmPassword);
    Account findByUsernameOrEmail(String identifier);
    Account findByEmail(String email);
    boolean activateAccount(String email);
    boolean updatePassword(String email, String newPassword);
}
