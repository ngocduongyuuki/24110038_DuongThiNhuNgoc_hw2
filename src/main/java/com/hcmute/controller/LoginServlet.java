package com.hcmute.controller;

import com.hcmute.dao.AccountDAO;
import com.hcmute.dao.impl.AccountDAOImpl;
import com.hcmute.model.Account;
import com.hcmute.service.AccountService;
import com.hcmute.service.impl.AccountServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private final AccountService accountService = new AccountServiceImpl();
    private final AccountDAO accountDAO = new AccountDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("account") != null) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }
        request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String usernameOrEmail = request.getParameter("username");
        String password = request.getParameter("password");

        if (usernameOrEmail == null || usernameOrEmail.trim().isEmpty()) {
            request.setAttribute("error", "Tên đăng nhập hoặc email không được để trống.");
            request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
            return;
        }

        if (password == null || password.trim().isEmpty()) {
            request.setAttribute("username", usernameOrEmail.trim());
            request.setAttribute("error", "Mật khẩu không được để trống.");
            request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
            return;
        }

        request.setAttribute("username", usernameOrEmail.trim());

        // Kiểm tra tài khoản chưa kích hoạt để đưa ra thông báo phù hợp
        Account found = accountDAO.findByUsernameOrEmail(usernameOrEmail.trim());
        if (found != null && !found.isActive()) {
            request.setAttribute("error", "Tài khoản chưa được kích hoạt. Vui lòng kiểm tra email để xác thực OTP.");
            request.setAttribute("pendingEmail", found.getEmail());
            request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
            return;
        }

        Account account = accountService.login(usernameOrEmail.trim(), password);

        if (account != null) {
            HttpSession session = request.getSession();
            // Tuyệt đối không lưu mật khẩu hoặc hash mật khẩu trong session
            Account safeAccount = new Account(
                account.getId(),
                account.getFullName(),
                account.getUsername(),
                account.getEmail(),
                account.getPhone(),
                null,
                account.isActive()
            );
            safeAccount.setProfileImage(account.getProfileImage());
            session.setAttribute("account", safeAccount);
            response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
            response.setHeader("Pragma", "no-cache");
            response.setDateHeader("Expires", 0);
            response.sendRedirect(request.getContextPath() + "/home");
        } else {
            request.setAttribute("error", "Tên đăng nhập hoặc mật khẩu không đúng.");
            request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
        }
    }
}
