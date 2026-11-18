<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Danh sách video của tôi</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <style>
        .video-table th, .video-table td { padding: 10px 12px; vertical-align: middle; }
        .video-thumb-cell { width: 160px; }
        .video-thumb-cell video { width: 140px; height: 80px; object-fit: cover; border-radius: 4px; background: var(--color-sidebar-dark); }
        .pagination { display: flex; gap: 6px; align-items: center; margin-top: 16px; flex-wrap: wrap; }
        .pagination a, .pagination span {
            display: inline-block;
            padding: 5px 11px;
            border: 1px solid var(--color-decor);
            border-radius: 3px;
            font-size: 13px;
            color: var(--color-sidebar);
            text-decoration: none;
            background: #ffffff;
            transition: all 0.15s;
        }
        .pagination a:hover { background: #EAF2F6; color: var(--color-sidebar); }
        .pagination a:focus { outline: none; box-shadow: 0 0 0 2px rgba(102, 155, 188, 0.4); }
        .pagination a:active { background: #D8E6EE; }
        .pagination .active-page {
            background: var(--color-primary);
            color: #ffffff;
            border-color: var(--color-primary-dark);
            font-weight: bold;
        }
        .pagination .disabled { color: var(--color-decor); cursor: default; border-color: var(--color-border); background: var(--color-cream-light); }
        .btn-sm { padding: 4px 10px; font-size: 12px; border-radius: 3px; text-decoration: none; display: inline-block; font-weight: 500; transition: all 0.15s; }
        .btn-sm:active { transform: translateY(1px); }
        .btn-edit { background: var(--color-sidebar); color: #ffffff; }
        .btn-edit:hover { background: var(--color-sidebar-dark); color: #ffffff; text-decoration: none; }
        .btn-edit:active { background: var(--color-sidebar-dark); }
        .btn-delete { background: var(--color-primary); color: #ffffff; }
        .btn-delete:hover { background: var(--color-primary-dark); color: #ffffff; text-decoration: none; }
        .btn-delete:active { background: var(--color-header); }
    </style>
</head>
<body>
    <header class="top-header">
        <a href="${pageContext.request.contextPath}/home" class="brand-title">ProductManager</a>
        <div class="user-actions">
            <span class="user-name">Xin chào <strong>${sessionScope.account.fullName}</strong></span>
            <a href="${pageContext.request.contextPath}/logout" class="btn-logout">Đăng xuất</a>
        </div>
    </header>

    <div class="app-layout">
        <aside class="sidebar">
            <div class="sidebar-profile">
                <img class="sidebar-avatar" src="${pageContext.request.contextPath}/assets/images/avatar.svg" alt="Avatar">
                <div class="sidebar-role">Thành viên</div>
            </div>
            <ul class="sidebar-menu">
                <li><a href="${pageContext.request.contextPath}/home" class="menu-link">Trang chủ</a></li>
                <li>
                    <a href="${pageContext.request.contextPath}/video" class="menu-link active-black">Quản lý Video</a>
                    <ul class="tree-subnav">
                        <li><a href="${pageContext.request.contextPath}/video/add">Thêm video mới</a></li>
                        <li><a href="${pageContext.request.contextPath}/video" class="sub-active">Danh sách video của tôi</a></li>
                    </ul>
                </li>
                <li><a href="${pageContext.request.contextPath}/product/list" class="menu-link">Quản lý sản phẩm</a></li>
            </ul>
        </aside>

        <main class="content-area">
            <h1 class="page-header-title">Danh sách video của tôi</h1>
            <p class="page-header-subtitle">Tổng: ${totalVideos} video &nbsp;|&nbsp; Trang ${currentPage}/${totalPages}</p>

            <c:if test="${not empty param.added}">
                <div class="alert alert-success">Thêm video thành công!</div>
            </c:if>
            <c:if test="${not empty param.updated}">
                <div class="alert alert-success">Cập nhật video thành công!</div>
            </c:if>
            <c:if test="${not empty param.deleted}">
                <div class="alert alert-success">Xóa video thành công!</div>
            </c:if>
            <c:if test="${not empty param.deleteFailed}">
                <div class="alert alert-danger">Xóa video thất bại. Vui lòng thử lại.</div>
            </c:if>

            <div class="panel-box">
                <div class="panel-box-header" style="display: flex; justify-content: space-between; align-items: center;">
                    <span>Video của tôi</span>
                    <a href="${pageContext.request.contextPath}/video/add"
                       style="background: var(--color-primary); color: #ffffff; padding: 5px 12px; border-radius: 3px; font-size: 12px; font-weight: 500; text-decoration: none;">
                        + Thêm video mới
                    </a>
                </div>
                <div class="panel-box-body">
                    <c:choose>
                        <c:when test="${empty videos}">
                            <div style="text-align:center;padding:40px;color:var(--color-text-muted);">
                                <p style="font-size:14px;margin-bottom:12px;">Bạn chưa có video nào.</p>
                                <a href="${pageContext.request.contextPath}/video/add"
                                   style="display:inline-block;background:var(--color-primary);color:#ffffff;padding:8px 18px;border-radius:4px;text-decoration:none;font-weight:500;">
                                    Thêm video đầu tiên
                                </a>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <table class="slide-table video-table">
                                <thead>
                                    <tr>
                                        <th style="width:40px;" class="center">STT</th>
                                        <th class="video-thumb-cell center">Preview</th>
                                        <th>Tiêu đề</th>
                                        <th>Mô tả</th>
                                        <th style="width:130px;">Ngày đăng</th>
                                        <th style="width:120px;" class="center">Hành động</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="v" items="${videos}" varStatus="st">
                                        <tr>
                                            <td class="center">${(currentPage - 1) * 6 + st.index + 1}</td>
                                            <td class="center video-thumb-cell">
                                                <c:choose>
                                                    <c:when test="${not empty v.videoPath}">
                                                        <video preload="metadata" muted>
                                                            <source src="${pageContext.request.contextPath}${v.videoPath}" type="video/mp4">
                                                        </video>
                                                    </c:when>
                                                    <c:otherwise><span style="color:var(--color-decor);">🎬</span></c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <a href="${pageContext.request.contextPath}/video/detail?id=${v.id}">
                                                    <c:out value="${v.title}"/>
                                                </a>
                                            </td>
                                            <td style="max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">
                                                <c:out value="${v.description}"/>
                                            </td>
                                            <td>${v.createdAtFormatted}</td>
                                            <td class="center action-links">
                                                <a href="${pageContext.request.contextPath}/video/edit?id=${v.id}"
                                                   class="btn-sm btn-edit">Sửa</a>
                                                &nbsp;
                                                <a href="${pageContext.request.contextPath}/video/delete?id=${v.id}"
                                                   class="btn-sm btn-delete"
                                                   onclick="return confirm('Bạn có chắc muốn xóa video \'${v.title}\'? Thao tác này không thể hoàn tác.');">
                                                    Xóa
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>

                            <%-- Pagination --%>
                            <div class="pagination">
                                <c:choose>
                                    <c:when test="${currentPage > 1}">
                                        <a href="${pageContext.request.contextPath}/video?page=${currentPage - 1}">« Trước</a>
                                    </c:when>
                                    <c:otherwise><span class="disabled">« Trước</span></c:otherwise>
                                </c:choose>

                                <c:forEach begin="1" end="${totalPages}" var="p">
                                    <c:choose>
                                        <c:when test="${p == currentPage}">
                                            <span class="active-page">${p}</span>
                                        </c:when>
                                        <c:otherwise>
                                            <a href="${pageContext.request.contextPath}/video?page=${p}">${p}</a>
                                        </c:otherwise>
                                    </c:choose>
                                </c:forEach>

                                <c:choose>
                                    <c:when test="${currentPage < totalPages}">
                                        <a href="${pageContext.request.contextPath}/video?page=${currentPage + 1}">Sau »</a>
                                    </c:when>
                                    <c:otherwise><span class="disabled">Sau »</span></c:otherwise>
                                </c:choose>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </main>
    </div>
</body>
</html>
