<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết video - <c:out value="${video.title}"/></title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <style>
        .detail-container { max-width: 860px; }
        .video-player-wrap {
            background: var(--color-sidebar-dark);
            border-radius: 6px;
            overflow: hidden;
            margin-bottom: 20px;
        }
        .video-player-wrap video { width: 100%; max-height: 480px; display: block; }
        .detail-meta { margin-bottom: 16px; }
        .detail-meta table td { padding: 6px 12px 6px 0; vertical-align: top; font-size: 13px; }
        .detail-meta table td:first-child { font-weight: bold; white-space: nowrap; color: var(--color-sidebar); min-width: 120px; }
        .detail-desc {
            background: #FFFDF8;
            border: 1px solid var(--color-border);
            border-radius: 4px;
            padding: 14px 16px;
            font-size: 13px;
            color: var(--color-text);
            white-space: pre-wrap;
            margin-bottom: 20px;
        }
        .btn-back {
            background: #ffffff; color: var(--color-sidebar); padding: 8px 16px; border-radius: 4px;
            font-size: 13px; text-decoration: none; display: inline-block;
            border: 1px solid var(--color-decor); font-weight: 500;
            transition: all 0.15s;
        }
        .btn-back:hover { background: #EAF2F6; text-decoration: none; color: var(--color-sidebar); }
        .btn-back:focus { outline: none; box-shadow: 0 0 0 3px rgba(102, 155, 188, 0.35); }
        .btn-back:active { background: #D8E6EE; transform: translateY(1px); }
        .btn-action {
            background: var(--color-sidebar); color: #ffffff; padding: 8px 16px; border-radius: 4px;
            font-size: 13px; text-decoration: none; display: inline-block; margin-left: 8px;
            border: 1px solid var(--color-sidebar-dark); font-weight: 500;
            transition: background 0.15s;
        }
        .btn-action:hover { background: var(--color-sidebar-dark); color: #ffffff; text-decoration: none; }
        .btn-action:focus { outline: none; box-shadow: 0 0 0 3px rgba(102, 155, 188, 0.35); }
        .btn-action:active { background: var(--color-sidebar-dark); transform: translateY(1px); }
        .btn-danger {
            background: var(--color-primary); color: #ffffff; padding: 8px 16px; border-radius: 4px;
            font-size: 13px; text-decoration: none; display: inline-block; margin-left: 8px;
            border: 1px solid var(--color-primary-dark); font-weight: 500;
            transition: background 0.15s;
        }
        .btn-danger:hover { background: var(--color-primary-dark); color: #ffffff; text-decoration: none; }
        .btn-danger:focus { outline: none; box-shadow: 0 0 0 3px rgba(193, 18, 31, 0.35); }
        .btn-danger:active { background: var(--color-header); transform: translateY(1px); }
        .file-missing {
            background: var(--color-cream);
            border: 1px solid var(--color-border);
            border-radius: 4px;
            padding: 12px 16px;
            color: var(--color-accent);
            margin-bottom: 16px;
            font-weight: 500;
        }
        .error-box {
            background: #FFFDF8;
            border: 1px solid var(--color-border);
            border-radius: 4px;
            padding: 16px;
            color: var(--color-accent);
        }
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
                        <li><a href="${pageContext.request.contextPath}/video">Danh sách video của tôi</a></li>
                    </ul>
                </li>
                <li><a href="${pageContext.request.contextPath}/product/list" class="menu-link">Quản lý sản phẩm</a></li>
            </ul>
        </aside>

        <main class="content-area">
            <c:choose>
                <c:when test="${not empty errorMsg}">
                    <div class="error-box">
                        <strong>⚠ ${errorMsg}</strong>
                        <p style="margin-top:10px;">
                            <a href="${pageContext.request.contextPath}/home" class="btn-back">← Về trang chủ</a>
                            <a href="${pageContext.request.contextPath}/video" class="btn-back" style="margin-left:8px;">Danh sách video</a>
                        </p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="detail-container">
                        <h1 class="page-header-title"><c:out value="${video.title}"/></h1>

                        <%-- Video player --%>
                        <c:choose>
                            <c:when test="${fileExists}">
                                <div class="video-player-wrap">
                                    <video controls autoplay>
                                        <source src="${pageContext.request.contextPath}${video.videoPath}" type="video/mp4">
                                        <source src="${pageContext.request.contextPath}${video.videoPath}" type="video/webm">
                                        Trình duyệt của bạn không hỗ trợ phát video HTML5.
                                    </video>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="file-missing">
                                    ⚠ File video không còn tồn tại trên server hoặc đã bị xóa.
                                </div>
                            </c:otherwise>
                        </c:choose>

                        <%-- Metadata --%>
                        <div class="detail-meta">
                            <table>
                                <tr>
                                    <td>👤 Người đăng:</td>
                                    <td><strong><c:out value="${video.account.fullName}"/></strong>
                                        (${video.account.username})</td>
                                </tr>
                                <tr>
                                    <td>📅 Ngày đăng:</td>
                                    <td>${video.createdAtFormatted}</td>
                                </tr>
                                <tr>
                                    <td>🔄 Cập nhật:</td>
                                    <td>${video.updatedAtFormatted}</td>
                                </tr>
                            </table>
                        </div>

                        <%-- Description --%>
                        <c:if test="${not empty video.description}">
                            <h3 style="margin-bottom:8px;font-size:14px;color:var(--color-sidebar);">Mô tả</h3>
                            <div class="detail-desc"><c:out value="${video.description}"/></div>
                        </c:if>

                        <%-- Action buttons --%>
                        <div>
                            <a href="${pageContext.request.contextPath}/home" class="btn-back">← Trang chủ</a>
                            <a href="${pageContext.request.contextPath}/video" class="btn-back" style="margin-left:8px;">Danh sách video</a>
                            <c:if test="${isOwner}">
                                <a href="${pageContext.request.contextPath}/video/edit?id=${video.id}"
                                   class="btn-action">✏ Chỉnh sửa</a>
                                <a href="${pageContext.request.contextPath}/video/delete?id=${video.id}"
                                   class="btn-danger"
                                   onclick="return confirm('Bạn có chắc muốn xóa video này?');">🗑 Xóa</a>
                            </c:if>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </main>
    </div>
</body>
</html>
