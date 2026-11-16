package com.hcmute.dao;

import com.hcmute.model.OtpToken;

public interface OtpDAO {
    boolean insert(OtpToken token);
    boolean update(OtpToken token);
    OtpToken findLatestByEmailAndPurpose(String email, String purpose);
    void invalidatePreviousOtps(String email, String purpose);
}
