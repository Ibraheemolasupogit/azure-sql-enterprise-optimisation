-- Reference data: organisations, pathways, statuses.

CREATE TABLE ref.Organisation
(
    OrganisationId      INT IDENTITY(1,1) CONSTRAINT PK_Organisation PRIMARY KEY,
    OrgCode             NVARCHAR(10)  NOT NULL,
    OrgName             NVARCHAR(200) NOT NULL,
    OrgType             NVARCHAR(50)  NOT NULL,   -- Acute, Community, GP, ICB, etc.
    IsActive            BIT           NOT NULL DEFAULT 1,
    CreatedUtc          DATETIME2(0)  NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE UNIQUE INDEX UX_Organisation_OrgCode
ON ref.Organisation(OrgCode);

CREATE TABLE ref.PathwayType
(
    PathwayTypeId   INT IDENTITY(1,1) CONSTRAINT PK_PathwayType PRIMARY KEY,
    Code            NVARCHAR(20)  NOT NULL,
    Name            NVARCHAR(100) NOT NULL,
    Description     NVARCHAR(400) NULL
);

CREATE UNIQUE INDEX UX_PathwayType_Code
ON ref.PathwayType(Code);

CREATE TABLE ref.PathwayStatus
(
    PathwayStatusId INT IDENTITY(1,1) CONSTRAINT PK_PathwayStatus PRIMARY KEY,
    Code            NVARCHAR(20)  NOT NULL,
    Name            NVARCHAR(100) NOT NULL,
    IsBreach        BIT           NOT NULL DEFAULT 0
);

CREATE UNIQUE INDEX UX_PathwayStatus_Code
ON ref.PathwayStatus(Code);
