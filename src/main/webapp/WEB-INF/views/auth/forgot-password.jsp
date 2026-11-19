<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Quên mật khẩu - ProductManager</title>
</head>
<body>
<div class="auth-card">
    <div class="auth-card-header">
        <h2><i class="bi bi-shield-lock me-2"></i>Quên mật khẩu</h2>
        <p>Nhập email để nhận mã xác nhận OTP</p>
    </div>
    <div class="auth-card-body">

        <c:if test="${not empty error}">
            <div class="alert alert-danger" role="alert">
                <i class="bi bi-exclamation-triangle me-2"></i><c:out value="${error}"/>
            </div>
        </c:if>

        <p class="text-muted mb-3" style="font-size:13px;">
            <i class="bi bi-info-circle me-1"></i>
            Vui lòng nhập địa chỉ email đã đăng ký. Hệ thống sẽ gửi mã OTP gồm 6 chữ số để đặt lại mật khẩu.
        </p>

        <form method="post" action="${pageContext.request.contextPath}/forgot-password" novalidate id="forgotForm">
            <div class="mb-3">
                <label for="email" class="form-label fw-semibold">Địa chỉ Email <span class="text-danger">*</span></label>
                <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-envelope"></i></span>
                    <input type="email" class="form-control" id="forgotEmail" name="email"
                           placeholder="name@example.com"
                           value="<c:out value='${email}'/>"
                           required autofocus>
                    <div class="invalid-feedback">Vui lòng nhập địa chỉ email hợp lệ.</div>
                </div>
            </div>

            <div class="d-grid mt-4">
                <button type="submit" class="btn btn-danger btn-lg">
                    <i class="bi bi-send me-2"></i>Gửi mã xác nhận
                </button>
            </div>
        </form>

        <div class="auth-footer-link mt-3">
            <a href="${pageContext.request.contextPath}/login" class="text-danger">
                <i class="bi bi-arrow-left me-1"></i>Quay lại Đăng nhập
            </a>
        </div>
    </div>
</div>

<script>
(function() {
    'use strict';
    var emailPattern = /^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,6}$/;
    var form = document.getElementById('forgotForm');
    if (!form) return;
    form.addEventListener('submit', function(e) {
        var email = document.getElementById('forgotEmail').value.trim();
        document.getElementById('forgotEmail').classList.remove('is-invalid');
        if (!email || !emailPattern.test(email)) {
            document.getElementById('forgotEmail').classList.add('is-invalid');
            e.preventDefault();
            e.stopPropagation();
        }
    });
})();
</script>
</body>
</html>
