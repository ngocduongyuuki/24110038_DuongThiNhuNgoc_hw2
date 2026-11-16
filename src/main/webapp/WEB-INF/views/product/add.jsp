<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thêm sản phẩm mới</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>

    <header class="top-header">
        <a href="${pageContext.request.contextPath}/product/list" class="brand-title">Dashboard</a>
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
                    <a href="${pageContext.request.contextPath}/product/list" class="menu-link dashboard-tab">Dashboard</a>
                </li>
                <li>
                    <a href="${pageContext.request.contextPath}/product/list" class="menu-link active-black">Quản lý Danh mục</a>
                    <ul class="tree-subnav">
                        <li><a href="${pageContext.request.contextPath}/product/add" class="sub-active">Thêm danh mục mới</a></li>
                        <li><a href="${pageContext.request.contextPath}/product/list">Danh sách danh mục</a></li>
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
            <c:if test="${not empty error}">
                <div class="alert alert-danger">${error}</div>
            </c:if>

            <div class="panel-box">
                <div class="panel-box-header">Thêm sản phẩm mới</div>
                <div class="panel-box-body">
                    <h2 class="form-heading">Sản phẩm:</h2>

                    <form role="form" action="${pageContext.request.contextPath}/product/add" method="post">
                        <div class="form-group">
                            <label>Tên sản phẩm:</label>
                            <input type="text" class="form-control" name="productName"
                                   placeholder="please enter product Name" value="${product.productName}" required />
                        </div>

                        <div class="form-group">
                            <label>Mô tả:</label>
                            <textarea class="form-control" name="description" rows="3"
                                      placeholder="Mô tả sản phẩm">${product.description}</textarea>
                        </div>

                        <div style="display: flex; gap: 15px; max-width: 650px;">
                            <div class="form-group" style="flex: 1;">
                                <label>Giá (VNĐ):</label>
                                <input type="number" class="form-control" name="price"
                                       value="${product.price}" min="0" step="1000" required />
                            </div>
                            <div class="form-group" style="flex: 1;">
                                <label>Số lượng:</label>
                                <input type="number" class="form-control" name="quantity"
                                       value="${product.quantity}" min="0" required />
                            </div>
                        </div>

                        <div class="form-group">
                            <label>Ảnh đại diện</label>
                            <input type="text" class="form-control" name="image"
                                   value="${product.image}" placeholder="https://... hoặc tên file ảnh" />
                        </div>

                        <div class="form-actions-bar">
                            <button type="submit" class="btn btn-default">Thêm</button>
                            <button type="reset" class="btn btn-primary">Hủy</button>
                            <a href="${pageContext.request.contextPath}/product/list" class="btn btn-default">Quay lại</a>
                        </div>
                    </form>
                </div>
            </div>
        </main>
    </div>

</body>
</html>
