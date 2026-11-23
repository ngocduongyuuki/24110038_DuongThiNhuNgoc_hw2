package com.hcmute.config;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Cấu hình Cloudinary từ biến môi trường hoặc file .env / properties
 * Tuyệt đối không hard-code bất kỳ thông tin bí mật nào trong source code.
 *
 * Cách cấu hình (theo thứ tự ưu tiên):
 * 1. Biến môi trường hệ điều hành: CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET (hoặc CLOUDINARY_URL)
 * 2. JVM property: -DCLOUDINARY_CLOUD_NAME=...
 * 3. File .env hoặc cloudinary.properties trong thư mục Tomcat conf / project
 */
public class CloudinaryConfig {

    private static final Logger LOGGER = Logger.getLogger(CloudinaryConfig.class.getName());
    private static final long CACHE_DURATION_MS = 3000L; // Tự động kiểm tra thay đổi sau mỗi 3 giây

    private static volatile Cloudinary instance;
    private static String cachedConfigFingerprint = null;
    private static long lastCheckTime = 0L;

    public static synchronized Cloudinary getInstance() {
        long now = System.currentTimeMillis();
        if (instance == null || (now - lastCheckTime) > CACHE_DURATION_MS) {
            lastCheckTime = now;
            Map<String, String> env = loadEnvironment();
            String currentFingerprint = computeFingerprint(env);

            if (!Objects.equals(currentFingerprint, cachedConfigFingerprint) || instance == null) {
                cachedConfigFingerprint = currentFingerprint;
                instance = createInstance(env);
            }
        }
        return instance;
    }

    /**
     * Cho phép nạp lại cấu hình ngay lập tức khi biến môi trường hoặc file .env được cập nhật
     */
    public static synchronized void reload() {
        cachedConfigFingerprint = null;
        instance = null;
        lastCheckTime = 0L;
    }

    /**
     * Kiểm tra nhanh trạng thái cấu hình Cloudinary mà không throw exception
     */
    public static boolean isConfigured() {
        return getInstance() != null;
    }

    /**
     * Trả về danh sách tên biến còn thiếu để hỗ trợ thông báo (chỉ tên biến, không chứa giá trị)
     */
    public static List<String> getMissingVariables() {
        List<String> missing = new ArrayList<>();
        Map<String, String> env = loadEnvironment();

        String cloudinaryUrl = resolve(new String[]{"CLOUDINARY_URL", "cloudinary.url", "cloudinary_url"}, env);
        if (cloudinaryUrl != null && !cloudinaryUrl.isBlank() && !isPlaceholder(cloudinaryUrl)) {
            return missing; // Đầy đủ vì đã có CLOUDINARY_URL
        }

        String cloudName = resolve(new String[]{"CLOUDINARY_CLOUD_NAME", "cloudinary.cloud_name", "cloudinary.cloud-name", "cloud_name"}, env);
        String apiKey    = resolve(new String[]{"CLOUDINARY_API_KEY", "cloudinary.api_key", "cloudinary.api-key", "api_key"}, env);
        String apiSecret = resolve(new String[]{"CLOUDINARY_API_SECRET", "cloudinary.api_secret", "cloudinary.api-secret", "api_secret"}, env);

        if (cloudName == null || cloudName.isBlank() || isPlaceholder(cloudName)) {
            missing.add("CLOUDINARY_CLOUD_NAME");
        }
        if (apiKey == null || apiKey.isBlank() || isPlaceholder(apiKey)) {
            missing.add("CLOUDINARY_API_KEY");
        }
        if (apiSecret == null || apiSecret.isBlank() || isPlaceholder(apiSecret)) {
            missing.add("CLOUDINARY_API_SECRET");
        }

        return missing;
    }

    private static String computeFingerprint(Map<String, String> env) {
        String url = resolve(new String[]{"CLOUDINARY_URL", "cloudinary.url", "cloudinary_url"}, env);
        if (url != null && !url.isBlank() && !isPlaceholder(url)) {
            return "URL:" + url.hashCode();
        }
        String name = resolve(new String[]{"CLOUDINARY_CLOUD_NAME", "cloudinary.cloud_name", "cloudinary.cloud-name", "cloud_name"}, env);
        String key = resolve(new String[]{"CLOUDINARY_API_KEY", "cloudinary.api_key", "cloudinary.api-key", "api_key"}, env);
        String sec = resolve(new String[]{"CLOUDINARY_API_SECRET", "cloudinary.api_secret", "cloudinary.api-secret", "api_secret"}, env);
        if (name == null || key == null || sec == null) return "NONE";
        return name + ":" + key + ":" + sec.hashCode();
    }

