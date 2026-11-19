package com.hcmute.controller;

import com.hcmute.util.VideoUploadUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.*;
import java.nio.file.*;

@WebServlet("/uploads/videos/*")
public class UploadFileServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String fileName = Paths.get(pathInfo.substring(1)).getFileName().toString();
        if (fileName.contains("..") || fileName.isBlank()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        Path filePath = Paths.get(VideoUploadUtil.getUploadDir()).resolve(fileName);
        if (!Files.exists(filePath) || !Files.isRegularFile(filePath)) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "File không tìm thấy.");
            return;
        }

        String contentType = getServletContext().getMimeType(fileName);
        if (contentType == null || !contentType.startsWith("video/")) {
            contentType = "application/octet-stream";
        }

        long fileLength = Files.size(filePath);

        String rangeHeader = request.getHeader("Range");
        if (rangeHeader != null && rangeHeader.startsWith("bytes=")) {
            serveRange(response, filePath, contentType, fileLength, rangeHeader);
        } else {
            response.setContentType(contentType);
            response.setHeader("Content-Length", String.valueOf(fileLength));
            response.setHeader("Accept-Ranges", "bytes");
            try (InputStream in = Files.newInputStream(filePath);
                 OutputStream out = response.getOutputStream()) {
                byte[] buf = new byte[8192];
                int read;
                while ((read = in.read(buf)) != -1) {
                    out.write(buf, 0, read);
                }
            }
        }
    }

    private void serveRange(HttpServletResponse response, Path filePath, String contentType,
                            long fileLength, String rangeHeader) throws IOException {
        try {
            String rangeValue = rangeHeader.substring("bytes=".length());
            String[] parts = rangeValue.split("-");
            long start = Long.parseLong(parts[0].trim());
            long end = (parts.length > 1 && !parts[1].trim().isEmpty())
                ? Long.parseLong(parts[1].trim())
                : fileLength - 1;

            if (start > end || start < 0 || end >= fileLength) {
                response.setStatus(HttpServletResponse.SC_REQUESTED_RANGE_NOT_SATISFIABLE);
                response.setHeader("Content-Range", "bytes */" + fileLength);
                return;
            }

            long contentLength = end - start + 1;
            response.setStatus(HttpServletResponse.SC_PARTIAL_CONTENT);
            response.setContentType(contentType);
            response.setHeader("Content-Range", "bytes " + start + "-" + end + "/" + fileLength);
            response.setHeader("Content-Length", String.valueOf(contentLength));
            response.setHeader("Accept-Ranges", "bytes");

            try (InputStream in = Files.newInputStream(filePath);
                 OutputStream out = response.getOutputStream()) {
                long toSkip = start;
                while (toSkip > 0) {
                    long skipped = in.skip(toSkip);
                    if (skipped <= 0) {
                        if (in.read() == -1) break;
                        skipped = 1;
                    }
                    toSkip -= skipped;
                }
                byte[] buf = new byte[8192];
                long remaining = contentLength;
                int read;
                while (remaining > 0 && (read = in.read(buf, 0, (int) Math.min(buf.length, remaining))) != -1) {
                    out.write(buf, 0, read);
                    remaining -= read;
                }
            }
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
        }
    }
}
