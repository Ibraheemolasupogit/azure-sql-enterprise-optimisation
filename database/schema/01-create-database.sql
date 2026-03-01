-- Creates the core Azure SQL database for the NHS HCareOps workload.
-- Run in the master database on the Azure SQL logical server.

CREATE DATABASE [HCareOps]
( 
    EDITION = 'GeneralPurpose',
    SERVICE_OBJECTIVE = 'GP_S_Gen5_2',  -- adjust as needed for your subscription
    MAXSIZE = 256 GB
);

-- Optional: configure collation explicitly
ALTER DATABASE [HCareOps] COLLATE SQL_Latin1_General_CP1_CI_AS;
