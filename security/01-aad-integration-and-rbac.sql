-- Example: map Entra ID groups to database roles
-- Replace group names with real AAD groups in your tenant.

CREATE USER [AAD-HCareOps-DBA] FROM EXTERNAL PROVIDER;
ALTER ROLE db_owner ADD MEMBER [AAD-HCareOps-DBA];

CREATE USER [AAD-HCareOps-Reporting] FROM EXTERNAL PROVIDER;
CREATE ROLE [db_reporting];
GRANT SELECT ON SCHEMA::[reporting] TO [db_reporting];
ALTER ROLE [db_reporting] ADD MEMBER [AAD-HCareOps-Reporting];
