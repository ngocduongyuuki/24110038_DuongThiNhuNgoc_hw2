package com.hcmute.controller;

import com.hcmute.model.Video;
import com.hcmute.service.VideoService;
import com.hcmute.service.impl.VideoServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet("/home")
public class HomeServlet extends HttpServlet {

    private final VideoService videoService = new VideoServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Video> latestVideos = videoService.getTop10LatestVideos();
        request.setAttribute("latestVideos", latestVideos);
        request.getRequestDispatcher("/WEB-INF/views/home.jsp").forward(request, response);
    }
}
