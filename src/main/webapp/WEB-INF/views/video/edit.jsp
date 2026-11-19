<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Chỉnh sửa video - ProductManager</title>
</head>
<body>
    <div class="d-flex align-items-center mb-3">
        <a href="${pageContext.request.contextPath}/video" class="btn btn-sm btn-outline-secondary me-2">
            <i class="bi bi-arrow-left"></i>
        </a>
        <div>
            <h1 class="h4 mb-0"><i class="bi bi-pencil-square me-2 text-danger"></i>Chỉnh sửa video</h1>
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

            <form action="${pageContext.request.contextPath}/video/edit" method="post"
                  enctype="multipart/form-data" novalidate id="editVideoForm">
                <input type="hidden" name="videoId" value="${video.id}">

                <div class="mb-3">
                    <label for="title" class="form-label fw-semibold">
                        Tiêu đề <span class="text-danger">*</span>
                    </label>
                    <input type="text" class="form-control" id="editTitle" name="title"
                           value="<c:out value='${video.title}'/>"
                           maxlength="200" required>
                    <div class="invalid-feedback">Tiêu đề video không được để trống.</div>
                </div>

                <div class="mb-3">
                    <label for="editDesc" class="form-label fw-semibold">Mô tả</label>
                    <textarea class="form-control" id="editDesc" name="description" rows="3"><c:out value="${video.description}"/></textarea>
                </div>

                <div class="mb-3">
                    <label class="form-label fw-semibold">Video hiện tại</label>
                    <div>
                        <video controls style="max-width:100%;border-radius:4px;border:1px solid #dee2e6;max-height:220px;">
                            <source src="${pageContext.request.contextPath}${video.videoPath}" type="video/mp4">
                            Trình duyệt không hỗ trợ phát video.
                        </video>
                    </div>
                </div>

                <div class="mb-4">
                    <label for="videoFile" class="form-label fw-semibold">Thay file video</label>
                    <input type="file" class="form-control" id="editVideoFile" name="videoFile"
                           accept="video/mp4,video/webm,video/ogg,.mp4,.webm,.ogv,.mov">
                    <div class="form-text text-muted" style="font-size:11px;">
                        <i class="bi bi-info-circle me-1"></i>Chấp nhận: MP4, WebM, OGV, MOV. Tối đa 200MB. Bỏ trống để giữ file cũ.
                    </div>
                </div>

                <div class="d-flex gap-2">
                    <button type="submit" class="btn btn-danger">
                        <i class="bi bi-check-circle me-1"></i>Lưu thay đổi
                    </button>
                    <a href="${pageContext.request.contextPath}/video" class="btn btn-outline-dark">
                        <i class="bi bi-x-lg me-1"></i>Hủy
                    </a>
                </div>
            </form>
        </div>
    </div>

<script>
(function() {
    'use strict';
    var form = document.getElementById('editVideoForm');
    if (!form) return;
    form.addEventListener('submit', function(e) {
        var title = document.getElementById('editTitle').value.trim();
        document.getElementById('editTitle').classList.remove('is-invalid');
        if (!title || title.length > 200) {
            document.getElementById('editTitle').classList.add('is-invalid');
            e.preventDefault();
            e.stopPropagation();
        }
    });
})();
</script>
</body>
</html>
