-- Optimised version of breach risk query
-- Makes date filter SARGable.

DECLARE @CutoffDate DATE = DATEADD(DAY, -60, GETUTCDATE());

SELECT
    r.ReferralId,
    p.HospitalNumber,
    pt.Name AS PathwayType,
    r.ReferralReceivedDt,
    DATEDIFF(DAY, r.ReferralReceivedDt, GETUTCDATE()) AS DaysOnPathway,
    ps.Name AS CurrentStatus
FROM core.Referral r
JOIN core.Patient p
    ON r.PatientId = p.PatientId
JOIN ref.PathwayType pt
    ON r.PathwayTypeId = pt.PathwayTypeId
JOIN core.PathwayEvent pe
    ON pe.ReferralId = r.ReferralId
JOIN ref.PathwayStatus ps
    ON pe.PathwayStatusId = ps.PathwayStatusId
WHERE pt.Code = 'CANCER_62'
AND r.ReferralReceivedDt < @CutoffDate
ORDER BY r.ReferralReceivedDt;
