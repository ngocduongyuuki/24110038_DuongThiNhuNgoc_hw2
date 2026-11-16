package com.hcmute.controller;

import com.hcmute.model.Account;
import com.hcmute.service.AccountService;
import com.hcmute.service.OtpService;
import com.hcmute.service.impl.AccountServiceImpl;
import com.hcmute.service.impl.OtpServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@WebServlet("/forgot-password")
public class ForgotPasswordServlet extends HttpServlet {

    private final AccountService accountService = new AccountServiceImpl();
    private final OtpService otpService = new OtpServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String email = request.getParameter("email");
        if (email == null || email.isBlank()) {
            request.setAttribute("error", "Vui lòng nhập địa chỉ email.");
            request.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(request, response);
            return;
        }

        email = email.trim();
        Account account = accountService.findByEmail(email);

        if (account != null && account.isActive()) {
            String sendError = otpService.generateAndSendOtp(email, "FORGOT_PASSWORD");
            if (sendError != null) {
                request.setAttribute("error", sendError);
                request.setAttribute("email", email);
                request.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(request, response);
                return;
            }
        }

        // Thông báo an toàn không tiết lộ email có tồn tại hay không
        String encodedEmail = URLEncoder.encode(email, StandardCharsets.UTF_8);
        response.sendRedirect(request.getContextPath() + "/verify-otp?email=" + encodedEmail + "&purpose=FORGOT_PASSWORD&sent=1");
    }
}
