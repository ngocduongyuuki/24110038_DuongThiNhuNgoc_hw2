<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Chi tiết video - <c:out value="${video.title}"/></title>
</head>
<body>
    <div class="d-flex align-items-center mb-3">
        <a href="${pageContext.request.contextPath}/video" class="btn btn-sm btn-outline-secondary me-2">
            <i class="bi bi-arrow-left"></i>
        </a>
        <div>
            <h1 class="h4 mb-0"><i class="bi bi-play-circle me-2 text-danger"></i>Chi tiết video</h1>
        </div>
    </div>

    <c:choose>
        <c:when test="${not empty errorMsg}">
            <div class="alert alert-warning" role="alert">
                <i class="bi bi-exclamation-triangle me-2"></i><strong>${errorMsg}</strong>
                <div class="mt-2">
                    <a href="${pageContext.request.contextPath}/home" class="btn btn-sm btn-outline-secondary me-1">
                        <i class="bi bi-house me-1"></i>Trang chủ
                    </a>
                    <a href="${pageContext.request.contextPath}/video" class="btn btn-sm btn-outline-secondary">
                        <i class="bi bi-camera-video me-1"></i>Danh sách video
                    </a>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div style="max-width:860px;">
                <h2 class="h5 fw-bold mb-3"><c:out value="${video.title}"/></h2>

                <!-- Video player -->
                <c:choose>
                    <c:when test="${fileExists}">
                        <div class="mb-3" style="background:#002336;border-radius:8px;overflow:hidden;">
                            <video controls autoplay style="width:100%;max-height:480px;display:block;">
                                <source src="${pageContext.request.contextPath}${video.videoPath}" type="video/mp4">
                                <source src="${pageContext.request.contextPath}${video.videoPath}" type="video/webm">
                                Trình duyệt của bạn không hỗ trợ phát video HTML5.
                            </video>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="alert alert-warning mb-3">
                            <i class="bi bi-exclamation-triangle me-2"></i>File video không còn tồn tại trên server hoặc đã bị xóa.
                        </div>
                    </c:otherwise>
                </c:choose>

                <!-- Metadata -->
                <div class="card mb-3 shadow-sm">
                    <div class="card-body py-2">
                        <table class="table table-borderless table-sm mb-0">
                            <tbody>
                                <tr>
                                    <td class="fw-semibold text-muted" style="width:140px;">
                                        <i class="bi bi-person me-1"></i>Người đăng
                                    </td>
                                    <td><strong><c:out value="${video.account.fullName}"/></strong>
                                        <span class="text-muted">(${video.account.username})</span></td>
                                </tr>
                                <tr>
                                    <td class="fw-semibold text-muted">
                                        <i class="bi bi-calendar me-1"></i>Ngày đăng
                                    </td>
                                    <td>${video.createdAtFormatted}</td>
                                </tr>
                                <tr>
                                    <td class="fw-semibold text-muted">
                                        <i class="bi bi-clock-history me-1"></i>Cập nhật
                                    </td>
                                    <td>${video.updatedAtFormatted}</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Description -->
                <c:if test="${not empty video.description}">
                    <div class="card mb-3 shadow-sm">
                        <div class="card-header bg-white py-2">
                            <strong><i class="bi bi-text-left me-2"></i>Mô tả</strong>
                        </div>
                        <div class="card-body">
                            <p style="white-space:pre-wrap;margin:0;font-size:13px;">
                                <c:out value="${video.description}"/>
                            </p>
                        </div>
                    </div>
                </c:if>

                <!-- Actions -->
                <div class="d-flex gap-2">
                    <a href="${pageContext.request.contextPath}/home" class="btn btn-outline-secondary">
                        <i class="bi bi-house me-1"></i>Trang chủ
                    </a>
                    <a href="${pageContext.request.contextPath}/video" class="btn btn-outline-secondary">
                        <i class="bi bi-camera-video me-1"></i>Danh sách video
                    </a>
                    <c:if test="${isOwner}">
                        <a href="${pageContext.request.contextPath}/video/edit?id=${video.id}"
                           class="btn btn-outline-primary">
                            <i class="bi bi-pencil me-1"></i>Chỉnh sửa
                        </a>
                        <a href="${pageContext.request.contextPath}/video/delete?id=${video.id}"
                           class="btn btn-danger"
                           onclick="return confirm('Bạn có chắc muốn xóa video này?');">
                            <i class="bi bi-trash me-1"></i>Xóa
                        </a>
                    </c:if>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</body>
</html>
