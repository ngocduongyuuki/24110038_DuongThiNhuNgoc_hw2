IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'ProductManagerDB')
BEGIN
    CREATE DATABASE ProductManagerDB;
END
GO

USE ProductManagerDB;
GO

-- =====================================================================
-- Bảng Account
-- =====================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'Account' AND type = 'U')
BEGIN
    CREATE TABLE Account (
        id        INT IDENTITY(1,1) PRIMARY KEY,
        full_name NVARCHAR(100)  NOT NULL,
        username  VARCHAR(50)    NOT NULL UNIQUE,
        email     VARCHAR(100)   NOT NULL UNIQUE,
        phone     VARCHAR(15),
        password  VARCHAR(255)   NOT NULL,
        active    BIT            NOT NULL DEFAULT 0
    );
END
GO

-- Migration: Bổ sung cột active nếu bảng Account đã tồn tại nhưng thiếu cột
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'Account' AND type = 'U')
   AND NOT EXISTS (
       SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
       WHERE TABLE_NAME = 'Account' AND COLUMN_NAME = 'active'
   )
BEGIN
    ALTER TABLE Account
    ADD active BIT NOT NULL DEFAULT 1;
    -- DEFAULT 1 để tài khoản cũ không bị khóa
END
GO

-- =====================================================================
-- Bảng Product
-- =====================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'Product' AND type = 'U')
BEGIN
    CREATE TABLE Product (
        product_id   INT IDENTITY(1,1) PRIMARY KEY,
        product_name NVARCHAR(200)  NOT NULL,
        description  NVARCHAR(MAX),
        price        DECIMAL(15,2)  NOT NULL DEFAULT 0,
        quantity     INT            NOT NULL DEFAULT 0,
        image        VARCHAR(500),
        created_date DATE           NOT NULL DEFAULT GETDATE()
    );
END
GO

-- =====================================================================
-- Bảng OtpToken (dùng cho xác thực OTP đăng ký và quên mật khẩu)
-- =====================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'OtpToken' AND type = 'U')
BEGIN
    CREATE TABLE OtpToken (
        id           INT IDENTITY(1,1) PRIMARY KEY,
        email        VARCHAR(100)  NOT NULL,
        otp_hash     VARCHAR(255)  NOT NULL,
        purpose      VARCHAR(50)   NOT NULL,
        created_at   DATETIME2     NOT NULL,
        expires_at   DATETIME2     NOT NULL,
        is_used      BIT           NOT NULL DEFAULT 0,
        attempts     INT           NOT NULL DEFAULT 0,
        max_attempts INT           NOT NULL DEFAULT 5
    );
END
GO

-- =====================================================================
-- Dữ liệu mẫu tài khoản (active=1 vì đây là tài khoản seed)
-- Mật khẩu: 123456 (BCrypt hash bên dưới — cần cập nhật nếu dùng thực)
-- Tạm thời dùng plaintext; khi đăng nhập lần đầu hệ thống sẽ tự nâng cấp BCrypt
-- =====================================================================
IF NOT EXISTS (SELECT * FROM Account WHERE username = 'admin')
BEGIN
    INSERT INTO Account (full_name, username, email, phone, password, active)
    VALUES (N'Quản trị viên', 'admin', 'admin@hcmute.edu.vn', '0901234567', '123456', 1);
END

IF NOT EXISTS (SELECT * FROM Account WHERE username = 'user1')
BEGIN
    INSERT INTO Account (full_name, username, email, phone, password, active)
    VALUES (N'Nguyễn Văn A', 'user1', 'user1@hcmute.edu.vn', '0987654321', '123456', 1);
END
GO

-- =====================================================================
-- Dữ liệu mẫu sản phẩm
-- =====================================================================
IF NOT EXISTS (SELECT * FROM Product WHERE product_name = N'Laptop Dell XPS 15')
BEGIN
    INSERT INTO Product (product_name, description, price, quantity, image, created_date)
    VALUES
    (
        N'Laptop Dell XPS 15',
        N'Laptop cao cấp dành cho lập trình viên, màn hình 15.6 inch OLED, CPU Intel Core i7.',
        35000000, 10,
        'https://images.unsplash.com/photo-1593642632559-0c6d3fc62b89?w=200',
        GETDATE()
    ),
    (
        N'Chuột Logitech MX Master 3',
        N'Chuột không dây cao cấp, pin sạc nhanh, kết nối đa thiết bị qua Bluetooth.',
        1800000, 50,
        'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=200',
        GETDATE()
    ),
    (
        N'Bàn phím cơ Keychron K2',
        N'Bàn phím cơ compact 75%, kết nối Bluetooth và USB-C, switch Red.',
        2500000, 30,
        'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=200',
        GETDATE()
    ),
    (
        N'Màn hình LG 27 inch 4K',
        N'Màn hình IPS 4K 27 inch, 60Hz, hỗ trợ HDR400, cổng USB-C.',
        12000000, 15,
        'https://images.unsplash.com/photo-1527443224154-c4a573d7e5b9?w=200',
        GETDATE()
    ),
    (
        N'Tai nghe Sony WH-1000XM5',
        N'Tai nghe chống ồn chủ động, pin 30 giờ, âm thanh Hi-Res.',
        8500000, 20,
        'https://images.unsplash.com/photo-1546435770-a3e426bf472b?w=200',
        GETDATE()
    );
END
GO
