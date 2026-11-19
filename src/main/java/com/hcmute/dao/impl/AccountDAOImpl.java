package com.hcmute.dao.impl;

import com.hcmute.config.JpaConfig;
import com.hcmute.dao.AccountDAO;
import com.hcmute.model.Account;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.TypedQuery;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class AccountDAOImpl implements AccountDAO {

    private static final Logger LOGGER = Logger.getLogger(AccountDAOImpl.class.getName());

    @Override
    public Account findByUsername(String username) {
        if (username == null || username.isBlank()) return null;
        EntityManager em = JpaConfig.getEntityManager();
        try {
            TypedQuery<Account> query = em.createQuery(
                "SELECT a FROM Account a WHERE a.username = :username", Account.class);
            query.setParameter("username", username.trim());
            List<Account> list = query.getResultList();
            return list.isEmpty() ? null : list.get(0);
        } catch (Exception e) {
            logSqlException("findByUsername", e);
            return null;
        } finally {
            em.close();
        }
    }

    @Override
    public Account findByEmail(String email) {
        if (email == null || email.isBlank()) return null;
        EntityManager em = JpaConfig.getEntityManager();
        try {
            TypedQuery<Account> query = em.createQuery(
                "SELECT a FROM Account a WHERE a.email = :email", Account.class);
            query.setParameter("email", email.trim());
            List<Account> list = query.getResultList();
            return list.isEmpty() ? null : list.get(0);
        } catch (Exception e) {
            logSqlException("findByEmail", e);
            return null;
        } finally {
            em.close();
        }
    }

    @Override
    public Account findByUsernameOrEmail(String identifier) {
        if (identifier == null || identifier.isBlank()) return null;
        EntityManager em = JpaConfig.getEntityManager();
        try {
            TypedQuery<Account> query = em.createQuery(
                "SELECT a FROM Account a WHERE a.username = :id OR a.email = :id", Account.class);
            query.setParameter("id", identifier.trim());
            query.setMaxResults(1);
            List<Account> list = query.getResultList();
            return list.isEmpty() ? null : list.get(0);
        } catch (Exception e) {
            logSqlException("findByUsernameOrEmail", e);
            return null;
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
            logSqlException("insert Account [username=" + (account != null ? account.getUsername() : "null") + "]", e);
            return false;
        } finally {
            em.close();
        }
    }

    @Override
    public boolean update(Account account) {
        EntityManager em = JpaConfig.getEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();
            em.merge(account);
            trans.commit();
            return true;
        } catch (Exception e) {
            if (trans.isActive()) {
                trans.rollback();
            }
            logSqlException("update Account [id=" + (account != null ? account.getId() : "null") + "]", e);
            return false;
        } finally {
            em.close();
        }
    }

    private void logSqlException(String action, Throwable t) {
        StringBuilder sb = new StringBuilder("Lỗi JPA/Database khi thực hiện ").append(action).append(": ");
        Throwable curr = t;
        while (curr != null) {
            if (curr instanceof SQLException sqlEx) {
                sb.append(String.format(" [SQLState=%s, ErrorCode=%d, Message=%s]",
                    sqlEx.getSQLState(), sqlEx.getErrorCode(), sqlEx.getMessage()));
            }
            curr = curr.getCause();
        }
        LOGGER.log(Level.SEVERE, sb.toString(), t);
    }
}
