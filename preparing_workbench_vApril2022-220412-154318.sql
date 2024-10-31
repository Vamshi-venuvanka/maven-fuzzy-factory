-- 1) Adjusting maximum network packet size for large data transfers
EXEC sp_configure 'network packet size', 32767;  -- Max 64 KB for network packet size
RECONFIGURE;

-- 2) Enabling strict behavior for null handling and warnings
SET ANSI_NULLS ON;
SET ANSI_WARNINGS ON;

-- 3) Adjusting query timeout settings for long-running queries
EXEC sp_configure 'remote query timeout', 28800;  -- 8 hours timeout for remote queries
RECONFIGURE;
