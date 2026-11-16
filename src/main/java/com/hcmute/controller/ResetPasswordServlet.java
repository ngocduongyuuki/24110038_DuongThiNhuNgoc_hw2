package com.hcmute.controller;

import com.hcmute.service.AccountService;
import com.hcmute.service.impl.AccountServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/reset-password")
public class ResetPasswordServlet extends HttpServlet {

    private final AccountService accountService = new AccountServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        String email = (session != null) ? (String) session.getAttribute("verified_reset_email") : null;

        if (email == null || email.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/forgot-password");
            return;
        }

        request.setAttribute("email", email);
        request.getRequestDispatcher("/WEB-INF/views/auth/reset-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        String email = (session != null) ? (String) session.getAttribute("verified_reset_email") : null;

        if (email == null || email.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/forgot-password");
            return;
        }

        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        if (password == null || password.length() < 6) {
            request.setAttribute("error", "Mật khẩu mới phải có ít nhất 6 ký tự.");
            request.getRequestDispatcher("/WEB-INF/views/auth/reset-password.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Mật khẩu xác nhận không khớp.");
            request.getRequestDispatcher("/WEB-INF/views/auth/reset-password.jsp").forward(request, response);
            return;
        }

        boolean updated = accountService.updatePassword(email, password);
        if (updated) {
            session.removeAttribute("verified_reset_email");
            response.sendRedirect(request.getContextPath() + "/login?reset=1");
        } else {
            request.setAttribute("error", "Cập nhật mật khẩu thất bại. Vui lòng thử lại.");
            request.getRequestDispatcher("/WEB-INF/views/auth/reset-password.jsp").forward(request, response);
        }
    }
}
