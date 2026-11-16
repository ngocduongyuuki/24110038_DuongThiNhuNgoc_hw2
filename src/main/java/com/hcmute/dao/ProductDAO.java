package com.hcmute.dao;

import com.hcmute.model.Product;
import java.util.List;

public interface ProductDAO {
    List<Product> findAll();
    Product findById(int productId);
    boolean insert(Product product);
    boolean update(Product product);
    boolean delete(int productId);
}
