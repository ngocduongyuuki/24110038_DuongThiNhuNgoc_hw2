package com.hcmute.service;

public interface OtpService {
    String generateAndSendOtp(String email, String purpose);
    OtpVerifyResult verifyOtp(String email, String purpose, String inputOtp);
    long getRemainingCooldownSeconds(String email, String purpose);
}
