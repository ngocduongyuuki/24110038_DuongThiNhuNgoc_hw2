package com.hcmute.service;

public interface EmailService {
    boolean isConfigured();
    void sendOtpEmail(String toEmail, String otpCode, String purpose) throws Exception;
}
