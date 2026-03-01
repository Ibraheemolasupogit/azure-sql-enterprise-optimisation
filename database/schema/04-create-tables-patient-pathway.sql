-- Core clinical and pathway tables.

CREATE TABLE core.Patient
(
    PatientId          BIGINT IDENTITY(1,1) CONSTRAINT PK_Patient PRIMARY KEY,
    NHSNumber          CHAR(10)       NULL,  -- demo only; treat as sensitive
    HospitalNumber     NVARCHAR(20)   NOT NULL,
    FirstName          NVARCHAR(100)  NOT NULL,
    LastName           NVARCHAR(100)  NOT NULL,
    DateOfBirth        DATE           NOT NULL,
    Sex                CHAR(1)        NOT NULL,   -- M/F/I/U in real life
    OrganisationId     INT            NOT NULL,
    CreatedUtc         DATETIME2(0)   NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE UNIQUE INDEX UX_Patient_HospitalNumber
ON core.Patient(HospitalNumber);

CREATE TABLE core.Referral
(
    ReferralId         BIGINT IDENTITY(1,1) CONSTRAINT PK_Referral PRIMARY KEY,
    PatientId          BIGINT        NOT NULL,
    PathwayTypeId      INT           NOT NULL,
    ReferralReceivedDt DATE          NOT NULL,
    Urgency            NVARCHAR(20)  NOT NULL, -- Routine, Urgent, 2WW etc.
    ReferringOrgId     INT           NOT NULL,
    ManagingOrgId      INT           NOT NULL,
    CreatedUtc         DATETIME2(0)  NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE INDEX IX_Referral_Patient ON core.Referral(PatientId);
CREATE INDEX IX_Referral_ReferralReceivedDt ON core.Referral(ReferralReceivedDt);

ALTER TABLE core.Referral
    ADD CONSTRAINT FK_Referral_Patient
        FOREIGN KEY (PatientId) REFERENCES core.Patient(PatientId);

ALTER TABLE core.Referral
    ADD CONSTRAINT FK_Referral_PathwayType
        FOREIGN KEY (PathwayTypeId) REFERENCES ref.PathwayType(PathwayTypeId);

ALTER TABLE core.Referral
    ADD CONSTRAINT FK_Referral_RefOrg
        FOREIGN KEY (ReferringOrgId) REFERENCES ref.Organisation(OrganisationId);

ALTER TABLE core.Referral
    ADD CONSTRAINT FK_Referral_ManOrg
        FOREIGN KEY (ManagingOrgId) REFERENCES ref.Organisation(OrganisationId);

CREATE TABLE core.PathwayEvent
(
    PathwayEventId     BIGINT IDENTITY(1,1) CONSTRAINT PK_PathwayEvent PRIMARY KEY,
    ReferralId         BIGINT        NOT NULL,
    EventDate          DATE          NOT NULL,
    EventType          NVARCHAR(50)  NOT NULL, -- e.g. "FirstSeen", "DecisionToTreat"
    PathwayStatusId    INT           NOT NULL,
    Notes              NVARCHAR(400) NULL,
    CreatedUtc         DATETIME2(0)  NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE INDEX IX_PathwayEvent_Referral_EventDate
ON core.PathwayEvent(ReferralId, EventDate);

ALTER TABLE core.PathwayEvent
    ADD CONSTRAINT FK_PathwayEvent_Referral
        FOREIGN KEY (ReferralId) REFERENCES core.Referral(ReferralId);

ALTER TABLE core.PathwayEvent
    ADD CONSTRAINT FK_PathwayEvent_Status
        FOREIGN KEY (PathwayStatusId) REFERENCES ref.PathwayStatus(PathwayStatusId);
