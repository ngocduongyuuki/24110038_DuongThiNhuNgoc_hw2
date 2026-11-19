package com.hcmute.service.impl;

import com.hcmute.dao.VideoDAO;
import com.hcmute.dao.impl.VideoDAOImpl;
import com.hcmute.model.Video;
import com.hcmute.service.VideoService;

import java.util.Collections;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class VideoServiceImpl implements VideoService {

    private static final Logger LOGGER = Logger.getLogger(VideoServiceImpl.class.getName());
    private final VideoDAO videoDAO = new VideoDAOImpl();

    @Override
    public boolean addVideo(Video video) {
        try {
            videoDAO.save(video);
            return true;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to add video: " + video.getTitle(), e);
            return false;
        }
    }

    @Override
    public Video getVideoById(int id) {
        try {
            return videoDAO.findById(id);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get video by id: " + id, e);
            return null;
        }
    }

    @Override
    public boolean updateVideo(Video video) {
        try {
            videoDAO.update(video);
            return true;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to update video: " + video.getId(), e);
            return false;
        }
    }

    @Override
    public String deleteVideo(int id) {
        try {
            Video video = videoDAO.findById(id);
            if (video == null) return null;
            String path = video.getVideoPath();
            videoDAO.delete(id);
            return path;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to delete video: " + id, e);
            return null;
        }
    }

    @Override
    public List<Video> getTop10LatestVideos() {
        try {
            return videoDAO.findTop10Latest();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get top 10 latest videos", e);
            return Collections.emptyList();
        }
    }

    @Override
    public List<Video> getVideosByAccount(int accountId, int page, int pageSize) {
        try {
            int firstResult = (page - 1) * pageSize;
            return videoDAO.findByAccountId(accountId, firstResult, pageSize);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get videos for account: " + accountId, e);
            return Collections.emptyList();
        }
    }

    @Override
    public long countVideosByAccount(int accountId) {
        try {
            return videoDAO.countByAccountId(accountId);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to count videos for account: " + accountId, e);
            return 0;
        }
    }
}
