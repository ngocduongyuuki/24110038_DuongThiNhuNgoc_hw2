<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Thêm sản phẩm mới - ProductManager</title>
</head>
<body>
    <div class="d-flex align-items-center mb-3">
        <a href="${pageContext.request.contextPath}/product/list" class="btn btn-sm btn-outline-secondary me-2">
            <i class="bi bi-arrow-left"></i>
        </a>
        <div>
            <h1 class="h4 mb-0"><i class="bi bi-plus-circle me-2 text-danger"></i>Thêm sản phẩm mới</h1>
        </div>
    </div>

    <div class="card shadow-sm" style="max-width:700px;">
        <div class="card-header bg-white">
            <strong><i class="bi bi-box me-2"></i>Thông tin sản phẩm</strong>
        </div>
        <div class="card-body">
            <c:if test="${not empty error}">
                <div class="alert alert-danger" role="alert">
                    <i class="bi bi-exclamation-triangle me-2"></i><c:out value="${error}"/>
                </div>
            </c:if>

            <form method="post" action="${pageContext.request.contextPath}/product/add" novalidate id="addProductForm">
                <div class="mb-3">
                    <label for="productName" class="form-label fw-semibold">
                        Tên sản phẩm <span class="text-danger">*</span>
                    </label>
                    <input type="text" class="form-control" id="productName" name="productName"
                           placeholder="Nhập tên sản phẩm"
                           value="<c:out value='${product.productName}'/>"
                           required maxlength="200">
                    <div class="invalid-feedback">Tên sản phẩm không được để trống.</div>
                </div>

                <div class="mb-3">
                    <label for="description" class="form-label fw-semibold">Mô tả</label>
                    <textarea class="form-control" id="description" name="description"
                              rows="3" placeholder="Mô tả sản phẩm (tùy chọn)"><c:out value="${product.description}"/></textarea>
                </div>

                <div class="row g-3 mb-3">
                    <div class="col-md-6">
                        <label for="price" class="form-label fw-semibold">
                            Giá (VNĐ) <span class="text-danger">*</span>
                        </label>
                        <div class="input-group">
                            <input type="number" class="form-control" id="price" name="price"
                                   value="${product.price}" min="0" step="1000"
                                   placeholder="0" required>
                            <span class="input-group-text">đ</span>
                            <div class="invalid-feedback">Giá sản phẩm phải >= 0.</div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <label for="quantity" class="form-label fw-semibold">
                            Số lượng <span class="text-danger">*</span>
                        </label>
                        <input type="number" class="form-control" id="quantity" name="quantity"
                               value="${product.quantity}" min="0" placeholder="0" required>
                        <div class="invalid-feedback">Số lượng phải >= 0.</div>
                    </div>
                </div>

                <div class="mb-4">
                    <label for="image" class="form-label fw-semibold">Ảnh đại diện</label>
                    <input type="text" class="form-control" id="image" name="image"
                           value="<c:out value='${product.image}'/>"
                           placeholder="https://... (URL hình ảnh, tùy chọn)"
                           maxlength="500">
                    <div class="form-text text-muted" style="font-size:11px;">Dán URL hình ảnh của sản phẩm</div>
                </div>

                <div class="d-flex gap-2">
                    <button type="submit" class="btn btn-danger">
                        <i class="bi bi-plus-circle me-1"></i>Thêm sản phẩm
                    </button>
                    <button type="reset" class="btn btn-outline-secondary">
                        <i class="bi bi-arrow-counterclockwise me-1"></i>Làm mới
                    </button>
                    <a href="${pageContext.request.contextPath}/product/list" class="btn btn-outline-dark">
                        <i class="bi bi-x-lg me-1"></i>Hủy
                    </a>
                </div>
            </form>
        </div>
    </div>

<script>
(function() {
    'use strict';
    var form = document.getElementById('addProductForm');
    if (!form) return;
    form.addEventListener('submit', function(e) {
        var valid = true;
        form.querySelectorAll('.is-invalid').forEach(function(el){ el.classList.remove('is-invalid'); });

        var name = document.getElementById('productName').value.trim();
        if (!name || name.length > 200) {
            document.getElementById('productName').classList.add('is-invalid');
            valid = false;
        }

        var priceVal = document.getElementById('price').value;
        var price = parseFloat(priceVal);
        if (priceVal === '' || isNaN(price) || price < 0) {
            document.getElementById('price').classList.add('is-invalid');
            valid = false;
        }

        var qtyVal = document.getElementById('quantity').value;
        var qty = parseInt(qtyVal, 10);
        if (qtyVal === '' || isNaN(qty) || qty < 0) {
            document.getElementById('quantity').classList.add('is-invalid');
            valid = false;
        }

        if (!valid) { e.preventDefault(); e.stopPropagation(); }
    });
})();
</script>
</body>
</html>
