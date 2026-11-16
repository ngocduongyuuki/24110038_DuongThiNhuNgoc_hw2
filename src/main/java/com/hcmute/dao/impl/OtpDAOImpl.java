package com.hcmute.dao.impl;

import com.hcmute.config.JpaConfig;
import com.hcmute.dao.OtpDAO;
import com.hcmute.model.OtpToken;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.TypedQuery;
import java.util.List;

public class OtpDAOImpl implements OtpDAO {

    @Override
    public boolean insert(OtpToken token) {
        EntityManager em = JpaConfig.getEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();
            em.persist(token);
            trans.commit();
            return true;
        } catch (Exception e) {
            if (trans.isActive()) trans.rollback();
            e.printStackTrace();
            return false;
        } finally {
            em.close();
        }
    }

    @Override
    public boolean update(OtpToken token) {
        EntityManager em = JpaConfig.getEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();
            em.merge(token);
            trans.commit();
            return true;
        } catch (Exception e) {
            if (trans.isActive()) trans.rollback();
            e.printStackTrace();
            return false;
        } finally {
            em.close();
        }
    }

    @Override
    public OtpToken findLatestByEmailAndPurpose(String email, String purpose) {
        EntityManager em = JpaConfig.getEntityManager();
        try {
            TypedQuery<OtpToken> query = em.createQuery(
                "SELECT o FROM OtpToken o WHERE o.email = :email AND o.purpose = :purpose ORDER BY o.createdAt DESC",
                OtpToken.class
            );
            query.setParameter("email", email);
            query.setParameter("purpose", purpose);
            query.setMaxResults(1);
            List<OtpToken> list = query.getResultList();
            return list.isEmpty() ? null : list.get(0);
        } finally {
            em.close();
        }
    }

    @Override
    public void invalidatePreviousOtps(String email, String purpose) {
        EntityManager em = JpaConfig.getEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();
            em.createQuery(
                "UPDATE OtpToken o SET o.used = true WHERE o.email = :email AND o.purpose = :purpose AND o.used = false"
            ).setParameter("email", email)
             .setParameter("purpose", purpose)
             .executeUpdate();
            trans.commit();
        } catch (Exception e) {
            if (trans.isActive()) trans.rollback();
            e.printStackTrace();
        } finally {
            em.close();
        }
    }
}
