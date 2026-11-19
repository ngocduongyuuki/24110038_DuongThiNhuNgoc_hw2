package com.hcmute.controller;

import com.hcmute.model.Product;
import com.hcmute.service.ProductService;
import com.hcmute.service.impl.ProductServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

@WebServlet("/product/*")
public class ProductServlet extends HttpServlet {

    private final ProductService productService = new ProductServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        if (pathInfo == null) pathInfo = "/list";

        switch (pathInfo) {
            case "/list" -> showList(request, response);
            case "/add" -> showAddForm(request, response);
            case "/edit" -> showEditForm(request, response);
            case "/delete" -> deleteProduct(request, response);
            default -> response.sendRedirect(request.getContextPath() + "/product/list");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String pathInfo = request.getPathInfo();

        if ("/add".equals(pathInfo)) {
            handleAdd(request, response);
        } else if ("/edit".equals(pathInfo)) {
            handleEdit(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/product/list");
        }
    }

    private void showList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Product> products = productService.getAllProducts();
        request.setAttribute("products", products);
        request.getRequestDispatcher("/WEB-INF/views/product/list.jsp").forward(request, response);
    }

    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/product/add.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            Product product = productService.getProductById(id);
            if (product == null) {
                response.sendRedirect(request.getContextPath() + "/product/list");
                return;
            }
            request.setAttribute("product", product);
            request.getRequestDispatcher("/WEB-INF/views/product/edit.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/product/list");
        }
    }

    private void deleteProduct(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            productService.deleteProduct(id);
        } catch (NumberFormatException ignored) {
        }
        response.sendRedirect(request.getContextPath() + "/product/list?deleted=1");
    }

    private void handleAdd(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String error = validateInputs(request);
        Product product = buildProductFromRequest(request);

        if (error != null) {
            request.setAttribute("error", error);
            request.setAttribute("product", product);
            request.getRequestDispatcher("/WEB-INF/views/product/add.jsp").forward(request, response);
            return;
        }

        boolean success = productService.addProduct(product);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/product/list?added=1");
        } else {
            request.setAttribute("error", "Thêm sản phẩm thất bại, vui lòng thử lại.");
            request.setAttribute("product", product);
            request.getRequestDispatcher("/WEB-INF/views/product/add.jsp").forward(request, response);
        }
    }

    private void handleEdit(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String error = validateInputs(request);
        Product product = buildProductFromRequest(request);
        try {
            product.setProductId(Integer.parseInt(request.getParameter("productId")));
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/product/list");
            return;
        }

        if (error != null) {
            request.setAttribute("error", error);
            request.setAttribute("product", product);
            request.getRequestDispatcher("/WEB-INF/views/product/edit.jsp").forward(request, response);
            return;
        }

        boolean success = productService.updateProduct(product);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/product/list?updated=1");
        } else {
            request.setAttribute("error", "Cập nhật sản phẩm thất bại, vui lòng thử lại.");
            request.setAttribute("product", product);
            request.getRequestDispatcher("/WEB-INF/views/product/edit.jsp").forward(request, response);
        }
    }

    private Product buildProductFromRequest(HttpServletRequest request) {
        Product product = new Product();
        String name = request.getParameter("productName");
        product.setProductName(name != null ? name.trim() : null);
        product.setDescription(request.getParameter("description"));
        product.setImage(request.getParameter("image"));

        String priceStr = request.getParameter("price");
        String quantityStr = request.getParameter("quantity");

        if (priceStr != null && !priceStr.isBlank()) {
            try {
                product.setPrice(new BigDecimal(priceStr.trim()));
            } catch (Exception ignored) {}
        }
        if (quantityStr != null && !quantityStr.isBlank()) {
            try {
                product.setQuantity(Integer.parseInt(quantityStr.trim()));
            } catch (Exception ignored) {}
        }

        return product;
    }

    private String validateInputs(HttpServletRequest request) {
        String name = request.getParameter("productName");
        if (name == null || name.isBlank()) {
            return "Tên sản phẩm không được để trống.";
        }
        if (name.trim().length() > 200) {
            return "Tên sản phẩm không được vượt quá 200 ký tự.";
        }

        String priceStr = request.getParameter("price");
        if (priceStr == null || priceStr.isBlank()) {
            return "Giá sản phẩm không được để trống.";
        }
        try {
            BigDecimal price = new BigDecimal(priceStr.trim());
            if (price.compareTo(BigDecimal.ZERO) < 0) {
                return "Giá sản phẩm phải lớn hơn hoặc bằng 0.";
            }
        } catch (Exception e) {
            return "Giá sản phẩm phải là một số hợp lệ.";
        }

        String quantityStr = request.getParameter("quantity");
        if (quantityStr == null || quantityStr.isBlank()) {
            return "Số lượng sản phẩm không được để trống.";
        }
        try {
            int qty = Integer.parseInt(quantityStr.trim());
            if (qty < 0) {
                return "Số lượng sản phẩm phải lớn hơn hoặc bằng 0.";
            }
        } catch (Exception e) {
            return "Số lượng sản phẩm phải là một số nguyên hợp lệ.";
        }

        String image = request.getParameter("image");
        if (image != null && image.trim().length() > 500) {
            return "Đường dẫn ảnh không được vượt quá 500 ký tự.";
        }

        return null;
    }
}
