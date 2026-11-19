package com.hcmute.dao.impl;

import com.hcmute.config.JpaConfig;
import com.hcmute.dao.VideoDAO;
import com.hcmute.model.Video;

import jakarta.persistence.EntityManager;
import jakarta.persistence.TypedQuery;
import java.util.List;

public class VideoDAOImpl implements VideoDAO {

    @Override
    public void save(Video video) {
        EntityManager em = JpaConfig.getEntityManager();
        try {
            em.getTransaction().begin();
            em.persist(video);
            em.getTransaction().commit();
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    @Override
    public Video findById(int id) {
        EntityManager em = JpaConfig.getEntityManager();
        try {
            // Use JOIN FETCH to eagerly load account for display
            TypedQuery<Video> q = em.createQuery(
                "SELECT v FROM Video v JOIN FETCH v.account WHERE v.id = :id", Video.class);
            q.setParameter("id", id);
            List<Video> result = q.getResultList();
            return result.isEmpty() ? null : result.get(0);
        } finally {
            em.close();
        }
    }

    @Override
    public void update(Video video) {
        EntityManager em = JpaConfig.getEntityManager();
        try {
            em.getTransaction().begin();
            em.merge(video);
            em.getTransaction().commit();
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    @Override
    public void delete(int id) {
        EntityManager em = JpaConfig.getEntityManager();
        try {
            em.getTransaction().begin();
            Video video = em.find(Video.class, id);
            if (video != null) {
                em.remove(video);
            }
            em.getTransaction().commit();
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    @Override
    public List<Video> findTop10Latest() {
        EntityManager em = JpaConfig.getEntityManager();
        try {
            TypedQuery<Video> q = em.createQuery(
                "SELECT v FROM Video v JOIN FETCH v.account ORDER BY v.createdAt DESC", Video.class);
            q.setMaxResults(10);
            return q.getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public List<Video> findByAccountId(int accountId, int firstResult, int maxResults) {
        EntityManager em = JpaConfig.getEntityManager();
        try {
            TypedQuery<Video> q = em.createQuery(
                "SELECT v FROM Video v WHERE v.account.id = :accountId ORDER BY v.createdAt DESC",
                Video.class);
            q.setParameter("accountId", accountId);
            q.setFirstResult(firstResult);
            q.setMaxResults(maxResults);
            return q.getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public long countByAccountId(int accountId) {
        EntityManager em = JpaConfig.getEntityManager();
        try {
            TypedQuery<Long> q = em.createQuery(
                "SELECT COUNT(v) FROM Video v WHERE v.account.id = :accountId", Long.class);
            q.setParameter("accountId", accountId);
            return q.getSingleResult();
        } finally {
            em.close();
        }
    }
}
