<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><sitemesh:write property="title"/></title>
    <!-- Bootstrap 5 -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <!-- Custom CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <sitemesh:write property="head"/>
    <style>
        :root {
            --bs-sidebar-bg: #003049;
            --bs-header-bg: #780000;
            --bs-primary-custom: #C1121F;
        }
        body { background-color: #FAF5EB; }
        .top-navbar {
            background-color: var(--bs-header-bg);
            height: 56px;
            padding: 0 20px;
        }
        .top-navbar .navbar-brand {
            color: #fff !important;
            font-size: 1.3rem;
            font-weight: bold;
            letter-spacing: 0.5px;
        }
        .top-navbar .nav-link {
            color: rgba(255,255,255,0.85) !important;
            font-size: 13px;
        }
        .top-navbar .nav-link:hover { color: #fff !important; }
        .top-navbar .user-name { color: rgba(255,255,255,0.9); font-size: 13px; }
        .top-navbar .btn-logout {
            background: rgba(255,255,255,0.15);
            color: #fff;
            border: 1px solid rgba(255,255,255,0.3);
            padding: 4px 12px;
            font-size: 12px;
            border-radius: 4px;
            text-decoration: none;
            transition: background 0.15s;
        }
        .top-navbar .btn-logout:hover { background: rgba(255,255,255,0.3); color: #fff; }

        /* Sidebar */
        .app-sidebar {
            width: 220px;
            min-height: calc(100vh - 56px);
            background-color: var(--bs-sidebar-bg);
            flex-shrink: 0;
            padding: 0;
        }
        .sidebar-profile {
            padding: 20px 16px 16px;
            border-bottom: 1px solid rgba(255,255,255,0.1);
            text-align: center;
        }
        .sidebar-avatar {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid rgba(255,255,255,0.3);
            margin-bottom: 8px;
        }
        .sidebar-name {
            color: #fff;
            font-size: 13px;
            font-weight: 600;
            margin-bottom: 2px;
        }
        .sidebar-role { color: rgba(255,255,255,0.6); font-size: 11px; }

        .sidebar-menu {
            list-style: none;
            padding: 8px 0;
            margin: 0;
        }
        .sidebar-menu > li { }
        .sidebar-menu .menu-link {
            display: block;
            padding: 10px 20px;
            color: rgba(255,255,255,0.8);
            font-size: 13px;
            text-decoration: none;
            transition: background 0.15s, color 0.15s;
        }
        .sidebar-menu .menu-link:hover,
        .sidebar-menu .menu-link.active {
            background: rgba(255,255,255,0.1);
            color: #fff;
        }
        .sidebar-menu .menu-link i { margin-right: 8px; font-size: 14px; }
        .tree-subnav {
            list-style: none;
            padding: 0;
            margin: 0;
            background: rgba(0,0,0,0.15);
        }
        .tree-subnav li a {
            display: block;
            padding: 7px 20px 7px 38px;
            color: rgba(255,255,255,0.65);
            font-size: 12px;
            text-decoration: none;
            transition: color 0.15s;
        }
        .tree-subnav li a:hover { color: #fff; }

        /* Content area */
        .app-layout { display: flex; min-height: calc(100vh - 56px); }
        .content-area {
            flex: 1;
            padding: 24px 28px;
            min-width: 0;
        }

        /* Footer */
        .app-footer {
            background: var(--bs-sidebar-bg);
            color: rgba(255,255,255,0.6);
            text-align: center;
            padding: 12px 20px;
            font-size: 12px;
        }

        /* Responsive sidebar */
        @media (max-width: 768px) {
            .app-sidebar { display: none; }
            .content-area { padding: 16px; }
        }
    </style>
</head>
<body>

<!-- TOP NAVBAR -->
<nav class="navbar top-navbar">
    <div class="container-fluid px-0">
        <a href="${pageContext.request.contextPath}/home" class="navbar-brand">
            <i class="bi bi-box-seam me-2"></i>ProductManager
        </a>
        <div class="d-flex align-items-center gap-3">
            <span class="user-name">
                Xin chào, <strong>${sessionScope.account.fullName}</strong>
            </span>
            <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                <i class="bi bi-box-arrow-right"></i> Đăng xuất
            </a>
        </div>
    </div>
</nav>

<div class="app-layout">
    <!-- SIDEBAR -->
    <aside class="app-sidebar">
        <div class="sidebar-profile">
            <img class="sidebar-avatar"
                 src="${not empty sessionScope.account.profileImage ? sessionScope.account.profileImage : pageContext.request.contextPath.concat('/assets/images/avatar.svg')}"
                 alt="Avatar"
                 onerror="this.src='${pageContext.request.contextPath}/assets/images/avatar.svg'">
            <div class="sidebar-name">${sessionScope.account.fullName}</div>
            <div class="sidebar-role">Thành viên</div>
        </div>
        <ul class="sidebar-menu">
            <li>
                <a href="${pageContext.request.contextPath}/home" class="menu-link">
                    <i class="bi bi-house-door"></i> Trang chủ
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/video" class="menu-link">
                    <i class="bi bi-camera-video"></i> Quản lý Video
                </a>
                <ul class="tree-subnav">
                    <li><a href="${pageContext.request.contextPath}/video/add">Thêm video mới</a></li>
                    <li><a href="${pageContext.request.contextPath}/video">Danh sách video</a></li>
                </ul>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/product/list" class="menu-link">
                    <i class="bi bi-box"></i> Quản lý sản phẩm
                </a>
                <ul class="tree-subnav">
                    <li><a href="${pageContext.request.contextPath}/product/add">Thêm sản phẩm mới</a></li>
                    <li><a href="${pageContext.request.contextPath}/product/list">Danh sách sản phẩm</a></li>
                </ul>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/profile" class="menu-link">
                    <i class="bi bi-person-circle"></i> Hồ sơ cá nhân
                </a>
            </li>
        </ul>
    </aside>

    <!-- MAIN CONTENT -->
    <main class="content-area">
        <sitemesh:write property="body"/>
    </main>
</div>

<!-- FOOTER -->
<footer class="app-footer">
    &copy; 2026 ProductManager &mdash; 24110038 Dương Thị Như Ngọc
</footer>

<!-- Bootstrap 5 JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
