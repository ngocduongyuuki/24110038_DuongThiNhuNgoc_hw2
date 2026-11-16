package com.hcmute.dao;

import com.hcmute.model.Account;

public interface AccountDAO {
    Account findByUsername(String username);
    Account findByEmail(String email);
    boolean insert(Account account);
}
