<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Xác thực mã OTP - ProductManager</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>

<div class="auth-wrapper">
    <div class="auth-box">
        <div class="auth-header">
            <h2>
                <c:choose>
                    <c:when test="${purpose eq 'FORGOT_PASSWORD'}">Quên mật khẩu</c:when>
                    <c:otherwise>Xác thực tài khoản</c:otherwise>
                </c:choose>
            </h2>
            <p>Hệ thống Quản lý Sản phẩm</p>
        </div>

        <div class="auth-body">
            <c:if test="${not empty infoMessage}">
                <div class="alert alert-info">${infoMessage}</div>
            </c:if>

            <c:if test="${not empty successMessage}">
                <div class="alert alert-success">${successMessage}</div>
            </c:if>

            <c:if test="${not empty error}">
                <div class="alert alert-danger">${error}</div>
            </c:if>

            <p style="font-size: 13px; color: var(--color-text-muted); margin-bottom: 15px; text-align: center;">
                Mã xác thực gồm 6 chữ số đã được gửi tới email:<br>
                <strong style="color: var(--color-primary); font-size: 14px;">${not empty maskedEmail ? maskedEmail : email}</strong>
            </p>

            <form method="post" action="${pageContext.request.contextPath}/verify-otp">
                <input type="hidden" name="email" value="${email}">
                <input type="hidden" name="purpose" value="${purpose}">
                <input type="hidden" name="action" value="verify">

                <div class="form-group">
                    <label style="text-align: center; display: block;">Nhập mã OTP (6 chữ số):</label>
                    <input type="text"
                           class="form-control"
                           name="otp"
                           maxlength="6"
                           pattern="[0-9]{6}"
                           inputmode="numeric"
                           placeholder="••••••"
                           autocomplete="one-time-code"
                           style="text-align: center; font-size: 24px; letter-spacing: 10px; font-weight: bold; height: 45px; max-width: 100%;"
                           required
                           autofocus>
                    <small style="display: block; text-align: center; color: var(--color-text-muted); margin-top: 5px;">
                        Mã OTP có hiệu lực trong vòng 5 phút
                    </small>
                </div>

                <div style="margin-top: 15px;">
                    <button type="submit" class="btn btn-primary btn-block">Xác nhận</button>
                </div>
            </form>

            <form method="post" action="${pageContext.request.contextPath}/verify-otp" style="margin-top: 10px;">
                <input type="hidden" name="email" value="${email}">
                <input type="hidden" name="purpose" value="${purpose}">
                <input type="hidden" name="action" value="resend">
                <button type="submit" id="btnResend" class="btn btn-default btn-block">Gửi lại mã OTP</button>
            </form>

            <div class="auth-footer" style="margin-top: 20px;">
                <a href="${pageContext.request.contextPath}/login">← Quay lại Đăng nhập</a>
            </div>
        </div>
    </div>
</div>

<script>
    (function () {
        var cooldown = parseInt("${cooldown}", 10) || 0;
        var btn = document.getElementById("btnResend");
        if (!btn) return;

        if (cooldown > 0) {
            btn.disabled = true;
            var originalText = "Gửi lại mã OTP";

            var interval = setInterval(function () {
                if (cooldown <= 0) {
                    clearInterval(interval);
                    btn.disabled = false;
                    btn.innerText = originalText;
                } else {
                    btn.innerText = originalText + " (" + cooldown + "s)";
                    cooldown--;
                }
            }, 1000);
        }
    })();
</script>

</body>
</html>
