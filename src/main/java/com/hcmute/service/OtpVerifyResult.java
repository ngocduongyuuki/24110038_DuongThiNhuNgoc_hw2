package com.hcmute.service;

public class OtpVerifyResult {
    private final boolean success;
    private final String message;
    private final int remainingAttempts;

    public OtpVerifyResult(boolean success, String message, int remainingAttempts) {
        this.success = success;
        this.message = message;
        this.remainingAttempts = remainingAttempts;
    }

    public static OtpVerifyResult ok(String message) {
        return new OtpVerifyResult(true, message, 0);
    }

    public static OtpVerifyResult fail(String message, int remainingAttempts) {
        return new OtpVerifyResult(false, message, remainingAttempts);
    }

    public boolean isSuccess() {
        return success;
    }

    public String getMessage() {
        return message;
    }

    public int getRemainingAttempts() {
        return remainingAttempts;
    }
}
