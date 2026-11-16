package com.hcmute.controller;

import com.hcmute.service.AccountService;
import com.hcmute.service.OtpService;
import com.hcmute.service.OtpVerifyResult;
import com.hcmute.service.impl.AccountServiceImpl;
import com.hcmute.service.impl.OtpServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/verify-otp")
public class VerifyOtpServlet extends HttpServlet {

    private final OtpService otpService = new OtpServiceImpl();
    private final AccountService accountService = new AccountServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String purpose = request.getParameter("purpose");
        if (purpose == null || purpose.isBlank()) {
            purpose = "REGISTER";
        }

        if (email == null || email.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        request.setAttribute("email", email.trim());
        request.setAttribute("maskedEmail", maskEmail(email.trim()));
        request.setAttribute("purpose", purpose);
        request.setAttribute("cooldown", otpService.getRemainingCooldownSeconds(email.trim(), purpose));

        if ("1".equals(request.getParameter("sent"))) {
            request.setAttribute("infoMessage", "Mã xác thực OTP gồm 6 chữ số đã được gửi đến email của bạn.");
        }

        request.getRequestDispatcher("/WEB-INF/views/auth/verify-otp.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String email = request.getParameter("email");
        String purpose = request.getParameter("purpose");
        String action = request.getParameter("action");
        String otp = request.getParameter("otp");

        if (purpose == null || purpose.isBlank()) {
            purpose = "REGISTER";
        }

        if (email == null || email.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        email = email.trim();
        request.setAttribute("email", email);
        request.setAttribute("maskedEmail", maskEmail(email));
        request.setAttribute("purpose", purpose);

        if ("resend".equalsIgnoreCase(action)) {
            String resendError = otpService.generateAndSendOtp(email, purpose);
            if (resendError != null) {
                request.setAttribute("error", resendError);
            } else {
                request.setAttribute("successMessage", "Mã OTP mới đã được gửi thành công đến email của bạn. Vui lòng kiểm tra hộp thư.");
            }
            request.setAttribute("cooldown", otpService.getRemainingCooldownSeconds(email, purpose));
            request.getRequestDispatcher("/WEB-INF/views/auth/verify-otp.jsp").forward(request, response);
            return;
        }

        // Mặc định là action verify
        OtpVerifyResult result = otpService.verifyOtp(email, purpose, otp);
        if (!result.isSuccess()) {
            request.setAttribute("error", result.getMessage());
            request.setAttribute("cooldown", otpService.getRemainingCooldownSeconds(email, purpose));
            request.getRequestDispatcher("/WEB-INF/views/auth/verify-otp.jsp").forward(request, response);
            return;
        }

        // Xác thực OTP thành công
        if ("REGISTER".equalsIgnoreCase(purpose)) {
            accountService.activateAccount(email);
            response.sendRedirect(request.getContextPath() + "/login?activated=1");
        } else if ("FORGOT_PASSWORD".equalsIgnoreCase(purpose)) {
            HttpSession session = request.getSession();
            session.setAttribute("verified_reset_email", email);
            response.sendRedirect(request.getContextPath() + "/reset-password");
        } else {
            response.sendRedirect(request.getContextPath() + "/login");
        }
    }

    private String maskEmail(String email) {
        if (email == null || !email.contains("@")) return email;
        int atIndex = email.indexOf('@');
        String name = email.substring(0, atIndex);
        String domain = email.substring(atIndex);

        if (name.length() <= 2) {
            return name.charAt(0) + "***" + domain;
        }
        return name.charAt(0) + "***" + name.charAt(name.length() - 1) + domain;
    }
}
