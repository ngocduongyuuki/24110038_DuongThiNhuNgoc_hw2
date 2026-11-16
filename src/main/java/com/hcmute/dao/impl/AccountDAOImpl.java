package com.hcmute.dao.impl;

import com.hcmute.config.JpaConfig;
import com.hcmute.dao.AccountDAO;
import com.hcmute.model.Account;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.TypedQuery;
import java.util.List;

public class AccountDAOImpl implements AccountDAO {

    @Override
    public Account findByUsername(String username) {
        EntityManager em = JpaConfig.getEntityManager();
        try {
            TypedQuery<Account> query = em.createQuery(
                "SELECT a FROM Account a WHERE a.username = :username", Account.class);
            query.setParameter("username", username);
            List<Account> list = query.getResultList();
            return list.isEmpty() ? null : list.get(0);
        } finally {
            em.close();
        }
    }

    @Override
    public Account findByEmail(String email) {
        EntityManager em = JpaConfig.getEntityManager();
        try {
            TypedQuery<Account> query = em.createQuery(
                "SELECT a FROM Account a WHERE a.email = :email", Account.class);
            query.setParameter("email", email);
            List<Account> list = query.getResultList();
            return list.isEmpty() ? null : list.get(0);
        } finally {
            em.close();
        }
    }

    @Override
    public boolean insert(Account account) {
        EntityManager em = JpaConfig.getEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();
            em.persist(account);
            trans.commit();
            return true;
        } catch (Exception e) {
            if (trans.isActive()) {
                trans.rollback();
            }
            e.printStackTrace();
            return false;
        } finally {
            em.close();
        }
    }
}
