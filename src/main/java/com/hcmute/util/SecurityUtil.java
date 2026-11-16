package com.hcmute.util;

import org.mindrot.jbcrypt.BCrypt;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Base64;
import java.util.regex.Pattern;

public class SecurityUtil {

    private static final SecureRandom SECURE_RANDOM = new SecureRandom();
    private static final Pattern BCRYPT_PATTERN = Pattern.compile("^\\$2[aby]\\$\\d{2}\\$[./A-Za-z0-9]{53}$");

    public static String generateOtp(int length) {
        if (length <= 0) length = 6;
        int min = (int) Math.pow(10, length - 1);
        int max = (int) Math.pow(10, length) - 1;
        int num = min + SECURE_RANDOM.nextInt(max - min + 1);
        return String.valueOf(num);
    }

    public static String hashOtp(String otp) {
        if (otp == null) return null;
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] digest = md.digest(otp.trim().getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : digest) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Thuật toán SHA-256 không khả dụng", e);
        }
    }

    public static boolean verifyOtp(String inputOtp, String storedHash) {
        if (inputOtp == null || storedHash == null) return false;
        String inputHash = hashOtp(inputOtp.trim());
        return MessageDigest.isEqual(
            inputHash.getBytes(StandardCharsets.UTF_8),
            storedHash.getBytes(StandardCharsets.UTF_8)
        );
    }

    public static String hashPassword(String password) {
        if (password == null) return null;
        return BCrypt.hashpw(password, BCrypt.gensalt(12));
    }

    public static boolean checkPassword(String plainPassword, String hashedPassword) {
        if (plainPassword == null || hashedPassword == null) return false;
        try {
            return BCrypt.checkpw(plainPassword, hashedPassword);
        } catch (IllegalArgumentException e) {
            return false;
        }
    }

    public static boolean isBCryptHash(String password) {
        if (password == null || password.length() != 60) return false;
        return BCRYPT_PATTERN.matcher(password).matches();
    }

    public static String generateSecureToken() {
        byte[] randomBytes = new byte[32];
        SECURE_RANDOM.nextBytes(randomBytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(randomBytes);
    }
}
