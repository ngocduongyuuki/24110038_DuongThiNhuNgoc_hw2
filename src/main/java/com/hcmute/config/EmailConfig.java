package com.hcmute.config;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

public class EmailConfig {

    static {
        // Đảm bảo Java luôn ưu tiên IPv4 trên Windows/Tomcat để tránh lỗi timeout khi phân giải IPv6 của smtp.gmail.com
        System.setProperty("java.net.preferIPv4Stack", "true");
    }

    private static Map<String, String> cachedEnv = null;
    private static long lastLoadedTime = 0;
    private static final long CACHE_DURATION_MS = 3000; // 3 giây để nhận cập nhật file .env nhanh chóng

    public static String getHost() {
        String val = resolveConfig("MAIL_HOST", "mail.smtp.host");
        return (val != null && !val.isBlank()) ? val.trim() : "smtp.gmail.com";
    }

    public static int getPort() {
        String val = resolveConfig("MAIL_PORT", "mail.smtp.port");
        if (val != null && !val.isBlank()) {
            try {
                return Integer.parseInt(val.trim());
            } catch (NumberFormatException ignored) {}
        }
        return 587;
    }

    public static String getUsername() {
        String val = resolveConfig("MAIL_USERNAME", "mail.smtp.user");
        return (val != null && !val.isBlank()) ? val.trim() : "";
    }

    public static String getPassword() {
        String val = resolveConfig("MAIL_PASSWORD", "mail.smtp.password");
        if (val != null && !val.isBlank()) {
            // Xóa mọi khoảng trắng nếu người dùng copy dạng "xxxx xxxx xxxx xxxx" từ Google App Password
            return val.trim().replace(" ", "");
        }
        return "";
    }

    public static String getFrom() {
        String val = resolveConfig("MAIL_FROM", "mail.smtp.from");
        if (val != null && !val.isBlank()) {
            return val.trim();
        }
        return getUsername();
    }

    public static boolean isAuth() {
        String val = resolveConfig("MAIL_SMTP_AUTH", "mail.smtp.auth");
        return val == null || !val.equalsIgnoreCase("false");
    }

    public static boolean isStartTls() {
        String val = resolveConfig("MAIL_SMTP_STARTTLS_ENABLE", "mail.smtp.starttls.enable");
        return val == null || !val.equalsIgnoreCase("false");
    }

    public static boolean isConfigured() {
        String user = getUsername();
        String pass = getPassword();
        return !user.isBlank() && !pass.isBlank()
                && !user.contains("your_email") && !pass.contains("your_app_password");
    }

    private static synchronized String resolveConfig(String envKey, String propKey) {
        // 1. Ưu tiên biến môi trường hệ thống
        String val = System.getenv(envKey);
        if (val != null && !val.isBlank()) return val;

        // 2. Thuộc tính JVM (-D)
        val = System.getProperty(envKey);
        if (val != null && !val.isBlank()) return val;
        val = System.getProperty(propKey);
        if (val != null && !val.isBlank()) return val;

        // 3. File .env cục bộ
        Map<String, String> env = getLocalEnvironment();
        if (env != null) {
            val = env.get(envKey);
            if (val != null && !val.isBlank()) return val;
            val = env.get(propKey);
            if (val != null && !val.isBlank()) return val;
        }
        return null;
    }

    private static synchronized Map<String, String> getLocalEnvironment() {
        long now = System.currentTimeMillis();
        if (cachedEnv == null || (now - lastLoadedTime) > CACHE_DURATION_MS) {
            cachedEnv = loadLocalEnvironment();
            lastLoadedTime = now;
        }
        return cachedEnv;
    }

    private static Map<String, String> loadLocalEnvironment() {
        Map<String, String> map = new HashMap<>();

        String catalinaBase = System.getProperty("catalina.base", "");
        String catalinaHome = System.getProperty("catalina.home", "");
        String userDir = System.getProperty("user.dir", "");

        String[] searchPaths = {
            ".env",
            "mail.properties",
            "db.properties",
            userDir + File.separator + ".env",
            catalinaBase + File.separator + ".env",
            catalinaBase + File.separator + "conf" + File.separator + ".env",
            catalinaHome + File.separator + ".env",
            new File(userDir).getParent() != null
                ? new File(userDir).getParent() + File.separator + ".env" : ""
        };

        for (String pathStr : searchPaths) {
            if (pathStr == null || pathStr.isBlank()) continue;
            File file = new File(pathStr);
            if (file.exists() && file.isFile()) {
                loadFileIntoMap(file, map);
            }
        }

        try (InputStream is = EmailConfig.class.getClassLoader().getResourceAsStream(".env")) {
            if (is != null) {
                readLinesIntoMap(is, map);
            }
        } catch (Exception ignored) {}

        return map;
    }

    private static void loadFileIntoMap(File file, Map<String, String> map) {
        try (InputStream is = new FileInputStream(file)) {
            readLinesIntoMap(is, map);
        } catch (Exception ignored) {}
    }

    private static void readLinesIntoMap(InputStream is, Map<String, String> map) {
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
            String line;
            while ((line = reader.readLine()) != null) {
                line = line.trim();
                if (line.isEmpty() || line.startsWith("#")) continue;
                int eq = line.indexOf('=');
                if (eq > 0) {
                    String key = line.substring(0, eq).trim();
                    String val = line.substring(eq + 1).trim();
                    if ((val.startsWith("\"") && val.endsWith("\"")) || (val.startsWith("'") && val.endsWith("'"))) {
                        val = val.substring(1, val.length() - 1);
                    }
                    map.put(key, val);
                }
            }
        } catch (Exception ignored) {}
    }
}
