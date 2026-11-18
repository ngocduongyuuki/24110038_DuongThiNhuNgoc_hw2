<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quên mật khẩu - ProductManager</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>

<div class="auth-wrapper">
    <div class="auth-box">
        <div class="auth-header">
            <h2>Quên mật khẩu</h2>
            <p>Hệ thống Quản lý Sản phẩm</p>
        </div>

        <div class="auth-body">
            <c:if test="${not empty error}">
                <div class="alert alert-danger">${error}</div>
            </c:if>

            <p style="font-size: 13px; color: var(--color-text-muted); margin-bottom: 15px;">
                Vui lòng nhập địa chỉ email đã đăng ký. Hệ thống sẽ gửi một mã OTP gồm 6 chữ số để bạn đặt lại mật khẩu.
            </p>

            <form method="post" action="${pageContext.request.contextPath}/forgot-password">
                <div class="form-group">
                    <label>Địa chỉ Email:</label>
                    <input type="email"
                           class="form-control"
                           name="email"
                           placeholder="name@example.com"
                           value="${email}"
                           required
                           autofocus>
                </div>

                <div style="margin-top: 20px;">
                    <button type="submit" class="btn btn-primary btn-block">Gửi mã xác nhận</button>
                </div>
            </form>

            <div class="auth-footer" style="margin-top: 20px;">
                <a href="${pageContext.request.contextPath}/login">← Quay lại Đăng nhập</a>
            </div>
        </div>
    </div>
</div>

</body>
</html>
