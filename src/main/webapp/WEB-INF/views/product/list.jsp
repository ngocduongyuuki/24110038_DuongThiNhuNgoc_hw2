<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Quản lý sản phẩm</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>

    <header class="top-header">
        <a href="${pageContext.request.contextPath}/home" class="brand-title">Dashboard</a>
        <div class="user-actions">
            <span class="user-name">Xin chào <strong>${sessionScope.account.fullName != null ? sessionScope.account.fullName : 'Nguyễn Hữu Trung'}</strong></span>
            <a href="${pageContext.request.contextPath}/logout" class="btn-logout">Đăng xuất</a>
        </div>
    </header>

    <div class="app-layout">
        <aside class="sidebar">
            <div class="sidebar-profile">
                <img class="sidebar-avatar" src="${pageContext.request.contextPath}/assets/images/avatar.svg" alt="Admin">
                <div class="sidebar-role">Bạn là Admin</div>
            </div>

            <ul class="sidebar-menu">
                <li>
                    <a href="${pageContext.request.contextPath}/home" class="menu-link">Trang chủ</a>
                </li>
                <li>
                    <a href="${pageContext.request.contextPath}/video" class="menu-link">Quản lý Video</a>
                    <ul class="tree-subnav">
                        <li><a href="${pageContext.request.contextPath}/video/add">Thêm video mới</a></li>
                        <li><a href="${pageContext.request.contextPath}/video">Danh sách video</a></li>
                    </ul>
                </li>
                <li>
                    <a href="${pageContext.request.contextPath}/product/list" class="menu-link dashboard-tab">Dashboard</a>
                </li>
                <li>
                    <a href="${pageContext.request.contextPath}/product/list" class="menu-link active-black">Quản lý Danh mục</a>
                    <ul class="tree-subnav">
                        <li><a href="${pageContext.request.contextPath}/product/add">Thêm danh mục mới</a></li>
                        <li><a href="${pageContext.request.contextPath}/product/list" class="sub-active">Danh sách danh mục</a></li>
                    </ul>
                </li>
                <li>
                    <a href="${pageContext.request.contextPath}/product/list" class="menu-link">Quản lý sản phẩm</a>
                </li>
                <li>
                    <a href="#" class="menu-link">Quản lý tài khoản</a>
                </li>
            </ul>
        </aside>

        <main class="content-area">
            <h1 class="page-header-title">Quản lý sản phẩm</h1>
            <p class="page-header-subtitle">Nơi bạn có thể quản lý sản phẩm của mình</p>

            <c:if test="${not empty param.added}">
                <div class="alert alert-success">Thêm sản phẩm thành công!</div>
            </c:if>
            <c:if test="${not empty param.updated}">
                <div class="alert alert-success">Cập nhật sản phẩm thành công!</div>
            </c:if>
            <c:if test="${not empty param.deleted}">
                <div class="alert alert-success">Xóa sản phẩm thành công!</div>
            </c:if>

            <div class="panel-box">
                <div class="panel-box-header">Danh sách sản phẩm</div>
                <div class="panel-box-body">
                    <div class="table-filter-bar">
                        <div>
                            <label>
                                <select id="recordsPerPage" onchange="changePageSize()">
                                    <option value="10">10</option>
                                    <option value="25">25</option>
                                    <option value="50">50</option>
                                </select> records per page
                            </label>
                        </div>
                        <div>
                            <label>Search:<input type="search" id="searchInput" onkeyup="filterTable()"></label>
                        </div>
                    </div>

                    <table class="slide-table" id="productTable">
                        <thead>
                            <tr>
                                <th style="width: 50px;" class="center">STT</th>
                                <th style="width: 140px;" class="center">Hình ảnh</th>
                                <th>Tên sản phẩm</th>
                                <th>Mô tả</th>
                                <th style="width: 120px;">Giá (VNĐ)</th>
                                <th style="width: 80px;" class="center">Số lượng</th>
                                <th style="width: 110px;">Hành động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty products}">
                                    <tr>
                                        <td colspan="7" class="center" style="color: var(--color-text-muted); padding: 20px;">Chưa có sản phẩm nào.</td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="p" items="${products}" varStatus="st">
                                        <tr>
                                            <td class="center">${st.index + 1}</td>
                                            <td class="center">
                                                <c:choose>
                                                    <c:when test="${not empty p.image}">
                                                        <img class="table-thumb-img" src="${p.image}" alt="${p.productName}"
                                                             onerror="this.style.display='none';">
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span style="color: var(--color-text-muted); font-style: italic; font-size: 11px;">Không có ảnh</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>${p.productName}</td>
                                            <td>${p.description}</td>
                                            <td><fmt:formatNumber value="${p.price}" pattern="#,##0" /></td>
                                            <td class="center">${p.quantity}</td>
                                            <td class="action-links">
                                                <a href="<c:url value='/product/edit?id=${p.productId}'/>">Sửa</a>
                                                | <a href="<c:url value='/product/delete?id=${p.productId}'/>"
                                                     onclick="return confirm('Bạn có chắc muốn xóa sản phẩm \'${p.productName}\'?');">Xóa</a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>

    <script>
    function filterTable() {
        var input = document.getElementById("searchInput");
        var filter = input.value.toLowerCase().trim();
        var table = document.getElementById("productTable");
        var tbody = table.getElementsByTagName("tbody")[0];
        var tr = tbody.getElementsByTagName("tr");

        for (var i = 0; i < tr.length; i++) {
            if (tr[i].cells.length <= 1) continue;
            var text = tr[i].textContent || tr[i].innerText;
            if (text.toLowerCase().indexOf(filter) > -1) {
                tr[i].style.display = "";
            } else {
                tr[i].style.display = "none";
            }
        }
    }

    function changePageSize() {
        var size = parseInt(document.getElementById("recordsPerPage").value, 10);
        var table = document.getElementById("productTable");
        var tbody = table.getElementsByTagName("tbody")[0];
        var tr = tbody.getElementsByTagName("tr");

        for (var i = 0; i < tr.length; i++) {
            if (tr[i].cells.length <= 1) continue;
            if (i < size) {
                tr[i].style.display = "";
            } else {
                tr[i].style.display = "none";
            }
        }
    }
    </script>
</body>
</html>
