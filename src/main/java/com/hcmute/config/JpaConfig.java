package com.hcmute.config;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

public class JpaConfig {

    private static final EntityManagerFactory factory;

    static {
        try {
            Map<String, Object> overrides = new HashMap<>();

            // 1. Nạp từ file môi trường cục bộ .env hoặc db.properties (nếu có và được gitignore)
            Map<String, String> localEnv = loadLocalEnvironment();

            // 2. Lấy thông tin cấu hình theo thứ tự ưu tiên:
            //    Ưu tiên 1: System Environment Variables (DB_URL, DB_USER, DB_PASSWORD, DB_DRIVER)
            //    Ưu tiên 2: JVM System Properties (-Ddb.url, -Ddb.password, ...)
            //    Ưu tiên 3: File cấu hình cục bộ an toàn (.env / db.properties)
            String dbUrl = resolveConfig("DB_URL", "db.url", localEnv);
            String dbUser = resolveConfig("DB_USER", "db.user", localEnv);
            String dbPassword = resolveConfig("DB_PASSWORD", "db.password", localEnv);
            String dbDriver = resolveConfig("DB_DRIVER", "db.driver", localEnv);

            if (dbUrl != null && !dbUrl.isBlank()) {
                overrides.put("jakarta.persistence.jdbc.url", dbUrl.trim());
            }
            if (dbUser != null && !dbUser.isBlank()) {
                overrides.put("jakarta.persistence.jdbc.user", dbUser.trim());
            }
            if (dbPassword != null) {
                overrides.put("jakarta.persistence.jdbc.password", dbPassword.trim());
            }
            if (dbDriver != null && !dbDriver.isBlank()) {
                overrides.put("jakarta.persistence.jdbc.driver", dbDriver.trim());
            }

            factory = Persistence.createEntityManagerFactory("ProductManagerPU", overrides);
        } catch (Throwable ex) {
            System.err.println("Khởi tạo EntityManagerFactory thất bại: " + ex);
            throw new ExceptionInInitializerError(ex);
        }
    }

    private static String resolveConfig(String envKey, String propKey, Map<String, String> localEnv) {
        // 1. Biến môi trường hệ điều hành
        String val = System.getenv(envKey);
        if (val != null && !val.isBlank()) return val;

        // 2. Thuộc tính JVM (-D)
        val = System.getProperty(envKey);
        if (val != null && !val.isBlank()) return val;
        val = System.getProperty(propKey);
        if (val != null && !val.isBlank()) return val;

        // 3. File môi trường cục bộ
        if (localEnv != null) {
            val = localEnv.get(envKey);
            if (val != null && !val.isBlank()) return val;
            val = localEnv.get(propKey);
            if (val != null && !val.isBlank()) return val;
        }
        return null;
    }

    private static Map<String, String> loadLocalEnvironment() {
        Map<String, String> map = new HashMap<>();

        String catalinaBase = System.getProperty("catalina.base", "");
        String catalinaHome = System.getProperty("catalina.home", "");
        String userDir = System.getProperty("user.dir", "");

        // Danh sách các vị trí có thể chứa file .env hoặc db.properties
        String[] searchPaths = {
            ".env",
            "db.properties",
            userDir + File.separator + ".env",
            userDir + File.separator + "db.properties",
            catalinaBase + File.separator + ".env",
            catalinaBase + File.separator + "conf" + File.separator + ".env",
            catalinaBase + File.separator + "conf" + File.separator + "db.properties",
            catalinaHome + File.separator + ".env",
            catalinaHome + File.separator + "conf" + File.separator + ".env",
            // Tìm trong thư mục cha của user.dir (khi chạy từ bin/)
            new File(userDir).getParent() != null
                ? new File(userDir).getParent() + File.separator + ".env" : "",
        };

        for (String pathStr : searchPaths) {
            if (pathStr == null || pathStr.isBlank()) continue;
            File file = new File(pathStr);
            if (file.exists() && file.isFile()) {
                loadFileIntoMap(file, map);
            }
        }

        // Kiểm tra thêm từ Classpath
        try (InputStream is = JpaConfig.class.getClassLoader().getResourceAsStream(".env")) {
            if (is != null) {
                readLinesIntoMap(is, map);
            }
        } catch (Exception ignored) {
        }

        try (InputStream is = JpaConfig.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (is != null) {
                readLinesIntoMap(is, map);
            }
        } catch (Exception ignored) {
        }

        return map;
    }

    private static void loadFileIntoMap(File file, Map<String, String> map) {
        try (InputStream is = new FileInputStream(file)) {
            readLinesIntoMap(is, map);
        } catch (Exception ignored) {
        }
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
        } catch (Exception ignored) {
        }
    }

    public static EntityManager getEntityManager() {
        return factory.createEntityManager();
    }

    public static void shutdown() {
        if (factory != null && factory.isOpen()) {
            factory.close();
        }
    }
}
