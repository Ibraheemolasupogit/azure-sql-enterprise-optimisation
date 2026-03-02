-- Composite index to optimise cancer breach monitoring workload.

CREATE INDEX IX_Referral_PathwayType_ReferralDate
ON core.Referral (PathwayTypeId, ReferralReceivedDt)
INCLUDE (PatientId, ReferringOrgId, ManagingOrgId);
