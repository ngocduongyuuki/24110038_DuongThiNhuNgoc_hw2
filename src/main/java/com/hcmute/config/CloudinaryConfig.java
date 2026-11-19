package com.hcmute.config;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Cấu hình Cloudinary từ biến môi trường hoặc file .env
 * Không hard-code bất kỳ credential nào trong source code.
 *
 * Cách cấu hình (theo thứ tự ưu tiên):
 * 1. Biến môi trường hệ điều hành: CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET
 * 2. JVM property: -DCLOUDINARY_CLOUD_NAME=... v.v.
 * 3. File .env hoặc cloudinary.properties trong thư mục Tomcat / project
 */
public class CloudinaryConfig {

    private static final Logger LOGGER = Logger.getLogger(CloudinaryConfig.class.getName());
    private static Cloudinary instance;

    public static synchronized Cloudinary getInstance() {
        if (instance == null) {
            Map<String, String> env = loadEnvironment();

            String cloudName = resolve("CLOUDINARY_CLOUD_NAME", env);
            String apiKey    = resolve("CLOUDINARY_API_KEY",    env);
            String apiSecret = resolve("CLOUDINARY_API_SECRET", env);

            if (cloudName == null || cloudName.isBlank()
                || apiKey == null || apiKey.isBlank()
                || apiSecret == null || apiSecret.isBlank()) {
                LOGGER.warning("Cloudinary chưa được cấu hình. " +
                    "Hãy đặt CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET " +
                    "trong biến môi trường hoặc file .env");
                return null;
            }

            instance = new Cloudinary(ObjectUtils.asMap(
                "cloud_name", cloudName.trim(),
                "api_key",    apiKey.trim(),
                "api_secret", apiSecret.trim(),
                "secure",     true
            ));
        }
        return instance;
    }

    private static String resolve(String key, Map<String, String> localEnv) {
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
        String userDir = System.getProperty("user.dir", "");

        String[] paths = {
            ".env",
            "cloudinary.properties",
            userDir + File.separator + ".env",
            userDir + File.separator + "cloudinary.properties",
            catalinaBase + File.separator + ".env",
            catalinaBase + File.separator + "conf" + File.separator + ".env",
            catalinaBase + File.separator + "conf" + File.separator + "cloudinary.properties",
        };

        for (String p : paths) {
            if (p == null || p.isBlank()) continue;
            File f = new File(p);
            if (f.exists() && f.isFile()) {
                loadFile(f, map);
            }
        }

        // Từ classpath
        for (String res : new String[]{".env", "cloudinary.properties"}) {
            try (InputStream is = CloudinaryConfig.class.getClassLoader().getResourceAsStream(res)) {
                if (is != null) readLines(is, map);
            } catch (Exception ignored) {}
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
                    map.putIfAbsent(key, val);
                }
            }
        } catch (Exception ignored) {}
    }
}
