<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Danh sách video - ProductManager</title>
</head>
<body>
    <div class="d-flex justify-content-between align-items-center mb-3">
        <div>
            <h1 class="h4 mb-1"><i class="bi bi-camera-video me-2 text-danger"></i>Danh sách video của tôi</h1>
            <p class="text-muted mb-0" style="font-size:13px;">
                Tổng: <strong>${totalVideos}</strong> video &nbsp;|&nbsp; Trang ${currentPage}/${totalPages}
            </p>
        </div>
        <a href="${pageContext.request.contextPath}/video/add" class="btn btn-danger">
            <i class="bi bi-plus-circle me-1"></i>Thêm video mới
        </a>
    </div>

    <c:if test="${not empty param.added}">
        <div class="alert alert-success alert-dismissible fade show">
            <i class="bi bi-check-circle me-2"></i>Thêm video thành công!
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>
    <c:if test="${not empty param.updated}">
        <div class="alert alert-success alert-dismissible fade show">
            <i class="bi bi-check-circle me-2"></i>Cập nhật video thành công!
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>
    <c:if test="${not empty param.deleted}">
        <div class="alert alert-success alert-dismissible fade show">
            <i class="bi bi-check-circle me-2"></i>Xóa video thành công!
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>
    <c:if test="${not empty param.deleteFailed}">
        <div class="alert alert-danger alert-dismissible fade show">
            <i class="bi bi-exclamation-triangle me-2"></i>Xóa video thất bại. Vui lòng thử lại.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <div class="card shadow-sm">
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
                                    <th class="text-center" style="width:45px;">STT</th>
                                    <th class="text-center" style="width:160px;">Preview</th>
                                    <th>Tiêu đề</th>
                                    <th>Mô tả</th>
                                    <th style="width:120px;">Ngày đăng</th>
                                    <th class="text-center" style="width:120px;">Hành động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="v" items="${videos}" varStatus="st">
                                    <tr>
                                        <td class="text-center">${(currentPage - 1) * 6 + st.index + 1}</td>
                                        <td class="text-center">
                                            <c:choose>
                                                <c:when test="${not empty v.videoPath}">
                                                    <video preload="metadata" muted
                                                           style="width:140px;height:80px;object-fit:cover;border-radius:4px;background:#002336;">
                                                        <source src="${pageContext.request.contextPath}${v.videoPath}" type="video/mp4">
                                                    </video>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted" style="font-size:1.5rem;">🎬</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <a href="${pageContext.request.contextPath}/video/detail?id=${v.id}" class="text-dark fw-semibold">
                                                <c:out value="${v.title}"/>
                                            </a>
                                        </td>
                                        <td style="max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">
                                            <c:out value="${v.description}"/>
                                        </td>
                                        <td>${v.createdAtFormatted}</td>
                                        <td class="text-center">
                                            <a href="${pageContext.request.contextPath}/video/edit?id=${v.id}"
                                               class="btn btn-sm btn-outline-primary me-1" title="Sửa">
                                                <i class="bi bi-pencil"></i>
                                            </a>
                                            <a href="${pageContext.request.contextPath}/video/delete?id=${v.id}"
                                               class="btn btn-sm btn-outline-danger"
                                               title="Xóa"
                                               onclick="return confirm('Bạn có chắc muốn xóa video \'${v.title}\'?');">
                                                <i class="bi bi-trash"></i>
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>

                    <%-- Pagination --%>
                    <div class="d-flex justify-content-center py-3">
                        <nav>
                            <ul class="pagination pagination-sm mb-0">
                                <li class="page-item ${currentPage <= 1 ? 'disabled' : ''}">
                                    <a class="page-link" href="${pageContext.request.contextPath}/video?page=${currentPage - 1}">«</a>
                                </li>
                                <c:forEach begin="1" end="${totalPages}" var="p">
                                    <li class="page-item ${p == currentPage ? 'active' : ''}">
                                        <a class="page-link" href="${pageContext.request.contextPath}/video?page=${p}">${p}</a>
                                    </li>
                                </c:forEach>
                                <li class="page-item ${currentPage >= totalPages ? 'disabled' : ''}">
                                    <a class="page-link" href="${pageContext.request.contextPath}/video?page=${currentPage + 1}">»</a>
                                </li>
                            </ul>
                        </nav>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</body>
</html>
