package com.hcmute.dao;

import com.hcmute.model.Video;
import java.util.List;

public interface VideoDAO {

    void save(Video video);

    Video findById(int id);

    void update(Video video);

    void delete(int id);

    /** Top 10 newest videos across all users */
    List<Video> findTop10Latest();

    /** Videos belonging to a specific account, paginated */
    List<Video> findByAccountId(int accountId, int firstResult, int maxResults);

    /** Count videos belonging to a specific account */
    long countByAccountId(int accountId);
}
