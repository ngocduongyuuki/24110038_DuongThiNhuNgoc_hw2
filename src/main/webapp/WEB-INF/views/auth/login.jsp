<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Đăng nhập - ProductManager</title>
</head>
<body>
<div class="auth-card">
    <div class="auth-card-header">
        <h2><i class="bi bi-lock-fill me-2"></i>Đăng nhập</h2>
        <p>Vui lòng đăng nhập để tiếp tục</p>
    </div>
    <div class="auth-card-body">

        <c:if test="${not empty param.activated}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle me-2"></i>Tài khoản đã được kích hoạt thành công! Vui lòng đăng nhập.
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${not empty param.reset}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle me-2"></i>Đặt lại mật khẩu thành công! Vui lòng đăng nhập bằng mật khẩu mới.
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${not empty param.logout or not empty param.logged_out}">
            <div class="alert alert-info alert-dismissible fade show" role="alert">
                <i class="bi bi-info-circle me-2"></i>Bạn đã đăng xuất an toàn khỏi hệ thống.
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <c:if test="${not empty error}">
            <div class="alert alert-danger" role="alert">
                <i class="bi bi-exclamation-triangle me-2"></i>${error}
                <c:if test="${not empty pendingEmail}">
                    <div class="mt-2">
                        <a href="${pageContext.request.contextPath}/verify-otp?email=${pendingEmail}&purpose=REGISTER"
                           class="btn btn-sm btn-outline-danger">
                            <i class="bi bi-envelope-check me-1"></i>Nhập mã OTP kích hoạt ngay
                        </a>
                    </div>
                </c:if>
            </div>
        </c:if>

        <form method="post" action="${pageContext.request.contextPath}/login" novalidate id="loginForm">
            <div class="mb-3">
                <label for="username" class="form-label fw-semibold">Tên đăng nhập hoặc Email</label>
                <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-person"></i></span>
                    <input type="text" class="form-control" id="username" name="username"
                           placeholder="Nhập username hoặc địa chỉ email"
                           value="${not empty username ? username : (not empty param.username ? param.username : '')}"
                           required autofocus>
                    <div class="invalid-feedback">Vui lòng nhập tên đăng nhập hoặc email.</div>
                </div>
            </div>

            <div class="mb-3">
                <div class="d-flex justify-content-between align-items-center mb-1">
                    <label for="password" class="form-label fw-semibold mb-0">Mật khẩu</label>
                    <a href="${pageContext.request.contextPath}/forgot-password" class="text-danger" style="font-size:12px;">
                        Quên mật khẩu?
                    </a>
                </div>
                <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-key"></i></span>
                    <input type="password" class="form-control" id="password" name="password"
                           placeholder="Nhập mật khẩu" required>
                    <button class="btn btn-outline-secondary" type="button" onclick="togglePassword('password', this)" tabindex="-1">
                        <i class="bi bi-eye"></i>
                    </button>
                    <div class="invalid-feedback">Vui lòng nhập mật khẩu.</div>
                </div>
            </div>

            <div class="d-grid mt-4">
                <button type="submit" class="btn btn-danger btn-lg">
                    <i class="bi bi-box-arrow-in-right me-2"></i>Đăng nhập
                </button>
            </div>
        </form>

        <div class="auth-footer-link mt-3">
            Chưa có tài khoản? <a href="${pageContext.request.contextPath}/register" class="text-danger fw-semibold">Đăng ký ngay</a>
        </div>
    </div>
</div>

<script>
function togglePassword(fieldId, btn) {
    var field = document.getElementById(fieldId);
    var icon = btn.querySelector('i');
    if (field.type === 'password') {
        field.type = 'text';
        icon.className = 'bi bi-eye-slash';
    } else {
        field.type = 'password';
        icon.className = 'bi bi-eye';
    }
}

(function() {
    'use strict';
    var form = document.getElementById('loginForm');
    if (!form) return;
    form.addEventListener('submit', function(e) {
        var username = document.getElementById('username').value.trim();
        var password = document.getElementById('password').value;
        var valid = true;
        // Reset
        form.querySelectorAll('.is-invalid').forEach(function(el){ el.classList.remove('is-invalid'); });

        if (!username) {
            document.getElementById('username').classList.add('is-invalid');
            valid = false;
        }
        if (!password) {
            document.getElementById('password').classList.add('is-invalid');
            valid = false;
        }
        if (!valid) {
            e.preventDefault();
            e.stopPropagation();
        }
    });
})();
</script>
</body>
</html>
