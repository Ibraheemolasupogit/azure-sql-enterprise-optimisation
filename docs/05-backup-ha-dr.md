# Backup, High Availability and Disaster Recovery

This document defines the data protection and resilience strategy for the HCareOps Azure SQL Database workload.

The system models operational healthcare reporting (e.g., cancer pathway monitoring), where both data integrity and service availability are critical.

---

## Backup

### Built-In Azure SQL Automatic Backups

Azure SQL Database provides fully managed automatic backups:

- Weekly full backups  
- Differential backups every 12–24 hours  
- Transaction log backups every 5–10 minutes  

These backups enable:

- Point-in-Time Restore (PITR)
- Long-Term Retention (LTR)

No manual backup scheduling is required.

---

### Point-in-Time Restore (PITR)

PITR allows restoring the database to a specific timestamp within the configured retention window.

**Typical retention (General Purpose tier):**
- 7–35 days configurable

#### Example Use Case

Accidental deletion of referral records at 14:05.

Restore to:
- 14:04 (pre-incident state)

In Azure, restore is executed via:
- Azure Portal
- Azure CLI
- PowerShell
- ARM/Bicep

---

### Long-Term Retention (LTR)

LTR is used for compliance and audit scenarios.

Example healthcare retention model:

| Backup Frequency | Retention |
|------------------|----------|
| Weekly           | 12 weeks |
| Monthly          | 12 months |
| Yearly           | 7 years |

LTR ensures protection against:
- Historical corruption
- Legal investigations
- Regulatory audits

---

### Restore Validation Script

After a restore, critical data must be validated.

```sql
SELECT 
    (SELECT COUNT(*) FROM core.Referral) AS ReferralCount,
    (SELECT COUNT(*) FROM core.Patient) AS PatientCount,
    (SELECT COUNT(*) FROM core.PathwayEvent) AS EventCount;
```

Optional deeper integrity validation:

```sql
DBCC CHECKDB WITH NO_INFOMSGS;
```

---

## High Availability

### Regional High Availability (Built-In)

Azure SQL Database provides built-in high availability:

- Synchronous replica architecture
- Automatic failover
- Quorum-based commit
- 99.99% SLA (General Purpose tier and above)

No manual configuration of Always On Availability Groups is required.

Intra-region hardware failure results in:

- Near-zero data loss
- Automatic failover within seconds

---

## Disaster Recovery

### Cross-Region Strategy

To protect against regional outage, Active Geo-Replication or Auto-Failover Groups are used.

Recommended approach:

**Auto-Failover Group**

Benefits:

- Automatic cross-region failover
- DNS-based read/write listener endpoint
- Read-only secondary for reporting workloads
- Minimal application configuration change

---

### Architecture Model

Primary Region: UK South  
Secondary Region: UK West  

Primary database replicates asynchronously to secondary.

Failover Group provides:

- Read/Write listener endpoint
- Read-only endpoint for reporting queries

---

## RPO and RTO Targets

| Scenario                  | RPO (Data Loss) | RTO (Downtime) |
|---------------------------|----------------|---------------|
| Local hardware failure    | ~0 seconds     | < 30 seconds  |
| Regional outage           | < 5 seconds    | < 5 minutes   |
| User data corruption      | Configurable via PITR | Restore duration dependent |

These targets align with healthcare-style operational monitoring systems.

---

## Failover Testing Procedure

Planned failover test process:

1. Confirm secondary database health.
2. Initiate manual failover via Azure portal.
3. Validate application connectivity.
4. Execute validation query:

```sql
SELECT COUNT(*) FROM core.Referral;
```

5. Confirm no data inconsistency.
6. Document outcome.
7. Fail back if required.

Recommended test frequency: Quarterly.

---

## Encryption and Backup Protection

Azure SQL backups are:

- Encrypted at rest (Transparent Data Encryption enabled by default)
- Encrypted in transit (TLS)
- Protected by Azure-managed keys (or customer-managed keys if configured)

Backup security aligns with overall access control policies.

---

## Summary

The HCareOps resilience model leverages:

- Native automated Azure SQL backups
- Point-in-Time Restore
- Long-Term Retention
- Built-in regional high availability
- Auto-Failover Groups for cross-region disaster recovery

This architecture ensures:

- Minimal data loss
- Rapid recovery
- Regulatory alignment
- Enterprise-ready continuity design