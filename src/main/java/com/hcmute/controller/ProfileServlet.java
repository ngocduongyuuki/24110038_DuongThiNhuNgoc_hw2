package com.hcmute.controller;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.hcmute.config.CloudinaryConfig;
import com.hcmute.model.Account;
import com.hcmute.service.AccountService;
import com.hcmute.service.OtpService;
import com.hcmute.service.impl.AccountServiceImpl;
import com.hcmute.service.impl.OtpServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.io.InputStream;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Pattern;

@WebServlet("/profile")
@MultipartConfig(
    fileSizeThreshold = 512 * 1024,       // 512 KB buffer trước khi ghi disk
    maxFileSize       = 5L * 1024 * 1024, // 5 MB tối đa mỗi file
    maxRequestSize    = 6L * 1024 * 1024  // 6 MB tối đa mỗi request
)
public class ProfileServlet extends HttpServlet {

    private static final Pattern EMAIL_PATTERN =
        Pattern.compile("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}$");
    private static final Set<String> ALLOWED_MIME_TYPES =
        new HashSet<>(Arrays.asList("image/jpeg", "image/png", "image/webp", "image/gif"));

    private final AccountService accountService = new AccountServiceImpl();
    private final OtpService otpService = new OtpServiceImpl();

    // ─── GET: Hiển thị trang profile ─────────────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Account account = getSessionAccount(request);
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Luôn lấy dữ liệu mới nhất từ DB (tránh session stale)
        Account fresh = accountService.findById(account.getId());
        if (fresh == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Phản ánh thông báo thành công từ redirect params
        if ("1".equals(request.getParameter("updated"))) {
            request.setAttribute("successMessage", "Cập nhật thông tin thành công!");
        }
        if ("1".equals(request.getParameter("emailUpdated"))) {
            request.setAttribute("successMessage", "Địa chỉ email đã được cập nhật thành công!");
        }
        if ("1".equals(request.getParameter("avatarUpdated"))) {
            request.setAttribute("successMessage", "Ảnh đại diện đã được cập nhật thành công!");
        }
        if ("session_expired".equals(request.getParameter("error"))) {
            request.setAttribute("errorMessage", "Phiên làm việc đã hết hạn. Vui lòng thực hiện lại.");
        }

        request.setAttribute("profileAccount", fresh);
        request.getRequestDispatcher("/WEB-INF/views/profile/profile.jsp").forward(request, response);
    }

    // ─── POST: Xử lý các action ──────────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        Account account = getSessionAccount(request);
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "";

