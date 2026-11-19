-- ============================================================
-- Migration: Thêm cột profile_image vào bảng Account
-- File: migration_profile.sql
-- Áp dụng: Chạy script này trên database ProductManagerDB
-- Không xóa dữ liệu hiện tại
-- ============================================================

USE ProductManagerDB;
GO

-- Kiểm tra cột đã tồn tại chưa trước khi thêm
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'Account'
      AND COLUMN_NAME = 'profile_image'
)
BEGIN
    ALTER TABLE Account ADD profile_image NVARCHAR(500) NULL;
    PRINT 'Đã thêm cột profile_image vào bảng Account';
END
ELSE
BEGIN
    PRINT 'Cột profile_image đã tồn tại, bỏ qua';
END
GO
