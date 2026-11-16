-- =====================================================================
-- MIGRATION: Bổ sung các cột cần thiết cho chức năng OTP và bảo mật
-- Chạy trên database: ProductManagerDB
-- An toàn: chỉ ADD COLUMN nếu chưa tồn tại, không xóa dữ liệu cũ
-- =====================================================================

USE ProductManagerDB;
GO

-- -----------------------------------------------------------------
-- 1. Bổ sung cột [active] vào bảng Account
--    Các tài khoản cũ mặc định = 1 (đã kích hoạt) để không mất quyền đăng nhập
-- -----------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'Account' AND COLUMN_NAME = 'active'
)
BEGIN
    ALTER TABLE Account
    ADD active BIT NOT NULL DEFAULT 1;

    PRINT 'Da them cot [active] vao bang Account. Tai khoan cu duoc kich hoat mac dinh.';
END
ELSE
BEGIN
    PRINT 'Cot [active] da ton tai trong bang Account.';
END
GO

-- -----------------------------------------------------------------
-- 2. Tạo bảng OtpToken nếu chưa có (Hibernate thường tự tạo,
--    nhưng đảm bảo thêm ở đây để script có thể chạy độc lập)
-- -----------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'OtpToken'
)
BEGIN
    CREATE TABLE OtpToken (
        id           INT            IDENTITY(1,1) PRIMARY KEY,
        email        VARCHAR(100)   NOT NULL,
        otp_hash     VARCHAR(255)   NOT NULL,
        purpose      VARCHAR(50)    NOT NULL,
        created_at   DATETIME2      NOT NULL,
        expires_at   DATETIME2      NOT NULL,
        is_used      BIT            NOT NULL DEFAULT 0,
        attempts     INT            NOT NULL DEFAULT 0,
        max_attempts INT            NOT NULL DEFAULT 5
    );

    PRINT 'Da tao bang OtpToken.';
END
ELSE
BEGIN
    PRINT 'Bang OtpToken da ton tai.';
END
GO

PRINT 'Migration hoan tat thanh cong.';
GO
