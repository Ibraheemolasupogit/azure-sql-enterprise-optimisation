-- File: 03-add-covering-index-pathwayevent.sql
-- Purpose: Eliminate Key Lookup amplification in CANCER_62 breach monitoring query
-- Impact: Reduces logical reads by ~66%
-- Environment: Azure SQL Database

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_PathwayEvent_Covering'
      AND object_id = OBJECT_ID('core.PathwayEvent')
)
BEGIN
    CREATE INDEX IX_PathwayEvent_Covering
    ON core.PathwayEvent (ReferralId)
    INCLUDE (PathwayStatusId);
END;