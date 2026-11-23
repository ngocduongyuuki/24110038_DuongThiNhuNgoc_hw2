package com.hcmute.util;

import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Utility class for handling video file uploads.
 * Saves files to a configured upload directory OUTSIDE the WAR deployment.
 */
public class VideoUploadUtil {

    private static final Logger LOGGER = Logger.getLogger(VideoUploadUtil.class.getName());

    /** Max file size: 200 MB */
    public static final long MAX_SIZE_BYTES = 200L * 1024 * 1024;

    /** Allowed MIME types */
    private static final Set<String> ALLOWED_MIME_TYPES = new HashSet<>(Arrays.asList(
        "video/mp4", "video/webm", "video/ogg", "video/quicktime"
    ));

    /** Allowed file extensions */
    private static final Set<String> ALLOWED_EXTENSIONS = new HashSet<>(Arrays.asList(
        "mp4", "webm", "ogv", "mov"
    ));

    /**
     * Returns the upload directory path.
     * Reads UPLOAD_DIR from environment / JVM property first.
     * Checks known existing storage locations before falling back to default.
     */
    public static String getUploadDir() {
        String dir = System.getenv("UPLOAD_DIR");
        if (dir == null || dir.isBlank()) dir = System.getProperty("UPLOAD_DIR");
        if (dir == null || dir.isBlank()) dir = System.getProperty("upload.dir");

        if (dir == null || dir.isBlank()) {
            String catalinaBase = System.getProperty("catalina.base", "");
            if (!catalinaBase.isBlank()) {
                dir = catalinaBase + File.separator + "uploads" + File.separator + "videos";
            } else if (Files.exists(Paths.get("D:\\apache-tomcat-11.0.27\\uploads\\videos"))) {
                dir = "D:\\apache-tomcat-11.0.27\\uploads\\videos";
            } else {
                dir = System.getProperty("java.io.tmpdir") + File.separator + "pm_uploads" + File.separator + "videos";
            }
        }
        return dir;
    }

    /**
     * Resolves the actual physical file path for a given filename.
     * Checks multiple possible upload directories to ensure backward compatibility
     * when switching between Tomcat 11 and Tomcat 10.1 in VS Code.
     */
    public static Path resolveVideoPath(String fileName) {
        if (fileName == null || fileName.isBlank() || fileName.contains("..")) {
            return null;
        }

        String baseName = extractFileName(fileName);
        String catalinaBase = System.getProperty("catalina.base", "");
        String catalinaHome = System.getProperty("catalina.home", "");

        String[] candidateDirs = {
            getUploadDir(),
            "D:\\apache-tomcat-11.0.27\\uploads\\videos",
            catalinaBase.isBlank() ? null : catalinaBase + File.separator + "uploads" + File.separator + "videos",
            catalinaHome.isBlank() ? null : catalinaHome + File.separator + "uploads" + File.separator + "videos",
            "D:\\Lập trình web\\24110038_DuongThiNhuNgoc_hw2\\uploads\\videos"
        };

        for (String cDir : candidateDirs) {
            if (cDir == null || cDir.isBlank()) continue;
            try {
                Path candidate = Paths.get(cDir).resolve(baseName);
                if (Files.exists(candidate) && Files.isRegularFile(candidate)) {
                    return candidate;
                }
            } catch (Exception ignored) {}
        }

        return null;
    }

    public static String getUploadUrlPrefix() {
        return "/uploads/videos/";
    }

    public static String saveVideoFile(Part part, StringBuilder errorOut) throws IOException {
        if (part == null || part.getSize() == 0) {
            errorOut.append("Không có file được chọn.");
            return null;
        }

        // Validate size
        if (part.getSize() > MAX_SIZE_BYTES) {
            errorOut.append("File quá lớn. Giới hạn tối đa là 200MB.");
            return null;
        }

        // Validate MIME type
        String contentType = part.getContentType();
        if (contentType == null || !ALLOWED_MIME_TYPES.contains(contentType.toLowerCase())) {
            errorOut.append("Định dạng file không hợp lệ. Chỉ chấp nhận MP4, WebM, OGV, MOV.");
            return null;
        }

        // Validate extension from submitted filename
        String submittedName = part.getSubmittedFileName();
        if (submittedName == null || submittedName.isBlank()) {
            errorOut.append("Không xác định được tên file.");
            return null;
        }
        // Sanitize: get only the basename
        submittedName = Paths.get(submittedName).getFileName().toString();
        String ext = "";
        int dotIdx = submittedName.lastIndexOf('.');
        if (dotIdx > 0) {
            ext = submittedName.substring(dotIdx + 1).toLowerCase();
        }
        if (!ALLOWED_EXTENSIONS.contains(ext)) {
            errorOut.append("Đuôi file không hợp lệ. Chỉ chấp nhận: .mp4, .webm, .ogv, .mov");
            return null;
        }

        // Prevent path traversal
        if (submittedName.contains("..") || submittedName.contains("/") || submittedName.contains("\\")) {
            errorOut.append("Tên file không hợp lệ.");
            return null;
        }

        // Create upload directory if not exists
        String uploadDir = getUploadDir();
        Path uploadPath = Paths.get(uploadDir);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }

        // Generate unique filename
        String uniqueName = UUID.randomUUID().toString() + "." + ext;
        Path destination = uploadPath.resolve(uniqueName);

        // Write file
        part.write(destination.toString());

        return uniqueName;
    }

    public static void deleteFile(String fileName) {
        if (fileName == null || fileName.isBlank()) return;
        String baseName = Paths.get(fileName).getFileName().toString();
        try {
            Path filePath = Paths.get(getUploadDir()).resolve(baseName);
            Files.deleteIfExists(filePath);
        } catch (IOException e) {
            LOGGER.log(Level.WARNING, "Failed to delete uploaded file: " + baseName, e);
        }
    }

    public static String extractFileName(String videoPath) {
        if (videoPath == null) return null;
        int idx = videoPath.lastIndexOf('/');
        if (idx >= 0) return videoPath.substring(idx + 1);
        idx = videoPath.lastIndexOf('\\');
        if (idx >= 0) return videoPath.substring(idx + 1);
        return videoPath;
    }
}
