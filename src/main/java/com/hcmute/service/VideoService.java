package com.hcmute.service;

import com.hcmute.model.Video;
import java.util.List;

public interface VideoService {

    boolean addVideo(Video video);

    Video getVideoById(int id);

    boolean updateVideo(Video video);

    /**
     * Delete video by id. Returns the videoPath so the caller can delete the file.
     * Returns null if video not found.
     */
    String deleteVideo(int id);

    /** Top 10 newest videos across all users */
    List<Video> getTop10LatestVideos();

    /** Videos belonging to a specific account, paginated */
    List<Video> getVideosByAccount(int accountId, int page, int pageSize);

    /** Count videos belonging to a specific account */
    long countVideosByAccount(int accountId);
}
