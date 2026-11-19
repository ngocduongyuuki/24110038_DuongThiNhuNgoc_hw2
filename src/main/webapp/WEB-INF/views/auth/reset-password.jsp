<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Đặt lại mật khẩu - ProductManager</title>
</head>
<body>
<div class="auth-card">
    <div class="auth-card-header">
        <h2><i class="bi bi-lock-fill me-2"></i>Đặt lại mật khẩu</h2>
        <p>Tạo mật khẩu mới cho tài khoản của bạn</p>
    </div>
    <div class="auth-card-body">

        <c:if test="${not empty error}">
            <div class="alert alert-danger" role="alert">
                <i class="bi bi-exclamation-triangle me-2"></i><c:out value="${error}"/>
            </div>
        </c:if>

        <p class="text-muted mb-3" style="font-size:13px;">
            <i class="bi bi-person me-1"></i>Tài khoản:
            <strong class="text-danger"><c:out value="${email}"/></strong><br>
            Vui lòng nhập mật khẩu mới (ít nhất 6 ký tự).
        </p>

        <form method="post" action="${pageContext.request.contextPath}/reset-password" novalidate id="resetForm">
            <div class="mb-3">
                <label class="form-label fw-semibold">Mật khẩu mới <span class="text-danger">*</span></label>
                <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-key"></i></span>
                    <input type="password" class="form-control" id="resetPassword" name="password"
                           placeholder="Ít nhất 6 ký tự" required minlength="6" autofocus>
                    <button class="btn btn-outline-secondary" type="button" onclick="togglePassword('resetPassword', this)" tabindex="-1">
                        <i class="bi bi-eye"></i>
                    </button>
                    <div class="invalid-feedback">Mật khẩu phải có ít nhất 6 ký tự.</div>
                </div>
            </div>

            <div class="mb-3">
                <label class="form-label fw-semibold">Xác nhận mật khẩu mới <span class="text-danger">*</span></label>
                <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-key-fill"></i></span>
                    <input type="password" class="form-control" id="resetConfirm" name="confirmPassword"
                           placeholder="Nhập lại mật khẩu mới" required>
                    <button class="btn btn-outline-secondary" type="button" onclick="togglePassword('resetConfirm', this)" tabindex="-1">
                        <i class="bi bi-eye"></i>
                    </button>
                    <div class="invalid-feedback" id="resetConfirmError">Mật khẩu xác nhận không khớp.</div>
                </div>
            </div>

            <div class="d-grid mt-4">
                <button type="submit" class="btn btn-danger btn-lg">
                    <i class="bi bi-check-circle me-2"></i>Cập nhật mật khẩu
                </button>
            </div>
        </form>

        <div class="auth-footer-link mt-3">
            <a href="${pageContext.request.contextPath}/login" class="text-danger">
                <i class="bi bi-arrow-left me-1"></i>Hủy và Quay lại Đăng nhập
            </a>
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
    var form = document.getElementById('resetForm');
    if (!form) return;
    form.addEventListener('submit', function(e) {
        var valid = true;
        form.querySelectorAll('.is-invalid').forEach(function(el){ el.classList.remove('is-invalid'); });

        var pwd = document.getElementById('resetPassword').value;
        if (!pwd || pwd.length < 6) {
            document.getElementById('resetPassword').classList.add('is-invalid');
            valid = false;
        }
        var confirm = document.getElementById('resetConfirm').value;
        if (!confirm || confirm !== pwd) {
            document.getElementById('resetConfirm').classList.add('is-invalid');
            document.getElementById('resetConfirmError').textContent =
                !confirm ? 'Vui lòng nhập lại mật khẩu.' : 'Mật khẩu xác nhận không khớp.';
            valid = false;
        }
        if (!valid) { e.preventDefault(); e.stopPropagation(); }
    });
})();
</script>
</body>
</html>
