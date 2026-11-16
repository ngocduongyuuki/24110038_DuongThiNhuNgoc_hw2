<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng ký - ProductManager</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>

<div class="auth-wrapper">
    <div class="auth-box">
        <div class="auth-header">
            <h2>Đăng ký tài khoản</h2>
            <p>Hệ thống Quản lý Sản phẩm</p>
        </div>

        <div class="auth-body">
            <c:if test="${not empty error}">
                <div class="alert alert-danger">${error}</div>
            </c:if>

            <form method="post" action="${pageContext.request.contextPath}/register">
                <div class="form-group">
                    <label>Họ và tên:</label>
                    <input type="text" class="form-control" name="fullName"
                           placeholder="Nhập họ và tên" value="${account.fullName}" required>
                </div>

                <div class="form-group">
                    <label>Tên đăng nhập:</label>
                    <input type="text" class="form-control" name="username"
                           placeholder="Nhập tên đăng nhập" value="${account.username}" required>
                </div>

                <div class="form-group">
                    <label>Email:</label>
                    <input type="email" class="form-control" name="email"
                           placeholder="name@example.com" value="${account.email}" required>
                </div>

                <div class="form-group">
                    <label>Số điện thoại:</label>
                    <input type="tel" class="form-control" name="phone"
                           placeholder="Nhập số điện thoại" value="${account.phone}">
                </div>

                <div class="form-group">
                    <label>Mật khẩu:</label>
                    <input type="password" class="form-control" name="password"
                           placeholder="Ít nhất 6 ký tự" required minlength="6">
                </div>

                <div class="form-group">
                    <label>Xác nhận mật khẩu:</label>
                    <input type="password" class="form-control" name="confirmPassword"
                           placeholder="Nhập lại mật khẩu" required>
                </div>

                <div style="margin-top: 20px;">
                    <button type="submit" class="btn btn-primary btn-block">Đăng ký</button>
                </div>
            </form>

            <div class="auth-footer">
                Đã có tài khoản? <a href="${pageContext.request.contextPath}/login">Đăng nhập</a>
            </div>
        </div>
    </div>
</div>

</body>
</html>
