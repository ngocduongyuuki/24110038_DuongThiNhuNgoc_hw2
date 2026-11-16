package com.hcmute.service;

import com.hcmute.model.Account;

public interface AccountService {
    Account login(String username, String password);
    String register(Account account, String confirmPassword);
}
