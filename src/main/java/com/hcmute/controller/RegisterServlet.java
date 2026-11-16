package com.hcmute.controller;

import com.hcmute.model.Account;
import com.hcmute.service.AccountService;
import com.hcmute.service.impl.AccountServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private final AccountService accountService = new AccountServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        Account account = new Account();
        account.setFullName(request.getParameter("fullName"));
        account.setUsername(request.getParameter("username"));
        account.setEmail(request.getParameter("email"));
        account.setPhone(request.getParameter("phone"));
        account.setPassword(request.getParameter("password"));

        String confirmPassword = request.getParameter("confirmPassword");

        String error = accountService.register(account, confirmPassword);

        if (error != null) {
            request.setAttribute("error", error);
            request.setAttribute("account", account);
            request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/login?registered=1");
        }
    }
}