        switch (action) {
            case "updateInfo"       -> handleUpdateInfo(request, response, account);
            case "requestEmailChange" -> handleRequestEmailChange(request, response, account);
            case "uploadAvatar"     -> handleUploadAvatar(request, response, account);
            default -> response.sendRedirect(request.getContextPath() + "/profile");
        }
    }

    // ─── Xử lý cập nhật fullName + phone ─────────────────────────────────────

    private void handleUpdateInfo(HttpServletRequest request, HttpServletResponse response, Account account)
            throws ServletException, IOException {
        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");

        String error = accountService.updateProfile(account.getId(), fullName, phone);
        if (error != null) {
            Account fresh = accountService.findById(account.getId());
            request.setAttribute("profileAccount", fresh != null ? fresh : account);
            request.setAttribute("errorMessage", error);
            request.getRequestDispatcher("/WEB-INF/views/profile/profile.jsp").forward(request, response);
            return;
        }

        // Cập nhật session để navbar hiển thị đúng
        account.setFullName(fullName != null ? fullName.trim() : account.getFullName());
        account.setPhone(phone != null && !phone.isBlank() ? phone.trim() : null);
        request.getSession().setAttribute("account", account);

        response.sendRedirect(request.getContextPath() + "/profile?updated=1");
    }

    // ─── Xử lý yêu cầu đổi email (gửi OTP đến email mới) ───────────────────

    private void handleRequestEmailChange(HttpServletRequest request, HttpServletResponse response, Account account)
            throws ServletException, IOException {
        String newEmail = request.getParameter("newEmail");
        Account fresh = accountService.findById(account.getId());
        request.setAttribute("profileAccount", fresh != null ? fresh : account);

        if (newEmail == null || newEmail.isBlank()) {
            request.setAttribute("emailError", "Email mới không được để trống.");
            request.getRequestDispatcher("/WEB-INF/views/profile/profile.jsp").forward(request, response);
            return;
        }
        newEmail = newEmail.trim().toLowerCase();

        if (!EMAIL_PATTERN.matcher(newEmail).matches()) {
            request.setAttribute("emailError", "Địa chỉ email không đúng định dạng.");
            request.getRequestDispatcher("/WEB-INF/views/profile/profile.jsp").forward(request, response);
            return;
        }

        if (newEmail.equals(account.getEmail() != null ? account.getEmail().toLowerCase() : "")) {
            request.setAttribute("emailError", "Email mới phải khác email hiện tại.");
            request.getRequestDispatcher("/WEB-INF/views/profile/profile.jsp").forward(request, response);
            return;
        }

        // Kiểm tra email đã được dùng bởi tài khoản khác chưa
        Account existing = accountService.findByEmail(newEmail);
        if (existing != null && existing.getId() != account.getId()) {
            request.setAttribute("emailError", "Email này đã được sử dụng bởi tài khoản khác.");
            request.getRequestDispatcher("/WEB-INF/views/profile/profile.jsp").forward(request, response);
            return;
        }

        // Lưu email mới vào session và gửi OTP
        HttpSession session = request.getSession();
        session.setAttribute("pending_email_change", newEmail);

        String otpError = otpService.generateAndSendOtp(newEmail, "UPDATE_EMAIL");
        if (otpError != null) {
            session.removeAttribute("pending_email_change");
            request.setAttribute("emailError", otpError);
            request.getRequestDispatcher("/WEB-INF/views/profile/profile.jsp").forward(request, response);
            return;
        }

        // Chuyển sang trang nhập OTP
        response.sendRedirect(request.getContextPath()
            + "/verify-otp?email=" + java.net.URLEncoder.encode(newEmail, "UTF-8")
            + "&purpose=UPDATE_EMAIL&sent=1");
    }

    // ─── Xử lý upload avatar lên Cloudinary ──────────────────────────────────

    private void handleUploadAvatar(HttpServletRequest request, HttpServletResponse response, Account account)
            throws ServletException, IOException {
        Account fresh = accountService.findById(account.getId());
        request.setAttribute("profileAccount", fresh != null ? fresh : account);

        Cloudinary cloudinary = CloudinaryConfig.getInstance();
        if (cloudinary == null) {
            List<String> missing = CloudinaryConfig.getMissingVariables();
            String missingDetails = missing.isEmpty() ? "" : " (Thiếu: " + String.join(", ", missing) + ")";
            request.setAttribute("avatarError", "Chức năng upload ảnh chưa được cấu hình" + missingDetails + ". Vui lòng cấu hình file .env hoặc liên hệ quản trị viên.");
            request.getRequestDispatcher("/WEB-INF/views/profile/profile.jsp").forward(request, response);
            return;
        }

        Part filePart = null;
        try {
            filePart = request.getPart("avatar");
        } catch (Exception e) {
            request.setAttribute("avatarError", "Không thể đọc file upload. Vui lòng thử lại.");
            request.getRequestDispatcher("/WEB-INF/views/profile/profile.jsp").forward(request, response);
            return;
        }

        if (filePart == null || filePart.getSize() == 0) {
            request.setAttribute("avatarError", "Vui lòng chọn file ảnh để upload.");
            request.getRequestDispatcher("/WEB-INF/views/profile/profile.jsp").forward(request, response);
            return;
        }

        // Kiểm tra MIME type (server-side, không dựa vào extension của client)
        String contentType = filePart.getContentType();
        if (contentType == null || !ALLOWED_MIME_TYPES.contains(contentType.toLowerCase())) {
            request.setAttribute("avatarError", "Chỉ chấp nhận file ảnh JPG, JPEG, PNG, WEBP hoặc GIF.");
            request.getRequestDispatcher("/WEB-INF/views/profile/profile.jsp").forward(request, response);
            return;
        }

        // Kiểm tra dung lượng (5 MB)
        if (filePart.getSize() > 5L * 1024 * 1024) {
            request.setAttribute("avatarError", "File ảnh không được vượt quá 5 MB.");
            request.getRequestDispatcher("/WEB-INF/views/profile/profile.jsp").forward(request, response);
            return;
        }

        // Upload lên Cloudinary
        try (InputStream is = filePart.getInputStream()) {
            byte[] fileBytes = is.readAllBytes();

            // Kiểm tra chữ ký nhị phân (magic bytes) để đảm bảo nội dung thực sự là ảnh
            if (!isImageMagicBytes(fileBytes)) {
                request.setAttribute("avatarError", "Nội dung file không phải là định dạng ảnh hợp lệ.");
                request.getRequestDispatcher("/WEB-INF/views/profile/profile.jsp").forward(request, response);
                return;
            }

            Map<?, ?> uploadResult = cloudinary.uploader().upload(fileBytes, ObjectUtils.asMap(
                "folder",         "product_manager/avatars",
                "public_id",      "avatar_" + account.getId(),
                "overwrite",      true,
                "resource_type",  "image",
                "transformation", "c_fill,g_face,h_200,w_200,q_auto,f_auto"
            ));

            String imageUrl = (String) uploadResult.get("secure_url");
            if (imageUrl == null || imageUrl.isBlank()) {
                request.setAttribute("avatarError", "Upload thất bại, Cloudinary không trả về URL ảnh.");
                request.getRequestDispatcher("/WEB-INF/views/profile/profile.jsp").forward(request, response);
                return;
            }

            boolean saved = accountService.updateProfileImage(account.getId(), imageUrl);
            if (!saved) {
                request.setAttribute("avatarError", "Upload thành công nhưng lưu URL thất bại. Vui lòng thử lại.");
                request.getRequestDispatcher("/WEB-INF/views/profile/profile.jsp").forward(request, response);
                return;
            }

            // Cập nhật session
            account.setProfileImage(imageUrl);
            request.getSession().setAttribute("account", account);

            response.sendRedirect(request.getContextPath() + "/profile?avatarUpdated=1");

        } catch (Exception e) {
            request.setAttribute("avatarError", "Lỗi upload ảnh: " + sanitizeMessage(e.getMessage()));
            request.getRequestDispatcher("/WEB-INF/views/profile/profile.jsp").forward(request, response);
        }
    }

    // ─── Helper ──────────────────────────────────────────────────────────────

    private Account getSessionAccount(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return null;
        return (Account) session.getAttribute("account");
    }

    private String sanitizeMessage(String msg) {
        if (msg == null) return "Lỗi không xác định.";
        // Không để lộ stack trace hoặc thông tin nội bộ
        return msg.length() > 200 ? msg.substring(0, 200) + "..." : msg;
    }

    private boolean isImageMagicBytes(byte[] bytes) {
        if (bytes == null || bytes.length < 8) return false;
        // JPEG: FF D8 FF
        if ((bytes[0] & 0xFF) == 0xFF && (bytes[1] & 0xFF) == 0xD8 && (bytes[2] & 0xFF) == 0xFF) return true;
        // PNG: 89 50 4E 47 0D 0A 1A 0A
        if ((bytes[0] & 0xFF) == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47
            && bytes[4] == 0x0D && bytes[5] == 0x0A && bytes[6] == 0x1A && bytes[7] == 0x0A) return true;
        // GIF: GIF87a / GIF89a (47 49 46 38)
        if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x38) return true;
        // WEBP: RIFF....WEBP (52 49 46 46 ... 57 45 42 50)
        if (bytes.length >= 12 && bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46
            && bytes[8] == 0x57 && bytes[9] == 0x45 && bytes[10] == 0x42 && bytes[11] == 0x50) return true;
        return false;
    }
}
