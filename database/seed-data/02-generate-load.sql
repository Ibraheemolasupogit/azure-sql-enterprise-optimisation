-- Generates synthetic workload for performance testing.
-- Run in HCareOps database.

SET NOCOUNT ON;

DECLARE @i INT = 1;

WHILE @i <= 5000
BEGIN
    INSERT INTO core.Patient
        (NHSNumber, HospitalNumber, FirstName, LastName, DateOfBirth, Sex, OrganisationId)
    VALUES
        (RIGHT('0000000000' + CAST(@i AS VARCHAR(10)), 10),
         CONCAT('H', FORMAT(@i + 1000, '000000')),
         'Test',
         CONCAT('Patient', @i),
         DATEADD(DAY, -(@i % 20000), GETDATE()),
         CASE WHEN @i % 2 = 0 THEN 'M' ELSE 'F' END,
         1);

    INSERT INTO core.Referral
        (PatientId, PathwayTypeId, ReferralReceivedDt, Urgency, ReferringOrgId, ManagingOrgId)
    VALUES
        (SCOPE_IDENTITY(),
         1,
         DATEADD(DAY, -(@i % 120), GETDATE()),
         '2WW',
         1,
         1);

    SET @i += 1;
END
