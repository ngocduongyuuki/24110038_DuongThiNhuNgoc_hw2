-- =====================================================================
-- MIGRATION: Tạo bảng Videos
-- Chạy trên database: ProductManagerDB
-- An toàn: chỉ tạo nếu chưa tồn tại
-- =====================================================================

USE ProductManagerDB;
GO

IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Videos'
)
BEGIN
    CREATE TABLE Videos (
        id             INT            IDENTITY(1,1) PRIMARY KEY,
        title          NVARCHAR(200)  NOT NULL,
        description    NVARCHAR(MAX),
        video_path     VARCHAR(500)   NOT NULL,
        thumbnail_path VARCHAR(500),
        created_at     DATETIME2      NOT NULL DEFAULT GETDATE(),
        updated_at     DATETIME2      NOT NULL DEFAULT GETDATE(),
        account_id     INT            NOT NULL,
        CONSTRAINT FK_Videos_Account
            FOREIGN KEY (account_id) REFERENCES Account(id)
            ON DELETE CASCADE
            ON UPDATE CASCADE
    );
    PRINT 'Da tao bang Videos.';
END
ELSE
BEGIN
    PRINT 'Bang Videos da ton tai.';
END
GO

PRINT 'Migration Videos hoan tat.';
GO
