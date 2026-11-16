<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đặt lại mật khẩu - ProductManager</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>

<div class="auth-wrapper">
    <div class="auth-box">
        <div class="auth-header">
            <h2>Đặt lại mật khẩu</h2>
            <p>Hệ thống Quản lý Sản phẩm</p>
        </div>

        <div class="auth-body">
            <c:if test="${not empty error}">
                <div class="alert alert-danger">${error}</div>
            </c:if>

            <p style="font-size: 13px; color: #555555; margin-bottom: 15px;">
                Tài khoản: <strong style="color: #0080ff;">${email}</strong><br>
                Vui lòng nhập mật khẩu mới của bạn (ít nhất 6 ký tự).
            </p>

            <form method="post" action="${pageContext.request.contextPath}/reset-password">
                <div class="form-group">
                    <label>Mật khẩu mới:</label>
                    <input type="password"
                           class="form-control"
                           name="password"
                           placeholder="Ít nhất 6 ký tự"
                           required
                           minlength="6"
                           autofocus>
                </div>

                <div class="form-group">
                    <label>Xác nhận mật khẩu mới:</label>
                    <input type="password"
                           class="form-control"
                           name="confirmPassword"
                           placeholder="Nhập lại mật khẩu mới"
                           required>
                </div>

                <div style="margin-top: 20px;">
                    <button type="submit" class="btn btn-primary btn-block">Cập nhật mật khẩu</button>
                </div>
            </form>

            <div class="auth-footer" style="margin-top: 20px;">
                <a href="${pageContext.request.contextPath}/login">← Hủy và Quay lại Đăng nhập</a>
            </div>
        </div>
    </div>
</div>

</body>
</html>
