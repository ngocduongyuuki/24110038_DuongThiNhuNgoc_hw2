<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Hồ sơ cá nhân - ProductManager</title>
    <style>
        .avatar-wrapper {
            position: relative;
            display: inline-block;
        }
        .avatar-img {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            object-fit: cover;
            border: 3px solid #C1121F;
        }
        .avatar-upload-btn {
            position: absolute;
            bottom: 4px;
            right: 4px;
            background: #C1121F;
            color: #fff;
            border: none;
            border-radius: 50%;
            width: 32px;
            height: 32px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 2px 6px rgba(0,0,0,0.3);
            transition: background 0.15s;
        }
        .avatar-upload-btn:hover { background: #780000; }
        #avatarPreview { display: none; }
        .section-title {
            font-weight: 700;
            color: #003049;
            border-left: 4px solid #C1121F;
            padding-left: 10px;
            margin-bottom: 16px;
        }
        .profile-card {
            background: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.08);
            padding: 24px;
            margin-bottom: 24px;
        }
        .email-badge {
            background: #f8d7da;
            color: #842029;
            font-size: 11px;
            border-radius: 4px;
            padding: 2px 8px;
            margin-left: 6px;
        }
    </style>
</head>
<body>

<div class="container-fluid px-0">
    <div class="d-flex align-items-center mb-4 gap-2">
        <i class="bi bi-person-circle fs-4 text-danger"></i>
        <h4 class="mb-0 fw-bold text-dark">Hồ sơ cá nhân</h4>
    </div>

    <%-- Thông báo thành công / lỗi --%>
    <c:if test="${not empty successMessage}">
        <div class="alert alert-success alert-dismissible fade show d-flex align-items-center" role="alert">
            <i class="bi bi-check-circle-fill me-2"></i>
            ${successMessage}
            <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert"></button>
        </div>
    </c:if>
    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>
            ${errorMessage}
            <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <div class="row g-4">

        <%-- Cột trái: Avatar --%>
        <div class="col-md-4 col-lg-3">
            <div class="profile-card text-center">
                <div class="avatar-wrapper mb-3">
                    <img id="avatarDisplay"
                         src="${not empty profileAccount.profileImage ? profileAccount.profileImage
                               : pageContext.request.contextPath.concat('/assets/images/avatar.svg')}"
                         alt="Avatar"
                         class="avatar-img"
                         onerror="this.src='${pageContext.request.contextPath}/assets/images/avatar.svg'">
                    <button type="button" class="avatar-upload-btn" onclick="document.getElementById('avatarFileInput').click()"
                            title="Thay đổi ảnh đại diện">
                        <i class="bi bi-camera-fill" style="font-size:14px;"></i>
                    </button>
                </div>
                <div class="fw-bold fs-5">${profileAccount.fullName}</div>
                <div class="text-muted small">@${profileAccount.username}</div>
                <div class="text-muted small mt-1">${profileAccount.email}</div>

                <%-- Form upload avatar (ẩn) --%>
                <form id="avatarForm" method="post" action="${pageContext.request.contextPath}/profile"
                      enctype="multipart/form-data" class="mt-3">
                    <input type="hidden" name="action" value="uploadAvatar">
                    <input type="file" id="avatarFileInput" name="avatar" accept="image/jpeg,image/png,image/webp,image/gif" class="d-none">
                    <div id="avatarPreview" class="mt-2 mb-2">
                        <img id="previewImg" src="" alt="Preview" class="avatar-img mb-2">
                        <div class="d-flex justify-content-center gap-2">
                            <button type="submit" class="btn btn-sm btn-danger">
                                <i class="bi bi-cloud-upload me-1"></i>Lưu ảnh
                            </button>
                            <button type="button" class="btn btn-sm btn-outline-secondary" onclick="cancelPreview()">Huỷ</button>
                        </div>
                    </div>
                    <c:if test="${not empty avatarError}">
                        <div class="alert alert-danger alert-sm mt-2 py-2 text-start" style="font-size:13px;">
                            <i class="bi bi-exclamation-triangle me-1"></i>${avatarError}
                        </div>
                    </c:if>
                </form>

                <div class="text-muted" style="font-size:11px; margin-top:8px;">
                    JPG, PNG, WEBP, GIF &mdash; tối đa 5 MB
                </div>
            </div>
        </div>

        <%-- Cột phải: Thông tin & Đổi email --%>
        <div class="col-md-8 col-lg-9">

            <%-- Card: Thông tin cá nhân --%>
            <div class="profile-card">
                <div class="section-title">Thông tin cá nhân</div>

                <c:if test="${not empty param.updateError}">
                    <div class="alert alert-danger py-2" style="font-size:13px;">
                        <i class="bi bi-exclamation-triangle me-1"></i>${param.updateError}
                    </div>
                </c:if>

                <form method="post" action="${pageContext.request.contextPath}/profile"
                      novalidate id="profileForm">
                    <input type="hidden" name="action" value="updateInfo">

                    <div class="row g-3">
                        <div class="col-sm-6">
                            <label class="form-label fw-semibold" for="fullName">Họ và tên <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="fullName" name="fullName"
                                   value="${profileAccount.fullName}" maxlength="100" required>
                            <div class="invalid-feedback">Họ và tên không được để trống.</div>
                        </div>
                        <div class="col-sm-6">
                            <label class="form-label fw-semibold" for="usernameField">Tên đăng nhập</label>
                            <input type="text" class="form-control bg-light" id="usernameField"
                                   value="${profileAccount.username}" readonly disabled>
                            <div class="form-text">Tên đăng nhập không thể thay đổi.</div>
                        </div>
                        <div class="col-sm-6">
                            <label class="form-label fw-semibold" for="phone">Số điện thoại</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-telephone"></i></span>
                                <input type="tel" class="form-control" id="phone" name="phone"
                                       value="${profileAccount.phone}" maxlength="15"
                                       placeholder="Nhập số điện thoại">
                            </div>
                            <div class="form-text">Chỉ chứa chữ số và dấu +, 8-15 ký tự.</div>
                            <div id="phoneError" class="text-danger small" style="display:none;"></div>
                        </div>
                        <div class="col-sm-6">
                            <label class="form-label fw-semibold">Email hiện tại</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-envelope"></i></span>
                                <input type="text" class="form-control bg-light"
                                       value="${profileAccount.email}" readonly disabled>
                            </div>
                            <div class="form-text">Để thay đổi email, dùng mục bên dưới.</div>
                        </div>
                    </div>

                    <c:if test="${not empty errorMessage and empty avatarError and empty emailError}">
                        <div class="alert alert-danger mt-3 py-2" style="font-size:13px;">
                            <i class="bi bi-exclamation-triangle me-1"></i>${errorMessage}
                        </div>
                    </c:if>

                    <div class="mt-4">
                        <button type="submit" class="btn btn-danger px-4">
                            <i class="bi bi-save me-2"></i>Lưu thay đổi
                        </button>
                    </div>
                </form>
            </div>

            <%-- Card: Đổi Email (OTP) --%>
            <div class="profile-card">
                <div class="section-title">Thay đổi địa chỉ Email</div>
                <p class="text-muted small mb-3">
                    Sau khi nhập email mới, hệ thống sẽ gửi mã OTP đến email mới để xác minh trước khi thay đổi.
                </p>

                <form method="post" action="${pageContext.request.contextPath}/profile"
                      novalidate id="emailChangeForm">
                    <input type="hidden" name="action" value="requestEmailChange">

                    <div class="row g-3 align-items-end">
                        <div class="col-sm-7">
                            <label class="form-label fw-semibold" for="newEmail">Email mới <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-envelope-at"></i></span>
                                <input type="email" class="form-control ${not empty emailError ? 'is-invalid' : ''}"
                                       id="newEmail" name="newEmail"
                                       placeholder="Nhập địa chỉ email mới" required>
                                <c:if test="${not empty emailError}">
                                    <div class="invalid-feedback">${emailError}</div>
                                </c:if>
                            </div>
                            <div id="newEmailError" class="text-danger small" style="display:none;"></div>
                        </div>
                        <div class="col-sm-5">
                            <button type="submit" class="btn btn-outline-danger w-100">
                                <i class="bi bi-send me-2"></i>Gửi mã OTP xác minh
                            </button>
                        </div>
                    </div>
                </form>
            </div>

        </div><%-- end col-right --%>
    </div><%-- end row --%>
