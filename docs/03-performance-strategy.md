# Performance Strategy

## Workload Characteristics

The platform supports a mixed OLTP and operational reporting workload:

- High insert rate on core.Patient and core.Referral.
- Time-based monitoring queries for cancer 62-day and RTT 18-week breaches.
- Join-heavy queries across Referral, PathwayEvent and reference tables.

---

## Identified Bottleneck

The breach monitoring workload for the 62-day cancer pathway (CANCER_62) exhibited high logical I/O and CPU usage.

The original predicate used:

```sql
DATEDIFF(DAY, r.ReferralReceivedDt, GETUTCDATE()) > 60
```

This design introduced two performance issues:

1. Non-SARGable date filtering.
2. Key Lookup amplification in `core.PathwayEvent`.

---

## Baseline Query

```sql
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
```

---

## Baseline Execution Metrics

Measured using:

- Actual Execution Plan
- `sys.dm_exec_query_stats`
- `sys.dm_exec_sql_text`

| Metric        | Approximate Value |
|--------------|------------------|
| Logical Reads | ~144,000 |
| CPU Time      | ~213 ms |
| Elapsed Time  | ~793 ms |
| Rows Returned | ~22,000 |

### Plan Observations

- Nonclustered Index Seek on `PathwayEvent`
- Followed by **Key Lookup**
- Key Lookup responsible for ~50%+ of query cost
- Lookup repeated ~22,000 times

This is a classic lookup amplification pattern.

---

## Root Cause Analysis

The nonclustered index on `core.PathwayEvent` did not include `PathwayStatusId`.

For each qualifying row:

1. SQL Server performed an Index Seek.
2. Then performed a Key Lookup on the clustered index.
3. Repeated thousands of times.

This inflated logical reads and CPU usage.

---

## Optimisation Step 1 — Covering Index

To eliminate the lookup:

```sql
CREATE INDEX IX_PathwayEvent_Covering
ON core.PathwayEvent (ReferralId)
INCLUDE (PathwayStatusId);
```

### Rationale

- `ReferralId` supports join predicate.
- `PathwayStatusId` removes need to revisit clustered index.
- Converts Seek + Lookup into single covering Seek.

---

## Post-Index Metrics

| Metric        | Before | After |
|--------------|--------|-------|
| Logical Reads | ~144,000 | ~48,900 |
| CPU Time      | ~213 ms | ~73–77 ms |
| Elapsed Time  | ~793 ms | ~82–150 ms |

Logical reads reduced by approximately 66%.

Execution plan now shows:

- Single `Index Seek`
- No Key Lookup operator

---

## Optimisation Step 2 — SARGable Date Predicate

Original predicate:

```sql
DATEDIFF(DAY, r.ReferralReceivedDt, GETUTCDATE()) > 60
```

Rewritten as:

```sql
DECLARE @CutoffDate DATE = DATEADD(DAY, -60, GETUTCDATE());

WHERE r.PathwayTypeId = 1
  AND r.ReferralReceivedDt < @CutoffDate;
```

### Why This Matters

- Avoids function on indexed column.
- Enables efficient index usage.
- Improves scalability as data volume increases.
- Aligns with composite index design patterns.

---

## Enterprise DBA Perspective

This optimisation demonstrates:

- Execution plan interpretation
- Identification of Key Lookup amplification
- Covering index design using INCLUDE
- DMV-based performance validation
- SARGability awareness
- Measured performance improvement

This pattern is directly applicable to production OLTP reporting workloads in Azure SQL Database.

---

## Summary

The CANCER_62 breach monitoring query was optimised by:

1. Eliminating Key Lookup amplification using a covering index.
2. Rewriting a non-SARGable predicate.
3. Validating improvements via DMVs.

Result:

- ~66% reduction in logical reads
- Significant CPU reduction
- Improved plan stability
- Production-safe performance enhancement

---




