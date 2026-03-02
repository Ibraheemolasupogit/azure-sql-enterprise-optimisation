-- Enables IO and time statistics for performance comparison.

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

PRINT 'Running original breach query...';
GO

-- Paste original query here when testing manually in SSMS

PRINT 'Running optimised breach query...';
GO

-- Paste optimised query here when testing manually in SSMS

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
