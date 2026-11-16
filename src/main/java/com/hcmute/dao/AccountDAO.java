package com.hcmute.dao;

import com.hcmute.model.Account;

public interface AccountDAO {
    Account findByUsername(String username);
    Account findByEmail(String email);
    Account findByUsernameOrEmail(String identifier);
    boolean insert(Account account);
    boolean update(Account account);
}
