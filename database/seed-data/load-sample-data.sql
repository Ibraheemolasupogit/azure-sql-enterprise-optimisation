-- Simple seed data for demo and performance testing.
-- Run after schema scripts.

-- Organisations
INSERT INTO ref.Organisation (OrgCode, OrgName, OrgType)
VALUES
('RQ8', 'Example NHS Acute Trust', 'Acute'),
('6A7', 'Neighbouring NHS Acute Trust', 'Acute'),
('Y1234', 'Example Integrated Care Board', 'ICB');

-- Pathway types
INSERT INTO ref.PathwayType (Code, Name, Description)
VALUES
('CANCER_62', '62-day Cancer', 'Urgent GP referral for suspected cancer'),
('CANCER_31', '31-day Cancer', 'Decision to treat to first treatment'),
('RTT_18', '18-week RTT', 'Referral to treatment waiting time');

-- Pathway statuses
INSERT INTO ref.PathwayStatus (Code, Name, IsBreach)
VALUES
('ACTIVE', 'Active', 0),
('COMPLETED', 'Completed', 0),
('BREACHED', 'Breached', 1),
('CANCELLED', 'Cancelled', 0);

-- A handful of example patients
INSERT INTO core.Patient
    (NHSNumber, HospitalNumber, FirstName, LastName, DateOfBirth, Sex, OrganisationId)
VALUES
('9999999999', 'H000001', 'Amira', 'Hassan', '1975-04-12', 'F', 1),
('8888888888', 'H000002', 'James', 'Walker', '1963-11-03', 'M', 1),
('7777777777', 'H000003', 'Sonia', 'Patel', '1982-07-21', 'F', 1);

-- Example referrals
INSERT INTO core.Referral
    (PatientId, PathwayTypeId, ReferralReceivedDt, Urgency, ReferringOrgId, ManagingOrgId)
VALUES
(1, 1, '2025-01-02', '2WW', 1, 1),
(2, 3, '2025-01-10', 'Routine', 1, 1),
(3, 1, '2025-01-15', '2WW', 2, 1);

-- Pathway events (including a breach scenario)
INSERT INTO core.PathwayEvent
    (ReferralId, EventDate, EventType, PathwayStatusId, Notes)
VALUES
(1, '2025-01-10', 'FirstSeen', 1, 'Seen in clinic'),
(1, '2025-02-20', 'FirstTreatment', 2, 'Surgery completed'),
(2, '2025-02-15', 'FirstSeen', 1, 'Routine clinic'),
(3, '2025-02-01', 'FirstSeen', 3, 'Exceeded target before treatment');
