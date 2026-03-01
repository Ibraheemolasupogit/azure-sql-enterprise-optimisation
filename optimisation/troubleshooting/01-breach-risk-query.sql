-- Calculates potential 62-day cancer breaches.
-- Used by operational dashboard to monitor performance.

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
AND DATEDIFF(DAY, r.ReferralReceivedDt, GETUTCDATE()) > 60
ORDER BY DaysOnPathway DESC;
