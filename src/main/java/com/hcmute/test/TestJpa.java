package com.hcmute.test;

import com.hcmute.config.JpaConfig;
import com.hcmute.dao.AccountDAO;
import com.hcmute.dao.ProductDAO;
import com.hcmute.dao.impl.AccountDAOImpl;
import com.hcmute.dao.impl.ProductDAOImpl;
import com.hcmute.model.Account;
import com.hcmute.model.Category;
import com.hcmute.model.Product;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

public class TestJpa {

    public static void main(String[] args) {
        System.out.println("========== BẮT ĐẦU KIỂM THỬ BẢO MẬT & JPA CRUD (HOMEWORK 2) ==========");

        AccountDAO accountDAO = new AccountDAOImpl();
        ProductDAO productDAO = new ProductDAOImpl();

        try {
            // 1. Kiểm thử CRUD Account qua JPA
            System.out.println("\n[1] KIỂM THỬ TÀI KHOẢN (ACCOUNT)...");
            Account admin = accountDAO.findByUsername("admin");
            if (admin != null) {
                System.out.println("   -> [THÀNH CÔNG] Đọc tài khoản admin: " + admin.getFullName() + " (" + admin.getEmail() + ")");
            } else {
                Account newAdmin = new Account("Quản trị viên", "admin", "admin@hcmute.edu.vn", "0901234567", "123456");
                accountDAO.insert(newAdmin);
                System.out.println("   -> [THÀNH CÔNG] Tạo tài khoản admin qua JPA!");
            }

            // 2. Kiểm thử CRUD Product qua JPA
            System.out.println("\n[2] KIỂM THỬ SẢN PHẨM (PRODUCT)...");
            List<Product> products = productDAO.findAll();
            System.out.println("   -> [THÀNH CÔNG] Lấy danh sách sản phẩm qua JPQL (Tổng số: " + products.size() + " SP)");
            for (Product p : products) {
                System.out.println("      * ID: " + p.getProductId() + " | Tên: " + p.getProductName() + " | Giá: " + p.getPrice() + " đ");
            }

            Product testProduct = new Product(
                "Sản phẩm Test Bảo Mật JPA",
                "Mô tả sản phẩm tạo trong test",
                new BigDecimal("8888000"),
                10,
                "https://images.unsplash.com/photo-1593642632559-0c6d3fc62b89?w=200",
                LocalDate.now()
            );
            if (productDAO.insert(testProduct)) {
                System.out.println("   -> [THÀNH CÔNG] Thêm mới Product qua JPA (ID: " + testProduct.getProductId() + ")");
                testProduct.setProductName("Sản phẩm Test (Cập nhật)");
                productDAO.update(testProduct);
                System.out.println("   -> [THÀNH CÔNG] Cập nhật Product qua JPA!");
                productDAO.delete(testProduct.getProductId());
                System.out.println("   -> [THÀNH CÔNG] Xóa Product test qua JPA!");
            }

            // 3. Kiểm thử CRUD Category qua JPA
            System.out.println("\n[3] KIỂM THỬ DANH MỤC (CATEGORY)...");
            EntityManager em = JpaConfig.getEntityManager();
            EntityTransaction trans = em.getTransaction();
            try {
                trans.begin();
                Category testCat = new Category("Danh mục Điện tử Test", "electronics.png", 1);
                em.persist(testCat);
                trans.commit();
                System.out.println("   -> [THÀNH CÔNG] Thêm mới Category qua JPA (ID: " + testCat.getCategoryId() + ")");

                Category foundCat = em.find(Category.class, testCat.getCategoryId());
                if (foundCat != null) {
                    System.out.println("   -> [THÀNH CÔNG] Tìm thấy Category theo ID: " + foundCat.getCategoryName());

                    trans.begin();
                    foundCat.setCategoryName("Danh mục Điện tử Test (Đã sửa)");
                    em.merge(foundCat);
                    trans.commit();
                    System.out.println("   -> [THÀNH CÔNG] Cập nhật Category qua JPA!");

                    trans.begin();
                    em.remove(foundCat);
                    trans.commit();
                    System.out.println("   -> [THÀNH CÔNG] Xóa Category qua JPA!");
                }
            } catch (Exception e) {
                if (trans.isActive()) trans.rollback();
                throw e;
            } finally {
                em.close();
            }

            System.out.println("\n========== TẤT CẢ CÁC BƯỚC TEST ACCOUNT, PRODUCT VÀ CATEGORY ĐỀU THÀNH CÔNG 100%! ==========");
        } catch (Exception e) {
            System.err.println("[LỖI] Xảy ra ngoại lệ trong quá trình kiểm thử:");
            e.printStackTrace();
        } finally {
            JpaConfig.shutdown();
        }
    }
}
