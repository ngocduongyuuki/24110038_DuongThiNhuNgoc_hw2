<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Trang chủ - 10 Video mới nhất</title>
    <style>
        .video-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 20px;
            margin-top: 16px;
        }
        .video-card {
            background: #fff;
            border: 1px solid #e5d5ba;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 1px 4px rgba(0,0,0,.07);
            transition: box-shadow .2s;
        }
        .video-card:hover { box-shadow: 0 4px 14px rgba(120,0,0,.12); }
        .video-card-thumb {
            background: #002336;
            height: 160px;
            display: flex; align-items: center; justify-content: center;
            color: #669bbc; font-size: 36px; overflow: hidden;
        }
        .video-card-thumb video { width:100%; height:100%; object-fit:cover; }
        .video-card-body { padding: 12px 14px 14px; }
        .video-card-title {
            font-size: 14px; font-weight: bold; margin-bottom: 6px;
            white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
        }
        .video-card-title a { color: #003049; }
        .video-card-title a:hover { color: #c1121f; text-decoration: underline; }
        .video-card-desc {
            font-size: 12px; color: #5c677d; margin-bottom: 8px;
            overflow: hidden; display: -webkit-box;
            -webkit-line-clamp: 2; -webkit-box-orient: vertical;
        }
        .video-card-meta { font-size: 11px; color: #669bbc; font-weight: 500; }
    </style>
</head>
<body>
    <div class="d-flex justify-content-between align-items-start mb-3">
        <div>
            <h1 class="h4 mb-1"><i class="bi bi-house-door me-2 text-danger"></i>Trang chủ</h1>
            <p class="text-muted mb-0" style="font-size:13px;">10 video mới nhất từ tất cả người dùng</p>
        </div>
        <a href="${pageContext.request.contextPath}/video/add" class="btn btn-danger">
            <i class="bi bi-plus-circle me-1"></i>Thêm video
        </a>
    </div>

    <c:choose>
        <c:when test="${empty latestVideos}">
            <div class="text-center py-5" style="background:#fff;border:1px solid #e5d5ba;border-radius:8px;">
                <div style="font-size:48px;">🎬</div>
                <p class="fw-bold text-danger mt-2 mb-1">Chưa có video nào</p>
                <p class="text-muted mb-3">Hãy là người đầu tiên đăng tải video!</p>
                <a href="${pageContext.request.contextPath}/video/add" class="btn btn-danger">
                    <i class="bi bi-plus-circle me-1"></i>Thêm video ngay
                </a>
            </div>
        </c:when>
        <c:otherwise>
            <div class="video-grid">
                <c:forEach var="v" items="${latestVideos}">
                    <div class="video-card">
                        <div class="video-card-thumb">
                            <c:choose>
                                <c:when test="${not empty v.videoPath}">
                                    <video preload="metadata" muted>
                                        <source src="${pageContext.request.contextPath}${v.videoPath}" type="video/mp4">
                                    </video>
                                </c:when>
                                <c:otherwise>🎬</c:otherwise>
                            </c:choose>
                        </div>
                        <div class="video-card-body">
                            <div class="video-card-title">
                                <a href="${pageContext.request.contextPath}/video/detail?id=${v.id}">
                                    <c:out value="${v.title}"/>
                                </a>
                            </div>
                            <div class="video-card-desc">
                                <c:choose>
                                    <c:when test="${not empty v.description}"><c:out value="${v.description}"/></c:when>
                                    <c:otherwise><em class="text-muted">Không có mô tả</em></c:otherwise>
                                </c:choose>
                            </div>
                            <div class="video-card-meta">
                                <span><i class="bi bi-person me-1"></i><c:out value="${v.account.fullName}"/></span>
                                <span class="ms-2"><i class="bi bi-calendar me-1"></i>${v.createdAtFormatted}</span>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>
</body>
</html>