    private static Cloudinary createInstance(Map<String, String> env) {
        // 1. Kiểm tra cấu hình dạng URL đầy đủ: CLOUDINARY_URL=cloudinary://api_key:api_secret@cloud_name
        String cloudinaryUrl = resolve(new String[]{"CLOUDINARY_URL", "cloudinary.url", "cloudinary_url"}, env);
        if (cloudinaryUrl != null && !cloudinaryUrl.isBlank() && !isPlaceholder(cloudinaryUrl)) {
            try {
                Cloudinary c = new Cloudinary(cloudinaryUrl.trim());
                LOGGER.info("Cloudinary đã được cấu hình thành công từ CLOUDINARY_URL.");
                return c;
            } catch (Exception e) {
                LOGGER.log(Level.WARNING, "Không thể khởi tạo Cloudinary từ CLOUDINARY_URL: " + e.getMessage(), e);
            }
        }

        // 2. Kiểm tra cấu hình 3 biến độc lập
        String cloudName = resolve(new String[]{"CLOUDINARY_CLOUD_NAME", "cloudinary.cloud_name", "cloudinary.cloud-name", "cloud_name"}, env);
        String apiKey    = resolve(new String[]{"CLOUDINARY_API_KEY", "cloudinary.api_key", "cloudinary.api-key", "api_key"}, env);
        String apiSecret = resolve(new String[]{"CLOUDINARY_API_SECRET", "cloudinary.api_secret", "cloudinary.api-secret", "api_secret"}, env);

        if (cloudName == null || cloudName.isBlank() || isPlaceholder(cloudName)
            || apiKey == null || apiKey.isBlank() || isPlaceholder(apiKey)
            || apiSecret == null || apiSecret.isBlank() || isPlaceholder(apiSecret)) {
            return null;
        }

        LOGGER.info("Cloudinary đã được khởi tạo thành công với Cloud: " + cloudName.trim());
        return new Cloudinary(ObjectUtils.asMap(
            "cloud_name", cloudName.trim(),
            "api_key",    apiKey.trim(),
            "api_secret", apiSecret.trim(),
            "secure",     true
        ));
    }

    private static boolean isPlaceholder(String val) {
        if (val == null) return true;
        String s = val.trim().toLowerCase();
        return s.startsWith("your_") || s.contains("your_cloudinary") || s.equals("none");
    }

    private static String resolve(String[] keys, Map<String, String> localEnv) {
        for (String key : keys) {
            String val = resolveSingle(key, localEnv);
            if (val != null && !val.isBlank()) {
                return val;
            }
        }
        return null;
    }

    private static String resolveSingle(String key, Map<String, String> localEnv) {
        // 1. Biến môi trường hệ điều hành
        String val = System.getenv(key);
        if (val != null && !val.isBlank()) return val;
        // 2. JVM property
        val = System.getProperty(key);
        if (val != null && !val.isBlank()) return val;
        // 3. File cục bộ
        if (localEnv != null) {
            val = localEnv.get(key);
            if (val != null && !val.isBlank()) return val;
        }
        return null;
    }

    private static Map<String, String> loadEnvironment() {
        Map<String, String> map = new HashMap<>();
        String catalinaBase = System.getProperty("catalina.base", "");
        String catalinaHome = System.getProperty("catalina.home", "");
        String userDir = System.getProperty("user.dir", "");
        String customEnvPath = System.getProperty("env.file", System.getenv("ENV_FILE"));

        // Danh sách các file cấu hình an toàn bên ngoài WAR / ngoài source code
        String[] paths = {
            userDir + File.separator + ".env",
            userDir + File.separator + "cloudinary.properties",
            "D:\\Lập trình web\\24110038_DuongThiNhuNgoc_hw2\\.env",
            "D:\\Lập trình web\\24110038_DuongThiNhuNgoc_hw2\\cloudinary.properties",
            catalinaHome.isBlank() ? null : catalinaHome + File.separator + ".env",
            catalinaHome.isBlank() ? null : catalinaHome + File.separator + "conf" + File.separator + ".env",
            catalinaHome.isBlank() ? null : catalinaHome + File.separator + "conf" + File.separator + "cloudinary.properties",
            catalinaBase.isBlank() ? null : catalinaBase + File.separator + ".env",
            catalinaBase.isBlank() ? null : catalinaBase + File.separator + "conf" + File.separator + ".env",
            catalinaBase.isBlank() ? null : catalinaBase + File.separator + "conf" + File.separator + "cloudinary.properties",
            customEnvPath
        };

        for (String p : paths) {
            if (p == null || p.isBlank()) continue;
            File f = new File(p);
            if (f.exists() && f.isFile()) {
                loadFile(f, map);
            }
        }

        return map;
    }

    private static void loadFile(File file, Map<String, String> map) {
        try (InputStream is = new FileInputStream(file)) {
            readLines(is, map);
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Không thể đọc file cấu hình: " + file.getPath(), e);
        }
    }

    private static void readLines(InputStream is, Map<String, String> map) {
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
            String line;
            while ((line = reader.readLine()) != null) {
                line = line.trim();
                if (line.isEmpty() || line.startsWith("#")) continue;
                int eq = line.indexOf('=');
                if (eq > 0) {
                    String key = line.substring(0, eq).trim();
                    String val = line.substring(eq + 1).trim();
                    if ((val.startsWith("\"") && val.endsWith("\""))
                        || (val.startsWith("'") && val.endsWith("'"))) {
                        val = val.substring(1, val.length() - 1);
                    }
                    map.put(key, val);
                }
            }
        } catch (Exception ignored) {}
    }
}