</div>

<script>
// ─── Avatar Preview ────────────────────────────────────────────────────────
document.getElementById('avatarFileInput').addEventListener('change', function() {
    var file = this.files[0];
    if (!file) return;

    // Kiểm tra loại file phía client (server vẫn kiểm tra lại)
    var allowed = ['image/jpeg','image/png','image/webp','image/gif'];
    if (!allowed.includes(file.type)) {
        alert('Chỉ chấp nhận file ảnh JPG, PNG, WEBP hoặc GIF.');
        this.value = '';
        return;
    }
    if (file.size > 5 * 1024 * 1024) {
        alert('File ảnh không được vượt quá 5 MB.');
        this.value = '';
        return;
    }

    var reader = new FileReader();
    reader.onload = function(e) {
        document.getElementById('previewImg').src = e.target.result;
        document.getElementById('avatarPreview').style.display = 'block';
    };
    reader.readAsDataURL(file);
});

function cancelPreview() {
    document.getElementById('avatarFileInput').value = '';
    document.getElementById('avatarPreview').style.display = 'none';
    document.getElementById('previewImg').src = '';
}

// ─── Validation form thông tin cá nhân ────────────────────────────────────
(function() {
    var form = document.getElementById('profileForm');
    if (!form) return;
    form.addEventListener('submit', function(e) {
        var fullName = document.getElementById('fullName').value.trim();
        var phone = document.getElementById('phone').value.trim();
        var valid = true;

        // Reset
        document.getElementById('fullName').classList.remove('is-invalid');
        document.getElementById('phoneError').style.display = 'none';

        if (!fullName) {
            document.getElementById('fullName').classList.add('is-invalid');
            valid = false;
        } else if (fullName.length > 100) {
            document.getElementById('fullName').classList.add('is-invalid');
            document.querySelector('#fullName ~ .invalid-feedback') &&
                (document.querySelector('#fullName ~ .invalid-feedback').textContent = 'Họ và tên không được vượt quá 100 ký tự.');
            valid = false;
        }

        if (phone) {
            var phonePattern = /^[+0-9]{8,15}$/;
            if (!phonePattern.test(phone.replace(/\s+/g, ''))) {
                document.getElementById('phoneError').textContent = 'Số điện thoại không đúng định dạng.';
                document.getElementById('phoneError').style.display = 'block';
                valid = false;
            }
        }

        if (!valid) {
            e.preventDefault();
            e.stopPropagation();
        }
    });
})();

// ─── Validation form đổi email ─────────────────────────────────────────────
(function() {
    var form = document.getElementById('emailChangeForm');
    if (!form) return;
    form.addEventListener('submit', function(e) {
        var emailInput = document.getElementById('newEmail');
        var errorDiv = document.getElementById('newEmailError');
        var emailPattern = /^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,6}$/;
        var val = emailInput.value.trim();

        emailInput.classList.remove('is-invalid');
        errorDiv.style.display = 'none';

        if (!val) {
            emailInput.classList.add('is-invalid');
            errorDiv.textContent = 'Email mới không được để trống.';
            errorDiv.style.display = 'block';
            e.preventDefault();
        } else if (!emailPattern.test(val)) {
            emailInput.classList.add('is-invalid');
            errorDiv.textContent = 'Địa chỉ email không đúng định dạng.';
            errorDiv.style.display = 'block';
            e.preventDefault();
        }
    });
})();
</script>

</body>
</html>
