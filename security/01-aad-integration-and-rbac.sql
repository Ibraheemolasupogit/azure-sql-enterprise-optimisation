-- =====================================================
-- Azure SQL Database – Entra ID Integration & RBAC
-- File: security/01-aad-integration-and-rbac.sql
--
-- Purpose:
--   Example of mapping Microsoft Entra ID groups to
--   database principals and roles in Azure SQL Database.
--
-- Notes:
--   - Entra ID groups are created in the directory first.
--   - This script is run against the HCareOps database.
--   - Group names here are examples – replace with real
--     Entra ID group names in your tenant.
-- =====================================================

---------------------------------------------------------
-- 1. DBA Administrative Group
---------------------------------------------------------
-- Entra group: AAD-HCareOps-DBA
-- Capability : Full database administration

CREATE USER [AAD-HCareOps-DBA]
FROM EXTERNAL PROVIDER;
GO

ALTER ROLE db_owner
ADD MEMBER [AAD-HCareOps-DBA];
GO

---------------------------------------------------------
-- 2. Reporting-Only Group
---------------------------------------------------------
-- Entra group: AAD-HCareOps-Reporting
-- Capability : Read-only access to the reporting schema

CREATE USER [AAD-HCareOps-Reporting]
FROM EXTERNAL PROVIDER;
GO

-- Application-specific reporting role
CREATE ROLE [db_reporting];
GO

GRANT SELECT ON SCHEMA::[reporting]
TO [db_reporting];
GO

ALTER ROLE [db_reporting]
ADD MEMBER [AAD-HCareOps-Reporting];
GO

---------------------------------------------------------
-- Principle:
--   Users are added to Entra ID groups.
--   Groups are mapped to database roles.
--   Roles receive the minimum required permissions.
---------------------------------------------------------