package com.hcmute.controller;

import com.hcmute.model.Account;
import com.hcmute.model.Video;
import com.hcmute.service.VideoService;
import com.hcmute.service.impl.VideoServiceImpl;
import com.hcmute.util.VideoUploadUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/video/*")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,          // 1 MB – buffer before disk
    maxFileSize       = 200L * 1024 * 1024,   // 200 MB per file
    maxRequestSize    = 210L * 1024 * 1024    // 210 MB per request
)
public class VideoServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(VideoServlet.class.getName());
    private static final int PAGE_SIZE = 6;

    private final VideoService videoService = new VideoServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) pathInfo = "/list";

        switch (pathInfo) {
            case "/list", "/" -> showList(request, response);
            case "/add"      -> showAddForm(request, response);
            case "/edit"     -> showEditForm(request, response);
            case "/delete"   -> deleteVideo(request, response);
            case "/detail"   -> showDetail(request, response);
            default          -> response.sendRedirect(request.getContextPath() + "/video");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String pathInfo = request.getPathInfo();

        if ("/add".equals(pathInfo)) {
            handleAdd(request, response);
        } else if ("/edit".equals(pathInfo)) {
            handleEdit(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/video");
        }
    }

    // ─── List (paginated) ────────────────────────────────────────────────────

    private void showList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Account account = getAccount(request);
        if (account == null) { redirectLogin(request, response); return; }

        int page = parsePage(request.getParameter("page"));
        long total = videoService.countVideosByAccount(account.getId());
        int totalPages = (int) Math.max(1, (long) Math.ceil((double) total / PAGE_SIZE));
        if (page > totalPages) page = totalPages;

        List<Video> videos = videoService.getVideosByAccount(account.getId(), page, PAGE_SIZE);

        request.setAttribute("videos", videos);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalVideos", total);
        request.getRequestDispatcher("/WEB-INF/views/video/list.jsp").forward(request, response);
    }

    // ─── Add ─────────────────────────────────────────────────────────────────

    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Account account = getAccount(request);
        if (account == null) { redirectLogin(request, response); return; }
        request.getRequestDispatcher("/WEB-INF/views/video/add.jsp").forward(request, response);
    }

    private void handleAdd(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Account account = getAccount(request);
        if (account == null) { redirectLogin(request, response); return; }

        String title = trim(request.getParameter("title"));
        String description = trim(request.getParameter("description"));

        // Validate title
        if (title == null || title.isBlank()) {
            request.setAttribute("error", "Tiêu đề không được để trống.");
            request.setAttribute("title", title);
            request.setAttribute("description", description);
            request.getRequestDispatcher("/WEB-INF/views/video/add.jsp").forward(request, response);
            return;
        }

        // Handle file upload
        Part videoPart = request.getPart("videoFile");
        StringBuilder uploadError = new StringBuilder();
        String fileName = VideoUploadUtil.saveVideoFile(videoPart, uploadError);

        if (fileName == null) {
            request.setAttribute("error", uploadError.toString());
            request.setAttribute("title", title);
            request.setAttribute("description", description);
            request.getRequestDispatcher("/WEB-INF/views/video/add.jsp").forward(request, response);
            return;
        }

        // Build relative URL path stored in DB
        String videoPath = VideoUploadUtil.getUploadUrlPrefix() + fileName;

        // Need a managed Account entity (JPA) – create reference with ID only
        Account managedAccount = new Account();
        managedAccount.setId(account.getId());

        Video video = new Video(title, description, videoPath, null, managedAccount);
        boolean saved = videoService.addVideo(video);

        if (saved) {
            response.sendRedirect(request.getContextPath() + "/video?added=1");
        } else {
            // If DB save fails, delete the orphan file
            VideoUploadUtil.deleteFile(fileName);
            request.setAttribute("error", "Lưu video vào cơ sở dữ liệu thất bại. Vui lòng thử lại.");
            request.setAttribute("title", title);
            request.setAttribute("description", description);
            request.getRequestDispatcher("/WEB-INF/views/video/add.jsp").forward(request, response);
        }
    }

    // ─── Edit ────────────────────────────────────────────────────────────────

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Account account = getAccount(request);
        if (account == null) { redirectLogin(request, response); return; }

        Video video = getOwnedVideo(request, account.getId());
        if (video == null) {
            response.sendRedirect(request.getContextPath() + "/video");
            return;
        }
        request.setAttribute("video", video);
        request.getRequestDispatcher("/WEB-INF/views/video/edit.jsp").forward(request, response);
    }

    private void handleEdit(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Account account = getAccount(request);
        if (account == null) { redirectLogin(request, response); return; }

        int id;
        try {
            id = Integer.parseInt(request.getParameter("videoId"));
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/video");
            return;
        }

        Video video = videoService.getVideoById(id);
        if (video == null || video.getAccount().getId() != account.getId()) {
            response.sendRedirect(request.getContextPath() + "/video");
            return;
        }

        String title = trim(request.getParameter("title"));
        String description = trim(request.getParameter("description"));

        if (title == null || title.isBlank()) {
            request.setAttribute("error", "Tiêu đề không được để trống.");
            request.setAttribute("video", video);
            request.getRequestDispatcher("/WEB-INF/views/video/edit.jsp").forward(request, response);
            return;
        }

        video.setTitle(title);
        video.setDescription(description);

        // Check if a new file was uploaded
        Part videoPart = request.getPart("videoFile");
        if (videoPart != null && videoPart.getSize() > 0) {
            StringBuilder uploadError = new StringBuilder();
            String newFileName = VideoUploadUtil.saveVideoFile(videoPart, uploadError);
            if (newFileName == null) {
                request.setAttribute("error", uploadError.toString());
                request.setAttribute("video", video);
                request.getRequestDispatcher("/WEB-INF/views/video/edit.jsp").forward(request, response);
                return;
            }
            // Delete old file
            String oldFileName = VideoUploadUtil.extractFileName(video.getVideoPath());
            String newVideoPath = VideoUploadUtil.getUploadUrlPrefix() + newFileName;
            video.setVideoPath(newVideoPath);
            boolean updated = videoService.updateVideo(video);
            if (updated) {
                VideoUploadUtil.deleteFile(oldFileName);
                response.sendRedirect(request.getContextPath() + "/video?updated=1");
            } else {
                VideoUploadUtil.deleteFile(newFileName);
                request.setAttribute("error", "Cập nhật thất bại. Vui lòng thử lại.");
                request.setAttribute("video", video);
                request.getRequestDispatcher("/WEB-INF/views/video/edit.jsp").forward(request, response);
            }
        } else {
            // No new file, just update metadata
            boolean updated = videoService.updateVideo(video);
            if (updated) {
                response.sendRedirect(request.getContextPath() + "/video?updated=1");
            } else {
                request.setAttribute("error", "Cập nhật thất bại. Vui lòng thử lại.");
                request.setAttribute("video", video);
                request.getRequestDispatcher("/WEB-INF/views/video/edit.jsp").forward(request, response);
            }
        }
    }

    // ─── Delete ──────────────────────────────────────────────────────────────

    private void deleteVideo(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Account account = getAccount(request);
        if (account == null) { redirectLogin(request, response); return; }

        int id;
        try {
            id = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/video");
            return;
        }

        Video video = videoService.getVideoById(id);
        if (video == null || video.getAccount().getId() != account.getId()) {
            response.sendRedirect(request.getContextPath() + "/video");
            return;
        }

        String fileName = VideoUploadUtil.extractFileName(video.getVideoPath());
        String deletedPath = videoService.deleteVideo(id);
        if (deletedPath != null) {
            VideoUploadUtil.deleteFile(fileName);
            response.sendRedirect(request.getContextPath() + "/video?deleted=1");
        } else {
            response.sendRedirect(request.getContextPath() + "/video?deleteFailed=1");
        }
    }

    // ─── Detail ──────────────────────────────────────────────────────────────

    private void showDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Account account = getAccount(request);
        if (account == null) { redirectLogin(request, response); return; }

        int id;
        try {
            id = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        Video video = videoService.getVideoById(id);
        if (video == null) {
            request.setAttribute("errorMsg", "Video không tồn tại hoặc đã bị xóa.");
            request.getRequestDispatcher("/WEB-INF/views/video/detail.jsp").forward(request, response);
            return;
        }

        // Check if the file still exists on disk
        String fileName = VideoUploadUtil.extractFileName(video.getVideoPath());
        String uploadDir = VideoUploadUtil.getUploadDir();
        boolean fileExists = (fileName != null) &&
            Files.exists(Paths.get(uploadDir).resolve(fileName));

        request.setAttribute("video", video);
        request.setAttribute("fileExists", fileExists);
        request.setAttribute("isOwner", video.getAccount().getId() == account.getId());
        request.getRequestDispatcher("/WEB-INF/views/video/detail.jsp").forward(request, response);
    }

    // ─── Helpers ─────────────────────────────────────────────────────────────

    private Account getAccount(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return null;
        return (Account) session.getAttribute("account");
    }

    private void redirectLogin(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.sendRedirect(request.getContextPath() + "/login");
    }

    private Video getOwnedVideo(HttpServletRequest request, int accountId) {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            Video video = videoService.getVideoById(id);
            if (video != null && video.getAccount().getId() == accountId) return video;
        } catch (NumberFormatException ignored) {}
        return null;
    }

    private int parsePage(String param) {
        try {
            int p = Integer.parseInt(param);
            return p < 1 ? 1 : p;
        } catch (Exception e) {
            return 1;
        }
    }

    private String trim(String s) {
        return (s == null) ? null : s.trim();
    }
}
