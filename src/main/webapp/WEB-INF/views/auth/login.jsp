<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập - ProductManager</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>

<div class="auth-wrapper">
    <div class="auth-box">
        <div class="auth-header">
            <h2>Đăng nhập</h2>
            <p>Hệ thống Quản lý Sản phẩm</p>
        </div>

        <div class="auth-body">
            <c:if test="${not empty param.registered}">
                <div class="alert alert-success">Đăng ký thành công! Vui lòng đăng nhập.</div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="alert alert-danger">${error}</div>
            </c:if>

            <form method="post" action="${pageContext.request.contextPath}/login">
                <div class="form-group">
                    <label>Tên đăng nhập:</label>
                    <input type="text" class="form-control" name="username" placeholder="Nhập tên đăng nhập" required autofocus>
                </div>

                <div class="form-group">
                    <label>Mật khẩu:</label>
                    <input type="password" class="form-control" name="password" placeholder="Nhập mật khẩu" required>
                </div>

                <div style="margin-top: 20px;">
                    <button type="submit" class="btn btn-primary btn-block">Đăng nhập</button>
                </div>
            </form>

            <div class="auth-footer">
                Chưa có tài khoản? <a href="${pageContext.request.contextPath}/register">Đăng ký ngay</a>
            </div>
        </div>
    </div>
</div>

</body>
</html>
