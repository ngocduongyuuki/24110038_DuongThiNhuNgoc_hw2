package com.hcmute.service.impl;

import com.hcmute.dao.ProductDAO;
import com.hcmute.dao.impl.ProductDAOImpl;
import com.hcmute.model.Product;
import com.hcmute.service.ProductService;

import java.util.List;

public class ProductServiceImpl implements ProductService {

    private final ProductDAO productDAO = new ProductDAOImpl();

    @Override
    public List<Product> getAllProducts() {
        return productDAO.findAll();
    }

    @Override
    public Product getProductById(int productId) {
        return productDAO.findById(productId);
    }

    @Override
    public boolean addProduct(Product product) {
        if (product == null) return false;
        return productDAO.insert(product);
    }

    @Override
    public boolean updateProduct(Product product) {
        if (product == null || product.getProductId() <= 0) return false;
        return productDAO.update(product);
    }

    @Override
    public boolean deleteProduct(int productId) {
        if (productId <= 0) return false;
        return productDAO.delete(productId);
    }
}
