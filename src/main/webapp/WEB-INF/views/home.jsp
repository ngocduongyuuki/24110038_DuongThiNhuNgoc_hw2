<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trang chủ - 10 Video mới nhất</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <style>
        .video-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 20px;
            margin-top: 16px;
        }
        .video-card {
            background: #ffffff;
            border: 1px solid var(--color-border);
            border-radius: 6px;
            overflow: hidden;
            box-shadow: 0 1px 4px rgba(0,48,73,.07);
            transition: box-shadow .2s ease-in-out;
        }
        .video-card:hover { box-shadow: 0 4px 14px rgba(120,0,0,.12); }
        .video-card-thumb {
            background: var(--color-sidebar-dark);
            height: 160px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--color-decor);
            font-size: 36px;
            overflow: hidden;
        }
        .video-card-thumb video {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .video-card-body { padding: 12px 14px 14px; }
        .video-card-title {
            font-size: 14px;
            font-weight: bold;
            margin-bottom: 6px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .video-card-title a { color: var(--color-sidebar); }
        .video-card-title a:hover { color: var(--color-primary); text-decoration: underline; }
        .video-card-desc {
            font-size: 12px;
            color: var(--color-text-muted);
            margin-bottom: 8px;
            overflow: hidden;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
        }
        .video-card-meta { font-size: 11px; color: var(--color-decor); font-weight: 500; }
        .video-card-meta span { margin-right: 10px; }
        .empty-state {
            text-align: center;
            padding: 50px 20px;
            color: var(--color-text-muted);
            background: var(--color-cream-light);
            border: 1px solid var(--color-border);
            border-radius: 6px;
        }
        .empty-icon { font-size: 48px; margin-bottom: 10px; }
        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 4px;
        }
        .btn-add {
            background: var(--color-primary);
            color: #ffffff;
            padding: 7px 16px;
            border-radius: 4px;
            font-size: 13px;
            font-weight: 500;
            text-decoration: none;
            display: inline-block;
            margin-top: 4px;
            border: 1px solid var(--color-primary-dark);
            transition: background 0.15s;
        }
        .btn-add:hover { background: var(--color-primary-dark); color: #ffffff; text-decoration: none; }
        .btn-add:focus { outline: none; box-shadow: 0 0 0 3px rgba(193, 18, 31, 0.35); }
        .btn-add:active { background: var(--color-header); transform: translateY(1px); }
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
                <li>
                    <a href="${pageContext.request.contextPath}/home" class="menu-link active-black">Trang chủ</a>
                </li>
                <li>
                    <a href="${pageContext.request.contextPath}/video" class="menu-link">Quản lý Video</a>
                    <ul class="tree-subnav">
                        <li><a href="${pageContext.request.contextPath}/video/add">Thêm video mới</a></li>
                        <li><a href="${pageContext.request.contextPath}/video">Danh sách video của tôi</a></li>
                    </ul>
                </li>
                <li>
                    <a href="${pageContext.request.contextPath}/product/list" class="menu-link">Quản lý sản phẩm</a>
                </li>
            </ul>
        </aside>

        <main class="content-area">
            <div class="section-header">
                <div>
                    <h1 class="page-header-title">Trang chủ</h1>
                    <p class="page-header-subtitle">10 video mới nhất từ tất cả người dùng</p>
                </div>
                <a href="${pageContext.request.contextPath}/video/add" class="btn-add">+ Thêm video</a>
            </div>

            <c:choose>
                <c:when test="${empty latestVideos}">
                    <div class="empty-state">
                        <div class="empty-icon">🎬</div>
                        <p style="font-size:16px;font-weight:bold;margin-bottom:8px;color:var(--color-accent);">Chưa có video nào</p>
                        <p style="color:var(--color-text-muted);margin-bottom:16px;">Hãy là người đầu tiên đăng tải video!</p>
                        <a href="${pageContext.request.contextPath}/video/add" class="btn-add">Thêm video ngay</a>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="video-grid">
                        <c:forEach var="v" items="${latestVideos}">
                            <div class="video-card">
                                <div class="video-card-thumb">
                                    <c:choose>
                                        <c:when test="${not empty v.videoPath}">
                                            <video preload="metadata" muted>
                                                <source src="${pageContext.request.contextPath}${v.videoPath}" type="video/mp4">
                                            </video>
                                        </c:when>
                                        <c:otherwise>🎬</c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="video-card-body">
                                    <div class="video-card-title">
                                        <a href="${pageContext.request.contextPath}/video/detail?id=${v.id}">
                                            <c:out value="${v.title}"/>
                                        </a>
                                    </div>
                                    <div class="video-card-desc">
                                        <c:choose>
                                            <c:when test="${not empty v.description}"><c:out value="${v.description}"/></c:when>
                                            <c:otherwise><em style="color:var(--color-text-muted);">Không có mô tả</em></c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div class="video-card-meta">
                                        <span>👤 <c:out value="${v.account.fullName}"/></span>
                                        <span>📅 ${v.createdAtFormatted}</span>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </main>
    </div>
</body>
</html>
