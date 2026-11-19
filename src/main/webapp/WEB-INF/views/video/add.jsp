<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Thêm video mới - ProductManager</title>
</head>
<body>
    <div class="d-flex align-items-center mb-3">
        <a href="${pageContext.request.contextPath}/video" class="btn btn-sm btn-outline-secondary me-2">
            <i class="bi bi-arrow-left"></i>
        </a>
        <div>
            <h1 class="h4 mb-0"><i class="bi bi-plus-circle me-2 text-danger"></i>Thêm video mới</h1>
        </div>
    </div>

    <div class="card shadow-sm" style="max-width:700px;">
        <div class="card-header bg-white">
            <strong><i class="bi bi-camera-video me-2"></i>Thông tin video</strong>
        </div>
        <div class="card-body">
            <c:if test="${not empty error}">
                <div class="alert alert-danger" role="alert">
                    <i class="bi bi-exclamation-triangle me-2"></i><c:out value="${error}"/>
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/video/add" method="post"
                  enctype="multipart/form-data" novalidate id="addVideoForm">

                <div class="mb-3">
                    <label for="title" class="form-label fw-semibold">
                        Tiêu đề <span class="text-danger">*</span>
                    </label>
                    <input type="text" class="form-control" id="title" name="title"
                           value="<c:out value='${title}'/>"
                           placeholder="Nhập tiêu đề video..." maxlength="200" required>
                    <div class="invalid-feedback">Tiêu đề video không được để trống.</div>
                </div>

                <div class="mb-3">
                    <label for="videoDesc" class="form-label fw-semibold">Mô tả</label>
                    <textarea class="form-control" id="videoDesc" name="description"
                              rows="3" placeholder="Nhập mô tả video (không bắt buộc)..."><c:out value="${description}"/></textarea>
                </div>

                <div class="mb-4">
                    <label for="videoFile" class="form-label fw-semibold">
                        File video <span class="text-danger">*</span>
                    </label>
                    <input type="file" class="form-control" id="videoFile" name="videoFile"
                           accept="video/mp4,video/webm,video/ogg,.mp4,.webm,.ogv,.mov" required>
                    <div class="invalid-feedback">Vui lòng chọn file video.</div>
                    <div class="form-text text-muted" style="font-size:11px;">
                        <i class="bi bi-info-circle me-1"></i>Chấp nhận: MP4, WebM, OGV, MOV. Kích thước tối đa: 200MB.
                    </div>
                    <div id="filePreview" class="mt-2" style="display:none;">
                        <video id="previewPlayer" controls
                               style="max-width:100%;border-radius:4px;border:1px solid #dee2e6;"></video>
                    </div>
                </div>

                <div class="d-flex gap-2">
                    <button type="submit" class="btn btn-danger">
                        <i class="bi bi-cloud-upload me-1"></i>Upload và lưu
                    </button>
                    <a href="${pageContext.request.contextPath}/video" class="btn btn-outline-dark">
                        <i class="bi bi-x-lg me-1"></i>Hủy
                    </a>
                </div>
            </form>
        </div>
    </div>

<script>
document.getElementById('videoFile').addEventListener('change', function() {
    var file = this.files[0];
    if (file) {
        var url = URL.createObjectURL(file);
        var preview = document.getElementById('previewPlayer');
        preview.src = url;
        document.getElementById('filePreview').style.display = 'block';
    }
});

(function() {
    'use strict';
    var form = document.getElementById('addVideoForm');
    if (!form) return;
    form.addEventListener('submit', function(e) {
        var valid = true;
        form.querySelectorAll('.is-invalid').forEach(function(el){ el.classList.remove('is-invalid'); });

        var title = document.getElementById('title').value.trim();
        if (!title || title.length > 200) {
            document.getElementById('title').classList.add('is-invalid');
            valid = false;
        }

        var fileInput = document.getElementById('videoFile');
        if (!fileInput.files || fileInput.files.length === 0) {
            fileInput.classList.add('is-invalid');
            valid = false;
        }

        if (!valid) { e.preventDefault(); e.stopPropagation(); }
    });
})();
</script>
</body>
</html>
