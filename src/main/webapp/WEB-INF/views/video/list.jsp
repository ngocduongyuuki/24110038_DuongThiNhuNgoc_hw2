<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Danh sách video - ProductManager</title>
    <style>
        .video-thumb-link {
            display: inline-block;
            cursor: pointer;
            text-decoration: none;
            line-height: 0;
        }
        .video-thumb-preview {
            width: 140px;
            height: 80px;
            object-fit: cover;
            border-radius: 6px;
            display: inline-block;
            vertical-align: middle;
            box-shadow: 0 1px 3px rgba(0,0,0,0.15);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        .video-thumb-link:hover .video-thumb-preview {
            transform: scale(1.04);
            box-shadow: 0 4px 10px rgba(0,0,0,0.25);
        }
        .video-table-title {
            color: #1a1a1a;
            font-weight: 600;
            text-decoration: none;
            transition: color 0.15s;
        }
        .video-table-title:hover {
            color: var(--bs-primary-custom, #C1121F);
        }
        .desc-truncate {
            max-width: 240px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        .page-link {
            color: #333;
        }
        .page-item.active .page-link {
            background-color: var(--bs-header-bg, #780000);
            border-color: var(--bs-header-bg, #780000);
            color: #fff;
        }
    </style>
</head>
<body>
    <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
        <div>
            <h1 class="h4 mb-1 text-dark fw-bold">
                <i class="bi bi-camera-video me-2 text-danger"></i>Danh sách video của tôi
            </h1>
            <p class="text-muted mb-0" style="font-size:13px;">
                Tổng số: <strong>${totalVideos}</strong> video &nbsp;|&nbsp; Trang <strong>${currentPage}</strong>/<strong>${totalPages}</strong>
            </p>
        </div>
        <a href="${pageContext.request.contextPath}/video/add" class="btn btn-danger">
            <i class="bi bi-plus-circle me-1"></i>Thêm video mới
        </a>
    </div>

    <c:if test="${not empty param.added}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="bi bi-check-circle-fill me-2"></i>Thêm video mới thành công!
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Đóng"></button>
        </div>
    </c:if>
    <c:if test="${not empty param.updated}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="bi bi-check-circle-fill me-2"></i>Cập nhật video thành công!
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Đóng"></button>
        </div>
    </c:if>
    <c:if test="${not empty param.deleted}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="bi bi-check-circle-fill me-2"></i>Xóa video thành công!
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Đóng"></button>
        </div>
    </c:if>
    <c:if test="${not empty param.deleteFailed}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>Xóa video thất bại. Vui lòng thử lại.
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Đóng"></button>
        </div>
    </c:if>

    <div class="card shadow-sm border-0">
        <div class="card-body p-0">
            <c:choose>
                <c:when test="${empty videos}">
                    <div class="text-center py-5 text-muted">
                        <i class="bi bi-camera-video" style="font-size:3rem;"></i>
                        <p class="mt-2 mb-3">Bạn chưa có video nào.</p>
                        <a href="${pageContext.request.contextPath}/video/add" class="btn btn-danger">
                            <i class="bi bi-plus-circle me-1"></i>Thêm video đầu tiên
                        </a>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="table-responsive">
                        <table class="table table-hover table-bordered mb-0 align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th class="text-center text-nowrap" style="width:50px;">STT</th>
                                    <th class="text-center text-nowrap" style="width:160px;">Preview</th>
                                    <th>Tiêu đề</th>
                                    <th>Mô tả</th>
                                    <th class="text-nowrap" style="width:130px;">Ngày đăng</th>
                                    <th class="text-center text-nowrap" style="width:140px;">Hành động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="v" items="${videos}" varStatus="st">
                                    <tr>
                                        <td class="text-center fw-semibold text-secondary">
                                            ${(currentPage - 1) * 6 + st.index + 1}
                                        </td>
                                        <td class="text-center">
                                            <a href="${pageContext.request.contextPath}/video/detail?id=${v.id}"
                                               class="video-thumb-link"
                                               title="Xem chi tiết: <c:out value='${v.title}'/>">
                                                <c:choose>
                                                    <c:when test="${not empty v.thumbnailPath}">
                                                        <img src="${pageContext.request.contextPath}${v.thumbnailPath}" alt="Thumbnail"
                                                             class="video-thumb-preview"
                                                             onerror="this.style.display='none'; if(this.nextElementSibling) this.nextElementSibling.style.display='inline-block';">
                                                        <video preload="metadata" muted playsinline class="video-thumb-preview" style="display:none;background:#002336;pointer-events:none;">
                                                            <source src="${pageContext.request.contextPath}${v.videoPath}#t=0.001" type="video/mp4">
                                                        </video>
                                                    </c:when>
                                                    <c:when test="${not empty v.videoPath}">
                                                        <video preload="metadata" muted playsinline class="video-thumb-preview" style="background:#002336;pointer-events:none;">
                                                            <source src="${pageContext.request.contextPath}${v.videoPath}#t=0.001" type="video/mp4">
                                                        </video>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <div class="video-thumb-preview bg-dark d-inline-flex align-items-center justify-content-center text-white">
                                                            <i class="bi bi-camera-video text-muted fs-4"></i>
                                                        </div>
                                                    </c:otherwise>
                                                </c:choose>
                                            </a>
                                        </td>
                                        <td>
                                            <a href="${pageContext.request.contextPath}/video/detail?id=${v.id}" class="video-table-title">
                                                <c:out value="${v.title}"/>
                                            </a>
                                        </td>
                                        <td class="desc-truncate" title="<c:out value='${v.description}'/>">
                                            <c:choose>
                                                <c:when test="${not empty v.description}">
                                                    <c:out value="${v.description}"/>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted fst-italic">Không có mô tả</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-muted small text-nowrap">${v.createdAtFormatted}</td>
                                        <td class="text-center text-nowrap">
                                            <a href="${pageContext.request.contextPath}/video/detail?id=${v.id}"
                                               class="btn btn-sm btn-outline-info me-1" title="Xem chi tiết">
                                                <i class="bi bi-eye"></i>
                                            </a>
                                            <a href="${pageContext.request.contextPath}/video/edit?id=${v.id}"
                                               class="btn btn-sm btn-outline-primary me-1" title="Chỉnh sửa">
                                                <i class="bi bi-pencil"></i>
                                            </a>
                                            <a href="${pageContext.request.contextPath}/video/delete?id=${v.id}"
                                               class="btn btn-sm btn-outline-danger"
                                               title="Xóa video"
                                               onclick="return confirm('Bạn có chắc muốn xóa video &quot;${v.title}&quot;?');">
                                                <i class="bi bi-trash"></i>
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>

                    <%-- Pagination --%>
                    <c:if test="${totalPages > 1}">
                        <div class="d-flex justify-content-between align-items-center px-3 py-3 border-top flex-wrap gap-2">
                            <div class="text-muted small">
                                Hiển thị video <strong>${(currentPage - 1) * 6 + 1}</strong> &ndash; <strong>${(currentPage - 1) * 6 + videos.size()}</strong> trong tổng số <strong>${totalVideos}</strong>
                            </div>
                            <nav aria-label="Phân trang video">
                                <ul class="pagination pagination-sm mb-0">
                                    <li class="page-item ${currentPage <= 1 ? 'disabled' : ''}">
                                        <a class="page-link" href="${pageContext.request.contextPath}/video?page=${currentPage - 1}" aria-label="Trang trước">
                                            <span aria-hidden="true">&laquo;</span>
                                        </a>
                                    </li>
                                    <c:forEach begin="1" end="${totalPages}" var="p">
                                        <li class="page-item ${p == currentPage ? 'active' : ''}">
                                            <a class="page-link" href="${pageContext.request.contextPath}/video?page=${p}">${p}</a>
                                        </li>
                                    </c:forEach>
                                    <li class="page-item ${currentPage >= totalPages ? 'disabled' : ''}">
                                        <a class="page-link" href="${pageContext.request.contextPath}/video?page=${currentPage + 1}" aria-label="Trang sau">
                                            <span aria-hidden="true">&raquo;</span>
                                        </a>
                                    </li>
                                </ul>
                            </nav>
                        </div>
                    </c:if>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</body>
</html>
