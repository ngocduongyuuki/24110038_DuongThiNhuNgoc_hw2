<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title><sitemesh:write property="title"/></title>

    <!-- Bootstrap 5 -->
    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">

    <!-- Bootstrap Icons -->
    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

    <!-- Custom CSS -->
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/style.css">

    <sitemesh:write property="head"/>

    <style>
        body {
            min-height: 100vh;
            background: linear-gradient(135deg, #003049 0%, #780000 100%);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .auth-brand {
            text-align: center;
            margin-bottom: 20px;
        }

        .auth-brand .brand-logo {
            font-size: 2rem;
            font-weight: bold;
            color: #fff;
            letter-spacing: 1px;
        }

        .auth-brand .brand-sub {
            color: rgba(255, 255, 255, 0.75);
            font-size: 13px;
        }

        .auth-card {
            background: #fff;
            border-radius: 8px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.25);
            width: 100%;
            max-width: 420px;
            overflow: hidden;
        }

        .auth-card-header {
            background: #780000;
            padding: 20px 24px;
            text-align: center;
        }

        .auth-card-header h2 {
            color: #fff;
            font-size: 1.3rem;
            font-weight: 600;
            margin: 0;
        }

        .auth-card-header p {
            color: rgba(255, 255, 255, 0.8);
            font-size: 12px;
            margin: 4px 0 0;
        }

        .auth-card-body {
            padding: 24px;
        }

        .auth-footer-link {
            text-align: center;
            margin-top: 16px;
            font-size: 13px;
            color: #666;
        }

        @media (max-width: 480px) {
            body {
                padding: 12px;
            }

            .auth-card {
                max-width: 100%;
            }

            .auth-card-body {
                padding: 20px;
            }
        }
    </style>
</head>

<body>
    <div class="auth-brand">
        <div class="brand-logo">
            <i class="bi bi-box-seam me-2"></i>ProductManager
        </div>
        <div class="brand-sub">Hệ thống Quản lý Sản phẩm</div>
    </div>

    <sitemesh:write property="body"/>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
