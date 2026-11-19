<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Đăng ký - ProductManager</title>
</head>
<body>
<div class="auth-card">
    <div class="auth-card-header">
        <h2><i class="bi bi-person-plus-fill me-2"></i>Đăng ký tài khoản</h2>
        <p>Tạo tài khoản mới để sử dụng hệ thống</p>
    </div>
    <div class="auth-card-body">

        <c:if test="${not empty error}">
            <div class="alert alert-danger" role="alert">
                <i class="bi bi-exclamation-triangle me-2"></i><c:out value="${error}"/>
            </div>
        </c:if>

        <form method="post" action="${pageContext.request.contextPath}/register" novalidate id="registerForm">
            <div class="mb-3">
                <label for="fullName" class="form-label fw-semibold">Họ và tên <span class="text-danger">*</span></label>
                <input type="text" class="form-control" id="fullName" name="fullName"
                       placeholder="Nhập họ và tên đầy đủ"
                       value="<c:out value='${account.fullName}'/>"
                       required maxlength="100">
                <div class="invalid-feedback">Họ và tên không được để trống.</div>
            </div>

            <div class="mb-3">
                <label for="username" class="form-label fw-semibold">Tên đăng nhập <span class="text-danger">*</span></label>
                <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-at"></i></span>
                    <input type="text" class="form-control" id="regUsername" name="username"
                           placeholder="a-z, 0-9, dấu chấm, gạch dưới"
                           value="<c:out value='${account.username}'/>"
                           required maxlength="50" pattern="[a-zA-Z0-9._-]+">
                    <div class="invalid-feedback">Tên đăng nhập chỉ được chứa a-z, 0-9, dấu chấm, gạch ngang, gạch dưới.</div>
                </div>
                <div class="form-text text-muted" style="font-size:11px;">Tối đa 50 ký tự, chỉ dùng a-z, 0-9, dấu . _ -</div>
            </div>

            <div class="mb-3">
                <label for="email" class="form-label fw-semibold">Email <span class="text-danger">*</span></label>
                <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-envelope"></i></span>
                    <input type="email" class="form-control" id="regEmail" name="email"
                           placeholder="name@example.com"
                           value="<c:out value='${account.email}'/>"
                           required maxlength="100">
                    <div class="invalid-feedback">Vui lòng nhập email hợp lệ.</div>
                </div>
            </div>

            <div class="mb-3">
                <label for="phone" class="form-label fw-semibold">Số điện thoại</label>
                <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-telephone"></i></span>
                    <input type="tel" class="form-control" id="phone" name="phone"
                           placeholder="0912345678 (tùy chọn)"
                           value="<c:out value='${account.phone}'/>"
                           maxlength="15" pattern="[+0-9]{8,15}">
                    <div class="invalid-feedback">Số điện thoại không hợp lệ (8-15 chữ số, có thể bắt đầu bằng +).</div>
                </div>
            </div>

            <div class="mb-3">
                <label for="password" class="form-label fw-semibold">Mật khẩu <span class="text-danger">*</span></label>
                <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-key"></i></span>
                    <input type="password" class="form-control" id="regPassword" name="password"
                           placeholder="Ít nhất 6 ký tự"
                           required minlength="6">
                    <button class="btn btn-outline-secondary" type="button" onclick="togglePassword('regPassword', this)" tabindex="-1">
                        <i class="bi bi-eye"></i>
                    </button>
                    <div class="invalid-feedback">Mật khẩu phải có ít nhất 6 ký tự.</div>
                </div>
            </div>

            <div class="mb-3">
                <label for="confirmPassword" class="form-label fw-semibold">Xác nhận mật khẩu <span class="text-danger">*</span></label>
                <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-key-fill"></i></span>
                    <input type="password" class="form-control" id="confirmPassword" name="confirmPassword"
                           placeholder="Nhập lại mật khẩu"
                           required minlength="6">
                    <button class="btn btn-outline-secondary" type="button" onclick="togglePassword('confirmPassword', this)" tabindex="-1">
                        <i class="bi bi-eye"></i>
                    </button>
                    <div class="invalid-feedback" id="confirmPasswordError">Mật khẩu xác nhận không khớp.</div>
                </div>
            </div>

            <div class="d-grid mt-4">
                <button type="submit" class="btn btn-danger btn-lg">
                    <i class="bi bi-person-check me-2"></i>Đăng ký
                </button>
            </div>
        </form>

        <div class="auth-footer-link mt-3">
            Đã có tài khoản? <a href="${pageContext.request.contextPath}/login" class="text-danger fw-semibold">Đăng nhập</a>
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
    var form = document.getElementById('registerForm');
    if (!form) return;

    var usernamePattern = /^[a-zA-Z0-9._-]+$/;
    var emailPattern = /^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,6}$/;
    var phonePattern = /^[+0-9]{8,15}$/;

    form.addEventListener('submit', function(e) {
        var valid = true;
        // Reset
        form.querySelectorAll('.is-invalid').forEach(function(el) { el.classList.remove('is-invalid'); });
        form.querySelectorAll('.is-valid').forEach(function(el) { el.classList.remove('is-valid'); });

        var fullName = document.getElementById('fullName').value.trim();
        if (!fullName || fullName.length > 100) {
            document.getElementById('fullName').classList.add('is-invalid');
            valid = false;
        }

        var username = document.getElementById('regUsername').value.trim();
        if (!username || username.length > 50 || !usernamePattern.test(username)) {
            document.getElementById('regUsername').classList.add('is-invalid');
            valid = false;
        }

        var email = document.getElementById('regEmail').value.trim();
        if (!email || !emailPattern.test(email)) {
            document.getElementById('regEmail').classList.add('is-invalid');
            valid = false;
        }

        var phone = document.getElementById('phone').value.trim();
        if (phone && !phonePattern.test(phone)) {
            document.getElementById('phone').classList.add('is-invalid');
            valid = false;
        }

        var password = document.getElementById('regPassword').value;
        if (!password || password.length < 6) {
            document.getElementById('regPassword').classList.add('is-invalid');
            valid = false;
        }

        var confirmPwd = document.getElementById('confirmPassword').value;
        if (!confirmPwd || confirmPwd !== password) {
            var el = document.getElementById('confirmPassword');
            el.classList.add('is-invalid');
            document.getElementById('confirmPasswordError').textContent =
                !confirmPwd ? 'Vui lòng xác nhận mật khẩu.' : 'Mật khẩu xác nhận không khớp.';
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
