<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thêm video mới</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <style>
        .upload-hint { font-size: 11px; color: var(--color-text-muted); margin-top: 4px; }
        .form-group { margin-bottom: 16px; }
        .form-group label { display: block; font-weight: bold; margin-bottom: 5px; font-size: 13px; color: var(--color-text); }
        .form-group input[type=text], .form-group textarea {
            width: 100%; padding: 8px 10px; border: 1px solid var(--color-decor);
            border-radius: 4px; font-size: 13px; box-sizing: border-box;
            background-color: #ffffff; color: var(--color-text);
            transition: border-color 0.15s, box-shadow 0.15s;
        }
        .form-group input[type=text]:focus, .form-group textarea:focus {
            border-color: var(--color-primary);
            box-shadow: 0 0 0 3px rgba(193, 18, 31, 0.2);
            outline: none;
        }
        .form-group textarea { height: 90px; resize: vertical; }
        .form-group input[type=file] { font-size: 13px; }
        .btn-submit {
            background: var(--color-primary); color: #ffffff; border: 1px solid var(--color-primary-dark);
            padding: 9px 22px; border-radius: 4px; font-size: 13px; font-weight: 500;
            cursor: pointer; transition: background 0.15s;
        }
        .btn-submit:hover { background: var(--color-primary-dark); }
        .btn-submit:focus { outline: none; box-shadow: 0 0 0 3px rgba(193, 18, 31, 0.35); }
        .btn-submit:active { background: var(--color-header); transform: translateY(1px); }
        .btn-cancel {
            background: #ffffff; color: var(--color-sidebar); padding: 9px 16px; border-radius: 4px;
            font-size: 13px; text-decoration: none; display: inline-block; margin-left: 8px;
            border: 1px solid var(--color-decor); font-weight: 500;
            transition: all 0.15s;
        }
        .btn-cancel:hover { background: #EAF2F6; text-decoration: none; color: var(--color-sidebar); }
        .btn-cancel:focus { outline: none; box-shadow: 0 0 0 3px rgba(102, 155, 188, 0.35); }
        .btn-cancel:active { background: #D8E6EE; transform: translateY(1px); }
    </style>
</head>
<body>
    <header class="top-header">
        <a href="${pageContext.request.contextPath}/home" class="brand-title">ProductManager</a>
        <div class="user-actions">
            <span class="user-name">Xin chào <strong>${sessionScope.account.fullName}</strong></span>
            <a href="${pageContext.request.contextPath}/logout" class="btn-logout">Đăng xuất</a>
        </div>
    </header>

    <div class="app-layout">
        <aside class="sidebar">
            <div class="sidebar-profile">
                <img class="sidebar-avatar" src="${pageContext.request.contextPath}/assets/images/avatar.svg" alt="Avatar">
                <div class="sidebar-role">Thành viên</div>
            </div>
            <ul class="sidebar-menu">
                <li><a href="${pageContext.request.contextPath}/home" class="menu-link">Trang chủ</a></li>
                <li>
                    <a href="${pageContext.request.contextPath}/video" class="menu-link active-black">Quản lý Video</a>
                    <ul class="tree-subnav">
                        <li><a href="${pageContext.request.contextPath}/video/add" class="sub-active">Thêm video mới</a></li>
                        <li><a href="${pageContext.request.contextPath}/video">Danh sách video của tôi</a></li>
                    </ul>
                </li>
                <li><a href="${pageContext.request.contextPath}/product/list" class="menu-link">Quản lý sản phẩm</a></li>
            </ul>
        </aside>

        <main class="content-area">
            <h1 class="page-header-title">Thêm video mới</h1>
            <p class="page-header-subtitle">Upload và chia sẻ video của bạn</p>

            <c:if test="${not empty error}">
                <div class="alert alert-danger">${error}</div>
            </c:if>

            <div class="panel-box">
                <div class="panel-box-header">Thông tin video</div>
                <div class="panel-box-body">
                    <form action="${pageContext.request.contextPath}/video/add"
                          method="post"
                          enctype="multipart/form-data">

                        <div class="form-group">
                            <label for="title">Tiêu đề <span style="color:var(--color-primary);">*</span></label>
                            <input type="text" id="title" name="title"
                                   value="<c:out value='${title}'/>"
                                   placeholder="Nhập tiêu đề video..." maxlength="200" required>
                        </div>

                        <div class="form-group">
                            <label for="description">Mô tả</label>
                            <textarea id="description" name="description"
                                      placeholder="Nhập mô tả video (không bắt buộc)..."><c:out value="${description}"/></textarea>
                        </div>

                        <div class="form-group">
                            <label for="videoFile">File video <span style="color:var(--color-primary);">*</span></label>
                            <input type="file" id="videoFile" name="videoFile"
                                   accept="video/mp4,video/webm,video/ogg,.mp4,.webm,.ogv,.mov" required>
                            <div class="upload-hint">
                                Chấp nhận: MP4, WebM, OGV, MOV. Kích thước tối đa: 200MB.
                            </div>
                            <div id="filePreview" style="margin-top:10px;display:none;">
                                <video id="previewPlayer" controls style="max-width:400px;border-radius:4px;border:1px solid var(--color-border);"></video>
                            </div>
                        </div>

                        <div>
                            <button type="submit" class="btn-submit">Upload và lưu</button>
                            <a href="${pageContext.request.contextPath}/video" class="btn-cancel">Hủy</a>
                        </div>
                    </form>
                </div>
            </div>
        </main>
    </div>

    <script>
    document.getElementById('videoFile').addEventListener('change', function() {
        var file = this.files[0];
        if (file) {
            var url = URL.createObjectURL(file);
            var preview = document.getElementById('previewPlayer');
            preview.src = url;
            document.getElementById('filePreview').style.display = 'block';
        }
    });
    </script>
</body>
</html>
