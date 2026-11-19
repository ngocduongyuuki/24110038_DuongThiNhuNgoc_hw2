<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Danh sách sản phẩm - ProductManager</title>
</head>
<body>
    <div class="d-flex justify-content-between align-items-center mb-3">
        <div>
            <h1 class="h4 mb-1"><i class="bi bi-box me-2 text-danger"></i>Quản lý sản phẩm</h1>
            <p class="text-muted mb-0" style="font-size:13px;">Danh sách tất cả sản phẩm trong hệ thống</p>
        </div>
        <a href="${pageContext.request.contextPath}/product/add" class="btn btn-danger">
            <i class="bi bi-plus-circle me-1"></i>Thêm sản phẩm
        </a>
    </div>

    <c:if test="${not empty param.added}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="bi bi-check-circle me-2"></i>Thêm sản phẩm thành công!
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>
    <c:if test="${not empty param.updated}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="bi bi-check-circle me-2"></i>Cập nhật sản phẩm thành công!
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>
    <c:if test="${not empty param.deleted}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="bi bi-check-circle me-2"></i>Xóa sản phẩm thành công!
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <div class="card shadow-sm">
        <div class="card-header bg-white py-2 d-flex justify-content-between align-items-center">
            <strong><i class="bi bi-table me-2"></i>Danh sách sản phẩm</strong>
            <div class="d-flex gap-2 align-items-center">
                <div class="input-group input-group-sm" style="width:220px;">
                    <span class="input-group-text"><i class="bi bi-search"></i></span>
                    <input type="search" class="form-control" id="searchInput" placeholder="Tìm kiếm..." oninput="filterTable()">
                </div>
            </div>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover table-bordered mb-0 align-middle" id="productTable">
                    <thead class="table-light">
                        <tr>
                            <th class="text-center" style="width:50px;">STT</th>
                            <th class="text-center" style="width:120px;">Hình ảnh</th>
                            <th>Tên sản phẩm</th>
                            <th>Mô tả</th>
                            <th style="width:130px;">Giá (VNĐ)</th>
                            <th class="text-center" style="width:90px;">Số lượng</th>
                            <th class="text-center" style="width:120px;">Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty products}">
                                <tr>
                                    <td colspan="7" class="text-center text-muted py-4">
                                        <i class="bi bi-inbox me-2"></i>Chưa có sản phẩm nào.
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="p" items="${products}" varStatus="st">
                                    <tr>
                                        <td class="text-center">${st.index + 1}</td>
                                        <td class="text-center">
                                            <c:choose>
                                                <c:when test="${not empty p.image}">
                                                    <img src="${p.image}" alt="${p.productName}"
                                                         style="max-width:80px;max-height:60px;object-fit:contain;border-radius:4px;"
                                                         onerror="this.style.display='none';">
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted" style="font-size:11px;font-style:italic;">Không có ảnh</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td><strong><c:out value="${p.productName}"/></strong></td>
                                        <td style="max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">
                                            <c:out value="${p.description}"/>
                                        </td>
                                        <td><fmt:formatNumber value="${p.price}" pattern="#,##0"/> đ</td>
                                        <td class="text-center">${p.quantity}</td>
                                        <td class="text-center">
                                            <a href="${pageContext.request.contextPath}/product/edit?id=${p.productId}"
                                               class="btn btn-sm btn-outline-primary me-1" title="Sửa">
                                                <i class="bi bi-pencil"></i>
                                            </a>
                                            <a href="${pageContext.request.contextPath}/product/delete?id=${p.productId}"
                                               class="btn btn-sm btn-outline-danger"
                                               title="Xóa"
                                               onclick="return confirm('Bạn có chắc muốn xóa sản phẩm \'${p.productName}\'?');">
                                                <i class="bi bi-trash"></i>
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

<script>
function filterTable() {
    var filter = document.getElementById("searchInput").value.toLowerCase().trim();
    var rows = document.querySelectorAll("#productTable tbody tr");
    rows.forEach(function(row) {
        if (row.cells.length <= 1) return;
        row.style.display = row.textContent.toLowerCase().indexOf(filter) > -1 ? "" : "none";
    });
}
</script>
</body>
</html>
