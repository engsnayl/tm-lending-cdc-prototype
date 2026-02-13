-- ============================================================
-- Enable CDC (Change Data Capture) on SentinelMock
-- CDC requires SQL Server Agent to be running
-- Only enabled on Agreement and Transaction tables
-- PaymentProfile and CustomProfile are lookup tables only
-- ============================================================

USE SentinelMock;
GO

-- Enable CDC on the database
EXEC sys.sp_cdc_enable_db;
GO

-- Enable CDC on Agreement table
EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name = N'Agreement',
    @role_name = NULL,
    @supports_net_changes = 1;
GO

-- Enable CDC on Transaction table
EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name = N'Transaction',
    @role_name = NULL,
    @supports_net_changes = 1;
GO

PRINT 'CDC enabled on SentinelMock database, Agreement table, and Transaction table.';
GO
