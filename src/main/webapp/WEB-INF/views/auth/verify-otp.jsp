<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Xác thực OTP - ProductManager</title>
</head>
<body>
<div class="auth-card">
    <div class="auth-card-header">
        <h2>
            <i class="bi bi-shield-check me-2"></i>
            <c:choose>
                <c:when test="${purpose eq 'FORGOT_PASSWORD'}">Quên mật khẩu</c:when>
                <c:when test="${purpose eq 'UPDATE_EMAIL'}">Xác thực Email mới</c:when>
                <c:otherwise>Xác thực tài khoản</c:otherwise>
            </c:choose>
        </h2>
        <p>Nhập mã OTP 6 chữ số đã được gửi đến email của bạn</p>
    </div>
    <div class="auth-card-body">

        <c:if test="${not empty infoMessage}">
            <div class="alert alert-info" role="alert">
                <i class="bi bi-info-circle me-2"></i>${infoMessage}
            </div>
        </c:if>
        <c:if test="${not empty successMessage}">
            <div class="alert alert-success" role="alert">
                <i class="bi bi-check-circle me-2"></i>${successMessage}
            </div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert alert-danger" role="alert">
                <i class="bi bi-exclamation-triangle me-2"></i>${error}
            </div>
        </c:if>

        <p class="text-center text-muted mb-3" style="font-size:13px;">
            Mã xác thực đã được gửi tới:<br>
            <strong class="text-danger">${not empty maskedEmail ? maskedEmail : email}</strong>
        </p>

        <form method="post" action="${pageContext.request.contextPath}/verify-otp" novalidate id="otpForm">
            <input type="hidden" name="email" value="${email}">
            <input type="hidden" name="purpose" value="${purpose}">
            <input type="hidden" name="action" value="verify">

            <div class="mb-3">
                <label class="form-label fw-semibold d-block text-center">Mã OTP (6 chữ số)</label>
                <input type="text" class="form-control form-control-lg text-center fw-bold"
                       name="otp" id="otpInput"
                       maxlength="6" pattern="[0-9]{6}" inputmode="numeric"
                       placeholder="● ● ● ● ● ●"
                       autocomplete="one-time-code"
                       style="letter-spacing: 12px; font-size: 1.5rem;"
                       required autofocus>
                <div class="invalid-feedback text-center">Mã OTP phải gồm đúng 6 chữ số.</div>
                <div class="form-text text-center text-muted mt-1" style="font-size:11px;">
                    <i class="bi bi-clock me-1"></i>Mã OTP có hiệu lực trong 5 phút
                </div>
            </div>

            <div class="d-grid">
                <button type="submit" class="btn btn-danger btn-lg">
                    <i class="bi bi-check2-circle me-2"></i>Xác nhận
                </button>
            </div>
        </form>

        <form method="post" action="${pageContext.request.contextPath}/verify-otp" class="d-grid mt-2">
            <input type="hidden" name="email" value="${email}">
            <input type="hidden" name="purpose" value="${purpose}">
            <input type="hidden" name="action" value="resend">
            <button type="submit" id="btnResend" class="btn btn-outline-secondary">
                <i class="bi bi-arrow-repeat me-1"></i>Gửi lại mã OTP
            </button>
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
    // OTP form validation
    var otpForm = document.getElementById('otpForm');
    if (otpForm) {
        otpForm.addEventListener('submit', function(e) {
            var otp = document.getElementById('otpInput').value.trim();
            document.getElementById('otpInput').classList.remove('is-invalid');
            if (!otp || !/^[0-9]{6}$/.test(otp)) {
                document.getElementById('otpInput').classList.add('is-invalid');
                e.preventDefault();
                e.stopPropagation();
            }
        });
        // Only allow digits
        document.getElementById('otpInput').addEventListener('input', function() {
            this.value = this.value.replace(/[^0-9]/g, '');
        });
    }

    // Cooldown for resend button
    var cooldown = parseInt("${cooldown}", 10) || 0;
    var btn = document.getElementById("btnResend");
    if (btn && cooldown > 0) {
        btn.disabled = true;
        var originalText = btn.innerHTML;
        var interval = setInterval(function() {
            if (cooldown <= 0) {
                clearInterval(interval);
                btn.disabled = false;
                btn.innerHTML = originalText;
            } else {
                btn.innerHTML = '<i class="bi bi-clock me-1"></i>Gửi lại mã OTP (' + cooldown + 's)';
                cooldown--;
            }
        }, 1000);
    }
})();
</script>
</body>
</html>
