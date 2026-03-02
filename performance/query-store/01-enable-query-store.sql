-- File: 01-enable-query-store.sql
-- Purpose: Configure Query Store for the HCareOps Azure SQL Database
-- Scope:   Run in the HCareOps database context
-- Notes:   Uses READ_WRITE mode with conservative storage limits suitable for POC/lab

ALTER DATABASE CURRENT
SET QUERY_STORE = ON
(
    OPERATION_MODE = READ_WRITE,
    CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30),
    DATA_FLUSH_INTERVAL_SECONDS = 900,     -- 15 minutes
    INTERVAL_LENGTH_MINUTES = 60,          -- 1-hour aggregation
    MAX_STORAGE_SIZE_MB = 1024,            -- 1 GB cap for personal subscription
    QUERY_CAPTURE_MODE = AUTO,             -- capture only relevant queries
    SIZE_BASED_CLEANUP_MODE = AUTO
);

-- Optional: verify settings
SELECT
    actual_state_desc,
    desired_state_desc,
    current_storage_size_mb,
    max_storage_size_mb,
    readonly_reason,
    current_interval_start_time
FROM sys.database_query_store_options;