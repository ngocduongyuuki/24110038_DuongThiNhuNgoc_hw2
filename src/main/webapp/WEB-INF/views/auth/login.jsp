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
            <c:if test="${not empty param.activated}">
                <div class="alert alert-success">Tài khoản đã được kích hoạt thành công! Vui lòng đăng nhập.</div>
            </c:if>
            <c:if test="${not empty param.reset}">
                <div class="alert alert-success">Đặt lại mật khẩu thành công! Vui lòng đăng nhập bằng mật khẩu mới.</div>
            </c:if>
            <c:if test="${not empty param.registered}">
                <div class="alert alert-success">Đăng ký thành công! Vui lòng đăng nhập.</div>
            </c:if>
            <c:if test="${not empty param.logout or not empty param.logged_out}">
                <div class="alert alert-success">Bạn đã đăng xuất an toàn khỏi hệ thống.</div>
            </c:if>

            <c:if test="${not empty error}">
                <div class="alert alert-danger">
                    ${error}
                    <c:if test="${not empty pendingEmail}">
                        <div style="margin-top: 8px;">
                            <a href="${pageContext.request.contextPath}/verify-otp?email=${pendingEmail}&purpose=REGISTER"
                               class="btn btn-default" style="padding: 4px 10px; font-size: 12px;">
                                👉 Nhập mã OTP kích hoạt ngay
                            </a>
                        </div>
                    </c:if>
                </div>
            </c:if>

            <form method="post" action="${pageContext.request.contextPath}/login">
                <div class="form-group">
                    <label>Tên đăng nhập hoặc Email:</label>
                    <input type="text" class="form-control" name="username"
                           placeholder="Nhập username hoặc địa chỉ email" required autofocus>
                </div>

                <div class="form-group">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
                        <label style="margin: 0;">Mật khẩu:</label>
                        <a href="${pageContext.request.contextPath}/forgot-password" style="font-size: 12px;">Quên mật khẩu?</a>
                    </div>
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
